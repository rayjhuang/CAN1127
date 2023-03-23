
#include "global.h"

#ifdef PD_ENABLE
TRUE_FALSE is_rxsvdm (BYTE cmd_byte, BYTE id_sel)
// id_sel: 0/1, standard/Apple
{
    return ((0xDF&RxData[0])==(cmd_byte)// ACK/NAK responsed / CMD to send/rcv
            && (0x80&RxData[1])==(0x80) // structured
            && *((WORD*)&RxData[2])==((id_sel==1) ? BIG_ENDIAN(SID_STANDARD)
                                      : (id_sel==2) ? BIG_ENDIAN(VID_APPLE)
                                      : BIG_ENDIAN(VID_CANYON_SEMI)));
}
#endif
#if defined(CFG_APPLE_DATEX) || defined(CFG_PDO1_ONLY)
TRUE_FALSE is_rxsvdm_ack_discid_apple ()
{
    return (is_rxsvdm(0x41,1) // ACK to Discover Identity
            && *((WORD*)&RxData[4])==BIG_ENDIAN(VID_APPLE));
}
#endif


#ifdef CFG_APPLE_DATEX

#define DATEX_BASE_ADDR 0x400
#define ACTIVE_DATEX_ADDR (DATEX_BASE_ADDR | 0x8000)

BYTE code strDatEx [4][15*16] _at_ DATEX_BASE_ADDR;
BYTE u8ExStr;
BYTE u8UvdmMod, u8UvdmCnt, u8UvdmCmd, u8UvdmAdr;
APPLE_DATEX_BYTE u8StateADExCmd;

void AppleDatExReset()
{
    u8ExStr = 0xFF;

    if      (strDatEx[3][0]!=0xFF) u8ExStr = 3; // [0x02D0,0x03C0)
    else if (strDatEx[2][0]!=0xFF) u8ExStr = 2; // [0x01E0,0x02D0)
    else if (strDatEx[1][0]!=0xFF) u8ExStr = 1; // [0x00F0,0x01E0)
    else if (strDatEx[0][0]!=0xFF) u8ExStr = 0; // [0x0000,0x00F0)

    if (u8ExStr<0xFF)
    {
        u8StateADExCmd = AEMD_1;
        u8UvdmMod = 0;
    }
}

void AppleDatExProc ()
{
    switch (u8StatePM)
    {
    case PM_STATE_ATTACHED:
        switch (u8StateADExCmd)
        {
        case AEMD_1:
            AMS_Start (PE_INIT_PORT_VDM_Identity_Request); // Disover Identiry
            break;
        case AEMD_2:
            AMS_Start (PE_INIT_PORT_SVIDs_Request);
            break;
        case AEMD_3:
            AMS_Start (PE_INIT_PORT_VDM_Modes_Request);
            break;
        case AEMD_END:
            AMS_Start (PE_DFP_PORT_VDM_Modes_Entry_Request);
            break;
        case AEMD_UVDM:
            AMS_Start (PE_INIT_PORT_UVDM_Request);
            break;
        }
        u8StatePM = PM_STATE_ATTACHED_AMS1;
        break;
    case PM_STATE_ATTACHED_AMS1:
        switch (u8PEAmsState)
        {
        case AMS_RSP_VDM:
            switch (u8StateADExCmd)
            {
            case AEMD_1:
                if (is_rxsvdm_ack_discid_apple()) // Discover Identity ACK-ed
                {
                    // SVID = 0xFF00
                    // VID of Apple (0x05AC) in ID Header [15:0]
                    if (RxData[15]<=(PID_MACBOOK2015>>8)) u8UvdmMod = 0x10;
                    u8StateADExCmd = AEMD_2;
                }
                else
                {
                    u8StateADExCmd = AEMD_IDLE;
                }
                break;
            case AEMD_2:
                if (is_rxsvdm(0x42,1)) // Discover SVIDs ACK-ed
                {
                    // SVID = 0xFF00
                    // VID of Apple (0x05AC) in SVID3
                    u8StateADExCmd = AEMD_3;
                }
                else
                {
                    u8StateADExCmd = AEMD_IDLE;
                }
                break;
            case AEMD_3:
                if (is_rxsvdm(0x43,2)) // Discover Modes ACK-ed
                {
                    // SVID = 0x05AC
                    // Mode1 = 0x00000002
                    // Mode2 = 0x01C20004
                    u8StateADExCmd = AEMD_END;
                }
                else
                {
                    u8StateADExCmd = AEMD_IDLE;
                }
                break;
            case AEMD_END:
                if (is_rxsvdm(0x44,2)) // Enter Mode ACK-ed
                {
                    // SVID = 0x05AC
                    // Pos=1
                    u8UvdmCnt  = 0x00;
                    u8UvdmCmd  = 0x05;
                    u8UvdmMod |= 0x01;
                    u8StateADExCmd = AEMD_UVDM;
                }
                else
                {
                    u8StateADExCmd = AEMD_IDLE;
                }
                break;
            case AEMD_UVDM:
                u8StateADExCmd = AEMD_IDLE;
                break;
            }
            break;
        case AMS_SND_TIMEOUT: // nothing received
            u8StateADExCmd = AEMD_IDLE;
            break;
//    case AMS_CRC_TIMEOUT:  // interrupted during sending, not sent
//    case AMS_SINK_TX_TIME: // interrupted before sending
//    case AMS_RSP_RCVD:     // interrupted
        default: // redo later
            ;
        }
        u8StatePM = PM_STATE_ATTACHED;
        break;
    }
}

