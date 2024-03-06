
#include "global.h"

//#define SREAD_EQUAL_VSSET      //Make SREAD_VOUT = VSSET when master read SREAD_VOUT
//#define ENA_VSSET_45_55_RANGE        //enable range of VSSET & SREAD_VOUT, it will adjust VSSET & SREAD_VOUT within 4.5V~5.5V
//#define MOUNTED_CHIP       //If chip in mount on the board, enable this marco. if via socket, disable it.

#define ACK0  0x08
#define NACK0 0x03
#define ACK1  0x88
#define NACK1 0x13
#define SBRWR 0x0B
#define SBRRD 0x0C
#define MBRWR 0x1B
#define MBRRD 0x1C

#define RO          0x01
#define RW          0x02
#define RC          0x04
#define WC          0x08
#define SO          0x10               // single R/W only

#define MAX_NUM_SCP_ACCESS  16

#define MIN_SCP_VBUS        0x0CE4     //  3.3V
#define MAX_SCP_VBUS        0x2EE0     // 12V
#define MIN_SCP_IBUS        0x0100     //  0.256A
#define MAX_SCP_IBUS        0x0BBB     // 3A

#define u16Min_Vout           0x0D48               //3.4V?
#define u16Max_Vout           0x2EE0               //12 V?
#define u16Min_Iout           0x12C                // 0.3A

#define UNIT_ADJ_VOLT         20

#define CAL_HI_BYTE(a) (((a) >> 8) & 0xFF)
#define CAL_LO_BYTE(a) ((a) & 0xFF)
 
#define HI_BYTE(a) ((BYTE *)&a)[0]
#define LO_BYTE(a) ((BYTE *)&a)[1]
 

#define SetPwrTransSCP()      SetPwrTransQC()
//#define BUILD_WORD(loByte, hiByte)   ((WORD)(((loByte) & 0x00FF) + (((hiByte) & 0x00FF) << 8)))

//#define SetPwrV(v)   (SET_PWR_V(v/UNIT_ADJ_VOLT))     // mV
//#define SetPwrI(i)   (SET_PWR_I(i/50))       // mA

#ifdef SCP_ENABLE

#ifdef CFG_SIM
#define tSCPResetime     20
#else
#define tSCPResetime     1050
#endif

//BYTE LastVboundH, LastIboundH;   //Add by marc
static BYTE u8ParsedRegAdr;
//static BYTE currFirstRead = 0;
//bit bScpPrlAdc;

extern BYTE idata u8RxBuffer [16+2];
extern BYTE idata u8TxBuffer [16];
extern BYTE idata u8RxNumByte;
extern BYTE idata u8TxNumByte;
extern BYTE ScpCheckCnt;

BYTE xdata u8ScpReg [208];
BYTE code  u8IniScpReg [208] = {
    /* Type A register */
    0x01,0x22,0x00,0x00,0x00,0x00,0x00,0x00, // 0x00 5/9/12 2A
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // 0x10
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
#if defined(CFG_22W)
    0x01,0x33,0x2C,0x00,0x00,0x00,0x00,0x00, // 0x20        22W  0x21 ????????????????
#elif defined(CFG_40W)
    0x01,0x02,0x50,0x00,0x00,0x00,0x00,0x00, // 0x20        40W
#endif
    0x00,0x34,0x00,0x00,0x34,0x14,0x00,0x03,
    0x34,0x5A,0x78,0x00,0x00,0x00,0x00,0x00, // 0x30
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x20,0x44,0x5A,0x00,0x00,0x00,0x00,0x00, // 0x40        UVP 3.2V / 9*0.75 / 12*0.75
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
   0x14,0x14,0x14,0x00,0x00,0x00,0x00,0x00, // 0x50         2A
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // 0x60
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // 0x70
    0x00,0x00,0x00,0x00,
    0x01,0x02, // [7C,7D] COMPILEDVER
    /* Type B register (by SCP spec 1.30G) */
    0xB8,      // [7E] ADP_TYPE0
    0x00,
#if 0 //Same as spec
    0xB0,0xE0,0x00,0x00,0x00,0x00,0x00,0x00, // 0x80
    0x00,0x00,0x01,0x30,0x00,0x82,0x00,0x00,
    0x9E,0x96,0xA4,0xCC,0x85,0x99,0x14,0x32, // 0x90   ,//0x95=0x99 indicate 2.5A MAX_IOUT ==> Fast charge to Huawei
#else // for huawei mate9
    0x91,0x10,0x80,0xB1,0x00,0x01,0x04,0x2D, // 0x80, // SCP-B, Type C
    0x03,0x01,0x01,0x30,0x00,0x03,0x00,0x00, //0x88:Chip ID, 0x89:HW ver, 0x8A/8B:FWVER_H/L, 0x8D:ADP_B_TYPE_1(model num of B-type)
#if   defined(CFG_18W)
    0x92,0x92,0xB7,0xCA,0x5E,0x92,0x14,0x32, // 0x90   //reg[0x95]=0xB2 indicate 3A MAX_IOUT ==> Super charge to Huawei, 5.5V 10V
#elif defined(CFG_22W)
    0x96,0x96,0xA1,0xCC,0x5E,0x94,0x14,0x32, // 0x90, 22W/22W/2.0A 3.3V~12V 0.3A~2A READ ONLY
#elif defined(CFG_40W)
    0xA8,0xA8,0xA2,0xCC,0x5E,0xA8,0x14,0x32, // 0x90, 40W/40W/2.0A 3.4V~12V 0.3A~4A READ ONLY
#endif
#endif
    0x94,0x94,0x32,0x14,0x00,0x00,0x00,0x00,	//CTRL_BYTE0/1
    0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00, // 0xA0  // STOP TIMER
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
//   0x27,0x10,0x07,0x08,0x32,0x72,0x00,0x00, // 0xB0	, VSET/ISET bondary  10V  1.8A
    0x2E,0xE0,0x0F,0xA0,0x32,0x72,0x00,0x00, // 0xB0	, VSET/ISET bondary  12V  4A
    0x14,0x82,0x07,0xD0,0x00,0x00,0x00,0x00,	//5.25V 0xBA/BB = ISET_H/L
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // 0xC0
    0x00,0x00,0xE1,0x28,0x00,0x00,0x00,0x00,     ///0xCA/CB = VSSET/ISSET, Reg[0xCB] = 0x28 for default, 0x00 for mobile first read,*/Marc20180706
#if 0
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // 0xD0
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    /* Reserved register address*/
    // for test control
    0x01,0x90,0x50,0x19,0x00,0x00,0x00,0x00, // 0xE0
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00, // 0xF0
    0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00
#endif
};

BYTE code  u8ScpRegAttr [208] = {
    RO|SO,   RO|SO,   RW|SO,   RC|SO,   RO|SO,   RO|SO,    0x00,    0x00, // 0x00
     0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,
     0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00, // 0x10
     0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,
    RO|SO,   RO|SO,   RO|SO,    0x00,    0x00,    0x00,    0x00,    0x00, // 0x20
    RC|SO,   RO|SO,    0x00,   RW|SO,   RW|SO,   RW|SO,    0x00,   RO|SO,
    RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,// 0x30
    RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,
    RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,// 0x40
    RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,
    RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO, // 0x50
    RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,   RO|SO,
     0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00, // 0x60
     0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,
     0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00, // 0x70
     0x00,    0x00,    0x00,    0x00,   RO|SO,   RO|SO,   RO|SO,    0x00,
    RO|SO,   RO,      RO,      RO,      RO,      RO,      RO,      RO,   // 0x80
    RO,      RO,      RO|SO,   RO|SO,   RO,      RO,      RO,      RO,
    RO,      RO,      RO,      RO,      RO,      RO,      RO,      RO,   // 0x90
    RO,      RO,      RO,      RO,      RO,      RO,      RO,      RO,
    RW,      RW,      RO|RC,   RC,      RC,      RC,      RO,      RO,   // 0xA0
    RO,      RO,      RO,      RO,      RO,      RO,      RO,      RO,
    RW,      RW,      RW,      RW,      RW,      RW,      RO,      RO, // 0xB0
    RW,      RW,      RW,      RW,      WC,      WC,      WC,      WC,
    RO,      RO,      RO,      RO,      RO,      RO,      RO,      RO,   // 0xC0
    RO,      RO,      RW,      RW,      WC,      WC,      RW,      RW,
#if 0
    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00, // 0xD0
    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,
#if 0 //Marc20180704 test
    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00, // 0xE0
    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,
    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00, // 0xF0
    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,    0x00,
#else
    RW,    RW,    RW,    RW,    RW,    RW,    RW,    RW, // 0xE0
    RW,    RW,    RW,    RW,    RW,    RW,    RW,    RW,
    RW,    RW,    RW,    RW,    RW,    RW,    RW,    RW, // 0xF0
    RW,    RW,    RW,    RW,    RW,    RW,    RW,    RW,
#endif
#endif
};

