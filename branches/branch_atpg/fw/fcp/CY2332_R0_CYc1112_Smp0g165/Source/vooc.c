/*
// =============================================================================
// add VOOC / VIVO functions into CY2211S_V100 PD20 firmware

//            copy from cy2311r2, rename some macros

// ALL Rights Are Reserved
// =============================================================================
*/
#include "global.h"


#ifdef VOOC_ENABLE

BYTE code TxMsg_55[2] = {0x01,0x55};
BYTE code TxMsg_04[8] = {0x07,0x08,0x04,0x00,0x76,0x6c,0x76,0x6f};
BYTE code TxMsg_a6[7] = {0x06,0x08,0xa6,0x00,0x16,0x37,0x09};
BYTE code TxMsg_07[5] = {0x04,0x08,0x07,0x00,0x01};
BYTE code TxMsg_05[8] = {0x07,0x08,0x05,0x00,0x00,0x00,0x00,0x00};
BYTE code TxMsg_06[8] = {0x07,0x08,0x06,0x00,0x00,0x00,0x00,0x00};
BYTE code TxMsg_03[4] = {0x03,0x08,0x03,0x00};
BYTE code TxMsg_09[8] = {0x07,0x08,0x09,0x00,0x00,0x00,0x1d,0x41};
BYTE code TxMsg_10[8] = {0x07,0x08,0x10,0x00,0x00,0x00,0x00,0x00};
BYTE code TxMsg_11[8] = {0x07,0x08,0x11,0x00,0x00,0x00,0x00,0x00};

volatile BYTE idata RxBuffer[10];
volatile BYTE idata TxBuffer[9];
volatile BYTE RxIndex;
volatile BYTE TxIndex;
volatile BYTE voocPulses;

BYTE idata volt;
BYTE idata current;
BYTE data u8VOOCsts;

extern bit bTmr1_Vooc;
#ifdef SCP_ENABLE
extern WORD u16Ctimer;
#else
WORD u16Ctimer;
#endif

void uart0_isr (void) interrupt INT_VECT_UART0 {
    if (RI) {
        if (RxIndex<10) {
            RxBuffer[RxIndex] = S0BUF;
            RxIndex++;
        }
    } else if (TI) {
        if (TxIndex <= TxBuffer[0]+1) {
            S0BUF = TxBuffer[TxIndex];
            TxIndex++;
        }
    }
    S0CON = 0x50; // clear RI/TI flags
}

void VOOCVoltTrans (WORD volx2) // voltage in 20mV
{
//   if (u8StatePM==PM_STATE_ATTACHED // power stepping may still not ready (by prior SCP transition)
//    && u8StatePE==PE_SRC_Disabled)  // (by right after entering SCP)
    {
        u16Target20mV = volx2;


//       if((WORD)GET_PWR_I()*50 > u16Max_Iout)  // PWR_I may be changed
//      u8Target50mA=100;              // +20%

        SetPwrTransQC ();
    }
//   else
//      u8DpDmDbCnt = 5;               // come back 5 ms
}

void transmit_vivo(BYTE buffer[], BYTE skip)
{
    volatile BYTE i, checksum=0;

    TxIndex=0;
    S0BUF=0xAA;

    if (skip > buffer[0]) skip=buffer[0]+1;
    for (i=0; i<skip; i++) {
        TxBuffer[i]=buffer[i];
        checksum += buffer[i];
    }

    for (i=skip; i<=buffer[0]; i++) {
        checksum += TxBuffer[i];
    }
    TxBuffer[i]=checksum;
}

void vivo_start(void)
{
    SET_2V7_SHORT_OFF();
    SET_DM_PULLDWN_ENA();
    ENABLE_DPDM_UART();
    bQcSta_Vooc=1;
    SET_CV_MODE();

    u8Target50mA=100;

    DB = 1;       // baud rate doubler
    PCON = 0x80;  // [7]:SMOD
    S0RELL = 0xF3;   // 28800(28846)bps@12MHz
    S0RELH = 0xC3;   // double baudrate and half over-sampling
    S0CON = 0x50;    // mode 1, S0 reception enable
    ES = 0x01;       // IE[4], serial 0
    RxIndex = 0;
    transmit_vivo(TxMsg_55, 10);
    FCPMSK =0x00;//&= ~0x80;  // disable interrupt
    u8QcSta = BCSTA_VIVO;
}

