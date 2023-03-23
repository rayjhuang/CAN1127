/*
// =============================================================================
// add APPLE/DCP/QC2/QC3 functions into CY2211S_V100 PD20 firmware
// 2017/11/16 Ray Huang
// 2018/07/10 Ray Huang
//            copy from cy2311r2, rename some macros

1. in timer1 ISR, call to QcOneMs()
   a. maintain debounce counter (u8DpDmDbCnt), D+/D- status (u8DpDmVal)
         0: <DAC1_DPDMLO
         1: DAC1_DPDMLO<?<DAC1_DPDMHI
         2: >DAC1_DPDMHI
      if (u8DpDmVal changed)
         reset (re-start) u8DpDmDbCnt
         update u8DpDmVal
      else (u8DpDmDbCnt enabled && not saturation)
         u8DpDmDbCnt++;
   b. maintain QCSTA
      if (u8DpDmDbCnt == expire_value && change QCSTA)
         goto next state
2. add event 'bEventPM' for voltage stepping

// ALL Rights Are Reserved
// =============================================================================
*/
#include "global.h"

#ifdef CFG_SIM
#define tAppleToDcp     3
#define tDcpToDmGnd     4 // 3ms x6
#define tDmGndToQC20    3
#define tQC20GoTrans    4
#define tQC30ToQC20     6
#define tQC30Mulcn      5 // x tQC30Multi in !CAN1112BX
#define tQcDetach       4
#else
#define tAppleToDcp     3   // 2ms
#define tDcpToDmGnd     210 // 1.0~1.5s (T_GLITCH_BC_DONE, 210ms x5)
#define tDmGndToQC20    3   // 3ms
#define tQC20GoTrans    30  // 20~60ms (T_GLITCH_MODE_CHANGE)
#define tQC30ToQC20     25  // 25ms
#define tQC30Mulcn      25  // 25ms
#define tQcDetach       11
#endif

#ifndef CAN1112BX // only for CAN1112AX/CAN1110X

// for supporting 200us D+/D- pulse needs higher ADC rate
// it causes ADC accuracy problem raised
#ifdef CFG_TWOPORT // this CAN1110 cannot pass QC3 compliance test
   #define QC30_400US
#else // basic application (1C), CFG_DYNPDP and others
   #define QC30_240US // cannot pass QC3 compliance test
// #define QC30_192US // only for QC3 compliance test, CLUVP failed in QC3
#endif

#ifdef QC30_400US // > 200
   #define tQC30Pulse 2 // 200us/ADC
   #define tQC30Multi 8 // ~= 1ms/loop
   #define TIMEOUT_CNTI (200-13) // 200us ISR
   #define SET_FASTER_ADC_RATE() (DACEN = 0xF2) // CC1/CC2 channels effected by D- channel, so don't be faster
   #define RESUME_ADC_RATE()
#endif

#ifdef QC30_240US // >120
   #define tQC30Pulse 2 // 120us/ADC
   #define tQC30Multi 11 // ~= 1ms/loop
   #define TIMEOUT_CNTI (120-14) // 120us ISR
   #define SET_FASTER_ADC_RATE() (DACEN = 0x32) // DP/DN/VBUS for IS_UNDER288()
   #define RESUME_ADC_RATE()
#endif

#ifdef QC30_216US // > 144
   #define tQC30Pulse 3 // 72us/ADC
   #define tQC30Multi 18 // ~= 1ms/loop
   #define TIMEOUT_CNTI (72-14) // 72us ISR
   #define SET_FASTER_ADC_RATE() (DACEN = 0x32, STOP_DAC1COMP(), START_DAC1COMP_3US_LOOP())
   #define RESUME_ADC_RATE()                   (STOP_DAC1COMP(), START_DAC1COMP_5US_LOOP())
#endif

#ifdef QC30_192US // > 144
   #define tQC30Pulse 4 // 48us/ADC
   #define tQC30Multi 26 // ~= 1ms/loop
   #define TIMEOUT_CNTI (48-13) // 48us ISR
   #define SET_FASTER_ADC_RATE() (DACEN = 0x32, STOP_DAC1COMP(), START_DAC1COMP_2US_LOOP())
   #define RESUME_ADC_RATE()                   (STOP_DAC1COMP(), START_DAC1COMP_5US_LOOP())
#endif

