
module fcp (
// =============================================================================
// CAN1110
// 2018/01/22 created, RAY HUANG, rayhuang@canyon-semi.com.tw
//            to integrate fcp1112 and fcpcrc
// ALL RIGHTS ARE RESERVED
// =============================================================================
input		dp_comp, dm_comp, id_comp,
output		intr, tx_en, tx_dat,
output	[7:0]	r_dat, r_sta, r_ctl, r_msk, r_crc, r_acc, r_dpdmsta,
input	[7:0]	r_wdat,
input	[6:0]	r_wr,
input		r_re,
input		clk, srstz,
output	[7:0]	r_tui 
);

   dpdmacc u0_dpdmacc (
	.dp_comp	(dp_comp),
	.dm_comp	(dm_comp),
	.id_comp	(id_comp),
	.r_re_0		(r_re),
	.r_wr_1		(r_wr[6]),//r_wr[5]
	.r_wdat		(r_wdat),
	.r_acc		(r_acc),
	.r_dpdmsta	(r_dpdmsta),
	.r_dm		(r_dm),
	.r_dmchg	(r_dmchg),
	.r_int		(r_acc_int),
	.clk		(clk),
	.rstz		(srstz)
   ); // u0_dpdmacc

   fcpegn u0_fcpegn (
//	.comp_dn	(dm_comp),
	.intr		(intr),
	.tx_en		(tx_en),
	.tx_dat		(tx_dat),
	.r_dat		(r_dat),
	.r_sta		(r_sta),
	.r_ctl		(r_ctl),
	.r_msk		(r_msk),
	.r_wr		(r_wr[4:0]),//r_wr[3:0]
	.r_wdat		(r_wdat),
	.ff_idn		(r_dm),
	.ff_chg		(r_dmchg),
	.r_acc_int	(r_acc_int),
	.clk		(clk),
	.srstz		(srstz),
	.r_tui		(r_tui)
   ); // u0_fcpegn

   wire r_crc_en = r_ctl[2];
   wire r_crc_last = r_ctl[3];
   wire r_wr_last = r_wr[5] & r_crc_last;  //r_wr[4]
   wire r_wr_other = r_wr[5] & ~r_crc_last;//r_wr[4]

   fcpcrc u0_fcpcrc (
	.tx_crc		(r_crc),
	.crc_din	(r_wdat),
	.crc_shfi	(r_wr_other),
	.crc_shfl	(r_wr_last),
	.crc_en		(r_crc_en),
	.clk		(clk),
	.srstz		(srstz)
   ); // u0_fcpcrc

endmodule // fcp

