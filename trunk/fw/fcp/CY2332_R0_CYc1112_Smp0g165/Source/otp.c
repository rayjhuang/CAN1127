
#include "global.h"

#define TCODE_BASE_ADDR           0x0033
#define GENERIC_HEADER_BASE_ADDR  0x0900
#define TRIM_TABLE_BASE_ADDR      0x0940
#define OPTION_TABLE_BASE_ADDR    0x0960
#define PDO_TABLE_BASE_ADDR       0x0970
#define VDO_TABLE_BASE_ADDR       0x09E0
#define MAPVOL_TABLE_BASE_ADDR    0x0A20
#define FTUNE_TABLE_BASE_ADDR     0x0A58

#ifdef CFG_CHECKSUM

#if ((MTT_N_TRM%2)==1)
BYTE code checksum_rsv _at_ TRIM_TABLE_BASE_ADDR+MTT_N_TRM*5;
#endif

WORD sum _at_ 0x40; // for easy debug
WORD code *pmem;
void inc_summation (WORD idx) { sum += pmem[idx]; }
void CHECK_SUM_OR_DIE ()
#ifdef CFG_SIM
#define CHECKSUM_SIZE 0x1000 // ~31ms/4KB (CAN1112)
#define CHECKSUM_AT() inc_summation ((0x4200-2)/2) // only for CFG_SIM
#else
#define CHECKSUM_SIZE 0x4200 // ~125ms (CAN1112)
#define CHECKSUM_AT()
#endif
{
    WORD idx;
    // summation skip 16-byte TCODE
    // from 0x0000 to GENERIC_HEADER_BASE_ADDR (excluded)
    for (idx=0; idx<TCODE_BASE_ADDR/2; idx++) inc_summation (idx);
    sum += ((pmem[ TCODE_BASE_ADDR      /2] & 0xFF00) | \
            (pmem[(TCODE_BASE_ADDR+16-1)/2] & 0x00FF)); // TCODE_BASE_ADDR is odd
    for (idx=(TCODE_BASE_ADDR+16-1)/2+1;
            idx<(GENERIC_HEADER_BASE_ADDR)/2; idx++) inc_summation (idx);

    for (idx=(GENERIC_HEADER_BASE_ADDR+16+16)/2;
            idx<(GENERIC_HEADER_BASE_ADDR+16+16+16)/2; idx++) inc_summation (idx); // GenHeaderFW

    // for (idx=(TRIM_TABLE_BASE_ADDR+MTT_N_TRM*5)/2; // skip trim table (option table in V2TABLE)
    for (idx=(FTUNE_TABLE_BASE_ADDR+MTT_N_OPT*2)/2; // skip all MTT (option table in V1TABLE)
            idx<CHECKSUM_SIZE/2; idx++) inc_summation (idx);

    CHECKSUM_AT();
    while (sum) {}
}

#endif // CFG_CHECKSUM

BYTE code TCodeOTP               [2][8]    _at_ TCODE_BASE_ADDR;

BYTE code GenHeaderCP            [1][16]   _at_ GENERIC_HEADER_BASE_ADDR;
BYTE code GenHeaderFT            [1][16]   _at_ GENERIC_HEADER_BASE_ADDR+16;
//// code GenHeaderFW            [1][16]   _at_ GENERIC_HEADER_BASE_ADDR+16+16;
BYTE code GenHeaderWriter        [1][16]   _at_ GENERIC_HEADER_BASE_ADDR+16+16+16;

BYTE code TrimTableOTP   [MTT_N_TRM][5]    _at_ TRIM_TABLE_BASE_ADDR;
BYTE code OptionTableOTP [MTT_N_OPT][4]    _at_ OPTION_TABLE_BASE_ADDR;
BYTE code MapVolTableOTP [MTT_N_PDO][7][2] _at_ MAPVOL_TABLE_BASE_ADDR;
#ifdef PD_ENABLE
BYTE code VdoTableOTP    [MTT_N_PDO][4][4] _at_ VDO_TABLE_BASE_ADDR;
BYTE code PdoTableOTP    [MTT_N_PDO][7][4] _at_ PDO_TABLE_BASE_ADDR;
#endif

#ifdef CFG_CALI_DACS
#define CALIB_TABLE_BASE_ADDR     0x4000
BYTE code CalibrateTableOTP      [4][14]   _at_ CALIB_TABLE_BASE_ADDR;
BYTE code D4_CALI[14] = { 0, 0, 0, 0, // DAC0 (PWR_V)
                        -13, 0,-2, 0, // DAC2 (PWR_I)
                          0, 0, 0, 0, // DAC1 (ADC)
                                0, 0};// checksum
