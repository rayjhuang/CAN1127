`timescale 1ns/1ns
module stm_isp_cc;
// FW test and the FW is written to OTP by CC
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_isp_cc);
`ifdef FW // FW for DUT defined in command line
parameter OTP_MAX = 1000; // probing range
reg [15:0] idx, fst0;
reg [7:0] codex [0:OTP_MAX-1];
reg [OTP_MAX*8-1:0] code8;
`ifdef DUMMY3
parameter DUMMY = 3;
`else
parameter DUMMY = 2;
`endif
reg [OTP_MAX*8*DUMMY-1:0] coden; // additional capacity
reg [7:0] MultiPulse = 'h00;
initial begin
#1	`HW.init_dut_fw; // ATO0004KX8VI150BG33NA already done this


	#500_000 // HW checksum lantency

	fst0 = 0;
	$readmemh ({"../fw/",`FW,"/",`FW,".1.memh"}, codex);
	for (idx=0;idx<OTP_MAX;idx=idx+1) begin
	   if (codex[idx]===8'hxx && fst0<10) begin
	      $display ($time,"ns <%m> NOTE: %0d XX at 0x%04x", fst0, idx);
	      if (fst0<9) fst0 = fst0 + 1;
	             else fst0 = idx;
	   end
	   if (codex[idx]===8'hxx) codex[idx] = $random;
	end
	for (idx=0;idx<=fst0;idx=idx+1) begin
	   code8[idx*8+:8] = codex[idx];
	   coden[(DUMMY+1)*idx*8+:(DUMMY+1)*8] = {{DUMMY{8'hdd}},code8[idx*8+:8]};
	end
	$display ($time,"ns <%m> NOTE: load firmware ../fw/",`FW,"/",`FW,".1.memh, %0d bytes", fst0);


	`UPD.DutsGdCrcSpec = 0; // FW not yet programed PRLTX
	`UPD.SpecRev = 0; // PD2
	`UPD.ExpOrdrs = 5; // SOP"_Debug

	#`UPD.INTERFRAM `UPD.CspW (`MISC,'h0c); // hold, short preamble
	#`UPD.INTERFRAM `UPD.CspW (`X0_NVMCTL,'h88|MultiPulse); // set VPP_EN
	#`UPD.INTERFRAM `UPD.CspR (`OFS, 'h00); // check OTP offset
	#`UPD.INTERFRAM `UPD.CspR (`DEC, 'h00); // check OTP offset
	#`UPD.INTERFRAM `UPD.CspW (`DEC, 'h80); // ACK for OTP access, reset address
	if (MultiPulse=='h10)
	   check_read_w_multi_pulse;



	#`UPD.INTERFRAM `UPD.CspW (`NVMIO,coden,(DUMMY+1)*fst0-DUMMY-1,1);
	#`UPD.INTERFRAM `UPD.CspW (`X0_NVMCTL,'h08|MultiPulse); // clear VPP_EN for OTP read

	#`UPD.INTERFRAM `UPD.CspR (`OFS,'h8000|fst0,1); // check OTP offset, inc
	#`UPD.INTERFRAM `UPD.CspW (`OFS,'h8000,1); // reset OTP offset, inc
	#`UPD.INTERFRAM `UPD.CspR (`NVMIO,code8,fst0-1,1); // 256-byte limited

	#40_000
	$display ($time,"ns <%m> starts.....");
	#`UPD.INTERFRAM `UPD.CspW (`ADR_SRST,'h010101,2,1); // software reset
	#`UPD.INTERFRAM `UPD.CspW (`MISC,'h0008_0008,3,1); // hold/free CPU
	// free MCU don't need re-checksum
//	#500_000 // HW checksum lantency



	// fw_complete
//	#1_000 hw_complete;
end
`else
	"ERROR: no FW defined"
`endif // FW

initial // for CLK multi-pulse simulation on orignal OTP model (A0ECO=B0)
#1000	forever
	   @(posedge `DUT.U0_CODE[0].CLK)
	   if (`DUT.U0_CODE[0].PGM==1) begin
	      force `DUT.U0_CODE[0].CLK = 1;
	      #9000 release `DUT.U0_CODE[0].CLK;
	   end
task check_read_w_multi_pulse;
begin
	$display ($time,"ns <%m> starts.....");
	`HW.set_code (0,'haa);
	`HW.set_code (1,'h55);
	`HW.set_code (2,'h00); #`UPD.INTERFRAM `UPD.CspR (`NVMIO, 'h0055aa, 2, 1);
	#`UPD.INTERFRAM `UPD.CspW (`OFS, 'h8000, 1); // restore OFS and DEC
	`HW.set_code (0,'hff);
	`HW.set_code (1,'hff);
	`HW.set_code (2,'hff); #`UPD.INTERFRAM `UPD.CspR (`NVMIO, 'hffffff, 2, 1);
	#`UPD.INTERFRAM `UPD.CspW (`OFS, 'h8000, 1); // restore OFS and DEC
end
endtask // check_read_w_multi_pulse
endmodule // stm_isp_cc

