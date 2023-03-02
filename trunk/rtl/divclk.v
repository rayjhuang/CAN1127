
module divclk(
input	mclk,
input   srstz,
input   atpg_en,
output  clk_1500k,
output	clk_500k, clk_100k, clk_50k,
output	clk_500, divff_8, divff_5
);

reg [2:0] div8;
reg [1:0] div1p5m_3;
reg [2:0] div500k_5;
reg       div100k_2;
reg [6:0] div50k_100;

assign divff_8 = div8[2]; // divide mclk by 8
assign divff_5 = div500k_5[2];

wire en8     = div8       == 3'd4;
wire en500k  = div1p5m_3  == 2'd2;
wire en100k  = div500k_5  == 3'd4;
wire en50k   = div100k_2  == 1'd1;
wire en500hz = div50k_100 == 7'd99;

always@(posedge mclk or negedge srstz)
  if(~srstz) div8 <= 'h0;
  else div8 <= div8+'h1;

always@(posedge clk_1500k or negedge srstz)
  if(~srstz) div1p5m_3 <='h0;
  else if (en500k) div1p5m_3 <= 'h0;
  else div1p5m_3 <= div1p5m_3+'h1;

always@(posedge clk_500k or negedge srstz)
  if(~srstz) div500k_5 <='h0;
  else if (en100k) div500k_5 <= 'h0;
  else div500k_5 <= div500k_5+'h1;

always@(posedge clk_100k or negedge srstz)
  if(~srstz) div100k_2 <='h0;
  else if (en50k) div100k_2 <= 'h0;
  else div100k_2 <= div100k_2+'h1;

always@(posedge clk_50k or negedge srstz)
  if(~srstz) div50k_100 <='h0;
  else if (en500hz) div50k_100 <= 'h0;
  else div50k_100 <= div50k_100+'h1;
 
`ifdef FPGA
reg n_en8, n_en500k, n_en100k, n_en50k, n_en500hz;
always @(negedge mclk or negedge srstz)
   if (~srstz) {n_en8,n_en500k,n_en100k,n_en50k,n_en500hz} <= 'h0;
   else        {n_en8,n_en500k,n_en100k,n_en50k,n_en500hz} <= #1 {en8,en500k,en100k,en50k,en500hz};
assign clk_1500k = mclk & n_en8;
assign clk_500k  = mclk & n_en8 & n_en500k;
assign clk_100k  = mclk & n_en8 & n_en500k & n_en100k;
assign clk_50k   = mclk & n_en8 & n_en500k & n_en100k & n_en50k;
assign clk_500   = mclk & n_en8 & n_en500k & n_en100k & n_en50k & n_en500hz;
`else
CLKDLX1 U0_D1P5M_ICG (.E(en8),     .CK(mclk),     .SE(atpg_en),.ECK(clk_1500k)); //667ns
CLKDLX1 U0_D500K_ICG (.E(en500k),  .CK(clk_1500k),.SE(atpg_en),.ECK(clk_500k));  //2us
CLKDLX1 U0_D100K_ICG (.E(en100k),  .CK(clk_500k), .SE(atpg_en),.ECK(clk_100k));  //10us
CLKDLX1 U0_D50K_ICG  (.E(en50k),   .CK(clk_100k), .SE(atpg_en),.ECK(clk_50k));   //20us
CLKDLX1 U0_D0P5K_ICG (.E(en500hz), .CK(clk_50k),  .SE(atpg_en),.ECK(clk_500));   //2ms
`endif

endmodule
