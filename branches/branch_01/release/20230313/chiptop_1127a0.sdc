###################################################################

# Created by write_sdc on Mon Mar 13 18:25:17 2023

###################################################################
set sdc_version 2.0

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V       \
-current mA
set_operating_conditions PVT_1P62V_125C -library worst
set_wire_load_mode top
set_max_fanout 10 [current_design]
create_clock [get_pins U0_ANALOG_TOP/OSC_O]  -name CLK  -period 40  -waveform {0 20}
set_clock_uncertainty 0.5  [get_clocks CLK]
create_generated_clock [get_pins U0_CORE/U0_CLK_MUX/Y]  -name MCLK  -source [get_pins U0_ANALOG_TOP/OSC_O]  -divide_by 1
set_clock_uncertainty 0.5  [get_clocks MCLK]
set_false_path   -from [get_ports TST]
set_input_delay -clock MCLK  10  [get_ports TST]
set_input_delay -clock MCLK  10  [get_ports CSP]
set_input_delay -clock MCLK  10  [get_ports CSN]
set_input_delay -clock MCLK  10  [get_ports VFB]
set_input_delay -clock MCLK  10  [get_ports COM]
set_input_delay -clock MCLK  10  [get_ports LG]
set_input_delay -clock MCLK  10  [get_ports SW]
set_input_delay -clock MCLK  10  [get_ports HG]
set_input_delay -clock MCLK  10  [get_ports BST]
set_input_delay -clock MCLK  10  [get_ports GATE]
set_input_delay -clock MCLK  10  [get_ports VDRV]
set_input_delay -clock MCLK  10  [get_ports DP]
set_input_delay -clock MCLK  10  [get_ports DN]
set_input_delay -clock MCLK  10  [get_ports CC1]
set_input_delay -clock MCLK  10  [get_ports CC2]
set_input_delay -clock MCLK  10  [get_ports GPIO_TS]
set_input_delay -clock MCLK  10  [get_ports SCL]
set_input_delay -clock MCLK  10  [get_ports SDA]
set_input_delay -clock MCLK  10  [get_ports GPIO1]
set_input_delay -clock MCLK  10  [get_ports GPIO2]
set_input_delay -clock MCLK  10  [get_ports GPIO3]
set_input_delay -clock MCLK  10  [get_ports GPIO4]
set_input_delay -clock MCLK  10  [get_ports GPIO5]
set_output_delay -clock MCLK  7  [get_ports CSP]
set_output_delay -clock MCLK  7  [get_ports CSN]
set_output_delay -clock MCLK  7  [get_ports VFB]
set_output_delay -clock MCLK  7  [get_ports COM]
set_output_delay -clock MCLK  7  [get_ports LG]
set_output_delay -clock MCLK  7  [get_ports SW]
set_output_delay -clock MCLK  7  [get_ports HG]
set_output_delay -clock MCLK  7  [get_ports BST]
set_output_delay -clock MCLK  7  [get_ports GATE]
set_output_delay -clock MCLK  7  [get_ports VDRV]
set_output_delay -clock MCLK  7  [get_ports DP]
set_output_delay -clock MCLK  7  [get_ports DN]
set_output_delay -clock MCLK  7  [get_ports CC1]
set_output_delay -clock MCLK  7  [get_ports CC2]
set_output_delay -clock MCLK  7  [get_ports GPIO_TS]
set_output_delay -clock MCLK  7  [get_ports SCL]
set_output_delay -clock MCLK  7  [get_ports SDA]
set_output_delay -clock MCLK  7  [get_ports GPIO1]
set_output_delay -clock MCLK  7  [get_ports GPIO2]
set_output_delay -clock MCLK  7  [get_ports GPIO3]
set_output_delay -clock MCLK  7  [get_ports GPIO4]
set_output_delay -clock MCLK  7  [get_ports GPIO5]
set_disable_timing [get_cells U0_CORE/U0_MCK_BUF] -from A -to Y
set_disable_timing [get_cells U0_CORE/U0_TCK_BUF] -from A -to Y
set_disable_timing STX018SIO1P4M_WORST/IOBMURUDA_A1 -from IE -to DI
set_disable_timing STX018SIO1P4M_WORST/IOBMURUDA_A0 -from IE -to DI
set_disable_timing STX018SIO1P4M_WORST/IODMURUDA_A0 -from IE -to DI
