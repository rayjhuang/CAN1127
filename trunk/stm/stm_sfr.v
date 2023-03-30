
`timescale 1ns/1ns
module stm_sfr;
// test SFR by HWI2c
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*30);

initial begin
#1	`HW.init_dut_fw;
#1	`I2CMST.dev_addr = 'h70;
	`I2CMST.init (3);
	#200_000
	$display ($time,"ns <%m> starts.....");
`ifdef GATE
`else
	`DUT_CORE.u0_regbank.u0_regE6.mem[3] =0; // r_adprx_en, assigned in bench for CC duty verification
        `DUT_CORE.u0_regbank.u0_regE6.mem[1:0] ='h0; // r_rxdb_opt, power-on value
`endif

	`I2CMST.sfrr (`REVID,{1'h1,`HW.REV_ID}); // check REV_ID
	`I2CMST.sfrw (`I2CCTL,'h19); // inc, PG0=BNK12 (REGX)
	TxRegx;
	TxProVal;
	TxDpDmVal;
	#(1000*1000) `I2CMST.sfrw (`ACCCTL,'h03); TxDpDmGlitch; // acc. at inactive
	#(1000*1000) `I2CMST.sfrw (`ACCCTL,'h00); TxDpDmGlitch; // acc. at active


	#(1000*200) // wait for the D- pulse
	`I2CMST.sfrr (`DPDMACC,'h00); // reset DPDMACC
	`I2CMST.sfrw (`FCPSTA,'h80); // clear ACC_DPDM
	#100_000 ChkOTP (`HW.OTP_SIZE-3); // ATTOP: the last 2-byte is revered

	`DUT_ANA.r_rstz = 0; #(1000*1)
	`DUT_ANA.r_rstz = 1; #(1000*1000) // wait for CPU idle

	`I2CMST.sfrw (`I2CCTL,'h01); // inc
	`I2CMST.sfrw (`FFCTL, 'h30); // let FFIO can be written
	`I2CMST.sfrw (`FFIO,$random);// initialize FFIO DAT0
	`I2CMST.sfrw (`FFSTA, 'h00); // empty FFIO
	`I2CMST.sfrw (`FFCTL, 'h00);
	TxPwrOn;

	#100_000 TxWrite1;
	#100_000 TxWrite0;


	#100_000
		`I2CMST.sfrw (`DEC,'h7c);
		`I2CMST.sfrw (`FFSTA,'h55); // system reset (PC reset as well)
		#10_000 // wait for system reset done
		`I2CMST.sfrr (`MISC,'h18); // hold, rst
		`I2CMST.sfrw (`MISC,'h08); // hold, clear system reset flag
		`I2CMST.bkwr (`ADR_SRST,3,{3{8'h01}}); // CPU reset
		`I2CMST.sfrw (`I2CCTL,'h01);
		`I2CMST.sfrw (`PRLTX,'h07); // CpMsgId
		`I2CMST.sfrw (`I2CCTL,'h01); // inc
		`I2CMST.sfrw (`ADR_SRST,'h00); // add clear srst flag function
		`I2CMST.sfrw (`ADR_I2CADR,'h89);

		`I2CMST.sfrw (`DPDNCTL,'h10); // let DN_COMP back to '0'
		`I2CMST.sfrw (`DPDNCTL,'h00);


		#(1000*200) // DPDMACC debounce
		`I2CMST.sfrw (`FCPSTA, 'h80);
		`I2CMST.sfrr (`DPDMACC,'h10);//11

	#100_000 TxPwrOn;
	#100_000 TxChkConn;
	#100_000 hw_complete;
end

task TxChkConn; // bench.chkconn (ANALOG_TOP)
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrr (`REVID,{1'h1,`HW.REV_ID}); // check REV_ID
	`I2CMST.sfrw (`I2CCTL,'h18); // non-inc, PG0=BNK12 (REGX)
	`I2CMST.bkwr (`X0_XANA0,13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`X0_XANA1,13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`X0_XANA2,13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`CVCTL,   13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`CCTRX,   13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`CCCTL,   13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`REGTRM0, 13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`REGTRM4, 13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`X0_AOPT, 13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`X0_BCK0, 13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`X0_BCK1, 13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`ATM,     13,{8'h00,$random,$random,$random});
	`I2CMST.bkwr (`CMPOPT,  13,{8'h00,$random,$random,$random});
end
endtask // TxChkConn

task TxPwrOn;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.bkrd ('h80,'h80,{
	64'h0000_0000_0000_0000,
	64'h0000_0000_0000_0000, // F0:DACLSB[1:0]
	64'h0000_0000_0000_0000,
	64'h0000_1f04_0000_0000, // E0: PWR_V
	64'hxx00_f800_8900_0000, // D8: i2cadr, i2csta, P0STA
	64'h3298_f000_1100_0100, // D0: GPIO5, RWBUF, EXGP, GPIOP, GPIOSL/H
	64'h0001_xxxx_00e1_0100, // C8(r24): I2CDEVA, I2CEV, I2CBUF
	1'h1,`HW.REV_ID,         //   (r23): REVID, CC_IDLE
	  40'h00_0000_0000,      //   (r18): OFS, DEC, CC_STATE
	            8'h80,8'h00, // C0(r16): ircon, I2CCMD=latched command, OFS, DEC, CC_STATE
	16'h0007,8'b0xxx_0000,8'h08, // CpMsgId, hold
	          32'h00xx_0000, // B8(r08):
	64'h8000_0020_01xx_0000, // B0(r00): CC_LOW, NAK, empty
	64'h0000_0028_00d9_0000, // A8: PWR_I
	64'h0000_0000_0000_00ff, // A0:
	64'h00xx_0000_8000_0040, // 9E: FCPDAT, FCP empty
	64'h0000_0000_0000_0000, // 90: add SFR97/6 in B0
	64'h0000_0000_0000_0000,
	64'h0900_0000_0000_070x | 'h0c // don't care SCL/SDA
	}); // 80:
