
`timescale 1ns/1ns
module stm_fcp2_format;
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp2_format);
initial timeout_task (1000*500);

initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	`HW.set_code ('h960,'h00);
	`HW.set_code ('h961,'h38); // APPLE/DCP/QC
	`HW.set_code ('h962,'h00);
	`HW.set_code ('h963,'h00);

	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep D+ attached
	             CheckHVDCP;
	#(1000*1000*4) // for SCP's fastest PING in 5ms
	             ScpSBWr_num ('ha0,'hc0,1); // active SCP (CLASS B)

	#(5*FCP_UI)  ScpBlkRd_err (1,'ha0);

	#(4*FCP_UI)  ScpMBWr_num ('hb0,4,32'hdc05_2823,0);
	#(4*FCP_UI)  ScpMBWr_num ('hb0,4,32'hdc05_2823,4);
	#(4*FCP_UI)  ScpMBWr_num ('hb0,4,32'hdc05_2823,1);
	#(4*FCP_UI)  ScpMBWr_num ('hb0,4,32'hdc05_2823,8);
	#(4*FCP_UI)  ScpMBWr_num ('hb0,4,32'hdc05_2823,5); // 9V/1.5A

	#(4*FCP_UI)  ScpSingleBlockRd ('ha0,'hc0);

	#(5*FCP_UI)  ScpBlkRd_err (0,'ha0);

	#(5*FCP_UI)  ScpSBWr_num ('ha0,'hc0,0);
	#(5*FCP_UI)  ScpSBWr_num ('ha0,'hc0,2);

	#(4*FCP_UI)  ScpSingleBlockRd ('ha0,'hc0);
	KeepDmIdle (5);
#10_000 hw_complete;
end // main

task ScpMBWr_num;
input [7:0] wadr, wlen;
input [8*16-1:0] wdat;
input [7:0] num; // num of write data, 'wlen' is normal, others is not
reg [7:0] byt,crc,ii;
begin
	if (wlen>16) begin
	   $display ($time,"ns <%m> ERROR: length %d not supported", wlen);
	   $finish;
	end
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, cnt:%0d, num:%0d",wadr,wlen,num);
	crc = CrcAcc (0,2,{wadr,MBRWR});
	FcpDevTx (3,{MBRWR,~(^MBRWR)}); // write
	FcpDevTx (3,{wadr, ~(^wadr)}); // address
	for (ii=0;ii<num;ii=ii+1) begin
	   byt = (ii==0) ? wlen : (ii<=wlen) ? wdat[8*(ii-1)+:8] : $random;
	   crc = CrcAcc (crc,1,byt);
	   FcpDevTx (3,{byt,~(^byt)});
	end
	crc = CrcAcc (crc,1,0); // shift out
	FcpDevTx (3,{crc,~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	if (num==wlen+1) begin // ACK response
	   CrcGen (1,{ACK0},crc);
	   FcpDevRx ({ACK0,~(^ACK0)});
	   FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
	end else // no response
	   KeepDmIdle (5);
end
endtask // ScpMBWr_num

task ScpSBWr_num;
input [7:0] wadr, wdat;
input [7:0] num; // num of write data, '1' is normal, others is not
reg [7:0] crc,byt,ii;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, dat:%02x, num:%0d",wadr,wdat,num);
	FcpDevTx ({1'h0,1'h1,1'h1},{SBRWR,~(^SBRWR)}); // write
	FcpDevTx ({1'h0,1'h1,1'h1},{wadr, ~(^wadr)}); // address
	crc = CrcAcc (0,2,{wadr,SBRWR});
	for (ii=0;ii<num;ii=ii+1) begin
	   byt = (ii==0) ? wdat : $random;
	   crc = CrcAcc (crc,1,byt);
	   FcpDevTx ({1'h0,1'h1,1'h1},{byt, ~(^byt)}); // additional data
	end
	crc = CrcAcc (crc,1,0); // shift out
	FcpDevTx ({1'h0,1'h1,1'h1},{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	if (num==1) begin // ACK response
	   crc = CrcAcc (0,1+1,{8'h0,ACK0});
	   FcpDevRx ({ACK0,~(^ACK0)});
	   FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
	end else // no response
	   KeepDmIdle (5);
end
endtask // ScpSBWr_num

task ScpBlkRd_err; // multi without 'cnt' or single with 'cnt'
input multi;
input [7:0] radr;
reg [7:0] crc,byt;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	byt = multi ? MBRRD : SBRRD;
	$display ($time,"ns <%m> cmd:%02x, adr:%02x", byt, radr);
	crc = CrcAcc (0,2,{radr,byt});
	FcpDevTx (3,{byt,~(^byt)});
	FcpDevTx (3,{radr,~(^radr)});
	if (!multi) begin
	   byt = $random;
	   crc = CrcAcc (crc,1,byt);
	   FcpDevTx (3,{byt, ~(^byt)});
	end
	crc = CrcAcc (crc,1,0); // shift out
	FcpDevTx (3,{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	KeepDmIdle (5); // no response
end
endtask // ScpSBRd_add

endmodule // stm_fcp2_format

