
// 20180427  For FW timing, uVision settings
//              Code Optimization: Level 8 Reuse Common Entry Code
//              Emphasis: Favor speed

#include "global.h"

#define ENA_FCP_PHY()        (FCPCTL |= 0x10)
#define DES_FCP_PHY()        (FCPCTL &= ~0x10)

#define FTX_END_Msk           0x01 // indicates TX completes a pakect sent.
#define FTX_EMPTY_Msk         0x02 // indicates TX FIFO is empty.  
#define FRX_PING_Msk          0x04 // indicates a master ping is received.
#define FRX_SHRT_Msk          0x08 // indicates a sync signal (2 short pulse) is received
#define FRX_B_DATA_Msk        0x10 // indicates 1-byte data is received with parity.
#define FRX_PAR_ERR_Msk       0x20 // indicates the received data with a parity error.
#define FRX_RESET_Msk         0x40 // indicates a reset signal is received.
#define ENA_FCP_INT(v)        (FCPMSK |= (v))
#define DES_FCP_INT(v)        (FCPMSK &= ~(v))
#define ENA_TX_EMPTY_INT()    (FCPMSK |= FTX_EMPTY_Msk)
#define DES_TX_EMPTY_INT()    (FCPMSK &= ~FTX_EMPTY_Msk)
#define ENA_TX_END_INT()      (FCPMSK |= FTX_END_Msk)
#define DES_TX_END_INT()      (FCPMSK &= ~FTX_END_Msk)

#define SET_DM_VREF_0V6()      (CaliADC(DACV5)   = 600/8)
#define SET_DM_CHANNEL_SCP()   (SAREN  &=~0x20)
#define SET_ONLY_DM_CHANNEL()  (DACEN   = 0x20)
#define CLR_COMP_DM_STA()      (CMPSTA  = 0x20)
#define IS_COMP_DM_VAL()      ((COMPI  &  0x20) != 0x00)

#define ADD_DP_CHANNEL() (DACEN |= 0x10)
#define DES_DP_CHANNEL() (DACEN &=~0x10) // de-select

#define FCP_UI 160 // us
#define FCP_SYNC_MAX (WORD)(1.5*FCP_UI/4)
#define FCP_PING_MAX (WORD)(1.2*FCP_UI*16)
#define FCP_PING_MIN (WORD)(0.8*FCP_UI*16)
#define FCP_RST_MIN  (WORD)(0.8*FCP_UI*100)
#define FCP_RST_MAX  (WORD)(1.2*FCP_UI*100)

#define SCP_CRC_GOOD()   (FCPCRC == 0)
#define SCP_CRC_PUSH(v)  (FCPCRC = v)
#define DIS_SCP_CRC()    (FCPCTL &= ~0x04)   //20181109
#define EN_SCP_CRC()    (FCPCTL |= 0x04)   //20181109
#define SCP_CRC_RST()    (FCPCTL &= ~0x04 , FCPCTL |= 0x04)

#ifdef SCP_ENABLE
//WORD idata u16DeltaTime;
//BYTE idata u8RxUI;// _at_ 0x13;
//BYTE idata u8RxBit;// _at_ 0x14;
BYTE idata u8ByteCnt;// _at_ 0x30;

BYTE idata u8RxBuffer [16+2];// _at_ 0x30;
BYTE idata u8RxNumByte;// _at_ 0x16;

BYTE idata u8TxBuffer [16];
BYTE idata u8TxNumByte;// _at_ 0x42;
//BYTE idata ScpRdyCnt;
BYTE ScpParErrCnt;
BYTE ScpCRCErrCnt;
BYTE ScpCheckCnt;
BYTE bdata u8ScpBits;
sbit bTxPing   =  u8ScpBits^0;
sbit bRxPing   =  u8ScpBits^1;
sbit bRxSync   =  u8ScpBits^2;
sbit bRxRst    =  u8ScpBits^3;
sbit bRxParErr =  u8ScpBits^4;
sbit bRxCrcErr =  u8ScpBits^5;
//bit bRxDmVal;

