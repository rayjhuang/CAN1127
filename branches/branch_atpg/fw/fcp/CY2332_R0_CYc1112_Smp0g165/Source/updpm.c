
#include "global.h"

extern bit bPdoGot7;

BYTE u8NumSrcPdo;
//BYTE xdata SRC_PDO[7][4] _at_ 0x040;
WORD xdata PDO_V_DAC[7]  _at_ 0x060;
BYTE xdata OPTION_REG[4] _at_ 0x070;

BYTE u8RDOPositionMinus;

volatile BYTE bdata u8PMStaBits _at_ 0x23;
sbit bDevSta_SndHR   = u8PMStaBits^0; // to send Hard Reset
sbit bDevSta_ChkCbl  = u8PMStaBits^2; // turn-on when Ra found and not CAPTI, turn-off if VCONN fail or cable checked
sbit bDevSta_5ACap   = u8PMStaBits^3; // device is allowed to exceed 3A
sbit bDevSta_LgStep  = u8PMStaBits^4; // PPS large step transition
#ifdef CFG_PPS
sbit bDevSta_PPSReq  = u8PMStaBits^5; // prior Request is PPS one
sbit bDevSta_PPSRdy  = u8PMStaBits^6; // to change voltage stepping behavior
#endif

BYTE bdata u8PMExBits _at_ 0x28;
#if defined(CFG_REDUCE_SZ) || !defined(PD_ENABLE)
#else
void Start2ndNego ()
{
    SET_PMEXTRA_2NDNEGO(); // use this bit for tracking if the 2nd nego. done
    CLR_PMEXTRA_PDOOPT();
    u8StatePM = PM_STATE_ATTACHED; // give PM back to PE_SRC_Transition_Supply
    Go_PE_SRC_Send_Capabilities();
}
sbit bPMExtra_DrSwp     = u8PMExBits^0;
sbit bPMExtra_PdoOpt    = u8PMExBits^1;
sbit bPMExtra_2ndNego   = u8PMExBits^2;
#endif
sbit bPMExtra_LetTxOK   = u8PMExBits^3;
sbit bPMExtra_TpNego    = u8PMExBits^4;
sbit bPMExtra_DpdpNego  = u8PMExBits^5;

PM_STATE_BYTE u8StatePM _at_ 0x14;

volatile WORD u16PMTimer _at_ 0x1A; // 0x1B, for tSrcRecover
volatile BYTE u8DischgTimer; // for discharge

#ifdef PD_ENABLE
TRUE_FALSE IsCable5ACapable ()
{
    return
        (// bPrlRcvd && // DiscoverID responded, but bPrlRcvd was reset
            (is_rxsvdm(0x41,1) // Discover Identity ACK-ed
             && (RxHdr&0xF01F)==0x500F // VDM with NDO=5
             && (RxData[16]&0x60)==0x40)) // current 5A
        ? TRUE
        : 
    FALSE;
}
#endif

TRUE_FALSE IsPwrGood ()
{
// GPIO_DEBUG_ASSERT();
#ifdef CFG_FPGA
    return TRUE; // DAC0 and DAC1 resolution mismatch in FPGA
#else
    WORD diff = u16Target20mV / (TUNE_PWR_GOOD() ?15 :9); // 4.5~6.7%, 8.6~11.1%
    if ((WORD)u8VinVal*4+2 >= u16Target20mV - diff &&
            (WORD)u8VinVal*4+2 <= u16Target20mV + diff)
    {
        return (IS_BBI2C_PWRGD() ? TRUE : FALSE);
    }
    else
    {
        return FALSE;
    }
#endif
}

#ifdef PD_ENABLE
void Try_VCONN_ON ()
{
    BYTE tmp1,tmp2;
    tmp1 = N_VCONN_TURN_ON;
    SET_VCONN_ON();
    while (tmp1--) // try to turn on VCONN repeatedly
    {
      tmp2 = 50; while (tmp2--); // delay ~30us for CAN1112
        CLR_V5OCPSTA(); // if VCONN is gated by current/prior turnung on, it is turned on again here
    }
}
#else
#define Try_VCONN_ON()
#endif

