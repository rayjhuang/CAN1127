
module ports (
  clkper,
  rst,
  port0,
  sfrdatai,
  sfraddr,
  sfrwe
  );

  // Control signals inputs
  input             clkper;     // Peripheral clock input
  input             rst;        // Global reset input

  // Port outputs
  output    [ 7: 0] port0;
  wire      [ 7: 0] port0;

  // Special function register interface
  input     [ 7: 0] sfrdatai;
  input     [ 6: 0] sfraddr;
  input             sfrwe;

//*******************************************************************--

  `include "mcu51_param.v"

  // Port registers
  reg       [ 7: 0] p0;

      //------------------------------------------------------------------
      // Port 0 ouput
      //------------------------------------------------------------------
      assign port0 = p0 ;

      //------------------------------------------------------------------
      always @(posedge clkper)
      begin : port0_proc
      //------------------------------------------------------------------
        //-----------------------------------
        // Synchronous reset
        //-----------------------------------
        if (rst == 1'b1)
        begin
          p0 <= P0_RV ;
        end
        else
        begin
          //-----------------------------------
          // Synchronous write
          //-----------------------------------
          // Special function register write
          //---------------------------------
          if (sfrwe == 1'b1 && sfraddr == P0_ID)
          begin
            p0 <= sfrdatai ;
          end
        end
      end



endmodule // ports

