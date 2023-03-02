
module sfrmux (
  isfrwait,
  sfraddr,
  c,
  ac,
  f0,
  rs,
  ov,
  f1,
  p,
  acc,
  b,
  dpl,
  dph,
  dps,
  dpc,
  p2,
  sp,
  smod,
  pmw,
  p2sel,
  gf0,
  stop,
  idle,
  ckcon,
  port0,
  port0ff,
  rmwinstr,
  arcon,
  md0,
  md1,
  md2,
  md3,
  md4,
  md5,
  t0_tmod,
  t0_tf0,
  t0_tf1,
  t0_tr0,
  t0_tr1,
  tl0,
  th0,
  t1_tmod,
  t1_tf1,
  t1_tr1,
  tl1,
  th1,
  wdtrel,
  ip0wdts,
  wdt_tm,
  t2con,
  s0con,
  s0buf,
  s0rell,
  s0relh,
  bd,
  ie0,
  it0,
  ie1,
  it1,
  iex2,
  iex3,
  iex4,
  iex5,
  iex6,
  iex7,
  iex8,
  iex9,
  iex10,
  iex11,
  iex12,
  ien0,
  ien1,
  ien2,
  ip0,
  ip1,
  isr_tm,
  i2c_int,
  i2cdat_o,
  i2cadr_o,
  i2ccon_o,
  i2csta_o,
  sfrdatai,
  tf1_gate,
  riti0_gate,
  iex7_gate,
  iex2_gate,
  srstflag,
  int_vect_8b, // External Interrupt 8
  int_vect_93, // External Interrupt 9
  int_vect_9b, // External Interrupt 10
  int_vect_a3, // External Interrupt 11
  ext_sfr_sel,
  sfrdatao
  );

    // SFR address bus
  input             isfrwait;
  input     [ 6: 0] sfraddr;
    // PSW register flags
  input             c;
  input             ac;
  input             f0;
  input     [ 1: 0] rs;
  input             ov;
  input             f1;
  input             p;
    // ACC register
  input     [ 7: 0] acc;
    // B register
  input     [ 7: 0] b;
    // DPL register
  input     [ 7: 0] dpl;
    // DPH register
  input     [ 7: 0] dph;
    // DPS register (Data Pointer Select)
  input     [ 3: 0] dps;
    // DPC register (Data Pointer Control)
  input     [5:0]   dpc;
    // Port 2 register
  input     [ 7: 0] p2;
    // SP (Stack Pointer) register
  input     [ 7: 0] sp;
    // PCON (Power Control) register flags
  input             smod;
  input             pmw;
  input             p2sel;
  input             gf0;
  input             stop;
  input             idle;
    // CKCON (Clock Control) register
  input     [ 7: 0] ckcon;
    // Port 0..3 output registers
  input     [ 7: 0] port0;
    // Port 0..3 input samples
  input     [ 7: 0] port0ff;
    // Read-Modify-Write instruction
    // to select between port sample and output register
  input             rmwinstr;
    // Multiplication/Division Unit inputs
  input     [ 7: 0] arcon;
  input     [ 7: 0] md0;
  input     [ 7: 0] md1;
  input     [ 7: 0] md2;
  input     [ 7: 0] md3;
  input     [ 7: 0] md4;
  input     [ 7: 0] md5;
    // Timer 0 inputs
  input     [ 3: 0] t0_tmod;
  input             t0_tf0;
  input             t0_tf1;
  input             t0_tr0;
  input             t0_tr1;
  input     [ 7: 0] tl0;
  input     [ 7: 0] th0;
    // Timer 1 inputs
  input     [ 3: 0] t1_tmod;
  input             t1_tf1;
  input             t1_tr1;
  input     [ 7: 0] tl1;
  input     [ 7: 0] th1;
    // Watchdog Timer input
  input     [ 7: 0] wdtrel;       // Watchdog Timer Reload
  input             ip0wdts;      // WDT status flag
  input             wdt_tm;       // test mode flag
  input     [ 7: 0] t2con;
    // Serial 0 inputs
  input     [ 7: 0] s0con;
  input     [ 7: 0] s0buf;
  input     [ 7: 0] s0rell;
  input     [ 7: 0] s0relh;
  input             bd;
  input             ie0;          // Ext. interrupt 0 request flag
  input             it0;          // Ext. interrupt 0 edge/level selection
  input             ie1;          // Ext. interrupt 1 request flag
  input             it1;          // Ext. interrupt 1 edge/level selection
  input             iex2;         // Ext. interrupt 2 request flag
  input             iex3;         // Ext. interrupt 3 / CC0 request flag
  input             iex4;         // Ext. interrupt 4 / CC1 request flag
  input             iex5;         // Ext. interrupt 5 / CC2 request flag
  input             iex6;         // Ext. interrupt 6 / CC3 request flag
  input             iex7;         // Ext. interrupt 7 request flag
  input             iex8;         // Ext. interrupt 8 request flag
  input             iex9;         // Ext. interrupt 9 request flag
  input             iex10;        // Ext. interrupt 10 request flag
  input             iex11;        // Ext. interrupt 11 request flag
  input             iex12;        // Ext. interrupt 12 request flag
  input     [ 7: 0] ien0;
  input     [ 5: 0] ien1;
  input     [ 5: 0] ien2;
  input     [ 5: 0] ip0;
  input     [ 5: 0] ip1;

  input             isr_tm;

    // I2C inputs
  input             i2c_int;
  input     [ 7: 0] i2cdat_o;
  input     [ 7: 0] i2cadr_o;
  input     [ 7: 0] i2ccon_o;
  input     [ 7: 0] i2csta_o;


    // SRST inputs
  input             srstflag;
    // External SFR data input
  input     [ 7: 0] sfrdatai;

  output            tf1_gate;     // t0_tf1 or t0_tf1
  wire              tf1_gate;
  output            riti0_gate;   // ri0 or ti0
  wire              riti0_gate;
  output            iex7_gate;    // iex7 or i2c_int (or i2c2_int)
  wire              iex7_gate;
  output            iex2_gate;    // iex2 or intspi
  wire              iex2_gate;
  output            int_vect_8b;
  wire              int_vect_8b;
  output            int_vect_93;
  wire              int_vect_93;
  output            int_vect_9b;
  wire              int_vect_9b;
  output            int_vect_a3;
  wire              int_vect_a3;
  output    [ 7: 0] sfrdatao;
  wire      [ 7: 0] sfrdatao;
  output    ext_sfr_sel;
  wire      ext_sfr_sel;

