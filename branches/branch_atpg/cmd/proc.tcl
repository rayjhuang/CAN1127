################################################################################
## processes for synopsys
## 2008/8/15,  Ray Huang
## there are several useful command line instead of becoming a process
## 2009/12/11, Ray Huang
## 1. a). sizeof_collection [ all_clock_gates ]
##        sizeof_collection [ all_registers -clock [ index_collection [ get_clocks ] 1 ]]
##    b). sizeof_collection [ get_cells -hier -filter "@ref_name=~*FF*" ]
##    c). query_objects [ get_cells * ] -tr 0
##    d). get_nets -of_objects [ get_pins $pin_obj ]
##    e). list_col [ all_clock_gates ]
##    f). get_attribute [ get_cell U0_CORE/u0_updphy ] ref_name
## 2. string
##    format
##    concat
##    append
## 3. attribute
##    list_attributes -application -class lib_cell
##    report_attribute -nosplit -application? $obj
##    number_of_pins
##    ff_edge_sense
##    full_name
##    is_hierarchical
##    is_sequential
##    is_rise_edge_triggered, is_fall_edge_triggered
##    is_integrated_clock_gating_cell
##    is_clock_pin
##    is_clock_gate_clock_pin
##    is_clock_gate_output_pin
##    pin_direction
## 4. insert_buffer / remove_buffer
##    create_cell / remove_cell
## All Rights Reserved
################################################################################

proc reg_summary {} {
   set all_reg [ all_registers ]
   set all_non $all_reg
   puts "\nregister summary:\n--------"
   puts "[ sizeof_collection $all_reg ]\tflip-flop"
   puts "[ sizeof_collection [ all_registers -level_sensitive ]]\tlatch"
   puts "[ sizeof_collection [ all_fanout -clock_tree -endpoints_only -flat ]]\t-\t-\tclock-leaf"
   foreach_in_collection ck [ get_clocks ] {
      set all_cked [ all_registers -clock $ck ]
      set all_non [ remove_from_collection $all_non $all_cked ]
      puts "\t[ sizeof_collection $all_cked ]\t-\t[ get_attribute $ck full_name ]"
      puts "\t\t[ sizeof_collection [ all_registers -rise_clock $ck ]]\trise"
      puts "\t\t[ sizeof_collection [ all_registers -fall_clock $ck ]]\tfall"
   }
   puts "\n-\tnon-leaf register:\n\t--------"
   list_col $all_non
   non_ff_leaf
   non_clock_leaf
   return 1
} ;# reg_summary
proc icg_summary { flag } {
   set all_reg [ all_registers ]
   puts "\nclock-gated summary:\n--------"
   puts "[ sizeof_collection [ all_clock_gates ]]\tclock-gating cell"
   set all_cgr [ all_fanout -only_cells -from [ get_pins -hierarchical clk_gate_*/ENCLK ]]
   set all_cgr [ filter $all_cgr "is_hierarchical == false" ]
   puts "[ sizeof_collection $all_cgr ]\tclock-gated"
   set all_cgr [ remove_from_collection $all_reg $all_cgr ]
   puts "[ sizeof_collection $all_cgr ]\tnon-gated register:\n\t--------"
   if { $flag == "true" } {
      list_col $all_cgr
   }
   return 1
} ;# icg_summary
proc non_ff_leaf {} {
   puts "\n-\tnon-ff-leaf pin:\n\t--------"
   foreach_in_collection pp [ all_fanout -clock_tree -endpoints_only -flat ] {
      set trig [ get_attribute -quiet [ get_cells -quiet -of $pp ] ff_edge_sense ]
      if { $trig == "" } {
         puts "\t[ get_attribute $pp full_name ]"
      }
   }
   return 1
} ;# non_ff_leaf
proc non_clock_leaf {} {
   puts "\n-\tnon-clock-leaf pin:\n\t--------"
   foreach_in_collection pp [ all_fanout -clock_tree -endpoints_only -flat ] {
      set trig [ get_attribute -quiet $pp is_clock_pin ]
      if { $trig != "true" } {
         puts "\t[ get_attribute $pp full_name ]"
      }
   }
   return 1
} ;# non_clock_leaf
proc disconnect_pins { pins } {
   foreach_in_collection pin $pins {
      disconnect_net [ get_nets -of_objects [ get_pins $pin ] ] $pin
   }
} ;# disconnect_pin
proc get_driver { pin_net only_cells } {
## give a net or a pin
## return the driving pin or the driving cell
   if { [ get_attribute -quiet [ get_pins -quiet $pin_net ]  pin_direction ] == "out" } {
      return [ get_cells -of_objects $pin_net ]
   }
   set the_col {}
   if { $only_cells==true || $only_cells==yes } {
      set fanin_list [ all_fanin -flat -to $pin_net -only_cells ]
      set the_col [ filter $fanin_list "is_hierarchical == false" ]
      if { [ get_attribute -quiet [ get_pins -quiet $pin_net ] pin_direction ] == "in" } {
         set the_col [ remove_from_collection $the_col [ get_cells -of_objects $pin_net ] ]
      }
   } else {
      set the_col [ all_fanin -flat -to $pin_net ]
      if { [ get_attribute -quiet [ get_pins -quiet $pin_net ] pin_direction ] == "in" } {
         set the_col [ remove_from_collection $the_col [ get_pins $pin_net ] ]
      }
   }
   return [ index_collection $the_col [ expr [ sizeof_collection $the_col ] - 1 ] ]
} ;# get_driver
proc get_pin_of_driver { pin_net } {
   get_driver $pin_net false
}
proc get_cell_of_driver { pin_net } {
   get_driver $pin_net true
}

