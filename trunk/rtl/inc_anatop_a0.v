
// DESCRIPTION
// -----------------------------------------------------------------------------
// this file is used (by `include) in DUT for
// 1. real chip simulation
// 2. FPGA simulation
// 3. is empty in synthesis of both cases
// Note :
// both DUT and FPGA included in chiptop_1126a0
// FPGA/AFE interface is the interface betweem FPGA and AFE
// DIGITAL/ANA interface is the interface betweem DIGITAL and anatop_1126a0
// -----------------------------------------------------------------------------

// FPGA/AFE interface defined in in/out, should not be declared again
`ifdef FPGA
`else
   wire [1:0] VCONN_EN,
              RP_EN;
   wire [17:0] SAMPL_SEL;
`endif
   wire [1:0] CC_SLOPE, // CAN1126A0 removed
	      OVP_SEL,
	      FSW,
              RP_SEL;
   wire [3:0] ANA_TM;
   wire [55:0] REGTRM;
   wire [9:0] DAC1;
   wire [10:0] DAC0;
   wire [7:0] PWR_I, DUMMY_IN;
   wire [5:0] DAC3_V;
`ifdef FPGA_SYNTHESIS // FPGA synthesis won't include U0_ANALOG_TOP
// following signals are from U0_CORE,
// to U0_ANALOG_TOP but not directly to FPGA IO, need declarations
   wire TX_EN, TX_DAT,
        DPDEN, DPDO,
        DNDEN, DNDO,
        CCI2C_EN, CC1_DOB, CC2_DOB, OSC_STOP,
	OPTO2, OPTO1,
	OCP_80M, OCP_160M;
