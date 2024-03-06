#ifndef _CONFIG_H_
#define _CONFIG_H_
////////////////////////////////////////////////////////////////////////////////
// this header file is used to define a compilation of a specific application
// un-comment each macro in 'exclusive application' to select/enable it
// un-comment all macro in 'exclusive application' to build a default revision
// build the default revision before PUSH to GIT server
////////////////////////////////////////////////////////////////////////////////

#define CFG_SIM
//#define CFG_FPGA

// exclusive applications //////////////////////////////////////////////////////
// note that not all enable/disable combinations are allowed
//#define CFG_DYNPDP
//#define CFG_TWOPORT
//#define CFG_DIGITAL_CC
//#define CFG_KPOS0 ////////// not for 8KB here and belows
//#define CFG_APPLE_DATEX
//#define CFG_GOOGLE
//#define CFG_CCA1 // 2C1A type 1 (with CFG_DYNPDP)
//#define CFG_BBI2C // bulk-boost by I2C, always CC
//#define CFG_DYNTWOPORT

#ifdef CFG_DYNTWOPORT
#define CFG_DYNPDP
#define CFG_TWOPORT
#endif

// exclusive devices ///////////////////////////////////////////////////////////
//#define CFG_CAN1110CX // CAN1110C/D/E
//#define CFG_CAN1110F
//#define CFG_CAN1112AX // CAN1112A0/1
//#define CFG_CAN1112B0
#define CFG_CAN1112B1
//#define CFG_CAN1112B2
//#define CFG_CAN1118A0
//#define CFG_CAN1121A0

#if defined(CFG_CAN1118A0)
   #define CAN1118AX
   #define CAN1112BX
   #define CAN1112B1X // CAN1112B1 and after
#endif

#if defined(CFG_CAN1112B0) \
 || defined(CFG_CAN1112B1) \
 || defined(CFG_CAN1112B2) \
 || defined(CFG_CAN1121A0)
   #define CAN1112BX // CAN1112B0 and after (=CAN1112B0X)
   #ifndef CFG_CAN1112B0
      #define CAN1112B1X // CAN1112B1 and after
   #endif
#endif

#if defined(CFG_CAN1110F) \
 || defined(CFG_CAN1110CX)
   #define CAN1110X
   #pragma nomdu_r515
#else
   #pragma mdu_r515 // Use On-chip Arithmetic Unit
#endif

#pragma OPTIMIZE(8,SIZE)
#define STATIC data
#define AUTO

// FW version control //////////////////////////////////////////////////////////
// encode a char between 'CY' and '1112' to specify an application
// '2': for CAN1110X
// 'a': for CAN1112AX
// 'b': for CAN1112B0
// 'c': for CAN1112B1 and after
// 'FIRMWARE_NUM' is used in usaul talks, so don't repeat as possible even the
//    other part of 'FIRMWARE_NAME' changed
//    begins other than '.' for testing revisions
#define TXCODE "g" // releasing('.')/testing(xyza-*) version
#define REV_NUM "64"
#ifdef CAN1110X
   #if   defined(CFG_CAN1110CX)
      #define FIRMWARE_APP "CY21110"
   #elif defined(CFG_CAN1110F)
      #define FIRMWARE_APP "CY31110"
   #endif
      #define FIRMWARE_NUM "2"
#elif defined(CAN1112BX)
   #if   defined(CFG_CAN1112B0)
      #define FIRMWARE_APP "CYb1112"
   #elif defined(CAN1112B1X)
      #define FIRMWARE_APP "CYc1112"
   #endif
      #define FIRMWARE_NUM "1"
#else // CAN1112AX
      #define FIRMWARE_APP "CYa1112"
      #define FIRMWARE_NUM "0"
#endif


// A U T O / M A N U A L  D E F I N E D ////////////////////////////////////////

// remove PPS to reduce code size //////////////////////////////////////////////
//#define CFG_PPS

// calibration of the DACs with FT /////////////////////////////////////////////
#if defined(CAN1112BX) && !defined(CFG_BBI2C)
//#define CFG_CALI_DACS // only for CAN1112BX
#endif

// remove bPMExtra_DrSwp to reduce code size ///////////////////////////////////
// remove bPMExtra_PdoOpt to reduce code size //////////////////////////////////
//#define CFG_REDUCE_SZ

// 1st nego scheme when 2nd-nego enabled ///////////////////////////////////////
// PDO1-only: iPhone always requests the 2nd PDO if multiple PDO
// APDO-excluded: MacBookPro (Chris@20190524) failed in requesting PPS
//#define CFG_PDO1_ONLY

// FW self-validate check-sum //////////////////////////////////////////////////
// after the WRITER revised, by calculating a checksum for each entry, the
// writer shall keep each entry's summation unchanged
//#define CFG_CHECKSUM

