#  source ~king/.cshrc
#  if ( -e ~king/.cshrc ) \
#  setenv LD_LIBRARY_PATH /mnt/tools/eda_tool/Verdi3/share/PLI/IUS/LINUX64
#  setenv PJ_NAME can1127
#  setenv PJ_PATH ~/project/$PJ_NAME
#  setenv NCDEF  '+RTL'
   setenv DCODE `date +%Y%m%d`
   echo $DCODE $PJ_NAME $PJ_PATH
   if ( `pwd` !~ "*work*" ) exit # @ ~/project/can1121/work?

   if ( "$1" == "RTL"   || \
        "$1" == "SMIMS" || \
        "$1" == "GATE" ) then

   if ( "$1" == "RTL" )     setenv NCDEF "+RTL"
   if ( "$1" == "SMIMS" )   setenv NCDEF "+FPGA+SMIMS"

   echo "DCODE   '"$DCODE"'\nPJ_NAME '"$PJ_NAME"'\nPJ_PATH '"$PJ_PATH"'\nNCDEF   '"$NCDEF"'"

   setenv NCCMD "+ncaccess+rc +nowarn+NONPRT -disable_sem2009 -sv"
   setenv NCCMD "$NCCMD +ncnowarn+CUVWSP +ncnowarn+CSINFI"
   setenv NCCMD "$NCCMD +ncnowarn+MRSTAR -timescale 1ns/10ps -nohistory"
   setenv FLIST "-f ${PJ_PATH}/cmd/rtl.f"
   setenv FLIST "$FLIST -f ${PJ_PATH}/cmd/macro.f -f ${PJ_PATH}/cmd/bench.f"
   setenv NCOPT "$NCCMD $FLIST $HWREV +define$NCDEF"


   echo "NCCMD = '"$NCCMD"'"
   echo "NCOPT = '"$NCOPT"'"

   if ( "$NCDEF" =~ "*+FPGA*" ) then
   ncverilog $NCOPT ../stm/stm_uart.v      -l stm_uart$NCDEF.log
   ncverilog $NCOPT ../stm/stm_uart.v      -l stm_uart+$NCDEF.log +define+PWDN
   ncverilog $NCOPT ../stm/stm_mon51.v     -l stm_mon51$NCDEF.log ../bench/logpc.v
   endif

   if ( "$NCDEF" =~ "*+RTL*" || "$NCDEF" =~ "*+FPGA*" ) then

   ncverilog $NCOPT ../stm/stm_pwm.v       -l stm_pwm$NCDEF.log
   ncverilog $NCOPT ../stm/stm_stby.v      -l stm_stby$NCDEF.log
   ncverilog $NCOPT ../stm/stm_stb_drp.v   -l stm_stb_drp$NCDEF.log
   ncverilog $NCOPT ../stm/stm_sdischg.v   -l stm_sdischg$NCDEF.log
   ncverilog $NCOPT ../stm/stm_bkpt.v      -l stm_bkpt$NCDEF.log
   ncverilog $NCOPT ../stm/stm_osc.v       -l stm_osc$NCDEF.log
   ncverilog $NCOPT ../stm/stm_sram.v      -l stm_sram$NCDEF.log
   ncverilog $NCOPT ../stm/stm_srambist.v  -l stm_srambist$NCDEF.log
   ncverilog $NCOPT ../stm/stm_cci2c.v     -l stm_cci2c$NCDEF.log
   ncverilog $NCOPT ../stm/stm_cci2c.v     -l stm_cci2c+$NCDEF.log +define+SWAP
   ncverilog $NCOPT ../stm/stm_cci2c.v     -l stm_cci2c-$NCDEF.log +define+CSP
   ncverilog $NCOPT ../stm/stm_cci2c.v     -l stm_cci2c--$NCDEF.log +define+CSP+SOP
   ncverilog $NCOPT ../stm/stm_fcp0.v      -l stm_fcp0$NCDEF.log
   ncverilog $NCOPT ../stm/stm_dacmux.v    -l stm_dacmux$NCDEF.log
   ncverilog $NCOPT ../stm/stm_monur.v     -l stm_monur$NCDEF.log
   ncverilog $NCOPT ../stm/stm_txopt.v     -l stm_txopt$NCDEF.log
   ncverilog $NCOPT ../stm/stm_ccrx.v      -l stm_ccrx$NCDEF.log
   ncverilog $NCOPT ../stm/stm_cc_bas.v    -l stm_cc_bas$NCDEF.log
   ncverilog $NCOPT ../stm/stm_gpio.v      -l stm_gpio$NCDEF.log
   ncverilog $NCOPT ../stm/stm_urx.v       -l stm_urx$NCDEF.log
   ncverilog $NCOPT ../stm/stm_uart_txrx.v -l stm_uart_txrx$NCDEF.log +define+BAUD=115200
   ncverilog $NCOPT ../stm/stm_uart_txrx.v -l stm_uart_txrx$NCDEF.log +define+BAUD=57600
   ncverilog $NCOPT ../stm/stm_uart_txrx.v -l stm_uart_txrx$NCDEF.log +define+BAUD=38400
   ncverilog $NCOPT ../stm/stm_uart_txrx.v -l stm_uart_txrx$NCDEF.log +define+BAUD=19200
