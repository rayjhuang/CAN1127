
module timer1 (
  clkper,
  rst,
  newinstr,
  t1ff,
  t1ack,
  int1ff,
  t1_tf1,
  t1ov,
  sfrdatai,
  sfraddr,
  sfrwe,
  t1_tmod,
  t1_tr1,
  tl1,
  th1
  );

  // Control signals inputs
  input             clkper;       // Global clock input
  input             rst;          // Global reset input
  input             newinstr;     // Start of new CPU instruction

  // Timers inputs
  input             t1ff;         // Timer 1 external input sample
  input             t1ack;        // Timer 1 interrupt acknowledge
  input             int1ff;       // External interrupt 1 input

  // Timer interrupt flags
  output            t1_tf1;       // Timer 1 overflow flag
  wire              t1_tf1;

  // Timer outputs
  output            t1ov;         // Timer 1 overflow output
  wire              t1ov;
  
  // Special function register interface
  input     [ 7: 0] sfrdatai;
  input     [ 6: 0] sfraddr;
  input             sfrwe;
  output    [ 3: 0] t1_tmod;
  wire      [ 3: 0] t1_tmod;
  output            t1_tr1;
  wire              t1_tr1;
  output    [ 7: 0] tl1;
  wire      [ 7: 0] tl1;
  output    [ 7: 0] th1;
  wire      [ 7: 0] th1;

