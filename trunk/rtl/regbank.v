
module regbank (
// =============================================================================
// USBPD project
// architecture with a MCU
// new version since Apr.2015
// 2015/04/17 move from core.v, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2017/03/07 '1110' postfix for can1110a0
// 2018/01/17 '1112a0' postfix
// 2018/09/03 '1112b0' postfix
// 2018/10/03 remove postfix
// ALL RIGHTS ARE RESERVED
// =============================================================================
input	[6:0]	srci, // async.
input		dm_fault, id_di, cc1_di, cc2_di, // async.
		di_rd_det, di_stbovp,
		i_tmrf,
		i_vcbyval, dnchk_en,
output		r_pwrv_upd, aswkup,
		ps_pwrdn,
		r_sleep, r_pwrdn, r_ocdrv_enz,
		r_osc_stop, r_osc_lo, r_osc_gate,
output	[11:0]	r_fw_pwrv,
output	[2:0]	r_cvcwr,
input	[15:0]	r_cvofs,
input	[7:0]	r_sdischg,
output		r_otpi_gate,
output	[7:4]	r_pwrctl,
output	[7:0]	r_pwr_i, r_cvctl,
		r_srcctl, r_dpdmctl,
		r_ccrx, r_cctrx, r_ccctl,
output	[6:0]	r_fcpwr,
output		r_fcpre,
input	[7:0]	fcp_r_dat, fcp_r_sta, fcp_r_msk, fcp_r_ctl, fcp_r_crc, fcp_r_acc,fcp_r_tui, r_accctl,
output		r_bclk_sel,
output	[14:0]	r_dacwr,
input	[7:0]	r_dac_en, r_sar_en, r_adofs, r_isofs,
input	[5:0]	x_daclsb, // bit un-positioned
output	[7:0]	r_comp_opt,
input   [7:0]   dac_r_ctl,dac_r_comp, dac_r_cmpsta,
input	[63:0]	dac_r_vs,
input	[6:0]	REVID,
input		atpg_en,
input		sfr_r, sfr_w, set_hold, bkpt_hold, cpurst,
input	[7:0]	sfr_addr, sfr_wdat,
output	[7:0]	sfr_rdat,
input	[7:0]	ff_p0, di_p0,
input		ictlr_idle, ictlr_inc,
output	[14:0]	r_inst_ofs,
output		r_psrd, r_pswr,
output		r_fortxdat, r_fortxrdy, r_fortxen,
output	[3:0]	r_ana_tm, // analog test
output		r_gpio_tm,
output	[1:0]	r_gpio_ie,
output	[6:0]	r_gpio_oe, r_gpio_pu, r_gpio_pd,
output	[2:0]	r_gpio_s0, r_gpio_s1, r_gpio_s2, r_gpio_s3,
output	[47:0]	r_ana_opt, // register trim for analog
input	[15:0]	i_pc,
input		i_goidle, i_gobusy, i_i2c_idle,
input	[7:0]	i_i2c_rwbuf, i_i2c_ltbuf, i_i2c_ofs,
output	[4:0]	o_intr,
output	[1:0]	r_auto_gdcrc,
output		r_exist1st,	// ORDRS decoder to expect the 1st k-code exist
		r_ordrs4,	// ORDRS decoder to expect 4 correct k-codes
		r_fifopsh,	// MCU writes FIFO (1T)
		r_fifopop,	// MCU reads FIFO (1T)
		r_unlock,	// force MCU's lock
		r_first,	// MCU's first write/read to FIFO
		r_last,		// MCU's last write to FIFO
		r_fiforst,	// MCU resets FIFO (1T)
		r_set_cpmsgid,	// write CpMsgId
		r_txendk,	// ended TX with K-codes, i.e. last byte of FIFO is being encoded as 2 K-codes
output	[4:0]	r_txnumk,	// TX 'N' bytes of K-Code from front of FIFO, 1Fh means all to be K-Code
output		r_txshrt,	// shorten auto-tx preamble
		r_auto_discard,
		r_hold_mcu,
output	[6:0]	r_txauto,	// [6]: K-encode payload, if not, those K-code will TX as raw
				// [5]: append an EOP K-code after the end of FIFO or auto-CRC if enabled
				// [4]: append an CRC32 after the end of FIFO, should enable autoeop to meet spec.
				// [3]: insert an 64-bit preamble before FIFO
				// [2:0]: insert an SOP*/Reset ordered set before FIFO, should enable autopam to meet spec.
output	[6:0]	r_rxords_ena,
output	[1:0]	r_spec, r_dat_spec,
output		r_dat_portrole, r_dat_datarole,
		r_discard,	// MCU write pulse (1T?), discard sending auto-GoodCRC
		r_pshords,	// don't decode ordered set, save the 2-byte data to FIFO
output	[3:0]   r_pg0_sel,
output		r_strtch, r_i2c_attr,
		r_i2c_ninc, r_hwi2c_en,
		r_i2c_fwnak, r_i2c_fwack,
output	[7:1]	r_i2c_deva,
input	[7:0]	i2c_ev,
input		prl_c0set,
		prl_cany0, prl_discard, prl_GCTxDone,
input	[2:0]	prl_cpmsgid,
input	[1:0]	pff_ack,
		prx_rst,
input		pff_obsd, pff_full, pff_empty,
		ptx_ack,
input	[5:0]	pff_ptr, prx_adpn,
input	[7:0]	pff_rdat,
input	[15:0]	pff_rxpart,
input	[4:0]	prx_rcvinf,
input	[2:0]	ptx_fsm,
input	[3:0]	prx_fsm, prl_fsm,
input	[6:0]	prx_setsta,
input		clk_1500k, clk_500k, clk_500,
		clk, xrstz, xclk,
output	[31:0]	dbgpo,
output		srstz, prstz
);
`define UNUSED_D4 8'hff
   wire ['hff:'h80] hit = {127'h0,sfr_addr[7]} << sfr_addr[6:0];
   wire ['hff:'h80] we = hit & {128{sfr_w}};
   wire [7:0] wdat = sfr_wdat; // rename
   wire [7:0]	regFF,regFE,regFD,regFC,regFB,regFA,regF9,regF8,
		regF7,regF6,regF5,regF4,regF3,regF2,regF1,regF0,
		regEF,regEE,regED,regEC,regEB,regEA,regE9,regE8,
		regE7,regE6,regE5,regE4,regE3,regE2,regE1,regE0,
		regDF,regDE,regDD,regDC,regDB,regDA,regD9,regD8,
		regD7,regD6,regD5,regD4,regD3,regD2,regD1,regD0,
		reg31,reg30,reg29,reg28,reg27,reg26,reg25,reg24,
		reg23,reg22,reg21,reg20,reg19,reg18,reg17,reg16,
   		reg15,reg14,reg13,reg12,reg11,reg10,reg09,reg08,
		reg07,reg06,reg05,reg04,reg03,reg02,reg01,reg00,
		regAF,regAE,regAD,regAC,regAB,regAA,regA9,regA8,
		regA7,regA6,regA5,regA4,regA3,regA2,regA1,regA0,
		reg9F,reg9E,reg9D,reg9C,reg9B,reg9A,reg99,reg98,
		reg97,reg96,reg95,reg94,reg93,reg92,reg91,reg90,
		reg8F,reg8E,reg8D,reg8C,reg8B,reg8A,reg89,reg88,
		reg87,reg86,reg85,reg84,reg83,reg82,reg81,reg80;
   assign sfr_rdat = {
        	regFF,regFE,regFD,regFC,regFB,regFA,regF9,regF8,
		regF7,regF6,regF5,regF4,regF3,regF2,regF1,regF0,
        	regEF,regEE,regED,regEC,regEB,regEA,regE9,regE8,
		regE7,regE6,regE5,regE4,regE3,regE2,regE1,regE0,
		regDF,regDE,regDD,regDC,regDB,regDA,regD9,regD8,
		regD7,regD6,regD5,regD4,regD3,regD2,regD1,regD0,
		reg31,reg30,reg29,reg28,reg27,reg26,reg25,reg24,
                reg23,reg22,reg21,reg20,reg19,reg18,reg17,reg16,
		reg15,reg14,reg13,reg12,reg11,reg10,reg09,reg08,
		reg07,reg06,reg05,reg04,reg03,reg02,reg01,reg00,
        	regAF,regAE,regAD,regAC,regAB,regAA,regA9,regA8,
		regA7,regA6,regA5,regA4,regA3,regA2,regA1,regA0,
        	reg9F,reg9E,reg9D,reg9C,reg9B,reg9A,reg99,reg98,
		reg97,reg96,reg95,reg94,reg93,reg92,reg91,reg90,
        	reg8F,reg8E,reg8D,reg8C,reg8B,reg8A,reg89,reg88,
		reg87,reg86,reg85,reg84,reg83,reg82,reg81,reg80} >> {sfr_addr[6:0],3'h0};

   wire [7:0] r_dec;
   wire r_ack = r_dec=='h7c; // allow some special access
   wire r_ack_hi = r_dec[7]=='h1; // to enable NVM access
   wire cc_stat = prx_rcvinf[3];
   wire cc_idle = prx_rcvinf[4];
   wire bus_idle = i_i2c_idle &~prl_cany0 & cc_idle & (~|ptx_fsm);

   wire [7:0] irq03,irq04,irq28,irqAE,irqDF;
   assign o_intr = {
		|{regAF&irqAE}, // SRCPRO
		|{regDE&irqDF}, // P0
		|{reg27&irq28}, // I2C
		|{reg06&irq04}, |{reg05&irq03}}; // UPDPHY

   reg [1:0] drstz;
   wire srst = ~drstz[1]; // sync. reset
   always @(posedge clk or negedge xrstz)
      if (~xrstz) drstz <= 'h0;
             else drstz <= drstz<<1 | 1'h1;

   reg [4:0] rstcnt;
   wire w_sysrst;
   wire sysrst = rstcnt[4:3]=='h2 && rstcnt[2:1]!='h0; // must be glitch-free
   wire sysupd = rstcnt=='h10;
   always @(posedge clk or negedge xrstz)
      if (~xrstz)
         rstcnt = 'h0;
      else if (w_sysrst | (|rstcnt) & bus_idle) begin: greycnt
         reg [4:0] bcd;
         bcd = {rstcnt^(rstcnt>>1)^(rstcnt>>2)^(rstcnt>>3)^(rstcnt>>4)} +'h1;
         rstcnt = bcd^(bcd>>1);
      end

   reg [1:0] r_phyrst;
   wire prst = r_phyrst[1]; // updphy reset
   wire w_phyrst, r_auto_rst, hrdrst;
   wire ev_phyrst = |{w_phyrst, hrdrst&r_auto_rst};
   always @(posedge clk or negedge xrstz)
      if (~xrstz) r_phyrst <= 'h0;
      else if (r_phyrst=='h1)
         r_phyrst <= (~prl_cany0 | i_goidle) ?'h2 :'h1;
      else if (|{ev_phyrst,r_phyrst})
         r_phyrst <= r_phyrst +'h1;

// reg r_sfrrst;
   wire w_sfrrst;
// always @(posedge clk or negedge xrstz)
//    if (~xrstz) r_sfrrst <= 'h0;
//           else r_sfrrst <= w_sfrrst;

   assign srstz = atpg_en |~(srst | sysrst); // system reset, sync., used to sync/async reset, HW trap pins control
   assign prstz = atpg_en |~(srst | sysrst | prst); // updphy reset, sync.
   wire   rrstz = srstz & xrstz; // atpg_en |~(srst | sysrst | r_sfrrst); // register reset, async.?

   glreg u0_reg00 (clk, rrstz, we['hb0], wdat, reg00); // TXCTL
   assign r_txauto = reg00[6:0];
   assign r_txendk = reg00[7];

   wire clrfirst = r_first & (r_fifopsh | r_fifopop);
   wire clrlast  = r_last  &  r_fifopsh;
   wire upd01 = |{we['hb1],clrfirst,clrlast};
   wire [7:0] wd01 = {clrlast  ?1'h0 :we['hb1] ?wdat[7] :reg01[7],
                      clrfirst ?1'h0 :we['hb1] ?wdat[6] :reg01[6],
                      we['hb1] ?wdat[5:0] :reg01[5:0]};
   glreg u0_reg01 (clk, rrstz, upd01, wd01, reg01); // FFCTL
   assign r_txnumk = reg01[4:0];
   assign r_unlock = reg01[5];
   assign r_first = reg01[6];
   assign r_last = reg01[7];

   assign reg02 = pff_rdat; // FFIO
   assign r_fifopsh = we['hb2];
   assign r_fifopop = sfr_r & hit['hb2];

// RECEIVER STATUS
// 7: Hard/Cable-Reset flag
// 6: EOP (of GoodCRC with CRC OK) rcvd
// 5: no EOP (EOP-expected packets, include disable/undefined one)
// 4: EOP rcvd with bad CRC
// 3: EOP rcvd with CRC OK
// 2: disabled/undefined ordered set rcvd, and the following flags won't be set
// 1: enabled ordered set rcvd
// 0: FR_Swap detected 
   wire phyrst = prst | prl_c0set | w_phyrst; // reset PHY status
   wire rst03 = phyrst;
   wire [7:0] clr03 = {8{we['hb3]}} & wdat;
   wire [7:0] set03 = {hrdrst, prl_cany0 ?7'h0 :prx_setsta};
   glsta u0_reg03 (clk, rrstz, rst03, set03, clr03, reg03, irq03); // STA0

// TRANSMITTER / FIFO STATUS
// 6: auto-returned GoodCRC discarded
// 7: auto-returned GoodCRC TX done
// 5: FIFO NAK
// 4: FIFO ACK, MCU push/pop last safely
// 3: FIFO obsoleted by RX
// 2: cc goes busy
// 1: cc goes idle
// 0: TxAck (TX goes idle)
// wire goempty = ptx_poplast; // TX last pop, goes empty
   wire rst04 = phyrst;
   wire [7:0] clr04 = {8{we['hb4]}} & wdat;
   wire [7:0] set04 = prl_cany0 ?'h0 :{prl_discard,prl_GCTxDone,pff_ack[1:0],
					pff_obsd,i_gobusy,i_goidle,ptx_ack};
   glsta u0_reg04 (clk, rrstz, rst04, set04, clr04, reg04, irq04); // STA1

   glreg u0_reg05 (clk, rrstz, we['hb5], wdat, reg05); // MSK0
   glreg u0_reg06 (clk, rrstz, we['hb6], wdat, reg06); // MSK1

   assign reg07 = {pff_empty,pff_full,pff_ptr}; // FFSTA
// assign cblrst = set03[1] & prx_rst[0]; // enabled Cable Reset rcvd.
   assign hrdrst = set03[1] & (|prx_rst); // enabled Hard/Cable Reset rcvd.
   assign w_phyrst  = we['hb7] & (wdat=='hc8) & r_ack; // r_dec=ack, from C8 (PE)
   assign r_discard = we['hb7] & (wdat=='hdc); // discard sending GoodCRC
   assign r_fiforst = we['hb7] & (wdat=='h0) | prl_c0set;
   assign w_sfrrst  ='h0; // we['hb7] & (wdat=='hff) & r_ack;
   assign w_sysrst  = we['hb7] & (wdat=='h55) & r_ack;
   wire clr_ack = |{w_phyrst,w_sfrrst,w_sysrst};

   assign reg08 = `UNUSED_D4; // MCU(ien1)
   assign reg09 = `UNUSED_D4; // MCU(ip1)
   assign reg10 = `UNUSED_D4; // MCU(s0relh)

   glreg u0_reg11 (clk, rrstz, we['hbb], wdat, reg11); // RXCTL
   assign r_auto_rst = reg11[7];
   assign r_rxords_ena = reg11[6:0] | {2'h0,~|reg11[6:0],4'h0};
// for CC-ISP,
// SOP"_Debug if no ordered-set
// no ordered-set enabled means no FW
// FW need to turn on at least one ordered-set

   wire [7:0] wd12 = sysupd ?(reg12|'h10) :we['hbc] ?wdat :{reg12[7:4],set_hold,reg12[2:0]};
   wire upd12 = we['hbc] | sysupd | set_hold | cpurst;
   glreg u0_reg12 (clk, rrstz, upd12, wd12, reg12); // MISC
// system reset indicator: reg12[4]
   assign r_hold_mcu = bkpt_hold | reg12[3] | regD4[2] | regD4[0]; // STOP/GATE
   assign r_txshrt = reg12[2]; // shorten PHYTX preamble, used in Canyon_mode_0, which response with shortened ones
   assign r_pshords = reg12[0];

   assign reg13 = {prl_cany0, prx_rcvinf[2:0], prl_fsm}; // CanyonMode0, ORDS, PRLS

   glreg #(5) u0_reg14 (clk, rrstz, we['hbe], wdat[7:3], reg14[7:3]); // PRLTX
   assign r_set_cpmsgid = we['hbe];
   assign r_auto_gdcrc = {reg14[3],reg14[7]};
   assign r_auto_discard = reg14[6];
   assign r_spec = reg14[5:4];
   assign reg14[2:0] = prl_cpmsgid;

   glreg u0_reg15 (clk, rrstz, we['hbf], wdat, reg15); // GPF

   assign reg16 = `UNUSED_D4; // MCU(ircon)
   assign reg17 = i_i2c_ofs; // I2CCMD

   wire [14:0] inst_ofs = {reg19[6:0],reg18},
		inst_ofs_plus = inst_ofs +'h1;
   wire upd18 = we['hc2] | ictlr_inc;
   wire [7:0] wd18 = ictlr_inc ?inst_ofs_plus[7:0] :we['hc2] ?wdat :'hx;
   glreg u0_reg18 (clk, rrstz, upd18, wd18, reg18); // OFS, NVM address {DEC[3:0],OFS}
   assign r_inst_ofs = inst_ofs;

   wire upd19 = we['hc3] | ictlr_inc | clr_ack;
   wire [7:0] wd19 = ictlr_inc ?{reg19[7],inst_ofs_plus[14:8]} :we['hc3] ?wdat :clr_ack ?'h0 :'hx;
   glreg u0_reg19 (clk, rrstz, upd19, wd19, reg19); // DEC, additional decoder
   assign r_dec = reg19;

   wire SavRcvdHdr = set03[6] | set03[3] & ~r_auto_gdcrc[1]; // r_auto_rxgdcrc
   wire upd20 = we['hc4] | SavRcvdHdr;
   wire upd21 = we['hc5] | SavRcvdHdr;
   wire [7:0] wd20 = we['hc4] ?wdat :pff_rxpart[7:0];
   wire [7:0] wd21 = we['hc5] ?wdat :pff_rxpart[15:8];
   glreg u0_reg20 (clk, rrstz, upd20, wd20, reg20); // PRLRXL
   glreg u0_reg21 (clk, rrstz, upd21, wd21, reg21); // PRLRXH
   assign r_dat_spec = reg20[7:6];
   assign r_dat_datarole = reg20[5];
   assign r_dat_portrole = reg21[0];

   assign reg22 = {cc_stat, ptx_fsm, prx_fsm}; // CC status, TRXS
   assign reg23 = {cc_idle, REVID};
   assign reg24 = `UNUSED_D4; // MCU(t2con)

   glreg #(6,'h18) u0_reg25 (clk, rrstz, we['hc9], wdat[5:0], reg25[5:0]); // I2CCTL
   assign reg25[7:6] = 'h0;
   assign r_i2c_fwack = we['hc9] & wdat[7];
   assign r_i2c_fwnak = we['hc9] & wdat[6];
// assign r_i2c_attr = reg25[5:4]; // HWI2C write attribute, 0/1/2/3: TCPC/writable/not-wr/rsvd
// assign r_i2c_raw = reg25[3]; // HWI2C can not recover this bit, FW do it
   assign r_i2c_attr = reg25[5]; // HWI2C write attribute, 0/1: writable/write-protected
   assign r_pg0_sel = reg25[4:1];
   assign r_i2c_ninc = ~reg25[0];

   reg q_toggle_i2c;
   wire to_toogle_i2c = we['hca] & (wdat[0]^reg26[0]); // to switch I2C
   wire ev_toogle_i2c = q_toggle_i2c & i_i2c_idle; // switch I2C
   always @(posedge clk or negedge rrstz)
      if (~rrstz)
         q_toggle_i2c <= 'h0;
      else
         q_toggle_i2c <=
               (to_toogle_i2c) ?'h1
              :(ev_toogle_i2c) ?'h0 :q_toggle_i2c;
   wire upd26 = we['hca] | ev_toogle_i2c; // never comes togather
   wire [7:0] wd26 = we['hca] ?{wdat[7:1],reg26[0]}
             :ev_toogle_i2c ?{reg26[7:1],~reg26[0]} :'hx;
   glreg #(8,{7'h70,1'h1}) u0_reg26 (clk, rrstz, upd26, wd26, reg26); // I2CDEVA
   assign r_i2c_deva = reg26[7:1];
   assign r_hwi2c_en = reg26[0];

   glreg u0_reg27 (clk, rrstz, we['hcb], wdat, reg27); // I2CMSK

   wire [7:0] set28 = i2c_ev;
   wire [7:0] clr28 = {8{we['hcc]}} & wdat;
   glsta u0_reg28 (clk, rrstz, 1'h0, set28, clr28, reg28, irq28); // I2CEV

   assign reg29 = i_i2c_ltbuf; // I2CBUF
   assign reg30 = r_ack_hi ? {2'h0,prx_adpn} : i_pc[7:0]; // PCL

   assign r_pswr = sfr_w & hit['hcf] & r_ack_hi; // from CAN1123A0
   assign r_psrd = sfr_r & hit['hcf] & r_ack_hi;
   wire upd31 = sfr_r & hit['hce] &~r_ack_hi;
   glreg u0_reg31 (clk, rrstz, upd31, i_pc[15:8], reg31); // latch PC high byte
// reg31, NVMIO, PCH
// NVMIO comes later, cannot use this address decoder.

   assign regD0 = `UNUSED_D4; // MCU(psw)

   glreg #(8,'h01) u0_regD1 (clk, rrstz, we['hd1], wdat, regD1); // GPIO5, pulldown
   assign r_exist1st = regD1[7];
   assign r_ordrs4 = regD1[6];
   assign r_strtch = regD1[5]; // HWI2C SCL stretch
   assign r_bclk_sel = regD1[4];
   assign r_gpio_tm = regD1[3];

   assign regD2 = i_i2c_rwbuf; // RWBUF
   glreg #(8,'h11) u0_regD3 (clk, rrstz, we['hd3], wdat, regD3); // GPIO34, pulldown

// OSCCTL begin ////////////////////////////////////////////////////////////////
   reg [2:0] oscdwn_shft; // shift counter for turning osc down
   wire oscdwn_en = oscdwn_shft[2];
   wire all_idle = bus_idle & (regD4[2:0]=='h2 | ictlr_idle); // MCU can run in OSC_LOW
   wire ps_oscdwn_en = oscdwn_shft[1] & all_idle;
   always @(posedge clk)
      oscdwn_shft <= {ps_oscdwn_en, oscdwn_shft[0], |regD4[2:0]}; // sync.

   wire as_p0_chg = |((di_p0^ff_p0) & regDE); // async. setDF
   glreg #(3) u4_regD4 (clk, rrstz, we['hd4], wdat[7:5], regD4[7:5]); // OSCCTL
   wire wkup_osc_low  = regD4[5]; // don't clear OSC_LOW by wake-up for wake-up-to-100KHz
   wire wkup_by_rddet = regD4[6];
   wire wkup_by_stbov = regD4[7];
   wire dmf_wkup = dm_fault & dnchk_en;
   AND2X1 U0_MASK_0 (.A(oscdwn_en),      .B(as_p0_chg),.Y(p0_chg_clr));
   AND2X1 U0_MASK_1 (.A(wkup_by_stbov),  .B(di_stbovp),.Y(di_stbovp_clr));
   AND2X1 U0_MASK_2 (.A(wkup_by_rddet),  .B(di_rd_det),.Y(di_rd_det_clr));
   AND2X1 U0_MASK_3 (.A(wkup_by_dnfault),.B(dmf_wkup), .Y(dm_fault_clr));
   wire auto_clr = ~rrstz | (p0_chg_clr // async. clear OSC STOP/LOW/GATE
			| di_rd_det_clr
			| di_stbovp_clr
			| dm_fault_clr
			| i_tmrf);
   wire pwrdn_rstz    = atpg_en | ~(auto_clr); // also clear OCDRV_ENZ
   wire osc_gate_rstz = atpg_en | ~(auto_clr);
   wire osc_stop_rstz = atpg_en | ~(auto_clr);

   AND2X1 U0_MASK_4 (.A(wkup_osc_low), .B(auto_clr), .Y(osc_low_clr));
   wire osc_low_rstz  = atpg_en | ~osc_low_clr & rrstz;

   glreg #(2) u3_regD4 (clk, pwrdn_rstz,    we['hd4], wdat[4:3], regD4[4:3]); // OSCCTL:PWRDN/OCDRV_ENZ
   glreg #(1) u2_regD4 (clk, osc_gate_rstz, we['hd4], wdat[2],   regD4[2]); // OSCCTL:osc_gate
   glreg #(1) u1_regD4 (clk, osc_low_rstz,  we['hd4], wdat[1],   regD4[1]); // OSCCTL:OSC_LOW
   glreg #(1) u0_regD4 (clk, osc_stop_rstz, we['hd4], wdat[0],   regD4[0]); // OSCCTL:OSC_STOP
   assign r_osc_stop  = regD4[0] & oscdwn_en; // to control OSC
   assign r_osc_lo    = regD4[1] & oscdwn_en; // to control OSC
     wire r_pos_gate  = regD4[2] & oscdwn_en; // set '1' for gating OSC
   assign r_pwrdn     = regD4[3] & oscdwn_en;
   assign r_ocdrv_enz = regD4[4] & oscdwn_en;

   wire ps_regD4_3 = we['hd4] & wdat[3];
   assign ps_pwrdn = ps_regD4_3 & ps_oscdwn_en;

   reg [3:0] osc_gate_n;
   assign r_osc_gate = |osc_gate_n; // 20210514 from CAN1123
   always @(negedge xclk or negedge xrstz)
      if (~xrstz) osc_gate_n <= 'h0;
      else osc_gate_n <= {osc_gate_n[2:0],r_pos_gate};
// OSCCTL end //////////////////////////////////////////////////////////////////

   glreg #(8,'hf0) u0_regD5 (clk, rrstz, we['hd5], wdat, regD5); // GPIOP
   glreg #(8,'h98) u0_regD6 (clk, rrstz, we['hd6], wdat, regD6); // GPIOSL
   glreg #(8,'h32) u0_regD7 (clk, rrstz, we['hd7], wdat, regD7); // GPIOSH
   assign r_gpio_ie = ~{regD3[7],regD3[3]};
   assign r_gpio_oe = {regD1[2],regD3[6],regD3[2],regD7[7],regD7[3],regD6[7],regD6[3]};
   assign r_gpio_pu = {regD1[1],regD3[5],regD3[1],regD5[7:4]};
   assign r_gpio_pd = {regD1[0],regD3[4],regD3[0],regD5[3:0]};
   assign r_gpio_s0 = regD6[2:0];
   assign r_gpio_s1 = regD6[6:4];
   assign r_gpio_s2 = regD7[2:0];
   assign r_gpio_s3 = regD7[6:4];

   assign regD8 = `UNUSED_D4; // MCU(adcon)

   glreg u0_regD9 (clk, rrstz, we['hd9], wdat, regD9); // ATM
   assign r_ana_tm = regD9[7:4]; // analog test mode
   assign r_fortxdat = regD9[3]; // force TX_DAT when r_fortxrdy=1
   assign r_fortxrdy = regD9[2]; // force to select r_fortxdat
   assign r_fortxen = regD9[1]; // force turn-on TX_EN
   assign r_sleep = regD9[0];

   assign regDA = `UNUSED_D4; // MCU(i2cdat)
   assign regDB = `UNUSED_D4; // MCU(i2cadr)
   assign regDC = `UNUSED_D4; // MCU(i2ccon)
   assign regDD = `UNUSED_D4; // MCU(i2csta)

   glreg u0_regDE (clk, rrstz, we['hde], wdat, regDE); // P0MSK

   reg [7:0] d_p0;
   always @(posedge clk or negedge rrstz)
      if (~rrstz) d_p0 <= 'h0;
             else d_p0 <= ff_p0;
   wire [7:0] setDF = d_p0^ff_p0;
   wire [7:0] clrDF = {8{we['hdf]}} & wdat;
   glsta u0_regDF (clk, rrstz, 1'h0, setDF, clrDF, regDF, irqDF); // P0STA

   assign dbgpo = {reg15,reg07,reg04,reg03};

// =======================================
// CAN1121 registers
   assign reg80 = `UNUSED_D4; // MCU(p0)
   assign reg81 = `UNUSED_D4; // MCU(sp)
   assign reg82 = `UNUSED_D4; // MCU(dpl)
   assign reg83 = `UNUSED_D4; // MCU(dph)
   assign{reg84,r_cvcwr[0]} = {r_cvofs[ 7:0],we['h84]}; // CVOFS01
   assign{reg85,r_cvcwr[1]} = {r_cvofs[15:8],we['h85]}; // CVOFS23
   assign reg86 = `UNUSED_D4; // MCU(wdtrel)
   assign reg87 = `UNUSED_D4; // MCU(pcon)

   assign reg88 = `UNUSED_D4; // MCU(tcon)
   assign reg89 = `UNUSED_D4; // MCU(tmod)
   assign reg8A = `UNUSED_D4; // MCU(tl0)
   assign reg8B = `UNUSED_D4; // MCU(tl1)
   assign reg8C = `UNUSED_D4; // MCU(th0)
   assign reg8D = `UNUSED_D4; // MCU(th1)
   assign reg8E = `UNUSED_D4; // MCU(ckcon)
   assign{reg8F,r_cvcwr[2]} = {r_sdischg,we['h8f]}; // SDISCHG

   assign{reg90,r_dacwr[13]} = {r_adofs,we['h90]}; // ADOFS
   assign{reg91,r_dacwr[14]} = {r_isofs,we['h91]}; // ISOFS
   assign reg92 = `UNUSED_D4; // MCU(dps)
   assign reg93 = `UNUSED_D4; // MCU(dpc)
   glreg #(3) u0_reg94 (clk, rrstz, we['h94], wdat[6:4], reg94[6:4]); // LDBPRO
   wire ovp_dbsel = reg94[4];
   wire scp_dbsel = reg94[5];
   assign r_otpi_gate = reg94[6] & reg94[7];
   assign reg95 = fcp_r_tui;
   assign reg96 = r_accctl;
   assign reg97 = fcp_r_acc;

   assign reg98 = `UNUSED_D4; // MCU(s0con)
   assign reg99 = `UNUSED_D4; // MCU(s0buf)
   assign reg9A = `UNUSED_D4; // MCU(ie2)
   assign reg9B = fcp_r_ctl,
          reg9C = fcp_r_sta,
          reg9D = fcp_r_msk,
          reg9E = fcp_r_dat,
          reg9F = fcp_r_crc;
   assign r_fcpwr = {we['h96],we['h9f],we['h95],we['h9e:'h9b]};
   assign r_fcpre = sfr_r & hit['h97];

   assign regA0 = `UNUSED_D4; // MCU(p2)
   glreg u0_regA1 (clk, rrstz, we['ha1], wdat, regA1); // DPDNCTL
   assign r_dpdmctl = regA1;

   glreg u0_regA2 (clk, rrstz, we['ha2], wdat, regA2); // REGTRM0
   glreg u0_regA3 (clk, rrstz, we['ha3], wdat, regA3); // REGTRM1
   glreg u0_regA4 (clk, rrstz, we['ha4], wdat, regA4); // REGTRM2
   glreg u0_regA5 (clk, rrstz, we['ha5], wdat, regA5); // REGTRM3
   glreg u0_regA6 (clk, rrstz, we['ha6], wdat, regA6); // REGTRM4
   glreg u0_regA7 (clk, rrstz, we['ha7], wdat, regA7); // REGTRM5 (AOPT)
   assign r_ana_opt = {regA7,regA6,regA5,regA4,regA3,regA2};

   assign regA8 = `UNUSED_D4; // MCU(ie0)
   assign regA9 = `UNUSED_D4; // MCU(ip0)
   assign regAA = `UNUSED_D4; // MCU(s0rell)
   
   glreg u0_regAB (clk, rrstz, we['hab], wdat, regAB);
   wire [7:0] ccofs = regAB;
   glreg #(8,'d40) u0_regAC (clk, rrstz, we['hac], wdat, regAC); // PWR_I  7->8bit default =1A 
   wire[7:0] dac2_code = regAC+ccofs;
   assign r_pwr_i = dac2_code;

   wire [7:0] clrAE = {8{we['hae]}} & wdat;
   wire [7:0] setAE;
   dbnc #(4,14) // 14~15 *2ms +sync
	u1_cf_db   (.o_dbc(reg94[3]),.o_chg(),.i_org(srci[3]),.clk(clk_500),.rstz(rrstz)),
        u2_ovp_db  (.o_dbc(reg94[2]),.o_chg(),.i_org(srci[2]),.clk(clk_500),.rstz(rrstz)),
        u1_ocp_db  (.o_dbc(reg94[1]),.o_chg(),.i_org(srci[1]),.clk(clk_500),.rstz(rrstz)),
        u1_uvp_db  (.o_dbc(reg94[0]),.o_chg(),.i_org(srci[0]),.clk(clk_500),.rstz(rrstz)); 
   dbnc // #(4,15) debounce 15~16 *2us +sync
        u0_iddi_db (.o_dbc(regAD[6]),.o_chg(setAE[6]), .i_org(id_di),    .clk(clk_500k),.rstz(rrstz)), // ccddovp (DPDN_CC_OVP)
        u1_ovp_db  (.o_dbc(m_ovp),   .o_chg(m_ovp_sta),.i_org(srci[2]),  .clk(clk_500k),.rstz(rrstz));
   dbnc #(3,5) // debounce 5~6 *2/3us +sync
	u0_cf_db   (.o_dbc(regAD[3]),.o_chg(setAE[3]), .i_org(srci[3]),  .clk(clk_1500k),.rstz(rrstz)),
	u0_ocp_db  (.o_dbc(regAD[1]),.o_chg(setAE[1]), .i_org(srci[1]),  .clk(clk_1500k),.rstz(rrstz)),
	u0_uvp_db  (.o_dbc(regAD[0]),.o_chg(setAE[0]), .i_org(srci[0]),  .clk(clk_1500k),.rstz(rrstz)),
        u1_scp_db  (.o_dbc(m_scp),   .o_chg(m_scp_sta),.i_org(srci[4]),  .clk(clk_1500k),.rstz(rrstz)),
	u0_dmf_db  (.o_dbc(regAD[7]),.o_chg(setAE[7]), .i_org(dm_fault), .clk(clk_1500k),.rstz(rrstz));
   dbnc #(2,2) // 2~3T (3 samples) +sync
	u0_otpi_db (.o_dbc(reg94[7]),.o_chg(),         .i_org(srci[6]),  .clk(clk),.rstz(rrstz)), // OTPI
	u0_cc1_db  (.o_dbc(s_cci2c1),.o_chg(),         .i_org(cc1_di),   .clk(clk),.rstz(rrstz)),
	u0_cc2_db  (.o_dbc(s_cci2c2),.o_chg(),         .i_org(cc2_di),   .clk(clk),.rstz(rrstz)),
	u0_ovp_db  (.o_dbc(s_ovp),   .o_chg(s_ovp_sta),.i_org(srci[2]),  .clk(clk),.rstz(rrstz)),
	u0_scp_db  (.o_dbc(s_scp),   .o_chg(s_scp_sta),.i_org(srci[4]),  .clk(clk),.rstz(rrstz)),
	u0_v5oc_db (.o_dbc(regAD[5]),.o_chg(setAE[5]), .i_org(srci[5]),  .clk(clk),.rstz(rrstz));

   assign regAD[2] = ovp_dbsel ? m_ovp : s_ovp ;
   assign regAD[4] = scp_dbsel ? m_scp : s_scp ;
   assign setAE[2] = ovp_dbsel ? m_ovp_sta : s_ovp_sta ;
   assign setAE[4] = scp_dbsel ? m_scp_sta : s_scp_sta ;

   glsta u0_regAE (clk, rrstz, 1'h0, setAE, clrAE, regAE, irqAE); // PROSTA
   wire gating_pwr = |{regAE[4]&regAF[4],regAE[2]&regAF[2]}; // sync./async. B0ECO
   wire gating_vconn = regAE[5]&regAF[5] | regAD[5]&i_vcbyval; // gating VCONN by value

   glreg u0_regAF (clk, rrstz, we['haf], wdat, regAF); // PROCTL

   assign regE0 = `UNUSED_D4; // MCU(acc)
   assign regE1 = dac_r_comp; // sync./de-glitch COMPI
   assign {regE2,r_dacwr[12]} = {dac_r_cmpsta,we['he2]}; // CMPSTA

   glreg u0_regE3 (clk, rrstz, we['he3], wdat, regE3); // SRCCTL
   assign r_srcctl = {
           regE3[7:4],regE3[3:2]&{2{~gating_vconn}},
           regE3[1],  regE3[0]&~gating_pwr}; // gating PWR_EN, FW case should be handled by FW  

   assign wkup_by_dnfault = regE3[7];
   assign aswkup = auto_clr;

   wire [3:0] lt_regE4_3_0; // latch PWR_V_LSB when writing
   glreg #(4,'h4) u1_regE4 (clk, rrstz, r_pwrv_upd, lt_regE4_3_0, regE4[3:0]); // real PWRCTL[3:0]
   glreg #(8,'h4) u0_regE4 (clk, rrstz, we['he4], wdat, {regE4[7:4],lt_regE4_3_0}); // PWRCTL
   glreg #(8,'h1f) // 500(12'h1F4h) for 500mV (2046 for 2046mV)
                  u0_regE5 (clk, rrstz, we['he5], wdat, regE5); // PWR_V
   assign r_pwrctl = regE4[7:4];
   assign r_fw_pwrv = {regE5,regE4[3:0]}; // [330,2100] for [330mV,2100mV] of DAC0+DAC3
   assign r_pwrv_upd = we['he5];

   glreg u0_regE6 (clk, rrstz, we['he6], wdat, regE6); // CCRX
   assign r_ccrx = regE6;

   glreg u0_regE7 (clk, rrstz, we['he7], wdat, regE7); // CCCTL
   assign r_ccctl = regE7;

   glreg u0_regE8 (clk, rrstz, we['he8], wdat, regE8); // CMPOPT
   assign r_comp_opt = regE8;

   assign regE9 = `UNUSED_D4; // MCU(md0)
   assign regEA = `UNUSED_D4; // MCU(md1)
   assign regEB = `UNUSED_D4; // MCU(md2)
   assign regEC = `UNUSED_D4; // MCU(md3)
   assign regED = `UNUSED_D4; // MCU(md4)
   assign regEE = `UNUSED_D4; // MCU(md5)
   assign regEF = `UNUSED_D4; // MCU(arcon)

   assign regF0 = `UNUSED_D4; // MCU(b)
   assign {regF1,r_dacwr[8]} = {dac_r_ctl,we['hf1]}; // DACCTL
   assign {regF2,r_dacwr[9]} = {r_dac_en,we['hf2]}; // DACEN
   assign {regF3,r_dacwr[10]} = {r_sar_en,we['hf3]}; // SAREN
   assign {regF4,r_dacwr[11]} = {{s_cci2c2,x_daclsb[5:3],
                                  s_cci2c1,x_daclsb[2:0]},we['hf4]}; // DACLSB

   glreg u0_regF5 (clk, rrstz, we['hf5], wdat, regF5); // CVCTL
   assign r_cvctl = regF5;

   glreg u0_regF6 (clk, rrstz, we['hf6], wdat, regF6); // CCTRX
   assign r_cctrx = regF6;
   assign regF7 = `UNUSED_D4; // MCU(srst)
   assign {regFF,regFE,regFD,regFC,regFB,regFA,regF9,regF8} = dac_r_vs;
   assign r_dacwr[7:0] = we['hff:'hf8];

endmodule // regbank

