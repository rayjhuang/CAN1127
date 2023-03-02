
// =============================================================================
// ATPG test mode
// 2018/01/24 new created, Ray Huang, rayhuang@canyon-semi.com.tw
// ALL RIGHTS ARE RESERVED
// =============================================================================

   assign xrstz = i_rstz; // | atpg_en; need POR to reset registers of GPIO for entering test modes

// wire [6:0] revid = 'h5a; // 1121a0
// wire [6:0] revid = 'h2e; // 1124a0
// wire [6:0] revid = 'h2f; // 1124b0 (a0eco2)
   wire [6:0] revid = 'h30; // 1126a0

   wire [3:0] tsdo_sel = r_do_ts[6:3];
   wire muxo_ts =
	tsdo_sel=='h0 ? 1'h0 :
	tsdo_sel=='h1 ? 1'h1 :
	tsdo_sel=='h2 ? divff_5 :
	tsdo_sel=='h3 ? divff_8 :
	tsdo_sel=='h4 ? dp_comp :
	tsdo_sel=='h5 ? dm_comp :
	tsdo_sel=='h6 ? cc1_di :
	tsdo_sel=='h7 ? cc2_di :
	tsdo_sel=='h8 ? di_xanav[0] : // OCP_160M
	tsdo_sel=='h9 ? pmem_clk[0] : // a0eco3 // di_pro[1] : // OCP
	tsdo_sel=='ha ? di_xanav[1] : // OCP_80M
	tsdo_sel=='hb ? di_pro[3] : // OTPI_C
	tsdo_sel=='hc ? di_pro[4] : // SCP
	tsdo_sel=='hd ? di_pro[5] : // V5OCP
	tsdo_sel=='he ? id_di : // CCDDOVP
	tsdo_sel=='hf ? dm_fault : // DN_FAULT
	                'hx;

   // ATPG considerations:
   // 1. scan insertion : top is CORE, POR is constant '1'
   // 2. scan def       : top is CHIPTOP, connect POR to TST
   // 3. ATPG           : the modified netlist
   // 4. simulation     : POR is an additional sequence
   assign OE_GPIO    = atpg_en ? 7'h60 : oe_gpio;
   assign DO_GPIO    = do_gpio;
   assign GPIO_IE    = atpg_en ? 'h3 : r_gpio_ie; // turn-on all IE, timing loop occurs
   assign GPIO_PU    = atpg_en ? 'h0 : r_pu_gpio;
   assign GPIO_PD    = atpg_en ? 'h0 : r_pd_gpio;
   assign DO_TS      = atpg_en ? 'h0 : {muxo_ts,r_do_ts[2:0]};

   assign SRAM_CLK   = sram_clk;
   assign SRAM_A     = sram_a;
   assign SRAM_D     = sram_d;
   assign SRAM_WEB   = atpg_en ? 'h1 : sram_web;
   assign SRAM_CEB   = atpg_en ? 'h1 : sram_ceb;
   assign SRAM_OEB   = atpg_en ? 'h0 : sram_oeb;

   assign PMEM_A     = pmem_a; // FF output
   assign PMEM_RE    = atpg_en ? 1'h0 : pmem_re;
   assign PMEM_PGM   = atpg_en ? 1'h0 : pmem_pgm;
   assign PMEM_CSB   = atpg_en ? 1'h1 : pmem_csb;
   assign PMEM_CLK   = atpg_en ? 2'h0 : pmem_clk;
   assign PMEM_TWLB  = atpg_en ? 2'h0 : pmem_twlb;
   assign PMEM_SAP   = atpg_en ? 2'h0 : r_sap;
   assign VPP_SEL    = atpg_en ? 1'h0 : r_vpp_en;

   assign lp_en    = r_gate_lp ? r_ana_opt[45] & r_ocdrv_enz : r_ana_opt[45];
   assign dnchk_en = r_imp_osc ? r_ana_opt[43] ^ di_imposc   : r_ana_opt[43]; // async. usage
   wire x_stb_rp   = r_xana[19];
   wire x_rd_enb   = r_xana[18];
   wire x_pwren_b  = r_xana[12];
   wire [15:0] o_dodat0 = {r_osc_lo,oe_gpio[6:0],muxo_ts,do_gpio[6:0]};
   wire [15:0] o_dodat1 = {sram_web,sram_ceb,lp_en,x_stb_rp,x_rd_enb,sram_a[10:0]};
   wire [15:0] o_dodat2 = {TX_DAT,TX_EN,2'h0,sram_d[7:0],4'h0};

   assign OCDRV_ENZ  = atpg_en ? 'h1 : r_ocdrv_enz;
   assign PWRDN      = atpg_en ? 'h0 : r_pwrdn;
   assign VPP_0V     = atpg_en ? 'h0 : vpp_zero;
   assign SLEEP      = atpg_en ? 'h1 : r_sleep;
   assign DAC1_V     = dac1_v;
   assign SAMPL_SEL  = atpg_en ? 'h0 : dacmux_sel;
   assign CCI2C_EN   = atpg_en ? 'h0 : cci2c_mode;
   assign XTM        = atpg_en ? 'h0 : {r_xtm[4:3],r_xtm[1:0]};
   assign ANA_TM     = atpg_en ? 'h0 : r_ana_tm;
   assign ANA_REGX[7:0] = r_xana[7:0];
   assign ANA_REGX[15:8] = atpg_en ? 'h0 : r_xana[15:8];
   assign LFOSC_ENB  = atpg_en ? 'h0 : r_xana[23], // XANA2[7]
	  STB_RP     = atpg_en ? 'h0 : x_stb_rp, // XANA2[3] ^ DRP_OSC
	  RD_ENB     = atpg_en ? 'h1 : x_rd_enb, // XANA2[2] ^ DRP_OSC
	  OCP_SEL    = r_xana[17], // XANA2[1]
	  PWREN_HOLD = r_xana[16]; // XANA2[0]

   assign ANA_OPT    = atpg_en ? 48'h0 : {r_ana_opt[47:46],lp_en,r_ana_opt[44],dnchk_en,r_ana_opt[42:0]};
   assign DUMMY_IN   = r_adummyi[7:0];
   assign OSC_STOP   = atpg_en ? 'h0 : r_osc_stop;
   assign OSC_LOW    = atpg_en ? 'h0 : r_osc_lo;
   assign DAC3_V     = r_dac3;
   assign IDAC_SEN   = atpg_en ? 'h0 : r_comp_opt[1];
   assign IDAC_EN    = atpg_en ? 'h0 : r_comp_opt[0];

   wire [15:0] o_dodat3 = {dac1_v[9:0],r_dac3[5:0]};
   wire [15:0] o_dodat4 = {dacmux_sel[15:0]};

   assign TX_DAT     = do_cc;
   assign TX_EN      = atpg_en ? 'h0 : oe_cc;
   assign CC2_DOB    = cci2c_cc2_dob;
   assign CC1_DOB    = cci2c_cc1_dob;

   wire ur_dpoe = r_dpdm_swap ? s0_rxdoe : 1'h1;
   wire ur_dpdo = r_dpdm_swap ? s0_rxdo  : s0_tx; // D+ for UART_TX in normal mode
   wire ur_dmoe = r_dpdm_swap ? 1'h1     : s0_rxdoe;
   wire ur_dmdo = r_dpdm_swap ? s0_tx    : s0_rxdo;
   wire DpEna =                   r_ur_dp ? ur_dpoe : ddi2c_mode ?~ddi2c_dpdo : r_dpdmctl[3];
   wire DpDat =                   r_ur_dp ? ur_dpdo : ddi2c_mode ? 1'h0       : r_dpdmctl[2];
   wire DmEna = fcp_oe ? 1'h1   : r_ur_dm ? ur_dmoe : ddi2c_mode ?~ddi2c_dmdo : r_dpdmctl[1];
   wire DmDat = fcp_oe ? fcp_do : r_ur_dm ? ur_dmdo : ddi2c_mode ? 1'h0       : r_dpdmctl[0];

   wire udpdm_di   = r_dpdm_swap ? dp_comp  : dm_comp; // D+ becomes UART_RX in swap mode
   wire udpdm_ie   = r_dpdm_swap ? r_ur_dp  : r_ur_dm;
   assign dpdm_urx = udpdm_ie ? udpdm_di   : s0_rx;

   wire [4:0] dpdosel = {r_dpdo_sel,r_dpdmctl[2]};
   wire muxo_dp =
	r_dpdo_sel=='h0 ? DpDat :
	dpdosel=='h02 ? di_sqlch :
	dpdosel=='h03 ? di_cc_49 :
	dpdosel=='h04 ? oe_cc :
	dpdosel=='h05 ? do_cc :
	dpdosel=='h06 ? cc1_di :
	dpdosel=='h07 ? cc2_di :
	dpdosel=='h08 ? di_pro[0] : // UVP
	dpdosel=='h09 ? di_pro[1] : // OCP
	dpdosel=='h0a ? di_pro[2] : // OVP
	dpdosel=='h0b ? di_pro[3] : // OTPI_C
	dpdosel=='h0c ? di_pro[4] : // SCP
	dpdosel=='h0d ? di_pro[5] : // V5OCP
	dpdosel=='h0e ? id_di : // CCDDOVP/DN_FAULT
	dpdosel=='h0f ? dm_fault : // CCDDOVP/DN_FAULT
	dpdosel=='h10 ? pwm_o[0] :
	dpdosel=='h11 ? pwm_o[1] :
	dpdosel=='h12 ? r_osc_stop :
	dpdosel=='h13 ? r_osc_lo :
	dpdosel=='h14 ? di_rd_det :
	dpdosel=='h15 ? di_stbovp :
	dpdosel=='h16 ? r_ocdrv_enz :
	dpdosel=='h17 ? x_rd_enb : // RD_ENB
	dpdosel=='h18 ? x_stb_rp : // STB_RP
	dpdosel=='h19 ? di_pro[6] : // OTPI (OTPI_S, original OTPI)
	dpdosel=='h1a ? di_drposc : // DRP_OSC
	dpdosel=='h1b ? di_imposc : // IMP_OSC
	dpdosel=='h1c ? sdischg_vin : // VIN_DISCHG
	dpdosel=='h1d ? sdischg_vbus : // VBUS_DISCHG
	dpdosel=='h1e ? r_srcctl[5] : // DISCHG_SEL
	dpdosel=='h1f ? dnchk_en : // DNCHK_EN
	                'hx;

   wire [4:0] dndosel = {r_dndo_sel,r_dpdmctl[0]};
   wire muxo_dn =
	r_dndo_sel=='h0 ? DmDat :
	dndosel=='h02 ? di_sqlch :
	dndosel=='h03 ? di_cc_49 :
	dndosel=='h04 ? oe_cc :
	dndosel=='h05 ? do_cc :
	dndosel=='h06 ? cc1_di :
	dndosel=='h07 ? cc2_di :
	dndosel=='h08 ? di_pro[0] : // UVP
	dndosel=='h09 ? di_pro[1] : // OCP
	dndosel=='h0a ? di_pro[2] : // OVP
	dndosel=='h0b ? di_pro[3] : // OTPI_C
	dndosel=='h0c ? di_cc_pk :
	dndosel=='h0d ? dac1_comp :
	dndosel=='h0e ? lp_en :
	dndosel=='h0f ? di_pro[6] : // CCDDOVP/OTPI
	dndosel=='h10 ? pwm_o[0] :
	dndosel=='h11 ? pwm_o[1] :
	dndosel=='h12 ? r_osc_stop :
	dndosel=='h13 ? r_osc_lo :
	dndosel=='h14 ? r_osc_gate :
	dndosel=='h15 ? r_sleep :
	dndosel=='h16 ? r_ocdrv_enz :
	dndosel=='h17 ? r_pwrdn :
	dndosel=='h18 ? vpp_zero :
	dndosel=='h19 ? r_vpp_en :
	dndosel=='h1a ? r_srcctl[0] : // PWREN_A
	dndosel=='h1b ? x_pwren_b : // PWREN_B (XANA1[4])
	dndosel=='h1c ? sdischg_vin : // VIN_DISCHG
	dndosel=='h1d ? sdischg_vbus : // VBUS_DISCHG
	dndosel=='h1e ? cci2c_cc1_dob :
	dndosel=='h1f ? cci2c_cc2_dob :
	                'hx;

   assign LDO3P9V    = atpg_en ? 'h0 : r_sdischg[7];
   assign DO_SRCCTL  = atpg_en ? 'h0 : {r_srcctl[7:5],sdischg_vbus,r_srcctl[3:2],sdischg_vin,r_srcctl[0]};
   assign DO_DAC0    = dac0_code;
   assign DO_PWR_I   = r_pwr_i;
   assign DO_DPDN    = atpg_en ? 'h0 : {dpdm_ie,r_dpdmctl[7:4],dpdm_short};
   assign DO_VOOC[3:0] = atpg_en ? 'h0 : {DpEna,muxo_dp,DmEna,muxo_dn};
   assign DO_VOOC[5:4] = r_comp_opt[3:2]; // a0eco, 20221110
   assign DO_CCTRX   = atpg_en ? 'h6 : r_cctrx; // S20UB, S100UB
   assign DO_CVCTL   = atpg_en ? 'h3 : r_cvctl; // CC_ENB, CV_ENB
   assign DO_CCCTL   = atpg_en ? 'h0 : r_ccctl; 

   assign SH_HOLD    = atpg_en ? 'h1 : sh_hold;
   assign SH_RST     = atpg_en ? 'h0 : sh_rst;
   assign DAC1_EN    = atpg_en ? 'h0 : r_ena_dac1comp;

   wire [15:0] o_dodat5 = {dac0_code[10:0],cci2c_cc2_dob,cci2c_cc1_dob,dnchk_en,sdischg_vbus,sdischg_vin};
   wire [15:0] o_dodat6 = {DpEna,muxo_dp,DmEna,muxo_dn,4'h0,r_pwr_i[7:0]};

   reg [15:0] d_dodat;
   always @(posedge mclk)
      if (sh_rst & sh_hold) // use atpg_en failed in do_syn.cmd in CAN1108
         d_dodat <= o_dodat0^o_dodat1^o_dodat2^o_dodat3^o_dodat4^o_dodat5^o_dodat6^REVID;

   reg [3:0] r_lt_gpi; // {SCL,SDA,GPIO1,GPIO2}
   always @*
      if (~xrstz) // latch inferred, don't scan
         r_lt_gpi <= {DI_GPIO[0], // to consist with that defined in design note
                      DI_GPIO[1],
                      DI_GPIO[2],
                      DI_GPIO[3]};

   assign lt_gpi = atpg_en ? 'h0 : r_lt_gpi; // sync. in submodule

   assign tm = atpg_en // tm[0] is not used
	?{d_dodat[15:2],2'h0} // tm[1] will be used to select s_clk
	:(xrstz&(r_gpio_tm|di_tst) ?{15'h0, |r_lt_gpi[3:0]}<<r_lt_gpi :16'h0) &~16'h2 | // let tm[1] indepent to r_gpio_tm
			  (di_tst  ?{15'h0,~|r_lt_gpi[3:1]}<<r_lt_gpi :16'h0);

   assign tm_atpg = // don't refer to this in core, refer to atpg_en instead
			di_tst & (r_lt_gpi=='h0);

   assign tclk_sel = |{atpg_en,tm[1]};

   assign sram_rdat = atpg_en ? d_dodat[7:0]  : SRAM_RDAT;
   assign pmem_q0   = atpg_en ? d_dodat[15:8] : PMEM_Q0;
   assign pmem_q1   = atpg_en ? d_dodat[7:0]  : PMEM_Q1;
   assign dac1_comp = atpg_en ? d_dodat[8]    : DAC1_COMP;
   assign di_cc_49  = atpg_en ? d_dodat[9]    : RX_D_49;
   assign di_cc_pk  = atpg_en ? d_dodat[10]   : RX_D_PK;
   assign di_sqlch  = atpg_en ? d_dodat[11]   : RX_SQL;
   assign di_gpio   = atpg_en ? d_dodat[6:0]  : {DI_GPIO[6:5],t_di_gpio4,DI_GPIO[3:0]};
   assign di_pro    = atpg_en ? d_dodat[13:7] : SRCI[6:0];
   assign cc1_di    = atpg_en ? d_dodat[7]    : CC1_DI; // didn't inverted in analog, 2018/02/01 check
   assign cc2_di    = atpg_en ? d_dodat[15]   : CC2_DI; // CAN1112_REGTRM_define_20180130.xlsx
   assign dm_comp   = atpg_en ? d_dodat[12]   : DM_COMP;
   assign dp_comp   = atpg_en ? d_dodat[13]   : DP_COMP;
   assign id_di     = atpg_en ? d_dodat[14]   : ID_DI;
   assign dm_fault  = atpg_en ? d_dodat[15]   : DM_FAULT;
   assign di_ts     = atpg_en ? d_dodat[11]   : DI_TS;
   assign di_xanav  = atpg_en ? d_dodat[4:0]  : XANAV[4:0];
   assign di_rd_det = atpg_en ? d_dodat[12]   : RD_DET;
   assign di_stbovp = atpg_en ? d_dodat[13]   : STB_OVP;
   assign di_drposc = atpg_en ? d_dodat[13]   : DRP_OSC;
   assign di_imposc = atpg_en ? d_dodat[13]   : IMP_OSC;

   assign di_p0     = {dac1_comp,di_gpio[6:0]}; // may need de-bounce
   assign di_aswk   = {di_imposc,dm_fault,di_rd_det,di_stbovp,di_drposc};

