
module updphy #(
parameter	FF_DEPTH_NUM = 30,
parameter	FF_DEPTH_NBT = 5)(
// =============================================================================
// USBPD physical layer top module
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2016/12/06 add FR_Swap detector
// 2017/03/07 '1v' postfix for can1110a0
// 2017/10/05 '2v' postfix for can1110c0, fix auto-TX-GoodCRC for PD30
// 2018/10/03 remove postfix for new naming rule
// ALL RIGHTS ARE RESERVED
// =============================================================================
input		i_cc, i_cc_49, i_sqlch,
input	[1:0]	r_sqlch,
input		r_adprx_en, r_adp2nd, r_exist1st, r_ordrs4,
		r_fifopsh, r_fifopop, r_fiforst,
		r_unlock, r_first, r_last,
		r_set_cpmsgid,
		r_rdy, // OTP read resdy
input	[7:0]	r_wdat, r_rdat,
input	[4:0]	r_txnumk,
input		r_txendk,
		r_txshrt,
		r_auto_discard,
input	[6:0]	r_txauto, r_rxords_ena,
input	[1:0]	r_spec, r_dat_spec, r_auto_gdcrc, r_rxdb_opt,
input		r_pshords, r_dat_portrole, r_dat_datarole,
		r_discard,
output		pid_goidle, pid_gobusy,
output	[1:0]	pff_ack, // 1/2/others: ACK/NAK/rsvd
output	[7:0]	pff_rdat,
output	[15:0]	pff_rxpart,
output	[4:0]	prx_rcvinf,
output		pff_obsd,
output	[FF_DEPTH_NBT-1:0]
		pff_ptr,
output		pff_empty, pff_full, // FIFO status
//		ptx_poplast, // last pop, goes empty
		ptx_ack, // TX done
		ptx_cc, ptx_oe,
output	[6:0]	prx_setsta,
output	[1:0]	prx_rst,
output		prl_c0set, prl_cany0,
		prl_cany0r, prl_cany0w, prl_discard, prl_GCTxDone,
output	[7:0]	prl_cany0adr,
output	[2:0]	prl_cpmsgid,
output	[7:0]	prx_fifowdat,
output	[2:0]	ptx_fsm,
output	[3:0]	prl_fsm, prx_fsm,
output	[5:0]	prx_adpn,
output	[31:0]	dbgpo,
input		clk, srstz
);
   wire r_auto_txgdcrc = r_auto_gdcrc[0];
   wire r_auto_rxgdcrc = r_auto_gdcrc[1];
   wire [1:0] prx_cccnt;
   wire [3:0] crc32_3_0, prx_crcsidat, ptx_crcsidat;
   wire [2:0] prx_rcvdords;
   wire [4:0] prx_rxcode;
   wire [6:0] tmp_setsta;
   wire rxsetsta_6 = tmp_setsta[6];
   wire rxsetsta_3 = tmp_setsta[3];
   phyrx u0_phyrx (
	.i_cc		(i_cc),
	.r_adprx_en	(r_adprx_en),
	.r_adp2nd	(r_adp2nd),
	.r_exist1st	(r_exist1st),
	.r_ordrs4	(r_ordrs4),
	.r_rxdb_opt	(r_rxdb_opt),
	.r_ords_ena	(r_rxords_ena),
	.r_pshords	(rx_pshords),
	.r_rgdcrc	(auto_rx_gdcrc),
	.ptx_txact	(ptx_txact),
	.prx_cccnt	(prx_cccnt),
	.prx_idle	(prx_idle),
	.prx_d_cc	(prx_d_cc),
	.prx_bmc	(prx_bmc),
	.prx_fsm	(prx_fsm),
	.prx_setsta	(tmp_setsta),
	.prx_trans	(prx_trans),
	.prx_fiforst	(prx_fiforst),
	.prx_fifopsh	(prx_fifopsh),
	.prx_fifowdat	(prx_fifowdat),
	.prx_rst	(prx_rst),
	.pff_txreq	(mux_txreq),
	.pid_ccidle	(pid_ccidle),
	.pid_goidle	(pid_goidle),
	.pid_gobusy	(pid_gobusy),
	.pcc_rxgood	(pcc_rxgood),
	.prx_crcstart	(prx_crcstart),
	.prx_crcshfi4	(prx_crcshfi4),
	.prx_crcsidat	(prx_crcsidat),
	.prx_rxcode	(prx_rxcode),
	.prx_adpn	(prx_adpn),
	.prx_rcvdords	(prx_rcvdords),
	.prx_eoprcvd	(prx_eoprcvd),
	.clk		(clk),
	.srstz		(srstz)
   ); // u0_phyrx

   phyidd u0_phyidd (
	.i_trans	(x_trans),
	.i_goidle	(ptx_goidle),
	.o_ccidle	(pid_ccidle),
	.o_goidle	(pid_goidle),
	.o_gobusy	(pid_gobusy),
	.clk		(clk),
	.srstz		(srstz)
   ); // u0_phyidd

   wire [7:0] prl_rdat, mux_rdat;
   wire [6:0] c0_txauto;
   wire [4:0] c0_txnumk;
   phytx u0_phytx (
	.r_txnumk	(c0_txnumk),
	.r_txendk	(c0_txendk),
	.r_txauto	(c0_txauto),
	.r_txshrt	(r_txshrt),
	.prx_cccnt	(prx_cccnt),
	.ptx_cc		(ptx_cc),
	.ptx_fsm	(ptx_fsm),
	.ptx_txact	(ptx_txact),
	.ptx_goidle	(ptx_goidle),
	.ptx_fifopop	(ptx_fifopop),
	.ptx_pspyld	(), // first-byte-read for OTP read (USBPD_02)
	.i_rdat		(mux_rdat),
	.i_txreq	(mux_txreq),
	.i_one		(mux_one),
	.ptx_crcstart	(ptx_crcstart),
	.ptx_crcshfi4	(ptx_crcshfi4),
	.ptx_crcshfo4	(ptx_crcshfo4),
	.ptx_crcsidat	(ptx_crcsidat),
	.pcc_crc30	(crc32_3_0),
	.clk		(clk),
	.srstz		(srstz)
   ); // u0_phytx

   wire
  [3:0] crcsidat = ptx_txact ?ptx_crcsidat :prx_crcsidat;
   wire crcstart = ptx_txact ?ptx_crcstart :prx_crcstart;
   wire crcshfi4 = ptx_txact ?ptx_crcshfi4 :prx_crcshfi4;
   wire crcshfo4 = ptx_txact ?ptx_crcshfo4 :1'h0;
   phycrc u0_phycrc (
	.crc32_3_0	(crc32_3_0),
	.rx_good	(pcc_rxgood),
	.i_shfidat	(crcsidat),
	.i_start	(crcstart),
	.i_shfi4	(crcshfi4),
	.i_shfo4	(crcshfo4),
	.clk		(clk)
   ); // u0_phycrc

   wire prl_idle; // ptx_txact & prl_idle means TX occupies the FIFO
   wire lockena = /* prx_idle & */ ~(ptx_txact & prl_idle) & r_first;
   wire fifosrstz = ~prx_fiforst & srstz;
   wire [55:0] pff_dat_7_1;
   wire [7:0] fifowdat;
   phyff #(
	.DEPTH_NUM	(FF_DEPTH_NUM),
	.DEPTH_NBT	(FF_DEPTH_NBT))
	u0_phyff (
	.r_psh		(r_fifopsh),
	.r_pop		(r_fifopop),
	.r_wdat		(r_wdat),
	.r_last		(r_last),
	.r_unlock	(r_unlock),
	.r_fiforst	(r_fiforst),
	.i_lockena	(lockena),
	.i_ccidle	(pid_ccidle),
	.ptx_pop	(fifopop_pff),
	.prx_psh	(fifopsh_pff),
	.prx_wdat	(prx_fifowdat),
	.txreq		(pff_txreq),
	.ffack		(pff_ack),
	.rdat0		(pff_rdat),
	.full		(pff_full),
	.empty		(pff_empty),
	.one		(pff_one),
	.half		(),
	.dat_7_1	(pff_dat_7_1),
	.obsd		(obsd),
	.ptr		(pff_ptr),
	.fifowdat	(fifowdat),
	.fifopsh	(fifopsh),
	.clk		(clk),
	.srstz		(fifosrstz)
   ); // u0_phyff

   assign pff_obsd = obsd & ~rxsetsta_6; // auto_rxgdcrc should not set 'obsd'
   assign ptx_oe = ptx_txact;
