
module glreg #( // general register
parameter WIDTH = 8,
parameter D4VAL = 'h0
)(
input	clk,
	arstz,
	we,
input	[WIDTH-1:0] wdat,
output	[WIDTH-1:0] rdat
);
   reg [WIDTH-1:0] mem;
   assign rdat = mem;
   always @(posedge clk or negedge arstz)
      if (~arstz)
         mem <= D4VAL;
      else if (we)
         mem <= wdat;
      else if (~we)
         mem <= mem;
      else // we='hx
         mem <= 'hx;

endmodule // glreg


module rsreg #( // register with async. set/reset
parameter WIDTH = 8
)(
input	clk,
	arstz,
	we,
input	[WIDTH-1:0] wdat, aset,
output	[WIDTH-1:0] rdat
);
   reg [WIDTH-1:0] mem;
   assign rdat = mem;
   genvar idx;
   generate
   for (idx=0;idx<WIDTH;idx=idx+1) begin: RSFF
   always @(posedge clk or negedge arstz or posedge aset[idx])
      if (~arstz) mem[idx] <= 1'h0;
      else if (aset[idx]) mem[idx] <= 1'h1;
      else if (we&wdat[idx]) mem[idx] <= 1'h0;
   end
   endgenerate
endmodule // rsreg


module glsta #( // general status register
// 20180123 : use set-pulse to IRQ
//            1. mask-out the set-pulse when STA is '1'
//            2. clear STA in ISR means the IRQ had been received
//            3. clear STA while set it, let STA cleared, so that the IRQ consist with STA
parameter WIDTH = 8
)(
input clk,arstz,rst0,
input [WIDTH-1:0] set2,clr1, // priority: 0>1>2
output [WIDTH-1:0] rdat, irq
);
   wire [WIDTH-1:0] sta_r;
   assign rdat = sta_r;
   assign irq = ~sta_r & set2;
   wire upd_r = (|(set2 | clr1 | rst0));
   wire [WIDTH-1:0] wd_r = rst0 ?{WIDTH{1'h0}} :(~clr1 & (sta_r | set2));
   glreg #(.WIDTH(WIDTH))
   u0 (.clk(clk), .arstz(arstz), .we(upd_r), .wdat(wd_r), .rdat(sta_r)); // register
endmodule // glsta


module dgreg_rf #( // with rise/fall outputs
// filter out a too-short pulse
parameter N_BIT = 2 // at least
)(
output reg dgo,
output rise,fall,
input dgi,clk,rstz
);
   reg [N_BIT-1:0] dgbuf;
   assign rise = ~dgo & ( &dgbuf);
   assign fall =  dgo & (~|dgbuf);
   always @(posedge clk or negedge rstz)
      if (~rstz) dgo <= 'h0;
      else if (rise) dgo <= 'h1;
      else if (fall) dgo <= 'h0;
   always @(posedge clk)
      dgbuf <= {dgi,dgbuf}>>1;
endmodule // dgreg_rf


module ff_sram #(
parameter BIT_ADDR = 7,
parameter N_WIDTH = 8
)(
input	[BIT_ADDR-1:0] A,
input	CLK,
input	[N_WIDTH-1:0] D,
input	WEN,
input	CEN,
output	[N_WIDTH-1:0] Q
);
reg [N_WIDTH-1:0] mem [0:2**BIT_ADDR-1], rdat;
assign Q = rdat;
always @(posedge CLK)
   if (~CEN) begin //  which type of 'rdat' works in the project?
      if (~WEN) mem [A] <= D; rdat <= mem [A];
//    if (~WEN) mem [A]  = D; rdat  = mem [A];
   end
endmodule // ff_sram


module synchr_pls (
// synchronizer for 1T positive pulse in/out
// high-to-low/low-to-high freq. domain
output q,
input qclk,qrstz,
    d,dclk,drstz
);
   reg dd;
   always @(posedge dclk or negedge drstz)
      if (~drstz) dd <= 1'h0;
      else if (d) dd <= ~dd;

   reg [1:0] qbuf;
   always @(posedge qclk or negedge qrstz)
      if (~qrstz) qbuf <= 2'h0;
      else qbuf <= {dd,qbuf}>>1; // casting

   assign q = ^qbuf[1:0];

endmodule // synchr_pls


module synchr_l2h (
// synchronizer for positive level/pulse input (glitch-free), output 1T pulse
// only for low-to-high freq. domain
output q,
input srstz,clk,d
);
   reg [2:0] dd;
   always @(posedge clk)
      if (~srstz) dd <= 3'h0;
      else dd <= {dd[1:0],d};
   assign q = dd==3'b011 || dd==3'b010;
endmodule // synchr_l2h


module dbnc #(
parameter WIDTH = 4,
parameter TIMEOUT = {WIDTH{1'h1}}
)(
output o_dbc,o_chg,
input i_org,clk,rstz
);
   reg [1:0] d_org;
   reg [WIDTH-1:0] db_cnt;
   wire toggle_s = ^d_org;
   wire toggle_p = db_cnt==TIMEOUT;
   always @(posedge clk or negedge rstz)
      if (~rstz)
         {db_cnt,d_org} <= 'h0;
      else begin
         d_org[0] <= i_org;
         if (toggle_s) begin
            db_cnt <= db_cnt +'h1;
            if (toggle_p) begin
               d_org[1] <= d_org[0];
               db_cnt <= 'h0;
            end
         end else if (|db_cnt)
            db_cnt <= 'h0;
      end
   assign o_dbc = d_org[1];
   assign o_chg = toggle_s & toggle_p;
endmodule // dbnc


module glpwm (
input clk,rstz,clk_base,we,
input [7:0] wdat,
output [7:0] r_pwm,
output pwm_o
);
   glreg u0_regpwm (clk, rstz, we, wdat, r_pwm);
   wire enable = r_pwm[7];
   wire [6:0] duty = r_pwm[6:0];

   reg [6:0] pwmcnt;
   always @(posedge clk_base or negedge rstz)
      if (~rstz)
         pwmcnt <= {7{1'h1}};
      else if (we & ~wdat[7]) // disable (forced) the pwm
         pwmcnt <= {7{1'h1}};
      else if (enable)
         pwmcnt <= pwmcnt - 'h1;

   assign pwm_o = pwmcnt < duty; // 0/128 ~ 127/128

endmodule // glpwm

