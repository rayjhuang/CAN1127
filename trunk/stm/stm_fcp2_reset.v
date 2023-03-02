
`timescale 1ns/1ns
module stm_fcp2_reset;
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp2_reset);
initial timeout_task (1000*300);

initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	`HW.set_code ('h960,'h00);
	`HW.set_code ('h961,'h38); // APPLE/DCP/QC
	`HW.set_code ('h962,'h00);
	`HW.set_code ('h963,'h00);

	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep D+ attached
	             CheckHVDCP;

//	#(1000*1000*4) // for SCP's fastest PING in 5ms
//	             FcpDevReset; // to support Note10
//	             CheckHVDCP;

	#(1000*1000*4) // for SCP's fastest PING in 5ms
	             FcpDevPing (0); // for SCP's fastest PING in 5ms
	             ChkAdpPing (0);
	#(2*FCP_UI)  FcpDevReset;
	             CheckHVDCP;

	#(1000*1000*4) // for SCP's fastest PING in 5ms
	             ScpSingleBlockRd ('h00,'h01); // CLASS A: 5V/2A,9V/2A,12V/2A
	#(2*FCP_UI)  ScpSingleBlockRd ('ha0,'h80); // CLASS B: SCP_EN=0
	#(2*FCP_UI)
#10_000 hw_complete;
end // main

endmodule // stm_fcp2_reset

