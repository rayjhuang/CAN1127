
module i2cslv (
// =============================================================================
// USBPD project
// architecture with a MCU
// new version since Apr.2015
// 2016/03/21 move from i2cslv.v of CAN1109, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2016/03/21 add FW support path
// 2016/10/11 add single-wire mode
// 2017/03/07 '1110' postfix for can1110a0
// 2018/09/03 '12' postfix for can1112b0
// 2018/10/03 no postfix for new naming rule
// 2019/08/22 issue o_re & o_r_early in cs_bit =='h1 when read idata    
// ALL RIGHTS ARE RESERVED
// =============================================================================
input		i_sda, i_scl,
output		o_sda,
input	[7:1]	i_deva, // device address
input		i_inc, // auto increase ofset
		i_fwnak, // to stretch clock, NAK the cycle
		i_fwack, // ACK the cycle
output		o_we,
		o_re, o_r_early,
		o_idle,
		o_dec,
output	[2:0]	o_busev,
output	[7:0]	o_ofs, o_lt_ofs,
		o_wdat, o_lt_buf,
output	[7:0]	o_dbgpo,
input	[7:0]	i_rdat,
input		i_rd_mem, i_clk, i_rstz,
input		i_prefetch
);
// =============================================================================
// scl, sda sync/debounce
   wire [3:0] reg_early = 4'h2;//2
   i2cdbnc db_scl (i_clk, i_rstz, i_scl, reg_early[1:0], i2c_scl, sclrise, sclfall),
           db_sda (i_clk, i_rstz, i_sda, reg_early[3:2], i2c_sda, sdarise, sdafall);

   wire i2c_s = sdafall & i2c_scl &~sclfall,
	i2c_p = sdarise & i2c_scl &~sclfall;

// =============================================================================
// state machine
   reg [3:0] cs_bit;
   reg [1:0] cs_sta;
   reg       cs_rwb;
   wire      ps_rwb;
   wire hit    = i_deva==o_wdat[7:1]; // after bit1 rise, = rwbuf, valid in bit0
   wire ps_hit = i_deva==o_wdat[6:0]; //for prefetch
