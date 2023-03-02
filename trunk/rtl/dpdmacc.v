
module dpdmacc (
////////////////////////////////////////////////////////////////////////////////
// D+/D- pulse accumulators with READ-CLEAR attributes
// positive pulse on D+ with a 150us filter (100~200us in QC3 spec.)
// negative pulse on D- with a 150us filter
// Revision,
// 20180903 first created
// ALL RIGHTS ARE RESERVED
////////////////////////////////////////////////////////////////////////////////
input		dp_comp,
		dm_comp,
		id_comp,
input		r_re_0, r_wr_1,
input	[7:0]	r_wdat,
output	[7:0]	r_acc, r_dpdmsta,
output		r_dm, r_dmchg, r_int,
input		clk, rstz
);
   ff_sync u0_dpsync (dp_comp,r_dp,dp_chg,clk,rstz);
   ff_sync u0_dmsync (dm_comp,r_dm,dm_chg,clk,rstz);
   ff_sync u0_idsync (id_comp,r_id,id_chg,clk,rstz);

   assign r_dmchg = dm_chg;

   wire dp_rise = ~r_dp & dp_chg;
   wire dm_fall =  r_dm & dm_chg;

   filter150us u0_dpfltr (dp_active_acc,dp_inacti_acc,dp_rise,dp_chg,clk,rstz);
   filter150us u0_dmfltr (dm_active_acc,dm_inacti_acc,dm_fall,dm_chg,clk,rstz);

   wire r_dp_edge = r_dpdmsta[0];
   wire r_dm_edge = r_dpdmsta[1];
   wire dp_acc = r_dp_edge ? dp_inacti_acc : dp_active_acc & r_dp;
   wire dm_acc = r_dm_edge ? dm_inacti_acc : dm_active_acc &~r_dm;

   wire upd00 = dp_acc | dm_acc | r_re_0;
   wire [7:0] wd00 = r_re_0
                     ? {3'h0, dm_acc, 3'h0, dp_acc}
                     : {r_acc[7:4]<'hf ? r_acc[7:4] + (dm_acc ? 4'h1 : 4'h0) : r_acc[7:4],
                        r_acc[3:0]<'hf ? r_acc[3:0] + (dp_acc ? 4'h1 : 4'h0) : r_acc[3:0]};
   assign r_int = dp_acc & (r_acc[3:0]=='h0 || r_re_0) ||
                  dm_acc & (r_acc[7:4]=='h0 || r_re_0);

   glreg u0_accmltr (clk,rstz,upd00,wd00,r_acc);

   wire upd01 = r_wr_1;
   glreg #(5) u0_dpdmsta (clk,rstz,upd01,r_wdat[4:0],r_dpdmsta[4:0]);
   assign r_dpdmsta[7] = r_dm;
   assign r_dpdmsta[6] = r_dp;
   assign r_dpdmsta[5] = r_id;

endmodule // dpdmacc

module filter150us #(
parameter	N_BIT = 12,
parameter	TIMEOUT = 1800 // 150us/(1us/12MHz)
)(
output		active_hit, inacti_hit,
input		start_edge, any_edge,
input		clk, rstz
);
reg	[11:0]	dbcnt;

   assign active_hit = dbcnt==(TIMEOUT-'h1);
   assign inacti_hit = dbcnt>=(TIMEOUT-'h1) && any_edge && ~start_edge;

   always @(posedge clk or negedge rstz)
      if (~rstz)
         dbcnt <= 'h0;
//    else if (start_edge)
//       dbcnt <= 'h1;
      else if (any_edge)
         dbcnt <= (dbcnt>'h0 && dbcnt<TIMEOUT) ? 'h0 : 'h1;
      else if (dbcnt>'h0 && dbcnt<TIMEOUT)
         dbcnt <= dbcnt + 'h1;

endmodule // filter150us

// debunce
module ff_sync (
input		i_org,
output		o_dbc, o_chg,
input		clk,
input		rstz
);

reg	[1:0]	d_org;

always @ (posedge clk or negedge rstz) begin
  if (!rstz)
    d_org <= 2'b00;
  else
    d_org <= {d_org[0], i_org};
end

assign o_dbc = d_org[1];
assign o_chg = ^d_org;

endmodule // ff_sync

