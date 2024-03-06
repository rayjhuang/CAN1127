
`timescale 1ns/1ns
module stm_sdischg;
// test the soft discharge
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*20);

initial begin
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (1); // 400KHz
	$display ($time,"ns <%m> starts.....");
	#200_000
	`I2CMST.sfrr (`SRCCTL,'h00); VBUS_DISCHG.VAL(0);

	`I2CMST.sfrr (`X0_SDISCHG,'h00);
	$display ($time,"ns <%m> basic discharge.....");
	`I2CMST.sfrw (`SRCCTL,'h00); VBUS_DISCHG.VAL(0);
	`I2CMST.sfrw (`SRCCTL,'h10); VBUS_DISCHG.VAL(1);
	`I2CMST.sfrw (`SRCCTL,'h10); VBUS_DISCHG.VAL(1);
	`I2CMST.sfrw (`SRCCTL,'h00); VBUS_DISCHG.VAL(0);

	otpi_chk;

	duty_chk (0,1,1); // VBUS_DISCHG 2/32
	duty_chk (0,1,2); // VIN/VBUS_DISCHG 3/32
	duty_chk (0,0,2); // basic discharge
	duty_chk (0,1,30); // VIN/VBUS_DISCHG 31/32
	duty_chk (0,0,20); // VIN 21/32
	duty_chk (0,1,31); // VBUS 32/32

	#100_000 hw_complete;
end

task otpi_chk;
begin
	$display ($time,"ns <%m> starts.....");
	fork
	   VBUS_DISCHG.KEEP(0,2);
	   repeat (100) begin #5000 `DUT_ANA.r_otpi=1; #5000 `DUT_ANA.r_otpi=0; end
	join
	`I2CMST.sfrw (`LDBPRO,'h40); // otpi_gate
	repeat (4) begin
	   #5000 `DUT_ANA.r_otpi=1;
	   #4700 VBUS_DISCHG.VAL(0);
	   #5000 `DUT_ANA.r_otpi=0;
	   #4700 VBUS_DISCHG.VAL(0);
	end
	#(1000*100)
	`I2CMST.sfrw (`SRCCTL,'h10); // VBUS_DISCHG
	fork
	   begin
	      repeat (100) @(negedge `DUT_ANA.VO_DISCHG);
	      $display ($time,"ns <%m> VBUS gated 100 times");
	   end
	   repeat (100) begin #6000 `DUT_ANA.r_otpi=1; #3330 `DUT_ANA.r_otpi=0; end
	join
end
endtask // otpi_chk

task duty_chk;
input vin_dis, vbus_dis;
input [4:0] duty;
begin
	$write ($time,"ns <%m> VIN discharge"); if (vin_dis) $write (" %0d/32",1+duty);
	$write (", VBUS discharge"); if (vbus_dis) $write (" %0d/32",1+duty);
	$display ();

	`I2CMST.sfrw (`X0_SDISCHG,8'h0|duty|vin_dis<<5|vbus_dis<<6);
	`I2CMST.sfrw (`SRCCTL,'h10);
	fork: duty_chk_fork
	   #(1000*1000*2)
	      `HW_FIN (($time,"ns <%m> ERROR: discharge pulse timeout"))
	   begin
	      fork
	         if (vbus_dis && duty!=31) begin
	            VBUS_DISCHG.WAIT(1,1);
	            VBUS_DISCHG.WAIT(0,1); // the first pulse may be a glitch
	            repeat (3) begin
	               VBUS_DISCHG.WAIT(1,1); #(1000*(10*(duty+1)-1)) // 1us before
	               VBUS_DISCHG.VAL(1); #2000 // 1us after
	               VBUS_DISCHG.VAL(0);
	            end
	         end else
	            VBUS_DISCHG.KEEP(1,1);
//	         if (vin_dis && duty!=31) begin
//	            VIN_DISCHG.WAIT(1,1);
//	            VIN_DISCHG.WAIT(0,1);
//	            repeat (3) begin
//	               VIN_DISCHG.WAIT(1,1); #(1000*(10*(duty+1)-1))
//	               VIN_DISCHG.VAL(1); #2000
//	               VIN_DISCHG.VAL(0);
//	            end
//	         end else
//	            VIN_DISCHG.KEEP(1,1);
	      join
	      disable duty_chk_fork;
	   end
	join
	`I2CMST.sfrw (`SRCCTL,'h00);
	`I2CMST.sfrw (`X0_SDISCHG,'h00);
//	VIN_DISCHG.VAL(0);
	VBUS_DISCHG.VAL(0);
end
endtask // duty_chk

dig_probe VBUS_DISCHG (`DUT_ANA.VO_DISCHG);

endmodule // stm_sdischg

