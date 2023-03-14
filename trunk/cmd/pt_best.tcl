
   set PJ_PATH [ getenv PJ_PATH ] ;# /mnt/app1/ray/project/can1127
#  set set_net /mnt/app1/king/WORK/CAN1127/APR_LAYOUT/chiptop_0429.v
#  set set_spf /mnt/app1/king/WORK/CAN1127/APR_LAYOUT/chiptop_0429.spef.min
   set set_net ./gate.v
   set set_spf spef.lnk ;# ./apr_min.lnk

   ls -l $set_net $set_spf
   set search_path [ list . \
                ${synopsys_root}/libraries/syn \
   ]

   set set_top chiptop_1127a0
   read_verilog -hdl_compiler $PJ_PATH/macro/anatop_1127a0_empty.v
   read_verilog $set_net
   current_design $set_top

   set target_library [ list \
		MSL18B_1536X8_RW10TM4_16_20210603_best_syn.db \
		std_best.db \
		STX018SIO1P4M_BEST.db \
		ATO0008KX8MX180LBX4DA_FF_1p980v_-40c.db \
   ]

   set synthetic_library [ list dw_foundation.sldb ]
   set link_library [ concat {*} $target_library $synthetic_library ]
   echo $target_library
   link
   current_design $set_top
   report_reference
   report_disable_timing -nosplit

   proc chktiming {} {
#	report_timing -nosplit -delay max -path full_clock_ex -input
	report_timing -nosplit -delay max -path end -max 10
	report_timing -nosplit -delay min -path end -max 10
 	report_timing -nosplit -delay max -path full_clock_ex -input
 	report_timing -nosplit -delay min -path full_clock_ex -input
        report_clock_timing -type summary



   }
   proc setclock0 { period } {
        remove_clock -all
        create_clock -period $period -waveform [ list 0 [ expr $period/2 ]] -name MCLK [ get_pins U0_ANALOG_TOP/OSC_O ]
	set_propagated_clock *
        set_clock_uncertainty 0.3 [ get_clocks ]
   }
   proc setclock1 { period } {
        remove_clock -all
        create_clock -period $period -waveform [ list 0 [ expr $period/2 ]] -name TCLK [ get_ports GPIO3 ]
	set_propagated_clock *
        set_clock_uncertainty 0.3 [ get_clocks ]
   }

#  set_operating_conditions BEST  -library STX018SIO1P4M_BEST
#  set_operating_conditions BEST  -library Max018SA_3p3v_BEST
   set_operating_conditions -analysis_type single
   read_parasitics $set_spf
   write_sdf ./chiptop_ff.sdf

   report_clock_gate_savings




   set_disable_timing U0_CORE/U0_MCK_BUF -to Y -from A
   set_disable_timing U0_CORE/U0_TCK_BUF -to Y -from A
   set_disable_timing [ get_lib_cells -of PAD_* ] -to DI -from IE
   set_multicycle_path 1 -to { U0_CODE_*/CSB U0_CODE_*/PGM U0_CODE_*/A* U0_CODE_*/RE U0_CODE_*/TWLB* }

#  set_false_path -thro { U0_CODE/PCE U0_CODE/PWE }
#  set_false_path -thro { U0_CODE/PPROG }
#  set_false_path -thro { U0_CODE/PDOUT* }

   set power_enable_analysis true

   setclock0 50


   chktiming
   report_power ;# Information: Checked out license 'PrimeTime-PX' (PT-019)

   setclock1 50
   set_false_path -from [get_ports GPIO3]
   chktiming
   report_power

   set output_list [ get_ports { GPIO4 GPIO5 } ]
   set input_list [ get_ports { SDA SCL GPIO1 } ]
   set_output_delay 0 -clock TCLK $output_list
   set_input_delay  5 -clock TCLK $input_list

   foreach_in_collection pp $output_list {
      report_timing -nosplit -delay max -path end -to $pp
      report_timing -nosplit -delay min -path end -to $pp
   }
   foreach_in_collection pp $input_list {
      puts [ get_object_name $pp ]
      report_timing -nosplit -delay max -path end -from $pp
      report_timing -nosplit -delay min -path end -from $pp
   }

   report_timing -nosplit -delay max -path full_clock_ex -input
   report_timing -nosplit -delay min -path full_clock_ex -input

## hold voilation in simulation (20211029)
## don't know why the timing is different between simulation
## add delay to let better margine (+0.10 -> , +0.18 -> respectively)
   report_timing -nosplit -delay min -path full_clock_ex -thr U0_CORE/u0_dacmux/u0_dac2sar/u0_dac1v/mem_reg_1_
   report_timing -nosplit -delay min -path full_clock_ex -thr U0_CORE/u0_regbank/osc_gate_n_reg*

   quit

