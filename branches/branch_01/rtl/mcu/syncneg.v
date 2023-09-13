
module syncneg (
  clk,
  reset,
  rsttowdt,
  rsttosrst,
  rst,
  int0,
  int1,
//int2,
//int3,
//int4,
//int5,
//int6,
//int7,
//int8,
  port0i,
  rxd0i,
  sdai,
  int0ff,
  int1ff,
//int2ff,
//int3ff,
//int4ff,
//int5ff,
//int6ff,
//int7ff,
//int8ff,
//int9ff,
//int10ff,
//int11ff,
//int12ff,
  port0ff,
  t0ff,
  t1ff,
  rxd0ff,
  sdaiff,
  rsttowdtff,
  rsttosrstff,
  rstff,
  resetff
  );

  input             clk;          // Master clock input
  input             reset;        // Hardware Reset Input
  input             rsttowdt;
  input             rsttosrst;
  input             rst;
  input             int0;         // Extenral Interrupt 0 input
  input             int1;         // Extenral Interrupt 1 input
//input             int2;         // External Interrupt 2 input
//input             int3;         // External Interrupt 3 input
//input             int4;         // External Interrupt 4 input
//input             int5;         // External Interrupt 5 input
//input             int6;         // External Interrupt 6 input
//input             int7;         // External Interrupt 7 input
  input     [ 7: 0] port0i;       // Port0 input
  input             rxd0i;        // Serial 0 data input
  input             sdai;         // I2C data input

  output            int0ff;       // Extenral Interrupt 0 sample
  wire              int0ff;
  output            int1ff;       // Extenral Interrupt 1 sample
  wire              int1ff;
//output            int2ff;       // Extenral Interrupt 2 sample
//wire              int2ff;
//output            int3ff;       // Extenral Interrupt 3 sample
//wire              int3ff;
//output            int4ff;       // Extenral Interrupt 4 sample
//wire              int4ff;
//output            int5ff;       // Extenral Interrupt 5 sample
//wire              int5ff;
//output            int6ff;       // Extenral Interrupt 6 sample
//wire              int6ff;
//output            int7ff;       // Extenral Interrupt 7 sample
//wire              int7ff;
//output            int8ff;       // Extenral Interrupt 8 sample
//wire              int8ff;
//output            int9ff;       // Extenral Interrupt 9 sample
//wire              int9ff;
//output            int10ff;      // Extenral Interrupt 10 sample
//wire              int10ff;
//output            int11ff;      // Extenral Interrupt 11 sample
//wire              int11ff;
//output            int12ff;      // Extenral Interrupt 12 sample
//wire              int12ff;
  output    [ 7: 0] port0ff;
  wire      [ 7: 0] port0ff;
  output            t0ff;         // Timer 0 sample
  wire              t0ff;
  output            t1ff;         // Timer 1 sample
  wire              t1ff;
  output            rxd0ff;       // Serial 0 data input sample
  wire              rxd0ff;
  output            sdaiff;       // I2C data input sample
  wire              sdaiff;
  output            rsttowdtff;
  wire              rsttowdtff;
  output            rsttosrstff;
  wire              rsttosrstff;
  output            rstff;
  wire              rstff;
  output            resetff;
  wire              resetff;

