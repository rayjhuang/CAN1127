
   set PJ_PATH [ getenv PJ_PATH ] ;# /mnt/app1/ray/project/can1127


   set set_net ./syn/chiptop_1127a0_2.v
   set set_sdf ./chiptop_1127a0_pre.sdf

   ls -l $set_net $set_sdf
   set search_path [ list . \
                ${synopsys_root}/libraries/syn \
   ]

   set set_top chiptop_1127a0
   read_verilog -hdl_compiler $PJ_PATH/macro/anatop_1127a0_empty.v
   read_verilog $set_net
   current_design $set_top

   set target_library [ list \
		MSL18B_1536X8_RW10TM4_16_20221107_worst_syn.db \
		std_worst.db \
		STX018SIO1P4M_WORST.db \
		ATO0008KX8MX180LBX4DA_SS_1p620v_125c.db \
   ]

   set synthetic_library [ list dw_foundation.sldb ]
   set link_library [ concat {*} $target_library $synthetic_library ]
   echo $target_library
   link
   current_design $set_top
   report_reference
   report_disable_timing -nosplit









#  set_wire_load_model -name 60000
   set_wire_load_mode top

   proc setclock0 { period } {
        remove_clock -all
        create_clock -period $period -waveform [ list 0 [ expr $period/2 ]] -name MCLK [ get_pins U0_ANALOG_TOP/OSC_O ]
#	set_propagated_clock *
        set_clock_uncertainty 0.2 [ get_clocks ]
        set_clock_latency 2.5 MCLK
   }
   proc setclock1 { period } {
        remove_clock -all
        create_clock -period $period -waveform [ list 0 [ expr $period/2 ]] -name TCLK [ get_ports GPIO3 ]
#	set_propagated_clock *
        set_clock_uncertainty 0.2 [ get_clocks ]
        set_clock_latency 5.0 TCLK
   }

   setclock0 50

#  set_ideal_network [ get_pins U0_MCLK_ICG/ECK ] ;# if no SDF
   read_sdf $set_sdf

#  set_output_delay 10 -clock hclk [ remove_from_collection [ all_outputs ] [ get_ports {XDAT_*}]]
#  set_output_delay 5  -clock hclk [ get_ports {XDAT_WEB XDAT_CEB}]
#  set_output_delay 3  -clock hclk [ get_ports {XDAT_A*}]
#  set_output_delay 6  -clock hclk [ get_ports {XDAT_D*}]

   set_disable_timing U0_CORE/U0_MCK_BUF -to Y -from A
   set_disable_timing U0_CORE/U0_TCK_BUF -to Y -from A
   set_disable_timing [ get_lib_cells -of PAD_* ] -to DI -from IE
   set_multicycle_path 1 -to { U0_CODE_*/CSB U0_CODE_*/PGM U0_CODE_*/A* U0_CODE_*/RE U0_CODE_*/TWLB* }

#  set_disable_timing [ get_timing_arcs -to { U0_CODE/PDIN* } -from { U0_CODE/PWE } ]
#  set_disable_timing [ get_timing_arcs -to { U0_CODE/PA* }   -from { U0_CODE/PWE } ]

#  set_false_path -thro U0_CODE/PDOUT*
#  set_false_path -to   U0_CORE/d_dodat_reg*

   set anatop_n [ get_pins { U0_ANALOG_TOP/CMP_SEL_* U0_ANALOG_TOP/AD_RST } ]
   set_output_delay 10 -clock MCLK $anatop_n
   set anatop_i [ filter_collection [ get_pins -of U0_ANALOG_TOP ] "pin_direction == in" ]
   set anatop_i [ remove_from_collection $anatop_i $anatop_n ]
   set_output_delay 15 -clock MCLK $anatop_i

   set anatop_o [ filter_collection [ get_pins -of U0_ANALOG_TOP ] "pin_direction == out" ]
   set anatop_o [ remove_from_collection $anatop_o [ get_pins { U0_ANALOG_TOP/OSC_O U0_ANALOG_TOP/RSTB } ]]
   set_input_delay  30 -clock MCLK $anatop_o

   report_timing -nosplit -delay max -path end -max 10
   report_timing -nosplit -delay min -path end -max 10
#  report_timing -nosplit -to [ get_ports GPIO* ] ;# scan chain output
#  report_timing -nosplit -to u0_ictlr/neg_r_pulse_reg/D

#  set_false_path -from {i_rstz i_clk atpg_en di_tst } -to DO_GPIO*
   report_timing -nosplit -to   [ get_pins { U0_SRAM/WEB U0_SRAM/CSB U0_SRAM/DI* }]
   report_timing -nosplit -from [ get_pins { U0_SRAM/DO* }]

   report_timing -path_type full_clock_expanded -nosplit
   report_timing -path_type full_clock_expanded -nosplit -delay_type min

#  set power_enable_analysis true
#  report_power ;# Information: Checked out license 'PrimeTime-PX' (PT-019)

   setclock1 50

   report_timing -path_type full_clock_expanded -nosplit
   report_timing -path_type full_clock_expanded -nosplit -delay_type min

   set_case_analysis 1 U0_CORE/atpg_en

   set output_list [ get_ports { GPIO4 GPIO5 } ]
   set_output_delay 0 -clock TCLK $output_list
   foreach_in_collection pp $output_list {
      report_timing -nosplit -delay max -path end -to $pp
      report_timing -nosplit -delay min -path end -to $pp
   }

   set input_list [ get_ports { SDA SCL GPIO1 } ]
   set_input_delay 0 -clock TCLK $input_list
   foreach_in_collection pp $input_list {
      puts [ get_object_name $pp ]
      report_timing -nosplit -delay max -path end -from $pp
      report_timing -nosplit -delay min -path end -from $pp
   }

#  exit

