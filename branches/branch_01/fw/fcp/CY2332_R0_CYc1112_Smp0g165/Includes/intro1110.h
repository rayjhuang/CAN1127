#ifndef _INTRO1110_H_
#define _INTRO1110_H_

/* FW data type */

typedef unsigned char  BYTE;
typedef unsigned short WORD;
typedef unsigned long  DWORD;
typedef bit TRUE_FALSE;
typedef bit SCUUESS_FAILED;
enum {
   FALSE = 0,
   TRUE = 1,
   SUCCESS = 0,
   FAILED = 1
}; // true-or-false, success-or-failed check


/* HW abstraction */
// to introduce qc.c of CY2332R0
// begin  ======================================================================
#define ADD_DPDM_CHANNELS()  ENABLE_DPDN_CHANNELS()
#define DES_DPDM_CHANNELS()  DISABLE_DPDN_CHANNELS()
#define SET_DM_PULLDWN_ENA() SET_DN_PULLDWN()
#define SET_DM_PULLDWN_DIS() SET_DN_NOT_PULLDWN()
#define SET_DPDM_SHORT_ENA() SET_DPDN_SHORT()
#define SET_DPDM_SHORT_DIS() SET_DPDN_NOT_SHORT()
#define SET_DPDM_ALL_OFF()   SET_DPDN_ALL_OFF() // clear DPDN_*
#define SET_ANALOG_CONST_CURR(v) ( v ? ENABLE_CONST_CURR() : DISABLE_CONST_CURR() )

#define START_DAC1COMP_2US_LOOP() (DACCTL = 0x07) // 2us DAC1/COMP starts
#define START_DAC1COMP_3US_LOOP() (DACCTL = 0x0B) // 3us DAC1/COMP starts
#define START_DAC1COMP_5US_LOOP() (DACCTL = 0x0F) // 5us@12MHz cycle DAC1/COMP
// end =========================================================================

#define INIT_TMRS()  (TCON = 0, TMOD = 0x11, ET0 = 1, ET1 = 1)

#undef  INIT_DAC_CHANNELS
#if defined(CFG_TS_NTC) \
 || defined(CFG_TS_ATT)
#define INIT_DAC_CHANNELS()      (DACEN  = 0xC8) // CC1/CC2/TS (IFB/VIN by switching)
#define ADD_TS_CHANNEL() // TS channel was added
#else
#define INIT_DAC_CHANNELS()      (DACEN  = 0xC0) // CC1/CC2
#define ADD_TS_CHANNEL()         ENABLE_TS_CHANNEL()
#endif
#undef  INIT_ANALOG_PK_SET_NTC
#if defined(CFG_TS_NTC) \
 || defined(CFG_TS_ATT_PULLHI)
#define INIT_ANALOG_PK_SET_NTC(v) (CCTRX  = 0x0B | v) // S100U/S20U/S2U are low-active
#define TURN_OFF_NTC_TO_SLEEP()   (CCTRX |= 0x04) // turn off NTC current source, S100U
#else
#define INIT_ANALOG_PK_SET_NTC(v) (CCTRX  = 0x0F | v) // TS floating, PK_SET=1
#define TURN_OFF_NTC_TO_SLEEP() // no current source to be turned off
#endif

#define ADD_CC_CHANNELS()        ENABLE_BOTH_CC_CHANNELS()
#define ADD_THE_CC_CHANNEL()     GO_SENSE_CC_CHANNEL()
#define DES_THE_CC_CHANNEL()     STOP_SENSE_CC_CHANNEL()
#define DES_VCONN_CHANNEL()      STOP_SENSE_VCONN_CHANNEL()

#define ENABLE_CURSNS()          INIT_ANALOG_CURSNS_EN()
#define DISABLE_CURSNS()         (CVCTL &=~0x04) // disable current sense

#define SET_ANALOG_OSC_LOW(v)    (v ? SET_OSC_SLOW() : SET_OSC_FAST()) // OSC_LOW=0/1
#undef  SET_ANALOG_SLEEP
#define SET_ANALOG_SLEEP(v)      (v ? (ATM |= 0x01) : (ATM &=~0x01)) // SLEEP=0/1
#undef  SET_RCV_SOPP
#define SET_RCV_SOPP(v)          (v ? (RXCTL |= 0x02) : (RXCTL &=~0x02))

