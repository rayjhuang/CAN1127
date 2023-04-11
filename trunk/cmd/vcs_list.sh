
#  setenv LD_LIBRARY_PATH /mnt/tools/eda_tool/Verdi3/share/PLI/VCS/LINUX64
#  source ~king/.cshrc
   if ( `pwd` !~ "*work*" ) exit # @ ~/project/can11xx/work

   setenv STILDPV_HOME "/mnt/tools/txs/2013.03/amd64/stildpv/lib/"
   set PLI_TXS = "-P ${STILDPV_HOME}stildpv_vcs.tab ${STILDPV_HOME}libstildpv.a"

#  set NOVAS_VCS_PLI = "/mnt/app1/king/.Temp/Verdi3/share/PLI/VCS/LINUX64/"
   set NOVAS_VCS_PLI = "/mnt/tools/verdi/2013.07/share/PLI/VCS/LINUX64/"
   set PLI_NOVAS = "-P ${NOVAS_VCS_PLI}novas.tab ${NOVAS_VCS_PLI}pli.a"
#  setenv LD_LIBRARY_PATH ${NOVAS_VCS_PLI}:${LD_LIBRARY_PATH}

   set VCSOPT = "-full64 +v2k +acc +no_notifier +vcs+lic+wait -notice -R -Mupdate +tetramax"
   set VCSOPT = "${VCSOPT} -q +nowarnTFIPC"
   set VCSOPT = "${VCSOPT} $PLI_NOVAS $PLI_TXS"
   set VCSOPT = "${VCSOPT} +define+tmax_msg=1+tmax_rpt=10"
   set VCSOPT = "${VCSOPT} -timescale=1ns/1ps -negdelay"
#  set VCSOPT = "${VCSOPT} -negdelay"

#  set VCSDUT = "-f ../cmd/bench_0.f ../release/0427/chiptop_1108a0_1.v"
#  set VCSDUT = "-f ../cmd/macro_1.f ./syn_b0/chiptop_1108a0_2.v ../stm/stm_atpg.v"
   set VCSDUT = "-f ../cmd/macro.f ./gate.v ../stm/stm_atpg.v +define+CAN1127A0+EMPTY"

   echo $PJ_PATH $VCSOPT $VCSDUT

   vcs $VCSOPT ./syn/atpg_parallel_stildpv.v     $VCSDUT -l atpg_parallel_max.log +define+MAX+VCD
   vcs $VCSOPT ./syn/atpg_chain_stildpv.v        $VCSDUT -l atpg_chain_max.log    +define+MAX+VCD
   vcs $VCSOPT ./syn/atpg_serial_99+3_stildpv.v  $VCSDUT -l atpg_serial_99+3.log  +define+MAX+VEC_GEN=\"atpg_serial_99+3.vec\"+VCD
   vcs $VCSOPT ./syn/atpg_serial_8_stildpv.v     $VCSDUT -l atpg_serial_8_max.log +define+MAX+VEC_GEN=\"atpg_serial_8.vec\"+VCD
   vcs $VCSOPT ./syn/atpg_serial_stildpv.v       $VCSDUT -l atpg_serial_max.log   +define+MAX+VEC_GEN=\"atpg_serial_max.vec\"

   vcs $VCSOPT ./syn/atpg_parallel_stildpv.v     $VCSDUT -l atpg_parallel_min.log +define+MIN+VCD
   vcs $VCSOPT ./syn/atpg_chain_stildpv.v        $VCSDUT -l atpg_chain_min.log    +define+MIN+VCD
   vcs $VCSOPT ./syn/atpg_serial_99+3_stildpv.v  $VCSDUT -l atpg_serial_99+3.log  +define+MIN+VEC_GEN=\"atpg_serial_99+3.vec\"+VCD
   vcs $VCSOPT ./syn/atpg_serial_8_stildpv.v     $VCSDUT -l atpg_serial_8_min.log +define+MIN+VEC_GEN=\"atpg_serial_8.vec\"+VCD
   vcs $VCSOPT ./syn/atpg_serial_stildpv.v       $VCSDUT -l atpg_serial_min.log   +define+MIN+VEC_GEN=\"atpg_serial_min.vec\"