enum {
    SCP_PRL_INIT,
    SCP_PRL_READY,
    SCP_PRL_RESPONSE,
} u8ScpPrlState;// _at_ 0x11;

#ifndef FPGA
//BYTE u8DACV0Lv = 0;
//BYTE u8VinOffset = 0;
#endif
BYTE u8SCPstate;
BYTE u8ScpRegA0;
BYTE u8ScpRegA2;
BYTE u8ScpRegA3;
BYTE u8ScpReg03;
BYTE u8ScpReg28;
BYTE ScpDpCnt;
BYTE VbusDischCnt;
BYTE u8Avgvol[2];
BYTE u8Avgcur[2];

//WORD u16IsOffset = 0;
//BYTE u8PwriOffset = 0;
//BYTE u8Debug = 0;
//bit 0 ==> HVDCP detach falg
//bit 1 ==> fortxen
//bit 2 ==> HVDCP detach disable
//bit 3 ==> DGND detach disable
//BYTE u16DiscTimer;

//extern BYTE u8DpDmDbCnt;

//WORD u16Max_Pwr;
//WORD u16Cnt_Pwr;
//WORD u16Min_Vout;
//WORD u16Max_Vout;
//WORD u16Min_Iout;
WORD idata u16Max_Iout;
WORD idata u16VBOUNDARY;
WORD idata u16IBOUNDARY;
WORD idata u16VSET;
WORD idata u16ISET;
WORD u16Ctimer;

#ifdef SCP_AUTHORITY
typedef union{
DWORD u32ScpAnti_data[8];
BYTE u8ScpAnti_data[32];
}scpaf;

xdata scpaf Anti_data;//*/
#endif

#ifdef AFC_ENABLE
BYTE AfcCmd = 0;
BYTE AfcCount = 0;
bit bAfcMode;
#endif

//bit bSet_Out;
//bit bReg2Fread;
bit bScpAntipass;
bit bdischchk;             // for 0xA4

//void ScpUpdateVolt();
void ScpUpdateCurr();

void ScpPrlInit ()
{
   u8ScpPrlState = SCP_PRL_INIT;
   bEventScpAF=0;
//   ET1 = 0;
   ScpPhyInit ();
}

//WORD BUILD_WORD(BYTE lobyte, BYTE hibyte)
//{
////	WORD SCPdata;
////	((BYTE *)&SCPdata)[0]=hibyte;
////	((BYTE *)&SCPdata)[1]=lobyte;
//	return ((WORD)hibyte<<8) | (WORD)lobyte;
//}
#define BUILD_WORD(lobyte,hibyte) (((WORD)hibyte<<8) | (WORD)lobyte)
#define MAX(a,b)  (a > b) ? a : b
#define Min(a,b)  (a < b) ? a : b

void SetScpBYTE2WORD(BYTE addr,WORD dat)
{
   u8ScpReg[addr] = ((BYTE *)&dat)[0];
   u8ScpReg[addr+1]=((BYTE *)&dat)[1];
}
/*
WORD ScpPowOfTen(BYTE pwr)
{
    if(pwr == 0)
        return (1);    //10^0
    else if(pwr == 1)
        return (10);   //10^1
    else if(pwr == 2)
        return (100);   //10^2
    else if(pwr == 3)
        return (1000); //10^3
    else
        return 0; //pwr is not inside 0~3
}*/

WORD scppowten(BYTE addr, BYTE pwr)
{
   BYTE i;
   WORD adddata = addr;
   for(i=1; i<=pwr ;i++)
      adddata*=10;
   return adddata;
}

void ScpReginit(void)
{
    BYTE xdata* dst;
    BYTE code* src;
    dst = (BYTE xdata*)u8ScpReg;
    src = (BYTE code*)u8IniScpReg;

    MEM_COPY_C2X(dst,src,0xD0);
//    bSet_Out=0;
    bdischchk=0;
    bScpAntipass=0;
    u16Target20mV=MAP_PDO1_DAC();
//    bReg2Fread=0;
    u16VBOUNDARY=0x2EE0;         // 12V
    u16IBOUNDARY=0x0FA0;         // 4A
    u16VSET=0x1482;              // 5.25V
    u16ISET=0x07D0;              // 2A
    /*Add by marc*/
    u8ScpRegA0 = 0x80;
    u8ScpReg[0xA0] = 0x80;  // Output enable
    u8ScpReg[0xA2] = 0x40 | (u8ScpRegA2&0x01);  // Status Byte 0 , timeout happend.
    u16Max_Iout = 4200;//(WORD)((WORD)(u8ScpReg[0x95] & 0x003F) * ScpPowOfTen(u8ScpReg[0x95] >> 6));
}

void ScpPrlStart ()
{
//   BYTE xdata* dst;
//   BYTE code* src;
//   BYTE ii;

//   FCPMSK &=~0x80;	            // disable ACC_DPDM
    /* Initialize SCP register */
//   dst = (BYTE xdata*)u8ScpReg;
//   src = (BYTE code*)u8IniScpReg;
//   for (ii=0; ii<0xDC; ii++) // <3ms
//   for (ii=0; ii<0xD0; ii++) // <3ms
//   {
//      u8ScpReg[ii] = u8IniScpReg[ii];
//   }
//	 MEM_COPY_C2X(dst,src,0xD0);
    /*Add by marc*/
//   u8ScpReg[0xA0] = 0x80;  // Output enable
//   u8ScpReg[0xA2] = 0x40 | (u8ScpRegA2&0x01);  // Status Byte 0 , timeout happend.
    // Apply default VSET/ISET to VBUS/IBUS

//    u16Max_Pwr = (WORD)(((WORD)dst[0x90] & 0x007F) * ScpPowOfTen((BYTE)dst[0x90] >> 7));
//    u16Cnt_Pwr = u16Max_Pwr;
//    u16Min_Vout = (WORD)((WORD)(u8ScpReg[0x92] & 0x003F) * ScpPowOfTen(u8ScpReg[0x92] >> 6));          //3.3V?
//    u16Max_Vout = (WORD)((WORD)(u8ScpReg[0x93] & 0x003F) * ScpPowOfTen(u8ScpReg[0x93] >> 6));          //12 V?
//    u16Min_Iout = (WORD)((WORD)(u8ScpReg[0x94] & 0x003F) * ScpPowOfTen(u8ScpReg[0x94] >> 6));          //0.3A?
//    u16Max_Iout = (WORD)((WORD)(u8ScpReg[0x95] & 0x003F) * ScpPowOfTen(u8ScpReg[0x95] >> 6));          //2 A?
//    ScpReginit();  // move to do elearer
    u8ParsedRegAdr = 0;
    //currFirstRead = 0;
    /*-----------*/
    u8SCPstate=0;
    ScpPhyStart ();
    SET_ANALOG_CABLE_COMP();
    u8ScpPrlState = SCP_PRL_READY;
}

void SCPreturnAck(BYTE ackdata)
{
   u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ackdata|0x80 : ackdata;
}
#define SET_CHANNEL_SWITCH() (CMPOPT |= 0x80)   // switch chennels, CH0:IS,  CH3:DI
#define CLR_CHANNEL_SWITCH() (CMPOPT &=~0x80)   // switch chennels, CH0:VIN, CH3:TS
#define ADD_CHANNEL_0()      (DACEN  |= 0x01)
#define DES_CHANNEL_0()      (DACEN  &=~0x01) // de-select

