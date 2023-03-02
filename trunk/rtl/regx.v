
module regx
#(
parameter UNREGX_D4 = 8'hff
)(
//=====================
//Xdata space, address FFF80~FFFF.
//20190729 create 
//=====================
input		regx_r, // cmd/addr hit (pre-state read-ack)
		regx_w, // already hit (write-ack)
		di_drposc, di_imposc, di_rd_det, di_stbovp, clk_500k,
output		r_imp_osc,
input	[6:0]	regx_addr, // cmd/addr phase
input   [7:0]   regx_wdat,
output	[7:0]	regx_rdat,
output	[1:0]	regx_hitbst, regx_wrpwm,
output	[2:0]	regx_wrcvc,
input	[6:0]	r_bistctl,
input	[7:0]	r_bistdat, r_vcomp, r_idacsh, r_cvofsx,
input	[15:0]	r_pwm,
output	[9:0]	regx_wrdac,
input	[8*8-1:0] dac_r_vs,
input	[7:0]	dac_comp, r_dac_en, r_sar_en,
output	[7:0]	r_xtm, r_i2crout, r_adummyi,
output  [23:0]  r_xana,
input	[4:0]	di_xana,
input	[3:0]	lt_gpi,
input		di_tst,
output  [14:0]  bkpt_pc,
output		bkpt_ena,
		we_twlb, r_vpp_en, r_vpp0v_en, r_otp_pwdn_en, r_otp_wpls,
output	[1:0]	wd_twlb, r_sap,
input	[1:0]	r_twlb,
input		upd_pwrv, ramacc, sse_idle, cc_idle,
output	[6:0]	r_do_ts,
output	[3:0]	r_dpdo_sel, r_dndo_sel,
input		di_ts, detclk, aswclk, atpg_en,
input	[4:0]	di_aswk,
input		clk, rrstz
);
   wire ['h7f:'h00] hit = 128'h1 << regx_addr[6:0];
   wire ['h7f:'h00] we = hit & {128{regx_w}};
   wire [7:0] wdat = regx_wdat; // rename
   wire [7:0]	reg7F,reg7E,reg7D,reg7C,reg7B,reg7A,reg79,reg78,
		reg77,reg76,reg75,reg74,reg73,reg72,reg71,reg70,
		reg6F,reg6E,reg6D,reg6C,reg6B,reg6A,reg69,reg68,
		reg67,reg66,reg65,reg64,reg63,reg62,reg61,reg60,
		reg5F,reg5E,reg5D,reg5C,reg5B,reg5A,reg59,reg58,
		reg57,reg56,reg55,reg54,reg53,reg52,reg51,reg50,
		reg4F,reg4E,reg4D,reg4C,reg4B,reg4A,reg49,reg48,
		reg47,reg46,reg45,reg44,reg43,reg42,reg41,reg40,
   		reg3F,reg3E,reg3D,reg3C,reg3B,reg3A,reg39,reg38,
		reg37,reg36,reg35,reg34,reg33,reg32,reg31,reg30,
		reg2F,reg2E,reg2D,reg2C,reg2B,reg2A,reg29,reg28,
		reg27,reg26,reg25,reg24,reg23,reg22,reg21,reg20,
		reg1F,reg1E,reg1D,reg1C,reg1B,reg1A,reg19,reg18,
		reg17,reg16,reg15,reg14,reg13,reg12,reg11,reg10,
		reg0F,reg0E,reg0D,reg0C,reg0B,reg0A,reg09,reg08,
		reg07,reg06,reg05,reg04,reg03,reg02,reg01,reg00;

   reg [6:0] d_regx_addr;
   always @(posedge clk) d_regx_addr <= regx_addr;
   assign regx_rdat = {
        	reg7F,reg7E,reg7D,reg7C,reg7B,reg7A,reg79,reg78,
		reg77,reg76,reg75,reg74,reg73,reg72,reg71,reg70,
        	reg6F,reg6E,reg6D,reg6C,reg6B,reg6A,reg69,reg68,
		reg67,reg66,reg65,reg64,reg63,reg62,reg61,reg60,
		reg5F,reg5E,reg5D,reg5C,reg5B,reg5A,reg59,reg58,
		reg57,reg56,reg55,reg54,reg53,reg52,reg51,reg50,
		reg4F,reg4E,reg4D,reg4C,reg4B,reg4A,reg49,reg48,
                reg47,reg46,reg45,reg44,reg43,reg42,reg41,reg40,
		reg3F,reg3E,reg3D,reg3C,reg3B,reg3A,reg39,reg38,
		reg37,reg36,reg35,reg34,reg33,reg32,reg31,reg30,
        	reg2F,reg2E,reg2D,reg2C,reg2B,reg2A,reg29,reg28,
		reg27,reg26,reg25,reg24,reg23,reg22,reg21,reg20,
        	reg1F,reg1E,reg1D,reg1C,reg1B,reg1A,reg19,reg18,
		reg17,reg16,reg15,reg14,reg13,reg12,reg11,reg10,
        	reg0F,reg0E,reg0D,reg0C,reg0B,reg0A,reg09,reg08,
		reg07,reg06,reg05,reg04,reg03,reg02,reg01,reg00 } >> {d_regx_addr[6:0],3'h0};

   assign {     reg7F,reg7E,reg7D,reg7C,reg7B,reg7A,reg79,reg78,
		reg77,reg76,reg75,reg74,reg73,reg72,reg71,reg70,
        	reg6F,reg6E,reg6D,reg6C,reg6B,reg6A,reg69,reg68,
		reg67,reg66,reg65,reg64,reg63,reg62,reg61,reg60,
		reg5F,reg5E,reg5D,reg5C,reg5B,reg5A,reg59,reg58,
		reg57,reg56,reg55,reg54,reg53,reg52,reg51,reg50,
		reg4F,reg4E,reg4D,reg4C,reg4B,reg4A,reg49,reg48,
                reg47,reg46,reg45,reg44,reg43,reg42,reg41,reg40 } = {64{UNREGX_D4}};

   assign {reg00,regx_wrcvc[0]} = {r_vcomp[7:0],   we['h00]}; // V_COMP
   assign {reg01,regx_wrcvc[1]} = {r_idacsh[7:0],  we['h01]}; // IDAC_SH
   assign {reg02,regx_wrcvc[2]} = {r_cvofsx[7:0],  we['h02]}; // CV_OFSX
   assign  reg03 = UNREGX_D4;
   assign  reg04 = UNREGX_D4;
   assign  reg05 = UNREGX_D4;
   assign  reg06 = UNREGX_D4;
   glreg u0_reg07 (clk, rrstz, we['h07], wdat, reg07); // DMY0
   assign r_adummyi = reg07;

   assign {reg08,regx_wrpwm[0]} = {r_pwm[7:0],  we['h08]}; // PWM0
   assign {reg09,regx_wrpwm[1]} = {r_pwm[15:8], we['h09]}; // PWM1
   assign  reg0A = UNREGX_D4;
   assign  reg0B = UNREGX_D4;
   assign  reg0C = UNREGX_D4;
   assign  reg0D = UNREGX_D4;
   assign  reg0E = UNREGX_D4;
   assign  reg0F = UNREGX_D4;

   glreg #(1) u0_reg10 (clk, rrstz, 1'h1, ramacc, r_ramacc); // to prevent from timing loop
   assign {reg10,regx_hitbst[0]} = {r_ramacc, r_bistctl, hit['h10]}; // BISTCTL
   assign {reg11,regx_hitbst[1]} = {r_bistdat, hit['h11]}; // BISTDAT

   glreg #(6,'h02) u0_reg12 (clk, rrstz, we['h12], wdat[7:2], reg12[7:2]); // NVMCTL
   assign r_vpp_en = reg12[7]; // 0/1: select LDO18/VDIO
   assign r_vpp0v_en = reg12[6];
   assign r_otp_pwdn_en = reg12[5];
   assign r_otp_wpls = reg12[4];
   assign r_sap = reg12[3:2];
   assign reg12[1:0] = r_twlb; // this is implemented in 'ictlr'
   assign wd_twlb = wdat[1:0];
   assign we_twlb = we['h12];

   glreg u0_reg13 (clk, rrstz, we['h13], wdat, reg13); // TDPDN
   assign r_dpdo_sel = reg13[7:4];
   assign r_dndo_sel = reg13[3:0];

   reg lt_drp, d_lt_drp;
   always @(posedge clk) d_lt_drp <= lt_drp; // sync.
   always @(posedge detclk or negedge rrstz) // async. flip-flop
      if (~rrstz) lt_drp <= 'h0;
             else lt_drp <= di_drposc;

   reg [3:0] d_lt_gpi;
   reg d_di_tst;
   always @(posedge clk) d_di_tst <= di_tst; // sync.
   always @(posedge clk) if (~rrstz) d_lt_gpi <= lt_gpi; // sync. in reset
   assign {reg14[7:3],reg14[0]} = {d_lt_gpi,d_di_tst,d_lt_drp};

   wire force_i2c_upd = we['h15] & (wdat[7:6]=='h2);
   wire i2c_mode_upd = sse_idle & cc_idle | force_i2c_upd;
   wire [5:0] lt_reg15_5_0; // temp
   wire [5:0] i2c_mode_wdat = force_i2c_upd ? wdat[5:0] : lt_reg15_5_0;
   glreg #(6) u1_reg15 (clk, rrstz, i2c_mode_upd, i2c_mode_wdat, reg15[5:0]); // for read
   glreg #(6) u0_reg15 (clk, rrstz, we['h15], wdat[5:0], lt_reg15_5_0); // I2CROUT
   assign reg15[7:6] = 1'h0;
   assign r_i2crout = reg15;

   reg d_we16;
   reg [5:0] lt_aswk, d_lt_aswk;
   always @(posedge clk) d_lt_aswk <= lt_aswk; // sync.
   always @(posedge clk) d_we16 <= we['h16] & wdat=='hc1;
   wire aswk_clrz = rrstz & (~d_we16 | atpg_en);
   always @(posedge aswclk or negedge aswk_clrz) // async. flip-flop
      if (~aswk_clrz) lt_aswk <= 'h0;
                 else lt_aswk <= {1'h1,di_aswk};
   assign  reg16 = {2'h0,d_lt_aswk};
   assign  reg17 = UNREGX_D4;

   wire [7:0] wd18; 
   glreg u0_tmp18 (clk, rrstz, we['h18], wdat, wd18);
   glreg u0_reg18 (clk, rrstz, we['h19], wd18, reg18); // BPPCL
   glreg u0_reg19 (clk, rrstz, we['h19], wdat, reg19); // BPPCH
   assign bkpt_pc = {reg19[6:0],reg18[7:0]};
   assign bkpt_ena = reg19[7];
  
   glreg u0_reg1A (clk, rrstz, we['h1a], wdat, reg1A); // XTM
   assign r_xtm = reg1A;

   dbnc #(2,2) // 2~3T (3 samples)
	u0_ts_db (.o_dbc(reg1B[3]),.o_chg(),.i_org(di_ts),.clk(clk),.rstz(rrstz));
   glreg #(7) u0_reg1B (clk, rrstz, we['h1b], {wdat[7:4],wdat[2:0]}, {reg1B[7:4],reg1B[2:0]}); // GPIOTS
   assign r_do_ts = {reg1B[7:4],reg1B[2:0]};

   wire lt_reg1C_0; // temp. storage
   glreg #(1) u1_reg1C (clk, rrstz, upd_pwrv, lt_reg1C_0, reg1C[0]); // real XANA0[0]: CV2
   glreg u0_reg1C (clk, rrstz, we['h1c], wdat, {reg1C[7:1],lt_reg1C_0}); // XANA0
   glreg u0_reg1D (clk, rrstz, we['h1d], wdat, reg1D); // XANA1
   glreg u0_reg1E (clk, rrstz, we['h1e], wdat, reg1E); // XANA2
   wire r_drp_osc = reg1E[4];
   wire stb_rp = r_drp_osc ?   reg1E[3] ^ di_drposc  : reg1E[3]; // async.
   wire rd_enb = r_drp_osc ? ~(reg1E[2] ^~di_drposc) : reg1E[2]; // async.
   assign r_xana = {reg1E[7:4],stb_rp,rd_enb,reg1E[1:0],reg1D,reg1C};
   assign r_imp_osc = reg1E[6];

   assign  reg1F[5] = 'h0;
   dbnc #(2,2) // 2~3T (3 samples) +sync
	u0_dosc_db (.o_dbc(reg14[1]),.o_chg(),.i_org(di_imposc), .clk(clk),.rstz(rrstz)),
	u0_iosc_db (.o_dbc(reg14[2]),.o_chg(),.i_org(di_drposc), .clk(clk),.rstz(rrstz)),
	u0_xana_db (.o_dbc(reg1F[0]),.o_chg(),.i_org(di_xana[0]),.clk(clk),.rstz(rrstz)), // OCP_80M
	u1_xana_db (.o_dbc(reg1F[1]),.o_chg(),.i_org(di_xana[1]),.clk(clk),.rstz(rrstz)), // OCP_160M
	u2_xana_db (.o_dbc(reg1F[2]),.o_chg(),.i_org(di_xana[2]),.clk(clk),.rstz(rrstz)),
	u3_xana_db (.o_dbc(reg1F[3]),.o_chg(),.i_org(di_xana[3]),.clk(clk),.rstz(rrstz)),
	u4_xana_db (.o_dbc(reg1F[4]),.o_chg(),.i_org(di_xana[4]),.clk(clk),.rstz(rrstz));
   dbnc // #(4,15) debounce 15~16 *2us +sync
        // this 2 bits are not used to control
	u0_sbov_db (.o_dbc(reg1F[6]),.o_chg(),.i_org(di_stbovp),.clk(clk_500k),.rstz(rrstz)),
	u0_rdet_db (.o_dbc(reg1F[7]),.o_chg(),.i_org(di_rd_det),.clk(clk_500k),.rstz(rrstz));

   assign  reg20 = UNREGX_D4;
   assign  reg21 = UNREGX_D4;
   assign  reg22 = UNREGX_D4;
   assign  reg23 = UNREGX_D4;
   assign  reg24 = UNREGX_D4;
   assign  reg25 = UNREGX_D4;
   assign  reg26 = UNREGX_D4;
   assign  reg27 = UNREGX_D4;

   assign {reg28,regx_wrdac[2]} = {dac_r_vs[8*0+:8],we['h28]}; // DACV8
   assign {reg29,regx_wrdac[3]} = {dac_r_vs[8*1+:8],we['h29]}; // DACV9
   assign {reg2A,regx_wrdac[4]} = {dac_r_vs[8*2+:8],we['h2a]}; // DACV10
   assign {reg2B,regx_wrdac[5]} = {dac_r_vs[8*3+:8],we['h2b]}; // DACV11
   assign {reg2C,regx_wrdac[6]} = {dac_r_vs[8*4+:8],we['h2c]}; // DACV12
   assign {reg2D,regx_wrdac[7]} = {dac_r_vs[8*5+:8],we['h2d]}; // DACV13
   assign {reg2E,regx_wrdac[8]} = {dac_r_vs[8*6+:8],we['h2e]}; // DACV14
   assign {reg2F,regx_wrdac[9]} = {dac_r_vs[8*7+:8],we['h2f]}; // DACV15

   assign {reg30,regx_wrdac[0]} = {r_dac_en,we['h30]}; // DACEN
   assign {reg31,regx_wrdac[1]} = {r_sar_en,we['h31]}; // SAREN
   assign  reg32 = {dac_comp}; // COMPI
   assign  reg33 = UNREGX_D4;
   assign  reg34 = UNREGX_D4;
   assign  reg35 = UNREGX_D4;
   assign  reg36 = UNREGX_D4;
   assign  reg37 = UNREGX_D4;

   assign  reg38 = UNREGX_D4;
   assign  reg39 = UNREGX_D4;
   assign  reg3A = UNREGX_D4;
   assign  reg3B = UNREGX_D4;
   assign  reg3C = UNREGX_D4;
   assign  reg3D = UNREGX_D4;
   assign  reg3E = UNREGX_D4;
   assign  reg3F = UNREGX_D4;

endmodule // regx

