
module isr (
  clkper,
  rst,
  intcall,
  retiinstr,
  int_vect_03,
  int_vect_0b,
  t0ff,
  int_vect_13,
  int_vect_1b,
  t1ff,
  int_vect_23,
  i2c_int,
  rxd0ff,
  int_vect_43,
  sdaiff,
  int_vect_4b,
  int_vect_53,
  int_vect_5b,
  int_vect_63,
  int_vect_6b,
  int_vect_8b,
  int_vect_93,
  int_vect_9b,
  int_vect_a3,
  int_vect_ab,
  irq,
  intvect,
  int_ack_03,
  int_ack_0b,
  int_ack_13,
  int_ack_1b,
  int_ack_43,
  int_ack_4b,
  int_ack_53,
  int_ack_5b,
  int_ack_63,
  int_ack_6b,
  int_ack_8b,
  int_ack_93,
  int_ack_9b,
  int_ack_a3,
  int_ack_ab,
  is_reg,
  ip0,
  ip1,
  ien0,
  ien1,
  ien2,
  isr_tm,
  sfraddr,
  sfrdatai,
  sfrwe
  );

  `include "mcu51_param.v"
  // Control signal inputs
  input             clkper;             // Global clock input
  input             rst;                // Global reset input

  // CPU input signals
  input             intcall;
  input             retiinstr;

  // Interrupt request input signals
  input             int_vect_03;        // External Interrupt 0
  input             int_vect_0b;        // Timer 0 Interrupt
  input             t0ff;
  input             int_vect_13;        // External Interrupt 1
  input             int_vect_1b;        // Timer 1 Interrupt
  input             t1ff;
  input             int_vect_23;        // Serial 0 Interrupt
  input             i2c_int;
  input             rxd0ff;
  input             int_vect_43;        // External Interrupt 7
  input             sdaiff;
  input             int_vect_4b;        // External Interrupt 2
  input             int_vect_53;        // External Interrupt 3
  input             int_vect_5b;        // External Interrupt 4
  input             int_vect_63;        // External Interrupt 5
  input             int_vect_6b;        // External Interrupt 6
  input             int_vect_8b;        // External Interrupt 8
  input             int_vect_93;        // External Interrupt 9
  input             int_vect_9b;        // External Interrupt 10
  input             int_vect_a3;        // External Interrupt 11
  input             int_vect_ab;        // External Interrupt 12

  // Interrupt request to CPU signal
  output            irq;
  wire              irq;
  // Interrupt vector signal
  output    [ 4: 0] intvect;
  wire      [ 4: 0] intvect;

  // Interrupt acknowledge signals
  output            int_ack_03;
  reg               int_ack_03;
  output            int_ack_0b;
  reg               int_ack_0b;
  output            int_ack_13;
  reg               int_ack_13;
  output            int_ack_1b;
  reg               int_ack_1b;

  output            int_ack_43;
  reg               int_ack_43;
  output            int_ack_4b;
  reg               int_ack_4b;
  output            int_ack_53;
  reg               int_ack_53;
  output            int_ack_5b;
  reg               int_ack_5b;
  output            int_ack_63;
  reg               int_ack_63;
  output            int_ack_6b;
  reg               int_ack_6b;

  output            int_ack_8b;
  reg               int_ack_8b;
  output            int_ack_93;
  reg               int_ack_93;
  output            int_ack_9b;
  reg               int_ack_9b;
  output            int_ack_a3;
  reg               int_ack_a3;
  output            int_ack_ab;
  reg               int_ack_ab;

  // In service register
  output    [ 3: 0] is_reg;
  wire      [ 3: 0] is_reg;

  // interrupt priority SFR registers output
  output    [ 5: 0] ip0;
  wire      [ 5: 0] ip0;
  output    [ 5: 0] ip1;
  wire      [ 5: 0] ip1;

  // interrupt enable SFR registers output
  output    [ 7: 0] ien0;
  wire      [ 7: 0] ien0;
  output    [ 5: 0] ien1;
  wire      [ 5: 0] ien1;
  output    [ 5: 0] ien2;
  wire      [ 5: 0] ien2;

  output            isr_tm;
  wire              isr_tm;
  // Special function register interface
  input     [ 6: 0] sfraddr;
  input     [ 7: 0] sfrdatai;
  input             sfrwe;

//*******************************************************************--

  function  [30: 0] LEVEL_PRIOR;
    input   [ 4: 0] in0;
    input   [ 4: 0] in1;
    input   [ 4: 0] in2;
    input   [ 4: 0] in3;
    input   [ 4: 0] in4;
    input   [ 4: 0] in5;
    input           en_in;

    reg     [ 4: 0] out0;
    reg     [ 4: 0] out1;
    reg     [ 4: 0] out2;
    reg     [ 4: 0] out3;
    reg     [ 4: 0] out4;
    reg     [ 4: 0] out5;
    reg             en_out;

    reg             en0_out;
    reg             en1_out;
    reg             en2_out;
    reg             en3_out;
    reg             en4_out;

    begin
      out0 = in0 & {5{en_in}};
      en0_out = en_in & (~(in0[0] | in0[1] | in0[2] | in0[3] | in0[4]));
      out1 = in1 & {5{en0_out}};
      en1_out = en0_out & (~(in1[0] | in1[1] | in1[2] | in1[3] | in1[4]));
      out2 = in2 & {5{en1_out}};
      en2_out = en1_out & (~(in2[0] | in2[1] | in2[2] | in2[3] | in2[4]));
      out3 = in3 & {5{en2_out}};
      en3_out = en2_out & (~(in3[0] | in3[1] | in3[2] | in3[3] | in3[4]));
      out4 = in4 & {5{en3_out}};
      en4_out = en3_out & (~(in4[0] | in4[1] | in4[2] | in4[3] | in4[4]));
      out5 = in5 & {5{en4_out}};
      en_out = en4_out & (~(in5[0] | in5[1] | in5[2] | in5[3] | in5[4])) ;

//	out0 = in0 & {5{en_in}};   en0_out = en_in   & ~|in0;
//	out1 = in1 & {5{en0_out}}; en1_out = en0_out & ~|in1;
//	out2 = in2 & {5{en1_out}}; en2_out = en1_out & ~|in2;
//	out3 = in3 & {5{en2_out}}; en3_out = en2_out & ~|in3;
//	out4 = in4 & {5{en3_out}}; en4_out = en3_out & ~|in4;
//	out5 = in5 & {5{en4_out}}; en_out  = en4_out & ~|in5;

      LEVEL_PRIOR = {out0, out1,
                     out2, out3,
                     out4, out5, en_out};
    end
  endfunction

  //---------------------------------------------------------------
  // Special Function Registers
  //---------------------------------------------------------------
  // Interrupt enable registers
  reg       [ 6: 0] ien0_reg;
  reg       [ 5: 0] ien1_reg;
//reg       [ 5: 0] ien2_reg;
//reg       [ 1: 0] ien2_dff;
  reg       [ 5: 0] ien2_reg;
  reg       [ 5: 0] ien3_reg;
  reg       [ 5: 0] ien4_reg;

  // Interrupt priority register
  reg       [ 5: 0] ip0_reg;
  reg       [ 5: 0] ip1_reg;

  //---------------------------------------------------------------
  // Masked Interrupt requests
  //---------------------------------------------------------------
  // interrupt request group0
  wire              irq0_g0;
  wire              irq1_g0;
  wire              irq2_g0;
  wire              irq3_g0;
  wire              irq4_g0;
  // interrupt request group1
  wire              irq0_g1;
  wire              irq1_g1;
  wire              irq2_g1;
  wire              irq3_g1;
  wire              irq4_g1;
  // interrupt request group2
  wire              irq0_g2;
  wire              irq1_g2;
  wire              irq2_g2;
  wire              irq3_g2;
  wire              irq4_g2;
  // interrupt request group3
  wire              irq0_g3;
  wire              irq1_g3;
  wire              irq2_g3;
  wire              irq3_g3;
  wire              irq4_g3;
  // interrupt request group4
  wire              irq0_g4;
  wire              irq1_g4;
  wire              irq2_g4;
  wire              irq3_g4;
  wire              irq4_g4;
  // interrupt request group5
  wire              irq0_g5;
  wire              irq1_g5;
  wire              irq2_g5;
  wire              irq3_g5;
  wire              irq4_g5;

  //----------------------------------------------------
  // interrupt priority group after chose
  // one interrupt with the highest priority inside group
  //---------------------------------------------------
  wire      [ 4: 0] irq_g0;
  wire      [ 4: 0] irq_g1;
  wire      [ 4: 0] irq_g2;
  wire      [ 4: 0] irq_g3;
  wire      [ 4: 0] irq_g4;
  wire      [ 4: 0] irq_g5;

  wire      [ 4: 0] irq_g0_p3;
  wire      [ 4: 0] irq_g0_p2;
  wire      [ 4: 0] irq_g0_p1;
  wire      [ 4: 0] irq_g0_p0;

  wire      [ 4: 0] irq_g1_p3;
  wire      [ 4: 0] irq_g1_p2;
  wire      [ 4: 0] irq_g1_p1;
  wire      [ 4: 0] irq_g1_p0;

  wire      [ 4: 0] irq_g2_p3;
  wire      [ 4: 0] irq_g2_p2;
  wire      [ 4: 0] irq_g2_p1;
  wire      [ 4: 0] irq_g2_p0;

  wire      [ 4: 0] irq_g3_p3;
  wire      [ 4: 0] irq_g3_p2;
  wire      [ 4: 0] irq_g3_p1;
  wire      [ 4: 0] irq_g3_p0;

  wire      [ 4: 0] irq_g4_p3;
  wire      [ 4: 0] irq_g4_p2;
  wire      [ 4: 0] irq_g4_p1;
  wire      [ 4: 0] irq_g4_p0;

  wire      [ 4: 0] irq_g5_p3;
  wire      [ 4: 0] irq_g5_p2;
  wire      [ 4: 0] irq_g5_p1;
  wire      [ 4: 0] irq_g5_p0;

  wire              en_in_prior0;
  wire              en_in_prior1;
  wire              en_in_prior2;
  wire              en_in_prior3;

  wire              en_out_prior0;
  wire              en_out_prior1;
  wire              en_out_prior2;
  wire              en_out_prior3;

  wire      [ 4: 0] int_prior3_g0;
  wire      [ 4: 0] int_prior3_g1;
  wire      [ 4: 0] int_prior3_g2;
  wire      [ 4: 0] int_prior3_g3;
  wire      [ 4: 0] int_prior3_g4;
  wire      [ 4: 0] int_prior3_g5;

  wire      [ 4: 0] int_prior2_g0;
  wire      [ 4: 0] int_prior2_g1;
  wire      [ 4: 0] int_prior2_g2;
  wire      [ 4: 0] int_prior2_g3;
  wire      [ 4: 0] int_prior2_g4;
  wire      [ 4: 0] int_prior2_g5;

  wire      [ 4: 0] int_prior1_g0;
  wire      [ 4: 0] int_prior1_g1;
  wire      [ 4: 0] int_prior1_g2;
  wire      [ 4: 0] int_prior1_g3;
  wire      [ 4: 0] int_prior1_g4;
  wire      [ 4: 0] int_prior1_g5;

  wire      [ 4: 0] int_prior0_g0;
  wire      [ 4: 0] int_prior0_g1;
  wire      [ 4: 0] int_prior0_g2;
  wire      [ 4: 0] int_prior0_g3;
  wire      [ 4: 0] int_prior0_g4;
  wire      [ 4: 0] int_prior0_g5;

  //---------------------------------------------------------------
  // Interrupt request registers after priority decoder
  //---------------------------------------------------------------
  wire      [ 4: 0] int_req0_reg;
  wire      [ 4: 0] int_req1_reg;
  wire      [ 4: 0] int_req2_reg;
  wire      [ 4: 0] int_req3_reg;
  wire      [ 4: 0] int_req4_reg;
  wire      [ 4: 0] int_req5_reg;

  //--------------------------------------------------------------
  // interrupt vector register
  //--------------------------------------------------------------
  reg       [ 4: 0] intvect_reg;
//reg       [ 3: 0] intvectDff ;
//wire      [ 4: 0] intvect_reg;
  //--------------------------------------------------------------
  // interrupt acknowledge vector
  //--------------------------------------------------------------
  reg       [29: 0] ackvec;
  wire      [29: 0] intack;
  wire      [29: 0] selector;

  //--------------------------------------------------------------
  // this signals define to which group belong interrupt that
  // service now is started
  //--------------------------------------------------------------
  wire              ack_g0;
  wire              ack_g1;
  wire              ack_g2;
  wire              ack_g3;
  wire              ack_g4;
  wire              ack_g5;

  //--------------------------------------------------------------
  // priority level of interrupt that interrupt subroutine
  // CPU is calling now
  //--------------------------------------------------------------
  wire      [ 1: 0] int_prior;

  //--------------------------------------------------------------
  // interrupt in service
  //--------------------------------------------------------------
  reg       [ 3: 0] is_reg_s;
  reg               isr_tm_reg;
  wire              int_vect_int_0b_s;
  wire              int_vect_int_1b_s;
  wire              int_vect_int_23_s;
  wire              int_vect_int_43_s;
  wire              int_vect_int_4b_s;
  wire              int_vect_int_83_s;

  //--------------------------------------------------------------
  // signals for used / not used interrupts
  //--------------------------------------------------------------
  wire              int_vect_int_03;        // External Interrupt 0
  wire              int_vect_int_0b;        // Timer 0 Interrupt
  wire              t0ff_int;
  wire              int_vect_int_13;        // External Interrupt 1
  wire              int_vect_int_1b;        // Timer 1 Interrupt
  wire              t1ff_int;
  wire              int_vect_int_23;        // Serial 0 Interrupt
  wire              rxd0ff_int;
  wire              int_vect_int_2b;        // Timer 2 Interrupt
  wire              int_vect_int_33;        // for future use (33)
  wire              int_vect_int_3b;        // for future use (3b)
  wire              int_vect_int_43;        // External Interrupt 7
  wire              sdaiff_int;
  wire              int_vect_int_4b;        // External Interrupt 2
  wire              misoiff_int;
  wire              int_vect_int_53;        // External Interrupt 3
  wire              int_vect_int_5b;        // External Interrupt 4
  wire              int_vect_int_63;        // External Interrupt 5
  wire              int_vect_int_6b;        // External Interrupt 6
  wire              int_vect_int_73;        // for future use (73)
  wire              int_vect_int_7b;        // for future use (7b)
  wire              int_vect_int_83;        // Serial 1 Interrupt
  wire              rxd1ff_int;
  wire              int_vect_int_8b;        // External Interrupt 8
  wire              int_vect_int_93;        // External Interrupt 9
  wire              int_vect_int_9b;        // External Interrupt 10
  wire              int_vect_int_a3;        // External Interrupt 11
  wire              int_vect_int_ab;        // External Interrupt 12
  wire              int_vect_int_b3;        // for future use (b3)
  wire              int_vect_int_bb;        // for future use (bb)
  wire              int_vect_int_c3;        // for future use (c3)
  wire              int_vect_int_cb;        // for future use (cb)
  wire              int_vect_int_d3;        // for future use (d3)
  wire              int_vect_int_db;        // for future use (db)
  wire              int_vect_int_e3;        // for future use (e3)
  wire              int_vect_int_eb;        // RTC interrupt

  //--------------------------------------------------------------
  // interrupt request register
  //--------------------------------------------------------------
  reg               irq_r;

  //--------------------------------------------------------------
  // assignments for used / not used interrupts
  //--------------------------------------------------------------
  assign int_vect_int_03 = int_vect_03;
  assign int_vect_int_0b = int_vect_0b;
  assign t0ff_int        = 1'h0 ;
  assign int_vect_int_13 = int_vect_13;
  assign int_vect_int_1b = int_vect_1b;
  assign t1ff_int        = 1'h0 ;
  assign int_vect_int_23 = int_vect_23;
  assign rxd0ff_int      = rxd0ff;
  assign int_vect_int_2b = i2c_int;
  assign int_vect_int_33 = 1'b0;
  assign int_vect_int_3b = 1'b0; // for future use (3b)
  assign int_vect_int_43 = int_vect_43; // 1'h0 ;
  assign sdaiff_int      = sdaiff;
  assign int_vect_int_4b = int_vect_4b; // 1'h0;
  assign misoiff_int     = 1'b0;
  assign int_vect_int_53 = int_vect_53; // 1'h0 ;
  assign int_vect_int_5b = int_vect_5b; // 1'h0 ;
  assign int_vect_int_63 = int_vect_63; // 1'h0 ;
  assign int_vect_int_6b = int_vect_6b; // 1'b0 ;
  assign int_vect_int_73 = 1'b0; // for future use (73)
  assign int_vect_int_7b = 1'b0; // for future use (7b)
  assign int_vect_int_83 = 1'b0; // iexCdcBusy ;
  assign rxd1ff_int      = 1'b0;
  assign int_vect_int_8b = int_vect_8b;
  assign int_vect_int_93 = int_vect_93; // 1'h0 ;
  assign int_vect_int_9b = int_vect_9b; // 1'h0 ;
  assign int_vect_int_a3 = int_vect_a3; // 1'h0 ;
  assign int_vect_int_ab = int_vect_ab; // 1'h0 ;
  assign int_vect_int_b3 = 1'b0; // for future use (b3)
  assign int_vect_int_bb = 1'b0; // for future use (bb)
  assign int_vect_int_c3 = 1'b0;
  assign int_vect_int_cb = 1'b0;
  assign int_vect_int_d3 = 1'b0; // for future use (d3)
  assign int_vect_int_db = 1'b0; // for future use (db)
  assign int_vect_int_e3 = 1'b0; // for future use (e3)
  assign int_vect_int_eb = 1'b0;

  //------------------------------------------------------------------
  // Interrupt enable 0 SFR register output map
  //------------------------------------------------------------------
  assign ien0       = {ien0_reg[6], 1'b0, ien0_reg[5:0]} ;

  //------------------------------------------------------------------
  // Interrupt enable 1 SFR register output map
  //------------------------------------------------------------------
  assign ien1       = ien1_reg ;

  //------------------------------------------------------------------
  // Interrupt enable 2 SFR register output map
  //------------------------------------------------------------------
  assign ien2       = ien2_reg ;

  //------------------------------------------------------------------
  // Interrupt priority 0 SFR register output map
  //------------------------------------------------------------------
  assign ip0        = ip0_reg ;

  //------------------------------------------------------------------
  // Interrupt priority 1 SFR register output map
  //------------------------------------------------------------------
  assign ip1        = ip1_reg ;

  //------------------------------------------------------------------
  // Interrupt vector output map
  //------------------------------------------------------------------
  assign intvect    = intvect_reg ;

  //------------------------------------------------------------------
  // is_reg output map
  //------------------------------------------------------------------
  assign is_reg     = is_reg_s ;

  //------------------------------------------------------------------
  // SFR register
  //------------------------------------------------------------------

      //------------------------------------------------------------------
      // IEN0 SFR register
      //------------------------------------------------------------------
      always @(posedge clkper)
      begin : ien0_reg_proc
        if (rst == 1'b1)
        begin
          ien0_reg <= {IEN0_RV[7], IEN0_RV[5:0]} ;
        end
        else
        begin
          if ((sfrwe == 1'b1) & (sfraddr == IEN0_ID))
          begin
            ien0_reg <= {sfrdatai[7], sfrdatai[5:0]} ;
          end
        end
      end

      //------------------------------------------------------------------
      // IEN1 SFR register
      //------------------------------------------------------------------
      always @(posedge clkper)
      begin : ien1_reg_proc
        if (rst == 1'b1)
        begin
          ien1_reg <= IEN1_RV[5:0] ;
        end
        else
        begin
          if ((sfrwe == 1'b1) & (sfraddr == IEN1_ID))
          begin
            ien1_reg <= sfrdatai[5:0] ;
          end
        end
      end

//    assign  ien1_reg  =  6'h00 ;

      //------------------------------------------------------------------
      // IEN2 SFR register
      //------------------------------------------------------------------
      always @(posedge clkper)
      begin : ien2_reg_proc
        if (rst == 1'b1)
        begin
          ien2_reg <= IEN2_RV[5:0] ;
        end
        else
        begin
          if ((sfrwe == 1'b1) & (sfraddr == IEN2_ID))
          begin
            ien2_reg <= sfrdatai[5:0] ;
          end
        end
      end

//    assign  ien2_reg  =  6'h0;



      //------------------------------------------------------------------
      // IP0 SFR register
      //------------------------------------------------------------------
      always @(posedge clkper)
      begin : ip0_reg_proc
        if (rst == 1'b1)
        begin
          ip0_reg <= IP0_RV[5:0] ;
        end
        else
        begin
          if ((sfrwe == 1'b1) & (sfraddr == IP0_ID))
          begin
            ip0_reg <= sfrdatai[5:0] ;
          end
        end
      end

      //------------------------------------------------------------------
      // IP1 SFR register
      //------------------------------------------------------------------
      always @(posedge clkper)
      begin : ip1_reg_proc
        if (rst == 1'b1)
        begin
          ip1_reg <= IP1_RV[5:0] ;
        end
        else
        begin
          if ((sfrwe == 1'b1) & (sfraddr == IP1_ID))
          begin
            ip1_reg <= sfrdatai[5:0] ;
          end
        end
      end

    always @(posedge clkper)
    begin : no_ien3_reg_proc
      ien3_reg <= IEN3_RV[5:0] ;
    end
    always @(posedge clkper)
    begin : no_ien4_reg_proc
      ien4_reg <= IEN4_RV[5:0] ;
    end


  //------------------------------------------------------------------
  // ISR TEST MODE register
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : isr_tm_reg_proc
    if (rst == 1'b1)
    begin
      isr_tm_reg <= PCON_RV[5] ;
    end
    else
    begin
      if ((sfrwe == 1'b1) & ( sfraddr == PCON_ID))
      begin
        isr_tm_reg <= sfrdatai[5] ;
      end
    end
  end

  assign isr_tm = isr_tm_reg ;

  assign int_vect_int_0b_s = (isr_tm_reg == 1'b0) ? int_vect_int_0b : t0ff_int ;
  assign int_vect_int_1b_s = (isr_tm_reg == 1'b0) ? int_vect_int_1b : t1ff_int ;
  assign int_vect_int_23_s = (isr_tm_reg == 1'b0) ? int_vect_int_23 : rxd0ff_int ;
  assign int_vect_int_43_s = (isr_tm_reg == 1'b0) ? int_vect_int_43 : sdaiff_int ;
  assign int_vect_int_4b_s = (isr_tm_reg == 1'b0) ? int_vect_int_4b : misoiff_int ;
  assign int_vect_int_83_s = (isr_tm_reg == 1'b0) ? int_vect_int_83 : rxd1ff_int ;

  //-------------------------------------------------------------------
  // enable or disable interrupts request individually
  //-------------------------------------------------------------------
  assign irq0_g0 = int_vect_int_03    & ien0_reg[0] ;
  assign irq1_g0 = int_vect_int_33    & ien3_reg[0] ;
  assign irq2_g0 = int_vect_int_83_s  & ien2_reg[0] ;
  assign irq3_g0 = int_vect_int_c3    & ien4_reg[0] ;
  assign irq4_g0 = int_vect_int_43_s  & ien1_reg[0] ;

  //----------------------------------------------------------
  // g0
  //----------------------------------------------------------
  assign irq_g0 = (irq0_g0 == 1'b1) ? 5'b10000 :
                  (irq1_g0 == 1'b1) ? 5'b01000 :
                  (irq2_g0 == 1'b1) ? 5'b00100 :
                  (irq3_g0 == 1'b1) ? 5'b00010 :
                  (irq4_g0 == 1'b1) ? 5'b00001 : 5'b00000 ;

  //----------------------------------------------------------
  // interrupt priority level demultiplexer
  //----------------------------------------------------------
  assign irq_g0_p3 = ((ip1_reg[0]) == 1'b1 &
                      (ip0_reg[0]) == 1'b1) ? irq_g0 : 5'b00000 ;
  assign irq_g0_p2 = ((ip1_reg[0]) == 1'b1 &
                      (ip0_reg[0]) == 1'b0) ? irq_g0 : 5'b00000 ;
  assign irq_g0_p1 = ((ip1_reg[0]) == 1'b0 &
                      (ip0_reg[0]) == 1'b1) ? irq_g0 : 5'b00000 ;
  assign irq_g0_p0 = ((ip1_reg[0]) == 1'b0 &
                      (ip0_reg[0]) == 1'b0) ? irq_g0 : 5'b00000 ;

  assign irq0_g1 = int_vect_int_0b_s  & ien0_reg[1] ;
  assign irq1_g1 = int_vect_int_3b    & ien3_reg[1] ;
  assign irq2_g1 = int_vect_int_8b    & ien2_reg[1] ;
  assign irq3_g1 = int_vect_int_cb    & ien4_reg[1] ;
  assign irq4_g1 = int_vect_int_4b_s  & ien1_reg[1] ;

  //----------------------------------------------------------
  // g1
  //----------------------------------------------------------
  assign irq_g1 = (irq0_g1 == 1'b1) ? 5'b10000 :
                  (irq1_g1 == 1'b1) ? 5'b01000 :
                  (irq2_g1 == 1'b1) ? 5'b00100 :
                  (irq3_g1 == 1'b1) ? 5'b00010 :
                  (irq4_g1 == 1'b1) ? 5'b00001 : 5'b00000 ;

  //----------------------------------------------------------
  // interrupt priority level demultiplexer
  //----------------------------------------------------------
  assign irq_g1_p3 = ((ip1_reg[1]) == 1'b1 &
                      (ip0_reg[1]) == 1'b1) ? irq_g1 : 5'b00000 ;
  assign irq_g1_p2 = ((ip1_reg[1]) == 1'b1 &
                      (ip0_reg[1]) == 1'b0) ? irq_g1 : 5'b00000 ;
  assign irq_g1_p1 = ((ip1_reg[1]) == 1'b0 &
                      (ip0_reg[1]) == 1'b1) ? irq_g1 : 5'b00000 ;
  assign irq_g1_p0 = ((ip1_reg[1]) == 1'b0 &
                      (ip0_reg[1]) == 1'b0) ? irq_g1 : 5'b00000 ;

  assign irq0_g2 = int_vect_int_13 & ien0_reg[2] ;
  assign irq1_g2 = int_vect_int_73 & ien3_reg[2] ;
  assign irq2_g2 = int_vect_int_93 & ien2_reg[2] ;
  assign irq3_g2 = int_vect_int_d3 & ien4_reg[2] ;
  assign irq4_g2 = int_vect_int_53 & ien1_reg[2] ;

  //----------------------------------------------------------
  // g2
  //----------------------------------------------------------
  assign irq_g2 = (irq0_g2 == 1'b1) ? 5'b10000 :
                  (irq1_g2 == 1'b1) ? 5'b01000 :
                  (irq2_g2 == 1'b1) ? 5'b00100 :
                  (irq3_g2 == 1'b1) ? 5'b00010 :
                  (irq4_g2 == 1'b1) ? 5'b00001 : 5'b00000 ;

  //----------------------------------------------------------
  // interrupt priority level demultiplexer
  //----------------------------------------------------------
  assign irq_g2_p3 = ((ip1_reg[2]) == 1'b1 &
                      (ip0_reg[2]) == 1'b1) ? irq_g2 : 5'b00000 ;
  assign irq_g2_p2 = ((ip1_reg[2]) == 1'b1 &
                      (ip0_reg[2]) == 1'b0) ? irq_g2 : 5'b00000 ;
  assign irq_g2_p1 = ((ip1_reg[2]) == 1'b0 &
                      (ip0_reg[2]) == 1'b1) ? irq_g2 : 5'b00000 ;
  assign irq_g2_p0 = ((ip1_reg[2]) == 1'b0 &
                      (ip0_reg[2]) == 1'b0) ? irq_g2 : 5'b00000 ;

  assign irq0_g3 = int_vect_int_1b_s  & ien0_reg[3] ;
  assign irq1_g3 = int_vect_int_7b    & ien3_reg[3] ;
  assign irq2_g3 = int_vect_int_9b    & ien2_reg[3] ;
  assign irq3_g3 = int_vect_int_db    & ien4_reg[3] ;
  assign irq4_g3 = int_vect_int_5b    & ien1_reg[3] ;

  //----------------------------------------------------------
  // g3
  //----------------------------------------------------------
  assign irq_g3 = (irq0_g3 == 1'b1) ? 5'b10000 :
                  (irq1_g3 == 1'b1) ? 5'b01000 :
                  (irq2_g3 == 1'b1) ? 5'b00100 :
                  (irq3_g3 == 1'b1) ? 5'b00010 :
                  (irq4_g3 == 1'b1) ? 5'b00001 : 5'b00000 ;

  //----------------------------------------------------------
  // interrupt priority level demultiplexer
  //----------------------------------------------------------
  assign irq_g3_p3 = ((ip1_reg[3]) == 1'b1 &
                      (ip0_reg[3]) == 1'b1) ? irq_g3 : 5'b00000 ;
  assign irq_g3_p2 = ((ip1_reg[3]) == 1'b1 &
                      (ip0_reg[3]) == 1'b0) ? irq_g3 : 5'b00000 ;
  assign irq_g3_p1 = ((ip1_reg[3]) == 1'b0 &
                      (ip0_reg[3]) == 1'b1) ? irq_g3 : 5'b00000 ;
  assign irq_g3_p0 = ((ip1_reg[3]) == 1'b0 &
                      (ip0_reg[3]) == 1'b0) ? irq_g3 : 5'b00000 ;

  assign irq0_g4 = int_vect_int_23_s  & ien0_reg[4] ;
  assign irq1_g4 = int_vect_int_b3    & ien3_reg[4] ;
  assign irq2_g4 = int_vect_int_a3    & ien2_reg[4] ;
  assign irq3_g4 = int_vect_int_e3    & ien4_reg[4] ;
  assign irq4_g4 = int_vect_int_63    & ien1_reg[4] ;

  //----------------------------------------------------------
  // g4
  //----------------------------------------------------------
  assign irq_g4 = (irq0_g4 == 1'b1) ? 5'b10000 :
                  (irq1_g4 == 1'b1) ? 5'b01000 :
                  (irq2_g4 == 1'b1) ? 5'b00100 :
                  (irq3_g4 == 1'b1) ? 5'b00010 :
                  (irq4_g4 == 1'b1) ? 5'b00001 : 5'b00000 ;

  //----------------------------------------------------------
  // interrupt priority level demultiplexer
  //----------------------------------------------------------
  assign irq_g4_p3 = ((ip1_reg[4]) == 1'b1 &
                      (ip0_reg[4]) == 1'b1) ? irq_g4 : 5'b00000 ;
  assign irq_g4_p2 = ((ip1_reg[4]) == 1'b1 &
                      (ip0_reg[4]) == 1'b0) ? irq_g4 : 5'b00000 ;
  assign irq_g4_p1 = ((ip1_reg[4]) == 1'b0 &
                      (ip0_reg[4]) == 1'b1) ? irq_g4 : 5'b00000 ;
  assign irq_g4_p0 = ((ip1_reg[4]) == 1'b0 &
                      (ip0_reg[4]) == 1'b0) ? irq_g4 : 5'b00000 ;

  assign irq0_g5 = int_vect_int_2b & ien0_reg[5] ;
  assign irq1_g5 = int_vect_int_bb & ien3_reg[5] ;
  assign irq2_g5 = int_vect_int_ab & ien2_reg[5] ;
  assign irq3_g5 = int_vect_int_eb & ien4_reg[5] ;
  assign irq4_g5 = int_vect_int_6b & ien1_reg[5] ;

  //----------------------------------------------------------
  // g5
  //----------------------------------------------------------
  assign irq_g5 = (irq0_g5 == 1'b1) ? 5'b10000 :
                  (irq1_g5 == 1'b1) ? 5'b01000 :
                  (irq2_g5 == 1'b1) ? 5'b00100 :
                  (irq3_g5 == 1'b1) ? 5'b00010 :
                  (irq4_g5 == 1'b1) ? 5'b00001 : 5'b00000 ;

  //----------------------------------------------------------
  // interrupt priority level demultiplexer
  //----------------------------------------------------------
  assign irq_g5_p3 = ((ip1_reg[5]) == 1'b1 &
                      (ip0_reg[5]) == 1'b1) ? irq_g5 : 5'b00000 ;
  assign irq_g5_p2 = ((ip1_reg[5]) == 1'b1 &
                      (ip0_reg[5]) == 1'b0) ? irq_g5 : 5'b00000 ;
  assign irq_g5_p1 = ((ip1_reg[5]) == 1'b0 &
                      (ip0_reg[5]) == 1'b1) ? irq_g5 : 5'b00000 ;
  assign irq_g5_p0 = ((ip1_reg[5]) == 1'b0 &
                      (ip0_reg[5]) == 1'b0) ? irq_g5 : 5'b00000 ;

  //---------------------------------------------------------------
  // interrupt priority level structure
  //---------------------------------------------------------------

  //------------------------------
  // interrupt enable for level 3
  //------------------------------
  assign en_in_prior3 = (~is_reg_s[3]) & ien0_reg[6] ;

  //---------------------------------------
  // level 3 block map
  //---------------------------------------
  assign {int_prior3_g0, int_prior3_g1,
          int_prior3_g2, int_prior3_g3,
          int_prior3_g4, int_prior3_g5,
          en_out_prior3} = LEVEL_PRIOR(irq_g0_p3, irq_g1_p3,
                                       irq_g2_p3, irq_g3_p3,
                                       irq_g4_p3, irq_g5_p3, en_in_prior3);

  //------------------------------
  // interrupt enable for level 2
  //------------------------------
  assign en_in_prior2 = (~is_reg_s[2]) & en_out_prior3 ;

  //---------------------------------------
  // level 2 block map
  //---------------------------------------
  assign {int_prior2_g0, int_prior2_g1,
          int_prior2_g2, int_prior2_g3,
          int_prior2_g4, int_prior2_g5,
          en_out_prior2} = LEVEL_PRIOR(irq_g0_p2, irq_g1_p2,
                                       irq_g2_p2, irq_g3_p2,
                                       irq_g4_p2, irq_g5_p2, en_in_prior2);

  //------------------------------
  // interrupt enable for level 1
  //------------------------------
  assign en_in_prior1 = (~is_reg_s[1]) & en_out_prior2 ;

  //---------------------------------------
  // level 1 block map
  //---------------------------------------
  assign {int_prior1_g0, int_prior1_g1,
          int_prior1_g2, int_prior1_g3,
          int_prior1_g4, int_prior1_g5,
          en_out_prior1} = LEVEL_PRIOR(irq_g0_p1, irq_g1_p1,
                                       irq_g2_p1, irq_g3_p1,
                                       irq_g4_p1, irq_g5_p1, en_in_prior1);

  //------------------------------
  // interrupt enable for level 0
  //------------------------------
  assign en_in_prior0 = (~is_reg_s[0]) & en_out_prior1 ;

  //---------------------------------------
  // level 0 block map
  //---------------------------------------
  assign {int_prior0_g0, int_prior0_g1,
          int_prior0_g2, int_prior0_g3,
          int_prior0_g4, int_prior0_g5,
          en_out_prior0} = LEVEL_PRIOR(irq_g0_p0, irq_g1_p0,
                                       irq_g2_p0, irq_g3_p0,
                                       irq_g4_p0, irq_g5_p0, en_in_prior0);

  //-------------------------------------------------------------------
  // interrupt request after priority level decoder
  // only one bit may be set at one time
  //------------------------------------------------------------------

  //-------------------------------------------------------------------
  // interrupt request group 0
  //-------------------------------------------------------------------
  assign int_req0_reg = int_prior3_g0 | int_prior2_g0 |
                      int_prior1_g0 | int_prior0_g0 ;

  //-------------------------------------------------------------------
  // interrupt request group 1
  //-------------------------------------------------------------------
  assign int_req1_reg = int_prior3_g1 | int_prior2_g1 |
                      int_prior1_g1 | int_prior0_g1 ;

  //-------------------------------------------------------------------
  // interrupt request group 2
  //-------------------------------------------------------------------
  assign int_req2_reg = int_prior3_g2 | int_prior2_g2 |
                      int_prior1_g2 | int_prior0_g2 ;

  //-------------------------------------------------------------------
  // interrupt request group 3
  //-------------------------------------------------------------------
  assign int_req3_reg = int_prior3_g3 | int_prior2_g3 |
                      int_prior1_g3 | int_prior0_g3 ;

  //-------------------------------------------------------------------
  // interrupt request group 4
  //-------------------------------------------------------------------
  assign int_req4_reg = int_prior3_g4 | int_prior2_g4 |
                      int_prior1_g4 | int_prior0_g4 ;

  //-------------------------------------------------------------------
  // interrupt request group 5
  //-------------------------------------------------------------------
  assign int_req5_reg = int_prior3_g5 | int_prior2_g5 |
                      int_prior1_g5 | int_prior0_g5 ;

  //------------------------------------------------------------------
  // 1 bit interrupt request to CPU
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : irq_r_proc
    if (rst == 1'b1)
    begin
      irq_r <= 1'b0 ;
    end
    else
    begin
      irq_r <= (~intcall) & (int_req0_reg[0] | int_req0_reg[1] |
                             int_req0_reg[2] | int_req0_reg[3] |
                             int_req0_reg[4] | int_req1_reg[0] |
                             int_req1_reg[1] | int_req1_reg[2] |
                             int_req1_reg[3] | int_req1_reg[4] |
                             int_req2_reg[0] | int_req2_reg[1] |
                             int_req2_reg[2] | int_req2_reg[3] |
                             int_req2_reg[4] | int_req3_reg[0] |
                             int_req3_reg[1] | int_req3_reg[2] |
                             int_req3_reg[3] | int_req3_reg[4] |
                             int_req4_reg[0] | int_req4_reg[1] |
                             int_req4_reg[2] | int_req4_reg[3] |
                             int_req4_reg[4] | int_req5_reg[0] |
                             int_req5_reg[1] | int_req5_reg[2] |
                             int_req5_reg[3] | int_req5_reg[4]) &
                             (ien0_reg[6]);
    end
  end

  assign irq = irq_r & (ien0_reg[6]);

  assign selector = {int_req0_reg, int_req1_reg,
                     int_req2_reg, int_req3_reg,
                     int_req4_reg, int_req5_reg};

  //------------------------------------------------------------------
  // interrupt vector generator
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : int_vect_int_proc
    if (rst == 1'b1)
    begin
      intvect_reg <= {5{1'b0}} ;
    end
    else
    begin
      case (1'b1)
        selector[29] : intvect_reg <= INT_VECT0 ;
        selector[24] : intvect_reg <= INT_VECT1 ;
        selector[19] : intvect_reg <= INT_VECT2 ;
        selector[14] : intvect_reg <= INT_VECT3 ;
        selector[ 9] : intvect_reg <= INT_VECT4 ;
        selector[ 4] : intvect_reg <= INT_VECT5 ;
        selector[25] : intvect_reg <= INT_VECT6 ;
        selector[20] : intvect_reg <= INT_VECT7 ;
        selector[15] : intvect_reg <= INT_VECT8 ;
        selector[10] : intvect_reg <= INT_VECT9 ;
        selector[ 5] : intvect_reg <= INT_VECT10 ;
        selector[ 0] : intvect_reg <= INT_VECT11 ;
        selector[27] : intvect_reg <= INT_VECT12 ;
        selector[22] : intvect_reg <= INT_VECT13 ;
        selector[17] : intvect_reg <= INT_VECT14 ;
        selector[12] : intvect_reg <= INT_VECT15 ;
        selector[ 7] : intvect_reg <= INT_VECT16 ;
        selector[ 2] : intvect_reg <= INT_VECT17 ;
        default                : ;
      endcase
    end
  end

//always @(posedge clkper)
//begin : int_vect_int_proc
//  if (rst == 1'b1)
//  begin
//    intvectDff <= {4{1'b0}} ;
//  end
//  else
//  begin
//    case (1'b1)
//      selector[29] : intvectDff <= 4'b0000 ;
//      selector[24] : intvectDff <= 4'b0001 ;
//      selector[19] : intvectDff <= 4'b0010 ;
//      selector[14] : intvectDff <= 4'b0011 ;
//      selector[ 9] : intvectDff <= 4'b0100 ;
//      selector[ 4] : intvectDff <= 4'b0101 ;
//      selector[25] : intvectDff <= 4'b0000 ;
//      selector[20] : intvectDff <= 4'b0001 ;
//      selector[15] : intvectDff <= 4'b0010 ;
//      selector[10] : intvectDff <= 4'b0011 ;
//      selector[ 5] : intvectDff <= 4'b0100 ;
//      selector[ 0] : intvectDff <= 4'b0101 ;
//      selector[27] : intvectDff <= 4'b1000 ;
//      selector[22] : intvectDff <= 4'b1001 ;
//      selector[17] : intvectDff <= 4'b1010 ;
//      selector[12] : intvectDff <= 4'b1011 ;
//      selector[ 7] : intvectDff <= 4'b1100 ;
//      selector[ 2] : intvectDff <= 4'b1101 ;
//      default                : ;
//    endcase
//  end
//end

//assign  intvect_reg  =  { intvectDff[3] , 1'h0 , intvectDff[ 2: 0] } ;
  //------------------------------------------------------------------
  // interrupt acknowledge vector
  // this is decoder (one-hot type) that decode interrupt acknowledge
  // signal base on interrupt vector
  // "ackvec" is 30 bit vector, only one bit is activ,
  // active bit points to source of interrupt vector
  //------------------------------------------------------------------
  always @(intvect_reg)
  begin : ackvec_proc
    case (intvect_reg)
      INT_VECT1   : ackvec = 30'b000001000000000000000000000000 ;
      INT_VECT2   : ackvec = 30'b000000000010000000000000000000 ;
      INT_VECT3   : ackvec = 30'b000000000000000100000000000000 ;
      INT_VECT4   : ackvec = 30'b000000000000000000001000000000 ;
      INT_VECT5   : ackvec = 30'b000000000000000000000000010000 ;
      INT_VECT6   : ackvec = 30'b000010000000000000000000000000 ;
      INT_VECT7   : ackvec = 30'b000000000100000000000000000000 ;
      INT_VECT8   : ackvec = 30'b000000000000001000000000000000 ;
      INT_VECT9   : ackvec = 30'b000000000000000000010000000000 ;
      INT_VECT10  : ackvec = 30'b000000000000000000000000100000 ;
      INT_VECT11  : ackvec = 30'b000000000000000000000000000001 ;
      INT_VECT12  : ackvec = 30'b001000000000000000000000000000 ;
      INT_VECT13  : ackvec = 30'b000000010000000000000000000000 ;
      INT_VECT14  : ackvec = 30'b000000000000100000000000000000 ;
      INT_VECT15  : ackvec = 30'b000000000000000001000000000000 ;
      INT_VECT16  : ackvec = 30'b000000000000000000000010000000 ;
      INT_VECT17  : ackvec = 30'b000000000000000000000000000100 ;
      default     : ackvec = 30'b100000000000000000000000000000 ;
    endcase
  end

  //-------------------------------------------------------------------
  // activate interrupt acknowledge vector only when intcall is active
  // active state of "intcall" signal enables generation interrupt
  // acknowledge signal to interrupt source
  // inactive state of "intcall" masks interrupt acknowledge vector
  //-------------------------------------------------------------------
  assign intack = ackvec & {30{intcall}};

  //-------------------------------------------------------------------
  // interrupt acknowledge outputs registers
  //-------------------------------------------------------------------
  always @(intack)
  begin : int_ack_proc

      int_ack_03 = intack[29] ;
      int_ack_0b = intack[24] ;
      int_ack_13 = intack[19] ;
      int_ack_1b = intack[14] ;
      int_ack_43 = intack[25] ;
      int_ack_4b = intack[20] ;
      int_ack_53 = intack[15] ;
      int_ack_5b = intack[10] ;
      int_ack_63 = intack[ 5] ;
      int_ack_6b = intack[ 0] ;
//    cdcBusyAck = intack[27] ;
      int_ack_8b = intack[22] ;
      int_ack_93 = intack[17] ;
      int_ack_9b = intack[12] ;
      int_ack_a3 = intack[ 7] ;
      int_ack_ab = intack[ 2] ;
  end

  //------------------------------------------------------------------
  // detect to which interrupt group signal ack is generated
  //------------------------------------------------------------------
  assign ack_g0 = intack[29] | intack[28] | intack[27] | intack[26] | intack[25] ;
  assign ack_g1 = intack[24] | intack[23] | intack[22] | intack[21] | intack[20] ;
  assign ack_g2 = intack[19] | intack[18] | intack[17] | intack[16] | intack[15] ;
  assign ack_g3 = intack[14] | intack[13] | intack[12] | intack[11] | intack[10] ;
  assign ack_g4 = intack[ 9] | intack[ 8] | intack[ 7] | intack[ 6] | intack[ 5] ;
  assign ack_g5 = intack[ 4] | intack[ 3] | intack[ 2] | intack[ 1] | intack[ 0] ;

  //-------------------------------------------------------------------
  //
  //-------------------------------------------------------------------
  assign int_prior = (ack_g0 == 1'b1) ? {ip1_reg[0], ip0_reg[0]} :
                     (ack_g1 == 1'b1) ? {ip1_reg[1], ip0_reg[1]} :
                     (ack_g2 == 1'b1) ? {ip1_reg[2], ip0_reg[2]} :
                     (ack_g3 == 1'b1) ? {ip1_reg[3], ip0_reg[3]} :
                     (ack_g4 == 1'b1) ? {ip1_reg[4], ip0_reg[4]} :
                     (ack_g5 == 1'b1) ? {ip1_reg[5], ip0_reg[5]} : 2'b00 ;

  //-------------------------------------------------------------------
  //
  //-------------------------------------------------------------------
  always @(posedge clkper)
  begin : is_reg_s_proc
    if (rst == 1'b1)
    begin
      is_reg_s <= 4'b0000 ;
    end
    else
    begin
      if (intcall == 1'b1)
      begin
        case (int_prior)
          2'b00   : is_reg_s <= 4'b0001 ;
          2'b01   : is_reg_s <= {3'b001, is_reg_s[  0]} ;
          2'b10   : is_reg_s <= { 2'b01, is_reg_s[1:0]} ;
          default : is_reg_s <= {  1'b1, is_reg_s[2:0]} ; // 2'b11
        endcase
      end
      else
      begin
        if (retiinstr == 1'b1)
        begin
          if ((is_reg_s[3]) == 1'b1)
          begin
            is_reg_s <= {1'b0, is_reg_s[2:0]} ;
          end
          else if ((is_reg_s[2]) == 1'b1)
          begin
            is_reg_s <= {2'b00, is_reg_s[1:0]} ;
          end
          else if ((is_reg_s[1]) == 1'b1)
          begin
            is_reg_s <= {3'b000, is_reg_s[0]} ;
          end
          else
          begin
            is_reg_s <= 4'b0000 ;
          end
        end
      end
    end
  end

endmodule // isr

