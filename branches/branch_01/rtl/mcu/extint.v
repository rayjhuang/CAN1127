
module extint (
  clkper,
  rst,
  newinstr,
  int0ff,
  int0ack,
  int1ff,
  int1ack,
  int2ff,
  iex2ack,
  int3ff,
  iex3ack,
  int4ff,
  iex4ack,
  int5ff,
  iex5ack,
  int6ff,
  iex6ack,
  int7ff,
  iex7ack,
  int8ff,
  iex8ack,
  int9ff,
  iex9ack,
  ie0,
  it0,
  ie1,
  it1,
  i2fr,
  iex2,
  i3fr,
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
  sfraddr,
  sfrdatai,
  sfrwe
  );

  // Control signal inputs
  input             clkper;         // Global clock input
  input             rst;            // Global reset input
  input             newinstr;       // Start of new CPU instruction

  input             int0ff;         // External interrupt 0
  input             int0ack;        // External interrupt 0 acknowledge
  input             int1ff;         // External interrupt 1
  input             int1ack;        // External interrupt 1 acknowledge
  input             int2ff;         // External interrupt 2
  input             iex2ack;        // External interrupt 2 acknowledge
  input             int3ff;         // External interrupt 3
  input             iex3ack;        // External interrupt 3 acknowledge
  input             int4ff;         // External interrupt 4
  input             iex4ack;        // External interrupt 4 acknowledge
  input             int5ff;         // External interrupt 5
  input             iex5ack;        // External interrupt 5 acknowledge
  input             int6ff;         // External interrupt 6
  input             iex6ack;        // External interrupt 6 acknowledge
  input             int7ff;         // External interrupt 7
  input             iex7ack;        // External interrupt 7 acknowledge
  input             int8ff;         // External interrupt 8
  input             iex8ack;        // External interrupt 8 acknowledge
  input             int9ff;         // External interrupt 9
  input             iex9ack;        // External interrupt 9 acknowledge

  output            ie0;            // External Interrupt 0 request flag of TCON
  wire              ie0;
  output            it0;            // External Interrupt 0 edge/level selection bit of TCON
  wire              it0;
  output            ie1;            // External Interrupt 1 request flag of T2CON
  wire              ie1;
  output            it1;            // External Interrupt 1 edge/level selection bit of TCON
  wire              it1;

  output            i2fr;           // Ext. interrupt 2 falling/rising edge selection bit of T2CON
  wire              i2fr;
  output            iex2;           // Ext. interrupt 2 request
  wire              iex2;
  output            i3fr;           // Ext. interrupt 3 falling/rising edge selection bit of T2CON
  wire              i3fr; 
  output            iex3;           // Ext. interrupt 3 request
  wire              iex3;
  output            iex4;           // Ext. interrupt 4 request
  wire              iex4;
  output            iex5;           // Ext. interrupt 5 request
  wire              iex5;
  output            iex6;           // Ext. interrupt 6 request
  wire              iex6;
  output            iex7;           // Ext. interrupt 7 request
  wire              iex7;
  output            iex8;           // Ext. interrupt 8 request
  wire              iex8;
  output            iex9;           // Ext. interrupt 9 request
  wire              iex9;
  output            iex10;          // Ext. interrupt 10 request
  wire              iex10;
  output            iex11;          // Ext. interrupt 11 request
  wire              iex11;
  output            iex12;          // Ext. interrupt 12 request
  wire              iex12;

  // Special function register interface
  input     [ 6: 0] sfraddr;
  input     [ 7: 0] sfrdatai;
  input             sfrwe;

