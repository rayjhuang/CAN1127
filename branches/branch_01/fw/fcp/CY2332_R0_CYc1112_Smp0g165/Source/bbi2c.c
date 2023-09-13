
#include "global.h"

#ifdef CFG_BBI2C

BYTE u8_i2cmst_deva,
     u8_i2cmst_wcnt, // 0/0xFF: write/read
     u8_i2cmst_addr,
     u8_i2cmst_dat0,
     u8_i2cmst_dat1;

bit b_i2cmst_busy;

void fwi2c_isr (void) interrupt INT_VECT_I2C
{
    switch (I2CSTA)
    {
    case 0x08: // S transmitted
    case 0x10: // S-r transmitted
        I2CCON = I2CCON & ~0x20; // de-assert START flag
        I2CDAT = u8_i2cmst_deva;
        break;
    case 0x18: // SLA+W transmitted, ACK received
        I2CDAT = u8_i2cmst_addr;
        break;
    case 0x28: // data transmitted, ACK received
        u8_i2cmst_wcnt++;
        if (u8_i2cmst_wcnt==1) {
            I2CDAT = u8_i2cmst_dat0;
        } else if (u8_i2cmst_wcnt==2) {
            I2CDAT = u8_i2cmst_dat1;
        } else if (u8_i2cmst_wcnt==3) {
            I2CCON = I2CCON | 0x10; // transmit P
            b_i2cmst_busy = 0;
        } else { // start to read
            I2CCON = I2CCON | 0x20; // transmit S-r
            u8_i2cmst_deva |= 0x01; // read;
        }
        break;
    case 0x30: // data transmitted, NAK received
        I2CCON = I2CCON | 0x10; // transmit P
        b_i2cmst_busy = 0;
        break;
    case 0x40: // SLA+R transmitted, ACK returned
        if (I2CDAT) { // dummy read, start to read
            I2CCON |= 0x04; // set AA
        }
        break;
    case 0x50: // data received, ACK returned
        u8_i2cmst_dat0 = I2CDAT; // if ACK, slave is ready for driving the next data
        I2CCON &=~0x04; // clear AA
        break;
    case 0x58: // data received, NAK returned
        u8_i2cmst_dat1 = I2CDAT;
    case 0x20: // SLA+W transmitted, NAK received
    case 0x48: // SLA+R transmitted, NAK received
        I2CCON = I2CCON | 0x10; // transmit P
        b_i2cmst_busy = 0;
        break;
    }
    I2CCON = I2CCON & ~0x08; // update I2CDAT/I2CCON before clearing SI
}

#define I2C_SLAVE_DEVA 0x3B
#define REG_ADDR_CONTROL       0x00
#define REG_ADDR_CHGCURLIMT    0x01
#define REG_ADDR_OUTSYSVOLT    0x02
#define REG_ADDR_UVP_THRESHOLD 0x03
#define REG_ADDR_CURLIMTMAX    0x07
#define REG_ADDR_CMDREG        0xEE
//#define REG_ADDR_INTRMASK      0xF0
#define REG_ADDR_STATUS        0xFF

enum {
    BBI2C_INIT_RESUME_I2C,
    BBI2C_INIT_RESET,
    BBI2C_INIT_CONTROL,
    BBI2C_INIT_CURLIMTMAX,
    BBI2C_INIT_UVP,
    BBI2C_IDLE,
    BBI2C_W_RESET,
    BBI2C_W_CONTROL,
    BBI2C_W_CURLIMTMAX,
    BBI2C_W_UVP,
    BBI2C_SYNC_W_V,
    BBI2C_SYNC_W_I,
    BBI2C_SYNC_R
// BBI2C_SYNC_W_V_THEN_UNDER,
// BBI2C_SYNC_W_UNDER_THEN_V,
// BBI2C_SYNC_W_INTB
} u8_bbi2c_state;

void bbi2c_sync_start ()
{
    u8_i2cmst_wcnt = (u8_bbi2c_state==BBI2C_SYNC_R) ? 0xFF : 0;
    u8_i2cmst_deva = (I2C_SLAVE_DEVA<<1); // start on write
    I2CCON = I2CCON | 0x20; // transmit S
    b_i2cmst_busy = 1;
}

