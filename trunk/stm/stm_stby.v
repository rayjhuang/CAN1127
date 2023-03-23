
`timescale 1ns/1ns
module stm_stby;
// stand-by mode
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*30);

initial begin
//#1	`HW.init_dut_fw;
#1	`HW.load_dut_fw ("../fw/iram/iram.1.memh");
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (3); // 1MHz
	#200_000
	$display ($time,"ns <%m> starts.....");
//	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, PG0=BNK12 (REGX)
	ideal_standby (0); // ideal
	ideal_standby (1); // also wake-up OSC_LOW
	#100_000 hw_complete;
end

task wkup_low_standby; // wake-up OSC_LOW as well
begin
	$display ($time,"ns <%m> starts.....");
end
endtask // wkup_low_standby

task ideal_standby;
input wkup_low;
begin
	$display ($time,"ns <%m> starts.....%s",wkup_low?"wakeup-to-100KHz":"wakeup-to-12MHz");
	// OSCCTL
	// {wkup_by_stbov, wkup_by_rddet, wkup_low, OCDRV_ENZ,
	//                         PWRDN, owc_gate, OSC_LOW, OSC_STOP}
	`I2CMST.sfrw (`X0_NVMCTL,'h48); // vpp0v_en
	`I2CMST.sfrw (`OSCCTL,'h02); // OSC_LOW
	`HW.PB.OSC_LOW.WAIT (1,1);
//	`I2CMST.init (100_000);
//	w/ a long 'Start' to be detected
//	simulate the procedure of FW (entering)
	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.sfrw (`PWR_V, 'h00); // suppress PWR_V for primary side
	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.sfrw (`OSCCTL,'h12); // OCDRV_ENZ
	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.sfrw (`PWR_V, 'h1f); // resume PWR_V for ideal value at wakeup
	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.sfrw (`OSCCTL,'hdf|wkup_low<<5);
	#100_000 repeat (10) begin // wakeup by RD_DET
	`USBCONN.Rpu1 = 4700; #({$random}%10000+30)
	`USBCONN.Rpu1 = 0;    #({$random}%10000+30);
	end

	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.bkwr (`PWR_V,2,{8'h1f,8'h00}); // PWR_V pulse for wakeup primary side
	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.sfrr (`OSCCTL,wkup_low?'he0:'hc2);
	#1000 `I2CMST.sdo=0; #50_000; `I2CMST.sfrw (`OSCCTL,'h00);
	`I2CMST.sfrr (`X0_NVMCTL,'h48); // vpp0v_en
end
endtask // ideal_standby	

endmodule // stm_stby

