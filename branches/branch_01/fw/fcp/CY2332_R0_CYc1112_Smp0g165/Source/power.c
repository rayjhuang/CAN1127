
#include "global.h"

#define APPX_DIV5(v) (v/5)
//efine APPX_DIV5(v) (v>>2)-(v>>5)-(v>>6)-(v>>8)
//TE DivBy5_10b (WORD val) { BYTE tmp = val>>2; tmp -= ((tmp>>3) + (tmp>>4) + (tmp>>6)); return tmp; }
//WORD MulBy5     (BYTE val) { return 5*val; }

void SetPwrI (BYTE c) { SET_PWR_I(c); }

#ifndef CFG_DIGITAL_CC // define SetPwrV() in digitalCC.c
void SetPwrV (WORD v) { SET_PWR_V(v); }
#endif

signed char s8VoltStep;
WORD u16Trans20mV, u16Target20mV; // also for Power-Good check, 20mV
BYTE  u8Trans50mA,  u8Target50mA; // 50mA (47.2mA)
bit bOpCurInc; // change OpC before voltage transition
bit bRDO_Mismatch;

void SetTarget50mA (BYTE cc)
{
   u8Target50mA = cc +
#ifdef CFG_PPS_CC_OFS_0
      ( bDevSta_PPSReq ?                 0  : MAP_CC_OFS() );
#elif defined(CFG_PPS_CC_OFS_X)
      ( bDevSta_PPSReq ? (MAP_CC_OFS() + 3) : MAP_CC_OFS() );
#else
                                              MAP_CC_OFS();
#endif
}

#ifdef CFG_BBI2C // no calibration

void CaliSetPwrI (BYTE cc) { SetTarget50mA(cc);                                                            SetPwrI (u8Target50mA); }
void CaliSetPwrV (WORD vv) { u16Target20mV = vv + (BYTE)(TUNE_OFS_PWRV()*4); u16BBI2CPwrV = u16Target20mV; SetPwrV (u16Target20mV); }
void PwrTransIsr () {} // no stepping
void PwrTransStart ()
{
    WORD u16BBI2CSETV;
    StopOVP();
    u16BBI2CPwrV = u16Target20mV;
    u16BBI2CSETV = u16Target20mV;
    if (u16BBI2CSETV >= 0x400) u16BBI2CSETV = 1023; // 0x3FF
    SetPwrV (u16BBI2CSETV);
    SetPwrI (u8Target50mA);
}
WORD u16BBI2CPwrV;

#else

#ifdef CFG_CALI_DACS
char CaliG (BYTE org, char gain)
{
   short AUTO round = (gain<0) ? -128 : 128;
   return (org * gain + round) / 256;
}
BYTE CaliADC (BYTE ADCV)
{
   short idata temp;
   if(bV2V_H) temp = ADCV - CaliG(ADCV,ADH_G()) + ADH_OFS();
   else       temp = ADCV - CaliG(ADCV,ADL_G()) + ADL_OFS();
   return (BYTE)((temp < 0 ) ? 0 : (temp > 255) ? 255 : temp);
}
#endif

void CaliSetPwrI (BYTE cc)
{
   #ifdef CFG_CALI_DACS
      short data temp;
      if (bV2V_H) temp = cc - CaliG(cc,CCH_G()) + CCH_OFS();
      else        temp = cc - CaliG(cc,CCL_G()) + CCL_OFS();
      cc = ((temp < 0 ) ? 0 : (temp > 127) ? 127 : temp);
   #else
      #ifdef CAN1110X
    if (cc < 1500/50) cc++;
    if (cc > 2500/50) cc--;
      #else // CAN1112X, PWR_I = 1.0498 CC - 1.9706
    if (cc < 1500/50) cc--;
    if (cc > 2500/50) cc++;
      #endif
   #endif

    DIGITALCC_MODIFY_CURR(); // Note: in FIXED-PPS request, bCCFlag may not yet be set
    // PPS-FIXED request, bCCFlag may not yet be cleared
    SetPwrI (cc);
}

#ifdef CFG_5V_OFS_7
   #define AT_5V_OFS_7() if (vv == 0xFA) vv+=7 // set 5V=5.14V, just for TENPAO
#else
   #define AT_5V_OFS_7()
