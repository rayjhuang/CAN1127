
`define PB_SAY(format) $display format
`define PB_FIN(format) begin $display format; #100 $finish; end

module ana_probe (input [15:0] sig);
task VAL;
input [15:0] exp; // mV
begin
	`PB_SAY (($time,"ns <%m> %0x(%0d), exp:%0x",sig,sig,exp));
        if (exp[15:12]!==4'hx && (sig&'hf000)!==(exp&'hf000) ||
            exp[11: 8]!==4'hx && (sig&'h0f00)!==(exp&'h0f00) ||
            exp[ 7: 4]!==4'hx && (sig&'h00f0)!==(exp&'h00f0) ||
            exp[ 3: 0]!==4'hx && (sig&'h000f)!==(exp&'h000f)) `PB_FIN (($time,"ns <%m> ERROR: value mismatched"));
end
endtask // VIN

task BELOW;
input [15:0] exp; // mV
input integer timeout; // ms
fork: CHK_EXP
	`PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
	#(1000*1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"));
	wait (sig<=exp) begin
	   `PB_SAY (($time,"ns <%m> checked %0d", exp));
	   disable CHK_EXP;
	end
join
endtask // BELOW

task WAIT;
input [15:0] exp; // mV
input integer timeout; // ms
fork: CHK_EXP
	`PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
	#(1000*1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"));
	wait (sig===exp) begin
	   `PB_SAY (($time,"ns <%m> checked %0d", exp));
	   disable CHK_EXP;
	end
join
endtask // WAIT

task WAIT_US;
input [15:0] exp; // mV
input integer timeout; // us
fork: CHK_EXP
        `PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
        #(1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"))
        wait (sig===exp) begin
           `PB_SAY (($time,"ns <%m> checked %0d", exp));
           disable CHK_EXP;
        end
join
endtask // WAIT_US

task KEEP;
input [15:0] exp; // mV
input integer timeout; // ms
fork: CHK_EXP
	`PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
	#(1000*1000*timeout) disable CHK_EXP;
	wait (sig!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"));
join
endtask // KEEP

task KEEP_US;
input [15:0] exp; // mV
input integer timeout; // us
fork: CHK_EXP
        `PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
        #(1000*timeout) disable CHK_EXP;
        wait (sig!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"))
join
endtask // KEEP_US
endmodule // ana_probe


module dig_probe (input sig);
task VAL;
input exp; // 0/1
begin
	`PB_SAY (($time,"ns <%m> %d, exp:%d",sig,exp));
	if (sig!==exp) `PB_FIN (($time,"ns <%m> ERROR: value mismatched"));
end
endtask

task WAIT;
input exp; // 0/1
input integer timeout; // ms
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"));
	   wait (sig===exp) begin
	      `PB_SAY (($time,"ns <%m> %d checked",exp));
	      disable CHK_EXP;
	   end
	join
endtask // WAIT

task WAIT_US;
input exp; // 0/1
input integer timeout; // us
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"));
	   wait (sig===exp) disable CHK_EXP;
	join
endtask // WAIT_US

task KEEP;
input exp;
input integer timeout; // ms
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*1000*timeout) disable CHK_EXP;
	   wait (sig!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"));
	join
endtask // KEEP

task KEEP_US;
input exp;
input integer timeout; // us
        fork: CHK_EXP
           `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
           #(1000*timeout) disable CHK_EXP;
           wait (sig!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"));
        join
endtask // KEEP_US
endmodule // dig_probe