end
endtask // TxPwrOn

task TxWrite1;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.bkwr ('h80,'h80,{
	64'hffff_ffff_ffff_ffff, // F8:
	64'hffff_ffef_ffff_ffff, // F0: DACLSB(CCI2C in A0)
	64'hffff_ffff_ffff_ffff, // E8:
	64'hffff_ffff_ffff_ffff, // E0:
	64'hffff_ff00_ffff_bf00, // D8: adcon,i2ccon,TM[2]=CCI2C in B0
	64'hff98_f0f8_22ff_f2ff, // D0: gpio_sel,STOP/LOW/gate,gpio_pu/pd
	64'hffff_ffff_00e1_f700, // C8: t2con,raw,inc,deva,i2cmsk
	64'hffff_ffff_ffff_ffff, // C0: ircon
	64'hffff_ffbf_ffff_0000, // B8: ie1,ip1, don't set r_otp_fast_r
	64'hffff_ffff_ffff_7fff, // B0: don't last
	64'hffff_ffff_ffd9_fffe, // A8: s0rell (w/o INT0)
	64'hffff_ffff_ffff_ffff, // A0:
	64'hffff_ffff_ffff_ffff, // 98:
	64'hffff_ffff_ffff_ffff, // 90:
	64'hafff_ffff_ffff_ffff, // 88:
	64'hffff_55aa_ffff_ffff  // 80:
	});
	`I2CMST.bkrd ('h80,'h80,{
	64'hfefe_fefe_fefe_fefe,
	64'h00ff_ff67_ffff_fe00, // F0: DACCTL(busy)
	64'h2000_0000_0000_00ff, // E8: md0~5, arcon
	64'hffff_ffff_fd00_0000, // E0: COMPI, CMPSTA, SCRCTL[1]:LG_DISCHG
	64'hxxff_f800_ffff_bf00, // D8: i2cadr, i2csta, P0STA
	64'hff98_f0e0_2200_f200, // D0: GPIO5, RWBUF, EXGP, GPIOP, GPIOSL/H, STB_OVP/PWRDN cleared
	64'hff00_xxxx_00e1_3700, // C8(r24): I2CDEVA, I2CEV, I2CBUF
	1'h1,`HW.REV_ID,         //    REVID, CC_IDLE
	  40'h80_ffff_8000,      //   (r18): OFS, DEC (ofs+1), CC_STATE
	            8'h80,8'h3f, // C0(r16): ircon, OFS, DEC, CC_STATE
	16'hffff,8'b0xxx_0000,8'hbf,
	          32'hffff_0000, // B8(r08): CpMsgId
	64'h80ff_ff10_00xx_3fff, // B0(r00): 1st/last,ACK,empty
	64'hff00_00ff_ffd9_7fbe, // A8: PROVAL, PROSTA
	64'hffff_ffff_ffff_ffff, // A0:
	64'h63xx_ff02_ff3f_00ff, // 98: en2, FCPSTA, FCPDAT, FCPCRC
	64'h00df_ff78_0000_ffff, // 90: LDBPRO, OTPI_S
	64'haf00_ff9x_ffff_ffff, // 88: th0=random, (ckcon)
	64'he9ff_55aa_0000_077x | 'hc // CC is output '1' by test mode but swithed to DI_OK
	});

	`I2CMST.sfrw ('hb4,'h21); // clear TX status
end
endtask // TxWrite1

task TxWrite0;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.bkwr ('h80,'h80,{
	64'h0000_0000_0000_0000, // F8:
	64'h0000_0000_0000_0000, // F0:
	64'h0000_0000_0000_0000, // E8:
	64'h0000_0000_0000_0000, // E0:
	64'h0000_0000_0000_0000, // D8: adcon,i2ccon
	64'h0098_f000_1100_0100, // D0: SCL/SDA sel,stop/low/gate,pu/pd
	64'h0000_0000_00e1_0100, // C8: t2con,raw,inc,deva,i2cmsk
	64'h0000_0000_0000_0000, // C0: ircon
	64'h0000_0008_0000_0000, // B8: ie1,ip1,hold
	64'h0000_0000_0000_0000, // B0:
	64'h0000_0000_00d9_0000, // A8:
	64'h0000_0000_0000_0000, // A0:
	64'h0000_0000_0000_0000, // 98:
        64'h0000_0000_0000_0000, // 90:
	64'h4000_0000_0000_0000, // 88:
        64'h0000_0000_0000_0000  // 80:
	});
	`I2CMST.bkrd ('h80,'h80,{
	64'h0000_0000_0000_0000,
	64'h0000_0000_0000_0000, // F0:
	64'h4000_00ff_ffff_ff00, // E8: md0~5, arcon
	64'h0000_0000_0000_0000  // E0:
		| {8'b0000_0x00,32'h0}, // E4: IDIN
	64'hxx00_f800_0000_0000, // D8(r40): i2cadr, i2csta, P0STA
	64'h0098_f000_1100_0100, // D0(r32): ANACTL, GPIOP, GPIOSL/H
	64'h0001_xxxx_00e1_0100, // C8(r24): I2CDEVA, I2CEV, I2CBUF
	1'h1,`HW.REV_ID,         //    REVID, CC_IDLE
	  56'h00_0000_0000_8014, // C0(r16): ircon, I2CCMD, OFS, DEC, CC_STATE
	16'h0000,8'b0xxx_0000,8'h08, // hold
	          32'h0000_0000, // B8(r08): CpMsgId
	64'h8000_0030_01xx_0000, // B0(r00): 1st/last,NAK/ACK,empty
	64'h0000_0000_00d9_0000, // A8:
	64'h0000_0000_0000_00ff, // A0:
	64'h00xx_0003_2000_0002, // 98: FCPSTA, s0con
	64'h0080_0000_0000_0000, // 90: DPDMACC 
	64'h4000_0000_0000_0020, // 88: tcon
	64'h0900_0000_0000_070x | 'hc}); // 80: idle
