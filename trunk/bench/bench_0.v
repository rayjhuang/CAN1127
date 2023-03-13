`timescale 1ns/100ps
`include "def_bench.v"
module bench;

initial begin
	$fsdbDumpfile ("bench_0.fsdb");
	$fsdbDumpvars;
end

`include "inc_bench_a0g.v"

`ifdef FPGA
reg r1_rstz; // reset button of DUT (DFP)
initial begin
	r1_rstz =0; #1_000
	r1_rstz =1;
end
reg clk_fpga_dut;
initial begin
	clk_fpga_dut =0;
	#({$random}%300+300) forever #(1000.0/2/({$random}%5+46)) clk_fpga_dut =~clk_fpga_dut;
end

// pull up/down FPGA/AFE interface assigned in synthesis 
pullup (weak1) (`DUT.scl);
pullup (weak1) (`DUT.sda);
wire [6:0] gpio_pull;
pulldown (weak0) (TST);
pullup   (weak1) (pu_scl);   tranif1 (pu_scl,  SCL,  gpio_pull[0]===1);
pulldown (weak0) (pd_scl);   tranif1 (pd_scl,  SCL,  gpio_pull[0]===0);
pullup   (weak1) (pu_sda);   tranif1 (pu_sda,  SDA,  gpio_pull[1]===1);
pulldown (weak0) (pd_sda);   tranif1 (pd_sda,  SDA,  gpio_pull[1]===0);
pullup   (weak1) (pu_gpio1); tranif1 (pu_gpio1,GPIO1,gpio_pull[2]===1);
pulldown (weak0) (pd_gpio1); tranif1 (pd_gpio1,GPIO1,gpio_pull[2]===0);
pullup   (weak1) (pu_gpio2); tranif1 (pu_gpio2,GPIO2,gpio_pull[3]===1);
pulldown (weak0) (pd_gpio2); tranif1 (pd_gpio2,GPIO2,gpio_pull[3]===0);
pullup   (weak1) (pu_gpio3); tranif1 (pu_gpio3,GPIO3,gpio_pull[4]===1);
pulldown (weak0) (pd_gpio3); tranif1 (pd_gpio3,GPIO3,gpio_pull[4]===0);
pullup   (weak1) (pu_gpio4); tranif1 (pu_gpio4,GPIO4,gpio_pull[5]===1);
pulldown (weak0) (pd_gpio4); tranif1 (pd_gpio4,GPIO4,gpio_pull[5]===0);
pullup   (weak1) (pu_gpio5); tranif1 (pu_gpio5,GPIO5,gpio_pull[6]===1);
pulldown (weak0) (pd_gpio5); tranif1 (pd_gpio5,GPIO5,gpio_pull[6]===0);
wire [35:0] dut_j8;
pullup (weak1) (dut_j8[35]);
pullup (weak1) (dut_j8[34]);
pulldown (pull0) (dut_j8[33]);
pulldown (pull0) (dut_j8[32]);
`endif // FPGA

chiptop_1127a0 U0_DUT ( // for DFP development
`ifdef FPGA // connect to AFE (.ucf file), to analog_top in chiptop
	.V5OCP		(), // I: from AFE/ANA
	.UVP		(), // I: from AFE/ANA
	.SCP		(), // I: from AFE/ANA
	.OCP		(), // I: from AFE/ANA
	.OVP		(), // I: from AFE/ANA
	.OTPI_S		(), // I: from AFE/ANA
	.OTPI_C		(), // I: from AFE/ANA
	.COMP_O		(), // I: from AFE/ANA
	.AD_RST		(),
	.AD_HOLD	(),
	.SAMPL_SEL	(),
	.dac1_9_2	(),
	.rp_type_en	(),
	.RP_EN		(),
	.VCONN_EN	(),
	.RX_D		(), // I: from AFE/ANA
	.CC_SEL		(),
	.TX_DRV0	(),
	.oeb_cc		(),
	.doe_cc		(),
	.PWR_ENABLE	(),
	.DISCHARGE	(),
	.dac_pwr_v	(),
	.DP_2V7_EN	(),
	.DN_2V7_EN	(),
	.DPDN_SHORT	(),
	.DP_DWN_EN	(),
	.DN_DWN_EN	(),
	.smims_j8_o	(dut_j8[31:0]),
	.smims_j8_i	(dut_j8[35:34]),
	.smims_ledz	(),
	.o_lo		(),
	.o_pull		(gpio_pull),
	.i_porz		(`DUT_ANA.RSTB),
	.smims_osc48	(clk_fpga_dut),
	.smims_clkgen	(1'h0),
	.smims_rstzbtn	(r1_rstz), // reset button
	.smims_cmdbtn	(1'h0), // command button, low-active
	.smims_dipmux	(4'd12), // DIP for mux selector
	.uart_tx	(), // J11_1
	.uart_rx	(), // J11_2
	.scl		(), // J11_3
	.sda		(), // J11_4
	.GPIO6		(),
	.IDDI		(),
`else // !FPGA
	.CSP		(),
	.CSN		(),
	.VFB		(),
	.COM		(),
	.LG		(),
	.SW		(),
	.HG		(),
	.BST		(),
	.GATE		(),
	.VDRV		(),
`endif // FPGA
	.CC1		(CC1),		.CC2		(CC2),
	.DP		(DP),		.DN		(DN),
	.GPIO_TS	(TS),
	.SCL		(SCL),		.SDA		(SDA),
	.GPIO1		(GPIO1),	.GPIO2		(GPIO2),
	.GPIO3		(GPIO3),	.GPIO4		(GPIO4),
	.GPIO5		(GPIO5),
	.TST		(TST)
); // U0_DUT

`include "rt_check.v" // real-time check

m51_synthe U0_M51 (
	.sfr_ack	(`DUT_MCU.sfrack),
	.sfr_rdat	(`DUT_MCU.esfrm_rddata), // [7:0]
	.mem_ack	(`DUT_MCU.memack),
	.mem_rdat	(`DUT_MCU.memdatai), // [7:0]
	.i_intz		(~`DUT_MCU.exint[5:4]), // TX/RX int
	.clk		(`DUT_CCLK)
); // U0_M51

mpsse_mst_i2c U0_I2CMST (
	.CSB (),
	.SCK (),
	.SDO (),
	.SDI ()
); // U0_I2CMST

uart_bhv U0_UARTMST (
	.x_txd (),
	.x_rxd ()
); // U0_UARTMST

// for v_DP to DP, v_DN to DN digital input of DUT
// force to dominate output driver of the IO cell, if D+/D- use digital IO
//initial force `DUT_ANA.DP_COMP = U0_USB_PORT.DP_COMP;
//initial force `DUT_ANA.DN_COMP = U0_USB_PORT.DN_COMP;
usb_port
U0_USB_PORT (
	.DPDO		(`DUT_ANA.DPDO),
	.DNDO		(`DUT_ANA.DNDO),
	.DPOE		(`DUT_ANA.DPDEN),
	.DNOE		(`DUT_ANA.DNDEN),
	.DP_DWN_EN	(`DUT_ANA.DP_DWN_EN), // SCP_DWN_EN
	.DN_DWN_EN	(`DUT_ANA.DN_DWN_EN),
	.DP_2V7_EN	(`DUT_ANA.DP_2V7_EN),
	.DN_2V7_EN	(`DUT_ANA.DN_2V7_EN),
	.DPDN_SHORT	(`DUT_ANA.DPDN_SHORT),
	.DP_COMP	(), // to provide a digital output behavior
	.DN_COMP	(), // to provide a digital output behavior
	.v_DP		(`DUT_ANA.v_DP),
	.v_DN		(`DUT_ANA.v_DN),

	.CC1_DI		(`DUT_ANA.CC1_DI),
	.CC2_DI		(`DUT_ANA.CC2_DI),
	.CCI2C		(`DUT_ANA.CCI2C_EN),
	.CC1_DOB	(`DUT_ANA.CC1_DOB),
	.CC2_DOB	(`DUT_ANA.CC2_DOB),
	.CC_SEL		(`DUT_ANA.CC_SEL),
	.RX_D_PK	(`DUT_ANA.RX_D_PK),
	.RX_D_49	(`DUT_ANA.RX_D_49),
	.RX_SQL		(`DUT_ANA.RX_SQL),
	.v_CC1		(`DUT_ANA.v_CC1),
	.v_CC2		(`DUT_ANA.v_CC2),
	.DUT_TX_EN	(`DUT_ANA.TX_EN),
	.DUT_TX_DAT	(`DUT_ANA.TX_DAT),
	.DUT_RP1_EN	(`DUT_ANA.RP1_EN),
	.DUT_RP2_EN	(`DUT_ANA.RP2_EN),
	.DUT_VCONN1_EN	(`DUT_ANA.VCONN1_EN),
	.DUT_VCONN2_EN	(`DUT_ANA.VCONN2_EN),
	.DUT_RP_SEL	(`DUT_ANA.RP_SEL),

	.v_VBUS		(`DUT_ANA.v_VO),
	.v_CV		(`DUT_ANA.v_VIN));

// I2CMST connection
// =============================================================================
reg i2cmst_pullup = 0;
tranif1 (pullup_5, `I2CMST.SCK, i2cmst_pullup); pullup (weak1) (pullup_5);
tranif1 (pullup_6, `I2CMST.SDO, i2cmst_pullup); pullup (weak1) (pullup_6);
reg cci2c_pullup = 0;
always @(cci2c_pullup)
     {`USBCONN.ExtCc1Rpu,
      `USBCONN.ExtCc2Rpu} = cci2c_pullup ?3 :0;
reg dpdmi2c_pullup = 0;
always @(dpdmi2c_pullup)
     {`USBCONN.USBDP.ExtRpu,
      `USBCONN.USBDN.ExtRpu} = dpdmi2c_pullup ?3 :0;

reg [4:0] i2c_connect
`ifdef I2C_CON
	= `I2C_CON;
`else	= 'b1;
`endif
tranif1 (`DUT.SCL,`I2CMST.SCK,i2c_connect[0]); // duti2c-mst
tranif1 (`DUT.SDA,`I2CMST.SDO,i2c_connect[0]);

assign `I2CMST.SCK = (i2c_connect[1]&`DUT_ANA.CC2_DOB&`DUT_ANA.CCI2C_EN) ? `DUT_ANA.v_CC2 > 1200 : 'hz; // dutcc -> mst
assign `I2CMST.SDO = (i2c_connect[1]&`DUT_ANA.CC1_DOB&`DUT_ANA.CCI2C_EN) ? `DUT_ANA.v_CC1 > 1200 : 'hz;
always @(`I2CMST.SCK or i2c_connect) if (i2c_connect[1]===1'h1) `USBCONN.ExtCc2Drv = (`I2CMST.SCK===1'h0 ?0 :1'hx); // mst -> dutcc
always @(`I2CMST.SDO or i2c_connect) if (i2c_connect[1]===1'h1) `USBCONN.ExtCc1Drv = (`I2CMST.SDO===1'h0 ?0 :1'hx);
assign `I2CMST.SCK = (i2c_connect[2]&`DUT_ANA.CC1_DOB&`DUT_ANA.CCI2C_EN) ? `DUT_ANA.v_CC1 > 1200 : 'hz; // dutcc -> mst (swapped)
assign `I2CMST.SDO = (i2c_connect[2]&`DUT_ANA.CC2_DOB&`DUT_ANA.CCI2C_EN) ? `DUT_ANA.v_CC2 > 1200 : 'hz;
always @(`I2CMST.SCK or i2c_connect) if (i2c_connect[2]===1'h1) `USBCONN.ExtCc1Drv = (`I2CMST.SCK===1'h0 ?0 :1'hx); // mst -> dutcc
always @(`I2CMST.SDO or i2c_connect) if (i2c_connect[2]===1'h1) `USBCONN.ExtCc2Drv = (`I2CMST.SDO===1'h0 ?0 :1'hx);

assign `I2CMST.SCK = (i2c_connect[3]&`DUT_ANA.DNDEN) ? `DUT_ANA.v_DN > 1200 : 'hz; // dutdpdm -> mst
assign `I2CMST.SDO = (i2c_connect[3]&`DUT_ANA.DPDEN) ? `DUT_ANA.v_DP > 1200 : 'hz;
always @(`I2CMST.SCK or i2c_connect) if (i2c_connect[3]===1'h1) `USBCONN.USBDN.ExtDrv = (`I2CMST.SCK===1'h0 ?0 :1'hx); // mst -> dutdpdm
always @(`I2CMST.SDO or i2c_connect) if (i2c_connect[3]===1'h1) `USBCONN.USBDP.ExtDrv = (`I2CMST.SDO===1'h0 ?0 :1'hx);
assign `I2CMST.SCK = (i2c_connect[4]&`DUT_ANA.DPDEN) ? `DUT_ANA.v_DP > 1200 : 'hz; // dutdpdm -> mst (swapped)
assign `I2CMST.SDO = (i2c_connect[4]&`DUT_ANA.DNDEN) ? `DUT_ANA.v_DN > 1200 : 'hz;
always @(`I2CMST.SCK or i2c_connect) if (i2c_connect[4]===1'h1) `USBCONN.USBDP.ExtDrv = (`I2CMST.SCK===1'h0 ?0 :1'hx); // mst -> dutdpdm
always @(`I2CMST.SDO or i2c_connect) if (i2c_connect[4]===1'h1) `USBCONN.USBDN.ExtDrv = (`I2CMST.SDO===1'h0 ?0 :1'hx);

// UART connection
// =============================================================================
reg [3:0] urmst_connect = 'b1; // {D+/D-, D-/D+, GPIO2/1, FPGA UART}
`ifdef FPGA
tranif1 (`DUT.uart_tx, `URMST.x_rxd, urmst_connect[0]);
tranif1 (`DUT.uart_rx, `URMST.x_txd, urmst_connect[0]);
`endif
tranif1 (`DUT.GPIO1,   `URMST.x_rxd, urmst_connect[1]);
tranif1 (`DUT.GPIO2,   `URMST.x_txd, urmst_connect[1]);

wire DDI2C_DP = `DUT_ANA.v_DP > 1000;
wire DDI2C_DN = `DUT_ANA.v_DN > 1000;
bufif1 (`URMST.x_rxd,DDI2C_DP,urmst_connect[2]&`DUT_ANA.DPDEN);
//always @(urmst_connect) `USBCONN.dp_rpu = urmst_connect[2];
always @(`URMST.x_txd or urmst_connect)
	if (urmst_connect[2]) `USBCONN.USBDN.FcpDrv = `URMST.x_txd;
			 else `USBCONN.USBDN.FcpDrv = 'hx;
bufif1 (`URMST.x_rxd,DDI2C_DN,urmst_connect[3]&`DUT_ANA.DNDEN); // swapped
//always @(urmst_connect) `USBCONN.dn_rpu = urmst_connect[3];
always @(`URMST.x_txd or urmst_connect)
	if (urmst_connect[3]) `USBCONN.USBDP.FcpDrv = `URMST.x_txd;
			 else `USBCONN.USBDP.FcpDrv = 'hx;

// TS connection
// =============================================================================
pullup (weak1) (pu_ts);
`ifdef CAN1112B2
`else
tranif1 (pu_ts,TS, `DUT_ANA.S100U & ~`DUT_CORE.DO_TS[0]); // PD for both RTL/FPGA
`endif


endmodule // bench

