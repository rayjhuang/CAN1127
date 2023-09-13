
// Configuration Parameters
  parameter PORT0_IMPLEMENT               = 1;       //  0,1
  parameter PORT1_IMPLEMENT               = 0;       //  0,1
  parameter PORT2_IMPLEMENT               = 0;       //  0,1
  parameter PORT3_IMPLEMENT               = 0;       //  0,1
  parameter TIMER0_IMPLEMENT              = 1;       //  0,1
  parameter TIMER1_IMPLEMENT              = 1;       //  0,1
  parameter TIMER2_IMPLEMENT              = 0;       //  0,1
  parameter SERIAL0_IMPLEMENT             = 1;       //  0,1
  parameter SERIAL1_IMPLEMENT             = 0;       //  0,1
  parameter PMU_IMPLEMENT                 = 1;       //  0,1
  parameter PMW_IMPLEMENT                 = 1;       //  0,1
  parameter MDU_IMPLEMENT                 = 1;       //  0,1
  parameter CKCON_IMPLEMENT               = 1;       //  0,1
  parameter WATCHDOG_IMPLEMENT            = 1;       //  0,1
  parameter ISR_TYPE                      = 515;     //  51,515
  parameter NO_DPTRS                      = 8;       //  1,2,8
  parameter DPARITH_IMPLEMENT             = 1;       //  0,1
  parameter D_MEMADDR_LENGTH              = 16;      //  16..23
  parameter MEMADDR_LENGTH                = 16;      //  16..23
  parameter OCDS_IMPLEMENT                = 0;       //  0,1
  parameter OCDS_TYPE                     = 0;       //  0..2
  parameter OCDS_NO_OF_BP                 = 2;       //  2,4,8
  parameter NO_EXT_INTERRUPTS             = 13;      //  0..13
  parameter I2C_IMPLEMENT                 = 1;       //  0,1
  parameter SPI_IMPLEMENT                 = 0;       //  0,1
  parameter HOLD_IMPLEMENT                = 0;       //  0,1
  parameter I2C_2_IMPLEMENT               = 0;       //  0,1
  parameter WDT_PRES_8_EXTENSION          = 1;       //  0,1
