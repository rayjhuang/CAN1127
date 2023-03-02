
`ifdef __DEF_BENCH_V
`else
`define __DEF_BENCH_V

// ===== BEGIN ===== for testbench and stimulus
// BENCH is defined in bench.f
`define I2CMST    `BENCH.U0_I2CMST
`define URMST     `BENCH.U0_UARTMST
`define DUT       `BENCH.U0_DUT
`define M51       `BENCH.U0_M51

`define DUT_ANA   `DUT.U0_ANALOG_TOP
`define DUT_CORE  `DUT.U0_CORE
`define DUT_MCLK  `DUT_CORE.i_clk
`define DUT_MCU   `DUT_CORE.u0_mcu
`define DUT_CCLK  `DUT_MCU.clkcpu

`ifdef CAN1124B0
`define DUT_SRAM    `DUT.U0_SRAM.mem
`define DUT_XDAT(a) `DUT_SRAM[a]
`define DUT_IDAT(a) `DUT_SRAM[a+'h500]
`elsif CAN1112B2
`define DUT_SRAM    `DUT.U0_XDAT.mem
`define DUT_XDAT(a) `DUT_SRAM[a]
`define DUT_IDAT(a) `DUT_SRAM[a+'h180]
`endif

`ifdef FPGA
   `define MON51_C     `DUT.u0_mon51_c.mem
   `define CODE_IF(n)  `DUT.U0_CODE[n].U1.mem
   `define CODE_CE(n)  `DUT.U0_CODE[n].U0.mem
   `define OTPMAIN(n,a) `CODE_CE(n)[a&'h1fff]
   `define OTPRDNT(n,a) `CODE_IF(n)[a&'h3f] // ATO0008KX8VI150BG33NA_FPGA
`else
   `ifdef GATE
      `define OTPMAIN(n,a) (n==1 ? `DUT.U0_CODE_1_.otpCell_normal_0[(a>>6)&'h7f][a&'h3f] \
                                 : `DUT.U0_CODE_0_.otpCell_normal_0[(a>>6)&'h7f][a&'h3f])
      `define OTPRDNT(n,a) (n==1 ? `DUT.U0_CODE_1_.otpCell_redundant_0[a&'h3f] \
                                 : `DUT.U0_CODE_0_.otpCell_redundant_0[a&'h3f])
   `else
      `define CODE_IF(n)  `DUT.U0_CODE[n].otpCell_redundant_0
      `define CODE_CE(n)  `DUT.U0_CODE[n].otpCell_normal_0
      `define OTPMAIN(n,a) `CODE_CE(n)[(a>>6)&'h7f][a&'h3f]
      `define OTPRDNT(n,a) `CODE_IF(n)[a&'h3f] // ATO0008KX8MX180LBX4DA
   `endif //GATE
`endif

// ===== END ===== for

`define DUT_PHY     `DUT_CORE.u0_updphy
`define USBPORT     `BENCH.U0_USB_PORT
`define TP          `USBPORT // test port
`define UPD         `TP.UPD
`define CCANA       `TP.CCANA
`define USBCONN     `TP.USBCONN
`define USBPB       `TP.PB
`define CL_FLAG     `DUT_ANA.r_cf
`define V_NTC       `DUT_ANA.v_RT
`define OCP         `DUT_ANA.r_ocp
`define VBUS_UVP    `DUT_ANA.r_uvp
`define VBUS_OVP    `DUT_ANA.r_ovp
`define CV_TARGET   `DUT_ANA.VIN_target
`define CV_VOLT     `DUT_ANA.v_VIN
`define PWR_ENABLE  `DUT_ANA.PWR_ENABLE
`define PWRI        `DUT_ANA.PWR_I

`define VCONN_RP(ra,rp) (ra?(rp==2?578:rp==1?574:570):(rp?3300:'hx)) // mV (Rp divided by Rp/Ra)
`define VCONN_5V(ra,rp) (ra?(rp==2?4951:rp==1?4953:4955):5000) // mV (5V divided by Rp/Ra)

`define HW hardware_rev
`define HW_FIN(format) begin $display format; #100 $finish; end

`endif //  __DEF_BENCH_V

