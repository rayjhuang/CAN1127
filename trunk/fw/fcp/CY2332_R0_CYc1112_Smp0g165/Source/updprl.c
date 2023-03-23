
#include "global.h"

extern WORD u16BistCM2Cnt;

volatile BYTE bdata u8PrlStatus _at_ 0x24;
sbit bPrlSent  = u8PrlStatus^0;
sbit bPrlRcvd  = u8PrlStatus^1;
sbit bPhySent  = u8PrlStatus^2;
sbit bPhyPatch = u8PrlStatus^4;
sbit bPrlRcvTo = u8PrlStatus^5; // tReceive timeout
sbit bHrRcvd   = u8PrlStatus^6;

PRL_TX_STATE_BYTE u8StatePrlTx _at_ 0x16 ;

//enum {
//   PRL_Rx_Wait_for_PHY_Message,
//   PRL_Rx_Layer_Reset_for_Receive,
//   PRL_Rx_Send_GoodCRC,
//   PRL_Rx_Check_MessageID,
//   PRL_Rx_Store_MessageID
//} u8StatePrlRx _at_ 0x17;

#ifdef PD_ENABLE
BYTE u8RetryCounter;
volatile BYTE u8MessageIDCounter;
volatile BYTE u8StoredMessageID;

void PRL_Tx_PHY_Layer_Reset (bit bStartup) // PRL_Tx_PHY_Layer_Reset
{
    STOP_TMR_RCV();
    bEventPRLTX = 0;
    (bStartup)
    ? PhysicalLayerStartup()
    : PhysicalLayerReset();

    u8PrlStatus = 0;
    u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
// u8StatePrlRx = PRL_Rx_Wait_for_PHY_Message;
    u8StoredMessageID = 0xFF;
    u8MessageIDCounter = 0;
}

void ConstructVDM (BYTE cmd_byte, BYTE ndo_byte)
// cmd_byte: [7:4][3:0]
// ndo_byte: [7:4][3][2:0], [NDO][UNSTRUCTURED][SVID_SEL]
{
    TxHdrL   |= 0x0F; // VDM
    TxHdrH   |= ndo_byte&0xF0;
    TxData[0] = cmd_byte; // initiate/ACK/NAK/cmd if structured, u8UvdmCmd if unstructured

    // structured, VDM Ver=1.0/2.0
    // always 2.0 if initiating Discover Identity
    TxData[1] = (ndo_byte&0x08) ? u8UvdmCnt // unstructured
                : (!bPESta_PD2 &&  // always SVDM1.0 in PD2.0
                   (!bPESta_SVDM1 || (cmd_byte&0xDF)==0x01)) ? 0xA0 : 0x80; // structured, SVDM2.0/1.0

    *((WORD*)&TxData[2]) = ((ndo_byte&0x07)==1) ? BIG_ENDIAN(SID_STANDARD)
                           : ((ndo_byte&0x07)==2) ? BIG_ENDIAN(VID_APPLE)
                           : BIG_ENDIAN(VID_CANYON_SEMI);
}

BYTE GetTemperature (TRUE_FALSE low)
{
// low : 0/1-degree lower bound
// only for 103AT NTC (10K@25)
// refer to Z:\RD\Project\CAN1110\Ray\NTC_to_ADC.xls
#ifdef CFG_TS_NTC
    BYTE temp_v = u8TmpVal;
    if (temp_v>64) // 512mV
        temp_v = (temp_v>=250) ? low
                 : 50 - temp_v/5; // low~37 degree
    else
        temp_v = 102 - temp_v; // 38~102 degree
    return temp_v;
#else
    return (low?25:20); // TS is used to do others
#endif
}
#endif

#define PowerRole 0x01

#ifdef CFG_PPS
void ClrTxData (BYTE dat0, BYTE dat1, BYTE cnt)
{
    TxData[0] = dat0;
    TxData[1] = dat1;
    while (cnt--) TxData[cnt+2] = 0;
}
#endif

