
#include "global.h"

// ?CO?MAIN(0x920) in 'Code:' column of 'BL51 Locate' tab
// *** WARNING L16: UNCALLED SEGMENT, IGNORED FOR OVERLAY PROCESS
//     SEGMENT: ?CO?MAIN
char code GenHeaderFW [16] = FIRMWARE_NAME;

#ifdef CFG_FPGA
char code UART_ISR [3] _at_ 0x23; /* Space for on-chip UART serial interrupt */
#endif

volatile BYTE bdata u8Event _at_ 0x20;
//it bEventPM     = u8Event^0; // policy manager
sbit bEventPE     = u8Event^1; // policy engine
sbit bEventPRLTX  = u8Event^2; // protocol TX
//it bEventPRLRX  = u8Event^3; // protocol RX
sbit bEventScpAF  = u8Event^3; // SCP anti fake processing RX
sbit bEventPHY    = u8Event^4; // physical
//it bEventTC     = u8Event^5; // type-C
//sbit bEventSCPHY  = u8Event^5; // SCP PHY
//it bEventCnti   = u8Event^6; // continuous mode pulse
sbit bEventScprl  = u8Event^6; // SCP/FCP
sbit bEvent1MS    = u8Event^7; // 1-ms

volatile BYTE bdata u8TmrBits _at_ 0x27;
sbit bTmr0_Step   = u8TmrBits^0; // timer0 for Policy Manager (power stepping)
sbit bTmr1_Scp    = u8TmrBits^1; // timer1 for SCP UI
sbit bTmr1_Vooc   = u8TmrBits^2; // timer1 for OPPC
#ifndef CAN1112BX
sbit bTmr0_Cnti   = u8TmrBits^6; // dominant mode, for 200us-pulse support
#endif


/*
volatile BYTE idata u8IsBuf[4];
volatile BYTE idata u8VbusBuf[4];
volatile BYTE idata index=0;
volatile BYTE idata u8Is=0;
volatile BYTE idata u8Vbus=0;*/

extern BYTE u8RetryCounter;
void PhysicalLayerSend (bit bPhyRetry);
void IsrTimer0 () interrupt INT_VECT_TIMER0
{
    STOP_TMR0(); // timeout
#ifndef CAN1112BX
    if (bTmr0_Cnti)
    {
        Qc3AccIsr();
    }
    else
#endif
    {
        if (bTmr0_Step)
        {
            PwrTransIsr();
        }
#ifdef PD_ENABLE
        else if (bTCSleep)
        {
            TypeCCcDetectSleep();
            if (bTCSleep) STRT_TMR0(TIMEOUT_SLP);
        }
        else // CRCReceiveTimer timeout (tReceive)
        {
            bEventPRLTX = 1;
            bPrlRcvTo = 1;
            if (u8StatePrlTx == PRL_Tx_Wait_for_PHY_Response
                    && u8RetryCounter < (bPESta_PD2 ? nRetryCount : nRetryCount-1))
         {  // the packet starts first, PRL state machine runs later
            PhysicalLayerSend (1); // WARNING L15: MULTIPLE CALL TO SEGMENT
         }
        }
#endif
     }
}

#if defined(VOOC_ENABLE) | defined(SCP_ENABLE) // no sleep mode in these applications
void IsrTimer1 () interrupt INT_VECT_TIMER1
{
    STOP_TMR1(); // timeout
#ifdef SCP_ENABLE
    if(bTmr1_Scp)
    {
//        bEventSCPHY = 1;
      if(Scp_CheckCount())
      {
        ScpPhyProc ();
      }
      bTmr1_Scp=0;
    }
    else
#endif
#ifdef VOOC_ENABLE
    {
        if(bTmr1_Vooc)  bTmr1_Vooc=0;
    }
#endif
    {}
}
#endif

