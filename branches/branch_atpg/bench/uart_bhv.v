//*****************************************************************************
//
// ENE 8051 IP Simulation Model
//
// Module:	Serial Singal Generator and Receiver
//	
// Engineer: 	Guide Wang
// Created on: 	2001/12/11
// Description: 
// 	This module is the model for 8051 IP Serial Port Simulation.
//*****************************************************************************
//`include "delay.h"
//`include "system.def"
//`include "e51_codegen.def"
//`include "e51_mon.def"
`timescale 1ns/100ps
//*****************************************************************************
module 	uart_bhv (		// system simulation Serial Signals receiver/generator
// output list
	x_txd,			// Serial output  from  E51 Serial Port Tranceiver

// input list
	x_rxd 			// Serial output to    E51 Serial Port Receiver
);
//*****************************************************************************
output 	x_txd; 			// Serial output to    E51 Serial Port Receiver
input	x_rxd;			// Serial input  from  E51 Serial Port Tranceiver

integer i,j;			// for loop counter (for txd)
integer k,h;			// for loop counter (for rxd)

integer txd_baud_period;	// 1/baud_rate (in neno second unit)
integer rxd_baud_period;	// 1/baud_rate (in neno second unit)

reg	[7:0]
	rxd_byte;		// during receiving byte
reg	[599:0]
	rxd_string;		// a line string of reciving from rxd_byte
event	ev_rx_rcved,
	ev_rx_start;

reg	dev_en,			// connect control, can be changed only when bus idle
	txdo, 			// Model output to    E51 Serial Port Receiver
	auto_rx;

assign	x_txd = (dev_en) ? txdo : 1'hz;
wire	#3 rxdi = (dev_en) ? x_rxd : 1'h1; // delay for gate-level simulation (debounce)
//*****************************************************************************
initial	// initial value for INT0 and INT1
begin
	dev_en = 0;
	txdo = 1;
	k = 599;		// rxd_string bit counter
	auto_rx =0;
	txd_baud_period = 1000_000_000/9600;
	rxd_baud_period = 1000_000_000/9600;
end

initial forever
begin
	wait (dev_en & auto_rx)
	@(negedge rxdi) ->ev_rx_start;
	fork: wait_rcv
	   @(ev_rx_start)
	      $display ($time, "ns <%m> WARNNING: an rx_start event is ignored");
	   @(ev_rx_rcved) disable wait_rcv;
	join
end

//*****************************************************************************
always @(ev_rx_start)
begin
	wait (rxdi==1'h0)		// wait falling edge to start receiving
	# rxd_baud_period		// wait start bit
	#(rxd_baud_period/2)		// wait half period to start 1 bit
	for(h=0; h<8; h=h+1)
		begin
		rxd_byte[h] = rxdi;
		rxd_string[k-(7-h)] = rxdi;
		# rxd_baud_period;	// wait a bit period
		end
	k = k - 8;			// next character bit address

	if(rxdi!==1'b1)		// check STOP bit if not ==1
		begin
		$display ($time, "ns <%m> ERROR: receive STOP bit FAIL(exp, rxd)=(1,%0b) rxd_byte = (%x)", rxdi, rxd_byte);
		$finish;
		end

`define E51_SERIAL_MODEL_DISPLAY_A_CHAR_A_LINE
////////////////////////////////////////////////////////////////////////////////
`ifdef 	E51_SERIAL_MODEL_DISPLAY_A_CHAR_A_LINE
////////////////////////////////////////////////////////////////////////////////

	$write ($time, "ns <%m> byte received %x", rxd_byte);
	if (rxd_byte>" " && rxd_byte<127)
	   $write (" (%c)", rxd_byte);
	$write ("\n");

////////////////////////////////////////////////////////////////////////////////
`else
////////////////////////////////////////////////////////////////////////////////
//	$display("[%0t] .", $realtime);

	if(rxd_byte == 8'h0A)		// new line character, display a full line string
		begin
		$display("[%0t] %s", $realtime, rxd_string);
//		$display("[%0t] E51 SERGEN receiving string = %s ", $realtime, rxd_string);
		for(h=0; h<600; h=h+1)
			rxd_string[h] = 0;
		k = 599;

//		$display("Received newline. End of Simulation!!!", $realtime, rxd_string);
//		`test_end;
		end
////////////////////////////////////////////////////////////////////////////////
`endif
////////////////////////////////////////////////////////////////////////////////
	->ev_rx_rcved;
end


//*****************************************************************************
// task: 
//	sergen_txd(txd_byte, mode, TB8)
//
// functional description:
//	generate a byte data to TXD line in baud_rate period
// parameters description:
//	txd_byte:	output serial byte
//	mode:		select serial mode(only 1 and 3 are valid)
//	TB8:		The 9th bit of TXD
//*****************************************************************************
task 	sergen_txd;
input	[7:0]	
	txd_byte;	// output serial byte
input	[1:0]	
	mode;		// select serial mode(only 1 and 3 are valid)
input	tb8;		// The 9th bit of TXD
//*****************************************************************************
begin
	$write ($time, "ns <%m> to output %x", txd_byte);
	if (txd_byte>" " && txd_byte<127)
	   $write (" (%c)", txd_byte);
	$write ("\n");

	// Send START bit
	txdo = 1'b0;			// start bit is "0"
	# txd_baud_period		// wait period
	for(i=0; i<8; i=i+1)
	begin
	   txdo = txd_byte[i];
	   # txd_baud_period;		// wait period
	end

	// Sent 9th bit in mode 3
	if(mode===2'h3)
	begin
	   txdo = tb8;
	   # txd_baud_period;		// wait period
	end

	// Send STOP bit
	txdo = 1'b1;
//	# txd_baud_period;		// wait period
end
endtask // sergen_txd

//*****************************************************************************
task sergen_rxd;
input [7:0] exp;
reg [7:0] idx;
begin
   ->ev_rx_start;
   @(ev_rx_rcved)
   for (idx=0; idx<8; idx=idx+1)
      if (exp[idx]!==1'hx && rxd_byte[idx]!==exp[idx]) begin
         $write ($time, "ns <%m> ERROR: rcv.data mismatch, dat: %x", rxd_byte);
         if (|rxd_byte==='hx) $write ("(%b)", rxd_byte);
         $write (", exp: %x", exp);
         if (|exp==='hx) $write ("(%b)", exp);
         $write ("\n");
         $finish;
      end
end
endtask // sergen_rxd


//*****************************************************************************
// task: 
//	sergen_set_baud_rate (txd_baud_rate, rxd_baud_rate)
//
// functional description:
//	set the transmitter/receiver baud rate for future procedure.
// parameters description:
//	txd_baud_rate	transmitting baud rate
//	rxd_baud_rate	receiving baud rate
//*****************************************************************************
task 	sergen_set_baud_rate;
input	[31:0]	txd_baud_rate,	// 0: unchanged
		rxd_baud_rate;	// 0: unchanged
//*****************************************************************************
begin
	if (txd_baud_rate>0) begin
	   txd_baud_period = (1000_000_000/txd_baud_rate);	// 1/baud_rate (in neno second unit)
	   $display("");
	   $display("*****************************************************************************");
	   $display("[%0t] < %m > set transmitter baud rate = %0d (clock period = %0d)... ", $realtime, txd_baud_rate, txd_baud_period);
	   $display("*****************************************************************************");
	   $display("");
	end
	if (rxd_baud_rate>0) begin
	   rxd_baud_period = (1000_000_000/rxd_baud_rate);	// 1/baud_rate (in neno second unit)
	   $display("");
	   $display("*****************************************************************************");
	   $display("[%0t] < %m > set receiver baud rate = %0d (clock period = %0d)... ", $realtime, rxd_baud_rate, rxd_baud_period);
	   $display("*****************************************************************************");
	   $display("");
	end
end
endtask // sergen_set_baud_rate
//*****************************************************************************

endmodule // uart_bhv

