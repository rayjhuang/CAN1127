
`timescale 1ns/1ns
module stm_fcp1_1byte_write_read;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_1byte_write_read);
initial timeout_task (1000*100);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep D+ attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	FCP_UI = 160*(1000*1.12);
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

task FcpPingTest; // if FCP_UI is long, ChkAdpPing shall start earlier
input DevPingStart;
event ev;
	->ev;
	fork
	FcpDevPing (DevPingStart);
	#(1000*1000*2) ChkAdpPing (0);
	join
endtask // FcpPingTest

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");
	FcpPingTest (0);

	#(1*FCP_UI) 
		    cmd =SBRWR; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // write
		    adr =8'h2B; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
		    dat1=8'h55; p=~(^dat1); FcpDevTx (3,{dat1,p}); // data
		    CrcGen(3,{dat1,adr ,cmd },crc);
		                p=~(^crc ); FcpDevTx (3,{crc ,p}); // CRC
		    FcpPingTest (1);

	cmd =ACK0 ; p=~(^(cmd )); FcpDevRx ({cmd ,p}); // ACK
	CrcGen(1,{cmd },crc);
	            p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);

	#(1*FCP_UI) FcpPingTest (0);

	#(1*FCP_UI) 
		    cmd =SBRRD; p=~(^cmd ); FcpDevTx (3,{cmd ,p}); // read
		    adr =8'h2B; p=~(^adr ); FcpDevTx (3,{adr ,p}); // address
		    CrcGen(2,{adr ,cmd },crc);
		                p=~(^crc ); FcpDevTx (3,{crc ,p}); // crc 
		    FcpPingTest (1);

	cmd =ACK0 ; p=~(^(cmd )); FcpDevRx ({cmd ,p}); // ACK
	dat1=dat1 ; p=~(^(dat1)); FcpDevRx ({dat1,p}); // data
	CrcGen(2,{dat1,cmd },crc);
	            p=~(^(crc )); FcpDevRx ({crc ,p}); // CRC
	ChkAdpPing (1);

	#(1*FCP_UI) 
	; // $finish;

end
endtask // tx_fcp

endmodule // stm_fcp1_1byte_write_read

