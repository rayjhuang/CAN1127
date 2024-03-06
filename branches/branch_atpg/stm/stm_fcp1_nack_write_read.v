
`timescale 1ns/1ns
module stm_fcp1_nack_write_read;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_nack_write_read);
initial timeout_task (1000*200);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep DP attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	tx_fcp;
#10_000 hw_complete;
end

reg	[7:0]	cmd;
reg	[7:0]	adr;
reg	[7:0]	lens;
reg	[7:0]	dat1,dat2,dat3,dat4,dat5; 
reg	[7:0]	dat6,dat7,dat8,dat9,dat10; 
reg	[7:0]	dat11,dat12,dat13,dat14,dat15; 
reg	[7:0]	crc;
reg		p;

parameter   NACK0=8'h03;

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");

	#(1*FCP_UI) ScpSingleBlockWr (8'h2D,8'h55);
	#(1*FCP_UI) ScpSingleBlockRd (8'h2D,8'h55);

//----------------------------------------------------------------------
	#(5*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
		    cmd =SBRWR; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // write
		    adr =8'hF1; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
		    dat1=8'hAA; p=~(^dat1); FcpDevTx (3,{dat1,p}); // data
		    CrcGen(3,{dat1,adr ,cmd },crc);
		                p=~(^crc ); FcpDevTx (3,{crc ,p}); // CRC
		    FcpDevPing (1);
	ChkAdpPing (0);
	cmd =NACK0 ; p=~(^(cmd )); FcpDevRx ({cmd ,p}); // NACK
	CrcGen(1,{cmd },crc);
	             p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);

//----------------------------------------------------------------------
	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
		    cmd =SBRRD; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // read
		    adr =8'hF1; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
		    CrcGen(2,{adr ,cmd },crc);
		                p=~(^crc ); FcpDevTx (3,{crc ,p}); // crc 
		    FcpDevPing (1);
	ChkAdpPing (0);
	cmd =NACK0 ; p=~(^(cmd )); FcpDevRx ({cmd ,p}); // NACK
	CrcGen(1,{cmd },crc);
	             p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);


//----------------------------------------------------------------------
	#(10*FCP_UI) 
	; // $finish;

end
endtask // tx_fcp

endmodule // stm_fcp1_nack_write_read

