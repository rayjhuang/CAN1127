#ifndef _DYNPDP_H_
#define _DYNPDP_H_

#ifdef CFG_DYNPDP

#define PDP_MINUS_VALUE_X2 (12*2)
#define TYPA_DETACH_2S

#ifdef CFG_CCA1
#define DYNPDP_RESET() bLcalPdpChg=FALSE, u8LcalVolt = 5
#else
extern BYTE u8LcalPdpx2;
extern bit bLcalPdpChg;
#define DYNPDP_RESET() bLcalPdpChg=FALSE
#endif

#ifdef DYNPDP_CFG_TS_LO // TS-low attaching
#ifdef TYPA_DETACH_HV
#define GET_TYPA_ATT() (bTAAttched ? (u8TmpVal < ADC_VALUE_TS_DET) : (u8TmpVal < ADC_VALUE_TS))
#else
#define GET_TYPA_ATT() (u8TmpVal < ADC_VALUE_TS)
#endif
#define DYNPDP_INIT()
#endif
#ifdef DYNPDP_CFG_TS_HI // TS-high attaching
#ifdef TYPA_DETACH_HV
#define GET_TYPA_ATT() (bTAAttched ? (u8TmpVal > ADC_VALUE_TS_DET) : (u8TmpVal > ADC_VALUE_TS))
#else
#define GET_TYPA_ATT() (u8TmpVal > ADC_VALUE_TS)
#endif
#define DYNPDP_INIT()
#endif
#ifdef DYNPDP_CFG_GPIO5_LO // GPIO5-low attaching
#ifndef CFG_TWOPORT
#define GET_TYPA_ATT() (!IS_GPIO5_HI())
#endif
#define DYNPDP_INIT() (GPIO5 &= 0xF8) // PD=0
#endif
#ifdef DYNPDP_CFG_GPIO5_HI // GPIO5-high attaching
#ifndef CFG_TWOPORT
#define GET_TYPA_ATT() (IS_GPIO5_HI())
#endif
#define DYNPDP_INIT() (GPIO5 &= 0xF8) // PD=0
#endif

extern bit bPMExtra_DpdpNego;
extern bit bTAAttched;

void DynPDP_AttDetOneMs ();
void DynPDP_PwrShare();
//#define DYNPDP_MODIFY_PDO() DynPDP_PwrShare()

#else

#define DynPDP_AttDetOneMs()
#define DynPDP_PwrShare()
//#define DYNPDP_MODIFY_PDO()
#define DYNPDP_RESET()
#define DYNPDP_INIT()

#endif // CFG_DYNPDP

#endif // _DYNPDP_H_
