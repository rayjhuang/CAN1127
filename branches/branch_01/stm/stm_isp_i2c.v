`timescale 1ns/1ns
module stm_isp_i2c;
// FW test and the FW is written to OTP by I2C
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_isp_i2c);
`ifdef FW // FW for DUT defined in command line
parameter OTP_MAX = 1000; // probing range
reg [15:0] idx, fst0;
reg [7:0] codex [0:OTP_MAX-1];
reg [OTP_MAX*8-1:0] code8;







initial begin
#1	`HW.init_dut_fw; // ATO0004KX8VI150BG33NA already done this
	`I2CMST.init (1); // 400KHz
	`I2CMST.dev_addr = 'h70; // to DUT
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

	end
	$display ($time,"ns <%m> NOTE: load firmware ../fw/",`FW,"/",`FW,".1.memh, %0d bytes", fst0);






	`I2CMST.sfrw (`MISC,'h08);      // hold
	`I2CMST.sfrw (`X0_NVMCTL,'h80); // set VPP_EN
	`I2CMST.sfrr (`OFS,'h00);       // check OTP offset
	`I2CMST.sfrr (`DEC,'h00);       // check OTP offset
	`I2CMST.sfrw (`DEC,'h80);       // ACK for OTP access, reset address

	`I2CMST.sfrw (`GPIO5,'h20); // SCL stretch
	`I2CMST.bkwr (`NVMIO,fst0,code8); // by SCL stretch

	check_multi_pulse;

	`I2CMST.sfrw (`X0_NVMCTL,'h00); // clear VPP_EN for OTP read

        `I2CMST.sfrw (`OFS,'h00); // ACK for OTP access, reset address
        `I2CMST.sfrw (`DEC,'h80); // ACK for OTP access, reset address
	`I2CMST.bkrd (`NVMIO,fst0,code8);

	#40_000
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`DEC,'h7c); // ACK for reset
	`I2CMST.sfrw (`FFSTA,'h55); // system reset
//	`HW.set_hw_chksum;
//	#500_000 // HW checksum lantency
//000	`I2CMST.sfrr (`NVMIO,'hee); // returns 'hee  if r_ack_hi=1
#3000	`I2CMST.sfrr (`NVMIO,'h00); // returns regCF if r_ack_hi=0

	// fw_complete
//	#1_000 hw_complete;
end
`else
	"ERROR: no FW defined"
`endif // FW

task check_multi_pulse;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`X0_NVMCTL,'h90); // set r_multi
	// to CODE_0_CE
	`I2CMST.bkwr (`NVMIO,2,'h55aa); // test multi-pulse, check by hand

        `I2CMST.sfrw (`OFS,'h00); // to CODE_1_CE
        `I2CMST.sfrw (`DEC,'ha0); // ACK for OTP access, reset address
	`I2CMST.bkwr (`NVMIO,2,'h55aa); // test multi-pulse, check by hand

	`I2CMST.sfrw (`X0_GPIOTS,'h94); // set TS test mode 9
        `I2CMST.sfrw (`OFS,'h00); // to CODE_0_IF
        `I2CMST.sfrw (`DEC,'hc0); // ACK for OTP access, reset address
	`I2CMST.bkwr (`NVMIO,2,'h55aa); // test multi-pulse, check by hand
end
endtask // check_multi_pulse
endmodule // stm_isp_i2c

