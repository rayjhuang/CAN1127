
module mpb #(
// =============================================================================
// external SFR master
// two masters can/shall not work together
// 2016/11/25 new created, Ray Huang, rayhuang@canyon-semi.com.tw
// 2018/01/19 function summary
//            1. primary bus (peripheral masters, i.e. I2CSLV/UPDPRL)
//            2. secondary bus
//               a) ESFRM (external SFR master, a master to MCU)
//               b) PG0 access
// 2021/02/04 move mpb.v (memory peripheral bus) 
//            1. saperate internal/external memory of MCU
//               ESFRM (HWI2C/MODE0)
//                  SFR -> MCU esfrm
//                  PG0 -> IDAT/XDAT
//               MCU -> IDAT (idat_*)
//               MCU -> XDAT (mem*)
//            2. read contorl/address selected by pre-state
//               write contorl/address/data selected by current state
//               delay PG0 IDAT access if MCU IDAT access
//               delay MCU XDAT access if PG0 XDAT access
//            3. BIST control
// 2021/03/11 add REGX at 0xFF80
//            1. no DMA
//            2. no BIST
// 2021/04/26 add XACC_WAIT_IACC=1 for CAN1124
//            modify hit range of XDAT and DMA
// ALL RIGHTS ARE RESERVED
// =============================================================================
parameter XACC_WAIT_IACC = 1 // IDAT and XDAT in a same SRAM
)(
input	[1:0]	i_rd,
		i_wr,
input	[7:0]	wdat0, wdat1,
		addr0, addr1,
input		r_i2c_attr,
// -----------------------------------------------------------------------------
output		esfrm_oe, esfrm_we, sfrack,
output	[7:0]	esfrm_wdat,
output	[6:0]	esfrm_adr,
input	[7:0]	mcu_esfr_rdat,
		delay_rdat,
input		delay_rrdy,
output		esfrm_rrdy,
output	[7:0]	esfrm_rdat,
input		channel_sel,
input	[3:0]	r_pg0_sel,
// DMA master (XDAT-only) ------------------------------------------------------
input		dma_w, dma_r,
input	[10:0]	dma_addr,
input	[7:0]	dma_wdat,
output		dma_ack,
// MCU memory bus --------------------------------------------------------------
input	[15:0]	memaddr, memaddr_c,
input		memwr, memrd, memrd_c, cpurst,
input	[7:0]	memdatao,
output		memack,
output		hit_xd, hit_xr, // hit XDATA (XDAT, REGX)
		hit_ps, hit_ps_c,
input		idat_r, idat_w,
input	[7:0]	idat_adr, idat_wdat,
// SRAM control ----------------------------------------------------------------
output		iram_ce,  xram_ce,  regx_re,
		iram_we,  xram_we,  regx_we,
output	[10:0]	iram_a,   xram_a,
output	[7:0]	iram_d,   xram_d,
input	[7:0]	iram_rdat,xram_rdat,regx_rdat,
input		bist_en,
		bist_wr,
input	[10:0]	bist_adr,
input	[7:0]	bist_wdat,
input		bist_xram,
// -----------------------------------------------------------------------------
input		mclk, srstz
);
   wire dma_hit_x  = dma_addr <11'h500; // dma_addr didn't reach REGX
   assign hit_xd   = memaddr  <16'h0500; assign hit_xr   = memaddr  >=16'hff80;
     wire hit_xd_c = memaddr_c<16'h0500;   wire hit_xr_c = memaddr_c>=16'hff80;
   assign hit_ps   =(memaddr  <16'h4080) &~cpurst;
   assign hit_ps_c =(memaddr_c<16'h4080) &~cpurst;

   wire ramacc = idat_w | idat_r; // highest priority

   // XDAT=bank0~9, IDAT=bank10~11, REGX=bank12
   wire [3:0] pg0_sel = r_pg0_sel<='d12 ? r_pg0_sel : {2'h0,r_pg0_sel[1:0]};
   wire sfr_wrpro = r_pg0_sel>'d12 & r_i2c_attr; // SFR write protect

   assign esfrm_wdat =         i_wr[1] ?wdat1 :wdat0;
   wire [7:0] muxadr = i_rd[1]|i_wr[1] ?addr1 :addr0;
   wire esfrm_hit_pg0 = muxadr[7]=='h0; // PG0 access from ESFRM
   assign esfrm_adr = muxadr[6:0];
   assign esfrm_oe = ~esfrm_hit_pg0 & (|i_rd),
          esfrm_we = ~esfrm_hit_pg0 & (|i_wr) & ~sfr_wrpro,
          sfrack = ~(esfrm_oe | esfrm_we);

   reg pg0_rdwait, pg0_wrwait; // PG0 access may wait iff hit IDATA
   wire pg0_rd = esfrm_hit_pg0 & (|i_rd) | pg0_rdwait;
   wire pg0_wr = esfrm_hit_pg0 & (|i_wr) & ~r_i2c_attr | pg0_wrwait;
   wire pg0_ird    = pg0_rd & pg0_sel<='hb & pg0_sel>='ha,
        pg0_iwr    = pg0_wr & pg0_sel<='hb & pg0_sel>='ha,
        pg0_xrd    = pg0_rd & pg0_sel<'ha,
        pg0_xwr    = pg0_wr & pg0_sel<'ha,
        pg0_rrd    = pg0_rd & pg0_sel=='hc,
        pg0_rwr    = pg0_wr & pg0_sel=='hc,
        pg0_iacc   = pg0_ird | pg0_iwr,
        pg0_xacc_x = pg0_xrd | pg0_xwr,
        pg0_xacc_r = pg0_rrd | pg0_rwr,
        pg0_xacc   = pg0_xacc_x | pg0_xacc_r;

   wire ramacc_msk = ramacc & XACC_WAIT_IACC;
   wire pg0imsk = pg0_iacc & XACC_WAIT_IACC;

   always @(posedge mclk or negedge srstz)
      if (~srstz) pg0_wrwait <= 'h0;
             else pg0_wrwait <= (pg0_iwr | pg0_xwr & XACC_WAIT_IACC) & ramacc;
   always @(posedge mclk or negedge srstz)
      if (~srstz) pg0_rdwait <= 'h0;
             else pg0_rdwait <= (pg0_ird | pg0_xrd & XACC_WAIT_IACC) & ramacc;

   reg r_pg0_rdrdy;
   always @(posedge mclk or negedge srstz)
      if (~srstz) r_pg0_rdrdy <= 'h0;
             else r_pg0_rdrdy <= pg0_xrd & ~(ramacc_msk)
                               | pg0_ird & ~(ramacc) | pg0_rrd;

   wire [7:0] pg0_rdat = (pg0_sel<='d9) ? xram_rdat
                       : (pg0_sel=='d12) ? regx_rdat : iram_rdat;
   assign esfrm_rdat = r_pg0_rdrdy ?pg0_rdat :delay_rrdy ?delay_rdat :mcu_esfr_rdat;
   assign esfrm_rrdy = esfrm_oe // SFR access returns immediately
		  | r_pg0_rdrdy // PG0 access may wait
		  | delay_rrdy; // the additional ictlr ACK for update the read buffer

////////////////////////////////////////////////////////////////////////////////
// external memory (XDATA) mux
// priority: PG0, DMA, MCU (no continuous PG0, no simultaneous read/write)
// synopsys translate_off /////////////////////////////////////////////////////
`define MPB_FIN(format) begin $display format; #100 $finish; end
   reg d_pg0_rwr; always @(posedge mclk) d_pg0_rwr <= pg0_rwr;
   reg d_pg0_rrd; always @(posedge mclk) d_pg0_rrd <= pg0_rrd;
   reg d_pg0_xwr; always @(posedge mclk) d_pg0_xwr <= pg0_xwr;
   reg d_pg0_xrd; always @(posedge mclk) d_pg0_xrd <= pg0_xrd;
   integer cnt_arbi =0; // count arbitration
   always @(posedge mclk) begin: check_pg0_req
   reg [3:0] memacc;
	if (XACC_WAIT_IACC & // SRAM can not be selected by both IDAT/XDAT access
	   (iram_ce & xram_ce)) `MPB_FIN (($time,"ns <%m> ERROR: simultaneously IDAT/XDAT access not supported"))
	if (!XACC_WAIT_IACC & // PG0 access has the highest priority in XMEM access
	   (pg0_rwr & d_pg0_rwr |
	    pg0_rrd & d_pg0_rrd |
	    pg0_xwr & d_pg0_xwr |
	    pg0_xrd & d_pg0_xrd)) `MPB_FIN (($time,"ns <%m> ERROR: continous PG0 request not supported"))
	if (pg0_rwr & pg0_rrd |
	    pg0_xwr & pg0_xrd) `MPB_FIN (($time,"ns <%m> ERROR: simultaneously PG0 r/w request not supported"))
	if (4'h0 + idat_w + idat_r
	         + memwr + memrd_c > 4'h1) `MPB_FIN (($time,"ns <%m> ERROR: memory access conflict!!"))
	memacc = 4'h0 + idat_w + idat_r + memwr + memrd_c
	              + pg0_iwr + pg0_ird + pg0_xwr + pg0_xrd + pg0_rwr + pg0_rrd + dma_w + dma_r;
	if (memacc>1) cnt_arbi = cnt_arbi + 1;
	if (memacc>2) $display ($time,"ns <%m> COVERAGE: memory %0d-access", memacc);
   end // check_pg0_req
// synopsys translate_on //////////////////////////////////////////////////////
   reg [1:0] xram_casel, // read select cmd/addr/wdat
             xram_rdsel; // read select ack/rdata
   always @(posedge mclk or negedge srstz)
      if (~srstz) xram_rdsel <= 'h0;
             else xram_rdsel <= xram_casel; 
   always @(xram_rdsel or pg0_xrd or pg0_rrd or dma_r or memrd_c
                       or pg0_xwr or pg0_rwr or dma_w or ramacc_msk or pg0imsk) begin
      xram_casel = 'h0;
      if (~(ramacc_msk|pg0imsk))
      case (xram_rdsel)
      2'h0: if (pg0_xrd|pg0_rrd) xram_casel = 'h1; // select PG0
            else if (~(pg0_xwr|pg0_rwr))
               if (dma_r) xram_casel = 'h2; // select DMA
               else if (~dma_w)
                  if (memrd_c) xram_casel = 'h3; // select XMEM
      2'h1: // PG0 read ready, PG0 dis-continuous
            if (~dma_w)
            xram_casel = dma_r ? 'h2
                       : memrd_c ? 'h3 : 'h0;
      2'h2, // DMA ack
      2'h3: // XMEM ack
            if (~(pg0_xwr|pg0_rwr))
            xram_casel = (pg0_xrd|pg0_rrd) ? 'h1
                       : dma_r ? 'h2
                       : dma_w ? 'h0
                       : memrd_c ? 'h3 : 'h0;
      endcase
   end

   wire pg0_w_ack = pg0_xwr & ~ramacc_msk;
   wire dma_w_ack = dma_w & {ramacc_msk,pg0imsk,pg0_xacc}=='h0; // ack for write XDAT
   wire dmaacc = dma_r | dma_w;
   assign dma_ack = dma_w_ack
                          | (xram_rdsel=='h2); // ack for read
// wire mem_w_ack = memwr & {ramacc_msk,pg0imsk,pg0_xacc,dmaacc}=='h0; // ack for write XDAT
   wire mem_w_ack = memwr & {pg0imsk,pg0_xacc,dmaacc}=='h0; // memwr can never with ramacc, or timing loop
   assign memack = ~cpurst &
                   (mem_w_ack
                          | (xram_rdsel=='h3)); // ack for read

////////////////////////////////////////////////////////////////////////////////
// SRAM/REGX control
////////////////////////////////////////////////////////////////////////////////
   wire bist_iwr  = bist_wr & ~bist_xram,
        bist_xwr  = bist_wr &  bist_xram,
        bist_ien  = bist_en & ~bist_xram,
        bist_xen  = bist_en &  bist_xram;
   assign iram_ce = bist_en ? bist_ien : ramacc | pg0_iacc;
   assign iram_we = bist_en ? bist_iwr : ramacc ?idat_w :pg0_iwr;

   assign xram_ce = bist_en ? bist_xen
                  : (xram_casel=='h1) // PG0 always hits
                 | ((xram_casel=='h2) | dma_w_ack) & dma_hit_x
                 |  (xram_casel=='h3) & memrd_c & hit_xd_c // shall not encounter ramacc
                 |  (xram_casel=='h0) & (pg0_w_ack | mem_w_ack & hit_xd);
   assign xram_we = bist_en ? bist_xwr
                  : pg0_w_ack
                  | dma_w_ack & dma_hit_x
                  | mem_w_ack & hit_xd;

   assign regx_re = pg0_xacc_r ?pg0_rrd : hit_xr_c & (xram_casel=='h3); // pre-read-clear
   assign regx_we = pg0_xacc_r ?pg0_rwr : hit_xr   & mem_w_ack; // w/o DMA/MBIST

   wire [1:0] xsel =
             (xram_casel=='h0) ?(pg0_xwr|pg0_rwr) ?'h1
                               :dma_w ?'h2 :'h3 :xram_casel;

   wire [10:0] xaddr = memwr|memrd ?memaddr[10:0] :memaddr_c[10:0], // memrd for better timing
              iram_adr = {3'h5,idat_adr[7:0]}, // bank10/11
              iram_bkb = {4'h2,idat_adr[6:0]}, // 0x28~0x6F => 0x128~0x16F (72-byte)
              xram_adr = xaddr,
              xram_bkb = xaddr|'h80;
   assign iram_a = bist_en ? bist_adr
                 : ramacc ? (idat_adr>='h28 && idat_adr<'h70 && channel_sel) ? iram_bkb : iram_adr
                 : {pg0_sel[0]?4'hb:4'ha,esfrm_adr[6:0]}; // bank10/11
   assign xram_a = bist_en ? bist_adr
                 : pg0_xacc ? {pg0_sel[3:0],esfrm_adr[6:0]}
                 : xsel=='h2 ? dma_addr
                 : (xram_adr<'h80 && channel_sel) ? xram_bkb : xram_adr;
   assign
      iram_d = bist_en ? bist_wdat
              : ramacc ? idat_wdat : esfrm_wdat,
      xram_d = bist_en ? bist_wdat
              : (pg0_xwr|pg0_rwr) ? esfrm_wdat
              : xsel=='h2 ? dma_wdat : memdatao;

endmodule // mpb

