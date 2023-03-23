
#include "global.h"


//#ifdef CONFIG_TS_DEFAULT_PDP


//#if 0
//BYTE code default_src_pdo_30W[24] =
//{
//    0x2C, 0x91, 0x01, 0x0A, // PDO1: Fixed 5V/3A, DRP
//    0x2C, 0xD1, 0x02, 0x00, // PDO2: Fixed 9V/3A,
//    0xFA, 0xC0, 0x03, 0x00, // PDO3: Fixed 12V/2.5A,
//    0xC8, 0xB0, 0x04, 0x00, // PDO4: Fixed 15V/2A,
//    0xA5, 0xA0, 0x05, 0x00, // PDO5: Fixed 18V/1.65A,
//    0x96, 0x40, 0x06, 0x00, // PDO6: Fixed 20V/1.5A,
//};

//BYTE code default_src_pdo_45W[24] =
//{
//    0x2C, 0x91, 0x01, 0x0A, // PDO1: Fixed 5V/3A, DRP
//    0x2C, 0xD1, 0x02, 0x00, // PDO2: Fixed 9V/3A,
//    0x2C, 0xC1, 0x03, 0x00, // PDO3: Fixed 12V/3A,
//    0x2C, 0xB1, 0x04, 0x00, // PDO4: Fixed 15V/3A,
//    0xFA, 0xA0, 0x05, 0x00, // PDO5: Fixed 18V/2.5A,
//    0xE1, 0x40, 0x06, 0x00, // PDO6: Fixed 20V/2.25A,
//};

//BYTE code default_src_pdo_60W[24] =
//{
//    0x2C, 0x91, 0x01, 0x0A, // PDO1: Fixed 5V/3A, DRP
//    0x2C, 0xD1, 0x02, 0x00, // PDO2: Fixed 9V/3A,
//    0x2C, 0xC1, 0x03, 0x00, // PDO3: Fixed 12V/3A
//    0x2C, 0xB1, 0x04, 0x00, // PDO4: Fixed 15V/3A
//    0x2C, 0xA1, 0x05, 0x00, // PDO5: Fixed 18V/3A
//    0x2C, 0x41, 0x06, 0x00, // PDO6: Fixed 20V/3A
//};
//#endif

//BYTE code default_src_pdo[24] = {
//    // 45W
//    0x2C, 0x91, 0x01, 0x0A, // PDO1: Fixed 5V/3A, DRP
//    0x2C, 0xD1, 0x02, 0x00, // PDO2: Fixed 9V/3A,
//    0x2C, 0xC1, 0x03, 0x00, // PDO3: Fixed 12V/3A,
//    0x2C, 0xB1, 0x04, 0x00, // PDO4: Fixed 15V/3A,
//    0xFA, 0xA0, 0x05, 0x00, // PDO5: Fixed 18V/2.5A,
//    0xE1, 0x40, 0x06, 0x00, // PDO6: Fixed 20V/2.25A,
//};

//#endif  // CONFIG_TS_DEFAULT_PDP

//void TsAttInit ()
//{
//   INIT_ANALOG_PK_SET_NTC();
//   ENABLE_TS_SARADC();
//   ENABLE_TS_CHANNEL();
//   DACLSB = 0x04;
//   DACCTL = 0x0f;
//}


#ifdef CFG_DYNPDP

#define ADC_VALUE_TS        (162) // 1.3V (1296mV)

#ifdef TYPA_DETACH_HV // hysteresis
#define ADC_VALUE_TS_DET    (225) // 1.8V
#endif


#ifdef CFG_SIM
#define T_ATT_DEBOUNCE      (3)
#else
#define T_ATT_DEBOUNCE      (5)
#endif

#ifdef TYPA_DETACH_2S
#ifdef CFG_SIM
#define T_DET_DEBOUNCE      (10)
#else
#define T_DET_DEBOUNCE      (2000)
#endif
#ifndef CFG_DYNTWOPORT
WORD uXXAttTimer;
#endif
#else
BYTE uXXAttTimer;
#endif

#ifdef CFG_CCA1
#else
BYTE u8LcalPdpx2; // support 0.5W granularity
#endif

// QC 27W->18W if the shared power not enough for QC 27W
#define CFG_DYNPDP_SHARE_QC_PWR

extern bit bQcOpt_PWR;
void QcVoltTrans (WORD volx2);

BYTE u8SavPdpx2;