void SCPVoltTrans (WORD volx2) // voltage in 20mV
{
//   if (u8StatePM==PM_STATE_ATTACHED // power stepping may still not ready (by prior SCP transition)
//    && u8StatePE==PE_SRC_Disabled)  // (by right after entering SCP)
    {
        u16Target20mV = volx2;
#if defined(CFG_22W)
        u8ScpReg[0x95] = (volx2<525)      // < 10.5V
                         ? 0x94                       // 2A
                         : 0x8F;                      // 1.5A
#elif defined(CFG_40W)
        u8ScpReg[0x95] = (volx2<=500)     // <= 10V
                         ? 0xAA                       // 4.2A
                         : (volx2<=550)               // <= 11V
                           ? 0xA0                     // 3.2A
                           : 0x9B;                    // 2.7A
#endif
//        u16Max_Iout = (WORD)(((WORD)u8ScpReg[0x95] & 0x003F) * ScpPowOfTen(u8ScpReg[0x95] >> 6));
       u16Max_Iout=scppowten(u8ScpReg[0x95] & 0x003F, u8ScpReg[0x95] >> 6);

        if(GET_PWR_I() > u16Max_Iout/50)     // PWR_I may be changed
            ScpUpdateCurr();
        //  u8Target50mA=u16Max_Iout/50;           // 42 => +20%
        else
            SetPwrTransSCP ();
    }
}

void ScpUpdateVolt()
{
    WORD u16CalValue = BUILD_WORD(u8ScpReg[0xB9], u8ScpReg[0xB8]);
//    SET_OVPINT(0);   // stop OVP
    /* Check limit of adjust voltage */
    if(u16CalValue < u16Min_Vout)
    {
        u16CalValue = u16Min_Vout;
    }
    else if((u16CalValue > u16Max_Vout) || (u16CalValue > u16VBOUNDARY))
    {
      u16CalValue=Min(u16Max_Vout,u16VBOUNDARY);
/*        if(u16Max_Vout > u16VBOUNDARY)
        {
            if(u16CalValue > u16VBOUNDARY)
            {
                u16CalValue = u16VBOUNDARY;
            }
        }
        else
        {
            u16CalValue = u16Max_Vout;
        }*/
        /* Update to VSET */
      SetScpBYTE2WORD(0xB8,u16CalValue);
//        u8ScpReg[0xB9] = LO_BYTE(u16CalValue);  // if VOUT set > boundry, VSET needs to be updated.
//        u8ScpReg[0xB8] = HI_BYTE(u16CalValue);  // if VOUT set < boundry, VSET dose not be updated.
//        u8ScpReg[0x2C] = u16CalValue/100;
    }

    u16VSET=BUILD_WORD(u8ScpReg[0xB9], u8ScpReg[0xB8]);
    u8ScpReg[0xCA] = (u16VSET>3000) ? (u16VSET-3000)/10 : 0;

   SetScpBYTE2WORD(0xAC,u16CalValue/UNIT_ADJ_VOLT*UNIT_ADJ_VOLT);
//    u8ScpReg[0xAD] = CAL_LO_BYTE(u16CalValue/UNIT_ADJ_VOLT*UNIT_ADJ_VOLT);        // DAC_VSET_L
//    u8ScpReg[0xAC] = CAL_LO_BYTE(u16CalValue/UNIT_ADJ_VOLT*UNIT_ADJ_VOLT);        // DAC_VSET_H
    u8ScpReg[0x29] = u16CalValue/100;

    if(((1000+u16CalValue)/UNIT_ADJ_VOLT) < u16Target20mV)                    // decress voltage > 1V
    {
       bdischchk=1;
       VbusDischCnt=0;
    }
    else
       bdischchk=0;
    /* Update to VSSET & VSOFET */
//   u16CalValue = BUILD_WORD(u8ScpReg[0xB9], u8ScpReg[0xB8])-u8ScpReg[0xC7]*1000;   //Remove VSOFFSET to get VSSET
#ifdef ENA_VSSET_45_55_RANGE_
    while(u16CalValue > 5500) { //255*10+3000 = 5550 = 0x15AE
        u16CalValue -= 1000;
        u8ScpReg[0xC7] += 1;
    }
    while((u16CalValue < 4500) && (u8ScpReg[0xC7] > 0)) {   //0x1194
        u16CalValue += 1000;
        u8ScpReg[0xC7] -= 1;
    }
#endif
    /* Apply to VBUS */
    SCPVoltTrans(u16CalValue/UNIT_ADJ_VOLT);
}

void ScpUpdateCurr()
{
    WORD u16CalValue = BUILD_WORD(u8ScpReg[0xBB], u8ScpReg[0xBA]);
    /* Check limit of adjust Current */
    if(u16CalValue < u16Min_Iout)
    {
        u16CalValue = u16Min_Iout;
    }
    else if((u16CalValue > (u16Max_Iout/* + 100*/)) || (u16CalValue > u16IBOUNDARY))
        //else if((u16CalValue > (u16Max_Iout + (u8PwriOffset*50))) || (u16CalValue > BUILD_WORD(u8ScpReg[0xB3], u8ScpReg[0xB2])))
    {
       
       u16CalValue=Min(u16Max_Iout,u16IBOUNDARY);
/*        if(u16Max_Iout > u16IBOUNDARY)
        {
            if(u16CalValue > u16IBOUNDARY)
            {
                u16CalValue = u16IBOUNDARY;
            }
        }
        else
        {
            u16CalValue = u16Max_Iout;
        }*/
        /* Update to ISET */
         SetScpBYTE2WORD(0xBA,u16CalValue);
//        u8ScpReg[0xBB] = LO_BYTE(u16CalValue);
//        u8ScpReg[0xBA] = HI_BYTE(u16CalValue);

        u8ScpReg[0x2D] = u8ScpReg[0xCB]/2;//u16CalValue/100;
    }
    u16ISET=BUILD_WORD(u8ScpReg[0xBB], u8ScpReg[0xBA]);
    u8ScpReg[0xCB] = u16ISET/50;

   SetScpBYTE2WORD(0xAE,u16CalValue/50*50);
//    u8ScpReg[0xAF] = CAL_LO_BYTE(u16CalValue/50*50);
//    u8ScpReg[0xAE] = CAL_HI_BYTE(u16CalValue/50*50);
    /* Apply to IBUS */

    u8Target50mA=u16CalValue/50 + ISET_OFFSET;        // +100mA   42=>+20%

    SetPwrTransSCP ();
}

void ScpcheckVOUTvalid(BYTE outputn)
{
    BYTE i;

//    outputn = (u8RxBuffer[1]==0x2C) ? 0x30 : 0x50;
    for(i=outputn; i<=outputn+15; i++)
    {
        if(u8ScpReg[0x21]!=0x03 && i==0x32) i++;   //if 0x2F hasn't be read, can't output 12V 191120 Jaden

        if(u8RxBuffer[2]==u8IniScpReg[i])
        {
            return;
        }
    }

   u8ScpReg[outputn]=u8IniScpReg[outputn];
}

