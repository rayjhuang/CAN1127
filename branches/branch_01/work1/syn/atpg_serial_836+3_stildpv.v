// Verilog STILDPV testbench written by  TetraMAX (TM)  H-2013.03-i130221_204017 
// Date: Wed Mar  6 11:07:33 2024
// Module tested: chiptop_1127a0

`timescale 1 ns / 1 ns

module bench;
   integer verbose;         // message verbosity level
   integer report_interval; // pattern reporting intervals
   integer diagnostic_msg;  // format miscompares for TetraMAX diagnostics
   parameter NINPUTS = 20, NOUTPUTS = 22;
   // The next two variables hold the current value of the TetraMAX pattern number
   // and vector number, while the simulation is progressing. $monitor or $display these
   // variables, or add them to waveform views, to see these values change with time
   integer pattern_number;
   integer vector_number;

   wire CSP;  reg CSP_REG ;
   wire CSN;  reg CSN_REG ;
   wire VFB;  reg VFB_REG ;
   wire COMP;  reg COMP_REG ;
   wire SW;  reg SW_REG ;
   wire BST;  reg BST_REG ;
   wire VDRV;  reg VDRV_REG ;
   wire LG;
   wire HG;
   wire GATE;
   wire DP;  reg DP_REG ;
   wire DN;  reg DN_REG ;
   wire CC1;  reg CC1_REG ;
   wire CC2;  reg CC2_REG ;
   wire TST;  reg TST_REG ;
   wire GPIO_TS;  reg GPIO_TS_REG ;
   wire SCL;  reg SCL_REG ;
   wire SDA;  reg SDA_REG ;
   wire GPIO1;  reg GPIO1_REG ;
   wire GPIO2;  reg GPIO2_REG ;
   wire GPIO3;  reg GPIO3_REG ;
   wire GPIO4;  reg GPIO4_REG ;
   wire GPIO5;  reg GPIO5_REG ;

   // map register to wire for DUT inputs and bidis
   assign CSP = CSP_REG ;
   assign CSN = CSN_REG ;
   assign VFB = VFB_REG ;
   assign COMP = COMP_REG ;
   assign SW = SW_REG ;
   assign BST = BST_REG ;
   assign VDRV = VDRV_REG ;
   assign DP = DP_REG ;
   assign DN = DN_REG ;
   assign CC1 = CC1_REG ;
   assign CC2 = CC2_REG ;
   assign TST = TST_REG ;
   assign GPIO_TS = GPIO_TS_REG ;
   assign SCL = SCL_REG ;
   assign SDA = SDA_REG ;
   assign GPIO1 = GPIO1_REG ;
   assign GPIO2 = GPIO2_REG ;
   assign GPIO3 = GPIO3_REG ;
   assign GPIO4 = GPIO4_REG ;
   assign GPIO5 = GPIO5_REG ;

   // instantiate the design into the testbench
   chiptop_1127a0 U0_DUT (
      .CSP(CSP),
      .CSN(CSN),
      .VFB(VFB),
      .COMP(COMP),
      .SW(SW),
      .BST(BST),
      .VDRV(VDRV),
      .LG(LG),
      .HG(HG),
      .GATE(GATE),
      .DP(DP),
      .DN(DN),
      .CC1(CC1),
      .CC2(CC2),
      .TST(TST),
      .GPIO_TS(GPIO_TS),
      .SCL(SCL),
      .SDA(SDA),
      .GPIO1(GPIO1),
      .GPIO2(GPIO2),
      .GPIO3(GPIO3),
      .GPIO4(GPIO4),
      .GPIO5(GPIO5)   );

   // STIL Direct Pattern Validate Access
   initial begin
      //
      // --- establish a default time format for %t
      //
      $timeformat(-9,2," ns",18);
      vector_number = 0;

      //
      // --- default verbosity to 0; use '+define+tmax_msg=N' on verilog compile line to change.
      //
      `ifdef tmax_msg
         verbose = `tmax_msg ;
      `else
         verbose = 0 ;
      `endif

      //
      // --- default pattern reporting interval is every 5 patterns;
      //     use '+define+tmax_rpt=N' on verilog compile line to change.
      //
      `ifdef tmax_rpt
         report_interval = `tmax_rpt ;
      `else
         report_interval = 5 ;
      `endif

      //
      // --- support generating Extened VCD output by using
      //     '+define+tmax_vcde' on verilog compile line.
      //
      `ifdef tmax_vcde
         // extended VCD, see Verilog specification, IEEE Std. 1364-2001 section 18.3
         if (verbose >= 1) $display("// %t : opening Extended VCD output file sim_vcde.vcd", $time);
         $dumpports( U0_DUT, "sim_vcde.vcd");
      `endif

      //
      // --- default miscompare messages are not formatted for TetraMAX diagnostics;
      //     use '+define+tmax_diag=N' on verilog compile line to format errors for diagnostics.
      //
      `ifdef tmax_diag
         diagnostic_msg = `tmax_diag ;
      `else
         diagnostic_msg = 0 ;
      `endif

      // '+define+tmax_parallel=N' on the command line overrides default simulation, using parallel load
      //   with N serial vectors at the end of each Shift
      // '+define+tmax_serial=M' on the command line forces M initial serial patterns,
      //   followed by the remainder in parallel (with N serial vectors if tmax_parallel is also specified)

      // +define+tmax_par_force_time on the command line overrides default parallel check/load time
      `ifdef tmax_par_force_time
         $STILDPV_parallel(,,,`tmax_par_force_time);
      `endif

      // TetraMAX parallel-mode simulation required for these patterns
      `ifdef tmax_parallel
         // +define+tmax_serial_timing on the command line overrides default minimal-time for parallel load behavior
         `ifdef tmax_serial_timing
         `else
            $STILDPV_parallel(,,0); // apply minimal time advance for parallel load_unload
            // if tmax_serial_timing is defined, use equivalent serial load_unload time advance
         `endif
         `ifdef tmax_serial
            $STILDPV_parallel(`tmax_parallel,`tmax_serial);
         `else
            $STILDPV_parallel(`tmax_parallel,0);
         `endif
      `else
         `ifdef tmax_serial
            // +define+tmax_serial_timing on the command line overrides default minimal-time for parallel load behavior
            `ifdef tmax_serial_timing
            `else
               $STILDPV_parallel(,,0); // apply minimal time advance for parallel load_unload
               // if tmax_serial_timing is defined, use equivalent serial load_unload time advance
            `endif
            $STILDPV_parallel(0,`tmax_serial);
         `else
            // default serial mode
         `endif
      `endif

      if (verbose>3)      $STILDPV_trace(1,1,1,1,1,report_interval,diagnostic_msg); // verbose=4; + trace each Vector
      else if (verbose>2) $STILDPV_trace(1,0,1,1,1,report_interval,diagnostic_msg); // verbose=3; + trace labels
      else if (verbose>1) $STILDPV_trace(0,0,1,1,1,report_interval,diagnostic_msg); // verbose=2; + trace WFT-changes
      else if (verbose>0) $STILDPV_trace(0,0,1,0,1,report_interval,diagnostic_msg); // verbose=1; + trace proc/macro entries
      else                $STILDPV_trace(0,0,0,0,0,report_interval,diagnostic_msg); // verbose=0; only pattern-interval

      $STILDPV_setup( "./syn/atpg_serial_836+3.stil.gz",,,"bench.U0_DUT" );
      while ( !$STILDPV_done()) #($STILDPV_run( pattern_number, vector_number ));
      $display("Time %t: STIL simulation data completed.",$time);
      $finish; // comment this out if you terminate the simulation from other activities
   end

   // STIL Direct Pattern Validate Trace Options
   // The STILDPV_trace() function takes '1' to enable a trace and '0' to disable.
   // Unspecified arguments maintain their current state. Tracing may be changed at any time.
   // The following arguments control tracing of:
   // 1st argument: enable or disable tracing of all STIL labels
   // 2nd argument: enable or disable tracing of each STIL Vector and current Vector count
   // 3rd argument: enable or disable tracing of each additional Thread (new Pattern)
   // 4th argument: enable or disable tracing of each WaveformTable change
   // 5th argument: enable or disable tracing of each Procedure or Macro entry
   // 6th argument: interval to print starting pattern messages; 0 to disable
   // For example, a separate initial block may be used to control these options
   // (uncomment and change time values to use):
   // initial begin
   //    #800000 $STILDPV_trace(1,1);
   //    #600000 $STILDPV_trace(,0);
   // Additional calls to $STILDPV_parallel() may also be defined to change parallel/serial
   // operation during simulation. Any additional calls need a # time value.
   // 1st integer is number of serial (flat) cycles to simulate at end of each shift
   // 2nd integer is TetraMAX pattern number (starting at zero) to start parallel load
   // 3rd optional value '1' will advance time during the load_unload the same as a serial
   //     shift operation (with no events during that time), '0' will advance minimal time
   //     (1 shift vector) during the parallel load_unload.
   // For example,
   //    #8000 $STILDPV_parallel( 2,10 );
   // end // of initial block with additional trace/parallel options
endmodule
