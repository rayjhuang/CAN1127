
`timescale 1ns/100ps
module bhv_compm_mux #(
parameter N_CHNL = 14 // number of channels
)(
input [N_CHNL-1:0] dac_sel,
input [N_CHNL*16-1:0] v_ana_in,
input [9:0] dac_code, // 10-bit DAC
input sh_rst, sh_hold,
output comp_o
);

wire [N_CHNL-1:0] #60 d6_dac_sel = dac_sel;
wire dac_sel_ov = (d6_dac_sel!=dac_sel) & (|dac_sel) & (|d6_dac_sel); // one-hot, non-overlapped
always @(posedge dac_sel_ov) $display ($time,"ns <%m> ERROR: channel selector overlapped");

wire [N_CHNL-1:0] #30 d3_dac_sel = dac_sel;
wire #30 d3_sh_rst = sh_rst;
wire ad_rst_ov = (|(d3_dac_sel | dac_sel)) & sh_rst | (d3_sh_rst | sh_rst) & (|dac_sel);
always @(posedge ad_rst_ov) $display ($time,"ns <%m> WARNING: S/H reset overlapped, channel discharged");

wire #30 d3_sh_hold = ~sh_hold;
wire ad_hold_ov = (|(d3_sh_hold | ~sh_hold)) & sh_rst | (d3_sh_rst | sh_rst) & ~sh_hold;
always @(posedge ad_hold_ov) $display ($time,"ns <%m> WARNING: S/H hold overlapped, input voltage discharged");

reg [15:0] v_cap=0, v_dac=0; // mV (16-bit)
assign comp_o = v_cap > v_dac;
integer delta_cap, cap_target, cnt_sel, ii;
always @*
   if (|dac_sel & ~sh_hold) begin
      cap_target = 0;
      cnt_sel = 0;
      for (ii=0;ii<N_CHNL;ii=ii+1)
         if (dac_sel[ii]) begin
            cap_target = cap_target + v_ana_in[ii*16+:16];
            cnt_sel = cnt_sel + 'h1;
         end
      cap_target = cap_target / cnt_sel;
   end

always #66
if (sh_rst) begin
   cap_target = 0;
   v_cap = v_cap/4;
   #10 v_cap = 0;
end else if (cap_target!=v_cap) begin
   delta_cap = cap_target - v_cap;
   v_cap = v_cap + ((delta_cap<=2 && delta_cap>0) ?1
                   :(delta_cap<0 && delta_cap>=-2) ?-1 :$signed(delta_cap*66/100));
end

integer delta_dac, dac_target;
always @(dac_code) dac_target = dac_code*2; // 2mV
always #80 if (dac_target!=v_dac) begin
   delta_dac = dac_target - v_dac;
   v_dac = v_dac + ((delta_dac<=3 && delta_dac>0) ?1
                     :(delta_dac<0 && delta_dac>=-3) ?-1 :$signed(delta_dac*50/100));
end

wire [15:0]
dbg_ana_in_0 = v_ana_in[16*0+:16],
dbg_ana_in_1 = v_ana_in[16*1+:16],
dbg_ana_in_2 = v_ana_in[16*2+:16],
dbg_ana_in_3 = v_ana_in[16*3+:16];

endmodule // bhv_compm_mux