#  ncverilog $NCOPT ../stm/stm_fw.v -l fw_debug$NCDEF.log +define+FW_DEBUG=\"../fw/preli2/CY_PDT_V1\"+T10
#  ncverilog $NCOPT ../stm/stm_fw.v -l fw_debug$NCDEF.log +define+FW_DEBUG=\"../fw/scp/timer1_DpDn\"+T10
#  ncverilog $NCOPT ../stm/stm_fw.v -l fw_debug$NCDEF.log +define+FW_DEBUG=\"../fw/scp/DpDn_UART\"+T10 ../stm/stm_test.v
   ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw0$NCDEF.log  +define+FW0=\"iram\"+T10
   ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw0+$NCDEF.log +define+FW0=\"tms\"+T10
   ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw1$NCDEF.log  +define+FW0=\"int_sim\"+FW1=\"int_sim\"+T10
#  ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw1$NCDEF.log  +define+FW0=\"int_fpga\"+T10
#  ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw2$NCDEF.log  +define+FW0=\"eeprom_w\"+FWI2C+T10
#  ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw3$NCDEF.log  +define+FW1=\"eeprom_to12\"+FWX2=\"iram\"+T100
#  ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw4$NCDEF.log  +define+FW0=\"eeprom_to08\"+FWX2=\"iram\"+T100
   ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw5$NCDEF.log  +define+FW0=\"mode0\"+T10
   ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw6$NCDEF.log  +define+FW0=\"timer1\"+T10
#  ncverilog $NCOPT ../stm/stm_fw.v -l stm_fw7$NCDEF.log  +define+FW0=\"autodet\"+T500
#  ncverilog $NCOPT ../stm/stm_i2cmst.v    -l stm_i2cmst$NCDEF.log
   ncverilog $NCOPT ../stm/stm_fwi2c.v     -l stm_fwi2c--$NCDEF.log +define+DPDMI2C+SWAP
   ncverilog $NCOPT ../stm/stm_fwi2c.v     -l stm_fwi2c-$NCDEF.log +define+DPDMI2C
   ncverilog $NCOPT ../stm/stm_fwi2c.v     -l stm_fwi2c$NCDEF.log
   ncverilog $NCOPT ../stm/stm_fwi2c.v     -l stm_fwi2c+$NCDEF.log +define+CCI2C
   ncverilog $NCOPT ../stm/stm_fwi2c.v     -l stm_fwi2c++$NCDEF.log +define+CCI2C+SWAP
   ncverilog $NCOPT ../stm/stm_i2crout.v   -l stm_i2crout$NCDEF.log
#  ncverilog $NCOPT ../stm/stm_dpdmi2c.v   -l stm_dpdmi2c$NCDEF.log
   ncverilog $NCOPT ../stm/stm_wdt.v       -l stm_wdt$NCDEF.log
   ncverilog $NCOPT ../stm/stm_hwi2c.v     -l stm_hwi2c$NCDEF.log
   ncverilog $NCOPT ../stm/stm_hwi2c_mpb.v -l stm_hwi2c_mpbxr$NCDEF.log +define+FW0=\"iram\"+T100
   ncverilog $NCOPT ../stm/stm_hwi2c_mpb.v -l stm_hwi2c_mpbir$NCDEF.log +define+FW0=\"iram\"+T100+IDATA
   ncverilog $NCOPT ../stm/stm_hwi2c_mpb.v -l stm_hwi2c_mpbxw$NCDEF.log +define+FW0=\"iram\"+T100+WR
   ncverilog $NCOPT ../stm/stm_hwi2c_mpb.v -l stm_hwi2c_mpbiw$NCDEF.log +define+FW0=\"iram\"+T100+IDATA+WR
   ncverilog $NCOPT ../stm/stm_hwi2c_fw.v  -l stm_hwi2c_fw$NCDEF.log
