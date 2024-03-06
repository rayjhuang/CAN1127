#ifndef _GLOBAL_H_
#define _GLOBAL_H_

#include "config.h"
#ifdef CAN1110X
#include "can1110_reg.h"
#include "can1110_hal.h"
#include "intro1110.h"
#else
#include "can1112_reg.h"
#include "can1112_hal.h"
#endif

#define T_RECEIVE 950 // 0.9~1.1ms (tReceive), start TX in ISR takes time!!
#define T_BISTCM2 1330 // 1.33ms, inform PrlTx before FIFO empty
#define TIMEOUT_ONE_MS (1000-12) // for 1-ms ISR by timer0/1

#ifdef CFG_SIM

#define PM_TIMER_VBUSON_DELAY  4
#define PM_TIMER_DISCHG_DELAY  3
#define PM_TIMER_PWRGD_DELAY_N 2
#define PM_TIMER_PWRGD_DELAY_F 2
#define PM_TIMER_PWRGD_DELAY_R 3
#define PM_TIMER_PWRGD_TIMEOUT 7
#define PM_TIMER_SMALL_STEP    5 // this should not shorter than stepping
#define PM_TIMER_LARGE_STEP    8
#define PM_TIMER_CC_TRANSITION 13
#define PM_TIMER_VCONNON       1
#define PM_TIMER_WAIT_CAP      5
#define T_DETACH_DISCHG_MIN    2
#define T_DETACH_DISCHG_MAX    5
#define T_PD_DEBOUNCE          2
#define T_CC_DEBOUNCE          6
#define T_CC_SLEEP             25
#define T_SENDER_RESPONSE      5
#define T_VCONN_SOURCE_ON      5
#define T_PS_HARD_RESET        6
#define T_SRC_TRANSITION       3
#define T_SRC_RECOVER          15
#define T_C_SENDSRCCAP         7
#define T_NO_RESPONSE          73 // > (T_C_SENDSRCCAP + 8) * nCapsCount
#define T_PPS_TIMEOUT          90
#define T_F2HR_2V8             4
#define T_F2HR_DEBNC()         3
#define T_F2OFF_DEBNC          4
#define T_CURRENT_LIMIT        3
#define T_SINK_TX              3
#define T_CHUNK_NOT_SUPPORTED  4
//#define nCapsCount 4
#define N_BISTCM2 100 // 5.33ms
#define STEP_UP 6
#define STEP_DN 3
#define CURR_STEP 5
#define T_STEPPING 100
#define TIMEOUT_SLP 20
#define N_VCONN_TURN_ON 10

#else

#define PM_TIMER_VBUSON_DELAY  200 // (TypeC - tVCONNStable Max.50ms)
#define PM_TIMER_DISCHG_DELAY  40
#define PM_TIMER_PWRGD_DELAY_N 120 // s8VoltStep==0, after tSrcTransition, delay to issue PS_RDY (Chris@20190415)
#define PM_TIMER_PWRGD_DELAY_F 10 // after discharge-off, delay to issue PS_RDY
#define PM_TIMER_PWRGD_DELAY_R 40 // after voltage transit upward, delay to issue PS_RDY
#define PM_TIMER_PWRGD_TIMEOUT 300
#define PM_TIMER_SMALL_STEP    23 // (tPpsSrcTransSmall 0~25ms)
#define PM_TIMER_LARGE_STEP    260 // (tPpsSrcTransLarge 0~275ms)
#define PM_TIMER_CC_TRANSITION 260
#define PM_TIMER_VCONNON       5
#define PM_TIMER_WAIT_CAP      400
#define T_DETACH_DISCHG_MIN    5 // discharge shall not longer than recovery period
#define T_DETACH_DISCHG_MAX    35 // the longer the hotter
#define T_PD_DEBOUNCE          10
#define T_CC_DEBOUNCE          120 // (tCCDebounce 100~200ms)
#define T_CC_SLEEP             3000
#define T_SENDER_RESPONSE      28 // 27+ms (tSenderResponse 24~30ms)
#define T_VCONN_SOURCE_ON      50
#define T_PS_HARD_RESET        30 // 29+ms (tPSHardReset 25~35ms)
#define T_SRC_TRANSITION       30 // 29+ms (tSrcTransition 25~35ms)
#define T_SRC_RECOVER          1500// for SCP 1~3S 800 // (tSrcRecover 0.66~1s)
#define T_C_SENDSRCCAP         150 // (tTypeCSendSourceCap 100~200ms)
#define T_NO_RESPONSE          5200 // (tNoResponse 4.5~5.5s)
#define T_PPS_TIMEOUT          13000 // (tPPSTimeout ~15s)
#define T_F2HR_2V8             20
#define T_F2HR_DEBNC()         30 // rev.20180321
#define T_F2OFF_DEBNC          30
#define T_CURRENT_LIMIT        30
#define T_SINK_TX              18 // (tSinkTx 16~20)
#define T_CHUNK_NOT_SUPPORTED  45 // (tChunkingNotSupported 40~50ms)
//#define nCapsCount 40 // 50
#define N_BISTCM2 800 // 42.67ms, N_BISTCM2*2*8 bits x3.33us, 30~60ms (tBISTContMode)
#define STEP_UP 1
#define STEP_DN 1
#define CURR_STEP 1
#define T_STEPPING 250
#define TIMEOUT_SLP 165 // 20ms sample rate (100KHz)
#define N_VCONN_TURN_ON 150