enum {
    SCP_PHY_INIT,
    SCP_PHY_READY,
    SCP_PHY_RX_BYTE,
    SCP_PHY_WAIT_TX_BEGIN,
    SCP_PHY_TX_PING,
    SCP_PHY_TX_BYTE,
    SCP_PHY_WAIT_TX_DONE,
} u8ScpPhyState;// _at_ 0x12;

#define MINI_TMR0(v) (TH0 = (0xFF),        \
                      TL0 = (-(v)),        \
                      TR0 = 1)
extern BYTE u8ScpReg03;
extern BYTE u8ScpRegA3;

void ScpPhyProc ()
{
    switch (u8ScpPhyState)
    {
    case SCP_PHY_INIT:
        break;
    case SCP_PHY_RX_BYTE:
        break;
    case SCP_PHY_READY:
        if(bRxRst)
        {
            ScpgoReset();
            u8ScpBits=0;
        }
        else if (bRxSync)
        {
            bRxSync = 0;
            u8RxBuffer[u8ByteCnt] = FCPDAT;
            SCP_CRC_PUSH(u8RxBuffer[u8ByteCnt]);
            bRxCrcErr = !SCP_CRC_GOOD();
            //crcTest[u8ByteCnt] = bRxCrcErr;
            u8ByteCnt++;
        }
        else if (bRxPing)
        {
            if (u8ByteCnt<=2 ||
                    u8ByteCnt>2 // data with CRC
                    && !bRxParErr && !bRxCrcErr)
            {
                if (u8ByteCnt==0) // solo PING
                {
//                  u8RxUI = u16DeltaTime/16;
                    u8RxNumByte=0;
                }
                else
                {
                    u8RxNumByte = u8ByteCnt - 1; // exclude the CRC and PING (-1,0 means PING-only/1-byte rcvd)
//                    bEventScprl = 1;           // move to SCP_PHY_TX_PING to wait sending ping.
                    ScpParErrCnt=0;
                    ScpCRCErrCnt=0;
                }
                bTxPing = 1;
//                u8ScpPhyState = SCP_PHY_WAIT_TX_BEGIN;
            }
            else// if(bRxParErr || bRxCrcErr)
            {   /* still send a slave ping if crc error & parity error */
                if(bRxCrcErr)
                {
                    u8ScpReg[0x03] |= 0x02;
                    u8ScpRegA3 |= 0x80;      //CRCRX
                    u8ScpReg03 |= 0x02;
                    ScpCRCErrCnt++;
                }
                if(ScpParErrCnt<0xFF)        // not received correct protocol yet, don't count error.
                {
                    if(bRxParErr)
                    {
                        ScpParErrCnt++;
                    }
                    if((ScpParErrCnt+ScpCRCErrCnt)>=9)
                    {
                        ScpgoReset();                        
                        u8ScpReg[0xA0] |= 0x40; // check error must turn off Vbus.
                        u8ScpPhyState=SCP_PHY_READY;
                        return;
                    }
                }
                bTxPing = 1;
//                u8ScpPhyState = SCP_PHY_WAIT_TX_BEGIN;
            }

            u8ScpPhyState = SCP_PHY_WAIT_TX_BEGIN;
            bRxParErr = 0;
            SCP_CRC_RST();
            u8ByteCnt = 0;
            bRxPing = 0;
            STRT_TMR1(FCP_UI);   //The slave ping after master ping must be sent within 1UI~5UI
            bTmr1_Scp=1;         // start SCP UI
        }
        break;
    case SCP_PHY_WAIT_TX_BEGIN:
        if (bTxPing)
        {   // the first byte
            FCPCTL &= 0xFC;   //let sync =0, parity = 0
            FCPDAT = 0xFF;
            ENA_TX_EMPTY_INT(); // enable TX empty Int
            u8ScpPhyState = SCP_PHY_TX_PING;
        }
        else if (u8TxNumByte>0)
        {
            FCPCTL |= 0x03;   //sync =1, parity = 1
            FCPDAT = u8TxBuffer[0];
            ENA_TX_EMPTY_INT(); // enable TX empty Int
            SCP_CRC_RST();
            if (u8TxNumByte==0x01) // only 1-byte to transmit
            {
                FCPCTL |= 0x08; // CRC for last data
            }
            SCP_CRC_PUSH(u8TxBuffer[0]);
            u8ScpPhyState = SCP_PHY_TX_BYTE;
        }
        break;
    case SCP_PHY_TX_BYTE:
        u8ByteCnt++;
        switch (u8TxNumByte-u8ByteCnt)
        {
        case 0x00:
        {
#ifdef AFC_ENABLE
            extern bit bAfcMode;
            if(!bAfcMode)
#endif
               FCPDAT = FCPCRC;
            break;
        }
        case 0xFF:
            FCPCTL &= ~0x0A;
            FCPDAT = 0xFF;
            break;
        case 0xFE:
            FCPCTL &= ~0x03;
            FCPCTL |= 0x02; // PARITY
            FCPDAT = 0xFF;
            ENA_TX_END_INT(); //enable TX completed Int
            u8ByteCnt = 0;
            u8TxNumByte = 0;
            u8ScpPhyState = SCP_PHY_WAIT_TX_DONE;
            break;
        case 1:
            FCPCTL |= 0x08; // CRC for last data
        default:
            FCPDAT = u8TxBuffer[u8ByteCnt];
            SCP_CRC_PUSH(u8TxBuffer[u8ByteCnt]);
            break;
        }
        break;
    case SCP_PHY_TX_PING: // the 2nd byte
        FCPCTL |= 0x02;
        FCPDAT = 0xFF;
        DES_TX_EMPTY_INT();
        ENA_TX_END_INT(); // Enable TX completed Int
        if(u8RxNumByte)
        {
/*            if(u8RxBuffer[0]==0x0C)       // single read response immediately
                ScpSRPrlProc();
            else*/
            {
               if(!bEventScpAF)           // not in anti fake process
                  bEventScprl = 1;
               else
               {}                         // only response a ping.
            }
        }
        u8ScpPhyState = SCP_PHY_WAIT_TX_DONE;
        break;
    case SCP_PHY_WAIT_TX_DONE:    //tx done include slave ping & data
        if (u8TxNumByte>0)
         {/* data has been sent (put in FCPDATA)*/
            STRT_TMR1(FCP_UI*3); //The Response data after slave ping must be sent within 3UI~5UI
            u8ScpPhyState = SCP_PHY_WAIT_TX_BEGIN;
            bTmr1_Scp=1;         // start SCP UI
        }
        else
         {/* slave ping has been sent  (put in FCPDATA)*/
            FCPMSK &= ~0x03; //disable TX empty & end INT
            //FCPCTL &= 0x10;       //reset FCPCTL except FCP_EN
            FCPCTL &= 0x14;         //reset FCPCTL except FCP_EN & CRC_EN
            u8ScpPhyState = SCP_PHY_READY;
            STRT_TMR1(FCP_UI*5);    // wait 5 UI and clear ScpCheckCnt if no interrupt.
            bTmr1_Scp=1;            // start SCP UI
        }
        if (!bTxPing)
        {
            bEventScprl = 1;
        }
        bTxPing = 0;
        break;
    }
//    bEventSCPHY = 0;
}

