
`timescale 1ns/1ns
module stm_pwm;
// general PWM
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*50);

initial begin // to watch the de-bounce
#(1000*1000)
	fork
	begin
	   `DUT_ANA.r_ovp = 1; #(1000*50) `DUT_ANA.r_ovp = 0; #(1000*1000)
	   `DUT_ANA.r_ovp = 1; #(1000*5)  `DUT_ANA.r_ovp = 0; #(1000*1000);
	end
	begin
	   `DUT_ANA.r_scp = 1; #(1000*5)  `DUT_ANA.r_scp = 0; #(1000*1000)
	   `DUT_ANA.r_scp = 1; #(1000*1)  `DUT_ANA.r_scp = 0; #(1000*1000);
	end
	join
end

initial begin
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (3); // 1MHz
	#200_000
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`SRCCTL,'h02); // LG discharge no ack-ed
	`I2CMST.sfrw (`SRCCTL,'h82); // LG discharge

	`I2CMST.sfrw (`GPIO34,'h44); // set OE
	`I2CMST.sfrw (`X0_PWM0,'h80); // PWM0 duty=0
	`I2CMST.sfrw (`X0_PWM1,'hff); // PWM0 duty=127/128
	fork
	GPIO3.KEEP (0,10);
	GPIO4.WAIT (1,1);
	join

	`I2CMST.sfrw (`X0_PWM0,'h8f); // PWM0 duty=15/128
	`I2CMST.sfrw (`X0_PWM1,'ha0); // PWM0 duty=64/128
	fork
	GPIO3.WAIT (1,1);
	GPIO4.WAIT (1,1);
	#(1000*1000*10);
	join

	`I2CMST.sfrw (`X0_PWM0,'h00); // PWM0 off
	`I2CMST.sfrw (`X0_PWM1,'h00); // PWM1 off
	fork
	GPIO3.KEEP (0,5);
	GPIO4.KEEP (0,5);
	join

	#100_000 hw_complete;
end

GPIO3 GPIO3();
GPIO4 GPIO4();

endmodule // stm_pwm

`define PBNAME GPIO3
`define PBSIG (`DUT.`PBNAME)
`include "inc_probe.v"
`define PBNAME GPIO4
`define PBSIG (`DUT.`PBNAME)
`include "inc_probe.v"

