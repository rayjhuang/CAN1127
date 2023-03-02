
`timescale 1ns/1ns
module stm_i2c_otp;
// OTP CP test by I2C
`include "stm_task.v"
initial timeout_task (1000*100);
parameter PROG_RATE = 9100; // I2C bit-rate (9us is too tight)
reg [15:0] idx;
reg [256*8-1:0] w_buf;
initial begin
#1	`HW.init_dut_fw; // ATO0004KX8VI150BG33NA already done this
	`I2CMST.init (960); // sync. to main clock for CP/FT

	$display ($time,"ns <%m> starts.....");
	`HW.set_code (0,'hfe); // not to hold MCU

	`HW.set_code ((`HW.OTP_SIZE/1024)*1024+60,'h80); // SJMP +0x02 @PC=0x403c, cache upto ?
	`HW.set_code ((`HW.OTP_SIZE/1024)*1024+61,'h02); // to prevent from fetching from ATTOP's OTP-rsvd area

	`HW.set_code (`HW.OTP_SIZE-4,'h80); // SJMP -0x70 @PC=0x3010, cache upto 0x3050+24?
	`HW.set_code (`HW.OTP_SIZE-3,'h90); // to prevent from cached
	repeat (5)
	   wait (`DUT_MCU.pc_o==`HW.OTP_SIZE-11) // check MCU do this jump back
	   wait (`DUT_MCU.pc_o==`HW.OTP_SIZE-10);

	`HW.set_code (`HW.OTP_SIZE-4,'h80); // SJMP +0x02 to prevent ATTOP's OTP-rsvd area
	`HW.set_code (`HW.OTP_SIZE-3,'h02);
	wait (`DUT_MCU.pc_o==`HW.OTP_SIZE+100); // check PC can exceed OTP_SIZE

	           `DUT_ANA.r_rstz = 0;
	#(1000*10) `DUT_ANA.r_rstz = 1;
	`HW.set_code ('h0400,'h80); // SJMP -2 @PC=0x0400
	`HW.set_code ('h0401,'hfe);