void ScpWrReqHdlr()
{
   volatile WORD u16CalValue;
//   if(u8ParsedRegAdr == 0)  { u8ParsedRegAdr = u8RxBuffer[1]; }   //give a initail address
    for( u8ParsedRegAdr = u8RxBuffer[1]; (u8ParsedRegAdr-u8RxBuffer[1]) < MAX_NUM_SCP_ACCESS; u8ParsedRegAdr++)
    {
//        if(u8ParsedRegAdr < 0xD0)//
        {
            switch(u8ParsedRegAdr)
            {
            /* ---------General Setting----------------*/
            case 0xA0:           //CTRL_BYTE0
//            TOGGLE_PO(P0_2);
            
                if(u8ScpReg[0xA0] & 0x40)  //SCP_MODE  //Marc20180627R
                {
                    if(!(u8ScpReg[0xA2] & 0x80))
                    {
                        SetScpBYTE2WORD(0xB8,0x1482);
//                        u8ScpReg[0xB8]=0x14;
//                        u8ScpReg[0xB9]=0x82;
                        u16VSET=0x1482;
                        u16ISET=0x07D0;               // 2A
                    }
                    u8ScpReg[0xA2] |= 0x80;           //Status Byte0, 0x80 means the present mode is "SCP protocol control mode".
                    CLR_ANALOG_CABLE_COMP();
                }
                else
                {
                    if((u8ScpReg[0xA2] & 0x80) && !(u8ScpReg[0xA0] & 0x20))//back to non SCP mode.
                    {
/*//                        BYTE u8ScpRegA0;//,u8ScpRegB0,u8ScpRegB1,u8ScpRegB2,u8ScpRegB3;         // 0xB0~0xB3 have to be kept????????????
//                        u8ScpRegA0=u8ScpReg[0xA0];
//                        u8ScpRegB0=u8ScpReg[0xB0];
//                        u8ScpRegB1=u8ScpReg[0xB1];
//                        u8ScpRegB2=u8ScpReg[0xB2];
//                        u8ScpRegB3=u8ScpReg[0xB3];*/
                        ScpReginit();
/*//                        u8ScpReg[0xA0]|=u8ScpRegA0&0x20;   // keep reset status
//                        u8ScpReg[0xB0]=u8ScpRegB0;
//                        u8ScpReg[0xB1]=u8ScpRegB1;
//                        u8ScpReg[0xB2]=u8ScpRegB2;
//                        u8ScpReg[0xB3]=u8ScpRegB3;*/
                    }
                    u8Target50mA=44+ISET_OFFSET;         // SCP A  2.2A
                }

               if((u8ScpReg[0xA0] & 0x20)) //Reset
               {/* For Now, only initialize SCP reg for SCP reset command */
                 u8SCPstate=0x02;
               }
               else //if(u8ScpReg[0xA0] & 0x80)  //OUTPUT_EN. If bit 7 was written by master, slave won't change state.
               {/* apply Voltage setting */

                    
                    (!(u8ScpReg[0xA0] & 0x80) && (u8ScpReg[0xA0] & 0x40)) ? SET_VBUS_OFF() : SET_VBUS_ON();
                    
                    ScpUpdateVolt();
                    //ScpUpdateCurr();
                }
                u8ScpRegA0=u8ScpReg[0xA0];
                u8ScpReg[0x2B]= (u8ScpReg[0xA0]&0x10) ? u8ScpReg[0x2B]|0x10 : u8ScpReg[0x2B]&~0x10;
                break;
            case 0xA1:
                u8ScpReg[0xA1]&=0x07;
                break;

            /* ---------Adjust Voltage----------------- */
            case 0xB1:          // VSET_BOUNDARY_L
               if(BUILD_WORD(u8ScpReg[0xB1], u8ScpReg[0xB0]) < u16Min_Vout)
               {/* Update V Boundary to min value */
                   if(BUILD_WORD(u8ScpReg[0xB1], u8ScpReg[0xB0]) == 0)
                   {
                       u8ScpReg[0xB1]=u8IniScpReg[0xB1];
                       u8ScpReg[0xB0]=u8IniScpReg[0xB0];
                   }
                   else
                     SetScpBYTE2WORD(0xB0,u16Min_Vout);
//                    u8ScpReg[0xB1] = CAL_LO_BYTE(u16Min_Vout);
//                    u8ScpReg[0xB0] = CAL_HI_BYTE(u16Min_Vout);
               }
               else if(BUILD_WORD(u8ScpReg[0xB1], u8ScpReg[0xB0]) > u16Max_Vout)
               {/* Update V Boundary to min value */
                  SetScpBYTE2WORD(0xB0,u16Max_Vout);
//                        u8ScpReg[0xB1] = CAL_LO_BYTE(u16Max_Vout);
//                        u8ScpReg[0xB0] = CAL_HI_BYTE(u16Max_Vout);
               }

                u16VBOUNDARY=BUILD_WORD(u8ScpReg[0xB1], u8ScpReg[0xB0]);
                break;
            case 0xB3:          // ISET_BOUNDARY_L
                if(BUILD_WORD(u8ScpReg[0xB3], u8ScpReg[0xB2]) < u16Min_Iout)
                {/* Update I Boundary to min Ialue */
                   if(BUILD_WORD(u8ScpReg[0xB3], u8ScpReg[0xB2]) == 0)
                   {
                       u8ScpReg[0xB2]=u8IniScpReg[0xB2];
                       u8ScpReg[0xB3]=u8IniScpReg[0xB3];
                   }
                   else
                     SetScpBYTE2WORD(0xB2,u16Min_Iout);
//                    u8ScpReg[0xB3] = CAL_LO_BYTE(u16Min_Iout);
//                    u8ScpReg[0xB2] = CAL_HI_BYTE(u16Min_Iout);
                }
                else if(BUILD_WORD(u8ScpReg[0xB3], u8ScpReg[0xB2]) > u16Max_Iout)
               {/* Update I Boundary to Max Ialue */
                  SetScpBYTE2WORD(0xB2,u16Max_Iout);
//                     u8ScpReg[0xB3] = LO_BYTE(u16Max_Iout);
//                     u8ScpReg[0xB2] = HI_BYTE(u16Max_Iout);
               }
                u16IBOUNDARY=BUILD_WORD(u8ScpReg[0xB3], u8ScpReg[0xB2]);
                break;
//         case 0xB4:          // MAX_VSET_OFFSET
//            break;
            case 0xB9:          // VSET_L
                /* Check limit & apply it*/
                u16VSET=BUILD_WORD(u8ScpReg[0xB9], u8ScpReg[0xB8]);
                ScpUpdateVolt();
                break;
            case 0xBB:          // ISET_L
                /* Copy value to ISSET */
//            u8ScpReg[0xCB] = BUILD_WORD(u8ScpReg[0xBB], u8ScpReg[0xBA])/50;
                u16ISET=BUILD_WORD(u8ScpReg[0xBB], u8ScpReg[0xBA]);
                ScpUpdateCurr();
                break;
            case 0xBD:          // VSET_OFFSET_L
 //               u16CalValue=(WORD)(u8ScpReg[0xB4]&0x3F)*(ScpPowOfTen(u8ScpReg[0xB4]>>6));
                  u16CalValue=scppowten(u8ScpReg[0xB4] & 0x3F, u8ScpReg[0xB4] >> 6);
                if(!(u8ScpReg[0xBC]&0x80))
                {/*Positive offset */
//                   u16CalValue = u16VSET + Min(BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F),u16CalValue);

                    if(BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F) <= u16CalValue)
                    {/* Offset must be under MAX_VSET_OFFSET */
                        u16CalValue = u16VSET + BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F);//(((WORD)(u8ScpReg[0xBC]&0x7F)<<8)|u8ScpReg[0xBD]);
                    }
                    else
                    {/* offset is larger than MAX_VSET_OFFSET*/
                        u16CalValue = u16VSET + u16CalValue;
                    }
                }
                else
                {/* Negative offset*/
                    if((BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F)) < u16VSET)    //if V offset  < Voltage value
                    {
//                        u16CalValue = u16VSET - Min(BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F),u16CalValue);
                        if((BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F)) > u16CalValue)
                        {/* offset > VSET, it will make VSET < 0 */
                            u16CalValue = u16VSET - u16CalValue;
                        }
                        else
                        {
                            u16CalValue = u16VSET - (BUILD_WORD(u8ScpReg[0xBD], u8ScpReg[0xBC]&0x7F)) ;
                        }
                    }
                    else
                        u16CalValue = 0;
                }

            //    SetScpBYTE2WORD(0xB8,u16CalValue);
                u8ScpReg[0xB9] = LO_BYTE(u16CalValue); // VSET_L
                u8ScpReg[0xB8] = HI_BYTE(u16CalValue); // VSET_H
                /* Check limit & apply it*/
                ScpUpdateVolt();
            //    SetScpBYTE2WORD(0xBC,0);
                u8ScpReg[0xBC] = 0;  //Write Clear
                u8ScpReg[0xBD] = 0;  //Write Clear
                break;
            case 0xBF:          // ISET_OFFSET_L
        //        u16CalValue=(u8ScpReg[0xB5]&0x3F)*(ScpPowOfTen(u8ScpReg[0xB5]>>6));
               u16CalValue=scppowten(u8ScpReg[0xB5] & 0x3F, u8ScpReg[0xB5] >> 6);
                if(!(u8ScpReg[0xBE]&0x80))
                {/*Positive offset */

                    if(BUILD_WORD(u8ScpReg[0xBF], u8ScpReg[0xBE]&0x7F) < u16CalValue)
                    {/* Offset must be under MAX_ISET_OFFSET */
                        u16CalValue = u16ISET + BUILD_WORD(u8ScpReg[0xBF], u8ScpReg[0xBE]&0x7F);
                    }
                    else
                    {/* offset is larger than MAX_ISET_OFFSET*/
                        u16CalValue = u16ISET + u16CalValue;
                    }
                }
                else
                {/* Negative offset*/
                    if(BUILD_WORD(u8ScpReg[0xBF], u8ScpReg[0xBE]&0x7F) >= u16VSET) // I offset > Iset
                    {/* offset > ISET, it will make ISET < 0 */
                        u16CalValue = 0;
                    }
                    else
                    {
                        if(BUILD_WORD(u8ScpReg[0xBF], u8ScpReg[0xBE]&0x7F) < u16CalValue)
                            u16CalValue = u16ISET - BUILD_WORD(u8ScpReg[0xBF], u8ScpReg[0xBE]&0x7F);
                        else
                            u16CalValue = u16ISET - u16CalValue;
                    }
                }

                u8ScpReg[0xBB] = LO_BYTE(u16CalValue); // ISET_L
                u8ScpReg[0xBA] = HI_BYTE(u16CalValue); // ISET_H
                /* Check limit & apply it*/
                ScpUpdateCurr();
                u8ScpReg[0xBE] = 0;  //Write Clear
                u8ScpReg[0xBF] = 0;  //Write Clear
                break;
            /* implement 0xCA flow */
            case 0xCA:          // VSSET
