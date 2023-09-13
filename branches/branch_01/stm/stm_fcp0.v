
`timescale 1ns/1ns
module stm_fcp1;
// 1. use I2CMST to program DUT
//   a) let DUT RX ping, then TX ping with DEV-PING-UI
//   b) let DUT TX byte which has a FCPUI-SYNC and DEV-PING-UI data
// Note:
//   1. I2CMST is slow, most timing is not checked
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1);
initial timeout_task (1000*600);

initial begin: main
#10	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
        `I2CMST.init (2); // 1 MHz
	`I2CMST.dev_addr = 'h70;	 
#(1000*50)	
	`I2CMST.sfrw (`FCPSTA,'h7c); // clear all RX status
	#(1000*200) FcpCrcTest (4,0,'h00,{8'h6d,8'h32,8'h2c,8'h0b}); // 4-byte RX
	#(1000*200) FcpCrcTest (4,0,'h6d,{8'h00,8'h32,8'h2c,8'h0b}); // 3-byte TX
	#(1000*200) FcpCrcTest (3,1,'h6d,{      8'h32,8'h2c,8'h0b}); // 3-byte TX
	#(1000*200)
	`I2CMST.sfrw (`DPDNCTL,'h20); // D+ pull-down (SCP_DWN_EN)
	`I2CMST.sfrw (`FCPCTL,'h10); // FCP_EN

        FCPUITest;
	repeat (3) begin
	   FCP_UI = (FCP_UI==160*1000) ? 176*1000
	          : (FCP_UI==176*1000) ? 144*1000 : 160*1000;

           #(3*FCP_UI) FcpAptRx (0,0,0); // Ping //20191128 add let adp_tx_ui update
	   #(3*FCP_UI) FcpAptRx (12,{16'h55ff,
	                             $random,
	                             $random,
	                             16'hcc77},12'b0000_0000_0001);
	   #(3*FCP_UI) FcpDevReset;
	   `I2CMST.sfrr (`FCPSTA,'h40|'bx000_0000); // FCP reset (CAN1112B0/1)
	   `I2CMST.sfrw (`FCPSTA,'h40);

	   #(3*FCP_UI) FcpAptTx (0,0); // Ping
	   #(3*FCP_UI) FcpAptTx (2,'h3355);
	   #(3*FCP_UI) FcpAptTx (2,'h00aa);

	   #(3*FCP_UI) FcpAptRx (0,0,0); // Ping
	   #(3*FCP_UI) FcpAptRx (2,'h5533,0);
	   #(3*FCP_UI) FcpAptRx (2,'h00aa,0);
	   #(3*FCP_UI) FcpAptRx (2,'h01aa,0);
	   #(3*FCP_UI) FcpAptRx (2,'hcc77,0);
	   #(3*FCP_UI) FcpAptRx (1,'h5a,0);
	   #(3*FCP_UI) FcpAptRx (1,'ha5,0);
	   #(3*FCP_UI) FcpAptRx (0,0,0); // Ping

	   #(3*FCP_UI) FcpAptTx (2,'h01aa);
	   #(3*FCP_UI) FcpAptTx (2,'hcc77);
	   #(3*FCP_UI) FcpAptTx (1,'h5a);
	   #(3*FCP_UI) FcpAptTx (1,'ha5);
	   #(3*FCP_UI) FcpAptTx (0,0); // Ping
	end  
           

 
#100000	hw_complete;
end

task FcpCrcTest;
input [4:0] bcnt;
input last;
input [7:0] exp;
input [32*8-1:0] sdat;
reg [7:0] ii;
begin
	$display ($time,"ns <%m> starts.....%0d", bcnt);
	`I2CMST.sfrw (`FCPCTL,'h00); // CRC disable
	`I2CMST.sfrw (`FCPCTL,'h04); // CRC enable
	for (ii=0;ii<bcnt;ii=ii+1) begin
	   if (last && ii==bcnt-1)
	   `I2CMST.sfrw (`FCPCTL,'h0c); // CRC enable/last
	   `I2CMST.sfrw (`FCPCRC,sdat[ii*8+:8]);
	end
	`I2CMST.sfrr (`FCPCRC,exp);
end
endtask // FcpCrcTest

task FCPUITest;
begin 
                FCP_UI=176*1000;
               `I2CMST.sfrw(`FCPTUI,'h80); // UI by User
    #(3*FCP_UI) FcpAptRx (0,0,0);          // Ping let adp_tx_ui update     
	       `I2CMST.sfrr(`FCPTUI,'h90); // check r_tui[7] isn't be change
	       `I2CMST.sfrw(`FCPTUI,'h00);

		FCP_UI=144*1000;
	       `I2CMST.sfrw(`FCPTUI,'h00); // UI by HW
    #(3*FCP_UI) FcpAptRx (0,0,0);          // Ping let adp_tx_ui update
	       `I2CMST.sfrr(`FCPTUI,'h70); // check r_tui[7] isn't be change 
	       `I2CMST.sfrw(`FCPTUI,'h00);
	        FCP_UI=160*1000;
end
endtask // FCPUITest

endmodule // stm_fcp1

