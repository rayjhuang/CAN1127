
module usb_port (
input		DPDO,      DNDO,
input		DPOE,      DNOE,
input		DP_DWN_EN, DN_DWN_EN,
input		DP_2V7_EN, DN_2V7_EN,
input		DPDN_SHORT,
output	[15:0]	v_DP,      v_DN,
		v_CC1,     v_CC2,
		v_VBUS,
output		DP_COMP,   DN_COMP,
input		CC1_DOB,   CC2_DOB,
output		CC1_DI,    CC2_DI,
input		CC_SEL,
		CCI2C,
output		RX_D_PK, RX_D_49,
output		RX_SQL,
input		DUT_TX_EN,
		DUT_TX_DAT,
		DUT_RP1_EN, DUT_RP2_EN,
		DUT_VCONN1_EN, DUT_VCONN2_EN,
input	[1:0]	DUT_RP_SEL
);

parameter A0=0;

// apy36576
// APY36576 (A0[0]);

// usb1_tester
// UDV (DP_COMP,DN_COMP);

   bhv_usbpd_controller
   UPD (comp_cc);

`ifdef USBTD
   usb_test_device #(A0)
   USBTD ();
`endif

   usbpd_analyzer CCANA (comp_cc);
// usb1_analyzer USBANA (DP_COMP,DN_COMP);

////////////////////////////////////////////////////////////////////////////////
// USB connector (CC1/CC2/D+/D-)
   usb_connector // additional for cross-hierarchy reference
   USBCONN (	.DPDO		(DPDO),		.DNDO		(DNDO),
		.DPOE		(DPOE),		.DNOE		(DNOE),
		.DP_DWN_EN	(DP_DWN_EN),	.DN_DWN_EN	(DN_DWN_EN),
		.DP_2V7_EN	(DP_2V7_EN),	.DN_2V7_EN	(DN_2V7_EN),
		.DPDN_SHORT	(DPDN_SHORT),
		.DP_COMP	(DP_COMP),	.DN_COMP	(DN_COMP),
		.v_DP		(v_DP),		.v_DN		(v_DN),
		.v_CC1		(v_CC1),	.v_CC2		(v_CC2),
		.comp_cc	(comp_cc),
		.CC1_DOB	(CC1_DOB),	.CC2_DOB	(CC2_DOB),
		.CC1_DI		(CC1_DI),	.CC2_DI		(CC2_DI),
		.CC_SEL		(CC_SEL),
		.CCI2C		(CCI2C),
		.RX_D_PK	(RX_D_PK),	.RX_D_49	(RX_D_49),
		.RX_SQL		(RX_SQL),
		.DUT_TX_EN	(DUT_TX_EN),
		.DUT_TX_DAT	(DUT_TX_DAT),
		.DUT_RP1_EN	(DUT_RP1_EN),	.DUT_RP2_EN	(DUT_RP2_EN),
		.DUT_VCONN1_EN	(DUT_VCONN1_EN),.DUT_VCONN2_EN	(DUT_VCONN2_EN),
		.DUT_RP_SEL	(DUT_RP_SEL)
   );

begin: PB

wire [15:0] v_VCONN = USBCONN.cable_ori ? v_CC1 : v_CC2;
wire [15:0] v_CC    = USBCONN.cable_ori ? v_CC2 : v_CC1;
ana_probe
DP		(v_DP),
DN		(v_DN),
CC1		(v_CC1),
CC2		(v_CC2),
VCONN		(v_VCONN),
VBUS		(v_VBUS);

wire probe_sink_tx_ng = v_CC <  1000 && v_CC > 400;
wire probe_sink_tx_ok = v_CC >= 1000;
dig_probe
CC_IDLE		(UPD.UPDPHY.cc_idle),
SinkTxOk	(probe_sink_tx_ok),
SinkTxNG	(probe_sink_tx_ng);

end // PB

endmodule // usb_port