//            TOGGLE_PO(P0_0);
                /* Copy voltage value to VSET */
//                u16CalValue=u8ScpReg[0xCA]*10/*+u8ScpReg[0xC7]*1000*/+3000;
               SetScpBYTE2WORD(0xB8,u8ScpReg[0xCA]*10/*+u8ScpReg[0xC7]*1000*/+3000);
//                u8ScpReg[0xB9] = LO_BYTE(u16CalValue);
//                u8ScpReg[0xB8] = HI_BYTE(u16CalValue);
                u16VSET=BUILD_WORD(u8ScpReg[0xB9], u8ScpReg[0xB8]);
                /* Check limit & apply it*/
                ScpUpdateVolt();
                break;
            case 0xCC:          // STEP_VSET_OFFSET
//                u16CalValue = (u8ScpReg[0xB4]&0x3F)*(ScpPowOfTen(u8ScpReg[0xB4]>>6));   //Get MAX_VSET_OFFSET first
               if(!(u8ScpReg[0xCC]&0x80))
               {/*Positive offset */
//                    if((u8ScpReg[0xCC]&0x7F)*u8ScpReg[0x96] <= u16CalValue)
                     {/* Offset must be under MAX_VSET_OFFSET */
                        u16CalValue = u16VSET + ((u8ScpReg[0xCC]&0x7F)*u8ScpReg[0x96]);
                    }
//                    else
                    {
//                        u16CalValue = u16VSET + u16CalValue;
                    }
                }
                else
               {/* Negative offset*/
                    if(((u8ScpReg[0xCC]&0x7F)*u8ScpReg[0x96]) < u16VSET)      //if V step offset  < Voltage value
                    {
//                        if(((u8ScpReg[0xCC]&0x7F)*u8ScpReg[0x96]) > u16CalValue)
                        {/* offset > VSET, it will make VSET < 0 */
//                            u16CalValue = u16VSET - u16CalValue;
                        }
//                        else
                        {
                            u16CalValue = u16VSET - ((u8ScpReg[0xCC]&0x7F)*u8ScpReg[0x96]) ;
                        }
                    }
                    else
                        u16CalValue = 0;
                }
                u8ScpReg[0xB9] = LO_BYTE(u16CalValue); // VSET_L
                u8ScpReg[0xB8] = HI_BYTE(u16CalValue); // VSET_H
                /* Check limit & apply it*/
                ScpUpdateVolt();
                u8ScpReg[0xCC] = 0;  //Write Clear
                break;
            /* ---------Adjust Current----------------- */
//         case 0xB5:          // MAX_ISET_OFFSET
//            break;
            case 0xCB:          // ISSET
//            TOGGLE_PO(P0_1);
                /* Copy value to ISET */
//                u16CalValue=u8ScpReg[0xCB]*50;
               SetScpBYTE2WORD(0xBA,u8ScpReg[0xCB]*50);
//                u8ScpReg[0xBB] = LO_BYTE(u16CalValue);
//                u8ScpReg[0xBA] = HI_BYTE(u16CalValue);
                u16ISET=BUILD_WORD(u8ScpReg[0xBB], u8ScpReg[0xBA]);
                ScpUpdateCurr();
                break;
            case 0xCD:          // STEP_ISET_OFFSET
       //         u16CalValue = (u8ScpReg[0xB5]&0x3F)*(ScpPowOfTen(u8ScpReg[0xB5]>>6));   //Get MAX_ISET_OFFSET first
               u16CalValue=scppowten(u8ScpReg[0xB5] & 0x3F, u8ScpReg[0xB5] >> 6);
                if(!(u8ScpReg[0xCD]&0x80))
                {/*Positive offset */
                    if((u8ScpReg[0xCD]&0x7F)*u8ScpReg[0x97] < u16CalValue)
                    {/* Offset must be under MAX_ISET_OFFSET */
                        u16CalValue = u16ISET + ((u8ScpReg[0xCD]&0x7F)*u8ScpReg[0x97]);
                    }
                    else
                    {
                        u16CalValue = u16ISET + u16CalValue;
                    }
                }
                else
                {/* Negative offset*/
                    if(((u8ScpReg[0xCD]&0x7F)*u8ScpReg[0x97]) >= u16ISET) // I step offset > Iset
                    {/* offset > ISET, it will make ISET < 0 */
                        u16CalValue = 0;
                    }
                    else
                    {
                        if(((u8ScpReg[0xCD]&0x7F)*u8ScpReg[0x97]) < u16CalValue)
                            u16CalValue = u16ISET - ((u8ScpReg[0xCD]&0x7F)*u8ScpReg[0x97]);
                        else
                            u16CalValue = u16ISET - u16CalValue;
                    }
                }
                u8ScpReg[0xBB] = LO_BYTE(u16CalValue); // ISET_L
                u8ScpReg[0xBA] = HI_BYTE(u16CalValue); // ISET_H
                /* Check limit & apply it*/
                ScpUpdateCurr();
                u8ScpReg[0xCD] = 0;  //Write Clear
                break;
/******************************** TYPE A ****************************/
            case 0x2B:
                u8ScpReg[0xA0]= (u8ScpReg[0x2B]&0x10)? u8ScpReg[0xA0]|0x10 : u8ScpReg[0xA0]&~0x10;
//                bSet_Out = (u8ScpReg[0x2B]&0x01)? 1 : 0;
                if(!(u8ScpReg[0x2B]&0x01))
                {
                    u8ScpReg[0x2C]=0x34;
                    u8ScpReg[0x2D]=0x14;
                }
                u16CalValue=(WORD)u8ScpReg[0x2C]*100;
                u8ScpReg[0xB9] = LO_BYTE(u16CalValue);
                u8ScpReg[0xB8] = HI_BYTE(u16CalValue);
                /* Check limit & apply it*/

                u16CalValue=(WORD)u8ScpReg[0x2D]*100;
                u8ScpReg[0xBB] = LO_BYTE(u16CalValue);
                u8ScpReg[0xBA] = HI_BYTE(u16CalValue);
                ScpUpdateVolt();
                u8ScpReg[0x2B]&= ~0xEF;      // only leave bit 4
                break;
            case 0x2C:
            case 0x2D:
               ScpcheckVOUTvalid(u8ParsedRegAdr);
            break;
            case 0xCE:
            case 0xCF:
#ifdef SCP_AUTHORITY
//               if(u8ScpReg[0xCE] && u8ScpReg[0xCE]<=0x0B)
            if(u8ScpReg[0xCE] != 0xFF)
            {
               u8ScpReg[0xCF]=0x80;
            }
            else
            {
               u8ScpReg[0xCE]=0x00;
               u8ScpReg[0xCF]=0x00;
            }
            bScpAntipass=0;
#endif
              break;
               
            }
        }
#if 0 //for test
        else
        {
            switch(u8ParsedRegAdr)
            {
            /* -----For Test-----------*/
            case 0xE1:  //duration to Read ADC
                break;
            case 0xE2:
                break;
            case 0xE3:
                if((u8ScpReg[0xE3]&0x0F) == 0x00)
                {
                    ATM &= 0xF1;   //Set force TX DAT/EN/RDY = 0
                }
                else if((u8ScpReg[0xE3]&0x0F) == 0x01)
                {
                    ATM &= 0xF1;   //Set force TX DAT/EN/RDY = 0
                    ATM |= 0x06;   //fortxen=1, fortxrdy=1
                }
                else if((u8ScpReg[0xE3]&0x0F) == 0x03)
                {
                    SET_FORCETX_HIGH();
                }
                else if((u8ScpReg[0xE3]&0x0F) == 0x05)
                {
                    SET_FORCETX_LOW();
                }
                break;
            case 0xE4:   //Enable DAC1 channel to DP
                if(u8ScpReg[0xE4])
                    ENA_DP_DAC1();
                else
                    DIS_DP_DAC1();
                break;
#if 0
            case 0xE5:  //Enable 0xE1 function
                break;
            case 0xE6:  //Give DACV0 when read it
                break;
            case 0xE7:  //Dongle BC reset
                break;
            case 0xE8:  //SREAD_VOUT use
                break;
            case 0xE9:  //SREAD_VOUT use
                break;
            case 0xEA:  //SREAD_VOUT use
                break;
            case 0xEB:  //stop RxRst in scpPhy.c
                break;
            case 0xEC:
                break;
#endif
            }
        }