void vivo_prl(void)
{
    if (RxIndex > 3) {
        //P0 = P0 ^ 0x10;     // toggle GPIO3 pin
        switch (RxBuffer[2]) {
        case 0x08: {
            if (RxIndex >= 6) {
                RxIndex=0;
            }
            break;
        }
        case 0x04: {
            if (RxIndex >= 4) {
                RxIndex=0;
                transmit_vivo(TxMsg_04, 10);
            }
            break;
        }
        case 0xa6: {
            if (RxIndex >= 4) {
                RxIndex=0;
                transmit_vivo(TxMsg_a6, 10);
            }
            break;
        }
        case 0x07: {
            if (RxIndex >= 4) {
                RxIndex=0;
                transmit_vivo(TxMsg_07, 10);
            }
            break;
        }
        case 0x05:
            if (RxIndex >= 4) {
                RxIndex=0;

                //temp=80 * u8Vbus;
                //TxBuffer[4]= (BYTE) (temp);
                //TxBuffer[5]= (BYTE) (temp>>8);
                (WORD) TxBuffer[5] = 80 * (u8VinVal-1);
                TxBuffer[4] = TxBuffer[6];

                (WORD) TxBuffer[7] = 25 * (u8CurVal+1);
                TxBuffer[6] = TxBuffer[8];

                transmit_vivo(TxMsg_05, 4);
            }
            break;

        case 0x03: {
            if (RxIndex >= 10) {
//               WORD volt1;
//               volt1=((WORD)((RxBuffer[6] << 8) + RxBuffer[5]))/20;
//               u16ReqPwrV=BUILD_WORD(RxBuffer[5],RxBuffer[6])/20;

//                if(volt<150) volt=150;

//             PWRCTL &= ~0x03;
//             PWRCTL |= volt & 0x03;
//             PWR_V = (volt >>2) & 0xff;


//             if (RxBuffer[4] | RxBuffer[3]) {
//             PWR_I=((WORD)((RxBuffer[4] << 8) + RxBuffer[3]))/50;
//             u8Target50mA=((WORD)((RxBuffer[4] << 8) + RxBuffer[3]))/50;
//             }
//             PWR_I=100;
                VOOCVoltTrans(((WORD)((RxBuffer[6] << 8) + RxBuffer[5]))/20);


//             }
                transmit_vivo(TxMsg_03, 10);

                RxIndex=0;
            }
            break;
        }
        case 0x06: {
            if (RxIndex >= 4) {
                RxIndex=0;
                TxBuffer[4]= 0xad;
                TxBuffer[5]= 0x02;
                TxBuffer[6]= 0xad;
                TxBuffer[7]= 0x02;
                transmit_vivo(TxMsg_06, 4);
            }
            break;
        }
        case 0x09: {
            if (RxIndex >= 4) {
                RxIndex=0;
                transmit_vivo(TxMsg_09, 10);
            }
            break;
        }
        case 0x10: {
            if (RxIndex >= 4) {
                RxIndex=0;
                transmit_vivo(TxMsg_10, 10);
            }
            break;
        }
        case 0x11: {
            if (RxIndex >= 4) {
                RxIndex=0;
                transmit_vivo(TxMsg_11, 10);
            }
            break;
        }//*/
        }
    }
}

void Vooc_init(void)
{
    u16Ctimer=DPDMACC;  // read clear
    u16Ctimer=0;
    voocPulses = 0;
    u8VOOCsts=0;
    //DPDMACC &= 0x0f;  // ?????
    ACCCTL &= ~0x03;
    FCPSTA = 0xff;   // clear all fcp status bits
    FCPMSK = 0x80;  	// enable ACC_DPDM
    IEN2 |= 0x04;	// INT_VECT_FCP, EX9
}

unsigned char transmit_vooc(unsigned char command)
{
    unsigned char i;

    command = (command & 0x1f) | 0xa0;
    for (i=0; i<8; i++) {
        if (command & 0x80) DPDNCTL = 0x0b;
        else DPDNCTL = 0x0a;
        command <<= 1;
        bTmr1_Vooc=1;
        STRT_TMR1(10);   	//low 10 us
        while(bTmr1_Vooc);

        DPDNCTL |= 0x04;	// Dp=1
        bTmr1_Vooc=1;
        STRT_TMR1(500);   	//high 500 us
        while(bTmr1_Vooc);
    }

    DPDNCTL = 0x19;			// 1st read clock
    bTmr1_Vooc=1;
    STRT_TMR1(10);   	//low 10 us
    while(bTmr1_Vooc);
    DPDNCTL = 0x1d;

    bTmr1_Vooc=1;
    STRT_TMR1(4000); 	// wait 4ms
    while(bTmr1_Vooc);

    command = 0;
    for (i=0; i<9; i++) {
        command <<= 1;
        DPDNCTL = 0x19;
        bTmr1_Vooc=1;
        STRT_TMR1(10);   	//low 10 us
        while(bTmr1_Vooc);
        DPDNCTL = 0x1d;		// end with Dp=1 & Dn pulled down
        bTmr1_Vooc=1;
        STRT_TMR1(500);   	//high 500 us
        while(bTmr1_Vooc);
        if (ACCCTL & 0x80) command |= 0x01;
    }
    return command;
}

