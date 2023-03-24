
module dacmux #(
// =============================================================================
// DAC multiplexer
// 1. simple comparators mux, to generate INT by a set_sta signal
// 2. auto generating DAC cycles to achieve auto-/semi-auto- ADC cycles
// 2016/11/28 new created, Ray Huang, rayhuang@canyon-semi.com.tw
// 2016/12/13 replace the 8-comparator by a 8-switch and a comparator/sample-hold
// 2018/10/03 add reset cycle, expend sample cycle, min. successive cycles
// 2021/05/08 re-structure for flexible number of channel
//            however changing any parameter still needs source code revising
// 2021/05/10 fix the 1-LSB offset error in 10-bit SAR (from CAN1123)
//            full range in manual mode (since CAN1119)
//            add o_hold (from CAN1123)
//            move to N_DACV = 13, N_CHNL = 13
// 2022/09/15 add channels for GPIO3/4 (CAN1126)
// ALL RIGHTS ARE RESERVED
// =============================================================================
parameter BIT_PTR = 'd5,
parameter N_DACV = 'd18, // N_DACV is num of channel if 2^BIT_PTR > 11
parameter N_CHNL = 'd18, // N_CHNL = N_DACV if N_DACV>=11
parameter BIT_PLUS = ('d2**BIT_PTR>N_CHNL+'d1) ?BIT_PTR :BIT_PTR+'d1,
parameter ALL1_PLUS = {BIT_PLUS{1'h1}}
)(
input		clk, srstz, i_comp,
input	[2:0]	r_comp_opt,
input	[7:0]	r_wdat,
output	[7:0]	r_adofs, r_isofs,
input	[10:0]	r_wr, // 7 additional SFRs, 4 additional REGX to write
input	[N_DACV-1:0] dacv_wr, // DACV* registers
output	[8*N_DACV-1:0] o_dacv,
output		o_shrst, // S/H reset
		o_hold,
output	[9:0]	o_dac1,
output	[N_CHNL-1:0] o_daci_sel,
output	[N_DACV-1:0]
		o_dat,
		r_dac_en, r_sar_en,
output	[7:0]	o_dactl, o_cmpsta,
output	[5:0]	x_daclsb, // bit un-positioned
output		o_intr,
output	[BIT_PLUS-1:0] o_smpl
);
// SFR address decode
   wire busy, semi_start;
   wire stop = r_wr[0] & ~r_wdat[0];
   wire wr_ctl = busy ?stop :r_wr[0]; // protect
   wire wr_dacen = r_wr[1];
   wire wr_saren = r_wr[2];
   wire wr_lsb = r_wr[3];
   wire wr_sta = r_wr[4];

   wire r_comp_swtch = r_comp_opt[2];
// wire r_comp_swap = r_comp_opt[1];
   wire r_comp_none = r_comp_opt[0];
   wire [7:0] r_dactl;
// wire r_park = r_dactl[7];
   wire r_dacyc = r_dactl[7];
   wire r_sar10 = r_dactl[6];
   wire r_md4ch = r_dactl[5]; // 4-channel mode
   wire r_sample = r_dactl[4]; // always sample
   wire [1:0] r_dac_t = r_dactl[3:2];
   wire r_loop = r_dactl[1];
   wire r_semi = r_dac_en=={N_DACV{1'h0}};
   wire r_semi_wr = |(dacv_wr & r_sar_en) & r_semi;

   reg [1:0] syn_comp;
   wire sync_i = syn_comp[1];
   always @(posedge clk) syn_comp <= {syn_comp[0],i_comp}; // sync.

   wire [BIT_PTR-1:0] cs_ptr, ps_ptr;
   wire dacyc_done;
   wire [N_DACV-1:0] r_comp;
   wire [N_DACV-1:0] datcmp = r_comp & ~('h1<<cs_ptr) | {N_DACV{sync_i}} & ('h1<<cs_ptr);
   wire updcmp = dacyc_done & (r_dac_en[cs_ptr]^r_sar_en[cs_ptr]); // don't update in SAR cycles
   glreg #(N_DACV) u0_compi (clk, srstz, updcmp, datcmp, r_comp); // COMPI

   wire semi_nxt = ~busy & r_semi_wr & (r_wdat=='hac); // ack
   wire semi_clr = ~busy & r_semi_wr & (r_wdat=='hc1); // clear
   assign semi_start = semi_clr | semi_nxt;
   wire auto_start = ~busy & wr_ctl & ~r_semi & ~stop;
   wire auto_sar = r_sar_en[cs_ptr] & ~r_semi;
// wire semi_sar = r_sar_en[cs_ptr] & (r_semi);

   wire sacyc_done;
   wire mxcyc_done = auto_sar ?sacyc_done :dacyc_done;
   wire sar_ini = (mxcyc_done | auto_start)
                             &  r_dac_en[ps_ptr] & r_sar_en[ps_ptr] | semi_clr;
   wire sar_nxt = dacyc_done & (r_dac_en[cs_ptr] & r_sar_en[cs_ptr] | r_semi);

   wire [BIT_PTR-1:0] lsbsel = x_daclsb[5:3];
   wire sar10_ch = r_sar10 & (lsbsel==cs_ptr); // the first 8 channels only
   wire [9:0] r_dac1v, r_rpt_v;
   wire ps_sample = wr_ctl ?r_wdat[4] :r_sample;
   dac2sar u0_dac2sar (
	.ps_sample	(ps_sample),
	.r_dacyc	(r_dacyc),
	.r_dac_t	(r_dac_t),
	.r_sar10	(sar10_ch),
	.sar_ini	(sar_ini),
	.sar_nxt	(sar_nxt),
	.semi_nxt	(semi_nxt),
	.auto_sar	(auto_sar),
	.busy		(busy),
	.stop		(stop),
	.sync_i		(sync_i),
	.sampl_begn	(sampl_begn),
	.sampl_done	(sampl_done),
	.dacyc_done	(dacyc_done),
	.sacyc_done	(sacyc_done),
	.sh_rst		(o_shrst),
	.dac_v		(r_dac1v),
	.rpt_v		(r_rpt_v),
	.clk		(clk),
	.srstz		(srstz)); // u0_dac2sar

   wire ps_md4ch  = wr_ctl ?r_wdat[5] :r_md4ch;
   wire [N_CHNL-1:0] app_dacis, pos_dacis;
   shmux #(
	.N_CHNL		(N_CHNL),
	.N_DACV		(N_DACV),
	.BIT_PTR	(BIT_PTR))
    u0_shmux (
	.ps_md4ch	(ps_md4ch),
	.r_comp_swtch	(r_comp_swtch),
	.r_semi		(r_semi),
	.r_loop		(r_loop),
	.r_dac_en	(r_dac_en[N_DACV-1:0]),
	.wr_dacv	(dacv_wr),
	.sh_hold	(o_hold),
	.busy		(busy),
	.stop		(stop),
	.semi_start	(semi_start),
	.auto_start	(auto_start),
	.mxcyc_done	(mxcyc_done),
	.sampl_begn	(sampl_begn),
	.sampl_done	(sampl_done),
	.app_dacis	(app_dacis[N_CHNL-1:0]),
	.pos_dacis	(pos_dacis[N_CHNL-1:0]),
	.ps_ptr		(ps_ptr[BIT_PTR-1:0]),
	.cs_ptr		(cs_ptr[BIT_PTR-1:0]),
	.clk            (clk),
        .srstz          (srstz)); // u0_shmux

   assign r_dactl[0] = busy;
   glreg #(7)
   u0_dactl (clk, srstz, wr_ctl, r_wdat[7:1], r_dactl[7:1]);
   glreg
   u0_dacen (clk, srstz, wr_dacen, r_wdat, r_dac_en[7:0]),
   u0_saren (clk, srstz, wr_saren, r_wdat, r_sar_en[7:0]);

   wire dacv_rpt = sacyc_done || dacyc_done && r_semi;
   wire sar10_rpt = dacv_rpt & sar10_ch;
   wire updlsb = sar10_rpt | wr_lsb;
   wire [5:0] wdlsb = wr_lsb
                    ?{r_wdat[6:4],r_wdat[2:0]} // higher priority
                    :{x_daclsb[5:2],r_rpt_v[1:0]};
   glreg #(6)
   u0_daclsb (clk, srstz, updlsb, wdlsb, x_daclsb); // {DACLSB[6:4],DACLSB[2:0]}

   wire [N_DACV-1:0]
        upd = (dacv_rpt ?'h1<<cs_ptr :'h0)
                  | (busy|semi_start ?'h0 :dacv_wr); // semi_start don't write DACV*
   wire [7:0] wda = dacv_rpt ?r_rpt_v[9:2] :r_wdat;
   wire [8*N_DACV-1:0] r_dacvs;
   genvar gi;
   generate
   for (gi=0;gi<N_DACV;gi=gi+1) begin: dacvs
   glreg u0 (clk, srstz, upd[gi], wda, r_dacvs[8*gi+:8]);
   end // dacvs
   endgenerate
   wire [7:0]
   dbg_dacvs_0 = r_dacvs[8*0+:8],
   dbg_dacvs_1 = r_dacvs[8*1+:8],
   dbg_dacvs_2 = r_dacvs[8*2+:8],
   dbg_dacvs_3 = r_dacvs[8*3+:8];

   wire tochg = r_loop // don't issue in manual DAC cycles for init.r_comp (if wanted)
              & dacyc_done &~r_sar_en[cs_ptr] // don't issue in both kind of SAR cycles
              & (r_comp[cs_ptr]^sync_i);
   wire [7:0] r_cmpsta, r_irq; // only for the first 8 channels
   wire [7:0] setsta = {7'h0,tochg}<<cs_ptr,
              clrsta = {8{wr_sta}} & r_wdat;
   glsta u0_cmpsta (clk, srstz, 1'h0, setsta, clrsta, r_cmpsta, r_irq);
   // 'set' has higher priority than 'clr'
   // a failed 'clr' makes 'sta' remained, it's ok, the next 'set' still issue an INT
   // (the too-frequently 'set' is ignored)

   assign o_dac1 = busy&r_sar_en[cs_ptr] ?r_dac1v
                                        :{r_dacvs[cs_ptr*8+:8],x_daclsb[1:0]};
   assign o_dactl = r_dactl;
   assign o_dat = r_comp;
   assign o_cmpsta = r_cmpsta;
   assign o_daci_sel = r_comp_none ?'h0 :app_dacis;
   assign o_intr = |r_irq;

   reg [BIT_PLUS-1:0] reg_smpl;
   always @(pos_dacis) begin: daci_sel
      reg [BIT_PLUS-1:0] ii;
      reg_smpl = ALL1_PLUS; // all-0
      for (ii=0; ii<N_CHNL; ii=ii+1)
         if (pos_dacis[ii])
            reg_smpl = (reg_smpl==ALL1_PLUS) ?ii :ALL1_PLUS-'h1; // one-hot or error
   end // daci_sel
   assign o_smpl = reg_smpl; // test mode in tape-out

`ifdef SYNTHESIS
`else
   always @(posedge clk)
      if (wr_sta & tochg) $display ($time,"ns <%m> CRITICAL: write CMPSTA while changed");
   always @(posedge clk)
      if (o_smpl==ALL1_PLUS-'h1) begin
         $display ($time,"ns <%m> ERROR: ADC chennel selector error, %0x",o_smpl);
         #100 $finish;
      end
`endif // SYNTHESIS

   glreg
   u0_adofs (clk, srstz, r_wr[5], r_wdat, r_adofs),
   u0_isofs (clk, srstz, r_wr[6], r_wdat, r_isofs);
   glreg // N_DACV>15
   u1_dacen (clk, srstz, r_wr[7], r_wdat[7:0], r_dac_en[15:8]),
   u1_saren (clk, srstz, r_wr[8], r_wdat[7:0], r_sar_en[15:8]);
   glreg #(N_DACV-16) // N_DACV>16
   u2_dacen (clk, srstz, r_wr[9],  r_wdat[N_DACV-1-16:0], r_dac_en[N_DACV-1:16]),
   u2_saren (clk, srstz, r_wr[10], r_wdat[N_DACV-1-16:0], r_sar_en[N_DACV-1:16]);

   reg [8*N_DACV-1:0] reg_dacv;
   always @(r_dacvs or r_adofs or r_isofs) begin: ofs_dacv
      reg [BIT_PTR:0] ii;
      reg [8:0] signv; // signed operation
      reg [7:0] r_ofs;
      for (ii=0; ii<N_DACV; ii=ii+1) begin
         r_ofs = (ii=='h2) ? r_isofs : r_adofs; // IS channel is the special
         signv = {1'h0,r_dacvs[8*ii+:8]} + {r_ofs[7],r_ofs};
         reg_dacv[8*ii+:8] = signv[8] ? r_ofs[7] ? 8'h0 : 8'hff : signv[7:0];
      end
   end // ofs_dacv
   assign o_dacv = reg_dacv;

endmodule // dacmux


module dac2sar (
input	[1:0] r_dac_t,
input	r_dacyc,
	r_sar10,
input	sar_ini,
	sar_nxt, semi_nxt,
	auto_sar,
	busy, stop,
	sync_i,
output	sampl_begn,
	sampl_done, sh_rst,
	dacyc_done,
	sacyc_done,
	ps_sample,
output	[9:0]
	dac_v, // DAC1 code
	rpt_v, // report value
input	clk, srstz
);
   reg [3:0] sarcyc;
   reg [6:0] dacnt;
`ifdef FPGA // FPGA AFE board used an slower DAC
   wire [6:0] T_SDAC = r_dacyc ? 'd83 : 'd59;
`else
   wire [6:0] T_SDAC = r_dacyc ? 'd23 : 'd11; // successive DAC cycles
`endif // FPGA
   wire [6:0] T_SMPL = r_dac_t=='h0 ?'d35 // sampling cycle, N+1 (-3T for sampling time)
                      :r_dac_t=='h1 ?'d47
                      :r_dac_t=='h2 ?'d59 :'d83;
   wire sacyc_last = sarcyc==(r_sar10 ?'h9 :'h7);
   assign sampl_begn = dacnt=='h1 && sarcyc=='h0 ; // sample begin
   assign sampl_done = ps_sample
                      ?dacnt==(T_SDAC-'h1) && sacyc_last
                      :dacnt==(T_SMPL-'h1);
   assign dacyc_done = dacnt==((sarcyc) ? T_SDAC : T_SMPL);
   assign sacyc_done = sacyc_last & dacyc_done;

   always @(posedge clk)
      if (~srstz | stop | dacyc_done) 
         dacnt <= 'h0;
      else if (busy)
         dacnt <= dacnt +'h1;

   always @(posedge clk)
      if (~srstz | sacyc_done | stop)
         sarcyc <= 'h0;
      else if (dacyc_done & auto_sar)
         sarcyc <= sarcyc +'h1;

   reg sh_rst_n;
   assign sh_rst = sh_rst_n;
   always @(negedge clk)
      sh_rst_n <= busy && dacnt=='h0 && sarcyc=='h0;

   wire dwnward = ~ // connect Vref to comp-, upward if i_comp
	sync_i; // pre-state of r_comp[cs_ptr], only valid at dacyc_done

   wire updlo = sar_ini | sar_nxt &~dwnward;
   wire updup = sar_ini | sar_nxt & dwnward; // chase downward
   wire upd1v = updlo | updup | semi_nxt;
   wire [9:0] r_lt_lo,r_lt_up,r_dac1v;
   wire [9:0] r_avg00 = ({1'h0,r_lt_lo}+r_lt_up)>>1,
              r_rptlo = dwnward ?r_lt_lo :r_avg00,
              r_rptup = dwnward ?r_avg00 :r_lt_up,
              r_avglo = sar_ini ?{8'h00,2'h0} :r_rptlo,
              r_avgup = sar_ini ?{8'hff,2'h3} :r_rptup,
              r_dacvo = semi_nxt ?r_avg00
                      : ({1'h0,r_avglo}+r_avgup)>>1,
              r_rpt_v = ~r_dac1v[0] // sacyc_done & r_sar10 // fix the 1-LSB offset error in 10-bit SAR
                      ? r_rptup // 10-bit SAR ending at r_avg00=r_rptlo+1, r_rptup=r_avg00+1
                      : ({1'h0,r_rptlo}+r_rptup)>>1;
   glreg #(10)
   u0_dac1v (clk, srstz, upd1v, r_dacvo, r_dac1v),
   u0_lt_lo (clk, srstz, updlo, r_avglo, r_lt_lo),
   u0_lt_up (clk, srstz, updup, r_avgup, r_lt_up);

   assign dac_v = r_dac1v;
   assign rpt_v = r_rpt_v;

endmodule // dac2sar

module shmux #(
parameter BIT_PTR = 'd3, // these assignments equivalent to CAN1121
parameter N_DACV = 'd8, // see the real value in its instanciation
parameter N_CHNL = 'd11 // 3-channel switchable (0,4,5)
)(
input	ps_md4ch,
	r_comp_swtch,
	r_semi,
	r_loop,
input [N_DACV-1:0] r_dac_en, wr_dacv,
output	busy,
	sh_hold,
input	stop,
	semi_start,
	auto_start,
	mxcyc_done,
	sampl_begn,
	sampl_done,
output [N_CHNL-1:0] app_dacis, pos_dacis, // appended
output [BIT_PTR-1:0] cs_ptr, ps_ptr,
input	clk, srstz
);
   reg [BIT_PTR:0] cs_mux, ps_mux; // one more bit for busy/idle
   assign busy = ~cs_mux[BIT_PTR];
   assign ps_ptr = ps_mux[BIT_PTR-1:0],
          cs_ptr = cs_mux[BIT_PTR-1:0];

   wire mux_upd = auto_start | semi_start | mxcyc_done;
   wire [BIT_PTR-1:0] sel_ptr = cs_ptr,
                      mux_ptr = sel_ptr | ((sel_ptr<'h8)&ps_md4ch ?'h4 :'h0);
   wire [N_CHNL-1:0] tmptr = {{N_CHNL-1{1'h0}},1'h1}<<mux_ptr; // temp
   reg [N_CHNL-1:0] r_dacis, ps_dacis;
   always @* begin: switch
   parameter [N_DACV-1:0] sw_candi = 'b00110001; // 3 '1' is must
   reg [BIT_PTR:0] ii; // one more bit
      for (ii=0; ii<N_CHNL; ii=ii+1)
         case (ii) // to specify the 3 switchable channels
              10: ps_dacis[ii] = r_comp_swtch & tmptr[0] | tmptr[ii];
               9: ps_dacis[ii] = r_comp_swtch & tmptr[5] | tmptr[ii];
               8: ps_dacis[ii] = r_comp_swtch & tmptr[4] | tmptr[ii];
         default: ps_dacis[ii] = r_comp_swtch & sw_candi[ii] ?1'h0 :tmptr[ii];
         endcase
   end // switch

// 20190718
   reg  [N_CHNL-1:0] neg_dacis;
   assign app_dacis = r_dacis | neg_dacis;
   assign pos_dacis = r_dacis;
   assign sh_hold = ~|r_dacis; 
   always@(negedge clk)
   	if(~srstz) neg_dacis <= {N_CHNL{1'h0}};
	else if (sampl_done) neg_dacis <= r_dacis;
	else neg_dacis <= {N_CHNL{1'h0}};

   always @(posedge clk) // non-overlap
      if (~srstz) r_dacis <= {N_CHNL{1'h0}};
      else if (sampl_begn) r_dacis <= ps_dacis;
      else if (sampl_done | stop) r_dacis <= {N_CHNL{1'h0}};

   always @(posedge clk)
      if (stop) cs_mux[BIT_PTR] <= 1'h1;
      else if (~srstz) cs_mux <= {1'h1,{BIT_PTR{1'h0}}};
      else if (mux_upd) cs_mux <= ps_mux;

   always @* begin: mux_seq
      reg [BIT_PTR-1:0] ii;
      reg [BIT_PTR:0] tmp; // an additional bit for carry
      ps_mux = {1'h0,cs_ptr};
      if (r_semi | auto_start) begin // semi_start or auto_start
         for (tmp=N_DACV-1; tmp!={BIT_PTR+1{1'h1}}; tmp=tmp-'h1)
            if (wr_dacv[tmp] | r_dac_en[tmp]) ps_mux = tmp;
      end else
         for (ii=N_DACV-1; ii>'h0; ii=ii-'h1) begin
            tmp = cs_ptr + ii;
            if (tmp > N_DACV-1) tmp = tmp - N_DACV;
            if (r_dac_en[tmp]) ps_mux = {1'h0,tmp};
         end
      if (busy & ((cs_ptr>=ps_ptr) & ~r_loop | r_semi))
         ps_mux[BIT_PTR] = 1'h1; // becomes idle
   end // mux_seq

endmodule // shmux

