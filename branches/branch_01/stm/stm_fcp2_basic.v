
`timescale 1ns/1ns
module stm_fcp2_basic;
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp2_basic);
initial timeout_task (1000*500);

initial begin: main
integer ii;
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	`HW.set_code ('h960,'h00);
	`HW.set_code ('h961,'h38); // APPLE/DCP/QC
	`HW.set_code ('h962,'h00);
	`HW.set_code ('h963,'h00);

	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep D+ attached
	CheckHVDCP;

	#(1000*1000*4) FcpDevPing (0); // for SCP's fastest PING in 5ms
	               ChkAdpPing (0);

	random_ui(1); ScpSingleBlockRd ('h00,'h01); // CLASS A: 5V/2A,9V/2A,12V/2A
	random_ui(1); ScpSingleBlockRd ('ha0,'h80); // CLASS B: SCP_EN=0
//	random_ui(1); ScpMultipleBlockRd ('hb2,2,40'ha00f); // 40W default (12V/4A)
//	random_ui(1); ScpMultipleBlockRd ('hb2,4,40'h7232_a00f); // 40W default (12V/4A)

	random_ui(1); ScpSingleBlockWr ('ha0,'hc0); // active SCP (CLASS B)

	random_ui(1); ScpMultipleBlockRd ('hb0,4,32'ha00f_e02e); // 40W default (12V/4A)
	FcpDevPing (0);
	ChkAdpPing (0);
	KeepDmIdle (10);

	random_ui(1); ScpSingleBlockWr ('hb0,'h33);
	random_ui(1); ScpSingleBlockRd ('hb0,'h33);

	random_ui(1); ScpMultipleBlockWr ('hb0,4,32'hdc05_2823); // 9V/1.5A
	random_ui(1); ScpMultipleBlockRd ('hb0,4,32'hdc05_2823);

	random_ui(3);
`ifdef CAN1112BX
	FCP_UI = 160*1000*1.0; // long RESET pulse
`else
	FCP_UI = 160*1000*0.81; // short RESET pulse (CAN1121A0 & CAN1120A0)
`endif
	FcpDevReset;
	`HW.PB.PWR_ENABLE.WAIT (0,10);
	`HW.PB.PWR_ENABLE.KEEP (0,10);
	`HW.PB.PWR_ENABLE.WAIT (1,15);
	CheckHVDCP;
	#(1000*1000*4) // for SCP's fastest PING in 5ms
	                    ScpSingleBlockRd ('ha0,'h80); // CLASS B: SCP_EN=0
	KeepDmIdle (10);
#10_000 hw_complete;
end

task random_ui;
input [7:0] delay; // UI
begin
	FCP_UI = {$random}%(160*1000*20/100) + 160*1000*90/100;
	#(FCP_UI*delay);
end
endtask // random_ui

endmodule // stm_fcp2_basic

