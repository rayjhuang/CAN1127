#ifndef _VOOC_HAL_H_
#define _VOOC_H_

#ifdef VOOC_ENABLE



unsigned char transmit_vooc(unsigned char);
void vivo_prl(void);
void Vooc_prl(void);
void vivo_start(void);
void Vooc_init(void);
void QcVoltTrans (WORD volx2);


#define VIVO_DIS_UART() {DISABLE_DPDM_UART();   ES = 0x00;}      // IE[4], serial 0

#else 

#define vivo_prl()
#define Vooc_prl()
#define vivo_start()
#define Vooc_init()
#define VIVO_DIS_UART()

#endif

#endif 
