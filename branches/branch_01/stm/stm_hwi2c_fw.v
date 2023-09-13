`timescale 1ns/1ns
module stm_hwi2c_fw;
// DUT HWI2C in FW mode
// CAN1126: @20221110 commit
//   add /rtl/i2cslv_fw.v and /rtl/core_a0_fw.v for FW mode support (renamed later)
//   list these files in rtl.f for doing this pattern
`include "stm_task.v"
initial timeout_task (1000*50);
initial #1 $fsdbDumpvars;
initial begin
	#10_000
	`I2CMST.dev_addr = 'h70;
	`HW.load_dut_fw ("../fw/hwi2c_fw/hwi2c_fw.2.memh");
	force `DUT_MCU.mempsrd_comb =0;
	#40_000
	$display ($time,"ns <%m> starts.....");
	`I2CMST.init (1); // 400KHz
	release `DUT_MCU.mempsrd_comb;

	#200_000 // init.
//	`I2CMST.sfrw (`I2CCTL,'h3a); // non-inc, BANK13 (XDATA, 80h~FFh), write-protected (in FW)
	`I2CMST.bkrd ('h03,2,'h30cd);
	`I2CMST.bkwr ('h03,2,'h55aa);
	`I2CMST.bkrd ('h03,2,'h30cd);

	`I2CMST.sfrw ('h02,'h55); `I2CMST.sfrr ('h02,'h55);
	`I2CMST.sfrw (`GPF,'haa); `I2CMST.sfrr (`GPF,'h00);
	`I2CMST.bkwr ('h01,2,'h4123);
	`I2CMST.bkrd ('h01,2,'h4123);
	`I2CMST.sfrr (`GPF,'h00);

	`I2CMST.sfrw ('h01,'h55); // no effect
	`I2CMST.sfrr ('h02,'h55);
	`I2CMST.bkrd ('h01,2,'h4123);

	`I2CMST.bkwr ('h00,4,'h11335577);
	`I2CMST.sfrr ('h02,'h55);
	`I2CMST.bkrd ('h00,4,'h11335577);

	#1_000 hw_complete;
end

endmodule // stm_hwi2c_fw