#endif

void CaliSetPwrV (WORD vv) // set voltage with calibration
{

    vv += (BYTE)(TUNE_OFS_PWRV()*4);
   AT_5V_OFS_7();

#ifdef CAN1110X

    if (vv >= 0x200) vv++;

#else // CAN1112X

   #ifdef CFG_CALI_DACS
   if (vv > 0x3E8 && !bCaliNon) // 1000
   {
      if(!bV2V_H) 
      {
         bV2V_H = 1;
         RE_SETPWRI();
         SET_V2V_H(); 
      }
      vv -= 27; 
   }
   else 
   {
      if (bV2V_H) // && && ~bCaliNon
      { 
         bV2V_H = 0;
         RE_SETPWRI();
         SET_V2V_L();
      }
      vv += CV_OFS();     
   }
   if (!bV2V_H)
   #endif
   {
    if (vv >= 0x100 && SKIP_V_0512()) vv++;
    if (vv >= 0x200)
    {
         if (bCaliNon && !bDevSta_PPSReq) // to support CFG_CALI_DACS w/o cali table
                                        vv -= (vv-0x200)/25;
        if (SKIP_V_1024()) vv++;
    }
    if (vv >= 0x201 && SKIP_V_1025()) vv++; // +19-byte??
    if (vv >= 0x300 && SKIP_V_1536()) vv++;
   }
#endif

    if (vv >= 0x400) vv = 1023; // 0x3FF

    SetPwrV (vv);
   CCA1_SET_LOCAL_VOLTAGE (vv);
}

#endif // CFG_BBI2C

// =============================================================================
// power (voltage/current) transition
// 1. pre-calc
//    a. IsRdoAgreed()
//    b. PwrTransInit() is also used : (0) for back to PDO1, (-1) for QC transition
// 2. PwrTransStart()
// 3. PwrTransIsr()

#ifdef PD_ENABLE
WORD GetPDOLoWord (BYTE pos_minus)
{
    WORD tmp = *((WORD xdata*)&SRC_PDO[pos_minus][0]);
    return tmp>>8 | tmp<<8;
}

WORD GetPDOHiWord (BYTE pos_minus)
{
    WORD tmp = *((WORD xdata*)&SRC_PDO[pos_minus][2]);
    return tmp>>8 | tmp<<8;
}
BYTE GetFixdPDOPwrI ()
// get max. curr from the PDO in 50mA
{
    WORD tmp = GetPDOLoWord(u8RDOPositionMinus) & 0x3FF;
    return (tmp/5); // 50mA
}

#endif
void PwrTransInit (BYTE pos_minus) // 0/1/2/3/4/5/6/0xFF
// preparation for power transition
//    bOpCurInc
//    s8VoltStep
//    u16Target20mV if fixed PDO
//     u8Target50mA if fixed PDO
{
    if (pos_minus < 7) // PD fixed/PPS
    {
#ifdef PD_ENABLE
        u8RDOPositionMinus = pos_minus;
        if (bDevSta_PPSReq)
        {   // already assigned in IsRdoAgreed()
            // CFG_TWOPORT: only PDO1 advertized with Type-A attached
        }
        else
        {
            u8Target50mA = TWOPORT_TARGET_I();
            u16Target20mV = PDO_V_DAC[pos_minus] & 0x3FF;
        }
#else
      SetTarget50mA(44+ISET_OFFSET);
      u16Target20mV = MAP_PDO1_DAC();    
#endif
    }
    else
    {   // already assigned in QcVoltTrans()
    }
    bOpCurInc = u8Target50mA > u8Trans50mA; // CurrStep is 1/-1

    s8VoltStep = (u16Target20mV == u16Trans20mV) ? 0
                 : (u16Target20mV >  u16Trans20mV)
//                   ? (bDevSta_PPSRdy && !bDevSta_LgStep) ? 1 : STEP_UP
//                   : (bDevSta_PPSRdy && !bDevSta_LgStep) ?-1 :-STEP_DN;
    ? STEP_UP+((4<u16Target20mV-u16Trans20mV)? 4 : u16Target20mV-u16Trans20mV) : 
     -(STEP_DN+((4<u16Trans20mV-u16Target20mV)? 4 : u16Trans20mV-u16Target20mV));
}

