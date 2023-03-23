
`timescale 1ns/100ps
module stm_cc_bas;
// UPD controller to send messages, DUT to auto-return GoodCRC
// DUT to send messages, UPD controller to return GoodCRC
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_cc_bas);
initial timeout_task (1000*15);
initial begin
#1	`HW.init_dut_fw;
#9	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
//	`HW.set_hw_chksum;
#99_990	`I2CMST.init (2); // 1MHz
	`I2CMST.dev_addr = 'h70; // to DUT
        
	$display ($time,"ns <%m> starts");
#100_000
	`I2CMST.TxPortRole =0; // 0: DFP/UFP, 1: Cable Plug
	`I2CMST.TxDataRole =0; // should be 0 in SOP'
//	`I2CMST.sfrw (`CMPOPT,'h40); // channel B
	`I2CMST.sfrw (`CCRX, 'h48); // enable squelch, adaptive
	`I2CMST.sfrw (`TXCTL,'h39); // enable preamble/SOP/CRC32/EOP
	`I2CMST.sfrw (`RXCTL,'h01); // enable SOP
	`I2CMST.sfrw (`PRLTX,'haf); // auto TX/RX GoodCRC transmit, Spec=PD3.0
	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, BANK12
	`UPD.DutsGdCrcSpec = 2; // Spec=PD3.0

//	`I2CMST.sfrw (`CMPOPT,'h40); // channel B
	#200_000 fork dut_rcv_n_auto_tx_gdcrc; `UPD.SndCmd (5); join
	#200_000 fork dut_snd_n_auto_rx_gdcrc; `UPD.RcvCmd (5); join

//	`I2CMST.sfrw (`CMPOPT,'h00); // channel A
	#200_000 fork dut_rcv_n_auto_tx_gdcrc; `UPD.SndCmd (5); join
	#200_000 fork dut_snd_n_auto_rx_gdcrc; `UPD.RcvCmd (5); join

	#200_000 VconnOcp;
	#200_000 VconnOnOff;

	#200_000 cc_fortx;
	#300_000 hw_complete;
end

task dut_rcv_n_auto_tx_gdcrc;
begin
	$display ($time,"ns <%m> starts");
	`I2CMST.sfrw (`FFSTA,'h00); // clear FIFO
	`I2CMST.sfrw (`STA0, 'hff); // clear all status
	`I2CMST.sfrw (`STA1, 'hff); // clear all status
	`I2CMST.rddat = 0;
	while (~`I2CMST.rddat[6]) #50000 `I2CMST.sfrr (`STA1,'hxx); // AUTO_TX_GDCRC rcvd
	`I2CMST.sfrr (`STA0,'h0b); // EOP_RCVD/ORDRS_RCVD/CC_LOW
	`I2CMST.sfrr (`STA1,'h47); // AUTOTXGDCRC_SENT/GO_BUSY/GO_IDLE/TX_DONE
	`I2CMST.sfrr (`FFSTA,'h06); // header+crc32
end
endtask // dut_rcv_n_auto_tx_gdcrc

task dut_snd_n_auto_rx_gdcrc;
begin
	$display ($time,"ns <%m> starts");
	`I2CMST.sfrw (`FFSTA,'h00); // clear FIFO
	`I2CMST.sfrw (`STA0, 'hff); // clear all status
	`I2CMST.sfrw (`STA1, 'hff); // clear all status
	`I2CMST.sfrr (`FFCTL,'hxx);
	`I2CMST.sfrw (`FFCTL,'hc0|`I2CMST.rddat); // first/last
	`I2CMST.sfrw (`FFIO, 'ha5); // Ping, DFP, PD3.0
	`I2CMST.sfrw (`FFIO, 'h01); // source
	`I2CMST.rddat = 0;
	while (~`I2CMST.rddat[6]) #50000 `I2CMST.sfrr (`STA0,'hxx); // AUTO_RX_GDCRC rcvd
	`I2CMST.sfrr (`STA0, 'h43); // AUTORXGDCRC_RCVD/ORDRS_RCVD/CC_LOW
	`I2CMST.sfrr (`STA1, 'h17); // FIFO_ACK/GO_BUSY/GO_IDLE/TX_DONE
	`I2CMST.sfrr (`FFSTA,'h80); // empty
end
endtask // dut_snd_n_auto_rx_gdcrc

task VconnOcp;
begin
	$display ($time,"ns <%m> starts");
	`I2CMST.sfrr (`SRCCTL,'h00); // check initial state
	`I2CMST.sfrw (`SRCCTL,'h04); // turn-on VCONN1
	`DUT_ANA.r_v5ocp = 1;        #(1000*10) ChkCC (5000,0);
	`I2CMST.sfrw (`X0_XTM,'h10); #(1000*10) ChkCC (0,0); // gating by value
	`DUT_ANA.r_v5ocp = 0;        #(1000*10) ChkCC (5000,0);
	`I2CMST.sfrw (`X0_XTM,'h00); #(1000*10) ChkCC (5000,0); // not by value
	`I2CMST.sfrw (`PROCTL,'h20); #(1000*10) ChkCC (0,0); // gating by status
	`I2CMST.sfrw (`PROSTA,'h20); #(1000*10) ChkCC (5000,0); // clear the status
	`I2CMST.sfrw (`PROCTL,'h00); #(1000*10) ChkCC (5000,0); // not by status
	`I2CMST.sfrw (`SRCCTL,'h00); #(1000*10) ChkCC (0,0); // turn-off VCONN1
	`I2CMST.sfrw (`SRCCTL,'h08); // turn-on VCONN2
	`DUT_ANA.r_v5ocp = 1;        #(1000*10) ChkCC (0,5000);
	`I2CMST.sfrw (`X0_XTM,'h10); #(1000*10) ChkCC (0,0); // gating by value
	`DUT_ANA.r_v5ocp = 0;        #(1000*10) ChkCC (0,5000);
	`I2CMST.sfrw (`X0_XTM,'h00); #(1000*10) ChkCC (0,5000); // not by value
	`I2CMST.sfrw (`PROCTL,'h20); #(1000*10) ChkCC (0,0); // gating by status
	`I2CMST.sfrw (`PROSTA,'h20); #(1000*10) ChkCC (0,5000); // clear the status
	`I2CMST.sfrw (`PROCTL,'h00); #(1000*10) ChkCC (0,5000); // not by status
	`I2CMST.sfrw (`SRCCTL,'h00); #(1000*10) ChkCC (0,0); // turn-off VCONN2
end
endtask // VconnOcp

task VconnOnOff;
reg [7:0] sav0;
begin
	$display ($time,"ns <%m> starts");
	ChkCC (0,0);
//	`I2CMST.sfrr (`CMPOPT,'hxx); sav0 = `I2CMST.rddat;
//	`I2CMST.sfrw (`CMPOPT,sav0&~'h40); // channel A

	`I2CMST.sfrw (`SRCCTL,'h04); // turn-on VCONN1
	#(1000*10) ChkCC (5000,0);

	`I2CMST.sfrw (`SRCCTL,'h08); // turn-on VCONN2
	#(1000*10) ChkCC (0,5000);

	`I2CMST.sfrw (`SRCCTL,'h00); // turn-off VCONN
//	`I2CMST.sfrw (`CMPOPT,sav0|'h40); // channel B

	`I2CMST.sfrw (`SRCCTL,'h04); // turn-on VCONN1
	#(1000*10) ChkCC (5000,0);

	`I2CMST.sfrw (`SRCCTL,'h08); // turn-on VCONN2
	#(1000*10) ChkCC (0,5000);

	`I2CMST.sfrw (`SRCCTL,'h00); // turn-off VCONN
//	`I2CMST.sfrw (`CMPOPT,sav0); // recover
end
endtask // VconnOnOff

task cc_fortx;
reg [7:0] sav0;
begin 
	$display ($time,"ns <%m> starts");
	ChkCC(0,0);
	repeat (2) begin
	`I2CMST.sfrw (`CCCTL,'h00);	// CC_SEL=0
        `I2CMST.sfrw (`ATM,'h0e);	// TX_EN=1,TX_DAT=1
	#(1000*10) ChkCC(1125,0);	// CC1='H'
	`I2CMST.sfrw (`CCCTL,'h01);	// CC_SEL=1
	#(1000*10) ChkCC(0,1125);	// CC2='H'
        `I2CMST.sfrw (`ATM,'h00);	// TX_EN=1,TX_DAT=1
	#(1000*10) ChkCC(0,0);
	end
end
endtask // cc_fortx

task ChkCC;
input [15:0] cc1a, cc2a;
begin
        `USBPORT.PB.CC1.VAL(cc1a);
        `USBPORT.PB.CC2.VAL(cc2a);
end
endtask // ChkCC

endmodule // stm_cc_bas

