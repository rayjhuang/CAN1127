
#include "global.h"

#ifdef PD_ENABLE
//BYTE xdata TxData [30] _at_ 0x000;
//BYTE xdata RxData [30] _at_ 0x020;
BYTE TxHdrL _at_ 0x0E, TxHdrH _at_ 0x0F;
WORD RxHdr  _at_ 0x10; // 0x11

WORD u16BistCM2Cnt;

extern BYTE u8MessageIDCounter;
extern BYTE u8StoredMessageID;
void ProtocolRxProc ()
{
/*    BYTE tmp;
    if ((PRLS&0x70) == 0x20 && u8StatePE != PE_SRC_VDM_Identity_Request) // SOP' in wrong states
    {
    }
    else
    {
        if ((RxHdr&0xF01F)==13)
        {
            u8MessageIDCounter = 0;
            u8StoredMessageID = 0xFF;
            // a Soft_Reset shall always be with Message ID =0
            // here never treat a received Soft_Reset a retried (6.7.1.2 in USB_PD_R3_0 V1.2 20180621.pdf)
        }
        tmp = (RxHdr>>9) & 0x07;
        if (u8StoredMessageID != tmp) // not rcvd a retried message
        {
            u8StoredMessageID = tmp;
            bPrlRcvd = 1;
//       bPrlSent = 0; // 20180724, AMS need to know is the prior TX sent when an RX arrived
            bEventPE = 1;
        }
    }*/
}

void SetPrlTxEvent ()
{
    if (u8StatePrlTx)
    {
        bEventPRLTX = 1;
    }
}

void IsrTx() interrupt INT_VECT_UPDTX
{
    if ((STA1&0x40) // auto-TX-GoodCRC sent
       ) {
        MSK1 &=~0x02; // quit re-transmission caused by discarded
        ProtocolRxProc();
    }
    else if (STA1&0x01) // TxDone (and is not of auto-TX-GoodCRC)
    {
        if (u8StatePrlTx == PRL_Tx_Wait_for_PHY_Response_TxDone) STRT_TMR_RCV(T_RECEIVE);
        if (u8StatePE == PE_BIST_Carrier_Mode) ADD_THE_CC_CHANNEL();
        SetPrlTxEvent();
    }
    else if ((MSK1&0x02) && (STA1&0x02)) // TX discarded, inform PRLTX once CC idle
    {
        STRT_TMR_RCV(160);
        MSK1 &=~0x02;
        SetPrlTxEvent();
    }
    STA1 = 0x041;
}

void IsrRx() interrupt INT_VECT_UPDRX
{
/*    BYTE ptr;
    BYTE hdr_l; // add for rev.20180222.02
    if (STA0&0x08) // a message rcvd
    {
        hdr_l = PRLRXL & 0x1F; // don't modify PRLRXH/L, keep MsgID/role for auto-returned GoodCRC
        if ((PRLRXH&0xF0)==0 && hdr_l==1) // GoodCRC
        {
            STOP_TMR_RCV(); // stop CRCReceiverTimer
            FFSTA = 0; // reset FIFO
            SetPrlTxEvent();
        }
        else
        {
            ptr = 0;
            STA1 = 0x30;
            FFCTL = 0x40; // first
            ((BYTE*)&RxHdr)[1] = FFIO;
            ((BYTE*)&RxHdr)[0] = FFIO;
            while (!(STA1&0x30) && ptr<30)
            {
                RxData[ptr++] = FFIO;
            }
        }
    }
    if ((STA0&0x02) && ((PRLS&0x70)==0x60)) // Hard Reset rcvd
    {
        bEventPE = 1;
        bHrRcvd = 1;
    }
    STA0 = 0x0A;*/
}

void PhysicalLayerStartup () // start receiver/auto-tx-goodcrc
{
#ifdef CAN1110X
    DEC = 0xC7;
#endif
    RXCTL |= 0x21; // Hard Reset, SOP //, 20180906 remove SOP'
    PRLTX = 0xD7; // auto-TX-GoodCRC, auto-discard, spec=2.0, MsgID=7
    STA0 = 0xFF;
    STA1 = 0xFF;
    EX4 = 1; // UPDRX
    EX5 = 1; // UPDTX
}

void PhysicalLayerReset () // stop/init receiver/auto-tx-goodcrc
{
    RXCTL = 0x01; // SOP (for Canyon Mode 0, but, is that right?)
    PRLTX = 0x07; // POR value
    CCRX = 0x48; // SQL_EN, RX_PK_EN=0, ADPRX_EN
    EX4 = 0; // UPDRX
    EX5 = 0; // UPDTX
    MSK0 = 0x0A; // EOP with CRC32 OK, enabled-ordered-set rcvd
    MSK1 = 0x41; // auto-TX-GoodCRC sent, TX done
}

void PhysicalLayerSend (bit bPhyRetry)
// re-send in tReceive (may run in both ISR/main-loop)
// *** WARNING L15: MULTIPLE CALL TO SEGMENT
// here (FW) should guarantee this function is never called recursively
{
   bPhyRetry=1;
/*    BYTE bcnt, ii;
    bPhySent = (REVID&0x80); // CC idle
    if (bPhySent)
    {
        STA1  = 0x30;
        FFSTA = 0x00; // reset FIFO
        FFCTL = 0x40; // set first
//       if (TXCTL==0x48) // Hard Reset
        if (u8StatePE==PE_SRC_Hard_Reset)
        {
            TXCTL = 0x48;
            FFIO  = 0x55;
            FFCTL = 0x82; // set last, 2-byte ex-code
            FFIO  = 0x65;
        }
        else
        {
            bcnt = ((TxHdrH & 0x70) >> 2); // NDO*4
            FFIO = TxHdrL;
            if (bPhyRetry) FFCTL = 0xa0; // last, FF_UNLOCK for rev.20180703 (for re-sending in tReceive)
            if (bcnt==0)   FFCTL = 0x80; // last, start the packet when FIFO ready to prevent form interrupted
            FFIO = TxHdrH;
            for (ii=0; ii<bcnt; ii++)
            {
                if (!bPhyRetry && ii==(bcnt-1)) FFCTL = 0x80; // last
                FFIO = TxData[ii];
            }
            FFCTL &= ~0x20; // rev.20180703
        }
        // any error condition here??
        if (STA1&0x20) // sending failed
        {
            bPhySent = 0;
        }
    }
    if (!bPhySent) // CC busy
    {
        STA1 |= 0x02; // clear GO_IDLE status
        MSK1 |= 0x02; // temporarily enable GO_IDLE INT
    }*/
}

void PhysicalLayerProc ()
{
/*    bEventPHY = 0;
// if (TXCTL==0x40) // BIST Carrier Mode 2
    if (u8StatePE==PE_BIST_Carrier_Mode)
    {
        if (!bPrlRcvTo)
        {
            DES_THE_CC_CHANNEL(); // stop sensing the CC lane for better eye diagram
            TXCTL = 0x40;
            STA1  = 0x30;
            FFSTA = 0x00; // reset FIFO
            FFCTL = 0x40; // set first
            u16BistCM2Cnt = N_BISTCM2 + 1;
        }
        while (--u16BistCM2Cnt && (FFSTA&0x3F)<34) FFIO = 0x44;
        if (!bPrlRcvTo) FFCTL = 0xBF; // set last/un-lock/numk=0x1F
        FFIO = 0x44;
        if (u16BistCM2Cnt) STRT_TMR_RCV(T_BISTCM2); // inform PrlTx later (must before FIFO empty)
    }
    else // SOP/SOP'/Hard Resest
    {
        PhysicalLayerSend (0);
    }*/
}
#endif