#ifdef CFG_BBI2C // no stepping
#else

void PwrTransStart ()
{
    if (s8VoltStep < 0)
    {
        StopOVP();
        if (IS_OPTION_ALDISCHG() || // always discharge dominates, 20180809
                !IS_OPTION_NODISCHG() && !IS_CLVAL() && u8CurVal <= 25) // 600mA
        {
            DISCHARGE_TYPC_TRANS();
            DISCHARGE_TYPA_TRANS();
        }
    }
    bTmr0_Step = 1;
    CCA1_SET_LOCAL_VOLTAGE (u16Target20mV);
    STRT_TMR0(T_STEPPING); // start the first stepping
}

void PwrTransIsr () // PolicyManagerTmr0 ()
{
    bit bVoltCompleted = u16Trans20mV == u16Target20mV,
        bCurrCompleted =  u8Trans50mA ==  u8Target50mA;

    if (bVoltCompleted && bCurrCompleted // transition completed
            || bProF2Hr && u8StatePM != PM_STATE_DISCHARGE // transition broken
            || bProF2Off) // transition broken
    {
//    bEventPM = 1; // PwrTrans ends, even if detached
        if (bDevSta_PPSReq & bDevSta_PPSRdy) DISCHARGE_OFF(); // 20180810
        bTmr0_Step = 0;
    }
    else
    {
        if ((s8VoltStep>0) ? bCurrCompleted : ~bVoltCompleted)
        {
            STRT_TMR0(T_STEPPING); // start timer for next voltage stepping
            u16Trans20mV += s8VoltStep;
         if (s8VoltStep>0) { if (u16Trans20mV > u16Target20mV) u16Trans20mV = u16Target20mV; }
                      else { if (u16Trans20mV < u16Target20mV) u16Trans20mV = u16Target20mV; }
         CaliSetPwrV(u16Trans20mV); // WARNING L15: MULTIPLE CALL TO SEGMENT
        }
        else if (~bCurrCompleted) // 20180712, PWR_I stepping
        {
            (IS_CLVAL())
            ? STRT_TMR0(T_STEPPING*3) // start timer for next current stepping
            : STRT_TMR0(T_STEPPING);
#if(CURR_STEP==1)
            u8Trans50mA += (bOpCurInc ? 1 : -1);
#else // CFG_SIM
           u8Trans50mA += (bOpCurInc ? CURR_STEP+((4<(u8Target50mA-u8Trans50mA)) ? 4:(u8Target50mA-u8Trans50mA)) : -(CURR_STEP+((4<(u8Target50mA-u8Trans50mA))? 4 : (u8Trans50mA-u8Target50mA))));
         if (bOpCurInc) { if (u8Trans50mA > u8Target50mA) u8Trans50mA = u8Target50mA; }
                   else { if (u8Trans50mA < u8Target50mA) u8Trans50mA = u8Target50mA; }
#endif
            CaliSetPwrI(u8Trans50mA);
        }
    }
}

#endif // CFG_BBI2C

// =============================================================================
void SetPwrTransQC ()
{
    PwrTransInit (-1); // transition to u16Target20mV/u8Target50mA
#if defined(CAN1112BX) & !defined(SCP_ENABLE)
    if (u8QcSta==QCSTA_QC30) // to prevent continuous mode accumulator from overflow
    {
        u8Trans50mA = u8Target50mA; // let PWR_I not stepping
        CaliSetPwrI(u8Trans50mA);
        s8VoltStep *= 16;
    }
#endif
    u8StatePM = PM_STATE_ATTACHED_TRANS;
    PwrTransStart ();
}

