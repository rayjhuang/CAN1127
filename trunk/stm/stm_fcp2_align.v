
`timescale 1ns/1ns
module stm_fcp2_align;
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp2_align);
initial timeout_task (1000*300);

initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	`HW.set_code ('h960,'h00);
	`HW.set_code ('h961,'h38); // APPLE/DCP/QC
	`HW.set_code ('h962,'h00);
	`HW.set_code ('h963,'h00);

	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep D+ attached
	             CheckHVDCP;
	#(1000*1000*4) // for SCP's fastest PING in 5ms

	#(4*FCP_UI) ScpMBRd_nak ('hb0,5); // NAK and odd length
	#(4*FCP_UI) FcpDevPing (0);
	            ChkAdpPing (0);

	KeepDmIdle (3);
#10_000 hw_complete;
end // main

task ScpMBRd_nak; // correct format with NAK response
input [7:0] radr, rlen;
reg [7:0] crc,byt;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, len:%02x", radr, rlen);
	crc = CrcAcc (0,4,{8'h0,rlen,radr,MBRRD});
	FcpDevTx (3,{MBRRD,~(^MBRRD)});
	FcpDevTx (3,{radr, ~(^radr)});
	FcpDevTx (3,{rlen, ~(^rlen)});
	FcpDevTx (3,{crc,  ~(^crc)}); FcpDevPing (1);
	                              ChkAdpPing (0);
	crc = CrcAcc (0,2,{8'h0,NAK0});
	FcpDevRx ({NAK0,~(^NAK0)});
	FcpDevRx ({crc, ~(^crc)});    ChkAdpPing (1);
end
endtask // ScpMBRd_nak

endmodule // stm_fcp2_align

