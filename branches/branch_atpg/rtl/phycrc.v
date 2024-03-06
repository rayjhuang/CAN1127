
module phycrc (
// =============================================================================
// USBPD physical layer submodule
// CRC32 encoder
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// ALL RIGHTS ARE RESERVED
// =============================================================================
//tput	[3:0]	o_crc30,
output	[3:0]	crc32_3_0, // for the transmitter
output		rx_good,
input	[3:0]	i_shfidat,
input		i_start, i_shfi4, i_shfo4,
		clk
);
   reg [31:0] crc32_r;
   assign rx_good = crc32_r == 32'hc704_dd7b; // residual, for receiver
   wire [31:0] crc32_tx = crc32_inv_comp (crc32_r);
   assign crc32_3_0 = crc32_tx[3:0];
   always @(posedge clk)
      if (i_start | i_shfi4) begin
         if (i_start) crc32_r = 'hffff_ffff;
         if (i_shfi4) crc32_r = crc32_gen (crc32_r, i_shfidat);
      end else if (i_shfo4)
         crc32_r = crc32_r<<4; // crc32_r shift left makes crc32_tx shift right

function [31:0] crc32_gen;
input [31:0] crc32_r;
input [3:0] dat;
reg [7:0] idx;
begin
   crc32_gen = crc32_r;
   for (idx=0;idx<4;idx=idx+1)
      crc32_gen = (dat[idx]^crc32_gen[31]) ?crc32_gen<<1 ^ 32'h04c1_1db7 :crc32_gen<<1;
end
endfunction // crc32_gen

function [31:0] crc32_inv_comp;
input [31:0] crc32_r;
reg [7:0] idx;
   for (idx=0;idx<32;idx=idx+1)
      crc32_inv_comp [idx] = ~crc32_r [31-idx];
endfunction // crc32_inv_comp

endmodule // phycrc