char xdata CALI_TABLE[14];
bit bCaliNon, bV2V_H;
#endif



#ifdef OTT
// ?CO?OTP(0x033) in 'Code:' column of 'BL51 Locate' tab
// *** WARNING L16: UNCALLED SEGMENT, IGNORED FOR OVERLAY PROCESS
//     SEGMENT: ?CO?OTP
#else
BYTE code FTuneTableOTP  [MTT_N_OPT][2]    _at_ FTUNE_TABLE_BASE_ADDR; // 20180730
                                
WORD code D4_V_DAC[7] = {
    0x1000 | DAC0_PWRV5V0,
    0x5000 | DAC0_PWRV5V0,
    0x0000 | DAC0_PWRV5V0,
    0x1000 | DAC0_PWRV5V0,
    0xC000 | DAC0_PWRV5V0,
    0x0000 | DAC0_PWRV5V0, // PDP = 15W
    0xF000 | DAC0_PWRV5V0
};
BYTE code D4_OPTION[4] = {
    OPTION_D4_0,
    OPTION_D4_1,
    OPTION_D4_2,
    OPTION_D4_3
};
#endif
BYTE FINE_TUNE[2];


BYTE xdata* lpMemXdst;
BYTE xdata* lpMemXsrc;
#ifdef PD_ENABLE
void MemCopyX2X (BYTE cnt) { // 21-byte subroutine
    while (cnt--) {
        lpMemXdst[cnt] = lpMemXsrc[cnt];
    }
}
#endif
BYTE code* lpMemCsrc; // initialized to the start of the table
                      // pointed to the valid entry by MttGetVld()
                      // also used (read-only) in MemCopyC2X()

BYTE code* lpPdoTable;
BYTE code* lpMapTable;
BYTE code* lpVdmTable;
BYTE u8NumVDO; // not include VDM Header
PDOGOT7_INST()

void MemCopyC2X (BYTE cnt) {
    while (cnt--) {
        lpMemXdst[cnt] = lpMemCsrc[cnt];
    }
}


BYTE MttGetVld (BYTE nByte, BYTE nEntry)
// return value:
//    the valid entry (1,2,...), 0 means no valid entry found
//    and let 'lpMemCsrc' point to the start of the entry
// 20190606: to prevent writer's missing prior entry from error
//           let the last not-all-1 entry be the one
{
    BYTE ii, jj;
    bit allone;
    lpMemCsrc += (BYTE)(nByte * (nEntry - 1));
    // point to the start of the last entry
    // nByte * (nEntry - 1) must below 256
    for (ii = 0; ii < nEntry; ii++)
    {
        allone = 1;
        for (jj = 0; jj < nByte; jj++)
        {
            if ( lpMemCsrc[jj] != 0xFF )
            {
                allone = 0;
                break;
            }
        }
        if (!allone) // not all-1, it's the one
        {
            break;
        }
        else // all-1, check the prior entry
        {
            lpMemCsrc -= nByte;
        }
    }
    // that all entries are all-1 means no valid entry
    return nEntry - ii;
}

#ifdef OTT
#define PRE_FTUEN_TABLE()
#define PRE_MAP_TABLE()     lpMapTable = MAPVOL_TABLE_BASE_ADDR
#if (MTT_N_OPT>1)
#define FIND_OPTION_TABLE() MttGetVld(4,MTT_N_OPT)
#else
#define FIND_OPTION_TABLE()
#endif
#define FIND_MAP_TABLE()
#define FIND_FTUNE_TABLE() *((WORD*)FINE_TUNE) = D4_FTUNE // big-endian
#define LP_MAP_TABLE()     (lpMapTable)
#define ASSIGN_PDO_TABLE()  lpPdoTable = PDO_TABLE_BASE_ADDR
#define ASSIGN_VDM_TABLE()  lpVdmTable = VDO_TABLE_BASE_ADDR
#else
#define PRE_FTUEN_TABLE()   lpMemCsrc  = FTUNE_TABLE_BASE_ADDR
#define PRE_MAP_TABLE()     lpMemCsrc  = MAPVOL_TABLE_BASE_ADDR
#define FIND_OPTION_TABLE() lpMemCsrc  = (MttGetVld(4,MTT_N_OPT)) ? lpMemCsrc : D4_OPTION
#define FIND_MAP_TABLE()    lpMapTable = (MttGetVld(2*7,MTT_N_PDO)) ? lpMemCsrc : 0
#define FIND_FTUNE_TABLE() *((WORD*)FINE_TUNE) = (MttGetVld(2,MTT_N_OPT)) ? *((WORD*)lpMemCsrc) : D4_FTUNE
#define LP_MAP_TABLE()    ((lpMapTable) ? lpMapTable : (BYTE*)D4_V_DAC)
#ifdef PD_ENABLE
#define ASSIGN_PDO_TABLE()
#else
#define ASSIGN_PDO_TABLE()  lpPdoTable = lpMemCsrc
#endif
#define ASSIGN_VDM_TABLE()  lpVdmTable = lpMemCsrc
#endif

