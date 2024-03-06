`timescale 1ns/1ns
module stm_csp;
// ISP via CC
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_csp);
initial timeout_task (1000*80);
reg [15:0] adr;
initial begin
#1	`HW.init_dut_fw;
#100_000
#500_000 // HW checksum lantency
	`UPD.DutsGdCrcSpec = 0; // FW not yet programed PRLTX
	`UPD.SpecRev = 0; // PD2
	`UPD.ExpOrdrs = 5; // SOP"_Debug
	#`UPD.INTERFRAM `UPD.CspR (`MISC,'h08);

	`HW.load_dut_fw ("../fw/int_sim/int_sim.2.memh"); // from CAN1121, wait for reset to start running
	`HW.set_code ('h300,'h34);
	`HW.set_code ('h301,'h12);
	`HW.set_code ('h302,'hff); // suppose the FW is not exceed 384 bytes
	`HW.set_code ('h303,'hff);
	`HW.set_code ('h440,'haa);
	`HW.set_code ('h441,'h55);
	disable fw_ending; // FW completing is not safe

	adr = 'h440;
	#`UPD.INTERFRAM `UPD.CspW (`I2CCTL,'h16); // PG0 writable, at bank3 (XDATA_0180h)
	#`UPD.INTERFRAM `UPD.CspW ('h20,   'h55); // PG0 write
	#`UPD.INTERFRAM `UPD.CspR ('h20,   'h55); // PG0 read

	#`UPD.INTERFRAM `UPD.CspW (`OFS,{16'h8000|adr},1); // csp_mem_w2 {DEC,OFS}
	#`UPD.INTERFRAM `UPD.CspR (`NVMIO,'h55aa,1,1); // csp_io_w2
#100_000
//	#`UPD.INTERFRAM `UPD.CspW (`DEC,'hac);
//	#`UPD.INTERFRAM `UPD.CspW (`FFSTA,'h55); // system reset, start FW
	#`UPD.INTERFRAM `UPD.CspW (`ADR_SRST,'h010101,2,1); // csp_io_w3: soft reset
#100_000 // receiver r_adprx_en
	#`UPD.INTERFRAM `UPD.CspW (`OFS,{16'h8000|adr},1); // csp_mem_w2 {DEC,OFS}
	#`UPD.INTERFRAM `UPD.CspR (`NVMIO,{2{8'hee}},1,1); // csp_io_w2
	// read in wrong mode, OFS won't increase, 8'hee returned

	@(posedge `DUT_CCLK) // wait for FW complete
	while (`DUT_MCU.u_ports.port0!=='hed) @(posedge `DUT_CCLK);
	$display ($time,"ns <%m> NOTE: DUT FW completed");
	`I2CMST.dev_addr = 'h70; // DUT
	`I2CMST.init (2); // 1 MHz
	`I2CMST.sfrw (`I2CCTL,'h19); // inc, BANK12 (a I2C write let I2CCMD not unknown)

	#`UPD.INTERFRAM `UPD.CspW (`MISC,'h0c); // short preamble, hold
	#`UPD.INTERFRAM `UPD.CspR (`TXCTL,{
		64'h0002_xxxx_00e1_0000, // C8(r24): I2CDEVA, I2CEV, I2CBUF
		48'hff80_xxxx_8440,`I2CCTL,8'h00, // C0(r16): ircon, I2CCMD, OFS, DEC
		8'hcx,8'b0000_0xxx,8'hd9,8'h0c, // ircon2, PRLTX(msgid), PRLS, MISC, GPF depends on FW
			  32'h000x_0000, // B8(r08): ien1, ip1, s0relh
		64'h8000_0000_00xx_0000  // B0(r00): NAK of CHA won't be set in Mode0, empty
	},20);

	adr = 'h300;
	#`UPD.INTERFRAM `UPD.CspW (`OFS,{16'h8000|adr},1);
	#`UPD.INTERFRAM `UPD.CspR (`NVMIO,'h1234,1,1);

	#`UPD.INTERFRAM `UPD.CspW (`DEC,'h80 | ('h440>>8));
	#`UPD.INTERFRAM `UPD.CspW (`OFS,'hff &  'h440);
	#`UPD.INTERFRAM `UPD.CspR (`NVMIO,'h55aa,1,1);

	adr = 'h302;
	#`UPD.INTERFRAM `UPD.CspW (`OFS,{16'h8000|adr},1);
	#`UPD.INTERFRAM `UPD.CspW (`MISC,'h08_0008,2,1); // no strech, hold MCU toggle (delay for safe pre-fetch)
	#`UPD.INTERFRAM `UPD.CspW (`X0_NVMCTL,'h80); // set VPP_EN
	#`UPD.INTERFRAM `UPD.CspW (`NVMIO,{8'h12,{2{8'hdd}},8'h34,{2{8'hdd}},8'h56,{2{8'hdd}},8'h78},9,1);
	#`UPD.INTERFRAM `UPD.CspW (`NVMIO,{8'haa,{2{8'hdd}},8'h55,{2{8'hdd}},8'h56,{2{8'hdd}},8'h78},9,1);
	#`UPD.INTERFRAM `UPD.CspW (`X0_NVMCTL,'h00); // clear VPP_EN
	#`UPD.INTERFRAM `UPD.CspR (`OFS,16'h8000|(adr+8),1);
	#`UPD.INTERFRAM `UPD.CspW (`OFS,{16'h8000|adr},1);
	#`UPD.INTERFRAM `UPD.CspR (`NVMIO,'h5678,1,1);

	#1_000_000
	#`UPD.INTERFRAM `UPD.CspW (`DEC,'h7c);
	#`UPD.INTERFRAM `UPD.CspW (`FFSTA,'h55); // system reset

	#600_000
	#200_000 TestDontGdCRC(5,1);
	#200_000 TestDontGdCRC(5,2);
	#200_000 TestDontGdCRC(5,3);
	#200_000 TestDontGdCRC(5,4);
	#200_000 TestDontGdCRC(5,5);
	#600_000

#100_000 // receiver r_adprx_en
	 #`UPD.INTERFRAM `UPD.CspR (`TXCTL,'h00);

	#1_000 hw_complete;
end

   always @(negedge `DUT_CORE.u0_regbank.u0_regE6.mem[3]) begin // CCRX
	#100_000 // after reset
	`DUT_CORE.u0_regbank.u0_regE6.mem[3] =1; // r_adprx_en
	`DUT_CORE.u0_regbank.u0_regE6.mem[1:0] =0; // r_rxdb_opt, reset in some tasks
	$display ($time,"ns <%m> NOTE: r_adprx_en disabled and enabled again");
   end

task TestDontGdCRC ( // don't return auto-GoodCRC
input [3:0] mtype,
input [2:0] target
);
begin
	$display ($time,"ns <%m> starts, %d", target);
	`UPD.SndCmd (.mtyp(mtype),.Wait4GdCRC(1));
	#`UPD.INTERFRAM `USBPB.CC_IDLE.KEEP(1,3);
end
endtask // TestDontGdCRC

endmodule // stm_csp

