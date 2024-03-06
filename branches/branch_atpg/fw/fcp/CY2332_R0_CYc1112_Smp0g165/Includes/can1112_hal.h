#ifndef _CAN1112_HAL_H_
#define _CAN1112_HAL_H_


/* CAN1112 ISR */

#define INT_VECT_INT0    0 // 03h, EXINT0_INT_VECT (low/fall)
#define INT_VECT_TIMER0  1 // 0Bh
#define INT_VECT_INT1    2 // 13h, EXINT1_INT_VECT (low/fall)
#define INT_VECT_TIMER1  3 // 1Bh
#define INT_VECT_UART0   4 // 23H
#define INT_VECT_I2C     5 // 2Bh, TIMER2

#define INT_VECT_COMP    8 // 43h, EXINT7_INT_VECT, (rise), SDA
#define INT_VECT_HWI2C   9 // 4Bh, EXINT2_INT_VECT,~(fall/rise), MISO
#define INT_VECT_P0     10 // 53h, EXINT3_INT_VECT,~(fall/rise)
#define INT_VECT_UPDRX  11 // 5Bh, EXINT4_INT_VECT, (rise)
#define INT_VECT_UPDTX  12 // 63h, EXINT5_INT_VECT, (rise)
#define INT_VECT_SRC    13 // 6Bh, EXINT6_INT_VECT, (rise)

#define INT_VECT_TMS    17 // 8Bh, EXINT8_INT_VECT, (rise)
#define INT_VECT_FCP    18 // 93h, EXINT9_INT_VECT, (rise)


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

#define INIT_TMRS()  (TCON = 0, TMOD = 0x11, ET0 = 1)

#define INIT_TMR0()  (TR0 = 0, TMOD = (TMOD & 0xFC) | 0x01, ET0 = 1)
#define STOP_TMR0()  (TR0 = 0)
#define STRT_TMR0(v) (TH0 = ((-(v)) >> 8), \
                      TL0 = (-(v)),        \
                      TR0 = 1)

#define INIT_TMR1()  (TR1 = 0, TMOD = (TMOD & 0xCF) | 0x10, ET1 = 1)
#define STOP_TMR1()  (TR1 = 0)
#define STRT_TMR1(v) (TH1 = ((- v) >> 8), \
                      TL1 = ( - v),       \
                      TR1 = 1)

#define STRT_1MSTMR() (IEN2 |= 0x02)
#define STOP_1MSTMR() (IEN2 &=~0x02)

#ifdef CFG_FPGA // 25mV/LSB, less linearity
#define DAC0_PWRV5V0  0x0C8 //  47x4=0x0BC (8'h2F,2'h0)
#define DAC0_PWRV9V0  0x168 //  86x4=0x158 (8'h56,2'h0)
#define DAC0_PWRV12V  0x1E0 // 120x4=0x1E0 (8'h78,2'h0)
#define DAC0_PWRV14V8 0x250 // 148x4=0x250
#define DAC0_PWRV15V  0x258 // 150x4=0x258 (8'h96,2'h0)
#define DAC0_PWRV20V  0x320 // 200x4=0x320 (8'hC8,2'h0)
#else // 20mV/LSB
#define DAC0_PWRV5V0  0x0FA // 250=0x0FA (8'h3E,2'h2), shall be the same as VSafe5V??
#define DAC0_PWRV9V0  0x1C2 // 450=0x1C2 (8'h70,2'h2)
#define DAC0_PWRV12V  0x258 // 600=0x258 (8'h96,2'h0)
#define DAC0_PWRV14V8 0x2E4 // 750=0x2EE (8'hBB,2'h2)
#define DAC0_PWRV15V  0x2EE // 750=0x2EE (8'hBB,2'h2)
#define DAC0_PWRV20V  0x3E8 //1000=0x3E8 (8'hFA,2'h0)
#endif

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

#define IS_DAC1COMP_BUSY()   (DACCTL &  0x01)
#define START_DAC1_ONCE()    (DACCTL |= 0x01)
#define START_DAC1_LOOP()    (DACCTL |= 0x03) // DAC1/COMP starts (some SFRs are to be protected)
#define STOP_DAC1COMP()      (DACCTL &=~0x03) // stop DAC1/COMP