#endif // CFG_SIM


#define GPIO_DEBUG_INIT()   ( GPIOSH |= 0x88, P0_0 = 1, P0_1 = 1 ) // enable GPIO1/2 output (P0.0/1)
#define GPIO_DEBUG_ASSERT() ( P0_0 = 0, P0_0 = 1 )
#define DPDA_DEBUG_INIT()   ( ATM |= 0x20) // TM[1]:DP=DAC1

#define DPDM_DEBUG_INIT()   ( DPDNCTL |= 0x0A ) // D+/D- output enable
#define DM_DEBUG_OUT(v)     ( v ? (DPDNCTL |= 0x01) : (DPDNCTL &= 0xFE) ) // output to D-
#define DP_DEBUG_OUT(v)     ( v ? (DPDNCTL |= 0x04) : (DPDNCTL &= 0xFB) ) // output to D+

#define CC12_DEBUG_OUT(v)   ( v ? (ATM |= 0x0E) : (ATM |= 0x06) ) // output to CC1/CC2 depend on CC_SEL
#define CC12_DEBUG_VAL(v)   ( v ? (ATM |= 0x08) : (ATM &=~0x08) ) // output depend on r_fortxen/r_fortxrdy
#define CC12_DEBUG_END()          (ATM &=~0x0E)                   // stop driving CC1/CC2


#define nRetryCount 3
#define nHardResetCount 2

#define SID_STANDARD      0xFF00
#define VID_APPLE         0x05AC
#define VID_QUALCOMM_QC40 0x05C6
#define VID_CANYON_SEMI   0x2A41 // (10817)

#define BIG_ENDIAN(v) ((v<<8)|(v>>8))


extern BYTE xdata* lpMemXdst;
extern BYTE xdata* lpMemXsrc;
extern BYTE code*  lpMemCsrc;

void MemCopyC2X (BYTE cnt);
void MemCopyX2X (BYTE cnt);
#define MEM_COPY_C2X(dst,src,cnt) (lpMemXdst=dst,lpMemCsrc=src,MemCopyC2X(cnt))
#define MEM_COPY_X2X(dst,src,cnt) (lpMemXdst=dst,lpMemXsrc=src,MemCopyX2X(cnt))

void MtTablesInit ();
void ReloadPdoTable (bit bReloadPDO6);


#define STRT_TMR_RCV(v)   STRT_TMR0(v)
#define STOP_TMR_RCV()    STOP_TMR0()

#ifdef CAN1110X
   #define STRT_ONE_MS_TMR() STRT_TMR1(TIMEOUT_ONE_MS)
   #define STOP_ONE_MS_TMR() STOP_TMR1()
