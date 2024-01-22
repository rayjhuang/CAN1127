module dacreg #(
parameter BIT_PTR = 'd5,
parameter N_DACV = 'd18
)(
input	clk, srstz,
input	[7:0] r_wdat,
input	[10:0] r_wr, // 7 additional SFRs, 4 additional REGX to write
input	[N_DACV-1:0] v_upd,
input	[7:0] v_wdat,
input	lsb_upd,
input	[5:0] lsb_wdat,
output	[5:0] r_daclsb_x, // {DACLSB[6:4],DACLSB[2:0]}
input	sync_i, dacyc_done,
input	[BIT_PTR-1:0] cs_ptr,
input	wr_ctl, wr_sta, cmpchg,
output	o_intr,
output	[7:1] r_dacctl_7_1,
output	[7:0] r_isofs, r_adofs, r_cmpsta,
output	[N_DACV-1:0] r_dac_en, r_sar_en, r_comp,
output	[8*N_DACV-1:0] r_dacvs, r_dacv
);
   wire [7:0] r_irq; // only for the first 8 channels
   wire [7:0] setsta = {7'h0,cmpchg}<<cs_ptr,
              clrsta = {8{wr_sta}} & r_wdat;
   glsta u0_cmpsta (clk, srstz, 1'h0, setsta, clrsta, r_cmpsta, r_irq);
   // 'set' has higher priority than 'clr'
   // a failed 'clr' makes 'sta' remained, it's ok, the next 'set' still issue an INT
   // (the too-frequently 'set' is ignored)
   assign o_intr = |r_irq;

   glreg #(6) u0_daclsb (clk, srstz, lsb_upd, lsb_wdat, r_daclsb_x); // {DACLSB[6:4],DACLSB[2:0]}
   glreg #(7) u0_dacctl (clk, srstz, wr_ctl, r_wdat[7:1], r_dacctl_7_1);

   wire [N_DACV-1:0] datcmp = r_comp & ~({{N_DACV{1'h0}}|1'h1}<<cs_ptr) | {{N_DACV{1'h0}}|sync_i}<<cs_ptr;
   wire updcmp = dacyc_done & (r_dac_en[cs_ptr]^r_sar_en[cs_ptr]); // don't update in SAR cycles
   glreg #(N_DACV) u0_compi (clk, srstz, updcmp, datcmp, r_comp); // COMPI

   genvar gi;
   generate
   for (gi=0;gi<N_DACV;gi=gi+1) begin: dacvs
   glreg u0 (clk, srstz, v_upd[gi], v_wdat, r_dacvs[8*gi+:8]);
   end // dacvs
   endgenerate
   wire [7:0]
   dbg_dacvs_0 = r_dacvs[8*0+:8],
   dbg_dacvs_1 = r_dacvs[8*1+:8],
   dbg_dacvs_2 = r_dacvs[8*2+:8],
   dbg_dacvs_3 = r_dacvs[8*3+:8];

   wire wr_dacen = r_wr[1];
   wire wr_saren = r_wr[2];
   glreg
   u0_dacen (clk, srstz, wr_dacen, r_wdat, r_dac_en[7:0]),
   u0_saren (clk, srstz, wr_saren, r_wdat, r_sar_en[7:0]);
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
   assign r_dacv = reg_dacv;

`ifdef SYNTHESIS
`else
   always @(posedge clk)
      if (wr_sta & cmpchg) $display ($time,"ns <%m> CRITICAL: write CMPSTA while changed");
`endif // SYNTHESIS
endmodule // dacreg

