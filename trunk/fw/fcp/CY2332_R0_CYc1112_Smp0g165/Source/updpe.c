
#include "global.h"

// =============================================================================
// global variablies
PE_STATE_BYTE u8StatePE _at_ 0x15;

#define PE_STATUS_INIT 0x03 // DFP, VCONN source
volatile BYTE bdata u8PEStaBits _at_ 0x26;
sbit bPESta_DFP   = u8PEStaBits^0; // UFP/DFP, changed at attaching, DR_Swap
sbit bPESta_VCSRC = u8PEStaBits^1; // VCONN source, changed at truning VCONN on, VCONN_Swap
sbit bPESta_CONN  = u8PEStaBits^2; // PD connected
sbit bPESta_EXPL  = u8PEStaBits^3; // Explicit Contract
sbit bPESta_TD    = u8PEStaBits^4; // Test Data BIST
sbit bPESta_Rejt  = u8PEStaBits^5; // nego. rejected
sbit bPESta_PD2   = u8PEStaBits^6; // back to PD2.0
sbit bPESta_SVDM1 = u8PEStaBits^7; // back to SVDM1.0

//volatile WORD u16PETimer _at_ 0x1C; // 0x1D
//volatile BYTE u8PETimer  _at_ 0x19;
//bit bPEBIST_Share ; // BIST share mode entry

BYTE u8HardResetCounter  _at_ 0x56;
#ifdef nCapsCount
BYTE u8CapsCounter;
#define RESET_CAPS_COUNTER() (u8CapsCounter = 0)
#define INC_CAPS_COUNTER() if (!bPESta_EXPL) u8CapsCounter++
#else
#define RESET_CAPS_COUNTER()
#define INC_CAPS_COUNTER()
#endif


#ifdef PD_ENABLE
void PE_Reset_On_Detached ()
{
    RESET_CAPS_COUNTER();
    u8HardResetCounter = 0;
    RST_ERR_RECOVERY_COUNTER();
    u16PETimer = 0; // stop SourcePPSCommTimer, NoResponseTimer
}

void PolicyEngineOneMs ()
{
    if (u8PETimer  && !--u8PETimer)
    {
        bEventPE = 1; // 20180921, keep PE alive sending SourceCap
    }
    if (u16PETimer)
    {
        if (!bTCAttched)
        {
            PE_Reset_On_Detached ();
        }
        else if (!--u16PETimer)
        {
            // SourcePPSCommTimer timeout
            // NoResponseTimer timeout
            bDevSta_SndHR = 1; // 20180603
            bEventPE = 1;
        }
    }
}

void SetNoResponseTimer ()
{
    if (u8HardResetCounter <= nHardResetCount)
    {
        u16PETimer = T_NO_RESPONSE;
    }
}

void Do_PE_DRS_Change ()
{
    bPESta_DFP = !bPESta_DFP;
    if (IS_V5OCPSTA())
    {
        SET_RCV_SOPP(0);
    }
    else
    {
        SET_RCV_SOPP(bPESta_DFP & bPESta_VCSRC & bTCRaDtcd);
    }
}
// =============================================================================
// AMS (send a command and then to wait for responded)

