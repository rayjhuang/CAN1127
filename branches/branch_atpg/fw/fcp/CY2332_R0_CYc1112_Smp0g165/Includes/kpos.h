#ifndef _KPOS_H_
#define _KPOS_H_

#ifdef CFG_KPOS0

extern BYTE ErrorRecovery_Counter;
extern BYTE btShortTmr;
extern bit bProDMFualt;

#undef  T_F2HR_DEBNC
#ifdef CFG_SIM
#define T_F2HR_DEBNC()         ((ErrorRecovery_Counter>=3)?1:3)
#define T_ERR_RECOVER          17
#else
#define T_F2HR_DEBNC()         ((ErrorRecovery_Counter>=3)?1:30)
#define T_ERR_RECOVER          2500 // 2.5S
#endif

#undef  DAC_OFS_PWR_I
#define DAC_OFS_PWR_I() ( bDevSta_PPSReq ?((PDO_V_DAC[2]>>12) + 5) :((PDO_V_DAC[2]>>12) + 6) )

#ifdef CAN1112BX
void Start_DM_Fault();
#endif

#define RST_ERR_RECOVERY_COUNTER() ( ErrorRecovery_Counter = 0)
#define INC_ERR_RECOVERY_COUNTER() if (ErrorRecovery_Counter<3) ErrorRecovery_Counter++


#else


#define bProDMFualt 0
#define Start_DM_Fault()
#undef  SET_DM_FAULT_DIS
#define SET_DM_FAULT_DIS()

#define RST_ERR_RECOVERY_COUNTER()
#define INC_ERR_RECOVERY_COUNTER()

#endif // CFG_KPOS0

#endif // _KPOS_H_
