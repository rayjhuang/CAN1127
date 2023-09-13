`timescale 1ns/1ns
module stm_fwi2c;
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
	#40_000
	$display ($time,"ns <%m> starts.....");
	`I2CMST.init (1); // 400KHz
	release `DUT_MCU.mempsrd_comb;

//	`I2CMST._txrx (0, 1'h1); // wait for FWI2C master's S
	`I2CMST._txrx (7, 8'hff); // wait for FWI2C master's DEVADR
	`I2CMST._rx_chk (7,`I2CMST.rx_data,8'hA0,0); // dev_addr=0x50
					`I2CMST._txrx_ack (0,0); // ACK
					`I2CMST._txrx_ack (1,0); // wait for FWI2C's P

	wait (`DUT_MCU.u_ports.port0==='hef)
	$display ($time,"ns <%m> NOTE: FW task done");
`ifdef CCI2C
#1000	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, BANK12
	`I2CMST.init (0); // 100KHz
`ifdef SWAP
	`I2CMST.sfrw (`X0_I2CROUT,'h35); // r_i2cslv_mode=1, r_i2cmcu_mode=1, swap
#1000	`BENCH.i2c_connect = 4; // I2CMST-DUT_CCI2C(SWAP)
`else
	`I2CMST.sfrw (`X0_I2CROUT,'h05); // r_i2cslv_mode=1, r_i2cmcu_mode=1
#1000	`BENCH.i2c_connect = 2; // I2CMST-DUT_CCI2C
`endif // SWAP
#1000	`BENCH.i2cmst_pullup = 1;
#1000	`BENCH.cci2c_pullup = 1;
`endif // CCI2C
`ifdef DPDMI2C
`ifdef SWAP
	`I2CMST.sfrw (`X0_I2CROUT,'h3a); // r_i2cslv_mode=1, r_i2cmcu_mode=1
#1000	`BENCH.i2c_connect = 16; // I2CMST-DUT_DPDMI2C(SWAP)
`else
	`I2CMST.sfrw (`X0_I2CROUT,'h0a); // r_i2cslv_mode=1, r_i2cmcu_mode=1
#1000	`BENCH.i2c_connect = 8; // I2CMST-DUT_DPDMI2C
`endif // SWAP
#1000	`BENCH.i2cmst_pullup = 1;
#1000	`BENCH.dpdmi2c_pullup = 1;
`endif // DPDMI2C

	#1000
	// additional HWI2C access
	`I2CMST.sfrw (`ADR_P0,'he1);
	`I2CMST.sfrw (`GPF,'h1e); `I2CMST.sfrr (`GPF,'h1e);
	`I2CMST.sfrw (`GPF,'he1); `I2CMST.sfrr (`GPF,'he1);

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

//	FW will complete the simulation
//	#1_000 hw_complete;
end

endmodule // stm_fwi2c

