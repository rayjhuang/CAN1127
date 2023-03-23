`timescale 1ns/1ns
module stm_i2crout;
// DUT FW issue I2C transfer as a master
//   then wait for I2C transfer as a slave, output recieved data to P0
// I2CMST sends EDh to end the simulation by FW of DUT
// mix some HWI2C access
`include "stm_task.v"
initial timeout_task (1000*50);
initial #1 $fsdbDumpvars;
initial begin
	#10_000
	`I2CMST.dev_addr = 'h70;
	`HW.load_dut_fw ("../fw/fwi2c/fwi2c.2.memh"); // dev_addr=0x50
	force `DUT_MCU.mempsrd_comb =0;
	#140_000 // add RSTB_5 to RSTB delay
	$display ($time,"ns <%m> starts.....");
#10000	`I2CMST.init (0); // 100KHz
#10000	`I2CMST.sfrw (`X0_I2CROUT,'h02); // FWI2C-SDA/SCL, HWI2C-DP/DN
	release `DUT_MCU.mempsrd_comb;

	fork
	FwI2cMst_test;
	#(1000*200) begin
	   `I2CMST.init (0); // 100KHz
#10000	   `BENCH.i2c_connect = 8; // I2CMST-DUT_DP/DN
	   `BENCH.i2cmst_pullup = 1;
	   `BENCH.dpdmi2c_pullup = 1;
#10000	   `I2CMST.sfrw (`REGTRM0,'h1e); `I2CMST.sfrr (`REGTRM0,'h1e); end
	join

#10000	`I2CMST.sfrw (`X0_I2CROUT,'h04); // FWI2C-CC1/CC2, HWI2C-SDA/SCL
#10000	`BENCH.i2c_connect = 1; // I2CMST-DUT_SDA/SCL
	// additional HWI2C access
#10000	`I2CMST.sfrw (`ADR_P0,'he1);
	`I2CMST.sfrw (`GPF,'h1e); `I2CMST.sfrr (`GPF,'h1e);
	`I2CMST.sfrw (`GPF,'he1); `I2CMST.sfrr (`GPF,'he1);

	FwI2cSlv_CCI2C_test;

//	FW will complete the simulation
//	#1_000 hw_complete;
end // initial

task FwI2cMst_test;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.init (1); // 400KHz
//	`I2CMST._txrx (0, 1'h1); // wait for FWI2C master's S
	`I2CMST._txrx (7, 8'hff); // wait for FWI2C master's DEVADR
	`I2CMST._rx_chk (7,`I2CMST.rx_data,8'hA0,0); // dev_addr=0x50
					`I2CMST._txrx_ack (0,0); // ACK
					`I2CMST._txrx_ack (1,0); // wait for FWI2C's P
	$display ($time,"ns <%m> waiting.....");
	wait (`DUT_MCU.u_ports.port0==='hef)
	$display ($time,"ns <%m> NOTE: FW task done");
end
endtask // FwI2cMst_test

task FwI2cSlv_CCI2C_test;
begin
	$display ($time,"ns <%m> starts.....");
#1000	`BENCH.i2c_connect = 2; // I2CMST-DUT_CC1/CC2
#1000	`BENCH.i2cmst_pullup = 1;
#1000	`BENCH.cci2c_pullup = 1;
	 #(1000*5)
	`I2CMST._tx_s;
	`I2CMST._txrx (7, 8'ha0);	`I2CMST._txrx_ack (1,0); // dev_addr of DUT
	`I2CMST._txrx (7, 8'h55);	`I2CMST._txrx_ack (1,0);
	`I2CMST._tx_p;

	`I2CMST._tx_s;
	`I2CMST._txrx (7, 8'ha1);	`I2CMST._txrx_ack (1,0);
	`I2CMST._txrx (7, 8'hff);
	`I2CMST._rx_chk (7,`I2CMST.rx_data,8'h55,0);
					`I2CMST._txrx_ack (0,0);
	#1000
	`I2CMST._tx_p; // this may cause mpsse_mst's bug, the 'p' doesn't come out
	#1000
//	`I2CMST._tx_p; // so do it again
	#1000

	`I2CMST._tx_s;
	`I2CMST._txrx (7, 8'ha0);	`I2CMST._txrx_ack (1,0);
	`I2CMST._txrx (7, 8'hed);	`I2CMST._txrx_ack (1,0);
	`I2CMST._tx_p;
end
endtask // FwI2cSlv_CCI2C_test

endmodule // stm_i2crout