//parameter PRES_LENGTH_EXTENSION         = 8;       //  1..8
  parameter PRES_LENGTH_EXTENSION         = 2;       //  1..8
  parameter SRST_IMPLEMENT                = 1;       //  0,1
  parameter COMBMEMINT_IMPLEMENT          = 1;       //  0,1
  parameter NO_OF_DMA_CH                  = 0;       //  0..8
  parameter RTC_IMPLEMENT                 = 0;       //  0,1
  parameter SMBUS_EXTENSION               = 0;       //  0,1
  parameter MUL_IMPLEMENT                 = 1;       //  1
  parameter DIV_IMPLEMENT                 = 1;       //  1
  parameter DA_IMPLEMENT                  = 1;       //  1
  parameter OCI_IMPLEMENT                 = 0;       //  0
  // Configuration end

  // Configuration Equations
  // (PORT0_IMPLEMENT = 0 or PORT0_IMPLEMENT = 1)
  // (PORT1_IMPLEMENT = 0 or PORT1_IMPLEMENT = 1)
  // (PORT2_IMPLEMENT = 0 or PORT2_IMPLEMENT = 1)
  // (PORT3_IMPLEMENT = 0 or PORT3_IMPLEMENT = 1)
  // (TIMER0_IMPLEMENT = 0 or TIMER0_IMPLEMENT = 1)
  // (TIMER1_IMPLEMENT = 0 or TIMER1_IMPLEMENT = 1)
  // (TIMER2_IMPLEMENT = 0 or TIMER2_IMPLEMENT = 1)
  // (SERIAL0_IMPLEMENT = 0 or SERIAL0_IMPLEMENT = 1)
  // (SERIAL1_IMPLEMENT = 0 or SERIAL1_IMPLEMENT = 1)
  // (PMU_IMPLEMENT = 0 or PMU_IMPLEMENT = 1)
  // (PMW_IMPLEMENT = 0 or PMW_IMPLEMENT = 1)
  // (MDU_IMPLEMENT = 0 or MDU_IMPLEMENT = 1)
  // (CKCON_IMPLEMENT = 0 or CKCON_IMPLEMENT = 1)
  // (WATCHDOG_IMPLEMENT = 0 or WATCHDOG_IMPLEMENT = 1)
  // (ISR_TYPE = 0 or ISR_TYPE = 51 or ISR_TYPE = 515)
  // (NO_DPTRS = 0 or NO_DPTRS = 1 or NO_DPTRS = 2 or NO_DPTRS = 8)
  // (DPARITH_IMPLEMENT = 0 or DPARITH_IMPLEMENT = 1)
  // (MUL_IMPLEMENT = 0 or MUL_IMPLEMENT = 1)
  // (DIV_IMPLEMENT = 0 or DIV_IMPLEMENT = 1)
  // (DA_IMPLEMENT = 0 or DA_IMPLEMENT = 1)
  // (MEMADDR_LENGTH > 15 and MEMADDR_LENGTH < 24)
  // (D_MEMADDR_LENGTH > 15 and D_MEMADDR_LENGTH < 24)
  // (OCI_IMPLEMENT = 0 or OCI_IMPLEMENT = 1)
  // (OCDS_IMPLEMENT = 0 or OCDS_IMPLEMENT = 1)
  // (NO_EXT_INTERRUPTS >= 0 and NO_EXT_INTERRUPTS < 14)
  // (I2C_IMPLEMENT = 0 or I2C_IMPLEMENT = 1)
  // (SPI_IMPLEMENT = 0 or SPI_IMPLEMENT = 1)
  // ((OCI_IMPLEMENT = 1 and OCDS_IMPLEMENT = 0) or (OCI_IMPLEMENT = 0 and OCDS_IMPLEMENT = 1) or (OCDS_IMPLEMENT = 0))
  // ((I2C_2_IMPLEMENT = 0 or I2C_2_IMPLEMENT = 1) and (I2C_2_IMPLEMENT = 0 or I2C_IMPLEMENT = 1))
  // (WDT_PRES_8_EXTENSION = 0 or WDT_PRES_8_EXTENSION = 1)
  // (SRST_IMPLEMENT = 0 or SRST_IMPLEMENT = 1)
  // (COMBMEMINT_IMPLEMENT = 0 or COMBMEMINT_IMPLEMENT = 1)
  // (NO_OF_DMA_CH >= 0 and NO_OF_DMA_CH < 9)
  // (RTC_IMPLEMENT = 0 or RTC_IMPLEMENT = 1)
  // Configuration end

  //-----------------------------------------------------------------
  // Interrupt Vectors
  //-----------------------------------------------------------------
  parameter INT_VECT0                     = 5'b00000; // 0x03h
  parameter INT_VECT1                     = 5'b00001; // 0x0Bh
  parameter INT_VECT2                     = 5'b00010; // 0x13h
  parameter INT_VECT3                     = 5'b00011; // 0x1Bh
  parameter INT_VECT4                     = 5'b00100; // 0x23h
  parameter INT_VECT5                     = 5'b00101; // 0x2Bh
  parameter INT_VECT6                     = 5'b01000; // 0x43h
  parameter INT_VECT7                     = 5'b01001; // 0x4Bh
  parameter INT_VECT8                     = 5'b01010; // 0x53h
  parameter INT_VECT9                     = 5'b01011; // 0x5Bh
  parameter INT_VECT10                    = 5'b01100; // 0x63h
  parameter INT_VECT11                    = 5'b01101; // 0x6Bh
  parameter INT_VECT12                    = 5'b10000; // 0x83h
  parameter INT_VECT13                    = 5'b10001; // 0x8Bh
  parameter INT_VECT14                    = 5'b10010; // 0x93h
  parameter INT_VECT15                    = 5'b10011; // 0x9Bh
  parameter INT_VECT16                    = 5'b10100; // 0xA3h
  parameter INT_VECT17                    = 5'b10101; // 0xABh
  //--------------------------------------------------------------
  // Additional vectors definition
  //--------------------------------------------------------------
  parameter INT_VECT18                    = 5'b00110; // 0x33h
  parameter INT_VECT19                    = 5'b00111; // 0x3Bh
  parameter INT_VECT20                    = 5'b01110; // 0x73h
  parameter INT_VECT21                    = 5'b01111; // 0x7Bh
  parameter INT_VECT22                    = 5'b10110; // 0xB3h
  parameter INT_VECT23                    = 5'b10111; // 0xBBh
  parameter INT_VECT24                    = 5'b11000; // 0xC3h
  parameter INT_VECT25                    = 5'b11001; // 0xCBh
  parameter INT_VECT26                    = 5'b11010; // 0xD3h
  parameter INT_VECT27                    = 5'b11011; // 0xDBh
  parameter INT_VECT28                    = 5'b11100; // 0xE3h
  parameter INT_VECT29                    = 5'b11101; // 0xEBh
  //------------------------------------------------------------------
  // Special Function Register description
  //------------------------------------------------------------------
  // Register : ID  : RV  : Description
  // p0       : 80h : FFh : Port 0
  // sp       : 81h : 07h : Stack Pointer
  // dpl      : 82h : 00h : Data Pointer Low 0
  // dph      : 83h : 00h : Data Pointer High 0
  // dpl1     : 84h : 00h : Data Pointer Low 1
  // dph1     : 85h : 00h : Data Pointer High 1
  // wdtrel   : 86h : 00h : Watchdog Timer Reload register
  // pcon     : 87h : 08h : Power Control
  // tcon     : 88h : 00h : Timer/Counter Control
  // tmod     : 89h : 00h : Timer Mode Control
  // tl0      : 8Ah : 00h : Timer 0, low byte
  // tl1      : 8Bh : 00h : Timer 1, low byte
  // th0      : 8Ch : 00h : Timer 0, high byte
  // th1      : 8Dh : 00h : Timer 1, high byte
  // ckcon    : 8Eh : 01h : Clock Control (Stretch=1)
  // p1       : 90h : FFh : Port 1
  // exif     :           : External Interrupt Flag (optional)
  // dps      : 92h : 00h : Data Pointer select Register
  // pagesel  : 94h : 01h : Page Selector Register
  // d_pagesel: 95h : 01h : Data Page Selector Register
  // s0con    : 98h : 00h : Serial Port 0, Control Register
  // s0buf    : 99h : 00h : Serial Port 0, Data Buffer
  // ien2     : 9Ah : 00h : Interrupt Enable Register 2
  // s1con    : 9Bh : 00h : Serial Port 1, Control Register
  // s1buf    : 9Ch : 00h : Serial Port 1, Data Buffer
  // s1rell   : 9Dh : 00h : Serial Port 1, Reload Register, low byte
  // p2       : A0h : 00h : Port 2
  // ien0     : A8h : 00h : Interrupt Enable Register 0
  // ip0      : A9h : 00h : Interrupt Priority Register 0
  // s0rell   : AAh : D9h : Serial Port 0, Reload Register, low byte
  // saddr0   :           : Slave Address Register 0 (optional)
  // saddr1   :           : Slave Address Register 1 (optional)
  // p3       : B0h : FFh : Port 3
  // ien1     : B8h : 00h : Interrupt Enable Register 1
  // ip1      : B9h : 00h : Interrupt Priority Register 1
  // s0relh   : BAh : 03h : Serial Port 0, Reload Register, high byte
  // s1relh   : BBh : 03h : Serial Port 1, Reload Register, high byte
  // ircon2   : BFh : 00h : Interrupt Request Control 2 Register
  // ircon    : C0h : 00h : Interrupt Request Control Register
  // ccen     : C1h : 00h : Compare/Capture Enable Register
  // ccl1     : C2h : 00h : Compare/Capture Register 1, low byte
  // cch1     : C3h : 00h : Compare/Capture Register 1, high byte
  // ccl2     : C4h : 00h : Compare/Capture Register 2, low byte
  // cch2     : C5h : 00h : Compare/Capture Register 2, high byte
  // ccl3     : C6h : 00h : Compare/Capture Register 3, low byte
  // cch3     : C7h : 00h : Compare/Capture Register 3, high byte
  // saden0   :           : Slave Addr Mask En. Register 0 (optional)
  // saden1   :           : Slave Addr Mask En. Register 1 (optional)
  // t2con    : C8h : 00h : Timer 2 Control
  // ien3     : C9h : 00h : Interrupt Enable Register 3
  // crcl     : CAh : 00h : Compare/Reload/Capture Register, low byte
  // crch     : CBh : 00h : Compare/Reload/Capture Register, high byte
  // t2mod    :           : Timer 2 Mode (optional)
  // rcap2l   :           : Timer 2 Capture LSB (optional)
  // rcap2h   :           : Timer 2 Capture MSB (optional)
  // tl2      : CCh : 00h : Timer 2, low byte
  // th2      : CDh : 00h : Timer 2, high byte
  // rtcsel   : CEh : 00h : RTC register select
  // rtcdata  : CFh : 00h : RTC data port
  // psw      : D0h : 00h : Program Status Word
  // ien4     : D1h : 00h : Interrupt Enable Register 4
  // i2c2dat  : D2h : 00h : Secondary I2C data register
  // i2c2adr  : D3h : 00h : Secondary I2C address register
  // i2c2con  : D4h : 00h : Secondary I2C control register
  // i2c2sta  : D5h : F8h : Secondary I2C status register
  // adcon    : 8hh : 00h : A/D Converter Register (only BD bit used)
  // i2cdat   : DAh : 00h : I2C data register (addr DAh in 80C552)
  // i2cadr   : DBh : 00h : I2C address register (addr DBh in 80C552)
  // i2ccon   : DCh : 00h : I2C control register (addrD8h in 80C552)
  // i2csta   : DDh : F8h : I2C status register (addrD9h in 80C552)
  // acc      : E0h : 00h : Accumulator
  // spsta    : E1h : 00h : SPI Serial Peripheral Status Register
  // spcon    : E2h : 14h : SPI Serial Peripheral Control Register
  // spdat    : E3h : 00h : SPI Serial Peripheral Data Register
  // md0      : E9h : 00h : Multiplication/Division Register 0
  // md1      : EAh : 00h : Multiplication/Division Register 1
  // md2      : EBh : 00h : Multiplication/Division Register 2
  // md3      : ECh : 00h : Multiplication/Division Register 3
  // md4      : EDh : 00h : Multiplication/Division Register 4
  // md5      : EEh : 00h : Multiplication/Division Register 5
  // arcon    : EFh : 00h : Arithmetic Control Register
  // b        : F0h : 00h : B Register
  // srst     : F7h : 00h : Software Reset Register
  // eip      :           : Extended Interrupt Priority (optional)
  //------------------------------------------------------------------
  // MAC_L Register description
  // mac_cc   : E6h : 00h : MAC common control
  // mac_cd   : E7h : 00h : MAC common data
  // mac_rf   : DEh : 00h : MAC receive fifo
  // mac_tf   : DFh : 00h : MAC transmit fifo
  // mac_te   : D6h : 00h : MAC transmit end of frame



  //---------------------------------------------------------------
  // Special Function Register locations
  //---------------------------------------------------------------
  // 80h - 87h
  parameter P0_ID          = 7'b0000000;
  parameter SP_ID          = 7'b0000001;
  parameter DPL_ID         = 7'b0000010;
  parameter DPH_ID         = 7'b0000011;
  parameter DPL1_ID        = 7'b0000100;
  parameter DPH1_ID        = 7'b0000101;
  parameter PCON_ID        = 7'b0000111;
  parameter WDTREL_ID      = 7'b0000110;

  // 88h - 8Fh
  parameter TCON_ID        = 7'b0001000;
  parameter TMOD_ID        = 7'b0001001;
  parameter TL0_ID         = 7'b0001010;
  parameter TL1_ID         = 7'b0001011;
  parameter TH0_ID         = 7'b0001100;
  parameter TH1_ID         = 7'b0001101;
  parameter CKCON_ID       = 7'b0001110;

  // 90h - 97h
  parameter P1_ID          = 7'b0010000;
  parameter DPS_ID         = 7'b0010010;
  parameter DPC_ID         = 7'b0010011;
  parameter PAGESEL_ID     = 7'b0010100;
  parameter D_PAGESEL_ID   = 7'b0010101;

  // 98h - 9Fh
  parameter S0CON_ID       = 7'b0011000;
  parameter S0BUF_ID       = 7'b0011001;
  parameter IEN2_ID        = 7'b0011010;
  parameter S1CON_ID       = 7'b0011011;
  parameter S1BUF_ID       = 7'b0011100;
  parameter S1RELL_ID      = 7'b0011101;

  // A0h - A7h
  parameter P2_ID          = 7'b0100000;
  parameter DMAS0_ID       = 7'b0100001;
  parameter DMAS1_ID       = 7'b0100010;
  parameter DMAS2_ID       = 7'b0100011;
  parameter DMAT0_ID       = 7'b0100100;
  parameter DMAT1_ID       = 7'b0100101;
  parameter DMAT2_ID       = 7'b0100110;

  // A8h - AFh
  parameter IEN0_ID        = 7'b0101000;
  parameter IP0_ID         = 7'b0101001;
  parameter S0RELL_ID      = 7'b0101010;

  // B0h - B7h
  parameter P3_ID          = 7'b0110000;
  parameter DMAC0_ID       = 7'b0110001;
  parameter DMAC1_ID       = 7'b0110010;
  parameter DMAC2_ID       = 7'b0110011;
  parameter DMASEL_ID      = 7'b0110100;
  parameter DMAM0_ID       = 7'b0110101;
  parameter DMAM1_ID       = 7'b0110110;

  // B8h - BFh
  parameter IEN1_ID        = 7'b0111000;
  parameter IP_ID          = 7'b0111000;
  parameter IP1_ID         = 7'b0111001;
  parameter S0RELH_ID      = 7'b0111010;
  parameter S1RELH_ID      = 7'b0111011;
  parameter IRCON2_ID      = 7'b0111111;

  // C0h - C7h
  parameter IRCON_ID       = 7'b1000000;
  parameter CCEN_ID        = 7'b1000001;
  parameter CCL1_ID        = 7'b1000010;
  parameter CCH1_ID        = 7'b1000011;
  parameter CCL2_ID        = 7'b1000100;
  parameter CCH2_ID        = 7'b1000101;
  parameter CCL3_ID        = 7'b1000110;
  parameter CCH3_ID        = 7'b1000111;

  // C8h - CFh
  parameter T2CON_ID       = 7'b1001000;
  parameter IEN3_ID        = 7'b1001001;
  parameter CRCL_ID        = 7'b1001010;
  parameter CRCH_ID        = 7'b1001011;
  parameter TL2_ID         = 7'b1001100;
  parameter TH2_ID         = 7'b1001101;
  parameter RTCSEL_ID      = 7'b1001110;
  parameter RTCDATA_ID     = 7'b1001111;

  // D0h - D7h
  parameter PSW_ID         = 7'b1010000;
  parameter IEN4_ID        = 7'b1010001;

  // D8h - DFh
  parameter ADCON_ID       = 7'b1011000;

  // E0h - E7h
  parameter ACC_ID         = 7'b1100000;
  // SPSTA -------------------------------------------------------
  // SPSTA location : E1
  parameter SPSTA_LOC      = 7'b1100001;
  parameter SPSTA_ID       = 7'b1100001;
  // SPCON -------------------------------------------------------
  // SPCON location : E2
  parameter SPCON_LOC      = 7'b1100010;
  parameter SPCON_ID       = 7'b1100010;
  // SPDAT -------------------------------------------------------
  // SPDAT location : E3
  parameter SPDAT_LOC      = 7'b1100011;
  parameter SPDAT_ID       = 7'b1100011;
  // SPI slave select register
  // SPSSN location : E4
  parameter SPSSN_LOC      = 7'b1100100;
  parameter SPSSN_ID       = 7'b1100100;

  // E8h - EFh
  parameter MD0_ID         = 7'b1101001;
  parameter MD1_ID         = 7'b1101010;
  parameter MD2_ID         = 7'b1101011;
  parameter MD3_ID         = 7'b1101100;
  parameter MD4_ID         = 7'b1101101;
  parameter MD5_ID         = 7'b1101110;
  parameter ARCON_ID       = 7'b1101111;

  // F0h - F7h
  parameter B_ID           = 7'b1110000;
  parameter EIP_ID         = 7'b1110101;
  parameter SRST_ID        = 7'b1110111;

  // MAC ----------------------------------------------------------
  // MAC_CC E6h
  parameter MAC_CC         = 7'b1100110;
  // MAC_CD E7h
  parameter MAC_CD         = 7'b1100111;
  // MAC_RF DEh
  parameter MAC_RF         = 7'b1011110;
  // MAC_TF DFh
  parameter MAC_TF         = 7'b1011111;
  // MAC_TE D6h
  parameter MAC_TE         = 7'b1010110;

  //---------------------------------------------------------------
  // Special Function Register reset values
  //---------------------------------------------------------------
  // 80h - 87h
  parameter P0_RV          = 8'b00000000;
  parameter SP_RV          = 8'b00000111;
  parameter DPL_RV         = 8'b00000000;
  parameter DPH_RV         = 8'b00000000;
  parameter DPL1_RV        = 8'b00000000;
  parameter DPH1_RV        = 8'b00000000;
  parameter PCON_RV        = 8'b00001000;
  parameter WDTREL_RV      = 8'b00000000;

  // 88h - 8Fh
  parameter TCON_RV        = 8'b00000000;
  parameter TMOD_RV        = 8'b00000000;
  parameter TL0_RV         = 8'b00000000;
  parameter TL1_RV         = 8'b00000000;
  parameter TH0_RV         = 8'b00000000;
  parameter TH1_RV         = 8'b00000000;