end
endtask // TxWrite0

task TxDpDmVal;
reg [7:0] ii;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrr (`ACCCTL,'h00); // reset DPDMACC
	for (ii=0; ii<8; ii=ii+1) begin
	   if ((ii%4)==0) HvDcpDrv (1000,1000);
	   if ((ii%4)==2) HvDcpDrv (1000,1600);
	   if ((ii%4)==1) HvDcpDrv (1600,1000);
	   if ((ii%4)==3) HvDcpDrv (1600,1600);
	   `DUT_ANA.r_dn_fault = (ii%3)==0;
//	   `DUT_ANA.r_DpDnCC_ovp = (ii%2)==0;
	   `I2CMST.sfrr (`ACCCTL,(((ii>>1)%2)          <<7)   // DN_COMP
	                        | ((ii%2)              <<6)); // DP_COMP
//	                        | ((ii%2 ? 8'h0 : 8'h1)<<5)); // DPDN_OVP (from IDIN)
	   //                   | ((ii%3 ? 8'h0 : 8'h1)<<5)); // DN_FAULT
	end
	HvDcpDrv (600,600);
	#(1000*150) // wait for the D- pulse
	`I2CMST.sfrr (`DPDMACC,'h00); // check/reset DPDMACC (short pulses)
	`I2CMST.sfrr (`FCPSTA,'h00);
