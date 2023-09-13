
module pmurstctrl (
  resetff,
  wdts,
  srst,
  pmuintreq,
  stop,
  idle,
  clkcpu_en,
  clkper_en,
  cpu_resume,
  rsttowdt,
  rsttosrst,
  rst
  );

  `include "mcu51_param.v"

  input             resetff;    // Reset input sample
  input             wdts;       // Watchdog Overflow input
  input             srst;       // Software reset input
  input             pmuintreq;  // Interrupt request (ext. int. 0 or 1 only)
  input             stop;       // Stop Mode request input from CPU
  input             idle;       // Idle Mode request input from CPU
  output            clkcpu_en;  // CPU clock enable output
  wire              clkcpu_en;
  output            clkper_en;  // Peripheral clock enable output
  wire              clkper_en;
  output            cpu_resume; // CPU run
  wire              cpu_resume;
  output            rsttowdt;   // Synchronous reset of WATCHDOG
  wire              rsttowdt;
  output            rsttosrst;  // Synchronous reset of SRST
  wire              rsttosrst;
  output            rst;        // Synchronous reset
  wire              rst;

//*******************************************************************--

  wire              clkcpu_gate; // CPU clock gate signal
  wire              clkper_gate; // Peripheral clock gate signal
  wire              clk_resume_s;

  // ----------------------------------
  // CPU Resume Signals
  // ----------------------------------
  assign clk_resume_s = 
                        (pmuintreq
                        )
                        ;
  assign cpu_resume = pmuintreq;
  // ----------------------------------
  // Clock Enable Signals
  // ----------------------------------
  assign clkcpu_gate  = ((~idle & ~stop) | clk_resume_s);
  assign clkper_gate  = (~stop | clk_resume_s);
  // ----------------------------------
  // CPU Clock Enable output
  // ----------------------------------
  assign clkcpu_en = clkcpu_gate;
  // ----------------------------------
  // Peripheral Clock Enable output
  // ----------------------------------
  assign clkper_en = clkper_gate;
  // ---------------------------------------------------------------
  // Asynchronous reset generation (upon hardware or watchdog or software reset)
  // ---------------------------------------------------------------
  assign rst         = wdts | srst | resetff;
  assign rsttowdt    = srst | resetff;
  assign rsttosrst   = wdts | resetff;
  
endmodule // pmurstctrl

