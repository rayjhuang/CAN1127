
#include "../can1127_reg.h"


#define TCODE_BASE_ADDR           0x0033
#define GENERIC_HEADER_BASE_ADDR  0x0900
#define TRIM_TABLE_BASE_ADDR      0x0940

BYTE code GenHeaderCP      [1][16]   _at_ GENERIC_HEADER_BASE_ADDR;
BYTE code GenHeaderFT      [1][16]   _at_ GENERIC_HEADER_BASE_ADDR+16;
// ?CO?OTP(0x920) in 'Code:' column of 'BL51 Locate' tab
// *** WARNING L16: UNCALLED SEGMENT, IGNORED FOR OVERLAY PROCESS
//     SEGMENT: ?CO?OTP
BYTE code GenHeaderFW      [1][16]   _at_ GENERIC_HEADER_BASE_ADDR+16+16;
//// code GenHeaderFW      [1][16] = FIRMWARE_NAME;
BYTE code GenHeaderWriter  [1][16]   _at_ GENERIC_HEADER_BASE_ADDR+16+16+16;

BYTE code TrimTableOTP     [6][5]    _at_ TRIM_TABLE_BASE_ADDR;
BYTE code TCodeOTP         [2][8]    _at_ TCODE_BASE_ADDR; // 20180601


BYTE xdata uartbuf [256]; // without overflow control
BYTE idata idx, ii;
bit urtx_rdy;

void new_line ()
{
   uartbuf[idx  ] = 0x0D; // CR
   uartbuf[idx+1] = 0x0A; // LF
   uartbuf[idx+2] = ':';
   uartbuf[idx+3] = 0;
   urtx_rdy = 1;
   idx = 0;
}

// fine INIT_TMR0()  (TR0 = 0, TMOD = (TMOD & 0xFC) | 0x01, ET0 = 1)
#define INIT_TMR0()  (         TMOD = (TMOD & 0xFC) | 0x01         )
#define STOP_TMR0()  (TR0 = 0)
#define STRT_TMR0(v) (TH0 = ((-(v)) >> 8), \
                      TL0 = (-(v)),        \
                      TR0 = 1)

void port0_isr (void) interrupt INT_VECT_P0 {
// interrupt 2 times for the first START detection
   if (!P0_3) { // 1st interrupt
      STRT_TMR0(0xFFFF);
      P0STA = 0x08; // clear status of GPIO2
   } else { // 2nd interrupt
      STOP_TMR0();
   }
}

void uart0_isr (void) interrupt INT_VECT_UART0 {
   if (RI) {
      RI =0;
      if (!urtx_rdy)
      {
         uartbuf[idx] = S0BUF;
         if (uartbuf[idx]==13) // ENTER key
         {
            new_line ();
         }
         else
         {
            idx++;
         }
      }
   }
   if (TI) { // RX set during here will re-int later
      urtx_rdy = 1;
      TI =0;
   }
}

void main (void) {
   /* trimming */
   unsigned char code *ptr = TRIM_TABLE_BASE_ADDR;
   REGTRM0 = *ptr; ptr++;
   REGTRM1 = *ptr; ptr++;
   REGTRM2 = *ptr; ptr++;
   REGTRM3 = *ptr; ptr++;
   REGTRM4 = *ptr;

   for (idx=0; idx<0xFF; idx++) uartbuf[idx] = 0;
   P0 = idx; // debug
   uartbuf[idx++] = 0; // let idx=0
   P0 = 2; // debug
   P0++; // try RMW instr

   PWRCTL = 0xC0; // UART on D+/D-

   DB = 0x1; // baud rate doubler
   PCON = PCON | 0x80; // [7]:SMOD
   S0RELL = 0xF3; // 57600(57692)bps for 24MHz-clock
// S0RELH = 0x03;
   S0RELH = 0xC3; // 4x baud
   S0CON = 0x50; // mode 1, S0 reception enable

   new_line ();

   P0MSK = 0x08; // GPIO2
   P0STA = 0xFF; // clear port 0 status

   EX3 = 1; // IE1.3, port 0
   ES = 0x01; // IE[4], serial 0
   EA = 0x01; // IE[7], enable

   while (1)
   {
      if (urtx_rdy)
      {
         if (uartbuf[idx])
         {
            S0BUF = uartbuf[idx++];
         }
         else
         {
            idx = 0;
         }
         urtx_rdy = 0;
      }
   }
}
