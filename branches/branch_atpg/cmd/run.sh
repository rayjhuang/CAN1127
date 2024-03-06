
#  setup EDA tools first
   if ( -e /mnt/app1/king/ ) then
#     source ~king/.cshrc
#     echo "\033]30;king.cshrc\007"
      which ncverilog lec dc_shell-t  pt_shell tmax verdi syn2SymDB
      setenv LD_LIBRARY_PATH /mnt/tools/eda_tool/Verdi3/share/PLI/IUS/LINUX64
   endif

   setenv SVN_EDITOR "/usr/bin/vim"
   setenv TURBO_LIBS "VSC18VGB15ELV16S_1P62V_150C"
   setenv NOVAS_LIBPATHS ""

   unset FLIST NCDEF NCCMD NCOPT
   unset PJ_NAME PJ_PATH DCODE USBTD REV
   setenv NCDEF "+RTL"
   setenv PJ_NAME can1127
   setenv PJ_PATH ~/project/$PJ_NAME
   setenv DCODE `date +%Y%m%d`

   setenv FLIST "-f ${PJ_PATH}/cmd/rtl.f -f ${PJ_PATH}/cmd/macro.f -f ${PJ_PATH}/cmd/bench.f"
   setenv HWREV '+define+CAN1127A0 ../bench/can1127.v'

#  setenv USBTD '+incdir+../stm/ ../stm/usb_test_device.v +define+USBTD'
#  setenv FWREV '+define+FW0=\"../fw/system/CYF24A0_Smxxe170.2.memh\" ../stm/cyf32r1x24.v' 

   echo "NCDEF = '"$NCDEF"'\nDCODE = '"$DCODE"'\nPJ_PATH = '"$PJ_PATH"'"
   echo "HWREV = '"$HWREV"''"
#  echo "USBTD = '"$USBTD"'\nFWREV = '"$FWREV"'"

   if ( `pwd` !~ "*work*" ) exit # @ ~/project/can1127/work?
   if ( ! -e run.sh )      ln -s ../cmd/run.sh
   if ( ! -e stm_list.sh ) ln -s ../cmd/stm_list.sh


   if ( "$1" != "NOGUI" ) then

   verdi -sv $FLIST $HWREV stm.v &
#  verdi -sv $FLIST $HWREV $USBTD stm.v &
#  verdi -sv -f ../cmd/rtl.f -f ../cmd/macro.f -f ../cmd/bench.f stm.v $HWREV +define+FPGA+SMIMS &

## check the generated (merged) RTL for FPGA (synthesis and simulation)
   setenv VERDI_FPGA_CHIP  "-v ../fpga/softmacro.v +incdir+../fpga/inc +define+FPGA+SMIMS"
   setenv VERDI_FPGA_BENCH "-f ../cmd/macro.f -f ../cmd/bench.f $HWREV stm.v"
#  verdi -sv $VERDI_FPGA_CHIP+FPGA_SYNTHESIS    ../fpga/src/can1127a0_fpga_20210605.v &
#  verdi -sv $VERDI_FPGA_CHIP $VERDI_FPGA_BENCH ../fpga/src/can1127a0_fpga_20210605.v &

## check the synthesis/APR result
#  verdi -sv -f ../cmd/macro.f ./syn/chiptop_1127a0_0.v &
#  verdi     -v ../macro/std.v ./syn/chiptop_1127a0_1.v &
#  verdi -sv -f ../cmd/macro.f ./syn/chiptop_1127a0_2.v &
#  verdi -sv -f ../cmd/macro.f ./syn/chiptop_1127a0_3.v &
#  verdi -sv -f ../cmd/macro.f -f ../cmd/bench.f gate.v $HWREV +define+GATE stm.v &

   setenv VERDI_ATPG "-f ../cmd/macro.f gate.v +define+GATE+VCD ../stm/stm_atpg.v"
#  verdi $VERDI_ATPG +define+MIN+VEC_GEN ./syn/atpg_chain_stildpv.v &
#  verdi $VERDI_ATPG +define+MIN+VEC_VER+CAN1127A0 &

   endif

