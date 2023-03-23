
#include "global.h"

#ifdef CFG_TWOPORT

#ifdef CFG_SIM
#define T_TP_ATT_DEBOUNCE  3
#define T_TP_DET_DEBOUNCE  7
#else
#define T_TP_ATT_DEBOUNCE  5
#define T_TP_DET_DEBOUNCE  2000
#endif

#ifdef TYPA_DETACH_2S
idata WORD uXXAttTimer;
#else
BYTE uXXAttTimer;
#endif

bit bTAAttched;
bit bTypaAttChg;
bit bLatchTypa; // latch Type-A (VBUS off) if OCP when both port attached
                // release it once Type-A detached

bit TwoPort_ReAttach ()
{
    return ((!bTCAttched && !bTAAttched && IS_TYPA_VBUS_ON()) // Type-A only (QC) to detach
            || (!bTCAttched && IS_VBUS_ON())  // also re-start Type-A (DCP)
            ||  (bTCAttched && bQcSta_InQC)); // Type-A in QC, to detach to restart Type-A
}

#ifndef CFG_DYNTWOPORT
void ModifyPDO2A4 ()
{
    SRC_PDO[0][0]  = 0xF0; // 2400mA
    SRC_PDO[0][1] &= 0xFC;
    u8NumSrcPdo = 1;
}
#endif

void TwoPort_TypaTurnOnVBUS ()
{   // in PM_STATE_ATTACHING, or PE_SRC_Discovery
    bTypaAttChg = 0; // clear those dummy (Type-A changes not in Type-C PD)
    if (bTAAttched && !bLatchTypa)
    {
        if (bTCAttched)
        {
#ifndef CFG_DYNTWOPORT
            ModifyPDO2A4 ();
            CaliSetPwrI (TWOPORT_MAX_PWR_I);
            SET_TYPA_VBUS_ON(); // turn-on VBUS after updating PWR_I (simulation patterns)
#endif
        }
        else
        {
            u8StatePM = PM_STATE_TYPA_ONLY;
        }
    }
}

#ifdef TYPA_ATTACH_BCQC
#define DAC1_DPDMLO_TAATTACH_MIN (41)  // 0.325V
#define TYPA_ATTACH_CONDITION() GET_TYPA_ATT() || bTCAttched==0 && (DAC1_DPDMLO_TAATTACH_MIN < CaliADC(DACV4)) && bQcSta_InQC==1 || !bTCAttched && bQcSta_Vooc
#else
#define TYPA_ATTACH_CONDITION() GET_TYPA_ATT()
#endif

void TwoPort_AttDetOneMs ()
{
    bit bSigSav = TYPA_ATTACH_CONDITION();

    if (bTAAttched==bSigSav)
    {
        if (uXXAttTimer)
        {
            uXXAttTimer = 0;
            if (!bTAAttched) bLatchTypa = 0; // bTAAttched may be reset by FW (normally by attaching signal)
        }
    }
    else
    {
        if (uXXAttTimer)
        {
            if (!--uXXAttTimer)
            {
                bTypaAttChg = 1; // start a Type-A plug/unplug task
                bTAAttched = ~bTAAttched;
                if (!bTAAttched) bLatchTypa = 0; // don't clear it during Type-A forced-re-attach
            }
        }
        else
        {
#ifdef TYPA_DETACH_2S
            if (bSigSav==0)
                uXXAttTimer = T_TP_DET_DEBOUNCE;
            else
#endif
                uXXAttTimer = T_TP_ATT_DEBOUNCE;
        }
    }
}

void TwoPort_ChgProc () // PE_SRC_Ready & PM_STATE_ATTACHED /ms
{
    bTypaAttChg = 0;
    if (bTAAttched)
        switch (u8StatePM)
        {
        case PM_STATE_ATTACHED:
            if (bPMExtra_TpNego)
            {
                bPMExtra_TpNego = 0;
                if (u8PEAmsState==AMS_RSP_RCVD) // Request received -> Accept sent -> PS_Rdy sent
                {
                    if (bPESta_Rejt) // Request received -> Reject sent
                    {
                        Go_PM_STATE_SEND_HR();
                    }
                    else
                    {
#ifndef CFG_DYNTWOPORT
                        CaliSetPwrI (TWOPORT_MAX_PWR_I);
                        SET_TYPA_VBUS_ON();
#endif
                    }
                }
                else
                {
                    bTypaAttChg = 1; // redo later
                }
            }
            else
            {
#ifndef CFG_DYNTWOPORT
                ModifyPDO2A4 ();
                Go_PE_SRC_Send_Capabilities();
                bPMExtra_TpNego = 1; // use this bit for tracking if the 2nd nego. done
                // keep PM_STATE_ATTACHED for PE_SRC_Transition_Supply
#endif
            }
            break;
        }
    else if (IS_TYPA_VBUS_ON()) // Type-A VBUS may have been off because of Type-A latched
    {
        SET_TYPA_VBUS_OFF();
        DISCHARGE_TYPEA_ENA();
        u8StatePM = PM_STATE_DISCHARGE_VBUS_A; // start Srouce_Caps there
        u16PMTimer = T_DETACH_DISCHG_MIN;
        ReloadPdoTable (RELOAD_MAX_PDO6());
    }
}

#endif // CFG_TWOPORT
