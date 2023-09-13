
module stm_monur;
// TD to send messages and GoodCRC

`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_monur);
initial timeout_task (1000*10);
parameter BAUDRATE = 28800;
tran (`URMST.x_rxd,`BENCH.GPIO2); // by monur.c

initial begin
#1	`URMST.auto_rx = 1;
	`URMST.sergen_set_baud_rate (BAUDRATE, BAUDRATE);
#100	`HW.load_dut_fw ("../fw/monur/monur.1.memh");
#100_000 $display ($time,"ns <%m> starts");
	`URMST.dev_en = 1;
	`BENCH.urmst_connect = 0;
	fork
	   begin
	      #100_000 `UPD.SndCmd (5,0,0,1); // w/o GoodCRC
	      #300_000 `UPD.SndCmd (1,0,0,1); // GoodCRC
	   end
	   begin
	      UartRcv (4,{{2{">"}},16'h0a0d});
	      UartRcv (10,{"5800 =1:",16'h0a0d});
	      UartRcv (10,{"1800 =1:",16'h0a0d});
	   end
	join

	#1_000 hw_complete;
end

task UartRcv;
input [7:0] cnt; // N;
input [8*128-1:0] exp;
reg [7:0] idx;
begin
	for (idx=0;idx<cnt;idx=idx+1)
	   `URMST.sergen_rxd (exp>>(idx*8));
end
endtask // UartRcv

endmodule // stm_monur

