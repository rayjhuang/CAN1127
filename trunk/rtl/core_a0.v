
module core_a0 (
// =============================================================================
// USBPD project
// architecture with a MCU
// new version since Apr.2015
// 2018/01/09 copy from CAN1110
// ALL RIGHTS ARE RESERVED
// =============================================================================
input	[5:0]	SRCI,
input	[4:0]	XANAV,
output	[15:0]	BCK_REGX,
output	[15:0]	ANA_REGX,	// XANA1,XANA0
output		LFOSC_ENB,	// XANA2[7]
		STB_RP,		// XANA2[3] ^ DRP_OSC
		RD_ENB,		// XANA2[2] ^ DRP_OSC
		OCP_SEL,	// XANA2[1]
		PWREN_HOLD,	// XANA2[0]
input		CC1_DI,  CC2_DI, DRP_OSC, IMP_OSC,
output		CC1_DOB, CC2_DOB, DAC1_EN, SH_RST, SH_HOLD, LDO3P9V, // IDAC_EN, IDAC_SEN,
output	[3:0]	XTM,
output	[7:0]	DO_CVCTL, DO_CCTRX, DO_SRCCTL, DO_CCCTL,
output	[10:0]	DO_DAC0,
output	[5:0]	DO_DPDN,
output	[3:0]	DO_VOOC,
output	[7:0]	DO_PWR_I,
// -----------------------------------------------------------------------------
output	[15:0]	PMEM_A,
input	[7:0]	PMEM_Q0, PMEM_Q1,
output	[1:0]	PMEM_TWLB, PMEM_SAP, PMEM_CLK,
output		PMEM_CSB, PMEM_RE, PMEM_PGM, VPP_SEL, VPP_0V,
// -----------------------------------------------------------------------------
output		SRAM_WEB, SRAM_CEB, SRAM_OEB, SRAM_CLK,
output	[10:0]	SRAM_A,
output	[7:0]	SRAM_D,
input	[7:0]	SRAM_RDAT,
// -----------------------------------------------------------------------------
input		RX_DAT, RX_SQL,
		RD_DET, STB_OVP,
output		TX_DAT, TX_EN,
		OSC_STOP, OSC_LOW,
		SLEEP, PWRDN, OCDRV_ENZ,
output	[9:0]	DAC1_V,
output	[17:0]	SAMPL_SEL,
input		DAC1_COMP,
output		CCI2C_EN,
output	[3:0]	ANA_TM,
input		DM_FAULT, DM_COMP, DP_COMP,
input	[6:0]	DI_GPIO,
output	[6:0]	DO_GPIO, OE_GPIO, GPIO_PU, GPIO_PD,
output	[1:0]	GPIO_IE,
output	[3:0]	DO_TS,
input		DI_TS,
output	[55:0]	REGTRM,
output	[7:0]	ANAOPT, DUMMY_IN,
output  [5:0]   DAC3_V,
input		i_clk, i_rstz,
		atpg_en, di_tst,
output		tm_atpg
`ifdef FPGA
,
input		i_s0_rx,
output		o_s0_tx, do_s0rx, oe_s0rx, o_cpurst,
output	[15:0]	memaddr, memaddr_c,
output	[7:0]	memdatao_c, memdatao,
output		mempswr_c, mempswr, memwr_c,
input		hit_mo,
input	[7:0]	monm_rdat,
input	[15:0]	pc_ini,
output	[31:0]	dbgpo,
input	[3:0]	dbgsel
`endif // FPGA
);
`ifdef FPGA
   wire tclk_sel, x_clk;
   wire #2 mclk = i_clk; // clock tree
   wire sram_clk = mclk;
   wire s0_rx_d4 = i_s0_rx;
`else // !FPGA
   wire	[15:0]	memaddr_c, memaddr;
   wire	[7:0]	memdatao_c, memdatao;
   wire		o_cpurst,
		o_s0_tx,
		memwr_c,
		mempswr_c, mempswr;
   wire		hit_mo = 1'h0,
		s0_rx_d4 = 1'h1;
   wire	[7:0]	monm_rdat = 8'h0;
   wire	[15:0]	pc_ini = 16'h0;

   // don't touch U0_ prefixed cells hierarchically
   parameter BAL_DELAY = 10;
   wire aswclk, detclk; // to delay the latching clock for balance and debounce
   wire [BAL_DELAY-1:0] aswclk_ps, detclk_ps;
   CKBUFX1 U0_ASWCLK_BUF [BAL_DELAY-1:0] (.A(aswclk_ps),.Y({aswclk,aswclk_ps[BAL_DELAY-1:1]}));
   CKBUFX1 U0_DETCLK_BUF [BAL_DELAY-1:0] (.A(detclk_ps),.Y({detclk,detclk_ps[BAL_DELAY-1:1]}));

   // don't touch U0_ prefixed cells hierarchically
   AND2X1   U0_SCAN_EN (.A(DI_GPIO[2]),.B(atpg_en),.Y());
   CKMUX2X1 U0_CLK_MUX (.D1(DI_GPIO[4]),.D0(i_clk), .S(tclk_sel),.Y(s_clk));
   CKMUX2X1 U0_DCLKMUX (.D1(DI_GPIO[4]),.D0(RD_DET),.S(tclk_sel),.Y(detclk_ps[0]));
   CKMUX2X1 U0_ACLKMUX (.D1(DI_GPIO[4]),.D0(aswkup),.S(tclk_sel),.Y(aswclk_ps[0]));
   CKBUFX1  U0_MCK_BUF (.A(i_clk),.Y(x_clk)); // output to debug, don't balance, for disable timing
   CKBUFX1  U0_TCK_BUF (.A(DI_GPIO[4]),.Y(t_di_gpio4)); // for di_gpio4 in atpg
// CLKBUFX1 U0_TCK_BUF (.A(DI_GPIO[4]),.Y(tclk)); // for ideal network

   wire r_osc_gate;
   wire #3 osc_en = ~r_osc_gate; // propagation delay for the hold time requirement
   CLKDLX1 U0_MCLK_ICG (.E(osc_en),.CK(s_clk),.SE(atpg_en),.ECK(g_clk));
   wire #2 mclk = g_clk; // clock tree latancy

   wire xram_ce, iram_ce;
   assign #1 sram_en = xram_ce | iram_ce; // propagation delay for the hold time requirement
   CLKDLX1 U0_SRAM_ICG (.E(sram_en),.CK(mclk),.SE(atpg_en),.ECK(sram_clk));