#ifdef PD_ENABLE
// =============================================================================
BYTE IsRdoAgreed () // called by PE
// to decide Accept/Reject
// to update u8ReqPwrI/u16ReqPwrV if return TRUE
{
#ifdef PD_ENABLE
    WORD RDO_OpC;
    BYTE PosMinus = ((RxData[3] & 0x70) >> 4) - 1;
    BYTE RDO_Mis = RxData[2]& 0x40; // RDO capability mismatch bit
    WORD RDO_Tmp = (WORD)RxData[2]<<8 | RxData[1];
    WORD PDO_HiW = GetPDOHiWord(PosMinus);
    WORD PDO_LoW = GetPDOLoWord(PosMinus);

    bRDO_Mismatch = RDO_Mis^6;

    if ((PDO_HiW&0xF000)==0xC000) // request to APDO (PPS)
    {
        RDO_Tmp = (RDO_Tmp >> 1) & 0x7FF; // PPS_RDO[19:9], Output Voltage, 20mV
        if (RDO_Tmp > MulBy5(PDO_HiW>>1) || // APDO[24:17], max. in 100mV
                RDO_Tmp < MulBy5(PDO_LoW>>8) || // APDO[15:8],  min. in 100mV
                bPESta_PD2) // < PD3.0, 20190925 Jaden modified
        {
            return (BYTE)(bPESta_PD2);	// <PD 3.0 0x01 or 0x00
        }
        else
        {
            RDO_OpC = RxData[0] & 0x7F;
            PDO_LoW = PDO_LoW & 0x7F; // APDO[6:0], max. in 50mA
        }
    }
    else
    {
        RDO_OpC = (RDO_Tmp >> 2) & 0x3FF;
        PDO_LoW = PDO_LoW & 0x3FF; // max. in 10mA
    }

    if (PosMinus < u8NumSrcPdo && RDO_OpC <= PDO_LoW)
    {
        SET_DEVSTA_PPSREQ(); // request to APDO (PPS)
        CCA1_PPS_Req();
        if (bDevSta_PPSReq)
        {
         SetTarget50mA ((RDO_OpC < 20) ? 20 : RDO_OpC); // 20180727
#ifdef CFG_PWRLMT
            {
                BYTE pwri = SOURCE_PDP()*1000/u16Target20mV;
                if (u8Target50mA > pwri) SetTarget50mA(pwri);
            }
#endif
            bDevSta_LgStep = u16Target20mV > (RDO_Tmp + 500/20) || // V(new)-V(prior) < -500mV
                             u16Target20mV < (RDO_Tmp - 500/20);   // V(new)-V(prior) > +500mV
            u16Target20mV = RDO_Tmp;
        }
        else
        {
        }

        // 2019.09.23
        if (bRDO_Mismatch) CCA1_TYPC_GOMISMATCH();
        else CCA1_TYPC_EXITMISMATCH();

        PwrTransInit (PosMinus);
        return 0x02;
    }
    else
#endif
    {
        return 0x00;
    }
}
#endif
#if defined(CFG_DYNTWOPORT) | !defined(SCP_ENABLE)

// =============================================================================
void ModifyPDO ()
// 1. if SRC_PDO[] max.current above 3A, modify it 3A
// 2. modify u8NumSrcPdo for PD20 (remove APDO)
{
   
#ifdef PD_ENABLE
    BYTE ii, type, num;
    WORD tmp;
    for(ii=0; ii<u8NumSrcPdo; ii++)
    {
        tmp = GetPDOLoWord(ii);
        type = SRC_PDO[ii][3] & 0xF0;

        if (!bDevSta_5ACap) // 3A max. if not 5A capable
        {
            if (type==0xC0) // PPS APDO
            {
                if ((tmp & 0x7F) > APPX_DIV5(3000/10))
                {
                    tmp = tmp & 0xFF80 | APPX_DIV5(3000/10);
                }
            }
            else
            {
                type &= 0xC0;
                if (type==0x00 || type==0x40) // Fixed or Variable
                {
                    if ((tmp & 0x3FF) > 3000/10)
                    {
                        tmp = tmp & 0xFC00 | 3000/10;
                    }
                }
            }
            SRC_PDO[ii][0] = tmp;
            SRC_PDO[ii][1] = tmp>>8;
        }
#ifdef CFG_PWRLMT
        if (type==0xC0) // PPS APDO
        {
            SRC_PDO[ii][3] |= 0x08;
        }
#endif

        if (type!=0xC0) // count not APDO(s)
        {
            num = ii; // the last non-APDO
        }
    }

    if (MODIFY_NPDO_EXCLUDE_APDO()) u8NumSrcPdo = num + 1; // 20180606
#endif
}
#endif
// =============================================================================
void DisableConstCurrent ()
{
    if (!IS_OPTION_CCUR())
    {
        SET_CV_MODE(); // CV mode with OCP
    }
}
