

`ifdef GATE // pc_o becomes 'z'
////	it's difficult to monitor such things in gate-level simulation
`else
   always @(posedge `DUT_CCLK)
      if (`DUT_MCU.mempsrd & `DUT_MCU.mempsack) begin: chkpsdat // to debug u0_ictlr
         reg [7:0] exp;
         exp = `HW.get_code(`DUT_MCU.u_cpu.pc_o);
         if (`DUT_MCU.memdatai!==exp) begin
            $display ($time,"ns <%m> ERROR: fetch 0x%x, exp:%x, dat:%x",`DUT_MCU.u_cpu.pc_o,exp,`DUT_MCU.memdatai);
            #1_000 $finish;
         end
      end // chkpsdat

   always @(posedge `DUT_MCU.clkper)
             if (`DUT_MCU.t0_tr0 & // don't set Timer0 when it's still running
		~`DUT_MCU.u_timer0.rst &
		 `DUT_MCU.u_timer0.sfrwe &
		(`DUT_MCU.u_timer0.sfraddr==`DUT_CORE.u0_mcu.u_timer0.TL0_ID ||
		 `DUT_MCU.u_timer0.sfraddr==`DUT_CORE.u0_mcu.u_timer0.TH0_ID))
	$display ($time,"ns <%m> WARNING: timer0 changed during runing, not good!!");

   reg x_cc, frc_cc;
   integer delay_f =0, delay_r =0, delay =0;
   always @(`DUT_CORE.u0_updphy.i_cc)
      if (frc_cc) if (`DUT_CORE.u0_updphy.i_cc) #(delay_r)x_cc = 'h1; else #(delay_f)x_cc = 'h0;
      else x_cc = `DUT_CORE.u0_updphy.i_cc;
   initial begin
      frc_cc =1;
      x_cc =0;
      force `DUT_CORE.u0_updphy.u0_phyrx.x_cc = x_cc;
      #199_000 `DUT_CORE.u0_regbank.u0_regE6.mem[3] =1; // r_adprx_en
               `DUT_CORE.u0_regbank.u0_regE6.mem[1:0] =0; // r_rxdb_opt, don't filter out those short pulses
   end

   wire signed [7:0] dcnt_h = `DUT_CORE.u0_updphy.u0_phyrx.u0_phyrx_adp.dcnt_h;
   wire [3:0] adp_v = `DUT_CORE.u0_updphy.u0_phyrx.u0_phyrx_adp.adp_v0;
   integer ofcnt =0; // overflow counter
   always @(posedge `DUT_CORE.mclk)
      if (dcnt_h==127 || dcnt_h==-128) begin
         $display ($time,"ns <%m> ADPWARN: dcnt_h marging");
         @(posedge `DUT_CORE.mclk)
         if (dcnt_h==127 || dcnt_h==-128) begin
            $display ($time,"ns <%m> ADPWARN: dcnt_h overflow %0d", ofcnt);
            ofcnt = ofcnt+1;
         end
      end
   reg egs; // edge select
   always @(posedge `DUT_CORE.mclk) begin
      if (`DUT_CORE.pid_gobusy&~`DUT_CORE.u0_updphy.ptx_txact) begin
         egs = {$random}%2; // 0/1: fall/rise delay more
         delay_r = egs ?{$random}%1200 :{$random}%400;
         delay_f = egs ?{$random}%400 :{$random}%1200;
      end
      if (`DUT_CORE.pid_goidle&`DUT_CORE.u0_updphy.u0_phyrx.u0_phyrx_adp.adp_en)
            $display ($time,"ns <%m> ADPNOTE: delay (%4d,%4d)%6d%6d",
		delay_r,delay_f,dcnt_h,adp_v);
   end

