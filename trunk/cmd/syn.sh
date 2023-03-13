
#  source ~king/.cshrc
   setenv PJ_NAME can1127
   setenv PJ_PATH ~/project/$PJ_NAME
   setenv DCODE `date +%Y%m%d`
   set sec = `date +%s`
   echo "PJ_PATH = '"$PJ_PATH"'\nDCODE = '"$DCODE"'"
   if ( `pwd` =~ "*work*" ) then #  @ ~/project/can1127/work?
#  which syn2SymDB
#  /mnt/tools/eda_tool/Verdi3/bin/syn2SymDB
#  syn2SymDB ../work1/std_worst.lib
#  dc_shell-xg-t -f ../cmd/gen_db.tcl |& tee gen_db_$DCODE.log
#  grep successfully gen_db_$DCODE.log

   set log = run_syn_${DCODE}.log
   echo `date` --- start syn.tcl					| tee $log
   dc_shell-xg-t -f ../cmd/syn.tcl |& tee ./syn/syn_$DCODE.log

   set grep_0 = "^0|Logic [01][\'is ]* assumed|sensitivity list|multiple driver|No.*equivalent"
   set grep_1 = "|Error:|Can.t |cannot |Unable to |undriven |slack \(VIOLATED.*-[0-9]*\.[0-9]"
   set grep_1 = "$grep_1|Tri-State|Latch|Timing loop"
   grep -E "$grep_0$grep_1" ./syn/syn_$DCODE.log			| tee -a $log
   grep -E "Clock Gating Summary" -A 9 ./syn/syn_$DCODE.log		| tee -a $log
   grep -E "report_area" -A 40 ./syn/syn_$DCODE.log | grep '^Total'	| tee -a $log
   sleep 3

   echo `date` --- start scan.tcl					| tee -a $log
   dc_shell-xg-t -f ../cmd/scan.tcl |& tee ./syn/scan_$DCODE.log
   grep -E "$grep_0$grep_1|test coverage.*%" ./syn/scan_$DCODE.log	| tee -a $log
   grep -E "Scan chain" ./syn/scan_$DCODE.log				| tee -a $log
   grep -E "reg_summary" -A 20 ./syn/scan_$DCODE.log			| tee -a $log
   grep -E "report_area" -A 40 ./syn/scan_$DCODE.log | grep '^Total'	| tee -a $log
#  grep 'CK.*[1-9][0-9]\.[0-9]' ./gate.sdf				| tee -a $log
   sleep 3

#  grep  ' DFF'  ./syn/chiptop_1127a0_0.v  | wc -l
#  grep ' SDFF'  ./syn/chiptop_1127a0_1x.v | wc -l
#  grep ' CLKDL' ./syn/chiptop_1127a0_1x.v | wc -l
   sed '/ATO000/,/;/{N;s/\(\.VSS(\n*\s*\)\S*)/\1)/;t;P;D}'   ./syn/chiptop_1127a0_1x.v | \
   sed '/ATO000/,/;/{N;s/\(\.VDD(\n*\s*\)\S*)/\1)/;t;P;D}' > ./syn/chiptop_1127a0_1.v
   grep -E 'VSS|VDD|VPP|GND'     ./syn/chiptop_1127a0_1.v		| tee -a $log
   grep -E 'VSS *\(|VDD *\(' -A1 ./syn/chiptop_1127a0_1.v		| tee -a $log
   grep -E 'GTECH'               ./syn/chiptop_1127a0_1.v		| tee -a $log
#  sed -n '/^I chain_0\s*0/,/^1$/p' ./syn/scan_$DCODE.log | sed 's/.*\s[0-9]\+\s*\(\S*\).*/\1/' | sed '/^1*$/d'
#  sed 's/VSS(\S*)/VSS()/'  -i ./syn/chiptop_1127a0_2.v
#  sed 's/GND(\S*)/GND()/g' -i ./syn/chiptop_1127a0_2.v
   sleep 3

   echo `date` --- start exist.tcl					| tee -a $log
   dc_shell-xg-t -f ../cmd/exist.tcl |& tee ./syn/exist_$DCODE.log
   grep -E "$grep_0$grep_1" ./syn/exist_$DCODE.log			| tee -a $log

   echo `date` --- start tmax.tcl					| tee -a $log
   tmax -shell ../cmd/tmax.tcl |& tee ./syn/tmax_$DCODE.log
#  grep -E "test coverage.*%" -A 6 -B 11 ./syn/tmax_*.log		| tee -a $log
   grep -E "test coverage.*%"            ./syn/tmax_*.log		| tee -a $log

   sed -i ./syn/atpg*.v \
	-e 's#chiptop_1127a0_test#bench#' \
	-e 's|dut|U0_DUT|'

   echo run.sh time:							| tee -a $log
   expr `date +%s` - $sec						| tee -a $log

