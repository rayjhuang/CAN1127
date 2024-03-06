
`timescale 1ns/1ns
module stm_fcp1_5byte_length_check;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_5byte_length_check);
initial timeout_task (1000*200);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep DP attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	FCP_UI = 160*(1000*1.11);
	tx_fcp;
#10_000 hw_complete;
end

reg	[7:0]	cmd;
reg	[7:0]	adr;
reg	[7:0]	lens, len1;
reg	[7:0]	dat1,dat2,dat3,dat4,dat5; 
reg	[7:0]	dat6,dat7,dat8,dat9,dat10; 
reg	[7:0]	dat11,dat12,dat13,dat14,dat15; 
reg	[7:0]	crc;
reg		p;

parameter   NACK0=8'h03;

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");
	#(32*FCP_UI);
		    FcpDevPing (0);
		    ChkAdpPing (0);
	dat1 = 'h5c;
	dat2 = 'h95;
//	#(1*FCP_UI) ScpMultipleBlockRd ('hc8,2,{dat2,dat1});
	#(1*FCP_UI) ScpSingleBlockWr (8'hA0,8'h40); // active CLASS B

	//-----------------------------------------------------------------------------------
	// MBRWR length is not correct
	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
		    cmd  =MBRWR; p=~(^cmd  ); FcpDevTx (3,{cmd  ,p}); // write
		    adr  =8'hB0; p=~(^adr  ); FcpDevTx (3,{adr  ,p}); // address
		    lens =8'h05; p=~(^lens ); FcpDevTx (3,{lens ,p}); // length of datas
		    dat1 =8'h55; p=~(^dat1 ); FcpDevTx (3,{dat1 ,p}); // data#1
		    dat2 =8'hAA; p=~(^dat2 ); FcpDevTx (3,{dat2 ,p}); // data#2
		    dat3 =8'hF1; p=~(^dat3 ); FcpDevTx (3,{dat3 ,p}); // data#3
		    dat4 =8'h0F; p=~(^dat4 ); FcpDevTx (3,{dat4 ,p}); // data#4
		    dat5 =8'h00; 
		    CrcGen(7,{dat4,dat3,dat2,dat1,lens,adr ,cmd },crc);
		                 p=~(^crc  ); FcpDevTx (3,{crc  ,p}); // CRC
		    FcpDevPing (1);
	ChkAdpPing (0);
	cmd =NACK0 ; p=~(^(cmd )); FcpDevRx ({cmd ,p}); // ACK
	CrcGen(1,{cmd },crc);
	             p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);

	//-----------------------------------------------------------------------------------
	// MBRWR length is correct
	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);
		    cmd  =MBRWR; p=~(^cmd  ); FcpDevTx (3,{cmd  ,p}); // write
		    adr  =8'hB0; p=~(^adr  ); FcpDevTx (3,{adr  ,p}); // address
		    lens =8'h05; p=~(^lens ); FcpDevTx (3,{lens ,p}); // length of datas
		    dat1 =dat1 ; p=~(^dat1 ); FcpDevTx (3,{dat1 ,p}); // data#1
		    dat2 =dat2 ; p=~(^dat2 ); FcpDevTx (3,{dat2 ,p}); // data#2
		    dat3 =dat3 ; p=~(^dat3 ); FcpDevTx (3,{dat3 ,p}); // data#3
		    dat4 =dat4 ; p=~(^dat4 ); FcpDevTx (3,{dat4 ,p}); // data#4
		    dat5 =dat5 ; p=~(^dat5 ); FcpDevTx (3,{dat5 ,p}); // data#5 
		    CrcGen(8,{dat5,dat4,dat3,dat2,dat1,lens,adr ,cmd },crc);
		                 p=~(^crc  ); FcpDevTx (3,{crc  ,p}); // CRC
		    FcpDevPing (1);
	ChkAdpPing (0);
	cmd =ACK0 ;  p=~(^(cmd )); FcpDevRx ({cmd ,p}); // ACK
	CrcGen(1,{cmd },crc);
	             p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);

	//-----------------------------------------------------------------------------------
	// MBRRD length is correct
	#(1*FCP_UI) ScpMultipleBlockRd ('hb0,5,{dat5,dat4,dat3,dat2,dat1});

	#(16*FCP_UI) 
	; // $finish;
end
endtask // tx_fcp

endmodule // stm_fcp1_5byte_length_check

