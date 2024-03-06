
module stm_sram;
// test SRAM by HWI2C (CP/FT)
// normal PG0 access by I2C
// special PG0 access by I2C
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*200);

parameter XMEM_SIZE = 1536-256; // bytes
parameter IMEM_SIZE = 256; // bytes
parameter NUM_BANK = 12; // round_up (XMEM_SIZE+IMEM_SIZE)/128
reg [(XMEM_SIZE+IMEM_SIZE)*8-1:0] sram_mem;

integer idx;
initial begin
#100	`HW.set_code('h40,'h80);
	`HW.set_code('h41,'hbe); // SJMP -'h42 @PC=0x0
	for (idx=0;idx<'h40;idx=idx+1) `HW.set_code(idx,'he4); // CLR A
	for (idx=0;idx<XMEM_SIZE+IMEM_SIZE;idx=idx+1) sram_mem[idx*8+:8] = $random;
	#4_900
	`I2CMST.init (1); // 400KHz, OTP read in 1MHz won't work
	`I2CMST.dev_addr = 'h70; // to DUT
	#100_000 $display ($time,"ns <%m> starts");
	#100_000 pg0_write_all;
	#100_000 pg0_write_protect;
	#100_000 pg0_write_random (100);
	#100_000 pg0_read_check;
	#100_000 hw_complete;
end

task pg0_write_protect;
begin
	// normal
	`I2CMST.sfrw (`GPF,'haa);
	`I2CMST.sfrr (`GPF,'haa);

	// PG0 write-protected
	`I2CMST.sfrw (`I2CCTL,'h21 | 'd3<<1); // ATTR, BANK3, INC
	`I2CMST.sfrw ({$random}%128,$random);

	// both PG0/SFR write-protected, PG0=BANK1
	`I2CMST.sfrw (`I2CCTL,'h21 | 'd13<<1); // ATTR, BANK13, INC
	`I2CMST.bkrd (5,4,sram_mem[(128+5)*8+:32]); // BANK13: PG0=BANK1

	// SFR write-protected
	`I2CMST.sfrw (`GPF,'h55);
	`I2CMST.sfrr (`GPF,'haa);

	// recover the write protection
	wait (`DUT_MCU.pc_o=='h10) // to clear the write-protect bit
	`HW.set_code(0,'h75); `HW.set_code(1,`I2CCTL); `HW.set_code(2,0); // MOV direct, #immed
	wait (`DUT_MCU.pc_o=='h00) // loop
	wait (`DUT_MCU.pc_o=='h10) // not to update I2CCTL any more
	`HW.set_code(0,'he4); `HW.set_code(1,'he4); `HW.set_code(2,'he4); // MOV direct, #immed

	mem_check;
end
endtask // pg0_write_protect

task mem_check;
reg [7:0] expected, physical;
integer ii, err;
begin
	err = 0;
	for (ii=0;ii<XMEM_SIZE+IMEM_SIZE;ii=ii+1) begin
	   expected = sram_mem>>ii*8;
	   physical = (ii>=XMEM_SIZE) ? `DUT_IDAT(ii-XMEM_SIZE) : `DUT_XDAT(ii);
	   if (expected!==physical) begin
	      $display ($time,"ns <%m> ERROR: data %0d mismatch, adr:%03x exp:%02x dat:%02x",
	                err, ii,expected,physical);
	      err = err + 1;
	   end
	end
	$display ($time,"ns <%m> %0d data checked, %0d error found", XMEM_SIZE+IMEM_SIZE, err);
	if (err) `HW_FIN (($time,"ns <%m> ERROR: %0d data mismatch",err))
end
endtask // mem_check

task pg0_read_check;
reg [3:0] bank;
begin
	for (bank=0; bank<NUM_BANK; bank=bank+1) begin
	   $display ($time, "ns <%m> bank: %0d", bank);
	   `I2CMST.sfrw (`I2CCTL,'h1 | (bank<<1)); // set PG0, INC=1
	   `I2CMST.bkrd (0,128,sram_mem>>(bank*128*8));
	end
	mem_check;
end
endtask // pg0_read_check

task pg0_write_all;
reg [3:0] bank;
begin
	for (bank=0; bank<NUM_BANK; bank=bank+1) begin
	   $display ($time, "ns <%m> bank: %0d", bank);
	   `I2CMST.sfrw (`I2CCTL,'h1 | (bank<<1)); // set PG0, INC=1
	   `I2CMST.bkwr (0,128,sram_mem>>(bank*128*8));
	end
	mem_check;
end
endtask // pg0_write_all

task pg0_write_random;
input [31:0] num; // time(s) to repeat
reg [3:0] bnk0, bnk1;
reg [9:0] adr, siz;
reg [128*8-1:0] mem;
begin
	`I2CMST.sfrw (`I2CCTL,'h1); // PG0=BANK0, INC=1
	bnk0 = 0;
	repeat (num) begin
	   adr = {$random} % (XMEM_SIZE+IMEM_SIZE);
	   siz = {$random} % (128-adr%128) + 1; // [1,128], don't exceed PG0 (SFR)
	   bnk1 = adr/128; // new bank

	   for (idx=0;idx<siz;idx=idx+1) begin
	      mem[idx*8+:8] = $random;
	      sram_mem[(adr+idx)*8+:8] = mem[idx*8+:8];
	   end

	   $display ($time, "ns <%m> adr: 0x%03x, size: %0d", adr, siz);
	   if (bnk0!=bnk1) begin
	      `I2CMST.sfrw (`I2CCTL,'h1 | (bnk1<<1)); // set PG0, INC=1
	      bnk0 = bnk1;
	   end
	   `I2CMST.bkwr (adr%128,siz,mem);
	end
	mem_check;
end
endtask // pg0_write_random

wire [7:0]
	dbg_mem_000 = sram_mem['h000*8+:8],
	dbg_mem_001 = sram_mem['h001*8+:8],
	dbg_mem_002 = sram_mem['h002*8+:8],
	dbg_mem_003 = sram_mem['h003*8+:8],
	dbg_mem_100 = sram_mem['h100*8+:8],
	dbg_mem_101 = sram_mem['h101*8+:8],
	dbg_mem_102 = sram_mem['h102*8+:8],
	dbg_mem_103 = sram_mem['h103*8+:8];

endmodule // stm_sram

