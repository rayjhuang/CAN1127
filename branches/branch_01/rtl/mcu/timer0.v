
module timer0 (
  clkper,
  rst,
  newinstr,
  t0ff,
  t0ack,
  t1ack,
  int0ff,
  t0_tf0,
  t0_tf1,
  sfrdatai,
  sfraddr,
  sfrwe,
  t0_tmod,
  t0_tr0,
  t0_tr1,
  tl0,
  th0
  );

  // Control signals inputs
  input             clkper;           // Global clock input
  input             rst;              // Global reset input
  input             newinstr;         // Start of new CPU instruction

  // Timers inputs
  input             t0ff;             // Timer 0 external input
  input             t0ack;            // Timer 0 interrupt acknowledge
  input             t1ack;            // Timer 1 interrupt acknowledge
  input             int0ff;           // External interrupt 0 input

  // Timer interrupt flags
  output            t0_tf0;           // Timer 0 overflow flag
  wire              t0_tf0;
  output            t0_tf1;           // Timer 0 TH0 mode 3 overflow flag
  wire              t0_tf1;

  // Special function register interface
  input     [ 7: 0] sfrdatai;
  input     [ 6: 0] sfraddr;
  input             sfrwe;
  output    [ 3: 0] t0_tmod;
  wire      [ 3: 0] t0_tmod;
  output            t0_tr0;
  wire              t0_tr0;
  output            t0_tr1;
  wire              t0_tr1;
  output    [ 7: 0] tl0;
  wire      [ 7: 0] tl0;
  output    [ 7: 0] th0;
  wire      [ 7: 0] th0;

