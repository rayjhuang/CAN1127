
`timescale 1ns/1ns
module stm_bkpt;
`include "stm_task.v"
initial timeout_task (500*100);
initial #1 $fsdbDumpvars (stm_bkpt);
reg [15:0] idx;
initial begin
#100	`HW.load_dut_fw ("../fw/gpio/gpio.2.memh");
#49900	$display ($time,"ns <%m> starts.....");
	`I2CMST.dev_addr = 'h70; // to DUT
	`I2CMST.init (2); // 1 MHz
`define ALL_GPIO {`DUT.GPIO5,`DUT.GPIO4,`DUT.GPIO3,`DUT.GPIO2,`DUT.GPIO1,`DUT.SDA,`DUT.SCL}
	for (idx=0; idx<'h80; idx=idx+1) // GPIO output about @100us
	   wait (`ALL_GPIO===idx[7:0]) ->ev;
	wait (`ALL_GPIO===8'h6f) ->ev;
	wait (`ALL_GPIO===8'h7e) ->ev;
	wait (`ALL_GPIO===8'h7f) ->ev;
	$display ($time,"ns <%m> NOTE: GPO completed.");

	wait (`ALL_GPIO==0)
	for (idx=0; idx<4; idx=idx+1) // GPIO PU/PD (only 4-GPIO in the FW)
	   wait (`ALL_GPIO===('h1<<idx)) ->ev;
	$display ($time,"ns <%m> NOTE: GPIO PU/PD completed.");

#(1000*100)
//	`I2CMST.sfrw (`I2CCTL,'h15); // PG0 to IDATA, all-writable, inc
//	`I2CMST.sfrw (`I2CCTL,'h19); // PG0 to REGX, inc

	try_bkpt ('h00ce,'he1,'h01); // 0x0105:7910 MOV R1,0x10
	try_bkpt ('h00ce,'h01,'h02); // 0x0105:7910 MOV R1,0x10
	try_bkpt ('h00cf,'h02,'h03); // 0x0105:7910 MOV R1,0x10

	try_bkpt ('h00d0,'h03,'h04); // 0x0107:E7   MOV A,@R1

	try_bkpt ('h00d3,'h04,'h05); // 0x010a:F580 MOV P0,A
	try_bkpt ('h00d4,'h05,'h06); // 0x010a:F580 MOV P0,A (done)

	try_bkpt ('h00cb,'h06,'h13); // 0x0102:B40409 CJNE A,#0x04,+9
	try_bkpt ('h00c9,'h13,'h15); // 0x0100:60FB JZ -5
	try_bkpt ('h00c8,'h15,'h16); // 0x00ff:E6   MOV A,@R0
	try_bkpt ('h00c6,'h16,'h18); // 0x00fd:7812 MOV R0,0x12

	`I2CMST.sfrw (`I2CCTL,'h19); // PG0 to BANK12(REGX), inc
	`I2CMST.sfrw (`X0_BKPCH,'h00); // disable break point
	`I2CMST.sfrw (`MISC,'h00); // run
        `I2CMST.sfrw (`I2CCTL,'h15); // PG0 to BANK10(IDATA), inc
	`I2CMST.bkwr ('h10,3,'h04_e00d); // cnt_gpi1, cnt_gpi2, PG0_CMD(4): P0=cnt_gpi1+cnt_gpi2
	// (0xed: FW complete)
end

task try_bkpt;
input [13:0] pc;
input [7:0] chk0; // chk0 before run
input [7:0] chk1; // chk1 to 0x10
begin
	$display ($time,"ns <%m> bkpt@pc:0x%0x", pc);
	`I2CMST.sfrw (`MISC,'h00); // run
	`I2CMST.sfrw (`MISC,'h08); // hold, set breakpoint under held
	#100_000 @(posedge `DUT_CCLK)
	if (`DUT_MCU.port0o!==chk0) begin
	   $display ($time,"ns <%m> ERROR: unexpected P0:%0x, exp:%0x", `DUT_MCU.port0o, chk0);
	   $finish;
	end
	`I2CMST.sfrw (`I2CCTL,'h19); // PG0 to BANK12(REGX), inc
	`I2CMST.bkwr (`X0_BKPCL,2,{16'h8000|pc});
        `I2CMST.sfrw (`I2CCTL,'h15); // PG0 to BANK10(IDATA), inc
	`I2CMST.bkwr ('h10,3,{8'h04,8'h0,chk1}); // PG0_CMD(4): P0=cnt_gpi1+cnt_gpi2
	`I2CMST.sfrw (`MISC,'h00); // run
	 wait(`DUT_CORE.u0_regbank.r_hold_mcu==1'h1);
end
endtask // try_bkpt

endmodule // stm_bkpt