#define START_DAC1COMP_SLEEP()    (DACCTL = 0x03) // 1us@12MHz cycle DAC1/COMP
#define START_DAC1COMP_2US_LOOP() (DACCTL = 0x07) // 2us DAC1/COMP starts
#define START_DAC1COMP_3US_LOOP() (DACCTL = 0x0B) // 3us DAC1/COMP starts
#define START_DAC1COMP_5US_LOOP() (DACCTL = 0x0F) // 5us@12MHz cycle DAC1/COMP

#ifdef CAN1112BX
   #define SET_DPDM_SHORT_ENA()  (ACCCTL |= 0x10) // let D+/D- short
   #define SET_DPDM_SHORT_DIS()  (ACCCTL &=~0x10) // D+/D- not short
   #ifdef CFG_CAN1112B0
      #define SET_DM_FAULT_ENA() (StopOVP(), AOPT |= 0x88) // DNCHK_EN=1,DIS_STOP_CV=1
   #else // CAN1112B1X
      #define SET_DM_FAULT_ENA() (StopOVP(), AOPT |= 0x08) // DNCHK_EN=1
   #endif
   #define SET_DM_FAULT_DIS()               (AOPT &=~0x08) // DNCHK_EN=0
#else // CAN1112AX
   #define SET_DPDM_SHORT_ENA()  (PWRCTL |= 0x08) // let D+/D- short
   #define SET_DPDM_SHORT_DIS()  (PWRCTL &=~0x08) // D+/D- not short
#endif

#define ENABLE_DPDM_UART()      (PWRCTL |=0xC0) //set bpbm to uart
#define DISABLE_DPDM_UART()     (PWRCTL &=~0xC0) //set bpbm

#define SET_DM_PULLDWN_ENA() (DPDNCTL |= 0x10) // D- pulldown
#define SET_DM_PULLDWN_DIS() (DPDNCTL &=~0x10) // D- not pulldown
#define SET_2V7_ON()         (DPDNCTL |= 0xC0) // turn on D+ 2.7V driver
#define SET_2V7_OFF()        (DPDNCTL &=~0xC0) // turn off D+ 2.7V driver
#define SET_2V7_DMDWN_OFF()  (DPDNCTL &=~0xD0) // turn off D+ 2.7V driver and D- pulldown
#define SET_2V7_SHORT_OFF()  (SET_DPDM_SHORT_DIS(),SET_2V7_OFF()) // turn off D+ 2.7V driver and D+/D- short
#define SET_DPDM_ALL_OFF()   (SET_DPDM_SHORT_DIS(),SET_2V7_DMDWN_OFF()) // clear DPDN_*
#define SET_DPDMOUT_DIS()    (DPDNCTL &= ~0x0F)			// float the Dp/Dn lines

#define IS_OCP_EN()                (CVCTL  &  0x01) // CC_ENB=1 (CC disabled) == OCP enabled
#define SET_OVP_125()              (CVCTL  |= 0x40) // 125% OVP (OVP_SEL[1:0]=1)
#define SET_OCP_CUT(v)             (v ? (CVCTL |= 0x10) : (CVCTL &=~0x10)) // IFB_CUT (0/1: forced connected/analog-auto by CC_ENB)
#define DISABLE_CURSNS()           (CVCTL  &=~0x04) // disable current sense
#define ENABLE_CURSNS()            (CVCTL  |= 0x04) // enable current sense
#define ANALOG_SELECT_CL()         (AOPT   |= 0x02) // re-route OTPI to Current Limit (CL: OTP_CF=1)
#define INIT_ANALOG_CABLE_DETECT() // no cable detector
#define INIT_ANALOG_DAC_EN()       (DACLSB |= 0x04) // OCP_EN (DAC_EN)

#if defined(CFG_TS_NTC) \
 || defined(CFG_TS_ATT)
   #ifdef CAN1112BX
   #define INIT_DAC_CHANNELS()     (DACEN   = 0xCC) // CC1/CC2/TS/IFB
   #else // CAN1112AX
   #define INIT_DAC_CHANNELS()     (DACEN   = 0xC8) // CC1/CC2/TS (IFB/VIN by switching)
   #endif
   #define ADD_TS_CHANNEL() // TS channel was added
#else
   #ifdef CAN1112BX
   #define INIT_DAC_CHANNELS()     (DACEN   = 0xC4) // CC1/CC2/IFB
   #else // CAN1112AX
   #define INIT_DAC_CHANNELS()     (DACEN   = 0xC0) // CC1/CC2 (IFB/VIN by switching)
   #endif
   #define ADD_TS_CHANNEL()        (DACEN  |= 0x08)