//	`HW.set_hw_chksum;
//#500_000 // HW checksum lantency
#3000	$display ($time,"ns, <%m> test OTP address counter.....");
////////////////////////////////////////////////////////////////////////////////
	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, BANK12
	`I2CMST.sfrw (`DEC,'h80); // ACK for OTP access
	`I2CMST.sfrw (`OFS,'h00); `I2CMST.bkrd (`NVMIO,10,{10{8'hee}}); // read OTP @r_hold_mcu=0
	`I2CMST.sfrr (`OFS,'h00);

	`I2CMST.sfrw (`MISC,'h08); // set r_hold_mcu
	`I2CMST.sfrw (`OFS,'h00); `I2CMST.bkrd (`NVMIO,10,{{9{8'hff}},8'hfe}); // read OTP @r_hold_mcu=1
	`I2CMST.sfrr (`OFS,'h0a);

	idx = `HW.OTP_SIZE-2;
	`I2CMST.sfrw (`DEC,'h80|idx[15:8]);
	`I2CMST.sfrw (`OFS,idx);  `I2CMST.bkrd (`NVMIO,10,{{8{8'hee}},{2{8'hff}}}); // read OTP @r_hold_mcu=1
	`I2CMST.sfrr (`OFS,idx+10); // the counter counts 10 times
	                          `I2CMST.bkrd (`NVMIO,5,{{5{8'hee}}});
	`I2CMST.sfrr (`OFS,idx+15); // the counter counts 5 times

	`I2CMST.sfrw (`DEC,'h80); // recover
	`I2CMST.sfrw (`OFS,'h0a);
////////////////////////////////////////////////////////////////////////////////

	$display ($time,"ns, <%m> program OTP @VPP_EN=0.....");
	`I2CMST.init (PROG_RATE); // sync. to main clock for CP/FT
	`I2CMST.bkwr (`NVMIO,10,{5{8'hf0,8'h43}}); // write OTP @r_hold_mcu=1, VPP_EN=0
	#(1000*80) `I2CMST.init (960); // sync. to main clock for CP/FT
	`I2CMST.sfrr (`OFS,'h14);
	`I2CMST.sfrw (`OFS,'h08); `I2CMST.bkrd (`NVMIO,10,{10{8'hff}}); // read OTP @r_hold_mcu=1
	`I2CMST.sfrr (`OFS,'h12);

	`I2CMST.sfrw (`OFS,'h0a);
	`I2CMST.sfrw (`MISC,'h08); // set r_hold_mcu
	`I2CMST.sfrw (`X0_NVMCTL,'h80); // set VPP_EN
	$display ($time,"ns, <%m> program OTP @VPP_EN=1.....");
	`I2CMST.init (PROG_RATE); // sync. to main clock for CP/FT
	`I2CMST.bkwr (`NVMIO,10,{5{8'hf0,8'h43}}); // write OTP @r_hold_mcu=1, VPP_EN=0
	#(1000*80) `I2CMST.init (960); // sync. to main clock for CP/FT
	`I2CMST.sfrw (`X0_NVMCTL,'h00); // clear VPP_EN for OTP read
	`I2CMST.sfrr (`OFS,'h14);
	`I2CMST.sfrw (`OFS,'h08); `I2CMST.bkrd (`NVMIO,10,{{4{8'hf0,8'h43}},{2{8'hff}}});
	`I2CMST.sfrw (`MISC,'h00); // clear r_hold_mcu
	`I2CMST.sfrr (`OFS,'h12);

	for (idx=0;idx<256;idx=idx+1) w_buf[idx*8+:8] = idx;
	w_buf[10*8+:24] = {24{1'h0}}; // repeatedly 8-bit programming

	#(1000*100) test_wr_1 ('h3000,$random); // CODE[0] redundant
	#(1000*100) test_wr_1 ('h3022,$random);
	#(1000*100) test_wr_1 ('h3044,$random);
	#(1000*100) test_wr_1 ('h2200,$random);

	#(1000*100) test_wr_256 ('h0014);
	#(1000*100) test_wr_256 ('h0fa0);

	#100_000 hw_complete;
end

task test_wr_1;
input [15:0] adr;
input [7:0] wdat;
reg [15:0] exp_a;
begin
	$display ($time,"ns <%m> starts.....0x%04x,0x%02x",adr,wdat);
	exp_a = adr + 1;
	`I2CMST.sfrw (`DEC,{2'h2,adr[13:8]});
	`I2CMST.sfrw (`OFS,adr[7:0]);
	`I2CMST.sfrw (`MISC,'h08); // set r_hold_mcu
	`I2CMST.sfrw (`X0_NVMCTL,'h80); // set VPP_EN=1
	`I2CMST.sfrw (`NVMIO,wdat); // write OTP @r_hold_mcu=1, VPP_EN=1
	#(1000*80)
	`I2CMST.sfrw (`X0_NVMCTL,'h00); // clear VPP_EN
	`I2CMST.sfrr (`DEC,{2'h2,exp_a[13:8]});
	`I2CMST.sfrr (`OFS,exp_a[7:0]);
	`I2CMST.sfrw (`DEC,{2'h2,adr[13:8]});
	`I2CMST.sfrw (`OFS,adr[7:0]);
	`I2CMST.sfrr (`NVMIO,wdat);
	`I2CMST.sfrr (`DEC,{2'h2,exp_a[13:8]});
end
endtask // test_wr_1

task test_wr_256;
input [15:0] adr;
reg [15:0] exp;
begin
	$display ($time,"ns <%m> starts.....0x%04x",adr);
	exp = adr + 256;
	`I2CMST.sfrw (`DEC,{2'h2,adr[13:8]});
	`I2CMST.sfrw (`OFS,adr[7:0]);

	`I2CMST.sfrw (`MISC,'h08); // set r_hold_mcu
	`I2CMST.sfrw (`X0_NVMCTL,'h80); // set VPP_EN=1
	`I2CMST.init (PROG_RATE); // sync. to main clock for CP/FT
	`I2CMST.bkwr (`NVMIO,256,w_buf); // write OTP @r_hold_mcu=1, VPP_EN=1
	#(1000*80) `I2CMST.init (960); // sync. to main clock for CP/FT
	`I2CMST.sfrw (`X0_NVMCTL,'h00); // clear VPP_EN

	`I2CMST.sfrr (`DEC,{2'h2,exp[13:8]});
	`I2CMST.sfrr (`OFS,exp[7:0]);
	`I2CMST.sfrw (`DEC,{2'h2,adr[13:8]});
	`I2CMST.sfrw (`OFS,adr[7:0]);
	`I2CMST.bkrd (`NVMIO,256,w_buf); // read OTP @r_hold_mcu=1

	`I2CMST.sfrr (`DEC,{2'h2,exp[13:8]});
	`I2CMST.sfrr (`OFS,exp[7:0]);
end
endtask // test_wr_256

endmodule // stm_i2c_otp

