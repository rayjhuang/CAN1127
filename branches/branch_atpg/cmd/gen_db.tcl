
#  mkdir ~/project/$PJ_NAME/work1
#     cd ~/project/$PJ_NAME/work1
#  mkdir ./work ./syn
#  cp ~/project/can1126/work1/novas.rc .
#  cp ~/project/can1126/work1/.synopsys_dc.setup .
#  cp ~/project/can1126/work1/stm.v       . -l
#  cp ~/project/can1124/work1/std*        . -l
#  cp ~/project/can1124/work1/worst.lib++ . -l
#  cp ~/project/can1124/work1/ATO0008KX8MX180LBX4DA_* .

#  source ~king/.cshrc
   if { [ catch { getenv "PJ_PATH" } msg ] } {
      puts $msg
      exit -1
   }
   set PJ_PATH [ getenv PJ_PATH ]
   enable_write_lib_mode

## standard cell
## link from /mnt/app1/ray/project/lib/mxic/8262A_L18B_STDCELL_V7/20210416_L18B_1.8V_7T/synopsys/1.8v/

## SRAM cells
## copy from CAN1124
## @3/15, copy from z:\RD\Process\MXIC\SRAM\MSL18B_1536X8_RW10TM4_16_20221107.FRAME_No_leak\ 
   read_lib  ${PJ_PATH}/macro/sram/MSL18B_1536X8_RW10TM4_16_20221107_worst_syn.lib
   write_lib -format db -output MSL18B_1536X8_RW10TM4_16_20221107_worst_syn.db MSL18B_1536X8_RW10TM4_16_20221107_worst_syn
   read_lib  ${PJ_PATH}/macro/sram/MSL18B_1536X8_RW10TM4_16_20221107_best_syn.lib
   write_lib -format db -output MSL18B_1536X8_RW10TM4_16_20221107_best_syn.db MSL18B_1536X8_RW10TM4_16_20221107_best_syn

## IO cells
## copy .v and .lib from CAN1124 and modify them for A0/A1 summary
   read_lib  ${PJ_PATH}/macro/STX018SIO1P4M_WORST.lib
   write_lib -format db -output STX018SIO1P4M_WORST.db STX018SIO1P4M_WORST
   read_lib  ${PJ_PATH}/macro/STX018SIO1P4M_BEST.lib
   write_lib -format db -output STX018SIO1P4M_BEST.db STX018SIO1P4M_BEST

## OTP cells
## .db in Z:\RD\Project\CAN1124\Project flow\OTP\Preliminary_Design_Kit_ATO0008KX8MX180LBX4DA_V0_11\Library_Model\v0_2 is too new
## copy from /mnt/app1/ray/project/lib/mxic/8262A_L18B_STDCELL_V7/Preliminary_Design_Kit_ATO0008KX8MX180LBX4DA_V0_11/...lib
## copy from CAN1124

   exit 1

#  mkdir ~/project/$PJ_NAME/worklec
#     cd ~/project/$PJ_NAME/worklec
#     cp ../work1/novas.rc .
#  ln -sf ../work1/syn .
#  ln -sf ../work1/syn/chiptop_1127a0_2.v gate.v
#  ln -sf ../stm/stm_gpio.v stm.v

