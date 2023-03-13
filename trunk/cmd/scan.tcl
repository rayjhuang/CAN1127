
   getenv PJ_PATH
   getenv DCODE
   set std_cell worst
   set top chiptop_1127a0
   read_ddc ./syn/$top.ddc

#  report_transitive_fanin  -nosplit -to   U0_CORE/U0_TCK_BUF/I ;# directly to GPIO3
#  report_transitive_fanout -nosplit -from U0_CORE/U0_TCK_BUF/O

   set top core_a0 ;# renamed in syn.tcl
   current_design $top
   link

## dft clock ####
   set period 40
   set tRise [ expr $period/2-5 ]
   set tFall [ expr $period-5 ]
   create_clock -period $period -waveform [ list $tRise $period ] -name dft_clk [ get_ports DI_GPIO[4]]
   set_clock_uncertainty -setup 0.5 [ all_clocks ]
   set_clock_uncertainty -hold  0.5 [ all_clocks ]

   source ../cmd/proc.tcl

#  set_wire_load_model [all_design] -name vis18_wl40 -library $std_cell
   set_wire_load_mode top
   set_operating_conditions PVT_1P62V_125C -library $std_cell
   set_max_fanout 10 $top

   set dont_touch_cs [ get_cells -hier { U0_* } ]
   set_dont_touch $dont_touch_cs

   set dont_use_cs [ get_lib_cells [ list \
			$std_cell/DLY* \
			$std_cell/CK* \
			$std_cell/*\[2-9\]\[0-9\] \
			]]
#			$std_cell/DFXCN1Q \
#			$std_cell/DFXCN2Q \
#
   set_dont_use $dont_use_cs

###########################################
##                DFT
## man test_variables
   set test_default_period $period
   set test_default_strobe [ expr $tRise-5 ]
   set test_protocol_add_cycle false
   print_variable_group test
###########################################
## Test mode ####
   set_dft_signal -view exist -type Constant   -port i_rstz  -active 1
   set_dft_signal -view exist -type TestMode   -port atpg_en -active 1
   set_dft_signal -view exist -type ScanClock  -port DI_GPIO[4] -timing [ list $tRise $tFall ] -test_mode all_dft
   set_dft_signal -view spec  -type ScanClock  -port DI_GPIO[4] -hookup_pin U0_CLK_MUX/Y       -test_mode all_dft
   set_dft_signal -view spec  -type ScanEnable -port DI_GPIO[2] -hookup_pin U0_SCAN_EN/Y \
                                                             -active 1 -usage { clock_gating scan }

   set_dft_connect SCAN_CON_1 -source DI_GPIO[2] -type clock_gating_control -target [ list dft_clk ]

## Scan in / Scan out ####
   set_dft_signal -view spec -type ScanDataIn  -port DI_GPIO[0]
   set_dft_signal -view spec -type ScanDataOut -port DO_GPIO[5] 
   set_scan_path chain_0 -scan_enable  DI_GPIO[2] -complete false \
              -view spec -scan_data_in DI_GPIO[0] -scan_data_out DO_GPIO[5]

   set_dft_signal -view spec -type ScanDataIn  -port DI_GPIO[1]
   set_dft_signal -view spec -type ScanDataOut -port DO_GPIO[6] 
   set_scan_path chain_1 -scan_enable  DI_GPIO[2] -complete false \
              -view spec -scan_data_in DI_GPIO[1] -scan_data_out DO_GPIO[6]

   set_scan_configuration -chain_count 2

#  set_scan_configuration -clock_mixing mix_edges -replace false
   set_scan_configuration -clock_mixing mix_edges -replace true

## AUTOFIX ####
   set_dft_configuration -scan enable
   set_dft_configuration -fix_bus disable
   set_dft_configuration -fix_reset disable
   set_dft_configuration -fix_bidirectional enable ;# fix SI from PAD
#  set_dft_configuration -fix_xpropagation enable

#  set_dft_configuration -control_points enable
#  set_dft_configuration -observe_points enable
#  set_dft_configuration -test_points enable
#  set_test_point_configuration -target testability -clock_type dominant \
#                               -power_saving enable \
#                               -max_observe_points 32 \
#                               -max_control_points 32

## Identify tool inserted clock gates ####
   set_dft_configuration -connect_clock_gating enable
   identify_clock_gating

   set_dft_insertion_configuration -preserve_design_name true -synthesis_optimization none -map_effort low

## Test Protocal creation ####
   create_test_protocol -infer_asynch -infer_clock

   dft_drc -pre_dft -verbose ;# > rpt/dft_drc_prescan.rpt

## preview dft ####
   preview_dft -show all ;# > rpt/preview_dft_all.rpt
   set_dft_configuration -connect_clock_gating enable

#---------- stitch the scan cells ----------
   insert_dft
   list_test_modes

#---------- postscan drc ---------- 
#  dft_drc -verbose ;# > rpt/dft_drc_postscan.rpt
   dft_drc -coverage -sample 1

#---------- coverage ----------
   report_scan_path

#  remove_test_protocol
   report_dft_signal
   report_dft_configuration

#---------- area optimization ----------
   set top chiptop_1127a0
   current_design $top
   link
#  set_input_delay  10 [ remove_from_collection [ all_inputs ] DI_GPIO[0] ] -clock CLK
#  set_output_delay 10 [ all_outputs ] -clock CLK
#  set flatten_ds [ get_designs { *_DW* SNPS_CLOCK_GATE_* } ]; set_flatten true -design $flatten_ds

   set_false_path -thro U0_CORE/U0_SCAN_EN/Y

   set_ideal_network [ get_pins {U0_CORE/U0_CLK_MUX/Y} ]
   set_ideal_network [ get_driving_pin [ get_pins U0_CORE/u0_regbank/srstz ]]

   set_ideal_network [ get_pins {U0_CORE/U0_SCAN_EN/Y} ]
   set_dont_touch_network [ get_pins {U0_CORE/U0_SCAN_EN/Y} ]

   set_disable_timing [ get_lib_cells -of PAD_* ] -to DI -from IE
   set_disable_timing [ get_cells U0_CORE/U0_MCK_BUF ] -to Y -from A
   set_disable_timing [ get_cells U0_CORE/U0_TCK_BUF ] -to Y -from A

#  set_ideal_network [ get_pins {U0_CORE/U0_TCK_BUF/O} ]
#  set_dont_touch_network [ get_pins {U0_CORE/U0_TCK_BUF/O} ]

   compile -area_effort high -map_effort high
   write_file $top -hierarchy -o ./syn/${top}_scan.ddc

#---------- results ----------
   current_design [ get_attribute [ get_cells U0_CORE/u0_updphy ] ref_name ]
                            report_reference
   current_design mcu51_a0; report_reference
   current_design core_a0;  report_reference; sizeof_collection [ all_registers ]
   report_area
   current_design $top;     report_reference
   report_area -hierarchy -nosplit
   report_timing -sort_by slack -max_paths 3  -nosplit -delay min -path end
   report_timing -sort_by slack -max_paths 10 -nosplit -delay max -path end
   report_timing -sort_by slack -max_paths 10
   report_constraint -all_violators -verbose

   set_clock_gate_ideal
   set_clock_network_cell_ideal

#---------- reconnect ----------
#  set TDGO_cell [ get_cells -hier -filter {@full_name=~*control_observe_register*} ]
   set TDGO_cell [ get_cells U0_CORE/* -filter {@full_name=~*control_observe_register*} ]
   foreach_in_collection cell $TDGO_cell {
      re_connect_pin2net [ get_pins -of ${cell} -filter full_name=~*CP ] \
                         [ get_nets -of U0_CORE/d_dodat_reg[0]/CP ]
   }

   reg_summary
   icg_summary true
   disconnect_pins [ get_pins { U0*/VSS U0*/VDD } ]
   report_ideal_network

#  set dis_ps [ get_pins -of [ get_nets U0_CORE/u0_regbank/rrstz ] -filter "pin_direction==out" ]
#  set_disable_timing [ get_cells -of $dis_ps ] -to O -from B1
   change_names -hierarchy -rule verilog
   remove_design { anatop_1127a0 }
   current_design $top; write -f verilog -hierarchy $top -o ./syn/${top}_2.v ;# for pre-sim, ATPG and formal check
   write_sdf ./chiptop_1127a0_pre.sdf

   read_file -rtl ../macro/empty.v ;# for APR needs those empty module definitions
   read_file -rtl ../macro/anatop_1127a0.v -define ANATOP_EMPTY
   current_design $top; write -f verilog -hierarchy $top -o ./syn/${top}_1x.v ;# -> _1.v for APR

   exit

