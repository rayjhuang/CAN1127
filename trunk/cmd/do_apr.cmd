
   RESET
   SET log file lec_apr_$DCODE.log -replace
   SET system mode setup
   PRINTENV DCODE
   PRINTENV RELC     // 20230330
   PRINTENV RETC     // 230406
   PRINTENV RET_PATH // ~king/WORK/CAN1127A0_A0585A0/APR_LAYOUT
   PRINTENV PJ_PATH  // /mnt/app1/ray/project/can????
   ls -l gate*

// SETENV SRC $PJ_PATH/release/$RELC/chiptop_1127a0_1.v
   SETENV SRC $PJ_PATH/work1/syn/chiptop_1127a0_2.v
// SETENV TAR $RET_PATH/USB_OK$RETC.v
   SETENV TAR ../release/$RELC/USB_OK$RETC.v.cpx
// SETENV TAR $PJ_PATH/work1/gate.v

// REAd LIbrary -Both    -REPlace -L $PJ_PATH/maxchip/std.lib/front_end/synopsys/Max018E_3p3v_WORST.lib.lec
   REAd LIbrary -Both    -REPlace    $PJ_PATH/macro/std.v
   REAd LIbrary -Revised -APPend     $PJ_PATH/macro/empty.v
// REAd LIbrary -Revised -APPend     $PJ_PATH/macro/apr_cell.v
   REAd LIbrary -Revised -APPend     $PJ_PATH/macro/anatop_1127a0.v -Define ANATOP_EMPTY

   REAd DEsign -VERILOG2K -root chiptop_1127a0 -Golden  $SRC
   REAd DEsign -Verilog   -root chiptop_1127a0 -Revised $TAR

   SET flatten model -gated_clock -seq_constant
   SET system mode lec
   ADD COmpared points -all
// REPort COmpared Points
   DATE
   COMpare -NONEQ_Print
   DATE
// EXIt -F

