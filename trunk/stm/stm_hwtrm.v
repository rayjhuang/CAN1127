
`timescale 1ns/1ns
module stm_hwtrim; //hardwire trim CV/CC/AD
`include "stm_task.v"
initial #1 $fsdbDumpvars;
initial timeout_task (1000*600);

initial begin: main
#1              `HW.set_code(0,-1);
                 wait (!`DUT_MCU.ro) #(1000*1000)
                $display ($time,"ns <%m> starts.....");
                `I2CMST.init (2); // 1 MHz
                `I2CMST.dev_addr = 'h70;
//==================================DAC0==========================================

#1000            cvtrm( 250*2,0,2,4,6);
#1000            cvtrm( 255*2,2,4,6,7);
#1000            cvtrm( 256*2,2,4,6,7);
#1000            cvtrm( 511*2,2,4,6,7);
#1000            cvtrm( 512*2,2,4,6,7);
#1000            cvtrm( 767*2,2,4,6,7);
#1000            cvtrm( 768*2,2,4,6,7);
#1000		 cvtrm(1023*2,2,4,6,7);
#1000            cvtrm(1024*2,2,4,6,7);
#1000            cvtrm(1035*2,2,4,6,7);
#1000            cvtrm(1036*2,2,4,6,7);
#1000            cvtrm(1037*2,2,4,6,7);
#1000            cvtrm(1050*2,2,4,6,7);

#1000            cvtrm( 250*2,0,1,2,3);
#1000            cvtrm( 255*2,1,2,3,4);
#1000            cvtrm( 256*2,1,2,3,4);
#1000            cvtrm( 511*2,1,2,3,4);
#1000            cvtrm( 512*2,1,2,3,4);
#1000            cvtrm( 767*2,1,2,3,4);
#1000            cvtrm( 768*2,1,2,3,4);
#1000		 cvtrm(1023*2,1,2,3,4);
#1000            cvtrm(1024*2,1,2,3,4);
#1000            cvtrm(1035*2,1,2,3,4);
#1000            cvtrm(1036*2,1,2,3,4);
#1000            cvtrm(1037*2,1,2,3,4);
#1000            cvtrm(1050*2,1,2,3,4);

#1000            cvtrm( 250*2,0,1,2,3);
#1000            cvtrm( 255*2,1,2,3,3);
#1000            cvtrm( 256*2,1,2,3,3);
#1000            cvtrm( 257*2,1,2,3,3);
#1000            cvtrm( 511*2,1,2,3,3);
#1000            cvtrm( 512*2,1,2,3,3);
#1000            cvtrm( 513*2,1,2,3,3);
#1000            cvtrm( 767*2,1,2,3,3);
#1000            cvtrm( 768*2,1,2,3,3);
#1000            cvtrm( 769*2,1,2,3,3);
#1000            cvtrm(1023*2,1,2,3,3);
#1000            cvtrm(1024*2,1,2,3,3);
#1000            cvtrm(1025*2,1,2,3,3);
#1000            cvtrm(1035*2,1,2,3,3);
#1000            cvtrm(1036*2,1,2,3,3);
#1000            cvtrm(1037*2,1,2,3,3);
#1000            cvtrm(1050*2,1,2,3,3);

#1000            cvtrm( 250*2,0,1,2,3);
#1000            cvtrm( 255*2,1,2,3,4);
#1000            cvtrm( 256*2,1,2,3,4);
#1000            cvtrm( 257*2,1,2,3,4);
#1000            cvtrm( 511*2,1,2,3,4);
#1000            cvtrm( 512*2,1,2,3,4);
#1000            cvtrm( 513*2,1,2,3,4);
#1000            cvtrm( 767*2,1,2,3,4);
#1000            cvtrm( 768*2,1,2,3,4);
#1000            cvtrm( 769*2,1,2,3,4);
#1000            cvtrm(1023*2,1,2,3,4);
#1000            cvtrm(1024*2,1,2,3,4);
#1000            cvtrm(1025*2,1,2,3,4);
#1000            cvtrm(1035*2,1,2,3,4);
#1000            cvtrm(1036*2,1,2,3,4);
#1000            cvtrm(1037*2,1,2,3,4);
#1000            cvtrm(1050*2,1,2,3,4);

#1000            cvtrm( 250*2,0,1,2,5);
#1000            cvtrm( 255*2,1,2,3,5);
#1000            cvtrm( 256*2,1,2,3,5);
#1000            cvtrm( 257*2,1,2,3,5);
#1000            cvtrm( 511*2,1,2,3,5);
#1000            cvtrm( 512*2,1,2,3,5);
#1000            cvtrm( 513*2,1,2,3,5);
#1000            cvtrm( 767*2,1,2,3,5);
#1000            cvtrm( 768*2,1,2,3,5);
#1000            cvtrm( 769*2,1,2,3,5);
#1000            cvtrm(1023*2,1,2,3,5);
#1000            cvtrm(1024*2,1,2,3,5);
#1000            cvtrm(1025*2,1,2,3,5);
#1000            cvtrm(1035*2,1,2,3,5);
#1000            cvtrm(1036*2,1,2,3,5);
#1000            cvtrm(1037*2,1,2,3,5);
#1000            cvtrm(1050*2,1,2,3,5);



#1000          	`I2CMST.sfrw (`CVOFS01,'d00);//default
	        `I2CMST.sfrw (`CVOFS23,'d00);//default
//==================================DAC1=================================

                `I2CMST.sfrw (`ADOFS,'h7f); // set positive dac1_ofs (+127)
                `I2CMST.sfrw (`ISOFS,'h7f); // set positive Isense_ofs
#1000            set_vin(17420); // (d9)
#1000           `DUT_ANA.v_RT=100; // (0c)

#500_000	`I2CMST.sfrw (`DACEN,'hff); // set ADC
		`I2CMST.sfrw (`SAREN,'hff);
		`I2CMST.sfrw (`DACLSB,'h04);
		`I2CMST.sfrw (`DACCTL,'hcf); // slowest ADC (FPGA case takes longer)
		`I2CMST.sfrw (`CCTRX,'h08); // CS_EN
 
		`DUT_ANA.v_VIN =30_000; // for DACV0 to over flow
		`DUT_ANA.v_CSP =54; // (e1)
#(1000*1000)	`I2CMST.sfrr (`DACV0,'hff); // check over flow
		`I2CMST.sfrr (`DACV3,'h8b);
		`I2CMST.sfrw (`ADOFS,'h81); // set negtive dac1_ofs (-127)
		`I2CMST.sfrr (`DACV0,'h3c);
		`I2CMST.sfrr (`DACV3,'h00); // check under flow
		`DUT_ANA.v_VIN =10_000; // 3e
 
		`I2CMST.sfrr (`DACV2,'hff); // check over flow   
		`DUT_ANA.v_CSP =15; // (3e)
#(1000*1000)	`I2CMST.sfrr (`DACV2,'hbd);
		`I2CMST.sfrw (`ISOFS,'hc0); `I2CMST.sfrr (`DACV2,'h00); // check under flow (-64)
		`I2CMST.sfrw (`ISOFS,'hd0); `I2CMST.sfrr (`DACV2,'h0e); // check under flow (-48)
		`I2CMST.sfrw (`ISOFS,'he0); `I2CMST.sfrr (`DACV2,'h1e); // check under flow (-32)
		`I2CMST.sfrw (`ISOFS,'hf0); `I2CMST.sfrr (`DACV2,'h2e); // check under flow (-16)
		`I2CMST.sfrw (`ISOFS,'h01); `I2CMST.sfrr (`DACV2,'h3f); // check under flow (+1)
		`I2CMST.sfrw (`ISOFS,'h21); `I2CMST.sfrr (`DACV2,'h5f); // check under flow (+33)

		`I2CMST.sfrw (`ADOFS,'h01); // (+1)
		`I2CMST.sfrr (`DACV0,'h3f);
		`I2CMST.sfrr (`DACV3,'h0d);
 //=============================DAC2=================================