BYTE u8SavDacEn;
void QC30ToQC20_Resume ()
{
    u8QcSta = QCSTA_QC20_5V;
    STOP_TMR0(); // disable timer0 ISR
    bTmr0_Cnti = 0;
    RESUME_ADC_RATE();
    DACEN = u8SavDacEn;
}
#endif // !CAN1112BX


// QC3 to QC2 by all valid QC2 modes ///////////////////////////////////////////
//#define EXIT_QC3_ALL

// QC2 to QC3 in all valid QC2 modes ///////////////////////////////////////////
#define ENTER_QC3_ALL // remove QCSTA_QC20_HV
#ifdef ENTER_QC3_ALL
   #define ENTER_QC3_CONDITION() (u8DpDmVal==0x21) // 0.325<D+<2.0V and D->2.0V
   #define QC2_CHANGE_TO_HV()
   #define QC2_CHANGE_TO_5V()
#else
   #define ENTER_QC3_CONDITION() (u8DpDmVal==0x21 && u8QcSta==QCSTA_QC20_5V)
   #define QC2_CHANGE_TO_HV()    (u8QcSta = QCSTA_QC20_HV)
   #define QC2_CHANGE_TO_5V()    (u8QcSta = QCSTA_QC20_5V)
#endif


#ifdef CFG_FPGA
#define DAC0_PWRVMIN  36*8 // 3.6V
#define DAC0_PWRVSTP   2*8 // 200mV, step of continuous mode
#else
#define DAC0_PWRVMIN0  180 // 3.6V
#define DAC0_PWRVMIN1  200 // 4.0V
#define DAC0_PWRVMIN2  220 // 4.4V
#define DAC0_PWRVMIN3  250 // 5.0V
#define DAC0_PWRVSTP    10 // 200mV, step of continuous mode
#endif

#define DAC1_DPDMLO     52// 0.424V 41 // 0.325V
#define DAC1_DPDMHI    253 // 2.024V

QCSTA_BYTE u8QcSta _at_ 0x18;

BYTE u8DpDmVal   _at_ 0x0A; // new value
BYTE u8DpDmDbCnt _at_ 0x0B;
BYTE u8DcpCnt    _at_ 0x0C;
char QcCntiStep  _at_ 0x0D; // signed

BYTE u8DPdebc;

#ifdef SCP_ENABLE
extern BYTE u8ScpRegA0;
#endif

BYTE bdata u8QcBits;
sbit bQcSta_InQC  = u8QcBits^0;
sbit bQcOpt_DCP   = u8QcBits^3; // #define OPTION_DCP   0x08
sbit bQcOpt_APPLE = u8QcBits^4; // #define OPTION_APPLE 0x10
sbit bQcOpt_QC    = u8QcBits^5; // #define OPTION_QC    0x20
sbit bQcOpt_PWR   = u8QcBits^6; // 0/1: 18W/27W
sbit bQcSta_Vooc  = u8QcBits^7;
BYTE u8QcVoltMin;

// =============================================================================
// a. initial options of QC
// b. start/return to APPLE/DCP
void QcStartup ()
{
   u8QcBits = OPTION_REG[1] & (OPTION_DCP | OPTION_APPLE | OPTION_QC);
// bQcOpt_QC     = IS_OPTION_QC();
// bQcOpt_DCP    = IS_OPTION_DCP();
// bQcOpt_APPLE  = IS_OPTION_APPLE();
    bQcOpt_PWR    = IS_OPTION_QC_PWR(); // bit assignment works
    switch (GET_OPTION_QCMIN()) // #define OPTION_QCMIN 0x60
    {
      case 0x60: u8QcVoltMin = DAC0_PWRVMIN3; break;
      case 0x40: u8QcVoltMin = DAC0_PWRVMIN2; break;
      case 0x20: u8QcVoltMin = DAC0_PWRVMIN1; break;
      default:   u8QcVoltMin = DAC0_PWRVMIN0; break;
    }
    SET_DPDMOUT_DIS();
    if (bQcOpt_DCP | bQcOpt_APPLE)
    {
        ADD_DPDM_CHANNELS();
        SET_DM_PULLDWN_DIS();
        VIVO_DIS_UART();
        ScpPrlInit();

        if (bQcOpt_APPLE && !TWOPORT_WITHOUT_APPLE())
        {
            u8QcSta = QCSTA_APPLE;
            SET_2V7_ON();
            (bQcOpt_DCP)
            ? SET_DPDM_SHORT_ENA()
            : SET_DPDM_SHORT_DIS();
        } /* Enable Apple mode */
        else
        {
            u8QcSta = QCSTA_DCP;
            SET_DPDM_SHORT_ENA();
            u8DcpCnt = 0;
        } /* Enable DCP mode */

        bQcSta_InQC = 0;
        bQcSta_Vooc = 0;
        u8DpDmDbCnt = 1;
    }
    Vooc_init();
}