module usb_connector (
input		DPDO,      DNDO,
input		DPOE,      DNOE,
input		DP_DWN_EN, DN_DWN_EN,
input		DP_2V7_EN, DN_2V7_EN,
input		DPDN_SHORT,
output		DP_COMP,   DN_COMP,
output	[15:0]	v_DP,      v_DN,
		v_CC1,     v_CC2,
output		comp_cc, // for analyzer/bridge
input		CC1_DOB,   CC2_DOB,
output		CC1_DI,    CC2_DI,
input		CC_SEL,
		CCI2C,
output		RX_D_PK, RX_D_49,
output		RX_SQL,
input		DUT_TX_EN,
		DUT_TX_DAT,
		DUT_RP1_EN, DUT_RP2_EN,
		DUT_VCONN1_EN, DUT_VCONN2_EN,
input	[1:0]	DUT_RP_SEL
);

   reg	dp_rpu =0, dn_rpu =0, // 1.5KOhm
	ExtCc1Drv =1'hx, ExtCc2Drv =1'hx, // 1'hx/0/1: Hi-Z/0V/3300mV, for external model signals going to DUT
	ExtCc1Rpu =0,    ExtCc2Rpu =0, // 4.7K pullup to 3.3V for I2C
	cable_ori =0; // 0:non-flipped

   reg	[23:0] Rpu1 =0, Rpd1 =0, Rpu2 =0, Rpd2 =0; // opened

   reg	rd_bdg =1'hx; // for rd_bdg=1 compatible
   initial #1 forever @(rd_bdg or cable_ori) if (rd_bdg!==1'hx)
      if (cable_ori) begin
         Rpd1=0; Rpd2=5100;
      end else begin
         Rpd1=5100; Rpd2=0;
      end

   always @(CC_SEL) $display ($time,"ns <%m> DUT updates orientation -> %d",CC_SEL);
   always @(cable_ori) $display ($time,"ns <%m> cable orientation -> %d",cable_ori);
   wire [15:0] v_CC = cable_ori ?v_CC2 :v_CC1; // for TxSinkOk/NG detection in TD
   assign comp_cc = v_CC > 550; // for analyzer/bridge RX

   wire [23:0] dut_rp = (DUT_RP_SEL==2'h0) ? 24'd36_000
                       :(DUT_RP_SEL==2'h1) ? 24'd12_000 : 24'd4_700;
   wire Pp1Drv = ~cable_ori & UPD.UPDPHY.txoe ? UPD.UPDPHY.txd : 1'hx;
   wire Pp2Drv =  cable_ori & UPD.UPDPHY.txoe ? UPD.UPDPHY.txd : 1'hx;
   wire [15:0] Cc1RvNetwork_v, Cc2RvNetwork_v;
   wire [23:0] Cc1RvNetwork_r, Cc2RvNetwork_r;
   vcompos #(9,400) USBCC1 (
	{Pp1Drv!==1'hx,     24'd350,   Pp1Drv===1 ?16'd1125 :16'd0, // BMC driver for >300ns rise/fall
	 DUT_TX_EN&~CC_SEL, 24'd350,   DUT_TX_DAT ?16'd1125 :16'd0, // BMC driver for >300ns rise/fall
	 CC1_DOB&CCI2C,     24'd200,   16'd0, // 1mA IO, 0.2V VOL
	 DUT_VCONN1_EN,     24'd10,    16'd5000, // 50mA VCONN, 0.5V drop
	 DUT_RP1_EN,        dut_rp,    16'd3300,
	 1'h1,              Rpu1,      16'd3300, // port partner pullup
	 1'h1,              Rpd1,      16'd0, // port partner pulldown
	 ExtCc1Rpu,         24'd2_000, 16'd3300, // 4.7KOhm external pullup
	 ExtCc1Drv!==1'hx,  24'd200,   ExtCc1Drv===1 ?16'd3300 :16'd0}, // digital IO driver of external models
			Cc1RvNetwork_r, Cc1RvNetwork_v,
			Cc1RvNetwork_r, Cc1RvNetwork_v, v_CC1);
   vcompos #(9,400) USBCC2 (
	{Pp2Drv!==1'hx,     24'd350,   Pp2Drv===1 ?16'd1125 :16'd0, // BMC driver for >300ns rise/fall
	 DUT_TX_EN& CC_SEL, 24'd350,   DUT_TX_DAT ?16'd1125 :16'd0, // BMC driver for >300ns rise/fall
	 CC2_DOB&CCI2C,     24'd200,   16'd0, // 1mA IO, 0.2V VOL
	 DUT_VCONN2_EN,     24'd10,    16'd5000, // 50mA VCONN, 0.5V drop
	 DUT_RP2_EN,        dut_rp,    16'd3300,
	 1'h1,              Rpu2,      16'd3300, // port partner pullup
	 1'h1,              Rpd2,      16'd0, // port partner pulldown
	 ExtCc2Rpu,         24'd2_000, 16'd3300, // 4.7KOhm external pullup
	 ExtCc2Drv!==1'hx,  24'd200,   ExtCc2Drv===1 ?16'd3300 :16'd0}, // digital IO driver of external models
			Cc2RvNetwork_r, Cc2RvNetwork_v,
			Cc2RvNetwork_r, Cc2RvNetwork_v, v_CC2);

   wire [15:0] DpVolt, DnVolt, vJpDp, vJpDn;
   wire [23:0] DpResist, DnResist, rDP, rDN;
   jumper JP_DPDN (
	.v1	(DpVolt),	.v2     (DnVolt),
	.r1	(DpResist),	.r2	(DnResist),
	.short	(DPDN_SHORT),
	.r_out1	(rDP),		.r_out2	(rDN),
	.v_out1	(vJpDp),	.v_out2	(vJpDn));
   usb_dd_composer USBDP (
	.comp	(DP_COMP),
	.rc_v	(v_DP),
	.target_v(vJpDp),.compose_v(DpVolt),
	.target_r(rDP),.compose_r(DpResist),
	.dena	(DPOE),		.dout	(DPDO),
	.puena	(dp_rpu), // full-speed
	.pdena	(DP_DWN_EN),
	.apena	(DP_2V7_EN));
   usb_dd_composer USBDN (
	.comp	(DN_COMP),
	.rc_v	(v_DN),
	.target_v(vJpDn),.compose_v(DnVolt),
	.target_r(rDN),.compose_r(DnResist),
	.dena	(DNOE),		.dout	(DNDO),
	.puena	(dn_rpu),
	.pdena	(DN_DWN_EN),
	.apena	(DN_2V7_EN));

