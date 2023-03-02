
module chiptop_1127a0 (
// =============================================================================
// USBPD project, CAN1127
// copy from CAN1126
// +FPGA+SMIMS
// ALL RIGHTS ARE RESERVED
// =============================================================================
`ifdef FPGA
input		V5OCP,UVP,SCP,OCP,OVP,
		OTPI_S,OTPI_C,
output	[2:0]	rp_type_en,
output	[1:0]	VCONN_EN, RP_EN,
input		RX_D, COMP_O, // AFE from CAN1119/COMP_O
output		CC_SEL, AD_RST, AD_HOLD,
		oeb_cc, doe_cc, // for FPGA AFE voltage divider CC driver
		TX_DRV0,
		PWREN_A,
		DISCHARGE,
output	[9:2]	dac_pwr_v, dac1_9_2,
output	[15:0]	SAMPL_SEL,
output		DP_2V7_EN, DP_DWN_EN, DPDN_SHORT,
		DN_2V7_EN, DN_DWN_EN,
output	[31:0]	smims_j8_o,
input	[1:0]	smims_j8_i,
output	[7:0]	smims_ledz,
output	[6:0]	o_pull,
output	[1:0]	o_lo,
input		i_porz,
		smims_osc48,
		smims_clkgen,
		smims_rstzbtn, // reset button
input		smims_cmdbtn, // command button, low-active
input	[3:0]	smims_dipmux, // DIP for mux selector
output		uart_tx, // J11_1
inout		uart_rx, // J11_2
inout		scl, // J11_3
inout		sda, // J11_4
inout		GPIO6, // for AFE
input		IDDI, // D+/D-/CC1/CC2 OVP
`else // !FPGA
inout		VBUS,
output		GATE_A, GATE_B, OCDRV,
input		ISENP, ISENN,
input		VFB, IFB,
`endif // FPGA
inout		DP, DN, CC1, CC2,
inout		TST,
input		TS, // resistor for OTP
inout		SCL, SDA, GPIO1, GPIO2,
inout		GPIO3, GPIO4, GPIO5
);
   wire SRAM_CLK, xdat_web, xdat_ceb, xdat_oeb;
   wire [7:0] xdat_d, SRAM_RDAT;
   wire [10:0] xdat_a;
   wire #2 SRAM_WEB = xdat_web;
   wire #2 SRAM_CEB = xdat_ceb;
   wire #2 SRAM_OEB = xdat_oeb;
   wire [10:0] #2 SRAM_A = xdat_a;
   wire [7:0] #2 SRAM_D = xdat_d;
   wire [7:0] #2 xdat_o = SRAM_RDAT;

// declare DIGITAL/ANA interface and connect it
// connect FPGA/AFE interface -> part by naming
   `include "inc_anatop_a0.v"

// digital IO interface, not in FPGA/AFE interface
   wire [6:0] DI_GPIO, DO_GPIO, OE_GPIO, PU_GPIO, PD_GPIO;
   wire [1:0] IE_GPIO;
   wire [3:0] DO_TS;

`ifdef FPGA
   `include "inc_fpga.v"
`else // !FPGA
   wire mclk = OSC_O;
   wire core_rstz = RSTB;

// PDDSDGZ1 // VIS : CUP
// ICBD53S_U // MAXCHIP : CUP
// PDT02SDGZ // VIS : CUP,PU,PD
// BCTB2N3S_UUD // MAXCHIP : CUP,PU,PD
// IOB3PURUDA_A0 // CAN1123A0 choose the 3.3V IO with 5V VCC applied
// IOBPURUDA_A0 // choose the IO with 50-Ohm output impedence @20221011
   IODMURUDA_A0 // w/o ANA_P connected
   PAD_SCL   (.PAD(SCL),  .IE(IE_GPIO[1]),.DI(DI_GPIO[0]),.OE(OE_GPIO[0]),.DO(DO_GPIO[0]),.PU(PU_GPIO[0]),.PD(PD_GPIO[0]),.ANA_R(),.RSTB_5(ANA_RSTB5),.VB(V1P1)),
   PAD_SDA   (.PAD(SDA),  .IE(IE_GPIO[1]),.DI(DI_GPIO[1]),.OE(OE_GPIO[1]),.DO(DO_GPIO[1]),.PU(PU_GPIO[1]),.PD(PD_GPIO[1]),.ANA_R(),.RSTB_5(ANA_RSTB5),.VB(V1P1));
   IOBMURUDA_A0 // w/o ANA_P connected
   PAD_TST   (.PAD(TST),  .IE(1'h1),      .DI(DI_TST),    .OE(1'h0),      .DO(1'h0),      .PU(1'h0),      .PD(1'h1),      .ANA_R(),.RSTB_5(ANA_RSTB5),.VB(V1P1)),
   PAD_GPIO1 (.PAD(GPIO1),.IE(IE_GPIO[0]),.DI(DI_GPIO[2]),.OE(OE_GPIO[2]),.DO(DO_GPIO[2]),.PU(PU_GPIO[2]),.PD(PD_GPIO[2]),.ANA_R(),.RSTB_5(ANA_RSTB5),.VB(V1P1)),
   PAD_GPIO2 (.PAD(GPIO2),.IE(IE_GPIO[0]),.DI(DI_GPIO[3]),.OE(OE_GPIO[3]),.DO(DO_GPIO[3]),.PU(PU_GPIO[3]),.PD(PD_GPIO[3]),.ANA_R(),.RSTB_5(ANA_RSTB5),.VB(V1P1));
   IOBMURUDA_A1 // w/ ANA_P connected
   PAD_GPIO3 (.PAD(GPIO3),.IE(IE_GPIO[0]),.DI(DI_GPIO[4]),.OE(OE_GPIO[4]),.DO(DO_GPIO[4]),.PU(PU_GPIO[4]),.PD(PD_GPIO[4]),.ANA_R(GP3_ANA_R),.ANA_P(ANAP_GP3),.RSTB_5(ANA_RSTB5),.VB(V1P1)),
   PAD_GPIO4 (.PAD(GPIO4),.IE(IE_GPIO[0]),.DI(DI_GPIO[5]),.OE(OE_GPIO[5]),.DO(DO_GPIO[5]),.PU(PU_GPIO[5]),.PD(PD_GPIO[5]),.ANA_R(GP4_ANA_R),.ANA_P(ANAP_GP4),.RSTB_5(ANA_RSTB5),.VB(V1P1)),
   PAD_GPIO5 (.PAD(GPIO5),.IE(IE_GPIO[0]),.DI(DI_GPIO[6]),.OE(OE_GPIO[6]),.DO(DO_GPIO[6]),.PU(PU_GPIO[6]),.PD(PD_GPIO[6]),.ANA_R(GP5_ANA_R),.ANA_P(ANAP_GP5),.RSTB_5(ANA_RSTB5),.VB(V1P1)),
   PAD_TS    (.PAD(TS),   .IE(IE_GPIO[0]),.DI(DI_TS),     .OE(DO_TS[2]),  .DO(DO_TS[3]),  .PU(DO_TS[1]),  .PD(DO_TS[0]),  .ANA_R(TS_ANA_R), .ANA_P(ANAP_TS), .RSTB_5(ANA_RSTB5),.VB(V1P1));

// MSL18B_1536X8_RW10TM4_16_20210427 // Kim@20210608: too long for APR
   MSL18B_1536X8_RW10TM4_16 U0_SRAM (
	.CK	(SRAM_CLK),
	.CSB	(SRAM_CEB),
	.WEB	(SRAM_WEB),
	.OEB	(SRAM_OEB),
	.A	(SRAM_A),
	.DI	(SRAM_D),
	.DO	(SRAM_RDAT));
`endif // !FPGA

   wire [15:0] PMEM_A;
   wire [7:0] PMEM_Q1,PMEM_Q0;
   wire [1:0] PMEM_CLK;
   wire [1:0] PMEM_TWLB,PMEM_SAP;
`ifdef FPGA
   ATO0008KX8VI150BG33NA_FPGA U0_CODE [1:0] (
	.pswdat	({2{~memdatao}}),
	.pswr	({2{mempswr}}),
	.mclk	({2{mclk}}),
	.VDDP	({2{VPP_SEL}}),
`else // !FPGA
   ATO0008KX8MX180LBX4DA U0_CODE [1:0] (
	.VDDP	({2{VPP_OTP}}),
`endif
	.A	({2{PMEM_A}}),
	.CSB	({2{PMEM_CSB}}),
	.CLK	(PMEM_CLK),
	.PGM	({2{PMEM_PGM}}),
	.RE	({2{PMEM_RE}}),
	.TWLB	({2{PMEM_TWLB}}),
	.VSS	(), // left empty for formal check
	.VDD	(), // left empty for formal check
	.SAP	({2{PMEM_SAP}}),
	.Q	({PMEM_Q1,PMEM_Q0})
   );

   wire [7:0] do_cvctl, do_srcctl, do_ccctl, do_cctrx;
   wire [7:0] do_pwr_i;
   wire [5:0] do_dpdm;
   wire [5:0] do_vooc;
   wire [7:0] do_xana0, do_xana1;
   wire [3:0] do_regx_xtm;
   assign {
	HVNG_CPEN,	// XANA1[7]
	CPV_SEL,	// XANA1[6]
	CLAMPV_EN,	// XANA1[5]
	PWREN_B,	// XANA1[4]
	DP_0P6V_EN,	// XANA1[3]
	DN_0P6V_EN,	// XANA1[2]
	V3VD_SEL[1:0]	// XANA1[1:0]
	} = do_xana1;
   assign {
	UVP_SEL,	// XANA0[7]
	CS_DIR,		// XANA0[6], dummy@0624 -> CS_DIR (20220915)
	DPDN_VTH,	// XANA0[5]
	VBUS_400K,	// XANA0[4]
	SEL_CCGAIN,	// XANA0[3]
	SEL_OCDRV,	// XANA0[2]
	SEL_FB,		// XANA0[1]
	CV2		// XANA0[0]
	} = do_xana0;
   assign {
	GP4_20U,
	GP3_20U,
	CC_FT,
	T3A} = do_regx_xtm;
   assign {
	OVP_SEL[1:0],
	ANTI_INRUSH,
	IFB_CUT,
	CC_PROT,
	OCP_EN,
	CV_ENB,
	CC_ENB} = do_cvctl;
   assign
	RP_EN		= do_ccctl[7:6],
	RP_SEL		= do_ccctl[5:4],
//      cc_rd_enb       = do_ccctl[3:2], // CAN1112 removed
	TX_DRV0		= do_ccctl[1],
	CC_SEL		= do_ccctl[0];
   assign {
	IDOE, // EN_VBUS_REG
	IDDO, // VBUSREG_V
	DPDEN,
	DPDO,
	DNDEN,
	DNDO} = do_vooc;
   assign {
	DPDNIE,
	DP_2V7_EN,
	DN_2V7_EN,
	DP_DWN_EN,
	DN_DWN_EN,
	DPDN_SHORT} = do_dpdm;
   assign {
	CC_SLOPE[1], // LDO9V, CAN1126A0 removed
	CC_SLOPE[0], // CC_SLOPE, CAN1126A0 removed
	DISCHG_SEL,
	VBUS_DISCHG,
	VCONN_EN[1:0],
	VIN_DISCHG,
	PWREN_A} = do_srcctl;
   assign {
	CCLEVEL,
	CCBIAS,
	TFA,
	TRA,
	CS_EN, // CAN1112 removed, CAN1126A0: pk_set -> CS_EN
	S100UB,
	S20UB,
	S2UB
	} = do_cctrx;
   wire [4:0] di_xanav = {
	1'h0,
	OPTO2,
	OPTO1,
	OCP_80M,
	OCP_160M};
   wire [6:0] srci = {
	OTPI_S, // original OTPI
	V5OCP,
	SCP,
	OTPI_C, // CF
	OVP,
	OCP,
	UVP};

   core_a0 U0_CORE (
	.SRCI		(srci),
	.XANAV		(di_xanav),
	.ANA_REGX	({do_xana1,do_xana0}),
	.LFOSC_ENB	(LFOSC_ENB), // XANA2[7]
	.STB_RP		(STB_RP), // XANA2[3] ^ DRP_OSC
	.RD_ENB		(RD_ENB), // XANA2[2] ^ DRP_OSC
	.OCP_SEL	(OCP_SEL), // XANA2[1]
	.PWREN_HOLD	(PWREN_HOLD), // XANA2[0]
	.XTM		(do_regx_xtm),
	.IDAC_EN	(IDAC_EN),
	.IDAC_SEN	(IDAC_SEN),
	.DRP_OSC	(DRP_OSC),
	.IMP_OSC	(IMP_OSC),
	.CC1_DI		(CC1_DI),
	.CC2_DI		(CC2_DI),
	.CC1_DOB	(CC1_DOB),
	.CC2_DOB	(CC2_DOB),
//	.CABLE_COMP	(CABLE_COMP), // CAN1126 removed
	.LDO3P9V	(LDO3P9V),
	.DO_SRCCTL	(do_srcctl),
	.DO_CVCTL	(do_cvctl),
	.DO_PWR_I	(PWR_I),
	.DO_DAC0	(DAC0),
	.DO_DPDN	(do_dpdm),
	.DO_VOOC	(do_vooc),
	.ID_DI		(IDDI),
	.DO_CCCTL	(do_ccctl),
	.DO_CCTRX	(do_cctrx),
// -----------------------------------------------------------------------------
	.PMEM_A		(PMEM_A),
	.PMEM_CSB	(PMEM_CSB),
	.PMEM_RE	(PMEM_RE),
	.PMEM_PGM	(PMEM_PGM),
	.PMEM_CLK	(PMEM_CLK),
	.PMEM_Q0	(PMEM_Q0),
	.PMEM_Q1	(PMEM_Q1),
	.PMEM_TWLB	(PMEM_TWLB),
	.PMEM_SAP	(PMEM_SAP),
// -----------------------------------------------------------------------------
	.SRAM_CLK	(SRAM_CLK),
	.SRAM_WEB	(xdat_web),
	.SRAM_CEB	(xdat_ceb),
	.SRAM_OEB	(xdat_oeb),
	.SRAM_A		(xdat_a),
	.SRAM_D		(xdat_d),
	.SRAM_RDAT	(xdat_o),
// -----------------------------------------------------------------------------
	.DO_TS		(DO_TS),
	.DI_TS		(DI_TS),
	.GPIO_IE	(IE_GPIO),
	.GPIO_PU	(PU_GPIO),
	.GPIO_PD	(PD_GPIO),
	.OE_GPIO	(OE_GPIO),
	.DO_GPIO	(DO_GPIO),
	.DI_GPIO	(DI_GPIO),
	.RX_D_49	(RX_D_49),
	.RX_D_PK	(RX_D_PK),
	.RX_SQL		(RX_SQL),
	.TX_DAT		(TX_DAT),
	.TX_EN		(TX_EN),
	.SLEEP		(SLEEP),
	.OCDRV_ENZ	(OCDRV_ENZ),
	.PWRDN		(PWRDN),
	.VPP_SEL	(VPP_SEL),
	.VPP_0V		(VPP_0V),
	.OSC_STOP	(OSC_STOP),
	.OSC_LOW	(OSC_LOW),
	.RD_DET		(RD_DET),
	.STB_OVP	(STB_OVP),
	.DAC1_EN	(DAC1_EN),
	.DAC1_V		(DAC1),
	.SAMPL_SEL	(SAMPL_SEL),
	.DAC1_COMP	(COMP_O),
	.CCI2C_EN	(CCI2C_EN),
	.ANA_TM		(ANA_TM),
	.ANA_OPT	(REGTRM),
	.DUMMY_IN	(DUMMY_IN),
	.SH_RST		(AD_RST),
	.SH_HOLD	(AD_HOLD),
	.DP_COMP	(DP_COMP),
	.DM_COMP	(DN_COMP),
	.DM_FAULT	(DN_FAULT),
	.DAC3_V		(DAC3_V),
	.tm_atpg	(tm_atpg), // O
	.atpg_en	(tm_atpg), // I
	.di_tst		(DI_TST),
	.i_clk		(mclk),
`ifdef FPGA
	.o_s0_tx	(uart_tx),	// O: MON51
	.i_s0_rx	(i_srx),	// I: MON51
	.do_s0rx	(srx_do),	// O: MON51
	.oe_s0rx	(srx_oe),	// O: MON51
	.o_cpurst	(cpurst),	// O:
	.memaddr	(memaddr),	// O: MON51 von Neumann memory
	.mempswr	(mempswr),	// O: MON51 von Neumann memory
	.memdatao	(memdatao),
	.memaddr_c	(memaddr_c),	// O: MON51 von Neumann memory
	.memdatao_c	(memdatao_c),	// O: MON51 von Neumann memory
	.mempswr_c	(mempswr_c),	// O: MON51 von Neumann memory
	.memwr_c	(memwr_c),	// O: MON51 von Neumann memory
	.monm_rdat	(monm_rdat),	// I: MON51 von Neumann memory
	.hit_mo		(hit_mo),	// O: MON51 von Neumann memory
	.pc_ini		(pc_ini),	// I: MON51 location
	.dbgpo		(core_dbgpo),	// FPGA
	.dbgsel		(smims_dipmux),	// FPGA
`endif // FPGA
	.i_rstz		(core_rstz)
   ); // U0_CORE

endmodule // chiptop_1127a0