`endif // FPGA

   wire [7:0] sfr_rdat, sfr_wdat;
   wire [6:0] sfr_adr;

   wire [7:0] idat_wdat, idat_adr;
   wire [7:0] esfrm_rdat, esfrm_wdat, prx_fifowdat, prl_cany0adr, sse_wdat, sse_adr;
   wire [7:0] delay_inst, ictlr_inst, mcu_esfrrdat;
   wire [6:0] esfrm_adr;
   wire [3:0] r_pg0_sel;

   wire [10:0] iram_a, xram_a, bist_adr;
   wire [7:0] iram_d, xram_d, bist_wdat;
   wire [7:0] sram_rdat, regx_rdat;
   wire [7:0] dma_wdat = 'h0;
   wire [10:0] dma_addr = 'h0;

   mpb u0_mpb (
	.i_rd		({prl_cany0r,sse_rd}),
	.i_wr		({prl_cany0w,sse_wr}),
	.wdat0		(sse_wdat),
	.wdat1		(prx_fifowdat),
	.addr0		(sse_adr),	// from initiator 0
	.addr1		(prl_cany0adr),	// from initiator 1
	.r_i2c_attr	(r_i2c_attr),
// -----------------------------------------------------------------------------
	.esfrm_oe	(esfrm_oe),	// to MCU (SFR mux)
	.esfrm_we	(esfrm_we),	// to MCU (SFR mux)
	.esfrm_wdat	(esfrm_wdat),	// to MCU (SFR mux)
	.esfrm_adr	(esfrm_adr),	// to MCU (SFR mux)
	.sfrack		(sfrack),	// to MCU (SFR master)
	.mcu_esfr_rdat	(mcu_esfrrdat),	// from MCU
	.delay_rdat	(delay_inst),	// from NVM controller
	.delay_rrdy	(ictlr_psrack),	// from NVM controller
	.esfrm_rrdy	(esfrm_rrdy),	// to initiators (peripheral masters)
	.esfrm_rdat	(esfrm_rdat),	// to initiators
	.channel_sel	(1'h0),
	.r_pg0_sel	(r_pg0_sel),
// -----------------------------------------------------------------------------
	.dma_w		(1'h0),
	.dma_r		(1'h0),
	.dma_addr	(dma_addr),
	.dma_wdat	(dma_wdat),
	.dma_ack	(dma_ack),
// -----------------------------------------------------------------------------
	.memwr		(memwr),
	.memrd		(memrd),
	.memrd_c	(memrd_c),
	.memaddr	(memaddr),
	.memaddr_c	(memaddr_c),
	.memdatao	(memdatao),
	.memack		(memack),
	.cpurst		(o_cpurst),
	.hit_xd		(hit_xd),	.hit_xr		(hit_xr),
	.hit_ps		(hit_ps),
	.hit_ps_c	(hit_ps_c),
	.idat_r		(mcu_ram_r),
	.idat_w		(mcu_ram_w),
	.idat_adr	(idat_adr),
	.idat_wdat	(idat_wdat),
// -----------------------------------------------------------------------------
	.iram_ce	(iram_ce),	.xram_ce	(xram_ce),	.regx_re	(regx_re),
	.iram_we	(iram_we),	.xram_we	(xram_we),	.regx_we	(regx_we),
	.iram_a		(iram_a),	.xram_a		(xram_a),
	.iram_d		(iram_d),	.xram_d		(xram_d),
	.iram_rdat	(sram_rdat),	.xram_rdat	(sram_rdat),	.regx_rdat      (regx_rdat),
	.bist_en	(bist_en),
	.bist_wr	(bist_wr),
	.bist_adr	(bist_adr),
	.bist_wdat	(bist_wdat),
	.bist_xram	(bist_xram),
// -----------------------------------------------------------------------------
	.mclk		(mclk),
	.srstz		(srstz)
   ); // u0_mpb

   wire [7:0]  sram_d =  {8{iram_we}} & iram_d |  {8{xram_we}} & xram_d;
   wire [10:0] sram_a = {11{iram_ce}} & iram_a | {11{xram_ce}} & xram_a;
   wire sram_web = ~(iram_we | xram_we);
   wire sram_ceb = ~(iram_ce | xram_ce);

   wire mempsrd, mempsrd_c;
   wire [7:0] memdatai
                = memrd&(hit_xd|hit_xr) ?(hit_xr ?regx_rdat :sram_rdat)
                :mempsrd&hit_ps ?ictlr_inst
                        :hit_mo ?monm_rdat :'hff; // non-defined area

   wire [7:0] di_p0, ff_p0, do_p0;
   wire [31:0] mcu_dbgpo;
   wire [15:0] mcu_pc = mcu_dbgpo[15:0];

   wire [4:0] sfr_intr;
   wire dac_intr, gpint1z, gpint0z;
   wire i_cpurst = ~srstz;
   wire [7:0] exint = {dac_intr,
			sfr_intr[4], // SRCSTA
			sfr_intr[1:0], // positive edge in mcu51
			~{sfr_intr[3],sfr_intr[2]}, // negative/positive edge in mcu51
			gpint1z,gpint0z}; // low/fall in mcu51

   mcu51 u0_mcu (
	.bclki2c	(r_bclk_sel),	// I
	.pc_ini		(pc_ini),	// I [15:0]
	.r_hold_mcu	(r_hold_mcu),	// I
	.slp2wakeup	(1'h0),		// I
	.wdt_slow	(1'h0),		// I
	.wdtov		(),		// O [1:0]: Watchdog Timer overflow/int wakeup
	.mdubsy		(),		// O
	.cs_run		(),		// O: cpu in RUN_STATE
	.t0_intr	(t0_intr),	// O: timer 0 over-flow and interrupt
	.clki2c		(mclk),		// I
	.clkmdu		(mclk),		// I
	.clkur0		(mclk),		// I
	.clktm0		(mclk),		// I
	.clktm1		(mclk),		// I
	.clkwdt		(mclk),		// I
	.i2c_autoack	(1'h0),		// I
	.i2c_con_ens1	(),		// O
	.clkcpu		(mclk),		// I: CPU clock input
	.clkper		(mclk),		// I: Peripheral clock input
	.reset		(i_cpurst),	// I: Hardware reset input
	.ro		(o_cpurst),	// O: Reset output
	.port0i		(di_p0),	// I [7:0]: Port inputs
	.port0ff	(ff_p0),	// O [7:0]: Port inputs sync.
	.port0o		(do_p0),	// O [7:0]: Port outputs
	.exint_9	(fcp_intr),	// I
	.exint		(exint),	// I [7:0]: fall/low, wakeup
	.clkcpuen	(),		// O: CPU clock enable output
	.clkperen	(),		// O: Peripheral clock enable output
	.rxd0i		(dpdm_urx),	// I: Serial/Port alternate signals, Serial 0 receive data
	.rxd0oe		(s0_rxdoe),	// O
	.rxd0o		(s0_rxdo),	// O: Serial/Port alternate signals, Serial 0 receive clock
	.txd0		(s0_tx),	// O: Serial/Port alternate signals, Serial 0 transmit data
	.scli		(mcui_scl),	// I: I2C clock input
	.sdai		(mcui_sda),	// I: I2C data input
	.sclo		(mcuo_scl),	// O: I2C clock output - registered
	.sdao		(mcuo_sda), 	// O: I2C data output  - registered
	.waitstaten	(waitstaten),	// O
	.mempsack	(mempsack),	// I: Memory interface
	.memack		(memack),	// I: Memory interface
	.memdatai	(memdatai),	// I [7:0]: Memory interface
	.memdatao	(memdatao),	// O [7:0]: Memory interface
	.memaddr	(memaddr),	// O [15:0]: Memory interface
	.mempswr	(mempswr),	// O: Program store write enable
	.mempsrd	(mempsrd),	// O: Program store read enable
	.memwr		(memwr),	// O: Memory write enable
	.memrd		(memrd),	// O: Memory read enable
	.memdatao_comb	(memdatao_c),	// O [7:0]: Combintional interface for posedge memories
	.memaddr_comb	(memaddr_c),	// O [15:0]: Combintional interface for posedge memories
	.mempswr_comb	(mempswr_c),	// O: Combintional interface for Program store write enable
	.mempsrd_comb	(mempsrd_c),	// O: Combintional interface for Program store read enable
	.memwr_comb	(memwr_c),	// O: Combintional interface for Memory write enable
	.memrd_comb	(memrd_c),	// O: Combintional interface for Memory read enable
	.ramdatai	(sram_rdat),	// I [7:0]: Data file interface
	.ramdatao	(idat_wdat),	// O [7:0]: Data file interface
	.ramaddr	(idat_adr),	// O [7:0]: Data file interface
	.ramwe		(mcu_ram_w),	// O: Data file write enable
	.ramoe		(mcu_ram_r),	// O: Data file output enable
	.dbgpo		(mcu_dbgpo),	// O [31:0]
	.esfrm_wrdata	(esfrm_wdat),	// I [7:0]: external SFR master bus
	.esfrm_addr	(esfrm_adr),	// I [6:0]
	.esfrm_we	(esfrm_we),	// I
	.esfrm_oe	(esfrm_oe),	// I
	.esfrm_rddata	(mcu_esfrrdat),	// O [7:0]
	.sfrdatai	(sfr_rdat),	// I [7:0]: external SFR bus
	.sfrack		(sfrack),	// I
	.sfrdatao	(sfr_wdat),	// O [7:0]
	.sfraddr	(sfr_adr),	// O [6:0]
	.sfrwe		(sfr_w),	// O
	.sfroe		(sfr_r)		// O
   ); // u0_mcu

   wire [15:0] pmem_a;
   wire [14:0] bkpt_pc, r_inst_ofs;
   wire [7:0] pmem_q0, pmem_q1;
   wire [1:0] pmem_clk, pmem_twlb, wd_twlb;

   ictlr u0_ictlr (
	.hit_ps		(hit_ps),
	.hit_ps_c	(hit_ps_c),
	.memaddr	(memaddr[14:0]),
	.memaddr_c	(memaddr_c[14:0]),
	.memdatao	(memdatao),
	.mempsack	(ictlr_psack),
	.mcu_psw	(mempswr),
	.mcu_psr_c	(mempsrd_c),
	.o_inst		(ictlr_inst),	// to MCU/SRF
	.o_ofs_inc	(ictlr_inc),	// to SRF
	.o_set_hold	(set_hold),	// to SFR
	.o_bkp_hold	(bkpt_hold),	// to SFR
	.bkpt_pc	(bkpt_pc),
	.bkpt_ena	(bkpt_ena),
	.d_inst		(delay_inst),	// to I2CSLV (via MPB)
	.sfr_psrack	(ictlr_psrack),
	.sfr_psofs	(r_inst_ofs),
	.sfr_psr	(r_psrd),
	.sfr_psw	(r_pswr),
	.dw_ena		(prl_cany0),	// dummy write
	.dw_rst		(prl_c0set),	// dummy write
	.sfr_wdat	(sfr_wdat),

	.pmem_pgm	(pmem_pgm),
	.pmem_re	(pmem_re),
	.pmem_csb	(pmem_csb),
	.pmem_clk	(pmem_clk),
	.pmem_a		(pmem_a),
	.pmem_q0	(pmem_q0),
	.pmem_q1	(pmem_q1),
	.pmem_twlb	(pmem_twlb),
	.we_twlb	(we_twlb),
	.wd_twlb	(wd_twlb),

	.r_multi	(r_otp_wpls),
	.pwrdn_rst	(pwrdn_rst),
	.r_pwdn_en	(r_otp_pwdn_en),
	.r_hold_mcu	(r_hold_mcu),
	.clk		(mclk),
//	.rstz		(srstz),
	.srst		(o_cpurst)
   ); // u0_ictlr

   assign mempsack = hit_ps
                   ? ictlr_psack
                   : (mempsrd|mempswr) &~o_cpurst; // to include non-defined area

   wire [6:0]	r_fcpwr;
   wire [7:0]	fcp_r_dat, fcp_r_sta, fcp_r_msk, fcp_r_ctl, fcp_r_crc, fcp_r_acc, r_accctl, fcp_r_tui;

   wire [14:0]	sfr_dacwr;
   wire [5:0]	x_daclsb; // bit un-positioned
   wire [8*18-1:0] dac_r_vs; // 18-channel CAN1127
   wire [17:0]	r_dac_en, r_sar_en, dac_r_comp; // 18-channel CAN1127
   wire [7:0]	dac_r_ctl, dac_r_cmpsta;
   wire [7:0]	r_adofs, r_isofs;

   wire [7:0]	i2c_ev, i2c_rwbuf, i2c_ltbuf, i2c_lt_ofs;
   wire [7:1]	r_i2c_deva;

   wire [1:0]	r_gpio_ie;
   wire [6:0]	r_pu_gpio, r_pd_gpio, r_gpio_oe, oe_gpio, do_gpio;
   wire [3:0]	lt_gpi;
   wire [2:0]	gpio_s0, gpio_s1, gpio_s2, gpio_s3;

   wire [31:0]	sfr_dbgpo;
   wire [3:0]	r_ana_tm;
   wire [55:0]	r_regtrm;
   wire [6:0]	REVID;
   wire [7:0]	r_ccrx, r_cvctl, r_ccctl, r_cctrx,
		r_dpdmctl, r_srcctl, r_pwr_i;
   wire [10:0]	dac0_code;
   wire [11:0]	r_fw_pwrv;

   wire [15:0]	pff_rxpart;
   wire [7:0]	pff_rdat;
   wire [6:0]	r_rxords_ena, prx_setsta, r_txauto;
   wire [5:0]	pff_ptr, prx_adpn, di_pro;
   wire [4:0]	r_txnumk, prx_rcvinf;
   wire [3:0]	prx_fsm, prl_fsm;
   wire [2:0]	ptx_fsm, prl_cpmsgid;
   wire [1:0]	r_spec, r_dat_spec, r_auto_gdcrc, pff_ack, prx_rst;
   wire [5:0]	r_dac3;
   wire [15:0]	r_cvofs;
   wire [7:0]	r_comp_opt;
   wire [5:0]	r_cvcwr; // u0_cvctl write

   wire ramacc = mcu_ram_r | mcu_ram_w;
   wire [1:0] r_sqlch = r_ccrx[7:6];
   wire r_adprx_en = r_ccrx[3];
   wire r_adp2nd   = r_ccrx[2];
   wire [1:0] r_rxdb_opt = r_ccrx[1:0];

   wire [7:4] r_pwrctl;
   wire r_ur_dp = r_pwrctl[7];
   wire r_ur_dm = r_pwrctl[6];

   regbank u0_regbank (
	.srci		(di_pro), // {V5OCP,SCP,OTPI,OVP,OCP,UVP}
	.aswkup		(aswkup),
	.dnchk_en	(dnchk_en),
	.dm_fault	(dm_fault), // anatop_can1112b0
	.di_rd_det	(di_rd_det),
	.di_stbovp	(di_stbovp),
	.cc1_di		(cc1_di),
	.cc2_di		(cc2_di),
	.i_tmrf		(t0_intr),
	.i_vcbyval	(r_vcbyval),
	.r_bclk_sel	(r_bclk_sel),
//	.r_cablecmp	(),
	.r_cvctl	(r_cvctl),
	.r_sleep	(r_sleep),
	.ps_pwrdn	(ps_pwrdn),
	.r_pwrdn	(r_pwrdn),
	.r_ocdrv_enz	(r_ocdrv_enz),
	.r_osc_stop	(r_osc_stop),
	.r_osc_lo	(r_osc_lo),
	.r_osc_gate	(r_osc_gate),
	.r_pwr_i	(r_pwr_i),
	.r_srcctl	(r_srcctl),
	.r_pwrctl	(r_pwrctl),
	.r_dpdmctl	(r_dpdmctl),
	.r_pwrv_upd	(r_pwrv_upd),
	.r_fw_pwrv	(r_fw_pwrv),

	.r_cvcwr	(r_cvcwr[1:0]),
	.r_cvofs	(r_cvofs),
	.r_otpi_gate	(r_otpi_gate),
	.r_ccrx		(r_ccrx),
	.r_cctrx	(r_cctrx),
	.r_ccctl	(r_ccctl),

	.r_fcpre	(r_fcpre),
	.r_fcpwr	(r_fcpwr),
	.fcp_r_dat	(fcp_r_dat),
	.fcp_r_sta	(fcp_r_sta),
	.fcp_r_msk	(fcp_r_msk),
	.fcp_r_ctl	(fcp_r_ctl),
	.fcp_r_crc	(fcp_r_crc),
	.fcp_r_acc	(fcp_r_acc),
        .fcp_r_tui      (fcp_r_tui),
	.r_accctl	(r_accctl),
	.r_comp_opt	(r_comp_opt),
	.r_dacwr	(sfr_dacwr),
	.r_dac_en	(r_dac_en[7:0]),
	.r_sar_en	(r_sar_en[7:0]),
        .r_isofs        (r_isofs),
	.r_adofs	(r_adofs),
	.dac_r_ctl	(dac_r_ctl),
	.dac_r_cmpsta	(dac_r_cmpsta),
	.dac_r_comp	(dac_r_comp[7:0]),
	.dac_r_vs	(dac_r_vs[8*8-1:0]), // the first 8 channels
	.x_daclsb	(x_daclsb),
	.REVID		(REVID),
	.atpg_en	(atpg_en),
	.sfr_r		(sfr_r),
	.sfr_w		(sfr_w),
	.sfr_addr	({1'h1,sfr_adr}),
	.sfr_wdat	(sfr_wdat),
	.sfr_rdat	(sfr_rdat),
	.set_hold	(set_hold),
	.bkpt_hold	(bkpt_hold),
	.cpurst		(o_cpurst),
	.ictlr_idle	(ictlr_idle),
	.ictlr_inc	(ictlr_inc),
	.ff_p0		(ff_p0),
	.di_p0		(di_p0),
	.r_pswr		(r_pswr),
	.r_psrd		(r_psrd),
	.r_inst_ofs	(r_inst_ofs),
	.r_fortxdat	(r_fortxdat),
	.r_fortxrdy	(r_fortxrdy),
	.r_fortxen	(r_fortxen),
	.r_gpio_tm	(r_gpio_tm),
	.r_gpio_pu	(r_pu_gpio),
	.r_gpio_pd	(r_pd_gpio),
	.r_gpio_oe	(r_gpio_oe),
	.r_gpio_ie	(r_gpio_ie),
	.r_gpio_s0	(gpio_s0),
	.r_gpio_s1	(gpio_s1),
	.r_gpio_s2	(gpio_s2),
	.r_gpio_s3	(gpio_s3),
	.r_regtrm	(r_regtrm),
	.r_ana_tm	(r_ana_tm),
	.o_intr		(sfr_intr),
	.i_pc		(mcu_pc),
	.i_goidle	(pid_goidle),
	.i_gobusy	(pid_gobusy),
	.bus_idle	(bus_idle),
	.i_i2c_idle	(sse_idle),
	.i_i2c_rwbuf	(i2c_rwbuf),
	.i_i2c_ltbuf	(i2c_ltbuf),
	.i_i2c_ofs	(i2c_lt_ofs),
	.r_exist1st	(r_exist1st),
	.r_ordrs4	(r_ordrs4),
	.r_fifopsh	(r_fifopsh),
	.r_fifopop	(r_fifopop),
	.r_unlock	(r_unlock),
	.r_first	(r_first),
	.r_last		(r_last),
	.r_fiforst	(r_fiforst),
	.r_set_cpmsgid	(r_set_cpmsgid),
	.r_txnumk	(r_txnumk),
	.r_txendk	(r_txendk),
	.r_txshrt	(r_txshrt),
	.r_auto_gdcrc	(r_auto_gdcrc),
	.r_auto_discard	(r_auto_discard),
	.r_spec		(r_spec),
	.r_dat_spec	(r_dat_spec),
	.r_dat_portrole	(r_dat_portrole),
	.r_dat_datarole	(r_dat_datarole),
	.r_hold_mcu	(r_hold_mcu),
	.r_txauto	(r_txauto),
	.r_rxords_ena	(r_rxords_ena),
	.r_pshords	(r_pshords),
	.r_discard	(r_discard),
	.r_strtch	(r_strtch),
	.r_i2c_deva	(r_i2c_deva),
	.r_hwi2c_en	(), // replaced by r_i2crout in CAN1126
	.r_i2c_ninc	(r_i2c_ninc),
	.r_i2c_fwnak	(r_i2c_fwnak),
	.r_i2c_fwack	(r_i2c_fwack),
	.r_i2c_attr	(r_i2c_attr),
	.r_pg0_sel	(r_pg0_sel),
	.i2c_stretch	(hwi2c_stretch), // added in CAN1127
	.i2c_ev		(i2c_ev),
	.prl_cany0	(prl_cany0),
	.prl_c0set	(prl_c0set),
	.prl_cpmsgid	(prl_cpmsgid),
	.prl_discard	(prl_discard),
	.prl_GCTxDone	(prl_GCTxDone),
	.pff_ack	(pff_ack),
	.pff_rdat	(pff_rdat),
	.pff_rxpart	(pff_rxpart),
	.pff_obsd	(pff_obsd),
	.pff_empty	(pff_empty),
	.pff_full	(pff_full),
	.pff_ptr	(pff_ptr),
	.ptx_ack	(ptx_ack),
	.prx_setsta	(prx_setsta),
	.prx_rst	(prx_rst),
	.prx_rcvinf	(prx_rcvinf),
	.prx_adpn	(prx_adpn),
	.prx_fsm	(prx_fsm),
	.ptx_fsm	(ptx_fsm),
	.prl_fsm	(prl_fsm),
	.dbgpo		(sfr_dbgpo),
	.clk_1500k	(clk_1500k),
	.clk_500k	(clk_500k),
	.clk_500	(clk_500),
	.clk		(mclk),
	.prstz		(prstz), // output, controlled sync. reset for updphy
	.srstz		(srstz), // output, controlled sync. reset
	.xclk		(s_clk), // from clock mux, before ICG
	.xrstz		(xrstz) // from analog
   ); // u0_regbank

   assign ictlr_idle = pmem_csb;

   wire [7:0] i2cslv_dbgpo;
   wire [3:0] slvo_ev;
   wire [7:1] i2cslv_deva = r_i2c_deva;
   wire r_i2c_inc = ~r_i2c_ninc;
   wire sse_rdrdy =~prl_cany0 & esfrm_rrdy;
   wire upd_rdrdy = prl_cany0 & esfrm_rrdy;
   wire sse_pg0 = ~sse_adr[7];
   wire sse_prefetch = sse_pg0 & (r_pg0_sel != 4'd12); // shall not prefetch REGX
   i2cslv u0_i2cslv (
	.i_sda		(slvi_sda),
	.i_scl		(slvi_scl),
	.o_sda		(slvo_sda),
	.i_deva		(i2cslv_deva), // device address
	.i_inc		(r_i2c_inc), // auto increase ofset
//	.i_raw		(r_raw_ena),
	.i_fwnak	(r_i2c_fwnak),
	.i_fwack	(r_i2c_fwack),
	.o_we		(sse_wr),
	.o_re		(slvo_re),
	.o_r_early	(slvo_early),
	.o_busev	(slvo_ev),
	.o_ofs		(sse_adr),
	.o_wdat		(sse_wdat),
//	.o_rw_buf	(i2c_rwbuf),
	.o_idle		(sse_idle),
	.o_dec		(sse_dec),
	.o_lt_buf	(i2c_ltbuf),
	.o_lt_ofs	(i2c_lt_ofs),
	.o_dbgpo	(i2cslv_dbgpo),
	.i_rdat		(esfrm_rdat),
	.i_rd_mem	(sse_rdrdy),
	.i_clk		(mclk),
	.i_rstz		(srstz),
        .i_prefetch	(sse_prefetch)
   ); // u0_i2cslv

   wire scl_strtch = r_strtch & (pmem_pgm | hwi2c_stretch);
   wire cc_idle = prx_rcvinf[4]; // also in u0_regbank

   wire [5:0] r_i2crout;
   wire [1:0] r_i2cslv_route = r_i2crout[1:0]; // 0/1/2/3 : GPIO/CC12/DPDM/disable
   wire [1:0] r_i2cmcu_route = r_i2crout[3:2]; // 0/1/2/3 : GPIO/CC12/DPDM/disable
   wire r_cci2c_swap = r_i2crout[4],
        r_dpdm_swap  = r_i2crout[5];

   wire gpi2cmcu = r_i2cmcu_route=='h0; // not swappable
   wire gpi2cslv = r_i2cslv_route=='h0;
   wire do_sda = ~(gpi2cslv & ~slvo_sda  | gpi2cmcu & ~mcuo_sda);
   wire do_scl = ~(gpi2cslv & scl_strtch | gpi2cmcu & ~mcuo_scl);
   
   wire cci2cmcu = r_i2cmcu_route=='h1; // swappable
   wire cci2cslv = r_i2cslv_route=='h1;
   wire cci2c_mode = cci2cmcu | cci2cslv;
   wire ccdo_sda = ~(cci2cslv & ~slvo_sda  | cci2cmcu & ~mcuo_sda);
   wire ccdo_scl = ~(cci2cslv & scl_strtch | cci2cmcu & ~mcuo_scl);
   wire cci2c_cc1_dob = ~(r_cci2c_swap ? ccdo_scl : ccdo_sda);
   wire cci2c_cc2_dob = ~(r_cci2c_swap ? ccdo_sda : ccdo_scl);

   wire ddi2cmcu = r_i2cmcu_route=='h2; // swappable
   wire ddi2cslv = r_i2cslv_route=='h2;
   wire ddi2c_mode = ddi2cmcu | ddi2cslv;
   wire dddo_sda = ~(ddi2cslv & ~slvo_sda  | ddi2cmcu & ~mcuo_sda);
   wire dddo_scl = ~(ddi2cslv & scl_strtch | ddi2cmcu & ~mcuo_scl);
   wire ddi2c_dpdo = r_dpdm_swap ? dddo_scl : dddo_sda;
   wire ddi2c_dmdo = r_dpdm_swap ? dddo_sda : dddo_scl;

   wire dp_comp, dm_comp;
   wire ddi2c_sda_di = r_dpdm_swap ? dm_comp : dp_comp;
   wire ddi2c_scl_di = r_dpdm_swap ? dp_comp : dm_comp;
   wire cci2c_sda_di = r_cci2c_swap ? cc2_di : cc1_di;
   wire cci2c_scl_di = r_cci2c_swap ? cc1_di : cc2_di;
   wire di_sda, di_scl;
   assign mcui_sda = ~(cci2cmcu &~cci2c_sda_di | ddi2cmcu &~ddi2c_sda_di | gpi2cmcu &~di_sda);
   assign mcui_scl = ~(cci2cmcu &~cci2c_scl_di | ddi2cmcu &~ddi2c_scl_di | gpi2cmcu &~di_scl);
   assign slvi_sda = ~(cci2cslv &~cci2c_sda_di | ddi2cslv &~ddi2c_sda_di | gpi2cslv &~di_sda);
   assign slvi_scl = ~(cci2cslv &~cci2c_scl_di | ddi2cslv &~ddi2c_scl_di | gpi2cslv &~di_scl);

   assign i2c_rwbuf = sse_wdat;
   assign sse_rd = slvo_re | slvo_early;
   assign i2c_ev = {
		sse_rd,
		sse_rd & sse_pg0,
		slvo_ev[3], // STOP (P)
		slvo_ev[2], // START (S/Sr)
		sse_wr,
		sse_wr & sse_pg0,
		slvo_ev[1], // to ACK/NAK device address
		slvo_ev[0]}; // command written

   wire [31:0] upd_dbgpo;
   wire di_cc_49;
   assign di_cc = cci2c_mode ? 'h0 : di_cc_49;
   updphy #(
	.FF_DEPTH_NUM	(34),
	.FF_DEPTH_NBT	(6))
	u0_updphy (
	.i_cc		(di_cc),
	.i_cc_49	(di_cc_49),
	.i_sqlch	(di_sqlch),
	.r_sqlch	(r_sqlch),
	.r_adprx_en	(r_adprx_en),
	.r_adp2nd	(r_adp2nd),
	.r_exist1st	(r_exist1st),
	.r_ordrs4	(r_ordrs4),
	.r_fifopsh	(r_fifopsh),
	.r_fifopop	(r_fifopop),
	.r_unlock	(r_unlock),
	.r_first	(r_first),
	.r_last		(r_last),
	.r_fiforst	(r_fiforst),
	.r_set_cpmsgid	(r_set_cpmsgid),
	.r_wdat		(sfr_wdat),
	.r_txnumk	(r_txnumk),
	.r_txendk	(r_txendk),
	.r_txshrt	(r_txshrt),
	.r_spec		(r_spec),
	.r_dat_spec	(r_dat_spec),
	.r_dat_portrole	(r_dat_portrole),
	.r_dat_datarole	(r_dat_datarole),
	.r_auto_gdcrc	(r_auto_gdcrc),
	.r_auto_discard	(r_auto_discard),
	.r_txauto	(r_txauto),
	.r_rxdb_opt	(r_rxdb_opt),
	.r_rxords_ena	(r_rxords_ena),
	.r_pshords	(r_pshords),
	.r_discard	(r_discard),
	.r_rdat		(esfrm_rdat),
	.r_rdy		(upd_rdrdy),
	.pid_goidle	(pid_goidle),
	.pid_gobusy	(pid_gobusy),
	.pff_ack	(pff_ack),
	.pff_rdat	(pff_rdat),
	.pff_rxpart	(pff_rxpart),
	.pff_obsd	(pff_obsd),
	.pff_empty	(pff_empty),
	.pff_full	(pff_full),
	.pff_ptr	(pff_ptr), // DEPTH_NBT
	.ptx_cc		(ptx_cc),
	.ptx_oe		(ptx_oe),
	.ptx_ack	(ptx_ack),
	.prx_setsta	(prx_setsta),
	.prx_rst	(prx_rst),
	.prx_rcvinf	(prx_rcvinf),
	.prl_c0set	(prl_c0set),
	.prl_cany0	(prl_cany0),
	.prl_cany0r	(prl_cany0r),
	.prl_cany0w	(prl_cany0w),
	.prl_cany0adr	(prl_cany0adr),
	.prl_cpmsgid	(prl_cpmsgid),
	.prl_discard	(prl_discard),
	.prl_GCTxDone	(prl_GCTxDone),
	.prx_fifowdat	(prx_fifowdat),
	.prx_adpn	(prx_adpn),
	.prx_fsm	(prx_fsm),
	.ptx_fsm	(ptx_fsm),
	.prl_fsm	(prl_fsm),
	.dbgpo		(upd_dbgpo),
	.clk		(mclk),
	.srstz		(prstz)
   ); // u0_updphy

   wire [9:0] dac1_v;
   wire [4:0] comp_smpl;
   wire [17:0] dacmux_sel;
   wire [13:0] regx_wrdac;
   wire [7:0] r_dacwdat = (|regx_wrdac) ? xram_d : sfr_wdat;
   wire [17:0] wr_dacv = {regx_wrdac[13:12],regx_wrdac[9:2],sfr_dacwr[7:0]};
   wire [10:0] r_dacwr = {regx_wrdac[11:10],regx_wrdac[1:0],sfr_dacwr[14:8]};
   wire [2:0] r_comp_opt_7_5_ = r_comp_opt[7:5];
   dacmux u0_dacmux (
	.clk		(mclk),
	.srstz		(srstz),
	.r_adofs	(r_adofs),
	.r_isofs	(r_isofs),
	.r_comp_opt	(r_comp_opt_7_5_),
	.r_dac_en	(r_dac_en),
	.r_sar_en	(r_sar_en),
	.x_daclsb	(x_daclsb),
	.i_comp		(dac1_comp),
	.o_daci_sel	(dacmux_sel),
	.dacv_wr	(wr_dacv),
	.r_wr		(r_dacwr),
	.r_wdat		(r_dacwdat),
	.o_dacv		(dac_r_vs),
	.o_shrst	(sh_rst),
	.o_hold		(sh_hold),
	.o_dac1		(dac1_v),
	.o_dat		(dac_r_comp),
	.o_dactl	(dac_r_ctl),
	.o_intr		(dac_intr),
	.o_cmpsta	(dac_r_cmpsta),
	.o_smpl		(comp_smpl) // select and sample
   ); // u0_dacmux

   fcp u0_fcp (
	.dp_comp	(dp_comp),
	.dm_comp	(dm_comp),
	.id_comp	(1'h0),
	.intr		(fcp_intr),
	.tx_en		(fcp_oe),
	.tx_dat		(fcp_do),
	.r_dat		(fcp_r_dat),
	.r_sta		(fcp_r_sta),
	.r_ctl		(fcp_r_ctl),
	.r_msk		(fcp_r_msk),
	.r_crc		(fcp_r_crc),
	.r_acc		(fcp_r_acc),
	.r_dpdmsta	(r_accctl),
	.r_re		(r_fcpre),
	.r_wr		(r_fcpwr),
	.r_wdat		(sfr_wdat),
	.clk		(mclk),
	.srstz		(srstz),
	.r_tui          (fcp_r_tui)
   ); // u0_fcp

   wire do_cc = r_fortxrdy ?r_fortxdat :ptx_cc;
   wire oe_cc = r_fortxen | ptx_oe;

   wire dpdm_ie = r_accctl[3];
   wire dpdm_short = r_accctl[4];
   wire r_ena_dac1comp = x_daclsb[2];
   wire [7:0] r_vcomp, r_idacsh, r_cvofsx, r_sdischg;
   wire [7:0] r_cvcwdat = (|r_cvcwr[5:3]) ? xram_d : sfr_wdat;
   cvctl u0_cvctl (
	.r_cvcwr	(r_cvcwr),
	.wdat		(r_cvcwdat),
	.r_cvofs	(r_cvofs),
	.r_sdischg	(r_sdischg),
	.r_vcomp	(r_vcomp),
	.r_idacsh	(r_idacsh),
	.r_cvofsx	(r_cvofsx),
	.sdischg_duty	(sdischg_duty),

	.r_hlsb_en	(r_halflsb_en),
	.r_hlsb_sel	(r_halflsb_sel),
	.r_hlsb_freq	(r_halflsb_freq),
	.r_hlsb_duty	(r_halflsb_duty),
	.r_fw_pwrv	(r_fw_pwrv),
	.r_dac0		(dac0_code),
	.r_dac3		(r_dac3),
	.clk_100k	(clk_100k),
	.clk		(mclk),
	.srstz		(srstz)
   ); // u0_cvctl
   wire sdischg_vin  = ~(r_sdischg[5] &~sdischg_duty | r_otpi_gate) & r_srcctl[1];
   wire sdischg_vbus = ~(r_sdischg[6] &~sdischg_duty | r_otpi_gate) & r_srcctl[4];

   wire [1:0] regx_hitbst;
   wire [6:0] r_do_ts, bist_r_ctl;
   wire [7:0] r_aopt, r_xtm, bist_r_dat, r_adummyi, r_bck0, r_bck1;
   wire [23:0] r_xana;
   wire [4:0] di_xanav;
   wire [1:0] r_sap;
   wire [3:0] r_dpdo_sel, r_dndo_sel;
   wire [6:0] regx_addr = xram_a[6:0];
   assign r_vcbyval      = r_xtm[4]; // CAN1124A0 -> CAN1127A0
   assign r_halflsb_freq = r_xtm[5]; // CAN1124A0
   assign r_halflsb_duty = r_xtm[6]; // CAN1124A0
   wire   r_gate_lp      = r_xtm[7]; // CAN1126A0
   assign r_halflsb_en   = r_pwrctl[4]; // CAN1124A0->CAN1126A0
   assign r_halflsb_sel  = r_pwrctl[5]; // CAN1126A0
   wire sram_oeb = bist_r_ctl[5];
// wire sram_sel = bist_r_ctl[4];
   wire [1:0] regx_wrpwm;
   wire [15:0] r_pwm;
   wire [4:0] di_aswk;
   wire [3:0] regx_wrcvc;
   assign {r_cvcwr[2],r_cvcwr[5:3]} = regx_wrcvc;
   regx u0_regx (
	.di_rd_det	(di_rd_det),
	.di_stbovp	(di_stbovp),
	.di_drposc	(di_drposc),
	.di_imposc	(di_imposc),
	.r_imp_osc	(r_imp_osc),
	.clk_500k	(clk_500k),

	.regx_hitbst	(regx_hitbst),
	.r_bistctl	(bist_r_ctl),
	.r_bistdat	(bist_r_dat),

	.regx_wrcvc	(regx_wrcvc),
	.r_sdischg	(r_sdischg),
	.r_vcomp	(r_vcomp),
	.r_idacsh	(r_idacsh),
	.r_cvofsx	(r_cvofsx),

	.regx_wrpwm	(regx_wrpwm),
	.r_pwm		(r_pwm),

	.regx_wrdac	(regx_wrdac),
	.dac_r_vs	(dac_r_vs[8*8+:8*10]), // from channel 8, 10 channels
	.dac_comp	(dac_r_comp[17:8]),
	.r_dac_en	(r_dac_en[17:8]),
	.r_sar_en	(r_sar_en[17:8]),

	.r_twlb		(pmem_twlb),
	.wd_twlb	(wd_twlb),
	.we_twlb	(we_twlb),
	.r_sap		(r_sap),
	.r_vpp_en	(r_vpp_en),
	.r_vpp0v_en	(r_vpp0v_en),
	.r_otp_pwdn_en	(r_otp_pwdn_en),
	.r_otp_wpls	(r_otp_wpls),

	.lt_gpi		(lt_gpi), // {GPIO2,GPIO1,SDA,SCL}
	.di_tst		(di_tst),
	.di_ts		(di_ts),
	.r_do_ts	(r_do_ts),
	.r_dpdo_sel	(r_dpdo_sel),
	.r_dndo_sel	(r_dndo_sel),

	.regx_wdat	(xram_d),
	.regx_addr	(regx_addr), // 1-bank of PG0
	.regx_w		(regx_we),
	.regx_r		(regx_re),
	.regx_rdat	(regx_rdat),
	.upd_pwrv	(r_pwrv_upd),
	.atpg_en	(atpg_en),
	.di_aswk	(di_aswk), // async.
	.aswclk		(aswclk),
	.detclk		(detclk),
	.clk		(mclk),
	.rrstz		(srstz),
        .bkpt_pc        (bkpt_pc),
        .bkpt_ena       (bkpt_ena),
	.r_bck0		(r_bck0),
	.r_bck1		(r_bck1),
	.r_adummyi	(r_adummyi),
	.r_xana		(r_xana),
	.di_xana	(di_xanav),
	.r_aopt		(r_aopt),
	.r_xtm		(r_xtm),
	.r_i2crout	(r_i2crout),
	.sse_idle	(sse_idle),
	.bus_idle	(bus_idle),
	.ramacc		(ramacc)
   ); // u0_regx

   srambist u0_srambist (
        .clk            (mclk),
        .srstz          (srstz),
	.reg_wdat	(xram_d),
	.reg_hit	(regx_hitbst),
	.reg_w		(regx_we),
	.reg_r		(regx_re),
	.iram_rdat	(sram_rdat),
	.xram_rdat	(sram_rdat),
	.bist_en	(bist_en),
	.bist_xram	(bist_xram),
	.bist_wr	(bist_wr),
	.bist_adr	(bist_adr),
	.bist_wdat	(bist_wdat),
	.o_bistctl	(bist_r_ctl),
	.o_bistdat	(bist_r_dat)
   ); // u0_srambist

   divclk u0_divclk (
	.mclk		(mclk),
	.srstz		(srstz),
	.atpg_en	(atpg_en),
	.divff_8	(divff_8), // mclk/8, 50%
	.divff_5	(divff_5), // mclk/120, 20%
	.clk_1500k	(clk_1500k),
	.clk_500k	(clk_500k),
	.clk_100k	(clk_100k),
	.clk_50k	(clk_50k),
	.clk_500	(clk_500)
   ); // u0_divclk

   assign pwrdn_rst = ps_pwrdn & r_vpp0v_en;
   wire vpp_zero = r_pwrdn & r_vpp0v_en;

`include "inc_gpio.v"
`include "inc_test_a0.v"

`ifdef FPGA
   assign do_s0rx = s0_rxdo;
   assign oe_s0rx = s0_rxdoe;
   wire [31:0] dbgpo5 ={8'h0,
			sfr_dbgpo[31:24],
			mcu_dbgpo[17:16],pid_goidle,pid_gobusy,
			mcu_dbgpo[18],sfr_intr[2:0],prl_fsm[3:0]};
   wire [31:0] dbgpo6 ={mcu_dbgpo[15:0],
			mcu_dbgpo[23:20],prl_fsm,
			1'h0,ptx_fsm,prx_fsm};
   assign dbgpo =
	(dbgsel=='ha) ?{16'h0,4'ha,4'h0,pmem_q0} :
	(dbgsel=='h9) ?{16'h0,pmem_a} :
	(dbgsel=='h8) ?{24'h8,8'h8} :
//	(dbgsel=='h7) ?{24'h7,i2cslv_dbgpo} :
	(dbgsel=='h7) ?{32'h7} :
	(dbgsel=='h6) ?dbgpo6 :
	(dbgsel=='h5) ?dbgpo5 :
	(dbgsel=='h4) ?upd_dbgpo :
	(dbgsel=='h3) ?{sfr_dbgpo[15:0],sfr_dbgpo[23:16],sfr_dbgpo[31:24]} :
	(dbgsel=='h2) ?{24'h6,do_p0} :
	(dbgsel=='h1) ?{pmem_q1,memdatai,sfr_dbgpo[15:0]} :
	(dbgsel=='h0) ?mcu_dbgpo :'hx;
   assign REVID[6:0] =  revid;
`else
   wire [6:0] revidz = ~revid;
   INVX1 U0_REVIDZ [6:0] (.Y(REVID[6:0]),.A(revidz));
`endif // FPGA

endmodule // core_a0

