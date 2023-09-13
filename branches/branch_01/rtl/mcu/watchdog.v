
module watchdog (
  wdt_slow,
  clkwdt,
  clkper,
  resetff,
  newinstr,
  wdts_s,
  wdts,
  ip0wdts,
  wdt_tm,
  sfrdatai,
  sfraddr,
  sfrwe,
  wdtrel
  );
  input             wdt_slow;
  input             clkwdt;         // reset may fail if clkwdt is in 32K mode
  input             clkper;         // Global clock input
  input             resetff;
  input             newinstr;
  output    [ 1: 0] wdts_s;
  output            wdts;           // WDT reset request
//wire              wdts;
  output            ip0wdts;        // WDT status flag
  reg               ip0wdts;
  output            wdt_tm;         // WDT test mode flag
  wire              wdt_tm;
  input     [ 7: 0] sfrdatai;
  input     [ 6: 0] sfraddr;
  input             sfrwe;
  output    [ 7: 0] wdtrel;
  wire      [ 7: 0] wdtrel;

//*******************************************************************--

  `include "mcu51_param.v"

  // Watchdog Timer Refresh request
  reg               wdtrefresh;
  // Watchdog Timer Reload Register
  reg       [ 7: 0] wdtrel_s;
  // Watchdog Timer Registers
  reg       [ 7: 0] wdtl;
  reg       [ 6: 0] wdth;
  // Watchdog Prescaler Registers
  reg               pres_2;
  reg       [ 3: 0] pres_16;
  // Watchdog counters of clk
  reg       [ 3: 0] cycles_reg;
  // Watchdog activated register
  reg               wdt_act, wdt_act_sync;
  // wdt status flag
  reg       [ 1: 0] wdts_s;
  // test mode flag
  reg               wdt_tm_s, wdt_tm_sync;
  // Watchdog Timer Refresh Flag in normal and debug modes
  reg               wdt_normal;
  reg               wdt_normal_ff;
  // Watchdog Prescaler Registers
  reg       [ PRES_LENGTH_EXTENSION-1: 0] pres_8;

  //------------------------------------------------------------------
  // Watchdog Timer status flag
  //   reset request flag
  //   high active output
  //------------------------------------------------------------------
//assign wdts = wdts_s ;

  reg wdts;
  always @(posedge clkper)
     wdts <= wdts_s[0] ;

  //------------------------------------------------------------------
  assign wdt_tm = wdt_tm_s ;

  always @(posedge clkwdt)
     wdt_tm_sync <= wdt_tm_s ;

  always @(posedge clkwdt)
     wdt_act_sync <= wdt_act ;

//synchr U_REFSYNC (.sck(clkper), .ena(wdtrefresh), .te(1'h0),
//                  .dck(clkwdt), .sync_q(wdtrefresh_sync));
  wire wdtrefresh_sync = wdtrefresh;

  wire [7:0] rev_half = wdt_slow ? 8'b0001_0000 : 8'b1000_0000;
  wire [14:0] rev_RSL = wdt_slow ? 15'b111_1111_0001_1111 : 15'b111_1111_1110_1111;
  wire [14:0] rev_RSH = wdt_slow ? 15'b111_1111_0001_1111 : 15'b111_1111_1111_1111;
  wire [14:0] rev_WDT_RSL = WDT_RSL & rev_RSL;
  wire [14:0] rev_WDT_RSH = WDT_RSH & rev_RSH;

  wire [14:8] half_RSL_tmp = rev_WDT_RSL[14:8] + wdtrel_s[6:0];
  wire [14:0] half_RSL = (half_RSL_tmp[8])
                       ? { half_RSL_tmp>>1, rev_WDT_RSL[7:0]>>1 | rev_half }
                       : { half_RSL_tmp>>1, rev_WDT_RSL[7:0]>>1 };

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : wdrel_write_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (resetff == 1'b1)
    begin
      wdtrel_s <= WDTREL_RV ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      if (sfrwe == 1'b1 && sfraddr == WDTREL_ID )
      begin
        wdtrel_s <= sfrdatai ;
      end
    end
  end


  //------------------------------------------------------------------
  always @(posedge clkwdt)
  begin : divider_proc
  //------------------------------------------------------------------
    if (resetff == 1'b1)
    begin
      cycles_reg <= 4'b0000 ;
      pres_8     <= {(PRES_LENGTH_EXTENSION){1'b0}};
    end
    else
    begin
      if (wdt_act_sync == 1'b1)
      begin
        if (wdt_tm_sync == 1'b0)
        begin
          //-----------------------------------
          // Synchronous reset
          //-----------------------------------
          if (wdtrefresh_sync == 1'b1)
          begin
            cycles_reg <= 4'b0000;
            pres_8     <= {(PRES_LENGTH_EXTENSION){1'b0}};
          end
          else
          begin
            //-----------------------------------
            // Synchronous write
            //-----------------------------------
              //--------------------------------
              // clk divider by 12
              //--------------------------------
              if (cycles_reg == 4'b1011)
              begin
                cycles_reg <= 4'b0000;
                if (pres_8 == {(PRES_LENGTH_EXTENSION){1'b1}})
                begin
                  pres_8   <= {(PRES_LENGTH_EXTENSION){1'b0}};
                end
                else
                begin
                  pres_8   <= pres_8 + 1'b1;
                end
              end
              else
              begin
                cycles_reg <= cycles_reg + 1'b1;
              end
          end
        end
        else
        begin
          cycles_reg <= 4'b1011;
          pres_8     <= {(PRES_LENGTH_EXTENSION){1'b1}};
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkwdt)
  begin : prescaler_proc
  //------------------------------------------------------------------
    if (resetff == 1'b1)
    begin
      pres_2  <= 1'b0 ;
      pres_16 <= 4'b0000 ;
    end
    else
    begin
      if (wdt_act_sync == 1'b1)
      begin
        if (wdt_tm_sync == 1'b0)
        begin
          if (wdtrefresh_sync == 1'b1)
          begin
            pres_2  <= 1'b0 ;
            pres_16 <= 4'b0000 ;
          end
          else
          begin
              //-----------------------------------
              // Synchronous reset
              //-----------------------------------
              if (cycles_reg == 4'b1011
                  && pres_8 == {(PRES_LENGTH_EXTENSION){1'b1}})
              begin
                pres_2 <= ~pres_2 ;
                //-----------------------------------
                // Synchronous write
                //-----------------------------------
                if (pres_2 == 1'b1)
                begin
                  //--------------------------------
                  // Prescalers :2, :16
                  //--------------------------------
                  if (pres_16 == 4'b1111)
                  begin
                    pres_16 <= 4'b0000 ;
                  end
                  else
                  begin
                    pres_16 <= pres_16 + 1'b1 ;
                  end
                end
              end
          end
        end
        else
        begin
          pres_2  <= 1'b1 ;
          pres_16 <= 4'b1111 ;
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkwdt)
  begin : timer_proc
  //------------------------------------------------------------------
    if (resetff == 1'b1)
    begin
      wdth    <= WDTH_RV ; // B"000_0000"
      wdtl    <= WDTL_RV ; // B"0000_0000"
      wdts_s  <= 2'b0 ;
    end
    else
    begin
      if (wdtrefresh_sync == 1'b1)
      begin
        wdth    <= wdtrel_s[6:0] ;
        wdtl    <= WDTL_RV ; // B"0000_0000"
        wdts_s  <= 2'b0 ;
      end
      else
      begin
        if (
          wdt_act_sync == 1'b1
          )
        begin
            if ((((wdtrel_s[7]) == 1'b1)
                 ? ({pres_16, pres_2, cycles_reg}) == 9'b111111011
                 : ({pres_2, cycles_reg}) == 5'b11011)
                         && pres_8 == {(PRES_LENGTH_EXTENSION){1'b1}})
            begin
              if (wdtl == rev_WDT_RSH[7:0])
              begin
                wdtl    <= WDTL_RV ;
                wdth    <= wdth + 1'b1 ;
//              if ((wdth) == rev_WDT_RSH[14:8])
                wdts_s  <= 2'b0 ;
              end
              else
              begin
                wdtl    <= wdtl + 1'b1 ;

                if (({wdth, wdtl}) == rev_WDT_RSL)
                  wdts_s[0] <= 1'b1 ;

                if ({1'h0,wdtl[6:0]} == (rev_WDT_RSH[7:0]>>1))
                  wdts_s[1] <= 1'b0 ;
                else if (({1'h0, wdth[5:0], wdtl}) == half_RSL)
                  wdts_s[1] <= 1'b1 ;
              end
            end
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : tm_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (resetff == 1'b1)
    begin
      wdt_tm_s <= PCON_RV[6] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special Function Register write
      //--------------------------------
      if (sfraddr == PCON_ID && sfrwe == 1'b1)
      begin
        wdt_tm_s <= sfrdatai[6] ;
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : wdts_proc
  //------------------------------------------------------------------
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    if (resetff == 1'b1)
    begin
      ip0wdts <= IP0_RV[6] ;
    end
    else
    begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special Function Register write
      //--------------------------------
      if (sfraddr == IP0_ID && sfrwe == 1'b1)
      begin
        ip0wdts <= sfrdatai[6] ;
      end
      else
      begin
        //--------------------------------
        // WDT Timer overflow
        //--------------------------------
        if (wdts_s[0] == 1'b1) // async.
        begin
          ip0wdts <= 1'b1 ;
        end
      end
    end
  end

  //------------------------------------------------------------------
  // Activate the Watchdog
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : wdt_act_proc
  //------------------------------------------------------------------
    if (wdts_s[0] == 1'b0) // async.
    begin
      if (resetff == 1'b1)
      begin
          wdt_act <= 1'b0 ;
      end
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      else
      begin
        //-----------------------------------
        // Synchronous reset
        //-----------------------------------
        if (sfrwe == 1'b1 && sfraddr == IEN1_ID && (sfrdatai[6]) == 1'b1)
        begin
          wdt_act <= 1'b1 ;
        end
      end
    end
  end

  //------------------------------------------------------------------
  // Watchdog Refresh
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : wdt_ref_proc
  //------------------------------------------------------------------
    if (resetff == 1'b1)
    begin
      wdtrefresh    <= 1'b0 ;
      wdt_normal    <= IEN0_RV[6] ;
      wdt_normal_ff <= IEN0_RV[6] ;
    end
    else
    begin

      if (sfraddr == IEN0_ID && sfrwe == 1'b1)
      begin
        //---------------------------------
        // Special Function Register write
        //---------------------------------
          wdt_normal    <= sfrdatai[6] ;
          wdt_normal_ff <= wdt_normal ;
      end
      else
      begin
        //-----------------------------------
        // Synchronous reset
        //-----------------------------------
        if (newinstr == 1'b1)
        begin
          //-------------------------------
          // Clear after one instruction
          //-------------------------------
            wdt_normal    <= 1'b0 ;
            wdt_normal_ff <= wdt_normal ;
        end
      end
      if (sfraddr == IEN1_ID && sfrwe == 1'b1 && (sfrdatai[6]) == 1'b1)
      begin
        //---------------------------------
        // Refresh the Watchdog
        //---------------------------------
          wdtrefresh    <= wdt_normal_ff ;
      end
      else
      begin
        wdtrefresh    <= 1'b0 ;
      end
    end
  end

  //------------------------------------------------------------------
  // Special function registers outputs
  //------------------------------------------------------------------
  assign wdtrel = wdtrel_s ;

endmodule // watchdog