#endif

        if((u8RxBuffer[0] == SBRWR) || ((u8RxBuffer[0] == MBRWR) && ((u8ParsedRegAdr-u8RxBuffer[1]) == u8RxBuffer[2]-1)))
      {/* all request data has been processed ==> finish the for-loop */
            break;
        }
    }
}

BYTE ScpRdReqHdlr()
{
    //BYTE WaitNextLoop = 0;   //If enable ADC this loop, read it's value next loop
   WORD u16CalValue;
   if(u8ParsedRegAdr == 0)  { u8ParsedRegAdr = u8RxBuffer[1]; }   //give a initail address
    for( ; (u8ParsedRegAdr-u8RxBuffer[1]) < MAX_NUM_SCP_ACCESS; u8ParsedRegAdr++)
    {
//      if((u8ParsedRegAdr >= 0xA8) && (u8ParsedRegAdr < 0xE0))
//        if(u8ParsedRegAdr < 0xD0)
        {
            switch(u8ParsedRegAdr)
            {
            /* ---------General Register----------------*/
            case 0xA0:     //
                u8ScpReg[0xA0] = IS_QC_VBUS_ON()   ? (u8ScpReg[0xA0]|0x80) : (u8ScpReg[0xA0]&~0x80);
                break;
            case 0xA2:
                u8ScpReg[0xA2]=(u8ScpReg[0xA2]&~0x01) | (u8ScpRegA2&0x01);
                u8ScpReg[0xA2] = (IS_CLVAL()) ? (u8ScpReg[0xA2]|=0x10) : (u8ScpReg[0xA2]&=~0x10);
                u8ScpRegA2=0;
                break;
            case 0xA3:
                u8ScpReg[0xA3]=u8ScpRegA3;
                u8ScpRegA3=0;
                break;
            case 0xA6:
                u8ScpReg[0xA6]=30;
                break;
            case 0xA7:
                u8ScpReg[0xA7]=33;
                break;
            case 0xA8:     //READ_VOUT_H
                if((u8RxBuffer[0] == MBRRD))// && ((u8ParsedRegAdr +1) == 0xA9)) //0xA9 = READ_VOUT_L
            { break;}   //avoid enable/disable DACV0 state 2times for a short time. (READ_VOUT_H & _L)
            case 0xA9:     //READ_VOUT_L
            case 0xC8:     //SREAD_VOUT
                /* update SREAD_VOUT & READ_VOUT */
                //if(bScpPrlAdc)
            {
                //bScpPrlAdc = 0;
                //DES_CHANNEL_0();

                // u16CalValue = ((DACV0<<2) | (DACLSB&0x03))*20;   //For 10-bit operation
                u16CalValue = ((u8Avgvol[0]+u8Avgvol[1])<<1)*20; //Get Real VIN    //For 8-bit operation


#ifndef FPGA
//                if(DACV0 <= u8DACV0Lv)  //Offset  for mounted IC
                {
//                    u16CalValue += u8VinOffset ; // add an offset form trim and reply
                }
//               if(u16CalValue < 5000)  //Offset for socket
//               {
//                  u16CalValue += 100;
//               }
#endif
//                u16CalValue -=  DACV2*5;         //       DACV2 24mA        1A - 200mV  for test MATE 9 needs

                u8ScpReg[0xA9] = LO_BYTE(u16CalValue);  //Update READ_VOUT_L
                u8ScpReg[0xA8] = HI_BYTE(u16CalValue);  //Update READ_VOUT_H

                /* Calculate SREAD_VOUT & VROFFSET */
#ifdef ENA_VSSET_45_55_RANGE
                if(u16CalValue < u8ScpReg[0xC6]*1000)
                {
                    u8ScpReg[0xC6] = u16CalValue/1000;   //Give VROFFSET a lower limit to avoid getting negative result for VBUS
                }
                u16CalValue = u16CalValue - u8ScpReg[0xC6]*1000;
                while(u16CalValue > 555) { //255*10+3000 = 5550 = 0x15AE
                    u16CalValue -= 1000;  // Increase 1V
                    u8ScpReg[0xC6] += 1;    // Decrrease 1V
                }
                while((u16CalValue < 4500) && (u8ScpReg[0xC6] > 0)) {   //4500 = 0x1194
                    u16CalValue += 1000;  // Decrrease 1V
                    u8ScpReg[0xC6] -= 1;    // Increase 1V
                }
#endif
                u8ScpReg[0xC8]= (u16CalValue >= 5550) ? 255 : (u16CalValue-3000)/10;
            }
            break;
            case 0xAA:     //READ_IOUT_H
                if((u8RxBuffer[0] == MBRRD))//
            { break;}
            case 0xAB:     //READ_IOUT_L
            case 0xC9:     //SREAD_IOUT
//            if(currFirstRead == 0)
//            {
//               currFirstRead = 1;
//               break;
//            }
                /* update SREAD_IOUT & READ_IOUT*/
                // if(bScpPrlAdc)
            {
                //  bScpPrlAdc = 0;
                //DES_CHANNEL_0();

                //u16CalValue = (((DACV0<<2) | (DACLSB&0x03))*3)*2;  //real measured current = 3 times DACV0
#ifdef CFG_CAN1112B0
                u16CalValue = (u8CurVal<<2)*2*3;  //real measured current = 3 times DACV2
                if(u16CalValue > 150)
                    u16CalValue += 150;      //offset 20190115
#else
                u16CalValue = ((u8Avgcur[0]+u8Avgcur[1])<<1)*2*3;  //real measured current = 3 times DACV2
#endif

                u8ScpReg[0xC9] = u16CalValue/50;
                u8ScpReg[0xAB] = LO_BYTE(u16CalValue);
                u8ScpReg[0xAA] = HI_BYTE(u16CalValue);

                // CLR_CHANNEL_SWITCH();  // switch chennels, CH0:IS,  CH3:DI
            }
            break;
            case 0xCF:
               
               u8ScpReg[0xCF] = bScpAntipass ? u8ScpReg[0xCF]|0x40 : u8ScpReg[0xCF]&~0x40;
            break;

            /******************************** TYPE A ****************************/
            case 0x03:
                u8ScpReg[0x03]=u8ScpReg03;
                u8ScpReg03=0;
                break;
            case 0x28:
                u8ScpReg[0x28]=u8ScpReg28;
                u8ScpReg28=0;
                break;
            case 0x2B:
                u8ScpReg[0x2B]&=0x10;
                break;
            case 0x2F:
//                bReg2Fread=1;
                u8ScpReg[0x21]=0x03;
                break;
            default:
                break;
            }
        }
#if 0
        else
        {
            switch(u8ParsedRegAdr)
            {
            case 0x82:  //B_ADP_TYPE
//            if(0xE2 == 0x01)
//            {//test, monitor DP, Dn
//               ENA_DP_DAC1();
//               u8ScpReg[0xE4] = 0x01;
//            }
 /*           if(u8Debug & 0x02)   //Marc20180905
            {
               //u8ScpReg[0xE7] = 1;
               ATM &= 0xF1;   //Set force TX DAT/EN/RDY = 0
               ATM |= 0x06;   //fortxen=1, fortxrdy=1
            }*/
                break;
            case 0xE6:
                u8ScpReg[0xE6] = DACV0;
                break;
            }
        }
#endif
      if(/*bScpPrlAdc || */(u8RxBuffer[0] == SBRRD) || ((u8RxBuffer[0] == MBRRD) && ((u8ParsedRegAdr-u8RxBuffer[1]) == u8RxBuffer[2]-1)))
      {/* all request data has been processed ==> finish the for-loop */
            break;
      }
    }
    return (0);//bScpPrlAdc);  //if waitNextLoop = 1, then Next loop trigger by timer
}

