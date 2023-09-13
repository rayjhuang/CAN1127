
`timescale 1ns/1ns
module stm_osc;
// HW checksum ok
// low-freq/wake-up w/o FW
//    1. I2CMST to set OSC_LOW and cannot waked-up by short SCL pulses
//       to wake-up by a 50us SCL pulse
//    2. UPD to set OSC_LOW
`include "stm_task.v"
initial #1 $fsdbDumpvars (stm_osc);
initial timeout_task (1000*100);

initial begin
#1	`HW.init_dut_fw;
#2	`HW.set_code(0,'h80);
	`HW.set_code(1,'hfe); // SJMP -2 @PC=0x0000

	#999_997 $display ($time,"ns <%m> starts");
	`I2CMST.init (2); // 1MHz
`ifdef SINGLE_A
`else	`I2CMST.sfrw (`CMPOPT,'h40); // Channel B
`endif
	`I2CMST.sfrw (`RXCTL,'h01); // ORDRS_EN[0]
	`I2CMST.sfrw (`PRLTX,'h80); // AUTOTXGCRC

`ifdef FPGA
	$display ($time,"ns <%m> no low-frequency mode in FPGA for MON51 communication");
	`UPD.DutsGdCrcSpec = 0; // not yet programmed
`else
#20000	`I2CMST.sfrw (`OSCCTL,'h02); // OSC_LOW

#10000	$display ($time,"ns <%m> manually generate a NAK cycle");
	`I2CMST._tx_s;
	`I2CMST._txrx (7,{`I2CMST.dev_addr,1'h0});
	`I2CMST._txrx_ack (1,1); // NAK
	`I2CMST._tx_p;
	`HW.PB.OSC_LOW.VAL(1);
#(1000*200)
//#10000	force `I2CMST.SCK = 0; // wake up temporarily by I2C, and I2C won't be idle until STOP
//#50000	release `I2CMST.SCK;
        #10000 wake_up_by_i2c (`GPF,'h55);
        #50000 wake_up_by_i2c (`OSCCTL,'h00);
	#50000 `I2CMST.sfrr (`GPF,'h55);

#(1000*200)
	`I2CMST.sfrw (`OSCCTL,'h00); // OSC_LOW 1->0
	`I2CMST.sfrw (`DEC,'h7c); // ACK
	`I2CMST.sfrw (`FFSTA,'hc8); // PHY reset (2T)

	`UPD.DutsGdCrcSpec = 0; // not yet programmed
//	`UPD.ExpOrdrs = 5; // SOP"_Debug
	#(1000*500) `UPD.CspW (`OSCCTL,'h02); // OSC_LOW
	`HW.PB.OSC_LOW.WAIT (1,1);
`endif
	#(1000*400) `UPD.CspW (`ADR_SRST,'h010101,2,1); // software reset fail w/o hold
	#(1000*200) `UPD.CspW (`MISC,'h08); // hold CPU
	#(1000*200) `UPD.CspW (`ADR_SRST,'h010101,2,1); // software reset should work
	#(1000*500) `UPD.CspR (`MISC,'h00); // CPU is free
`ifdef FPGA
`else
	`HW.PB.OSC_LOW.VAL (0);
	`HW.PB.OSC_LOW.WAIT (1,1); // OSCCTL setting resumed once CC_IDLE
`endif
	#1_000 hw_complete;
end

task wake_up_by_i2c; // temporarily
input [7:0] addr, wdat;
begin
   force `DUT.SDA = 0; // wake up temporarily by I2C start
   fork
      #(1000*100) `I2CMST.sfrw (addr,wdat);
      @(negedge `DUT.SCL) release `DUT.SDA; // I2C on start
   join
end
endtask: wake_up_by_i2c

endmodule // stm_osc

