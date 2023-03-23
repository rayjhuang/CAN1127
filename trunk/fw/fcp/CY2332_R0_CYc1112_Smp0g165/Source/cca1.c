
#include "global.h"

#ifdef CFG_CCA1

#define ROOT_DELAY 1000 //decrease vol delay
#define I2C_RELOAD_TIME 500
#define I2C_SLAVE_DEVA 0x50
#define I2C_MASTER_IDX 0x078 // local status

BYTE u8SlvPdpx2, u8SlvVolt, u8SlvSta, max_temp; // slave PDP, slave voltage, slave plug state,
bit bSlv_PPSReqFirst, bMas_PPSReqFirst;
WORD root_timer, I2C_broketimer;
bit bI2cMstBusy;
bit bI2cMstWdat;
BYTE xdata u8LcalPdpx2 _at_ I2C_MASTER_IDX; // support 0.5W granularity
BYTE xdata u8LcalVolt  _at_ I2C_MASTER_IDX+1;
BYTE xdata u8LcalSta  _at_ I2C_MASTER_IDX+2;

void fwi2c_isr (void) interrupt INT_VECT_I2C
{
    switch (I2CSTA)
    {
    case 0x08: // S transmitted
    case 0x10: // S-r transmitted
        I2CCON = I2CCON & ~0x20; // de-assert START flag
        I2CDAT = (bI2cMstWdat==TRUE) ? (I2C_SLAVE_DEVA<<1)  | 0x01 // read
                 : (I2C_SLAVE_DEVA<<1); // write
        break;
    case 0x18: // SLA+W transmitted, ACK received
        I2CDAT = I2C_MASTER_IDX % 0x80;
        break;
    case 0x28: // data transmitted, ACK received
        if (bI2cMstWdat!=TRUE) {
            I2CDAT = u8SlvPdpx2;
            bI2cMstWdat = TRUE;
        } else {
            I2CCON = I2CCON | 0x20; // transmit S-r
        }
        break;
    case 0x30: // data transmitted, NAK received
        if (bI2cMstWdat!=TRUE) {
            bI2cMstBusy = FALSE;
        } else {
            I2CCON = I2CCON | 0x20; // transmit S-r
        }
        break;
    case 0x40: // SLA+R transmitted, ACK returned
        if (I2CDAT) { // dummy read, start to read
            I2CCON |= 0x04; // set AA
        }
        break;
    case 0x50: // data received, ACK returned
        u8SlvVolt = I2CDAT; // if ACK, slave is ready for driving the next data
        I2CCON &=~0x04; // clear AA
        break;
    case 0x58: // data received, NAK returned
        u8SlvSta = I2CDAT;
    case 0x20: // SLA+W transmitted, NAK received
    case 0x48: // SLA+R transmitted, NAK received
        bI2cMstBusy = FALSE;
        break;
    }
    if (bI2cMstBusy!=TRUE) I2CCON = I2CCON | 0x10; // transmit P
    I2CCON = I2CCON & ~0x08; // update I2CDAT/I2CCON before clearing SI
}

void cca1_sync_start ()
{
    if (bI2cMstBusy!=TRUE && IS_MASTER())
    {
        I2CCON = I2CCON | 0x20; // transmit S
        bI2cMstBusy = TRUE;
        bI2cMstWdat = FALSE;
    }
    else if(++I2C_broketimer > I2C_RELOAD_TIME)
    {
        I2CCON = I2CCON | 0x20; // transmit S
        bI2cMstBusy = TRUE;
        bI2cMstWdat = FALSE;
        I2C_broketimer = 0;
    }
}