#else
   #define STRT_ONE_MS_TMR() STRT_1MSTMR()
   #define STOP_ONE_MS_TMR() STOP_1MSTMR()
#endif

extern bit bEventPE;
extern bit bEventPRLTX;
extern bit bEventPHY;

extern bit bTmr0_Step;
extern bit bTmr0_Cnti;
extern bit bTmr1_Scp;

//extern BYTE xdata TxData [];
//extern BYTE xdata RxData [];
extern WORD RxHdr;
extern BYTE TxHdrL, TxHdrH;



extern bit bPrlSent;
extern bit bPrlRcvd;
extern bit bPhySent;
extern bit bPhyPatch;
extern bit bPrlRcvTo;
extern bit bHrRcvd;

typedef enum {
   PRL_Tx_Wait_for_Message_Request,       // 0x00
   PRL_Tx_Reset_for_Transmit,             // 0x01
   PRL_Tx_Construct_Message,              // 0x02
   PRL_Tx_Wait_for_PHY_Response_TxDone,   // 0x03
   PRL_Tx_Wait_for_PHY_Done,              // 0x04
   PRL_Tx_Wait_for_PHY_Response,          // 0x05
   PRL_Tx_Match_MessageID,                // 0x06
   PRL_Tx_Message_Sent,                   // 0x07
   PRL_Tx_Check_Retry_Counter,            // 0x08
   PRL_Tx_Transmission_Error              // 0x09
}  PRL_TX_STATE_BYTE;
extern PRL_TX_STATE_BYTE u8StatePrlTx;



typedef enum {
   AMS_CMD_SENDING,              // 0x00
   AMS_RSP_RCVING,               // 0x01
   AMS_RSP_RCVD,                 // 0x02
   AMS_CRC_TIMEOUT,              // 0x03
   AMS_SND_TIMEOUT,              // 0x04
   AMS_SINK_TX_TIME,             // 0x05
   AMS_RSP_ACCEPT,               // 0x06
   AMS_RSP_REJECT,               // 0x07
   AMS_RSP_VDM,                  // 0x08
   AMS_CMD_SENT,                 // 0x09
}  AMS_STATE_BYTE;
extern AMS_STATE_BYTE u8PEAmsState;


typedef enum {
   PE_SRC_Startup,               // 0x00
   PE_SRC_Send_Capabilities,     // 0x01
   PE_SRC_Negotiate_Capability,  // 0x02
   PE_SRC_Hard_Reset,            // 0x03
   PE_SRC_Disabled,              // 0x04
   PE_SRC_Discovery,             // 0x05
   PE_SRC_Transition_Accept,     // 0x06
   PE_SRC_Transition_Supply,     // 0x07
   PE_SRC_Transition_PS_RDY,     // 0x08
   PE_SRC_Ready,                 // 0x09
   PE_SRC_Get_Sink_Cap,          // 0x0A
   PE_SRC_Capability_Response,   // 0x0B
   PE_SRC_Wait_New_Capabilities, // 0x0C
   PE_SRC_Transition_to_default, // 0x0D
   PE_SRC_Hard_Reset_Received,   // 0x0E
   PE_SRC_VDM_Identity_Request,  // 0x0F
   PE_SRC_Send_Soft_Reset,       // 0x10
   PE_SRC_Soft_Reset,            // 0x11
   PE_SRC_Send_Reject,           // 0x12
   PE_SRC_Send_Source_Alert,     // 0x13
   PE_SRC_Send_Not_Supported,    // 0x14
   PE_SRC_Chunk_Recieved,        // 0x15
   PE_SRC_Give_Source_Status,    // 0x16
   PE_SRC_Give_PPS_Status,       // 0x17
   PE_SRC_Give_Source_Cap_Ext,   // 0x18
   PE_SRC_Error_Recovery,        // 0x19
   PE_VCS_Accept_Swap,           // 0x1A
   PE_VCS_Wait_for_VCONN,        // 0x1B
   PE_VCS_Turn_On_VCONN,         // 0x1C
   PE_VCS_Send_PS_RDY,           // 0x1D
   PE_BIST_Carrier_Mode,         // 0x1E
   PE_RESP_VDM_Send_QC4_Plus,    // 0x1F
   PE_RESP_VDM_Send_Identity,    // 0x20
   PE_RESP_VDM_Get_Identity_NAK, // 0x21
   PE_DRS_Accept_Swap,           // 0x22
   PE_DRS_Send_Swap,             // 0x23
   PE_INIT_PORT_VDM_Identity_Request,
   PE_INIT_PORT_SVIDs_Request,
   PE_INIT_PORT_VDM_Modes_Request,
   PE_DFP_PORT_VDM_Modes_Entry_Request,
   PE_INIT_PORT_UVDM_Request,    // 0x28
}  PE_STATE_BYTE;
extern PE_STATE_BYTE u8StatePE;