//	`I2CMST.sfrw (`FCPSTA,'h80); // clear ACC_DPDM
end
endtask // TxDpDmVal

task TxDpDmGlitch;
reg [7:0] ii;
begin
	HvDcpDrv (600,2000);
	#(1000*200) `I2CMST.sfrr (`DPDMACC,'hxx); // reset DPDMACC
	            `I2CMST.sfrw (`FCPSTA,'h80); // clear ACC_DPDM
	#(1000*200)
	for (ii=0; ii<14; ii=ii+1) begin
	   case (ii)
	   9,6:     #(1000*100);
	   13:      #(1000*300);
	   default: #(1000*200);
	   endcase
	   HvDcpDrv (2600-`USBCONN.USBDP.HvDcpDrv, 2600-`USBCONN.USBDN.HvDcpDrv);
	end
        `I2CMST.sfrr (`DPDMACC,'h55); // reset DPDMACC
        `I2CMST.sfrr (`DPDMACC,'h00);

	#(1000*200) // wait for the D- pulse
	$display ($time,"ns <%m> clear dp/dm_acc");
	HvDcpDrv ('hx,'hx);

	`I2CMST.sfrr (`FCPSTA,'h80);
	`I2CMST.sfrw (`FCPSTA,'h80); // clear ACC_DPDM
end
endtask // TxDpDmGlitch

