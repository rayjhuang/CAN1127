// File		: fcpcrc.v
// Description	: to CRC encode/decode to CRC polynominal=X^8+X^5+X^4+X^3+X^0
// History	:
//  2017/11/02  : create
//  2018/01/22  : crc_en is to replace crc_start
//  2020/08/01  : Ray, to simplify coding style (formal checked)

`define	CRC_POLY	8'h39

module fcpcrc (
	output	[7:0]	tx_crc, // CAN1121A0 naming
	input	[7:0]	crc_din,
	input		crc_en,	  // operation enable/disable
			crc_shfi, // data byte shift-in pulse (not last data)
			crc_shfl, // last data byte shift_in pulse
	input		clk, srstz
);

reg	[7:0]	crc8_r;
assign tx_crc = crc8_r[7:0];
always @ (posedge clk or negedge srstz)
begin
  if (!srstz)
    crc8_r = 8'h00;
  else
    if (!crc_en) 
      crc8_r = 8'h00;
    else begin
      if (crc_shfi |
          crc_shfl) crc8_r = crc8_gen(crc8_r, crc_din);
      if (crc_shfl) crc8_r = crc8_gen(crc8_r, 'h0);
    end
end

function [7:0]
crc8_gen;
input	[7:0]	crc8_r, dat;
reg	[7:0]	idx;
begin
    crc8_gen = crc8_r;
    for (idx=0;idx<8;idx=idx+1) 
	crc8_gen = {crc8_gen[6:0],dat[7-idx]} ^ (crc8_gen[7] ? `CRC_POLY : 'h0);
end
endfunction

endmodule