proc get_connect_by_dir { coll att } {
## get connect by direction
## 'att': out | in
   set RTN ""
   foreach_in_collection pp $coll {
      if { [ string match $att [ get_attribute [ get_object_name $pp ] pin_direction ] ] } {
         set RTN [ add_to_collection $RTN $pp ]
      }
   }
   return $RTN
} ;# get_connect_by_dir

proc get_connect_non_ck { ck_net } {
## get a collection of pin(s) of the 'ck_net's loading(s)
## 'proc get_net_driver' depended
   set RTN ""
   foreach_in_collection pp [ all_fanout -from [ get_net_driver $ck_net ] -flat -break_on_bboxes ] {
      if { [ string match "in" [ get_attribute [ get_object_name $pp ] pin_direction ] ] &&
         ! [ string match "*\/CK"  [ get_object_name $pp ] ] &&
         ! [ string match "*\/CKN" [ get_object_name $pp ] ] &&
         ! [ string match "*\/SCK" [ get_object_name $pp ] ] &&
         ! [ string match "*\/DCK" [ get_object_name $pp ] ] } {
          set RTN [ add_to_collection $RTN $pp ]
      }
   }
   return $RTN
} ;# get_connect_non_ck

proc report_type_name { coll } {
## show the cell type of the cells in the collection
   foreach_in_collection pp $coll { puts "\t[ get_attribute $pp ref_name ]\t[ get_object_name $pp ]" }
} ;# report_name

# report_type_name [ get_cells -hier * -filter "ref_name =~ scs8lp_dl*" ]

proc report_all_latch { num } {
#  all_registers -level_sensitive
   set collection_result_display_limit $num
   filter_collection [ get_cells -hier * ] "ref_name =~ LNQ*" ;# for TSMC library
#  filter_collection [ get_cells -hier * ] "ref_name =~ TL*" ;# for faraday library
#  filter_collection [ get_cells -hier * ] "ref_name =~ scs8lp_dl*" ;# HHNEC
#  set collection_result_display_limit 100
} ;# report_all_latch

proc list_col { coll } {
   foreach_in_collection pp $coll { puts "\t[ get_object_name $pp ]" }
   puts [ sizeof_collection $coll ]
}

