
`define PB_SAY(format) $display format
`define PB_FIN(format) begin $display format; #100 $finish; end

module `PBNAME;
////////////////////////////////////////////////////////////////////////////////
`ifdef PBSIG // to declare a digital probing module

`ifdef TXSIG
`define PROBING TD.PB.sig_,`TXSIG
always #(1000*1000*10) $display ($time,"ns <%m> %d", `PROBING);
`undef TXSIG
`endif

task VAL;
input exp; // 0/1
begin
	`PB_SAY (($time,"ns <%m> %d, exp:%d",`PBSIG,exp));
	if (`PBSIG!==exp) `PB_FIN (($time,"ns <%m> ERROR: value mismatched"))
end
endtask

task WAIT;
input exp; // 0/1
input integer timeout; // ms
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"))
	   wait (`PBSIG===exp) disable CHK_EXP;
	join
endtask // WAIT

task WAIT_US;
input exp; // 0/1
input integer timeout; // us
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"))
	   wait (`PBSIG===exp) disable CHK_EXP;
	join
endtask // WAIT_US

task KEEP;
input exp;
input integer timeout; // ms
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*1000*timeout) disable CHK_EXP;
	   wait (`PBSIG!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"))
	join
endtask // KEEP

task KEEP_US;
input exp;
input integer timeout; // us
	fork: CHK_EXP
	   `PB_SAY (($time,"ns <%m> starts.....%d,%0d",exp,timeout));
	   #(1000*timeout) disable CHK_EXP;
	   wait (`PBSIG!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"))
	join
endtask // KEEP_US

`undef PBSIG
`endif // PBSIG


////////////////////////////////////////////////////////////////////////////////
`ifdef PBANA // to declare a analog probing module

task VAL;
input [15:0] exp; // mV
begin
	`PB_SAY (($time,"ns <%m> %0x(%0d), exp:%0x",`PBANA,`PBANA,exp));
        if (exp[15:12]!==4'hx && (`PBANA&'hf000)!==(exp&'hf000) ||
            exp[11: 8]!==4'hx && (`PBANA&'h0f00)!==(exp&'h0f00) ||
            exp[ 7: 4]!==4'hx && (`PBANA&'h00f0)!==(exp&'h00f0) ||
            exp[ 3: 0]!==4'hx && (`PBANA&'h000f)!==(exp&'h000f)) `PB_FIN (($time,"ns <%m> ERROR: value mismatched"))
end
endtask // VIN

task WAIT;
input [15:0] exp; // mV
input integer timeout; // ms
fork: CHK_EXP
	`PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
	#(1000*1000*timeout) `PB_FIN (($time,"ns <%m> ERROR: timeout"))
	wait (`PBANA===exp) begin
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
	wait (`PBANA===exp) begin
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
	wait (`PBANA!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"))
join
endtask // KEEP

task KEEP_US;
input [15:0] exp; // mV
input integer timeout; // us
fork: CHK_EXP
	`PB_SAY (($time,"ns <%m> starts.....%0d,%0d",exp,timeout));
	#(1000*timeout) disable CHK_EXP;
	wait (`PBANA!==exp) `PB_FIN (($time,"ns <%m> ERROR: not kept as expected"))
join
endtask // KEEP_US

`undef PBANA
`endif // PBANA

`undef PBNAME
endmodule

