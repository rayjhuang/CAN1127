
module wakeupctrl (
  irq,
  int0ff,
  int1ff,
  it0,
  it1,
  isreg,
  intprior0,
  intprior1,
  eal,
  eint0,
  eint1,
  pmuintreq
  );

  input             irq;              // from ISR
  input             int0ff;           // external interrupt 0 sample
  input             int1ff;           // external interrupt 1 sample
  input             it0;              // interrupt 0 type select
  input             it1;              // interrupt 1 type select
  input     [ 3: 0] isreg;
  input     [ 1: 0] intprior0;
  input     [ 1: 0] intprior1;
  input             eal;              // Enable all interrupts
  input             eint0;            // external interrupt 0 mask
  input             eint1;            // external interrupt 1 mask
  output            pmuintreq;
  wire              pmuintreq;

//*******************************************************************--

  `include "mcu51_param.v"

  wire              int_req;          // Interrupt request sync.e

  //------------------------------------------------------------------
  // Interrupt request to PMU
  //------------------------------------------------------------------
  assign pmuintreq = int_req ;

  //------------------------------------------------------------------
  // Combinational interrupt request
  // High active
  //------------------------------------------------------------------
      assign int_req =
        ((irq == 1'b1) |                                    // ISR intreq
         (eal == 1'b1 &
          ((int0ff == 1'b0 & eint0 == 1'b1 & it0 == 1'b0 &  // ext. int. 0
            ((intprior0[0]  == 1'b1 &
              intprior1[0]  == 1'b1 &                       // l3
              isreg[3]      == 1'b0) |
             (intprior0[0]  == 1'b0 &
              intprior1[0]  == 1'b1 &                       // l2
              isreg[3]      == 1'b0 &
              isreg[2]      == 1'b0) |
             (intprior0[0]  == 1'b1 &
              intprior1[0]  == 1'b0 &                       // l1
              isreg[3]      == 1'b0 &
              isreg[2]      == 1'b0 &
              isreg[1]      == 1'b0) |
             (intprior0[0]  == 1'b0 &
              intprior1[0]  == 1'b0 &                       // l0
              isreg[3]      == 1'b0 &
              isreg[2]      == 1'b0 &
              isreg[1]      == 1'b0 &
              isreg[0]      == 1'b0)))
           |
           (int1ff == 1'b0 & eint1 == 1'b1 & it1 == 1'b0 &  // ext. int. 1
            ((intprior0[1]  == 1'b1 &
              intprior1[1]  == 1'b1 &                       // l3
              isreg[3]      == 1'b0) |
             (intprior0[1]  == 1'b0 &
              intprior1[1]  == 1'b1 &                       // l2
              isreg[3]      == 1'b0 &
              isreg[2]      == 1'b0) |
             (intprior0[1]  == 1'b1 &
              intprior1[1]  == 1'b0 &                       // l1
              isreg[3]      == 1'b0 &
              isreg[2]      == 1'b0 &
              isreg[1]      == 1'b0) |
             (intprior0[1]  == 1'b0 &
              intprior1[1]  == 1'b0 &                       // l0
              isreg[3]      == 1'b0 &
              isreg[2]      == 1'b0 &
              isreg[1]      == 1'b0 &
              isreg[0]      == 1'b0)
             )
            )
           ))) ? 1'b1 : 1'b0 ;


endmodule // wakeupctrl

