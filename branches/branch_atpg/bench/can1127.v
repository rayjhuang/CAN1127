
//`define DUT bench.DUT
`define DUT_SRAM    `DUT.U0_SRAM.mem
`define DUT_XDAT(a) `DUT_SRAM[a]
`define DUT_IDAT(a) `DUT_SRAM[a+'h500]
`ifdef GATE // for right-side only
`define CODE0(n,a)  (n==0) ? `DUT.U0_CODE_0_.otpCell_normal_0[(a>>6)&'h7f][a&'h3f] : \
                    (n==1) ? `DUT.U0_CODE_1_.otpCell_normal_0[(a>>6)&'h7f][a&'h3f] : 'hx
`define CODE1(n,a)  (n==0) ? `DUT.U0_CODE_0_.otpCell_redundant_0[a&'h3f] : \
                    (n==1) ? `DUT.U0_CODE_1_.otpCell_redundant_0[a&'h3f] : 'hx
`else // can for both right/left-side
`define CODE0(n,a)  `DUT.U0_CODE[n].otpCell_normal_0[(a>>6)&'h7f][a&'h3f]
`define CODE1(n,a)  `DUT.U0_CODE[n].otpCell_redundant_0[a&'h3f] // ATO0008KX8MX180LBX4DA
`endif
`define DUT_ANA     `DUT.U0_ANALOG_TOP
`define DUT_CORE    `DUT.U0_CORE
`define DUT_MCLK    `DUT_CORE.U0_MCLK_ICG.ECK
`define DUT_MCU     `DUT_CORE.u0_mcu
`define DUT_CCLK    `DUT_MCU.clkcpu

module hardware_rev; // can1127
initial $fsdbDumpvars;
`ifdef CAN1124B0 parameter REV_ID = 7'h2f; `endif // CAN1124B0
`ifdef CAN1126A0 parameter REV_ID = 7'h30; `endif // CAN1126A0
`ifdef CAN1127A0 parameter REV_ID = 7'h31; `endif // CAN1127A0
parameter OTP_SIZE = 'h4080; // 16K128B
parameter LSB_PWR_I = 25; // mA/LSB

function [7:0] get_code;
input [15:0] adr;
	get_code = ~(
	(adr<OTP_SIZE) ? (adr[14]) ? (adr[6]  ?`CODE1(1,adr) : `CODE1(0,adr))
	                           : (adr[13] ?`CODE0(1,adr) : `CODE0(0,adr))
`ifdef FPGA
	               : (adr>='h8000 && adr<'h9800)
	                          ? ~`MON51_C[adr[12:0]] // 6KB for MON51, not inverted
`endif	               : 'h00); // OTP erased state
endfunction // get_code

task set_code;
input [15:0] adr;
input [7:0] pdat;
	if (adr<OTP_SIZE) begin
`ifdef GATE
           if (adr[14]) if (adr[6])  `DUT.U0_CODE_1_.otpCell_redundant_0[adr[5:0]] = ~pdat;
	                        else `DUT.U0_CODE_0_.otpCell_redundant_0[adr[5:0]] = ~pdat;
/* main blocks */  else if (adr[13]) `DUT.U0_CODE_1_.otpCell_normal_0[adr>>6][adr&'h3f] = ~pdat;
                                else `DUT.U0_CODE_0_.otpCell_normal_0[adr>>6][adr&'h3f] = ~pdat;
`else
           if (adr[14]) if (adr[6])  `CODE1(1,adr) = ~pdat;
	                        else `CODE1(0,adr) = ~pdat;
/* main blocks */  else if (adr[13]) `CODE0(1,adr) = ~pdat;
	                        else `CODE0(0,adr) = ~pdat;
`endif
	end
`ifdef FPGA
	else if (adr>='h8000 && adr<'h9800)
	   `MON51_C[adr[12:0]] = pdat; // not inverted
`endif
endtask: set_code

// function void init_dut_fw; // vcs dosen't like 'void'
task init_dut_fw;
integer adr;
	for (adr=0;adr<OTP_SIZE;adr=adr+1) set_code (adr,'hff);
endtask: init_dut_fw

task load_dut_fw;
input [256*8-1:0] fn;
reg [15:0] adr;
reg [15:0] word_mem [0:OTP_SIZE/2-1];
reg [7:0] code_mem [0:OTP_SIZE-1];
begin
	for (adr=0;adr<OTP_SIZE;adr=adr+1) code_mem[adr] = {8{1'h1}};
	case (fn[0+:8*7])
	".2.memh": begin
	           $display ($time,"ns <%m> NOTE: 2-byte hex file");
	           for (adr=0;adr<OTP_SIZE/2;adr=adr+1) word_mem[adr] = {16{1'h1}};
	           $readmemh (fn, word_mem); // .2.memh
	           for (adr=0;adr<OTP_SIZE;adr=adr+2) {code_mem[adr+1],code_mem[adr]} = word_mem[adr/2];
	           end
	default:   begin
	           $display ($time,"ns <%m> NOTE: 1-byte hex file");
	           $readmemh (fn, code_mem);
	           end
	endcase
	for (adr=0;adr<OTP_SIZE;adr=adr+1) set_code (adr,code_mem[adr]);
	$display ($time,"ns <%m> NOTE: load firmware %0s (revid:%02x)", fn, REV_ID);
end
endtask: load_dut_fw

task dut_hit_rate (
input [31:0] period =0 // evaluated period, us
);
integer mempsrd, mempsack;
reg [7:0] rate;
reg [8*10-1:0] name;
begin
   name = "DUT";
   $display ($time,"ns <%m> NOTE: start to evaluate hit rate of %0s", name);
   mempsrd = 0;
   mempsack = 0;
   fork
      begin: counting
         forever
            @(posedge `DUT_CCLK)
            if (`DUT_MCU.mempsrd) begin
               mempsrd = mempsrd + 1;
               mempsack = mempsack + `DUT_MCU.mempsack;
            end
      end // counting
      if (period>0)
         #(1000*period) disable counting;
   join
   rate = mempsack*100/mempsrd;
   $display ($time,"ns <%m> NOTE: %0s hits %0d%% (%0d,%0d)", name, rate, mempsack, mempsrd);
end
endtask // dut_hit_rate

parameter MAX_PULSE_LEN = 20;
`ifdef GATE
wire pulse_width_probe = 0; // optimized
`else
wire pulse_width_probe = `DUT_CORE.u0_mpb.ramacc;
//re pulse_width_probe = `DUT_MCU.ramoe;
`endif
task pulse_width_analy;
integer width_acc [1:MAX_PULSE_LEN];
reg [7:0] cnt, ii;
reg d_probe;
begin
	for (ii=1;ii<=MAX_PULSE_LEN;ii=ii+1)
        width_acc[ii] = 0;
	d_probe = 0;
	$display ($time,"ns <%m> start.....");
	begin: counting // disable this to report the result
	   forever @(posedge `DUT_MCLK) begin
	   if (pulse_width_probe) begin
	      if (~d_probe) cnt = 'h1; // rise, reset
	      else if (cnt<'hff) cnt = cnt + 'h1;
	   end else if (d_probe) begin // fall
	      if (cnt>MAX_PULSE_LEN)
	         width_acc[MAX_PULSE_LEN] = width_acc[MAX_PULSE_LEN] + 1;
	      else width_acc[cnt] = width_acc[cnt] + 1;
	   end
	   d_probe = pulse_width_probe;
	   end // forever
	end // counting
	for (ii=1;ii<MAX_PULSE_LEN;ii=ii+1)
	   if (width_acc[ii]>0)
	      $display ($time,"ns <%m> width_acc[%0d]: %0d", ii, width_acc[ii]);
	$display ($time,"ns <%m> width_acc[>]: %0d", width_acc[MAX_PULSE_LEN]);
end
endtask // pulse_width_analy
wire [7:0]
dbg_width_0  = pulse_width_analy.width_acc[MAX_PULSE_LEN],
dbg_width_1  = pulse_width_analy.width_acc[1],
dbg_width_2  = pulse_width_analy.width_acc[2],
dbg_width_10 = pulse_width_analy.width_acc[10],
dbg_width_11 = pulse_width_analy.width_acc[11],
dbg_width_12 = pulse_width_analy.width_acc[12],
dbg_width_13 = pulse_width_analy.width_acc[13],
dbg_width_14 = pulse_width_analy.width_acc[14],
dbg_width_15 = pulse_width_analy.width_acc[15],
dbg_width_16 = pulse_width_analy.width_acc[16];

// IO cells ////////////////////////////////////////////////////////////////////
initial begin
force `DUT.PAD_GPIO_TS.DI = `DUT.PAD_GPIO_TS.IE ? `DUT_ANA.v_RT>=1100 : 1'h0;
end // initial
////////////////////////////////////////////////////////////////////////////////


`ifdef GATE // pc_o becomes 'z'
////	it's difficult to monitor such things in gate-level simulation
`else
   always @(posedge `DUT_CCLK) begin: mcu_check
      if (`DUT_MCU.mempsrd & `DUT_MCU.mempsack) begin: chk_psdat // to debug u0_ictlr
         reg [7:0] exp;
         exp = `HW.get_code(`DUT_MCU.u_cpu.pc_o);
         if (`DUT_MCU.memdatai!==exp) begin
            $display ($time,"ns <%m> ERROR: fetch 0x%x, exp:%x, dat:%x",`DUT_MCU.u_cpu.pc_o,exp,`DUT_MCU.memdatai);
            #500 $finish;
         end
      end // chk_psdat

      if (`DUT_CORE.iram_ce & `DUT_CORE.xram_ce) begin: chk_sram
         $display ($time,"ns <%m> ERROR: uni-SRAM architecture violation");
         #500 $finish;
      end // chk_sram
      if ((8'h0 + `DUT_MCU.mempswr + `DUT_MCU.memwr
                + `DUT_MCU.mempsrd + `DUT_MCU.memrd) >1) begin: chk_vonn
         $display ($time,"ns <%m> ERROR: Von Nuemann architecture violation");
         #500 $finish;
      end // chk_vonn

      if (`DUT_MCU.t0_tr0 & // don't set Timer0 when it's still running
		~`DUT_MCU.u_timer0.rst &
		 `DUT_MCU.u_timer0.sfrwe &
		(`DUT_MCU.u_timer0.sfraddr==`DUT_CORE.u0_mcu.u_timer0.TL0_ID ||
		 `DUT_MCU.u_timer0.sfraddr==`DUT_CORE.u0_mcu.u_timer0.TH0_ID)) begin: chk_tmr0
	 $display ($time,"ns <%m> WARNING: timer0 changed during runing, not good!!");
      end // chk_tmr0
   end // mcu_check
`endif // GATE


begin: PB // hw_probe
dig_probe	SLEEP (`DUT_ANA.SLEEP),
		OSC_LOW (`DUT_ANA.OSC_LOW),
		PWR_ENABLE (`DUT_ANA.PWREN),
		DISCHARGE  (`DUT_ANA.VO_DISCHG);
ana_probe	PWR_I ({8'h0,`DUT_ANA.DAC2});
end // hw_probe

`include "../../can1126/bench/mem_dump.v" // longer path for UVM0
endmodule // hardware_rev