#define INIT_ADC_CHANNELS()      (SAREN  = 0xFF)
#define RXHEADER_BELOW_PD30()    (PRLRXL < 0x80) // SpecRev < PD30
#define IS_CH_0_ON()             (DACEN &  0x01)
#define IS_CH_2_ON()             (DACEN &  0x04)
#define IS_CH_3_ON()             (DACEN &  0x08)
#define TOGGLE_CH03_SWITCH()     COMP_SWITCH_TOGGLE()
#define RESET_CH03_SWITCH()      COMP_SWITCH(0)
#define IS_CH03_SWITCHED()       (CMPOPT &  0x80)

#define START_DAC1COMP_SLEEP()   (DACCTL = 0x03) // 1us@12MHz cycle DAC1/COMP

#define SET_OVP_125()               // no 125% OVP
#define SET_ANALOG_CC_PROT(v)       // no CC1/2 protection
#define SET_ANALOG_DIS_STOP_CV(v)   // no stop-CV protection
#define SET_ANALOG_CP_CLKX2(v)      // no CP_CLKX2

#ifdef CFG_FPGA // no deived-by-2 in FPGA AFE
#define DAC1_CC_2V6 1023 // 10-bit
#define DAC1_CC_1V6 800
#define DAC1_CC_0V8 400
#define DAC1_CC_0V4 200
#define DAC1_CC_0V2 100
#else
#define DAC1_CC_2V6 650 // CC voltage threshold of detach @Rp=330uA
#define DAC1_CC_1V6 400 // CC voltage threshold of detach @Rp=180/80uA
#define DAC1_CC_0V8 200 // CC voltage threshold of Ra @Rp=330uA
#define DAC1_CC_0V4 100 // CC voltage threshold of Ra @Rp=180uA
#define DAC1_CC_0V2 50  // CC voltage threshold of Ra @Rp=80uA
#endif

#define DAC1_VIN_0V8 40 // @VIN=0.8V
#define DAC1_VSAFE_0V_MAX DAC1_VIN_0V8

#ifdef PWRGD_VFB // power-good on VFB
#define ADD_VBUS_PG_CHANNELS() (DACEN |= 0x07)
#define DES_VBUS_PG_CHANNELS() (DACEN &=~0x07)
#else
#define ADD_VBUS_PG_CHANNELS() (DACEN |= 0x03)
#define DES_VBUS_PG_CHANNELS() (DACEN &=~0x03)
#endif

#undef  IS_UNDER288
#define IS_UNDER288()            (IS_VBUS_ON() && DACV1<TUNE_OFS_CLUVP()) // VBUS < 2.56V or more

#define ANALOG_SELECT_CL()       (REGTRM5|= 0x02) // re-route OTPI to Current Limit
#define SET_OCP_CUT(v)           (v ? (REGTRM5 &=~0x01) : (REGTRM5 |= 0x01)) // TST_IFB (0/1: analog-auto by CC_ENB/forced-short)

#ifdef CFG_SLEEP_3V6
#define SET_SLEEP_3V6()          (PWR_V = 0x2D , PWRCTL &=~0x03)
#define CLR_SLEEP_3V6()
#else
#define SET_SLEEP_3V6()
#define CLR_SLEEP_3V6()
#endif

#define PWM_DLL_ENABLE()         (DACLSB |= 0xC0)
#define PWM_GATE_HI()            (PWMD    = 0x00) // PG_INV
#define PWM_GATE_LO()            (PWMD    = 0x01)
#define IS_PWM_GATE_LO()         (PWMD   == 0x01)
#define TYPA_ATT_VAL()           (CDVAL  &  0x04) // TYPA_ATT
#define GPIO3_HI()               (EXGP   &=~0x01, EXGP |= 0x02) // pullup
#define GPIO3_LO()               (EXGP   &=~0x02, EXGP |= 0x01) // pulldown
#define GPIO3_OUTPUT_MODE()      (EXGP   |= 0x04) // OE=1
#define GPIO12_OUTPUT_MODE()     (GPIOSH |= 0x88) // OE=1
#define GPIO1_OUT(v)             (v ? (P0_0 = 1) : (P0_0 = 0)) // DO=0/1
#define GPIO2_OUT(v)             (v ? (P0_1 = 1) : (P0_1 = 0)) // DO=0/1
#define GPIO3_OUT(v)             (v ? (P0_4 = 1) : (P0_4 = 0)) // DO=0/1
#define IS_GPIO1_HI()            (P0_2)

#endif // _INTRO1110_H_
