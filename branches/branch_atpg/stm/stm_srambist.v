
`timescale 1ns/1ns
module stm_srambist;
// MBIST
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_srambist);
initial timeout_task (1000*20);
parameter MEM_SIZE = 1536; // bytes
initial begin
#100	`HW.init_dut_fw;
#4_900	`I2CMST.init (1); // 400KHz, OTP read in 1MHz won't work
        `I2CMST.dev_addr = 'h70; // to DUT
#500_000
`define T_BIST_RW  (MEM_SIZE*6*1000/12-2*9*1000*1000/400) // ns
`define T_BIST_RWR (MEM_SIZE*9*1000/12-2*9*1000*1000/400) // ns
	$display ($time,"ns <%m> starts.....%0d,%0dus",`T_BIST_RW/1000,`T_BIST_RWR/1000);
		#100_000
		`I2CMST.sfrr (`REVID,{1'h1,`HW.REV_ID}); // CC is high
		`I2CMST.sfrw (`I2CCTL,'h14); // PG0=BANK10 for HWI2C-IRAM access
		`I2CMST.sfrw ('h10,'h5a);    // write xram/iram, make mistake
		`I2CMST.sfrw (`I2CCTL,'h18); // PG0=BANK12 for HWI2C-XREG access
// MATS++
// Inter word
		`I2CMST.sfrw (`X0_BISTDAT,'h80); `I2CMST.sfrw (`X0_BISTCTL,'h01); // ↑(r0000,w0000)
#`T_BIST_RW	`I2CMST.sfrr (`X0_BISTCTL,'h08); // reset/check BIST_FAIL
		`I2CMST.sfrw (`X0_BISTDAT,'ha0); `I2CMST.sfrw (`X0_BISTCTL,'h01); // ↑(r0000,w1111)
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'h90); `I2CMST.sfrw (`X0_BISTCTL,'h07); // ↓(r1111,w0000,r0000)

// Intra word 1
#`T_BIST_RWR	`I2CMST.sfrw (`X0_BISTDAT,'h84); `I2CMST.sfrw (`X0_BISTCTL,'h01); // ↑(r0000,w0101)
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'ha5); `I2CMST.sfrw (`X0_BISTCTL,'h01); // ↑(r0101,w1010)
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'h95); `I2CMST.sfrw (`X0_BISTCTL,'h07); // ↓(r1010,w0101,r0101)

// Intra word 2
#`T_BIST_RWR	`I2CMST.sfrw (`X0_BISTDAT,'h89); `I2CMST.sfrw (`X0_BISTCTL,'h01); // bg: 00110011
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'haa); `I2CMST.sfrw (`X0_BISTCTL,'h01);
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'h9a); `I2CMST.sfrw (`X0_BISTCTL,'h07);

// Intra word 3
#`T_BIST_RWR	`I2CMST.sfrw (`X0_BISTDAT,'h8e); `I2CMST.sfrw (`X0_BISTCTL,'h01); // bg: 00001111
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'haf); `I2CMST.sfrw (`X0_BISTCTL,'h01);
#`T_BIST_RW	`I2CMST.sfrw (`X0_BISTDAT,'h9f); `I2CMST.sfrw (`X0_BISTCTL,'h07);

// check result
#`T_BIST_RWR	`I2CMST.sfrr (`X0_BISTCTL,'hX0|'b0xxx); // check BIST_FAIL

#100 // to diagnose a SAF
		`I2CMST.sfrw (`I2CCTL,'h14); // PG0=BANK10 for HWI2C-IRAM access
		`I2CMST.sfrw ('h10,'h0);     // write xram/iram, make mistake
		`I2CMST.sfrw (`I2CCTL,'h18); // PG0=BANK12 for HWI2C-XREG access
                `I2CMST.sfrw (`X0_BISTCTL,'h01);
#`T_BIST_RW	`I2CMST.sfrr (`X0_BISTCTL,'h08);

#10_000	hw_complete;
end

endmodule

