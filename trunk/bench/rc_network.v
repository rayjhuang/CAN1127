
module jumper (
input	[15:0]	v1, v2,
input	[23:0]	r1, r2, // '0' stands for open
input		short, // 0/1: open/short
output	[23:0]	r_out1, r_out2,
output	[15:0]	v_out1, v_out2
);
	wire [15:0]
	ShortV = (r1===0) ? v2
		       : (r2===0) ? v1
		       : ({24'h0,v1} * r2 + v2 * r1) / (r1 + r2);
	assign v_out1 = short ? ShortV : v1;
	assign v_out2 = short ? ShortV : v2;
	wire [23:0]
	ShortR = (r1===0) ? r2
		       : (r2===0) ? r1
		       : ({24'h0,r1} * r2) / (r1 + r2);
	assign r_out1 = short ? ShortR : r1;
	assign r_out2 = short ? ShortR : r2;
endmodule // jumper

module rc_driver (
input	[15:0]	vi,
input	[23:0]	ri,
output	reg
	[15:0]	rc_v =0 // after R/C delay
);
parameter ci = 8'd100; // pF
   event ev_calc;
   always @(vi) disable rc_calc;
   always @(vi) #0 ->ev_calc;
   always @(ev_calc) begin: rc_calc
   reg [31:0] tau; // time constant (ps)
   integer delta; // mV
   real dv; // mV
     while (rc_v!=vi) begin // FALSE if vi is unknown
	tau = ri * ci;
	delta = vi - rc_v;
	dv = delta * (1 - (2.71828**(-1000.0/tau)));
	if (dv<1 && dv>-1) begin
	   if (dv<0) dv = -dv;
	   #(1/dv) rc_v = rc_v + (delta>0 ? 1 : -1);
	end else
	   #1 rc_v = rc_v + dv;
     end
   end // rc_calc
endmodule // rc_driver

module vcompos #( // analog voltage composer
parameter N_DIV = 5,
parameter C_LOAD = 60 // pF
)(
input [N_DIV*(1+24+16)-1:0] rv_param,
output reg [23:0] r,
output reg [15:0] v,
input [23:0] target_r,
input [15:0] target_v,
output [15:0] vout
);
   always @* begin: rv_network
   reg [3:0] ii;
   reg ena;
   reg [15:0] volt;
   reg [23:0] resist;
      r = 0;
      v = 0;
      for (ii=0; ii<N_DIV; ii++) begin
         {ena,resist,volt} = rv_param[(1+24+16)*ii+:(1+24+16)];
         rv_divider (v,r,ena,volt,resist);
      end
   end // rv_network

task rv_divider;
inout reg [15:0] volt;
inout reg [23:0] resist; // '0' stands for an opened target
input ena;
input [15:0] div_v;
input [23:0] div_r; // '0' stands for an opened driver
   if (ena && div_r>0) begin
	volt   = (resist===0) ? div_v : ({24'h0,div_v} * resist + volt * div_r) / (resist+div_r);
	resist = (resist===0) ? div_r : {24'h0,resist} * div_r / (resist+div_r);
   end
endtask // rv_divider

   rc_driver #(C_LOAD)
	rc_output (target_v,target_r,vout);

endmodule // vcompos

