
`timescale 1ns/100ps
module stm_dacmux;
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial begin
#10	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
	ReTimeout (2);
#(1000*200)
	$display ($time,"ns <%m> starts.....");
	`I2CMST.dev_addr = 'h70; // DUT
	`I2CMST.init (2); // 1 MHz

	`I2CMST.sfrw (`I2CCTL,'h19); // inc, BANK12 (REGX)

	check_full_scale;
	check_zero_enable;
	manual_check_always_sample;

	ReTimeout (50); basic_semi_scan;
	    repeat (10) random_sar8_scan ('h3ffff);

	ReTimeout (500); basic_sar10_scan;
	ReTimeout (150); basic_sar8_scan;

	ReTimeout (100); random_sar8_scan ('h3ffff);
	    repeat (100) random_sar8_scan ($random);

	#(1000*200) hw_complete;
end

always @(posedge `DUT_MCLK) if (`DUT_CORE.u0_dacmux.sacyc_done)
	$display ($time,"ns <%m> v_sampler:%0d, r_rpt_v:%0d", `DUT_ANA.compm_mux.v_cap, `DUT_CORE.u0_dacmux.r_rpt_v);

task check_full_scale;
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`DACV0,'hff);
	`I2CMST.sfrw (`DACLSB,'h07); // try DAC1 full scale, turn-on DAC1/COMP (DAC1_EN)
	#1000
	if (`DUT_ANA.compm_mux.v_dac!==2046) begin
	   $display ($time,"ns <%m> ERROR: DAC1 full range error");
	   $finish;
	end else
	   $display ($time,"ns <%m> DAC1 manually full range is %0dmV",`DUT_ANA.compm_mux.v_dac);
endtask: check_full_scale

task check_zero_enable;
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`DACCTL,'h01); // try to start without DACEN, no effect
	#1000
	if (`DUT_CORE.u0_dacmux.busy!==1'h0) begin
	   $display ($time,"ns <%m> ERROR: DAC1/COMP should stay idle");
	   $finish;
	end
endtask: check_zero_enable

task manual_check_always_sample;
	$display ($time,"ns <%m> starts.....");
	`I2CMST.bkwr (`DACEN,3,{8'h04,8'h5a,8'h5a}); // in inc, all ADC channels, DAC1_EN
	`I2CMST.sfrw (`DACCTL,'h13); // always sample
	`I2CMST.sfrw (`DACCTL,'h00);
	`I2CMST.sfrw (`DACEN,'h01); `I2CMST.sfrw (`DACCTL,'h01); // restore cs_ptr=0
	`I2CMST.sfrw (`DACEN,'h00); // restore DACEN
endtask: manual_check_always_sample

task basic_semi_scan;
reg [15:0] ii;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`X0_SAREN2,'h08); // channel 11
	`I2CMST.bkwr (`DACCTL,4,{8'h34,8'hff,8'h00,8'h40}); // in inc, semi, 10-bit, LSB for ch3, DAC1_EN
	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, BANK12
	for (ii=0;ii<200;ii=ii+1) begin // or scan-all takes 400ms
	   force `DUT_ANA.compm_mux.v_ana_in[3*16+:16] = ii;
	   `I2CMST.bkwr (`DACV3,10,{{9{8'hac}},8'hc1});
	   `I2CMST.sfrr (`DACV3,ADC8(`DUT_ANA.compm_mux.v_ana_in[3*16+:16]));
	   `I2CMST.sfrr (`DACLSB,(ADC10(`DUT_ANA.compm_mux.v_ana_in[3*16+:16])&'h3)|'h34);
	end
	force `DUT_ANA.compm_mux.v_ana_in[1*16+:16]  = {$random}%2048;
	force `DUT_ANA.compm_mux.v_ana_in[2*16+:16]  = {$random}%2048;
	force `DUT_ANA.compm_mux.v_ana_in[3*16+:16]  = {$random}%2048;
	force `DUT_ANA.compm_mux.v_ana_in[11*16+:16] = {$random}%2048;

	`I2CMST.bkwr (`DACV1,8,{{7{8'hac}},8'hc1});
	`I2CMST.sfrr (`DACV1,ADC8(`DUT_ANA.compm_mux.v_ana_in[1*16+:16]));

	`I2CMST.bkwr (`X0_DACV11,8,{{7{8'hac}},8'hc1}); // channel 11
	`I2CMST.sfrr (`X0_DACV11,ADC8(`DUT_ANA.compm_mux.v_ana_in[11*16+:16]));

	`I2CMST.bkwr (`DACV1,8,{{7{8'hac}},8'hc1}); // not support inter-channel semi-SAR
	`I2CMST.bkwr (`DACV2,8,{{7{8'hac}},8'hc1});
	`I2CMST.bkwr (`DACV3,8,{{7{8'hac}},8'hc1});
	`I2CMST.sfrw (`I2CCTL,'h19); // inc, BANK12
	`I2CMST.sfrw (`DACCTL,'h00); // 8-bit
	`I2CMST.bkrd (`DACV1,3,{ADC8(`DUT_ANA.compm_mux.v_ana_in[3*16+:16]),
				ADC8(`DUT_ANA.compm_mux.v_ana_in[2*16+:16]),
				ADC8(`DUT_ANA.compm_mux.v_ana_in[1*16+:16])});

	release `DUT_ANA.compm_mux.v_ana_in[1*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[2*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[3*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[11*16+:16];
end
endtask // basic_semi_scan

task basic_sar10_scan;
reg [15:0] ii;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.bkwr (`DACEN,3,{8'h74,8'hff,8'h80}); // in inc, LSB for ch7, DAC1_EN
	for (ii=0;ii<2050;ii=ii+1) begin
	   force `DUT_ANA.compm_mux.v_ana_in[7*16+:16] = ii;
	   `I2CMST.sfrw (`DACCTL,'h41); // 10-bit mode
	   wait (`DUT_CORE.u0_dacmux.busy==1'h1)
	   wait (`DUT_CORE.u0_dacmux.busy==1'h0)
	   `I2CMST.sfrr (`DACV7,ADC10(ii)>>2);
	   `I2CMST.sfrr (`DACLSB,ADC10(ii)&'h3|'h74); // check LSB
	end
	#(1000) release `DUT_ANA.compm_mux.v_ana_in[7*16+:16];
end
endtask // basic_sar10_scan

task basic_sar8_scan;
reg [15:0] ii;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.bkwr (`DACEN,3,{8'h04,8'hff,8'hff}); // in inc, all ADC channels, DAC1_EN
	for (ii=0;ii<2100;ii=ii+8) begin
	   force `DUT_ANA.compm_mux.v_ana_in[0*16+:16] = ii +  0;
	   force `DUT_ANA.compm_mux.v_ana_in[1*16+:16] = ii +  1;
	   force `DUT_ANA.compm_mux.v_ana_in[2*16+:16] = ii +  2;
	   force `DUT_ANA.compm_mux.v_ana_in[3*16+:16] = ii +  3;
	   force `DUT_ANA.compm_mux.v_ana_in[4*16+:16] = ii +  4;
	   force `DUT_ANA.compm_mux.v_ana_in[5*16+:16] = ii +  5;
	   force `DUT_ANA.compm_mux.v_ana_in[6*16+:16] = ii +  6;
	   force `DUT_ANA.compm_mux.v_ana_in[7*16+:16] = ii +  7;
	   `I2CMST.sfrw (`DACCTL,'h01); // 8-bit mode
	   wait (`DUT_CORE.u0_dacmux.busy==1'h1)
	   wait (`DUT_CORE.u0_dacmux.busy==1'h0)
	   `I2CMST.bkrd (`DACV0,8,{
			ADC8 ( ii +  7 ),
			ADC8 ( ii +  6 ),
			ADC8 ( ii +  5 ),
			ADC8 ( ii +  4 ),
			ADC8 ( ii +  3 ),
			ADC8 ( ii +  2 ),
			ADC8 ( ii +  1 ),
			ADC8 ( ii +  0 )});
	   #(1000*100) release_all;
	end
end
endtask // basic_sar8_scan

task random_sar8_scan;
input [17:0] sel; // enable channels
reg [7:0] dacv07,dacv06,dacv05,dacv04,dacv03,dacv02,dacv01,dacv00,
          dacv15,dacv14,dacv13,dacv12,dacv11,dacv10,dacv09,dacv08,
                                                    dacv17,dacv16;
reg switch;
begin
	switch = $random;
	$display ($time,"ns <%m> starts.....%04X,%x",sel,switch);
	{dacv03,dacv02,dacv01,dacv00} = $random;
	{dacv07,dacv06,dacv05,dacv04} = $random;
	{dacv11,dacv10,dacv09,dacv08} = $random;
	{dacv15,dacv14,dacv13,dacv12} = $random;
	              {dacv17,dacv16} = $random;
	`I2CMST.sfrw (`CMPOPT,{switch,7'h0}); // switch
	`I2CMST.bkwr (`DACEN,2,{8'hff,sel[7:0]});
	`I2CMST.bkwr (`DACV0,8,{dacv07,dacv06,dacv05,dacv04,dacv03,dacv02,dacv01,dacv00});
	`I2CMST.bkwr (`X0_DACEN2,2,{8'hff,sel[15:8]});
	`I2CMST.bkwr (`X0_DACV8, 8,{dacv15,dacv14,dacv13,dacv12,dacv11,dacv10,dacv09,dacv08});
	`I2CMST.bkwr (`X0_DACEN3,2,{8'hff,sel[17:16]});
	`I2CMST.bkwr (`X0_DACV16,8,{dacv17,dacv16});
	force `DUT_ANA.v_VIN  = {$random}%20480;
	force `DUT_ANA.v_VO   = {$random}%20480;
	force `DUT_ANA.v_IFB  = {$random}%2048;
	force `DUT_ANA.v_RT   = {$random}%2048;
	force `DUT_ANA.v_DP   = {$random}%2048;
	force `DUT_ANA.v_DN   = {$random}%2048;
	force `DUT_ANA.v_CC1  = {$random}%4096;
	force `DUT_ANA.v_CC2  = {$random}%4096;
	force `DUT_ANA.v_GP5  = {$random}%2048;
	force `DUT_ANA.v_GP4  = {$random}%2048;
	force `DUT_ANA.v_GP3  = {$random}%2048;
	force `DUT_ANA.v_GP2  = {$random}%2048;
	force `DUT_ANA.v_GP1  = {$random}%2048;
	`I2CMST.sfrw (`DACCTL,'h01); // 8-bit mode
	if (sel[7:0]==0)
	`I2CMST.sfrr (`DACCTL,'h00); // not started
	else
	wait (`DUT_CORE.u0_dacmux.busy==1'h1)
	wait (`DUT_CORE.u0_dacmux.busy==1'h0);
	if (switch)
	`I2CMST.sfrw (`CMPOPT,{1'h0,7'h0}); // clear switch
	`I2CMST.bkrd (`DACV0,8,{
			sel[ 7] ? ADC8(`DUT_ANA.v_CC2/2)   : dacv07,
			sel[ 6] ? ADC8(`DUT_ANA.v_CC1/2)   : dacv06,
			sel[ 5] ? ADC8(switch
					?`DUT_ANA.v_DN/3
					:`DUT_ANA.v_DN)    : dacv05,
			sel[ 4] ? ADC8(switch
					?`DUT_ANA.v_DP/3
					:`DUT_ANA.v_DP)    : dacv04,
			sel[ 3] ? ADC8(`DUT_ANA.v_RT)      : dacv03,
			sel[ 2] ? ADC8(`DUT_ANA.v_IFB)     : dacv02,
			sel[ 1] ? ADC8(`DUT_ANA.v_VO/10)   : dacv01,
			sel[ 0] ? ADC8(switch
					?`DUT_ANA.v_VO/20
					:`DUT_ANA.v_VIN/20): dacv00});
	`I2CMST.bkrd (`X0_DACV8,8,{
			sel[15] ? ADC8(`DUT_ANA.v_GP3)     : dacv15,
			sel[14] ? ADC8(`DUT_ANA.v_GP4)     : dacv14,
			sel[13] ? ADC8(`DUT_ANA.v_GP5)     : dacv13,
			sel[12] ? ADC8(`DUT_ANA.v_CC2/4)   : dacv12,
			sel[11] ? ADC8(`DUT_ANA.v_CC1/4)   : dacv11,
			sel[10] ? ADC8(`DUT_ANA.v_VO/20)   : dacv10,
			sel[ 9] ? ADC8(`DUT_ANA.v_DN/3)    : dacv09,
			sel[ 8] ? ADC8(`DUT_ANA.v_DP/3)    : dacv08});
	`I2CMST.bkrd (`X0_DACV16,2,{
			sel[17] ? ADC8(`DUT_ANA.v_GP1)     : dacv17,
			sel[16] ? ADC8(`DUT_ANA.v_GP2)     : dacv16});
	#(1000*100) release_all;
end
endtask // random_sar8_scan

function [9:0] ADC10; // voltage to 10-bit ADC
input [15:0] exp; // mV
	ADC10 = (exp>=2045) ? 1023 : (exp+1)/2;
endfunction // ADC10

function [7:0] ADC8; // voltage to 8-bit ADC
input [15:0] exp; // mV
	ADC8 = (exp>=2039) ? 255 : (exp+1)/8;
endfunction // ADC8

initial #100 begin: ChkExpectedADC
reg [15:0] ii;
	$display ($time,"ns <%m> check function ADC8==ADC10...");
	for (ii=0;ii<2100;ii=ii+1)
	   if (ADC8(ii)!=ADC10(ii)>>2)
	      $display ($time,"ns <%m> ADC8!=ADC10 @%0d",ii);
end // ChkExpectedADC

task release_all;
begin
	release `DUT_ANA.compm_mux.v_ana_in[0*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[1*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[2*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[3*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[4*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[5*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[6*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[7*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[8*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[9*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[10*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[11*16+:16];
	release `DUT_ANA.compm_mux.v_ana_in[12*16+:16];
	release `DUT_ANA.v_VIN;
	release `DUT_ANA.v_VO;
	release `DUT_ANA.v_IFB;
	release `DUT_ANA.v_RT;
	release `DUT_ANA.v_DP;
	release `DUT_ANA.v_DN;
	release `DUT_ANA.v_CC1;
	release `DUT_ANA.v_CC2;
end
endtask // release_all

endmodule // stm_dacmux

