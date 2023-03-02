
`timescale 1ns/1ns
module stm_debnc;
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_debnc);
initial timeout_task (1000*200);
initial begin
#1	`HW.init_dut_fw;
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (3);
	$display ($time,"ns <%m> starts.....");
	wait (`DUT_CORE.i_rstz)

	#3000 TxDebnc (0); // test negative pulse
	#3000 TxDebnc (1); // test positive pulse, return to '0'

	`I2CMST.sfrw (`I2CCTL,'h19); // inc, PG0=BNK12 (REGX)
	`I2CMST.sfrw (`LDBPRO,'h10); // 30us OVP
	#3000 TxDebncOvp (0,1);
	#3000 TxDebncOvp (1,1);
	#3000 TxDebncScp (0,0);
	#3000 TxDebncScp (1,0);

	`I2CMST.sfrw (`LDBPRO,'h20); // 3us SCP
	#3000 TxDebncOvp (0,0);
	#3000 TxDebncOvp (1,0);
	#3000 TxDebncScp (0,1);
	#3000 TxDebncScp (1,1);

	#3000 TxLdbOcp (0);

	#100_000 hw_complete;
end

integer debnc, multi;
wire [31:0] latency = (debnc+2) * multi * (1000/12+1); // one additinal clock for sync., roundup
wire [31:0] glitch = (debnc-1) * multi * (1000/12); // for clock is a little varient from 12MHz, roundown
wire [31:0] space = debnc * multi * 100;

task TxDebncScp;
input	val, // 0/1: negative/positive pulse
	dbc; // 0/1: short/3us
begin
	$display ($time,"ns <%m> starts.....%d,%d",val,dbc);
	debnc=(dbc?6:3); multi=(dbc?8:1);
        #3000 `DUT_ANA.r_scp = ~val;
        #latency fork
        SCP.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_scp = val; #glitch `DUT_ANA.r_scp = ~val; #space; end disable SCP.KEEP; end
	join
end
endtask // TxDebncScp

task TxDebncOvp;
input	val, // 0/1: negative/positive pulse
	dbc; // 0/1: short/30us
begin
	$display ($time,"ns <%m> starts.....%d,%d",val,dbc);
	debnc=(dbc?16:3); multi=(dbc?24:1);
        #3000 `DUT_ANA.r_ovp = ~val;
        #latency fork
	OVP.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_ovp = val; #glitch `DUT_ANA.r_ovp = ~val; #space; end disable OVP.KEEP; end
	join

	debnc=16; multi=24;
        #3000 `DUT_ANA.r_DpDnCC_ovp = ~val;
        #latency fork
        CDOVP.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_DpDnCC_ovp = val; #glitch `DUT_ANA.r_DpDnCC_ovp = ~val; #space; end disable CDOVP.KEEP; end
        join
end
endtask // TxDebncOvp

task TxDebnc;
input val; // 0/1: negative/positive pulse
begin
	$display ($time,"ns <%m> starts.....%d",val);
	debnc=6; multi=8;
        #3000 `DUT_ANA.r_ocp = ~val;
        #latency fork
	OCP.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_ocp = val; #glitch `DUT_ANA.r_ocp = ~val; #space; end disable OCP.KEEP; end
        join

        #3000 `DUT_ANA.r_uvp = ~val;
        #latency fork
        UVP.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_uvp = val; #glitch `DUT_ANA.r_uvp = ~val; #space; end disable UVP.KEEP; end
        join

        TxDebncScp (val,0);
        TxDebncOvp (val,0);

	debnc=6; multi=8;
        #3000 `DUT_ANA.r_cf = ~val;
        #latency fork
        OTPI_CF.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_cf = val; #glitch `DUT_ANA.r_cf = ~val; #space; end disable OTPI_CF.KEEP; end
        join

	debnc=6; multi=8;
        #3000 `DUT_ANA.r_dn_fault = ~val;
        #latency fork
        DN_FAULT.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_dn_fault = val; #glitch `DUT_ANA.r_dn_fault = ~val; #space; end disable DN_FAULT.KEEP; end
        join

	debnc=3; multi=1;
        #3000 `DUT_ANA.r_v5ocp = ~val;
        #latency fork
        V5OCP.KEEP (~val,1);
        begin repeat (10) begin `DUT_ANA.r_v5ocp = val; #glitch `DUT_ANA.r_v5ocp = ~val; #space; end disable V5OCP.KEEP; end
        join
end
endtask // TxDebnc

task TxLdbOcp;
input val;
begin
	$display ($time,"ns <%m> starts.....%d",val);
	debnc=14; multi=24000;
        #3000 `DUT_ANA.r_ocp = ~val;
        #latency fork
	LDBOCP.KEEP (~val,1);
        begin repeat (2) begin `DUT_ANA.r_ocp = val; #glitch `DUT_ANA.r_ocp = ~val; #space; end disable LDBOCP.KEEP; end
        join
end
endtask // TxLdbOcp

task TxLdbUvp;
input val;
begin
	$display ($time,"ns <%m> starts.....%d",val);
	debnc=14; multi=24000;
        #3000 `DUT_ANA.r_uvp = ~val;
        #latency fork
	LDBUVP.KEEP (~val,1);
        begin repeat (2) begin `DUT_ANA.r_uvp = val; #glitch `DUT_ANA.r_uvp = ~val; #space; end disable LDBUVP.KEEP; end
        join
end
endtask // TxLdbUvp

UVP UVP ();
OCP OCP ();
OVP OVP ();
OTPI_CF OTPI_CF ();
SCP SCP ();
V5OCP V5OCP ();
CDOVP CDOVP ();
DN_FAULT DN_FAULT ();

LDBUVP LDBUVP ();
LDBOCP LDBOCP ();

endmodule // stm_debnc

`define PBNAME UVP
`define PBSIG (`DUT_CORE.u0_regbank.regAD[0])
`include "inc_probe.v"
`define PBNAME OCP
`define PBSIG (`DUT_CORE.u0_regbank.regAD[1])
`include "inc_probe.v"
`define PBNAME OVP
`define PBSIG (`DUT_CORE.u0_regbank.regAD[2])
`include "inc_probe.v"
`define PBNAME OTPI_CF
`define PBSIG (`DUT_CORE.u0_regbank.regAD[3])
`include "inc_probe.v"
`define PBNAME SCP
`define PBSIG (`DUT_CORE.u0_regbank.regAD[4])
`include "inc_probe.v"
`define PBNAME V5OCP
`define PBSIG (`DUT_CORE.u0_regbank.regAD[5])
`include "inc_probe.v"
`define PBNAME CDOVP
`define PBSIG (`DUT_CORE.u0_regbank.regAD[6])
`include "inc_probe.v"
`define PBNAME DN_FAULT
`define PBSIG (`DUT_CORE.u0_regbank.regAD[7])
`include "inc_probe.v"

`define PBNAME LDBUVP
`define PBSIG (`DUT_CORE.u0_regbank.reg94[0])
`include "inc_probe.v"
`define PBNAME LDBOCP
`define PBSIG (`DUT_CORE.u0_regbank.reg94[1])
`include "inc_probe.v"

