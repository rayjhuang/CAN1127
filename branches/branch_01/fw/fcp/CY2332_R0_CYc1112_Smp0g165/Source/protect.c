
#include "global.h"

volatile BYTE bdata u8ProBits _at_ 0x25;
sbit btOTPSig     = u8ProBits^0; // OTP signal
sbit bPro2HrSig   = u8ProBits^1; // 'OR' those protect signals of Hard Reset
sbit bPro2OffSig  = u8ProBits^2; // 'OR' those protect signals of Error Recovery
sbit bProCLSig    = u8ProBits^3; // sampled CL signal
sbit bProF2Hr     = u8ProBits^4; // protect-to-Hard_Reset
sbit bProF2Off    = u8ProBits^5; // protect-to-Error_Recovery
sbit bProCLimit   = u8ProBits^6; // CL status
#ifdef CFG_PPS
sbit bProCLChg    = u8ProBits^7; // CL status changed
#endif


#ifdef SCP_ENABLE
extern BYTE u8ScpReg03;
extern BYTE u8ScpReg28;
extern BYTE u8ScpRegA3;
#endif
volatile BYTE u8Fault2OffTimer;
volatile BYTE u8Fault2HrTimer;
volatile BYTE u8CLimitTimer _at_ 0x13;

OVP_LATCH_INST


void IsrProtect() interrupt INT_VECT_SRC
{
    if (IS_F2OFFSTA()) // V5OCP don't cause fault-to-off, 20180710
    {
        u8Fault2OffTimer = T_F2OFF_DEBNC;
        bPro2OffSig = 0;
        bProF2Off = 1;

        if(IS_SCPVAL()) SET_OVPINT(0);
        OVP_LATCH_SET();

#ifdef SCP_ENABLE
        if(IS_OVPVAL())
        {
            u8ScpRegA3 |= 0x02;  // SCP OV
            u8ScpReg28 |= 0x04;
        }
#endif
        SET_VBUS_OFF();
        CLR_F2OFFSTA(); // clear SCP/OVP status
    }
}

void ResumeOVP ()
{
    if (IS_OPTION_OVP()) {
        if (!IS_OVPVAL()) CLR_OVPSTA();
        SET_OVPINT(1);
    }
}

void SrcProtectInit ()
{
    CLR_F2OFFSTA(); // clear SCP/OVP status
    if (IS_OPTION_OVP() || IS_OPTION_SCP())
    {
        if (IS_OPTION_SCP()) SET_SCPINT(1);
//    if (IS_OPTION_OVP()) SET_OVPINT(1);
        ResumeOVP();
        u8Fault2OffTimer = 1; // or, if SCP/OVP kept high since power-on, VBUS stays off
        EX6 = 1; // enable protection interrupt
    }
    ADD_TS_CHANNEL();
}