void IsrOneMsTimer () interrupt
#ifdef CAN1110X
INT_VECT_TIMER1
{
    STOP_ONE_MS_TMR();
    STRT_ONE_MS_TMR();
#else // CAN1112X
INT_VECT_TMS
{
#endif
    bEvent1MS = 1;
}

BYTE u8CurVal;
BYTE u8VinVal;
BYTE u8TmpVal;
bit bMsNot1st; // not the 1st-time one-ms procedure

void OneMsProc ()
{
// DEBUG BEGIN
// DM_DEBUG_OUT(IS_CLVAL())
// DM_DEBUG_OUT(IS_OCPVAL())
// DEBUG END

#ifdef CAN1112BX // without CH03_SWITCHING
   if (IS_CH_2_ON()) u8CurVal = CaliADC(DACV2);
   if (IS_CH_3_ON()) u8TmpVal = CaliADC(DACV3);
   if (IS_CH_0_ON()) u8VinVal = CaliADC(DACV0);
#else // CAN1112AX/CAN1110X, 2ms sampling VIN/IS, TS initially 2ms unknown
#ifdef PWRGD_VFB
    if (IS_CH_2_ON()) u8VinVal = DACV2;
   if (IS_CH03_SWITCHED()) { if (IS_CH_0_ON()) u8CurVal = DACV0; }
                      else { if (IS_CH_3_ON()) u8TmpVal = DACV3; }
#else
   if (IS_CH03_SWITCHED()) { if (IS_CH_0_ON()) u8CurVal = DACV0; }
                      else { if (IS_CH_3_ON()) u8TmpVal = DACV3;
                             if (IS_CH_0_ON()) u8VinVal = DACV0; }
#endif // PWRGD_VFB
    TOGGLE_CH03_SWITCH(); // note: channel 0/3 may be turned off (QC3)
#endif

    SrcProtectOneMs();
    TypeCCcDetectOneMs();
    PolicyManagerOneMs();
    PolicyEngineOneMs();
    QcOneMs();

// DELAY_INIT_SFR: delayed hardware initialization
// CAN1110C/D/E:
// ANALOG_TOP issue: cannot cut-out IFB (always connected)
// connect far away after ENABLE_CURSNS() (delayed-connected)
// or IFB will be coupled and stay on a voltage, introducing a IS offset
    if (!bMsNot1st)
    {
#ifdef CFG_CAN1110CX
        INIT_ANALOG_IFB_CONNECTED(); // correspond to init CC mode
#else // CFG_CAN1110F/CAN1112X
        SET_OCP_CUT(1); // analog-auto switching by CC_ENB
#endif
        bMsNot1st = 1;
    }
    else
    {
        bbi2c_tick();
        CCA1_MsTick();
        TwoPort_AttDetOneMs();
        DynPDP_AttDetOneMs();
        DigitalCC_MsTick();
    }

    bEvent1MS = 0; // to see how long this routine takes in simulation
}

void main ()
{
   ATM=0x00;
   V5_RESET();
   CHECK_SUM_OR_DIE();
// while (GenHeaderFW[0]!="C") {} // 22 bytes
// PPE_INIT_SFR: pre-init hardware initialization
   TWOPORT_INIT(); // turn off Type-A VBUS ASAP
   INIT_DAC_CHANNELS();
   INIT_ADC_CHANNELS();
   SET_V5OCP_EN(); // initialize PROCTL
   DIGITALCC_INIT(); // initialize OCP mode for digital CC
   DYNPDP_INIT(); // turn off GPIO5 if needed
   CCA1_INIT();
   bbi2c_init();

   MtTablesInit();
   TypeCResetRp(); // set u8TypeC_PWR_I for setting PWR_I in PM
   PhysicalLayerReset();
   PolicyManagerReset();
   SrcProtectInit();
   ScpPrlInit();

// POST_INIT_SFR: post-init hardware initialization
   INIT_ANALOG_CABLE_DETECT();
   INIT_ANALOG_DAC_EN();
   SET_ANALOG_CC_PROT(1);
   SET_ANALOG_DIS_STOP_CV(1); // always disable stopping CV in CAN1112B0
   ENABLE_CURSNS();
   ANALOG_SELECT_CL();

   if (GET_OPTION_CCMP() > 2) SET_OVP_125(); // 20180907, 20190715
// SET_ANALOG_CABLE_COMP(); // move into PolicyManagerReset() for CCOMP run-time changed

   INIT_ENABLE_SR();

   INIT_ANALOG_PK_SET_NTC(TUNE_CCTRX());
   SET_RP_ON();
   SET_RD_OFF();
   START_DAC1COMP_5US_LOOP();
/*   
   {
      BYTE idata  i,j;
   for(i=0;i<100;i++)
      {
         
           SET_RP2_OFF();
   for(j=0;j<255;j++) i=i;;
               SET_RP_ON();
   for(j=0;j<255;j++) i=i;
         
      }
   }*/

// DPDM_DEBUG_INIT();
// GPIO_DEBUG_INIT();
// DPDA_DEBUG_INIT();

// CC12_DEBUG_OUT(1);
// CC12_DEBUG_VAL(0);
// CC12_DEBUG_END();

// IP0 |= 0x02; // set group 1 (TIMER0-0x0B, HWI2C-0x4B, 0x8B) level 1
   INIT_TMRS();
//   INIT_TMR1();
   ET1 = 1;         // enable timer for SCP and VOOC

    STRT_ONE_MS_TMR();
    EA = 1; // enable interrupts

    while (1)
    {
        if (u8Event)
        {
//       if (bEventTC)    TypeCCcDetectProc();
//       if (bEventPM)    PolicyManagerProc();
            if (bEventPE)    PolicyEngineProc();
//            if (bEventPRLTX) ProtocolTxProc();
//       if (bEventPRLRX) ProtocolRxProc();
//            if (bEventPHY)   PhysicalLayerProc();
//            if (bEventSCPHY) ScpPhyProc();
            if (bEventScprl) ScpPrlProc();
            if (bEvent1MS)   OneMsProc();
            if (bEventScpAF) ScpSHA256Proc();
//         SCP_PROC();
        }
    }
}
