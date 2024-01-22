module shmux #(
parameter BIT_PTR = 'd3, // these assignments equivalent to CAN1121
parameter N_DACV = 'd8, // see the real value in its instanciation
parameter N_CHNL = 'd11, // 3-channel switchable (0,4,5)
parameter BIT_PLUS = 'd4, // 4-bit pointer for N_CHNL>8
parameter ALL1_PLUS = {BIT_PLUS{1'h1}}
)(
input	ps_md4ch,
	r_comp_swtch,
	r_semi,
	r_loop,
input [N_DACV-1:0] r_dac_en, wr_dacv,
output	busy,
	sh_hold,
input	stop,
	semi_start,
	auto_start,
	mxcyc_done,
	sampl_begn,
	sampl_done,
output [N_CHNL-1:0] app_dacis, // appended
output [BIT_PTR-1:0] cs_ptr, ps_ptr,
output	[BIT_PLUS-1:0] o_smpl,
input	clk, srstz
);
   reg [BIT_PTR:0] cs_mux, ps_mux; // one more bit for busy/idle
   assign busy = ~cs_mux[BIT_PTR];
   assign ps_ptr = ps_mux[BIT_PTR-1:0],
          cs_ptr = cs_mux[BIT_PTR-1:0];

   wire mux_upd = auto_start | semi_start | mxcyc_done;
   wire [BIT_PTR-1:0] sel_ptr = cs_ptr,
                      mux_ptr = sel_ptr | ((sel_ptr<'h8)&ps_md4ch ?'h4 :'h0);
   wire [N_CHNL-1:0] tmptr = {{N_CHNL-1{1'h0}},1'h1}<<mux_ptr; // temp
   reg [N_CHNL-1:0] r_dacis, ps_dacis;
   always @* begin: switch
   parameter [N_DACV-1:0] sw_candi = 'b00110001; // 3 '1' is must
   reg [BIT_PTR:0] ii; // one more bit
      for (ii=0; ii<N_CHNL; ii=ii+1)
         case (ii) // to specify the 3 switchable channels
              10: ps_dacis[ii] = r_comp_swtch & tmptr[0] | tmptr[ii];
               9: ps_dacis[ii] = r_comp_swtch & tmptr[5] | tmptr[ii];
               8: ps_dacis[ii] = r_comp_swtch & tmptr[4] | tmptr[ii];
         default: ps_dacis[ii] = r_comp_swtch & sw_candi[ii] ?1'h0 :tmptr[ii];
         endcase
   end // switch

// 20190718
   reg  [N_CHNL-1:0] neg_dacis;
   assign app_dacis = r_dacis | neg_dacis;
   assign sh_hold = ~|r_dacis; 
   always@(negedge clk)
   	if (~srstz | (|neg_dacis)) neg_dacis <= {N_CHNL{1'h0}};
	else if (sampl_done) neg_dacis <= r_dacis;

   always @(posedge clk) // non-overlap
      if (~srstz) r_dacis <= {N_CHNL{1'h0}};
      else if (sampl_begn) r_dacis <= ps_dacis;
      else if (sampl_done | stop) r_dacis <= {N_CHNL{1'h0}};

   always @(posedge clk)
      if (stop) cs_mux[BIT_PTR] <= 1'h1;
      else if (~srstz) cs_mux <= {1'h1,{BIT_PTR{1'h0}}};
      else if (mux_upd) cs_mux <= ps_mux;

   always @* begin: mux_seq
      reg [BIT_PTR-1:0] ii;
      reg [BIT_PTR:0] tmp; // an additional bit for carry
      ps_mux = {1'h0,cs_ptr};
      if (r_semi | auto_start) begin // semi_start or auto_start
         for (tmp=N_DACV-1; tmp!={BIT_PTR+1{1'h1}}; tmp=tmp-'h1)
            if (wr_dacv[tmp] | r_dac_en[tmp]) ps_mux = tmp;
      end else
         for (ii=N_DACV-1; ii>'h0; ii=ii-'h1) begin
            tmp = cs_ptr + ii;
            if (tmp > N_DACV-1) tmp = tmp - N_DACV;
            if (r_dac_en[tmp]) ps_mux = {1'h0,tmp};
         end
      if (busy & ((cs_ptr>=ps_ptr) & ~r_loop | r_semi))
         ps_mux[BIT_PTR] = 1'h1; // becomes idle
   end // mux_seq

   reg [BIT_PLUS-1:0] reg_smpl;
   always @(r_dacis) begin: daci_sel // pos_dacis
      reg [BIT_PLUS-1:0] ii;
      reg_smpl = ALL1_PLUS; // all-0
      for (ii=0; ii<N_CHNL; ii=ii+1)
         if (r_dacis[ii])
            reg_smpl = (reg_smpl==ALL1_PLUS) ?ii :ALL1_PLUS-'h1; // one-hot or error
   end // daci_sel
   assign o_smpl = reg_smpl; // test mode in tape-out

`ifdef SYNTHESIS
`else
   always @(posedge clk)
      if (o_smpl==ALL1_PLUS-'h1) begin
         $display ($time,"ns <%m> ERROR: ADC chennel selector error, %0x",o_smpl);
         #100 $finish;
      end
`endif // SYNTHESIS
endmodule // shmux