//*******************************************************************--

  `include "mcu51_param.v"

  wire[3:0] tcon30;
  wire[7:0] ircon;
  wire[7:0] ircon2;

  wire [ 8: 0] sfrdatao_int;

  //--------------------------------------------------------------------
  // TCON (3:0)
  //--------------------------------------------------------------------


      assign tcon30 = {ie1, it1, ie0, it0} ;

  //--------------------------------------------------------------------
  // IRCON(0) = iex7
  //--------------------------------------------------------------------
      assign ircon[0] = iex7 ;


  //--------------------------------------------------------------------
  // IRCON(1) = iex2
  //--------------------------------------------------------------------
      assign ircon[1] = iex2 ;


  //--------------------------------------------------------------------
  // IRCON(2) = iex3
  //--------------------------------------------------------------------
      assign ircon[2] = iex3 ;


  //--------------------------------------------------------------------
  // IRCON(3) = iex4
  //--------------------------------------------------------------------
      assign ircon[3] = iex4 ;


  //--------------------------------------------------------------------
  // IRCON(4) = iex5
  //--------------------------------------------------------------------
      assign ircon[4] = iex5 ;


  //--------------------------------------------------------------------
  // IRCON(5) = iex6
  //--------------------------------------------------------------------
      assign ircon[5] = iex6 ;


  //--------------------------------------------------------------------
  // IRCON(7:6) = exf2,tf2
  //--------------------------------------------------------------------

      assign ircon[7:6] = 2'b00 ;

  //--------------------------------------------------------------------
  // IRCON2(0) = iex8
  //--------------------------------------------------------------------
      assign ircon2[0] = iex8 ;


  //--------------------------------------------------------------------
  // IRCON2(1) = iex9
  //--------------------------------------------------------------------
      assign ircon2[1] = iex9 ;


  //--------------------------------------------------------------------
  // IRCON2(2) = iex10
  //--------------------------------------------------------------------
      assign ircon2[2] = iex10 ;


  //--------------------------------------------------------------------
  // IRCON2(3) = iex11
  //--------------------------------------------------------------------
      assign ircon2[3] = iex11 ;


  //--------------------------------------------------------------------
  // IRCON2(4) = iex12
  //--------------------------------------------------------------------
      assign ircon2[4] = iex12 ;


  //--------------------------------------------------------------------
  // IRCON2(7:5) = 0
  //--------------------------------------------------------------------
  assign ircon2[7:5] = 3'b000 ;

  //--------------------------------------------------------------------
  assign sfrdatao_int =
    ( sfraddr == SP_ID          )? {sp, 1'b1} :
    ( sfraddr == DPL_ID         )? {dpl, 1'b1} :
    ( sfraddr == DPH_ID         )? {dph, 1'b1} :
    ( sfraddr == WDTREL_ID      )? {wdtrel, 1'b1} :
    ( sfraddr == PCON_ID        )? {smod,wdt_tm,isr_tm,pmw,p2sel,gf0,stop,idle, 1'b1} :
    ( sfraddr == TCON_ID        )? {(t0_tf1 | t1_tf1),(t0_tr1 | t1_tr1),t0_tf0,t0_tr0, tcon30, 1'b1} :
    ( sfraddr == TMOD_ID        )? {t1_tmod, t0_tmod, 1'b1} :
    ( sfraddr == TL0_ID         )? {tl0, 1'b1} :
    ( sfraddr == TL1_ID         )? {tl1, 1'b1} :
    ( sfraddr == TH0_ID         )? {th0, 1'b1} :
    ( sfraddr == TH1_ID         )? {th1, 1'b1} :
    ( sfraddr == CKCON_ID       )? {ckcon, 1'b1} :

    ( sfraddr == DPS_ID         )? {4'b0000, dps, 1'b1} :
    ( sfraddr == DPC_ID         )? {2'b00, dpc, 1'b1} :

    ( sfraddr == S0CON_ID       )? {s0con, 1'b1} :
    ( sfraddr == S0BUF_ID       )? {s0buf, 1'b1} :
    ( sfraddr == IEN2_ID        )? {2'b00, ien2, 1'b1} :

    ( sfraddr == P2_ID          )? {p2, 1'b1} :

    ( sfraddr == IEN0_ID        )? {ien0, 1'b1} :
    ( sfraddr == IP0_ID         )? {1'b0, ip0wdts,ip0, 1'b1} :
    ( sfraddr == S0RELL_ID      )? {s0rell, 1'b1} :

    ( sfraddr == IEN1_ID        )? {2'b00, ien1, 1'b1} :
    ( sfraddr == IP1_ID         )? {2'b00, ip1, 1'b1} :
    ( sfraddr == S0RELH_ID      )? {s0relh, 1'b1} :
//  ( sfraddr == IRCON2_ID      )? {ircon2, 1'b1} :

    ( sfraddr == IRCON_ID       )? {ircon, 1'b1} :
    ( sfraddr == T2CON_ID       )? {t2con, 1'b1} :

    ( sfraddr == PSW_ID         )? {c, ac, f0, rs, ov, f1, p, 1'b1} :

    ( sfraddr == ADCON_ID       )? { bd , 7'b0000000 , 1'b1 } :
    ( sfraddr == I2CDAT_ID      )? { i2cdat_o , 1'b1 } :
    ( sfraddr == I2CADR_ID      )? { i2cadr_o , 1'b1 } :
    ( sfraddr == I2CCON_ID      )? { i2ccon_o , 1'b1 } :
    ( sfraddr == I2CSTA_ID      )? { i2csta_o , 1'b1 } :

    ( sfraddr == ACC_ID         )? { acc , 1'b1 } :
    ( sfraddr == MD0_ID         )? { md0 , 1'b1 } :
    ( sfraddr == MD1_ID         )? { md1 , 1'b1 } :
    ( sfraddr == MD2_ID         )? { md2 , 1'b1 } :
    ( sfraddr == MD3_ID         )? { md3 , 1'b1 } :
    ( sfraddr == MD4_ID         )? { md4 , 1'b1 } :
    ( sfraddr == MD5_ID         )? { md5 , 1'b1 } :
    ( sfraddr == ARCON_ID       )? { arcon , 1'b1 } :
    ( sfraddr == B_ID           )? { b , 1'b1 } :
    ( sfraddr == SRST_ID        )? { 7'b0000000,srstflag , 1'b1} :

    ( sfraddr == P0_ID &&  rmwinstr == 1'b1)             ? {port0,   1'b1} :
    ( sfraddr == P0_ID && (rmwinstr == 1'b0 || isfrwait))? {port0ff, 1'b1} :

    {sfrdatai, 1'b0} ;

  assign tf1_gate = t0_tf1 | t1_tf1 ;



  assign riti0_gate = s0con[0] | s0con[1] ;



//assign iex7_gate = ircon[0] | i2c_int ;
  assign iex7_gate = ircon[0] ;







  assign iex2_gate = ircon[1] ;


  assign int_vect_8b = iex8;
  assign int_vect_93 = iex9;
  assign int_vect_9b = iex10;
  assign int_vect_a3 = iex11;

  assign ext_sfr_sel = sfrdatao_int[0] ;
  assign sfrdatao = sfrdatao_int[8:1];

endmodule // SFRMUX

