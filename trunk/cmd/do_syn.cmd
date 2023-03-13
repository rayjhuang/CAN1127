// source ~king/.cshrc3

   RESET
   SET LOg File lec_syn_$DCODE.log -replace
   SET SYstem Mode Setup
   PRINTENV DCODE
   PRINTENV PJ_PATH  // /mnt/app1/ray/project/can????

//----------------------------------------------------------------------
// Let S_MSCALE_XPROC module becomes a blackbox for un-mapped CUTs.
//----------------------------------------------------------------------
// ADD notranslat modules S_MSCALE_XPROC -design -both

//----------------------------------------------------------------------
// Let M_CommandExt_Bridge module becomes a blackbox.
// To ignore not-mapped D-FF chipsettopI/SDRAM_CTRLI/U_CTRL_ENG/U_CMD_EXT/CommandExt_BridgeI/FIFO_COUNTER_reg_2_
//----------------------------------------------------------------------
// ADD notranslat modules M_CommandExt_Bridge -design -both

   REAd LIbrary -Both -REPlace $PJ_PATH/macro/std.v
   REAd LIbrary -Both -APPend  $PJ_PATH/macro/empty.v
   REAd LIbrary -Both -APPend  $PJ_PATH/macro/anatop_1127a0.v -Define ANATOP_EMPTY

// read golden design
// REAd revised design (post-layout and then be ECO-ed)
   REAd DEsign -VERILOG2K -ROOT chiptop_1127a0 -Golden -f $PJ_PATH/cmd/rtl.f
   REAd DEsign -VErilog   -ROOT chiptop_1127a0 -Revised $PJ_PATH/work1/syn/chiptop_1127a0_2.v
// REAd DEsign -VErilog   -ROOT chiptop_1110a0 -Revised $PJ_PATH/release/20221020/USB_OK0571A0.v.cp

// ----------------------------------------------------
// ABSTract LOGic
// Disable DFT mode
//-----------------------------------------------------
// ADD TIed Signals
// ADD PRimary Output
   ADD PRimary Input DI_TST -Both
   ADD PIn Constraints 0 DI_TST -Both

// ADD REnaming Rule map1 %s_reg_%d__%d_ @1_reg[@2][@3] -MAp -Revised
// ADD REnaming Rule map2 %s_reg%d_%d_   @1_reg[@3]     -MAp -Revised
// ADD REnaming Rule map3 %s_reg_%d_     @1_reg[@2]     -MAp -Revised
// ADD REnaming Rule map4 %s_REG_%d_     @1_REG[@2]     -MAp -Revised

//----------------------------------------------------
// To tie all undriven signals in the design to 0
//----------------------------------------------------
// SET UNDRiven Signal 0 -Both

   SET FLatten Model -GATED_Clock -SEQ_Constant
   SET System Mode LEc

   REPort UNmapped Points -TYpe DFF

   ADD MApped Points U0_CORE/u0_mcu/u_watchdog/wdts_s_reg[1] U0_CORE/u0_mcu/u_watchdog/wdts_s_reg_1_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[0] U0_CORE/d_dodat_reg_0_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[1] U0_CORE/d_dodat_reg_1_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[2] U0_CORE/d_dodat_reg_2_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[3] U0_CORE/d_dodat_reg_3_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[4] U0_CORE/d_dodat_reg_4_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[5] U0_CORE/d_dodat_reg_5_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[6] U0_CORE/d_dodat_reg_6_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[7] U0_CORE/d_dodat_reg_7_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[8] U0_CORE/d_dodat_reg_8_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[9] U0_CORE/d_dodat_reg_9_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[10] U0_CORE/d_dodat_reg_10_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[11] U0_CORE/d_dodat_reg_11_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[12] U0_CORE/d_dodat_reg_12_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[13] U0_CORE/d_dodat_reg_13_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[14] U0_CORE/d_dodat_reg_14_/U$1 -NOINVert
   ADD MApped Points U0_CORE/d_dodat_reg[15] U0_CORE/d_dodat_reg_15_/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_fcp/u0_fcpegn/u0_fcpctl/mem_reg[5] U0_CORE/u0_fcp/u0_fcpegn/u0_fcpctl/mem_reg_5_/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_fcp/u0_fcpegn/u0_fcpctl/mem_reg[6] U0_CORE/u0_fcp/u0_fcpegn/u0_fcpctl/mem_reg_6_/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_fcp/u0_fcpegn/u0_fcpctl/mem_reg[7] U0_CORE/u0_fcp/u0_fcpegn/u0_fcpctl/mem_reg_7_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_regbank/u1_regE4/mem_reg[0] U0_CORE/u0_regbank/u1_regE4/mem_reg_0_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_regbank/u1_regE4/mem_reg[1] U0_CORE/u0_regbank/u1_regE4/mem_reg_1_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[0] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_0_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[1] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_1_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[2] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_2_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[3] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_3_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[4] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_4_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[5] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_5_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[6] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_6_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[7] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_7_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[8] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_8_/U$1 -NOINVert
// ADD MApped Points U0_CORE/u0_dacmux/u0_dac1v/mem_reg[9] U0_CORE/u0_dacmux/u0_dac1v/mem_reg_9_/U$1 -NOINVert
// ADD MApped Points /U0_CORE/u0_regbank/u1_regE4/mem_reg[2] /U0_CORE/u0_regbank/u1_regE4/mem_reg_2_/U$1 -NOINVert
// ADD MApped Points /U0_CORE/u0_dacmux/sh_rst_n_reg /U0_CORE/u0_dacmux/sh_rst_n_reg/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_divclk/U0_D1P5M_ICG/U$1 U0_CORE/u0_divclk/U0_D1P5M_ICG/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_divclk/U0_D1P5M_ICG/U$1 U0_CORE/u0_divclk/U0_D1P5M_ICG/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_divclk/U0_D500K_ICG/U$1 U0_CORE/u0_divclk/U0_D500K_ICG/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_divclk/U0_D100K_ICG/U$1 U0_CORE/u0_divclk/U0_D100K_ICG/U$1 -NOINVert
   ADD MApped Points U0_CORE/u0_divclk/U0_D50K_ICG/U$1  U0_CORE/u0_divclk/U0_D50K_ICG/U$1  -NOINVert
   ADD MApped Points U0_CORE/u0_divclk/U0_D0P5K_ICG/U$1 U0_CORE/u0_divclk/U0_D0P5K_ICG/U$1 -NOINVert

// DELete COmpared Points
// DELete MApped Points

   REPort UNmapped Points -TYpe DFF

   ADD COmpared Points -All
// ADD COmpared Points U0_CORE/d_dodat_reg*
// COMpare -NONEQ_Print -ABORT_Print
   REPort COmpared Points

//----------------------------
// To resolve Abort point
//----------------------------
// REPort compare data -abort
   SET COmpare Effort super
   COMpare -NONEQ_Print

   DATE
// EXIt -Force
// SYSTEM
// TCLMODE
// SET GUi
// SET SYstem Mode Setup
// SET ROot Module
// DOFile ../cmd/do_syn.cmd