void IsrScpPhy () interrupt INT_VECT_FCP
{
    BYTE u8ScpStatus = FCPSTA;

#ifdef VOOC_ENABLE
    extern volatile BYTE voocPulses;
    if ((u8ScpStatus & FCPMSK & 0x80) && (DPDMACC & 0x0f)) {         // acc_dpdm
        if (voocPulses < 21) {
            if( !TWOPORT_WITHOUT_QC())
                voocPulses++;
        } else {
            FCPMSK = 0;	// disable all scp interrupts
            u8QcSta = BCSTA_VOOC;                                    // OPPO
            ACCCTL = 0x02;	// disconnect the D+/D- short
        }
    }
    else
#endif
    {
        if(u8ScpStatus & FRX_RESET_Msk)
        {
            bRxRst = 1;
            u8ScpPhyState=SCP_PHY_READY;
        }
        else if(u8ScpStatus & FRX_PING_Msk)
        {
            STOP_TMR1(); // stop check timer
            if(!u8SCPstate)
            {
                DES_FCP_INT(0x80);  // disable dpdm acc
                u8SCPstate = 0x01;  // into SCP, Jaden 190917
                FCPSTA = FRX_RESET_Msk; //Clear FCP RESET Status, may QC status leave.
                ENA_FCP_INT(FRX_RESET_Msk);
            }
            u8ScpPhyState=SCP_PHY_READY;
            //      STRT_TMR0(FCP_UI);   //The slave ping after master ping must be sent within 1UI~5UI
            bRxPing = 1;

//            if(!(u8ScpStatus & FRX_B_DATA_Msk))    // 2nd ping rises data flag. if 0 means the first ping
//                u8ByteCnt=0;

            if(ScpCheckCnt<=1 || !u8ByteCnt) ScpCheckCnt=0;

            ScpCheckCnt++;                         // counter to check a complete command.
            //      bRxSync = 0;
        }
        else if(u8ScpStatus & FRX_SHRT_Msk)
        {
            STOP_TMR1(); // stop check timer
            if(u8ScpStatus & FRX_B_DATA_Msk)
            {
                if (!bRxSync || u8ScpPhyState==SCP_PHY_READY)
                {
                    bRxSync = 1;
                }

                if(u8ScpStatus & FRX_PAR_ERR_Msk)
                {
                    bRxParErr = 1;
                    u8ScpReg[0x03] |= 0x01;
                    u8ScpRegA3 |= 0x40;            //PARRX
                    u8ScpReg03 |= 0x01;
                }
                ScpCheckCnt++;
            }
            ScpCheckCnt++;
            STRT_TMR1(FCP_UI*20);    // wait 20 UI and clear ScpCheckCnt if no interrupt of ping or sync.
            bTmr1_Scp=1;               // start SCP UI
        }
        else if(u8ScpStatus & (FTX_EMPTY_Msk | FTX_END_Msk))
        {
            //FCPMSK &= ~0x03; //disable TX empty & end INT
        }

        ScpPhyProc ();
//        bEventSCPHY = 1;
    }
    FCPSTA = 0xFF; //Clear FCP Status
}

void ScpPhyInit(void)
{
    u8ScpPhyState = SCP_PHY_INIT;

    IEN2 &=~0x04;
    DES_FCP_INT(FRX_RESET_Msk);
    DES_FCP_PHY();
    // recover DM chennel funtion?? in BcRst()?
}

void ScpPhyStart ()
{

//   TH0 = 0xFF;
//   ET0 = 1; // INT_VECT_TIMER0

    FCPCTL = 0; // SCP state machine may slow
    FCPMSK = 0;
    IEN2 |= 0x04; // INT_VECT_FCP, EX9

//   u16DeltaTime = 0;
//   u8RxUI = FCP_UI;

    u8ByteCnt = 0;
    u8ScpBits = 0;
    ScpParErrCnt=0xFF;
    ScpCRCErrCnt=0xFF;
    FCPSTA = 0xFF; //Clear FCP Status
    ENA_FCP_INT(FRX_PING_Msk | FRX_SHRT_Msk);
    ENA_FCP_PHY();
    u8ScpPhyState = SCP_PHY_READY;
}

bit Scp_CheckCount(void)
{
   if(u8ScpPhyState == SCP_PHY_READY)
   {
      ScpCheckCnt = 0;
      return FALSE;
   }
   return TRUE;
}

#endif