void ReloadPdoTable (bit bReloadPDO6)
{
#ifdef PD_ENABLE
#ifndef OTT // MTT-only
    if (lpPdoTable==0) // use default instead
    {
        SRC_PDO[0][0] =  300; // 3.0A
        SRC_PDO[0][1] = (300 >> 8) | 100 << 2;
        SRC_PDO[0][2] =            ((100 << 2) >> 8); // 5V
        SRC_PDO[0][3] = 0x0A; // PDO1: Fixed, DRP
        u8NumSrcPdo = 1;
    }
    else // PDO table exists
#endif
    {
        MEM_COPY_C2X((BYTE*)SRC_PDO,lpPdoTable,4*7); // lpMemCsrc = lpPdoTable;
        u8NumSrcPdo = MttGetVld(4,bReloadPDO6?6:7); // rev.20180402 (better than CY2311R2V100.012)
    }
#else
    bReloadPDO6=bReloadPDO6;
#endif
    // load DAC mapping table if exists
    MEM_COPY_C2X((BYTE*)PDO_V_DAC, LP_MAP_TABLE(), 2*7);
}

void MtTablesInit ()
{
    /* trim table */
    lpMemCsrc = TRIM_TABLE_BASE_ADDR;
    if (MttGetVld(5,MTT_N_TRM)) // find trim table
    {
        REGTRM0 = lpMemCsrc[0];
        REGTRM1 = lpMemCsrc[1];
        REGTRM2 = lpMemCsrc[2];
        REGTRM3 = lpMemCsrc[3];
        REGTRM4 = lpMemCsrc[4];
    }

    /* fine-tune table */
    PRE_FTUEN_TABLE();
    FIND_FTUNE_TABLE();
// INIT_ANALOG_PK_SET_NTC(TUNE_CCTRX()); // default CCTRX, move to POST_HW_INIT

    /* option table */
    lpMemCsrc = OPTION_TABLE_BASE_ADDR;
    FIND_OPTION_TABLE();
    lpMemXdst = (BYTE*)(&OPTION_REG);
    MemCopyC2X(4);

    /* DAC0/PWR_V mapping table */
    PRE_MAP_TABLE();
    FIND_MAP_TABLE();

    /* PDO table */
#ifndef OTT // MTT-only
    lpMemCsrc = PDO_TABLE_BASE_ADDR;
    lpPdoTable = 0;
    if (MttGetVld(4*7,MTT_N_PDO))
#endif
    {
        ASSIGN_PDO_TABLE();
        PDOGOT7_SETUP();
    }
    ReloadPdoTable (0); // to initial DAC0 mapping table for type-C voltage

#ifdef PD_ENABLE
    /* VDO table */
    lpMemCsrc = VDO_TABLE_BASE_ADDR;
// u8NumVDO = 0;
#ifndef OTT // MTT-only
    if (MttGetVld(4*4,MTT_N_PDO)) // find VDM Data Object
#endif
    {
        ASSIGN_VDM_TABLE();
        if (lpMemCsrc[0]|lpMemCsrc[1]) // VID=0 means the table is erased
            u8NumVDO = MttGetVld(4,4);
    }
#endif
#ifdef CFG_CALI_DACS
   lpMemCsrc = CALIB_TABLE_BASE_ADDR;
   if (MttGetVld(14,4))
   {
      MEM_COPY_C2X(CALI_TABLE,lpMemCsrc,14);
      SET_V2V_L();
      CLR_CC_TRIM();
//    bCaliNon = 0;
   }
   else
   {
      MEM_COPY_C2X(CALI_TABLE,D4_CALI,14);
      bCaliNon = 1; // calibration table not found
   }

#endif
}
