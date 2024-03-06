
`timescale 1ns/1ps
module m51_synthe
#(
// =============================================================================
// USBPD project
// architecture with a MCU
// new version since Apr.2015
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2015/04/17 move to new project directory, ~/project/usbpd_90
// ALL RIGHTS ARE RESERVED
// =============================================================================
parameter SD = 1 // ns
)(
input	[7:0]	sfr_rdat, mem_rdat,
input	[1:0]	i_intz,
input		sfr_ack, mem_ack, clk
);
reg		sfr_r, sfr_w;
reg	[6:0]	sfr_addr;
reg	[7:0]	sfr_wdat;
reg		rdreq, mem_w, memrd_d, memwr_d;
reg	[15:0]	mem_addr =0, mem_addr_d =0;
reg	[7:0]	mem_wdat, mem_wdat_d;

wire mem_r = rdreq & !mem_ack; 

always @(posedge clk) mem_addr_d <= #SD mem_addr;
always @(posedge clk) mem_wdat_d <= #SD mem_wdat;
always @(posedge clk) memrd_d <= #SD mem_r;
always @(posedge clk) memwr_d <= #SD mem_w;

event ev;
reg Timer0Exp =1;
reg [7:0] rddat; // read buffer
wire [7:0] wait_sig = {5'h0,Timer0Exp,~i_intz};
initial {sfr_w,sfr_r} =0;
initial {mem_w,rdreq} =0;

task sfrw;
input [6:0] addr;
input [7:0] wdat;
begin
	@(posedge clk) #SD
	sfr_w = 1;
	sfr_addr = addr;
	sfr_wdat = wdat;
	@(posedge clk) while (sfr_ack!==1) @(posedge clk);
	#SD
	sfr_w = 0;
	sfr_addr = $random;
	sfr_wdat = $random;
	@(posedge clk);
end
endtask // sfrw

task sfrr;
input [6:0] addr;
input [7:0] exp;
reg [7:0] idx;
begin
	@(posedge clk) #SD
	sfr_r = 1;
	sfr_addr = addr;
	@(posedge clk) while (sfr_ack!==1) @(posedge clk);
	rddat = sfr_rdat;
	for (idx=0;idx<8;idx=idx+1)
	   if (exp[idx]!==1'hx && rddat[idx]!==exp[idx]) begin
	      $display ($time,"ns <%m> ERROR: mismatch @%02x, dat:%b, exp:%b",addr,rddat,exp);
	      #100 $finish;
	   end else
	      ;//$display ($time,"ns <%m> DEBUG: data match");
	#SD
	sfr_r = 0;
	sfr_addr = $random;
	@(posedge clk);
end
endtask // sfrr


parameter BLOCK_SIZE = 128;
event ev_bkrd;

task bkwr;
input [7:0] addr, cnt;
input [8*BLOCK_SIZE-1:0] wdat;
integer ii;
	for (ii=0; ii<cnt; ii=ii+1)
	   sfrw (addr, wdat>>ii*8);
endtask // bkwr

task bkrd;
input [7:0] addr, cnt;
input [8*BLOCK_SIZE-1:0] exp;
integer ii;
	for (ii=0; ii<cnt; ii=ii+1) begin
	   sfrr (addr, exp>>ii*8);
	   ->ev_bkrd;
	end
endtask // bkrd


task memw;
input [15:0] addr;
input [7:0] wdat;
begin
	@(posedge clk) #SD
	mem_w = 1;
	mem_addr = addr;
	mem_wdat = wdat;
	@(posedge clk) while (mem_ack&memwr_d!==1) @(posedge clk);
	#SD
	mem_w = 0;
	mem_addr = $random;
	mem_wdat = $random;
	@(posedge clk);
end
endtask // memw

task memr;
input [15:0] addr;
input [7:0] exp;
reg [7:0] idx;
begin
	@(posedge clk) #SD
	rdreq = 1;
	mem_addr = addr;
	@(posedge clk) while ((mem_ack&memrd_d)!==1) @(posedge clk);
	rddat = mem_rdat;
	for (idx=0;idx<8;idx=idx+1)
	   if (rddat[idx]!=exp[idx]) begin
	      if (|exp==='hx) $display ($time,"ns <%m> ERROR: mismatch @%04x: dat %x, exp %b",addr,rddat,exp);
	      else            $display ($time,"ns <%m> ERROR: mismatch @%04x: dat %x, exp %x",addr,rddat,exp);
	      #100 $finish;
	   end else
	      ;//$display ($time,"ns <%m> DEBUG: data match");
	#SD
	rdreq = 0;
	mem_addr = $random;
	@(posedge clk);
end
endtask // memr

// -----------------------------------------------------------------------------
`include "pd_task.v"

endmodule // m51_synthe