#endif
//efine INIT_ANALOG_PK_SET_NTC()   (CCTRX  |= 0x6C) // PK_SET = 1, 100uA NTC (and TX rise/fall 20180731)
//efine INIT_ANALOG_PK_SET_NTC()   (CCTRX  |= 0x2C) // PK_SET = 1, 100uA NTC (and TX rise/fall 20180803)
#if defined(CFG_TS_NTC) \
 || defined(CFG_TS_ATT_PULLHI)
   #define INIT_ANALOG_PK_SET_NTC(v) (CCTRX  = 0x0B | v) // S100U/S20U/S2U are low-active, 20180928
   #define TURN_OFF_NTC_TO_SLEEP()   (CCTRX |= 0x04) // turn off NTC current source, S100U
#else
   #define INIT_ANALOG_PK_SET_NTC(v) (CCTRX  = 0x0F | v) // TS floating, PK_SET=1
   #define TURN_OFF_NTC_TO_SLEEP() // no current source to be turned off
#endif

#ifdef CFG_CALI_DACS
#define SKIP_V_1536()              (bCaliNon ? (REGTRM3 & 0x08) : (CALI_TABLE[3] & 0x08)) // REGTRM[27]
#define SKIP_V_1024()              (bCaliNon ? (REGTRM3 & 0x10) : (CALI_TABLE[3] & 0x02)) // REGTRM[28]
#define SKIP_V_1025()              (bCaliNon ? (REGTRM4 & 0x20) : (CALI_TABLE[3] & 0x04)) // REGTRM[37]
#define SKIP_V_0512()              (bCaliNon ? (REGTRM3 & 0x20) : (CALI_TABLE[3] & 0x01)) // REGTRM[29]

#else
#define SKIP_V_1536()              (REGTRM3 & 0x08) // REGTRM[27]
#define SKIP_V_1024()              (REGTRM3 & 0x10) // REGTRM[28]
#define SKIP_V_1025()              (REGTRM4 & 0x20) // REGTRM[37]
#define SKIP_V_0512()              (REGTRM3 & 0x20) // REGTRM[29]
#endif

#define SET_ANALOG_CABLE_COMP()    (CMPOPT  = (CMPOPT & ~0x07) | GET_OPTION_CCMP()) // cable compensation
#define CLR_ANALOG_CABLE_COMP()    (CMPOPT &= (~0x07))

#define SET_ANALOG_OSC_LOW(v)      (v ? (OSCCTL |= 0x02) : (OSCCTL &=~0x02)) // OSC_LOW=0/1
#define SET_ANALOG_SLEEP(v)        (v ? (ATM    |= 0x01) : (ATM    &=~0x01)) // SLEEP=0/1
#define SET_ANALOG_CONST_CURR(v)   (v ? (CVCTL  &=~0x01) : (CVCTL  |= 0x01)) // CC_ENB = 0 to enable CC

#ifdef CFG_CAN1112B0
   #define SET_ANALOG_DIS_STOP_CV(v) (v ? (AOPT   |= 0x80) : (AOPT   &=~0x80)) // DIS_STOP_CV=0/1
   #define SET_ANALOG_CP_CLKX2(v)
#else // CAN1112AX, CAN1112B1X
   #define SET_ANALOG_DIS_STOP_CV(v)
   #ifdef CAN1112BX
      #define SET_ANALOG_CP_CLKX2(v) (v ? (AOPT   |= 0x80) : (AOPT   &=~0x80)) // CP_CLKX2=0/1
   #else
      #define SET_ANALOG_CP_CLKX2(v)
   #endif
#endif

#ifdef CFG_CC_PROT
//efine SET_ANALOG_CC_PROT(v)      (v && IS_OPTION_CC_PROT() ? (DACLSB |= 0x20) : (DACLSB &=~0x20)) // CC_PROT=0/1
#define SET_ANALOG_CC_PROT(v)      (v                        ? (DACLSB |= 0x20) : (DACLSB &=~0x20)) // CC_PROT=0/1
#else
#define SET_ANALOG_CC_PROT(v)
#endif

#define SET_RCV_SOPP(v)            (v ? (RXCTL  |= 0x02) : (RXCTL  &=~0x02))