#ifdef PD_ENABLE
void Go_PRL_Tx_Construct_Message ()
{
// u8StatePrlTx = PRL_Tx_Construct_Message;
    TXCTL = 0x39; // auto-preamble/SOP/CRC32/EOP
    u8StatePrlTx = PRL_Tx_Wait_for_PHY_Response_TxDone;
    {
        TxHdrL = bPESta_PD2 ? 0x40 : 0x80; // SpecRev
        if (bPESta_DFP) TxHdrL |= 0x20; // Data Role
        TxHdrH = PowerRole | (u8MessageIDCounter<<1);
        switch (u8StatePE)
        {
        case PE_SRC_Send_Soft_Reset:
            TxHdrL |= 0x0D; // Soft Reset
            break;
        case PE_VCS_Send_PS_RDY:
        case PE_SRC_Transition_PS_RDY:
            TxHdrL |= 0x06; // PS_RDY
            break;
        case PE_VCS_Accept_Swap:
        case PE_DRS_Accept_Swap:
        case PE_SRC_Soft_Reset:
        case PE_SRC_Transition_Accept:
            TxHdrL |= 0x03; // Accept
            break;
        case PE_SRC_Send_Reject:
        case PE_SRC_Capability_Response:
            TxHdrL |= 0x04; // Reject
            break;
        case PE_SRC_Send_Not_Supported:
            TxHdrL |= bPESta_PD2 ? 0x04 : 0x10; // Reject or Not_Supported
            break;
#ifdef CFG_PPS
        case PE_SRC_Send_Source_Alert:
            TxHdrL |= 0x06; // Alert
            TxHdrH |= 0x10; // NDO=1
            ClrTxData(0,0,4);
            TxData[3] = 0x10; // only because of bProCLChg
            break;
        case PE_SRC_Give_Source_Status:
            TxHdrL |= 0x02; // Status
            TxHdrH |= 0xA0; // extended, NDO=2
//       ClrTxData(5,0x80,6); // length of Status Data Block, chunked, number=0, request=0
            ClrTxData(6,0x80,6); // PDr30v12
#ifdef STATUS_INT_TEMP
            TxData[2] = GetTemperature(1); // Internal Temp
#endif
            TxData[3] = 2; // Present Input=External Power
//       TxData[4] = 0; // Present Battery Input
            TxData[5] = bProCLimit ? 0x10 : 0x00; // Event Flags
//       TxData[6] = 0x00; // Temperature Status
//       TxData[7] = 0x00; // padding, Power Status in PDr30v12
            break;
        case PE_SRC_Give_PPS_Status:
            TxHdrL |= 0x0C; // PPS_Status
            TxHdrH |= 0xA0; // extended, NDO=2
            ClrTxData(4,0x80,6); // length of Status Data Block, chunked, number=0, request=0
            TxData[2] = 0xFF; // Output Voltage (low byte)
            TxData[3] = 0xFF; // Output Voltage (high byte)
            TxData[4] = 0xFF; // Output Current
            TxData[5] = bProCLimit ? 0x08 : 0x00; // Real Time Flags (20180809)
            break;
        case PE_SRC_Give_Source_Cap_Ext:
            TxHdrL |= 0x01; // Source_Cap_Ext
            TxHdrH |= 0xF0; // extended, NDO=7
            ClrTxData(24,0x80,26); // length of Status Data Block, chunked, number=0, request=0
            MEM_COPY_C2X(&(TxData[2]),lpVdmTable,12); // VID, 0xXXXX, XID, 0xHWFW, PID
            *((WORD*)&TxData[4]) = *((WORD*)&TxData[12]); // PID
            *((WORD*)&TxData[12]) = 0;
            TxData[25] = SOURCE_PDP(); // rev.20180222.10
            break;
#endif // CFG_PPS
#ifdef PD_ENABLE
        case PE_SRC_VDM_Identity_Request:
            TXCTL = 0x3A; // auto-preamble/SOP'/CRC32/EOP
            ConstructVDM(0x01,0x11); // initiate Discover Identity
            TxHdrH &=~0x01; // PwrRole -> Cable shall be '0'
            TxHdrL &=~0x20; // DatRole -> rsvd shall be '0'
            break;
        case PE_SRC_Send_Capabilities:
            TxHdrL |= 0x01; // Source_Capabilities
            TxHdrH |= u8NumSrcPdo<<4;
            MEM_COPY_X2X(TxData,SRC_PDO[0],u8NumSrcPdo*4);
            break;
        case PE_BIST_Carrier_Mode:
            bPrlRcvTo = 0;
        case PE_SRC_Hard_Reset:
//       TXCTL = 0x40; // auto encoded K code
//       TXCTL = 0x48; // K-code encoding with preamble
            u8StatePrlTx = PRL_Tx_Wait_for_PHY_Done; // no bEventPE
            break;
#endif
#ifdef QC4PLUS
        case PE_RESP_VDM_Send_QC4_Plus:
            TxHdrL |= 0x0F; // VDM
            TxHdrH |= 2<<4;
            TxData[0] = 0xA0; // ACK
            TxData[1] = RxData[1];
            *((WORD*)&TxData[2]) = BIG_ENDIAN(VID_QUALCOMM_QC40);
            switch (RxData[1] & 0x7F) // CMD1
            {
            case 0x10: // Inquire charger case temperature
                TxHdrH &=~0x70;
                TxHdrH |= 1<<4;
                TxData[0] = 0x50; // NAK
                break;
            case 0x0B: // Inquire charger connector temperature
                TxData[4] = GetTemperature(0); // takes long!?
                TxData[5] = 0x00;
                TxData[6] = 0x00;
                TxData[7] = 0x00;
                break;
            case 0x06: // Inquire voltage at connector
                TxData[4] = 0x00;
            TxData[5] = CaliADC(DACV1)<<3;
            TxData[6] = CaliADC(DACV1)>>5;
                TxData[7] = 0x00;
                break;
            case 0x0C: // Inquire charger type
                TxData[4] = 0x04; // Charger type = Quick Charge 4
                TxData[5] = 0x00;
                TxData[6] = 0x00;
                TxData[7] = 0x00;
                break;
            case 0x0E: // Inquire charger protocol version
                TxData[4] = bPESta_PD2 ? 0x20 : 0x30; // Charger protocol version
                TxData[5] = 0x00;
                TxData[6] = 0x00;
                TxData[7] = 0x00;
                break;
            }
            break;
#endif // QC4PLUS
#ifdef PD_ENABLE
        case PE_RESP_VDM_Send_Identity:
            ConstructVDM(0x41,((u8NumVDO+1)<<4)|0x01); // plus VDM Header
            MEM_COPY_C2X(&(TxData[4]),lpVdmTable,u8NumVDO*4);
            break;
        case PE_RESP_VDM_Get_Identity_NAK: // NAK to not only Discover Identity
            ConstructVDM(0x80 | RxData[0], 0x11);
            break;
        case PE_INIT_PORT_VDM_Identity_Request:
            ConstructVDM(0x01,0x11); // initiate Discover Identity
            break;
#endif
#ifdef CFG_APPLE_DATEX
        case PE_INIT_PORT_SVIDs_Request:
            ConstructVDM(0x02,0x11); // initiate Discover SVIDs
            break;
        case PE_INIT_PORT_VDM_Modes_Request:
            ConstructVDM(0x03,0x12); // initiate Discover Modes
            break;
        case PE_DFP_PORT_VDM_Modes_Entry_Request:
            ConstructVDM(0x04,0x12); // initiate Enter Mode
            TxData[1] |= OBJPOS_ENTER;
            break;
        case PE_INIT_PORT_UVDM_Request:
            switch (u8UvdmCmd)
            {
            case 2: // READ
                ConstructVDM(0x02, 0x0A | ((u8UvdmCnt + ((u8UvdmCnt==6) ? 1 : 2)) << 4)); // initiate UVDM_2 (plus VDM header and VDO2-copy/ending-zero)
                MEM_COPY_C2X(&(TxData[(u8UvdmMod&0x10)?4:8]),&(strDatEx[u8ExStr][u8UvdmAdr]),u8UvdmCnt*4);
                if (u8UvdmMod&0x10 && u8UvdmCnt<6) // MacBook2015
                {
                    *((WORD*)&TxData[u8UvdmCnt*4+4]) = 0; // ending-zero
                    *((WORD*)&TxData[u8UvdmCnt*4+6]) = 0;
                }
                break;
            case 5: // CONTROL
                ConstructVDM(0x05,0x1A); // UVDM_05 (APPLE)
                break;
            case 0x10: // CHECK-SUM
                ConstructVDM(0x10,0x28); // UVDM_10 (CANYON)
                break;
            }
            break;
#endif
        case PE_DRS_Send_Swap:
            TxHdrL |= 0x09; // DR_Swap
            break;
        }
    }
    bEventPHY = 1;
}
void Go_PRL_Tx_Check_Retry_Counter ()
{
    BYTE RetryLimit;
// u8StatePrlTx = PRL_Tx_Check_Retry_Counter;
    RetryLimit = bPESta_PD2 ? nRetryCount : nRetryCount-1;
    if (u8StatePE == PE_SRC_Hard_Reset_Received) // 20180809
    {
        u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
    }
    else if (u8RetryCounter >= RetryLimit) // || bDevSta_CBL)
    {
//    u8StatePrlTx = PRL_Tx_Transmission_Error;
        u8MessageIDCounter++, u8MessageIDCounter &= 0x07;
        bEventPE = 1;
        u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
    }
    else
    {
//    Go_PRL_Tx_Construct_Message(); // takes long!!
        if (!bPrlRcvTo) bEventPHY = 1; // 20190726 move the timeout-repeated-TX starting to ISR for tRecieve
        u8RetryCounter++;
        u8StatePrlTx = PRL_Tx_Wait_for_PHY_Response_TxDone;
    }
// bPrlSent = 0; // not sent (yet)
}