WORD u16_mst_voltage; // the voltage reuqested by the master
WORD u16_bb_voltage;  // the voltage sent to the bulk-boost

WORD u16_mst_current; // the current reuqested by the master
WORD u16_bb_current;  // the current sent to the bulk-boost

WORD u16_mst_currentmax;
WORD u16_mst_control;
BYTE u8_uvp;
BYTE u8_bb_status; // [4]: power-good
BYTE u8_initdelay;

//BYTE uvp_debnc;
//WORD u16_mst_intb;
//bit intb;

void bbi2c_preset_v ()
{
    u8_i2cmst_dat0 = u16_mst_voltage;
    u8_i2cmst_dat1 = u16_mst_voltage >> 8;
    u8_i2cmst_addr = REG_ADDR_OUTSYSVOLT;
}

/*void bbi2c_preset_uvp ()
{
   uvp = bDevSta_PPSReq ? 0x1F : u16_mst_voltage * 8 / 100; // 80% UVP
   u8_i2cmst_dat0 = 0; // OVP threshold, don't use
   u8_i2cmst_dat1 = uvp;
   u8_i2cmst_addr = REG_ADDR_UVP_THRESHOLD;
}
*/
void bbi2c_tick ()
{
    if (b_i2cmst_busy==FALSE)
    {
        switch (u8_bbi2c_state)
        {
        case BBI2C_INIT_RESUME_I2C:
            if (!(P0_1 && P0_0)) // SCL or SDA low
            {
                if (P0_0) // SCL high
                {
                    GPIOSL |=  0x02; // SCL becomes GPIO1
                    P0_0 = 0; // SCL goes low
                }
                else
                {
                    P0_0 = 1; // SCL goes high
                    GPIOSL &= ~0x07; // resume SCL
                }
            }
            else
            {
                u8_bbi2c_state = BBI2C_INIT_RESET;
            }
            break;

        case BBI2C_INIT_RESET:
         if (u8_initdelay != 5)
         {
            u8_initdelay++;
            u8_bbi2c_state = BBI2C_INIT_RESET;
         }
         else
         {
            u8_bbi2c_state = BBI2C_W_RESET;
            u8_i2cmst_dat0 = 0x80;
            u8_i2cmst_dat1 = 0;
            u8_i2cmst_addr = REG_ADDR_CMDREG;
            bbi2c_sync_start ();
         }
            break;

        case BBI2C_INIT_CONTROL:      //set protect mode hiccup
            u16_mst_control = 0x4046;  //hiccup
            u8_bbi2c_state = BBI2C_W_CONTROL;
            u8_i2cmst_dat0 = u16_mst_control;
            u8_i2cmst_dat1 = u16_mst_control >> 8;
            u8_i2cmst_addr = REG_ADDR_CONTROL;
            bbi2c_sync_start ();
            break;

        case BBI2C_INIT_CURLIMTMAX:   //set currentmax to 5A
            u16_mst_currentmax = 0xF000;
            u8_bbi2c_state = BBI2C_W_CURLIMTMAX;
            u8_i2cmst_dat0 = u16_mst_currentmax;
            u8_i2cmst_dat1 = u16_mst_currentmax >> 8;
            u8_i2cmst_addr = REG_ADDR_CURLIMTMAX;
            bbi2c_sync_start ();
            break;

        case BBI2C_INIT_UVP:
            u8_uvp = 0x1E ;
            u8_bbi2c_state = BBI2C_W_UVP;
            u8_i2cmst_dat0 = 0; // OVP threshold, 6576 don't use
            u8_i2cmst_dat1 = u8_uvp;
            u8_i2cmst_addr = REG_ADDR_UVP_THRESHOLD;
            bbi2c_sync_start ();
            break;

        case BBI2C_IDLE:
            u16_mst_voltage = u16BBI2CPwrV * 2;
            u16_mst_current = IS_OCP_EN() ? (WORD)GET_PWR_I() * 2 *11 :(WORD)GET_PWR_I() * 2 *10;
            // if fixed OCP110% else PPS CC100%

            if (u16_mst_current!=u16_bb_current)
            {
                u8_bbi2c_state = BBI2C_SYNC_W_I;
                u8_i2cmst_dat0 = u16_mst_current;
                u8_i2cmst_dat1 = u16_mst_current >> 8;
                u8_i2cmst_addr = REG_ADDR_CHGCURLIMT;
                bbi2c_sync_start ();
            }
            /*else if ((u16_mst_voltage!=u16_bb_voltage) && (s8VoltStep<=0)) //UVP
            {
               if (IS_OPTION_UVP())
               {
               u8_bbi2c_state = BBI2C_SYNC_W_UNDER_THEN_V;
               bbi2c_preset_uvp ();
               bbi2c_sync_start ();
               }
               else
               {
               u8_bbi2c_state = BBI2C_SYNC_W_V;
               bbi2c_preset_v ();
               bbi2c_sync_start ();
               }
            }
            else if ((u16_mst_voltage!=u16_bb_voltage) && (s8VoltStep >0))
            {
               if (IS_OPTION_UVP())
               {
               u8_bbi2c_state = BBI2C_SYNC_W_V_THEN_UNDER;
               }
               else
               {
               u8_bbi2c_state = BBI2C_SYNC_W_V;
               }
               bbi2c_preset_v ();
               bbi2c_sync_start ();
            }*/ //UVP
            else if (u16_mst_voltage!=u16_bb_voltage)
            {
                u8_bbi2c_state = BBI2C_SYNC_W_V;
                bbi2c_preset_v ();
                bbi2c_sync_start ();
            }
            else // polling
            {
                u8_bbi2c_state = BBI2C_SYNC_R;
                u8_i2cmst_addr = REG_ADDR_STATUS;
                bbi2c_sync_start ();
            }
            break;
        /*case BBI2C_SYNC_W_V_THEN_UNDER:      //UVP
           if (uvp_debnc!=5)
           {
              uvp_debnc++;
              u8_bbi2c_state = BBI2C_SYNC_W_V_THEN_UNDER;
           }
           else
           {
              u8_bbi2c_state = BBI2C_SYNC_W_V;
              bbi2c_preset_uvp ();
              bbi2c_sync_start ();
              uvp_debnc=0;
           }
           break;
        case BBI2C_SYNC_W_UNDER_THEN_V:
           u8_bbi2c_state = BBI2C_SYNC_W_V;
           bbi2c_preset_v ();
           bbi2c_sync_start ();
    break;*/    //UVP
        case BBI2C_W_RESET:
            u8_bbi2c_state = BBI2C_INIT_CONTROL;
            break;
        case BBI2C_W_CONTROL:
            u8_bbi2c_state = BBI2C_INIT_CURLIMTMAX;
            break;
        case BBI2C_W_CURLIMTMAX:
            u8_bbi2c_state = BBI2C_INIT_UVP;
            break;
        case BBI2C_W_UVP:
            u8_bbi2c_state = BBI2C_IDLE;
            break;
        case BBI2C_SYNC_W_V:
            u16_bb_voltage = u16_mst_voltage;
            u8_bbi2c_state = BBI2C_IDLE;
            break;
        case BBI2C_SYNC_W_I:
            u16_bb_current = u16_mst_current;
            u8_bbi2c_state = BBI2C_IDLE;
            break;
        case BBI2C_SYNC_R:
            u8_bb_status = u8_i2cmst_dat1;
            u8_bbi2c_state = BBI2C_IDLE;
            break;
        }
    }
}

void bbi2c_init ()
{
    {
        I2CCON = I2CCON | 0xC1; // enable I2C master, 100KHz
//    I2CCON = I2CCON | 0xC2; // enable I2C master, 200KHz
//    I2CCON = I2CCON | 0xC3; // enable I2C master, 375/500KHz
//    GPIO5 |= 0x10; // r_bclk_sel=0/1, 375/500KHz
        ET2 = 0x1; // enable I2C interrupt
        (GPIO34_OUTPUT_MODE());
    }
}

#endif // CFG_BBI2C