void PolicyManagerReset ()
{
    bTmr0_Step = 0; // if in transition, stop it, 20181023
    TypeCResetRp(); // restore Rp for attach/detach detection

    // CC_ENB=0 as power-on value means in CC when power-on
    // don't set CC_ENB=1 if OptionTable(CC)
    DisableConstCurrent();

// CFG_DIGITAL_CC: set PWR_V/I after 'DisableConstCurrent()'

    PwrTransInit (0); // set u16Target20mV/u8Target50mA, s8VoltStep...
    u16Trans20mV = u16Target20mV;
    CaliSetPwrV (u16Trans20mV);

    u8Trans50mA = u8TypeC_PWR_I; // the correct u8Trans50mA is u8TypeC_PWR_I but u8Target50mA
    CaliSetPwrI (u8Trans50mA); // 20180716, depend on 'bCCFlag'

    u8PMExBits = 0; // not yet SinkTxOK
// bPMExtra_LetTxOK = 0; // not yet SinkTxOK
// bPMExtra_2ndNego = 0; // not yet 2ndNego

    INI_PMEXTRA_PDOOPT(); // bit assignment works
    INI_PMEXTRA_DRSWP();
    AppleDatExReset ();
    DYNPDP_RESET ();
}

// =============================================================================
// state machine
void Go_PM_STATE_SEND_HR ()
{
    u8StatePM = PM_STATE_ATTACHED_SEND_HR;
    bDevSta_SndHR = 1;
    bEventPE = 1;
}

void Go_PM_STATE_DETACHING ()
{
    SAVE_PWR_STATUS(); // note: VBUS of Type-C may be turned-off in ISR if OVP/SCP
    u8StatePM = PM_STATE_DETACHING_MIN;
    u8DischgTimer = T_DETACH_DISCHG_MIN; // (N+1)-ms discharge at least
    StopOVP();
    SET_VBUS_OFF();
    SET_TYPA_VBUS_OFF();
    TYPA_RE_ATTACH();
    PolicyManagerReset();
    if (u8StatePE == PE_SRC_Transition_to_default ||
#ifdef CFG_KPOS0
            u8StatePE == PE_SRC_Hard_Reset)
    {
        u16PMTimer = T_SRC_RECOVER; // start tSrcRecover from VBUS off
    }
    else if(u8StatePE == PE_SRC_Error_Recovery)
    {
        u16PMTimer = T_ERR_RECOVER;
#else
            u8StatePE == PE_SRC_Hard_Reset ||
            u8StatePE == PE_SRC_Error_Recovery)
    {
        u16PMTimer = T_SRC_RECOVER; // start tSrcRecover from VBUS off
#endif
    }
    DISCHARGE_TYPC_DETCH(); // to discharge VBUS
    DISCHARGE_TYPA_DETCH();
}

// after receiving a Hard Reset and T_PS_HARD_RESET
// after sending a Hard Reset and T_PS_HARD_RESET (PE error, fault-to-HR)
// detached
// fault-to-off
void Go_PM_STATE_DISCHARGE_SKIP () // discharge VIN or skip (go DETACHING)
{
#ifdef PD_ENABLE
    if (IS_VCONN_ON())
    {
        (IS_VCONN_ON1()) ? SET_RP1_OFF() : SET_RP2_OFF();
        SET_VCONN_OFF();
        TOGGLE_FLIP();
        SET_DRV0_ON(); // VCONN discharge starts
    }
#endif
    // ===== codes before VBUS-off to earn more VCONN discharging period =====
    u8StatePM = PM_STATE_DISCHARGE;
    STOP_TMR0(); // if (bTmr0_Step), stop it

#ifndef CAN1112BX
    bTmr0_Cnti = 0; // QC3 of CAN1110X/CAN1112AX may occupy timer 0
#endif

#ifdef PD_ENABLE
    if (u8StatePE == PE_SRC_Hard_Reset_Received ||
            u8StatePE == PE_SRC_Hard_Reset) // PE is waiting in T_PS_HARD_RESET
    {   // u8PETimer is to be reset, so push PE a state ahead
        u8StatePE = PE_SRC_Transition_to_default;
    }
#endif
    PolicyEngineReset(FALSE); // 20180809, tSrcRecover will fail if don't care bTCAttched

    u8PMStaBits = 0; // clear PPS/PM status
#ifdef CFG_BBI2C
    Go_PM_STATE_DETACHING ();
#else
    PwrTransInit (0); // set u16Target20mV/u8Target50mA, s8VoltStep...
    u8Trans50mA = u8Target50mA; // let PWR_I not stepping and need not set PWR_I
#ifndef CFG_STEP_BACK_SLOW
    s8VoltStep *= 2;
#endif
    (s8VoltStep >= 0 || bProF2Off) // don't voltage stepping
    ? Go_PM_STATE_DETACHING()
    : PwrTransStart();
#endif
    // ===== codes before VBUS-off to earn more VCONN discharging period =====
#ifdef PD_ENABLE
    if (IS_DRV0_ON())
    {
        SET_DRV0_OFF(); // VCONN discharge ends
        TOGGLE_FLIP();
        SET_RP_ON();
    }
#endif
}