// WORD DividerWWW (WORD divdd, WORD divsr)
// {  // 38-byte by C?UIDIVR515, Use On-chip Arithmetic Unit in CAN1112
//    // 85-byte by C?UIDIV
//    return divdd / divsr;
// }

#define QC_MAX_PWR_I 60 // 3.0A
#define QC_SHIFT_PWR_I 2 // 0.1A

#if !defined(SCP_ENABLE) | !defined(CFG_40W)
BYTE QcCalcPwrI ()
{
    BYTE tmp = (bQcOpt_PWR ? 27000 : 18000) / u16Target20mV;
    if (tmp > QC_MAX_PWR_I)
    {
        tmp = QC_MAX_PWR_I;
    }
    tmp += QC_SHIFT_PWR_I; // 20181008
    return tmp;
}
#endif
#ifdef CAN1112BX
#define QC30_TO_QC20_IF_AX()    {}
#define CHK_DP_DETACH_IF_AX()   {}
#define CHK_DP_DETACH_IF_B0()   { if (u8QcSta >= QCSTA_DMGND) QcChkDpDetach(); }

#define DPDM_UPDATE_OPERATING() { UpdateDpDmVal(); }
#define QC_CONTI_CONDITION()    (u8DpDmDbCnt==tQcDetach)
#else // CAN1112AX/CAN1110X
#define QC30_TO_QC20_IF_AX()    { if (u8QcSta==QCSTA_QC30) QC30ToQC20_Resume(); }
#define CHK_DP_DETACH_IF_AX()   { QcChkDpDetach(); }
#define CHK_DP_DETACH_IF_B0()   {}
#define DPDM_UPDATE_OPERATING() { if (u8QcSta!=QCSTA_QC30) UpdateDpDmVal(); }
#define QC_CONTI_CONDITION()    (u8DpDmDbCnt==tQcDetach || bTmr0_Cnti)
#endif
void QcVoltTrans (WORD volx2) // voltage in 20mV
{
    if (u8StatePM==PM_STATE_ATTACHED // power stepping may still not ready (by prior QC2 transition)
            && u8StatePE==PE_SRC_Disabled)  // (by right after entering QC2)
    {
        u16Target20mV = volx2;
#if /*!defined(SCP_ENABLE) | */!defined(CFG_40W)
         SetTarget50mA (bbQcSta_InQC
                       ? QcCalcPwrI ()
                       : u8TypeC_PWR_I); // detach
#else
         SetTarget50mA (44+ISET_OFFSET);             //2.2A
#endif
        SetPwrTransQC ();
    }
    else
    {
        u8DpDmDbCnt = tQC20GoTrans
                      - (tQC20GoTrans>10 ? 5 : 2); // come back 5ms (2ms in CFG_SIM) later
    }
}

void QcChkDpDetach ()
{
    if ((u8DpDmVal & 0x0F)==0x00 && QC_CONTI_CONDITION()
            || !IS_QC_VBUS_ON() // OVP ISR turned off VBUS, 20180913
            || IS_QC_DISABLED_BY_PD())
    {
#ifndef CAN1112BX // only for CAN1112AX/CAN1110X
        if (bTmr0_Cnti)
        {
            QC30ToQC20_Resume(); // (to resume current sense, IFB channel, needs time)
            u8DpDmDbCnt = tQcDetach - 3; // do detachment later
        }
        else
#endif // !CAN1112BX
        {
            Go_QCSTA_IDLE();
            QcVoltTrans(MAP_PDO1_DAC());
            DisableConstCurrent();
        }
    }
}

