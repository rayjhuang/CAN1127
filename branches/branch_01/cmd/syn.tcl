
   if { [ catch { getenv "PJ_PATH" } msg ] } {
      puts $msg
      exit -1
   }
   getenv PJ_PATH
   getenv DCODE
   set std_cell worst
   set top chiptop_1127a0
   read_file -rtl ../macro/anatop_1127a0.v -define ANATOP_EMPTY
   read_file -autoread -top $top -recursive -exclude { inc_* *restruct* */.svn* } { ../rtl } -define R51MDU
#  read_file { .      } -autoread            -top phyff
   set rename_ds [ remove_from_collection [ get_designs * ] \
                 [ remove_from_collection [ get_designs *_* ] mcu51_cpu ]]
   rename_design $rename_ds -postfix "_a0" -update_links ;# for RTL code is used by simulation models

   current_design $top
   uniquify
   link
   check_design

   list_licenses
   check_license {
        Design-Compiler \
        DC-Ultra-Opt \
        Power-Optimization \
        Test-Compiler \
        Test-Compression-Synthesis }
#       DC-Ultra-Features \

   set period 40
   create_clock -name CLK [ get_pins U0_ANALOG_TOP/OSC_O ] -period $period
   create_generated_clock [ get_pins U0_CORE/U0_CLK_MUX/Y] -source [ get_pins U0_ANALOG_TOP/OSC_O ] \
                -name MCLK -divide_by 1 ;# for CT_gen can pass through the mux

   #48MHz  
#  set period1 20.8 
#  create_clock -name CLK1 [ get_pins U0_CORE/DI_GPIO[4] ] -period $period1
#  create_generated_clock [ get_pins U0_CORE/U1_CLK_MUX/Z] -source [ get_pins U0_CORE/DI_GPIO[4] ] \
#               -name SCLK -divide_by 1 ;

#  set_input_delay  7 -clock SCLK [ all_inputs ]
#  set_output_delay 5 -clock SCLK [ all_outputs ]
 
   set_input_delay  30 -clock MCLK [ all_inputs ]
   set_output_delay 20 -clock MCLK [ all_outputs ]

   set anatop_n [ get_pins { U0_ANALOG_TOP/CMP_SEL_* U0_ANALOG_TOP/AD_RST } ]
   set_output_delay 10 -clock MCLK $anatop_n
   set anatop_i [ filter_collection [ get_pins -of U0_ANALOG_TOP ] "pin_direction == in" ]
   set anatop_i [ remove_from_collection $anatop_i $anatop_n ]
   set_output_delay 15 -clock MCLK $anatop_i

   set anatop_o [ filter_collection [ get_pins -of U0_ANALOG_TOP ] "pin_direction == out" ]
   set anatop_o [ remove_from_collection $anatop_o [ get_pins { U0_ANALOG_TOP/OSC_O U0_ANALOG_TOP/RSTB } ]]
   set_input_delay  31 -clock MCLK $anatop_o
 
#  set_max_transition 1.98 $top
   set_clock_uncertainty -setup 0.5 [all_clocks]
   set_clock_uncertainty -hold  0.5 [all_clocks]

   set_ideal_network [ get_pins {U0_CORE/U0_CLK_MUX/Y U0_CORE/U0_MCLK_ICG/ECK} ]
#  set_ideal_network [ get_driving_pin [ get_pins U0_CORE/u0_regbank/srstz ]]
#  set_ideal_network [ get_pins {U0_CORE/U0_SCAN_EN/Z} ]
#  set_dont_touch_network [ get_pins {U0_CORE/U0_SCAN_EN/Z} ]

#  set_ideal_network [ get_pins {U0_CORE/U0_TCK_BUF/Z} ]
#  set_dont_touch_network [ get_pins {U0_CORE/U0_TCK_BUF/Z} ]

   set dont_touch_cs [ remove_from_collection [ get_cells -hier { U0_* } ] [ get_cells U0_CORE ]]
   set_dont_touch $dont_touch_cs
   set_false_path -from [ get_ports { TST } ]
#  set_false_path -from [get_clocks MCLK] -to [get_clocks SCLK]
#  set_false_path -from [get_clocks SCLK] -to [get_clocks MCLK]
#  set_false_path -from [get_clocks MCLK] -to [get_clocks CLK1]
#  set_false_path -from [get_clocks CLK1] -to [get_clocks MCLK]
   set_false_path -from $anatop_o -to [ all_outputs ]
   set_false_path -from $anatop_o -to $anatop_i

   set_disable_timing [ get_lib_cells -of PAD_* ] -to DI -from IE
   set_disable_timing [ get_cells U0_CORE/U0_MCK_BUF ] -to Y -from A
   set_disable_timing [ get_cells U0_CORE/U0_TCK_BUF ] -to Y -from A
   set_disable_timing [ get_cells U0_CORE/U0_BUF_NEG* ] -to Y -from A

   set_fix_multiple_port_nets -all -buffer_constants -feedthroughs
#  set_wire_load_model [all_design] -name vis18_wl40 -library $std_cell
   set_wire_load_mode top
   set_operating_conditions PVT_1P62V_125C -library $std_cell
   set_max_fanout 10 $top

   set dont_use_cs [ get_lib_cells [ list \
			$std_cell/DLY* \
			$std_cell/CK* \
			$std_cell/SDFF* \
			]]
   set_dont_use $dont_use_cs
   set_clock_gating_style -pos integrated -neg integrated \
			-control_point before -control_signal scan_enable

   compile -map_effort high -area_effort high -scan -gate_clock

   list_attributes
#  report_clock_gating
   report_clock_gating -ungated -v -nosplit

#  compile_ultra -scan -gate_clock ;# not licensed

   report_timing -path_type full_clock_expanded -input_pin
   report_timing -from [ get_pins U0_CORE/u0_ictlr/c_buf_reg*/Q* ]
   report_timing -to   [ get_pins U0_SRAM/A* ]
   report_timing -to   [ get_pins U0_SRAM/D* ]
   report_timing -to   [ get_pins U0_CODE[*]/A* ]
   report_timing -from [ get_pins U0_CODE[*]/Q* ]

   current_design [ get_attribute [ get_cell U0_CORE/u0_updphy ] ref_name ]
                             report_reference; sizeof_collection [ all_registers ]
   current_design fcp_a0;    report_reference; sizeof_collection [ all_registers ]
   current_design dacmux_a0; report_reference; sizeof_collection [ all_registers ]
   current_design mcu51_a0;  report_reference; sizeof_collection [ all_registers ]
   current_design core_a0;   report_reference; sizeof_collection [ all_registers ]
   report_area
   current_design $top;      report_reference; sizeof_collection [ all_registers ]
   report_area -hierarchy
   report_constraint -all_violators -verbose

   source ../cmd/proc.tcl
   list_col $anatop_n
   list_col $anatop_i
   list_col $anatop_o
   reg_summary
   icg_summary true
   disconnect_pins [ get_pins { U0*/VSS U0*/VDD } ]
   report_ideal_network

   change_names -rules verilog -hierarchy
   write_file $top -hierarchy -o ./syn/$top.ddc
#  write_sdf ./syn/chiptop.sdf

   remove_ideal_network -all
   write_sdc ./syn/$top.sdc 
   remove_design { anatop_1127a0 } ;#GM_M1O_4K256X16_5T18_T05
   write -f verilog -hierarchy $top -o ./syn/${top}_0.v

   exit