void PolicyManagerOneMs ()
{
    bit bPMTimeout = (u16PMTimer && !--u16PMTimer);

    switch (u8StatePM)
    {
#ifdef CFG_TWOPORT // additional PM_STATEs
    case PM_STATE_TYPA_ONLY: // Type-A stay 5V
        if (!bTAAttched || bProF2Hr || bProF2Off)
        {
            if (bTAAttched) Go_PE_SRC_Error_Recovery();
            Go_PM_STATE_DISCHARGE_SKIP();
        }
        else if (bTCAttched) // from Type-A (DCP) goes Type-C
        {
            u8StatePM = PM_STATE_ATTACHING;
        }
        else if (bQcSta_InQC || bQcSta_Vooc)
        {
            u8StatePE = PE_SRC_Disabled;
            u8StatePM = PM_STATE_ATTACHED;
        }
        break;
    case PM_STATE_DISCHARGE_VBUS_A:
        if (bPMTimeout)
        {
            DISCHARGE_TYPEA_OFF();
            Go_PE_SRC_Send_Capabilities ();
            u8StatePM = PM_STATE_ATTACHED;
        }
        break;
#endif

    case PM_STATE_DETACHED:
        if (ANY_ATTACHED())
        {
            u8StatePE = PE_SRC_Startup;
            u8StatePM = PM_STATE_ATTACHING;
            ADD_VBUS_PG_CHANNELS();
            ReloadPdoTable (RELOAD_MAX_PDO6()); // takes long!!
            NEGO2ND_INIT_NPDO();
            ResumeOVP();
        }
#ifdef CFG_TWOPORT
        if (!bTCAttched && !bLatchTypa)
        {
            SET_TYPA_VBUS_ON();
        }
#endif
        break;
    case PM_STATE_ATTACHING:
        if (!ANY_ATTACHED())
        {
            u8StatePM = PM_STATE_DETACHED;
        }
        else if (IsPwrGood() &&
                 !(bProF2Hr || bProF2Off) // wait for those FAULT disappeared
                 AND_NOT_OVP_LATCHED())
        {
            if (bTCAttched) // wait for those FAULT disappeared
            {   // bDevSta_5ACap may have been set before the fault
#ifdef PD_ENABLE
                if (IS_OPTION_CAPT())
                {
                    bDevSta_5ACap = 1;
                }
                else if (bTCRaDtcd) // 20180907
                {
                    Try_VCONN_ON ();
                    bDevSta_ChkCbl = 1; // to attempt Discover Id.
                }
#endif
                if (u8StatePE == PE_SRC_Transition_to_default) bEventPE = 1; // start NoResponseTimer
                u16PMTimer = PM_TIMER_VBUSON_DELAY; // power good to Source_Capabilities delay
                CLR_F2OFFSTA(); // clear SCP/OVP status
#ifdef CFG_TWOPORT
#ifndef CFG_DYNTWOPORT
                if (!bTAAttched)
#endif
                {
                    SET_TYPA_VBUS_OFF();
                }
#endif
                SET_VBUS_ON();
                u8StatePM = PM_STATE_PWRGOOD;
            }
            TwoPort_TypaTurnOnVBUS ();
        }
        break;
    case PM_STATE_PWRGOOD: // delay after power good (VBUS-on)
        if (!ANY_ATTACHED() || bProF2Hr || bProF2Off) // don't check IsPwrGood() once VBUS on
        {
            if (bTCAttched) Go_PE_SRC_Error_Recovery();
            Go_PM_STATE_DISCHARGE_SKIP();
        }
        else if (bPMTimeout)
        {
            PolicyEngineReset(TRUE);
            bEventPE = 1;
            u8StatePM = PM_STATE_ATTACHED;
        }
#ifdef CFG_TWOPORT
        else if (bTypaAttChg)
        {
            TwoPort_TypaTurnOnVBUS ();
        }
#endif
        break;
    case PM_STATE_ATTACHED:
    case PM_STATE_ATTACHED_AMS1:
    case PM_STATE_ATTACHED_WAIT_CAP:
    case PM_STATE_ATTACHED_TRANS_PRE:   // tSrcTransition
    case PM_STATE_ATTACHED_TRANS:       // stepping
    case PM_STATE_ATTACHED_TRANS_DISCHG:
    case PM_STATE_ATTACHED_TRANS_PWRGD: // wait for PwrGood
    case PM_STATE_ATTACHED_TRANS_PST:   // delay
    case PM_STATE_ATTACHED_CC_TRANS:
    case PM_STATE_ATTACHED_TRANS_LOW_DISCHG: // lower discharging power
        if (TYPC_TO_DETACH()) // to detach (or re-attach)
        {
            Go_PM_STATE_DISCHARGE_SKIP();
            PRE_TYPA_RE_ATTACH();
        }
        else if (bProF2Off || bProF2Hr)
        {
            TWOPORT_LATCH_TYPA(); // depend on bTAAttched, which may be reset in Go_PM_STATE_DETACHING()
            if (bProF2Off ||
                    bProF2Hr && !bPESta_CONN)
            {
                Go_PE_SRC_Error_Recovery();
                Go_PM_STATE_DISCHARGE_SKIP(); // refers to PE_SRC_Error_Recovery in PM_STATE_DETACHING
            }
            else // if (bProF2Hr) // && bPESta_CONN
            {
                Go_PM_STATE_SEND_HR();
            }
        }
        else // from PE/QC
        {
            switch (u8StatePE)
            {
            case PE_SRC_Transition_to_default: // PE error (protocol)
                Go_PM_STATE_DISCHARGE_SKIP();
                break;
#ifdef PD_ENABLE
            case PE_VCS_Turn_On_VCONN:
                switch (u8StatePM)
                {
                case PM_STATE_ATTACHED:
                    u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                    u16PMTimer = PM_TIMER_VCONNON; // start VCONN-ON delay
                    Try_VCONN_ON ();
                    break;
                case PM_STATE_ATTACHED_TRANS_PST:
                    if (bPMTimeout)
                    {
                        u8StatePM = PM_STATE_ATTACHED;
                        bEventPE = 1;
                    }
                    break;
                }
                break;
#endif

#ifdef CFG_TWOPORT
            case PE_SRC_Discovery: // Type-C, not yet PD connected
                TwoPort_TypaTurnOnVBUS ();
                break;
#endif

            case PE_SRC_Disabled: // QC2/QC3/SCP
                switch (u8StatePM)
                {
                case PM_STATE_ATTACHED_TRANS:
                    if (!bTmr0_Step)
                    {
//                u16PMTimer = 2;
                        DISCHARGE_QC_OFF();
                        u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                    }
                    break;
                case PM_STATE_ATTACHED_TRANS_PST:
                    ResumeOVP();
                    SCP_DischBIST();
                    u8StatePM = PM_STATE_ATTACHED;
                    break;
                }
                break;
#ifdef PD_ENABLE
            case PE_SRC_Transition_Supply:
                switch (u8StatePM)
                {
                case PM_STATE_ATTACHED:
                    if (bDevSta_PPSReq & bDevSta_PPSRdy) // 20180713, Fri.
                    {
                        CLR_ANALOG_CABLE_COMP();         // disable cable comp before pps transfer voltage
                        PwrTransStart ();
                        u16PMTimer = bDevSta_LgStep
                                     ? PM_TIMER_LARGE_STEP : PM_TIMER_SMALL_STEP;
                        u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                    }
                    else // FIXED-FIXED
                    {   // FIXED-PPS, PPS-FIXED
                        u16PMTimer = T_SRC_TRANSITION; // start tSrcTransition
                        u8StatePM = PM_STATE_ATTACHED_TRANS_PRE;
                    }
                    break;
                case PM_STATE_ATTACHED_TRANS_PRE:
                    if (bPMTimeout)
                    {
                        if (!IS_OCP_EN()) // optioned CC, PS_RDY by a constant delay
                        {   // so is PPS-FIXED
                            u16PMTimer = PM_TIMER_CC_TRANSITION; // must longer than stepping
                        }                                       // the longest stepping PWR_V/PWR_I may be transit 15V/2A
                        u8StatePM = PM_STATE_ATTACHED_TRANS; // always do transition, 20180712
                        PwrTransStart ();
                    }
                    break;
                case PM_STATE_ATTACHED_TRANS: // change PDO or not, with voltage transition or not
                    if (s8VoltStep==0) // no voltage stepping (FIXED, thus no current stepping either)
                    {
                        u16PMTimer = PM_TIMER_PWRGD_DELAY_N;
                        u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                    }
                    else if (!bTmr0_Step) // power-stepping done
                    {
//                if (IS_OPTION_CCUR()) // optioned CC mode transition, 20180417
                        if (!IS_OCP_EN())     // optioned CC mode transition, 20180906
                        {   // so is PPS-FIXED
                            u8StatePM = PM_STATE_ATTACHED_CC_TRANS;
                        }
                        else
                        {
                            u16PMTimer = PM_TIMER_PWRGD_TIMEOUT;
                            u8StatePM = PM_STATE_ATTACHED_TRANS_PWRGD; // in-CC transition??
                        }
                    }
                    break;
                case PM_STATE_ATTACHED_TRANS_PWRGD: // Power Good detected (timeout won't entry)
                    if (bPMTimeout) // PwrGood timer (PM_TIMER_PWRGD_TIMEOUT) timeout
                    {
                        ResumeOVP();
                    }
                    if (IsPwrGood())
                    {
                        if (IS_DISCHARGE())
                        {
                            u8StatePM = PM_STATE_ATTACHED_TRANS_DISCHG;
                            u16PMTimer = PM_TIMER_DISCHG_DELAY;
                        }
                        else
                        {
                            u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                            u16PMTimer = PM_TIMER_PWRGD_DELAY_R;
                        }
                    }
                    break;
                case PM_STATE_ATTACHED_TRANS_DISCHG:
                    if (bPMTimeout)
                    {
                        DISCHARGE_OFF();
                        u16PMTimer = PM_TIMER_PWRGD_DELAY_F;
                        u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                    }
                    break;
                case PM_STATE_ATTACHED_CC_TRANS:
                case PM_STATE_ATTACHED_TRANS_LOW_DISCHG:
                    if (bPMTimeout)
                    {
                        DISCHARGE_OFF(); // turn-off may cause an accedental OVP in CAN1112B1, 20190712
                        u16PMTimer = PM_TIMER_PWRGD_DELAY_F;
                        u8StatePM = PM_STATE_ATTACHED_TRANS_PST;
                    }
                    else if (u8StatePM==PM_STATE_ATTACHED_CC_TRANS)
                    {
                        if (IS_DISCHARGE() // only for in-CC transition (PPS-FIXED, optioned CC mode)
                                && !(bDevSta_PPSReq && bDevSta_PPSRdy)) // PPS-PPS: DISCHARGE_OFF() when stepping done
                        {
                            DISCHARGE_OFF();
                            u8StatePM = PM_STATE_ATTACHED_TRANS_LOW_DISCHG;
                        }
                    }
                    else // PM_STATE_ATTACHED_TRANS_LOW_DISCHG
                    {
                        DISCHARGE_TYPC_TRANS();
                        u8StatePM = PM_STATE_ATTACHED_CC_TRANS;
                    }
                    break;
                case PM_STATE_ATTACHED_TRANS_PST:
                    if (bPMTimeout)
                    {
                        if (bDevSta_PPSReq)
                        {
                            SET_CC_MODE();
                        }
                        else
                        {
                            DisableConstCurrent();
                        }
                        ResumeOVP(); // 20180906 moved from the above else {}
                        bEventPE = 1;
                        u8StatePM = PM_STATE_ATTACHED;
                    }
                    break;
                }
                break;
            case PE_SRC_Wait_New_Capabilities:
                if (u8StatePM == PM_STATE_ATTACHED_WAIT_CAP)
                {
                    if (bPMTimeout)
                    {
                        u8StatePM = PM_STATE_ATTACHED;
                        bEventPE = 1;
                    }
                }
                else
                {
                    u16PMTimer = PM_TIMER_WAIT_CAP;
                    u8StatePM = PM_STATE_ATTACHED_WAIT_CAP;
                }
                break;
            case PE_SRC_Startup: // from PE_SRC_VDM_Identity_Request
                if (IsCable5ACapable())
                    bDevSta_5ACap = 1;
//             ModifyPDO3A(); // 20180606
                bDevSta_ChkCbl = 0; // cable checked
                bEventPE = 1;
                break;
            case PE_SRC_Ready: // once an explicit contract or an AMS end
                if (0)
                    ;

                else if (bPMExtra_PdoOpt | bPMExtra_2ndNego)
                    switch (u8StatePM)
                    {
                    case PM_STATE_ATTACHED:
                        if (bPMExtra_2ndNego)
                        {
                            CLR_PMEXTRA_2NDNEGO();
                            if (u8PEAmsState!=AMS_RSP_RCVD) // Request received -> Accept sent -> PS_Rdy sent
                                // Request received -> Reject sent
                                SET_PMEXTRA_PDOOPT(); // redo the 2nd nego
                        }
                        else
                        {
                            ReloadPdoTable (RELOAD_MAX_PDO6()); // recover the original PDOs
#ifdef CFG_PDO1_ONLY
                            if (bPdoGot7)
                            {
                                u8StatePM = PM_STATE_ATTACHED_AMS1;
                                AMS_Start (PE_INIT_PORT_VDM_Identity_Request);
                            }
#else // APDO-excluded
                            if (u8RDOPositionMinus!=0) // start the 2nd nego. only if PDO1 requested
                            {
                                CLR_PMEXTRA_PDOOPT();
                            }
#endif
                            else
                            {
                                Start2ndNego ();
                            }
                        }
                        break;
#ifdef CFG_PDO1_ONLY
                    case PM_STATE_ATTACHED_AMS1:
                        switch (u8PEAmsState)
                        {
                        case AMS_RSP_VDM:
                            if (is_rxsvdm_ack_discid_apple())
                            {
                                u8NumSrcPdo = 2;
                                MEM_COPY_X2X(SRC_PDO[1],SRC_PDO[6],4);
                                PDO_V_DAC[1] = PDO_V_DAC[1] & 0xF000
                                               | PDO_V_DAC[6] & 0x0FFF;
                            }
//                   to be continued
                        case AMS_SND_TIMEOUT: // nothing received
                            Start2ndNego ();
                            break;
//                case AMS_CRC_TIMEOUT:  // interrupted during sending, not sent
//                case AMS_SINK_TX_TIME: // interrupted before sending
//                case AMS_RSP_RCVD:     // interrupted
                        default:
                            u8StatePM = PM_STATE_ATTACHED; // redo later
                            break;
                        }
                        break;
#endif
                    }

                else if (bPMExtra_DrSwp) // to run in UFP mode
                    switch (u8StatePM)
                    {
                    case PM_STATE_ATTACHED:
                        if (bPESta_DFP)
                        {
                            AMS_Start (PE_DRS_Send_Swap);
                            u8StatePM = PM_STATE_ATTACHED_AMS1;
                        }
                        else // only issue DR_Swap in DFP mode
                        {
                            CLR_PMEXTRA_DRSWP();
                        }
                        break;
                    case PM_STATE_ATTACHED_AMS1:
                        // if DR_Swap is not well responded (no GoodCRC or SenderResponseTimer timeout)
                        // ignore it 'cause some devices don't work fine, 20180603
                        if (u8PEAmsState==AMS_RSP_ACCEPT ||
                                u8PEAmsState==AMS_RSP_REJECT ||
                                u8PEAmsState==AMS_SND_TIMEOUT)
                        {
                            CLR_PMEXTRA_DRSWP();
                        }
                        u8StatePM = PM_STATE_ATTACHED; // redo later if bPMExtra_DrSwp==1
                        break;
                    }

                TWOPORT_CHANGE_PROC()
                APPLE_DATEX_PROC

                else if (!bPMExtra_LetTxOK && !bPESta_PD2)
                {
                    bPMExtra_LetTxOK = 1; // "let SinkTxOK" has done
                    SetSnkTxOK();
                }

#ifdef PD_ENABLE
                else if (bProCLChg) // only PPSRdy would happen
                    switch (u8StatePM)
                    {
                    case PM_STATE_ATTACHED:
                        AMS_Start (PE_SRC_Send_Source_Alert);
                        u8StatePM = PM_STATE_ATTACHED_AMS1;
                        break;
                    case PM_STATE_ATTACHED_AMS1:
                        if (u8PEAmsState==AMS_CMD_SENT)
                        {
                            CLR_PRO_CL_CHG();
                        }
                        u8StatePM = PM_STATE_ATTACHED; // redo later if bProCLChg==1
                        break;
                    }
#endif
                break;
#endif
            }
        }
        break;
#ifdef PD_ENABLE
    case PM_STATE_ATTACHED_SEND_HR:
        if (~bTCAttched // detach during tPSHardReset, 20180601
                || u8StatePE == PE_SRC_Transition_to_default) // tPSHardReset
        {
            Go_PM_STATE_DISCHARGE_SKIP();
        }
        break;
#endif
    case PM_STATE_DISCHARGE: // from transition
        if (!bTmr0_Step)
        {
            Go_PM_STATE_DETACHING();
        }
        break;
    case PM_STATE_DETACHING_MIN:
        if (!u8DischgTimer--)
        {
            u8StatePM = PM_STATE_DETACHING;
            u8DischgTimer = T_DETACH_DISCHG_MAX;
        }
        break;
    case PM_STATE_DETACHING: // discharge VBUS
      if (CaliADC(DACV1) <= (DAC1_VSAFE_0V_MAX>>2)-3 // VSafe_0V_Max
// VIN/VBUS detected '0' during the begining of discharging
//        DACV1 >  (DAC1_VSAFE_0V_MAX>>2>>1) ||) // u8DischgTimer==0, u8DischgTimer -> -1
           )
        {
            DISCHARGE_OFF();
            DISCHARGE_TYPEA_OFF();
            DES_VBUS_PG_CHANNELS();
            bEventPE = 0; // if PE decide to issue Source_Cap/DiscoverID, cancel it
            CLR_PRO_CL_CHG(); // if OP condition changed (CL), cancel it
            bProCLimit = 0;
            switch (u8StatePE)
            {
            case PE_SRC_Error_Recovery: // T_SRC_RECOVER should be set at entering DETACHING
                SET_RP_OFF();
                INC_ERR_RECOVERY_COUNTER();
            case PE_SRC_Transition_to_default:
                u8StatePM = PM_STATE_RECOVER;
                if (!u16PMTimer) u16PMTimer = 10;
                break;
            default:
                u8StatePM = PM_STATE_DETACHED;
                break;
            }
        }
      else if (u8DischgTimer && !--u8DischgTimer) // discharge maximum time
        {
            DISCHARGE_OFF();
            DISCHARGE_TYPEA_OFF();
        }
        break;
    case PM_STATE_RECOVER: // tSrcRecover
        if (bPMTimeout)
        {
            bEventPE = 1;
            u8StatePM = PM_STATE_DETACHED;
        }
        break;
    }
}