BYTE ScpValidityCheck()
{
    BYTE ii;
    if(((u8RxBuffer[0] & 0x0F) == SBRWR) && (u8RxBuffer[1] > 0xA0) && (u8RxBuffer[1] != 0xCE) && !(u8ScpReg[0xA0]&0x40) && !(u8ScpReg[0xCF]&0x80))
    {   /*OUTPUT_MODE is not SCP_MODE ==> B type Register can't be write,  in AF mode*/
        return (FALSE);
    }

    if((u8RxBuffer[0] & 0x10) && ((u8RxBuffer[1]%2) || (u8RxBuffer[2]%2) || u8RxBuffer[2]>MAX_NUM_SCP_ACCESS))
    {   /*multiple RW have to start at even address and length has to be even and < 16*/
        return (FALSE);
    }

#ifdef SCP_AUTHORITY
   if(u8RxBuffer[1] == 0xCE)
   {        
      if(((u8RxBuffer[0] == SBRWR) && (!u8RxBuffer[2] || (u8RxBuffer[2]<0xFF && u8RxBuffer[2]>0x0B))) ||               // data
         ((u8RxBuffer[0] == MBRWR) && (!u8RxBuffer[3] || (u8RxBuffer[3]<0xFF && u8RxBuffer[3]>0x0B))))
      return (FALSE);
   }
#endif

    for(ii=u8RxBuffer[1]; ii<u8RxBuffer[1]+u8RxBuffer[2]; ii++)
    {
      if(!u8ScpRegAttr[ii])
      {   /*the register isn't be defined.*/
         return (FALSE);
      }
      else if(((u8RxBuffer[0]&0x0F) == SBRWR) && (!(u8ScpRegAttr[ii] & (RW|WC))))
      {   /*the register can't be write*/
         return (FALSE);
      }
      else if(((u8RxBuffer[0]&0x0F) == SBRRD) && (!(u8ScpRegAttr[ii] & (RW|RO|RC))))
      {/*the register can't be read*/
         return (FALSE);
      }

      if((u8RxBuffer[0] & 0x10) && (u8ScpRegAttr[ii] & SO))
      {/*only supports single read / write*/
         return (FALSE);
      }

      if(ii>=0xD0)
      {
         return (FALSE);
      }

      if(!(u8RxBuffer[0]&0x10))
      {/* all request data has been processed ==> finish the for loop */
         break;
      }
    }

    return(TRUE);     //no error
}

BYTE ScpAFValidityCheck(void)
{
   return ((u8ScpReg[0xCF]&0x80) && u8RxBuffer[1]>=0xA0 && u8RxBuffer[1]<0xCE) ? 1 : 0;
}
/*
BYTE ScpSingleReadCheck()
{
    if(!(u8ScpRegAttr[u8RxBuffer[1]] & (RW|RO|RC)))
    {   
        return (FALSE);
    }

    return(TRUE);     //no error
}*/

