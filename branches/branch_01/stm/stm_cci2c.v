
`timescale 1ns/1ns
module stm_cci2c;
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*20);

initial begin: main
#10	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0
	wait (!`DUT_MCU.ro) #(1000*500)
	`I2CMST.init (0); // 100KHz, for CC1/CC2 400pF
	`I2CMST.dev_addr = 'h70;
	$display ($time,"ns <%m> starts.....");

//	#(1000*100) `I2CMST.sfrw (`I2CCTL,'h18); // non-inc, BANK12

`ifdef SWAP
`define XTM 'h11
	#(1000*100) `I2CMST.sfrw (`X0_I2CROUT,`XTM); // CCI2C_EN=1, r_cci2c_swap
	#(1000*100) `BENCH.i2c_connect = 4; // swapped CCI2C
`else
`define XTM 'h01
   `ifdef CSP
	`UPD.DutsGdCrcSpec = 0; // FW not yet programed PRLTX
	`UPD.SpecRev = 0; // PD2
	`ifdef SOP
	   `UPD.ExpOrdrs = 1; // SOP
	   #(1000*100) `I2CMST.sfrw (`RXCTL,'h01); // suppose FW turns on SOP listening
	`else
	   `UPD.ExpOrdrs = 5; // SOP"_Debug
	`endif
	`UPD.CspW (`X0_I2CROUT,'h01); // CCI2C_EN=1
   `else
	#(1000*100) `I2CMST.sfrw (`X0_I2CROUT,`XTM); // CCI2C_EN=1
   `endif
	#(1000*100) `BENCH.i2c_connect = 2; // I2CMST-DUT_CCI2C
`endif
	#(1000*100) `BENCH.i2cmst_pullup = 1;
	            `BENCH.cci2c_pullup = 1;
	#(1000*100) `I2CMST.sfrr (`X0_I2CROUT,`XTM);
	            `I2CMST.sfrw (`GPF,'haa);
	            `I2CMST.sfrr (`GPF,'haa);

	#(1000*100) `I2CMST.sfrw (`X0_I2CROUT,'h00); // CCI2C doesn't work in I2C mode even if CC1/2 pullup
	#(1000*100) `BENCH.i2c_connect = 1; // I2CMST-DUT_I2C
	            `I2CMST.sfrw (`GPF,'h55);
	            `I2CMST.sfrr (`GPF,'h55);
	            `I2CMST.sfrr (`X0_XTM,'h00);

	hw_complete;
end

endmodule // stm_cci2c