extern bit bPESta_SVDM1;
extern bit bPESta_PD2;
extern bit bPESta_DFP;
extern bit bPESta_CONN;
extern bit bPESta_Rejt;
extern bit bRDO_Mismatch; // RDO capability mismatch bit
extern bit bPEBIST_Share; // BIST share mode entry

void PolicyEngineProc ();
void Go_PE_SRC_Send_Capabilities ();
void Go_PE_SRC_Error_Recovery ();
TRUE_FALSE IsAmsPending ();


typedef enum {
   PM_STATE_DETACHED,
   PM_STATE_DETACHING,             // 0x01, discharge VBUS
   PM_STATE_DISCHARGE,             // 0x02, discharge VIN
   PM_STATE_ATTACHING,             // 0x03
   PM_STATE_PWRGOOD,               // 0x04
   PM_STATE_ATTACHED,              // 0x05
   PM_STATE_ATTACHED_TRANS_PRE,    // 0x06
   PM_STATE_ATTACHED_TRANS,        // 0x07
   PM_STATE_ATTACHED_TRANS_PWRGD,  // 0x08
   PM_STATE_ATTACHED_TRANS_DISCHG, // 0x09
   PM_STATE_ATTACHED_TRANS_PST,    // 0x0A
   PM_STATE_ATTACHED_CC_TRANS,
   PM_STATE_ATTACHED_TRANS_LOW_DISCHG,
   PM_STATE_ATTACHED_WAIT_CAP,     // 0x0D
   PM_STATE_ATTACHED_SEND_HR,      // 0x0E
   PM_STATE_ATTACHED_AMS1,         // 0x0F
   PM_STATE_RECOVER,               // 0x10
#ifdef CFG_TWOPORT // additional PM_STATEs
   PM_STATE_DISCHARGE_VBUS_A,      // 0x11
   PM_STATE_TYPA_ONLY,             // 0x12
#endif
   PM_STATE_DETACHING_MIN,        // 0x13, discharge VBUS MIN
}  PM_STATE_BYTE;
extern PM_STATE_BYTE u8StatePM;

extern BYTE u8RDOPositionMinus;
extern BYTE u8NumSrcPdo;
extern WORD xdata PDO_V_DAC  [];
extern BYTE xdata SRC_PDO    [][4];
extern BYTE xdata OPTION_REG [];

extern BYTE code D4_OPTION[];


#define OPTION_RP1   0x01
#define OPTION_RP2   0x02
#define OPTION_OVP   0x04
#define OPTION_SCP   0x08
#define OPTION_OTP   0x10
#define OPTION_UVP   0x20
#define OPTION_CCUR  0x40
#define OPTION_RP    (OPTION_RP1|OPTION_RP2)

#define OPTION_CCMP  0x07
#define OPTION_DCP   0x08
#define OPTION_APPLE 0x10
#define OPTION_QC    0x20
#define OPTION_CAPT  0x40

//efine OPTION_VREF  0x03
//efine OPTION_FBSEL 0x02
//efine OPTION_DDSEL 0x04
#define OPTION_SLPEN 0x08
#define OPTION_QCPWR 0x10
#define OPTION_QCMIN 0x60