#define IS_UNDER288() (IS_VBUS_ON() && CaliADC(DACV1)<TUNE_OFS_CLUVP()) // VBUS < 2.56V or more

#define SET_FLIP()              (CCCTL |= 0x01) // to select CC2 (flipped)
#define NON_FLIP()              (CCCTL &=~0x01) // to select CC1 (non-flipped)
#define IS_FLIP()               (CCCTL &  0x01) // orientation (0/1: non-flipped/flipped)
#define TOGGLE_FLIP()           (CCCTL ^= 0x01)

#define RESET_AUTO_GOODCRC()    (PRLTX  = 0x07) // POR value
#define RXHEADER_BELOW_PD30()   (PRLRXL < 0x80) // SpecRev < PD30

#define INIT_ADC_CHANNELS()     (SAREN  = 0xFF)

#define ADD_CC_CHANNELS()       (DACEN |= 0xC0)
#define ADD_THE_CC_CHANNEL()    (DACEN |= (IS_FLIP()) ? 0x80 : 0x40) // the selected CC
#define DES_THE_CC_CHANNEL()    (DACEN &= (IS_FLIP()) ?~0x80 :~0x40)
#define DES_VCONN_CHANNEL()     (DACEN &= (IS_FLIP()) ?~0x40 :~0x80)
#define SET_DPDM_CHANNELS()     (DACEN  = 0x30)
#define ADD_DPDM_CHANNELS()     (DACEN |= 0x30)
#define DES_DPDM_CHANNELS()     (DACEN &=~0x30) // de-select

#define IS_CH_0_ON()            (DACEN &  0x01)
#define IS_CH_2_ON()            (DACEN &  0x04)
#define IS_CH_3_ON()            (DACEN &  0x08)

#define ADD_VBUS_PG_CHANNELS() (DACEN |= 0x03)
#define DES_VBUS_PG_CHANNELS() (DACEN &=~0x03)

#define TOGGLE_CH03_SWITCH()    (CMPOPT ^= 0x80)
#define RESET_CH03_SWITCH()     (CMPOPT &=~0x80)
#define IS_CH03_SWITCHED()      (CMPOPT &  0x80)

#define SET_RD_OFF()
#define SET_RP_VAL(v)    (CCCTL  = (CCCTL &~0x30) | (v << 4))
#define SET_RP_ON()      (CCCTL |= 0xC0)
#define SET_RP_OFF()     (CCCTL &=~0xC0)
#define SET_RP1_OFF()    (CCCTL &=~0x40)
#define SET_RP2_OFF()    (CCCTL &=~0x80)
#define SET_RP1_ON()    (CCCTL |=0x40)
#define SET_RP2_ON()    (CCCTL |=0x80)


#define SET_DRV0_ON()    (CCCTL |= 0x02)
#define SET_DRV0_OFF()   (CCCTL &=~0x02)
#define IS_DRV0_ON()     (CCCTL &  0x02)

#define IS_VCONN_ON1()   (SRCCTL &  0x04)
#define IS_VCONN_ON2()   (SRCCTL &  0x08)
#define IS_VCONN_ON()    (SRCCTL &  0x0C)
#define SET_VCONN_ON()   (IS_FLIP() ? (SRCCTL |= 0x04) : (SRCCTL |= 0x08))
#define SET_VCONN_OFF()  (SRCCTL &=~0x0C)

#define DISCHARGE_ENA()  (SRCCTL |= 0x02)
#define DISCHARGE_OFF()  (SRCCTL &=~0x02)
#define IS_DISCHARGE()   (SRCCTL &  0x02)

#ifdef CFG_BBI2C
#define SET_VBUS_ON()    GPIO4_OUT(1)
#define SET_VBUS_OFF()   GPIO4_OUT(0)
#define IS_VBUS_ON()     IS_GPIO4_HI()
#else
#define SET_VBUS_ON()    (SRCCTL |= 0x01)
#define SET_VBUS_OFF()   (SRCCTL &=~0x01)
#define IS_VBUS_ON()     (SRCCTL &  0x01)
#endif

#ifdef CFG_CAN1121A0
#define GET_PWR_I()      (PWR_I)
#define SET_PWR_I(v)     (PWR_I = (v<<1))
#define PWR_V_UPPER_BOUND 0x41A // 1050 = 21V
#define GET_PWR_V()      (PWRCTL & 0x07) | ((WORD)PWR_V << 3)
#define SET_PWR_V(v)     (PWRCTL = (PWRCTL & ~0x07) | v & 0x07, \
                          PWR_V = (v >> 3))
