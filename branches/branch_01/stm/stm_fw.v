`timescale 1ns/1ns
module stm_fw;
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_fw);
event ev0;
always @(ev0) `HW.dut_hit_rate (0);
initial begin
	#10_000
	force `DUT_MCU.mempsrd_comb =0; // to prevent from being held before FW loaded
	`I2CMST.init (1); // 400KHz
	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
	#150_000 // add RSTB_5 to RSTB delay
	#40_000 `I2CMST.sfrw (`X0_NVMCTL,'h18); // multi-pulse
	#40_000 $display ($time,"ns <%m> starts.....");
	fork
`ifdef FW0 // FW for DUT
	begin
	   `HW.load_dut_fw ({"../fw/",`FW0,"/",`FW0,".1.memh"});
	   @(posedge `DUT_MCU.clkcpu) #1 release `DUT_MCU.mempsrd_comb; // let FW go
	   ->ev0; // start dut_hit_rate()
	   wait (`DUT_MCU.u_ports.port0==='hef) $display ($time,"ns <%m> NOTE: DUT FW task done");
	end
`else
	`HW.init_dut_fw;
	release `DUT_MCU.mempsrd_comb;
`endif
	join

`ifdef FWI2C // the FW has FW-completing ability (FWI2C-to-P0)
	`I2CMST._tx_s;
	`I2CMST._txrx (7, 8'hec);	`I2CMST._txrx_ack (1,0); // FW dev_addr
	`I2CMST._txrx (7, 8'hed);	`I2CMST._txrx_ack (1,0); // to end in FW
	`I2CMST._tx_p;
`else
`ifdef FW_DEBUG // debug FW by simulation
	load_dut_fw ({`FW_DEBUG,".2.memh"});
`else
	#1_000 hw_complete;
`endif
`endif
end

endmodule // stm_fw

