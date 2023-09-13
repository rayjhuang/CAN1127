`timescale 1ns/1ns
module stm_uart_txrx;
// let GPIO1/2 be UART
// UART data received buffered by the FW

`include "stm_task.v"
initial timeout_task (1000*50);
initial #1 $fsdbDumpvars (stm_uart_txrx);
parameter BAUDRATE = `BAUD; // stm_list.sh assigned
parameter FW_BAUD = 115200; // by uart_txrx.2.memh
initial begin
#10	`I2CMST.init (2); // 1 MHz
	`I2CMST.dev_addr = 'h70; // to DUT
	`URMST.dev_en = 1;
#100	`HW.load_dut_fw ("../fw/uart_txrx/uart_txrx.2.memh");
	$display ($time,"ns <%m> starts.....");

	`URMST.sergen_set_baud_rate (FW_BAUD, FW_BAUD);

	`BENCH.urmst_connect =4; // initially D+/D- by the FW (DUT's TX/RX)
	#1000 wait (`URMST.x_rxd==1) #100 RxPrompt; // FW initial to prompt on D+/D-
	#1_200_000 // FW initial
	`BENCH.urmst_connect =2; // UART master to GPIO1/2 (DUT's TX/RX)
	$display ($time,"ns <%m> starts UART master on GPIO1/2");
	`I2CMST.sfrw (`GPIOSH,'h7e); // UART on GPIO1/2
	`I2CMST.sfrw (`PWRCTL,'h00); // disable UART to D+/D-
	TestUartTxRx;

	`DUT_ANA.r_rstz = 0; #1000
	`DUT_ANA.r_rstz = 1;

	`BENCH.urmst_connect =4; // UART master to D+/D-
	#1000 wait (`URMST.x_rxd==1) #100 RxPrompt; // FW initial to prompt on D+/D-
	#2_500_000 // more FW initial
//	`I2CMST.sfrr (`PWRCTL,'hxx);
//	`I2CMST.sfrw (`PWRCTL,`I2CMST.rddat | 'hc0); // UART to D+/D-
	$display ($time,"ns <%m> starts UART master on D+/D-");
	if (FW_BAUD!=BAUDRATE) begin
	`URMST.sergen_set_baud_rate (BAUDRATE, BAUDRATE);
//	if (BAUDRATE==115200)`I2CMST.sfrw (`ADR_S0RELL,256-13);
	if (BAUDRATE==57600) `I2CMST.sfrw (`ADR_S0RELL,-26);
	if (BAUDRATE==38400) `I2CMST.sfrw (`ADR_S0RELL,-39);
	if (BAUDRATE==19200) `I2CMST.sfrw (`ADR_S0RELL,-78);
	end
	TestUartTxRx;
	#1_000_000
	`BENCH.urmst_connect =8; // UART master to D-/D+
	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, PG0=BNK12 (REGX)
	`I2CMST.sfrw (`X0_I2CROUT,'ha0); // force update r_dpdm_swap
	$display ($time,"ns <%m> starts UART master on D-/D+");
	TestUartTxRx;

	hw_complete;
end

task TestUartTxRx;
reg [7:0] idx0;
begin
	`I2CMST.sfrw (`I2CCTL,'h1); // inc

	for (idx0="A";idx0<"N";idx0=idx0+1) #(1000*100) `URMST.sergen_txd (idx0,1,0);
	`I2CMST.bkrd (0,13,"MLKJIHGFEDCBA"); // PG0

	`URMST.sergen_txd (13,1,0); // [Enter]
	for (idx0="A";idx0<"N";idx0=idx0+1) `URMST.sergen_rxd (idx0);
	RxPrompt;
end
endtask // TestUartTxRx

task RxPrompt;
begin
	`URMST.sergen_rxd ('h0d); // CR
	`URMST.sergen_rxd ('h0a); // LF
	`URMST.sergen_rxd (":");
	$display ($time,"ns <%m> prompt received");
end
endtask // RxPrompt

endmodule // stm_uart_txrx