#else
#define GET_PWR_I()      (PWR_I & 0x7F)
#define SET_PWR_I(v)     (PWR_I = (PWR_I & 0x80) | (v & 0x7F))
#define PWR_V_UPPER_BOUND 0x3FF // 1023 = 20.46V
#define GET_PWR_V()      (PWRCTL & 0x03) | ((WORD)PWR_V << 2)
#define SET_PWR_V(v)     (PWRCTL = (PWRCTL & ~0x03) | v & 0x03, \
                          PWR_V = (v >> 2)) // PWR_V must be the last in CAN1112
#endif

#define SET_SCPINT(v)    (v ?(PROCTL |= 0x10) :(PROCTL &=~0x10))
#define SET_OVPINT(v)    (v ?(PROCTL |= 0x04) :(PROCTL &=~0x04))
#define OVP_ACTIVE()         (PROCTL &  0x04)

#define SET_V5OCP_EN()   (PROCTL =  0x20) // V5OCP will gating VCONN

#ifdef CAN1112BX
#define IS_DM_FAULT()    (PROVAL &  0x80)
#endif
#define IS_CLVAL()       (PROVAL &  0x08) // OTPI can becomes CL since CAN1110C0
#define IS_OTPVAL()      (~COMPI &  0x08) // NTC resistance is below the threshold
#define IS_UVPVAL()      (PROVAL &  0x01)
#define IS_OCPVAL()      (PROVAL &  0x02)
#define IS_OVPVAL()      (PROVAL &  0x04)
#define IS_SCPVAL()      (PROVAL &  0x10)
#define IS_F2OFFVAL()    (PROVAL &  0x14) // fault-to-off, SCP/OVP
#define IS_V5OCPSTA()    (PROSTA &  0x20)
#define IS_F2OFFSTA()    (PROSTA &  0x14)
#define CLR_V5OCPSTA()   (PROSTA |= 0x20)
#define CLR_OVPSTA()     (PROSTA |= 0x04) // clear OVP status before resume OVP
#define CLR_F2OFFSTA()   (PROSTA |= 0x14) // fault-to-off, SCP/OVP
#define IS_PWREN()       (SRCCTL &  0x01) // power switch

#if   defined(CFG_SLEEP_3V6) && defined(CAN1112B1X)
#define SET_SLEEP_3V6()  (AOPT  |= 0x30)
#define CLR_SLEEP_3V6()  (AOPT  &=~0x30)
#elif defined(CFG_SLEEP_3V6)
#ifdef CFG_CAN1121A0
#define SET_SLEEP_3V6()  (PWR_V = 0x16, PWRCTL &=~0x07, PWRCTL |= 0x04)
#else
#define SET_SLEEP_3V6()  (PWR_V = 0x2D, PWRCTL &=~0x03)
#endif
#define CLR_SLEEP_3V6()
#else
#define SET_SLEEP_3V6()
#define CLR_SLEEP_3V6()
#endif

#define GPIO12_OUTPUT_MODE()     (GPIOSH |= 0x88) // OE=1
#define GPIO34_OUTPUT_MODE()     (GPIO34  = 0x44) // OE=1, PD=0
#define GPIO5_OUTPUT_MODE()      (GPIO5   = 0x04) // 0E=1, PD=0
#define GPIO1_OUT(v)             (v ? (P0_0 = 1) : (P0_0 = 0)) // DO=0/1
#define GPIO2_OUT(v)             (v ? (P0_1 = 1) : (P0_1 = 0)) // DO=0/1
#define GPIO3_OUT(v)             (v ? (P0_4 = 1) : (P0_4 = 0)) // DO=0/1
#define GPIO4_OUT(v)             (v ? (P0_5 = 1) : (P0_5 = 0)) // DO=0/1
#define GPIO5_OUT(v)             (v ? (P0_6 = 1) : (P0_6 = 0)) // DO=0/1
#define IS_GPIO1_HI()            (P0_2)
#define IS_GPIO3_HI()            (P0_4)
#define IS_GPIO4_HI()            (P0_5)
#define IS_GPIO5_HI()            (P0_6)

#endif // _CAN1112_HAL_H_