//*******************************************************************--

  `include "mcu51_param.v"

  //-------------------------------------------------------------------
  // External Interrupt 0 signals
  //-------------------------------------------------------------------
  reg               it0_s;          // Level/edge select flag
  reg               ie0_s;          // Interrupt 0 request flag
  reg               int0_fall;      // Interrupt 0 edge detection
  reg               int0_clr;       // Interrupt 0 ack detection
  reg               int0_ff1;       // Interrupt 0 input sample
  //-------------------------------------------------------------------
  // External Interrupt 1 signals
  //-------------------------------------------------------------------
  reg               it1_s;          // Level/edge select flag
  reg               ie1_s;          // Interrupt 1 request flag
  reg               int1_fall;      // Interrupt 1 edge detection
  reg               int1_clr;       // Interrupt 1 ack detection
  reg               int1_ff1;       // Interrupt 1 input sample
  //-------------------------------------------------------------------
  // External Interrupt 2 signals
  //-------------------------------------------------------------------
   reg		iex2_set;
   reg		int2_ff1;	// int2 edge detection
   reg		iex2_s;		// int2 request flag
   reg		i2fr_s;		// int2 rising/falling edge select flag
  //-------------------------------------------------------------------
  // External Interrupt 3 signals
  //-------------------------------------------------------------------
   reg		iex3_set;
   reg		int3_ff1;	// int3 edge detection
   reg		iex3_s;		// int3 request flag
   reg		i3fr_s;		// int3 rising/falling edge select flag
  //-------------------------------------------------------------------
  // External Interrupt 4 signals
  //-------------------------------------------------------------------
   reg		iex4_set;
   reg		int4_ff1;	// int4 edge detection
   reg		iex4_s;		// int4 request flag
  //-------------------------------------------------------------------
  // External Interrupt 5 signals
  //-------------------------------------------------------------------
   reg		iex5_set;
   reg		int5_ff1;	// int5 edge detection
   reg		iex5_s;		// int5 request flag
  //-------------------------------------------------------------------
  // External Interrupt 6 signals
  //-------------------------------------------------------------------
   reg		iex6_set;
   reg		int6_ff1;	// int6 edge detection
   reg		iex6_s;		// int6 request flag
  //-------------------------------------------------------------------
  // External Interrupt 7 signals
  //-------------------------------------------------------------------
   reg		iex7_set;
   reg		int7_ff1;	// int7 edge detection
   reg		iex7_s;		// int7 request flag
  //-------------------------------------------------------------------
  // External Interrupt 8 signals
  //-------------------------------------------------------------------
   reg		iex8_set;
   reg		int8_ff1;	// int8 edge detection
   reg		iex8_s;		// int8 request flag
  //-------------------------------------------------------------------
  // External Interrupt 9 signals
  //-------------------------------------------------------------------
   reg		iex9_set;
   reg		int9_ff1;	// int9 edge detection
   reg		iex9_s;		// int9 request flag
  //-------------------------------------------------------------------
  // External Interrupt 10 signals
  //-------------------------------------------------------------------

  //-------------------------------------------------------------------
  // External Interrupt 11 signals
  //-------------------------------------------------------------------

  //-------------------------------------------------------------------
  // External Interrupt 12 signals
  //-------------------------------------------------------------------



  //-------------------------------------------------------------------
  // External Interrupt 0 service
  //-------------------------------------------------------------------
      always @(posedge clkper)
      begin : int0_proc
        if (rst == 1'b1)
        begin
          //------------------------------------
          // Synchronous reset
          //------------------------------------
          it0_s     <= TCON_RV[0] ;
          ie0_s     <= TCON_RV[1] ;
          int0_fall <= 1'b0 ;
          int0_clr  <= 1'b0 ;
          int0_ff1  <= 1'b0 ;
        end
        else
        begin
          if (sfraddr == TCON_ID && sfrwe == 1'b1)
          begin
            it0_s     <= sfrdatai[0] ;
            ie0_s     <= sfrdatai[1] ;
          end
          else
          begin
            if (it0_s == 1'b0)
            begin
              // Low level detect
              ie0_s     <= ~int0ff ;
            end
            else
            begin
              //------------------------------------
              // SFR write
              //------------------------------------
              if (int0ack == 1'b1 || int0_clr == 1'b1)
              begin
                // clear int. request
                ie0_s     <= 1'b0 ;
              end
              else
              begin
                //--------------------------------
                // Interrupt 0 request
                //--------------------------------
                if (int0_fall == 1'b1 || (int0ff == 1'b0 && int0_ff1 == 1'b1))
                begin
                  //Falling edge
                  ie0_s     <= 1'b1 ;
                end
              end
            end
          end
          //--------------------------------
          // Interrupt 0 edge detection
          //--------------------------------
          if (int0ff == 1'b0 && int0_ff1 == 1'b1)
          begin
            int0_fall <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || int0ack == 1'b1)
          begin
            int0_fall <= 1'b0 ;
          end
          //--------------------------------
          // Interrupt 0 ack detection
          //--------------------------------
          if (int0ack == 1'b1)
          begin
            int0_clr <= 1'b1 ;
          end
          else if (newinstr == 1'b1)
          begin
            int0_clr <= 1'b0 ;
          end
          //--------------------------------
          // int0 input flip-flop
          //--------------------------------
          int0_ff1  <= int0ff ;
        end
      end

      assign ie0 = ie0_s ;

      assign it0 = it0_s ;

  //-------------------------------------------------------------------
  // External Interrupt 1 service
  //-------------------------------------------------------------------
      always @(posedge clkper)
      begin : int1_proc
        if (rst == 1'b1)
        begin
          //------------------------------------
          // Synchronous reset
          //------------------------------------
          it1_s     <= TCON_RV[2] ;
          ie1_s     <= TCON_RV[3] ;
          int1_fall <= 1'b0 ;
          int1_clr  <= 1'b0 ;
          int1_ff1  <= 1'b0 ;
        end
        else
        begin
          if (sfraddr == TCON_ID && sfrwe == 1'b1)
          begin
            it1_s     <= sfrdatai[2] ;
            ie1_s     <= sfrdatai[3] ;
          end
          else
          begin
            if (it1_s == 1'b0)
            begin
              // Low level detect
              ie1_s     <= ~int1ff ;
            end
            else
            begin
              //------------------------------------
              // SFR write
              //------------------------------------
              if (int1ack == 1'b1 || int1_clr == 1'b1)
              begin
                // clear int. request
                ie1_s     <= 1'b0 ;
              end
              else
              begin
                //--------------------------------
                // Interrupt 1 request
                //--------------------------------
                if (int1_fall == 1'b1 || (int1ff == 1'b0 && int1_ff1 == 1'b1))
                begin
                  //Falling edge
                  ie1_s     <= 1'b1 ;
                end
              end
            end
          end
          //--------------------------------
          // Interrupt 1 edge detection
          //--------------------------------
          if (int1ff == 1'b0 && int1_ff1 == 1'b1)
          begin
            int1_fall <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || int1ack == 1'b1)
          begin
            int1_fall <= 1'b0 ;
          end
          //--------------------------------
          // Interrupt 1 ack detection
          //--------------------------------
          if (int1ack == 1'b1)
          begin
            int1_clr <= 1'b1;
          end
          else if (newinstr == 1'b1)
          begin
            int1_clr <= 1'b0;
          end
          //--------------------------------
          // int1 input flip-flop
          //--------------------------------
          int1_ff1  <= int1ff ;
        end
      end

      assign ie1 = ie1_s ;

      assign it1 = it1_s ;

  //------------------------------------------------------------------
  // External interrupt 2 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex2_proc
        if (rst == 1'b1)
        begin
          iex2_set  <=  1'b0 ;
          int2_ff1  <=  1'b1 ;
          iex2_s    <=  IRCON_RV[1] ;
          i2fr_s    <=  T2CON_RV[5] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == T2CON_ID && sfrwe == 1'b1)
          begin
            i2fr_s    <= sfrdatai[5] ;
          end
          if ( sfraddr == IRCON_ID && sfrwe == 1'b1)
          begin
            iex2_s    <= sfrdatai[1] ;
          end
          else
          begin
            if (iex2ack == 1'b1)
            begin
              iex2_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 2 request flag
              //-------------------------------
              if (iex2_set == 1'b1)
              begin
                iex2_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if
              ((int2ff == 1'b1 && int2_ff1 == 1'b0 && i2fr_s == 1'b1) ||  // positive edge
               (int2ff == 1'b0 && int2_ff1 == 1'b1 && i2fr_s == 1'b0))   // negative edge
          begin
            iex2_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex2ack == 1'b1)
          begin
            iex2_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int2 input sample
          //-------------------------------
          int2_ff1  <= int2ff ;
        end
      end

      assign iex2 = iex2_s ;
      assign i2fr = i2fr_s ;

//    assign iex2 = IRCON_RV[1] ;
//    assign i2fr = T2CON_RV[5] ;

  //------------------------------------------------------------------
  // External interrupt 3 / CCU0 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex3_proc
        if (rst == 1'b1)
        begin
          iex3_set  <=  1'b0 ;
          int3_ff1  <=  1'b1 ;
          iex3_s    <=  IRCON_RV[2] ;
          i3fr_s    <=  T2CON_RV[6] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == T2CON_ID && sfrwe == 1'b1)
          begin
            i3fr_s    <= sfrdatai[6] ;
          end
          if ( sfraddr == IRCON_ID && sfrwe == 1'b1)
          begin
            iex3_s    <= sfrdatai[2] ;
          end
          else
          begin
            if (iex3ack == 1'b1)
            begin
              iex3_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 3 request flag
              //-------------------------------
              if (iex3_set == 1'b1)
              begin
                iex3_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if
              ((int3ff == 1'b1 && int3_ff1 == 1'b0 && i3fr_s == 1'b1) ||  // positive edge
               (int3ff == 1'b0 && int3_ff1 == 1'b1 && i3fr_s == 1'b0))   // negative edge
          begin
            iex3_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex3ack == 1'b1)
          begin
            iex3_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int3 input sample
          //-------------------------------
          int3_ff1  <= int3ff ;
        end
      end

      assign iex3 = iex3_s ;
      assign i3fr = i3fr_s ;

//    assign iex3 = IRCON_RV[2] ;
//    assign i3fr = T2CON_RV[6] ;

  //------------------------------------------------------------------
  // External interrupt 4 / CCU1 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex4_proc
        if (rst == 1'b1)
        begin
          iex4_set  <=  1'b0 ;
          int4_ff1  <=  1'b0 ;
          iex4_s    <=  IRCON_RV[3] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == IRCON_ID && sfrwe == 1'b1)
          begin
            iex4_s    <= sfrdatai[3] ;
          end
          else
          begin
            if (iex4ack == 1'b1)
            begin
              iex4_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 4 request flag
              //-------------------------------
              if (iex4_set == 1'b1)
              begin
                iex4_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if (int4ff == 1'b1 && int4_ff1 == 1'b0)   // positive edge
          begin
            iex4_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex4ack == 1'b1)
          begin
            iex4_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int4 input sample
          //-------------------------------
          int4_ff1  <= int4ff ;
        end
      end

      assign iex4 = iex4_s ;
//    assign iex4 = IRCON_RV[3] ;

  //------------------------------------------------------------------
  // External interrupt 5 / CCU2 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex5_proc
        if (rst == 1'b1)
        begin
          iex5_set  <=  1'b0 ;
          int5_ff1  <=  1'b0 ;
          iex5_s    <=  IRCON_RV[4] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == IRCON_ID && sfrwe == 1'b1)
          begin
            iex5_s    <= sfrdatai[4] ;
          end
          else
          begin
            if (iex5ack == 1'b1)
            begin
              iex5_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 5 request flag
              //-------------------------------
              if (iex5_set == 1'b1)
              begin
                iex5_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if (int5ff == 1'b1 && int5_ff1 == 1'b0)   // positive edge
          begin
            iex5_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex5ack == 1'b1)
          begin
            iex5_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int5 input sample
          //-------------------------------
          int5_ff1  <= int5ff ;
        end
      end

      assign iex5 = iex5_s ;
//    assign iex5 = IRCON_RV[4] ;

  //------------------------------------------------------------------
  // External interrupt 6 / CCU3 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex6_proc
        if (rst == 1'b1)
        begin
          iex6_set  <=  1'b0 ;
          int6_ff1  <=  1'b0 ;
          iex6_s    <=  IRCON_RV[5] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == IRCON_ID && sfrwe == 1'b1)
          begin
            iex6_s    <= sfrdatai[5] ;
          end
          else
          begin
            if (iex6ack == 1'b1)
            begin
              iex6_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 6 request flag
              //-------------------------------
              if (iex6_set == 1'b1)
              begin
                iex6_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if (int6ff == 1'b1 && int6_ff1 == 1'b0)   // positive edge
          begin
            iex6_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex6ack == 1'b1)
          begin
            iex6_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int6 input sample
          //-------------------------------
          int6_ff1  <= int6ff ;
        end
      end

      assign iex6 = iex6_s ;
//    assign iex6 = IRCON_RV[5] ;

  //------------------------------------------------------------------
  // External interrupt 7 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex7_proc
        if (rst == 1'b1)
        begin
          iex7_set  <=  1'b0 ;
          int7_ff1  <=  1'b0 ;
          iex7_s    <=  IRCON_RV[0] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == IRCON_ID && sfrwe == 1'b1)
          begin
            iex7_s    <= sfrdatai[0] ;
          end
          else
          begin
            if (iex7ack == 1'b1)
            begin
              iex7_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 7 request flag
              //-------------------------------
              if (iex7_set == 1'b1)
              begin
                iex7_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if (int7ff == 1'b1 && int7_ff1 == 1'b0)   // positive edge
          begin
            iex7_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex7ack == 1'b1)
          begin
            iex7_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int7 input sample
          //-------------------------------
          int7_ff1  <= int7ff ;
        end
      end

      assign iex7 = iex7_s ;
//    assign iex7 = IRCON_RV[0] ;

  //------------------------------------------------------------------
  // External interrupt 8 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex8_proc
        if (rst == 1'b1)
        begin
          iex8_set  <=  1'b0 ;
          int8_ff1  <=  1'b0 ;
          iex8_s    <=  IRCON2_RV[0] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == IRCON2_ID && sfrwe == 1'b1)
          begin
            iex8_s    <= sfrdatai[0] ;
          end
          else
          begin
            if (iex8ack == 1'b1)
            begin
              iex8_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 8 request flag
              //-------------------------------
              if (iex8_set == 1'b1)
              begin
                iex8_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if (int8ff == 1'b1 && int8_ff1 == 1'b0)   // positive edge
          begin
            iex8_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex8ack == 1'b1)
          begin
            iex8_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int8 input sample
          //-------------------------------
          int8_ff1  <= int8ff ;
        end
      end

      assign iex8 = iex8_s ;
//    assign iex8 = IRCON2_RV[0] ;

  //------------------------------------------------------------------
  // External interrupt 9 service
  //------------------------------------------------------------------
      always @(posedge clkper)
      begin : iex9_proc
        if (rst == 1'b1)
        begin
          iex9_set  <=  1'b0 ;
          int9_ff1  <=  1'b0 ;
          iex9_s    <=  IRCON2_RV[1] ;
        end
        else
        begin
          //-------------------------------
          // SFR write
          //-------------------------------
          if ( sfraddr == IRCON2_ID && sfrwe == 1'b1)
          begin
            iex9_s    <= sfrdatai[1] ;
          end
          else
          begin
            if (iex9ack == 1'b1)
            begin
              iex9_s  <=  1'b0 ;
            end
            else
            begin
              //-------------------------------
              // External Interrupt 9 request flag
              //-------------------------------
              if (iex9_set == 1'b1)
              begin
                iex9_s  <=  1'b1 ;
              end
            end
          end
          //-------------------------------
          // Edge detection
          //-------------------------------
          if (int9ff == 1'b1 && int9_ff1 == 1'b0)   // positive edge
          begin
            iex9_set  <= 1'b1 ;
          end
          else if (newinstr == 1'b1 || iex9ack == 1'b1)
          begin
            iex9_set  <= 1'b0 ;
          end
          //-------------------------------
          // Int9 input sample
          //-------------------------------
          int9_ff1  <= int9ff ;
        end
      end

      assign iex9 = iex9_s ;
//    assign iex9 = IRCON2_RV[1] ;

  //------------------------------------------------------------------
  // External interrupt 10 service
  //------------------------------------------------------------------

      assign iex10 = IRCON2_RV[2] ;

  //------------------------------------------------------------------
  // External interrupt 11 service
  //------------------------------------------------------------------

      assign iex11 = IRCON2_RV[3] ;

  //------------------------------------------------------------------
  // External interrupt 12 service
  //------------------------------------------------------------------

      assign iex12 = IRCON2_RV[4] ;

endmodule // extint