task TxProVal;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrr (`PROVAL,'h00);
	`I2CMST.sfrr (`PROSTA,'h00);

	`DUT_ANA.r_dn_fault = 1; #100
	`DUT_ANA.r_dn_fault = 0; #1000
	`DUT_ANA.r_dn_fault = 1; #200
	`DUT_ANA.r_dn_fault = 0; #1000
	`DUT_ANA.r_dn_fault = 1; #1000
	`DUT_ANA.r_dn_fault = 0; #100
	`DUT_ANA.r_dn_fault = 1; #1000
	`DUT_ANA.r_dn_fault = 0; #200
	`DUT_ANA.r_dn_fault = 1;
	`I2CMST.sfrr (`PROVAL,'h80);
	`I2CMST.sfrr (`PROSTA,'h80); // CAN1124A0 adds the status
	`DUT_ANA.r_dn_fault = 0;
	`I2CMST.sfrr (`PROVAL,'h00);
	`I2CMST.sfrr (`PROSTA,'h80);
	`I2CMST.sfrw (`PROSTA,'h80);
	`I2CMST.sfrr (`PROSTA,'h00);
end
endtask // TxProVal

task HvDcpDrv; // portable device dirve D+/D- (copy from usb_test_device.v)
input [15:0] dpsel, dnsel; // 'hx/1/2/others: floating/0.6V/FCP_HI/?mV
begin
	`USBCONN.USBDP.HvDcpDrv = dpsel;
	`USBCONN.USBDN.HvDcpDrv = dnsel;
end
endtask // HvDcpDrv

task ChkOTP;
input [15:0] adr;
begin
	$display ($time,"ns <%m> starts.....");
	`I2CMST.sfrw (`DEC,'h01);
	`I2CMST.sfrr (`NVMIO,'h00); // r_ack_hi=0, results PCH
	`I2CMST.sfrw (`DEC,(`HW.OTP_SIZE>>8) | 'h80);
	`I2CMST.sfrw (`OFS, `HW.OTP_SIZE);
	`I2CMST.sfrr (`NVMIO,'hee); // r_ack_hi=1, out-of-range, results 'hee

	`HW.set_code (adr,$random);
	`I2CMST.sfrw (`DEC,(adr>>8) | 'h80);
	`I2CMST.sfrw (`OFS, adr);
	`I2CMST.sfrr (`NVMIO,`HW.get_code (adr));
	`I2CMST.sfrw (`DEC,'h00); // clear r_ack_hi
end
endtask // ChkOTP

task TxRegx;
begin
	$display ($time,"ns <%m> starts.....POR");
	`I2CMST.bkrd ('h00,'h80,{ // POR values
	{8{64'hffff_ffff_ffff_ffff}}, // 40h~7Fh
	64'hffff_ffff_ff00_0000, // 38h:
	64'hffff_ffff_ff00_0000, // 30h:
	64'h0000_0000_0000_0000, // 28h:
	64'hffff_ffff_ffff_0000, // 20h:
	64'h0000_0000_0000_0000, // 18h: 1B[3]:TS/DI, STB_OVP
	64'h0000_00f0_0008_0000, // 10h: SAP, HWTRP
	64'h00ff_ffff_ffff_0000, // 08h:
	64'h0000_0000_ff00_0000  // 00h:
	});
	$display ($time,"ns <%m> starts.....WR1");
	`I2CMST.bkwr ('h00,'h80,{ // Write-1
	{8{64'hffff_ffff_ffff_ffff}}, // 40h~7Fh
	64'hffff_ffff_ffff_ffff, // 38h:
	64'hffff_ffff_ffff_ffff, // 30h:
	64'hffff_ffff_ffff_ffff, // 28h:
	64'hffff_ffff_ffff_ffff, // 20h:
	64'hffff_ffff_feff_ffff, // 18h: TS_PD=0
	64'hff00_f0ff_ffff_ffff, // 10h: BIST_START is self-protected
	64'hffff_ffff_ffff_ffff, // 08h:
	64'hf5af_ffff_ffff_ffff  // 00h: random number
	});
	`I2CMST.bkrd ('h00,'h80,{ // Write-1 results
	{8{64'hffff_ffff_ffff_ffff}}, // 40h~7Fh
	64'hffff_ffff_ff00_0303, // 38h:
	64'hffff_ffff_ff00_ffff, // 30h: DACEN, SAREN, COMPI
	64'hffff_ffff_ffff_ffff, // 28h:
	64'hffff_ffff_ffff_ffff, // 20h:
	64'h00ff_fffe_f6ff_ffff, // 18h: EPR_MODE will be update at PWR_V's update, DI_TS=DN_FAULT
	64'hff00_30f0_ffff_ff76, // 10h: BIST, HWTRP
	64'hffff_ffff_ffff_ffff, // 08h:
	64'hf5af_ffff_ffff_ffff  // 00h:
	});
	$display ($time,"ns <%m> starts.....WR0");
	`I2CMST.bkwr ('h00,'h80,{ // Write-0
	{8{64'h0}},              // 40h~7Fh
	{4{64'h0}},              // 20h~3Fh
	64'h0000_0000_0100_0000, // 18h: 1B[0]:TSPD
	64'h0000_0000_0000_0000, // 10h:
	{2{64'h0}}});            // 00h~0Fh
	`I2CMST.bkrd ('h00,'h80,{ // Write-0 results
	{8{64'hffff_ffff_ffff_ffff}}, // 40h~7Fh
	64'hffff_ffff_ff00_0000, // 38h:
	64'hffff_ffff_ff00_0000, // 30h:
	64'h0000_0000_0000_0000, // 28h:
	64'hffff_ffff_ffff_0000, // 20h:
	64'h0000_0000_0100_0000, // 18h:
	64'h0000_00f4_0000_0000, // 10h: SAP, HWTRP, IMP_OSC
	64'h00ff_ffff_ffff_0000, // 08h:
	64'h0000_0000_ff00_0000  // 00h:
	});
end
endtask // TxRegx

endmodule // stm_sfr