## pre-layout
## date code
################################################################################
   if ( "$1" =~ "RELEASE*" ) then
   echo $DCODE $log
   if ( ! -e ../release/$DCODE/ )    mkdir ../release/$DCODE/
   cp -p ./syn/chiptop_1127a0_1.v          ../release/$DCODE/
   cp -p ./syn/chiptop_1127a0.sdc          ../release/$DCODE/
   cp -p ./syn/chiptop_1127a0.scandef      ../release/$DCODE/
   cp -p ../cmd/apr_note.txt               ../release/$DCODE/
   cp -p ../cmd/pt_best.tcl                ../release/$DCODE/
   cp -p ../cmd/pt_wrst.tcl                ../release/$DCODE/
   if ( ! -e ../release/$DCODE/log ) mkdir ../release/$DCODE/log/
   cp -p ./syn/*_$DCODE.log                ../release/$DCODE/log/
   cp -p ./syn/atpg_*                      ../release/$DCODE/log/
   endif
   if ( "$1" =~ "*PRESIM" ) then
   grep '[1-9][0-9]\.' chiptop_1127a0_pre.sdf				| tee -a $log
   pt_shell -f ../cmd/pt_pre.tcl | tee ./syn/pt_pre_$DCODE.log
   ln -sf        ./syn/chiptop_1127a0_2.v     gate.v
   ln -sf            ./chiptop_1127a0_pre.sdf gate.sdf
   ls -l gate.*
   echo `date` --- start do_syn.cmd					| tee -a $log
   lec -nogui -Dofile ../cmd/do_syn.cmd
   lec -nogui -Dofile ../cmd/do_netlist.cmd
   date									| tee -a $log
   endif

## post-layout
## release code, return code
################################################################################
   if ( "$1" == "POSTSIM" ) then
   setenv DCODE `date +%Y%m%d`
   setenv RELC 20230313
   setenv RETC 221110
   setenv RET_PATH ~king/WORK/CAN1127A0_A0571A0/APR_LAYOUT
   echo $RELC $RETC $RET_PATH $DCODE
   ls -ld ${RET_PATH}/*${RETC}.*
   cp -p ${RET_PATH}/USB_OK${RETC}.v        ../release/$RELC/USB_OK${RETC}.v.cp
   cp -p ${RET_PATH}/USB_OK${RETC}.spef     ../release/$RELC/USB_OK${RETC}.spef.cp
#  cp -p ${RET_PATH}/USB_OK${RETC}.spef.min ../release/$RELC/USB_OK${RETC}.spef.min.cp
#  cp -p ${RET_PATH}/USB_OK${RETC}.spef.max ../release/$RELC/USB_OK${RETC}.spef.max.cp

   cat ../release/$RELC/USB_OK${RETC}.v.cp | \
   sed '/ATO000.*U0_CODE_/a, .VSS () , .VDD () , .VDDP (VPP_OTP)' | \
   sed 's/\.VPP_OTP ( 1'"'"'b1/.VPP_OTP ( VPP_OTP/' > ../release/$RELC/USB_OK${RETC}.v.cpx
#  sed '/ATO0004KX8VI150BG33NA U0_CODE_/a, .VSS ( 1'"'"'h0 ) , .VDD ( 1'"'"'h1 ) , .VDDP ( VDDP )' | \
#  sed '/OTP_VDDP_A0 U0_OTP_VDDP/s/\(\.SEL_VDDP\)/.VDDP ( VDDP ) , \1/' | \
#  sed 's/, *\.\(GPIO[78]\) ( [^ ]* )/, .\1 ( \1 )/g' | \
#  sed 's/, *\.\(D[PN]_[AB]\) ( [^ ]* )/, .\1 ( \1 )/g' | \
#  sed '/inout  GPIO6 ;/iinout  DP_A ;'  | sed '/ GPIO6 ,/s/\(GPIO6 *,\)/DP_A , \1/'  | \
#  sed '/inout  GPIO6 ;/iinout  DN_A ;'  | sed '/ GPIO6 ,/s/\(GPIO6 *,\)/DN_A , \1/'  | \
#  sed '/inout  GPIO6 ;/iinout  GPIO7 ;' | sed '/ GPIO6 ,/s/\(GPIO6 *,\)/GPIO7 , \1/' > ../release/$RELC/USB_OK${RETC}.v.cpx

   ln -sf ../release/$RELC/USB_OK${RETC}.v.cpx   gate.v
   lec -nogui -Dofile ../cmd/do_apr.cmd
   ln -sf ../release/$RELC/USB_OK${RETC}.spef.cp spef.lnk
#  ln -sf ../release/$RELC/USB_OK${RETC}.spef.min.cp apr_min.lnk
#  ln -sf ../release/$RELC/USB_OK${RETC}.spef.max.cp apr_max.lnk
   pt_shell -f ../cmd/pt_best.tcl | tee ./syn/pt_best_$DCODE.log
   pt_shell -f ../cmd/pt_wrst.tcl | tee ./syn/pt_wrst_$DCODE.log
   grep -E '^0|Error:|Can.t |cannot |Unable ' ./syn/pt_*${DCODE}.log
   grep '^ *slack' ./syn/pt_*${DCODE}.log
   grep 'Total Power' syn/pt_*
   grep 'ANT ' gate.v | wc -l
   foreach sp ('sp_AND' sp_OR sp_INV sp_SDF sp_ANT 'sp_[A-Z]' sp_)
      echo `grep "$sp" gate.v | wc -l` "\t$sp"
   end

## gate-level simulation (bench_0.v)
   ln -sf ./chiptop_ff.sdf gate.sdf
   ln -sf ./chiptop_ss.sdf gate.sdf
   ls -l ../release/$RELC
   ls -l spef* gate*

## a0eco (20221110)
   lec -nogui -Dofile ../cmd/do_a0eco.cmd

   endif

