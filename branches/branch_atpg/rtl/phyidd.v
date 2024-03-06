
module phyidd (
// =============================================================================
// USBPD physical layer submodule
// idle detector
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2017/03/07 '1v' postfix for can1110a0
// 2018/10/03 remove postfix for new naming rule
// ALL RIGHTS ARE RESERVED
// =============================================================================
input	i_trans, i_goidle,
output	o_ccidle,
output	o_goidle, // CC's going idle means RX done
	o_gobusy,
input	clk, srstz
);
   reg ccidle;
   reg [1:0] ntrancnt; // 3 times
   reg [7:0] ttranwin, trans0, trans1; // 16us, 192T@12MHz
   wire ttrans_sat = ttranwin=='d192;
   wire gobusy = ccidle & (ntrancnt=='h2) & i_trans; // doesn't go to 'h3
   wire goidle = ~ccidle & ttrans_sat;
   wire [7:0] ttranwin_p1 = ttrans_sat ?ttranwin :ttranwin +'h1;
   wire [7:0] ttranwin_minus = ttranwin_p1 - trans0;

   always @(posedge clk)
      if (~srstz | goidle | i_goidle)
         ccidle <= 'h1;
      else if (gobusy)
         ccidle <= 'h0;

   always @(posedge clk)
      if (~srstz | goidle | i_goidle | gobusy | ccidle & ttrans_sat & ~i_trans)
         ntrancnt <= 'h0;
      else if (i_trans)
         ntrancnt <= (ntrancnt=='h3) ?ntrancnt :ntrancnt +'h1;

   always @(posedge clk)
      if (~srstz | gobusy | ccidle & i_trans & (ntrancnt=='h0))
         ttranwin <= 'h0;
      else if (i_trans) begin
         case (ntrancnt)
         'h1: {ttranwin,trans0} <= {2{ttranwin_p1}};
         'h2: {ttranwin,trans1} <= {2{ttranwin_p1}};
         'h3: begin
              ttranwin <= ttranwin_minus;
              trans0 <= trans1 - trans0;
              trans1 <= ttranwin_minus;
         end
         endcase
      end else if (~ttrans_sat)
         ttranwin <= ttranwin_p1;

   assign o_ccidle = ccidle;
   assign o_goidle = goidle | i_goidle;
   assign o_gobusy = gobusy;

endmodule // phyidd