task rv_divider;
inout reg [15:0] volt;
inout reg [23:0] resist; // '0' stands for open
input ena;
input [15:0] div_v;
input [23:0] div_r;
   if (ena) begin
	volt   = (resist===0) ? div_v : ({24'h0,div_v} * resist + volt * div_r) / (resist+div_r);
	resist = (resist===0) ? div_r : {24'h0,resist} * div_r / (resist+div_r);
   end
endtask // rv_divider

endmodule // USBCONN


module usb_dd_composer (
output		comp,
output	[15:0]	rc_v,
input	[15:0]	target_v, // target value after external circuit
input	[23:0]	target_r,
output	[15:0]	compose_v, // R/V calculating result
output	[23:0]	compose_r,
input		dena, dout, // DUT: digital output
		puena, // DUT: Rpu enable (full/low-speed)
		pdena, // DUT: HVDCP pull-down
		apena // DUT: APPLE mode
);
// drivers external behavior models
reg [15:0] HvDcpDrv =16'hx; // 1'hx/1/2/others: Hi-Z/0.6V/3.3V/any-mV
reg FcpDrv =1'hx; // 1'hx/0/1: Hi-Z/0.6V/FCP_HI/?mV (for FCP/SCP driver)
reg HstDrv =1'hx; // USB host driver
reg ExtRpu =0; // 4.7K pullup to 3.3V
reg ExtDrv =1'hx; // 1'hx/0/1: Hi-Z/0V/3300mV, for external model signals going to DUT

   rc_driver #(400) RcDrv (
	.vi	(target_v),
	.ri	(target_r),
	.rc_v	(rc_v));

   assign comp = rc_v > 1200;

   assign compose_v = RcNetwork.v;
   assign compose_r = RcNetwork.r;
   always @* begin: RcNetwork
	reg [23:0] r;
	reg [15:0] v; v=0; r=0;
//	rv_divider (v,r,hena, hout ?3300 :0,   200);
	rv_divider (v,r,dena, dout ?3300 :0,   909); // DUT FCP driver, 1us rise/fall time
	rv_divider (v,r,puena, 3300,         1_500); // USB device pullup
	rv_divider (v,r,pdena, 0,           20_000); // QC pulldown
	rv_divider (v,r,apena, 2700,        22_000); // apple mode pullup
	rv_divider (v,r,1'h1, 0,           900_000); // leakage
	rv_divider (v,r,HvDcpDrv!==16'hx,
	                HvDcpDrv===16'h2 ?3300 
	              : HvDcpDrv===16'h1 ?600
	              : HvDcpDrv,            4_000); // HVDCP or any-mV driver
	rv_divider (v,r,ExtRpu, 3300,        2_000); // 4.7KOhm external pullup
	rv_divider (v,r,ExtDrv!==1'hx,
	                ExtDrv===1 ?3300 :0,   200); // digital IO driver of external models
	rv_divider (v,r,FcpDrv!==1'hx,
	                FcpDrv ?3300 :0,     2_000); // 2.2us rise/fall time
	end // RcNetwork

endmodule // usb_dd_composer