void UpdateDpDmVal ()
{
    BYTE dacv;
    BYTE prior = u8DpDmVal;
   dacv = CaliADC(DACV4); u8DpDmVal  = (dacv < DAC1_DPDMLO) ? 0 : (dacv > DAC1_DPDMHI) ? 0x02 : 0x01; // D+
#ifndef AFCTEST
   dacv = CaliADC(DACV5); if (dacv >= DAC1_DPDMLO) { u8DpDmVal |= (dacv > DAC1_DPDMHI) ? 0x20 : 0x10; } // D-
#else
   dacv = CaliADC(DACV5); if (dacv >= DAC1_DPDMLO) { u8DpDmVal |= (dacv > DAC1_DPDMHI) ? 0x20 : (CaliADC(DACV5)>175) ? 0x40 :0x10; } // D-
#endif

    if (u8DpDmVal != prior)
    {
      if(u8QcSta==QCSTA_DCP && prior == 0x11 && !u8DPdebc)   // to filter noise on DP while device test DPDM short
      {
         u8DPdebc=3;
      }
       if(u8DPdebc>1)
       {
          u8DpDmVal=prior;
          u8DPdebc--;
       }
       else
       {
#ifdef CAN1112BX
#else // only for CAN1112AX/CAN1110X
// inc/dec voltage after pulse active //////////////////////////////////////////
        if (bTmr0_Cnti)
        {
            if (u8DpDmVal==0x21 && u8DpDmDbCnt >= tQC30Pulse
                    && u8DcpCnt < tQC30Mulcn)
            {
                if (prior==0x22) QcCntiStep += 1;
                if (prior==0x11) QcCntiStep -= 1;
            }
        }
#endif
        {
            u8DpDmDbCnt = 1; // re-start for active pulses
        }
         u8DcpCnt = 0;
         u8DPdebc=0;
     }
    }
    else if (u8DpDmDbCnt > 0 && u8DpDmDbCnt < 255)
    {
      u8DPdebc=0;
      u8DpDmDbCnt++;
    }
}

void Go_QCSTA_IDLE ()
{
    QC30_TO_QC20_IF_AX(); // goes QC2
    DES_DPDM_CHANNELS();
    SET_DPDM_FREE(); // free D+/D-, rev.20180402
    VIVO_DIS_UART();
    ScpPrlInit();
    u8QcSta = QCSTA_IDLE;
}

