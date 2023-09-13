
// =============================================================================
// GPIO and debug signals
// 2018/01/24 new created, Ray Huang, rayhuang@canyon-semi.com.tw
// ALL RIGHTS ARE RESERVED
// =============================================================================

   function di_sel;
   input [2:0] pos;
   input [3*4-1:0] sel;
   input [3:0] candi;
   input d4val;
      di_sel = (sel[2:0]==pos) ?candi[0]
              :(sel[5:3]==pos) ?candi[1]
              :(sel[8:6]==pos) ?candi[2]
             :(sel[11:9]==pos) ?candi[3] :d4val;
   endfunction
   wire [6:0] di_gpio;
   wire [3*4-1:0] gpio_sel = {gpio_s3, gpio_s2, gpio_s1, gpio_s0};
   assign di_scl  = di_sel (3'h0, gpio_sel, di_gpio[3:0], 1'h1), // de-bounce, sync in sub-module
          di_sda  = di_sel (3'h1, gpio_sel, di_gpio[3:0], 1'h1),
          gpint0z = di_sel (3'h4, gpio_sel, di_gpio[3:0], 1'h1),
          gpint1z = di_sel (3'h5, gpio_sel, di_gpio[3:0], 1'h1),
          s0_rx   = di_sel (3'h7, gpio_sel, di_gpio[3:0], s0_rx_d4);

   wire prx_bmc = upd_dbgpo[18];
   wire cc_rxd  = upd_dbgpo[17];

   wire cc_flip = r_ccctl[0];

   wire dm_2v7_en = r_dpdmctl[6];
   wire dm_dwn_en = r_dpdmctl[4];

   wire t0tr = mcu_dbgpo[16];
   wire t0tf = mcu_dbgpo[17];
   wire t1tr = mcu_dbgpo[18];
   wire t1tf = mcu_dbgpo[19];
   wire mirq = mcu_dbgpo[20];
   wire reti = mcu_dbgpo[21];
   wire mrst = mcu_dbgpo[22];
   wire [7:0] do_opt = {s0_rxdo,s0_tx,do_p0[3:0],do_sda,do_scl};
   wire [1:0] pwm_o;
   wire [3:0] do_p0_6_4_ = {do_p0[6],do_p0[5:4]^pwm_o};

   glpwm u0_pwm [1:0] (
	.rstz		({2{srstz}}),
	.clk		({2{mclk}}),
	.clk_base	({2{clk_50k}}),
	.wdat		({2{xram_d}}),
	.we		(regx_wrpwm),
	.r_pwm		(r_pwm),
	.pwm_o		(pwm_o)
   ); // u0_pwm

   assign o_s0_tx = s0_tx; // FPGA

   wire [15:0] tm;
   assign do_gpio = { // {GPIO5,GPIO4,GPIO3,GPIO2,GPIO1,SDA,SCL}
	do_p0_6_4_,
	do_opt[gpio_s3], do_opt[gpio_s2],
	do_opt[gpio_s1], do_opt[gpio_s0]} & (|tm[1:0] ?'h0f :|tm[15:2] ?'h03 :'h7f)
//		| (tm[0]  ?'h0 :'h0) // ATPG
		| (tm[1]  ?{x_clk,     xrstz,    1'h0,                              4'h0} :'h0)
		| (tm[2]  ?{di_cc,     cc_rxd,   prx_bmc,    cc_idle,   di_sqlch,   2'h0} :'h0)
		| (tm[3]  ?{di_cc_49,  cc_rxd,   di_cc_49,   cc_idle,   di_sqlch,   2'h0} :'h0)
		| (tm[4]  ?{do_cc,     oe_cc,    slvo_sda,   cc2_di ,   cc1_di,     2'h0} :'h0)
		| (tm[5]  ?{dac1_comp, dp_comp,  di_cc_49,   di_cc_49,  di_sqlch,   2'h0} :'h0)
		| (tm[6]  ?{di_pro[4], di_pro[2:0],                     mirq,       2'h0} :'h0)
		| (tm[7]  ?{di_pro[3:0],                                di_pro[5],  2'h0} :'h0)
		| (tm[8]  ?{cc_flip,   do_cc,    oe_cc,      reti,      mirq,       2'h0} :'h0)
		| (tm[9]  ?{dpdm_short,dm_2v7_en,dm_dwn_en,  reti,      mirq,       2'h0} :'h0)
		| (tm[10] ?{t0tf,      r_osc_lo, t1tr,       t0tr,      r_osc_stop, 2'h0} :'h0)
		| (tm[11] ?{comp_smpl[3:0],                             dac1_comp,  2'h0} :'h0)
		| (tm[12] ?{pmem_pgm,  pmem_re,  t_pmem_csb, r_vpp_en,  t_pmem_clk, 2'h0} :'h0)
		| (tm[13] ?{fcp_oe,    fcp_do,   dm_comp,    reti,      mirq,       2'h0} :'h0)
		| (tm[14] ?{t0tf,      t1tf,     t1tr,       t0tr,      mirq,       2'h0} :'h0)
		| (tm[15] ?{t0tr,      mrst,     t1tr,       reti,      mirq,       2'h0} :'h0);

   assign oe_gpio = ((~xrstz & di_tst) ?'h70 :'h7f) & (r_gpio_oe & ~{3'h0,
		(gpio_s3=='h0) & do_scl | (gpio_s3=='h1) & do_sda | (gpio_s3=='h7) & ~s0_rxdoe,
		(gpio_s2=='h0) & do_scl | (gpio_s2=='h1) & do_sda | (gpio_s2=='h7) & ~s0_rxdoe,
		(gpio_s1=='h0) & do_scl | (gpio_s1=='h1) & do_sda | (gpio_s1=='h7) & ~s0_rxdoe,
		(gpio_s0=='h0) & do_scl | (gpio_s0=='h1) & do_sda | (gpio_s0=='h7) & ~s0_rxdoe}
		| (|tm[1:0] ?'h60 :(xrstz&|tm[15:2] ?'h7c :'h0))); // force output

