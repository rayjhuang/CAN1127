
module stm_i2cpre; // test i2c read idata prefetch function
// test HWI2C basic functions
// test HWI2C OTP-access functions
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*200);
initial #10_000 begin
	force `HW.pulse_width_probe = `DUT_CORE.u0_mpb.pg0_rdwait;
	`HW.pulse_width_analy;
end
reg [7:0] sav0, sav1;
initial begin
#100	`HW.load_dut_fw ("../fw/i2cpre/i2cpre.2.memh"); // access 180h: data00[0], 85h: data01[5]
        `I2CMST.init (1); // 400KHz, OTP read in 1MHz won't work
	`I2CMST.dev_addr = 'h70; // to DUT
#150_000 // add RSTB_5 to RSTB delay
#100    $display ($time,"ns <%m> starts");
        `I2CMST.sfrw (`I2CCTL,'h17); repeat (100) TestXdata_0; // PG0=BANK11 (IDATA), inc
        `I2CMST.sfrw (`I2CCTL,'h05); repeat (100) TestXdata_0; // PG0=BANK2 (XDATA), inc

	wait (`DUT_MCU.u_ports.port0==='hec)
	wait (`DUT_MCU.u_ports.port0==='hef) // check FW status
	disable `HW.pulse_width_analy.counting;
	#100_000 hw_complete;
end

task TestXdata_0; // should be in inc-mode I2C
reg [6:0] start,cnt;
reg [7:0] idx,dat;
reg [8:0] ptr;
reg [8*512-1:0] exp;
begin	->ev;
	start = {$random}%128; // in PG0
	cnt = {$random}%8+1;
	if (start+cnt>'d128) cnt = 'd128-start;
	exp = {2{$random}} & ~({8{8'hff}}<<(cnt*8));
	$display ($time,"ns <%m> start:0x%x, cnt:%0d, exp:%0x",start,cnt,exp);
	`I2CMST.bkwr (start,cnt,exp);
	`I2CMST.bkrd (start,cnt,exp);
end
endtask // TestXdata_0

endmodule // stm_i2cpre