TRUE_FALSE AMS_Cmd_n_Respond ()
{
    switch (u8PEAmsState)
    {
    case AMS_SINK_TX_TIME:
        if (bPrlRcvd)
        {
            u8PETimer = 0; // stop SinkTxTimer
            return TRUE; // ending in AMS_SINK_TX_TIME
        }
        else // SinkTxTimer timeout
        {
            u8PEAmsState = AMS_CMD_SENDING;
            bEventPRLTX = 1;
        }
        break;
    case AMS_CMD_SENDING:
        if (bPrlSent)
        {
            switch (u8StatePE)
            {
            case PE_SRC_Send_Source_Alert:
                u8PEAmsState = AMS_CMD_SENT;
                return TRUE; // to end this AMS
                break;
            default:
                u8PETimer = T_SENDER_RESPONSE; // start SenderResponseTimer
                u8PEAmsState = AMS_RSP_RCVING;
            }
        }
        else
        {
            u8PEAmsState = AMS_CRC_TIMEOUT;
            return TRUE; // to end this AMS
        }
        break;
    case AMS_RSP_RCVING:
        u8PETimer = 0; // stop SenderResponseTimer
        if (bPrlRcvd)
        {
            if (((RxHdr>>8)&0x70)!=0) // Data Message
            {
                switch (RxHdr&0x801F)
                {
                case 0x0F:
                    if ((RxData[0]&0xDF)==0x41 // Discover Identity ACK-ed
                            && (RxData[1]&0x60)< 0x20) // Structured VDM Version < Version 2.0
                        bPESta_SVDM1 = 1;
                    u8PEAmsState = AMS_RSP_VDM;
                    break;
                default:
                    u8PEAmsState = AMS_RSP_RCVD;
                }
            }
            else // Control Message
            {
                switch (RxHdr&0x801F)
                {
                case 3:
                    u8PEAmsState = AMS_RSP_ACCEPT;
                    break;
                case 4:
                    u8PEAmsState = AMS_RSP_REJECT;
                    break;
                default:
                    u8PEAmsState = AMS_RSP_RCVD;
                }
            }
        }
        else
        {
            u8PEAmsState = AMS_SND_TIMEOUT; // SenderResponseTimer timeout
        }
        return TRUE; // to end this AMS
        break;
    }
    return FALSE; // to continie this AMS
}
// ==implicit
//   PE_SRC_VDM_Identity_Request()
//   PE_SRC_Send_Soft_Reset()
// ==explicit
//   PE_DRS_Send_Swap()
//   PE_INIT_PORT_VDM_Identity_Request()
//   PE_SRC_Send_Source_Alert()
// ==depends
//   PE_SRC_Send_Capabilities()
//   1. in implicit nego.
//   2. in explicit nego.
//   3. on receiving a Get_Source_Cap
//   4. on accepting a Soft_Reset
//   5. after sending a Soft_Reset
void AMS_Start (PE_STATE_BYTE NextState)
{
    bPrlSent = 0; // init (not sent yet)
// bPrlRcvd = 0;
// this bit is set by
// 1. a message received (after a GoodCRC returned, updphy.c)
// 2. a received message to interrupt an AMS, do the received (updpe.c)
// is clear by
// 1. a GoodCRC received (for a sent message, updprl.c)
// 2. once used
//    in PE_SRC_Ready
//    in AMS
    if (bPESta_PD2 || // PD2.0
            !bPESta_EXPL ||
            u8StatePE==PE_SRC_Soft_Reset ||
            u8StatePE==PE_SRC_Send_Soft_Reset ||
            NextState==PE_SRC_Send_Soft_Reset) // to send a Soft_Reset
    {
        bEventPRLTX = 1;
        u8PEAmsState = AMS_CMD_SENDING;
    }
    else // PD3.0
    {
        bPMExtra_LetTxOK = 0; // do "let SinkTxOK" after done
        SetSnkTxNG(); // 20180603
        u8PETimer = T_SINK_TX; // start SinkTxTimer
        u8PEAmsState = AMS_SINK_TX_TIME;
    }
    u8StatePE = NextState; // assign a PE state from starting the AMS
}
#endif
AMS_STATE_BYTE u8PEAmsState _at_ 0x12;