#1000           `I2CMST.sfrw(`CCOFS,'h32); // set DAC2_TRIM=+50LSB
                `I2CMST.sfrw(`PWR_I,'d80);   //set PWR_I = 2A
                 if(`DUT_ANA.PWR_I != 'd130) begin
                         $display($time,"ns<%m> Error: PWR_I value isn't 82h");
                   #1000 $finish;
                 end       

#1000           `I2CMST.sfrw(`CCOFS,'hce); // set DAC2_TRIM=-50LSB
                `I2CMST.sfrw(`PWR_I,'d120);  //set PWR_I = 3A
                 if(`DUT_ANA.PWR_I != 'd70) begin
                         $display($time,"ns<%m> Error: PWR_I value isn't 46h");
                   #1000 $finish;
                 end

    
#10000 hw_complete;
end

task cvtrm;
input [11:0] fw_pwrv;
input [3:0] cvofs0,cvofs1,cvofs2,cvofs3;
reg [10:0] tb_dac0code;
reg [5:0] tb_cvofs;
reg [15:0] tb_vin;
begin
#10	tb_dac0code  =   fw_pwrv >'d2047 ?  'd2046 : fw_pwrv;
	tb_cvofs     =  (fw_pwrv >'d2047 ? fw_pwrv[11:1]-'d1023 : 'h0) +
			(fw_pwrv <'d512  ? cvofs0
			:fw_pwrv <'d1024 ? cvofs1
			:fw_pwrv <'d1536 ? cvofs2 : cvofs3);

	`I2CMST.sfrw(`CVOFS01,{cvofs0[3],cvofs1,cvofs0[2:0]});
	`I2CMST.sfrw(`CVOFS23,{cvofs2[3],cvofs3,cvofs2[2:0]});
	`I2CMST.sfrr(`PWRCTL,'hxx);
	`I2CMST.sfrw(`PWRCTL,{`I2CMST.rddat[7:4],fw_pwrv[3:0]});
	`I2CMST.sfrw(`PWR_V,fw_pwrv[11:4]);

	tb_vin = tb_dac0code*10 + tb_cvofs*20;

	$display($time,"ns<%m>start cvtrm test");
	$display($time,"ns<%m>FW set PWRV =%0dV",fw_pwrv*10);
	$display($time,"ns<%m>CVOFS3      =%0d" ,cvofs3);
	$display($time,"ns<%m>tb_dac0     =%0dV",tb_dac0code*10);
	$display($time,"ns<%m>tb_cvofs    =%0dV",tb_cvofs*20);
	$display($time,"ns<%m>tb_VBUS     =%0dV",tb_vin);

	`TP.PB.VBUS.WAIT (tb_vin,1);
	`TP.PB.VBUS.KEEP (tb_vin,1);
end
endtask // cvtrm


task set_vin ;
input [15:0] vin;
reg   [10:0] set_pwrv;
reg    [7:0] rddat;
begin
 set_pwrv=vin/20;
`I2CMST.sfrr(`PWRCTL,'hxx);
 rddat = `I2CMST.rddat;
`I2CMST.sfrw(`PWRCTL,{rddat[7:3],set_pwrv[2:0]});
`I2CMST.sfrw(`PWR_V,set_pwrv[10:3]);
 $display($time,"ns<%m> Set VBUS = %0dmv",vin);
end 
endtask 
wire [7:0] dbg_dacv0 = `DUT_CORE.u0_regbank.dac_r_vs[8*0+:8],
           dbg_dacv1 = `DUT_CORE.u0_regbank.dac_r_vs[8*1+:8],
           dbg_dacv2 = `DUT_CORE.u0_regbank.dac_r_vs[8*2+:8],
           dbg_dacv3 = `DUT_CORE.u0_regbank.dac_r_vs[8*3+:8],
           dbg_dacv4 = `DUT_CORE.u0_regbank.dac_r_vs[8*4+:8],
           dbg_dacv5 = `DUT_CORE.u0_regbank.dac_r_vs[8*5+:8],
           dbg_dacv6 = `DUT_CORE.u0_regbank.dac_r_vs[8*6+:8],
           dbg_dacv7 = `DUT_CORE.u0_regbank.dac_r_vs[8*7+:8];

endmodule