void ScpPrlProc ()
{
    BYTE ii;
    switch (u8ScpPrlState)
    {
    case SCP_PRL_INIT:
        break;
    case SCP_PRL_READY:
#ifdef AFC_ENABLE
        bAfcMode=0;
#endif
        if(u8SCPstate==0x02)
        {
            if(u8ScpReg[0xA0] & 0x40)                 // SCP mode vbus off
                SET_VBUS_OFF();                       // disable vbus 1s

            Go_QCSTA_IDLE();
            u16Ctimer=tSCPResetime;
            //  u8StatePM=PM_STATE_ATTACHED;
            //  u8StatePE =PE_SRC_Disabled;
            SCPVoltTrans(MAP_PDO1_DAC());
            DisableConstCurrent();
            bEventScprl = 0;
            return;
        }
        switch (u8RxBuffer[0]) // command
        {
        case SBRWR:              // signal write
            if(u8RxNumByte == 3 && ScpCheckCnt == 11) // master ping + sync + cmd + sync + addr + sync + data + sync + crc + sync + master ping
            {
#ifdef SCP_AUTHORITY
                if(ScpAFValidityCheck())
                {
                    if(u8RxBuffer[1]<=0xA7)       // not at 0xA0 ~ 0xA7 !!!!!!!!!!!!!!!!   modified is needed  !!!!!!!!!!!!!!!!!
                    {
                        Anti_data.u8ScpAnti_data[u8RxBuffer[1]-0xA0] = u8RxBuffer[2];
                        Anti_data.u8ScpAnti_data[u8RxBuffer[1]-0xA0+8]=u8RxBuffer[2]+1;

//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                        SCPreturnAck(ACK0);
                        bScpAntipass=0;
                    }
                    else
                       SCPreturnAck(NACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                }
                else
#endif
                {
                /* Check Validity of Request */
                    if((ScpValidityCheck() == TRUE))
                    {
                        /* Write data to Register */
                        u8ScpReg[u8RxBuffer[1]] = u8RxBuffer[2]; // 0xA1 bit 3~7 RO
                        SCPreturnAck(ACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                        /* Implement request */
                        //              ScpWrReqHdlr();
                        /* Clear Data if the attribution is Write Clear */
//                      if(u8ScpRegAttr[u8RxBuffer[1]] & WC)
//                      {
//                         u8ScpReg[u8RxBuffer[1]] = 0;
//                      }
                    }
                    else
                    {
                       SCPreturnAck(NACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                    }
                }
                u8TxNumByte = 1;
                u8ScpPrlState = SCP_PRL_RESPONSE;
            }
            else
            {
                u8ParsedRegAdr = 0;
                u8ScpPrlState = SCP_PRL_READY;
            }
            break;
        case SBRRD:
            ScpSRPrlProc();                               // single read
            break;
        case MBRWR:                       // multiple write
            /* Check Validity of Request */
            if(u8RxNumByte > 4 && u8RxNumByte == (u8RxBuffer[2] + 3) && ScpCheckCnt == (u8RxBuffer[2]*2+11))
            {
#ifdef SCP_AUTHORITY
                if(ScpAFValidityCheck())
                {
                    if((u8RxBuffer[1]+u8RxBuffer[2]-1)<=0xA7 && !((u8RxBuffer[1]|u8RxBuffer[2])%2))        //  !!!!!!!!!!!!!!!!   modified is needed  !!!!!!!!!!!!!!!!!
                    {
                        for(ii=0; ii<u8RxBuffer[2]; ii++)
                        {
                            Anti_data.u8ScpAnti_data[u8RxBuffer[1]+ii-0xA0] = u8RxBuffer[3+ii];
                            Anti_data.u8ScpAnti_data[u8RxBuffer[1]+ii-0xA0+8]=u8RxBuffer[3+ii]+1;
                        }
                       SCPreturnAck(ACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                        bScpAntipass=0;
                    }
                    else
                       SCPreturnAck(NACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                }
                else
#endif
                {
                    if((ScpValidityCheck() == TRUE))
                    {
                        /* Write data to Register */
                        for(ii=0; ii<u8RxBuffer[2]; ii++)
                        {
                            u8ScpReg[u8RxBuffer[1]+ii] = u8RxBuffer[3+ii];
                        }
                       SCPreturnAck(ACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                        /* Implement request */
                        //          ScpWrReqHdlr();
                        /* Clear Data if the attribution is Write Clear */
                        /*                  for(ii=0; ii<u8RxBuffer[2]; ii++)
                        {
                        if(u8ScpRegAttr[u8RxBuffer[1]+ii] & WC)
                        {
                        u8ScpReg[u8RxBuffer[1]+ii] = 0;
                        }
                        }*/
                    }
                    else
                    {
                       SCPreturnAck(NACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                    }
                }
                u8TxNumByte = 1;
                u8ScpPrlState = SCP_PRL_RESPONSE;
            }
            else
            {
                u8ParsedRegAdr = 0;
                u8ScpPrlState = SCP_PRL_READY;
            }
            break;
        case MBRRD:
            if(u8RxNumByte == 3 && ScpCheckCnt == 11)
            {
#ifdef SCP_AUTHORITY
                if(ScpAFValidityCheck())
                {
                    if((u8RxBuffer[1]+u8RxBuffer[2]-1)<=0xBF && !((u8RxBuffer[1]|u8RxBuffer[2])%2))
                    {
                        SCPreturnAck(ACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                        u8TxNumByte = u8RxBuffer[2] + 1;
                        for(ii=0; ii<u8RxBuffer[2]; ii++)
                        {
                            u8TxBuffer[1+ii] = Anti_data.u8ScpAnti_data[u8RxBuffer[1]+ii-0xA0];
                        }
                    }
                    else
                    {
                        SCPreturnAck(NACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                        u8TxNumByte = 1;
                    }

                }
                else
#endif
                {
                    /* Check Validity of Request */
                    if((ScpValidityCheck() == TRUE))
                    {
                        /* Implement request */
                        if(ScpRdReqHdlr())
                        {
                            break;
                        }

                        /* Copy data from Register */
                       SCPreturnAck(ACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                        u8TxNumByte = u8RxBuffer[2] + 1;
                        for(ii=0; ii<u8RxBuffer[2]; ii++)
                        {
                            u8TxBuffer[1+ii] = u8ScpReg[u8RxBuffer[1]+ii];
                            if(u8ScpRegAttr[u8RxBuffer[1]+ii] & RC)
                            {/* Clear Data if the attribution is Read Clear */
                                u8ScpReg[u8RxBuffer[1]+ii] = (u8RxBuffer[1]+ii == 0xA2) ? (u8ScpReg[0xA2] & ~0x07) : 0;
                            }
                        }
                    }
                    else
                    {
                       SCPreturnAck(NACK0);
//                        u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                        u8TxNumByte = 1;
                    }
                }
                u8ScpPrlState = SCP_PRL_RESPONSE;
            }
            else
            {
                u8ParsedRegAdr = 0;
                u8ScpPrlState = SCP_PRL_READY;
            }
            break;
#ifdef AFC_ENABLE
        case 0x08:
            if (AfcCmd == 0x08) AfcCount++;
            else {
                AfcCmd = 0x08;
                AfcCount = 1;
            }
            bAfcMode = 1;
            u8TxBuffer[0] = 0x08;
            u8TxNumByte = 1;

            u8ScpPrlState = SCP_PRL_RESPONSE;
            break;
        case 0x46:
            if (AfcCmd == 0x46) AfcCount++;
            else {
                AfcCmd = 0x46;
                AfcCount = 1;
            }
            bAfcMode = 1;
            u8TxBuffer[0] = 0x46;
            u8TxNumByte = 1;

            u8ScpPrlState = SCP_PRL_RESPONSE;
            break;
#endif
        }
        if(u8SCPstate==0x01) u16Ctimer = (u8ScpReg[0xA1]&0x07)*505;        // receive command reset timer.
        break;
    case SCP_PRL_RESPONSE:
        if(u8RxBuffer[0]&SBRWR == SBRWR)
        {
            if((u8TxBuffer[0]&ACK0) == ACK0)
            {
               if(ScpAFValidityCheck())
               {
                  if((u8RxBuffer[1]==0xA7) || (u8RxBuffer[0] == MBRWR && (u8RxBuffer[1]+u8RxBuffer[2]-1)==0xA7)) bEventScpAF=1;     //after write 0xA7 call anti_fake
               }
               else
                  ScpWrReqHdlr();
            }
#if 0
            else if((u8RxBuffer[1] == 0x2C || u8RxBuffer[1] ==0x2D))// && (u8TxBuffer[0]&NACK0) == NACK0)   // if 0x2C or 0x2D was written a wrong number, response a nack and resume default.
            {
               u8ScpReg[u8RxBuffer[1]]=u8IniScpReg[u8RxBuffer[1]];
            }
#endif
        }

#ifdef AFC_ENABLE
        if (bAfcMode && AfcCount>=3) {
            switch (AfcCmd) {
            case 0x08:
                //     PWR_I = 44;        // current limit 2.2A
                //     PWR_V = 65;        // 5.20V
                //     PWRCTL &= ~0x03;
                u16Target20mV = 260;
                u8Target50mA=44+ISET_OFFSET;
                SetPwrTransQC ();

                //           QcVoltTrans(260);
                break;
            case 0x46:
                //     PWR_I = 36;     // current limit 1.8A
                //     PWR_V = 113;    // 9.04V
                //     PWRCTL &= ~0x03;
                u16Target20mV = 452;
                u8Target50mA=36;
                SetPwrTransQC ();
                //         QcVoltTrans(450);
                break;
            }
        }
#endif

        u8ParsedRegAdr = 0;
        u8ScpPrlState = SCP_PRL_READY;
        ScpCheckCnt=0;

        if(u8SCPstate==0x02)      // received SCP Reset signal
        {
            ScpgoReset();
            return;              // keep bEventScprl = 1;
        }
        break;
    }
    bEventScprl = 0; // this is the flag that triggered this process. Done, clear the flag.
}

void ScpSRPrlProc(void)                               // single read
{
    if(u8RxNumByte == 2 && ScpCheckCnt == 9) // master ping + sync + cmd + sync + addr + sync + crc + sync + master ping)
    {
#ifdef SCP_AUTHORITY
        if(ScpAFValidityCheck())
        {
            if(u8RxBuffer[1]<=0xBF)
            {
                SCPreturnAck(ACK0);
//                u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                u8TxBuffer[1] = Anti_data.u8ScpAnti_data[u8RxBuffer[1]-0xA0];
                u8TxNumByte = 2;
            }
            else
            {
                SCPreturnAck(NACK0);
//                u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                u8TxNumByte = 1;
            }
        }
        else
#endif
        {
            /* Check Validity of Request */
            if((ScpValidityCheck() == TRUE))
            {
                /* Implement request */
                ScpRdReqHdlr();
                /* Copy data from Register */
                SCPreturnAck(ACK0);
//                u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? ACK0|0x80 : ACK0;
                u8TxBuffer[1] = u8ScpReg[u8RxBuffer[1]];
                if(u8ScpRegAttr[u8RxBuffer[1]] & RC)
                {
                    u8ScpReg[u8RxBuffer[1]] = (u8RxBuffer[1] == 0xA2) ? (u8ScpReg[u8RxBuffer[1]] & ~0x07) : 0;
                }
                u8TxNumByte = 2;
            }
            else
            {
                SCPreturnAck(NACK0);
//                u8TxBuffer[0] = ((u8ScpReg[0xA0]&0x08) && (u8ScpRegA3 | u8ScpRegA2)) ? NACK0|0x80 : NACK0;
                u8TxNumByte = 1;
            }
        }
        u8ScpPrlState = SCP_PRL_RESPONSE;
    }
    else
    {
        u8ParsedRegAdr = 0;
        u8ScpPrlState = SCP_PRL_READY;
    }
}

void SCP_TimeOut(void)
{
// if(!(CCCTL & 0xC0))
// SET_RP_ON();
    if((u8ScpReg[0xA1]&0x07) && (u8ScpReg[0xA0]&0x40) && (u8QcSta > QCSTA_DMGND))
    {
        u16Ctimer--;
        if(!u16Ctimer)
        {
            u8ScpRegA2=0x01;
            ScpgoReset();
        }
    }

   if(bdischchk && VbusDischCnt<250) VbusDischCnt++;                   // test voltage high to low
}

void SCP_DischBIST(void)
{
   if(bdischchk)
   {
      u8ScpReg[0xA4] = (VbusDischCnt<=200) ? 0x80 : 0x00;     // <=200 ms pass
   }
   bdischchk=0;
}

void SCP_Reset_Delay(void)
{
    u16Ctimer--;

    if(!u16Ctimer) SET_VBUS_ON();
}

void SCP_DP_protection(void)
{
    if(u8ScpReg[0xA0]&0x10)               // D+ protect disable
    {
        ScpDpCnt++;
        if(ScpDpCnt>200)
        {
            u8ScpReg[0xA0]&=~0x10;        // after 0.2S resume
            u8ScpReg[0x2B]&=~0x10;
            u8DpDmDbCnt = 1; // reset debounce counter
        }
        return;
    }
    ScpDpCnt=0;
    if(u8SCPstate==0x02) return;

//    bRxRst = DACV4 < 52 ? 1 : 0;        // if D+ <= 0.424V do reset.
//    if(u8AvgDP[0] < 53 && u8AvgDP[1] < 53)
    if((!(u8DpDmVal&0x0F)) && u8DpDmDbCnt==3)
    {
        ScpgoReset();
    }
}

void ScpgoReset(void)
{
   u8SCPstate=0x02;
   bEventScprl = 1;
   u8ScpPrlState = SCP_PRL_READY;
}

void Average_VolCur(void)
{   
   u8Avgvol[1]=u8Avgvol[0];
   u8Avgvol[0]=u8VinVal;
   u8Avgcur[1]=u8Avgcur[0];
   u8Avgcur[0]=u8CurVal;
}

#ifdef SCP_AUTHORITY

void ScpSHA256Proc(void)
{
   bScpAntipass = ((Sha256Handle(&Anti_data.u32ScpAnti_data[0],u8ScpReg[0xCE]))==1) ? 1 : 0;
   bEventScpAF=0;
}
#endif

#endif