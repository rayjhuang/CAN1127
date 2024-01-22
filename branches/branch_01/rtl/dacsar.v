module dac2sar (
input	[1:0] r_dac_t,
input	r_dacyc,
	r_sar10,
input	sar_ini,
	sar_nxt, semi_nxt,
	auto_sar,
	busy, stop,
	sync_i,
	ps_sample,
output	sampl_begn,
	sampl_done, sh_rst,
	dacyc_done,
	sacyc_done,
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