// QC Class B //////////////////////////////////////////////////////////////////
// support HVDCP 20V
//#define CFG_QC_CLASSB

// CC_PROT function ////////////////////////////////////////////////////////////
// cannot turn-on in CAN1112A1 (analog glitch)
#ifdef CFG_KPOS0
   #define CFG_CC_PROT
#endif

// Sleep mode 4.9/3.6V /////////////////////////////////////////////////////////
// CAN1112B0 (and before) can support CFG_SLEEP_3V6 by PWR_V
// for now, only for KPOS case, 20190328
#ifdef CFG_KPOS0
   #define CFG_SLEEP_3V6
#endif

// for GOOGLE costumized ///////////////////////////////////////////////////////
// OVP/OTP latch-off mode
// constant power
#ifdef CFG_GOOGLE
   #define CFG_OVP_LATCH
   #define CFG_PWRLMT
   #define CFG_STEP_BACK_SLOW
   #define CFG_PPS_CC_OFS_0
#endif

// for 2C1A define
// one of CFG_CCA1_PPS_PRIOR/CFG_CCA1_AVG/CFG_CCA1_MASTER_HI is a must
#ifdef CFG_CCA1
// #define CFG_CCA1_PPS_PRIOR // for samsung note require PPS don't decrease PPS
// #define CFG_CCA1_AVG       // orginal
   #define CFG_CCA1_MASTER_HI // default, master C 45W
// #define CFG_CCA1_MISMATCH_POWER
#endif

// for TENPAO DYNPDP, 
// set fixed 5V=5.14V ,QC 5V=5.14V ,PPS 5.2V~16V, QC3 5V(5.14V)~?
// set typeA attach in 1.3V, detach in 1.8V
#ifdef CFG_TENPAO
#define TYPA_DETACH_HV
#define CFG_5V_OFS_7
#else
#define TYPA_DETACH_2S
#endif

// for LITEON constant power
#ifdef CFG_LITEON
   #define CFG_PWRLMT
   #define CFG_PPS_CC_OFS_X // will set PPS PwrI + 3 offset
#endif

// OTT /////////////////////////////////////////////////////////////////////////
// especially for CAN1110X
#if defined(CAN1110X) && defined(CFG_PPS) && \
   (defined(CFG_DYNPDP) \
 || defined(CFG_TWOPORT))
   #define OTT // One-Time-programmable Table
   #ifdef OTT
        #define MTT_N_TRM 3 // in [1,6]
        #define MTT_N_OPT 3 // in [1,4]
        #define MTT_N_PDO 1
   #else
        #define MTT_N_TRM 3 // in [1,6]
        #define MTT_N_OPT 2 // in [1,4]
        #define MTT_N_PDO 2 // in [1,4]
   #endif
#else
        #define MTT_N_TRM 6 // in [1,6]
        #define MTT_N_OPT 4 // in [1,4]
        #define MTT_N_PDO 4 // in [1,4]
#endif

// Power-Good on VFB channel ///////////////////////////////////////////////////
// for those VFB-on-channel-2 revisions (only for CAN1110X (rev.C and later))
// for PWM application, VIN cannot be used to do Power-Good detection
// (VIN is fixed to DC-IN)
#ifdef CAN1110X
#define PWRGD_VFB
#endif

#ifdef CFG_TWOPORT
// exclusive GPIO config ///////////////////////////////////////////////////////
// TYPADET/PWREN/DISCHARGE
#if defined(CAN1110X)
   #define TWOPORT_CFG_ADET_GATEZ_GPIO3 // CY2313/CY231124Q
#else // CAN1112X
// #define TWOPORT_CFG_TS_GPIO1_GPIO2 // AP43971
   #define TWOPORT_CFG_TSZ_GPIO3_GPIO4 // AP43971 (2019/06/12 new-defined bonding)
// #define TWOPORT_CFG_GPIO5_GPIO3_GPIO4 // CY2332-24Q (2019/08/01 for 1A1C Car Charger)
   #define TYPA_ATTACH_BCQC
#endif
#endif

#ifdef CFG_DYNPDP
// exclusive GPIO config ///////////////////////////////////////////////////////
// TYPADET
#ifdef CFG_CCA1
   #define DYNPDP_CFG_GPIO5_LO
// #define DYNPDP_CFG_GPIO5_HI
#else
   #define DYNPDP_CFG_TS_LO
// #define DYNPDP_CFG_TS_HI
#endif
#endif

// support QC4 UVDM ////////////////////////////////////////////////////////////
//#define QC4PLUS

// support 'Internal Temp' of the extended message, Status /////////////////////
//#define STATUS_INT_TEMP

