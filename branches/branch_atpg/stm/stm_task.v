
`include "def_bench.v"

event ev;

`ifdef GATE
`else
task release_m51;
begin
	release `DUT_MCU.sfrwe_s;
	release `DUT_MCU.sfroe_s;
	release `DUT_MCU.sfraddr;
	release `DUT_MCU.sfrdatao;
	release {`DUT_MCU.mempsrd_comb,`DUT_MCU.mempsrd,`DUT_CORE.hit_ps};
	release {`DUT_MCU.memwr_comb,`DUT_MCU.memwr};
	release {`DUT_MCU.memrd_comb,`DUT_MCU.memrd};
	release {`DUT_MCU.memaddr_comb,`DUT_MCU.memaddr};
	release {`DUT_MCU.memdatao_comb,`DUT_MCU.memdatao};
	$display ($time,"ns <%m> release DUT_MCU");
end
endtask // release_m51

task force_m51;
begin
	force `DUT_MCU.sfrwe_s       = `M51.sfr_w; // to access internal SFR
	force `DUT_MCU.sfroe_s       = `M51.sfr_r;
	force `DUT_MCU.sfraddr       = `M51.sfr_addr;
	force `DUT_MCU.sfrdatao      = `M51.sfr_wdat;
	force `DUT_MCU.mempsrd_comb  = 'h0;
	force `DUT_MCU.mempsrd       = 'h0;
	force `DUT_CORE.hit_ps       = 'h1;
	force `DUT_MCU.memwr_comb    = `M51.mem_w;
	force `DUT_MCU.memwr         = `M51.memwr_d;
	force `DUT_MCU.memrd_comb    = `M51.mem_r;
	force `DUT_MCU.memrd         = `M51.memrd_d;
	force `DUT_MCU.memaddr_comb  = `M51.mem_addr;
	force `DUT_MCU.memaddr       = `M51.mem_addr_d;
	force `DUT_MCU.memdatao_comb = `M51.mem_wdat;
	force `DUT_MCU.memdatao      = `M51.mem_wdat_d;
	$display ($time,"ns <%m> start to force DUT_MCU");
end
endtask // force_m51
`endif // GATE

`ifdef FPGA
initial #100 {`MON51_C[0],`MON51_C[1],`MON51_C[2]} = 'h020000; // 0000:020200 - LJMP addr16
`endif

task hw_complete;
   `HW_FIN (($time,"ns <%m> NOTE: simulation completed by HW"))
endtask // hw_complete

initial fork: fw_ending
   forever @(posedge `DUT_CCLK) if (`DUT_MCU.port0o==='hed) `HW_FIN (($time,"ns <%m> NOTE: simulation completed by DUT FW"))
   forever @(posedge `DUT_CCLK) if (`DUT_MCU.port0o==='hee) `HW_FIN (($time,"ns <%m> ERROR: simulation failed by DUT FW"))
   forever @(`DUT_MCU.u_ports.port0) $display ($time,"ns <%m> NOTE: DUT P0-report: %x",`DUT_MCU.u_ports.port0);
join // fw_ending

reg [8*80-1:0] TimeStampMsg ="";
always #(1000*1000*10) $display ($time/1000,"us <%m> NOTE: time stamp%0s", TimeStampMsg);
always #(1000*1000*10) $fsdbDumpflush;

`ifdef T1000	initial #0 timeout_task (1000*1000);
`elsif T500	initial #0 timeout_task (1000*500);
`elsif T100	initial #0 timeout_task (1000*100);
`elsif T10	initial #0 timeout_task (1000*10);
`endif // for stm_fw.v
task timeout_task;
input [31:0] to; // us
begin
   $display ($time,"ns <%m> simulation timeout timer: %0d", to);
   #(1000*to); // time to time out
   `HW_FIN (($time,"ns <%m> ERROR: simulation failed by timeout"))
end
endtask // timeout_task
reg [15:0] timeout_timer; // ms
event ev_timeout_reset;
always @ev_timeout_reset timeout_task (1000*timeout_timer);
task ReTimeout;
input [15:0] to; // ms
begin
	disable timeout_task;
	timeout_timer = to;
	->ev_timeout_reset;
end
endtask // ReTimeout

