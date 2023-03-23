#ifndef _TWOPORT_H_
#define _TWOPORT_H_

#ifdef CFG_TWOPORT

#define TWOPORT_MAX_PWR_I 4000/50 // 4A
#define TYPA_DETACH_2S

void TwoPort_TypaTurnOnVBUS ();
void TwoPort_AttDetOneMs ();
void ModifyPDO2A4 ();
void TwoPort_ChgProc ();
bit  TwoPort_ReAttach ();

extern bit bTAAttched;
extern bit bTypaAttChg;
extern bit bLatchTypa;

extern bit bPMExtra_TpNego;
extern WORD u16PMTimer;

#ifdef CAN1112BX
#define CLEAR_CNTI()
#else
#define CLEAR_CNTI() (bTmr0_Cnti=0)
#endif

#define PRE_TYPA_RE_ATTACH()        { bQcSta_InQC=0; CLEAR_CNTI(); }
#define TYPA_RE_ATTACH()            { bTAAttched = 0; }
#define TYPC_TO_DETACH()            TwoPort_ReAttach()
#define ANY_ATTACHED()              (bTCAttched || bTAAttched)

#define IS_QC_VBUS_ON()             IS_TYPA_VBUS_ON()
#define IS_QC_DISABLED_BY_PD()      FALSE
#define DISCHARGE_QC_ENA()          DISCHARGE_TYPEA_ENA()
#define DISCHARGE_QC_OFF()          DISCHARGE_TYPEA_OFF()

#ifdef TWOPORT_CFG_ADET_GATEZ_GPIO3 // CY2313/CY231124Q
#define TWOPORT_INIT()              (PWM_DLL_ENABLE(),GPIO3_OUTPUT_MODE())
#define GET_TYPA_ATT()              TYPA_ATT_VAL()
#define IS_TYPA_VBUS_ON()           IS_PWM_GATE_LO()
#define SET_TYPA_VBUS_ON()          PWM_GATE_LO()
#define SET_TYPA_VBUS_OFF()         PWM_GATE_HI()
#define DISCHARGE_TYPEA_ENA()       GPIO3_OUT(1)
#define DISCHARGE_TYPEA_OFF()       GPIO3_OUT(0)
#endif
#ifdef TWOPORT_CFG_TS_GPIO1_GPIO2 // AP43971
#define ADC_VALUE_TS (162) // 1.3V (1296mV)
#define TWOPORT_INIT()              (GPIO12_OUTPUT_MODE())
#define GET_TYPA_ATT()              (u8TmpVal > ADC_VALUE_TS) // 20190513 for the PCB
#define IS_TYPA_VBUS_ON()           IS_GPIO1_HI()
#define SET_TYPA_VBUS_ON()          GPIO1_OUT(1)
#define SET_TYPA_VBUS_OFF()         GPIO1_OUT(0)
#define DISCHARGE_TYPEA_ENA()       GPIO2_OUT(1)
#define DISCHARGE_TYPEA_OFF()       GPIO2_OUT(0)
#endif
#ifdef TWOPORT_CFG_TSZ_GPIO3_GPIO4 // AP43971 (2019/06/12 new-defined bonding)
#define ADC_VALUE_TS (162) // 1.3V (1296mV)
#define TWOPORT_INIT()              (GPIO34_OUTPUT_MODE())
#define GET_TYPA_ATT()              (u8TmpVal < ADC_VALUE_TS) // TS-low attaching
#define IS_TYPA_VBUS_ON()           IS_GPIO3_HI()
#define SET_TYPA_VBUS_ON()          GPIO3_OUT(1)
#define SET_TYPA_VBUS_OFF()         GPIO3_OUT(0)
#define DISCHARGE_TYPEA_ENA()       GPIO4_OUT(1)
#define DISCHARGE_TYPEA_OFF()       GPIO4_OUT(0)
#endif
#ifdef TWOPORT_CFG_GPIO5_GPIO3_GPIO4 // CY2332-24Q (2019/08/01 for 1A1C Car Charger)
#define TWOPORT_INIT()              (GPIO34_OUTPUT_MODE())
#define GET_TYPA_ATT()              !IS_GPIO5_HI()
#define IS_TYPA_VBUS_ON()           IS_GPIO3_HI()
#define SET_TYPA_VBUS_ON()          GPIO3_OUT(1)
#define SET_TYPA_VBUS_OFF()         GPIO3_OUT(0)
#define DISCHARGE_TYPEA_ENA()       GPIO4_OUT(1)
#define DISCHARGE_TYPEA_OFF()       GPIO4_OUT(0)
#endif