// exclusive/none TS pin config ////////////////////////////////////////////////
// comment out CFG_TS_NTC to save about 30-byte code size
#if defined(TWOPORT_CFG_TS_GPIO1_GPIO2) \
 || defined(TWOPORT_CFG_TSZ_GPIO3_GPIO4) \ 
 || defined(DYNPDP_CFG_TS_LO) \
 || defined(DYNPDP_CFG_TS_HI)
   #define CFG_TS_ATT // Type-A attachment detector (GPI), OTP eliminated
   #ifdef DYNPDP_CFG_TS_LO
   #define CFG_TS_ATT_PULLHI // TS internal current source for pull TS high (5V)
   #endif
#else // QC4PLUS compliance needs NTC
   #define CFG_TS_NTC // 10K@25C NTC
#endif

//#define VOOC_ENABLE
#define SCP_ENABLE
#define AFC_ENABLE
#define CFG_40W
//#define AFCTEST
#define SCP_AUTHORITY

////////////////////////////////////////////////////////////////////////////////
// generating firmware full name in OTP header (16-byte)
// let the FW can be told
////////////////////////////////////////////////////////////////////////////////

#define CFG_CHAR0 "_"

#if   defined(CFG_SIM)
   #define CFG_CHAR1 "S" // for verilog simulation
#elif defined(CFG_FPGA)
   #define CFG_CHAR1 "F" // FPGA emulation
#else
   #define CFG_CHAR1 "T" // typical application
#endif

#ifdef CFG_QC_CLASSB
   #ifdef OTT
      #define CFG_CHAR2 "2"
   #else
      #define CFG_CHAR2 "M"
   #endif
   #define QC3_VOLT_MAX DAC0_PWRV20V
   #define QC2_20V
#else // no 20V in QC20/30
   #ifdef OTT
      #define CFG_CHAR2 "o"
   #else
      #define CFG_CHAR2 "m" // Multi-Time-programmable Table
   #endif
   #define QC3_VOLT_MAX DAC0_PWRV12V
#endif

#if   defined(CFG_APPLE_DATEX)
   #define CFG_CHAR34 "a0"
#elif defined(CFG_BBI2C)
   #define CFG_CHAR34 "b0"
#elif defined(CFG_DIGITAL_CC)
   #define CFG_CHAR34 "c0"
#elif defined(CFG_GOOGLE)
   #define CFG_CHAR34 "g5"
#elif defined(DYNPDP_CFG_GPIO5_LO) && defined(CFG_CCA1) && defined(CFG_CCA1_PPS_PRIOR)
   #define CFG_CHAR34 "dc"
#elif defined(DYNPDP_CFG_GPIO5_LO) && defined(CFG_CCA1) && defined(CFG_CCA1_AVG)
   #define CFG_CHAR34 "db"
#elif defined(DYNPDP_CFG_GPIO5_HI) && defined(CFG_CCA1)
   #define CFG_CHAR34 "da"
#elif defined(DYNPDP_CFG_GPIO5_LO) && defined(CFG_CCA1) && defined(CFG_CCA1_MASTER_HI)
   #define CFG_CHAR34 "d9"
#elif defined(DYNPDP_CFG_TS_HI)    && defined(CFG_CCA1)
   #define CFG_CHAR34 "d8"
#elif defined(DYNPDP_CFG_TS_LO) && defined(CFG_TENPAO) && defined(CFG_5V_OFS_7)
   #define CFG_CHAR34 "d2"
#elif defined(DYNPDP_CFG_TS_LO) && defined(CFG_TENPAO)
   #define CFG_CHAR34 "d1"
#elif defined(DYNPDP_CFG_TS_LO) && !defined(CFG_TENPAO)// the orignal
   #define CFG_CHAR34 "d0"
#elif defined(CFG_KPOS0)
   #define CFG_CHAR34 "k0"
#elif defined(CFG_LITEON)
   #define CFG_CHAR34 "l0"
#elif defined(CFG_TWOPORT) && defined(TWOPORT_CFG_ADET_GATEZ_GPIO3)
   #define CFG_CHAR34 "t1"
#elif defined(CFG_TWOPORT) && defined(TWOPORT_CFG_TS_GPIO1_GPIO2)
   #define CFG_CHAR34 "t2"
#elif defined(CFG_TWOPORT) && defined(TWOPORT_CFG_TSZ_GPIO3_GPIO4)
   #define CFG_CHAR34 "t3"
#elif defined(CFG_TWOPORT) && defined(TWOPORT_CFG_GPIO5_GPIO3_GPIO4)
   #define CFG_CHAR34 "t4"
#else
   #define CFG_CHAR34 "p0"
#endif

#define CFG_STR5 CFG_CHAR0 CFG_CHAR1 CFG_CHAR2 CFG_CHAR34
#define FIRMWARE_NAME { FIRMWARE_APP CFG_STR5 TXCODE FIRMWARE_NUM REV_NUM }


#endif // _CONFIG_H_