#  ncverilog $NCOPT ../stm/stm_tcpc_0.v    -l stm_tcpc_0$NCDEF.log
#  ncverilog $NCOPT ../stm/stm_tcpc_1.v    -l stm_tcpc_1$NCDEF.log
   ncverilog $NCOPT ../stm/stm_debnc.v     -l stm_debnc$NCDEF.log
   ncverilog $NCOPT ../stm/stm_sfr.v       -l stm_sfr$NCDEF.log
   ncverilog $NCOPT ../stm/stm_csp.v       -l stm_csp$NCDEF.log
   ncverilog $NCOPT ../stm/stm_i2c_otp.v   -l stm_i2c_otp$NCDEF.log
   ncverilog $NCOPT ../stm/stm_hwtrm.v     -l stm_hwtrm$NCDEF.log
   ncverilog $NCOPT ../stm/stm_scan_pwrv.v -l stm_scan_pwrv$NCDEF.log +define+HLSB=0
   ncverilog $NCOPT ../stm/stm_scan_pwrv.v -l stm_scan_pwrv+$NCDEF.log +define+HLSB=1
   ncverilog $NCOPT ../stm/stm_scan_pwrv.v -l stm_scan_pwrv++$NCDEF.log +define+HLSB=3
   ncverilog $NCOPT ../stm/stm_i2cpre.v    -l stm_i2cpre.v$NCDEF.log

   ncverilog $NCOPT ../stm/stm_isp_i2c.v   -l stm_isp_i2c$NCDEF.log    +define+FW=\"int_sim\"+T100
   ncverilog $NCOPT ../stm/stm_isp_cc.v    -l stm_isp_cc$NCDEF.log     +define+FW=\"int_sim\"+T500
#  ncverilog $NCOPT ../stm/stm_isp_cc.v    -l stm_isp_cc+$NCDEF.log    +define+FW=\"int_sim\"+T500+DUMMY3
#  ncverilog $NCOPT ../stm/stm_isp_ccbdg.v -l stm_isp_ccbdg$NCDEF.log  +define+FW=\"int_sim\"+T500
   ncverilog $NCOPT ../stm/stm_isp_cci2c.v -l stm_isp_cci2c$NCDEF.log  +define+FW=\"int_sim\"+T100
   ncverilog $NCOPT ../stm/stm_isp_cci2c.v -l stm_isp_cci2c+$NCDEF.log +define+FW=\"int_sim\"+T100+SOP

#  ncverilog $NCOPT ../stm/stm_fcp0_test_mode.v             -l stm_fcp0_test_mode$NCDEF.log

   # fcp1 for Marc's FW
   setenv FCP1REV '+define+FW0=\"../fw/fcp/SCPR0SMPL.02521S.2.memh\"'
   ncverilog $NCOPT ../stm/stm_fcp1_ping_write_read.v       -l stm_fcp1_ping_write_read$NCDEF.log       $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_TypeA_whole_registers.v -l stm_fcp1_TypeA_whole_registers$NCDEF.log $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_TypeB_whole_registers.v -l stm_fcp1_TypeB_whole_registers$NCDEF.log $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_1byte_write_read.v      -l stm_fcp1_1byte_write_read$NCDEF.log      $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_conti_write_read.v      -l stm_fcp1_conti_write_read$NCDEF.log      $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_bad_crc_parity.v        -l stm_fcp1_bad_crc_parity$NCDEF.log        $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_5byte_length_check.v    -l stm_fcp1_5byte_length_check$NCDEF.log    $FCP1REV
   ncverilog $NCOPT ../stm/stm_fcp1_nack_write_read.v       -l stm_fcp1_nack_write_read$NCDEF.log       $FCP1REV

   setenv FCP2REV '+define+FW0=\"../fw/fcp/CYc1112_Smp0g165.2.memh\"'
   ncverilog $NCOPT ../stm/stm_fcp2_basic.v                 -l stm_fcp2_basic$NCDEF.log  $FCP2REV
   ncverilog $NCOPT ../stm/stm_fcp2_reset.v                 -l stm_fcp2_reset$NCDEF.log  $FCP2REV
   ncverilog $NCOPT ../stm/stm_fcp2_packet.v                -l stm_fcp2_packet$NCDEF.log $FCP2REV
   ncverilog $NCOPT ../stm/stm_fcp2_format.v                -l stm_fcp2_format$NCDEF.log $FCP2REV
   ncverilog $NCOPT ../stm/stm_fcp2_align.v                 -l stm_fcp2_align$NCDEF.log  $FCP2REV
   ncverilog $NCOPT ../stm/stm_fcp2_ping.v                  -l stm_fcp2_ping$NCDEF.log   $FCP2REV

   endif

   if ( "$NCDEF" =~ "*+RTL*" ) then

