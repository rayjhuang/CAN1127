
module divclk(
input	mclk,
input   srstz,
input   atpg_en,
output  clk_1p0m,
output	clk_500k, clk_100k, clk_50k,
output	clk_500, divff_o1, divff_o2
);

reg [3:0] div12;
reg       div1p0m_2;
reg [2:0] div500k_5;
reg       div100k_2;
reg [6:0] div50k_100;

assign divff_o1 = div12[3]; // divided by 12, 33%
assign divff_o2 = div500k_5[1]; // 100KHz, 40%

wire en12    = div12      == 4'he; // 4'd11;
wire en500k  = div1p0m_2  == 1'd1;
wire en100k  = div500k_5  == 3'd4;
wire en50k   = div100k_2  == 1'd1;
wire en500hz = div50k_100 == 7'd99;

always@(posedge mclk or negedge srstz)
   if (~srstz) div12 = 'h0;
   else if (en12) div12 = 'h0;
   else
// div12 = div12+'h1;

   begin: gray_counter
      reg [4:0] ii;
      reg [4-1:0] bin, bin_plus;
      for (ii=0; ii<4; ii=ii+1) // gray-to-binary
         bin[ii] = ^(div12 >> ii);
      bin_plus = bin + 'h1;
      div12 = bin_plus^(bin_plus>>1); // binary-to-gray
   end // gray_counter


always@(posedge clk_1p0m or negedge srstz)
  if(~srstz) div1p0m_2 <='h0;
  else if (en500k) div1p0m_2 <= 'h0;
  else div1p0m_2 <= div1p0m_2+'h1;

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
reg n_en12, n_en500k, n_en100k, n_en50k, n_en500hz;
always @(negedge mclk or negedge srstz)
   if (~srstz) {n_en12,n_en500k,n_en100k,n_en50k,n_en500hz} <= 'h0;
   else        {n_en12,n_en500k,n_en100k,n_en50k,n_en500hz} <= #1 {en12,en500k,en100k,en50k,en500hz};
assign clk_1p0m  = mclk & n_en12;
assign clk_500k  = mclk & n_en12 & n_en500k;
assign clk_100k  = mclk & n_en12 & n_en500k & n_en100k;
assign clk_50k   = mclk & n_en12 & n_en500k & n_en100k & n_en50k;
assign clk_500   = mclk & n_en12 & n_en500k & n_en100k & n_en50k & n_en500hz;
`else
CLKDLX1 U0_D1P0M_ICG (.E(en12),    .CK(mclk),     .SE(atpg_en),.ECK(clk_1p0m)); //1us
CLKDLX1 U0_D500K_ICG (.E(en500k),  .CK(clk_1p0m), .SE(atpg_en),.ECK(clk_500k));  //2us
CLKDLX1 U0_D100K_ICG (.E(en100k),  .CK(clk_500k), .SE(atpg_en),.ECK(clk_100k));  //10us
CLKDLX1 U0_D50K_ICG  (.E(en50k),   .CK(clk_100k), .SE(atpg_en),.ECK(clk_50k));   //20us
CLKDLX1 U0_D0P5K_ICG (.E(en500hz), .CK(clk_50k),  .SE(atpg_en),.ECK(clk_500));   //2ms
`endif

endmodule