void AppleDatExAttention()
{
// RxData[7:6]; // VID_APPLE
    u8UvdmCnt = RxData[5]&0x07; // CNT
    u8UvdmCmd = RxData[4]; // 2:READ, 5:CONTROL
    if (u8UvdmMod&0x10) // MacBook2015
        ;
    else // copy VDO2 of rcvd (Attention) to VDO1 of sending
    {
        TxData[4] = RxData[8];
        TxData[5] = RxData[9];
        TxData[6] = RxData[10];
        TxData[7] = 0;
    }
    u8UvdmAdr = RxData[8] + (RxData[11] ? RxData[11] + 0xC0 : 0);
    u8StateADExCmd = AEMD_UVDM;
}

#define SET_OTP_ADDR(v)   (DEC     = (v>>8), OFS = v)
#define SET_CV_VOLT_11V() (PWR_V   = (11000/80))
#define SET_V5_VOLT_9V()  (SRCCTL |= 0x40)
#define STOP_MCU()        (MISC   |= 0x08)

BYTE CheckSum (BYTE id)
{
    BYTE ii, sum;
    sum = 0;
   for (ii=0;ii<15*16;ii++) sum += strDatEx[id][ii];
    return sum;
}

void CanyonSemiAttention()
{
    switch (RxData[4])
    {
    case 0x10: // check-sum
        u8UvdmCmd = 0x10;
        TxData[4] = CheckSum (0);
        TxData[5] = CheckSum (1);
        TxData[6] = CheckSum (2);
        TxData[7] = CheckSum (3);
        u8StateADExCmd = AEMD_UVDM;
        break;
    case 0x02: // table programming initialization
        switch (RxData[5])
        {
         case 0x1: SET_OTP_ADDR(ACTIVE_DATEX_ADDR+240*1); break;
         case 0x2: SET_OTP_ADDR(ACTIVE_DATEX_ADDR+240*2); break;
         case 0x3: SET_OTP_ADDR(ACTIVE_DATEX_ADDR+240*3); break;
         default:  SET_OTP_ADDR(ACTIVE_DATEX_ADDR);
        }
//    SET_VBUS_OFF(); // 11V-VBUS or self-powered sink?
        SET_CV_VOLT_11V();
        SET_RP_VAL(0); // Rp distorted in LDO9V
        SET_V5_VOLT_9V();
        STOP_MCU();
        // ready for table programming (Mode 0)
        break;
    }
}

#endif // CFG_APPLE_DATEX
