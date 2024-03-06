
`timescale 1ns/1ns
module stm_fcp1_ping_write_read;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_ping_write_read);
initial timeout_task (1000*330);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep DP attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	FCP_UI = 160*(1000*1.10);
	tx_fcp;
#10_000 hw_complete;
end

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");
	//----------------------------------------------------------------------------
	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
	#(2*FCP_UI) FcpDevTx (3,{8'h01,1'h0}); // Hauwei M8's behavior
		    FcpDevPing (1);
		    ChkAdpPing (0);

	#(2*FCP_UI*0.10) // shorter for eliminating the 1st edge of SYNC
		    ScpSingleBlockRd (8'h00,8'h08);
	#(1*FCP_UI) ScpSingleBlockRd (8'hA0,8'h80); // CLASS A

	#(90*FCP_UI)
	//----------------------------------------------------------------------------
	#(1*FCP_UI) NakSingleBlockWr (8'hB0,8'h55); // NACK in CLASS A
	#(1*FCP_UI) ScpSingleBlockWr (8'hA0,8'h40); // active CLASS B
	#(1*FCP_UI) ScpSingleBlockWr (8'hB0,8'h55); // ACK in CLASS B

	//----------------------------------------------------------------------------
	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);

	#(6*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);

	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);

	//----------------------------------------------------------------------------
	#(1*FCP_UI) ScpSingleBlockRd (8'hB0,8'h55);

	//------------------------------------------------------
	#(1*FCP_UI) ScpSingleBlockRd (8'hB1,8'h7C);
	#(1*FCP_UI) ScpSingleBlockWr (8'hB1,8'hAA);
	#(1*FCP_UI) ScpSingleBlockRd (8'hB1,8'hAA);

	//-----------------------------------------------------
	#(1*FCP_UI) 
	; // $finish;

end
endtask // tx_fcp


parameter   NACK0=8'h03;

task NakSingleBlockWr;
input [7:0] wradr, wrdat;
reg [7:0] cmd, adr, dat1, crc;
reg		p;
begin
	FcpDevPing (0);
	ChkAdpPing (0);
	$display ($time,"ns <%m> adr:%02x, exp:%02x",wradr,wrdat);
	cmd =SBRWR; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // write
	adr =wradr; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
	dat1=wrdat; p=~(^dat1); FcpDevTx (3,{dat1,p}); // data
	CrcGen(3,{dat1,adr ,cmd },crc);
	            p=~(^crc ); FcpDevTx (3,{crc ,p}); // CRC
	FcpDevPing (1);
	ChkAdpPing (0);
	cmd =NACK0; p=~(^(cmd )); FcpDevRx ({cmd ,p}); // ACK
	CrcGen(1,{cmd },crc);
	            p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);
end
endtask // NakSingleBlockWr

endmodule // stm_fcp1_ping_write_read

