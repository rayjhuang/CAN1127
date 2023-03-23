
`timescale 1ns/1ns
module stm_scan_pwrv;
// test DAC0/DAC3, and offset registers
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_scan_pwrv);
initial timeout_task (1000*1000);

initial begin
#1	`HW.init_dut_fw;
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (3); // ideal 1MHz
#200_000 $display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`I2CCTL,'h19); // BNK12, inc
	scan_dac0 (`HLSB,0,0,0,0);
	scan_dac0 (`HLSB,-1,-1,-1,-1);
	repeat (4)
	scan_dac0 (`HLSB,$random,$random,$random,$random);
#100_000 hw_complete;
end

task scan_dac0;
input [2:0] hlsb; // 0/1/3:
input [3:0] ofs0, ofs1, ofs2, ofs3;
reg [15:0] ii, r_cvofs;
begin
	r_cvofs = {ofs3, ofs2, ofs1, ofs0};
	#100_000 $display ($time,"ns <%m> starts.....%0d,%0d,%0d,%0d (%0d)",ofs0,ofs1,ofs2,ofs3,hlsb);
	`I2CMST.sfrw (`X0_XTM,{1'h0,hlsb[2:1],5'h0}); // [duty,freq]
	`I2CMST.bkwr (`CVOFS01,2,{ofs2[3],ofs3,ofs2[2:0],
	                          ofs0[3],ofs1,ofs0[2:0]});
	for (ii=150*2; ii<=1050*2; ii=ii+1*2) // 300mV~2100mV
	if (ii < 300*2 ||
	    ii > 500*2 && ii < 600*2 ||
	    ii > 900*2) begin // fewer cases
	   `I2CMST.bkwr (`PWRCTL,2,{ii[11:4],3'h0,hlsb[0],ii[3:0]}); // in inc.
	   if (hlsb[0]) repeat (2) begin // half-LSB
	      VTARGET.WAIT_US (exp_v(ii,  r_cvofs)*10, 200);
	      VTARGET.WAIT_US (exp_v(ii+2,r_cvofs)*10, 200);
	   end else begin // normail (1-LSB)
	      VTARGET.WAIT_US (exp_v(ii,r_cvofs)*10, 200);
	      VTARGET.KEEP_US (exp_v(ii,r_cvofs)*10, 80);
	   end
	end
end
endtask // scan_dac0

function [15:0] exp_v;
input [15:0] vin, r_cvofs; // 10mV
	   exp_v =
		 vin<256*2 ?vin+2*r_cvofs[0*4+:4]
		:vin<512*2 ?vin+2*r_cvofs[1*4+:4]
		:vin<768*2 ?vin+2*r_cvofs[2*4+:4] :vin+2*r_cvofs[3*4+:4]; // 10mV
endfunction

VTARGET VTARGET();
endmodule // stm_scan_pwrv

`define PBNAME VTARGET
`define PBANA (`DUT_ANA.VO_target)
`include "inc_probe.v"