#define OPTION_DRSWP    0x01
#define OPTION_PDO2     0x02
//efine OPTION_CC_PROT  0x04
#define OPTION_NODISCHG 0x08
#define OPTION_ALDISCHG 0x10

#define OPTION_D4_0  OPTION_RP1
#define OPTION_D4_1  OPTION_DCP
#define OPTION_D4_2  0x00
#define OPTION_D4_3  0x00

#define IS_OPTION_OVP()    (OPTION_REG[0] & OPTION_OVP)
#define IS_OPTION_SCP()    (OPTION_REG[0] & OPTION_SCP)
#define IS_OPTION_OTP()    (OPTION_REG[0] & OPTION_OTP)
#define IS_OPTION_UVP()    (OPTION_REG[0] & OPTION_UVP)
#define IS_OPTION_CCUR()   (OPTION_REG[0] & OPTION_CCUR)

#define IS_OPTION_DCP()    (OPTION_REG[1] & OPTION_DCP)
#define IS_OPTION_APPLE()  (OPTION_REG[1] & OPTION_APPLE)
#define IS_OPTION_QC()     (OPTION_REG[1] & OPTION_QC)
#define IS_OPTION_CAPT()   (OPTION_REG[1] & OPTION_CAPT)

//efine IS_OPTION_IFB()    (OPTION_REG[2] & OPTION_IFB)
//efine IS_OPTION_FBSEL()  (OPTION_REG[2] & OPTION_FBSEL)
//efine IS_OPTION_DDSEL()  (OPTION_REG[2] & OPTION_DDSEL)
#define IS_OPTION_SLPEN()  (OPTION_REG[2] & OPTION_SLPEN)
#define IS_OPTION_QC_PWR() (OPTION_REG[2] & OPTION_QCPWR)

#define IS_OPTION_DRSWP()       (OPTION_REG[3] & OPTION_DRSWP)
#define IS_OPTION_PDO2()        (OPTION_REG[3] & OPTION_PDO2)
//efine IS_OPTION_CC_PROT()     (OPTION_REG[3] & OPTION_CC_PROT)
#define IS_OPTION_NODISCHG()    (OPTION_REG[3] & OPTION_NODISCHG)
#define IS_OPTION_ALDISCHG()    (OPTION_REG[3] & OPTION_ALDISCHG)

#define GET_OPTION_RP()    (OPTION_REG[0] & OPTION_RP)
#define GET_OPTION_CCMP()  (OPTION_REG[1] & OPTION_CCMP)
//efine GET_OPTION_VREF()  (OPTION_REG[2] & OPTION_VREF)
#define GET_OPTION_QCMIN() (OPTION_REG[2] & OPTION_QCMIN)

#ifdef CAN1110X
#define OPTION_SR 0x80
#define IS_OPTION_SR() (OPTION_REG[1] & OPTION_SR)
#define INIT_ENABLE_SR() if (IS_OPTION_SR()) { INIT_ANALOG_SR(); ENABLE_SR(); }
#else
#define INIT_ENABLE_SR()
#endif

#define TUNE_OFS_PWRV()      (FINE_TUNE[0] & 0x0f)
#define TUNE_OFS_CLUVP()    ((FINE_TUNE[0] >> 4) + 32) // 2560+ mV
#define TUNE_PWR_GOOD()      (FINE_TUNE[1] & 0x02)
#define TUNE_CCTRX()         (FINE_TUNE[1] & 0xf0)

#define MAP_PDO1_DAC()       (PDO_V_DAC[0] & 0x3FF)
#define MAP_CC_OFS()         (PDO_V_DAC[2]>>12)
#define DAC_CODE_OTP_HI()  (((PDO_V_DAC[0]>>8) & 0xF0) | (PDO_V_DAC[1]>>12))
#define DAC_CODE_OTP_LO()  (((PDO_V_DAC[3]>>8) & 0xF0) | (PDO_V_DAC[4]>>12))
#define SOURCE_PDP()       (((PDO_V_DAC[5]>>8) & 0xF0) | (PDO_V_DAC[6]>>12))

