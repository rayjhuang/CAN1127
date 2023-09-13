// File		: fcp1112.v
// Description	: Huawei FCP/SCP transceiver 
// History	:
//  2018/1/22
//	create
//  2018/01/31
//	a. fix RX sync receive (rx_sync_rvd) generation and be renamed to new_rx_sync_rcvd
//	b. add tx buffer empty register to denote the FCPDAT is not wrote to TX
//	c. add two read-only bits to FCPCTL
//	      r_ctl[7] = tx_dbuf_keep_empty, tx data buffer is on empty
//	      r_ctl[6] = on_tx_trans, tx is on busy
//  2017/01/31
//	d. rx parity check is revised: just reporting to current data byte, 
//	   no accumulation for whole transcation (REV0131B)
//  2017/02/01
//	a. RX RESET Pattern is revised as: >=100UI (REV20180201)
//  2017/02/01
//	b. add fcp_en = FCPCTL[4]
//	c  FCPCTL[5] = idn = decounced DN
//  2019/06/25 rename to fcpegn
`define	IDLE		4'b0000
`define	RX_CHK 		4'b0001
`define	RX_PING		4'b0010
`define	RX_PING2	4'b1110
`define	RX_TRANS	4'b0011
`define	RX_RST		4'b0100
`define	TX_WO_S_WO_P	4'b1001
`define	TX_WO_S_WI_P	4'b1010
`define	TX_WI_S_WO_P	4'b1011
`define	TX_WI_S_WI_P	4'b1100

module fcpegn (
//input		comp_dn,	// D- comparator output
output		intr,		// interrupt (1T)
output		tx_en,		// TX enable, =1 during TX
output		tx_dat,		// TX bit data, =1, logic-1 data
output	[7:0]	r_dat,		// RX data buffer register
output	[7:0]	r_sta,		// fcp status register
output	[7:0]	r_ctl,		// fcp control register
output	[7:0]	r_msk,		// fcp status mask register
input	[4:0]	r_wr,		// fcp register write enable (1T)
input	[7:0]	r_wdat,
input		ff_idn, ff_chg, r_acc_int,
input		clk,
input		srstz,
output  [7:0]	r_tui
);

//-------------------------------------------------------------------
wire		idn = ff_idn, chg = ff_chg;

wire	[7:0]	setsta, clrsta,r_irq;
wire		updbufen;
wire	[7:0]	updbuf;
wire	[11:0]	r_shft_buf;

reg	[7:0]	r_dat0;

// UPDate Data BUFfer (r_dat) enable & muxed data buffer input
wire		upd_dbuf_en;
wire	[7:0]	upd_dbuf;

// 1MHz clock generator
reg	[3:0]	us_cnt; // us_cnt = 0 ~ 11
wire		sync; // NOT_OK
wire		us_cnt_ceiling; // 1MHz clock; duty=1/12

// UI interval count of symbols (ping/sync/bit) on DN, 1UI=160us
reg	[7:0]	ui_intv_cnt;


// TX/RX data buffer (sharing for TX & RX)
wire	[1:0]	sync_len; // sync bits
reg	[1:0]	sync_length;
wire	[11:0]	trans_buf; // transcation buffer
reg	[11:0]	rxtx_buf;
wire		tran_buf_upd;

// the RX controls
wire		rx_bit_shift;
wire		rx_pbit_shift; // RX Parity shift in & comparison enable (1T)
reg		rx_byte_pchk;  // RX Parity check status by per data byte
//wire		rx_sync_check; // RX Sync(Start/End)-toggle receiving enable
//reg	[1:0]	rx_sync_cnt; // RX Sync Bits Counter (thermal meter count), count to 2'b11 represent sync received
//wire		rx_sync_rcvd; // RX Sync Received (1T)
wire		rx_ping_rcvd; // RX Ping Received (1T flag)
wire		rx_byte_rcvd; // RX Data Byte Received (1T flag)
wire		rx_parity_err; // RX Parity CHecK STAtus
wire		rx_reset; // master send 100UI DN=1 reset pulse
reg	[1:0]	new_rx_sync_cnt; // RX sync edges counter
wire		new_rx_sync_rcvd; // new RX sync received flag
wire		new_rx_sync_cnt_en; // new RX sync edges counter enable; 1-> +1 accumulation
wire		new_rx_sync_cnt_clr; // new RX sync edges counter clear; 1-> to clear

