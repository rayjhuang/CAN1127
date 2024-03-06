###################################################################

# Created by write_sdc on Tue Mar 28 18:24:24 2023

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
set_false_path   -from [list [get_pins U0_ANALOG_TOP/LG] [get_pins U0_ANALOG_TOP/HG] [get_pins \
U0_ANALOG_TOP/GATE] [get_pins U0_ANALOG_TOP/RX_DAT] [get_pins                  \
U0_ANALOG_TOP/RX_SQL] [get_pins U0_ANALOG_TOP/COMP_O] [get_pins                \
U0_ANALOG_TOP/V5OCP] [get_pins U0_ANALOG_TOP/RD_DET] [get_pins                 \
U0_ANALOG_TOP/IMP_OSC] [get_pins U0_ANALOG_TOP/DRP_OSC] [get_pins              \
U0_ANALOG_TOP/OCP] [get_pins U0_ANALOG_TOP/SCP] [get_pins U0_ANALOG_TOP/UVP]   \
[get_pins U0_ANALOG_TOP/CC1_DI] [get_pins U0_ANALOG_TOP/CC2_DI] [get_pins      \
U0_ANALOG_TOP/OTPI] [get_pins U0_ANALOG_TOP/OVP] [get_pins                     \
U0_ANALOG_TOP/DN_COMP] [get_pins U0_ANALOG_TOP/DP_COMP] [get_pins              \
U0_ANALOG_TOP/DN_FAULT] [get_pins U0_ANALOG_TOP/OCP_80M] [get_pins             \
U0_ANALOG_TOP/OCP_160M] [get_pins U0_ANALOG_TOP/OPTO1] [get_pins               \
U0_ANALOG_TOP/OPTO2] [get_pins U0_ANALOG_TOP/VPP_OTP] [get_pins                \
U0_ANALOG_TOP/RSTB_5] [get_pins U0_ANALOG_TOP/V1P1] [get_pins                  \
U0_ANALOG_TOP/TS_ANA_P] [get_pins U0_ANALOG_TOP/GP5_ANA_P] [get_pins           \
U0_ANALOG_TOP/GP4_ANA_P] [get_pins U0_ANALOG_TOP/GP3_ANA_P] [get_pins          \
U0_ANALOG_TOP/GP2_ANA_P] [get_pins U0_ANALOG_TOP/GP1_ANA_P]]  -to [list [get_ports CSP] [get_ports CSN] [get_ports VFB] [get_ports COM]     \
[get_ports SW] [get_ports BST] [get_ports VDRV] [get_ports LG] [get_ports HG]  \
[get_ports GATE] [get_ports DP] [get_ports DN] [get_ports CC1] [get_ports CC2] \
[get_ports GPIO_TS] [get_ports SCL] [get_ports SDA] [get_ports GPIO1]          \
[get_ports GPIO2] [get_ports GPIO3] [get_ports GPIO4] [get_ports GPIO5]]
set_false_path   -from [list [get_pins U0_ANALOG_TOP/LG] [get_pins U0_ANALOG_TOP/HG] [get_pins \
U0_ANALOG_TOP/GATE] [get_pins U0_ANALOG_TOP/RX_DAT] [get_pins                  \
U0_ANALOG_TOP/RX_SQL] [get_pins U0_ANALOG_TOP/COMP_O] [get_pins                \
U0_ANALOG_TOP/V5OCP] [get_pins U0_ANALOG_TOP/RD_DET] [get_pins                 \
U0_ANALOG_TOP/IMP_OSC] [get_pins U0_ANALOG_TOP/DRP_OSC] [get_pins              \
U0_ANALOG_TOP/OCP] [get_pins U0_ANALOG_TOP/SCP] [get_pins U0_ANALOG_TOP/UVP]   \
[get_pins U0_ANALOG_TOP/CC1_DI] [get_pins U0_ANALOG_TOP/CC2_DI] [get_pins      \
U0_ANALOG_TOP/OTPI] [get_pins U0_ANALOG_TOP/OVP] [get_pins                     \
U0_ANALOG_TOP/DN_COMP] [get_pins U0_ANALOG_TOP/DP_COMP] [get_pins              \
U0_ANALOG_TOP/DN_FAULT] [get_pins U0_ANALOG_TOP/OCP_80M] [get_pins             \
U0_ANALOG_TOP/OCP_160M] [get_pins U0_ANALOG_TOP/OPTO1] [get_pins               \
U0_ANALOG_TOP/OPTO2] [get_pins U0_ANALOG_TOP/VPP_OTP] [get_pins                \
U0_ANALOG_TOP/RSTB_5] [get_pins U0_ANALOG_TOP/V1P1] [get_pins                  \
U0_ANALOG_TOP/TS_ANA_P] [get_pins U0_ANALOG_TOP/GP5_ANA_P] [get_pins           \
U0_ANALOG_TOP/GP4_ANA_P] [get_pins U0_ANALOG_TOP/GP3_ANA_P] [get_pins          \
U0_ANALOG_TOP/GP2_ANA_P] [get_pins U0_ANALOG_TOP/GP1_ANA_P]]  -to [list [get_pins U0_ANALOG_TOP/BST_SET] [get_pins U0_ANALOG_TOP/DCM_SEL]   \
[get_pins U0_ANALOG_TOP/HGOFF] [get_pins U0_ANALOG_TOP/HGON] [get_pins         \
U0_ANALOG_TOP/LGOFF] [get_pins U0_ANALOG_TOP/LGON] [get_pins                   \
U0_ANALOG_TOP/EN_DRV] [get_pins {U0_ANALOG_TOP/FSW[1]}] [get_pins              \
{U0_ANALOG_TOP/FSW[0]}] [get_pins U0_ANALOG_TOP/EN_OSC] [get_pins              \
U0_ANALOG_TOP/MAXDS] [get_pins U0_ANALOG_TOP/EN_GM] [get_pins                  \
U0_ANALOG_TOP/EN_ODLDO] [get_pins U0_ANALOG_TOP/EN_IBUK] [get_pins             \
U0_ANALOG_TOP/CP_EN] [get_pins U0_ANALOG_TOP/EXT_CP] [get_pins                 \
U0_ANALOG_TOP/INT_CP] [get_pins U0_ANALOG_TOP/ANTI_INRUSH] [get_pins           \
U0_ANALOG_TOP/PWREN_HOLD] [get_pins {U0_ANALOG_TOP/RP_SEL[1]}] [get_pins       \
{U0_ANALOG_TOP/RP_SEL[0]}] [get_pins U0_ANALOG_TOP/RP1_EN] [get_pins           \
U0_ANALOG_TOP/RP2_EN] [get_pins U0_ANALOG_TOP/VCONN1_EN] [get_pins             \
U0_ANALOG_TOP/VCONN2_EN] [get_pins {U0_ANALOG_TOP/SGP[5]}] [get_pins           \
{U0_ANALOG_TOP/SGP[4]}] [get_pins {U0_ANALOG_TOP/SGP[3]}] [get_pins            \
{U0_ANALOG_TOP/SGP[2]}] [get_pins {U0_ANALOG_TOP/SGP[1]}] [get_pins            \
U0_ANALOG_TOP/S20U] [get_pins U0_ANALOG_TOP/S100U] [get_pins                   \
U0_ANALOG_TOP/TX_EN] [get_pins U0_ANALOG_TOP/TX_DAT] [get_pins                 \
U0_ANALOG_TOP/CC_SEL] [get_pins U0_ANALOG_TOP/TRA] [get_pins                   \
U0_ANALOG_TOP/TFA] [get_pins U0_ANALOG_TOP/LSR] [get_pins                      \
U0_ANALOG_TOP/SEL_RX_TH] [get_pins U0_ANALOG_TOP/DAC1_EN] [get_pins            \
U0_ANALOG_TOP/DPDN_SHORT] [get_pins U0_ANALOG_TOP/DP_2V7_EN] [get_pins         \
U0_ANALOG_TOP/DN_2V7_EN] [get_pins U0_ANALOG_TOP/DP_0P6V_EN] [get_pins         \
U0_ANALOG_TOP/DN_0P6V_EN] [get_pins U0_ANALOG_TOP/DP_DWN_EN] [get_pins         \
U0_ANALOG_TOP/DN_DWN_EN] [get_pins {U0_ANALOG_TOP/PWR_I[7]}] [get_pins         \
{U0_ANALOG_TOP/PWR_I[6]}] [get_pins {U0_ANALOG_TOP/PWR_I[5]}] [get_pins        \
{U0_ANALOG_TOP/PWR_I[4]}] [get_pins {U0_ANALOG_TOP/PWR_I[3]}] [get_pins        \
{U0_ANALOG_TOP/PWR_I[2]}] [get_pins {U0_ANALOG_TOP/PWR_I[1]}] [get_pins        \
{U0_ANALOG_TOP/PWR_I[0]}] [get_pins {U0_ANALOG_TOP/DAC3[5]}] [get_pins         \
{U0_ANALOG_TOP/DAC3[4]}] [get_pins {U0_ANALOG_TOP/DAC3[3]}] [get_pins          \
{U0_ANALOG_TOP/DAC3[2]}] [get_pins {U0_ANALOG_TOP/DAC3[1]}] [get_pins          \
{U0_ANALOG_TOP/DAC3[0]}] [get_pins {U0_ANALOG_TOP/DAC1[9]}] [get_pins          \
{U0_ANALOG_TOP/DAC1[8]}] [get_pins {U0_ANALOG_TOP/DAC1[7]}] [get_pins          \
{U0_ANALOG_TOP/DAC1[6]}] [get_pins {U0_ANALOG_TOP/DAC1[5]}] [get_pins          \
{U0_ANALOG_TOP/DAC1[4]}] [get_pins {U0_ANALOG_TOP/DAC1[3]}] [get_pins          \
{U0_ANALOG_TOP/DAC1[2]}] [get_pins {U0_ANALOG_TOP/DAC1[1]}] [get_pins          \
{U0_ANALOG_TOP/DAC1[0]}] [get_pins U0_ANALOG_TOP/CV2] [get_pins                \
U0_ANALOG_TOP/LFOSC_ENB] [get_pins U0_ANALOG_TOP/VO_DISCHG] [get_pins          \
U0_ANALOG_TOP/DISCHG_SEL] [get_pins U0_ANALOG_TOP/OCP_EN] [get_pins            \
U0_ANALOG_TOP/CS_EN] [get_pins U0_ANALOG_TOP/CCI2C_EN] [get_pins               \
U0_ANALOG_TOP/UVP_SEL] [get_pins {U0_ANALOG_TOP/TM[3]}] [get_pins              \
{U0_ANALOG_TOP/TM[2]}] [get_pins {U0_ANALOG_TOP/TM[1]}] [get_pins              \
{U0_ANALOG_TOP/TM[0]}] [get_pins {U0_ANALOG_TOP/DAC0[10]}] [get_pins           \
{U0_ANALOG_TOP/DAC0[9]}] [get_pins {U0_ANALOG_TOP/DAC0[8]}] [get_pins          \
{U0_ANALOG_TOP/DAC0[7]}] [get_pins {U0_ANALOG_TOP/DAC0[6]}] [get_pins          \
{U0_ANALOG_TOP/DAC0[5]}] [get_pins {U0_ANALOG_TOP/DAC0[4]}] [get_pins          \
{U0_ANALOG_TOP/DAC0[3]}] [get_pins {U0_ANALOG_TOP/DAC0[2]}] [get_pins          \
{U0_ANALOG_TOP/DAC0[1]}] [get_pins {U0_ANALOG_TOP/DAC0[0]}] [get_pins          \
U0_ANALOG_TOP/SLEEP] [get_pins U0_ANALOG_TOP/OSC_LOW] [get_pins                \
U0_ANALOG_TOP/OSC_STOP] [get_pins U0_ANALOG_TOP/PWRDN] [get_pins               \
U0_ANALOG_TOP/VPP_ZERO] [get_pins U0_ANALOG_TOP/STB_RP] [get_pins              \
U0_ANALOG_TOP/RD_ENB] [get_pins U0_ANALOG_TOP/LDO3P9V] [get_pins               \
U0_ANALOG_TOP/VPP_SEL] [get_pins U0_ANALOG_TOP/CC1_DOB] [get_pins              \
U0_ANALOG_TOP/CC2_DOB] [get_pins {U0_ANALOG_TOP/OVP_SEL[1]}] [get_pins         \
{U0_ANALOG_TOP/OVP_SEL[0]}] [get_pins U0_ANALOG_TOP/DPDN_VTH] [get_pins        \
U0_ANALOG_TOP/DPDEN] [get_pins U0_ANALOG_TOP/DPDO] [get_pins                   \
U0_ANALOG_TOP/DPIE] [get_pins U0_ANALOG_TOP/DNDEN] [get_pins                   \
U0_ANALOG_TOP/DNDO] [get_pins U0_ANALOG_TOP/DNIE] [get_pins                    \
{U0_ANALOG_TOP/DUMMY_IN[7]}] [get_pins {U0_ANALOG_TOP/DUMMY_IN[6]}] [get_pins  \
{U0_ANALOG_TOP/DUMMY_IN[5]}] [get_pins {U0_ANALOG_TOP/DUMMY_IN[4]}] [get_pins  \
{U0_ANALOG_TOP/DUMMY_IN[3]}] [get_pins {U0_ANALOG_TOP/DUMMY_IN[2]}] [get_pins  \
{U0_ANALOG_TOP/DUMMY_IN[1]}] [get_pins {U0_ANALOG_TOP/DUMMY_IN[0]}] [get_pins  \
U0_ANALOG_TOP/CP_CLKX2] [get_pins U0_ANALOG_TOP/SEL_CONST_OVP] [get_pins       \
U0_ANALOG_TOP/LP_EN] [get_pins U0_ANALOG_TOP/DNCHK_EN] [get_pins               \
U0_ANALOG_TOP/IRP_EN] [get_pins U0_ANALOG_TOP/CCBFEN] [get_pins                \
{U0_ANALOG_TOP/REGTRM[55]}] [get_pins {U0_ANALOG_TOP/REGTRM[54]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[53]}] [get_pins {U0_ANALOG_TOP/REGTRM[52]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[51]}] [get_pins {U0_ANALOG_TOP/REGTRM[50]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[49]}] [get_pins {U0_ANALOG_TOP/REGTRM[48]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[47]}] [get_pins {U0_ANALOG_TOP/REGTRM[46]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[45]}] [get_pins {U0_ANALOG_TOP/REGTRM[44]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[43]}] [get_pins {U0_ANALOG_TOP/REGTRM[42]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[41]}] [get_pins {U0_ANALOG_TOP/REGTRM[40]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[39]}] [get_pins {U0_ANALOG_TOP/REGTRM[38]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[37]}] [get_pins {U0_ANALOG_TOP/REGTRM[36]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[35]}] [get_pins {U0_ANALOG_TOP/REGTRM[34]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[33]}] [get_pins {U0_ANALOG_TOP/REGTRM[32]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[31]}] [get_pins {U0_ANALOG_TOP/REGTRM[30]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[29]}] [get_pins {U0_ANALOG_TOP/REGTRM[28]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[27]}] [get_pins {U0_ANALOG_TOP/REGTRM[26]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[25]}] [get_pins {U0_ANALOG_TOP/REGTRM[24]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[23]}] [get_pins {U0_ANALOG_TOP/REGTRM[22]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[21]}] [get_pins {U0_ANALOG_TOP/REGTRM[20]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[19]}] [get_pins {U0_ANALOG_TOP/REGTRM[18]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[17]}] [get_pins {U0_ANALOG_TOP/REGTRM[16]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[15]}] [get_pins {U0_ANALOG_TOP/REGTRM[14]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[13]}] [get_pins {U0_ANALOG_TOP/REGTRM[12]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[11]}] [get_pins {U0_ANALOG_TOP/REGTRM[10]}] [get_pins    \
{U0_ANALOG_TOP/REGTRM[9]}] [get_pins {U0_ANALOG_TOP/REGTRM[8]}] [get_pins      \
{U0_ANALOG_TOP/REGTRM[7]}] [get_pins {U0_ANALOG_TOP/REGTRM[6]}] [get_pins      \
{U0_ANALOG_TOP/REGTRM[5]}] [get_pins {U0_ANALOG_TOP/REGTRM[4]}] [get_pins      \
{U0_ANALOG_TOP/REGTRM[3]}] [get_pins {U0_ANALOG_TOP/REGTRM[2]}] [get_pins      \
{U0_ANALOG_TOP/REGTRM[1]}] [get_pins {U0_ANALOG_TOP/REGTRM[0]}] [get_pins      \
U0_ANALOG_TOP/AD_HOLD] [get_pins U0_ANALOG_TOP/SEL_CCGAIN] [get_pins           \
U0_ANALOG_TOP/VFB_SW] [get_pins U0_ANALOG_TOP/CPVSEL] [get_pins                \
U0_ANALOG_TOP/CLAMPV_EN] [get_pins U0_ANALOG_TOP/HVNG_CPEN] [get_pins          \
U0_ANALOG_TOP/OCP_SEL] [get_pins U0_ANALOG_TOP/TS_ANA_R] [get_pins             \
U0_ANALOG_TOP/GP5_ANA_R] [get_pins U0_ANALOG_TOP/GP4_ANA_R] [get_pins          \
U0_ANALOG_TOP/GP3_ANA_R] [get_pins U0_ANALOG_TOP/GP2_ANA_R] [get_pins          \
U0_ANALOG_TOP/GP1_ANA_R]]
set_input_delay -clock MCLK  30  [get_ports TST]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/LG]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/HG]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/GATE]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/RX_DAT]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/RX_SQL]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/COMP_O]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/V5OCP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/RD_DET]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/IMP_OSC]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/DRP_OSC]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OCP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/SCP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/UVP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/CC1_DI]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/CC2_DI]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OTPI]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OVP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/DN_COMP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/DP_COMP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/DN_FAULT]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OCP_80M]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OCP_160M]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OPTO1]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/OPTO2]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/VPP_OTP]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/RSTB_5]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/V1P1]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/TS_ANA_P]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/GP5_ANA_P]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/GP4_ANA_P]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/GP3_ANA_P]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/GP2_ANA_P]
set_input_delay -clock MCLK  31  [get_pins U0_ANALOG_TOP/GP1_ANA_P]
set_input_delay -clock MCLK  30  [get_ports CSP]
set_input_delay -clock MCLK  30  [get_ports CSN]
set_input_delay -clock MCLK  30  [get_ports VFB]
set_input_delay -clock MCLK  30  [get_ports COM]
set_input_delay -clock MCLK  30  [get_ports SW]
set_input_delay -clock MCLK  30  [get_ports BST]
set_input_delay -clock MCLK  30  [get_ports VDRV]
set_input_delay -clock MCLK  30  [get_ports DP]
set_input_delay -clock MCLK  30  [get_ports DN]
set_input_delay -clock MCLK  30  [get_ports CC1]
set_input_delay -clock MCLK  30  [get_ports CC2]
set_input_delay -clock MCLK  30  [get_ports GPIO_TS]
set_input_delay -clock MCLK  30  [get_ports SCL]
set_input_delay -clock MCLK  30  [get_ports SDA]
set_input_delay -clock MCLK  30  [get_ports GPIO1]
set_input_delay -clock MCLK  30  [get_ports GPIO2]
set_input_delay -clock MCLK  30  [get_ports GPIO3]
set_input_delay -clock MCLK  30  [get_ports GPIO4]
set_input_delay -clock MCLK  30  [get_ports GPIO5]
set_output_delay -clock MCLK  20  [get_ports CSP]
set_output_delay -clock MCLK  20  [get_ports CSN]
set_output_delay -clock MCLK  20  [get_ports VFB]
set_output_delay -clock MCLK  20  [get_ports COM]
set_output_delay -clock MCLK  20  [get_ports SW]
set_output_delay -clock MCLK  20  [get_ports BST]
set_output_delay -clock MCLK  20  [get_ports VDRV]
set_output_delay -clock MCLK  20  [get_ports LG]
set_output_delay -clock MCLK  20  [get_ports HG]
set_output_delay -clock MCLK  20  [get_ports GATE]
set_output_delay -clock MCLK  20  [get_ports DP]
set_output_delay -clock MCLK  20  [get_ports DN]
set_output_delay -clock MCLK  20  [get_ports CC1]
set_output_delay -clock MCLK  20  [get_ports CC2]
set_output_delay -clock MCLK  20  [get_ports GPIO_TS]
set_output_delay -clock MCLK  20  [get_ports SCL]
set_output_delay -clock MCLK  20  [get_ports SDA]
set_output_delay -clock MCLK  20  [get_ports GPIO1]
set_output_delay -clock MCLK  20  [get_ports GPIO2]
set_output_delay -clock MCLK  20  [get_ports GPIO3]
set_output_delay -clock MCLK  20  [get_ports GPIO4]
set_output_delay -clock MCLK  20  [get_ports GPIO5]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/BST_SET]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DCM_SEL]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/HGOFF]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/HGON]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/LGOFF]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/LGON]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/EN_DRV]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/FSW[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/FSW[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/EN_OSC]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/MAXDS]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/EN_GM]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/EN_ODLDO]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/EN_IBUK]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CP_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/EXT_CP]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/INT_CP]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/ANTI_INRUSH]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/PWREN_HOLD]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/RP_SEL[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/RP_SEL[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/RP1_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/RP2_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/VCONN1_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/VCONN2_EN]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/SGP[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/SGP[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/SGP[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/SGP[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/SGP[1]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/S20U]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/S100U]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/TX_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/TX_DAT]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CC_SEL]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/TRA]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/TFA]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/LSR]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/SEL_RX_TH]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DAC1_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DPDN_SHORT]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DP_2V7_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DN_2V7_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DP_0P6V_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DN_0P6V_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DP_DWN_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DN_DWN_EN]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[7]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[6]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/PWR_I[0]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC3[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC3[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC3[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC3[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC3[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC3[0]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[9]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[8]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[7]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[6]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC1[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CV2]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/LFOSC_ENB]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/VO_DISCHG]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DISCHG_SEL]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/OCP_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CS_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CCI2C_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/UVP_SEL]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/TM[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/TM[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/TM[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/TM[0]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[10]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[9]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[8]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[7]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[6]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DAC0[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/SLEEP]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/OSC_LOW]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/OSC_STOP]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/PWRDN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/VPP_ZERO]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/STB_RP]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/RD_ENB]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/LDO3P9V]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/VPP_SEL]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CC1_DOB]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CC2_DOB]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/OVP_SEL[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/OVP_SEL[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DPDN_VTH]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DPDEN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DPDO]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DPIE]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DNDEN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DNDO]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DNIE]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[7]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[6]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/DUMMY_IN[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CP_CLKX2]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/SEL_CONST_OVP]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/LP_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/DNCHK_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/IRP_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CCBFEN]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[55]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[54]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[53]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[52]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[51]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[50]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[49]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[48]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[47]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[46]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[45]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[44]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[43]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[42]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[41]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[40]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[39]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[38]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[37]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[36]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[35]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[34]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[33]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[32]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[31]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[30]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[29]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[28]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[27]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[26]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[25]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[24]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[23]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[22]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[21]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[20]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[19]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[18]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[17]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[16]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[15]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[14]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[13]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[12]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[11]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[10]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[9]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[8]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[7]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[6]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[5]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[4]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[3]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[2]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[1]}]
set_output_delay -clock MCLK  20  [get_pins {U0_ANALOG_TOP/REGTRM[0]}]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/AD_HOLD]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/SEL_CCGAIN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/VFB_SW]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CPVSEL]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/CLAMPV_EN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/HVNG_CPEN]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/OCP_SEL]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/TS_ANA_R]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/GP5_ANA_R]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/GP4_ANA_R]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/GP3_ANA_R]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/GP2_ANA_R]
set_output_delay -clock MCLK  20  [get_pins U0_ANALOG_TOP/GP1_ANA_R]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_VO10]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_VO20]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_GP1]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_GP2]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_GP3]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_GP4]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_GP5]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_VIN20]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_TS]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_IS]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_CC2]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_CC1]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_CC2_4]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_CC1_4]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_DP]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_DP_3]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_DN]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/CMP_SEL_DN_3]
set_output_delay -clock MCLK  15  [get_pins U0_ANALOG_TOP/AD_RST]
set_disable_timing [get_cells U0_CORE/U0_MCK_BUF] -from A -to Y
set_disable_timing [get_cells U0_CORE/U0_TCK_BUF] -from A -to Y
set_disable_timing [get_cells U0_CORE/U0_BUF_NEG0] -from A -to Y
set_disable_timing [get_cells U0_CORE/U0_BUF_NEG1] -from A -to Y
set_disable_timing [get_cells U0_CORE/U0_BUF_NEG2] -from A -to Y
set_disable_timing STX018SIO1P4M_WORST/IOBMURUDA_A1 -from IE -to DI
set_disable_timing STX018SIO1P4M_WORST/IOBMURUDA_A0 -from IE -to DI
set_disable_timing STX018SIO1P4M_WORST/IODMURUDA_A0 -from IE -to DI
