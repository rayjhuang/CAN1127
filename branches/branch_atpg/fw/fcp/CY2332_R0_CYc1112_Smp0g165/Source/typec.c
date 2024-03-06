
#include "global.h"

volatile BYTE bdata u8CcStaCur _at_ 0x21;
sbit bCc1Sta0     = u8CcStaCur^0;
sbit bCc1Sta1     = u8CcStaCur^1;
sbit bCc1Sta2     = u8CcStaCur^2;
sbit bCc2Sta0     = u8CcStaCur^4;
sbit bCc2Sta1     = u8CcStaCur^5;
sbit bCc2Sta2     = u8CcStaCur^6;

volatile BYTE bdata u8TypeCBits _at_ 0x22;
sbit bTCAttched   = u8TypeCBits^0;
sbit bTCSleep     = u8TypeCBits^1; // to switch TIMER0 as well
sbit bTCCcDbnc    = u8TypeCBits^2;
sbit bTCRaDtcd    = u8TypeCBits^3; // Ra detected, 20180907

volatile WORD u16TCTimer _at_ 0x1E; // 0x1F, for sleep timer

volatile BYTE u8CcThresholdHi;
volatile BYTE u8CcThresholdLo;

#ifdef PD_ENABLE
BYTE u8TypeC_PWR_I; // for setting PWR_I

void SetSnkTxOK()
{
    SET_RP_VAL(2);
    u8CcThresholdHi = DAC1_CC_2V6>>2;
    u8CcThresholdLo = DAC1_CC_0V8>>2;
}

void SetSnkTxNG()
{
    SET_RP_VAL(1);
    u8CcThresholdHi = DAC1_CC_1V6>>2;
    u8CcThresholdLo = DAC1_CC_0V4>>2;
}

void TypeCResetRp ()
{
    BYTE RpSel = GET_OPTION_RP();
    if (RpSel==2)
    {
        SetSnkTxOK();
        u8TypeC_PWR_I = 60; // 3.0A
    }
    else if (RpSel==1)
    {
        SetSnkTxNG();
        u8TypeC_PWR_I = 30; // 1.5A
    }
    else
    {
        u8CcThresholdHi = DAC1_CC_1V6>>2;
        u8CcThresholdLo = DAC1_CC_0V2>>2;
        SET_RP_VAL(0);
        u8TypeC_PWR_I = 10; // 0.5A
    }
    u8TypeC_PWR_I = 44;// 2.2A for SCP 60; // 3.0A
}

BYTE CcVolt2CcSta (BYTE CcVol)
{
    return
        (CcVol >= u8CcThresholdHi) ? 0x04 :
        (CcVol >= u8CcThresholdLo) ? 0x02 : 0x01;
}

void TypeCCcDetectSleep () // also for timer0 ISR in SLEEP
{
    BYTE u8CcStaPri = u8CcStaCur; // save the prior status of CC1/2

    if (bTCAttched)
    {
        u8CcStaCur = (IS_FLIP())
                     ? (u8CcStaCur&0x0F) | ((REVID&0x80) ? CcVolt2CcSta(DACV7)<<4 : 0x20)  // update CC2
                     : (u8CcStaCur&0xF0) | ((REVID&0x80) ? CcVolt2CcSta(DACV6)    : 0x02); // update CC1
    }
    else
    {
        u8CcStaCur = CcVolt2CcSta(DACV6)     // CC1
                     | CcVolt2CcSta(DACV7)<<4; // CC2
    }
    if (u8CcStaCur != u8CcStaPri) // CC changed
    {
        if (bTCSleep && IS_TO_ATTACH()) // wake-up when one Rd detected in SLEEP
        {
            STOP_TMR0();
            STOP_DAC1COMP();
#if defined(CFG_SLEEP_3V6) && !defined(CAN1112B1X)
            CaliSetPwrV (MAP_PDO1_DAC()); // don't wanna this appears in HAL
#else
            CLR_SLEEP_3V6();
#endif
            SET_ANALOG_OSC_LOW(0);
            SET_ANALOG_SLEEP(0);
            SET_ANALOG_CC_PROT(1); // 20180723
//       SET_ANALOG_DIS_STOP_CV(0); // 20180725
            INIT_ANALOG_PK_SET_NTC(TUNE_CCTRX()); // resume NTC current source
            ENABLE_CURSNS(); // 20180904
            START_DAC1COMP_5US_LOOP(); // 60T/12KHz = 5us
            STRT_ONE_MS_TMR();
            bTCSleep = 0;
        }
        if (!bTCSleep) // start debounce timer if awake or awaked
        {
            if (bTCAttched)
            {
                u16TCTimer = T_PD_DEBOUNCE; // re-start PD debounce
            }
            else
            {
                u16TCTimer = T_CC_DEBOUNCE; // re-start CC debounce
                bTCCcDbnc = 1;
            }
        }
    }
}
#define IS_TO_DETACH() (IS_FLIP() ? bCc2Sta2 : bCc1Sta2) // 20180608
#define IS_TO_ATTACH() (bCc2Sta1 ^ bCc1Sta1)
#else
#define IS_TO_DETACH() 0 // 20180608
#define IS_TO_ATTACH() 1
#endif


#if defined(CFG_DYNPDP) || defined(CFG_TWOPORT) || !defined(PD_ENABLE)// no sleep mode in these applications
#define Count2Sleep()
#else
void Count2Sleep ()
{
    if (IS_OPTION_SLPEN() && u8StatePE!=PE_SRC_Error_Recovery)
    {
        u16TCTimer = T_CC_SLEEP; // start sleep timer if becomes detached
    }
}
#endif

void TypeCCcDetectOneMs ()
{
// DP_DEBUG_OUT(bTCAttched);
// DM_DEBUG_OUT(u8CcStaCur & 2);
    TypeCCcDetectSleep();
   
#ifdef PD_ENABLE

    if (u16TCTimer && !--u16TCTimer) // timeout
    {
        if (bTCAttched)
        {
            if (IS_TO_DETACH() || u8StatePE==PE_SRC_Error_Recovery)
            {
                CCA1_TYPC_DETACH();
                bTCAttched = 0;
                bTCRaDtcd = 0;
                ADD_CC_CHANNELS();
                Count2Sleep(); // start sleep timer if becomes detached
            }
        }
        else if (bTCCcDbnc)
        {
            bTCCcDbnc = 0;
            if (IS_TO_ATTACH())
            {
                CCA1_TYPC_ATTACH();
                bTCAttched = 1;
                bTCRaDtcd = bCc1Sta0 | bCc2Sta0; // 20180907
                (bCc1Sta1) ? NON_FLIP() : SET_FLIP();
                DES_VCONN_CHANNEL();
            }
            else
            {
                Count2Sleep(); // start sleep timer if stay detached
            }
        }
        else // goto sleep
        {
            bTCSleep = 1;
            StopOVP();
            STOP_ONE_MS_TMR();
            STOP_DAC1COMP();
            DISABLE_CURSNS(); // 20180904
            TURN_OFF_NTC_TO_SLEEP(); // 20181031
//       SET_ANALOG_DIS_STOP_CV(1); // 20180725
            SET_ANALOG_CC_PROT(0); // 20180723
            SET_SLEEP_3V6();
            SET_ANALOG_SLEEP(1);
            SET_ANALOG_OSC_LOW(1);
            START_DAC1COMP_SLEEP(); // 12T/100KHz = 120us
            STRT_TMR0(TIMEOUT_SLP);
        }
    }
#else
    bTCAttched = 1;
#endif
}