// =============================================================================
// state machine
void Go_PE_SRC_Send_Capabilities ()
{
#ifndef ADVERTISE_IN_QC23
#ifndef CFG_DYNTWOPORT              // if dyntwoport won't be into QC
    if (bQcSta_InQC)
    {
        u8StatePE = PE_SRC_Disabled;
        RESET_AUTO_GOODCRC();
//        u16PETimer = 0; // reset NoResponseTimer
    }
    else
#endif
#endif
    {
#if !defined(CFG_DYNTWOPORT) & defined(SCP_ENABLE)                // SCP without PD
        u8StatePE = PE_SRC_Disabled;
        RESET_AUTO_GOODCRC();
//        u16PETimer = 0; // reset NoResponseTimer
#else
      if (u8StatePE==PE_SRC_Send_Soft_Reset) { RESET_CAPS_COUNTER(); }
                                        else { INC_CAPS_COUNTER(); }
        AMS_Start (PE_SRC_Send_Capabilities);      // set u8StatePE first??
        ModifyPDO (); // 20180606
        DynPDP_PwrShare();
#endif
    }
}

#ifdef PD_ENABLE
void Go_PE_SRC_Ready () // 20180921
{
    u8StatePE = PE_SRC_Ready;
    if (bDevSta_PPSRdy)
    {
        u16PETimer = T_PPS_TIMEOUT ; // (re-)start SourcePPSCommTimer
    }
}

void Go_PE_SRC_Send_Soft_Reset ()
{
    PRL_Tx_PHY_Layer_Reset(TRUE);
    AMS_Start (PE_SRC_Send_Soft_Reset);
    u8StatePM = PM_STATE_ATTACHED; // re-nego later
}

void Go_PE_SRC_Hard_Reset ()
{
    u8StatePE = PE_SRC_Hard_Reset;
    u8PETimer = T_PS_HARD_RESET; // start PSHardResetTimer
    u8HardResetCounter++;
    SetNoResponseTimer();
    bEventPRLTX = 1; // send Hard Reset and wait for PSHardResetTimer timeout
}
#else
#define Go_PE_SRC_Hard_Reset()
#endif

void Go_PE_SRC_Error_Recovery ()
{
    bEventPE = 0; // if PE decide to issue Source_Cap/DiscoverID, cancel it
    u8StatePE = PE_SRC_Error_Recovery;
}

//#define PD2_REQ_PPS

#ifdef PD_ENABLE
void Go_PE_SRC_Negotiate_Capability ()
{
// u8StatePE = PE_SRC_Negotiate_Capability;
    BYTE RdoSTA = IsRdoAgreed();

    switch(RdoSTA)
    {
    case 0x02:
        bPESta_Rejt = 0;
        u8StatePE = PE_SRC_Transition_Accept; // to Accept
        break;
    case 0x01:
//#ifdef PD2_REQ_PPS
        Go_PE_SRC_Send_Soft_Reset();   // PD 2.0 but request PPS ,send soft reset
        break;
//#endif
    case 0x00:
        bPESta_Rejt = 1;
        u8StatePE = PE_SRC_Capability_Response; // to Reject
        break;
    }
    bEventPRLTX = 1;
// u16PETimer = bDevSta_PPSReq ? T_PPS_TIMEOUT : 0; // stop/(re-)start SourcePPSCommTimer
}

void PolicyEngineReset (bit bStartup)
{
    bEventPE = 0;
    u8PETimer = 0;
    u8PEAmsState = AMS_CMD_SENDING;
    u8PEStaBits = PE_STATUS_INIT;
    RESET_CAPS_COUNTER();
    PRL_Tx_PHY_Layer_Reset(bStartup);
}
#endif

