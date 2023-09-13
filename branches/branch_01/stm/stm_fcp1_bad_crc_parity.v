
`timescale 1ns/1ns
module stm_fcp1_bad_crc_parity;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_bad_crc_parity);
initial timeout_task (1000*200);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep DP attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	FCP_UI = 160*(1000*0.89);
	tx_fcp;
#10_000 hw_complete;
end

reg	[7:0]	cmd;
reg	[7:0]	adr;
reg	[7:0]	dat1;
reg	[7:0]	crc;
reg		p;

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");

	#(1*FCP_UI) ScpSingleBlockWr (8'h2B,8'hAA);
	#(1*FCP_UI) ScpSingleBlockRd (8'h2B,8'hAA);

	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
	#(1*FCP_UI) cmd =SBRWR; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // write
		    adr =8'h2B; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
		    dat1=8'h55; p= (^dat1); FcpDevTx (3,{dat1,p}); // data with wrong parity
		    CrcGen(3,{dat1,adr ,cmd },crc);
		                p=~(^crc ); FcpDevTx (3,{ crc,p}); // CRC
		    FcpDevPing (1);
		    ChkAdpPing (0);

        #(5*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
	#(1*FCP_UI) cmd =SBRWR; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // write
		    adr =8'h2B; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
		    dat1=8'h55; p=~(^dat1); FcpDevTx (3,{dat1,p}); // data
		    CrcGen(3,{dat1,adr ,cmd },crc);
		                p=~(^crc ); FcpDevTx (3,{~crc,p}); // wrong CRC
		    FcpDevPing (1);
		    ChkAdpPing (0); // SLAVE still respond a PING even if CRC error

	#(1*FCP_UI) ScpSingleBlockRd (8'h2B,8'hAA);
	#(1*FCP_UI) ScpSingleBlockWr (8'h2B,8'h55);
	#(1*FCP_UI) ScpSingleBlockRd (8'h2B,8'h55);
	#(1*FCP_UI) 
	; // $finish;
end
endtask // tx_fcp

endmodule // stm_fcp1_bad_crc_parity

