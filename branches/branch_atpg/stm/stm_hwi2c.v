
module stm_hwi2c;
// test HWI2C basic functions
// test HWI2C OTP-access functions
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_hwi2c);
initial timeout_task (1000*300);
initial #10_000 `HW.pulse_width_analy;
reg [7:0] sav0, sav1;
initial begin
#100	`HW.init_dut_fw;
#9_900	`I2CMST.init (1); // 400KHz, OTP read in 1MHz won't work
	`I2CMST.dev_addr = 'h70; // to DUT
	#100_000 $display ($time,"ns <%m> starts");
	#500_000

	`I2CMST.sfrr (`NVMIO,'hxx); sav0 = `I2CMST.rddat; // which data will be returned? (no r_ack_hi)
	`I2CMST.sfrr (`I2CCTL,'hxx);
	`I2CMST.sfrw (`I2CCTL,`I2CMST.rddat & ~'h1e | 'h06); // PG0 in 100h..17Fh, all-writable
	`I2CMST.sfrw (0,'h55); // 20160731, hold CPU may causes ram_acc to block pg0's access
	`I2CMST.sfrr (0,'h55);
	`I2CMST.sfrr (`I2CCTL,'hxx);
	`I2CMST.sfrw (`I2CCTL,`I2CMST.rddat | 'h01); // inc
	`HW.load_dut_fw ("../fw/iram/iram.1.memh"); // access IDAT(08h): data00[0], XDAT(16dh): data01[5], w/ WDT
	`I2CMST.sfrw (`ADR_SRST,8'h01);
	`I2CMST.sfrw (`ADR_SRST,8'h01);
	`I2CMST.sfrw (`ADR_SRST,8'h01); // CPU reset
	repeat (10) TestXdata_0;

	repeat (30) #3_000 `I2CMST.bkrd (`ADR_DPL,2,'hx); // in inc-mode I2C

	`I2CMST.sfrr (`MISC,'hxx); sav1 = `I2CMST.rddat;
	`I2CMST.sfrr (`I2CCTL,'hxx);
	`I2CMST.sfrw (`I2CCTL,`I2CMST.rddat & ~'h1f | 'h18); // non-inc BANK12
	`I2CMST.bkwr (`MISC,3,'h08_0008); // no strech, hold MCU toggle
	refresh_wdt (0,0,'h80-4); // 2ms*4
	repeat (30) TestOTPRead ($random%2>0); // hold too long would cause WDT timeout
	`I2CMST.sfrw (`DEC,'h00); // clr DEC
	`I2CMST.bkwr (`MISC,3,'h08_0008); // no SCL strech, hold MCU toggle
	`I2CMST.sfrw (`GPIO5,'h21); // SCL strech
	`I2CMST.sfrw (`X0_NVMCTL,'h80); // set VPP_EN
	refresh_wdt (0,0,'h80-100); // 2ms*100
	repeat (200) TestOTPWrite;
	`I2CMST.sfrw (`X0_NVMCTL,'h00); // clear VPP_EN
	`I2CMST.sfrw (`GPIO5,'h01); // no SCL strech
	`I2CMST.bkwr (`MISC,3,'h08_0008); // hold MCU toggle, non-inc
	`I2CMST.sfrw (`DEC,'h00); // clr DEC
	repeat (200) TestOTPRead ($random%2>0);
	`I2CMST.sfrw (`DEC,'h00); // clr DEC
	`I2CMST.sfrw (`MISC,sav1);

	`I2CMST.sfrr (`I2CCTL,'hxx);
	`I2CMST.sfrw (`I2CCTL,`I2CMST.rddat & ~'h1e | 'h01); // PG0 in 00h..7Fh, all-writable, inc
	repeat (100) TestXdata_0;

	wait (`DUT_MCU.u_ports.port0==='hec)
	wait (`DUT_MCU.u_ports.port0==='hef) // check FW status
	disable `HW.pulse_width_analy.counting;
	hw_complete;
end

task TestXdata_0; // should be in inc-mode I2C
reg [6:0] start,cnt;
reg [7:0] dat;
reg [8:0] ptr;
reg [8*512-1:0] exp;
begin	->ev;
	start = {$random}%128; // in pg0
	cnt = {$random}%8+1;
	if (start+cnt>'d128) cnt = 'd128-start;
	exp = {2{$random}} & ~({8{8'hff}}<<(cnt*8));
	$display ($time,"ns <%m> start:0x%x, cnt:%0d, exp:%0x",start,cnt,exp);
	`I2CMST.bkwr (start,cnt,exp);
	`I2CMST.bkrd (start,cnt,exp);
end
endtask // TestXdata_0

task TestOTPWrite;
reg [14:0] start;
reg [11:0] cnt, idx;
reg [7:0] dat0,dat1;
reg [8*1024-1:0] exp;
begin	->ev;
	case ({$random}%4)
	0: start = {$random}%(32)+(`HW.OTP_SIZE/1024)* 512-16; // around a boundary (half)
	1: start = {$random}%(32)+(`HW.OTP_SIZE/1024)*1024-16; // around a boundary (main-dummy)
	2: start = {$random}%(32)+(`HW.OTP_SIZE/1024)*1024+64-16; // around a boundary (dummy-dumy)
	default: start = {$random}%(`HW.OTP_SIZE)+900; // random (but iram.c)
	endcase
	cnt = {$random}%6+1; // byte
	exp = {$random,$random,$random,$random} & ~({128{1'h1}}<<(cnt*8));
	$display ($time,"ns <%m> start:0x%x, cnt:%0d, exp:%0x",start,cnt,exp);
	if (start+cnt>`HW.OTP_SIZE)
	   $display ($time,"ns <%m> WARNING: OTP exceeded, skipped");
	else if (start<=(`HW.OTP_SIZE/1024)*1024+63  && start+cnt>=(`HW.OTP_SIZE/1024)*1024+62 // 1st rsvd bytes
	      || start<=(`HW.OTP_SIZE/1024)*1024+127 && start+cnt>=(`HW.OTP_SIZE/1024)*1024+126) // 2nd rsvd bytes
	   $display ($time,"ns <%m> WARNING: reserved area touched, skipped");
	else begin
	   `I2CMST.sfrw (`OFS,start[7:0]);
	   `I2CMST.sfrw (`DEC,{1'h1,start[14:8]});
	   `I2CMST.bkwr (`NVMIO,cnt,exp);
	   for (idx=0;idx<cnt;idx=idx+1) begin
	      dat1 = exp>>(idx*8);
	      dat0 = `HW.get_code(start+idx);
	      if (dat0!==dat1 && |(~dat1 & dat0)!=='h0) begin
	         $display ($time,"ns <%m> ERROR: OTP write failed, adr:%04x, dat:%02x, exp:%02x",
			   start+idx,dat0,dat1);
	         $finish;
	      end
	   end
	end
end
endtask // TestOTPWrite

task TestOTPRead;
input tgl;
reg [14:0] start, ptr;
reg [11:0] cnt, ii;
reg [7:0] dat;
reg [8*128-1:0] exp;
begin	->ev;
	case ({$random}%4)
	0: start = {$random}%(32)+(`HW.OTP_SIZE/1024)* 512-16; // around a boundary
	1: start = {$random}%(32)+(`HW.OTP_SIZE/1024)*1024-16; // around a boundary
	2: start = {$random}%(32)+(`HW.OTP_SIZE/1024)*1024+64-16; // around a boundary
	3: start = {$random}%(`HW.OTP_SIZE); // random
	endcase
	cnt = {$random}%8+1; // byte
	exp = 0;
	for (ii=0;ii<cnt;ii=ii+1)
	   exp = (exp<<8) | `HW.get_code(start+cnt-1-ii);
	$display ($time,"ns <%m> start:0x%x, cnt:%0d, exp:%0x",start,cnt,exp);
	if (tgl) `I2CMST.bkwr (`MISC,2,'h0800); // hold MCU toggle
	`I2CMST.sfrw (`OFS,start[7:0]);
	`I2CMST.sfrw (`DEC,{1'h1,start[14:8]});
	`I2CMST.bkrd (`NVMIO,cnt,exp);
end
endtask // TestOTPRead

task refresh_wdt; // non-inc
input tm, pres;
input [6:0] rel;
begin
	`I2CMST.sfrw (`ADR_WDTREL,{pres,rel}); // prescaler select
	`I2CMST.sfrw (`ADR_PCON,tm?'h40:0); // wdt_tm
	`I2CMST.bkwr (`ADR_IEN0,2,'h4040); // WDT, refresh flag
	`I2CMST.sfrw (`ADR_IEN1,'h40); // SWDT, start/refresh
end
endtask // refresh_wdt

endmodule // stm_hwi2c

