#ifndef _SCP_HAL_H_
#define _SCP_H_

   void Go_QCSTA_IDLE ();
#define ISET_OFFSET     0
   
#ifdef SCP_ENABLE
   void ScpPrlInit ();
   void ScpPhyProc ();
   void ScpPrlProc ();
   void ScpPrlStart ();
   void ScpReginit ();
   void ScpPhyStart ();
   void ScpSRPrlProc(void);
   void ScpPhyInit(void);
   void SCP_TimeOut(void);
   void SCP_DP_protection(void);
   void ScpgoReset(void);
   void SCP_Reset_Delay(void);
   void SCP_DischBIST(void);
   void Average_VolCur(void);
   bit Scp_CheckCount(void);
   WORD BUILD_WORD(BYTE lobyte, BYTE hibyte);
 
#define CHK_DP_DETACH()    if(u8SCPstate) SCP_DP_protection(); else  {CHK_DP_DETACH_IF_B0()}

#ifdef SCP_AUTHORITY
   void ScpSHA256Proc(void);
#else
#define ScpSHA256Proc()
#endif

   extern BYTE u8SCPstate;
   extern BYTE u8DpDmVal;
   extern BYTE u8DpDmDbCnt;

//#define SCP_I_SET()  if(!bPESta_CONN && !pos_minus) u8ReqPwrI=48        // 2.4A
#else 

#define ScpPrlInit()
#define ScpPhyProc()
#define ScpPrlProc()
#define ScpPrlStart()
#define SCP_TimeOut()
//#define SCP_I_SET()
#define CHK_DP_DETACH() CHK_DP_DETACH_IF_B0()
#define ScpReginit()
#define ScpSHA256Proc()
#define SCP_DischBIST()
#define Average_VolCur()

#endif

#endif // _SCP_HAL_H_
