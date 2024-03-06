#ifndef _POWER_H_
#define _POWER_H_

extern BYTE  u8Target50mA,  u8Trans50mA;
extern WORD u16Target20mV, u16Trans20mV;
extern signed char s8VoltStep;

void SetTarget50mA (BYTE cc);

#ifdef CFG_CALI_DACS

BYTE CaliADC (BYTE ADCV);

extern char xdata CALI_TABLE[];
extern bit bCaliNon, bV2V_H;

#define SET_V2V_L()  {REGTRM1 = (REGTRM1 & 0x7f) | (CALI_TABLE[0]<<7); REGTRM2 = (REGTRM2 & 0xf0) | (CALI_TABLE[0]>>1);}
#define SET_V2V_H()  {REGTRM1 = (REGTRM1 & 0x7f) | (CALI_TABLE[1]<<7); REGTRM2 = (REGTRM2 & 0xf0) | (CALI_TABLE[1]>>1);}
#define CLR_CC_TRIM(){REGTRM0 =  REGTRM0 & 0x7f;                       REGTRM1 =  REGTRM1 & 0x80;}

#define RE_SETPWRI() CaliSetPwrI(u8Trans50mA)

#define CV_OFS()     (CALI_TABLE[2])
#define CCL_OFS()    (CALI_TABLE[6]) 
#define CCH_OFS()    (CALI_TABLE[7]) 
#define ADL_OFS()    (CALI_TABLE[10])
#define ADH_OFS()    (CALI_TABLE[11])

#define CCL_G()      (CALI_TABLE[4])  
#define CCH_G()      (CALI_TABLE[5])  
#define ADL_G()      (CALI_TABLE[8])  
#define ADH_G()      (CALI_TABLE[9]) 

#else

#define CaliADC(v) v

#define RE_SETPWRI()
#define bCaliNon  1

#endif


void CaliSetPwrI (BYTE);
void CaliSetPwrV (WORD);

void ModifyPDO (); // 20180606
void DisableConstCurrent (); // 20180913
BYTE IsRdoAgreed ();

void SetPwrTransQC ();
void PwrTransInit (BYTE);
void PwrTransStart ();
void PwrTransIsr ();

#endif // _POWER_H_