// the TX controls
wire		tx_end; // complete the TX transcation
wire		tx_dbuf_empty; // TX data buffer is empty (data was captured, prepare to write next byte for transcation)
wire		tx_buf_reload; // TX buffer reload enable after 1st wrote
wire		on_tx_trans; // during FCP TX transcation
wire		tx_bit_shift;
reg		tx_dbuf_keep_empty;

// state machine
reg	[3:0]	fcp_state;
reg	[6:0]	symb_cnt;
wire		is_idle,
		is_rx_chk,
		is_rx_ping,
		is_rx_ping2,
		is_rx_trans,
		is_rx_rst,
		is_tx_wo_s_wo_p,
		is_tx_wo_s_wi_p,
		is_tx_wi_s_wo_p,
		is_tx_wi_s_wi_p;
		
//-------------------------------------------------------------------

//-------------------------------------------------------------------
// DN debounce
/*
dn_dbnc u0_cmpdn_db (
	.i_org		(comp_dn),
	.o_dbc		(idn),		// debounced D-
	.o_chg		(chg),
	.clk		(clk),
	.rstz		(srstz)
);
*/
wire fall = idn & chg;
//-------------------------------------------------------------------

//-------------------------------------------------------------------
// Registers
//---------------------------------
// Control (0x94)
wire	[1:0]	ftx_mode;
wire		ftx_sync, ftx_parity;
wire	[7:0]	r_ctl_reg;
glreg #(8,'h00) u0_fcpctl (
	.clk		(clk),
	.arstz		(srstz),
	.we		(r_wr[0]),
	.wdat		(r_wdat),
	.rdat		(r_ctl_reg)
);

assign r_ctl = {tx_dbuf_keep_empty, on_tx_trans, idn, r_ctl_reg[4:0]}; 

assign fcp_en     = r_ctl[4]; 
	/*-----------------------------------*/
	/* defintion                         */
	/*-----------------------------------*/
	/*
	   fcp_en  |  description | operation
	  ---------+--------------+-----------------------------------------------------------------
	   0       |  disable     | stay on idle state 
	   1       |  enable      | idle state -> tx or rx state
	   1 -> 0  |  disable     | stay on rx/tx state to complete transcation then to idle state
	*/
	

assign ftx_parity = r_ctl[1];
assign ftx_sync   = r_ctl[0];

	/*-----------------------------------*/
	/* defintion                         */
	/*-----------------------------------*/
	/*
	   ftx_sync  ftx_parity  |  definition (for TX data byte transcation)
	  -----------------------+-------------------------------------------------------------------------
	      0           0      |  w/o leading sync and w/o tailing parity bit (for 1st byte of pure Ping)
	      0           1      |  w/o leading sync and w/i tailing parity bit (for 2nd byte of Ping) -- remark: end of transcation
	      1           0      |  w/i leading sync and w/o tailing parity bit (for 1st byte of Ping after data byte transmitted)
	      1           1      |  w/i leading sync and w/i tailing parity bit (for normal data byte)
	*/
assign ftx_mode = {ftx_sync, ftx_parity};


