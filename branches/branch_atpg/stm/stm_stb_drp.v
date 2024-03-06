
`timescale 1ns/1ns
module stm_stb_drp;
// stand-by mode
// DRP toggle
// IMP toggle
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*50);

initial begin
//#1	`HW.init_dut_fw;
#1	`HW.load_dut_fw ("../fw/iram/iram.1.memh");
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (3); // 1MHz
	#200_000
	$display ($time,"ns <%m> starts.....");

//	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, PG0=BNK12 (REGX)
//	`I2CMST.sfrw (`X0_XANA2,'h80); // LFOSC_EN
	fork
	DNCHK_EN.KEEP (0,5);
	STB_RP.KEEP (0,5);
	RD_ENB.KEEP (0,5);
	join
	
	`I2CMST.sfrw (`X0_AOPT,'h08); DNCHK_EN.VAL(1); // AOPT[3]: DNCHK_EN
	`I2CMST.sfrw (`X0_AOPT,'h00); DNCHK_EN.VAL(0);
	`I2CMST.sfrw (`X0_XANA2,'h0c); STB_RP.VAL(1); RD_ENB.VAL(1);
	`I2CMST.sfrw (`X0_XANA2,'h04); STB_RP.VAL(0); RD_ENB.VAL(1);
	`I2CMST.sfrw (`X0_XANA2,'h08); STB_RP.VAL(1); RD_ENB.VAL(0);
	`I2CMST.sfrw (`X0_XANA2,'h00); STB_RP.VAL(0); RD_ENB.VAL(0);

	`I2CMST.sfrw (`X0_XANA2,'h50); // set r_drp/imp_osc
	fork
	begin DNCHK_EN.WAIT (1,11); DNCHK_EN.WAIT (0,11); end
	repeat (3) begin
	      DRP_OSC.WAIT(1,6); #3 STB_RP.VAL(1); RD_ENB.VAL(1);
	      DRP_OSC.WAIT(0,6); #3 STB_RP.VAL(0); RD_ENB.VAL(0); end
	join
	
	#100_000 hw_complete;
end

task wkup_low_standby; // wake-up OSC_LOW as well
begin
	$display ($time,"ns <%m> starts.....");
end
endtask // wkup_low_standby

DNCHK_EN DNCHK_EN();
STB_RP   STB_RP();
RD_ENB   RD_ENB();
DRP_OSC  DRP_OSC();

endmodule // stm_stb_drp

`define PBNAME DNCHK_EN
`define PBANA (`DUT_ANA.`PBNAME)
`include "inc_probe.v"

`define PBNAME STB_RP
`define PBANA (`DUT_ANA.`PBNAME)
`include "inc_probe.v"

`define PBNAME RD_ENB
`define PBANA (`DUT_ANA.`PBNAME)
`include "inc_probe.v"

`define PBNAME DRP_OSC
`define PBANA (`DUT_ANA.`PBNAME)
`include "inc_probe.v"

