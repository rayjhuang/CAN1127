
`timescale 1ns/100ps
module stm_ccrx;
// UPD controller to send messages, DUT to auto-return GoodCRC
// flip
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_ccrx);
initial timeout_task (1000*100);
initial begin
#1	`HW.init_dut_fw;
#9	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
#99_990	`I2CMST.init (2); // 1MHz
	`I2CMST.dev_addr = 'h70; // to DUT

	$display ($time,"ns <%m> starts");
	`I2CMST.sfrw (`CCRX, 'h48); // enable squelch, adaptive
	`I2CMST.sfrw (`RXCTL,'h01); // enable SOP
	`I2CMST.sfrw (`PRLTX,'haf); // auto TX/RX GoodCRC transmit, Spec=PD3.0
	`UPD.DutsGdCrcSpec = 2; // Spec=PD3.0

	`UPD.SndCmd (3,7,{$random,$random,$random,$random,
				$random,$random,$random,32'h8000_0000}); // BIST Test Data

	TestData_Preamble;
	TestData_Ordrs;
	TestData_CRC32;

	`UPD.SndCmd (3,7,{$random,$random,$random,$random,
				$random,$random,$random,32'h8000_0000}); // BIST Test Data
	`I2CMST.sfrw (`CCCTL,'h01); // select CC2
	`USBCONN.cable_ori = 1; // select CC2
	`UPD.SndCmd (3,7,{$random,$random,$random,$random,
				$random,$random,$random,32'h8000_0000}); // BIST Test Data

	#300_000 hw_complete;
end

task TestData_CRC32;
reg [7:0] ii;
	repeat (16) begin
	   ii = {$random}%32;
	   $display ($time,"ns <%m> starts, crc-err @bit:%0d", ii);
	   #(1000*200) fork
	   `UPD.UPDPHY.tx_packet (1,,,2,$random,,ii); // random SOP Control Message
	   @(`UPD.UPDPHY.tx_packet.crcgen.r_crc32)
	     `UPD.UPDPHY.tx_packet.crcgen.r_crc32 = `UPD.UPDPHY.tx_packet.crcgen.r_crc32 ^ ('h1<<ii);
	   join
	   #`UPD.INTERFRAM `USBPB.CC_IDLE.KEEP (1,2); // no GoodCRC return
	end
endtask // TestData_CRC32

task TestData_Preamble;
reg [7:0] ii;
begin
	$display ($time,"ns <%m> starts");
	for (ii=24;ii<40;ii=ii+1) begin
	   #(1000*200)
	   `UPD.UPDPHY.tx_packet (1,,,2,$random,,ii); // random SOP Control Message
	   #`UPD.INTERFRAM `UPD.RcvChkOrdrs (1,2);
	end
end
endtask // TestData_Preamble

task TestData_Ordrs;
reg [7:0] ii;
begin
	$display ($time,"ns <%m> starts");
	for (ii=0;ii<8;ii=ii+1) begin
	   #(1000*200)
	   `UPD.UPDPHY.tx_packet (ii,,,2,$random); // random Control Message
	   #`UPD.INTERFRAM
	   if (ii==1) `UPD.RcvChkOrdrs (ii,2); // SOP
	         else `USBPB.CC_IDLE.KEEP (1,2); // no GoodCRC return
	end
end
endtask // TestData_Ordrs

endmodule // stm_ccrx

