
`ifdef __DEF_SFR_V
`else
`define __DEF_SFR_V

`define IRQ0 0
`define IRQ1 1
`define TMR0 2

// external SFR (CAN1121 -> CAN1124)
`define CVOFS01 8'h84
`define CVOFS23 8'h85

`define DPDNCTL	8'h8f

`define ADOFS	8'h90
`define ISOFS	8'h91

`define LDBPRO	8'h94
`define FCPTUI	8'h95
`define ACCCTL	8'h96
`define DPDMACC	8'h97
`define FCPCTL	8'h9b
`define FCPSTA	8'h9c
`define FCPMSK	8'h9d
`define FCPDAT	8'h9e
`define FCPCRC	8'h9f

`define REGTRM0	8'ha1
`define REGTRM1	8'ha2
`define REGTRM2	8'ha3
`define REGTRM3	8'ha4
`define REGTRM4	8'ha5
`define REGTRM5	8'ha6
`define REGTRM6	8'ha7

`define CCOFS	8'hab
`define PWR_I	8'hac
`define PROVAL	8'had
`define PROSTA	8'hae
`define PROCTL	8'haf

`define COMPI	8'he1
`define CMPSTA	8'he2
`define SRCCTL	8'he3
`define PWRCTL	8'he4
`define PWR_V	8'he5
`define CCRX	8'he6
`define CCCTL	8'he7

`define CMPOPT	8'he8

`define DACCTL 	8'hf1 // DAC/COMP control
`define DACEN	8'hf2
`define SAREN	8'hf3
`define DACLSB	8'hf4
`define CVCTL	8'hf5
`define CCTRX	8'hf6

`define DACV0	8'hf8
`define DACV1	8'hf9
`define DACV2	8'hfa
`define DACV3	8'hfb
`define DACV4	8'hfc
`define DACV5	8'hfd
`define DACV6	8'hfe
`define DACV7	8'hff

// external SFR (usbpd_90)
`define TXCTL	8'hb0
`define FFCTL	8'hb1 // FIFO control and TX number of K-code
`define FFIO	8'hb2 // FIFO IO port
`define STA0	8'hb3 // RX status
`define STA1	8'hb4 // TX, FIFO and CC status
`define MSK0	8'hb5
`define MSK1	8'hb6
`define FFSTA	8'hb7 // FIFO status, reset

`define RXCTL	8'hbb // RX control, ordered set enable
`define MISC	8'hbc // miscellaneous
`define PRLS	8'hbd // protocol status
`define PRLTX	8'hbe // CpMsgId
`define GPF	8'hbf

`define I2CCMD	8'hc1 // HWI2C wr_pg0 addr.
`define OFS	8'hc2 // NVM address {DEC[3:0],OFS}
`define DEC	8'hc3
`define PRLRXL	8'hc4 // received header
`define PRLRXH	8'hc5 // received header
`define TRXS	8'hc6 // TX/RX status
`define REVID	8'hc7 // revsion ID / SFRIO

`define I2CCTL	8'hc9 // HWI2C control
`define I2CDEVA	8'hca // HWI2C dev.adr
`define I2CMSK	8'hcb // HWI2C mask
`define I2CEV	8'hcc // HWI2C status
`define I2CBUF	8'hcd // HWI2C rcvd. device address or wr_pg0 wdat
`define PCL	8'hce
`define NVMIO	8'hcf // read/write NVM

`define GPIO5	8'hd1
`define RWBUF	8'hd2
`define GPIO34	8'hd3
`define OSCCTL	8'hd4
`define GPIOP	8'hd5
`define GPIOSL	8'hd6
`define GPIOSH	8'hd7

`define ATM	8'hd9

`define P0MSK	8'hde
`define P0STA	8'hdf

// internal SFR
`define ADR_P0		{1'h1,7'b000_0000} ////80
`define ADR_SP		{1'h1,7'b000_0001} ////81
`define ADR_DPL		{1'h1,7'b000_0010} ////82
`define ADR_DPH		{1'h1,7'b000_0011} ////83
`define ADR_WDTREL	{1'h1,7'b000_0110} ////86
`define ADR_PCON	{1'h1,7'b000_0111} ////87

`define ADR_TCON	{1'h1,7'b000_1000} ////88
`define ADR_TMOD	{1'h1,7'b000_1001} ////89
`define ADR_TL0		{1'h1,7'b000_1010} ////8A
`define ADR_TL1		{1'h1,7'b000_1011} ////8B
`define ADR_TH0		{1'h1,7'b000_1100} ////8C
`define ADR_TH1		{1'h1,7'b000_1101} ////8D
`define ADR_CKCON	{1'h1,7'b000_1110} ////8E

