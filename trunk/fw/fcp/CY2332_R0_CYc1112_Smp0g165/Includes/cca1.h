
#ifndef _CCA1_H_
#define _CCA1_H_

#ifdef CFG_CCA1

#ifndef CFG_DYNPDP // to support CCA1 without Type-A
#define bTAAttched FALSE
#define PDP_MINUS_VALUE_X2 0
#endif

extern BYTE xdata u8LcalPdpx2;
extern BYTE xdata u8LcalVolt;
extern BYTE xdata u8LcalSta;
extern bit bLcalPdpChg;

#define IS_MASTER() (P0_2==TRUE) // GND GPIO1 for slave
#define CCA1_TYPC_GOMISMATCH() u8LcalSta |=0x08
#define CCA1_TYPC_EXITMISMATCH() u8LcalSta &=~0x08
#define CCA1_PPS_Req() ((bDevSta_PPSReq) ? (u8LcalSta |= 0x04) : (u8LcalSta &=~0x04) )
#define CCA1_TYPA_ATTACH() u8LcalSta |= 0x02
#define CCA1_TYPA_DETACH() u8LcalSta &=~0x02
#define CCA1_TYPC_ATTACH() u8LcalSta |= 0x01
#define CCA1_TYPC_DETACH() u8LcalSta &=~0x0D // clear type-c plug, PPS, mismatch status
#define CCA1_SET_LOCAL_VOLTAGE(v) u8LcalVolt = (v + 49)/50
void CCA1_INIT ();
void CCA1_MsTick ();

#else

#define CCA1_TYPC_GOMISMATCH()
#define CCA1_TYPC_EXITMISMATCH()
#define CCA1_PPS_Req()
#define CCA1_TYPC_ATTACH()

#define CCA1_TYPC_DETACH()
#define CCA1_SET_LOCAL_VOLTAGE(v)
#define CCA1_INIT()
#define CCA1_MsTick()

#endif // CFG_CCA1

#endif // _CCA1_H_