`define DUT_FF `DUT_PHY.u0_phyff.mem
wire [7:0]
dbg_dutff_00 = `DUT_FF[00],
dbg_dutff_01 = `DUT_FF[01],
dbg_dutff_02 = `DUT_FF[02],
dbg_dutff_03 = `DUT_FF[03],
dbg_dutff_04 = `DUT_FF[04],
dbg_dutff_05 = `DUT_FF[05],
dbg_dutff_06 = `DUT_FF[06],
dbg_dutff_07 = `DUT_FF[07],
dbg_dutff_08 = `DUT_FF[08],
dbg_dutff_09 = `DUT_FF[09],
dbg_dutff_10 = `DUT_FF[10],
dbg_dutff_11 = `DUT_FF[11],
dbg_dutff_12 = `DUT_FF[12],
dbg_dutff_13 = `DUT_FF[13],
dbg_dutff_14 = `DUT_FF[14],
dbg_dutff_15 = `DUT_FF[15],
dbg_dutff_16 = `DUT_FF[16],
dbg_dutff_17 = `DUT_FF[17],
dbg_dutff_18 = `DUT_FF[18],
dbg_dutff_19 = `DUT_FF[19];
`endif // GATE

`ifdef GATE
always @(posedge `DUT_ANA.OSC_O)
`else // RTL
always@*
`endif // GATE
begin: chkconn // check connections
parameter N_ANACHK = 47;
reg [N_ANACHK-1:0] map;
        #5 map = {
	`DUT_ANA.TM[3:0]     	=== `DUT_CORE.u0_regbank.u0_regD9.rdat[7:4], // ATM
	`DUT_ANA.SLEEP       	=== `DUT_CORE.u0_regbank.u0_regD9.rdat[0],
	`DUT_ANA.DISCHG_SEL	=== `DUT_CORE.u0_regbank.u0_regE3.rdat[5],
	`DUT_ANA.LDO3P9V	=== `DUT_CORE.u0_cvctl.u0_sdischg.rdat[7], // reg8F
	`DUT_ANA.VPP_SEL	=== `DUT_CORE.u0_regx.u0_reg12.rdat[5], // NVMCTL[7]
	`DUT_ANA.OVP_SEL[1:0]	=== `DUT_CORE.u0_regbank.u0_regF5.rdat[7:6], // CVCTL
	`DUT_ANA.ANTI_INRUSH	=== `DUT_CORE.u0_regbank.u0_regF5.rdat[5],
	`DUT_ANA.OCP_EN		=== `DUT_CORE.u0_regbank.u0_regF5.rdat[2], // --- 40
	`DUT_ANA.CS_EN		=== `DUT_CORE.u0_regbank.u0_regF6.rdat[3],
	`DUT_ANA.REGTRM[55:48]	=== `DUT_CORE.u0_regbank.u0_regA7.rdat,
	`DUT_ANA.REGTRM[47:40]	=== `DUT_CORE.u0_regbank.u0_regA6.rdat,
	`DUT_ANA.REGTRM[39:32]	=== `DUT_CORE.u0_regbank.u0_regA5.rdat,
	`DUT_ANA.REGTRM[31:24]	=== `DUT_CORE.u0_regbank.u0_regA4.rdat,
	`DUT_ANA.REGTRM[23:16]	=== `DUT_CORE.u0_regbank.u0_regA3.rdat,
	`DUT_ANA.REGTRM[15:8]	=== `DUT_CORE.u0_regbank.u0_regA2.rdat,
	`DUT_ANA.REGTRM[7:0]	=== `DUT_CORE.u0_regbank.u0_regA1.rdat,
	`DUT_ANA.SGP[4]  	=== `DUT_CORE.u0_regx.u0_reg1A.rdat[1], // XTM
	`DUT_ANA.SGP[3]  	=== `DUT_CORE.u0_regx.u0_reg1A.rdat[2], // --- 30
	`DUT_ANA.UVP_SEL  	=== `DUT_CORE.u0_regx.u0_reg1C.rdat[7], // XANA0
	`DUT_ANA.DPDN_VTH 	=== `DUT_CORE.u0_regx.u0_reg1C.rdat[5],
	`DUT_ANA.SEL_CCGAIN	=== `DUT_CORE.u0_regx.u0_reg1C.rdat[3],
	`DUT_ANA.VFB_SW		=== `DUT_CORE.u0_regx.u0_reg1C.rdat[1],
	`DUT_ANA.CV2		=== `DUT_CORE.u0_regx.u1_reg1C.rdat[0],
	`DUT_ANA.LFOSC_ENB	=== `DUT_CORE.u0_regx.u0_reg1E.rdat[7], // XANA2
        `DUT_ANA.OCP_SEL	=== `DUT_CORE.u0_regx.u0_reg1E.rdat[1],
        `DUT_ANA.PWREN_HOLD	=== `DUT_CORE.u0_regx.u0_reg1E.rdat[0],
        `DUT_ANA.HVNG_CPEN	=== `DUT_CORE.u0_regx.u0_reg1D.rdat[7], // XANA1
        `DUT_ANA.CPV_SEL	=== `DUT_CORE.u0_regx.u0_reg1D.rdat[6], // --- 20
        `DUT_ANA.CLAMPV_EN	=== `DUT_CORE.u0_regx.u0_reg1D.rdat[5],
        `DUT_ANA.DP_0P6V_EN	=== `DUT_CORE.u0_regx.u0_reg1D.rdat[3],
        `DUT_ANA.DN_0P6V_EN	=== `DUT_CORE.u0_regx.u0_reg1D.rdat[2],
        `DUT_ANA.EXT_CP		=== `DUT_CORE.u0_regx.u0_reg05.rdat[7], // BCK1
        `DUT_ANA.EN_IBUK	=== `DUT_CORE.u0_regx.u0_reg05.rdat[6],
        `DUT_ANA.EN_ODLDO	=== `DUT_CORE.u0_regx.u0_reg05.rdat[5],
        `DUT_ANA.EN_GM		=== `DUT_CORE.u0_regx.u0_reg05.rdat[4],
        `DUT_ANA.MAXDS		=== `DUT_CORE.u0_regx.u0_reg05.rdat[3],
        `DUT_ANA.EN_OSC		=== `DUT_CORE.u0_regx.u0_reg05.rdat[2],
        `DUT_ANA.FSW		=== `DUT_CORE.u0_regx.u0_reg05.rdat[1:0], // --- 10
        `DUT_ANA.INT_CP		=== `DUT_CORE.u0_regx.u0_reg04.rdat[7], // BCK0
        `DUT_ANA.EN_DRV		=== `DUT_CORE.u0_regx.u0_reg04.rdat[6],
        `DUT_ANA.LGON		=== `DUT_CORE.u0_regx.u0_reg04.rdat[5] | `DUT_CORE.frc_lg_on,
        `DUT_ANA.HGON		=== `DUT_CORE.u0_regx.u0_reg04.rdat[4],
        `DUT_ANA.LGOFF		=== `DUT_CORE.u0_regx.u0_reg04.rdat[3],
        `DUT_ANA.HGOFF		=== `DUT_CORE.u0_regx.u0_reg04.rdat[2],
        `DUT_ANA.DCM_SEL	=== `DUT_CORE.u0_regx.u0_reg04.rdat[1],
        `DUT_ANA.BST_SET	=== `DUT_CORE.u0_regx.u0_reg04.rdat[0],
        `DUT_ANA.SGP[5]		=== `DUT_CORE.u0_regbank.u0_regF6.rdat[0]}; // --- 1
        if (map!=={N_ANACHK{1'h1}})
	   `HW_FIN(($time,"ns <%m> ERROR: mis-vertor:%0x",map))
end // chkconn