#ifndef CFG_TWOPORT
bit bTAAttched;
#endif
bit bTypa2Att, bLcalPdpChg;
BYTE pwrV;
void DynPDP_PwrShare()
{
    if (u8LcalPdpx2) // local PDP >0 means power limited
    {
        idata WORD tmp, orgI, pwrI;
        idata BYTE ii, type;

        for (ii = 0; ii < u8NumSrcPdo; ii++)
        {
            type = SRC_PDO[ii][3] & 0xC0;
            tmp = ( SRC_PDO[ii][1]<<8 | SRC_PDO[ii][0] );
            if (0x00 == type) // Fixed
            {
                pwrV = (WORD)(((0x0F&SRC_PDO[ii][2]) << 6)
                              | ((SRC_PDO[ii][1]) >> 2)) >> 1; // pwrV is multiple of 100mV

                orgI = tmp & ~0xFC00; // in 10mA
                tmp &= 0xFC00;
                pwrI = (u8LcalPdpx2<=130) ? ( u8LcalPdpx2 * 500 / pwrV ) : ( u8LcalPdpx2 * 250 / (pwrV/2) ); // 65W max.
            }
            else // 0xC0 APDO
            {
                pwrV = (SRC_PDO[ii][3] << 7)
                       | (SRC_PDO[ii][2] >> 1); // in 100mV

                if (pwrV== 59) pwrV =  50;
                if (pwrV==110) pwrV =  90;
                if (pwrV==160) pwrV = 150;
                if (pwrV==210) pwrV = 200;

                orgI = tmp & ~0xFF00; // in 50mA
                tmp &= 0xFF00;
                pwrI = ( u8LcalPdpx2 * 100 / pwrV );
            }
            if (pwrI > orgI) pwrI = orgI;
            tmp |= pwrI;
            SRC_PDO[ii][0] = tmp;
            SRC_PDO[ii][1] = tmp >> 8;
        }
    }
}

void DynPDP_AttDetOneMs () // attachment by TS
{
#ifndef CFG_DYNTWOPORT				// if dyntwoport do twoport A-attach process.
    bit bTmpSig =bTypa2Att;
    bTypa2Att = GET_TYPA_ATT();
    if (bTmpSig==bTypa2Att)
    {
        if (uXXAttTimer && (!--uXXAttTimer) && (bTAAttched!=bTypa2Att))
        {
            bTAAttched = bTypa2Att;
#ifdef CFG_CCA1
            if (bTAAttched) CCA1_TYPA_ATTACH();
            else CCA1_TYPA_DETACH();
#else
            if (bTAAttched) u8LcalPdpx2 = (SOURCE_PDP() * 2) - PDP_MINUS_VALUE_X2;
            else u8LcalPdpx2 = 0; // unlimited
#endif
        }
    }
    else
    {
#ifdef TYPA_DETACH_2S
        if (bTypa2Att==0)
            uXXAttTimer = T_DET_DEBOUNCE;
        else
#endif
            uXXAttTimer = T_ATT_DEBOUNCE;
    }
#else
#ifdef CFG_CCA1
    if (bTAAttched) CCA1_TYPA_ATTACH();
    else CCA1_TYPA_DETACH();
#else
    if (bTAAttched) u8LcalPdpx2 = (SOURCE_PDP() * 2) - PDP_MINUS_VALUE_X2;
    else u8LcalPdpx2 = 0; // unlimited
#endif
#endif

    // detect if local PDP changed
    if (u8SavPdpx2!=u8LcalPdpx2) // PDP was updated
    {
        u8SavPdpx2 = u8LcalPdpx2;
#ifdef CFG_DYNPDP_SHARE_QC_PWR
        bQcOpt_PWR = (u8LcalPdpx2 && u8LcalPdpx2 < 27*2) ? 0 : IS_OPTION_QC_PWR();
        if (bQcSta_InQC) QcVoltTrans(u16Target20mV);
#endif
        if (bPESta_CONN) bLcalPdpChg = TRUE;
    }

    // re-nogo. if local PDP changed
    if (u8StatePM==PM_STATE_ATTACHED && u8StatePE==PE_SRC_Ready)
    {
        if (bPMExtra_DpdpNego==TRUE)
        {
            bPMExtra_DpdpNego = 0;
            if (u8PEAmsState==AMS_RSP_RCVD) // Request received -> Accept sent -> PS_Rdy sent
            {
                if (bPESta_Rejt) // Request received -> Reject sent
                {
                    Go_PM_STATE_SEND_HR();
                }
            }
            else
            {
                bLcalPdpChg = TRUE; // redo later
            }
        }
        else if (bLcalPdpChg==TRUE)
        {
            bLcalPdpChg = FALSE;
            ReloadPdoTable (RELOAD_MAX_PDO6()); // u8NumSrcPdo not for PD20
            Go_PE_SRC_Send_Capabilities();
            bPMExtra_DpdpNego = 1; // use this bit for tracking if the 2nd nego. done
            // keep PM_STATE_ATTACHED for PE_SRC_Transition_Supply
        }
    }
}

#endif // CFG_DYNPDP