void ProtocolTxProc ()
{
    bEventPRLTX = 0;

    switch (u8StatePrlTx)
    {
    case PRL_Tx_Wait_for_Message_Request:
        u8RetryCounter = 0;
        bPrlSent = 0; // not sent (yet), init for not started by AMS
        if (u8StatePE == PE_SRC_Send_Soft_Reset)
        {
            u8StatePrlTx = PRL_Tx_Reset_for_Transmit;
            u8MessageIDCounter = 0;
            u8StoredMessageID = 0xFF;
//       u8StatePrlRx = PRL_Rx_Wait_for_PHY_Message;
        }
        if (u8StatePE == PE_SRC_Ready)
            ; // interrupted before start sending
        else
            Go_PRL_Tx_Construct_Message();
        break;
    case PRL_Tx_Wait_for_PHY_Done: // no GoodCRC response expected (CarrierMode2/HardReset)
        if (u8StatePE == PE_BIST_Carrier_Mode)
        {
            if (u16BistCM2Cnt>0) // from Tmr0
            {
                bEventPHY = 1; // to continue the BIST Carrier Mode 2 packet
            }
            else // from TxDone->PRLTX
            {
                u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
                bEventPE = 1;
            }
        }
        else if (bPhySent) // from TxDone->PRLTX, Hard Reset sent
        {
//       u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
            PRL_Tx_PHY_Layer_Reset(FALSE);
        }
        else
        {
            bEventPHY = 1; // try Hard Reset again once CC gets IDLE
        }
        break;
    case PRL_Tx_Wait_for_PHY_Response_TxDone:
        bPrlRcvTo = 0;
        u8StatePrlTx = PRL_Tx_Wait_for_PHY_Response;
        break;
    case PRL_Tx_Wait_for_PHY_Response:
        if (bPrlRcvTo || !bPhySent)
        {
            Go_PRL_Tx_Check_Retry_Counter();
        }
        else // GoodCRC received
        {
//       u8StatePrlTx = PRL_Tx_Match_MessageID;
            if (((PRLRXH>>1)&0x07)==u8MessageIDCounter) // MessageID matched
            {
                u8StatePrlTx = PRL_Tx_Message_Sent;
                u8MessageIDCounter++, u8MessageIDCounter &= 0x07;
                bEventPE = 1;
                bPrlSent = 1;
                bPrlRcvd = 0; // if so, the sent means the received finished
                u8StatePrlTx = PRL_Tx_Wait_for_Message_Request;
            }
            else
            {
                Go_PRL_Tx_Check_Retry_Counter();
            }
        }
        break;
    }
}
#endif