void Vooc_prl(void)
{
    switch(u8VOOCsts)
    {
    case 0x00:
        bQcSta_Vooc=1;
        u16Ctimer++;
        DPDNCTL = 0x0f;		// Dp=1, Dn=1
        if(u16Ctimer>=250)
        {
            u8VOOCsts=0x01;
            u16Ctimer=0;
            voocPulses=0;
        }
        break;
    case 0x01:
        if(!u16Ctimer)
        {
            if((transmit_vooc(0x08) & 0x40)==0)
            {
                voocPulses++;
                if(voocPulses>10)
                    u8VOOCsts=0x10;

            }
            else
                u8VOOCsts=0x02;
        }
        if(u16Ctimer<100)
            u16Ctimer++;
        else
            u16Ctimer=0;
        break;
    case 0x02:
        u16Ctimer++;
        if(u16Ctimer==12)
        {
            volt = 217;		// target voltage 4.5V, take into account the +8 offset

            //			PWR_I = 82;				// current limit 4.1A
            //			PWRCTL = (PWRCTL & 0xfc) | 0x01;			// 4.50V
            //			PWR_V = 0x38;
            u8Target50mA=100;
            VOOCVoltTrans(volt);
            //        QcVoltTrans(volt);
        }
        else if(u16Ctimer==52)
        {
            u8VOOCsts=0x03;
            u16Ctimer=0;
        }
        break;
    case 0x03:
    {
        WORD temp;
        if(!u16Ctimer)
        {
            temp = transmit_vooc(0x04) & 0x70;
            if(temp==0)
                u8VOOCsts=0x10;

            switch(temp)
            {
            case 0x60:			// too high, 0x60 0r 0x40?
                if (volt > 157) volt -= 1;
                //				PWRCTL = (PWRCTL & 0xfc) | (volt & 0x03);
                //				PWR_V = (volt >> 2) + 2;

                VOOCVoltTrans(volt);
                //          QcVoltTrans(volt);

                break;

            case 0x50:			// too low
                if (volt < 255) volt +=1;
                //				PWRCTL = (PWRCTL & 0xfc) | (volt & 0x03);
                //				PWR_V = (volt >> 2) + 2;
                VOOCVoltTrans(volt);
//               QcVoltTrans(volt);

                break;
            case 0x70:
                u8VOOCsts=0x04;
                break;
            default:

                break;

            }
        }
        if(u16Ctimer<50)
            u16Ctimer++;
        else
            u16Ctimer=0;
    }
    break;
    case 0x04:
        u16Ctimer++;
        if(u16Ctimer>50)
        {
            WORD temp;
            temp = transmit_vooc(0x06) & 0x3f;       // ask for target current level
            current= temp*5 + 60;

            if (current >80) current=80;
            current <<= 1;             // x2

            u8VOOCsts=0x05;
            u16Ctimer=0;
            voocPulses=0;
        }
        break;
    case 0x05:
        u16Ctimer++;
        if(u16Ctimer>30)
        {
            WORD temp;
            temp = transmit_vooc(0x02) & 0x7f;

            // when there is no response
            if (temp==0) {
                voocPulses++;
                if (voocPulses>10) {
                    //			SRCCTL &= ~0x01;		// turn off the MOSFET
                    DPDNCTL = 0x03;			// float the Dp lines, Dn=1
                    u16Ctimer=0;
                    u8VOOCsts=0x10;
                    break;
                }
            } else {
                voocPulses=0;
            }

            if (u8CurVal < current-1) {
                if (volt < 255) volt++;
            } else if (u8CurVal > current+1) {
                if (volt > 157 ) volt--;
            }

            VOOCVoltTrans(volt);

//             QcVoltTrans(volt);

//          PWRCTL = (PWRCTL & 0xfc) | (volt & 0x03);
//          PWR_V = (volt >> 2) + 2;

            // when Vbus is way lower than expected, the power may be off
            if ((u8VinVal < 58) && (volt ==255))
                u8VOOCsts=0x10;	// * to add some retry
        }
        break;
    case 0x11:
        u16Ctimer++;
        if(u16Ctimer>250)
        {
            SRCCTL |= 0x01;         // turn the MOSFET back on
            u8VOOCsts=0x10;
        }
        break;
    case 0x10:
    default:
//       DPDNCTL = 0x05;         // float the Dp/Dn lines
        Go_QCSTA_IDLE();

        VOOCVoltTrans(MAP_PDO1_DAC());
        //    QcVoltTrans(PDO_V_DAC[0]);
        break;
    }
}

#endif
