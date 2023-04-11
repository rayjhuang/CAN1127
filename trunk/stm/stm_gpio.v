`timescale 1ns/1ns
module stm_gpio;
// let the four digital pins be GPO and output something
// toggle GPIO1/GPIO2 to let FW counting by ISR, and put the result on P0
//  r_hold_mcu test
`include "stm_task.v"
initial timeout_task (1000*100);
initial #1 $fsdbDumpvars (stm_gpio);
reg [15:0] idx;

initial #1 `BENCH.urmst_connect =2; // UART master to GPIO1/2
parameter BAUDRATE = 28800; // usbpd_90
initial begin

#1	`URMST.dev_en = 1;
	`URMST.sergen_set_baud_rate (BAUDRATE, BAUDRATE);
#100	`HW.load_dut_fw ("../fw/uart/uart.1.memh");
	`I2CMST.dev_addr = 'h70; // to DUT
	`I2CMST.init (2); // 1 MHz
#500_000 // HW checksum lantency
	$display ($time,"ns <%m> UART starts.....");
	`I2CMST.sfrw (`GPIOSH,'h7e); // UART on GPIO1/2

	fork
	#(1000*200) begin
	`URMST.sergen_txd ('h55,1,0);
   	#(1000*100) `URMST.sergen_txd ('hE0,1,0); // test full-duplex
	end
	`URMST.sergen_rxd ('h55);
   	join
   	#(1000*330)
	`URMST.sergen_txd ('hE0,1,0);
#10000	`URMST.dev_en = 0;


#10000	`DUT_ANA.r_rstz = 0;
#1000	`HW.load_dut_fw ("../fw/gpio/gpio.2.memh");
#1000	`DUT_ANA.r_rstz = 1;
#1000	$display ($time,"ns <%m> GPIO starts.....");

`define ALL_GPIO {`DUT.GPIO5,`DUT.GPIO4,`DUT.GPIO3,`DUT.GPIO2,`DUT.GPIO1,`DUT.SDA,`DUT.SCL}
	for (idx=0; idx<'h80; idx=idx+1) // GPIO output
	   wait (`ALL_GPIO===idx[7:0]) ->ev;
//	wait (`ALL_GPIO===8'h6f) ->ev;
//	wait (`ALL_GPIO===8'h7e) ->ev;
//	wait (`ALL_GPIO===8'h7f) ->ev;
	$display ($time,"ns <%m> NOTE: GPO completed.");

	wait (`ALL_GPIO==0)
	for (idx=0; idx<7; idx=idx+1) // GPIO PU/PD
	   wait (`ALL_GPIO===('h1<<idx)) ->ev;
	$display ($time,"ns <%m> NOTE: GPIO PU/PD completed.");

#(1000*100)
	`I2CMST.sfrw (`I2CCTL,'h14); // PG0 to IDATA(bank10)
	`I2CMST.sfrr ('h10,'h08); // IDATA['h10]: cnt_gpi1
	`I2CMST.sfrr ('h11,'h80); // IDATA['h11]: cnt_gpi2

	for (idx=0; idx<'h05; idx=idx+1) begin
	   #100_000 force `DUT.GPIO1 = 0; // edge trigger
	     #9_000 force `DUT.GPIO1 = 1;
	end
	release `DUT.GPIO1;
	`I2CMST.sfrr ('h10,'h0d); // IDATA['h10]: cnt_gpi1
	`I2CMST.sfrr ('h11,'h80); // IDATA['h11]: cnt_gpi2
`ifdef FPGA
// 'cpuclk' is not stopped/lowed/gated in FPGA for safe MON51 polling
`else
	tx_osc;
`endif
	for (idx=0; idx<'h06; idx=idx+1) begin
	   #100_000 force `DUT.GPIO2 = 0; // level trigger
	     #1_000 force `DUT.GPIO2 = 1;
	end
	release `DUT.GPIO2;
	`I2CMST.sfrr ('h10,'h0d); // IDATA['h10]: cnt_gpi1
	`I2CMST.sfrr ('h11,'he0); // IDATA['h11]: cnt_gpi2

	TxHold (100); // test holding MCU during fetching
	`I2CMST.rddat=1;
	while (`I2CMST.rddat>0) #9000 `I2CMST.sfrr ('h12,'hxx); // polling for PG0_CMD(0x20) end

	`I2CMST.sfrw ('h12,'h04); // PG0_CMD(4): FW completing
//	FW will complete the simulation
//	#1_000 hw_complete;
end

task chk_osc_stop;
begin
	`I2CMST.sfrw ('h12,'h01); // PG0_CMD(1): OSC_STOP
	#(1000*10) fork: chk0
	@(`DUT_CORE.i_clk) `HW_FIN (($time,"ns <%m> ERROR: OSC_STOP expected"))
	#(1000*10) disable chk0;
	join
	$display ($time,"ms <%m> done");
end
endtask // chk_osc_stop

task tx_osc;
integer osc;
reg [7:0] sav0;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrr (`DACLSB,'hxx); sav0 = `I2CMST.rddat;
	`I2CMST.sfrw (`DACLSB,sav0|'h04); // turn-on DAC1/COMP

	chk_osc_stop;

//	tx_ath(0);
//	tx_ath(1);
	tx_dac1;
//	tx_dac_15mA; //should check ANA Current OPA whether work when sleep=1 and osc_stop = 1,

//	tx_cc12; // removed 2017/03/22, RX_D_49 is turned off by SLEEP

	`I2CMST.sfrw (`OSCCTL,'h20); // CAN1126 needs 'wkup_osc_low' set
	`I2CMST.sfrw ('h12,'h02); // PG0_CMD(2): OSC_LOW
	fork: chk1
	   @(posedge `DUT_ANA.OSC_LOW) #2000 // cleared very soon in FPGA
	   @(negedge `DUT_ANA.OSC_LOW) #2000 disable chk1;
	   #(1000*100) if (`DUT_ANA.OSC_LOW!==1'h1) `HW_FIN (($time,"ns <%m> ERROR: OSC_LOW expected"))
	join

	repeat (100) @(posedge `DUT_CORE.i_clk); // for both RTL/FPGA
	osc =0;
	`I2CMST.sfrw ('h12,'h03); // PG0_CMD(3): gating OSC
	#(1000*10) fork: chk2
	   forever @(`DUT_ANA.OSC_O) osc = osc+1;
	   #(1000*10) disable chk2;
	   @(`DUT_MCLK) `HW_FIN (($time,"ns <%m> ERROR: OSC should be gated"))
	join
	if (osc<100) `HW_FIN (($time,"ns <%m> ERROR: OSC expected"))

	`I2CMST.sfrr ('h12,'h00); // wake-up
	`I2CMST.sfrw (`DACLSB,sav0);
end
endtask // tx_osc

task tx_cc12; // wake-up by CC1/2
integer osc;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrr (`CCCTL,'h00); // check CC status

	chk_osc_stop;

	osc =0;
	`USBCONN.ExtCc1Rpu =1;
#5000	`USBCONN.ExtCc1Rpu =0;
	fork: chk1
	   forever @(`DUT_CORE.i_clk) osc = osc+1;
	   #(1000*10) disable chk1;
	join
	if (osc<100) `HW_FIN (($time,"ns <%m> ERROR: OSC should be waked-up"))
end
endtask // tx_cc12

task tx_dac1; // wake-up by DAC1/COMP
integer osc;
reg [7:0] sav1;
begin
	$display ($time,"ns <%m> starts.....");

//	`I2CMST.sfrw (`CMPOPT,'h30); // DAC/COMP circuit/INT enable

	`I2CMST.sfrr (`P0MSK, 'hff); // FW did
	`I2CMST.sfrw (`DACV6, 'h01); // DACV6=8mV
	`I2CMST.sfrw (`DACEN, 'h40); // DAC/COMP will be at CC1
	`I2CMST.sfrw (`DACCTL,'h11); // always sample

	chk_osc_stop;

	osc =0;
	`USBCONN.ExtCc1Rpu =1;
#5000	`USBCONN.ExtCc1Rpu =0;
	fork: chk1
	   forever @(`DUT_CORE.i_clk) osc = osc+1;
	   #(1000*10) disable chk1;
	join
	if (osc<100) `HW_FIN (($time,"ns <%m> ERROR: OSC should be waked-up"))
end
endtask // tx_dac1

task TxHold;
input [7:0] cnt;
reg [7:0] misc;
begin	$display ($time,"ns <%m> starts");
	`I2CMST.sfrr (`MISC,'hxx); misc = `I2CMST.rddat;
	repeat (cnt) begin
	   #({$random}%5000+50000) `I2CMST.sfrw ('h12,'h20); // PG0_CMD(0x20): keep fetching
	   repeat (10) begin
	      #({$random}%2000+1000) `I2CMST.sfrw (`MISC,misc|'h08);
	      #({$random}%1000+10000)
	      if (`DUT.PMEM_RE!==0) `HW_FIN (($time,"ns <%m> ERROR: OTP should be idle"))
	      `I2CMST.sfrw (`MISC,misc);
	   end
	end
end
endtask // TxHold

endmodule // stm_gpio

