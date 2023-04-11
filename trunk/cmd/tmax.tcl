
   report_version -full
#  set_messages log tmax.log -replace
## Let more gates on the schematic.
#  set_environment_viewer -max_gates 300 ;# Error: Command not supported for non-GUI version. (M230)
## Reading the Netlist and Library Models
#  set pj_path "/mnt/app1/ben/project/usbpd_01/ASIC"
#  read_netlist -format verilog ${pj_path}/atpg/lib/*.v
#  read_netlist -format verilog ${pj_path}/atpg/netlist/chip.v
#  set pj_path "/mnt/app1/ray/project/usbpd_02/ASIC"
   set pj_path [ getenv PJ_PATH ]
   read_netlist -format verilog ${pj_path}/macro/std.v
   read_netlist -format verilog ${pj_path}/macro/io.v
   read_netlist -format verilog ${pj_path}/macro/io_udp.v
   read_netlist -format verilog ${pj_path}/work1/syn/chiptop_1127a0_3.v
   report_modules -summary

## TetraMAX ignores the contents of the block. It terminates the block
## inputs and connects TIEX primitives to the outputs.
## set_build -black_box {
##      DROM4096X32M8 RADP1280X8 RADP2048X32 RADP640X16 RADP720X16 RADP720X8 RASP1280X8 \
##      RASP640X16 RASP640X34 RASP720X8 RASP800X8 RASP960X8 RASP976X10 RFSP108X32 RFSP128X16 \
##      RFSP128X32 RFSP16X104 RFSP16X52 RFSP16X64 RFSP240X32 RFSP24X52 RFSP32X13 RFSP32X26 \
##      RFSP32X30 RFSP32X32 RFSP32X64 RFSP64X21 RFSP64X26 RFSP64X32 RFSP64X64 RFSP64X8 RFSP72X64 \
##      RFSP8X80 RFSP96X16 RFSP96X32 RFSP96X56 RFSP96X64 RFTP112X32 RFTP128X32 RFTP16X32 RFTP16X36 \
##      RFTP16X52 RFTP16X64 RFTP184X32 RFTP32X11 RFTP32X14 RFTP32X26 RFTP32X32 RFTP32X56 RFTP32X64 \
##      RFTP32X68 RFTP360X16 RFTP416X32 RFTP48X64 RFTP512X8 RFTP64X10 RFTP64X22 RFTP64X32 \
##      RFTP64X40 RFTP64X54 RFTP64X64 RFTP64X8 RFTP96X32 \
##      PLL07B_TOP \
##      OSC32K02D_TOP \
##      ADC08C_TOP R2RDAC06_TOP S013DA10B3C_200S_E \
##      POR01B_TOP arm926ejs_top \
##      USB20PHY04C_TOP
##}

   set_build -empty_box { 
        ATO0008KX8MX180LBX4DA \
        MSL18B_1536X8_RW10TM4_16_20221107 \
        anatop_1127a0 \
        tranif1 \
        }
#       OTP_VDDP_A0 \

## Building the ATPG Model  (BUILD-> DRC)
   run_build_model chiptop_1127a0

## Define clocks and pin constraints
#  add_clocks 0 CLK MCLK SCLK
#  add_clocks 0 MCLK -timing 200 50 80 40 -unit ns -shift

   add_pi_constraints 1 TST
#  add_pi_constraints 0 p_auto_detb
#  add_pi_constraints 0 p_nce
#  add_pi_constraints 1 p_sce
#  add_pi_constraints X { p_sck p_sda p_irq }

#  add_pi_constraints X {
#          VSS \
#          }
  

#  add_po_masks {
#          \
#          }

   report_pi_constraints

###Starting Test DRC
#--------------------------------------------------------------------------------
# To solve Warning: 18 remodeled latches may fail VerilogDPV parallel simulation; 
#          use set_drc -nodslave_remodel -noreclassify_invalid_dslaves. (M404)
#--------------------------------------------------------------------------------
#  set_drc -nodslave_remodel -noreclassify_invalid_dslaves
#  set_drc ${pj_path}/atpg/netlist/chipset.spf
   set_drc ${pj_path}/work1/syn/chiptop_1127a0.spf
   run_drc  ;# (DRC -> TEST)

   report_buses -summary
   report_buses -contention Fail -verbose
   report_buses -zstate     Fail -verbose
   report_primitives -summary
   report_rules -all -fail
#  report_rules -fail ;# > ./rpt/report_rules.rpt
   report_violations -all ;# > ./rpt/report_violations.rpt
   report_nonscan_cells -summary ;# > ./rpt/report_nonscan_cells.rpt
#  report_buses -summary ;# > ./rpt/report_buses.rpt

###Create patterns (ATPG performed for stuck fault model using internal pattern source)
   set_atpg -abort_limit 512 -merge high -basic_min_detects_per_pattern 1 -pattern 1000 -coverage 98
   add_faults -all
   run_atpg -auto_compression

#  report_summaries ;# > ./rpt/report_summaries.rpt

###Writing ATPG Patterns
#  report_faults -summary
#  write_faults ./vout/faults.all -all -replace
#  write_patterns ./vout/A1018B.wgl    -internal -format wgl -replace -split 100

###To generate group patterns
#  write_patterns ./pattern/chipset_atpg.v -internal -format verilog_single_file     -serial -replace    -split 10
#  write_patterns ./netlist/atpg.stil -internal -cellnames verilog -format stil -vcs -serial -replace ;# -split 10
   write_patterns ./syn/atpg_parallel.stil.gz     -compress gzip -format stil99 -parallel -replace
   write_patterns ./syn/atpg_serial.stil.gz       -compress gzip -format stil99 -serial -replace
   write_patterns ./syn/atpg_chain.stil.gz        -compress gzip -format stil99 -serial -replace -last 0
#  write_patterns ./syn/atpg_serial_2.stil.gz     -compress gzip -format stil99 -serial -replace -last 2
   write_patterns ./syn/atpg_serial_8.stil.gz     -compress gzip -format stil99 -serial -replace -last 8
   write_patterns ./syn/atpg_serial_99+3.stil.gz  -compress gzip -format stil99 -serial -replace -last 101 -first 99
   write_patterns ./syn/atpg_serial_836+3.stil.gz -compress gzip -format stil99 -serial -replace -last 838 -first 836

###To generate split patterns
#  set_patterns -internal -split_patterns
#  write_patterns ./pattern/chipset_atpg.v -internal -format verilog_single_file -serial -replace -split 1

###To generate IDDQ patterns
   remove_faults -all
   set_faults -model iddq
#  set_iddq -toggle      ;# pseudo-stack-at is the default
   add_faults -all
   set_atpg -patterns 20 ;# budget of 20 IDDQ strobes
   run_atpg -auto_compression
   write_patterns ./syn/atpg_iddq.stil.gz        -compress gzip -format stil99 -serial -replace

   exit
#  gui_start

