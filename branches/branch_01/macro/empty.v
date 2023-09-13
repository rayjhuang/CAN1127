
module IODMURUDA_A0( PAD, IE, DI, OE, DO, PU , PD , ANA_R , RSTB_5 , VB );
input IE, OE , DO , PU , PD , VB , RSTB_5;
output DI , ANA_R; // to ADC
inout PAD;
endmodule

module IOBMURUDA_A0( PAD, IE, DI, OE, DO, PU , PD , ANA_R , RSTB_5 , VB );
input IE, OE , DO , PU , PD , VB , RSTB_5;
output DI , ANA_R; // to ADC
inout PAD;
endmodule

module IOBMURUDA_A1( PAD, IE, DI, OE, DO, PU , PD , ANA_R , RSTB_5 , VB , ANA_P );
input IE, OE , DO , PU , PD , VB , RSTB_5 , ANA_P ; // from current source
output DI , ANA_R; // to ADC
inout PAD;
endmodule

module MSL18B_1536X8_RW10TM4_16_20221107 ( DO, CK, CSB, OEB, WEB, A, DI );
output	[7:0]	DO;
input		CK;
input		OEB, CSB;
input		WEB;
input	[10:0]	A;
input	[7:0]	DI;
endmodule

module ATO0008KX8MX180LBX4DA ( A, CSB, CLK, PGM, RE, TWLB, VSS, VDD, VDDP, SAP, Q );
input	[15:0]	A;
input		CSB;
input		CLK;
input		PGM;
input		RE;
input	[1:0]	TWLB;
input		VSS;
input		VDD;
input		VDDP;
input	[1:0]	SAP;
output	[7:0]	Q;
endmodule