//	|| 7'h00==o_wdat[7:1] // 00h: general call address/START byte
//	|| 5'h01==o_wdat[7:1]>>2 // 04h..07h: Hs-mode master code
//	|| 5'h1f==o_wdat[7:1]>>2 // 7ch..7fh: device ID
//	|| 5'h1e==o_wdat[7:1]>>2; // 78h..7bh: 10-bit addressing

    always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz)
         cs_sta <= 'h0;
      else if (i2c_s | i2c_p)
         cs_sta <= 'h0;
      else if (cs_bit=='h0)begin 
         if (sclfall)
            case (cs_sta)
               'h0: cs_sta <= cs_rwb ? 'h2: 'h1;
               'h1: cs_sta <= 'h2;
            endcase
         else if ( (cs_sta=='h0) & sclrise & ~hit & ~i_prefetch ) // NACK
            cs_sta <= 'h3; 
      end 
      else if (cs_bit=='h2) //rwbuf shift in data when sclrise,so check ps_hit in cs_bit=='h2 at sclfall.
         if (sclfall)
            if (cs_sta=='h0)
                 cs_sta <= ~ps_hit & i_prefetch ? 'h3 : cs_sta;


   assign ps_rwb = (sclrise && cs_bit=='h1 && cs_sta=='h0 && i2c_sda);//for prefetch
   always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz)
         cs_rwb <= 'h0;
      else if (i2c_s) cs_rwb <= 'h0;
      else if (sclrise && cs_bit=='h1 && cs_sta=='h0)
                 cs_rwb <= i2c_sda;
   always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz)
         cs_bit <= 'hf;
      else if (i2c_s) cs_bit <= (sclfall) ?'h8 :'h9; // include START, i2c_s comes with sclfall in single-wire
      else if ((cs_sta!='h3) & sclfall & (cs_bit != 'hf))
                 cs_bit <= (|cs_bit) ? cs_bit - 'h1 : 'h8;
      else if (i2c_p) cs_bit <= 'hf;

// =============================================================================
// buf/adr
   reg [7:0] adcnt, rwbuf;
   always @(posedge i_clk or negedge i_rstz)begin
     if(~i_rstz) adcnt<='h0;
     else  if (sclfall)
         case (cs_sta)
         'h0: adcnt <= adcnt;
         'h1: if (cs_bit=='h1) adcnt <= rwbuf;
         'h2: if (cs_rwb && cs_bit=='h1 && ~i_prefetch ||
		  cs_rwb && cs_bit=='h2 &&  i_prefetch ||
                 ~cs_rwb && cs_bit=='h0) adcnt <= adcnt+{7'h0,i_inc};
         endcase
   end

   wire ps_rdmem0 = cs_rwb & (cs_sta!='h3 && ( cs_bit=='h0)) & i_rd_mem;
   wire ps_rdmem1 = cs_rwb & (cs_sta!='h3 && cs_bit=='h8) & i_rd_mem &~i2c_scl; // more latancy
   wire ps_rdmem2 = cs_rwb & (cs_sta!='h3 && ( cs_bit=='h1|cs_bit=='h0)) & i_rd_mem;// o_r_early and o_re occur on cs_bit=1,data ready in cs_bit= 1 or 0 when prefetch

   wire [7:0] ps_rwbuf = rwbuf<<1 | i2c_sda;
   always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz)
         rwbuf <= 8'hff; // initial value to initial SDA
      else if (cs_sta!='h3)
         if (cs_rwb) begin
            if (ps_rdmem0|ps_rdmem1|ps_rdmem2)
               rwbuf <= i_rdat;
            else if (sclrise & (cs_bit>'h0)) // don't shift ACK/NAK for keeping data longer
               rwbuf <= rwbuf<<1;
         end else if (sclrise & (cs_bit>'h0))
            rwbuf <= ps_rwbuf;
   reg sdat;
   wire ps_rd_dat7 = i_rd_mem ?i_rdat[7] :rwbuf[7]; // for i_rd_mem hits sclfall
   always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz)
         sdat <= 'h1;
      else if (sclfall)
         case (cs_sta)
            'h0: sdat <= (cs_bit=='h0 && cs_rwb) ? ps_rd_dat7
                       : (cs_bit=='h1 && hit && ~i_prefetch) ? 'h0 // to ACK or NAK automatically
                       : (cs_bit=='h1 && i_prefetch) ?'h0 :'h1;    // hit has been check in cs_bit=2 in prefetch
            'h1: sdat <= (cs_bit=='h1) ? 'h0 : 'h1;
            'h2: sdat <= (cs_bit!='h1 && cs_rwb) ? (cs_bit=='h0) & i2c_sda | ps_rd_dat7 // read ACK/NAK
                       : (cs_bit=='h1 &&~cs_rwb) ? 'h0 : 'h1; // always ACK to write
            default:
                 sdat <= 'h1;
         endcase
      else if (i_fwnak ^ i_fwack) // to ACK/NAK by FW
         sdat <= i_fwnak;
      else if (ps_rdmem1) // after sclfall
         sdat <= i_rdat[7];

// =============================================================================
// latch ofs/rwbuf for tracking what was written
// latch device address for FW decoding
   reg [7:0] lt_ofs;
   reg [7:0] lt_buf;
   assign o_lt_ofs = lt_ofs;
   assign o_lt_buf = lt_buf;
   wire dev_addr_ack = sclrise & (cs_sta=='h0 && cs_bit=='h1) & ps_hit;
   wire cmd_written  = sclfall & (cs_sta=='h1 && cs_bit=='h1);
   always @(posedge i_clk) if (dev_addr_ack) lt_buf <= ps_rwbuf; else if (o_we) lt_buf <= rwbuf;
   always @(posedge i_clk) if (cmd_written) lt_ofs <= rwbuf;

// =============================================================================
// output
   wire   predec= cs_bit=='h1 && cs_sta=='h0; // idata prefetch decode dev.addr
   assign o_dec = cs_bit=='h0 && cs_sta=='h0; // decode dev.addr
   assign o_ofs = adcnt;
   assign o_wdat = rwbuf;
   assign o_we = ~cs_rwb && sclfall && cs_bit=='h1 && cs_sta=='h2;
   assign o_re =  (cs_rwb && sclrise && cs_bit=='h0 && cs_sta=='h2 && ~i_prefetch && ~i2c_sda) | //~i2c_sda:check master need next data
  	 	  (cs_rwb && sclrise && cs_bit=='h1 && cs_sta=='h2 &&  i_prefetch);// read idata in cs_bit == 'h1
   assign o_r_early = (cs_rwb & sclrise & o_dec & hit    & ~i_prefetch)| 
                      (ps_rwb & sclrise & predec& ps_hit &  i_prefetch) ;
   assign o_sda = sdat;
   assign o_idle = cs_bit=='hf;
   assign o_busev = {
	i2c_p,
	cmd_written,
	sclrise & (cs_bit=='h1 && cs_sta=='h0)}; // dev.addr ack/nak
   assign o_dbgpo = {sclfall,sclrise,sdarise,i2c_p,cs_bit[3:0]};

endmodule // i2cslv

module i2cdbnc (
input	i_clk, i_rstz,
	i_i2c,
input	[1:0] r_opt, // [fall,rise] earlier
output	o_i2c,
	rise, fall
);
   reg [2:0] d_i2c;
   reg r_i2c;
   assign o_i2c = r_i2c;
   assign rise = ~r_i2c & (r_opt[0] ?  &d_i2c[1:0] :  &d_i2c[2:0]);
   assign fall =  r_i2c & (r_opt[1] ? ~|d_i2c[1:0] : ~|d_i2c[2:0]);

   always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz) d_i2c <= {3{1'h1}};//original {3{1'h1}}
      else if (rise|fall) d_i2c <= {{2{rise|~fall}},i_i2c};
                     else d_i2c <= {d_i2c[1:0],     i_i2c};

   always @(posedge i_clk or negedge i_rstz)
      if (~i_rstz) r_i2c <= 'h1;//'h1 original
      else if (rise|fall) r_i2c <= r_i2c ? ~fall : rise;
      // don't become 'X' in RTL simulation

endmodule // i2cdbnc

