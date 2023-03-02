
module stm_wdt;
// test WDT basic functions
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*200);
time start;
initial begin
#100	`HW.init_dut_fw;
#9_900	`I2CMST.init (1); // 400KHz
	`I2CMST.dev_addr = 'h70; // to DUT
	#500_000 test_wdt (1,0,0); // 21.35us*128
	#500_000 test_wdt (1,1,0); // 21.35us*128
	#500_000 test_wdt (1,0,'h20); // 21.35us*96
	#500_000 test_wdt (0,0,'h80-'h20); // 2ms*32
	#500_000 test_wdt (0,1,'h80-'h03); // 32.8ms*3
	hw_complete;
end

task test_wdt;
input tm, pres;
input [6:0] rel;
begin
	$display ($time,"ns <%m> starts, %d, %d, %02x", tm, pres, rel);
	`I2CMST.bkwr (`ADR_SRST,3,'h01_0101); // CPU reset (non-inc)
	`I2CMST.sfrw (`ADR_WDTREL,{pres,rel}); // prescaler select
	`I2CMST.sfrw (`ADR_PCON,tm?'h40:0); // wdt_tm
	`I2CMST.sfrw (`ADR_IEN1,'h40); // SWDT, start/refresh
	#(1000*100)
	`I2CMST.bkwr (`ADR_IEN0,2,'h4040); // WDT, refresh flag
	`I2CMST.sfrw (`ADR_IEN1,'h40); // SWDT, start/refresh
	start = $time;
	wait (`DUT_MCU.ro)
	$display ($time,"ns <%m> NOTE: CPU reset, WDT timeout %.2fms", 1.0*($time-start)/1000/1000);
end
endtask // test_wdt

endmodule // stm_wdt

