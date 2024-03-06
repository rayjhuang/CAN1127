#ifndef _DIGITALCC_H_
#define _DIGITALCC_H_

#ifdef CFG_DIGITAL_CC

extern bit bCCFlag;

#define SET_CC_MODE() bCCFlag = 1
#define SET_CV_MODE() bCCFlag = 0

#define DIGITALCC_INIT() { SET_ANALOG_CONST_CURR(0); SET_CC_MODE(); }
#define DIGITALCC_MODIFY_CURR() if (bCCFlag && !bDevSta_PPSRdy \
                                             || bDevSta_PPSReq) u8TargetPwrI -= u8TargetPwrI/10;

void DigitalCC_MsTick ();
void SetPwrV (WORD v);

#undef IS_OCP_EN
#define IS_OCP_EN() (!bCCFlag)

#undef IS_CLVAL
#define IS_CLVAL() DigitalCC_CLVAL()
TRUE_FALSE DigitalCC_CLVAL ();

#else 

#define SET_CC_MODE() { SET_ANALOG_CONST_CURR(1); CLR_ANALOG_CABLE_COMP(); }
#define SET_CV_MODE() { SET_ANALOG_CONST_CURR(0); SET_ANALOG_CABLE_COMP(); }

#define DIGITALCC_INIT()
#define DIGITALCC_MODIFY_CURR()

#define DigitalCC_MsTick()

#endif 

#endif // _DIGITALCC_H_
