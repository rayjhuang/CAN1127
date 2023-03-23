
#include "../can1127_reg.h"

typedef enum {
   I2CSLV_STATE_IDLE,       // 0x00
   I2CSLV_STATE_RDAT,       // 0x01
   I2CSLV_STATE_WDAT,       // 0x02
}  I2CSLV_STATE_BYTE;
I2CSLV_STATE_BYTE i2csta _at_ 0x10;
BYTE bycnt _at_ 0x11;

bit ev_wdat;
BYTE wdat [4],
     wcmd _at_ 0x12,
     wcnt _at_ 0x13;

BYTE rdat0; // save the 1st byte
BYTE xdata cmd00 _at_ 0x80+0x00; // BANK13
BYTE xdata cmd01 _at_ 0x80+0x01; // BANK13
BYTE xdata cmd02 _at_ 0x80+0x02; // BANK13
BYTE xdata cmd03 _at_ 0x80+0x03; // BANK13
#define NUM_CMD 4

BYTE xdata ext00 [3] _at_ 0x00;
BYTE xdata ext01 [1]; // _at_ 0x03;
BYTE xdata ext03 [1]; // _at_ 0x04;

BYTE code cmd_table [][2] =
{  // len, ofs
      { 4,  0}, // CMD00: length=4, offset@0
      { 2,  3}, // CMD01: length=2, offset@3
      { 1,  4}, // CMD02: length=1, offset@4 (useless)
      {-2,  4}  // CMD03: length=2, offset@4 (read-only)
};

BYTE xdata* getext (BYTE cmd)
{
   return ext00 + cmd_table[cmd][1];
}

void hwi2c_isr () interrupt INT_VECT_HWI2C
{
   if (I2CEV&0x04) // PG0WR
   {
      if (i2csta==I2CSLV_STATE_WDAT && bycnt<4)
      {
         wdat[bycnt] = I2CBUF;
         bycnt++;
      }
      I2CEV = 0x04; // stretch more
   }

   else if (I2CEV&0x40) // PG0RD
   {
      if (i2csta==I2CSLV_STATE_RDAT && bycnt<4 || bycnt==0)
      {
         ((BYTE xdata*)I2CCMD)[0x80] = getext(I2CCMD)[bycnt]; // for returning the next byte
         bycnt++;
         i2csta = I2CSLV_STATE_RDAT;
      }
      I2CEV = 0x40; // stretch more
   }

   else if (I2CEV&0x10) // CMD
   {
      if (I2CCMD<NUM_CMD)
      {
         bycnt = 0;
         rdat0 = ((BYTE xdata*)I2CCMD)[0x80]; // prefetch

         i2csta = I2CSLV_STATE_WDAT;
      }
      I2CEV = 0x10; // stretch more
   }

   else if (I2CEV&0x20) // STOP
   {
      I2CEV = 0x20;
      ((BYTE xdata*)I2CCMD)[0x80] = rdat0; // restore
      if (i2csta==I2CSLV_STATE_WDAT && bycnt>0)
      {
         wcmd = I2CCMD; // I2CCMD is about to disapear
         wcnt = bycnt;
         ev_wdat = 1;
      }

      i2csta = I2CSLV_STATE_IDLE;
   }
}

void hwi2c_fw_init ()
{
   GPIO5 |= 0x20; // SCL stretch
   i2csta = I2CSLV_STATE_IDLE;
   cmd03 = 0xCD, ext03[0] = 0x30;
}

void main ()
{
   BYTE ii;
   hwi2c_fw_init();
   I2CCTL = 0x3A; // non-inc,BANK13(XDATA 80h~FFh),write-protected
   I2CMSK = 0x74; // rdpg0/stop/cmd/wrpg0
   EX2 = 1; // IEN1.1: HWI2C
   EAL = 1; // IEN0.7: EA/EAL
   while (1)
      if (ev_wdat)
      {
         P0 = wcmd;
         for (ii=0; ii<wcnt; ii++)
            P0 = wdat[ii];
         if (wcnt==cmd_table[wcmd][0])
         {
            ((BYTE xdata*)wcmd)[0x80] = wdat[0];
            for (ii=1; ii<wcnt; ii++)
               getext(wcmd)[ii-1] = wdat[ii];
         }
         ev_wdat = 0;
      }
}