#  ncverilog $NCOPT ../stm/stm_tm.v -l stm_tm0$NCDEF.log
#  ncverilog $NCOPT ../stm/stm_tm.v -l stm_tm1$NCDEF.log +define+FW=\"system/CYF12C0_Smxx.166\"

   endif

   if ( "$1" == "GATE" ) then

   setenv NCDEF "+GATE"
   setenv NCCMD "+ncaccess+rc +nowarn+NONPRT -disable_sem2009 -sv"
   setenv NCCMD "$NCCMD +ncnontcglitch"
   setenv NCCMD "$NCCMD +extend_tcheck_data_limit/100 +neg_tchk"
   setenv NCCMD "$NCCMD +ncnowarn+SDFNCAP +ncnowarn+SDFNEP +ncnowarn+SDFNET +ncnowarn+SDFINC +ncnowarn+SDFNL1"
#  setenv NCDUT "-f ../cmd/bench_0.f  -f ../cmd/add_phy_0.f ./gate.v +define$NCDEF+CAN1112A0"
#  setenv NCDUT "-f ../cmd/bench_b0.f -f ../cmd/add_phy_0.f ./gate.v +define$NCDEF+CAN1112B0"
#  setenv NCDUT "-f ../cmd/bench_b1.f -f ../cmd/add_phy_0.f ./gate.v +define$NCDEF+CAN1112B1"
   setenv NCDUT "-f ../cmd/bench.f -f ../cmd/macro.f ./gate.v +define$NCDEF"
   setenv NCOPT "$NCCMD $NCDUT $HWREV"

   ls -l ./spef* ./gate*

#  ncverilog $NCOPT ../stm/stm_tm.v      -l stm_tm$NCDEF.log
   ncverilog $NCOPT ../stm/stm_sfr.v     -l stm_sfr$NCDEF.log
   ncverilog $NCOPT ../stm/stm_hwi2c.v   -l stm_hwi2c$NCDEF.log
#  ncverilog $NCOPT ../stm/stm_monur.v   -l stm_monur$NCDEF.log

#  setenv NCDUT "-f ../cmd/macro_1.f ./gate.v ../stm/stm_atpg.v"
#  ncverilog $NCOPT -l atpg_serial_31+3_ver.log +define+FSDB+GATE+MIN+VEC_VER=\"atpg_serial_31+3.vec\"
#  ncverilog $NCOPT -l atpg_serial_ver.log           +define+GATE+MIN+VEC_VER=\"atpg_serial.vec\"

   endif
   endif

   date | tee stm_list.log
   echo "all_stm:" `grep    '^[^#]\s*ncverilog '    ./stm_list.sh | wc -l`                       | tee -a stm_list.log
   echo "all_log:"                             `ls -1 ./stm_*.log | wc -l`                       | tee -a stm_list.log
   echo "all_run:" `grep -l 'ncsim> run'                 ./s*.log | wc -l` "\t(started)"         | tee -a stm_list.log
   echo "all_pas:" `grep -l 'NOTE: simulation completed' ./s*.log | wc -l` "\t(completed)"       | tee -a stm_list.log
   echo "all_int:" `grep -l '^Simulation interrupted'    ./s*.log | wc -l` "\t(interrupted)"     | tee -a stm_list.log
#  echo "all_ext:" `grep -l '(status 1), exiting'        ./s*.log | wc -l` "\t(compiler exited)" | tee -a stm_list.log
   echo "all_ext:" `grep -l ': \*[EF],'                  ./s*.log | wc -l` "\t(compiler exited)" | tee -a stm_list.log
   echo "all_err:" `grep -l '> ERROR:'                   ./s*.log | wc -l` "\t(error finished)"  | tee -a stm_list.log
   grep -l '> ERROR:' ./*.log                                                                    | tee -a stm_list.log

   if ( "$1" == "" ) setenv NCDEF "+RTL"