void SrcProtectOneMs ()
{
    bit bProSigSav; // save last state at first
    bit bProSigTmp;

    // Current Limit
    bProSigSav = bProCLSig;
    bProCLSig = IS_CLVAL(); // bit assignment works
    if (bProSigSav==bProCLSig)
    {
        if (u8CLimitTimer && !--u8CLimitTimer)
        {
            if (bProCLimit!=bProCLSig)
            {
                if (bProF2Hr)
                {
                }
                else
                {
                    SET_PRO_CL_CHG(); // set only in PPS, 20181022
                    bProCLimit = bProCLSig;
                    if (u8Fault2HrTimer)
                    {
                        u8Fault2HrTimer = T_F2HR_DEBNC();
                    }
                }
            }
        }
    }
    else
    {
        u8CLimitTimer = T_CURRENT_LIMIT;
    }

    // Fault-to-Hard-Reset
    // Over Temperature Protection
    // Over Current or Low Voltage Boundary
    bProSigSav = bPro2HrSig;
    if (bTmr0_Step)
    {
        bPro2HrSig = 0;
    }
    else
    {
        btOTPSig = IS_OPTION_OTP() && ((btOTPSig && bProF2Hr)
                                       ? (u8TmpVal <= DAC_CODE_OTP_LO()) // 0xFF'd let OTP never recovered
                                       : (u8TmpVal <  DAC_CODE_OTP_HI()));

#ifdef SCP_ENABLE
        if(btOTPSig)
        {
            u8ScpRegA3 |= 0x10;        // SCP OT
            u8ScpReg28 |= 0x01;
        }
#endif
#ifdef CFG_BBI2C
        bPro2HrSig = (IS_OCP_EN() ? IS_BBI2C_CC // in CV mode
                      : IS_UNDER288() && bProCLimit) // in CC mode, add CL on 20180528
                     || btOTPSig;
#else
        bPro2HrSig = (IS_OCP_EN() ? IS_OCPVAL() // in CV mode
                      : IS_UNDER288() && bProCLimit) // in CC mode, add CL on 20180528
                     || btOTPSig;
#endif
    }

// rev.20180321 begin
    if (u8Fault2HrTimer>0)
    {
        if (IS_OCP_EN() && IS_DISCHARGE()) // add discharging condition, rev.20180402
        {   // reset (not disable) the de-bounce in discharging in OCP_EN mode
            u8Fault2HrTimer = T_F2HR_DEBNC();
        }
        else if (bPro2HrSig) // in the active cycle
        {
            if (!--u8Fault2HrTimer)
            {
                bProF2Hr = 1;
            }
        }
        else if (u8Fault2HrTimer>=(IS_OCP_EN() ? T_F2HR_DEBNC() : T_F2HR_2V8))
        {
            u8Fault2HrTimer = 0;
            bProF2Hr = 0;
        }
        else
        {
            u8Fault2HrTimer++;
        }
    }
    else if (bProSigSav!=bPro2HrSig) // to start de-bounce
    {
        u8Fault2HrTimer = 1; // for increasing counting
        if (bPro2HrSig) // in the active cycle
        {
            u8Fault2HrTimer = IS_OCP_EN() ? T_F2HR_DEBNC() : T_F2HR_2V8;
        }
    }
// rev.20180321 end

    // Fault-to-Off
    // Over Voltage Protection
    // Short Circuit Protection
    // Under Voltage Protection (not in PPS)
    bProSigSav  = bPro2OffSig;
//#ifdef CFG_BBI2C
//#else
    bProSigTmp  = IS_OPTION_SCP() && IS_SCPVAL() || IS_OPTION_OVP() && IS_OVPVAL() && OVP_ACTIVE();
    bPro2OffSig =
//               IS_OPTION_UVP() && IS_UVPVAL() && IS_OCP_EN();   // not UVP in CL
                 IS_OPTION_UVP() && IS_UVPVAL() // && bProCLSig
                                 && !(bDevSta_PPSReq | bDevSta_PPSRdy) // not in PPS

#ifdef CFG_KPOS0
        ;
    if(bPro2OffSig)
    {
        bProF2Off = 1;
        bPro2OffSig = 1;
    }
    bPro2OffSig |= bProSigTmp;

#ifdef CAN1112BX
    if(bProDMFualt)
    {
        bProF2Off = 1;
        bPro2OffSig = 1;
        bProDMFualt = 0;
    }
#endif

#else
        || bProSigTmp;
#endif
//#endif

    if (bProSigSav==bPro2OffSig)
    {
        if (u8Fault2OffTimer && !--u8Fault2OffTimer)
        {
            bProF2Off = bPro2OffSig;
        }
    }
    else if (!bProSigTmp || bProF2Off) // only debounce for falling
    {
        u8Fault2OffTimer = T_F2OFF_DEBNC;
    }
    else // in case of OVP/SCP happens before enabled (no interrput)
    {
        bProF2Off = bPro2OffSig;
    }
#ifdef SCP_ENABLE
    if(bPro2OffSig)
    {
        u8ScpRegA3 |= 0x01;   // SCP UV
        u8ScpReg28 |= 0x08;
    }
#endif
}
