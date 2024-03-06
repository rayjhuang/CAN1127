
#include "global.h"

#ifdef CFG_MODE1

void ScpPhyInit ()
{
    FCPMSK = 0x0C; // RX PING, RX SYNC
    FCPCTL |= 0x10;
    IEN2 |= 0x04; // INT_VECT_FCP, EX9
}

BYTE u8ByteCnt, u8ScpRxData [2];
volatile BYTE u8ScpSta;

void IsrScpPhy () interrupt INT_VECT_FCP
{
    u8ScpSta = FCPSTA;
    FCPSTA = 0x0C; // clear FCP Status
    bEventScp = 1;
}

void ScpPhyProc ()
{
    bEventScp = 0;
    if (u8ScpSta&0x08) // RX short
    {
        if (u8ByteCnt>0) u8ScpRxData[u8ByteCnt-1] = FCPDAT; // data received
        u8ByteCnt++;
    }
    else if (u8ScpSta&0x04) // RX PING
    {
        if (u8ByteCnt==3 // the 3rd SYNC stands for 2nd data received
                && *((WORD*)&u8ScpRxData[0])==BIG_ENDIAN(VID_CANYON_SEMI))
        {
            SET_DPDM_I2C(); // set D+/D- become I2C
        }
    }
}

#endif // CFG_MODE1