//---------------------------------
// Status (0x95)
glsta u0_fcpsta (
	.clk		(clk),
	.arstz		(srstz),
	.rst0		(1'h0),
	.set2		(setsta),
	.clr1		(clrsta),
	.rdat		(r_sta)
`ifdef CAN1110
`else
	,
	.irq		(r_irq)
`endif
);

assign setsta = {
		r_acc_int,
		rx_reset,
		rx_parity_err,
		rx_pbit_shift,//2019/4/2 b1: rx_byte_rcvd;b2:rx_pbit_shift
		new_rx_sync_rcvd,
		rx_ping_rcvd,
		tx_dbuf_empty,
		tx_end
		};

assign clrsta = { {8{r_wr[1]}} & r_wdat };

//---------------------------------
// Mask (0x96)
glreg u0_fcpmsk (
	.clk		(clk),
	.arstz		(srstz),
	.we		(r_wr[2]),
	.wdat		(r_wdat),
	.rdat		(r_msk)
);

`ifdef CAN1110
assign intr = |(r_msk & setsta);
`else
assign intr = |(r_msk & r_irq );
`endif

//---------------------------------
// Data (0x97)
glreg u0_fcpdat (
	.clk		(clk),
	.arstz		(srstz),
	.we		(upd_dbuf_en),
	.wdat		(upd_dbuf),
	.rdat		(r_dat)
);

assign upd_dbuf_en = r_wr[3] | rx_byte_rcvd;
assign upd_dbuf    = r_wr[3] ? r_wdat : rxtx_buf[7:0]; // s2p & p2s buffer

//-------------------------------------------------------------------
// us_cnt = 0 ~ 11; 1MHz clock generator -- 1us cycle (12MHz -- divide 12 --> 1MHz)
assign us_cnt_ceiling = (us_cnt==4'd11) && !is_idle;
assign sync = (r_wr[3] & is_idle) | (tx_bit_shift);

always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    us_cnt <= 4'd0;
  else
    if (sync | us_cnt_ceiling | is_idle)
      us_cnt <= 4'd0;
    else
      us_cnt <= us_cnt + 1;
end

//-------------------------------------------------------------------
// adaptive RX 20180419
parameter [7:0] FCP_UI = 'd160; // us
parameter [6:0] PING_MIN = 'd12; // UI
parameter [6:0] PING_MAX = 'd20; // UI
reg [5:0] catch_sync;
wire [7:0] adp_rx_ui;
wire [7:0] rx_ui_1_2 = adp_rx_ui >> 1; // 1/2 UI
wire [7:0] rx_ui_1_4 = adp_rx_ui >> 2; // 1/4 UI
wire [7:0] rx_ui_1_8 = adp_rx_ui >> 3; // 1/8 UI
wire [7:0] rx_ui_3_8 = rx_ui_1_4 + rx_ui_1_8; // 3/8 UI
wire [7:0] rx_ui_5_8 = rx_ui_1_2 + rx_ui_1_8; // 5/8 UI
always @ (posedge clk or negedge srstz)begin 
   if(!srstz)
      catch_sync<='d40;
   else if(is_rx_chk & chg)
      catch_sync <= ui_intv_cnt;
end 

//-------------------------------------------------------------------
// adaptive TX 20191122
wire [15:0] catch_ping = // us
    (ui_intv_cnt>'d80) ? {9'h0,symb_cnt-1} * FCP_UI + ui_intv_cnt // count to FCP_UI if is_rx_ping
                       : {9'h0,symb_cnt  } * FCP_UI + ui_intv_cnt;
wire [15:0] ui_by_ping = (catch_ping >> 4 ) + catch_ping[3]; // round, us
wire [7:0] ui_delta = ui_by_ping > FCP_UI+'d60 ? +60
                    : ui_by_ping < FCP_UI-'d60 ? -60 : ui_by_ping-FCP_UI;
wire r_ui_by_sync = r_tui[7];
wire [7:0] r_ping_ui = {r_tui[6],r_tui[6:0]}; // 2's complement signed
wire [7:0] adp_tx_ui = FCP_UI + r_ping_ui;
wire [7:0] adp_tx_1_4 = (adp_tx_ui >> 2 ) + adp_tx_ui[1]; // round, us
wire [7:0] tui_wdat = r_wr[4] ? r_wdat : {r_tui[7],ui_delta[6:0]};
wire tui_upd = r_wr[4]
             | is_rx_ping & chg
                          & (symb_cnt>'h9); // a mal-format byte may cause IDLE accidentally
                                            // (ex. lack of parity bit)
glreg u0_fcptui (
	.clk		(clk),
	.arstz		(srstz),
	.we		(tui_upd),
	.wdat		(tui_wdat),
	.rdat		(r_tui) // {1-bit sel, 7-bit signed}
);

assign adp_rx_ui = r_ui_by_sync ? {catch_sync,2'h0} : adp_tx_ui;

//-------------------------------------------------------------------
// UI interval counter
always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    ui_intv_cnt <= 8'd0;
  else
    if ((chg & ~on_tx_trans) | (sync))  // ++
      ui_intv_cnt <= 8'd1;
    else
      if (is_rx_trans && symb_cnt>'h9 && idn) // RX_TRANS -> RX_PING2
        ui_intv_cnt <= 8'd81;
      else
      if (us_cnt_ceiling)
        if (ui_intv_cnt==(is_rx_trans ?adp_rx_ui
                         :is_rx_ping  ?FCP_UI :adp_tx_ui))
          ui_intv_cnt <= 8'd1;
        else
          ui_intv_cnt <= ui_intv_cnt + 1;
      else
        ui_intv_cnt <= ui_intv_cnt;
end

//-------------------------------------------------------------------
assign trans_buf_upd = r_wr[3] & is_idle |
		       tx_buf_reload |
		       tx_bit_shift | 
		       rx_bit_shift;

assign sync_len = (r_wr[3] & is_idle) ? ((ftx_mode[1]==1) ? ((idn==r_wdat[7]) ? 2'b10 : 2'b01) : 2'b00) :
	          (tx_buf_reload)     ? ((ftx_mode[1]==1) ? ((idn==r_dat[7] ) ? 2'b10 : 2'b01) : 2'b00) : 2'b00;

always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    sync_length <= 2'd0;
  else
    if (r_wr[3] & is_idle | tx_buf_reload)
      sync_length <= sync_len;
    else
      sync_length <= sync_length;
end

wire	[7:0]	txbuf;
assign txbuf = (r_wr[3] & is_idle) ? r_wdat  
	                           : (tx_buf_reload) ?  r_dat : 8'd0 ;

assign trans_buf = (r_wr[3] & is_idle | tx_buf_reload) ?
		            ((ftx_mode==2'b00) ? {txbuf,4'b0000} :
			     (ftx_mode==2'b01) ? {txbuf,4'b0000} :
			     (ftx_mode==2'b10) ? ((sync_len==2'd2) ? {~txbuf[7], txbuf[7],~txbuf[7],txbuf,1'b0}
								   : { txbuf[7],~txbuf[7], txbuf,2'b00}) :
					         ((sync_len==2'd2) ? {~txbuf[7], txbuf[7],~txbuf[7],txbuf,~(^(txbuf))}
								   : { txbuf[7],~txbuf[7], txbuf,~((^txbuf)),1'b0})) :
			    (rxtx_buf<<1'b1 | idn & ~on_tx_trans);

always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    rxtx_buf <= 12'd0;
  else
    if (trans_buf_upd)
      rxtx_buf <= trans_buf;
    else
      rxtx_buf <= rxtx_buf;
end

//-------------------------------------------------------------------
// RX control/status
// RX data bit shift-in enable (1T)
assign rx_bit_shift = ((is_rx_trans) &
		       (symb_cnt>=0 & symb_cnt<=7'd7) &
		       (ui_intv_cnt==rx_ui_1_2) & (us_cnt_ceiling));

// RX Parity shift in & comparison enable (1T)
assign rx_pbit_shift = ((is_rx_trans) & 
			(symb_cnt==7'd8) &
			(ui_intv_cnt==rx_ui_1_2) & (us_cnt_ceiling));

// RX Sync(Start/End)-toggle receiving enable
//assign rx_sync_check = ((
//			 is_rx_trans) & 
//		        (ui_intv_cnt>=8'd35 & ui_intv_cnt<=8'd45) & (chg));

// RX Ping Received (1T flag)
assign rx_ping_rcvd = ((is_rx_ping | is_rx_ping2) &
		       (symb_cnt>=PING_MIN && symb_cnt<=PING_MAX) &
		       (fall));
//		       (idn==1'b0) &
//		       (ui_intv_cnt==8'd144) & (us_cnt_ceiling));

// RX Data Byte Received (1T flag)
assign rx_byte_rcvd = ((is_rx_trans) &
		       (symb_cnt==7'd8) &
		       (ui_intv_cnt==rx_ui_5_8) & (us_cnt_ceiling));

// RX Sync Received (1T)
//assign rx_sync_rcvd = ((is_rx_trans) & 
//		       (rx_sync_check) &
//		       (rx_sync_cnt==2'b01));

// Master Send 100UI DX=1 reset pulse
assign rx_reset = ((is_rx_rst) &
//		   (symb_cnt>=7'd100) & 	// (REV20180201)
//		   (symb_cnt>=7'd90)  & 	// (REV20181108)
//		   (symb_cnt>=7'd67)  & 	// (REV20191129)
		   (symb_cnt>=7'd80)  &         // (REV20191210)
		   (fall));
		   //(ui_intv_cnt==8'd144) & (us_cnt_ceiling));


// RX Sync Bits Counter (thermal meter count), count to 2'b11 then sync received is confirmed
//always @ (posedge clk or srstz) begin
//  if (!srstz)
//    rx_sync_cnt <= 2'b00;
//  else
//    if (symb_cnt!=7'd1)
//      if (rx_sync_check)
//	rx_sync_cnt <= {rx_sync_cnt[0],1'b1};
//      else
//	rx_sync_cnt <= rx_sync_cnt;
//    else
//      rx_sync_cnt <= 2'b00;
//end

//--------------------------------------------

assign new_rx_sync_cnt_en = ((is_idle) & (chg)) |
                            ((is_rx_chk |
                              is_rx_trans) &
                             (symb_cnt==7'd0 | symb_cnt==7'd1) &
                             (ui_intv_cnt>=(rx_ui_1_4-'h8) & ui_intv_cnt<=(rx_ui_1_4+'h8)) & (chg)) |
                            ((is_rx_trans) &
                             (symb_cnt==7'd9) &
                             (chg | fall)); // remarked: check "fall" if parity bit=1
                                            //           check "chg", if parity bit=0

assign new_rx_sync_cnt_clr = (symb_cnt>=7'd2 & symb_cnt<=7'd8) | (is_rx_ping);

always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    new_rx_sync_cnt <= 2'b00;
  else
    if (new_rx_sync_cnt_en)
      new_rx_sync_cnt <= new_rx_sync_cnt + 1;
    else
      if (new_rx_sync_cnt_clr)
        new_rx_sync_cnt <= 2'd0;
      else
	new_rx_sync_cnt <= new_rx_sync_cnt;
end

assign new_rx_sync_rcvd = (is_rx_trans) & (new_rx_sync_cnt==2'b10) & chg;

//--------------------------------------------

// RX Parity CHecK Status
always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    rx_byte_pchk <= 1'b0;
  else
    if (rx_pbit_shift) // (REV20180131)
      rx_byte_pchk <= idn ^ (~(^(rxtx_buf[7:0])));
    else
      rx_byte_pchk <= 1'b0;
end
/*
    if (is_idle)
      rx_byte_pchk <= 1'b0;
    else
      if (rx_pbit_shift)
        rx_byte_pchk <= rx_byte_pchk | (idn ^ (~(^(rxtx_buf[7:0]))));
      else
	rx_byte_pchk <= rx_byte_pchk;
*/

assign rx_parity_err = rx_byte_pchk; // (REV20180131)
//assign rx_parity_err = rx_byte_pchk & 
//		       new_rx_sync_rcvd;

//-------------------------------------------------------------------
// process the TX controls

assign tx_en = on_tx_trans;

assign tx_dat = rxtx_buf[11];

assign tx_end = 
			 (tx_dbuf_keep_empty) & 
			 ((is_tx_wo_s_wo_p & (symb_cnt==({5'd0,sync_length}+7'd7))  |
			   is_tx_wo_s_wi_p & (symb_cnt==({5'd0,sync_length}+7'd8))  |
			   is_tx_wi_s_wo_p & (symb_cnt==({5'd0,sync_length}+7'd8)) |
			   is_tx_wi_s_wi_p & (symb_cnt==({5'd0,sync_length}+7'd9))) & 
			   (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling)); 

assign tx_dbuf_empty = 
			((is_tx_wo_s_wo_p | is_tx_wo_s_wi_p) & 
			 (symb_cnt==7'd0) &
			 (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling)) | 
			((is_tx_wi_s_wo_p | is_tx_wi_s_wi_p) &
			 (symb_cnt==7'd0) &
			 (ui_intv_cnt==adp_tx_1_4) & (us_cnt_ceiling));

assign tx_buf_reload = 
			 (~tx_dbuf_keep_empty) & 
			 ((is_tx_wo_s_wo_p & (symb_cnt==({5'd0,sync_length}+7'd7))  |
			   is_tx_wo_s_wi_p & (symb_cnt==({5'd0,sync_length}+7'd8))  |
			   is_tx_wi_s_wo_p & (symb_cnt==({5'd0,sync_length}+7'd8))  |
			   is_tx_wi_s_wi_p & (symb_cnt==({5'd0,sync_length}+7'd9))) &
			   (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling));
assign on_tx_trans = 
			 (is_tx_wo_s_wo_p  |
			  is_tx_wo_s_wi_p  |
			  is_tx_wi_s_wo_p  |
			  is_tx_wi_s_wi_p);
assign tx_bit_shift = 
			 ((is_tx_wi_s_wo_p |
			   is_tx_wi_s_wi_p) &
			  (symb_cnt <=sync_length) &
			  (ui_intv_cnt==adp_tx_1_4) & (us_cnt_ceiling)) |
			 ((is_tx_wo_s_wo_p) & 
			  (symb_cnt >=sync_length) & (symb_cnt < ({5'd0,sync_length}+7'd7)) &
			  (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling)) |
			 ((is_tx_wi_s_wi_p) &
			  (symb_cnt >=sync_length) & (symb_cnt < ({5'd0,sync_length}+7'd9)) &
			  (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling)) |
			 ((is_tx_wi_s_wo_p) &
			  (symb_cnt >=sync_length) & (symb_cnt < ({5'd0,sync_length}+7'd8)) & 
			  (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling)) |
			 ((is_tx_wo_s_wi_p) &
			  (symb_cnt >=sync_length) & (symb_cnt < ({5'd0,sync_length}+7'd8)) & 
			  (ui_intv_cnt==adp_tx_ui) & (us_cnt_ceiling));

always @ (posedge clk or negedge srstz) begin
  if (!srstz)
    tx_dbuf_keep_empty <= 1'b1;
  else
    if (r_wr[3])
      tx_dbuf_keep_empty <= 1'b0;
    else
      if (tx_dbuf_empty)
        tx_dbuf_keep_empty <= 1'b1;
      else
        tx_dbuf_keep_empty <= tx_dbuf_keep_empty;
end
			
//-------------------------------------------------------------------
// state machine
assign is_idle         = (fcp_state==`IDLE);
assign is_rx_chk       = (fcp_state==`RX_CHK);
assign is_rx_ping      = (fcp_state==`RX_PING);
assign is_rx_ping2     = (fcp_state==`RX_PING2);
assign is_rx_trans     = (fcp_state==`RX_TRANS);
assign is_rx_rst       = (fcp_state==`RX_RST);
assign is_tx_wo_s_wo_p = (fcp_state==`TX_WO_S_WO_P);
assign is_tx_wo_s_wi_p = (fcp_state==`TX_WO_S_WI_P);
assign is_tx_wi_s_wo_p = (fcp_state==`TX_WI_S_WO_P);
assign is_tx_wi_s_wi_p = (fcp_state==`TX_WI_S_WI_P);

reg rx_trans_8_chg;
   always @(posedge clk)
      if (chg)
         rx_trans_8_chg <= is_rx_trans && symb_cnt=='h8 && !rx_trans_8_chg;

always @ (posedge clk or negedge srstz) begin
  if (!srstz) begin
    fcp_state <= `IDLE;
    symb_cnt  <= 0;
  end
  else begin
    case (fcp_state)
      //------------------------------------------------------------------
      `IDLE : begin
	 if (!fcp_en) 
	   fcp_state <= `IDLE;
	 else // else if (fcp_en)
	   if (chg & symb_cnt==7'd0) // idn = 1 (from 0)
	     fcp_state <= `RX_CHK;
	   else
	     if (r_wr[3]) // FCPDATA is wrote
	       case (ftx_mode) // ftx_mode = {fcp_sync, fcp_parity}
	         2'b00: fcp_state <= `TX_WO_S_WO_P; // TX w/o sync & w/o parity
	         2'b01: fcp_state <= `TX_WO_S_WI_P; // TX w/o sync & w/i parity
	         2'b10: fcp_state <= `TX_WI_S_WO_P; // TX w/i sync & w/o parity
	         2'b11: fcp_state <= `TX_WI_S_WI_P; // TX w/i sync & w/i parity
	       endcase
	     else
	       fcp_state <= `IDLE;
	 symb_cnt <= 0;
      end // `IDLE
      //------------------------------------------------------------------
      `RX_CHK  :  begin // to check (decide) master send ping/reset or sync
	if (idn) begin
	  if (symb_cnt==7'd2) begin // confirm master is on sending ping
	    fcp_state <= `RX_PING;
	    symb_cnt  <= 0;
	  end
	  else begin // idn=1 still met, stay on same state
	    fcp_state <= `RX_CHK;
	    if ((ui_intv_cnt==8'd20 | ui_intv_cnt==8'd60) & us_cnt_ceiling) // sample idn at 20us & 60us
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  end
	end // if (idn)
	else begin
	  if (symb_cnt==7'd1) // master is on sending sync
	    fcp_state <= `RX_TRANS;
	  else
	    fcp_state <= `IDLE;
	  symb_cnt  <= 0;
	end // else if (idn)
      end // `RX_CHK
      //------------------------------------------------------------------
      `RX_PING2,
      `RX_PING : begin
	if (idn) begin
	  if (rx_ping_rcvd) begin
	    fcp_state <= `IDLE;
	    symb_cnt  <= 7'd0;
	  end
	  if (symb_cnt<=PING_MAX) begin
//	    fcp_state <= `RX_PING;
	    if (ui_intv_cnt==8'd80 & us_cnt_ceiling) // sample the idn at 80us (1/2 UI)
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  end // if (symb_cnt<7'd17)
	  else begin
	    fcp_state <= `RX_RST; // PING is as long as 17 UI, to check whether master will reset slave
	    symb_cnt  <= symb_cnt;
	  end // else if (symb_cnt<7'd17)
	end // if (idn)
	else begin
//	  if (symb_cnt == 7'd17) begin
	    fcp_state <= `IDLE; // if symb_cnt==16 and fall=1 --> master is received, rx_ping_rcvd=1
	    symb_cnt  <= 7'd0;
//	  end
//	  else begin
//	    fcp_state <= `RX_PING; // if symb_cnt==16 and fall=1 --> master is received, rx_ping_rcvd=1
//	    if (ui_intv_cnt==8'd80 & us_cnt_ceiling) // sample the idn at 80us (1/2 UI)
//	      symb_cnt <= symb_cnt + 1;
//	    else
//	      symb_cnt <= symb_cnt;
//	  end
	end // end if (idn)
      end // `RX_PING
      //------------------------------------------------------------------
      `RX_TRANS : begin // master sends sync/data+parity/ping
	if (symb_cnt<=7'd8) begin
	  fcp_state <= `RX_TRANS;
	  if (chg && ui_intv_cnt < rx_ui_3_8 && rx_trans_8_chg
                  && ui_intv_cnt > rx_ui_1_8
                  && symb_cnt > 7'h7) // early-sync, no sync-int.
	    symb_cnt <= 7'h0;
          else
	  if (ui_intv_cnt==rx_ui_1_2 & us_cnt_ceiling)
	    symb_cnt <= symb_cnt + 1;
	  else
	    symb_cnt <= symb_cnt;
	end // if (symb_cnt <= 7'd8)
	else begin
	  if (symb_cnt==7'd9) begin // master is on sending parity bit
	    fcp_state <= `RX_TRANS;
	    //if (rx_sync_cnt>=2'd1) // sync or end has received / is on receiving (edited)
	    if (new_rx_sync_cnt>=2'd1) // sync or end has received / is on receiving
	      symb_cnt <= 7'd0;
	    else
	      if (ui_intv_cnt==rx_ui_1_2 & us_cnt_ceiling)
		symb_cnt <= symb_cnt+1;
	      else
		symb_cnt <= symb_cnt;
	  end // if (symb_cnt==7'd9)
	  else begin // received bits >= 10UI, master is on sending ping or an error is encountered
	    if (idn) begin // check symb_cnt>=10 and idn=1 --> to check wether ping is sending
	      fcp_state <= `RX_PING2;
	      symb_cnt  <= symb_cnt;
	    end // if (idn)
	    else begin  // symb_cnt>=10 and idn=0 --> an error case
	      fcp_state <= `IDLE;
	      symb_cnt  <= 7'd0;
	    end // else if (idn)
	  end // else if (symb_cnt==7'd9)
	end // else if (symb_cnt<=7'd8)
      end // `RX_TRANS
      //------------------------------------------------------------------
      `RX_RST : begin
	if (idn) begin
	  fcp_state <= `RX_RST;
	  if (symb_cnt<7'd100) // & symb_cnt<=7'd100) // (REV20180201)
	    if (ui_intv_cnt==8'd80 & us_cnt_ceiling)
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  else
	    symb_cnt <= symb_cnt;
	end // if (idn)
	else begin
	  fcp_state <= `IDLE;
	  symb_cnt  <= 7'd0;
	end //else if (idn)
      end // `RX_RST
      //------------------------------------------------------------------
      `TX_WO_S_WO_P : begin
	case (symb_cnt) 
	  7'd0, 7'd1, 7'd2, 7'd3, 7'd4, 7'd5, 7'd6 : begin
	    fcp_state <= `TX_WO_S_WO_P;
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling)
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  end
	  7'd7: begin
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling) begin
	      if (tx_dbuf_keep_empty)
		fcp_state <= `IDLE;
	      else
	        case (ftx_mode)
		  2'b00: fcp_state <= `TX_WO_S_WO_P;
		  2'b01: fcp_state <= `TX_WO_S_WI_P;
		  2'b10: fcp_state <= `TX_WI_S_WO_P;
		  2'b11: fcp_state <= `TX_WI_S_WI_P;
	        endcase
	      symb_cnt <= 7'd0;
	    end
	    else begin
	      fcp_state <= `TX_WO_S_WO_P;
	      symb_cnt  <= symb_cnt;
	    end
	  end
	  default : begin
	    fcp_state <= `TX_WO_S_WO_P;
	    symb_cnt  <= symb_cnt;
	  end
	endcase
      end // `TX_WO_S_WO_P
      //------------------------------------------------------------------
      `TX_WO_S_WI_P : begin
	case (symb_cnt)
	  7'd0, 7'd1, 7'd2, 7'd3, 7'd4, 7'd5, 7'd6, 7'd7 : begin
	    fcp_state <= `TX_WO_S_WI_P;
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling)
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  end
	  7'd8 : begin
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling) begin
	      if (tx_dbuf_keep_empty)
	        fcp_state <= `IDLE; // regarded as single TX Ping sent complete
	      else
	        case (ftx_mode)
		  2'b00: fcp_state <= `TX_WO_S_WO_P;
		  2'b01: fcp_state <= `TX_WO_S_WI_P;
		  2'b10: fcp_state <= `TX_WI_S_WO_P;
		  2'b11: fcp_state <= `TX_WI_S_WI_P;
	        endcase
	      symb_cnt  <= 7'd0;
	    end
	    else begin
	      fcp_state <= `TX_WO_S_WI_P;
	      symb_cnt  <= symb_cnt;
	    end
	  end
	  default : begin
	    fcp_state <= `TX_WO_S_WI_P;
	    symb_cnt  <= symb_cnt;
	  end
	endcase
      end // `TX_WO_S_WI_P
      //------------------------------------------------------------------
      `TX_WI_S_WO_P : begin
	if (symb_cnt <= {5'd0,sync_length}) begin
	  fcp_state <= `TX_WI_S_WO_P;
	  if (ui_intv_cnt==adp_tx_1_4 & us_cnt_ceiling)
	    symb_cnt <= symb_cnt+1;
	  else
	    symb_cnt <= symb_cnt;
	end
	else begin
	  if (symb_cnt <= ({5'd0,sync_length}+7'd7)) begin
	    fcp_state <= `TX_WI_S_WO_P;
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling)
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  end
	  else begin
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling) begin
	      if (tx_dbuf_keep_empty)
		fcp_state <= `IDLE;
	      else
	        case (ftx_mode)
		  2'b00: fcp_state <= `TX_WO_S_WO_P;
		  2'b01: fcp_state <= `TX_WO_S_WI_P;
		  2'b10: fcp_state <= `TX_WI_S_WO_P;
		  2'b11: fcp_state <= `TX_WI_S_WI_P;
	        endcase
	      symb_cnt  <= 7'd0;
	    end
	    else begin
	      fcp_state <= `TX_WI_S_WO_P;
	      symb_cnt  <= symb_cnt;
	    end
	  end
	end
      end // `TX_WI_S_WO_P
      //------------------------------------------------------------------
      `TX_WI_S_WI_P : begin
	if (symb_cnt <= {5'd0,sync_length}) begin
	  fcp_state <= `TX_WI_S_WI_P;
	  if (ui_intv_cnt==adp_tx_1_4 & us_cnt_ceiling)
	    symb_cnt <= symb_cnt+1;
	  else
	    symb_cnt <= symb_cnt;
	end
	else begin
	  //if ((symb_cnt>{5'd0,sync_length}) & (symb_cnt <= ({5'd0,sync_length}+7'd8))) begin
	  if (symb_cnt <= ({5'd0,sync_length}+7'd8)) begin
	    fcp_state <= `TX_WI_S_WI_P;
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling)
	      symb_cnt <= symb_cnt + 1;
	    else
	      symb_cnt <= symb_cnt;
	  end
	  else begin
	    if (ui_intv_cnt==adp_tx_ui & us_cnt_ceiling) begin
	      if (tx_dbuf_keep_empty)
		fcp_state <= `IDLE;
	      else
	        case (ftx_mode)
		  2'b00: fcp_state <= `TX_WO_S_WO_P;
		  2'b01: fcp_state <= `TX_WO_S_WI_P;
		  2'b10: fcp_state <= `TX_WI_S_WO_P;
		  2'b11: fcp_state <= `TX_WI_S_WI_P;
	        endcase
	      symb_cnt <= 7'd0;
	    end
	    else begin
	      fcp_state <= `TX_WI_S_WI_P;
	      symb_cnt  <= symb_cnt;
	    end
	  end
	end
      end // `TX_WI_P_WI_P
      //------------------------------------------------------------------
      default : begin
	fcp_state <= `IDLE;
	symb_cnt  <= 7'd0;
      end
    endcase
  end
end

endmodule

//===================================================================
//-- DN (compator output) debunce
/*
module dn_dbnc (
input		i_org,
output		o_dbc, o_chg,
input		clk,
input		rstz
);

reg	[1:0]	d_org;

always @ (posedge clk or negedge rstz) begin
  if (!rstz)
    d_org <= 2'b00;
  else
    d_org <= {d_org[0], i_org};
end

assign o_dbc = d_org[1];
assign o_chg = ^d_org;

endmodule
*/