//*******************************************************************--

  `include "mcu51_param.v"

  // Timer/Counter registers
  reg       [ 7: 0] tl1_s;
  reg       [ 7: 0] th1_s;

  // Control registers
  reg               t1_gate;
  reg               t1_ct;
  reg       [ 1: 0] t0_mode;
  reg       [ 1: 0] t1_mode;
  reg               t1_tr1_s;
  reg               t1_tf1_s;

  // Clock counter
  reg       [ 3: 0] clk_count;
  reg               clk_ov12;     // Clock divided by 12

  //---------------------------------------------------------------
  // Timer 1 control signals
  //---------------------------------------------------------------
  // External input t1 falling edge detector
  wire              t1_fall;      // t1 input fall edge detector
  reg               t1_ff1;       // t1 input flip-flop
  // Timer 1 signals
  wire              t1_clk;       // Timer 1 clock
  wire              t1_open;      // Timer 1 open
  wire              tl1_clk;      // Timer low 1 clock
  wire              th1_clk;      // Timer high 1 clock
  wire              tl1_ov;       // Timer low 1 overflow
  reg               tl1_ov_ff;
  wire              th1_ov;       // Timer high 1 overflow
  reg               th1_ov_ff;
  reg               t1clr;        // Timer 1 interrupt ack detection

  //------------------------------------------------------------------
  // Timer 1 overflow flag
  //   interrupt request flag
  //   high active output
  //   cleared by high on signal t1ack
  //------------------------------------------------------------------
  assign t1_tf1 = t1_tf1_s ;

  //------------------------------------------------------------------
  // Timer 1 overflow output
  //   output for serial interface
  //   high active output
  //   active during single clk period
  //------------------------------------------------------------------
  assign t1ov = (t1_mode == 2'b10) ? tl1_ov : th1_ov ;

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tcon_6_write_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      t1_tr1_s <= TCON_RV[6] ;
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
        t1_tr1_s <= sfrdatai[6] ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tcon_7_write_proc
  //------------------------------------------------------------------
    if (rst == 1'b1)
    begin
      t1_tf1_s <= TCON_RV[7] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      if (sfrwe == 1'b1 && sfraddr == TCON_ID)
      begin
        t1_tf1_s <= sfrdatai[7] ;
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
          t1_tf1_s <= 1'b0 ;
        end
        else
        begin
          //--------------------------------
          // Timer 1 interrupt acknoledge
          //--------------------------------
          if (t0_mode != 2'b11)
          begin
            //--------------------------------
            // Timer 1 overflow flag TF1
            //--------------------------------
            if (((t1_mode == 2'b00  || t1_mode == 2'b01) &&
                 (th1_ov  == 1'b1   || th1_ov_ff == 1'b1)) ||
                ((t1_mode == 2'b10) &&
                 (tl1_ov  == 1'b1   || tl1_ov_ff == 1'b1)))
            begin
              t1_tf1_s <= 1'b1 ;
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
      t1_gate   <= TMOD_RV[7] ;
      t1_ct     <= TMOD_RV[6] ;
      t1_mode   <= TMOD_RV[5:4] ;
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
        t1_gate   <= sfrdatai[7] ;
        t1_ct     <= sfrdatai[6] ;
        t1_mode   <= sfrdatai[5:4] ;
        t0_mode   <= sfrdatai[1:0] ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tl1_write_proc
  //------------------------------------------------------------------
    if (rst == 1'b1)
    begin
      tl1_s <= TL1_RV ;
    end
    else
    begin
      if (sfrwe == 1'b1 && sfraddr == TL1_ID)
      begin
        //-----------------------------------
        // Synchronous write
        //-----------------------------------
        //--------------------------------
        // Special function register write
        //--------------------------------
        tl1_s <= sfrdatai ;
      end
      else
      begin
        if (t1_mode == 2'b10 && tl1_ov == 1'b1)
        begin
          tl1_s <= th1_s ; // Reload mode
        end
        else
        begin
          if (tl1_clk == 1'b1)
          begin
            //-----------------------------------
            // Synchronous reset
            //-----------------------------------
            tl1_s <= tl1_s + 1'b1 ;
          end
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : th1_write_proc
  //------------------------------------------------------------------
    if (rst == 1'b1)
    begin
      th1_s <= TH1_RV ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      if (sfrwe == 1'b1 && sfraddr == TH1_ID)
      begin
        th1_s <= sfrdatai ;
      end
      else
      begin
        //-----------------------------------
        // Synchronous write
        //-----------------------------------
        //--------------------------------
        // Special function register write
        //--------------------------------
        if (th1_clk == 1'b1)
        begin
          th1_s <= th1_s + 1'b1 ;
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
  // Timer 1 clock
  // t1_clk is high active during single clk period
  //------------------------------------------------------------------
  assign t1_clk = clk_ov12 ;

////------------------------------------------------------------------
//always @(posedge clkper)
//begin : t1_fall_proc
////------------------------------------------------------------------
//  //-----------------------------------
//  // Synchronous reset
//  //-----------------------------------
//  if (rst == 1'b1)
//  begin
//    t1_ff1 <= 1'b0 ;
//  end
//  else
//  begin
//    //-----------------------------------
//    // Synchronous write
//    //-----------------------------------
//    // t1 input flip-flop
//    //--------------------------------
//    t1_ff1 <= t1ff ;
//  end
//end

  //------------------------------------------------------------------
  // Falling edge detection on the external input t1
  // t1_fall is high active during single clk period
  //------------------------------------------------------------------
//assign t1_fall = t1_ff1 & ~t1ff ;
  assign t1_fall = 1'h0 ;

  //------------------------------------------------------------------
  // Timer 1 open gate control
  //------------------------------------------------------------------
  assign t1_open = (t1_tr1_s | (t0_mode == 2'b11)) & (int1ff | ~t1_gate) ;


  //------------------------------------------------------------------
  // Timer 1 low order byte clock
  // tl0_clk is high active during single clk period
  //------------------------------------------------------------------
  assign tl1_clk = (t1_open == 1'b1 &&
                    t1_ct   == 1'b0 &&
                    t1_mode != 2'b11) ? t1_clk :
                   (t1_open == 1'b1 &&
                    t1_ct   == 1'b1 &&
                    t1_mode != 2'b11) ? t1_fall :
                                        1'b0 ;

  //------------------------------------------------------------------
  // Timer 1 high order byte clock
  // th1_clk is high active during single clk period
  //------------------------------------------------------------------
  assign th1_clk = (t1_mode == 2'b00 ||
                    t1_mode == 2'b01) ? tl1_ov :        // Modes 0 or 1
                                        1'b0 ;

  //------------------------------------------------------------------
  // Timer low 1 overflow
  // tl1_ov is high active during single clk period
  //------------------------------------------------------------------
  assign tl1_ov = ((tl1_s[4:0] == 5'b11111 && t1_mode == 2'b00) ||
                   (tl1_s[7:0] == 8'b11111111)) ? tl1_clk : 1'b0 ;

  //------------------------------------------------------------------
  // Timer low 1 overflow flip-flop
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tl1_ov_ff_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      tl1_ov_ff <= 1'b0 ;
      t1clr <= 1'b0;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      if (tl1_ov == 1'b1)
      begin
        tl1_ov_ff <= 1'b1 ;
      end
      else if (newinstr == 1'b1)
      begin
        tl1_ov_ff <= 1'b0 ;
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
  // Timer high 1 overflow
  // th1_ov is high active during single clk period
  //------------------------------------------------------------------
  assign th1_ov = (th1_s[7:0] == 8'b11111111) ? th1_clk : 1'b0 ;

  //------------------------------------------------------------------
  // Timer high 1 overflow flip-flop
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : th1_ov_ff_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (rst == 1'b1)
    begin
      th1_ov_ff <= 1'b0 ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      if (th1_ov == 1'b1)
      begin
        th1_ov_ff <= 1'b1 ;
      end
      else if (newinstr == 1'b1)
      begin
        th1_ov_ff <= 1'b0 ;
      end
    end
  end

  //------------------------------------------------------------------
  // Special Function registers outputs
  //------------------------------------------------------------------
  assign tl1 = tl1_s ;

  //------------------------------------------------------------------
  assign th1 = th1_s ;

  //------------------------------------------------------------------
  assign t1_tmod = {t1_gate, t1_ct, t1_mode} ;

  //------------------------------------------------------------------
  assign t1_tr1 = t1_tr1_s ;


endmodule // timer1