//*******************************************************************--

  `include "mcu51_param.v"

  // Hardware reset sample flip-flops
  reg               reset_ff1;
  reg               reset_ff2;
  // External Interrupt 0 sample flip-flops
  reg               int0_ff1;
  reg               int0_ff2;
  // External Interrupt 1 sample flip-flops
  reg               int1_ff1;
  reg               int1_ff2;
  // External Interrupt 2 sample flip-flops
  //reg               int2_ff1;
  //reg               int2_ff2;
  // External Interrupt 3 sample flip-flops
  //reg               int3_ff1;
  //reg               int3_ff2;
  // External Interrupt 4 sample flip-flops
  //reg               int4_ff1;
  //reg               int4_ff2;
  // External Interrupt 5 sample flip-flops
  //reg               int5_ff1;
  //reg               int5_ff2;
  // External Interrupt 6 sample flip-flops
  //reg               int6_ff1;
  //reg               int6_ff2;
  // External Interrupt 7 sample flip-flops
  //reg               int7_ff1;
  //reg               int7_ff2;
  // External Interrupt 8 sample flip-flops
  //reg               int8_ff1;
  //reg               int8_ff2;
  // External Interrupt 9 sample flip-flops
  // External Interrupt 10 sample flip-flops
  // External Interrupt 11 sample flip-flops
  // External Interrupt 12 sample flip-flops
  // Port 0 sample flip-flops
  reg       [ 7: 0] p0_ff1;
  reg       [ 7: 0] p0_ff2;
  // Timer 0 input sample flip-flops
  // Timer 1 input sample flip-flops
  // Watchdog Timer input sample flip-flops
  // Serial 0 input sample flip-flops
  reg               rxd0_ff1;
  reg               rxd0_ff2;
  // I2C input sample flip-flop
  reg               sdai_ff1;
  reg               sdai_ff2;
  reg               rsttowdt_ff1;
  reg               rsttosrst_ff1;
  reg               rst_ff1;

  //-------------------------------------------------------------------
  // reset(input) ______  reset_ff1  ______  reset_ff2
  //       ------|      |___________|      |__________ resetff (output)
  // clk (input) |      |           |      |
  //       -----o|>     |     -----o|>     |
  //         |   |______|     |     |______|
  //         |________________|
  //-------------------------------------------------------------------
  always @(posedge clk)
  begin : syncreg_proc
  //-------------------------------------------------------------------
    reset_ff1 <= reset ;
    reset_ff2 <= reset_ff1 ;
  end

  //-------------------------------------------------------------------
  assign resetff = reset_ff2 ;

      //-------------------------------------------------------------------
      // Reset to Watchdog flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : rsttowdtff_proc
        rsttowdt_ff1 <= rsttowdt;
      end
      assign rsttowdtff = rsttowdt_ff1 ;

      //-------------------------------------------------------------------
      // Reset to Watchdog flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : rsttosrstff_proc
        rsttosrst_ff1 <= rsttosrst;
      end
      assign rsttosrstff = rsttosrst_ff1 ;

      //-------------------------------------------------------------------
      // Reset to Watchdog flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : rstff_proc
        rst_ff1 <= rst;
      end
      assign rstff = rst_ff1 ;

      //-------------------------------------------------------------------
      // External Interrupts 0..12 sampling scheme
      //-------------------------------------------------------------------
      // int (input)  ______  int_ff1    ______  int_ff2
      //       ------|      |___________|      |__________ intff (output)
      // clk (input) |      |           |      |
      //       -----o|>     |     -----o|>     |
      //         |   |______|     |     |______|
      //         |________________|
      //-------------------------------------------------------------------
      //-------------------------------------------------------------------
      // External Interrupt 0 synchronization flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : int0ff_proc
        int0_ff1 <= int0 ;
        int0_ff2 <= int0_ff1 ;
      end
      assign int0ff = int0_ff2 ;

      //-------------------------------------------------------------------
      // External Interrupt 1 synchronization flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : int1ff_proc
        int1_ff1 <= int1 ;
        int1_ff2 <= int1_ff1 ;
      end
      assign int1ff = int1_ff2 ;


////////-------------------------------------------------------------------
//////// External Interrupt 2 synchronization flip-flops
////////-------------------------------------------------------------------
//    always @(posedge clk)
//    begin : int2ff_proc
//      int2_ff1 <= int2 ;
//      int2_ff2 <= int2_ff1 ;
//    end
//    assign int2ff = int2_ff2 ;

////////-------------------------------------------------------------------
//////// External Interrupt 3 synchronization flip-flops
////////-------------------------------------------------------------------
//    always @(posedge clk)
//    begin : int3ff_proc
//      int3_ff1 <= int3 ;
//      int3_ff2 <= int3_ff1 ;
//    end
//    assign int3ff = int3_ff2 ;
//////assign int3ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 4 synchronization flip-flops
////////-------------------------------------------------------------------
//    always @(posedge clk)
//    begin : int4ff_proc
//      int4_ff1 <= int4 ;
//      int4_ff2 <= int4_ff1 ;
//    end
//    assign int4ff = int4_ff2 ;
//////assign int4ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 5 synchronization flip-flops
////////-------------------------------------------------------------------
//    always @(posedge clk)
//    begin : int5ff_proc
//      int5_ff1 <= int5 ;
//      int5_ff2 <= int5_ff1 ;
//    end
//    assign int5ff = int5_ff2 ;
//////assign int5ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 6 synchronization flip-flops
////////-------------------------------------------------------------------
//    always @(posedge clk)
//    begin : int6ff_proc
//      int6_ff1 <= int6 ;
//      int6_ff2 <= int6_ff1 ;
//    end
//    assign int6ff = int6_ff2 ;
//////assign int6ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 7 synchronization flip-flops
////////-------------------------------------------------------------------
//    always @(posedge clk)
//    begin : int7ff_proc
//      int7_ff1 <= int7 ;
//      int7_ff2 <= int7_ff1 ;
//    end
//    assign int7ff = int7_ff2 ;
//////assign int7ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 8 synchronization flip-flops
////////-------------------------------------------------------------------
//////always @(posedge clk)
//////begin : int8ff_proc
//////  int8_ff1  <=  int8 ;
//////  int8_ff2  <=  int8_ff1 ;
//////end

//    assign int8ff = int8 ;

////////-------------------------------------------------------------------
//////// External Interrupt 9 synchronization flip-flops
////////-------------------------------------------------------------------
//////assign int9ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 10 synchronization flip-flops
////////-------------------------------------------------------------------
//////assign int10ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 11 synchronization flip-flops
////////-------------------------------------------------------------------
//////assign int11ff = 1'h0 ;
//////
////////-------------------------------------------------------------------
//////// External Interrupt 12 synchronization flip-flops
////////-------------------------------------------------------------------
//////assign int12ff = 1'h0 ;
//////
      //-------------------------------------------------------------------
      // Port 0..3 sampling scheme
      //-------------------------------------------------------------------
      // port (input)  ______  port_ff1  ______  port_ff2
      //       ------|      |___________|      |__________ portff (output)
      // clk (input) |      |           |      |
      //       -----o|>     |     -----o|>     |
      //         |   |______|     |     |______|
      //         |________________|
      //-------------------------------------------------------------------
      //-------------------------------------------------------------------
      // Port 0 synchronization flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : p0ff_proc
        p0_ff1 <= port0i ;
        p0_ff2 <= p0_ff1 ;
      end
      assign port0ff = p0_ff2 ;

      //-------------------------------------------------------------------
      // Timer 0 input sampling scheme
      //-------------------------------------------------------------------
      // t0 (input)   ______  t0_ff1     ______  t0_ff2
      //       ------|      |___________|      |__________ t0ff (output)
      // clk (input) |      |           |      |
      //       -----o|>     |     -----o|>     |
      //         |   |______|     |     |______|
      //         |________________|
      //-------------------------------------------------------------------
      //-------------------------------------------------------------------
      // Timer 0 input synchronization flip-flops
      //-------------------------------------------------------------------
      assign t0ff = 1'h0 ;

      //-------------------------------------------------------------------
      // Timer 1 input sampling scheme
      //-------------------------------------------------------------------
      // t1 (input)   ______  t1_ff1     ______  t1_ff2
      //       ------|      |___________|      |__________ t1ff (output)
      // clk (input) |      |           |      |
      //       -----o|>     |     -----o|>     |
      //         |   |______|     |     |______|
      //         |________________|
      //-------------------------------------------------------------------
      //-------------------------------------------------------------------
      // Timer 1 input synchronization flip-flops
      //-------------------------------------------------------------------
      assign t1ff = 1'h0 ;

      //-------------------------------------------------------------------
      // Serial 0 input sampling scheme
      //-------------------------------------------------------------------
      // rxd0i(input) ______  rxd0_ff1   ______  rxd0_ff2
      //       ------|      |___________|      |__________ rxd0ff (output)
      // clk (input) |      |           |      |
      //       -----o|>     |     -----o|>     |
      //         |   |______|     |     |______|
      //         |________________|
      //-------------------------------------------------------------------
      //-------------------------------------------------------------------
      // Serial 0 input synchronization flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : rxd1ff_proc
        rxd0_ff1 <= rxd0i ;
        rxd0_ff2 <= rxd0_ff1 ;
      end
      assign rxd0ff = rxd0_ff2 ;
// synopsys translate_off
   always @(rxd0_ff1) if (!reset) // not in reset
      if (rxd0_ff1===1'hx) // meta-stable
         #({$random}%10+10) if (rxd0i!==1'hx) begin
            rxd0_ff1 = $random;
            $display ($time,"ns <%m> rxd0_ff1 got matastable");
         end
// synopsys translate_on

      //-------------------------------------------------------------------
      // I2C input sampling scheme
      //-------------------------------------------------------------------
      // sdai (input) ______  sdai_ff1   ______  sdai_ff2
      //       ------|      |___________|      |__________ sdaiff (output)
      // clk (input) |      |           |      |
      //       -----o|>     |     -----o|>     |
      //         |   |______|     |     |______|
      //         |________________|
      //-------------------------------------------------------------------
      //-------------------------------------------------------------------
      // I2C input synchronization flip-flops
      //-------------------------------------------------------------------
      always @(posedge clk)
      begin : sdaiff_proc
        sdai_ff1 <= sdai ;
        sdai_ff2 <= sdai_ff1 ;
      end
      assign sdaiff = sdai_ff2 ;



endmodule // syncneg

