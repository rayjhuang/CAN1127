
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
// 2024/01/22 modulize dacreg
// ALL RIGHTS ARE RESERVED
// =============================================================================
parameter BIT_PTR = 'd5,
parameter N_DACV = 'd18, // N_DACV is num of channel if 2^BIT_PTR > 11
parameter N_CHNL = 'd18, // N_CHNL = N_DACV if N_DACV>=11
parameter BIT_PLUS = ('d2**BIT_PTR>N_CHNL+'d1) ?BIT_PTR :BIT_PTR+'d1
)(
input		clk, srstz, i_comp,
input	[2:0]	r_comp_opt,
input	[7:0]	r_wdat,
input	[10:0]	r_wr, // 7 additional SFRs, 4 additional REGX to write
input	[N_DACV-1:0] dacv_wr, // DACV* registers
output		o_shrst, // S/H reset
		o_hold,
output	[9:0]	o_dac1,
output	[N_CHNL-1:0] o_daci_sel, // select a channel for comp+
output	[N_DACV-1:0]
		r_comp,
		r_dac_en, r_sar_en,
output	[8*N_DACV-1:0] r_dacv,
output	[7:0]	r_adofs, r_isofs,
output	[7:0]	r_dacctl, r_cmpsta,
output	[5:0]	r_daclsb_x, // bit un-positioned
output		o_intr,
output	[BIT_PLUS-1:0] o_smpl
);
// SFR address decode
   wire busy;
   wire stop = r_wr[0] & ~r_wdat[0];
   wire wr_ctl = busy ?stop :r_wr[0]; // protect
   wire wr_lsb = r_wr[3];
   wire wr_sta = r_wr[4];

   wire r_comp_swtch = r_comp_opt[2];
// wire r_comp_swap = r_comp_opt[1];
   wire r_comp_none = r_comp_opt[0];
// wire r_park = r_dacctl[7];
   wire r_dacyc = r_dacctl[7];
   wire r_sar10 = r_dacctl[6];
   wire r_md4ch = r_dacctl[5]; // 4-channel mode
   wire r_sample = r_dacctl[4]; // always sample
   wire [1:0] r_dac_t = r_dacctl[3:2];
   wire r_loop = r_dacctl[1];
   assign r_dacctl[0] = busy;
   wire r_semi = r_dac_en=={N_DACV{1'h0}};
   wire r_semi_wr = |(dacv_wr & r_sar_en) & r_semi;

   reg [1:0] syn_comp;
   wire sync_i = syn_comp[1];
   always @(posedge clk) syn_comp <= {syn_comp[0],i_comp}; // sync.

   wire [BIT_PTR-1:0] cs_ptr, ps_ptr;
   wire semi_nxt = ~busy & r_semi_wr & (r_wdat=='hac); // ack
   wire semi_clr = ~busy & r_semi_wr & (r_wdat=='hc1); // clear
   wire semi_start = semi_clr | semi_nxt;
   wire auto_start = ~busy & wr_ctl & ~r_semi & ~stop;
   wire auto_sar = r_sar_en[cs_ptr] & ~r_semi;
// wire semi_sar = r_sar_en[cs_ptr] & (r_semi);

   wire dacyc_done, sacyc_done;
   wire mxcyc_done = auto_sar ?sacyc_done :dacyc_done;
   wire sar_ini = (mxcyc_done | auto_start)
                             &  r_dac_en[ps_ptr] & r_sar_en[ps_ptr] | semi_clr;
   wire sar_nxt = dacyc_done & (r_dac_en[cs_ptr] & r_sar_en[cs_ptr] | r_semi);

   wire [BIT_PTR-1:0] lsbsel = r_daclsb_x[5:3];
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
   wire [N_CHNL-1:0] app_dacis;
   assign o_daci_sel = r_comp_none ?'h0 :app_dacis;
   shmux #(
	.N_CHNL		(N_CHNL),
	.N_DACV		(N_DACV),
	.BIT_PTR	(BIT_PTR),
	.BIT_PLUS	(BIT_PLUS))
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
	.ps_ptr		(ps_ptr[BIT_PTR-1:0]),
	.cs_ptr		(cs_ptr[BIT_PTR-1:0]),
	.o_smpl		(o_smpl),
	.clk            (clk),
        .srstz          (srstz)); // u0_shmux

   wire cmpchg = r_loop // don't issue in manual DAC cycles for init.r_comp (if wanted)
              & dacyc_done &~r_sar_en[cs_ptr] // don't issue in both kind of SAR cycles
              & (r_comp[cs_ptr]^sync_i);

   wire [8*N_DACV-1:0] r_dacvs;
   assign o_dac1 = busy&r_sar_en[cs_ptr] ?r_dac1v
                                        :{r_dacvs[cs_ptr*8+:8],r_daclsb_x[1:0]};

   wire dacv_rpt = sacyc_done || dacyc_done && r_semi;
   wire sar10_rpt = dacv_rpt & sar10_ch;
   wire updlsb = sar10_rpt | wr_lsb;
   wire [5:0] wdlsb = wr_lsb
                    ?{r_wdat[6:4],r_wdat[2:0]} // higher priority
                    :{r_daclsb_x[5:2],r_rpt_v[1:0]};

   wire [N_DACV-1:0]
        v_upd = (dacv_rpt ?'h1<<cs_ptr :'h0)
                    | (busy|semi_start ?'h0 :dacv_wr); // semi_start don't write DACV*
   wire [7:0] v_wdat = dacv_rpt ?r_rpt_v[9:2] :r_wdat;

   dacreg #(
	.BIT_PTR	(BIT_PTR),
	.N_DACV		(N_DACV))
   u0_dacreg (
	.clk		(clk),
	.srstz		(srstz),
	.r_wr		(r_wr), .r_wdat (r_wdat),
	.v_upd		(v_upd), .v_wdat (v_wdat),
	.lsb_upd	(updlsb), .lsb_wdat (wdlsb),
	.dacyc_done	(dacyc_done), .sync_i (sync_i), .cs_ptr (cs_ptr),
	.wr_sta		(wr_sta), .cmpchg (cmpchg), .o_intr (o_intr),
	.wr_ctl		(wr_ctl),
	.r_cmpsta	(r_cmpsta),
	.r_daclsb_x	(r_daclsb_x), // {DACLSB[6:4],DACLSB[2:0]}
	.r_dacctl_7_1	(r_dacctl[7:1]),
	.r_comp		(r_comp),
	.r_isofs	(r_isofs),
	.r_adofs	(r_adofs),
	.r_dac_en	(r_dac_en),
	.r_sar_en	(r_sar_en),
	.r_dacvs	(r_dacvs),
	.r_dacv		(r_dacv)
   );

endmodule // dacmux

