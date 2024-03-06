//----------------------------------------------------------------------------
// Revision history:
// Rev0.3	2021/6/3
//	1. Fixing typo for defining Y address and Q address
// 	2. Fixing reserved_address_warning setup for supporting auto config.
//
// Rev0.2	2021/5/26
// 	1. Adding HaveDummyFlag
//
// Rev0.1       2021/4/26
//      1. Copy test from AT1K64T40LLP7ZA V0.4 and modify the project name and model name
//      2. Remove unused ports
//
//----------------------------------------------------------------------------
// Module Name   : ATO0008KX8MX180LBX4DA 
//----------------------------------------------------------------------------
// Pin List
//		A[numAddr-1:0]: Address (I) 
//		Q: Data output (O)
//		CSB: Chip select, low active (I) 
//		CLK: R/W strobe; signal from system Clock (I) 
//		PGM: Program enable, high active (I) 
//		RE: Read enable , high active (I) 
//		TWLB[1:0]: Turn on even/odd, normal WLs or spare WL (I)
//		SAP[1:0]: Sense Amplifier Pulse modes. Sensing pulse: 00/01 for CLK high, 
//			  10 for long and 11 for short pulses. Not hardwired to any values. Default 10.
//		VDDP: High voltage input pin for program and read (P)
//		VDD: Core supply voltage pins (P)
//		VSS: GND pins (G)
//----------------------------------------------------------------------------
//ReadMe: 1. When back annotation , please define "SET_ANNOTATE".
//        2. Load OTP data from loadfile.txt, please define "SET_LOADFILE".
//           example: ncverilog  <verilogfilename> +define+SET_ANNOTATE
//                 vcs <verilogfilename> +define+SET_ANNOTATE
//
//loadfile.txt bit map format in hexadecimal
//Please refer to loadfile.txt generate from the gen_loadfile task in the testbench.
//                           Q = A[9:5]
//                                          Col=A[4:0]
//                              A[4:0]=5'h1f    ...    A[4:0]=5'h00
//              A[15:10]=6'h00  . . . . . . . . . . . . .
//                              . Q
//                              .   Q
//      Row=A[15:10]        ... .     Q
//                              .       
//                              .         
//              A[15:10]=6'h3f  .     
//         redundant_row_bank_0 .
//----------------------------------------------------------------------------

`timescale 1ns/10ps

module ATO0008KX8MX180LBX4DA( A, CSB, CLK, PGM, RE, TWLB, VDDP, VSS, VDD, SAP, Q );

`include "ATO0008KX8MX180LBX4DA_parameter.txt"

input[numAddr-1:0] A;
input CSB;
input CLK;
input PGM; 
input RE;
//input HDRON;
	wire HDRON = PGM; // No HDRON i/o
input [1:0] TWLB;
	//wire [1:0] TWLB = 2'b00; // No TWLB i/o
input VDDP;
input VSS;
input VDD;
input [1:0] SAP;
	//wire [1:0] SAP = 2'b10; // No SAP i/o
//input [1:0] MR;
	wire [1:0] MR = 2'b00; // No MR i/o
//input VDD_OK;
	wire VDD_OK = 1'b0; // No VDD_OK i/o
//input [15:0] D; //enable PGM or not
	wire [15:0] D = 16'h0000; // No D i/o
//input TP1C;
	wire TP1C = 1'b1; // No TP1C i/o

//input TM;
//input RESET12N;
//input RESET28N;

output [numQBIT-1:0] Q;
//reg [numQBIT-1:0] Q;
wire [numQBIT-1:0] Q;

