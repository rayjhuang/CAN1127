
module stm_hwi2c_mpb;
// test MBP by HWI2C and iram.c
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_hwi2c_mpb);
initial timeout_task (1000*200);
initial #10_000 begin
`ifdef IDATA
	force `HW.pulse_width_probe = |{`DUT_CORE.u0_mpb.pg0_ird,`DUT_CORE.u0_mpb.pg0_iwr}; // PG0 -> IRAM
`else	
//	force `HW.pulse_width_probe = |{`DUT_CORE.u0_mpb.pg0_xrd,`DUT_CORE.u0_mpb.pg0_xwr}; // PG0 -> XRAM
	force `HW.pulse_width_probe = |{`DUT_CORE.u0_mpb.memrd,`DUT_CORE.u0_mpb.memwr}; // MCU -> XRAM
`endif
	`HW.pulse_width_analy;
end
initial begin
	fork
	begin: FW_TASK
	@(negedge `DUT_MCU.ro)
	`HW.load_dut_fw ({"../fw/",`FW0,"/",`FW0,".1.memh"});
	wait (`DUT_MCU.u_ports.port0==='hef)
	   $display ($time,"ns <%m> NOTE: DUT FW task done");
	end
	begin: main
	#200_000
	`I2CMST.init (1); // 400KHz, high bit-rate would cause long IDAT access fails PG0 access
`ifdef IDATA
	$display ($time,"ns <%m> switch PG0 to BANK11");
	`I2CMST.sfrw (`I2CCTL,'h16); // PG0=BANK11, non-inc
`endif
	`I2CMST.sfrw (`I2CCTL,'h06); // PG0=BANK3, non-inc
	`I2CMST.sfrw (0,'haa);
`ifdef WR
	`I2CMST.bkwr (0,1000,{1000{8'haa}});
`else	`I2CMST.bkrd (0,1000,{1000{8'haa}});
`endif
	end
	join

	disable `HW.pulse_width_analy.counting;
	hw_complete;
end // initial

endmodule // stm_hwi2c_mpb

