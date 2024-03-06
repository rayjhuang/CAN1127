// This script is used to do the formal check
// When RTL code needs optimization after finalized
// rayhuang@canyon-semi.com.tw
// ALL RIGHTS ARE RESERVED
// =============================================================================
// source ~king/.cshrc3
// DOFile ../cmd/do_rtl.cmd
   RESET
   SET LOg File lec_rtl_$DCODE.log -replace
   SET SYstem Mode Setup
   PRINTENV DCODE    // 20210922
   PRINTENV PJ_PATH  // /mnt/app1/steven/project/can1127
   DATE

// REAd LIbrary -Both -REPlace $PJ_PATH/macro/std.v
   REAd LIbrary -Both -REPlace $PJ_PATH/rtl/softmacro.v -VERILOG2K
// REAd LIbrary -Both -APPend  $PJ_PATH/macro/empty.v
// REAd LIbrary -Both -APPend  $PJ_PATH/macro/anatop_1127a0.v -Define SYNTHESIS

// read golden design
   REAd DEsign -VERILOG2K -ROOT dacmux -Golden $PJ_PATH/rtl/dacmux.v
// REAd revised design (post-layout and then be ECO-ed)
   REAd DEsign -VERILOG2K -ROOT dacmux -Revised \
	$PJ_PATH/rtl/dacmux_equ.v \
	$PJ_PATH/rtl/dacreg.v \
	$PJ_PATH/rtl/dacsar.v \
	$PJ_PATH/rtl/shmux.v

   SET System Mode LEc
// REPort UNmapped Points -TYpe DFf -TYpe PO -TYpe PI
   REPort UNmapped Points -GOlden
   ADD MApped Points -RULE "o_dacv\[%d\]" "r_dacv\[@1\]"
   ADD MApped Points -RULE "o_dat\[%d\]" "r_comp\[@1\]"
   ADD MApped Points -RULE "o_cmpsta\[%d\]" "r_cmpsta\[@1\]"
   ADD MApped Points -RULE "o_dactl\[%d\]" "r_dacctl\[@1\]"
   ADD MApped Points -RULE "x_daclsb\[%d\]" "r_daclsb_x\[@1\]"
   REPort UNmapped Points -SUMmary
   ADD COmpared Points -All

   COMpare -NONEQ_Print -ABORT_Print

//----------------------------
// To resolve Abort point
//----------------------------
// REPort compare data -abort
// SET COmpare Effort super
// COMpare -NONEQ_Print

   DATE
// SET GUi
// EXIt -Force