proc report_lib_cell_by_pin_num { num gt } {
   foreach_in_collection cell [ get_lib_cells scs8lp_ss_1.55v_-40C/* ] {
      set tmp [ sizeof_collection [ get_lib_pins -of_objects $cell ] ]
      if { $gt && $num < $tmp ||
          !$gt && $num == $tmp } {
         query_objects $cell
      }
   }
}

proc ff_trace_back { pin_name start_name condition } {
#  ff_trace_back SA *p_test_enable false
#  return a collection which didn't connect to p_test_enable
   set RTN ""
   set all [ all_registers -edge ]
   foreach_in_collection pp $all {
      set name [ get_object_name $pp ]
      set pins [ get_pins -quiet $name/$pin_name ]
      if { 0 < [ sizeof_collection $pins ] } {
         set tmp [ all_fanin -trace all -flat -start -to $pins ]
         set tmp [ filter_collection $tmp "full_name =~ $start_name" ]
         if { $condition == true  && 0 <  [ sizeof_collection $tmp ] ||
              $condition == false && 0 == [ sizeof_collection $tmp ] } {
            set RTN [ add_to_collection $RTN $pp ]
         }
      } else {
         echo "'$pin_name' not found on '$name'"
      }
   }
   return $RTN
}

proc count_pins { cell } {
   set pins [ get_pins -of $cell ] ; puts "\tnum:\t[sizeof_collection $pins]"
   set pins [ get_pins -of $cell -filter "pin_direction==in" ] ; puts "\tin:\t[sizeof_collection $pins]"
   set pins [ get_pins -of $cell -filter "pin_direction==out" ] ; puts "\tout:\t[sizeof_collection $pins]"
   set pins [ get_pins -of $cell -filter "pin_direction==inout" ] ; puts "\tinout:\t[sizeof_collection $pins]"
}

#  set cells [ filter_collection [ get_cells -hier * ] "is_hierarchical==false and is_black_box==false" ]
proc list_input_floating {} {
   set cells [ filter_collection [ get_cells -hier * ] "is_hierarchical==false" ]
   foreach_in_collection pp $cells {
      puts [ get_object_name $pp ]
      set pins [ filter_collection [ get_pins -of $pp ] "pin_direction == in" ]
      foreach_in_collection ii $pins {
         set trace [ all_connected [ get_nets -of $ii ] -leaf ]
         set outs [ filter_collection $trace "pin_direction == out" ]
         if { 0 < [ sizeof_collection $outs ] } {
            puts "\t[ get_object_name $outs ]"
         } else {
#           puts "\tfloating : [ get_object_name [ get_nets -of $ii ]]"
            puts "\tfloating : [ get_object_name $ii ]"
         }
      }
   }
}

## begin #######################################################################
## fix sdf
proc set_clock_gate_ideal {} {
   foreach_in_collection cg [ all_clock_gates ] {
      set name [ get_object_name $cg ]
      if { [ get_attribute $cg is_hierarchical ] == true } {
         set name [ get_object_name [ get_cells $name/* ]]
      }
      puts [ get_object_name [ get_pins -of $name -filter "is_clock_gate_output_pin==true" ]]
      set_annotated_delay -cell 0 -to   [ get_pins -of $name -filter "is_clock_gate_output_pin==true" ] \
                                  -from [ get_pins -of $name -filter "is_clock_gate_clock_pin==true" ]
   }
} ;# set_clock_gate_ideal
proc set_clock_network_cell_ideal {} {
   report_clocks ;# or 'is_clock_network_cell' false
   foreach_in_collection cg [ get_cells -hier -filter "is_clock_network_cell==true" ] {
      set name [ get_object_name $cg ]
      puts [ get_object_name [ get_pins -of $name -filter "pin_direction==out" ]]
      set_annotated_delay -cell 0 -to   [ get_pins -of $name -filter "pin_direction==out" ] \
                                  -from [ get_pins -of $name -filter "pin_direction==in" ]
   }
} ;# set_clock_network_cell_ideal
## fix sdf
## end #########################################################################

## begin #######################################################################
## fix scan
proc add_iport { iport } {
   create_port $iport -direction in
   create_net  $iport
   connect_net [ get_nets $iport ] [ get_ports $iport ]
} ;# add_iport
   
proc is_string { str } {
## to tell string from collection
   return [ string match {[a-zA-Z]*} $str ]
} ;# is_string
   
proc get_connected_pins { pin_net_port args } {
## { -type all } { -leaf } { -direction all }
   set las ""
   set sw_(-type) all
   set sw_(-leaf) ""
   set sw_(-direction) all
   for {set x 0} {$x<[llength $args]} {incr x} {
      set it [ lindex $args $x ]
      switch -regex -- $it {
         ^-      {
            if { $x==[llength $args]-1 ||
                 $las!="" } { set sw_($las) "_TRUE_" }
            set las $it
         }
         default {
            if { $las=="" } { puts "args WARNING: switch expected" } else { set sw_($las) $it }
            set las ""
         }
      }
   }
## type: ff:      return FF pins
##       none-ff: return none-FF pins
##       all:     return all pins

   set cnn [ get_nets -of $pin_net_port ]
   switch -exact $sw_(-leaf) {
      _TRUE_  { set cnn [ all_connected -leaf $cnn ] }
      default { set cnn [ all_connected       $cnn ] }
   }
   switch -exact $sw_(-direction) {
      "in"    { set cnn [ get_pins -q $cnn -filter "@pin_direction==in" ] }
      "out"   { set cnn [ get_pins -q $cnn -filter "@pin_direction==out" ] }
      "all"   { set cnn [ get_pins -q $cnn ] }
      default { puts "invalid 'direction' value"
                return "" }
   }
   foreach_in_collection chk $cnn {
      if { [ get_attribute -q [ get_cells -of $chk ] ff_edge_sense ] !=1 && $sw_(-type)=="ff" ||
           [ get_attribute -q [ get_cells -of $chk ] ff_edge_sense ] ==1 && $sw_(-type)=="none-ff" } {
         set cnn [ remove_from_collection $cnn $chk ]
      }
   }
   return $cnn
} ;# get_connected_pins

proc fix_scan_boundary_i { iport { scan_clk scan_clk } { scan_mode scan_mode } } {
   set name $iport
   if { ![ is_string $iport ] } {
      set name [ get_object_name $iport ]
   }    
   puts "check port: $name"
   if { [ set ff_pins [ get_connected_pins $iport -type none-ff -direction in -leaf ]] =="" } {
      puts "\tneed not be fixed because of connected to [ get_object_name $ff_pins ]"
      return
   }
   puts "fix port: $name"
## "\t1. create fix_scan_ mux/dff cells (DFQD0BWP7T,MUX2D1BWP7T)"
## "\t2. create fix_scan_ nets for mux out and case1 input"
## "\t3. disconnect the orginal nets, then connect to the mux out"
## "\t4. connect the orginal nets to the mux case0 input (normal mode)"
## "\t5. connect others"
   set org_con [ get_connected_pins $iport -direction in ]
   set org_net [ get_nets -of $iport ]
   set name [ get_object_name $org_net ]
   puts "\tby revising net: $name"
   create_cell fix_scan_$name\_dff_u0 tcb018gbwp7twc/DFQD0BWP7T
   create_cell fix_scan_$name\_mux_u0 tcb018gbwp7twc/MUX2D1BWP7T
   create_net  fix_scan_$name\_mux_z_n0
   create_net  fix_scan_$name\_mux_i1_n0
   disconnect_net $org_net $org_con
      connect_net fix_scan_$name\_mux_z_n0 $org_con
      connect_net fix_scan_$name\_mux_z_n0  fix_scan_$name\_mux_u0/Z
      connect_net [ get_nets $org_net ]     fix_scan_$name\_mux_u0/I0
      connect_net [ get_nets $scan_mode ]   fix_scan_$name\_mux_u0/S
      connect_net fix_scan_$name\_mux_i1_n0 fix_scan_$name\_mux_u0/I1
      connect_net fix_scan_$name\_mux_i1_n0 fix_scan_$name\_dff_u0/Q
      connect_net [ get_nets $scan_clk ]    fix_scan_$name\_dff_u0/CP
#     connect_net [ get_nets -of [ get_ports o_ps_wr ]] fix_scan_$name\_dff_u0/D
} ;# fix_scan_boundary_i

proc get_driving_pin {pin} {
   return [ get_pins -leaf -of [all_connected [get_pins $pin]] -filter {pin_direction =~ *out} ]
}

## fix scan
proc re_connect_pin2net { ipin inet } {
   disconnect_net [ get_nets -of $ipin ] $ipin
      connect_net $inet $ipin
} ;# re_connect_pin2net

## end #########################################################################

   alias r read_file -f verilog
   alias h history
   alias s source
   alias c current_design