//parameter CKCON_RV       = 8'b01110001;
  parameter CKCON_RV       = 8'b00010001;

  // 90h - 97h
  parameter P1_RV          = 8'b11111111;
  parameter DPS_RV         = 8'b00000000;
  parameter DPC_RV         = {8'b00000000,
                              8'b00001000,
                              8'b00010000,
                              8'b00011000,
                              8'b00100000,
                              8'b00101000,
                              8'b00110000,
                              8'b00111000};
  parameter PAGESEL_RV     = 8'b00000001;
  parameter D_PAGESEL_RV   = 8'b00000001;

  // 98h - 9Fh
  parameter S0CON_RV       = 8'b01000000; // mode 1
  parameter S0BUF_RV       = 8'b00000000;
  parameter IEN2_RV        = 8'b00000000;
  parameter S1CON_RV       = 8'b00000000;
  parameter S1BUF_RV       = 8'b00000000;
  parameter S1RELL_RV      = 8'b00000000;

  // A0h - A7h
  parameter P2_RV          = 8'b11111111;
  parameter DMAS0_RV       = 8'b00000000;
  parameter DMAS1_RV       = 8'b00000000;
  parameter DMAS2_RV       = 8'b00000000;
  parameter DMAT0_RV       = 8'b00000000;
  parameter DMAT1_RV       = 8'b00000000;
  parameter DMAT2_RV       = 8'b00000000;

  // A8h - AFh
  parameter IEN0_RV        = 8'b00000000;
  parameter IP0_RV         = 8'b00000000;
  parameter IP0_RW         = 8'b01000000; // Watchdog reset
  parameter S0RELL_RV      = 8'b11011001;

  // B0h - B7h
  parameter P3_RV          = 8'b11111111;
  parameter DMAC0_RV       = 8'b00000000;
  parameter DMAC1_RV       = 8'b00000000;
  parameter DMAC2_RV       = 8'b00000000;
  parameter DMASEL_RV      = 8'b00000000;
  parameter DMAM0_RV       = 8'b00000000;
  parameter DMAM1_RV       = 8'b00011111;

  // B8h - BFh
  parameter IEN1_RV        = 8'b00000000;
  parameter IP_RV          = 8'b00000000;
  parameter IP1_RV         = 8'b00000000;
  parameter S0RELH_RV      = 8'b00000011;
  parameter S1RELH_RV      = 8'b00000011;
  parameter IRCON2_RV      = 8'b00000000;


  // C0h - C7h
  parameter IRCON_RV       = 8'b00000000;
  parameter CCEN_RV        = 8'b00000000;
  parameter CCL1_RV        = 8'b00000000;
  parameter CCH1_RV        = 8'b00000000;
  parameter CCL2_RV        = 8'b00000000;
  parameter CCH2_RV        = 8'b00000000;
  parameter CCL3_RV        = 8'b00000000;
  parameter CCH3_RV        = 8'b00000000;

  // C8h - CFh
  parameter T2CON_RV       = 8'b00000000;
  parameter IEN3_RV        = 8'b00000000;
  parameter CRCL_RV        = 8'b00000000;
  parameter CRCH_RV        = 8'b00000000;
  parameter TL2_RV         = 8'b00000000;
  parameter TH2_RV         = 8'b00000000;
  parameter RTCSEL_RV      = 8'b00000000;

  parameter RTASS_RV       = 8'b00000000;
  parameter RTAS_RV        = 8'b00000000;
  parameter RTAM_RV        = 8'b00000000;
  parameter RTAH_RV        = 8'b00000000;
  parameter RTCC_RV        = 8'b00000000;
  parameter TRIM_RV        = 8'b01100101;
  parameter RTCSS_RV       = 8'b00000000;
  parameter RTCS_RV        = 8'b00000000;
  parameter RTCM_RV        = 8'b00000000;
  parameter RTCH_RV        = 8'b00000000;
  parameter RTCD0_RV       = 8'b00000000;
  parameter RTCD1_RV       = 8'b00000000;

  // D0h - D7h
  parameter PSW_RV         = 8'b00000000;
  parameter IEN4_RV        = 8'b00000000;

  // I2C2DAT   : D2  : 00  :
  parameter I2C2DAT_ID     = 7'b1010010;  // I2C2DAT location

  // I2C2ADR   : D3  : 00  :
  parameter I2C2ADR_ID     = 7'b1010011;  // I2C2ADR location

  // I2C2CON   : D4  : 00  :
  parameter I2C2CON_ID     = 7'b1010100;  // I2C2CON location

  // I2C2STA   : D5  : F8  :
  parameter I2C2STA_ID     = 7'b1010101;  // I2C2STA location

  // I2CSMB_SEL   : D6  : 00  :
  
  parameter I2C2SMB_SEL_ID      = 7'b1010110;  // I2CSMB_SEL_ID location

  parameter I2C2SMB_SEL_RV      = 3'b000;      // I2CSMB_SEL_RV reset

  // I2CSMB_DST   : D7  : 00  :
  parameter I2C2SMB_DST_ID      = 7'b1010111;  // I2CSMB_DST_ID location
  parameter I2C2SMB_TMEXT_L_ID  = 3'b000;      // I2CSMB_TMEXT_L_ID location
  parameter I2C2SMB_TMEXT_H_ID  = 3'b001;      // I2CSMB_TMEXT_H_ID location
  parameter I2C2SMB_TSEXT_L_ID  = 3'b010;      // I2CSMB_TSEXT_L_ID location
  parameter I2C2SMB_TSEXT_H_ID  = 3'b011;      // I2CSMB_TSEXT_H_ID location
  parameter I2C2SMB_TOUT_L_ID   = 3'b100;      // I2CSMB_TOUT_L_ID location
  parameter I2C2SMB_TOUT_H_ID   = 3'b101;      // I2CSMB_TOUT_H_ID location
  parameter I2C2SMB_TMEXT_RV    = 16'b0000000000110101; // I2CSMB_TMEXT_RV reset
  parameter I2C2SMB_TSEXT_RV    = 16'b0000000011110100; // I2CSMB_TSEXT_RV reset
  parameter I2C2SMB_TOUT_RV     = 16'b0000000101010110; // I2CSMB_TOUT_RV reset





  // D8h - DFh
  parameter ADCON_RV       = 8'b00000000;

  // I2CDAT   : DA  : 00  :
  parameter I2CDAT_ID      = 7'b1011010;  // I2CDAT location
  parameter I2CDAT_RV      = 8'b00000000; // I2CDAT reset

  // I2CADR   : DB  : 00  :
  parameter I2CADR_ID      = 7'b1011011;  // I2CADR location
//parameter I2CADR_RV      = 8'b00000000; // I2CADR reset
  parameter I2CADR_RV      = 8'b10001001; // I2CADR reset

  // I2CCON   : DC  : 00  :
  parameter I2CCON_ID      = 7'b1011100;  // I2CCON location
  parameter I2CCON_RV      = 8'b00000000; // I2CCON reset

  // I2CSTA   : DD  : F8  :
  parameter I2CSTA_ID      = 7'b1011101;  // I2CSTA location
  parameter I2CSTA_RV      = 8'b11111000; // I2CSTA reset

  // I2CSMB_SEL   : DE  : 00  :
  
  parameter I2CSMB_SEL_ID      = 7'b1011110;  // I2CSMB_SEL_ID location


  parameter I2CSMB_SEL_RV      = 3'b000;      // I2CSMB_SEL_RV reset

  // I2CSMB_DST   : DF  : 00  :
  parameter I2CSMB_DST_ID      = 7'b1011111;  // I2CSMB_DST_ID location
  parameter I2CSMB_TMEXT_L_ID  = 3'b000;      // I2CSMB_TMEXT_L_ID location
  parameter I2CSMB_TMEXT_H_ID  = 3'b001;      // I2CSMB_TMEXT_H_ID location
  parameter I2CSMB_TSEXT_L_ID  = 3'b010;      // I2CSMB_TSEXT_L_ID location
  parameter I2CSMB_TSEXT_H_ID  = 3'b011;      // I2CSMB_TSEXT_H_ID location
  parameter I2CSMB_TOUT_L_ID   = 3'b100;      // I2CSMB_TOUT_L_ID location
  parameter I2CSMB_TOUT_H_ID   = 3'b101;      // I2CSMB_TOUT_H_ID location
  parameter I2CSMB_TMEXT_RV    = 16'b0000000000110101; // I2CSMB_TMEXT_RV reset
  parameter I2CSMB_TSEXT_RV    = 16'b0000000011110100; // I2CSMB_TSEXT_RV reset
  parameter I2CSMB_TOUT_RV     = 16'b0000000101010110; // I2CSMB_TOUT_RV reset


  // E0h - E7h
  parameter ACC_RV         = 8'b00000000;
  // SPSTA reset : 00
  parameter SPSTA_RST      = 8'b00000000;
  // SPCON reset : 14
  parameter SPCON_RST      = 8'b00010100;
  // SPDAT reset : 00
  parameter SPDAT_RST      = 7'b0000000;
  // SPI slave select register
  parameter SPSSN_RST      = 8'b11111111;

  // E8h - EFh
  parameter MD0_RV         = 8'b00000000;
  parameter MD1_RV         = 8'b00000000;
  parameter MD2_RV         = 8'b00000000;
  parameter MD3_RV         = 8'b00000000;
  parameter MD4_RV         = 8'b00000000;
  parameter MD5_RV         = 8'b00000000;
  parameter ARCON_RV       = 8'b00000000;

  // F0h - F7h
  parameter B_RV           = 8'b00000000;
  parameter EIP_RV         = 8'b00000000;
  parameter SRST_RV        = 8'b00000000;

  //-----------------------------------------------------------------
  // RTC SFR port address definition
  //-----------------------------------------------------------------
  parameter RTASS_ID       = 4'b0000;
  parameter RTAS_ID        = 4'b0001;
  parameter RTAM_ID        = 4'b0010;
  parameter RTAH_ID        = 4'b0011;
  parameter RTCC_ID        = 4'b0100;
  parameter TRIM_ID        = 4'b0101;
  parameter RTCSS_ID       = 4'b0110;
  parameter RTCS_ID        = 4'b0111;
  parameter RTCM_ID        = 4'b1000;
  parameter RTCH_ID        = 4'b1001;
  parameter RTCD0_ID       = 4'b1010;
  parameter RTCD1_ID       = 4'b1011;

  //-----------------------------------------------------------------
  // Instruction Mnemonics
  //-----------------------------------------------------------------
  // 00H - 0Fh
  parameter NOP            = 8'b00000000;
  parameter AJMP_0         = 8'b00000001;
  parameter LJMP           = 8'b00000010;
  parameter RR_A           = 8'b00000011;
  parameter INC_A          = 8'b00000100;
  parameter INC_ADDR       = 8'b00000101;
  parameter INC_IR0        = 8'b00000110;
  parameter INC_IR1        = 8'b00000111;
  parameter INC_R0         = 8'b00001000;
  parameter INC_R1         = 8'b00001001;
  parameter INC_R2         = 8'b00001010;
  parameter INC_R3         = 8'b00001011;
  parameter INC_R4         = 8'b00001100;
  parameter INC_R5         = 8'b00001101;
  parameter INC_R6         = 8'b00001110;
  parameter INC_R7         = 8'b00001111;

  // 10H - 1Fh
  parameter JBC_BIT        = 8'b00010000;
  parameter ACALL_0        = 8'b00010001;
  parameter LCALL          = 8'b00010010;
  parameter RRC_A          = 8'b00010011;
  parameter DEC_A          = 8'b00010100;
  parameter DEC_ADDR       = 8'b00010101;
  parameter DEC_IR0        = 8'b00010110;
  parameter DEC_IR1        = 8'b00010111;
  parameter DEC_R0         = 8'b00011000;
  parameter DEC_R1         = 8'b00011001;
  parameter DEC_R2         = 8'b00011010;
  parameter DEC_R3         = 8'b00011011;
  parameter DEC_R4         = 8'b00011100;
  parameter DEC_R5         = 8'b00011101;
  parameter DEC_R6         = 8'b00011110;
  parameter DEC_R7         = 8'b00011111;

  // 20H - 2Fh
  parameter JB_BIT         = 8'b00100000;
  parameter AJMP_1         = 8'b00100001;
  parameter RET            = 8'b00100010;
  parameter RL_A           = 8'b00100011;
  parameter ADD_N          = 8'b00100100;
  parameter ADD_ADDR       = 8'b00100101;
  parameter ADD_IR0        = 8'b00100110;
  parameter ADD_IR1        = 8'b00100111;
  parameter ADD_R0         = 8'b00101000;
  parameter ADD_R1         = 8'b00101001;
  parameter ADD_R2         = 8'b00101010;
  parameter ADD_R3         = 8'b00101011;
  parameter ADD_R4         = 8'b00101100;
  parameter ADD_R5         = 8'b00101101;
  parameter ADD_R6         = 8'b00101110;
  parameter ADD_R7         = 8'b00101111;

  // 30H - 3Fh
  parameter JNB_BIT        = 8'b00110000;
  parameter ACALL_1        = 8'b00110001;
  parameter RETI           = 8'b00110010;
  parameter RLC_A          = 8'b00110011;
  parameter ADDC_N         = 8'b00110100;
  parameter ADDC_ADDR      = 8'b00110101;
  parameter ADDC_IR0       = 8'b00110110;
  parameter ADDC_IR1       = 8'b00110111;
  parameter ADDC_R0        = 8'b00111000;
  parameter ADDC_R1        = 8'b00111001;
  parameter ADDC_R2        = 8'b00111010;
  parameter ADDC_R3        = 8'b00111011;
  parameter ADDC_R4        = 8'b00111100;
  parameter ADDC_R5        = 8'b00111101;
  parameter ADDC_R6        = 8'b00111110;
  parameter ADDC_R7        = 8'b00111111;

  // 40H - 4Fh
  parameter JC             = 8'b01000000;
  parameter AJMP_2         = 8'b01000001;
  parameter ORL_ADDR_A     = 8'b01000010;
  parameter ORL_ADDR_N     = 8'b01000011;
  parameter ORL_A_N        = 8'b01000100;
  parameter ORL_A_ADDR     = 8'b01000101;
  parameter ORL_A_IR0      = 8'b01000110;
  parameter ORL_A_IR1      = 8'b01000111;
  parameter ORL_A_R0       = 8'b01001000;
  parameter ORL_A_R1       = 8'b01001001;
  parameter ORL_A_R2       = 8'b01001010;
  parameter ORL_A_R3       = 8'b01001011;
  parameter ORL_A_R4       = 8'b01001100;
  parameter ORL_A_R5       = 8'b01001101;
  parameter ORL_A_R6       = 8'b01001110;
  parameter ORL_A_R7       = 8'b01001111;

  // 50H - 5Fh
  parameter JNC            = 8'b01010000;
  parameter ACALL_2        = 8'b01010001;
  parameter ANL_ADDR_A     = 8'b01010010;
  parameter ANL_ADDR_N     = 8'b01010011;
  parameter ANL_A_N        = 8'b01010100;
  parameter ANL_A_ADDR     = 8'b01010101;
  parameter ANL_A_IR0      = 8'b01010110;
  parameter ANL_A_IR1      = 8'b01010111;
  parameter ANL_A_R0       = 8'b01011000;
  parameter ANL_A_R1       = 8'b01011001;
  parameter ANL_A_R2       = 8'b01011010;
  parameter ANL_A_R3       = 8'b01011011;
  parameter ANL_A_R4       = 8'b01011100;
  parameter ANL_A_R5       = 8'b01011101;
  parameter ANL_A_R6       = 8'b01011110;
  parameter ANL_A_R7       = 8'b01011111;

  // 60H - 6Fh
  parameter JZ             = 8'b01100000;
  parameter AJMP_3         = 8'b01100001;
  parameter XRL_ADDR_A     = 8'b01100010;
  parameter XRL_ADDR_N     = 8'b01100011;
  parameter XRL_A_N        = 8'b01100100;
  parameter XRL_A_ADDR     = 8'b01100101;
  parameter XRL_A_IR0      = 8'b01100110;
  parameter XRL_A_IR1      = 8'b01100111;
  parameter XRL_A_R0       = 8'b01101000;
  parameter XRL_A_R1       = 8'b01101001;
  parameter XRL_A_R2       = 8'b01101010;
  parameter XRL_A_R3       = 8'b01101011;
  parameter XRL_A_R4       = 8'b01101100;
  parameter XRL_A_R5       = 8'b01101101;
  parameter XRL_A_R6       = 8'b01101110;
  parameter XRL_A_R7       = 8'b01101111;

  // 70H - 7Fh
  parameter JNZ            = 8'b01110000;
  parameter ACALL_3        = 8'b01110001;
  parameter ORL_C_BIT      = 8'b01110010;
  parameter JMP_A_DPTR     = 8'b01110011;
  parameter MOV_A_N        = 8'b01110100;
  parameter MOV_ADDR_N     = 8'b01110101;
  parameter MOV_IR0_N      = 8'b01110110;
  parameter MOV_IR1_N      = 8'b01110111;
  parameter MOV_R0_N       = 8'b01111000;
  parameter MOV_R1_N       = 8'b01111001;
  parameter MOV_R2_N       = 8'b01111010;
  parameter MOV_R3_N       = 8'b01111011;
  parameter MOV_R4_N       = 8'b01111100;
  parameter MOV_R5_N       = 8'b01111101;
  parameter MOV_R6_N       = 8'b01111110;
  parameter MOV_R7_N       = 8'b01111111;

  // 80H - 8Fh
  parameter SJMP           = 8'b10000000;
  parameter AJMP_4         = 8'b10000001;
  parameter ANL_C_BIT      = 8'b10000010;
  parameter MOVC_A_PC      = 8'b10000011;
  parameter DIV_AB         = 8'b10000100;
  parameter MOV_ADDR_ADDR  = 8'b10000101;
  parameter MOV_ADDR_IR0   = 8'b10000110;
  parameter MOV_ADDR_IR1   = 8'b10000111;
  parameter MOV_ADDR_R0    = 8'b10001000;
  parameter MOV_ADDR_R1    = 8'b10001001;
  parameter MOV_ADDR_R2    = 8'b10001010;
  parameter MOV_ADDR_R3    = 8'b10001011;
  parameter MOV_ADDR_R4    = 8'b10001100;
  parameter MOV_ADDR_R5    = 8'b10001101;
  parameter MOV_ADDR_R6    = 8'b10001110;
  parameter MOV_ADDR_R7    = 8'b10001111;

  // 90H - 9Fh
  parameter MOV_DPTR_N     = 8'b10010000;
  parameter ACALL_4        = 8'b10010001;
  parameter MOV_BIT_C      = 8'b10010010;
  parameter MOVC_A_DPTR    = 8'b10010011;
  parameter SUBB_N         = 8'b10010100;
  parameter SUBB_ADDR      = 8'b10010101;
  parameter SUBB_IR0       = 8'b10010110;
  parameter SUBB_IR1       = 8'b10010111;
  parameter SUBB_R0        = 8'b10011000;
  parameter SUBB_R1        = 8'b10011001;
  parameter SUBB_R2        = 8'b10011010;
  parameter SUBB_R3        = 8'b10011011;
  parameter SUBB_R4        = 8'b10011100;
  parameter SUBB_R5        = 8'b10011101;
  parameter SUBB_R6        = 8'b10011110;
  parameter SUBB_R7        = 8'b10011111;

  // A0H - AFh
  parameter ORL_C_NBIT     = 8'b10100000;
  parameter AJMP_5         = 8'b10100001;
  parameter MOV_C_BIT      = 8'b10100010;
  parameter INC_DPTR       = 8'b10100011;
  parameter MUL_AB         = 8'b10100100;
  parameter UNKNOWN        = 8'b10100101;
  parameter MOV_IR0_ADDR   = 8'b10100110;
  parameter MOV_IR1_ADDR   = 8'b10100111;
  parameter MOV_R0_ADDR    = 8'b10101000;
  parameter MOV_R1_ADDR    = 8'b10101001;
  parameter MOV_R2_ADDR    = 8'b10101010;
  parameter MOV_R3_ADDR    = 8'b10101011;
  parameter MOV_R4_ADDR    = 8'b10101100;
  parameter MOV_R5_ADDR    = 8'b10101101;
  parameter MOV_R6_ADDR    = 8'b10101110;
  parameter MOV_R7_ADDR    = 8'b10101111;

  // B0H - BFh
  parameter ANL_C_NBIT     = 8'b10110000;
  parameter ACALL_5        = 8'b10110001;
  parameter CPL_BIT        = 8'b10110010;
  parameter CPL_C          = 8'b10110011;
  parameter CJNE_A_N       = 8'b10110100;
  parameter CJNE_A_ADDR    = 8'b10110101;
  parameter CJNE_IR0_N     = 8'b10110110;
  parameter CJNE_IR1_N     = 8'b10110111;
  parameter CJNE_R0_N      = 8'b10111000;
  parameter CJNE_R1_N      = 8'b10111001;
  parameter CJNE_R2_N      = 8'b10111010;
  parameter CJNE_R3_N      = 8'b10111011;
  parameter CJNE_R4_N      = 8'b10111100;
  parameter CJNE_R5_N      = 8'b10111101;
  parameter CJNE_R6_N      = 8'b10111110;
  parameter CJNE_R7_N      = 8'b10111111;

  // C0H - CFh
  parameter PUSH           = 8'b11000000;
  parameter AJMP_6         = 8'b11000001;
  parameter CLR_BIT        = 8'b11000010;
  parameter CLR_C          = 8'b11000011;
  parameter SWAP_A         = 8'b11000100;
  parameter XCH_ADDR       = 8'b11000101;
  parameter XCH_IR0        = 8'b11000110;
  parameter XCH_IR1        = 8'b11000111;
  parameter XCH_R0         = 8'b11001000;
  parameter XCH_R1         = 8'b11001001;
  parameter XCH_R2         = 8'b11001010;
  parameter XCH_R3         = 8'b11001011;
  parameter XCH_R4         = 8'b11001100;
  parameter XCH_R5         = 8'b11001101;
  parameter XCH_R6         = 8'b11001110;
  parameter XCH_R7         = 8'b11001111;

  // D0H - DFh
  parameter POP            = 8'b11010000;
  parameter ACALL_6        = 8'b11010001;
  parameter SETB_BIT       = 8'b11010010;
  parameter SETB_C         = 8'b11010011;
  parameter DA_A           = 8'b11010100;
  parameter DJNZ_ADDR      = 8'b11010101;
  parameter XCHD_IR0       = 8'b11010110;
  parameter XCHD_IR1       = 8'b11010111;
  parameter DJNZ_R0        = 8'b11011000;
  parameter DJNZ_R1        = 8'b11011001;
  parameter DJNZ_R2        = 8'b11011010;
  parameter DJNZ_R3        = 8'b11011011;
  parameter DJNZ_R4        = 8'b11011100;
  parameter DJNZ_R5        = 8'b11011101;
  parameter DJNZ_R6        = 8'b11011110;
  parameter DJNZ_R7        = 8'b11011111;

  // E0H - EFh
  parameter MOVX_A_IDPTR   = 8'b11100000;
  parameter AJMP_7         = 8'b11100001;
  parameter MOVX_A_IR0     = 8'b11100010;
  parameter MOVX_A_IR1     = 8'b11100011;
  parameter CLR_A          = 8'b11100100;
  parameter MOV_A_ADDR     = 8'b11100101;
  parameter MOV_A_IR0      = 8'b11100110;
  parameter MOV_A_IR1      = 8'b11100111;
  parameter MOV_A_R0       = 8'b11101000;
  parameter MOV_A_R1       = 8'b11101001;
  parameter MOV_A_R2       = 8'b11101010;
  parameter MOV_A_R3       = 8'b11101011;
  parameter MOV_A_R4       = 8'b11101100;
  parameter MOV_A_R5       = 8'b11101101;
  parameter MOV_A_R6       = 8'b11101110;
  parameter MOV_A_R7       = 8'b11101111;

  // F0H - FFh
  parameter MOVX_IDPTR_A   = 8'b11110000;
  parameter ACALL_7        = 8'b11110001;
  parameter MOVX_IR0_A     = 8'b11110010;
  parameter MOVX_IR1_A     = 8'b11110011;
  parameter CPL_A          = 8'b11110100;
  parameter MOV_ADDR_A     = 8'b11110101;
  parameter MOV_IR0_A      = 8'b11110110;
  parameter MOV_IR1_A      = 8'b11110111;
  parameter MOV_R0_A       = 8'b11111000;
  parameter MOV_R1_A       = 8'b11111001;
  parameter MOV_R2_A       = 8'b11111010;
  parameter MOV_R3_A       = 8'b11111011;
  parameter MOV_R4_A       = 8'b11111100;
  parameter MOV_R5_A       = 8'b11111101;
  parameter MOV_R6_A       = 8'b11111110;
  parameter MOV_R7_A       = 8'b11111111;

  //-----------------------------------------------------------------
  // Interrupt reset values
  //-----------------------------------------------------------------
  parameter VECT_RV        = 5'b00000; // Interrupt Vector reset value
  parameter IS_REG_RV      = 4'b0000;  // In Service Register reset value

  //-----------------------------------------------------------------
  // Interrupt Vector locations
  //-----------------------------------------------------------------
  // external interrupt 0
  parameter VECT_E0        = 5'b00000;

  // timer 0 overflow
  parameter VECT_TF0       = 5'b00001;

  // external interrupt 1
  parameter VECT_E1        = 5'b00010;

  // timer 1 overflow
  parameter VECT_TF1       = 5'b00011;

  // serial channel 0
  parameter VECT_SER0      = 5'b00100;

  // timer 2 overflow/ext. reload
  parameter VECT_TF2       = 5'b00101;

  // A/D converter
  parameter VECT_ADC       = 5'b01000;

  // external interrupt 2
  parameter VECT_EX2       = 5'b01001;

  // external interrupt 3
  parameter VECT_EX3       = 5'b01010;

  // external interrupt 4
  parameter VECT_EX4       = 5'b01011;

  // external interrupt 5
  parameter VECT_EX5       = 5'b01100;

  // external interrupt 6
  parameter VECT_EX6       = 5'b01101;

  // serial channel 1
  parameter VECT_SER1      = 5'b10000;

  //-----------------------------------------------------------------
  // Start address location
  //-----------------------------------------------------------------
  parameter ADDR_RV       = 16'b0000000000000000; //


  //-----------------------------------------------------------------
  // RAM & SFR address reset value
  //-----------------------------------------------------------------
  parameter RAM_SFR_ADDR_RV= 8'b00000000; //


  //-----------------------------------------------------------------
  // Data register reset value
  //-----------------------------------------------------------------
  parameter DATAREG_RV     = 8'b00000000; //


  //-----------------------------------------------------------------
  // High ordered half of address during indirect addressing
  //-----------------------------------------------------------------
  parameter ADDR_HIGH_RI   = 8'b00000000; //


  //-----------------------------------------------------------------
  // Watchdog Timer reset value
  //-----------------------------------------------------------------
  parameter WDTH_RV        = 7'b0000000;  // High ordered WDT
  parameter WDTL_RV        = 8'b00000000; // Low ordered WDT


  //-----------------------------------------------------------------
  // Watchdog Timer reset state
  //-----------------------------------------------------------------
  parameter WDT_RSL       = 15'b111111111111011; // X"7FFB"
  parameter WDT_RSH       = 15'b111111111111111; // X"0000"

  //-----------------------------------------------------------------
  // I2C Input filter size
  //-----------------------------------------------------------------
  parameter GLITCHREG     = 3;

  parameter SETUP_REG     = 5;

  //---------------------------------------------------------------
  // FSM STATUS enumeration type
  //---------------------------------------------------------------
  parameter       FSMSTA08 = 5'b00000;
  parameter       FSMSTA10 = 5'b00001;
  parameter       FSMSTA18 = 5'b00010;
  parameter       FSMSTA20 = 5'b00011;
  parameter       FSMSTA28 = 5'b00100;
  parameter       FSMSTA30 = 5'b00101;
  parameter       FSMSTA38 = 5'b00110;
  parameter       FSMSTA40 = 5'b00111;
  parameter       FSMSTA48 = 5'b01000;
  parameter       FSMSTA50 = 5'b01001;
  parameter       FSMSTA58 = 5'b01010;
  parameter       FSMSTA60 = 5'b01011;
  parameter       FSMSTA68 = 5'b01100;
  parameter       FSMSTA70 = 5'b01101;
  parameter       FSMSTA78 = 5'b01110;
  parameter       FSMSTA80 = 5'b01111;
  parameter       FSMSTA88 = 5'b10000;
  parameter       FSMSTA90 = 5'b10001;
  parameter       FSMSTA98 = 5'b10010;
  parameter       FSMSTAA0 = 5'b10011;
  parameter       FSMSTAA8 = 5'b10100;
  parameter       FSMSTAB0 = 5'b10101;
  parameter       FSMSTAB8 = 5'b10110;
  parameter       FSMSTAC0 = 5'b10111;
  parameter       FSMSTAC8 = 5'b11000;
  parameter       FSMSTAF8 = 5'b11001;
  parameter       FSMSTA00 = 5'b11010;

  //---------------------------------------------------------------
  // FSM DETECT enumeration type
  //---------------------------------------------------------------
  parameter       FSMDET0 = 3'b000;
  parameter       FSMDET1 = 3'b001;
  parameter       FSMDET2 = 3'b010;
  parameter       FSMDET3 = 3'b011;
  parameter       FSMDET4 = 3'b100;
  parameter       FSMDET5 = 3'b101;
  parameter       FSMDET6 = 3'b110;

  //---------------------------------------------------------------
  // FSM SYNCHRONIZATION enumeration type
  //---------------------------------------------------------------
  parameter       FSMSYNC0 = 3'b000;
  parameter       FSMSYNC1 = 3'b001;
  parameter       FSMSYNC2 = 3'b010;
  parameter       FSMSYNC3 = 3'b011;
  parameter       FSMSYNC4 = 3'b100;
  parameter       FSMSYNC5 = 3'b101;
  parameter       FSMSYNC6 = 3'b110;
  parameter       FSMSYNC7 = 3'b111;

  //---------------------------------------------------------------
  // FSM MODE enumeration type
  //---------------------------------------------------------------
  parameter       FSMMOD0 = 3'b000;
  parameter       FSMMOD1 = 3'b001;
  parameter       FSMMOD2 = 3'b010;
  parameter       FSMMOD3 = 3'b011;
  parameter       FSMMOD4 = 3'b100;
  parameter       FSMMOD5 = 3'b101;
  parameter       FSMMOD6 = 3'b110;