void QcOneMs ()
{
    if ((IS_QC_VBUS_ON() && !IS_QC_DISABLED_BY_PD())

#ifdef SCP_ENABLE
       || (!(u8ScpRegA0 & 0x80) && (u8ScpRegA0 & 0x40) && u8SCPstate!=0x02) || // not reset and MOS disable and SCP B
          (u8ScpRegA0 & 0x10)     // if D+ protect disable
#endif
       )
    {
        DPDM_UPDATE_OPERATING();
        switch (u8QcSta)
        {
        case QCSTA_IDLE:
#ifdef CFG_KPOS0
            btShortTmr++;
            if(btShortTmr == 10)
            {
                QcStartup();
                ResumeOVP();
                btShortTmr = 0;
            }
            else
            {
                Start_DM_Fault();
            }
#else
            QcStartup();
#endif
            break;

        case QCSTA_APPLE:
            if (u8DpDmDbCnt == tAppleToDcp && bQcOpt_DCP && (u8DpDmVal & 0x0F) < 2)       // D+ < 2V
            {
                u8QcSta = QCSTA_DCP;
                SET_2V7_OFF();
                u8DcpCnt = 0;
                u8DpDmDbCnt = 1;
            } /* D+/D- short if DCP enabled */
            else
            {
                TWOPORT_DISABLE_APPLE(); // not enough power for Type-A 2.4A (APPLE), Type-C 3.0A/2.4A
            }
            break; /* Apple mode */

        case QCSTA_DCP:
            if (u8DpDmDbCnt == tDcpToDmGnd)
            {
#ifdef CFG_SIM
                if (u8DcpCnt < 1)
                {
                    if(u8DcpCnt==0) ScpReginit();   // 2 ms
#else
                if (u8DcpCnt < 4)
                {
                    if(u8DcpCnt==1) ScpReginit();   // 2 ms
#endif
                    u8DcpCnt++;
                    u8DpDmDbCnt = 1;
                }
                else if (u8DpDmVal == 0x11 && bQcOpt_QC && !TWOPORT_WITHOUT_QC())
                {
                    u8QcSta = QCSTA_DMGND;
                    SET_2V7_SHORT_OFF();
                    SET_DM_PULLDWN_ENA();
                } /* D+/D- short */
            }
#ifndef CFG_KPOS0
             if (u8DpDmVal == 0x00 && bQcOpt_APPLE && u8DpDmDbCnt == 100)
             {
                 // D+/D- short
                 // D+/D-=0V after tDcpToDmGnd x6, which means
                 // 1) DpDmDetach
                 // 2) Device doesn't drive D+/D- any more
                 QcStartup();
             }
#endif
#ifdef VOOC_ENABLE
            else if ((u8DpDmDbCnt>=10) && (u8DpDmVal==0x22) && !TWOPORT_WITHOUT_QC())
            {
                vivo_start();
            }//*/
#endif
            break; /* DCP mode */

        case QCSTA_DMGND:
            Start_DM_Fault();
            if (u8DpDmDbCnt == tDmGndToQC20 && u8DpDmVal == 0x01 && !bProDMFualt)
            {
                ScpPrlStart();
                u8QcSta = QCSTA_QC20_5V;
                SET_CC_MODE();
                bQcSta_InQC = 1;
            }
            SET_DM_FAULT_DIS();
            CHK_DP_DETACH_IF_AX();
            break;

        case QCSTA_QC20_5V:
        case QCSTA_QC20_HV:
            if (u8DpDmDbCnt==tQC20GoTrans
#ifdef SCP_ENABLE
                    && !u8SCPstate                    // in SCP
#endif
               )
            {
#ifndef SCP_ENABLE
                if (ENTER_QC3_CONDITION())            //  SCP not support QC3.0 ??
                {
                    u8QcSta = QCSTA_QC30;
#ifdef CAN1112BX
                    ACCCTL |= 0x03; // after pulse
                    QcCntiStep = DPDMACC; // clear the accumulator
#else // CAN1112AX/CAN1110X
                    QcCntiStep = 0; // clear the accumulator
                    u8SavDacEn = DACEN;
                    SET_FASTER_ADC_RATE();
                    bTmr0_Cnti = 1; // enter QCSTA_QC30
                    STRT_TMR0(TIMEOUT_CNTI);
#endif
                }
            else if (u8DpDmVal==0x12) { QcVoltTrans(DAC0_PWRV9V0); QC2_CHANGE_TO_HV(); } //       D+>2.0V and 0.325<D-<2.0V
#else
            if (u8DpDmVal==0x12) { QcVoltTrans(DAC0_PWRV9V0); QC2_CHANGE_TO_HV(); } //       D+>2.0V and 0.325<D-<2.0V
#endif
            else if (u8DpDmVal==0x11) { QcVoltTrans(DAC0_PWRV12V); QC2_CHANGE_TO_HV(); } // 0.325<D+<2.0V and 0.325<D-<2.0V
#ifdef QC2_20V
            else if (u8DpDmVal==0x22) { QcVoltTrans(DAC0_PWRV20V); QC2_CHANGE_TO_HV(); } //       D+>2.0V and       D->2.0V
#endif
            else if (u8DpDmVal==0x01) { QcVoltTrans(MAP_PDO1_DAC()); QC2_CHANGE_TO_5V(); } // 0.325<D+<2.0V and 0.325>D-
            }
#ifdef VOOC_ENABLE
            else if (u8DpDmDbCnt==200)
            {if ((u8DpDmVal==0x22) && !TWOPORT_WITHOUT_QC()) vivo_start();}
#endif

#ifdef AFCTEST
            // detect 100UI and disable the phy for S9
            if ((u8DpDmVal==0x41) && (u8DpDmDbCnt>=14)) {
                ScpPhyInit();
            }
#endif

            CHK_DP_DETACH_IF_AX();
            break;

        case QCSTA_QC30:
#ifndef SCP_ENABLE
#ifdef CAN1112BX
            if (u8DpDmDbCnt==tQC30ToQC20 && (
#ifdef EXIT_QC3_ALL
                        u8DpDmVal==0x12 || // 9V
                        u8DpDmVal==0x11 || // 12V
#ifdef QC2_20V
                        u8DpDmVal==0x22 || // 20V
#endif
#endif
                        u8DpDmVal==0x01)) // 5V, exit QC3
            {
                u8QcSta = QCSTA_QC20_5V;
                u8DpDmDbCnt = tQC20GoTrans - 2; // do QCSTA_QC20_5V 2ms later
            }
            else if (u8StatePM==PM_STATE_ATTACHED)
            {
                QcCntiStep = DPDMACC; // read and clear
                if (QcCntiStep!=0) // && u8DpDmDbCnt < tQC30Mulcn
                {
                    u8DpDmDbCnt = 1; // reset debounce counter
                    QcCntiStep = (QcCntiStep & 0x0F) - ((BYTE)QcCntiStep >> 4); // in [-15,15]
                    while (QcCntiStep>0 && u16Target20mV<QC3_VOLT_MAX)
                    {
                        QcCntiStep--;
                        u16Target20mV += DAC0_PWRVSTP;
                    }
                    while (QcCntiStep<0 && u16Target20mV>u8QcVoltMin)
                    {
                        QcCntiStep++;
                        u16Target20mV -= DAC0_PWRVSTP;
                    }
                    QcVoltTrans(u16Target20mV);
                }
                else if (u8DpDmDbCnt==1)
#else // CAN1112AX/CAN1110X
            {
                if (QcCntiStep!=0)
                {
                    while (QcCntiStep>0)
                    {
                        QcCntiStep--;
                        if (u16Target20mV<QC3_VOLT_MAX)
                        {
                            u16Target20mV += DAC0_PWRVSTP;
                            CaliSetPwrV (u16Target20mV);
                        }
                    }
                    while (QcCntiStep<0)
                    {
                        QcCntiStep++;
                        if (u16Target20mV>u8QcVoltMin)
                        {
                            u16Target20mV -= DAC0_PWRVSTP;
                            StopOVP(); // SET_OVPINT(0); // 20180904
                            CaliSetPwrV (u16Target20mV);
                            DISCHARGE_QC_ENA();
                        }
                    }
                    CaliSetPwrI (QcCalcPwrI()); // 20181009
                }
                else if (!bTmr0_Step) // Port-A detaching may cause VIN step down, in which QcCntiStep=0
#endif
                {
                    DISCHARGE_QC_OFF(); // 1ms discharge, 20181009
                    ResumeOVP(); // 20180904
                }
            }
#endif
            break;
#ifdef VOOC_ENABLE
        case BCSTA_VIVO:

            if (((u8DpDmVal&0x30)==0) && (u8DpDmDbCnt>=50)) {

                Go_QCSTA_IDLE();
                QcVoltTrans(MAP_PDO1_DAC());
                DisableConstCurrent();
                break;
            }
            vivo_prl();
            break;

        case BCSTA_VOOC:
            Vooc_prl();
            break;
#endif
        }
        SCP_TimeOut();
        Average_VolCur();
        CHK_DP_DETACH();
    }
#ifdef SCP_ENABLE
    else if(u8SCPstate==0x02 && bTCAttched && u8StatePE == PE_SRC_Disabled)        // SCP reset delay 1S and enable vbus
    {
        SCP_Reset_Delay();
    }
#endif
    else if (u8QcSta!=QCSTA_IDLE) // to disable QC
    {
        Go_QCSTA_IDLE ();
        QcVoltTrans(MAP_PDO1_DAC());
    }
}

#ifndef CAN1112BX // only for CAN1112AX/CAN1110X
void Qc3AccIsr () // QcTmr0Proc, ISR of timer 0
{
    STRT_TMR0(TIMEOUT_CNTI); // restart asap help accuracy
    UpdateDpDmVal();

// inc/dec voltage in pulse active /////////////////////////////////////////////
//   if (u8DpDmDbCnt==tQC30Pulse)
//   {
//      if (u8DpDmVal==0x22) QcCntiStep += 1;
//      if (u8DpDmVal==0x11) QcCntiStep -= 1;
//   }
//   else
    if (u8DpDmDbCnt==tQC30Multi)
    {
        if (u8DcpCnt < tQC30Mulcn)
        {
            u8DcpCnt++; // u8DcpCnt is temporarily used as the debounce timer high part
            u8DpDmDbCnt = tQC30Pulse + 1; // re-start for u8DcpCnt in QC3
        }
        else // debounce timer timeout
            if ((
#ifdef EXIT_QC3_ALL
                        u8DpDmVal==0x12 || // 9V
                        u8DpDmVal==0x11 || // 12V
#ifdef QC2_20V
                        u8DpDmVal==0x22 || // 20V
#endif
#endif
                        u8DpDmVal==0x01)) // 5V, exit QC3
            {
                u8DpDmDbCnt = tQC20GoTrans - 3; // tell QCSTA_QC20_5V to trans to DAC0_PWRV??
                QC30ToQC20_Resume(); // (to resume current sense needs time)
            }
            else
            {
                QcChkDpDetach();
            }
    }
}
#endif // !CAN1112BX
