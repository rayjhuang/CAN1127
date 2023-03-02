
`timescale 1ns/1ns
module stm_fcp1_TypeA_whole_registers;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_TypeA_whole_registers);
initial timeout_task (1000*1200);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep DP attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	FCP_UI = 160*(1000*0.90);
	tx_fcp;
#10_000 hw_complete;
end

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");
	#(31*FCP_UI);
	#(1*FCP_UI) FcpDevPing (0);
		    ChkAdpPing (0);

	#(1*FCP_UI) ScpSingleBlockRd (8'h00,8'h08); // Addr=00 / default=08
	#(1*FCP_UI) ScpSingleBlockRd (8'h01,8'h22); // Addr=01 / default=22
	#(1*FCP_UI) ScpSingleBlockRd (8'h02,8'h00); // Addr=02 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h03,8'h00); // Addr=03 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h04,8'h00); // Addr=04 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h05,8'h00); // Addr=05 / default=00

	#(1*FCP_UI) ScpSingleBlockRd (8'h20,8'h03); // Addr=20 / default=03
	#(1*FCP_UI) ScpSingleBlockRd (8'h21,8'h01); // Addr=21 / default=01
	#(1*FCP_UI) ScpSingleBlockRd (8'h22,8'h2c); // Addr=22 / default=2C
	#(1*FCP_UI) ScpSingleBlockRd (8'h28,8'h00); // Addr=28 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h29,8'h00); // Addr=29 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h2b,8'h00); // Addr=2B / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h2c,8'h34); // Addr=2C / default=34
	#(1*FCP_UI) ScpSingleBlockRd (8'h2d,8'h14); // Addr=2D / default=14

	#(1*FCP_UI) ScpSingleBlockRd (8'h2f,8'h1d); // Addr=2F / default=1D

	#(1*FCP_UI) ScpSingleBlockRd (8'h30,8'h34); // Addr=30 / default=34
	#(1*FCP_UI) ScpSingleBlockRd (8'h31,8'h37); // Addr=31 / default=37
	#(1*FCP_UI) ScpSingleBlockRd (8'h32,8'h3c); // Addr=32 / default=3C
	#(1*FCP_UI) ScpSingleBlockRd (8'h33,8'h41); // Addr=33 / default=41
	#(1*FCP_UI) ScpSingleBlockRd (8'h34,8'h46); // Addr=34 / default=46
	#(1*FCP_UI) ScpSingleBlockRd (8'h35,8'h4b); // Addr=35 / default=4B
	#(1*FCP_UI) ScpSingleBlockRd (8'h36,8'h50); // Addr=36 / default=50
	#(1*FCP_UI) ScpSingleBlockRd (8'h37,8'h55); // Addr=37 / default=55
	#(1*FCP_UI) ScpSingleBlockRd (8'h38,8'h5a); // Addr=38 / default=5A
	#(1*FCP_UI) ScpSingleBlockRd (8'h39,8'h64); // Addr=39 / default=64
	#(1*FCP_UI) ScpSingleBlockRd (8'h3a,8'h69); // Addr=3A / default=69
	#(1*FCP_UI) ScpSingleBlockRd (8'h3b,8'h6e); // Addr=3B / default=6E
	#(1*FCP_UI) ScpSingleBlockRd (8'h3c,8'h73); // Addr=3C / default=73
	#(1*FCP_UI) ScpSingleBlockRd (8'h3d,8'h78); // Addr=3D / default=78
//	#(1*FCP_UI) ScpSingleBlockRd (8'h3e,8'h00); // Addr=3E / default=00
//	#(1*FCP_UI) ScpSingleBlockRd (8'h3f,8'h00); // Addr=3F / default=00

	#(1*FCP_UI) ScpSingleBlockRd (8'h40,8'h14); // Addr=40 / default=14
	#(1*FCP_UI) ScpSingleBlockRd (8'h41,8'h19); // Addr=41 / default=19
	#(1*FCP_UI) ScpSingleBlockRd (8'h42,8'h00); // Addr=42 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h43,8'h00); // Addr=43 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h44,8'h00); // Addr=44 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h45,8'h00); // Addr=45 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h46,8'h00); // Addr=46 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h47,8'h00); // Addr=47 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h48,8'h00); // Addr=48 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h49,8'h00); // Addr=49 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h4a,8'h00); // Addr=4A / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h4b,8'h00); // Addr=4B / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h4c,8'h00); // Addr=4C / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h4d,8'h00); // Addr=4D / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h4e,8'h00); // Addr=4E / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'h4f,8'h00); // Addr=4F / default=00

	#(1*FCP_UI) 
	; // $finish;
end
endtask // tx_fcp

endmodule // stm_fcp1_TypeA_whole_registers