void PolicyEngineProc ()
{
    bEventPE = 0;

    if (bDevSta_SndHR)
    {
        if (u8StatePrlTx) // busy
        {
            bEventPE = 1; // try again
        }
        else // available
        {
            Go_PE_SRC_Hard_Reset();
            bDevSta_SndHR = 0;
        }
    }
#ifdef PD_ENABLE
    else if (bHrRcvd)
    {
        u8StatePE = PE_SRC_Hard_Reset_Received;
        u8PETimer = T_PS_HARD_RESET;
        SetNoResponseTimer();
        PRL_Tx_PHY_Layer_Reset(FALSE);
    }
#endif
    else
    {
        switch (u8StatePE)
        {
        case PE_SRC_Startup:
            u8PEStaBits = PE_STATUS_INIT;
#ifdef PD_ENABLE
            if (bDevSta_ChkCbl && !IS_V5OCPSTA()) // trun-on VCONN successfully, 20180706
            {
                SET_RCV_SOPP(1); // 20180906
                AMS_Start (PE_SRC_VDM_Identity_Request);
            }
            else
#endif
            {
                Go_PE_SRC_Send_Capabilities();
            }
            break;
        case PE_SRC_Send_Capabilities:
#ifdef PD_ENABLE
            if (AMS_Cmd_n_Respond())
            {
                switch (u8PEAmsState)
                {
                case AMS_RSP_RCVD:
                    if (!bPESta_EXPL)
                    {
                        if ((RxHdr&0x00C0)==0x0080) // SpecRev=PD3.0 in this any received message
                        {
                            SetSnkTxNG();
                        }
                        else // PD2.0
                        {
                            bPESta_PD2 = 1;
                        }
                    }
                    ((RxHdr&0xF01F)==0x1002) // Request
                    ? Go_PE_SRC_Negotiate_Capability()
                    : Go_PE_SRC_Send_Soft_Reset();
                    break;
                case AMS_SND_TIMEOUT: // SenderResponseTimer timeout
                    Go_PE_SRC_Hard_Reset();
                    break;
                case AMS_CRC_TIMEOUT:
#ifdef nCapsCount
                    if (u8CapsCounter >= nCapsCount)
                    {
                        u8StatePE = PE_SRC_Disabled;
                        RESET_AUTO_GOODCRC(); // so that PRLRX won't trigger bEventPE again
                    }
                    else
#endif
                        if(bPESta_CONN)//(bPESta_EXPL) received goodcrc for powerbank
                        {
                            if (bPrlRcvd) // interrupted
                            {
                                bEventPE = 1; // do the rcvd
                                Go_PE_SRC_Ready();
                            }
                            else
                            {
                                Go_PE_SRC_Send_Soft_Reset();
                            }
                        }
                        else
                        {
                            u8StatePE = PE_SRC_Discovery;
                            u8PETimer = T_C_SENDSRCCAP;
                        }
                    break;
                }
            }
            else // GoodCRC received
            {
                RST_ERR_RECOVERY_COUNTER();
                PE_Reset_On_Detached ();
                bPESta_CONN = 1;
            }
#endif
            break;
#ifdef PD_ENABLE
        case PE_SRC_Discovery:
        case PE_SRC_Wait_New_Capabilities:
            bPrlRcvd ? bPESta_CONN ?
            Go_PE_SRC_Send_Soft_Reset()		// soft reset for powerbank
            : Go_PE_SRC_Hard_Reset()
            : Go_PE_SRC_Send_Capabilities();
            break;
        case PE_BIST_Carrier_Mode: // PD_R30V11_6.6.7.2 BISTContModeTimer,
            Go_PE_SRC_Ready(); // return to normal operation
            break;
        case PE_SRC_Capability_Response:
            if (bPESta_EXPL)
            {
                Go_PE_SRC_Ready();
            }
            else
            {
                u8StatePE = PE_SRC_Wait_New_Capabilities;
            }
            break;
        case PE_SRC_Transition_Accept: // sending Accept
            if (bPrlSent) // Accept sent
            {
                u8StatePE = PE_SRC_Transition_Supply;
            }
            else // CRCReceiveTimer timeout, interrputed, busy
            {
                Go_PE_SRC_Hard_Reset();
            }
            break;
        case PE_SRC_Transition_Supply: // wait for transition
            if (bPrlRcvd) // interrputed
            {
                Go_PE_SRC_Hard_Reset();
            }
            else
            {
                u8StatePE = PE_SRC_Transition_PS_RDY;
                bEventPRLTX = 1;
            }
            break;
        case PE_SRC_Transition_PS_RDY: // sending PS_RDY
            if (bPrlSent) // PS_RDY sent
            {
                bPESta_EXPL = 1;
                SET_DEVSTA_PPSRDY();
                Go_PE_SRC_Ready(); // will refer to 'bDevSta_PPSRdy'
            }
            else // CRCReceiveTimer timeout, interrputed, busy
            {
                Go_PE_SRC_Hard_Reset();
            }
            break;
        case PE_VCS_Accept_Swap:
            if (bPrlSent) // Accept sent
            {
                if (bPESta_VCSRC)
                {
                    u8StatePE = PE_VCS_Wait_for_VCONN;
                    u8PETimer = T_VCONN_SOURCE_ON; // start VCONNOnTimer
                }
                else
                {
                    u8StatePE = PE_VCS_Turn_On_VCONN;
                }
            }
            else // CRCReceiveTimer timeout, interrputed, busy
            {
                Go_PE_SRC_Send_Soft_Reset();
            }
            break;
        case PE_VCS_Turn_On_VCONN:
            u8StatePE = PE_VCS_Send_PS_RDY;
            bEventPRLTX = 1;
            bPESta_VCSRC = 1; // becomes VCONN source
            SET_RCV_SOPP(bPESta_DFP && !IS_V5OCPSTA());
            break;
        case PE_VCS_Wait_for_VCONN:
            u8PETimer = 0; // stop VCONNOnTimer
            if (bPrlRcvd && (RxHdr&0xF01F)==6) // PS_RDY
            {
                Go_PE_SRC_Ready();
                SET_VCONN_OFF();
                bPESta_VCSRC = 0; // becomes not VCONN source
                SET_RCV_SOPP(0);
            }
            else // VCONNOnTimer timeout or interrupted
            {
                Go_PE_SRC_Hard_Reset();
            }
            break;
        case PE_SRC_VDM_Identity_Request:
            if (AMS_Cmd_n_Respond())
            {
                PRL_Tx_PHY_Layer_Reset(TRUE); // bPrlRcvd is reset as well
                u8StatePE = PE_SRC_Startup;
            }
            break;
        case PE_DRS_Accept_Swap: // don't response GoodCRC to SOP' as a UFP, (LeCroy USBIFWS#106)
            if (bPrlSent)
            {
                Go_PE_SRC_Ready();
                Do_PE_DRS_Change();
            }
            else
            {
                Go_PE_SRC_Send_Soft_Reset();
            }
            break;
        case PE_SRC_Disabled:
            Go_PE_SRC_Hard_Reset(); // NoResponseTimer timeout
            break;
        case PE_SRC_Soft_Reset:
            (bPrlSent)
            ? Go_PE_SRC_Send_Capabilities()
            : Go_PE_SRC_Hard_Reset();
            break;
        case PE_SRC_Hard_Reset_Received:
        case PE_SRC_Hard_Reset:
            u8StatePE = PE_SRC_Transition_to_default;
            break;
        case PE_SRC_Error_Recovery:
            SET_RP_ON();
            break;
//    case PE_SRC_Transition_to_default:
//       break;
        case PE_SRC_Chunk_Recieved:
            u8StatePE = PE_SRC_Send_Not_Supported;
            bEventPRLTX = 1;
            break;
        case PE_SRC_Give_Source_Cap_Ext:
        case PE_SRC_Give_Source_Status:
        case PE_SRC_Give_PPS_Status:
        case PE_SRC_Send_Not_Supported:
        case PE_SRC_Send_Reject:
        case PE_VCS_Send_PS_RDY:
            (bPrlSent)
            ? Go_PE_SRC_Ready()
            : Go_PE_SRC_Send_Soft_Reset();
            break;
        case PE_RESP_VDM_Send_Identity:
        case PE_RESP_VDM_Get_Identity_NAK: // interruptible
            if (bPrlRcvd) // interrupted
            {
                bEventPE = 1; // do the rcvd
            }
            (bPrlSent | bPrlRcvd)
            ? Go_PE_SRC_Ready()
            : Go_PE_SRC_Send_Soft_Reset(); // this clears bPrlRcvd
            break;
        case PE_SRC_Ready:
#ifdef PD_ENABLE
            u16PETimer = 0; // stop SourcePPSCommTimer, 20180921
            if (bPrlRcvd & ~bPESta_TD)
            {
                u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
                bPrlRcvd = 0;
                if (RxHdr & 0x8000) // Extended Messages
                {
                    if (!bPESta_PD2 && // 20180920
                            (RxData[1] & 0x80) && // chunked
                            ((((WORD)RxData[1]<<8 | RxData[0]) & 0x01FF) > 26)) // Data Size > MaxExtendedMsgLegacyLen
                    {
                        u8StatePE = PE_SRC_Chunk_Recieved;
                        u8PETimer = T_CHUNK_NOT_SUPPORTED;
                    }
                    else // unchunked/multi-chunk in PD3 or unrecognized in PD2, 20180920
                    {
                        u8StatePE = PE_SRC_Send_Not_Supported;
                        bEventPRLTX = 1;
                    }
                }
                else if (RxHdr&0x7000) // Data Messages
                {
                    switch (RxHdr&0x1F)
                    {
                    case 0x02: // Request
                        Go_PE_SRC_Negotiate_Capability();
                        break;
                    case 0x03: // BIST
                        if (u8RDOPositionMinus==0) // VBUS=Vsafe5V
                        {
                            switch (RxData[3])
                            {
                            case 0x50: // Carrier Mode 2
                                u8StatePE = PE_BIST_Carrier_Mode;
                                bEventPRLTX = 1;
                                break;
                            case 0x80: // Test Data
                                bPESta_TD = 1;
                                break;
                            case 0x90: //Shared Test Mode Entry
                                bPEBIST_Share = 1;
                                break;
                            case 0xA0: //Shared Test Mode Exit
                                bPEBIST_Share = 0;
                                break;
                            }
                        }
                        break;
                    case 0x0F: // VDM
                        if (0) ;
                        APPLE_DATEX_ATTENTION
                        CANYON_SEMI_ATTENTION
                        else if (*((WORD*)&RxData[2])==BIG_ENDIAN(SID_STANDARD)
                                 && (RxData[1]&0x80)==0x80) // structured VDM
                        {
                            if (u8NumVDO>0) // OPTION : support SVDM
                            {
                                if ((RxData[0]&0xDF)!=0x06) // no response to Attention REQ
                                {
                                    u8StatePE = ((RxData[0]&0xDF)==0x01 && !(bPESta_PD2 && bPESta_DFP)) // Discover Identity REQ
                                                ? PE_RESP_VDM_Send_Identity
                                                : PE_RESP_VDM_Get_Identity_NAK;
                                    bEventPRLTX = 1;
                                }
                            }
                            else // OPTION : not support SVDM
                            {
                                if (!bPESta_PD2) // ignore if PD20
                                {
                                    u8StatePE = PE_SRC_Send_Not_Supported;
                                    bEventPRLTX = 1;
                                }
                            }
                        }
                        else // unstructured VDM
                        {
                            if (0)
                                ;
#ifdef QC4PLUS
                            else if ( RxData[0]==3 // CMD0
                                      && (RxData[1]==0x06 || RxData[1]==0x10 ||
                                          RxData[1]==0x0B || RxData[1]==0x0C || RxData[1]==0x0E) // CMD1
                                      && *((WORD*)&RxData[2])==BIG_ENDIAN(VID_QUALCOMM_QC40))
                            {
                                u8StatePE = PE_RESP_VDM_Send_QC4_Plus;
                                bEventPRLTX = 1;
                            }
#endif
                            else if (!bPESta_PD2) // ignore if PD20
                            {
                                u8StatePE = PE_SRC_Send_Not_Supported;
                                bEventPRLTX = 1;
                            }
                        }
                        break;

// CASE0. PD2/PD3 unexpected
                    case 0x01: // Source_Capabilities
                    case 0x04: // Sink_Capabilities
                        Go_PE_SRC_Send_Soft_Reset();
                        break;

// CASE1. PD2/PD3 unsupported
//             case 0x00: // Reserved
//             0x05~0x0E: // PD2 Reserved
//             0x08~0x0E: // PD3 Reserved
//             0x10~0x1F: // Reserved

// CASE2. PD2 unrecognized, USB_PD_R2_0 V1.3 Sec.6.3.4
// CASE3. PD3 unrecognized or unsupported
//             case 0x05: // Battery_Status
//             case 0x06: // Alert
//             case 0x07: // Get_Country_Info
                    default:
                        u8StatePE = PE_SRC_Send_Not_Supported; // or Reject in updprl.c
                        bEventPRLTX = 1;
                        break;
                    }
                }
                else // Control Messages
                {
                    switch (RxHdr&0x1F)
                    {
#ifndef SCP_ENABLE
                    case 0x07: // Get_Source_Cap
                        bPESta_EXPL = 0; // force implicit for instantly response
                        Go_PE_SRC_Send_Capabilities();
                        bPESta_EXPL = 1; // recover it for PE_SRC_Send_Capabilities
                        break;
                    case 0x09: // DR_Swap
                        u8StatePE = (SRC_PDO[0][3]&0x02) ? PE_DRS_Accept_Swap : PE_SRC_Send_Reject;
                        bEventPRLTX = 1;
                        break;
                    case 0x0B: // VCONN_Swap
                        u8StatePE = (IS_OPTION_CAPT() ||
//                             IS_V5OCPSTA() || // trun-on VCONN failed, 20180907
                                     !bTCRaDtcd) // no Ra detected, 20180907
                                    ? PE_SRC_Send_Not_Supported // or Reject in updprl.c
                                    : PE_VCS_Accept_Swap;
                        bEventPRLTX = 1;
                        break;
                    case 0x0D: // Soft Reset
                        u8StatePE = PE_SRC_Soft_Reset;
                        bEventPRLTX = 1;
                        break;
#ifdef CFG_PPS
                    case 0x11: // Get_Source_Cap_Extended
                        if (bPESta_PD2)
                        {
                            u8StatePE = PE_SRC_Send_Not_Supported; // Reject in updprl.c
                            bEventPRLTX = 1;
                        }
                        else
                        {
                            u8StatePE = (u8NumVDO>0)
                                        ? PE_SRC_Give_Source_Cap_Ext
                                        : PE_SRC_Send_Not_Supported;
                            bEventPRLTX = 1;
                        }
                        break;
                    case 0x12: // Get_Status
                        if (bPESta_PD2)
                        {
                            u8StatePE = PE_SRC_Send_Not_Supported; // Reject in updprl.c
                            bEventPRLTX = 1;
                        }
                        else
                        {
                            u8StatePE = PE_SRC_Give_Source_Status;
                            bEventPRLTX = 1;
                        }
                        break;
                    case 0x14: // Get_PPS_Status
                        if (bPESta_PD2)
                        {
                            u8StatePE = PE_SRC_Send_Not_Supported; // Reject in updprl.c
                            bEventPRLTX = 1;
                        }
                        else
                        {
//                   u8StatePE = bDevSta_PPSReq
//                        ? PE_SRC_Give_PPS_Status
//                        : PE_SRC_Send_Not_Supported;
                            u8StatePE = PE_SRC_Give_PPS_Status; // 20181015
                            bEventPRLTX = 1;
                        }
                        break;
#endif // CFG_PPS

// CASE0. PD2/PD3 unexpected, USB_PD_R2_0 V1.3 Sec.6.7.1
                    case 0x01: // GoodCRC
                    case 0x10: // Not_Supported
                    case 0x03: // Accept
                    case 0x04: // Reject
                    case 0x06: // PS_RDY
                        Go_PE_SRC_Send_Soft_Reset(); // ignore or Soft_Reset, it's a question
                        break;

// CASE1. PD2/PD3 unsupported
//             case 0x00: // Reserved
//             0x0E~0x0F: // Reserved
//             case 0x02: // GotoMin
//             case 0x05: // Ping
//             case 0x08: // Get_Sink_Cap
//             case 0x0A: // PR_Swap
//             case 0x0C: // Wait
// CASE2. PD2 unrecognized, USB_PD_R2_0 V1.3 Sec.6.3.4
// CASE3. PD3 unrecognized or unsupported
//             case 0x13: // FR_Swap
//             case 0x15: // Get_Country_Codes
//             case 0x16: // Get_Sink_Cap_Extended
//             0x17~0x1F: // Reserved
#endif
                    default:
                        u8StatePE = PE_SRC_Send_Not_Supported; // or Reject in updprl.c
                        bEventPRLTX = 1;
                        break;
                    }
                }
            }
#endif
            break;
        case PE_SRC_Send_Soft_Reset: // non-interruptible
            if (AMS_Cmd_n_Respond())
            {
                if (bPrlSent
                        || !bPrlRcvd) // AMS_CRC_TIMEOUT without bPrlSent/bPrlRcvd
                {
                    if (bPrlRcvd &&
                            u8PEAmsState==AMS_RSP_ACCEPT) Go_PE_SRC_Send_Capabilities(); // Accept
                    else // sent without received or sent and reveived something else
                        Go_PE_SRC_Hard_Reset();
                }
                else // received without sent
                    Go_PE_SRC_Send_Soft_Reset(); // interrupted, so retry
            }
            break;
        case PE_DRS_Send_Swap: // non-interruptible
        case PE_SRC_Send_Source_Alert: // interruptible
        case PE_INIT_PORT_UVDM_Request:
        case PE_INIT_PORT_VDM_Identity_Request:
        case PE_INIT_PORT_SVIDs_Request:
        case PE_INIT_PORT_VDM_Modes_Request:
        case PE_DFP_PORT_VDM_Modes_Entry_Request:
#ifdef PD_ENABLE
            if (AMS_Cmd_n_Respond())
            {
                if (bPrlSent)
                {
                    if (bPrlRcvd)
                    {
                        bPrlRcvd = 0;
                        if (u8StatePE==PE_DRS_Send_Swap)
                        {
                            switch (u8PEAmsState)
                            {
                            case AMS_RSP_ACCEPT:
                                Do_PE_DRS_Change();
                            case AMS_RSP_REJECT:
                                break;
                            default: // interrupted, Soft_Reset
                                Go_PE_SRC_Send_Soft_Reset();
                            }
                        }
                        else
                        {
                            if (u8PEAmsState==AMS_RSP_VDM)
                            {
                            }
                            else
                            {
                                bEventPE = 1; // interrupted
                                bPrlRcvd = 1; // do the rcvd
                            }
                        }
                    }
                    else // sent without received
                    {
                    }
                    Go_PE_SRC_Ready();
                }
                else if (bPrlRcvd) // received without sent
                {
                    bEventPE = 1; // not sent, do the rcvd
                    Go_PE_SRC_Ready();
                }
                else // AMS_CRC_TIMEOUT without bPrlSent/bPrlRcvd
                {
                    Go_PE_SRC_Send_Soft_Reset();
                }
            }
#endif
            break;
        case PE_RESP_VDM_Send_QC4_Plus:
            Go_PE_SRC_Ready();
            break;
#endif
        }
    }
}
