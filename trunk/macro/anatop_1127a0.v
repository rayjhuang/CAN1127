// File       : anatop_1127a0.v
// Description: analog top for CAN1127, copy from anatop_1126a0.v
// 20230302   : z:\RD\Project\CAN1127\
`timescale 1ns/100ps
module anatop_1127a0 (
//inout		VIN ,	// VIN
//inout		PGND ,	// Analog GND
//inout		GND ,	// Digital GND
//inout		V5V ,	// 5.0V LDO out
// === P D  PAD ================================================================
inout		CC1 ,
inout		CC2 ,
inout		DP ,
inout		DN ,
inout		VFB ,
inout		CSP , CSN ,
// === B U C K  PAD ============================================================
inout		COM, LG, SW, HG, BST, GATE, VDRV,
// === B U C K  interface part =================================================
input		BST_SET ,
		DCM_SEL ,
		HGOFF ,
		HGLGOFF ,
		HGON ,
		LGON ,
		ENDRV ,
input	[1:0]	FSW ,
input		EN_OSC ,
input		MAXDS ,
		EN_GM ,
		EN_ODLDO ,
		EN_IBUK ,
// === P D  interface part =====================================================
input   [1:0]   RP_SEL ,
input		RP1_EN ,
input		RP2_EN ,
input		VCONN1_EN ,
input		VCONN2_EN ,
input	[5:1]	SGP , // high-active, 20uA current source enable
input		S20U , S100U , // high-active, CAN1127 removes B suffix
input		TX_EN ,
input		TX_DAT ,
input		CC_SEL ,
input		TRA , TFA , LSR ,
output		RX_DAT ,
output		RX_SQL ,
input		SEL_RX_TH , // CAN1127 changes name, CCLEVEL ,
input		DAC1_EN ,
input		DPDN_SHORT ,
input		DP_2V7_EN , DN_2V7_EN ,
input		DP_0P6V_EN , DN_0P6V_EN ,
input		DP_DWN_EN , DN_DWN_EN ,
input	[7:0]	PWR_I ,
input	[5:0]	DAC3,
input	[9:0]	DAC1 ,
input		CV2 , LFOSC_ENB ,
input		VO_DISCHG ,
		DISCHG_SEL ,
//		T3A, CC_FT,
input		CMP_SEL_VO10 , CMP_SEL_VO20 ,
input		CMP_SEL_GP1 , CMP_SEL_GP2 ,
input		CMP_SEL_GP3 , CMP_SEL_GP4 , CMP_SEL_GP5 , CMP_SEL_VIN20,
input		CMP_SEL_TS ,
input		CMP_SEL_IS ,
input		CMP_SEL_CC2 ,
input		CMP_SEL_CC1 ,
input		CMP_SEL_CC2_4 ,
input		CMP_SEL_CC1_4 ,
input		CMP_SEL_DP , CMP_SEL_DP_3 ,
input		CMP_SEL_DN , CMP_SEL_DN_3 ,
input		OCP_EN , CS_EN ,
output		COMP_O ,
input		CCI2C_EN ,
		UVP_SEL ,
input	[3:0]	TM ,
output		V5OCP ,
output		RSTB ,
input	[10:0]	DAC0 ,
input		SLEEP ,
input		OSC_LOW , OSC_STOP , PWRDN , VPP_ZERO ,
output		OSC_O , RD_DET ,
		IMP_OSC , DRP_OSC ,
input		STB_RP , RD_ENB ,
//put	[3:0]	CABLE_COMP ,
input		PWREN ,
output		OCP ,
output		SCP ,
output		UVP ,
input		LDO3P9V , VPP_SEL ,
input		CC1_DOB ,
input		CC2_DOB ,
output		CC1_DI ,
output		CC2_DI ,
input		ANTI_INRUSH ,
//put		IFB_CUT ,
output		OTPI , // CF ,
//put		CC_PROT ,
input	[1:0]	OVP_SEL ,
output		OVP ,
//put		TX_DRV0 ,
output		DN_COMP ,
		DP_COMP ,
input		DPDN_VTH ,
input		DPDEN , DPDO , DPIE ,
		DNDEN , DNDO , DNIE ,
//		IDEN ,  IDDO ,
//tput		IDIN ,
input   [7:0]   DUMMY_IN ,
input	        CP_CLKX2 ,	// REGTRM[47]
		SEL_CONST_OVP ,	// REGTRM[46]
		LP_EN ,		// REGTRM[45]
//		LP_SEL ,	// REGTRM[44]
		DNCHK_EN ,	// REGTRM[43]
		IRP_EN ,	// REGTRM[42]
//		VBUS_REG_SEL ,	// REGTRM[41]
		CCBFEN ,	// REGTRM[40]
input   [55:0]  REGTRM ,
input		AD_RST , AD_HOLD ,
output		DN_FAULT ,
input		
		SEL_CCGAIN , VFB_SW ,
//		SEL_OCDRV , SEL_FB ,
		CPV_SEL ,
		CLAMPV_EN ,
input		HVNG_CPEN , PWREN_HOLD , // CPF_SEL ,
		OCP_SEL ,
//		IDAC_EN , IDAC_SEN ,
output		OCP_80M , OCP_160M ,
output		OPTO1 , OPTO2,
// =============================================================================
output		VPP_OTP ,
output		VDD_OTP ,
//output	VD18 , // power supply for digital core
output		RSTB_5 , V1P1 , // analog signals for IO cells
input		TS_ANA_R , GP5_ANA_R , GP4_ANA_R , GP3_ANA_R , GP2_ANA_R , GP1_ANA_R , // analog signals of IO cells and ADC
output		TS_ANA_P , GP5_ANA_P , GP4_ANA_P , GP3_ANA_P , GP2_ANA_P , GP1_ANA_P   // analog signals of 100+20uA/20uA output
 ); // anatop_1127a0

`ifdef ANATOP_EMPTY // SYNTHESIS
// an empty module in synthesis
// an empty module in formal check will be modeled as a black box and compared
`else
assign VPP_OTP = VPP_SEL & ~VPP_ZERO;
assign VDD_OTP = 1;

wire [15:0] v_CC1, v_CC2, v_DP, v_DN; // assigned in bench_0.v, bench_u0.v
assign #1 DP  = DPDEN ? DPDO : 1'hz; // digital output only
assign #1 DN  = DNDEN ? DNDO : 1'hz; // digital output only
assign #1 CC1 = CCI2C_EN & CC1_DOB ? 1'h0 : 1'hz; // digital output only
assign #1 CC2 = CCI2C_EN & CC2_DOB ? 1'h0 : 1'hz; // digital output only
assign #1 CC1_DI = v_CC1>=1800 && CCI2C_EN; // 1.0~2.6V
assign #1 CC2_DI = v_CC2>=1800 && CCI2C_EN; // 1.0~2.6V

assign #10 GATE = PWREN;

reg r_otpi=0, r_ovp=0, r_ocp=0, r_scp=0, r_uvp=0, r_v5ocp=0, r_cf=0;
assign {V5OCP, OTPI, OVP, OCP, SCP, UVP} = {r_v5ocp, r_otpi, r_ovp, r_ocp, r_scp, r_uvp};
reg r_dn_fault=0;
reg r_DpDnCC_ovp=0;
assign DN_FAULT = r_dn_fault;

reg r_ocp80m=0, r_ocp160m=0, r_opto1=0, r_opto2=0;
assign {OCP_80M, OCP_160M, OPTO1, OPTO2} = {r_ocp80m, r_ocp160m, r_opto1, r_opto2};

assign #1 DP_COMP = v_DP > 1200;
assign #1 DN_COMP = v_DN > 1200;

   wire [15:0] rx_v_cc = CC_SEL ?v_CC2 :v_CC1;
   bhv_cc_rcver cc_rcver (rx_v_cc,RX_SQL,RX_D_PK,RX_D_49);
   assign RX_DAT = RX_D_49;

reg [15:0] v_VIN=0, v_IS=0, v_RT=1000, v_GP5=0, v_GP4=0, v_GP3=0, v_GP2=0, v_GP1=0; // mV

integer delta_VIN, VIN_target0, VIN_target;
always @(DAC0 or DAC3 or CV2) VIN_target0 = (DAC0+DAC3*2)*(CV2?20:10); // 20/40mV
wire stb_pulse = VIN_target0<50; // DAC0=4
reg r_standby =0;
always @(posedge stb_pulse) begin: calc_standby
   if (r_standby) fork
      #(1000*6) r_standby = 0; // 10us to exit (for sim.)
      @stb_pulse disable calc_standby;
   join else fork
      #(1000*40) r_standby = 1; // entered after 40us (for sim.)
      @stb_pulse disable calc_standby;
   join
end
always @(r_standby or VIN_target0)
   VIN_target = r_standby ? 4000 : VIN_target0;

always #1000 if (VIN_target!=v_VIN) begin
   delta_VIN = VIN_target - v_VIN;
   v_VIN = v_VIN + ((delta_VIN<=33 && delta_VIN>0) ?1
                   :(delta_VIN<0 && delta_VIN>=-33) ?-1 :$signed(delta_VIN*3/100));
end

wire [15:0] v_VO; // assigned in bench_u0.v
reg [15:0] v_DAC_CV; // used in bench_u0.v
always @(DAC0 or DAC3 or CV2) v_DAC_CV = (DAC0+DAC3*2)*(CV2?2:1); // mV

bhv_compm_mux #(18)
compm_mux (
	.dac_sel ({
		CMP_SEL_GP1,
		CMP_SEL_GP2,
		CMP_SEL_GP3,
		CMP_SEL_GP4,
		CMP_SEL_GP5,
		CMP_SEL_CC2_4,
		CMP_SEL_CC1_4,
		CMP_SEL_VO20,
		CMP_SEL_DN_3,
		CMP_SEL_DP_3,
		CMP_SEL_CC2,
		CMP_SEL_CC1,
		CMP_SEL_DN,
		CMP_SEL_DP,
		CMP_SEL_TS,
		CMP_SEL_IS,
		CMP_SEL_VO10,
		CMP_SEL_VIN20}),
	.sh_rst (AD_RST),
	.sh_hold (AD_HOLD),
	.dac_code (DAC1),
	// below scan sequence is implemented in core logic
	.v_ana_in ({
		v_GP1,
		v_GP2,
		v_GP3,
		v_GP4,
		v_GP5,
		v_CC2/16'd4,
		v_CC1/16'd4,
		v_VO/16'd20,
		v_DN/16'd3,
		v_DP/16'd3,
		v_CC2/16'd2,
		v_CC1/16'd2,
		v_DN,
		v_DP,
		v_RT,
		v_IS,
		v_VO/16'd10,
		v_VIN/16'd20}),
	.comp_o (comp_o));

assign #1 COMP_O = DAC1_EN ? comp_o : 'h0;
assign IDIN = r_DpDnCC_ovp; // since CAN1121B0

// --- begin POR, OSC
// -----------------------------------------------------------------------------
   reg r_clk, r_rstz, d_rstz;
   assign RSTB_5 = r_rstz; // IO ready first
   assign RSTB   = d_rstz; // for HW trap
   assign #(100) RD_DET = v_CC1 <= 2000 && v_CC1 >= 600
                       || v_CC2 <= 2000 && v_CC2 >= 600;
   initial begin
	r_clk =0;
	r_rstz =0;
	d_rstz =0;
	#30_000
	fork
	      #1_000 r_rstz =1; // 8-clock after
	   #1001_000 d_rstz =1; // 100us after
	   forever
		if (OSC_STOP) #5                 r_clk =0;
		else if (OSC_LOW) begin:osc_low
		              #(1000000.0/100/2) r_clk = ~r_clk;
		end else      #(1000.0/12/2)     r_clk = ~r_clk;
	join
   end
   always @(negedge OSC_LOW) #5 disable osc_low;
   always @(PWREN) $display ($time,"ns <%m> power enable -> %d",PWREN);
   always @(VO_DISCHG) $display ($time,"ns <%m> VO (VBUS) discharge -> %d",VO_DISCHG);
`ifdef ATPG
`else // for ATPG don't want this
   always @(CC_SEL)     $display ($time,"ns <%m> cable orientation -> %d",CC_SEL);
`endif
   assign #2.5 OSC_O = r_clk; // clock tree

   reg r_imp_osc=0, r_drp_osc=0;
   always #(1000*1000*10) r_imp_osc = ~r_imp_osc; assign IMP_OSC = LFOSC_ENB ? 'h0 : r_imp_osc;
   always #(1000*1000*5)  r_drp_osc = ~r_drp_osc; assign DRP_OSC = LFOSC_ENB ? 'h0 : r_drp_osc;
// -----------------------------------------------------------------------------
// --- end POR, OSC

`endif // ANATOP_EMPTY
endmodule // anatop_1127a0