#if defined(CAN1112BX) || defined (CAN1110X)
   #define D4_FTUNE 0x7000 // CLUVP=7 (3.12V)
#else // CAN1112AX
   #define D4_FTUNE 0x7060 // CLUVP=7 (3.12V), MCCTRL=1, CCBIAS=1, OUTCTRL=0
#endif

extern BYTE FINE_TUNE[];

extern BYTE code* lpVdmTable;
extern BYTE u8NumVDO;

extern bit bDevSta_SndHR;
extern bit bDevSta_ChkCbl;
extern bit bDevSta_PPSReq;
extern bit bDevSta_PPSRdy;
extern bit bDevSta_LgStep;
extern bit bDevSta_5ACap;

extern bit bPMExtra_LetTxOK;
extern bit bPMExtra_PdoOpt;
extern bit bPMExtra_2ndNego;

void Go_PM_STATE_SEND_HR ();

void PolicyManagerOneMs ();
void PolicyManagerReset ();

extern bit bTCAttched;
extern bit bTCSleep;
extern bit bTCRaDtcd; // 20180907
void TypeCCcDetectOneMs ();

extern bit bProF2Hr;
extern bit bProF2Off;
extern bit bProCLimit;
extern bit bProCLChg;

//extern bit bEventSCPHY;
//extern bit bEvMissPhy;
extern bit bEventScprl;
extern bit bEventScpAF;

extern xdata BYTE u8ScpReg[];

//#define DEBOUNCED_OVP
// 20190718 revise to debounced OVP for system ESD
// 20190813 return to quick OVP (code=7840->7884)
void ResumeOVP ();
#define StopOVP() SET_OVPINT(0)


void SrcProtectInit ();
void SrcProtectOneMs ();


typedef enum {
   QCSTA_IDLE,    // 0x00
   QCSTA_APPLE,   // 0x01
   QCSTA_DCP,     // 0x02
   QCSTA_DMGND,   // 0x03
   QCSTA_QC20_5V, // 0x04
   QCSTA_QC20_HV, // 0x05, high voltage
   QCSTA_QC30,    // 0x06
   BCSTA_VIVO,
   BCSTA_VOOC
}  QCSTA_BYTE;
extern QCSTA_BYTE u8QcSta;

extern bit bQcSta_InQC;
extern bit bQcSta_Vooc;
void QcOneMs ();
void Qc3AccIsr ();
void QcStartup ();

TRUE_FALSE is_rxsvdm (BYTE cmd_byte, BYTE id_sel);
TRUE_FALSE is_rxsvdm_ack_discid_apple ();

extern BYTE u8CurVal;
extern BYTE u8VinVal;
extern BYTE u8TmpVal;

#include "power.h"


#include "twoport.h"
#include "dynpdp.h"
#include "kpos.h"
#include "scp.h"
#include "digitalCC.h"
#include "appledex.h"
#include "cca1.h"
#include "bbi2c.h"
#include "vooc.h"
#include "adapter_antifake.h"


#ifdef CFG_CHECKSUM
void CHECK_SUM_OR_DIE ();
#else
#define CHECK_SUM_OR_DIE()
#endif

#ifdef CFG_OVP_LATCH
extern bit btOVPLatch;
#define OVP_LATCH_INST bit btOVPLatch;
#define OVP_LATCH_SET() if (IS_OVPVAL()) btOVPLatch = 1
#define AND_NOT_OVP_LATCHED() && !btOVPLatch


#else
#define OVP_LATCH_INST
#define OVP_LATCH_SET()
#define AND_NOT_OVP_LATCHED()
#endif

