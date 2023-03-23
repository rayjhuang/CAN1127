#ifndef _APPLEDEX_H_
#define _APPLEDEX_H_

#ifdef CFG_APPLE_DATEX

#define PID_MACBOOK2015 0x1390

typedef enum {
   AEMD_IDLE,
   AEMD_1,
   AEMD_2,
   AEMD_3,
   AEMD_END,
   AEMD_UVDM,
} APPLE_DATEX_BYTE;
extern APPLE_DATEX_BYTE u8StateADExCmd;
extern BYTE u8UvdmMod, u8UvdmCnt, u8UvdmCmd, u8UvdmAdr;
extern BYTE code strDatEx[][15*16];
extern BYTE u8ExStr;

void AppleDatExReset();
void AppleDatExProc();
void AppleDatExAttention();
void CanyonSemiAttention();

#define APPLE_DATEX_SET() u8StateADExCmd = AEMD_UVDM
#define APPLE_DATEX_PROC else if (u8StateADExCmd!=AEMD_IDLE) { AppleDatExProc (); }
#define APPLE_DATEX_ATTENTION else if (is_rxsvdm(6,2) && (u8UvdmMod&0x01)) { AppleDatExAttention(); }
#define CANYON_SEMI_ATTENTION else if (is_rxsvdm(6,0)) { CanyonSemiAttention(); }

#define OBJPOS_ENTER 0x01 // Object Posistion = 1

#define V5_RESET() (SRCCTL &= ~0x40, DEC = 0, SET_VBUS_OFF())

#else

#define u8UvdmCnt 0x00

#define AppleDatExReset()

#define APPLE_DATEX_SET()
#define APPLE_DATEX_PROC
#define APPLE_DATEX_ATTENTION
#define CANYON_SEMI_ATTENTION

#define OBJPOS_ENTER 0x00

#define V5_RESET()

#endif

#endif // _APPLE_DATA_EX_H_
