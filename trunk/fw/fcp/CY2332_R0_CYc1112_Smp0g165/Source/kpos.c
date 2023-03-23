
#include "global.h"

#ifdef CFG_KPOS0

volatile BYTE ErrorRecovery_Counter;
volatile bit bProDMFualt;
volatile BYTE btShortTmr;

void Start_DM_Fault()
{
    BYTE ii, bProDM_COUNTER;
    SET_DM_FAULT_ENA();
    for(ii=0; ii<35; ii++)
    {
        if(IS_DM_FAULT())
        {
            bProDM_COUNTER++;
            if(bProDM_COUNTER>5)
            {
                bProDMFualt = 1;
            }
        }
        else
        {
            bProDM_COUNTER = 0;
        }
    }
    SET_DM_FAULT_DIS();
}

#endif // CFG_KPOS0
