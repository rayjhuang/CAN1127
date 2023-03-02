

`timescale 1ns/1ns
module stm_fcp2_packet;
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp2_packet);
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
//	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0, 0); // active SCP (CLASS B)

	#(5*FCP_UI)  ScpSBWr_parity ('ha0,'hc0, 2);
`ifdef CAN1112BX
`else
	#(5*FCP_UI)  ScpSBWr_parity ('ha0,'hc0, 4); // CAN1112 failed
`endif

	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0, 1);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0, 2);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0, 4);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0, 8);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0,'h10);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0,'h20);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0,'h40);
	#(5*FCP_UI)  ScpSBWr_sync1 ('ha0,'hc0,'h80);

	#(4*FCP_UI)  ScpSingleBlockRd ('ha0,'h80);
#10_000 hw_complete;
end // main

task ScpSBWr_sync1;
input [7:0] wadr, wdat;
input [7:0] lack; // fewer sync in each byte
reg [7:0] crc;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, dat:%02x, for:%d",wadr,wdat,lack);
	crc = CrcAcc (0,3+1,{8'h0,wdat,wadr,SBRWR});
	FcpDevTx ({lack[4],1'h1,~lack[0]},{SBRWR,~(^SBRWR)}); // write
	FcpDevTx ({lack[5],1'h1,~lack[1]},{wadr, ~(^wadr)}); // address
	FcpDevTx ({lack[6],1'h1,~lack[2]},{wdat, ~(^wdat)}); // data
	FcpDevTx ({lack[7],1'h1,~lack[3]},{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	if (lack) // no response
	   KeepDmIdle (5);
	else begin // ACK response
	   crc = CrcAcc (0,1+1,{8'h0,ACK0});
	   FcpDevRx ({ACK0,~(^ACK0)});
	   FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
	end
end
endtask // ScpSBWr_sync1

task ScpSBWr_parity;
input [7:0] wadr, wdat;
input [3:0] lack; // lack of parity bit in each byte
reg [7:0] crc;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, dat:%02x, for:%d",wadr,wdat,lack);
	crc = CrcAcc (0,3+1,{8'h0,wdat,wadr,SBRWR});
	FcpDevTx ({1'h0,~lack[0],1'h1},{SBRWR,~(^SBRWR)}); // write
	FcpDevTx ({1'h0,~lack[1],1'h1},{wadr, ~(^wadr)}); // address
	FcpDevTx ({1'h0,~lack[2],1'h1},{wdat, ~(^wdat)}); // data
	FcpDevTx ({1'h0,~lack[3],1'h1},{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	if (lack) // no response
	   KeepDmIdle (5);
	else begin // ACK response
	   crc = CrcAcc (0,1+1,{8'h0,ACK0});
	   FcpDevRx ({ACK0,~(^ACK0)});
	   FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
	end
end
endtask // ScpSBWr_parity

endmodule // stm_fcp2_packet