#  vcs $VCSOPT ./syn/atpg_serial_stildpv.v       $VCSDUT -l atpg_serial+SF0.log   +define+MIN+SF0
#  vcs $VCSOPT ./syn/atpg_iddq_stildpv.v         $VCSDUT -l atpg_iddq.log         +define+MIN+VEC_GEN=\"atpg_iddq.vec\"+VCD

   vcs $VCSOPT ./syn/atpg_serial_836+3_stildpv.v $VCSDUT -l atpg_serial_836+3.log +define+MAX+VEC_GEN=\"atpg_serial_836+3.vec\"+VCD
   vcs $VCSOPT ./syn/atpg_serial_836+3_stildpv.v $VCSDUT -l atpg_serial_836+3.log +define+MIN+VEC_GEN=\"atpg_serial_836+3.vec\"+VCD
   diff ../workmin/atpg_serial_836+3.vec ../work1/atpg_serial_836+3.vec

   vfast -ft verilog bench_a.vcd
#  mv bench_a.vcd.fsdb atpg_serial_99+3_gen.vcd.fsdb
#  mv bench_a.vcd.fsdb atpg_serial_99+3_ver.vcd.fsdb

   grep -H 'simulation .* completed' atpg_*.log
   grep 'patterns completed' atpg_*.log
   grep -E "expected to be|End of STIL" atpg_*.log | grep -v 'to be Z'
   grep 'Signal .* expected' atpg_* | grep -v 'expected to be Z'

   diff ../workmin/atpg_serial_99+3.vec  ../work1/
   diff ../workmin/atpg_serial_8.vec     ../work1/
   diff ../workmin/atpg_serial_min.vec   ../work1/atpg_serial_max.vec
   sed 's/^P.*\t/\t/' ../workmin/atpg_serial_min.vec > ../release/$RELC/atpg_serial_${DCODE}.sd

   vcs $VCSOPT $VCSDUT -l atpg_serial_99+3_ver.log +define+GATE+MIN+VEC_VER=\"atpg_serial_99+3.vec\"+VCD
   vcs $VCSOPT $VCSDUT -l atpg_serial_99+3_ver.log +define+GATE+MAX+VEC_VER=\"atpg_serial_99+3.vec\"+VCD
   vcs $VCSOPT $VCSDUT -l atpg_serial_8_ver.log    +define+GATE+MIN+VEC_VER=\"atpg_serial_8.vec\"+VCD
   vcs $VCSOPT $VCSDUT -l atpg_serial_8_ver.log    +define+GATE+MAX+VEC_VER=\"atpg_serial_8.vec\"+VCD
   vcs $VCSOPT $VCSDUT -l atpg_serial_ver_min.log  +define+GATE+MIN+VEC_VER=\"atpg_serial_min.vec\"
   vcs $VCSOPT $VCSDUT -l atpg_serial_ver_max.log  +define+GATE+MAX+VEC_VER=\"atpg_serial_max.vec\"

   set VCSDUT = "-f ../cmd/macro.f ./gate.v -f ../cmd/bench.f $HWREV +define+CAN1127A0"
   vcs $VCSOPT $VCSDUT ../stm/stm_sfr.v -l stm_sfr+GATE.log +define+GATE+VCD -v2005 +systemverilogext+sv
   vfast -ft verilog bench_g.vcd

#  set NCDUT = "$VCSDUT"
#  ncverilog $NCOPT $NCDUT -l atpg_serial_99+3_ver.log +define+FSDB+GATE+MIN+VEC_VER=\"atpg_serial_99+3.vec\"
#  ncverilog $NCOPT $NCDUT -l atpg_serial_ver.log           +define+GATE+MIN+VEC_VER=\"atpg_serial.vec\"