`define ADR_DPS		{1'h1,7'b001_0010} ////92
`define ADR_DPC		{1'h1,7'b001_0011} ////93

`define ADR_S0CON	{1'h1,7'b001_1000} ////98
`define ADR_S0BUF	{1'h1,7'b001_1001} ////99
`define ADR_IEN2	{1'h1,7'b001_1010} ////9A

`define ADR_P2		{1'h1,7'b010_1000} ////A0
`define ADR_IEN0	{1'h1,7'b010_1000} ////A8, IE in REG52.H
`define ADR_IP0		{1'h1,7'b010_1001} ////A9
`define ADR_S0RELL	{1'h1,7'b010_1010} ////AA

`define ADR_IEN1	{1'h1,7'b011_1000} ////B8
`define ADR_IP		{1'h1,7'b011_1001} ////B9
`define ADR_S0RELH	{1'h1,7'b011_1010} ////BA

`define ADR_IRCON	{1'h1,7'b100_0000} ////C0
`define ADR_T2CON	{1'h1,7'b100_1000} ////C8

`define ADR_PSW		{1'h1,7'b101_0000} ////D0

`define ADR_ADCON	{1'h1,7'b101_1000} ////D8
`define ADR_I2CDAT	{1'h1,7'b101_1010} ////DA
`define ADR_I2CADR	{1'h1,7'b101_1011} ////DB
`define ADR_I2CCON	{1'h1,7'b101_1100} ////DC
`define ADR_I2CSTA	{1'h1,7'b101_1101} ////DD

`define ADR_ACC		{1'h1,7'b110_0000} ////E0

`define ADR_MD0		{1'h1,7'b110_1001} ////E9
`define ADR_MD1		{1'h1,7'b110_1010} ////EA
`define ADR_MD2		{1'h1,7'b110_1011} ////EB
`define ADR_MD3		{1'h1,7'b110_1100} ////EC
`define ADR_MD4		{1'h1,7'b110_1101} ////ED
`define ADR_MD5		{1'h1,7'b110_1110} ////EE
`define ADR_ARCON	{1'h1,7'b110_1111} ////EF

`define ADR_B		{1'h1,7'b111_0000} ////F0
`define ADR_SRST	{1'h1,7'b111_0111} ////F7

// XDATA register (CAN1123)
`define REGX(X0) {9'h1ff,X0}
`define X0_PWM0		7'h08
`define X0_PWM1		7'h09

`define X0_SDISCHG	7'h0f

`define X0_BISTCTL	7'h10
`define X0_BISTDAT	7'h11
`define X0_NVMCTL	7'h12
`define X0_TDPDN	7'h13
`define X0_HWTRP	7'h14
`define X0_I2CROUT	7'h15

`define X0_AOPT		7'h17

`define X0_BKPCL	7'h18
`define X0_BKPCH	7'h19
`define X0_XTM		7'h1a
`define X0_GPIOTS	7'h1b
`define X0_XANA0	7'h1c
`define X0_XANA1	7'h1d
`define X0_XANA2	7'h1e

`define X0_DACV16	7'h20
`define X0_DACV17	7'h21

`define X0_DACV8	7'h28
`define X0_DACV9	7'h29
`define X0_DACV10	7'h2a
`define X0_DACV11	7'h2b
`define X0_DACV12	7'h2c
`define X0_DACV13	7'h2d
`define X0_DACV14	7'h2e
`define X0_DACV15	7'h2f

`define X0_DACEN2	7'h30
`define X0_SAREN2	7'h31
`define X0_COMPI2	7'h32

`define X0_DACEN3	7'h38
`define X0_SAREN3	7'h39
`define X0_COMPI3	7'h3a

`endif // __DEF_SFR_V

