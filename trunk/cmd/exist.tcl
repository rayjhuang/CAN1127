
   getenv PJ_PATH
   getenv DCODE
   printenv
   printvar

   set top chiptop_1127a0
   read_file -format verilog -rtl { ../macro/anatop_1127a0.v } -define ANATOP_EMPTY
   read_verilog -netlist ./syn/${top}_2.v
   current_design $top
   link

###########################################
##                netlist
#  remove_port [ remove_from_collection [ get_ports ] \
#                      [ get_ports { p_test* p_rstb_ext p_clk12m p_lbdb p_pol p_irq }]]
   source ../cmd/proc.tcl
   re_connect_pin2net [ get_pins U0_CORE/i_rstz ] [ get_nets -of PAD_TST/DI ]
   re_connect_pin2net [ get_pins U0_CORE/atpg_en ] [ get_nets -of PAD_TST/DI ]
   write -f verilog -hierarchy $top -o ./syn/${top}_3.v ;# for tmax ATPG

## dft clock
   set period 50
   set tRise [ expr $period/2-5 ]
   set tFall [ expr $period-10 ]
#  create_clock -period $period -waveform [ list $tRise $tFall ] -name dft_clk [ get_ports GPIO3 ]
#  set_clock_uncertainty -setup 0.5 [ all_clocks ]
#  set_clock_uncertainty -hold  0.5 [ all_clocks ]
#  report_clocks

# Identify the test ports to DFT Compiler.
   set_scan_state scan_existing
#  set_scan_configuration -replace false
#  set_scan_configuration -style clocked_scan
   report_scan_configuration

###########################################
##                DFT
## man test_variables
#  set test_default_bidir_delay 1.0
   set test_default_period $period
   set test_default_strobe [ expr $tRise-5 ]
   set test_protocol_add_cycle false
   set test_stil_netlist_format verilog
   print_variable_group test
   print_variable_group write_test
###########################################
   set_dft_signal -view exist -type TestMode   -port TST   -hookup_pin U0_CORE/atpg_en -active_state 1
   set_dft_signal -view exist -type ScanEnable -port GPIO1 -hookup_pin U0_CORE/DI_GPIO[2] -active_state 1
   set_dft_signal -view exist -type ScanClock  -port GPIO3 -hookup_pin U0_CORE/U0_CLK_MUX/Y \
                  -timing [ list $tRise $tFall ] -test_mode all_dft

## Scan in / Scan out
   set_scan_path chain_0 -view exist -infer_dft_signals \
                         -scan_enable GPIO1 -scan_data_in SCL   -scan_data_out GPIO4
   set_scan_path chain_1 -view exist -infer_dft_signals \
                         -scan_enable GPIO1 -scan_data_in SDA   -scan_data_out GPIO5

## Test Protocal creation
   create_test_protocol -infer_clock -infer_asynch
   dft_drc -verbose
   report_scan_path
#  dft_drc -coverage_estimate -verbose ;# > rpt/fcoverage_2.rpt
#  change_names -hierarchy -rule verilog
#  write -f verilog  -hierarchy -output netlist/chipset_scan_1.v
#  set verilogout_show_unconnected_pins TRUE
#  write -f verilog -hierarchy $set_top -o netlist/chipset_scan_2.v

   write_test_protocol -output ./syn/chiptop_1127a0.spf ;# for TMAX
   write_scan_def -output ./syn/chiptop_1127a0.scandef ;# for APR
   check_scan_def

   quit

