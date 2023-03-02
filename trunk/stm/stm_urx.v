`timescale 1ns/1ns
module stm_urx;
// let GPIO1/2 be UART
// UART data received buffered by the FW

`include "stm_task.v"
initial timeout_task (1000*40);
initial #1 $fsdbDumpvars (stm_urx);
parameter BAUDRATE = 28800 * 4;
reg [7:0] idx0, idx1;
initial begin
#10	`URMST.dev_en = 1;
	`URMST.sergen_set_baud_rate (BAUDRATE, BAUDRATE);
	`I2CMST.init (2); // 1 MHz
	`I2CMST.dev_addr = 'h70; // to DUT
	`BENCH.urmst_connect =2; // UART master to GPIO1/2
#100	`HW.load_dut_fw ("../fw/urx/urx.2.memh");
	$display ($time,"ns <%m> starts.....");

	#100_000 // POR
	$display ($time,"ns <%m> starts UART on GPIO1/2");
	`I2CMST.sfrw (`I2CCTL,'h1); // inc
	#1_200_000 // FW initial

	`I2CMST.sfrw (`GPIOSH,'h7e); // UART on GPIO1/2
	fork
	for (idx0="A";idx0<"N";idx0=idx0+1) #(1000*100) `URMST.sergen_txd (idx0,1,0);
	for (idx1="a";idx1<"m";idx1=idx1+1) #(1000*111) UART_TX (idx1);
	join
	`I2CMST.bkrd (0,13,"MLKJIHGFEDCBA"); // page 0

	`BENCH.urmst_connect =4; // UART master to D+/D-
	`DUT_ANA.r_rstz = 0; #1000
	`DUT_ANA.r_rstz = 1;
	#100_000 // POR
	$display ($time,"ns <%m> starts UART on D+/D-");
	`I2CMST.sfrw (`I2CCTL,'h1); // inc
	#1_200_000 // FW initial

	`I2CMST.sfrr (`PWRCTL,'hxx);
	`I2CMST.sfrw (`PWRCTL,`I2CMST.rddat | 'hc0); // UART to D+/D-
	fork
	for (idx0="A";idx0<"N";idx0=idx0+1) #(1000*100) `URMST.sergen_txd (idx0,1,0);
	for (idx1="a";idx1<"m";idx1=idx1+1) #(1000*111) UART_TX (idx1);
	join
	`I2CMST.bkrd (0,13,"MLKJIHGFEDCBA"); // PG0

	hw_complete;
end

`define sfr_rdat `I2CMST.rddat
task UART_TX; // DUT UART TX controlled by I2C
input [7:0] dat;
reg [7:0] tmp;
fork
begin
//	$display ($time,"ns <%m> NOTE: send data: %x", dat);
	`I2CMST.sfrw (`ADR_S0BUF,dat);
	$display ($time,"ns <%m> NOTE: DUT UART transmitted: %x (%c)", dat, dat);
	`sfr_rdat = 0;
	while (~|(`sfr_rdat)) // polling TX flag, FW put it in GPF
	   `I2CMST.sfrr (`GPF,'hxx);
	#(1000*100) tmp = `URMST.rxd_byte;
	if (dat!==tmp) begin
	   $display ($time,"ns <%m> ERROR: data mismatch, exp:%02x, dat:%02x", dat, tmp);
	   $finish;
	end
//	`I2CMST.sfrw (`ADR_S0CON,`sfr_rdat & ~'h02); // clear TX flag, to prevent from entering ISR repeatedly, FW does it
	`I2CMST.sfrw (`GPF,0);
end
begin
	`URMST.sergen_rxd (dat);
end
join
endtask // UART_TX

endmodule // stm_urx