void CCA1_MsTick ()
{
    BYTE max = SOURCE_PDP() * 2;

    if (IS_MASTER())
    {
        cca1_sync_start();

#ifdef CFG_CCA1_PPS_PRIOR
        //check PPS first
        if ((u8SlvSta & 0x04) && !(u8LcalSta & 0x01)) //Slave PPS and Master detach
        {
            bSlv_PPSReqFirst = 1;
        }
        if (!(u8SlvSta & 0x04))
        {
            bSlv_PPSReqFirst = 0;
        }
        if (u8LcalSta & 0x04 && !(u8SlvSta & 0x01)) //Master PPS and Slave detach
        {
            bMas_PPSReqFirst = 1;
        }
        if (!(u8LcalSta & 0x04))
        {
            bMas_PPSReqFirst = 0;
        }

        if (bTCAttched && bSlv_PPSReqFirst) //Slave enter PPS mode first
        {
            u8LcalPdpx2 = 15*2;
        }
        else if (u8SlvSta & 0x01 && bMas_PPSReqFirst) //Master enter PPS mode first
        {
            u8SlvPdpx2 = 15*2;
        }
        else
#endif
#ifdef CFG_CCA1_MISMATCH_POWER
            if (u8SlvSta & 0x08) // Slave mismatch
            {
                if (!(u8LcalSta & 0x08))
                {
                    BYTE u8LcalI = ((u8LcalPdpx2/(2 * u8LcalVolt)) >= 3 ) ? 3 : (u8LcalPdpx2/(2 * u8LcalVolt));
                    BYTE u8LcalRealPdpx2 = u8LcalVolt * u8LcalI * 2;
                    if((u8LcalRealPdpx2 + u8SlvPdpx2) < max)
                    {
                        u8SlvPdpx2 = max-u8LcalRealPdpx2;
                        u8LcalPdpx2 = u8LcalRealPdpx2;
                    }
                }
            }
            else if (u8LcalSta & 0x08) // Local mismatch
            {
                if (!(u8SlvSta & 0x08))
                {
                    BYTE u8SlvI = ((u8SlvPdpx2/(2 * u8SlvVolt)) >= 3 ) ? 3 : (u8SlvPdpx2/(2 * u8SlvVolt));
                    BYTE u8SlvRealPdpx2 = u8SlvVolt * u8SlvI * 2;
                    if((u8SlvRealPdpx2 + u8SlvPdpx2) < max)
                    {
                        u8LcalPdpx2 = max - u8SlvRealPdpx2;
                        u8SlvPdpx2 = u8SlvRealPdpx2;
                    }
                }
            }
            else
#endif
                // calc. PDP

                if(bPEBIST_Share) //BIST share mode entry set the max power
                {
                    u8SlvPdpx2 = 0;
                    u8LcalPdpx2 = 0;
                }
                else if (u8SlvSta & 0x01)
                {
                    if (bTAAttched)
                    {
                        if (bTCAttched) {
                            u8SlvPdpx2 = (max - PDP_MINUS_VALUE_X2) / 2;
                            u8LcalPdpx2 = u8SlvPdpx2;
                        } else {
                            u8SlvPdpx2 = max - PDP_MINUS_VALUE_X2;
                        }
                    }
                    else
                    {
                        if (bTCAttched) {
                            u8SlvPdpx2 = max / 2;
                            u8LcalPdpx2 = u8SlvPdpx2;
                        } else {
                            u8SlvPdpx2 = 0; // unlimited
                        }
                    }
                }
                else
                {
                    if (bTAAttched)
                    {
                        if (bTCAttched) {
                            u8LcalPdpx2 = max - PDP_MINUS_VALUE_X2;
                        }
                    }
                    else
                    {
                        if (bTCAttched) {
                            u8LcalPdpx2 = 0; // unlimited
                        }
                    }
                }

        // calc. max voltage, do the root control, mapping from actual case
        max = u8SlvVolt;
        if (u8LcalVolt > max) max = u8LcalVolt;
        //max += 1;
        // GPIO4=0 GPIO3=0 if all detach ; GPIO4=0 GPIO3=1 if attached and Vbusmax<=9
        // GPIO4=1 GPIO3=0 9V < Vbusmax <= 15V ; GPIO4=1 GPIO3=1 15V < Vbusmax
        if(max_temp <= max || ++root_timer > ROOT_DELAY )
        {
            if (!bTAAttched && !bTCAttched && !(u8SlvSta & 0x01))
            {
                P0_5 = 0; //GPIO4
                P0_4 = 0; //GPIO3
            }
            else {
                P0_5 = max > 9; //GPIO4
                P0_4 = max <= 9 || max > 15; //GPIO3
            }
            root_timer = 0;
            max_temp = max;
        }
    }
}

void CCA1_INIT ()
{
    if (IS_MASTER())
    {
        I2CCON = I2CCON | 0xC1; // enable I2C master, 100KHz
//    I2CCON = I2CCON | 0xC2; // enable I2C master, 200KHz
//    I2CCON = I2CCON | 0xC3; // enable I2C master, 375/500KHz
//    GPIO5 |= 0x10; // r_bclk_sel=0/1, 375/500KHz
        ET2 = 0x1; // enable I2C interrupt
    }
    else
    {
        I2CCTL = 0x11 | ((I2C_MASTER_IDX/0x80)<<1); // writable PG0 at 0x80, INC
        I2CDEVA = (I2C_SLAVE_DEVA<<1) | 0x01; // slave device address, HWI2C stay enabled
    }
    u8LcalPdpx2 = 0; // initial local PDP
    u8LcalVolt  = 5; // 5V
    u8LcalSta  = 0; // initial local plug state
    root_timer = 0;
    max_temp = 0;
    I2C_broketimer = 0;
    GPIO34 = 0x44;
}

#endif // CFG_CCA1