//*******************************************************************--

  `include "mcu51_param.v"

  // Timer/Counter registers
  reg       [ 7: 0] tl0_s;
  reg       [ 7: 0] th0_s;

  // Control registers
  reg       [ 1: 0] t0_mode;
  reg               t0_ct;
  reg               t0_gate;
  reg               t0_tr0_s;
  reg               t0_tr1_s;
  reg               t0_tf0_s;
  reg               t0_tf1_s;
  // Clock counter
  reg       [ 3: 0] clk_count;
  reg               clk_ov12;         // Clock divided by 12

  //---------------------------------------------------------------
  // Timer 0 control signals
  //---------------------------------------------------------------
  // External input t0 falling edge detector
  wire              t0_fall;          // t0 input fall edge detector
  reg               t0_ff1;           // t0 input flip-flop
  // Timer 0 signals
  wire              t0_clk;           // Timer 0 clock
  wire              t0_open;          // Timer 0 open
  wire              tl0_clk;          // Timer low 0 clock
  wire              th0_clk;          // Timer high 0 clock
  wire              tl0_ov;           // Timer low 0 overflow
  reg               tl0_ov_ff;        // Timer low 0 overflow
  wire              th0_ov;           // Timer high 0 overflow
  reg               th0_ov_ff;        // Timer high 0 overflow
  reg               t0clr;            // Timer 0 interrupt ack detection
  reg               t1clr;            // Timer 1 interrupt ack detection

  //------------------------------------------------------------------
  // Timer 0 overflow flag
  //   interrupt request flag
  //   high active output
  //   cleared by high t0ack
  //------------------------------------------------------------------
  assign t0_tf0 = t0_tf0_s ;

  //------------------------------------------------------------------
  // Timer 1 overflow flag (only for Mode 3)
  //   interrupt request flag
  //   high active output
  //   cleared by high t1ack
  //------------------------------------------------------------------
  assign t0_tf1 = t0_tf1_s ;

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tcon_4_write_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      t0_tr0_s <= TCON_RV[4] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      if (sfrwe == 1'b1 && sfraddr == TCON_ID)
      begin
        t0_tr0_s <= sfrdatai[4] ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tcon_5_write_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      t0_tf0_s <= TCON_RV[5] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      if (sfrwe == 1'b1 && sfraddr == TCON_ID)
      begin
        t0_tf0_s <= sfrdatai[5] ;
      end
      else
      begin
        //--------------------------------
        // Timer 0 interrupt acknoledge
        //--------------------------------
        if (t0ack == 1'b1 || t0clr == 1'b1)
        begin
          t0_tf0_s <= 1'b0 ;
        end
        else
        begin
          //--------------------------------
          // Timer 0 overflow flag TF0
          //--------------------------------
          if (((t0_mode == 2'b00  || t0_mode   == 2'b01) &&
               (th0_ov  == 1'b1   || th0_ov_ff == 1'b1)) ||
              ((t0_mode == 2'b10  || t0_mode   == 2'b11) &&
               (tl0_ov  == 1'b1   || tl0_ov_ff == 1'b1)))
          begin
            t0_tf0_s <= 1'b1 ;
          end
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tcon_6_write_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      t0_tr1_s <= TCON_RV[6] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      if (sfrwe == 1'b1 && sfraddr == TCON_ID)
      begin
        t0_tr1_s <= sfrdatai[6] ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tcon_7_write_proc
  //------------------------------------------------------------------
    if (rst == 1'b1)
    begin
      t0_tf1_s <= TCON_RV[7] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      if (sfrwe == 1'b1 && sfraddr == TCON_ID)
      begin
        t0_tf1_s <= sfrdatai[7] ;
      end
      else
      begin
        //-----------------------------------
        // Synchronous write
        //-----------------------------------
        // Special function register write
        //--------------------------------
        if (t1ack == 1'b1 || t1clr == 1'b1)
        begin
          t0_tf1_s <= 1'b0 ;
        end
        else
        begin
          //--------------------------------
          // Timer 1 interrupt acknoledge
          //--------------------------------
          if (t0_mode == 2'b11)
          begin
            //--------------------------------
            // Timer 1 overflow flag TF1 generated by Timer 0 im mode 3
            //--------------------------------
            if (th0_ov == 1'b1)
            begin
              t0_tf1_s <= 1'b1 ;
            end
          end
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tmod_write_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      t0_gate   <= TMOD_RV[3] ;
      t0_ct     <= TMOD_RV[2] ;
      t0_mode   <= TMOD_RV[1:0] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      if (sfrwe == 1'b1 && sfraddr == TMOD_ID)
      begin
        t0_gate   <= sfrdatai[3] ;
        t0_ct     <= sfrdatai[2] ;
        t0_mode   <= sfrdatai[1:0] ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : th0_write_proc
  //------------------------------------------------------------------
    if (rst == 1'b1)
    begin
      th0_s <= TH0_RV ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      if (sfrwe == 1'b1 && sfraddr == TH0_ID)
      begin
        th0_s <= sfrdatai ;
      end
      else
      begin
        //-----------------------------------
        // Synchronous write
        //-----------------------------------
        // Special function register write
        //--------------------------------
        if (th0_clk == 1'b1)
        begin
          th0_s <= th0_s + 1'b1 ;
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tl0_write_proc
  //------------------------------------------------------------------
    if (rst == 1'b1)
    begin
      tl0_s <= TL0_RV ;
    end
    else
    begin
      if (sfrwe == 1'b1 && sfraddr == TL0_ID)
      begin
        //-----------------------------------
        // Synchronous write
        //-----------------------------------
        // Special function register write
        //--------------------------------
        tl0_s <= sfrdatai ;
      end
      else
      begin
        if (t0_mode == 2'b10 && tl0_ov == 1'b1)
        begin
          tl0_s <= th0_s ; // Reload mode
        end
        else
        begin
          if (tl0_clk == 1'b1)
          begin
            //-----------------------------------
            // Synchronous reset
            //-----------------------------------
            tl0_s <= tl0_s + 1'b1 ;
          end
        end
      end
    end
  end

  //------------------------------------------------------------------
  // Clock counter with overflow divided by 2 or 12
  // clk_ov2 is high active during single clk period
  // clk_ov12 is high active during single clk period
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : clk_count_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      clk_count <= 4'b0000 ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Clock counter
      //--------------------------------
      if (clk_count == 4'b1011)
      begin
        clk_count <= 4'b0000 ;
      end
      else
      begin
        clk_count <= clk_count + 1'b1 ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : clk_ov12_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      clk_ov12 <= 1'b0 ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Clock divided by 12
      //--------------------------------
      if (clk_count == 4'b1011)
      begin
        clk_ov12 <= 1'b1 ;
      end
      else
      begin
        clk_ov12 <= 1'b0 ;
      end
    end
  end

  //------------------------------------------------------------------
  // Timer 0 clock
  // t0_clk is high active during single clk period
  //------------------------------------------------------------------
  assign t0_clk = clk_ov12 ;

////------------------------------------------------------------------
//always @(posedge clkper)
//begin : t0_ff_proc
////------------------------------------------------------------------
//  //-----------------------------------
//  // Synchronous reset
//  //-----------------------------------
//  if (rst == 1'b1)
//  begin
//    t0_ff1 <= 1'b0 ;
//  end
//  else
//  begin
//    //-----------------------------------
//    // Synchronous write
//    //-----------------------------------
//    // t0 input flip-flop
//    //--------------------------------
//    t0_ff1 <= t0ff ;
//  end
//end

  //------------------------------------------------------------------
  // Falling edge detection on the external input t0 (t0ff)
  // t0_fall is high active during single clk period
  //------------------------------------------------------------------
//assign t0_fall = t0_ff1 & ~t0ff ;
  assign t0_fall = 1'h0 ;

  //------------------------------------------------------------------
  // Timer 0 open gate control
  //------------------------------------------------------------------
  assign t0_open = t0_tr0_s & (int0ff | ~t0_gate) ;

  //------------------------------------------------------------------
  // Timer 0 low order byte clock
  // tl0_clk is high active during single clk period
  //------------------------------------------------------------------
  assign tl0_clk = (t0_open == 1'b1 && t0_ct == 1'b0) ? t0_clk :
                   (t0_open == 1'b1 && t0_ct == 1'b1) ? t0_fall : 1'b0 ;

  //------------------------------------------------------------------
  // Timer 0 high ordered byte clock
  // th0_clk is high active during single clk period
  //------------------------------------------------------------------
  assign th0_clk = (t0_mode == 2'b00 || t0_mode == 2'b01) ? tl0_ov : // Modes 0 or 1
                   (t0_tr1_s == 1'b1 && t0_mode == 2'b11) ? t0_clk : // Mode 3
                                                           1'b0 ;
  //------------------------------------------------------------------
  // Timer low 0 overflow
  // tl0_ov is high active during single clk period
  //------------------------------------------------------------------
  assign tl0_ov = ((tl0_s[4:0] == 5'b11111 && t0_mode == 2'b00) ||
                   (tl0_s[7:0] == 8'b11111111)) ? tl0_clk : 1'b0 ;

  //------------------------------------------------------------------
  // Timer low 0 overflow flip-flop
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tl0_ov_ff_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      tl0_ov_ff <= 1'b0 ;
      t0clr <= 1'b0;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      if (tl0_ov == 1'b1)
      begin
        tl0_ov_ff <= 1'b1 ;
      end
      else if (newinstr == 1'b1)
      begin
        tl0_ov_ff <= 1'b0 ;
      end
      //-----------------------------------
      // ACK detection
      //-----------------------------------
      if (t0ack == 1'b1)
      begin
        t0clr <= 1'b1 ;
      end
      else if (newinstr == 1'b1)
      begin
        t0clr <= 1'b0 ;
      end
    end
  end

  //------------------------------------------------------------------
  // Timer high 0 overflow
  // th0_ov is high active during single clk period
  //------------------------------------------------------------------
  assign th0_ov = (th0_s[7:0] == 8'b11111111) ? th0_clk : 1'b0 ;

  //------------------------------------------------------------------
  // Timer high 0 overflow flip-flop
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : th0_ov_ff_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      th0_ov_ff <= 1'b0 ;
      t1clr <= 1'b0;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      if (th0_ov == 1'b1)
      begin
        th0_ov_ff <= 1'b1 ;
      end
      else if (newinstr == 1'b1)
      begin
        th0_ov_ff <= 1'b0 ;
      end
      //-----------------------------------
      // ACK detection
      //-----------------------------------
      if (t1ack == 1'b1)
      begin
        t1clr <= 1'b1 ;
      end
      else if (newinstr == 1'b1)
      begin
        t1clr <= 1'b0 ;
      end
    end
  end

  //------------------------------------------------------------------
  // Special Function registers outputs
  //------------------------------------------------------------------
  assign tl0 = tl0_s ;

  //------------------------------------------------------------------
  assign th0 = th0_s ;

  //------------------------------------------------------------------
  assign t0_tmod = {t0_gate, t0_ct, t0_mode} ;

  //------------------------------------------------------------------
  assign t0_tr0 = t0_tr0_s ;

  //------------------------------------------------------------------
  assign t0_tr1 = t0_tr1_s ;


endmodule // timer0