// assign ptx_poplast = ptx_fifopop & pff_one & ~prl_cany0;
   assign ptx_ack = ptx_goidle & ~prl_cany0;

   wire [47:0] pff_c0dat = {pff_dat_7_1,pff_rdat} >> (r_pshords ?16 :0);
   wire [6:0] prl_txauto;
   updprl u0_updprl (
	.r_spec		(r_spec),
	.r_dat_spec	(r_dat_spec),
	.r_dat_portrole	(r_dat_portrole),
	.r_dat_datarole	(r_dat_datarole),
	.r_auto_txgdcrc	(r_auto_txgdcrc),
	.r_auto_discard	(r_auto_discard),
	.r_set_cpmsgid	(r_set_cpmsgid),
	.r_dat_cpmsgid	(r_wdat[2:0]),
	.r_discard	(r_discard),
	.r_rdat		(r_rdat),
	.r_rdy		(r_rdy),
	.prl_c0set	(prl_c0set),
	.prl_cany0	(prl_cany0),
	.prl_rdat	(prl_rdat),
	.prl_last	(prl_last),
	.prl_txreq	(prl_txreq),
	.prl_cany0r	(prl_cany0r),
	.prl_cany0w	(prl_cany0w),
	.prl_cany0adr	(prl_cany0adr),
	.prl_fsm	(prl_fsm),
	.prl_idle	(prl_idle),
	.prl_discard	(prl_discard),
	.prl_GCTxDone	(prl_GCTxDone),
	.prl_cpmsgid	(prl_cpmsgid),
	.prl_txauto	(prl_txauto),
	.pid_ccidle	(pid_ccidle),
	.ptx_ack	(ptx_goidle),
	.ptx_txact	(ptx_txact),
	.ptx_fifopop	(fifopop_prl),
	.prx_fifopsh	(fifopsh_prl),
	.prx_gdmsgrcvd	(prx_gdmsgrcvd),
	.prx_eoprcvd	(prx_eoprcvd),
	.prx_fifowdat	(prx_fifowdat),
	.prx_rcvdords	(prx_rcvdords),
	.pff_c0dat	(pff_c0dat),
	.clk		(clk),
	.srstz		(srstz)
   ); // u0_updprl

   wire rx_gdcrc = {pff_c0dat[15:12],pff_c0dat[4:0]}=='h1;
   assign pff_rxpart = pff_c0dat[15:0]; // part of message header
   assign prx_rcvinf = {pid_ccidle, prx_d_cc, prx_rcvdords};
   assign auto_rx_gdcrc = rx_gdcrc & r_auto_rxgdcrc;
   assign prx_gdmsgrcvd = rxsetsta_3 &~rx_gdcrc;

   assign mux_txreq   = prl_idle ?pff_txreq :prl_txreq;
   assign mux_one     = prl_idle ?pff_one   :prl_last;
   assign mux_rdat    = prl_idle ?pff_rdat  :prl_rdat;
   assign rx_pshords  = prl_idle ?r_pshords :'h0;

   assign c0_txnumk   = prl_idle ?r_txnumk :'h0;
   assign c0_txendk   = prl_idle ?r_txendk :'h0;
   assign c0_txauto   = prl_idle ?r_txauto :prl_txauto;

   assign fifopsh_prl =~prl_idle & prx_fifopsh;
   assign fifopsh_pff = prl_idle & prx_fifopsh;
   assign fifopop_prl =~prl_idle & ptx_fifopop;
   assign fifopop_pff = prl_idle & ptx_fifopop;

   reg [8:0] cclow_cnt;
   reg [1:0] d_cc;
   always @(posedge clk or negedge srstz)
      if (~srstz) d_cc <= 'h3;
      else d_cc <= {d_cc[0],i_cc_49};
   always @(posedge clk)
      if (~srstz || d_cc=='h1) cclow_cnt <= 'd0; // CC rises
      else if (d_cc=='h2) cclow_cnt <= 'd360+'d10; // CC falls, more cycles for margine
      else if (|cclow_cnt) cclow_cnt <= cclow_cnt - 'd1;

   dbnc #(3) u0_sqlch_db (.o_dbc(d_sqlch),.o_chg(),.i_org(i_sqlch),.clk(clk),.rstz(srstz));
   wire dont_sqlch = r_sqlch[1] & (ptx_txact | // don't squelch if TX is active, dummy??
				   prx_fsm[3]); // don't squelch if RX is already in stable states
   assign x_trans = prx_trans & (dont_sqlch | ~(r_sqlch[0]&d_sqlch));
   assign prx_setsta = {tmp_setsta[6:1],cclow_cnt=='h1}; // [0] is replaced by FR_Swap detected

   assign dbgpo = {
	1'h0, ptx_fifopop, prx_fifopsh,
	prx_rxcode[4:0],
	prx_fsm[3:0],
	pid_ccidle, prx_bmc, prx_d_cc,
	fifopsh,
	pff_rdat[7:0],
	fifowdat[7:0]
	};

endmodule // updphy

