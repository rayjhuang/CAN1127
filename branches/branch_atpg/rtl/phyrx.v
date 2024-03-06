
module phyrx (
// =============================================================================
// USBPD physical layer submodule
// RX controller with a BMC decoder
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2017/03/07 '1v' postfix for can1110a0
// 2017/04/13 add 4-code decoding option for ORDRS decoder
// 2018/01/09 '2v' output EOP info
// 2018/10/03 remove postfix
// ALL RIGHTS ARE RESERVED
// =============================================================================
input		i_cc,
input		ptx_txact,
		r_adprx_en, r_adp2nd, r_exist1st, r_ordrs4,
input	[1:0]	r_rxdb_opt, // RX de-bounce options
input	[6:0]	r_ords_ena,
input		r_pshords,
		r_rgdcrc,
output	[1:0]	prx_cccnt, // [0]: bit-sent, [1]: mid-term
		prx_rst,
output	[6:0]	prx_setsta,
output		prx_idle, prx_d_cc, prx_bmc,
		prx_trans,
		prx_fiforst,
		prx_fifopsh,
output	[7:0]	prx_fifowdat,
input		pff_txreq,
input		pid_gobusy, pid_goidle, pid_ccidle,
input		pcc_rxgood,
output		prx_crcstart, prx_crcshfi4,
output	[3:0]	prx_crcsidat,
output	[4:0]	prx_rxcode,
output	[5:0]	prx_adpn,
output	[2:0]	prx_rcvdords,
output		prx_eoprcvd,
output	[3:0]	prx_fsm,
input		clk, srstz
);
   wire x_cc = i_cc; // for easy duty-tolarance simulation
   phyrx_db u0_phyrx_db (
	.clk		(clk),
	.srstz		(srstz),
	.x_cc		(x_cc),
	.r_rxdb_opt	(r_rxdb_opt),
	.ptx_txact	(ptx_txact),
	.gohi		(db_gohi),
	.golo		(db_golo),
	.gotrans	(db_gotrans));
   phyrx_adp u0_phyrx_adp (
	.clk		(clk),
	.srstz		(srstz),
	.gohi		(db_gohi),
	.golo		(db_golo),
	.k0_det		(k0_det),
	.gobusy		(pid_gobusy),
	.goidle		(pid_goidle),
	.i_ccidle	(pid_ccidle),
	.r_adprx_en	(r_adprx_en),
	.r_adp2nd	(r_adp2nd),
	.adp_val	(prx_adpn),
	.d_cc		(prx_d_cc),
	.cctrans	(cctrans));

   reg shrtrans; // short transit captured
   reg [5:0] cccnt;
   wire ui_bnd = cccnt=='d39;
   wire ui_mid = cccnt=='d19;
   wire ui_trn = cccnt>='d5 && cccnt<(shrtrans ?'d29 :'d28); // transit window
   wire ui_upb = cccnt>='d28; // boundary window
   assign prx_cccnt = {ui_mid,ui_bnd};
   always @(posedge clk)
      if (~srstz)
         shrtrans <= 'h0;
      else if (cctrans)
         shrtrans <= ui_trn ?~shrtrans :'h0;
   always @(posedge clk)
      if (~srstz)
         cccnt <= {6{1'h1}};
      else if (pff_txreq | (ptx_txact ?ui_bnd :cctrans))
         cccnt <= 'h0;
      else if (~&cccnt)
         cccnt <= cccnt +'h1;

   wire shrtx2 = cctrans & ui_trn & shrtrans; // continuous 2 short trans
   wire longx1 = cctrans & ui_upb; // long trans
   wire bitrcvd = shrtx2 | longx1;
   reg [2:0] bcnt;
   reg [3:0] cs_dat5b; // de-BMC, encoded data
   wire [4:0] ps_dat5b = {shrtx2,cs_dat5b};
   wire [4:0] ps_dat4b = bmc_decoder (ps_dat5b); // decoded data
   wire keop = ps_dat4b=='h14;

   parameter bmni_idle = 4'h0;
   parameter bmni_ord0 = 4'h1; // cc becomes busy
   parameter bmni_ord1 = 4'h3; // low nibble rcvd, to rcv high nibble of low byte
   parameter bmni_ord2 = 4'h2; // 1st byte rcvd, to rcv high byte
   parameter bmni_ord3 = 4'h6; // low nibble rcvd, to complete the ordered set
   parameter bmni_pyl0 = 4'he; // to rcv 1st nibble of payload, start CRC
   parameter bmni_pyl1 = 4'ha; // to rcv 2st nibble of payload, NDO (wrong)
   parameter bmni_pyll = 4'hb; // to rcv rest of payload, wait for EOP to end the packet
   parameter bmni_pylh = 4'h9; // to rcv rest of payload, wait for EOP to end the packet
   parameter bmni_wait = 4'h5; // wait for going idle or EOP
   reg [3:0] cs_bmni;
   wire
   cs_ord0 = cs_bmni==bmni_ord0,
   cs_idle = cs_bmni==bmni_idle,
   cs_ord1 = cs_bmni==bmni_ord1,
   cs_ord2 = cs_bmni==bmni_ord2,
   cs_ord3 = cs_bmni==bmni_ord3,
   cs_pyl0 = cs_bmni==bmni_pyl0,
   cs_pyl1 = cs_bmni==bmni_pyl1,
   cs_pyll = cs_bmni==bmni_pyll,
   cs_pylh = cs_bmni==bmni_pylh,
   cs_wait = cs_bmni==bmni_wait,
   cs_pyld = cs_bmni[3];

   assign k0_det = // the 1st k-code of ordrs detected
     cs_ord0 & ps_dat4b[4] & ( // kvld
               ps_dat4b[3:0]=='h1 || // Sync-1
               ps_dat4b[3:0]=='h3 || // Sync-3
               ps_dat4b[3:0]=='h5 || // RST-1
               ps_dat4b[3:0]=='h6);  // RST-2
   wire nibrcvd = (k0_det | (bcnt=='h4)) & bitrcvd;
   wire dat5b_rst = pid_gobusy | nibrcvd & keop; // reset the buffer to prevent start/end of the pack

   always @(posedge clk)
      if (~srstz | dat5b_rst) // dat5b_rst is not in CAN1106
         cs_dat5b <= 'h0;
      else if (bitrcvd)
         cs_dat5b <= ps_dat5b>>1; // shift right because of LSB first

   reg [7:0] ordsbuf; // buffer for ordered set
   reg [4:0] cs_dat4b;
   wire [3:0] ps_nibb = {cs_pyld ?ps_dat4b[3:0] :{ps_dat4b[4],ps_dat4b[2:0]}};
   wire [3:0] cs_nibb = {cs_pyld ?cs_dat4b[3:0] :{cs_dat4b[4],cs_dat4b[2:0]}}; 
   wire [7:0] fifowdat = {ps_nibb,cs_nibb}; 
   wire [2:0] ps_ords;
   wire [7:0] ords_msk = {r_ords_ena[6:0],1'h0};
   wire ps_ords_ena = ords_msk [ps_ords];
   wire cs_ords_ena = ords_msk [ordsbuf[2:0]];
   wire r_lost1st = ~r_exist1st;
   wire lost1st; // lost 1st symbol of ordered set
   assign {lost1st,ps_ords} = ordered_set ({fifowdat,ordsbuf},r_lost1st,r_ordrs4);

// wire r_pshords = r_rxauto[0];
// wire r_pshcrc = r_rxauto[1]; // don't recognize CRC32, just accumulate

   always @(posedge clk)
      if (~srstz | nibrcvd)
         bcnt <= 'h0;
      else if (~cs_idle & ~(cs_ord0 && bcnt>'h1) & bitrcvd)
         bcnt <= bcnt +'h1;

   always @(posedge clk)
      if (nibrcvd) begin
         cs_dat4b <= ps_dat4b;
         case (1)
         cs_ord1: ordsbuf <= fifowdat; // first 2-symbol of ordered set
         cs_ord3: ordsbuf[3:0] <= {1'h0,ps_ords}; // decoded ordered set
         endcase
      end

   always @(posedge clk)
      if (~srstz | pid_goidle | nibrcvd & keop)
                  cs_bmni <= bmni_idle;
      else if (cs_idle & pid_gobusy &~ptx_txact)
                  cs_bmni <= bmni_ord0;
      else if (nibrcvd)
         case (1)
         cs_ord0: cs_bmni <= bmni_ord1;
         cs_ord1: cs_bmni <= bmni_ord2;
         cs_ord2: cs_bmni <= bmni_ord3;
         cs_ord3: cs_bmni <=
                   |prx_rst ?bmni_idle
                            :ps_ords_ena ?lost1st ?bmni_pyl1 // only 3 k-code rcvd
                                                  :bmni_pyl0 // 4th k-code rcvd
                                         :bmni_wait;
         cs_pyl0: cs_bmni <= bmni_pyl1;
         cs_pyl1: cs_bmni <= bmni_pyll;
         cs_pyll: cs_bmni <= bmni_pylh;
         cs_pylh: cs_bmni <= bmni_pyll;
         cs_wait:; // wait for going idle or EOP
         endcase

   wire skip_pyl0 = cs_ord3 & lost1st;
   assign prx_crcstart = nibrcvd & (cs_pyl0 | skip_pyl0);
   assign prx_crcshfi4 = nibrcvd & (cs_pyld &~keop | skip_pyl0);
   assign prx_crcsidat = ps_dat4b[3:0];
   assign prx_rxcode = cs_dat4b;
   assign prx_rcvdords = ordsbuf[2:0]; // here-encoded ordered set

   assign prx_fiforst = nibrcvd & cs_ord0 | prx_setsta[6];
   assign prx_fifopsh = nibrcvd & (r_pshords&(cs_ord1|cs_ord3) | cs_pylh | cs_pyl1);
   assign prx_fifowdat = fifowdat;
   assign prx_idle = cs_idle;
// assign prx_pyld = cs_pyld; // prx_fsm[3]
   assign prx_fsm = cs_bmni;
   wire eoprcvd = nibrcvd & cs_pyld & cs_ords_ena & keop;
   assign prx_eoprcvd = eoprcvd;
   assign prx_setsta = {
		eoprcvd & pcc_rxgood & r_rgdcrc, // EOP rcvd with CRC OK, auto clear
	     pid_goidle & cs_pyld & cs_ords_ena &~cs_idle, // no EOP (EOP-expected packets)
		eoprcvd &~pcc_rxgood, // EOP rcvd with bad CRC
		eoprcvd & pcc_rxgood &~r_rgdcrc, // EOP rcvd with CRC OK
		nibrcvd & cs_ord3 &~ps_ords_ena, // undefined/disabled ordered set rcvd
		nibrcvd & cs_ord3 & ps_ords_ena, // defined/enabled ordered set rcvd
		bitrcvd & cs_ord0 & (bcnt>'h1) & (ps_dat5b[4]==ps_dat5b[3])}; // preamble end
   assign prx_rst = {ps_ords=='h6,  // Hard Reset
                     ps_ords=='h7}; // Cable Reset

   assign prx_bmc = cs_dat5b[3]; // for debug by waveform view
   assign prx_trans = // cctrans | // pre-transit
//			^cc_buf[1:0]; // include TX trans
			db_gotrans;

function [4:0] bmc_decoder;
input [4:0] dat;
   case (dat)
      'b11110: bmc_decoder = 'h00;
      'b01001: bmc_decoder = 'h01;
      'b10100: bmc_decoder = 'h02;
      'b10101: bmc_decoder = 'h03;
      'b01010: bmc_decoder = 'h04;
      'b01011: bmc_decoder = 'h05;
      'b01110: bmc_decoder = 'h06;
      'b01111: bmc_decoder = 'h07;
      'b10010: bmc_decoder = 'h08;
      'b10011: bmc_decoder = 'h09;
      'b10110: bmc_decoder = 'h0a;
      'b10111: bmc_decoder = 'h0b;
      'b11010: bmc_decoder = 'h0c;
      'b11011: bmc_decoder = 'h0d;
      'b11100: bmc_decoder = 'h0e;
      'b11101: bmc_decoder = 'h0f;
      'b11000: bmc_decoder = 'h11; // Sync-1
      'b10001: bmc_decoder = 'h12; // Sync-2
      'b00110: bmc_decoder = 'h13; // Sync-3
      'b01101: bmc_decoder = 'h14; // EOP
      'b00111: bmc_decoder = 'h15; // RST-1
      'b11001: bmc_decoder = 'h16; // RST-2
      default: bmc_decoder = 'h10;
   endcase
endfunction // bmc_decoder

function [1:0] match_ords;
input [15:0] kcod,target;
input r_lost1st,r_match4;
reg lost_1st_symbol, matched;
begin
   lost_1st_symbol = (~|((kcod^(target>>4))&'h0fff)) & r_lost1st;
   matched = r_match4
	?~|((kcod^target))
	:~|((kcod^target)&'hfff0) || // don't care 1st, added in CAN1110
	 ~|((kcod^target)&'hff0f) || // don't care 2nd
	 ~|((kcod^target)&'hf0ff) || // don't care 3rd
	 ~|((kcod^target)&'h0fff);   // don't care 4th
   match_ords = {lost_1st_symbol, lost_1st_symbol | matched};
end
endfunction // match_ords

function [3:0] ordered_set;
input [15:0] kcod;
input l1st,m4; // r_lost1st,r_match4
reg [7:1] match, l_1st; // lost 1st symbol, match other 3 symbols
begin
   {l_1st[1],match[1]} = match_ords (kcod,'ha999,l1st,m4); // SOP:         Sync-1,Sync-1,Sync-1,Sync-2
   {l_1st[2],match[2]} = match_ords (kcod,'hbb99,l1st,m4); // SOP':        Sync-1,Sync-1,Sync-3,Sync-3
   {l_1st[3],match[3]} = match_ords (kcod,'hb9b9,l1st,m4); // SOP":        Sync-1,Sync-3,Sync-1,Sync-3
   {l_1st[4],match[4]} = match_ords (kcod,'hbee9,l1st,m4); // SOP'_Debug:  Sync-1,RST-2, RST-2, Sync-3
   {l_1st[5],match[5]} = match_ords (kcod,'habe9,l1st,m4); // SOP"_Debug:  Sync-1,RST-2, Sync-3,Sync-2
   {l_1st[6],match[6]} = match_ords (kcod,'heddd,l1st,m4); // Hard Reset:  RST-1, RST-1, RST-1, RST-2
   {l_1st[7],match[7]} = match_ords (kcod,'hbd9d,l1st,m4); // Cable Reset: RST-1, Sync-1,RST-1, Sync-3
   case (1)
      match[1]: ordered_set = {l_1st[1],3'h1};
      match[2]: ordered_set = {l_1st[2],3'h2};
      match[3]: ordered_set = {l_1st[3],3'h3};
      match[4]: ordered_set = {l_1st[4],3'h4};
      match[5]: ordered_set = {l_1st[5],3'h5};
      match[6]: ordered_set = {l_1st[6],3'h6};
      match[7]: ordered_set = {l_1st[7],3'h7};
      default:  ordered_set = {1'h0,3'h0};
   endcase
end
endfunction // ordered_set

endmodule // phyrx

module phyrx_db (
input clk, srstz, x_cc, ptx_txact,
input [1:0] r_rxdb_opt,
output gohi, golo, gotrans
);
   reg [3:0] num_lo,num_hi;
   reg [7:0] cc_buf; // rev.B
   always @(posedge clk)
      if (~srstz)
         cc_buf <= 'h0;
      else begin
         cc_buf[7:2] <= (cc_buf[7:2]<<1) | (ptx_txact ?'h0 :cc_buf[1]);
         cc_buf[1] <= cc_buf[0];
         cc_buf[0] <= x_cc;
      end

   always @(cc_buf) begin: cnt_one // rev.B
      reg [3:0] idx;
      num_hi = 4'h0;
      for (idx=0;idx<8;idx=idx+1)
      num_hi = num_hi + {3'h0,cc_buf[idx]};
      num_lo = 4'h8 - num_hi;
   end

   wire [1:0] db_rise_opt = {r_rxdb_opt[0],1'h0};
   wire [1:0] db_fall_opt = {r_rxdb_opt[1],1'h0};
   assign gohi = db_rise_opt==2'h0 ?( &cc_buf[3:0]) :(num_lo <= {2'h0,db_rise_opt});
   assign golo = db_fall_opt==2'h0 ?(~|cc_buf[3:0]) :(num_hi <= {2'h0,db_fall_opt});
   assign gotrans = ^cc_buf[1:0];
/*
parameter DB_BIT = 6; // at least 4
reg [DB_BIT-1:0] cc_buf;
   wire ccstable1 =  &cc_buf[DB_BIT-2:0];
   wire ccstable0 = ~|cc_buf[DB_BIT-2:0];
   wire ccstable = ccstable0 | ccstable1;
   wire ps_d_cc = ccstable ?cc_buf[DB_BIT-2] :cc_buf[DB_BIT-1];
   wire cs_d_cc = cc_buf[DB_BIT-1]; // sync and debounce
   wire cctrans = cs_d_cc ?ccstable0 :ccstable1; // stable transit
   always @(posedge clk)
      cc_buf <= {ps_d_cc, cc_buf[DB_BIT-3:1], ptx_txact ?1'h1 :cc_buf[0], i_cc};
*/
endmodule

module phyrx_adp (
input clk, srstz, gohi, golo, gobusy, goidle, i_ccidle, k0_det, r_adprx_en, r_adp2nd,
output [5:0] adp_val,
output d_cc, cctrans
);
   reg signed [7:0] dcnt_h;
   wire signed [5:0] adp_v0 = dcnt_h/6;
   wire signed [4:0] adp_v1 = (adp_v0>15) ?15 :(adp_v0<-15) ?-15 :adp_v0[4:0]; // out-of-range??
   wire adp_sign = adp_v1[4];
   wire [3:0] adp_abs = adp_sign ?-adp_v1 :adp_v1;
   reg [5:0] adp_n;  // adaptive value (result, for I2C probe), [4]: sign, [5]: 2nd
   reg [5:0] dcnt_e; // duty counter of edge
   reg [3:0] dcnt_n; // duty counter of compensation
   wire adp_trans = dcnt_n==adp_n[3:0];
   wire adp_f = adp_n[4]; // negative sum means to delay falling
   wire adp_chk = dcnt_e[5:4]=='h1 || dcnt_e[5:4]=='h2;
   wire adp_en = (dcnt_e=='h0 || adp_chk) && adp_n[3:0]!='h0; // adaptive enable
   wire adp_gate = (dcnt_e=='h0 || dcnt_e=='h3f) | adp_chk;

   reg cs_d_cc;
   wire adp_gohi = adp_en &~adp_f ?adp_trans :gohi;
   wire adp_golo = adp_en & adp_f ?adp_trans :golo;
   wire rev_trans = cs_d_cc ?adp_golo :adp_gohi;
   always @(posedge clk)
      if (~srstz) cs_d_cc <= 'h0; // '0' because of cc_buf is initailized to be '0'
      else if (rev_trans) cs_d_cc <= ~cs_d_cc;

   wire ph_get_adp_n = dcnt_e=='h31 || dcnt_e=='h01;
   wire ph_clr_dcnt_h = ph_get_adp_n || dcnt_e=='h11;
   wire ph_cal_dcnt_h = (dcnt_e[3:0]<'h7 && dcnt_e[3:0]>'h0) && dcnt_e[5:4]!='h2;
   wire org_trans = cs_d_cc & golo | ~cs_d_cc & gohi;
   wire tmp_trans = (adp_chk ?rev_trans :org_trans) & ~i_ccidle;

   always @(posedge clk)
      if (~srstz) adp_n <= 'h0;
      else if ( ph_get_adp_n& org_trans) adp_n <= {~dcnt_e[5],adp_sign,adp_abs};
   always @(posedge clk)
      if (~srstz | (gobusy | goidle)) begin
         dcnt_e <= 'h3f;
         dcnt_h <= 0;
      end else begin
         if (k0_det & r_adprx_en)
            dcnt_e <= 'h0;
         else if (tmp_trans)
            if (dcnt_e=='h11)
               dcnt_e <= (adp_abs>2) ?'h8 :'h0; // rapid to start the 2nd calculate
            else if (dcnt_e=='h31 && ~r_adp2nd)
               dcnt_e <= 'h0;
            else if (dcnt_e>'h0)
               dcnt_e <= r_adprx_en ?dcnt_e -'h1 :'h3f;
         if (ph_clr_dcnt_h & tmp_trans | k0_det)
            dcnt_h <= 'h0;
         else if (ph_cal_dcnt_h)
            dcnt_h <= cs_d_cc ?dcnt_h +1 :dcnt_h -1;
      end
   always @(posedge clk)
      if (~srstz | adp_trans) dcnt_n <= 'h0;
      else if (adp_en)
         if (dcnt_n=='h0 && (adp_f & cs_d_cc & golo
                           |~adp_f &~cs_d_cc & gohi)) dcnt_n <= 'h1;
         else if (|dcnt_n) dcnt_n <= dcnt_n +'h1;

   assign cctrans = adp_gate & rev_trans;
   assign adp_val = adp_n;
   assign d_cc = cs_d_cc;

endmodule // phyrx_adp

