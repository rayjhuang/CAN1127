
module stm_txopt;
// test DUT's packet generator
// UPD controller to check messages / return GoodCRC
// 20210422 copy form CAN1123, modify STA0/1
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_txopt);
initial timeout_task (1000*120);
`define DUT_RX     `DUT_PHY.u0_phyrx
`define DUT_TXDONE `DUT_CORE.u0_regbank.reg04[0]
`define DUT_RX_OK  `DUT_CORE.u0_regbank.reg03[3]
initial begin
#1	`HW.init_dut_fw;
#99	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
//	$readmemh ("../fw/tcode/tcode.20170601", `CODE_CE);
	`I2CMST.dev_addr = 'h70; // to DUT
	#99_900 `I2CMST.init (2); // 1MHz
	#100_000 $display ($time,"ns <%m> starts");
	#100_000 // wait for SYNTHE MCU hold

	easiest_bmc_tx_measurement_after_por;

`ifdef SINGLE_A
`else	`I2CMST.sfrw (`CMPOPT,'h40); // channel B
`endif
	`I2CMST.sfrw (`FFCTL,'h1e); // TX_NUMK=30
	`I2CMST.sfrw (`TXCTL,'h40); // TX_AUTO_K=1
	                            dut_txopt_0 ( 2,'h44); // 2*16*32-bit '01' sequence
	                            dut_txopt_0 (34,'h88); // 34*16*32-bit '0' (150KHz/58ms)
	`I2CMST.sfrw (`FFCTL,'h1f); // TX_NUMK=31
	                            dut_txopt_0 (34,'h44); // 34x16-bit '01' sequence
	`I2CMST.sfrw (`TXCTL,'h00); // TX_AUTO_K=1
	                            dut_txopt_0 (34,'h55); // 34-byte raw data, 34x8-bit '10' sequence
	`I2CMST.sfrw (`FFCTL,'h00); // TX_NUMK=0,TX_ENDK=0,TX_AUTO_*=0
	                            dut_txopt_0 (10,'h34); // 100-bit '01' sequence
	`I2CMST.sfrw (`FFCTL,'h06); // TX_NUMK=6
	                            dut_txopt_0 (4,'haa); // 4-byte raw data, 32-bit '01' sequence
	                            dut_txopt_0 (2,'h0a); // 2-byte raw data (LSB-first)
	`I2CMST.sfrw (`TXCTL,'h40); // TX_AUTO_K=1
	                            dut_txopt_0 (2,'h4b); // RTL miss-considered, 00001000_01010101_... x2 (32-bit)
	                            dut_txopt_0 (2,'ha4); // RTL miss-considered, 01010_10101... x2 (20-bit)
	                            dut_txopt_0 (2,'haf); // 00001... x4
	                            dut_txopt_0 (2,'h44); // BIST Carrier Mode 2 (32-bit)

	`I2CMST.sfrw (`TXCTL,'h40); dut_txopt_hr0 (0); // 6-byte k-coded
	`I2CMST.sfrw (`TXCTL,'h48); dut_txopt_hr0 (1); // 2-byte k-coded, auto-pream
	`I2CMST.sfrw (`TXCTL,'hc0); dut_txopt_ping0; // endk

	`I2CMST.sfrw (`MISC, 'h08); // hold MCU to for standby

	`I2CMST.sfrw (`TXCTL,'h0f); dut_txopt_hr1 (1); // 1-byte k-code auto-Cable-Reset, ending by 01111... x2 (encoded 0x07)
	`I2CMST.sfrw (`TXCTL,'hcf); dut_txopt_hr1 (1); // 1-byte k-code auto-Cable-Reset, only EOP follows
	`I2CMST.sfrw (`TXCTL,'hce); dut_txopt_hr1 (0); // 1-byte k-code auto-Hard-Reset, only EOP follows

fork
	begin
	`I2CMST.sfrw (`STA0, 'hff); // clear RX/TX status to receive new status
	`I2CMST.sfrw (`STA1, 'hff);
	`I2CMST.sfrw (`RXCTL,'h01); // DUT to receive SOP
	`I2CMST.sfrw (`TXCTL,'h39); // enable auto-EOP,-CRC,-preamble,-SOP
	`I2CMST.sfrw (`FFCTL,'h40); // first, numk=0
	`I2CMST.sfrw (`FFIO, 'ha5); // Ping, DFP, spec=2
	`I2CMST.sfrw (`FFCTL,'h80); // last, numk=0
	`I2CMST.sfrw (`FFIO, 'h01); // NDO=0, source
	wait (`DUT_TXDONE) $display ($time,"ns <%m> DUT TX done");
	wait (`DUT_RX_OK) $display ($time,"ns <%m> DUT RX CRC32 OK");
	end
	`UPD.RcvCmd (5); // Ping
join
	`I2CMST.sfrr (`FFCTL,'hxx);
	`I2CMST.sfrw (`FFCTL,'h40|`I2CMST.rddat); // first
	`I2CMST.sfrr (`FFIO, 'h81); // GoodCRC,DROLE=inverse
	`I2CMST.sfrr (`FFIO, 'h00); // NDO=0,PROLE=inverse

	#300_000 hw_complete;
end

task dut_txopt_0;
input [7:0] cnt,dat;	// 8'h34: preamble-like via BMC-BCD-encoded
			// 8'haa: preamble-like '01' sequence via raw-encoded
reg [7:0] sav0;
fork
begin	->ev;
	$display ($time,"ns <%m> starts, %d, %d", cnt, dat);
	#(1000*20)
	if (cnt>0) begin
	   `I2CMST.sfrw (`STA1,'h01); // clear TXDONE status
	   `I2CMST.sfrr (`FFCTL,'hxx); sav0 = `I2CMST.rddat;
	   if (cnt==1)
	      `I2CMST.sfrw (`FFCTL,'hc0|sav0); // first/last
	   else begin
	      `I2CMST.sfrw (`FFCTL,'h40|sav0); `I2CMST.bkwr (`FFIO,cnt-1,{34{dat}}); // first
	      `I2CMST.sfrw (`FFCTL,'h80|sav0); `I2CMST.sfrw (`FFIO,dat); // last
	   end
	   wait (`DUT_TXDONE);
	end
end
join
endtask // dut_txopt_0

task dut_txopt_hr0;
// Hard Reset by no auto-, numk-auto-enc
input auto; // 0/1: 6-byte-k-coded/2-byte-k-coded
fork
begin	->ev;
	$display ($time,"ns <%m> starts, %d", auto);
	#(1000*20)
	`I2CMST.sfrw (`STA1,'h01); // clear TXDONE status
	`I2CMST.sfrr (`FFCTL,'hxx);
	`I2CMST.sfrw (`FFCTL,'h40|`I2CMST.rddat); // first
	if (~auto)
	`I2CMST.bkwr (`FFIO,4,{4{8'h44}}); // 16*4-bit preamble
	`I2CMST.sfrw (`FFIO,'h55); // RST-1, RST-1
	`I2CMST.sfrr (`FFCTL,'hxx);
	`I2CMST.sfrw (`FFCTL,'h80|`I2CMST.rddat); // last
	`I2CMST.sfrw (`FFIO,'h65); // RST-1, RST-2
	wait (`DUT_TXDONE);
end
	`UPD.RcvChkOrdrs (6,3);
join
endtask // dut_txopt_hr0

task dut_txopt_hr1;
// Hard/Cable Reset by auto encoded ordered set
input cr; // 0/1: HR/CR
reg [7:0] lt0;
fork
begin	->ev;
	$display ($time,"ns <%m> starts, %d", cr);
	`I2CMST.sfrw (`STA1,'h31); // clear FF-ACK/NAK, TXDONE status
	`I2CMST.sfrr (`FFCTL,'hxx); lt0 = `I2CMST.rddat;
	`I2CMST.sfrw (`FFCTL,'hc0); // first/last
//	`I2CMST.sfrw (`FFIO,'h07); // K(7) = EOP
	`I2CMST.sfrw (`FFIO,'h00); // zero-payload, added in CAN1110
	wait (`DUT_TXDONE)
	#20_000 `I2CMST.sfrr (`STA1,'bxx01_xxx1); // check FF-ACK/NAK, TXDONE
	`I2CMST.sfrw (`STA1,'h11); // clear FF-ACK, TXDONE
	`I2CMST.sfrw (`FFCTL,lt0); // recover
end
	`UPD.RcvChkOrdrs (cr?7:6,3);
join
endtask // dut_txopt_hr1

task dut_txopt_ping0;
reg [31:0] crc32,dat;
integer idx;
fork
begin
	$display ($time,"ns <%m> starts");
	dat = 'h01a5; // Ping,DFP,PD3,Source
	crc32 = 'hffff_ffff;
	for (idx=0;idx<16;idx=idx+1)
	crc32 = (dat[idx]^crc32[31]) ?crc32<<1 ^ 32'h04c1_1db7 :crc32<<1;
	crc32 = `DUT_PHY.u0_phycrc.crc32_inv_comp (crc32);
	`I2CMST.sfrr (`FFCTL,'hxx);
	`I2CMST.sfrw (`FFCTL,'h40|`I2CMST.rddat); // first
	`I2CMST.sfrw (`STA1,'h01); // clear TXDONE status
	for (idx=0;idx<4;idx=idx+1)
	`I2CMST.sfrw (`FFIO,'h44); // 16*4-bit preamble
	`I2CMST.sfrw (`FFIO,'h11); // Sync-1, Sync-1
	`I2CMST.sfrw (`FFIO,'h21); // Sync-1, Sync-2
	`I2CMST.sfrw (`FFIO,dat[7:0]);
	`I2CMST.sfrw (`FFIO,dat[15:8]);
	`I2CMST.sfrw (`FFIO,crc32[7:0]);
	`I2CMST.sfrw (`FFIO,crc32[15:8]);
	`I2CMST.sfrw (`FFIO,crc32[23:16]);
	`I2CMST.sfrw (`FFIO,crc32[31:24]);
	`I2CMST.sfrr (`FFCTL,'hxx);
	`I2CMST.sfrw (`FFCTL,'h80|`I2CMST.rddat); // last
	`I2CMST.sfrw (`FFIO,'h07); // EOP
	wait (`DUT_TXDONE)
	wait (`DUT_RX.cs_bmni==`DUT_RX.bmni_ord3)
	@(`DUT_RX.cs_bmni) if (`DUT_RX.cs_bmni!==`DUT_RX.bmni_wait) `HW_FIN (($time,"ns <%m> ERROR: DUT should enter WAIT when received un-enabled SOP"))
	@(`DUT_RX.cs_bmni) if (`DUT_RX.cs_bmni!==`DUT_RX.bmni_idle) `HW_FIN (($time,"ns <%m> ERROR: DUT should be IDLE after CC idle"))
	$display ($time,"ns <%m> NOTE: GoodCRC returned successfully");
end
	`UPD.RcvCmd (5); // Ping
join
endtask // dut_txopt_ping0

task easiest_bmc_tx_measurement_after_por;
begin
	$display ($time,"ns <%m> starts");
	`I2CMST.sfrw (`TXCTL,'h40); // TX_AUTO_K
	`I2CMST.sfrw (`FFCTL,'hde); // FIRST/LAST/TX_NUMK=30
	`I2CMST.sfrw (`FFIO,'h99); // 512 clocks @300KHz
	wait (`DUT_TXDONE);
end
endtask // easiest_bmc_tx_measurement_after_por

endmodule // stm_txopt

