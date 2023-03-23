
`timescale 1ns/1ns
module stm_fcp1_TypeB_whole_registers;
// 1. let DUT FW-controlled
// 2. FcpDevTx to trigger the FW
// 3. FcpDevRx to check its responding data
`include "stm_task.v"
`include "fcp_task.v"
initial #1 $fsdbDumpvars (stm_fcp1_TypeB_whole_registers);
initial timeout_task (1000*1800);
initial begin: main
#100	`HW.load_dut_fw (`FW0); // from CAN1121
	wait (!`DUT_MCU.ro) #(1000*1000)
	$display ($time,"ns <%m> starts.....");
	#(1000*1000) `USBCONN.USBDP.HvDcpDrv = 1; // keep DP attached
	#(1000*1000*30); // wait for HVDCP and SCP init
	FCP_UI = 160*(1000*0.88);
	tx_fcp;
#10_000 hw_complete;
end

task tx_fcp;
begin
	$display ($time,"ns <%m> starts.....");
	#(31*FCP_UI);

//	#(1*FCP_UI) ScpSingleBlockRd (8'h7c,8'h00); // Addr=7c / default=00
//	#(1*FCP_UI) ScpSingleBlockRd (8'h7d,8'h00); // Addr=7d / default=00

	#(1*FCP_UI) ScpSingleBlockRd (8'h80,8'h90); // Addr=80 / default=B0 ?? 90 (charger's behavior)
	#(1*FCP_UI) ScpSingleBlockRd (8'h81,8'h10); // Addr=81 / default=10 B_ADP_TYPE
	#(1*FCP_UI) ScpSingleBlockRd (8'h82,8'h80); // Addr=82 / default=00 VENDER_ID_H
	#(1*FCP_UI) ScpSingleBlockRd (8'h83,8'hb1); // Addr=83 / default=00 VENDER_ID_L
	#(1*FCP_UI) ScpSingleBlockRd (8'h84,8'h00); // Addr=84 / default=00 MODULE_ID_H
	#(1*FCP_UI) ScpSingleBlockRd (8'h85,8'h01); // Addr=85 / default=00 MODULE_ID_L
	#(1*FCP_UI) ScpSingleBlockRd (8'h86,8'h01); // Addr=86 / default=00 SERIAL_NO_H
	#(1*FCP_UI) ScpSingleBlockRd (8'h87,8'h34); // Addr=87 / default=00 SERIAL_NO_L
	#(1*FCP_UI) ScpSingleBlockRd (8'h88,8'h01); // Addr=88 / default=00 CHIP_ID
	#(1*FCP_UI) ScpSingleBlockRd (8'h89,8'h02); // Addr=89 / default=00 HWVER
	#(1*FCP_UI) ScpSingleBlockRd (8'h8a,8'h01); // Addr=8a / default=01 FWVER_H
	#(1*FCP_UI) ScpSingleBlockRd (8'h8b,8'h29); // Addr=8b / default=30 FWVER_L
//	#(1*FCP_UI) ScpSingleBlockRd (8'h8c,8'h00); // Addr=8c / default=00 (reserved)
	#(1*FCP_UI) ScpSingleBlockRd (8'h8d,8'h82); // Addr=8d / default=82 ADP_B_TYPE1
	#(1*FCP_UI) ScpSingleBlockRd (8'h8e,8'h00); // Addr=8e / default=00 FACTORY_ID
//	#(1*FCP_UI) ScpSingleBlockRd (8'h8f,8'h00); // Addr=8f / default=00 (reserved)

	#(1*FCP_UI) ScpSingleBlockRd (8'h90,8'h9e); // Addr=90 / default=9E
	#(1*FCP_UI) ScpSingleBlockRd (8'h91,8'h96); // Addr=91 / default=96
	#(1*FCP_UI) ScpSingleBlockRd (8'h92,8'ha4); // Addr=92 / default=A4
	#(1*FCP_UI) ScpSingleBlockRd (8'h93,8'hcc); // Addr=93 / default=CC
	#(1*FCP_UI) ScpSingleBlockRd (8'h94,8'h85); // Addr=94 / default=85 MIN_IOUT
	#(1*FCP_UI) ScpSingleBlockRd (8'h95,8'hb2); // Addr=95 / default=99 MAX_IOUT ??
	#(1*FCP_UI) ScpSingleBlockRd (8'h96,8'h14); // Addr=96 / default=14
	#(1*FCP_UI) ScpSingleBlockRd (8'h97,8'h32); // Addr=97 / default=32
	#(1*FCP_UI) ScpSingleBlockRd (8'h98,8'h64); // Addr=98 / default=64
	#(1*FCP_UI) ScpSingleBlockRd (8'h99,8'h64); // Addr=99 / default=64
	#(1*FCP_UI) ScpSingleBlockRd (8'h9a,8'h32); // Addr=9a / default=32
	#(1*FCP_UI) ScpSingleBlockRd (8'h9b,8'h14); // Addr=9b / default=14 
