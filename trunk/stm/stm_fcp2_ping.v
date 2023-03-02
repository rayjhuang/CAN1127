
`timescale 1ns/1ns
module stm_fcp2_ping;
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp2_ping);
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

	#(1000*1000*4) ScpSBRd_wo_master_tail ('ha0);

	#(1000*1000*4) ScpSingleBlockRd ('ha0,'h80); // CLASS B: SCP_EN=0

	#(1000*1000*4) FcpDevPing (0);
	               ChkAdpPing (0);

	#(1000*1000*4) ScpSBRd_wo_master_head ('ha0);
	KeepDmIdle (5);

	#(4*FCP_UI) ScpSingleBlockRd ('ha0,'h80); // CLASS B: SCP_EN=0
#10_000 hw_complete;
end

task ScpSBRd_wo_master_tail;
input [7:0] radr;
reg [7:0] crc,byt;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x", radr);
	crc = CrcAcc (0,3,{8'h0,radr,SBRRD}); // shift out
	FcpDevTx (3,{SBRRD,~(^SBRRD)});
	FcpDevTx (3,{radr, ~(^radr)});
	FcpDevTx (3,{crc,  ~(^crc)});
end
endtask // ScpSBRd_wo_master_tail

task ScpSBRd_wo_master_head;
input [7:0] radr;
reg [7:0] crc,byt;
begin
	$display ($time,"ns <%m> adr:%02x", radr);
	crc = CrcAcc (0,3,{8'h0,radr,SBRRD}); // shift out
	FcpDevTx (3,{SBRRD,~(^SBRRD)});
	FcpDevTx (3,{radr, ~(^radr)});
	FcpDevTx (3,{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
end
endtask // ScpSBRd_wo_master_head

endmodule // stm_fcp2_ping

