
module PrlTimer_1112a0 #(
// =============================================================================
// USBPD protocol layer submodule
// 2016/11/28 separated from updprl.v
// 2018/01/09 CAN1112, change Tifg_TIMEOUT (longer for safer)
// ALL RIGHTS ARE RESERVED
// =============================================================================
parameter Tifg_TIMEOUT = 600, // InterFrameGap(min.25us), 12MHz x 50us ('h258)
parameter Ttrn_TIMEOUT = 2304, // Transmit(max.195us), 12MHz x 192us ('h900)
parameter N_WIDTH = 12 // 12-bit timer
)(
output [1:0] to,
input restart,stop,clk,srstz
);
   reg [N_WIDTH-1:0] timer;
   reg ena;
   assign to = {timer>=Ttrn_TIMEOUT,timer>=Tifg_TIMEOUT};
   always @(posedge clk)
      if (~srstz | restart)
         {ena,timer} <= {restart,{N_WIDTH{1'h0}}};
      else if (stop)
         ena <= 'h0;
      else if (ena & ~to[1])
         timer <= timer +'h1;

endmodule // PrlTimer_1112a0