#ifdef CFG_PDO1_ONLY
#define PDOGOT7_INST()             bit bPdoGot7;
#define PDOGOT7_SETUP()            if (lpPdoTable[6*4]!=0xFF) bPdoGot7 = 1
#define RELOAD_MAX_PDO6()          bPMExtra_PdoOpt // reload PDO max. 6 when 2nd nego. enabled
#define MODIFY_NPDO_EXCLUDE_APDO() (bPESta_PD2)
#define NEGO2ND_INIT_NPDO()        if (bPMExtra_PdoOpt) u8NumSrcPdo = 1; // re-define 2nd nego, 20181015
#else
#define PDOGOT7_INST()
#define PDOGOT7_SETUP()
#define RELOAD_MAX_PDO6()          0
#define MODIFY_NPDO_EXCLUDE_APDO() (bPESta_PD2 || bPMExtra_PdoOpt && !bPMExtra_2ndNego)
#define NEGO2ND_INIT_NPDO()
#endif

#ifdef CFG_PPS
#define SET_DEVSTA_PPSREQ() bDevSta_PPSReq = (PDO_HiW&0xF000)==0xC000
#define SET_DEVSTA_PPSRDY() bDevSta_PPSRdy = bDevSta_PPSReq
#define CLR_PRO_CL_CHG() bProCLChg = 0
#define SET_PRO_CL_CHG() bProCLChg = bDevSta_PPSReq & bDevSta_PPSRdy
#else
#define bDevSta_PPSReq FALSE
#define bDevSta_PPSRdy FALSE
#define bProCLChg FALSE
#define SET_DEVSTA_PPSREQ()
#define SET_DEVSTA_PPSRDY()
#define SET_PRO_CL_CHG()
#define CLR_PRO_CL_CHG()
#endif // CFG_PPS

#if defined(CFG_REDUCE_SZ) || !defined(PD_ENABLE)
#define bPMExtra_DrSwp   FALSE
#define bPMExtra_PdoOpt  FALSE
#define bPMExtra_2ndNego FALSE
#define INI_PMEXTRA_DRSWP()
#define CLR_PMEXTRA_DRSWP()
#define INI_PMEXTRA_PDOOPT()
#define SET_PMEXTRA_PDOOPT()
#define CLR_PMEXTRA_PDOOPT()
#define SET_PMEXTRA_2NDNEGO()
#define CLR_PMEXTRA_2NDNEGO()
#define Start2ndNego()
#else
#define INI_PMEXTRA_DRSWP()   bPMExtra_DrSwp = IS_OPTION_DRSWP() // bit assignment works
#define CLR_PMEXTRA_DRSWP()   bPMExtra_DrSwp = 0
#define INI_PMEXTRA_PDOOPT()  bPMExtra_PdoOpt = IS_OPTION_PDO2() // bit assignment works
#define SET_PMEXTRA_PDOOPT()  bPMExtra_PdoOpt = 1
#define CLR_PMEXTRA_PDOOPT()  bPMExtra_PdoOpt = 0
#define SET_PMEXTRA_2NDNEGO() bPMExtra_2ndNego = 1
#define CLR_PMEXTRA_2NDNEGO() bPMExtra_2ndNego = 0
#endif // CFG_REDUCE_SZ


#ifdef PD_ENABLE
extern BYTE u8TypeC_PWR_I;

void PhysicalLayerReset ();
void PhysicalLayerStartup ();
void PhysicalLayerProc ();
void TypeCResetRp ();
void SetSnkTxNG ();
void SetSnkTxOK ();
void TypeCCcDetectSleep ();
void ProtocolTxProc ();
void PolicyEngineReset (bit bStartup);
void PRL_Tx_PHY_Layer_Reset (bit bStartup);
void AMS_Start (PE_STATE_BYTE NextState);
void PolicyEngineOneMs ();
#else
#define u8TypeC_PWR_I   44
#define TypeCResetRp()
#define SetSnkTxNG()
#define SetSnkTxOK()
#define TypeCCcDetectSleep()
#define ProtocolTxProc()
#define PolicyEngineReset(x)
#define PhysicalLayerReset()
#define PhysicalLayerStartup()
#define PhysicalLayerProc()
#define PRL_Tx_PHY_Layer_Reset(x)
#define AMS_Start(x);
#define PolicyEngineOneMs()
#endif

#endif // _GLOBAL_H_