`ifdef EMPTY
`else
reg [numQBIT_QD-1:0] otpCell_normal_0[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_0[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_1[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_1[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_2[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_2[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_3[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_3[0:numY-1];
// Added by Thomas 2021-4-6 for supporting 1-to-4 ROWs by 1-to-4 COLUMNs configuration 
reg [numQBIT_QD-1:0] otpCell_normal_4[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_4[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_5[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_5[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_6[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_6[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_7[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_7[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_8[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_8[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_9[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_9[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_10[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_10[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_11[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_11[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_12[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_12[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_13[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_13[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_14[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_14[0:numY-1];
reg [numQBIT_QD-1:0] otpCell_normal_15[0:numX-1][0:numY-1];
reg [numQBIT_QD-1:0] otpCell_redundant_15[0:numY-1];

/* control signal check*/
wire [5:0] control_set; //{VDD,VDDP,CSB,PGM,RE,HDRON}
reg[3:0] mode_err;
reg silent_st;     // flag to inhibit timing check during starting up
wire PROGRAM = mode_err[2];
wire READ = mode_err[1];    
wire STANDBY = mode_err[0];  
wire DEEPSLEEP = mode_err[3];  

wire RE_one = RE;
wire RE_zero = !RE;
wire PGM_one = PGM;
wire PGM_zero = !PGM;
wire PGMB_RE = !PGM && RE;
wire PGM_REB = PGM && !RE;
wire PGM_REB_TP1CB = PGM && !RE && !TP1C;
wire CS_RE = !CSB && RE;
wire CSB_RE = CSB && RE;
wire CS_PGMB_RE = !CSB && !PGM && RE;
wire CS_PGM_REB = !CSB && PGM && !RE;
wire CS_PGM_REB_TP1CB = !CSB && PGM && !RE && !TP1C;
//wire CSB_TMB = CSB && !TM;
wire tm_CSB_PGMB =  CSB && !PGM;    // use for tm mode check
//wire RS12N_CS_CSB_TMB = RESET12N && !CSB && PGM && !TM;
//wire RS28N_CS_CSB_TMB = RESET28N && !CSB && PGM && !TM;
//wire TM_CSB_REB = TM && CSB && !RE;

wire [numQBIT-1:0] Qx = Gen_multiBits(1'bx);   //Gen_multiBits is a function
wire [numQBIT-1:0] Q0 = Gen_multiBits(1'b0);
wire [numQBIT-1:0] Q1 = Gen_multiBits(1'b1);

wire [numAQ-1:0] A_BIT;
wire [numAY-1:0] A_Y;
wire [numAX-1:0] A_X;
wire normal_access;
wire redundant_access;
wire odd_access;
wire even_access;
wire reserved_address_warning;
//wire [2:0] bank_set; //{TP1C, A[10], A[9]}
wire [5:0] bank_set; //{TP1C, 1'b0, 1'b0, A[10], A[9]}
//reg [3:0] D_IN;	// Modified for supporting 1-to-4 ROWs by 1-to-4 COLUMNs; by Thomas 2021-4-6
//wire [31:0] Q_UP;	// Modified for supporting 1-to-4 ROWs by 1-to-4 COLUMNs; by Thomas 2021-4-6
//wire [31:0] Q_DN;	// Modified for supporting 1-to-4 ROWs by 1-to-4 COLUMNs; by Thomas 2021-4-6
reg [15:0] D_IN;
wire [63:0] Q_UP;
wire [63:0] Q_DN;

assign normal_access = (TWLB[1:0] == 2'b00);
assign redundant_access = (TWLB[1:0] == 2'b11);
// reserve address check or not (sc)
//assign reserved_address_warning = (TWLB[1:0] == 2'b11) && ((A_Y== 6'b111111)|(A_Y== 6'b111110)) && Reserve_address_en; // Modified by Thomas 2021_0603 for supporting auto config.
assign reserved_address_warning = (TWLB[1:0] == 2'b11) && ((A_Y== {numAY{1'b1}})|(A_Y== { {numAY-1{1'b1}}, 1'b0})) && Reserve_address_en;
assign odd_access = (TWLB[1:0] == 2'b01);
assign even_access= (TWLB[1:0] == 2'b10);
//assign A_BIT = A[AQ_start:AQ_end]; // Modified by Thomas 2021-4-22 for supporting single QD without D input
assign A_BIT = (AQ_start==AQ_end) ? 0 : A[AQ_start:AQ_end];
//assign A_Y = A[AY_start:AY_end]; // Modified by Thomas 2021-4-22 for supporting single QD without D input
assign A_Y = (AY_start==AY_end) ? 0 : A[AY_start:AY_end];
//assign A_X = A[AX_start:AX_end]; // Modified by Thomas 2021-4-22 for supporting single QD without D input
assign A_X = (AX_start==AX_end) ? 0 : A[AX_start:AX_end];

// reset12n,reset28n,TM timing check
reg notify_en;    //eliminate initial false timing check

reg notify_r1s;
reg notify_r1h;
reg notify_r2s;
reg notify_r2h;

// New parameter for avoid programming during power up and down <Begin>, added by Thomas, 2021-4-1
reg notify_csiH;	// Controls {(PGM=0 or CLK=0) and HDRON=0} to VDD_OK setup time
reg notify_chiH;	// Controls {(PGM=0 or CLK=0) and HDRON=0} to VDD_OK hold time
reg notify_csiC;	// Controls {(PGM=0 or CLK=0) and HDRON=0} to VDD_OK setup time
reg notify_chiC;	// Controls {(PGM=0 or CLK=0) and HDRON=0} to VDD_OK hold time
reg notify_csiP;	// Controls {(PGM=0 or CLK=0) and HDRON=0} to VDD_OK setup time
reg notify_chiP;	// Controls {(PGM=0 or CLK=0) and HDRON=0} to VDD_OK hold time
reg notify_psi;		// VDDP to VDD_OK setup time
reg notify_phi;		// VDDP to VDD_OK hold time
// New parameter for avoid programming during power up and down <End>, added by Thomas, 2021-4-1

reg notify_ts;
reg notify_th;

reg notify_hsr;  //HDRON to CSB setup for read mode
reg notify_hhr;  //HDRON to CSB hold for read mode
reg notify_hsp;  //HDRON to CSB setup for program mode
reg notify_hhp;  //HDRON to CSB hold for program mode

reg notify_vsr;  //VDDP to CSB setup for read mode
reg notify_vhr;  //VDDP to CSB hold for read mode
reg notify_vsp;  //VDDP to CSB setup for program mode
reg notify_vhp;  //VDDP to CSB hold for program mode

reg notify_ahr;  //ADDR to CSB hold for read mode
reg notify_asr;  //ADDR to CSB setup for read mode
reg notify_ahrTWLB;  //ADDR to CSB hold for read mode
reg notify_asrTWLB;  //ADDR to CSB setup for read mode

reg notify_aspA;  //ADDR to CSB setup for program mode
reg notify_ahpA;  //ADDR to CSB hold for program mode 
reg notify_aspTWLB;  //TWLB to CSB setup for program mode
reg notify_ahpTWLB;  //TWLB to CSB hold for program mode 
reg notify_aspD;  //D to CSB setup for program mode
reg notify_ahpD;  //D to CSB hold for program mode 

reg notify_wsr;  //PGM to CSB setup for read mode
reg notify_whr;   //PGM to CSB hold for read mode
reg notify_wsp;  //PGM to CSB setup time for programm mode
reg notify_whp;  //PGM to CSB hold time for programm mode

reg notify_rsr;   //RE to CSB setup for read mode
reg notify_rhr;    //RE to CSB hold for read mode
reg notify_rhp;    //RE to CSB hold for program mode
reg notify_rsp;   //RE to CSB setup for program mode  

reg notify_ckl;  //CLK pilse low width
reg notify_cyr;  //CLK period
reg notify_ckh;  //CLK pilse peak width

reg notify_ras;   //ADDR to CLK rising edge setup time for read mode 
reg notify_rah;   //ADDR to CLK rising edge hold time for read mode   
reg notify_rasTWLB;   //TWLB to CLK rising edge setup time for read mode 
reg notify_rahTWLB;   //TWLB to CLK rising edge hold time for read mode   

reg notify_sspA;   //ADDR to CLK setup time for program mode
reg notify_shpA;   //ADDR to CLK hold time for program mode
reg notify_sspTWLB;   //TWLB to CLK setup time for program mode
reg notify_shpTWLB;   //TWLB to CLK hold time for program mode
reg notify_sspD;   //D to CLK setup time for program mode
reg notify_shpD;   //D to CLK hold time for program mode
reg notify_sw;   //CLK pulse width
reg notify_swm;   //CLK pulse width
reg DUMMY_FLAG;
//wire [numQBIT-1:0] Qm; // Modified by Thomas 2021-4-12
reg [numQBIT-1:0] Qm;
//reg [numQBIT_QD-1:0] Qm_0,Qm_1,Qm_2,Qm_3;	// Added by Thomas for supporting 1-to-4 ROWs by 1-to-4 COLUMNs 
reg [numQBIT_QD-1:0] Qm_0,Qm_1,Qm_2,Qm_3,Qm_4,Qm_5,Qm_6,Qm_7,Qm_8,Qm_9,Qm_10,Qm_11,Qm_12,Qm_13,Qm_14,Qm_15;
wire [numQBIT_QD-1:0] Qm_4R1C;
reg [numQBIT-1:0] Qe;  // output in end of read cycle
time CLK_r;
time time_CLKH;
//To specify Q delay
wire CLK_Thold; // output hold after CLK high 
wire CLK_Tcd;   // output after CLK high, Tcd>Thold
reg [numQBIT-1:0] Qt; // output in transition read cycle bet'w Thold to Tcd
/*timing violation check*/
specify 

	//Timing check for avoid programming during power up and down <Begin>, added by Thomas, 2021-4-1
		specparam Tcs_pi = 10_000.000000;
		specparam Tch_pi = 10_100.000000;
		specparam Tps_pi = 10_100.000000;
		specparam Tph_pi = 10_100.000000;

/*	// VDD_OK timing check
	$setup(negedge HDRON, posedge VDD_OK, Tcs_pi, notify_csiH);
	$hold(negedge VDD_OK, posedge HDRON, Tch_pi, notify_chiH);
	$setup(negedge PGM, posedge VDD_OK, Tcs_pi, notify_csiP);
	$hold(negedge VDD_OK, posedge PGM, Tch_pi, notify_chiP);
	$setup(negedge CLK, posedge VDD_OK, Tcs_pi, notify_csiC);
	$hold(negedge VDD_OK, posedge CLK, Tch_pi, notify_chiC);
	$setup(posedge VDDP, posedge VDD_OK, Tps_pi, notify_psi);
	$hold(negedge VDD_OK, negedge VDDP, Tph_pi, notify_phi);
*/	//Timing check for avoid programming during power up and down <End>, added by Thomas, 2021-4-1

	//Timing check for PROGRAM 
        //specparam Tr1s_pp = 100.000000;
       	//specparam Tr1h_pp = 100.000000;
        //specparam Tr2s_pp = 100.000000;
        //specparam Tr2h_pp = 100.000000;

		specparam Ths_pp = 3_000.000000;  //sc
		specparam Thh_pp = 3_000.000000;  //sc       
        specparam Tvs_pp = 10_000.000000;   //sc
        specparam Tvh_pp = 1_000.000000;    //sc
        specparam Tas_pp = 10.000000;
        specparam Tah_pp = 10.000000;
        specparam Tws_pp = 10.000000;
        specparam Twh_pp = 10.000000;
        specparam Trs_pp = 10.000000;
        specparam Trh_pp = 10.000000;
        specparam Tss_pp = 7.000000;
        specparam Tsh_pp = 7.000000;
        specparam Tsw_min_pp = 9000.000000;
        specparam Tsw_max_pp = 11000.000000;

// reset, TM timing check
//	$setup(posedge RESET12N, posedge PGM &&& CSB_TMB, Tr1s_pp, notify_r1s); 
//	$setup(posedge RESET28N, posedge PGM &&& CSB_TMB, Tr2s_pp, notify_r2s); 
//	$hold(negedge PGM &&& CSB_TMB, negedge RESET12N, Tr1h_pp, notify_r1h); 
//	$hold(negedge PGM &&& CSB_TMB, negedge RESET28N, Tr2h_pp, notify_r2h); 

// VDDP timing check
	//$setup(posedge HDRON, negedge CSB , Ths_pp, notify_hsp); 
	//$hold(posedge CSB , negedge HDRON, Thh_pp, notify_hhp); 
	$setup(posedge VDDP, negedge CSB &&& PGM_one, Tvs_pp, notify_vsp); 
	$hold(posedge CSB &&& PGM_one, negedge VDDP, Tvh_pp, notify_vhp); 

	$setup(posedge PGM, negedge CSB &&& RE_zero, Tws_pp, notify_wsp); 
	$setup(negedge RE, negedge CSB &&& PGM_one, Trs_pp, notify_rsp); 

	$setup(negedge CSB, posedge A[0] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[0] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[1] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[1] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[2] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[2] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[3] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[3] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[4] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[4] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[5] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[5] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[6] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[6] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[7] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[7] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[8] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[8] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[9] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[9] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[10] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[10] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[11] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[11] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[12] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[12] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[13] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[13] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[14] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[14] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[15] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[15] &&& PGM_REB, Tas_pp, notify_aspA);
/*	$setup(negedge CSB, posedge A[16] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[16] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[17] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[17] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[18] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[18] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, posedge A[19] &&& PGM_REB, Tas_pp, notify_aspA);
	$setup(negedge CSB, negedge A[19] &&& PGM_REB, Tas_pp, notify_aspA);
*/	$setup(negedge CSB, posedge TWLB[0] &&& PGM_REB, Tas_pp, notify_aspTWLB);
	$setup(negedge CSB, negedge TWLB[0] &&& PGM_REB, Tas_pp, notify_aspTWLB);
	$setup(negedge CSB, posedge TWLB[1] &&& PGM_REB, Tas_pp, notify_aspTWLB);
	$setup(negedge CSB, negedge TWLB[1] &&& PGM_REB, Tas_pp, notify_aspTWLB);

   	$setup(posedge A[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[2], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[2], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[3], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[3], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[4], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[4], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[5], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[5], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[6], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[6], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[7], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[7], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[8], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[8], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[9], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[9], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[10], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[10], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[11], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[11], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[12], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[12], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[13], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[13], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[14], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[14], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[15], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[15], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
/*   	$setup(posedge A[16], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[16], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[17], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[17], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[18], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[18], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge A[19], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(negedge A[19], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspA);
   	$setup(posedge D[0], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[0], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[1], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[1], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[2], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[2], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[3], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[3], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[4], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[4], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[5], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[5], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[6], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[6], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[7], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[7], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[8], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[8], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[9], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[9], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[10], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[10], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[11], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[11], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[12], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[12], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[13], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[13], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[14], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[14], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(posedge D[15], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
   	$setup(negedge D[15], posedge CLK &&& CS_PGM_REB_TP1CB, Tss_pp, notify_sspD);
*/   	$setup(posedge TWLB[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspTWLB);
   	$setup(negedge TWLB[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspTWLB);
   	$setup(posedge TWLB[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspTWLB);
   	$setup(negedge TWLB[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_sspTWLB);

	$width(posedge CLK &&& CS_PGM_REB, Tsw_min_pp, 0, notify_sw);
	//$width(posedge CLK &&& CS_PGM_REB, Tsw_min_pp, Tsw_max_pp, notify_sw);


	$hold(negedge CLK &&& CS_PGM_REB, posedge A[0], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[0], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[1], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[1], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[2], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[2], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[3], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[3], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[4], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[4], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[5], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[5], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[6], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[6], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[7], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[7], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[8], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[8], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[9], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[9], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[10], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[10], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[11], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[11], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[12], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[12], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[13], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[13], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[14], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[14], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[15], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[15], Tsh_pp, notify_shpA);
/*	$hold(negedge CLK &&& CS_PGM_REB, posedge A[16], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[16], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[17], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[17], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[18], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[18], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[19], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[19], Tsh_pp, notify_shpA);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[0], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[0], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[1], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[1], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[2], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[2], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[3], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[3], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[4], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[4], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[5], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[5], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[6], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[6], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[7], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[7], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[8], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[8], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[9], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[9], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[10], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[10], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[11], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[11], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[12], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[12], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[13], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[13], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[14], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[14], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, posedge D[15], Tsh_pp, notify_shpD);
	$hold(negedge CLK &&& CS_PGM_REB_TP1CB, negedge D[15], Tsh_pp, notify_shpD);
*/	$hold(negedge CLK &&& CS_PGM_REB, posedge TWLB[0], Tsh_pp, notify_shpTWLB);
	$hold(negedge CLK &&& CS_PGM_REB, negedge TWLB[0], Tsh_pp, notify_shpTWLB);
	$hold(negedge CLK &&& CS_PGM_REB, posedge TWLB[1], Tsh_pp, notify_shpTWLB);
	$hold(negedge CLK &&& CS_PGM_REB, negedge TWLB[1], Tsh_pp, notify_shpTWLB);

	$hold(posedge A[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[2] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[2] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[3] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[3] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[4] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[4] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[5] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[5] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[6] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[6] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[7] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[7] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[8] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[8] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[9] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[9] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[10] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[10] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[11] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[11] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[12] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[12] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[13] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[13] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[14] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[14] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[15] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[15] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
/*	$hold(posedge A[16] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[16] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[17] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[17] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[18] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[18] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(posedge A[19] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
	$hold(negedge A[19] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpA);
*/	$hold(posedge TWLB[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpTWLB);
	$hold(negedge TWLB[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpTWLB);
	$hold(posedge TWLB[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpTWLB);
	$hold(negedge TWLB[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahpTWLB);

	$hold(posedge CSB &&& RE_zero, negedge PGM, Twh_pp, notify_whp);
	$hold(posedge CSB &&& PGM_one, posedge RE, Trh_pp, notify_rhp);

	//Timing check for READ 
	        specparam Ths_pr = 11_000.000000;  //sc	(HDRON)
        	specparam Thh_pr = 11_000.000000;  //sc	(HDRON)
    	specparam Tvs_pr = 10_000.000000;   //sc
        specparam Tvh_pr = 1_000.000000;    //sc
        specparam Tas_pr = 10.000000;
        specparam Tah_pr = 10.000000;
        specparam Tws_pr = 10.000000;
        specparam Twh_pr = 10.000000;
        specparam Trs_pr = 10.000000;
        specparam Trh_pr = 10.000000;
        specparam Tqh_pr = 0.000000;
        specparam Tcyc = 50.000000; //
        specparam Tckh = 25.000000; //
        specparam Tckl = 25.000000; //
        specparam Tras = 7.000000;
        specparam Trah = 7.000000;
        specparam Tcd =  7.000000; //
        specparam Thold = 5.000000;


//VDDP timing check
	//$setup(negedge HDRON, negedge CSB , Ths_pr, notify_hsr); 
	//$hold(posedge CSB , posedge HDRON, Thh_pr, notify_hhr); 
	$setup(negedge VDDP, negedge CSB &&& RE_one, Tvs_pr, notify_vsr); 
	$hold(posedge CSB &&& RE_one, posedge VDDP, Tvh_pr, notify_vhr); 

	$setup(negedge PGM, negedge CSB &&& RE_one, Tws_pr, notify_wsr); 
	$setup(posedge RE, negedge CSB &&& PGM_zero, Trs_pr, notify_rsr); 

	$setup(negedge CSB, posedge A[0] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[0] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[1] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[1] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[2] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[2] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[3] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[3] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[4] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[4] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[5] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[5] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[6] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[6] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[7] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[7] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[8] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[8] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[9] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[9] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[10] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[10] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[11] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[11] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[12] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[12] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[13] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[13] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[14] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[14] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[15] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[15] &&& PGMB_RE, Tas_pr, notify_asr);
/*	$setup(negedge CSB, posedge A[16] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[16] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[17] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[17] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[18] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[18] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge A[19] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge A[19] &&& PGMB_RE, Tas_pr, notify_asr);
*/	$setup(negedge CSB, posedge TWLB[0] &&& PGMB_RE, Tas_pr, notify_asrTWLB);
	$setup(negedge CSB, negedge TWLB[0] &&& PGMB_RE, Tas_pr, notify_asrTWLB);
	$setup(negedge CSB, posedge TWLB[1] &&& PGMB_RE, Tas_pr, notify_asrTWLB);
	$setup(negedge CSB, negedge TWLB[1] &&& PGMB_RE, Tas_pr, notify_asrTWLB);

    	$setup(posedge A[0], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[0], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[1], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[1], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[2], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[2], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[3], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[3], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[4], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[4], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[5], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[5], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[6], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[6], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[7], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[7], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[8], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[8], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[9], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[9], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[10], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[10], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[11], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[11], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[12], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[12], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[13], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[13], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[14], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[14], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[15], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[15], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
/*    	$setup(posedge A[16], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[16], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[17], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[17], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[18], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[18], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge A[19], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge A[19], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
*/    	$setup(posedge TWLB[0], posedge CLK &&& CS_PGMB_RE, Tras, notify_rasTWLB);
    	$setup(negedge TWLB[0], posedge CLK &&& CS_PGMB_RE, Tras, notify_rasTWLB);
    	$setup(posedge TWLB[1], posedge CLK &&& CS_PGMB_RE, Tras, notify_rasTWLB);
    	$setup(negedge TWLB[1], posedge CLK &&& CS_PGMB_RE, Tras, notify_rasTWLB);

	$width(posedge CLK &&& CS_PGMB_RE, Tckh, 0, notify_ckh);
	$width(negedge CLK &&& CS_PGMB_RE, Tckl, 0, notify_ckl);
	$period(posedge CLK &&& CS_PGMB_RE, Tcyc, notify_cyr);
	$period(negedge CLK &&& CS_PGMB_RE, Tcyc, notify_cyr);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[0], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[0], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[1], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[1], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[2], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[2], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[3], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[3], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[4], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[4], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[5], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[5], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[6], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[6], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[7], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[7], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[8], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[8], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[9], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[9], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[10], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[10], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[11], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[11], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[12], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[12], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[13], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[13], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[14], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[14], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[15], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[15], Trah, notify_rah);
/*	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[16], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[16], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[17], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[17], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[18], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[18], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[19], Trah, notify_rah);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[19], Trah, notify_rah);
*/	$hold(negedge CLK &&& CS_PGMB_RE, posedge TWLB[0], Trah, notify_rahTWLB);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge TWLB[0], Trah, notify_rahTWLB);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge TWLB[1], Trah, notify_rahTWLB);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge TWLB[1], Trah, notify_rahTWLB);

	$hold(posedge A[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[2] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[2] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[3] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[3] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[4] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[4] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[5] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[5] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[6] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[6] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[7] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[7] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[8] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[8] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[9] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[9] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[10] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[10] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[11] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[11] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[12] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[12] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[13] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[13] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[14] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[14] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[15] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[15] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
/*	$hold(posedge A[16] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[16] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[17] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[17] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[18] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[18] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(posedge A[19] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
	$hold(negedge A[19] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahr);
*/	$hold(posedge TWLB[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahrTWLB);
	$hold(negedge TWLB[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahrTWLB);
	$hold(posedge TWLB[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahrTWLB);
	$hold(negedge TWLB[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_ahrTWLB);

	$hold(posedge CSB &&& PGM_zero, negedge RE, Trh_pr, notify_rhr);
	$hold(posedge CSB &&& RE_one, posedge PGM, Twh_pr, notify_whr);

	//define Tcd, Thold, Tqh_pr delay
  	if (PGMB_RE) (posedge CSB => (Q[0] +: Qe[0])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[1] +: Qe[1])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[2] +: Qe[2])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[3] +: Qe[3])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[4] +: Qe[4])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[5] +: Qe[5])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[6] +: Qe[6])) = Tqh_pr;  //parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[7] +: Qe[7])) = Tqh_pr;  //parallel connection 
/*    	if (PGMB_RE) (posedge CSB => (Q[8] +: Qe[8])) = Tqh_pr;  //parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[9] +: Qe[9])) = Tqh_pr;  //parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[10] +: Qe[10])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[11] +: Qe[11])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[12] +: Qe[12])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[13] +: Qe[13])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[14] +: Qe[14])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[15] +: Qe[15])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[16] +: Qe[16])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[17] +: Qe[17])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[18] +: Qe[18])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[19] +: Qe[19])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[20] +: Qe[20])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[21] +: Qe[21])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[22] +: Qe[22])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[23] +: Qe[23])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[24] +: Qe[24])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[25] +: Qe[25])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[26] +: Qe[26])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[27] +: Qe[27])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[28] +: Qe[28])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[29] +: Qe[29])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[30] +: Qe[30])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[31] +: Qe[31])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[32] +: Qe[32])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[33] +: Qe[33])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[34] +: Qe[34])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[35] +: Qe[35])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[36] +: Qe[36])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[37] +: Qe[37])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[38] +: Qe[38])) = Tqh_pr;//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[39] +: Qe[39])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[40] +: Qe[40])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[41] +: Qe[41])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[42] +: Qe[42])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[43] +: Qe[43])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[44] +: Qe[44])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[45] +: Qe[45])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[46] +: Qe[46])) = Tqh_pr;//parallel connection 
    	if (PGMB_RE) (posedge CSB => (Q[47] +: Qe[47])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[48] +: Qe[48])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[49] +: Qe[49])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[50] +: Qe[50])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[51] +: Qe[51])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[52] +: Qe[52])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[53] +: Qe[53])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[54] +: Qe[54])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[55] +: Qe[55])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[56] +: Qe[56])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[57] +: Qe[57])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[58] +: Qe[58])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[59] +: Qe[59])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[60] +: Qe[60])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[61] +: Qe[61])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[62] +: Qe[62])) = Tqh_pr;//parallel connection 
        if (PGMB_RE) (posedge CSB => (Q[63] +: Qe[63])) = Tqh_pr;//parallel connection 
*/
	//Thold:
	if (CSB_RE) (posedge CLK => (Q[0] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[1] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[2] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[3] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[4] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[5] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[6] +: Qx)) = Thold;	// parallel connection
	if (CSB_RE) (posedge CLK => (Q[7] +: Qx)) = Thold;	// parallel connection

	//Tcd: data out after CLK high are changed to after CLK low by Thomas 2021-04-28
	if (CSB_RE) (negedge CLK => (Q[0] +: Qm[0])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[1] +: Qm[1])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[2] +: Qm[2])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[3] +: Qm[3])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[4] +: Qm[4])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[5] +: Qm[5])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[6] +: Qm[6])) = Tcd; // negedge para connection
	if (CSB_RE) (negedge CLK => (Q[7] +: Qm[7])) = Tcd; // negedge para connection
/*	if (CS_RE) (posedge CLK => (Q[8] +: Qm[8])) = (Tcd,Tcd,Thold);	// negedge para connection
	if (CS_RE) (posedge CLK => (Q[9] +: Qm[9])) = (Tcd,Tcd,Thold);	// negedge para connection
	if (CS_RE) (posedge CLK => (Q[10] +: Qm[10])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[11] +: Qm[11])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[12] +: Qm[12])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[13] +: Qm[13])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[14] +: Qm[14])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[15] +: Qm[15])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[16] +: Qm[16])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[17] +: Qm[17])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[18] +: Qm[18])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[19] +: Qm[19])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[20] +: Qm[20])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[21] +: Qm[21])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[22] +: Qm[22])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[23] +: Qm[23])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[24] +: Qm[24])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[25] +: Qm[25])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[26] +: Qm[26])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[27] +: Qm[27])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[28] +: Qm[28])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[29] +: Qm[29])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[30] +: Qm[30])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[31] +: Qm[31])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[32] +: Qm[32])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[33] +: Qm[33])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[34] +: Qm[34])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[35] +: Qm[35])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[36] +: Qm[36])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[37] +: Qm[37])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[38] +: Qm[38])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[39] +: Qm[39])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[40] +: Qm[40])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[41] +: Qm[41])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[42] +: Qm[42])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[43] +: Qm[43])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[44] +: Qm[44])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[45] +: Qm[45])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[46] +: Qm[46])) = (Tcd,Tcd,Thold);// negedge para connection
	if (CS_RE) (posedge CLK => (Q[47] +: Qm[47])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[48] +: Qm[48])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[49] +: Qm[49])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[50] +: Qm[50])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[51] +: Qm[51])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[52] +: Qm[52])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[53] +: Qm[53])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[54] +: Qm[54])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[55] +: Qm[55])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[56] +: Qm[56])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[57] +: Qm[57])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[58] +: Qm[58])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[59] +: Qm[59])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[60] +: Qm[60])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[61] +: Qm[61])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[62] +: Qm[62])) = (Tcd,Tcd,Thold);// negedge para connection
        if (CS_RE) (posedge CLK => (Q[63] +: Qm[63])) = (Tcd,Tcd,Thold);// negedge para connection
*/
endspecify 

integer i, j, m;
/* initial clear cells*/
initial begin
        notify_r1s = 0;
        notify_r1h = 0;
        notify_r2s = 0;
        notify_r2s = 0;

	// new power control avoid programming during power up and down <begin>, added by Thomas, 2021-4-1 
	notify_csiH = 0;
	notify_chiH = 0;
	notify_csiP = 0;
	notify_chiP = 0;
	notify_csiC = 0;
	notify_chiC = 0;
	notify_psi = 0;
	notify_phi = 0;
	// new power control avoid programming during power up and down <end>, added by Thomas, 2021-4-1 

        notify_ts = 0;
        notify_th = 0;
        notify_en = 0;

        notify_hsr = 0;
        notify_hhr = 0;
        notify_vsr = 0;
        notify_vhr = 0;
        notify_asr = 0;
        notify_ahr = 0;
        notify_wsr = 0;
        notify_whr = 0;
        notify_rsr = 0;
        notify_rhr = 0;
        notify_cyr = 0;
        notify_ckh = 0;
        notify_ckl = 0;
        notify_ras = 0;
        notify_rah = 0;
        notify_hsp = 0;
        notify_hhp = 0;
        notify_vsp = 0;
        notify_vhp = 0;
        notify_aspA = 0;
        notify_aspD = 0;
        notify_aspTWLB = 0;
	notify_ahpA = 0;
	notify_ahpD = 0;
	notify_ahpTWLB = 0;
        notify_wsp = 0;
        notify_whp = 0;
        notify_rsp = 0;
        notify_rhp = 0;
        notify_sspA = 0;
        notify_sspD = 0;
        notify_sspTWLB = 0;
        notify_shpA = 0;
        notify_shpD = 0;
        notify_shpTWLB = 0;
        notify_sw = 0;
	notify_swm = 0;
	DUMMY_FLAG = (HaveDummyFlag) ? 0 : 1; 
	#0.1 notify_en = 1;    //flag to inhibit timing check during initiation

	//clear main array 
	//for (i=0; i < 2**numAX; i=i +1)begin // Modified by Thomas 2021-4-22 for supporting single QD without D input
	for (i=0; i <2**(numAX-NoAddrAX); i=i +1)begin	
		//for (j=0; j < 2**numAY; j=j+1)begin    // Modified by Thomas 2021-4-22 for supporting single QD without D input
		for (j=0; j<2**(numAY-NoAddrAY); j=j+1)begin
			for (m=0; m < numQBIT_QD; m=m+1) begin
	   			otpCell_normal_0[i][j][m] = 1'b0;
	   			otpCell_normal_1[i][j][m] = 1'b0;
	   			otpCell_normal_2[i][j][m] = 1'b0;
	   			otpCell_normal_3[i][j][m] = 1'b0;
	   			otpCell_normal_4[i][j][m] = 1'b0;
	   			otpCell_normal_5[i][j][m] = 1'b0;
	   			otpCell_normal_6[i][j][m] = 1'b0;
	   			otpCell_normal_7[i][j][m] = 1'b0;
	   			otpCell_normal_8[i][j][m] = 1'b0;
	   			otpCell_normal_9[i][j][m] = 1'b0;
	   			otpCell_normal_10[i][j][m] = 1'b0;
	   			otpCell_normal_11[i][j][m] = 1'b0;
	   			otpCell_normal_12[i][j][m] = 1'b0;
	   			otpCell_normal_13[i][j][m] = 1'b0;
	   			otpCell_normal_14[i][j][m] = 1'b0;
	   			otpCell_normal_15[i][j][m] = 1'b0;
			end
		end
	end
	//clear redundant array 
	//for (j=0; j < 2**numAY; j=j+1)begin    // Modified by Thomas 2021-4-22 for supporting single QD without D input
	for (j=0; j<2**(numAY-NoAddrAY); j=j+1)begin
        	for (m=0; m < numQBIT_QD; m=m+1) begin
                	otpCell_redundant_0[j][m] = 1'b0;
                	otpCell_redundant_1[j][m] = 1'b0;
                	otpCell_redundant_2[j][m] = 1'b0;
                	otpCell_redundant_3[j][m] = 1'b0;
                	otpCell_redundant_4[j][m] = 1'b0;
                	otpCell_redundant_5[j][m] = 1'b0;
                	otpCell_redundant_6[j][m] = 1'b0;
                	otpCell_redundant_7[j][m] = 1'b0;
                	otpCell_redundant_8[j][m] = 1'b0;
                	otpCell_redundant_9[j][m] = 1'b0;
                	otpCell_redundant_10[j][m] = 1'b0;
                	otpCell_redundant_11[j][m] = 1'b0;
                	otpCell_redundant_12[j][m] = 1'b0;
                	otpCell_redundant_13[j][m] = 1'b0;
                	otpCell_redundant_14[j][m] = 1'b0;
                	otpCell_redundant_15[j][m] = 1'b0;
            	end
    	end
	silent_st = 0;
	`ifdef  SET_LOADFILE
		loadfile2otp;
	`endif
        #500;
end


//Timing check for avoid programming during power up and down <Begin>, added by Thomas, 2021-4-1
always @(notify_csiH) begin
	if(notify_en && HaveVDD_OK) $display("@%.2fns: Tcs_pi: HDRON to VDD_OK setup time violation!!\n",$realtime);
	if(notify_en && HaveVDD_OK && ((PGM && CLK) || HDRON) ) $display("@%.2fns: Tcs_pi: program access is not allowed!!\n",$realtime); 
end

always @(notify_csiP) begin
	if(notify_en && HaveVDD_OK) $display("@%.2fns: Tcs_pi: PGM to VDD_OK setup time violation!!\n",$realtime);
	if(notify_en && HaveVDD_OK && ((PGM && CLK) || HDRON) ) $display("@%.2fns: Tcs_pi: program access is not allowed!!\n",$realtime); 
end

always @(notify_csiC) begin
	if(notify_en && HaveVDD_OK) $display("@%.2fns: Tcs_pi: CLK to VDD_OK setup time violation!!\n",$realtime);
	if(notify_en && HaveVDD_OK && ((PGM && CLK) || HDRON) ) $display("@%.2fns: Tcs_pi: program access is not allowed!!\n",$realtime); 
end

always @(notify_psi) begin
	if(notify_en && HaveVDD_OK) $display("@%.2fns: Tps_pi: VDDP to VDD_OK setup time violation!!\n",$realtime);
	if(notify_en && HaveVDD_OK && !VDDP) $display("@%.2fns: Tps_pi: VDDP is not turned on!!\n",$realtime);
end

always @(notify_chiH) begin
	if(notify_en && HaveVDD_OK) $display("@%.2fns: Tch_pi: HDRON to VDD_OK hold time violation!!\n",$realtime);
	if(notify_en && HaveVDD_OK && ((PGM && CLK) || HDRON) ) $display("@%.2fns: Tch_pi: program access is not allowed!!\n",$realtime);
end

always @(notify_chiP) begin
        if(notify_en && HaveVDD_OK) $display("@%.2fns: Tch_pi: PGM to VDD_OK hold time violation!!\n",$realtime);
        if(notify_en && HaveVDD_OK && ((PGM && CLK) || HDRON) ) $display("@%.2fns: Tch_pi: program access is not allowed!!",$realtime);
end

always @(notify_chiC) begin
        if(notify_en && HaveVDD_OK) $display("@%.2fns: Tch_pi: CLK to VDD_OK hold time violation!!\n",$realtime);

end

always @(notify_phi) begin
        if(notify_en && HaveVDD_OK) $display("@%.2fns: Tph_pi: VDDP to VDD_OK hold time violation!!\n",$realtime);
	if(notify_en && HaveVDD_OK && !VDDP) $display("@%.2fns: Tph_pi: VDDP should not be turned off yet!!\n",$realtime);
end
//Timing check for avoid programming during power up and down <Begin>, added by Thomas, 2021-4-1

//assign bank_set = {TP1C, A[10], A[9]}; <------------ <D_IN[2/3] dont exist, base on A[10] only> Thomas 2021-4-6
assign bank_set[5:0] = {TP1C, A[BankAXYSelBit4], A[BankAXYSelBit3], A[BankAXYSelBit2], A[BankAXYSelBit1], A[BankAXYSelBit0]};	// <------------------ should add mux to use this instead !!!!
always @(bank_set or D) begin
	//D_IN=4'd0;	// Modified for supporting 1-to-4 ROWs by 1-to-4 COLUMNs; by Thomas 2021-4-6
	D_IN=16'h0000;
    if ((numQDperCol==1) && (numQDperRow==1) && (numPDBitTotal==0)) begin  // Added by Thomas 2021-4-22 for supporting 1-ROW by 1-COLUMN
	D_IN[0]=1;
    end else if ((numQDperCol==2) && (numQDperRow==1) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 2-ROW by 1-COLUMN
	casex(bank_set[5:0])
	  6'b1XXXX0 : D_IN[0]=1;
   	  6'b1XXXX1 : D_IN[1]=1;
	  default:  D_IN={14'h0000,D[1:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==1) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 1-COLUMN
	casex(bank_set[5:0])
	  6'b0XXX0X : D_IN[15:0]={12'h000,2'b00,D[1:0]};
	  6'b0XXX1X : D_IN[15:0]={12'h000,D[1:0],2'b00};
	  6'b1XXX00 : D_IN[0] =1'b1;
	  6'b1XXX01 : D_IN[1] =1'b1;
	  6'b1XXX10 : D_IN[2] =1'b1;
	  6'b1XXX11 : D_IN[3] =1'b1;
	  default:  D_IN=16'h0000; //{14'h0000,D[1:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==1) && (numPDBitTotal==4)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 1-COLUMN
	casex(bank_set[5:0])
	  6'b1XXX00 : D_IN[0] =1'b1;
	  6'b1XXX01 : D_IN[1] =1'b1;
	  6'b1XXX10 : D_IN[2] =1'b1;
	  6'b1XXX11 : D_IN[3] =1'b1;
	  default:  D_IN={12'h000,D[3:0]};
	endcase
    end else if ((numQDperCol==1) && (numQDperRow==2) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 1-ROW by 2-COLUMN
	casex(bank_set[5:0])
	  6'b1XXXX0 : D_IN[0]=1;
   	  6'b1XXXX1 : D_IN[1]=1;
	  default:  D_IN={14'h0000,D[1:0]};
	endcase
    end else if ((numQDperCol==2) && (numQDperRow==2) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 2-ROW by 2-COLUMN
	casex(bank_set[5:0])
	  6'b0XXX0X : D_IN[15:0]={12'h000,2'b00,D[1:0]};
	  6'b0XXX1X : D_IN[15:0]={12'h000,D[1:0],2'b00};
	  6'b1XXX00 : D_IN[0]=1;
   	  6'b1XXX01 : D_IN[1]=1;
	  6'b1XXX10 : D_IN[2]=1;
	  6'b1XXX11 : D_IN[3]=1;
	  default:  D_IN=16'h0000; //{14'h0000,D[1:0]};
	endcase
    end else if ((numQDperCol==2) && (numQDperRow==2) && (numPDBitTotal==4)) begin  // Added by Thomas 2021-4-6 for supporting 2-ROW by 2-COLUMN
	casex(bank_set[5:0])
	  6'b1XXX00 : D_IN[0]=1;
   	  6'b1XXX01 : D_IN[1]=1;
	  6'b1XXX10 : D_IN[2]=1;
	  6'b1XXX11 : D_IN[3]=1;
	  default:  D_IN={12'h000,D[3:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==2) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 2-COLUMN
	casex(bank_set[5:0])
	  6'b0XX00X : D_IN[15:0]={8'h00,4'h0,2'b00,D[1:0]};
	  6'b0XX01X : D_IN[15:0]={8'h00,4'h0,D[1:0],2'b00};
	  6'b0XX10X : D_IN[15:0]={8'h00,2'b00,D[1:0],4'h0};
	  6'b0XX11X : D_IN[15:0]={8'h00,D[1:0],2'b00,4'h0};
	  6'b1XX000 : D_IN[0] =1'b1;
	  6'b1XX001 : D_IN[1] =1'b1;
	  6'b1XX010 : D_IN[2] =1'b1;
	  6'b1XX011 : D_IN[3] =1'b1;
	  6'b1XX100 : D_IN[4] =1'b1;
	  6'b1XX101 : D_IN[5] =1'b1;
	  6'b1XX110 : D_IN[6] =1'b1;
	  6'b1XX111 : D_IN[7] =1'b1;
	  default:  D_IN=16'h0000; //{14'h0000,D[1:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==2) && (numPDBitTotal==4)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 2-COLUMN
	casex(bank_set[5:0])
	  6'b0XX0XX : D_IN[15:0]={8'h00,4'h0,D[3:0]};
	  6'b0XX1XX : D_IN[15:0]={8'h00,D[3:0],4'h0};
	  6'b1XX000 : D_IN[0] =1'b1;
	  6'b1XX001 : D_IN[1] =1'b1;
	  6'b1XX010 : D_IN[2] =1'b1;
	  6'b1XX011 : D_IN[3] =1'b1;
	  6'b1XX100 : D_IN[4] =1'b1;
	  6'b1XX101 : D_IN[5] =1'b1;
	  6'b1XX110 : D_IN[6] =1'b1;
	  6'b1XX111 : D_IN[7] =1'b1;
	  default:  D_IN=16'h0000; //(bank_set[2])?{8'h00,D[3:0],4'h0}:{8'h00,4'h0,D[3:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==2) && (numPDBitTotal==8)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 2-COLUMN
	casex(bank_set[5:0])
	  6'b1XX000 : D_IN[0] =1'b1;
	  6'b1XX001 : D_IN[1] =1'b1;
	  6'b1XX010 : D_IN[2] =1'b1;
	  6'b1XX011 : D_IN[3] =1'b1;
	  6'b1XX100 : D_IN[4] =1'b1;
	  6'b1XX101 : D_IN[5] =1'b1;
	  6'b1XX110 : D_IN[6] =1'b1;
	  6'b1XX111 : D_IN[7] =1'b1;
	  default:  D_IN={8'h00,D[7:0]};
	endcase
    end else if ((numQDperCol==1) && (numQDperRow==4) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 1-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b0XXX0X : D_IN[15:0]={12'h000,2'b00,D[1:0]};
	  6'b0XXX1X : D_IN[15:0]={12'h000,D[1:0],2'b00};
	  6'b1XXX00 : D_IN[0] =1'b1;
	  6'b1XXX01 : D_IN[1] =1'b1;
	  6'b1XXX10 : D_IN[2] =1'b1;
	  6'b1XXX11 : D_IN[3] =1'b1;
	  default:  D_IN=16'h0000; //(bank_set[1])?{12'h000,D[1:0],2'b00}:{12'h000,2'b00,D[1:0]};
	endcase
//$display("\n Check-X: bank_set=%6b, D_IN=%h \n",bank_set,D_IN);
    end else if ((numQDperCol==2) && (numQDperRow==4) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 2-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b0XX00X : D_IN[15:0]={8'h00,4'b0000,2'b00,D[1:0]};
	  6'b0XX01X : D_IN[15:0]={8'h00,4'b0000,D[1:0],2'b00};
	  6'b0XX10X : D_IN[15:0]={8'h00,2'b00,D[1:0],4'b0000};
	  6'b0XX11X : D_IN[15:0]={8'h00,D[1:0],2'b00,4'b0000};
	  6'b1XX000 : D_IN[0] =1'b1;
	  6'b1XX001 : D_IN[1] =1'b1;
	  6'b1XX010 : D_IN[2] =1'b1;
	  6'b1XX011 : D_IN[3] =1'b1;
	  6'b1XX100 : D_IN[4] =1'b1;
	  6'b1XX101 : D_IN[5] =1'b1;
	  6'b1XX110 : D_IN[6] =1'b1;
	  6'b1XX111 : D_IN[7] =1'b1;
	  default:  D_IN=16'h0000; //{14'h0000,D[1:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==4) && (numPDBitTotal==2)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b0X000X : D_IN[15:0]={8'h00,4'h0,2'b00,D[1:0]};
	  6'b0X001X : D_IN[15:0]={8'h00,4'h0,D[1:0],2'b00};
	  6'b0X010X : D_IN[15:0]={8'h00,2'b00,D[1:0],4'h0};
	  6'b0X011X : D_IN[15:0]={8'h00,D[1:0],2'b00,4'h0};
	  6'b0X100X : D_IN[15:0]={4'h0,2'b00,D[1:0],8'h00};
	  6'b0X101X : D_IN[15:0]={4'h0,D[1:0],2'b00,8'h00};
	  6'b0X110X : D_IN[15:0]={2'b00,D[1:0],4'h0,8'h00};
	  6'b0X111X : D_IN[15:0]={D[1:0],2'b00,4'h0,8'h00};
	  6'b1X0000 : D_IN[0] =1'b1;
	  6'b1X0001 : D_IN[1] =1'b1;
	  6'b1X0010 : D_IN[2] =1'b1;
	  6'b1X0011 : D_IN[3] =1'b1;
	  6'b1X0100 : D_IN[4] =1'b1;
	  6'b1X0101 : D_IN[5] =1'b1;
	  6'b1X0110 : D_IN[6] =1'b1;
	  6'b1X0111 : D_IN[7] =1'b1;
	  6'b1X1000 : D_IN[8] =1'b1;
	  6'b1X1001 : D_IN[9] =1'b1;
	  6'b1X1010 : D_IN[10] =1'b1;
	  6'b1X1011 : D_IN[11] =1'b1;
	  6'b1X1100 : D_IN[12] =1'b1;
	  6'b1X1101 : D_IN[13] =1'b1;
	  6'b1X1110 : D_IN[14] =1'b1;
	  6'b1X1111 : D_IN[15] =1'b1;
	  default:  D_IN=16'h0000; //{12'h000,D[1:0]};
	endcase
    end else if ((numQDperCol==1) && (numQDperRow==4) && (numPDBitTotal==4)) begin  // Added by Thomas 2021-4-6 for supporting 1-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b1XXX00 : D_IN[0] =1'b1;
	  6'b1XXX01 : D_IN[1] =1'b1;
	  6'b1XXX10 : D_IN[2] =1'b1;
	  6'b1XXX11 : D_IN[3] =1'b1;
	  default:  D_IN={12'h000,D[3:0]};
	endcase
    end else if ((numQDperCol==2) && (numQDperRow==4) && (numPDBitTotal==4)) begin  // Added by Thomas 2021-4-6 for supporting 2-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b0XX0XX : D_IN[15:0]={8'h00,4'h0,D[3:0]};
	  6'b0XX1XX : D_IN[15:0]={8'h00,D[3:0],4'h0};
	  6'b1XX000 : D_IN[0] =1'b1;
	  6'b1XX001 : D_IN[1] =1'b1;
	  6'b1XX010 : D_IN[2] =1'b1;
	  6'b1XX011 : D_IN[3] =1'b1;
	  6'b1XX100 : D_IN[4] =1'b1;
	  6'b1XX101 : D_IN[5] =1'b1;
	  6'b1XX110 : D_IN[6] =1'b1;
	  6'b1XX111 : D_IN[7] =1'b1;
	  default:  D_IN=16'h0000; //{12'h000,D[3:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==4) && (numPDBitTotal==4)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b0X00XX : D_IN[15:0]={8'h00,4'h0,D[3:0]};
	  6'b0X01XX : D_IN[15:0]={8'h00,D[3:0],4'h0};
	  6'b0X10XX : D_IN[15:0]={4'h0,D[3:0],8'h00};
	  6'b0X11XX : D_IN[15:0]={D[3:0],4'h0,8'h00};
	  6'b1X0000 : D_IN[0] =1'b1;
	  6'b1X0001 : D_IN[1] =1'b1;
	  6'b1X0010 : D_IN[2] =1'b1;
	  6'b1X0011 : D_IN[3] =1'b1;
	  6'b1X0100 : D_IN[4] =1'b1;
	  6'b1X0101 : D_IN[5] =1'b1;
	  6'b1X0110 : D_IN[6] =1'b1;
	  6'b1X0111 : D_IN[7] =1'b1;
	  6'b1X1000 : D_IN[8] =1'b1;
	  6'b1X1001 : D_IN[9] =1'b1;
	  6'b1X1010 : D_IN[10] =1'b1;
	  6'b1X1011 : D_IN[11] =1'b1;
	  6'b1X1100 : D_IN[12] =1'b1;
	  6'b1X1101 : D_IN[13] =1'b1;
	  6'b1X1110 : D_IN[14] =1'b1;
	  6'b1X1111 : D_IN[15] =1'b1;
	  default:  D_IN=16'h0000; //{12'h000,D[3:0]};
	endcase
    end else if ((numQDperCol==2) && (numQDperRow==4) && (numPDBitTotal==8)) begin  // Added by Thomas 2021-4-6 for supporting 2-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b1XX000 : D_IN[0] =1'b1;
	  6'b1XX001 : D_IN[1] =1'b1;
	  6'b1XX010 : D_IN[2] =1'b1;
	  6'b1XX011 : D_IN[3] =1'b1;
	  6'b1XX100 : D_IN[4] =1'b1;
	  6'b1XX101 : D_IN[5] =1'b1;
	  6'b1XX110 : D_IN[6] =1'b1;
	  6'b1XX111 : D_IN[7] =1'b1;
	  default:  D_IN={8'h00,D[7:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==4) && (numPDBitTotal==8)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b0X0XXX : D_IN[15:0]={8'h00,D[7:0]};
	  6'b0X1XXX : D_IN[15:0]={D[7:0],8'h00};
	  6'b1X0000 : D_IN[0] =1'b1;
	  6'b1X0001 : D_IN[1] =1'b1;
	  6'b1X0010 : D_IN[2] =1'b1;
	  6'b1X0011 : D_IN[3] =1'b1;
	  6'b1X0100 : D_IN[4] =1'b1;
	  6'b1X0101 : D_IN[5] =1'b1;
	  6'b1X0110 : D_IN[6] =1'b1;
	  6'b1X0111 : D_IN[7] =1'b1;
	  6'b1X1000 : D_IN[8] =1'b1;
	  6'b1X1001 : D_IN[9] =1'b1;
	  6'b1X1010 : D_IN[10] =1'b1;
	  6'b1X1011 : D_IN[11] =1'b1;
	  6'b1X1100 : D_IN[12] =1'b1;
	  6'b1X1101 : D_IN[13] =1'b1;
	  6'b1X1110 : D_IN[14] =1'b1;
	  6'b1X1111 : D_IN[15] =1'b1;
	  default:  D_IN=16'h0000; //(bank_set[2])?{D[7:0],8'h00}:{8'h00,D[7:0]};
	endcase
    end else if ((numQDperCol==4) && (numQDperRow==4) && (numPDBitTotal==16)) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
	casex(bank_set[5:0])
	  6'b1X0000 : D_IN[0] =1'b1;
	  6'b1X0001 : D_IN[1] =1'b1;
	  6'b1X0010 : D_IN[2] =1'b1;
	  6'b1X0011 : D_IN[3] =1'b1;
	  6'b1X0100 : D_IN[4] =1'b1;
	  6'b1X0101 : D_IN[5] =1'b1;
	  6'b1X0110 : D_IN[6] =1'b1;
	  6'b1X0111 : D_IN[7] =1'b1;
	  6'b1X1000 : D_IN[8] =1'b1;
	  6'b1X1001 : D_IN[9] =1'b1;
	  6'b1X1010 : D_IN[10] =1'b1;
	  6'b1X1011 : D_IN[11] =1'b1;
	  6'b1X1100 : D_IN[12] =1'b1;
	  6'b1X1101 : D_IN[13] =1'b1;
	  6'b1X1110 : D_IN[14] =1'b1;
	  6'b1X1111 : D_IN[15] =1'b1;
	  default:  D_IN=D[15:0];
	endcase
    end else begin
                $display("\n\n TM ERROR at time %g : Invalid ROW & COLUMN parameter configuration defined. \n\n",$time);
                D_IN[15:0]=0;
    end
end

// control signal check     // (design dependent)
assign control_set = {VDD, VDDP, CSB, PGM, RE, HDRON}; // , RESET12N, RESET28N}; 
//decoded into PROGRAM,READ,CTRERR, default
always @(control_set) begin
	casex(control_set)
	  6'b110101 : mode_err = {1'b0 ,1'b1 ,1'b0, 1'b0}; //PROGRAM
   	  6'b1x0010 : mode_err = {1'b0 ,1'b0 ,1'b1, 1'b0}; //READ   
   	  6'b1x1000 : mode_err = {1'b0 ,1'b0 ,1'b0, 1'b1}; //STANDBY   
   	  6'b0x1000 : mode_err = {1'b1 ,1'b0 ,1'b0, 1'b0}; //DEEPSLEEP
	  default: mode_err = {1'b0, 1'b0, 1'b0, 1'b0}; 
	endcase
end


/*** program otpCell ***/
always @(posedge CLK) begin
	if(normal_access && PROGRAM && D_IN[0]) begin
		otpCell_normal_0[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[0] program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[0]) begin
		otpCell_redundant_0[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[0] program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[0]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access && PROGRAM && D_IN[1]) begin
		otpCell_normal_1[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[1] program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[1]) begin
		otpCell_redundant_1[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[1] program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[1]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[2]) begin
		otpCell_normal_2[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[2] program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[2]) begin
		otpCell_redundant_2[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[2] program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[2]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[3]) begin
		otpCell_normal_3[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[3] program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[3]) begin
		otpCell_redundant_3[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t D_IN[3] program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[3]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[4]) begin
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin
		otpCell_redundant_4[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[4]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[5]) begin
		otpCell_normal_5[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin
		otpCell_redundant_5[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[5]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[6]) begin
		otpCell_normal_6[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[6]) begin
		otpCell_redundant_6[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[6]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[7]) begin
		otpCell_normal_7[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[7]) begin
		otpCell_redundant_7[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[7]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[8]) begin
		otpCell_normal_8[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[8]) begin
		otpCell_redundant_8[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[8]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[9]) begin
		otpCell_normal_9[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[9]) begin
		otpCell_redundant_9[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[9]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[10]) begin
		otpCell_normal_10[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[10]) begin
		otpCell_redundant_10 [A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[10]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[11]) begin
		otpCell_normal_11[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[11]) begin
		otpCell_redundant_11[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[11]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[12]) begin
		otpCell_normal_12[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[12]) begin
		otpCell_redundant_12[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[12]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[13]) begin
		otpCell_normal_13[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[13]) begin
		otpCell_redundant_13[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[13]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[14]) begin
		otpCell_normal_14[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[14]) begin
		otpCell_redundant_14[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[14]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end
always @(posedge CLK) begin
	if(normal_access & PROGRAM & D_IN[15]) begin
		otpCell_normal_15[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[15]) begin
		otpCell_redundant_15[A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM & D_IN[15]) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end

/* read cells to Q latch*/
always @(posedge CLK) begin
	if(READ & ~DUMMY_FLAG) begin
            $display("Read dummy cycle.\n");
            DUMMY_FLAG <=#2 1'b1;   //sc ?
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_0<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_0 <= otpCell_normal_0[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_0 <= otpCell_redundant_0[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_0 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_0 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_0 <=  otpCell_normal_0[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_0 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_0 <=  otpCell_normal_0[A_X][A_Y];
		end else begin
		  	   Qm_0 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_1<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_1 <= otpCell_normal_1[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_1 <= otpCell_redundant_1[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_1 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_1 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_1 <=  otpCell_normal_1[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_1 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_1 <=  otpCell_normal_1[A_X][A_Y];
		end else begin
		  	   Qm_1 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_2<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_2 <= otpCell_normal_2[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_2 <= otpCell_redundant_2[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_2 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_2 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_2 <=  otpCell_normal_2[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_2 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_2 <=  otpCell_normal_2[A_X][A_Y];
		end else begin
		  	   Qm_2 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_3<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_3 <= otpCell_normal_3[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_3 <= otpCell_redundant_3[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_3 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_3 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_3 <=  otpCell_normal_3[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_3 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_3 <=  otpCell_normal_3[A_X][A_Y];
		end else begin
		  	   Qm_3 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_4<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_4 <= otpCell_normal_4[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_4 <= otpCell_redundant_4[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_4 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_4 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_4 <=  otpCell_normal_4[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_4 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_4 <=  otpCell_normal_4[A_X][A_Y];
		end else begin
		  	   Qm_4 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_5<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_5 <= otpCell_normal_5[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_5 <= otpCell_redundant_5[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_5 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_5 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_5 <=  otpCell_normal_5[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_5 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_5 <=  otpCell_normal_5[A_X][A_Y];
		end else begin
		  	   Qm_5 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_6<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_6 <= otpCell_normal_6[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_6 <= otpCell_redundant_6[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_6 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_6 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_6 <=  otpCell_normal_6[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_6 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_6 <=  otpCell_normal_6[A_X][A_Y];
		end else begin
		  	   Qm_6 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_7<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_7 <= otpCell_normal_7[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_7 <= otpCell_redundant_7[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_7 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_7 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_7 <=  otpCell_normal_7[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_7 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_7 <=  otpCell_normal_7[A_X][A_Y];
		end else begin
		  	   Qm_7 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_8<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_8 <= otpCell_normal_8[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_8 <= otpCell_redundant_8[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_8 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_8 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_8 <=  otpCell_normal_8[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_8 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_8 <=  otpCell_normal_8[A_X][A_Y];
		end else begin
		  	   Qm_8 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_9<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_9 <= otpCell_normal_9[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_9 <= otpCell_redundant_9[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_9 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_9 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_9 <=  otpCell_normal_9[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_9 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_9 <=  otpCell_normal_9[A_X][A_Y];
		end else begin
		  	   Qm_9 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_10<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_10 <= otpCell_normal_10[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_10 <= otpCell_redundant_10[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_10 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_10 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_10 <=  otpCell_normal_10[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_10 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_10 <=  otpCell_normal_10[A_X][A_Y];
		end else begin
		  	   Qm_10 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_11<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_11 <= otpCell_normal_11[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_11 <= otpCell_redundant_11[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_11 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_11 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_11 <=  otpCell_normal_11[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_11 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_11 <=  otpCell_normal_11[A_X][A_Y];
		end else begin
		  	   Qm_11 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_12<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_12 <= otpCell_normal_12[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_12 <= otpCell_redundant_12[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_12 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_12 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_12 <=  otpCell_normal_12[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_12 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_12 <=  otpCell_normal_12[A_X][A_Y];
		end else begin
		  	   Qm_12 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_13<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_13 <= otpCell_normal_13[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_13 <= otpCell_redundant_13[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_13 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_13 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_13 <=  otpCell_normal_13[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_13 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_13 <=  otpCell_normal_13[A_X][A_Y];
		end else begin
		  	   Qm_13 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_14<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_14 <= otpCell_normal_14[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_14 <= otpCell_redundant_14[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_14 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_14 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_14 <=  otpCell_normal_14[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_14 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_14 <=  otpCell_normal_14[A_X][A_Y];
		end else begin
		  	   Qm_14 <= {numQBIT_QD{1'bx}};
		end
	end
end

always @(posedge CLK,posedge CSB) begin
	if(CSB) begin
		Qm_15<={numQBIT_QD{1'bx}};
	end
	else begin
		if(READ & DUMMY_FLAG & normal_access) begin
		    Qm_15 <= otpCell_normal_15[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
		    Qm_15 <= otpCell_redundant_15[A_Y];
		end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
		    Qm_15 <=  {numQBIT_QD{1'b0}};    //sc output 0s when reading reserved address
		    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
		end else if(READ & DUMMY_FLAG & odd_access) begin
		        //if(A[0]== 1'b0)
			if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
		           Qm_15 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_15 <=  otpCell_normal_15[A_X][A_Y];
		end else if(READ & DUMMY_FLAG & even_access) begin
		        //if(A[0]== 1'b1)
			if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
		           Qm_15 <=  {numQBIT_QD{1'b1}};
		        else
		           Qm_15 <=  otpCell_normal_15[A_X][A_Y];
		end else begin
		  	   Qm_15 <= {numQBIT_QD{1'bx}};
		end
	end
end

assign #(Thold) CLK_Thold = CLK & CS_PGMB_RE;
//assign #28 CLK_Tcd = CLK & CS_PGMB_RE;
//assign #(Tcd-Tckh) CLK_Tcd = CLK; // Modified by Thomas for Tcd comes after negedge of CLK tom
assign #(Tcd + Tckh) CLK_Tcd = CLK;
wire Tran_region = CLK_Thold & ~CLK_Tcd;	//Transition region for posedge CLK=>Tcd (Data invalid when CLK_Tcd high)
//wire Tran_region = CLK_Thold | CLK_Tcd;	//Transition region for negedge CLK=>Tcd (Data invalid when CLK_Tcd high)
reg [numAQ-1:0] pre_A_BIT,temp_A_BIT;
reg [numAY-1:0] pre_A_Y,temp_A_Y;
reg [numAX-1:0] pre_A_X,temp_A_X;
reg [numAddr-1:0] temp_A;
always @(posedge CLK_Thold or negedge CS_RE)  //sc "or?"
	Qt <= Qx;
//always @(posedge CLK_Tcd)        //del when change Tcd from pos to neg CLK
//	Qt <= Q1;   //sc  Q1?
	
always @(posedge CSB or posedge RE)
	DUMMY_FLAG <=#1 (HaveDummyFlag) ? 1'b0 : 1'b1;	// reset DUMMY_FLAG
	
//assign Qm = temp_A[10] ? {Qm_3,Qm_2} : {Qm_1,Qm_0} ;	// Modified by Thomas for supporting 1-to-4 ROWs by 1-to-4 COLUMNs configuration 2021-4-12	
always @(temp_A[BankAXYSelBit4],temp_A[BankAXYSelBit3],temp_A[BankAXYSelBit2],temp_A[BankAXYSelBit1],temp_A[BankAXYSelBit0],Qm_0,Qm_1,Qm_2,Qm_3,Qm_4,Qm_4,Qm_5,Qm_6,Qm_7,Qm_8,Qm_9,Qm_10,Qm_11,Qm_12,Qm_13,Qm_14,Qm_15) begin
	if (numQDTotal==1) Qm = Qm_0; // Added by Thomas 2021-4-6 for supporting 1-ROW by 1-COLUMN
	else if (numQDTotal==2) begin // Added by Thomas 2021-4-6 for supporting (1-ROW by 2-COLUMN) and (2-ROW by 1-COLUMN)
		if (numQBIT==numQBIT_QD) Qm = temp_A[BankAXYSelBit0] ? Qm_1 : Qm_0;
		else Qm = {Qm_1,Qm_0};
	end // Added by Thomas 2021-4-6 for supporting (1-ROW by 2-COLUMN) and (2-ROW by 1-COLUMN)
	else if (numQDTotal==4) begin  // Added by Thomas 2021-4-6 for supporting (1-ROW by 4-COLUMN) and (2-ROW by 2-COLUMN) and (4-ROW by 1-COLUMN)
		if (numQBIT==numQBIT_QD) Qm = temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_3 : Qm_2) : (temp_A[BankAXYSelBit0] ? Qm_1 : Qm_0);
		else if (numQBIT==numQBIT_QD*(numQDTotal/2)) Qm = temp_A[BankAXYSelBit1] ? {Qm_3,Qm_2} : {Qm_1,Qm_0};
		else Qm = {Qm_3,Qm_2,Qm_1,Qm_0};
	end // Added by Thomas 2021-4-6 for supporting (1-ROW by 4-COLUMN) and (2-ROW by 2-COLUMN) and (4-ROW by 1-COLUMN)
	else if (numQDTotal==8) begin  // Added by Thomas 2021-4-6 for supporting (2-ROW by 4-COLUMN) and (4-ROW by 2-COLUMN)
		if (numQBIT==numQBIT_QD) Qm = temp_A[BankAXYSelBit2] ? (temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_7 : Qm_6) : (temp_A[BankAXYSelBit0] ? Qm_5 : Qm_4)) : 
									    (temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_3 : Qm_2) : (temp_A[BankAXYSelBit0] ? Qm_1 : Qm_0));
		else if (numQBIT==numQBIT_QD*(numQDTotal/4)) Qm = temp_A[BankAXYSelBit2] ?	(temp_A[BankAXYSelBit1] ? {Qm_7,Qm_6} : {Qm_5,Qm_4}) : (temp_A[BankAXYSelBit1] ? {Qm_3,Qm_2} : {Qm_1,Qm_0});
		else if (numQBIT==numQBIT_QD*(numQDTotal/2)) Qm = temp_A[BankAXYSelBit2] ?	{Qm_7,Qm_6,Qm_5,Qm_4} : {Qm_3,Qm_2,Qm_1,Qm_0};
		else Qm = {Qm_7,Qm_6,Qm_5,Qm_4,Qm_3,Qm_2,Qm_1,Qm_0};
	end // Added by Thomas 2021-4-6 for supporting (2-ROW by 4-COLUMN) and (4-ROW by 2-COLUMN)
	else if (numQDTotal==16) begin  // Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
		if (numQBIT==numQBIT_QD) begin
			Qm = temp_A[BankAXYSelBit3] ?	(temp_A[BankAXYSelBit2] ? (temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_15 : Qm_14) : (temp_A[BankAXYSelBit0] ? Qm_13 : Qm_12)) : 
										  (temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_11 : Qm_10) : (temp_A[BankAXYSelBit0] ? Qm_9  : Qm_8))) :
							(temp_A[BankAXYSelBit2] ? (temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_7  : Qm_6)  : (temp_A[BankAXYSelBit0] ? Qm_5  : Qm_4))  :
										  (temp_A[BankAXYSelBit1] ? (temp_A[BankAXYSelBit0] ? Qm_3  : Qm_2)  : (temp_A[BankAXYSelBit0] ? Qm_1  : Qm_0)));
		end else if (numQBIT==numQBIT_QD*(numQDTotal/8)) begin 
			Qm = temp_A[BankAXYSelBit3] ?	(temp_A[BankAXYSelBit2] ? (temp_A[BankAXYSelBit1] ? {Qm_15,Qm_14} : {Qm_13,Qm_12}) : (temp_A[BankAXYSelBit1] ? {Qm_11,Qm_10} : {Qm_9,Qm_8})) :
							(temp_A[BankAXYSelBit2] ? (temp_A[BankAXYSelBit1] ? {Qm_7, Qm_6}  : {Qm_5, Qm_4})  : (temp_A[BankAXYSelBit1] ? {Qm_3, Qm_2}  : {Qm_1,Qm_0}));
		end else if (numQBIT==numQBIT_QD*(numQDTotal/4)) Qm = temp_A[BankAXYSelBit3] ?	(temp_A[BankAXYSelBit2] ? {Qm_15,Qm_14,Qm_13,Qm_12} : {Qm_11,Qm_10,Qm_9,Qm_8}) :
												(temp_A[BankAXYSelBit2] ? {Qm_7, Qm_6, Qm_5, Qm_4}  : {Qm_3, Qm_2, Qm_1,Qm_0});
		else if (numQBIT==numQBIT_QD*(numQDTotal/2)) Qm = temp_A[BankAXYSelBit3] ?	{Qm_15,Qm_14,Qm_13,Qm_12,Qm_11,Qm_10,Qm_9,Qm_8} : {Qm_7,Qm_6,Qm_5,Qm_4,Qm_3,Qm_2,Qm_1,Qm_0};
		else Qm = {Qm_15,Qm_14,Qm_13,Qm_12,Qm_11,Qm_10,Qm_9,Qm_8,Qm_7,Qm_6,Qm_5,Qm_4,Qm_3,Qm_2,Qm_1,Qm_0};
	end // Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
	else begin
                $display("\n\n At time %g, ERROR : Invalid ROW & COLUMN configuration defined. \n\n",$time);
                Qm={numQBIT{1'bX}};
	end
end

`ifdef SET_ANNOTATE
	assign Q = CSB ? Qe : Qm ;
`else
	assign Q = Tran_region ? Qt : CSB ? Qe : Qm ;
`endif

always @(posedge CSB) begin
	if(PGMB_RE) begin
		Qe <= {numQBIT{1'bx}};	//Read cycle finish 
	end
end

always @(negedge CSB) begin
        if(PGMB_RE) begin
                Qe <= {numQBIT{1'bx}};       //start Reading 
        end
end
//always @(posedge CTRERR)
//	$display("@%.2fns \tControl signal(s) is(are) arranged UNCORRECTLY!!!\n",$realtime);	




always@(posedge CLK,posedge CSB)
begin
	if(CSB) begin
		temp_A_BIT<={numAQ{1'b0}};
		pre_A_BIT<={numAQ{1'b0}};
		temp_A_Y<={numAY{1'b0}};
		pre_A_Y<={numAY{1'b0}};
		temp_A_X<={numAX{1'b0}};
		pre_A_X<={numAX{1'b0}};
		temp_A<={numAddr{1'b0}};
		
	end 
	else begin
		temp_A_BIT<=A_BIT;
		pre_A_BIT<=temp_A_BIT;
		temp_A_Y<=A_Y;
		pre_A_Y<=temp_A_Y;
		temp_A_X<=A_X;
		pre_A_X<=temp_A_X;	
		temp_A<=A;
	end
end
//#########################read  violation report#####################################
always @(notify_hsr) begin
        if(notify_en && HaveHDRON) $display("@%.2fns \t Ths_pr: HDRON to CSB setup vio!!\n", $realtime);
end
always @(notify_hhr) begin
        if(notify_en && HaveHDRON) $display("@%.2fns \t Thh_pr: HDRON to CSB hold vio!!\n", $realtime);
end
always @(notify_vsr) begin
        if(notify_en) $display("@%.2fns \t Tvs_pr: VDDP to CSB setup vio!!\n", $realtime);
end
always @(notify_vhr) begin
        if(notify_en) $display("@%.2fns \t Tvh_pr: VDDP to CSB hold vio!!\n", $realtime);
end
always @(notify_asr) begin
	 if(notify_en) $display("@%.2fns \t Tas_pr: Addr to CSB setup time violation.\n",$realtime);  
end
always @(notify_ahr) begin
	 if(notify_en) $display("@%.2fns \t Tah_pr: Addr to CSB setup time violation.\n",$realtime);  
end
always @(notify_asrTWLB) begin
	 if(notify_en) $display("@%.2fns \t Tas_pr: TWLB to CSB setup time violation.\n",$realtime);  
end
always @(notify_ahrTWLB) begin
	 if(notify_en) $display("@%.2fns \t Tah_pr: TWLB to CSB setup time violation.\n",$realtime);  
end
always @(notify_wsr) begin
	 if(notify_en) $display("@%.2fns \t Tws_pr: PGM to CSB setup violation.\n",$realtime);  
end
always @(notify_whr) begin
	 if(notify_en) $display("@%.2fns \t Twh_pr: PGM to CSB setup violation.\n",$realtime);  
end
always @(notify_rsr) begin
	 if(notify_en) $display("@%.2fns \t Trs_pr: RE to CSB setup violation.\n",$realtime);  
end
always @(notify_rhr) begin
	 if(notify_en) $display("@%.2fns \t Trh_pr: RE to CSB hold time violation.\n",$realtime);  
end
always @(notify_ckh) begin
        if(READ & DUMMY_FLAG) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en) $display("@%.2fns Tckh: Min CLK high period violation.\n", $realtime);  //sc check
        end
end
always @(notify_ckl) begin
        if(READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en) $display("@%.2fns \t Tckl: min CLK low period violation!!\n", $realtime);
        end
end
always @(notify_cyr) begin
        if(READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en) $display("@%.2fns \t Tcyc: Read CLK period vio!!\n", $realtime);
        end
end
always @(notify_ras) begin
        if(READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en) $display("@%.2fns \t Tras_pr: Addr to CLK setup time violation.\n",$realtime);  
        end
end
always @(notify_rah) begin
        if(READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en) $display("@%.2fns \t Trah_pr: Addr to CLK hold time violation.\n",$realtime);  
        end
end
always @(notify_rasTWLB) begin
        if(READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en) $display("@%.2fns \t Tras_pr: TWLB to CLK setup time violation.\n",$realtime);  
        end
end
always @(notify_rahTWLB) begin
        if(READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
		if(notify_en && HaveTWLB) $display("@%.2fns \t Trah_pr: TWLB to CLK hold time violation.\n",$realtime);  
        end
end
//#########################program  violation report#####################################
always @(notify_hsp) begin
        if(notify_en && HaveHDRON) $display("@%.2fns \t Ths_pp: HDRON to CSB setup vio!!\n", $realtime);
end
always @(notify_hhp) begin
        if(notify_en && HaveHDRON) $display("@%.2fns \t Thh_pp: HDRON to CSB hold vio!!\n", $realtime);
end
always @(notify_vsp) begin
        if(notify_en) $display("@%.2fns \t Tvs_pp: VDDP to CSB setup vio!!\n", $realtime);
end
always @(notify_vhp) begin
        if(notify_en) $display("@%.2fns \t Tvh_pp: VDDP to CSB hold vio!!\n", $realtime);
end
always @(notify_aspA) begin
	if(notify_en) $display("@%.2fns \t Tas_pp: CSB to A setup time violation.\n",$realtime);  
end
always @(notify_aspD) begin
	if(notify_en) $display("@%.2fns \t Tas_pp: CSB to D setup time violation.\n",$realtime);  
end
always @(notify_aspTWLB) begin
	if(notify_en) $display("@%.2fns \t Tas_pp: CSB to TWLB setup time violation.\n",$realtime);  
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[0]
        if(normal_access  & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[1]
        if(normal_access   & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to QD[1] program normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to QD[1] program redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[2]
        if(normal_access   & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[3]
        if(normal_access   & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[4]
        if(normal_access   & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[5]
        if(normal_access   & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[6]
        if(normal_access   & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[7]
        if(normal_access   & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[8]
        if(normal_access   & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[9]
        if(normal_access   & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[10]
        if(normal_access   & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[11]
        if(normal_access   & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[12]
        if(normal_access   & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[13]
        if(normal_access   & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[14]
        if(normal_access   & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpA) begin       //CSB hold time violation, QD[15]
        if(normal_access   & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end



always @(notify_ahpD) begin       //CSB hold time violation, QD[0]
        if(normal_access   & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[1]
        if(normal_access   & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[2]
        if(normal_access  & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[3]
        if(normal_access   & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[4]
        if(normal_access  & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[5]
        if(normal_access   & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[6]
        if(normal_access  & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[7]
        if(normal_access   & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[8]
        if(normal_access  & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[9]
        if(normal_access   & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[10]
        if(normal_access  & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[11]
        if(normal_access   & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[12]
        if(normal_access  & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[13]
        if(normal_access   & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[14]
        if(normal_access  & D_IN[14]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[14]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpD) begin       //CSB hold time violation, QD[15]
        if(normal_access   & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to D hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end

always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[0]
        if(normal_access   & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[1]
        if(normal_access   & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[2]
        if(normal_access  & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[2] program normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[2] program redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[3]
        if(normal_access   & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[4]
        if(normal_access  & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[4] program normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[4] program redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[5]
        if(normal_access   & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[6]
        if(normal_access  & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[6] program normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[6] program redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[7]
        if(normal_access   & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[8]
        if(normal_access  & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[8] program normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to QD[8] program redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[9]
        if(normal_access   & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[10]
        if(normal_access   & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[11]
        if(normal_access   & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[12]
        if(normal_access   & D_IN[12]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[13]
        if(normal_access   & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[14]
        if(normal_access   & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_ahpTWLB) begin       //CSB hold time violation, QD[15]
        if(normal_access   & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to TWLB hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_wsp) begin
	if(notify_en) $display("@%.2fns \t Tws_pp: PGM to CSB setup time violation.\n",$realtime);  
end
always @(notify_whp) begin       //PGM hold time violation,  QD[0]
        if(normal_access   & !silent_st & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[0] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[1]
        if(normal_access   & !silent_st & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[1] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[2]
        if(normal_access   & !silent_st & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[2] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[3]
        if(normal_access   & !silent_st & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[3] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[4]
        if(normal_access   & !silent_st & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[4] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[5]
        if(normal_access   & !silent_st & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[5] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[6]
        if(normal_access   & !silent_st & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[6] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[7]
        if(normal_access   & !silent_st & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[7] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[8]
        if(normal_access   & !silent_st & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[8] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[9]
        if(normal_access   & !silent_st & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[9] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[10]
        if(normal_access   & !silent_st & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[10] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[11]
        if(normal_access   & !silent_st & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[11] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[12]
        if(normal_access   & !silent_st & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[12] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[13]
        if(normal_access   & !silent_st & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[13] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[14]
        if(normal_access   & !silent_st & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[14] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning   & !silent_st & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_whp) begin       //PGM hold time violation,  QD[15]
        if(normal_access   & !silent_st & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[15] normal cell [%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_rsp) begin
	 if(notify_en) $display("@%.2fns \t Trs_pp: RE to CSB setup time violation.\n",$realtime);  
end

always @(notify_rhp) begin       //RE hold time violation QD[0]
        if(normal_access  & !silent_st & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[0] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[0] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[1]
        if(normal_access  & !silent_st & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[1] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[1] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[2]
        if(normal_access  & !silent_st & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[2] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[2] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[3]
        if(normal_access  & !silent_st & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[3] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[3] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[4]
        if(normal_access  & !silent_st & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[4] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[4] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[5]
        if(normal_access  & !silent_st & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[5] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[5] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[6]
        if(normal_access  & !silent_st & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[6] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[6] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[7]
        if(normal_access  & !silent_st & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[7] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[7] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[8]
        if(normal_access  & !silent_st & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[8] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[8] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[9]
        if(normal_access  & !silent_st & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[9] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[9] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[10]
        if(normal_access  & !silent_st & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[10] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[10] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[11]
        if(normal_access  & !silent_st & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[11] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[11] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[12]
        if(normal_access  & !silent_st & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[12] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[12] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[13]
        if(normal_access  & !silent_st & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[13] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[13] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[14]
        if(normal_access  & !silent_st & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[14] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[14] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_rhp) begin       //RE hold time violation QD[15]
        if(normal_access  & !silent_st & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[15] normal cell[%d][%d] Bit[%d].",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning  & !silent_st & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Trh_pp: RE to CSB hold time violation. Fail to program QD[15] redundant cell[%d] Bit[%d].",$realtime, temp_A_Y ,temp_A_BIT);
        end
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[0]) begin
		otpCell_normal_0[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[0]) begin
                 otpCell_redundant_0[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[1]) begin
		otpCell_normal_1[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[1]) begin
                 otpCell_redundant_1[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[2]) begin
		otpCell_normal_2[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[2]) begin
                 otpCell_redundant_2[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[3]) begin
		otpCell_normal_3[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[3]) begin
                 otpCell_redundant_3[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[4]) begin
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin
                 otpCell_redundant_4[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[5]) begin
		otpCell_normal_5[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin
                 otpCell_redundant_5[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[6]) begin
		otpCell_normal_6[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[6]) begin
                 otpCell_redundant_6[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[7]) begin
		otpCell_normal_7[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[7]) begin
                 otpCell_redundant_7[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[8]) begin
		otpCell_normal_8[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[8]) begin
                 otpCell_redundant_8[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[9]) begin
		otpCell_normal_9[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[9]) begin
                 otpCell_redundant_9[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[10]) begin
		otpCell_normal_10[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[10]) begin
                 otpCell_redundant_10[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[11]) begin
		otpCell_normal_11[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[11]) begin
                 otpCell_redundant_11[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[12]) begin
		otpCell_normal_12[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[12]) begin
                 otpCell_redundant_12[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[13]) begin
		otpCell_normal_13[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[13]) begin
                 otpCell_redundant_13[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[14]) begin
		otpCell_normal_14[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[14]) begin
                 otpCell_redundant_14[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspA) begin
	if(normal_access & PROGRAM  & D_IN[15]) begin
		otpCell_normal_15[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[15]) begin
                 otpCell_redundant_15[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[0]) begin
		otpCell_normal_0[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[0]) begin
                 otpCell_redundant_0[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[1]) begin
		otpCell_normal_1[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[1]) begin
                 otpCell_redundant_1[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[2]) begin
		otpCell_normal_2[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[2]) begin
                 otpCell_redundant_2[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[3]) begin
		otpCell_normal_3[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[3]) begin
                 otpCell_redundant_3[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[4]) begin
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin
                 otpCell_redundant_4[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[5]) begin
		otpCell_normal_5[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin
                 otpCell_redundant_5[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[6]) begin
		otpCell_normal_6[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[6]) begin
                 otpCell_redundant_6[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[7]) begin
		otpCell_normal_7[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[7]) begin
                 otpCell_redundant_7[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[8]) begin
		otpCell_normal_8[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[8]) begin
                 otpCell_redundant_8[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[9]) begin
		otpCell_normal_9[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[9]) begin
                 otpCell_redundant_9[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[10]) begin
		otpCell_normal_10[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[10]) begin
                 otpCell_redundant_10[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[11]) begin
		otpCell_normal_11[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[11]) begin
                 otpCell_redundant_11[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[12]) begin
		otpCell_normal_12[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[12]) begin
                 otpCell_redundant_12[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[13]) begin
		otpCell_normal_13[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[13]) begin
                 otpCell_redundant_13[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[4]) begin
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin
                 otpCell_redundant_4[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspTWLB) begin
	if(normal_access & PROGRAM  & D_IN[15]) begin
		otpCell_normal_15[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[15]) begin
                 otpCell_redundant_15[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: TWLB to CLK setup vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[0]) begin
		otpCell_normal_0[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[0]) begin
                 otpCell_redundant_0[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[1]) begin
		otpCell_normal_1[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[1]) begin
                 otpCell_redundant_1[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[2]) begin
		otpCell_normal_2[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[2]) begin
                 otpCell_redundant_2[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[3]) begin
		otpCell_normal_3[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[3]) begin
                 otpCell_redundant_3[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[4]) begin
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin
                 otpCell_redundant_4[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[5]) begin
		otpCell_normal_5[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin
                 otpCell_redundant_5[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[6]) begin
		otpCell_normal_6[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[6]) begin
                 otpCell_redundant_6[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[7]) begin
		otpCell_normal_7[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[7]) begin
                 otpCell_redundant_7[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[8]) begin
		otpCell_normal_8[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[8]) begin
                 otpCell_redundant_8[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[9]) begin
		otpCell_normal_9[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[9]) begin
                 otpCell_redundant_9[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[10]) begin
		otpCell_normal_10[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[10]) begin
                 otpCell_redundant_10[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[11]) begin
		otpCell_normal_11[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[11]) begin
                 otpCell_redundant_11[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[12]) begin
		otpCell_normal_12[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[12]) begin
                 otpCell_redundant_12[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[13]) begin
		otpCell_normal_13[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[13]) begin
                 otpCell_redundant_13[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[14]) begin
		otpCell_normal_14[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[14]) begin
                 otpCell_redundant_14[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_sspD) begin
	if(normal_access & PROGRAM  & D_IN[15]) begin
		otpCell_normal_15[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[15]) begin
                 otpCell_redundant_15[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: D to CLK setup vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[0]
	if(normal_access & PROGRAM  & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[1]
	if(normal_access & PROGRAM  & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[2]
	if(normal_access & PROGRAM  & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[3]
	if(normal_access & PROGRAM  & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[4]
	if(normal_access & PROGRAM  & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[5]
	if(normal_access & PROGRAM  & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[6]
	if(normal_access & PROGRAM  & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[7]
	if(normal_access & PROGRAM  & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[8]
	if(normal_access & PROGRAM  & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[9]
	if(normal_access & PROGRAM  & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[10]
	if(normal_access & PROGRAM  & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[11]
	if(normal_access & PROGRAM  & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[12]
	if(normal_access & PROGRAM  & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[13]
	if(normal_access & PROGRAM  & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[14]
	if(normal_access & PROGRAM  & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpTWLB) begin //Program Address to CLK hold time violation QD[15]
	if(normal_access & PROGRAM  & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: TWLB to CLK hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[0]
	if(normal_access & PROGRAM  & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[1]
	if(normal_access & PROGRAM  & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[2]
	if(normal_access & PROGRAM  & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[3]
	if(normal_access & PROGRAM  & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[4]
	if(normal_access & PROGRAM  & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[5]
	if(normal_access & PROGRAM  & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[6]
	if(normal_access & PROGRAM  & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[7]
	if(normal_access & PROGRAM  & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[8]
	if(normal_access & PROGRAM  & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[9]
	if(normal_access & PROGRAM  & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[10]
	if(normal_access & PROGRAM  & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[11]
	if(normal_access & PROGRAM  & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[12]
	if(normal_access & PROGRAM  & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[13]
	if(normal_access & PROGRAM  & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[14]
	if(normal_access & PROGRAM  & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpD) begin //Program Address to CLK hold time violation QD[15]
	if(normal_access & PROGRAM  & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: D to CLK hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[0]
	if(normal_access & PROGRAM  & D_IN[0]) begin
                otpCell_normal_0[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[0]) begin
                otpCell_redundant_0[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[1]
	if(normal_access & PROGRAM  & D_IN[1]) begin
                otpCell_normal_1[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[1]) begin
                otpCell_redundant_1[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[2]
	if(normal_access & PROGRAM  & D_IN[2]) begin
                otpCell_normal_2[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[2]) begin
                otpCell_redundant_2[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[3]
	if(normal_access & PROGRAM  & D_IN[3]) begin
                otpCell_normal_3[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[3]) begin
                otpCell_redundant_3[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[4]
	if(normal_access & PROGRAM  & D_IN[4]) begin
                otpCell_normal_4[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[4]) begin
                otpCell_redundant_4[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[5]
	if(normal_access & PROGRAM  & D_IN[5]) begin
                otpCell_normal_5[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[5]) begin
                otpCell_redundant_5[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[6]
	if(normal_access & PROGRAM  & D_IN[6]) begin
                otpCell_normal_6[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[6]) begin
                otpCell_redundant_6[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[7]
	if(normal_access & PROGRAM  & D_IN[7]) begin
                otpCell_normal_7[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[7]) begin
                otpCell_redundant_7[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[8]
	if(normal_access & PROGRAM  & D_IN[8]) begin
                otpCell_normal_8[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[8]) begin
                otpCell_redundant_8[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[9]
	if(normal_access & PROGRAM  & D_IN[9]) begin
                otpCell_normal_9[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[9]) begin
                otpCell_redundant_9[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[10]
	if(normal_access & PROGRAM  & D_IN[10]) begin
                otpCell_normal_10[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[10]) begin
                otpCell_redundant_10[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[11]
	if(normal_access & PROGRAM  & D_IN[11]) begin
                otpCell_normal_11[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[11]) begin
                otpCell_redundant_11[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[12]
	if(normal_access & PROGRAM  & D_IN[12]) begin
                otpCell_normal_12[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[12]) begin
                otpCell_redundant_12[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[13]
	if(normal_access & PROGRAM  & D_IN[13]) begin
                otpCell_normal_13[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[13]) begin
                otpCell_redundant_13[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[14]
	if(normal_access & PROGRAM  & D_IN[14]) begin
                otpCell_normal_14[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[14]) begin
                otpCell_redundant_14[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_shpA) begin //Program Address to CLK hold time violation QD[15]
	if(normal_access & PROGRAM  & D_IN[15]) begin
                otpCell_normal_15[temp_A_X][temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, temp_A_X, temp_A_Y, temp_A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM  & D_IN[15]) begin
                otpCell_redundant_15[temp_A_Y][temp_A_BIT] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, temp_A_Y, temp_A_BIT);
        end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[0]) begin    //no PROGRAM
		otpCell_normal_0[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[0]) begin //no PRORAM
		otpCell_redundant_0[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[1]) begin    //no PROGRAM
		otpCell_normal_1[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[1]) begin //no PRORAM
		otpCell_redundant_1[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[2]) begin    //no PROGRAM
		otpCell_normal_2[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[2]) begin //no PRORAM
		otpCell_redundant_2[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[3]) begin    //no PROGRAM
		otpCell_normal_3[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[3]) begin //no PRORAM
		otpCell_redundant_3[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[4]) begin    //no PROGRAM
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin //no PRORAM
		otpCell_redundant_4[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[5]) begin    //no PROGRAM
		otpCell_normal_5[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin //no PRORAM
		otpCell_redundant_5[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[6]) begin    //no PROGRAM
		otpCell_normal_6[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[6]) begin //no PRORAM
		otpCell_redundant_6[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[7]) begin    //no PROGRAM
		otpCell_normal_7[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[7]) begin //no PRORAM
		otpCell_redundant_7[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[8]) begin    //no PROGRAM
		otpCell_normal_8[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[8]) begin //no PRORAM
		otpCell_redundant_8[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[9]) begin    //no PROGRAM
		otpCell_normal_9[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin //no PRORAM
		otpCell_redundant_9[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[10]) begin    //no PROGRAM
		otpCell_normal_10[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[10]) begin //no PRORAM
		otpCell_redundant_10[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[11]) begin    //no PROGRAM
		otpCell_normal_11[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[11]) begin //no PRORAM
		otpCell_redundant_11[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[12]) begin    //no PROGRAM
		otpCell_normal_12[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[12]) begin //no PRORAM
		otpCell_redundant_12[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[13]) begin    //no PROGRAM
		otpCell_normal_13[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[13]) begin //no PRORAM
		otpCell_redundant_13[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[14]) begin    //no PROGRAM
		otpCell_normal_14[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[14]) begin //no PRORAM
		otpCell_redundant_14[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
always @(notify_sw) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[15]) begin    //no PROGRAM
		otpCell_normal_15[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[15]) begin //no PRORAM
		otpCell_redundant_15[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end
//to report CLK high max for program
always @(posedge CLK) begin
        if(PGM) begin
                CLK_r = $time;
        end
end
always @(negedge CLK) begin
        if(PGM) begin
                time_CLKH = $time - CLK_r;
                if(time_CLKH > Tsw_max_pp) begin
			notify_swm=~notify_swm;
                end
        end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[0]) begin
		otpCell_normal_0[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[0] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[0]) begin
		otpCell_redundant_0[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[0] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[1]) begin
		otpCell_normal_1[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[1] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[1]) begin
		otpCell_redundant_1[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[1] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[2]) begin
		otpCell_normal_2[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[2] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[2]) begin
		otpCell_redundant_2[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[2] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[3]) begin
		otpCell_normal_3[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[3] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[3]) begin
		otpCell_redundant_3[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[3] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[4]) begin
		otpCell_normal_4[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[4] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[4]) begin
		otpCell_redundant_4[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[4] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[5]) begin
		otpCell_normal_5[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[5] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[5]) begin
		otpCell_redundant_5[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[5] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[6]) begin
		otpCell_normal_6[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[6] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[6]) begin
		otpCell_redundant_6[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[6] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[7]) begin
		otpCell_normal_7[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[7] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[7]) begin
		otpCell_redundant_7[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[7] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[8]) begin
		otpCell_normal_8[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[8] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[8]) begin
		otpCell_redundant_8[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[8] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[9]) begin
		otpCell_normal_9[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[9] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[9]) begin
		otpCell_redundant_9[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[9] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[10]) begin
		otpCell_normal_10[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[10] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[10]) begin
		otpCell_redundant_10[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[10] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[11]) begin
		otpCell_normal_11[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[11] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[11]) begin
		otpCell_redundant_11[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[11] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[12]) begin
		otpCell_normal_12[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[12] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[12]) begin
		otpCell_redundant_12[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[12] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[13]) begin
		otpCell_normal_13[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[13] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[13]) begin
		otpCell_redundant_13[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[13] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[14]) begin
		otpCell_normal_14[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[14] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[14]) begin
		otpCell_redundant_14[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[14] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end
always @(notify_swm) begin  //pulse width high violation
	if(normal_access & PROGRAM & D_IN[15]) begin
		otpCell_normal_15[A_X][A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[15] normal cell[%d][%d] Bit[%d]!!",$realtime, time_CLKH, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM & D_IN[15]) begin
		otpCell_redundant_15[A_Y][A_BIT] <= 1'bx;
		 if(notify_en) $display("@%.2fns \t Tsw_max_pp: CLK pulse width time %.2fns is greater than the maximum!!! Fail to program QD[15] redundant cell[%d] Bit[%d]!!",$realtime, time_CLKH, A_Y, A_BIT);
	end
end

/*
//Reset to CSB timing check
always @(notify_r1s) begin  
	if(normal_access) begin   //no !PROGRAM
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tr1s_pp: RESET12N to CSB setup vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning) begin
		otpCell_redundant[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tr1s_pp: RESET12N to CSB setup vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end

always @(notify_r2s) begin  
	if(normal_access) begin
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tr2s_pp: RESET28N to CSB setup vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning) begin
		otpCell_redundant[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tr2s_pp: RESET28N to CSb setup vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end

always @(notify_r1h) begin  
	if(normal_access) begin
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tr1h_pp: RESET12N to CSB hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning) begin
		otpCell_redundant[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tr1h_pp: RESET28N to CSB hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end

always @(notify_r2h) begin  
	if(normal_access) begin
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tr2h_pp: RESET12N to CSB hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning) begin
		otpCell_redundant[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tr2h_pp: RESET28N to CSB hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end*/
// RE to TM timing check (aft read power down)
always @(notify_ts) begin
	if(!READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
            	if(notify_en) $display("@%.2fns: Tts_pr: RE to TM setup time violation!!\n",$realtime);
	end
end

always @(notify_th) begin
	if(!READ) begin
		Qm_0 <= {numQBIT_QD{1'bx}};
		Qm_1 <= {numQBIT_QD{1'bx}};
		Qm_2 <= {numQBIT_QD{1'bx}};
		Qm_3 <= {numQBIT_QD{1'bx}};
		Qm_4 <= {numQBIT_QD{1'bx}};
		Qm_5 <= {numQBIT_QD{1'bx}};
		Qm_6 <= {numQBIT_QD{1'bx}};
		Qm_7 <= {numQBIT_QD{1'bx}};
		Qm_8 <= {numQBIT_QD{1'bx}};
		Qm_9 <= {numQBIT_QD{1'bx}};
		Qm_10 <= {numQBIT_QD{1'bx}};
		Qm_11 <= {numQBIT_QD{1'bx}};
		Qm_12 <= {numQBIT_QD{1'bx}};
		Qm_13 <= {numQBIT_QD{1'bx}};
		Qm_14 <= {numQBIT_QD{1'bx}};
		Qm_15 <= {numQBIT_QD{1'bx}};
            if(notify_en) $display("@%.2fns: Tth_pr: RE to TM hold time violation!!\n",$realtime);
	end
end

function [numQBIT-1:0] Gen_multiBits;
        input a;
        integer tt;
        for (tt=0; tt<numQBIT; tt=tt+1) begin
                Gen_multiBits[tt] = a;
        end
endfunction

function [numAY-1:0] set0AY;
        input a;
        integer tt;
        for (tt=0; tt<numAY; tt=tt+1) begin
                set0AY[tt] = a;
        end
endfunction

task loadfile2otp;
reg[numBit_Line-1:0] data_shift;
reg[numBit_Line-1:0] sampleArray[0:numTotLine-1]; 
reg[numAddr-1:0] Atask;
integer Xptr,i,j,k;
begin
Xptr = 0;
Atask = 0;

$readmemh("loadfile.txt", sampleArray);
	for(i=0;i<numTotLine;i=i+1)begin
		data_shift = sampleArray[i];	

		//for(j=0;j<2**numAY;j=j+1)begin	  // Modified by Thomas 2021-4-22 for supporting no upper column address <AY_start==AY_end==AQ_start>	
		for(j=0;j<2**(numAY-NoAddrAY);j=j+1)begin	

		    if ((numQDperCol==1) && (numQDperRow==1)) begin     // Added by Thomas 2021-4-6 for supporting 1-ROW by 1-COLUMN
			if ((i==(numTotLine-1)) && (numRedundantRow>0)) otpCell_redundant_0[j]=data_shift[numBit_Line-1:0];
			else otpCell_normal_0[i][j]=data_shift[numBit_Line-1:0];
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end
		    else if ((numQDperCol==2) && (numQDperRow==2)) begin	// Modified by Thomas 2021-4-6 for supporting any 2-ROW by 2-COLUMN configuration
			//if(i==(numTotLine-2)) begin	// Modified by Thomas 2021-4-22 for supporting no Redundant Row
			if((i==(numTotLine-2)) && (numRedundantRow>0)) begin
				//{otpCell_redundant_1[j],otpCell_redundant_0[j]}=data_shift[31:0];
				{otpCell_redundant_1[j],otpCell_redundant_0[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-1))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-1)) && (numRedundantRow>0)) begin
				//{otpCell_redundant_3[j],otpCell_redundant_2[j]}=data_shift[31:0];
				{otpCell_redundant_3[j],otpCell_redundant_2[j]}=data_shift[numBit_Line-1:0];
			//end else if(i<64)begin // Modified by Thomas 2021-4-12 for supporting any 2-ROW by 2-COLUMN configration
			end else if(i<(2**numAX))begin
				//{otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[31:0];
				{otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[numBit_Line-1:0];
			end else begin
				//{otpCell_normal_3[i-64][j],otpCell_normal_2[i-64][j]}=data_shift[31:0];
				{otpCell_normal_3[i-numQBIT][j],otpCell_normal_2[i-numQBIT][j]}=data_shift[numBit_Line-1:0];
			end
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end	// Added by Thomas 2021-4-6 for supporting 2-ROW by 2-COLUMN
		    else if ((numQDperCol==1) && (numQDperRow==4)) begin   // Added by Thomas 2021-4-6 for supporting 1-ROW by 4-COLUMN
			//if(i==(numTotLine-1))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			if ((i==(numTotLine-1)) && (numRedundantRow>0)) begin
				{otpCell_redundant_3[j],otpCell_redundant_2[j],otpCell_redundant_1[j],otpCell_redundant_0[j]}=data_shift[numBit_Line-1:0];
			end else begin
				{otpCell_normal_3[i][j],otpCell_normal_2[i][j],otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[numBit_Line-1:0];
			end
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end // Added by Thomas 2021-4-6 for supporting 1-ROW by 4-COLUMN
		    else if ((numQDperCol==2) && (numQDperRow==4)) begin	// Added by Thomas 2021-4-6 for supporting 2-ROW by 4-COLUMN
			//if(i==(numTotLine-2)) begin	// Modified by Thomas 2021-4-22 for supporting no Redundant Row
			if((i==(numTotLine-2)) && (numRedundantRow>0)) begin
				{otpCell_redundant_3[j],otpCell_redundant_2[j],otpCell_redundant_1[j],otpCell_redundant_0[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-1))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-1)) && (numRedundantRow>0)) begin
				{otpCell_redundant_7[j],otpCell_redundant_6[j],otpCell_redundant_5[j],otpCell_redundant_4[j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==0) ) begin
				{otpCell_normal_3[i][j],otpCell_normal_2[i][j],otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[numBit_Line-1:0];
			end else begin
				{otpCell_normal_7[i-(2**numAX)][j],otpCell_normal_6[i-(2**numAX)][j],otpCell_normal_5[i-(2**numAX)][j],otpCell_normal_4[i-(2**numAX)][j]}=data_shift[numBit_Line-1:0];
			end
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end	// Added by Thomas 2021-4-6 for supporting 2-ROW by 4-COLUMN
		    else if ((numQDperCol==4) && (numQDperRow==4)) begin	// Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
			//if(i==(numTotLine-4)) begin	// Modified by Thomas 2021-4-22 for supporting no Redundant Row
			if((i==(numTotLine-4)) && (numRedundantRow>0)) begin
				{otpCell_redundant_3[j],otpCell_redundant_2[j],otpCell_redundant_1[j],otpCell_redundant_0[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-3))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-3)) && (numRedundantRow>0)) begin
				{otpCell_redundant_7[j],otpCell_redundant_6[j],otpCell_redundant_5[j],otpCell_redundant_4[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-2))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-2)) && (numRedundantRow>0)) begin
				{otpCell_redundant_11[j],otpCell_redundant_10[j],otpCell_redundant_9[j],otpCell_redundant_8[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-1))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-1)) && (numRedundantRow>0)) begin
				{otpCell_redundant_15[j],otpCell_redundant_14[j],otpCell_redundant_13[j],otpCell_redundant_12[j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==0) ) begin
				{otpCell_normal_3[i][j],otpCell_normal_2[i][j],otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==1) ) begin
				{otpCell_normal_7[i][j],otpCell_normal_6[i][j],otpCell_normal_5[i][j],otpCell_normal_4[i][j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==2) ) begin
				{otpCell_normal_11[i][j],otpCell_normal_10[i][j],otpCell_normal_9[i][j],otpCell_normal_8[i][j]}=data_shift[numBit_Line-1:0];
			end else begin
				{otpCell_normal_15[i-(2**numAX)][j],otpCell_normal_14[i-(2**numAX)][j],otpCell_normal_13[i-(2**numAX)][j],otpCell_normal_12[i-(2**numAX)][j]}=data_shift[numBit_Line-1:0];
			end
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end	// Added by Thomas 2021-4-6 for supporting 4-ROW by 4-COLUMN
		    else if ((numQDperCol==4) && (numQDperRow==2)) begin	// Added by Thomas 2021-4-6 for supporting 4-ROW by 2-COLUMN
			//if(i==(numTotLine-4)) begin	// Modified by Thomas 2021-4-22 for supporting no Redundant Row
			if((i==(numTotLine-4)) && (numRedundantRow>0)) begin
				{otpCell_redundant_1[j],otpCell_redundant_0[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-3))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-3)) && (numRedundantRow>0)) begin
				{otpCell_redundant_3[j],otpCell_redundant_2[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-2))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-2)) && (numRedundantRow>0)) begin
				{otpCell_redundant_5[j],otpCell_redundant_4[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-1))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-1)) && (numRedundantRow>0)) begin
				{otpCell_redundant_7[j],otpCell_redundant_6[j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==0) ) begin
				{otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==1) ) begin
				{otpCell_normal_3[i][j],otpCell_normal_2[i][j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==2) ) begin
				{otpCell_normal_5[i][j],otpCell_normal_4[i][j]}=data_shift[numBit_Line-1:0];
			end else begin
				{otpCell_normal_7[i-(2**numAX)][j],otpCell_normal_6[i-(2**numAX)][j]}=data_shift[numBit_Line-1:0];
			end
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end	// Added by Thomas 2021-4-6 for supporting 4-ROW by 2-COLUMN
		    else if ((numQDperCol==4) && (numQDperRow==1)) begin	// Added by Thomas 2021-4-6 for supporting 4-ROW by 1-COLUMN
			//if(i==(numTotLine-4)) begin	// Modified by Thomas 2021-4-22 for supporting no Redundant Row
			if((i==(numTotLine-4)) && (numRedundantRow>0)) begin
				{otpCell_redundant_0[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-3))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-3)) && (numRedundantRow>0)) begin
				{otpCell_redundant_1[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-2))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-2)) && (numRedundantRow>0)) begin
				{otpCell_redundant_2[j]}=data_shift[numBit_Line-1:0];
			//end else if(i==(numTotLine-1))begin // Modified by Thomas 2021-4-22 for supporting no Redundant Row
			end else if ((i==(numTotLine-1)) && (numRedundantRow>0)) begin
				{otpCell_redundant_3[j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==0) ) begin
				{otpCell_normal_1[i][j],otpCell_normal_0[i][j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==1) ) begin
				{otpCell_normal_3[i][j],otpCell_normal_2[i][j]}=data_shift[numBit_Line-1:0];
			end else if ( (i<(2**numAX)) && ((i%4)==2) ) begin
				{otpCell_normal_5[i][j],otpCell_normal_4[i][j]}=data_shift[numBit_Line-1:0];
			end else begin
				{otpCell_normal_7[i-(2**numAX)][j],otpCell_normal_6[i-(2**numAX)][j]}=data_shift[numBit_Line-1:0];
			end
			data_shift=data_shift>>(numQBIT_QD*numQDperRow);
		    end	// Added by Thomas 2021-4-6 for supporting 4-COLUMN by 1-ROW

		end
	end
end
endtask
`endif // EMPTY
endmodule





