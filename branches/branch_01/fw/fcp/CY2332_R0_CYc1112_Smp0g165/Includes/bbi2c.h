
#ifndef _BBI2C_H_
#define _BBI2C_H_

#ifdef CFG_BBI2C
// N O T E :  set always CC mode in the table

extern signed char s8VoltStep;
extern BYTE u8_bb_status;
extern WORD u16BBI2CPwrV;

#define IS_BBI2C_PWRGD() (u8_bb_status & 0x10)

#undef IS_OCPVAL
#define IS_OCPVAL() (u8_bb_status & 0x08)


#undef IS_CLVAL
#define IS_CLVAL() (u8_bb_status & 0x08)

/*#undef DISCHARGE_ENA
#define DISCHARGE_ENA() // no discharge*/

void bbi2c_init();
void bbi2c_tick();

#else

#define IS_BBI2C_PWRGD() TRUE

#define bbi2c_init()
#define bbi2c_tick()

#endif // CFG_BBI2C

#endif // _BBI2C_H_