#define TWOPORT_DISABLE_APPLE()     if (TWOPORT_WITHOUT_APPLE()) Go_QCSTA_IDLE ()
#define TWOPORT_WITHOUT_APPLE()     (bTCAttched && !bQcOpt_PWR) // to disable APPLE if 18W
#define TWOPORT_WITHOUT_QC()        bTCAttched // to disable QC
#define TWOPORT_LATCH_TYPA()        if (bTAAttched && bTCAttched) bLatchTypa = 1 // 15-byte
#define TWOPORT_CHANGE_PROC()       else if (bTypaAttChg | bPMExtra_TpNego) TwoPort_ChgProc ();
#ifndef CFG_DYNTWOPORT
#define TWOPORT_TARGET_I()          (bTCAttched && bTAAttched ) ? TWOPORT_MAX_PWR_I \
                                                        : GetFixdPDOPwrI() // plug A->C nego, C->A re-nego
#else
#define TWOPORT_TARGET_I()					GetFixdPDOPwrI()
#endif

#define DISCHARGE_TYPA_TRANS()      if (IS_TYPA_VBUS_ON()) DISCHARGE_TYPEA_ENA();
#define DISCHARGE_TYPC_TRANS()      if (IS_VBUS_ON())      DISCHARGE_ENA()

#define DISCHARGE_TYPA_DETCH()      if (bTypaPwred) DISCHARGE_TYPEA_ENA();
#define DISCHARGE_TYPC_DETCH()      if (bTypcPwred) DISCHARGE_ENA()
#define SAVE_PWR_STATUS() \
   bit bTypcPwred = IS_VBUS_ON() || bTCAttched, \
       bTypaPwred = IS_TYPA_VBUS_ON() // because of Type-A latch function

#define SET_DPDM_FREE()             SET_2V7_DMDWN_OFF() // to support DCP in A-detached/C-attached state
                                                        // don't disable D+/D- short as SET_DPDM_ALL_OFF()
#else

#define PRE_TYPA_RE_ATTACH()
#define TYPA_RE_ATTACH()
#define TYPC_TO_DETACH()            (!bTCAttched)
#define ANY_ATTACHED()              (bTCAttched)

#define IS_QC_VBUS_ON()             IS_VBUS_ON()
#define IS_QC_DISABLED_BY_PD()      (bPESta_CONN)
#define DISCHARGE_QC_ENA()          DISCHARGE_ENA()
#define DISCHARGE_QC_OFF()          DISCHARGE_OFF()

#define SET_TYPA_VBUS_OFF()
#define DISCHARGE_TYPEA_OFF()

#define TWOPORT_INIT()
#define TWOPORT_DISABLE_APPLE()
#define TWOPORT_WITHOUT_APPLE()     FALSE
#define TWOPORT_WITHOUT_QC()        FALSE
#define TWOPORT_LATCH_TYPA()
#define TWOPORT_CHANGE_PROC()
#define TWOPORT_TARGET_I()          GetFixdPDOPwrI()

#define DISCHARGE_TYPA_TRANS()
#define DISCHARGE_TYPC_TRANS()      DISCHARGE_ENA()

#define DISCHARGE_TYPA_DETCH()
#define DISCHARGE_TYPC_DETCH()      DISCHARGE_ENA()
#define SAVE_PWR_STATUS()

#define SET_DPDM_FREE()             SET_DPDM_ALL_OFF() // to support DCP in A-detached/C-attached state

#define TwoPort_TypaTurnOnVBUS()
#define TwoPort_AttDetOneMs()

#endif // CFG_TWOPORT

#endif // _TWOPORT_H_