`else // !FPGA_SYNTHESIS == FPGA_SIM
   wire [7:0] ANAOPT;
   wire CP_CLKX2	= ANAOPT[7];
   wire SEL_CONST_OVP	= ANAOPT[6];
   wire LP_EN		= ANAOPT[5];
   wire DNCHK_EN	= ANAOPT[3];
   wire IRP_EN		= ANAOPT[2];
   wire CCBFEN		= ANAOPT[0];
   anatop_1127a0 U0_ANALOG_TOP (
//	.VIN		(VIN),
	.CC1		(CC1),
	.CC2		(CC2),
	.DP		(DP),
	.DN		(DN),
	.VFB		(VFB),
	.CSP		(ISENP),
	.CSN		(ISENN),
	.COM		(COM),
	.LG		(LG),
	.SW		(SW),
	.HG		(HG),
	.BST		(BST),
	.GATE		(GATE),
	.VDRV		(VDRV),
// =============================================================================
	.BST_SET	(BST_SET),
	.DCM_SEL	(DCM_SEL),
	.HGOFF		(HGOFF),
	.HGLGOFF	(HGLGOFF),
	.HGON		(HGON),
	.LGON		(LGON),
	.ENDRV		(ENDRV),
	.FSW		(FSW),
	.EN_OSC		(EN_OSC),
	.MAXDS		(MAXDS),
	.EN_GM		(EN_GM),
	.EN_ODLDO	(EN_ODLDO),
	.EN_IBUK	(EN_IBUK),
// =============================================================================
	.RP_SEL		({
/*1*/			 RP_SEL[1],
			 RP_SEL[0]}),
	.RP1_EN		(RP_EN[0]),
	.RP2_EN		(RP_EN[1]),
	.RD_ENB		(RD_ENB),
	.STB_RP		(STB_RP),
	.DRP_OSC	(DRP_OSC),
	.IMP_OSC	(IMP_OSC),
	.VCONN1_EN	(VCONN_EN[0]),
/*10*/	.VCONN2_EN	(VCONN_EN[1]),
	.HVNG_CPEN	(HVNG_CPEN), // higher gate voltage for VCONN switch
//	.HVNB_CPEN	(HVNB_CPEN),
	.SGP		({
			 GP5_20U,	// CAN1127A0: GP5_20U/S2UB
			 GP4_20U,	// CAN1126A0
			 GP3_20U,	// CAN1126A0
			 GP2_20U,	// CAN1127A0
			 GP1_20U}),	// CAN1127A0
	.S20U		(S20U),		// CAN1127A0: remove B suffix
	.S100U		(S100U),	// CAN1127A0: remove B suffix
	.TX_EN		(TX_EN),
/*20*/	.TX_DAT		(TX_DAT),
	.CC_SEL		(CC_SEL),
	.TRA		(TRA),
	.TFA		(TFA),
	.RX_DAT		(RX_DAT),
	.RX_SQL		(RX_SQL),
	.LSR		(LSR),
	.SEL_RX_TH	(SEL_RX_TH),
	.DPDN_SHORT	(DPDN_SHORT),
	.DP_2V7_EN	(DP_2V7_EN),
/*30*/	.DN_2V7_EN	(DN_2V7_EN),
	.DP_0P6V_EN	(DP_0P6V_EN),
	.DN_0P6V_EN	(DN_0P6V_EN),
	.DP_DWN_EN	(DP_DWN_EN), // CAN1124A0 rename
	.DN_DWN_EN	(DN_DWN_EN),
//	.VIN_DISCHG_EN	(VIN_DISCHG),
	.VO_DISCHG	(VO_DISCHG),
	.DISCHG_SEL	(DISCHG_SEL),
	.CMP_SEL_GP1	(SAMPL_SEL[17]),
	.CMP_SEL_GP2	(SAMPL_SEL[16]),
	.CMP_SEL_GP3	(SAMPL_SEL[15]),
/*40*/	.CMP_SEL_GP4	(SAMPL_SEL[14]),
	.CMP_SEL_GP5	(SAMPL_SEL[13]),
	.CMP_SEL_CC2_4	(SAMPL_SEL[12]),
	.CMP_SEL_CC1_4	(SAMPL_SEL[11]),
	.CMP_SEL_VO20	(SAMPL_SEL[10]), // CAN1127: VIN20 -> VO20
	.CMP_SEL_DN_3	(SAMPL_SEL[9]), // D-/3
	.CMP_SEL_DP_3	(SAMPL_SEL[8]), // D+/3
	.CMP_SEL_CC2	(SAMPL_SEL[7]),
	.CMP_SEL_CC1	(SAMPL_SEL[6]),
	.CMP_SEL_DN	(SAMPL_SEL[5]),
/*50*/	.CMP_SEL_DP	(SAMPL_SEL[4]),
	.CMP_SEL_TS	(SAMPL_SEL[3]),
	.CMP_SEL_IS	(SAMPL_SEL[2]),
	.CMP_SEL_VIN20	(SAMPL_SEL[1]), // CAN1127: VBUS -> VIN20
	.CMP_SEL_VO10	(SAMPL_SEL[0]), // CAN1127: VIN -> VO10
	.DAC1_EN	(DAC1_EN), // CAN1124A0: DAC -> DAC1
	.DAC1		({
			 DAC1[9],
			 DAC1[8],
			 DAC1[7],
			 DAC1[6],
/*60*/			 DAC1[5],
			 DAC1[4],
			 DAC1[3],
			 DAC1[2],
			 DAC1[1],
			 DAC1[0]}),
	.AD_RST		(AD_RST),
	.AD_HOLD	(AD_HOLD),
	.COMP_O		(COMP_O),
	.CCI2C_EN	(CCI2C_EN),
/*70*/	.UVP_SEL	(UVP_SEL),
	.TM		({
			 ANA_TM[3],
			 ANA_TM[2],
			 ANA_TM[1],
			 ANA_TM[0]}),
	.RSTB		(RSTB),
	.CV2		(CV2),
	.DAC0		({
			 DAC0[10],
			 DAC0[9],
			 DAC0[8],
/*80*/			 DAC0[7],
			 DAC0[6],
			 DAC0[5],
			 DAC0[4],
			 DAC0[3],
			 DAC0[2],
			 DAC0[1],
			 DAC0[0]}),
	.DAC3		({		// CAN1121A0 new
			 DAC3_V[5],	// CAN1124A0 added
			 DAC3_V[4],
/*90*/			 DAC3_V[3],
			 DAC3_V[2],
			 DAC3_V[1],
			 DAC3_V[0]}),
	.SLEEP		(SLEEP),
	.OSC_LOW	(OSC_LOW),
	.OSC_STOP	(OSC_STOP),
	.PWRDN		(PWRDN),
	.VPP_ZERO	(VPP_0V),
/*100*/	.VPP_SEL	(VPP_SEL),	// pmem_vpphi
	.LDO3P9V	(LDO3P9V),	// LDO9V
	.OSC_O		(OSC_O),
	.RD_DET		(RD_DET),
//	.STB_OVP	(STB_OVP),
//	.CC_SLOPE	({
//			 CC_SLOPE[1], // CAN1124A0 added, CAN1126A0 removed
//			 CC_SLOPE[0]}),
//	.CABLE_COMP	({
//			 CABLE_COMP[3],
//			 CABLE_COMP[2],
//			 CABLE_COMP[1],
//			 CABLE_COMP[0]}), // CAN1121A0 [2:0] -> [3:0], CAN1126A0 removed
//	.PWR_ENABLE	(PWR_ENABLE), // CAN1126A0 changes
	.PWREN		(PWREN),
//	.PWREN_B	(PWREN_B),
	.ANTI_INRUSH	(ANTI_INRUSH),	// CAN1121A0 new
//	.CC_PROT	(CC_PROT),
	.OVP_SEL	({
			 OVP_SEL[1],
			 OVP_SEL[0]}),	// CAN1121A0 new
	.OVP		(OVP),
	.UVP		(UVP),
	.PWR_I		({
                         PWR_I[7], // CAN1121A0 add 1-bit
			 PWR_I[6],
			 PWR_I[5],
			 PWR_I[4],
			 PWR_I[3],
			 PWR_I[2],
			 PWR_I[1],
			 PWR_I[0]}),
	.OCP_EN		(OCP_EN),
	.CS_EN		(CS_EN),
//	.IFB_CUT	(IFB_CUT),	// CAN1121A0 new
	.OCP_SEL	(OCP_SEL),
	.V5OCP		(V5OCP),
//	.CF		(OTPI_C),	// CAN1124A0: separate OTP_CF
	.OCP_80M	(OCP_80M),
	.OCP_160M	(OCP_160M),
	.OCP		(OCP),
	.SCP		(SCP),
	.OTPI		(OTPI_S),	// CAN1124A0: separate OTP_CF
	.CC1_DOB	(CC1_DOB),	// CAN1121A0 new
	.CC2_DOB	(CC2_DOB),	// CAN1121A0 new
	.CC1_DI		(CC1_DI),	// CAN1121A0 new, CAN1124A0: DIB -> DI
	.CC2_DI		(CC2_DI),	// CAN1121A0 new, CAN1124A0: DIB -> DI
//	.TX_DRV0	(TX_DRV0),
	.DP_COMP	(DP_COMP),
	.DN_COMP	(DN_COMP),
	.DPDN_VTH	(DPDN_VTH),
	.DPIE		(DPDNIE),
	.DNIE		(DPDNIE),
	.DPDEN		(DPDEN),
	.DPDO		(DPDO),
	.DNDEN		(DNDEN),
	.DNDO		(DNDO),
//	.IDEN		(IDOE),
//	.IDDO		(IDDO),
//	.IDIN		(IDDI),
	.CP_CLKX2	(CP_CLKX2),		// REGTRM[47]
	.SEL_CONST_OVP	(SEL_CONST_OVP),	// REGTRM[46]
	.LP_EN		(LP_EN),		// REGTRM[45]
//	.LP_SEL		(LP_SEL),		// REGTRM[44]
	.DNCHK_EN	(DNCHK_EN),		// REGTRM[43]
	.IRP_EN		(IRP_EN),		// REGTRM[42]
//	.VBUS_REG_SEL	(VBUS_REG_SEL),		// REGTRM[41]
	.CCBFEN		(CCBFEN),		// REGTRM[40]
	.DN_FAULT	(DN_FAULT),
	.REGTRM		({
			 REGTRM[55],
			 REGTRM[54],
			 REGTRM[53],
			 REGTRM[52],
			 REGTRM[51],
			 REGTRM[50],
			 REGTRM[49],
			 REGTRM[48],
			 REGTRM[47],
			 REGTRM[46],
			 REGTRM[45],
			 REGTRM[44],
			 REGTRM[43],
			 REGTRM[42],
			 REGTRM[41],
			 REGTRM[40],
			 REGTRM[39],
			 REGTRM[38],
			 REGTRM[37],
			 REGTRM[36],
			 REGTRM[35],
			 REGTRM[34],
			 REGTRM[33],
			 REGTRM[32],
			 REGTRM[31],
			 REGTRM[30],
			 REGTRM[29],
			 REGTRM[28],
			 REGTRM[27],
			 REGTRM[26],
			 REGTRM[25],
			 REGTRM[24],
			 REGTRM[23],
			 REGTRM[22],
			 REGTRM[21],
			 REGTRM[20],
			 REGTRM[19],
			 REGTRM[18],
			 REGTRM[17],
			 REGTRM[16],
			 REGTRM[15],
			 REGTRM[14],
			 REGTRM[13],
			 REGTRM[12],
			 REGTRM[11],
			 REGTRM[10],
			 REGTRM[ 9],
			 REGTRM[ 8],
			 REGTRM[ 7],
			 REGTRM[ 6],
			 REGTRM[ 5],
			 REGTRM[ 4],
			 REGTRM[ 3],
			 REGTRM[ 2],
			 REGTRM[ 1],
			 REGTRM[ 0]}),
	.SEL_CCGAIN	(SEL_CCGAIN),
//	.SEL_OCDRV	(SEL_OCDRV),
//	.SEL_FB		(SEL_FB),
	.VFB_SW		(VFB_SW),
	.CLAMPV_EN	(CLAMPV_EN),
	.CPV_SEL	(CPV_SEL), // lower voltage for PWREN charge pump
	.PWREN_HOLD	(PWREN_HOLD), // once named CPF_SEL
//	.T3A		(T3A),
//	.CC_FT		(CC_FT),
//	.CS_DIR		(CS_DIR),
	.LFOSC_ENB	(LFOSC_ENB),
//	.IDAC_EN	(IDAC_EN),
//	.IDAC_SEN	(IDAC_SEN),
	.OPTO1		(OPTO1),
	.OPTO2		(OPTO2),
	.DUMMY_IN	({
			 DUMMY_IN[ 7],
			 DUMMY_IN[ 6],
			 DUMMY_IN[ 5],
			 DUMMY_IN[ 4],
			 DUMMY_IN[ 3],
			 DUMMY_IN[ 2],
			 DUMMY_IN[ 1],
			 DUMMY_IN[ 0]}),
// -----------------------------------------------------------------------------
	.VPP_OTP	(VPP_OTP),	// let APR route to OTP
	.VDD_OTP	(VDD_OTP),	// let APR route to OTP
	.RSTB_5		(IO_RSTB5),	// let APR route to IO cells
	.V1P1		(V1P1),		// let APR route to IO cells
	.TS_ANA_P	(ANAP_TS),	// let APR route to IO cell TS
	.TS_ANA_R	(TS_ANA_R),	// let APR route to IO cell TS
	.GP1_ANA_P	(ANAP_GP1),	// let APR route to IO cell GPIO1
	.GP1_ANA_R	(GP1_ANA_R),	// let APR route to IO cell GPIO1
	.GP2_ANA_P	(ANAP_GP2),	// let APR route to IO cell GPIO2
	.GP2_ANA_R	(GP2_ANA_R),	// let APR route to IO cell GPIO2
	.GP3_ANA_P	(ANAP_GP3),	// let APR route to IO cell GPIO3
	.GP3_ANA_R	(GP3_ANA_R),	// let APR route to IO cell GPIO3
	.GP4_ANA_P	(ANAP_GP4),	// let APR route to IO cell GPIO4
	.GP4_ANA_R	(GP4_ANA_R),	// let APR route to IO cell GPIO4
	.GP5_ANA_P	(ANAP_GP5),	// let APR route to IO cell GPIO5
	.GP5_ANA_R	(GP5_ANA_R) 	// let APR route to IO cell GPIO5
   ); // U0_ANALOG_TOP

`endif // FPGA_SYNTHESIS