//	#(1*FCP_UI) ScpSingleBlockRd (8'h9c,8'h00); // Addr=9c / default=00 (reserved)
//	#(1*FCP_UI) ScpSingleBlockRd (8'h9d,8'h00); // Addr=9d / default=00 (reserved)
//	#(1*FCP_UI) ScpSingleBlockRd (8'h9e,8'h00); // Addr=9e / default=00 (reserved)
//	#(1*FCP_UI) ScpSingleBlockRd (8'h9f,8'h00); // Addr=9f / default=00 (reserved)

	#(1*FCP_UI) ScpSingleBlockRd (8'ha0,8'h80); // Addr=a0 / default=00 ??
	#(1*FCP_UI) ScpSingleBlockRd (8'ha1,8'h02); // Addr=a1 / default=02
	#(1*FCP_UI) ScpSingleBlockRd (8'ha2,8'h40); // Addr=a2 / default=00 ??
	#(1*FCP_UI) ScpSingleBlockRd (8'ha3,8'h00); // Addr=a3 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'ha4,8'h00); // Addr=a4 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'ha5,8'h00); // Addr=a5 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'ha6,8'h00); // Addr=a6 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'ha7,8'h00); // Addr=a7 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'ha8,8'h00); // Addr=a8 / default=00 ?? 0F (follow SREAD_*OUT)
	#(1*FCP_UI) ScpSingleBlockRd (8'ha9,8'h00); // Addr=a9 / default=00 ?? 50
`ifdef FPGA // ADC in FPGA is slower
`else
	#(1*FCP_UI) ScpSingleBlockRd (8'haa,8'h02); // Addr=aa / default=00 ?? this FW uses switched CH0 sensing current (CAN1110?/CAN1112AX), DAC0=220
	#(1*FCP_UI) ScpSingleBlockRd (8'hab,8'h88); // Addr=ab / default=00 ?? -- which is VIN/20 in CAN1121A0, 0x0288=648mA (DACV0=27,216mV)
`endif
	#(1*FCP_UI) ScpSingleBlockRd (8'hac,8'h00); // Addr=ac / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'had,8'h00); // Addr=ad / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hae,8'h00); // Addr=ae / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'haf,8'h00); // Addr=af / default=00

	#(1*FCP_UI) ScpSingleBlockRd (8'hb0,8'h15); // Addr=b0 / default=15
	#(1*FCP_UI) ScpSingleBlockRd (8'hb1,8'h7c); // Addr=b1 / default=7C
	#(1*FCP_UI) ScpSingleBlockRd (8'hb2,8'h09); // Addr=b2 / default=09
	#(1*FCP_UI) ScpSingleBlockRd (8'hb3,8'hc4); // Addr=b3 / default=C4
	#(1*FCP_UI) ScpSingleBlockRd (8'hb4,8'h32); // Addr=b4 / default=32
	#(1*FCP_UI) ScpSingleBlockRd (8'hb5,8'h72); // Addr=b5 / default=72
//	#(1*FCP_UI) ScpSingleBlockRd (8'hb6,8'h00); // Addr=b6 / default=00 (reserved)
//	#(1*FCP_UI) ScpSingleBlockRd (8'hb7,8'h00); // Addr=b7 / default=00 (reserved)
	#(1*FCP_UI) ScpSingleBlockRd (8'hb8,8'h14); // Addr=b8 / default=14
	#(1*FCP_UI) ScpSingleBlockRd (8'hb9,8'h82); // Addr=b9 / default=82
	#(1*FCP_UI) ScpSingleBlockRd (8'hba,8'h07); // Addr=ba / default=07
	#(1*FCP_UI) ScpSingleBlockRd (8'hbb,8'hd0); // Addr=bb / default=D0
	#(1*FCP_UI) ScpSingleBlockRd (8'hbc,8'h00); // Addr=bc / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hbd,8'h00); // Addr=bd / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hbe,8'h00); // Addr=be / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hbf,8'h00); // Addr=bf / default=00

	#(1*FCP_UI) ScpSingleBlockRd (8'hc6,8'h00); // Addr=c6 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hc7,8'h00); // Addr=c7 / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hc8,8'hc4); // Addr=c8 / default=00 SREAD_VOUT (10mV)
	#(1*FCP_UI) ScpSingleBlockRd (8'hc9,8'h0c); // Addr=c9 / default=00 SREAD_IOUT (50mA)
	#(1*FCP_UI) ScpSingleBlockRd (8'hca,8'he1); // Addr=ca / default=E1
	#(1*FCP_UI) ScpSingleBlockRd (8'hcb,8'h28); // Addr=cb / default=28
	#(1*FCP_UI) ScpSingleBlockRd (8'hcc,8'h00); // Addr=cc / default=00
	#(1*FCP_UI) ScpSingleBlockRd (8'hcd,8'h15); // Addr=cd / default=00 ??
//	#(1*FCP_UI) ScpSingleBlockRd (8'hce,8'h00); // Addr=ce / default=00 (reserved)
//	#(1*FCP_UI) ScpSingleBlockRd (8'hcf,8'h00); // Addr=cf / default=00 (reserved)

	#(1*FCP_UI) 
	; // $finish;

end
endtask // tx_fcp

endmodule // stm_fcp1_TypeB_whole_registers

