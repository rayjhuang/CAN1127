
// on-chip macro
// =============================================================================
   -v ${PJ_PATH}/macro/std.v
      ${PJ_PATH}/macro/anatop_1127a0.v
//    ${PJ_PATH}/macro/anatop_1127a0_empty.v // to verify the independency in ATPG
      ${PJ_PATH}/macro/bhv_cc_rcver.v
      ${PJ_PATH}/macro/bhv_compm_mux.v
   -v ${PJ_PATH}/macro/io_udp.v
   -v ${PJ_PATH}/macro/io.v
   +incdir+${PJ_PATH}/macro/
   -v ${PJ_PATH}/macro/ATO0008KX8MX180LBX4DA.v
   -v ${PJ_PATH}/macro/sram/MSL18B_1536X8_RW10TM4_16_20210603_SS.v

   -v ${PJ_PATH}/fpga/softmacro.v
   -v ${PJ_PATH}/fpga/ATO0008KX8VI150BG33NA_FPGA.v

