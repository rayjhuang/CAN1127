#include "global.h"

#ifdef CFG_DIGITAL_CC

WORD PWRV_Value;
bit bCCFlag; // D:0x2A.6 for simulation

BYTE u8OcpDbncTimer;
bit bCcLoopLmt; // CC loop is active

#ifdef CFG_SIM
#define T_OCP_DEBNC 3
#else
#define T_OCP_DEBNC 15
#endif

#define LOW_PWR_V 2800/20

void SetPwrV (WORD v)
{
// if (v < LOW_PWR_V) v = LOW_PWR_V; // if FW bug
    PWRV_Value = v;
    if (!bCCFlag // set PWR_V right after SET_CV_MODE()
            || !bCcLoopLmt) SET_PWR_V(v);
}

TRUE_FALSE DigitalCC_CLVAL ()
{
    WORD temp = GET_PWR_V();
    if (!bProCLimit)
    {
        temp += PWRV_Value/20;
    }
    return  PWRV_Value > temp;
}

void DigitalCC_MsTick ()
{
    if (!bCCFlag
            || IS_OCPVAL()) // set 'bCcLoopLmt' immediately at OCP=1
    {
        bCcLoopLmt = bCCFlag;
        u8OcpDbncTimer = 0;
    }
    else if (bCcLoopLmt) // if OCP=0, start the debounce to clear 'bCcLoopLmt'
    {
        if (u8OcpDbncTimer)
        {
            if (!--u8OcpDbncTimer)
            {
                bCcLoopLmt = 0;
            }
        }
        else
        {
            u8OcpDbncTimer = T_OCP_DEBNC;
        }
    }

    if (bCCFlag)
    {
        WORD temp = GET_PWR_V();
        if (IS_OCPVAL())
        {
//       if (temp > LOW_PWR_V)
            temp -= 1;
        }
        else
        {
            if (temp < PWRV_Value)
                temp += 1;
        }
        SET_PWR_V(temp);
    }
}

#endif
