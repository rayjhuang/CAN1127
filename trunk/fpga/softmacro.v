
module ev_indic ( // rising-edge or level-high
output dst_ev,
input dst_clk, src_clk, src_rstz, level,
input src_ev
);
   reg [3:0] cnt;
   reg [1:0] d_dst_clk;
   reg d_src_ev;
   wire dst_edge = ^d_dst_clk;
   assign src_ev_T1 = (src_ev ^ d_src_ev) | (cnt=='h0) & src_ev & level;
   assign dst_ev = cnt[3];
   always @(posedge src_clk or negedge src_rstz)
      if (~src_rstz) cnt <= 'h0;
      else if ((|cnt) ?dst_edge :src_ev_T1) cnt <= cnt +'h1;

   always @(posedge src_clk or negedge src_rstz)
      if (~src_rstz) d_src_ev <= 'h0;
      else d_src_ev <= src_ev;

   always @(posedge src_clk or negedge src_rstz)
      if (~src_rstz) d_dst_clk <= 'h0;
      else d_dst_clk <= {d_dst_clk[0],dst_clk};
endmodule // ev_indic


module dgbus #(
// filter out a too-short transition
parameter WIDTH = 3
)(
output reg [WIDTH-1:0] dgo,
input [WIDTH-1:0] dgi,
input clk,rstz
);
   wire [WIDTH-1:0] dg_tmp, tmp_rise, tmp_fall;
   dgreg_rf dgu [WIDTH-1:0] (dg_tmp, tmp_rise, tmp_fall, dgi, {WIDTH{clk}}, {WIDTH{rstz}});

   reg [WIDTH-1:0] d_dgo;
   always @(posedge clk or negedge rstz)
      if (~rstz) begin
         d_dgo <= {WIDTH{1'h0}};
         dgo <= {WIDTH{1'h0}};
      end else begin
         d_dgo <= dg_tmp;
         if (d_dgo==dg_tmp)
            dgo <= d_dgo;
      end

endmodule // dgbus


module cmd_req_gen #(
parameter CLK_REQ = 12_000 // 12KHz
)(
output	reg	req_rdy, // request is ready for processing
		req_vld, // there's something in req_bus[7:0]
output	[7:0]	req_bus,
input		req_btn, // request button input
		req_ack, // request has been processed
		clk,rstz
);

   dgreg_rf degltch0 (d_req,req_rise,req_fall,req_btn,clk,rstz);
   reg [7:0] req_buf;
   reg [15:0] req_len;
   wire rev_rise = ~req_rdy & req_rise;
   wire rev_fall = ~req_rdy & req_fall;
   wire req_add = rev_fall & (req_len<CLK_REQ/3);
   wire req_tri = rev_fall & (req_len>=CLK_REQ/3) & (req_len<CLK_REQ) & (|req_bus);
   wire req_psh =    d_req & (req_len==CLK_REQ);
   wire req_rst =    d_req & (req_len>=CLK_REQ*2)
                 | req_psh & (req_bus[3:0]=='h0) // push to become req_bus=0
                 | req_add & (req_bus=='hf); // add to become req_bus=0
   always @(posedge clk)
      if (~rstz | req_rst) req_buf <= 'h0;
      else if (req_add) req_buf[3:0] <= req_buf[3:0] +'h1;
      else if (req_psh) req_buf <= {req_buf[3:0],4'h0};
   always @(posedge clk)
      if (rev_rise) req_len <= 'h0;
      else if (d_req) req_len <= (&req_len) ?req_len :req_len +'h1;
   always @(posedge clk)
      if (~rstz | req_rst)
         {req_vld,req_rdy} <= 2'h0;
      else if (req_tri)
         {req_vld,req_rdy} <= 2'h1;
      else if (req_ack) // ACK rcvd, req_buf reserved
         req_rdy <= 1'h0;
      else if (~req_rdy & (|req_bus))
         req_vld <= 1'h1;

   assign req_bus = req_buf;

endmodule // cmd_req_gen


// Xilinx distributed-RAM
// there's an address-combinational out
// registered output is preferred
module dist_mem_8kx8 ( // in CAN1110 FPGA
input [12:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:8*1024-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_8kx8

module dist_mem_6kx8 ( // initialized by elaborating with 'mon51.coe'
input [12:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:6*1024-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_6kx8

module dist_mem_4kx8 (
input [11:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:4*1024-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_4kx8

module dist_mem_1536x8 ( // in CAN1124 FPGA
input [10:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:1536-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_1536x8

module dist_mem_1kx8 ( // initialized by elaborating with 'dut.coe'
input [9:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:1*1024-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_1kx8

// -----------------------------------------------------------------------------

module dist_mem_8kx16 ( // initialized by elaborating with 'dut.coe'
input [12:0] a,
input clk,
input [15:0] d,
input we,
output [15:0] qspo
);
reg [15:0] mem [0:8*1024-1], rdat;
assign qspo = rdat;
wire [15:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_8kx16

module dist_mem_1kx16 ( // initialized by elaborating with 'dut.coe'
input [9:0] a,
input clk,
input [15:0] d,
input we,
output [15:0] qspo
);
reg [15:0] mem [0:1*1024-1], rdat;
assign qspo = rdat;
wire [15:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_1kx16

module dist_mem_256x16 ( // initialized by elaborating with 'dut.coe'
input [7:0] a,
input clk,
input [15:0] d,
input we,
output [15:0] qspo
);
reg [15:0] mem [0:256-1], rdat;
assign qspo = rdat;
wire [15:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_256x16

// -----------------------------------------------------------------------------

module dist_mem_640x8 (
input [9:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:640-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_640x8

module dist_mem_512x8 (
input [8:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:512-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_512x8

module dist_mem_256x8 (
input [7:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:256-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_256x8

module dist_mem_128x8 (
input [6:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:128-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_128x8

module dist_mem_64x8 (
input [5:0] a,
input clk,
input [7:0] d,
input we,
output [7:0] qspo
);
reg [7:0] mem [0:64-1], rdat;
assign qspo = rdat;
wire [7:0] spo = mem [a];
always @(posedge clk) begin
   if (we) mem [a] <= d;
   rdat <= spo;
end
endmodule // dist_mem_64x8

// -----------------------------------------------------------------------------

module clk_wiz_48to45 (
input CLK_IN1,
output CLK_OUT1
);
assign CLK_OUT1 = CLK_IN1;
endmodule // clk_wiz_48to45

