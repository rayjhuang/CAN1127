//----------------------------------------------------------------------------
// Revision history:
// Rev 0.2  21/05/21: Update Tcd definition from rising CLK trigger (32ns max.) to falling CLK trigger (7ns max.)
// Rev 0.1  20/05/20: First creation based on datasheet V0.14
//----------------------------------------------------------------------------
// Module Name    : ATO0004KX8VI150BG33NA_FPGA
//----------------------------------------------------------------------------
// Pin List
//		A[numAddr-1:0]: Address (I) 
//		Q[numQBIT-1:0]: Data output (O)
//		CSB: Chip select, low active
//		CLK: R/W strobe; signal from system Clock
//		PGM: Program enable, high active (I) 
//		RE: Read enable 
//		SAP: Test pin.Set high.
//		TWLB: 00: Normal main array turn on;01:Odd main array;10:Even main array;11:redundant row
//		VDDP: High voltage pin for program, low for read. VH=3.7v (logi 1) VL=1.8v(logic 0) (P) 
//	  	VSS: GND (P)
//	  	VDD: Core supply voltage
//----------------------------------------------------------------------------
//----------------------------------------------------------------------------
`timescale 1ns/10ps
module ATO0008KX8VI150BG33NA_FPGA(A, CSB, CLK, PGM, RE, TWLB, VDDP, VSS, VDD, SAP, Q, pswdat, pswr, mclk);
input [7:0] pswdat;
input pswr, mclk;

`include "ATO0008KX8VI150BG33NA_parameter.txt"

input[numAddr-1:0] A;
input CSB;
input CLK;
input PGM; 
input RE;
input [1:0] TWLB;
input VDDP;
input VSS;
input VDD;
input [1:0] SAP;
//input [1:0] MR;
//input TM;
//input RESET12N;
//input RESET28N;

output [numQBIT-1:0] Q;

// translate_off

//reg [numQBIT-1:0] Q;
wire [numQBIT-1:0] Q;
reg [numQBIT-1:0] otpCell_normal[0:numX-1][0:numY-1];
reg [numQBIT-1:0] otpCell_redundant[0:numY-1];

/* control signal check*/
wire [5:0] control_set;
reg[2:0] mode_err;
reg silent_st;     // flag to inhibit timing check during starting up
wire PROGRAM = mode_err[2]; //{vdd,csb,pgm,re}=1010 
wire READ = mode_err[1];    //{vdd,csb,pgm,re}=1001 ?? 
wire CTRERR = mode_err[0];  //{vdd,csb,pgm,re}=1010 else??

wire RE_one = RE;
wire RE_zero = !RE;
wire PGM_one = PGM;
wire PGM_zero = !PGM;
wire PGMB_RE = !PGM && RE;
wire PGM_REB = PGM && !RE;
wire CS_RE = !CSB && RE;
wire CS_PGMB_RE = !CSB && !PGM && RE;
wire CS_PGM_REB = !CSB && PGM && !RE;

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
assign normal_access = (TWLB[1:0] == 2'b00);
assign redundant_access = (TWLB[1:0] == 2'b11);
// reserve address check or not (sc)
assign reserved_address_warning = (TWLB[1:0] == 2'b11) && (A_Y== set0AY(1'b1)) && Reserve_address_en;
assign odd_access = (TWLB[1:0] == 2'b01);
assign even_access= (TWLB[1:0] == 2'b10);
assign A_BIT = A[AQ_start:AQ_end];
assign A_Y = A[AY_start:AY_end];
assign A_X = A[AX_start:AX_end];

// reset12n,reset28n,TM timing check
reg notify_en;    //eliminate initial false timing check

reg notify_r1s;
reg notify_r1h;
reg notify_r2s;
reg notify_r2h;
reg notify_ts;
reg notify_th;

reg notify_vsr;
reg notify_vhr;
reg notify_vsp;
reg notify_vhp;

reg notify_ckl;
reg notify_cyr;
reg notify_ckh;
reg notify_pd;

reg notify_rsp;
reg notify_wsp;
reg notify_asp;

reg notify_ssp;
reg notify_wh; 
reg notify_shp;
reg notify_ahp;
reg notify_whp;
reg notify_hre;
reg notify_rsr; 
reg notify_ras;
reg notify_asr;
reg notify_wsr;
reg notify_hra;
reg notify_hrcb;
reg notify_rhr;
reg notify_hrpgm;

reg DUMMY_FLAG;
reg [numQBIT-1:0] Qm;  // output in normal read
reg [numQBIT-1:0] Qe;  // output in end of read cycle
time CLK_r;
time time_CLKH;
//To specify Q delay
wire CLK_Thold; // output hold after CLK high 
wire CLK_Tcd;   // output after CLK high, Tcd>Thold
reg [numQBIT-1:0] Qt; // output in transition read cycle bet'w Thold to Tcd
/*timing violation check*/
specify 
	//Timing check for PROGRAM 
        specparam Tr1s_pp = 100.000000;
        specparam Tr1h_pp = 100.000000;
        specparam Tr2s_pp = 100.000000;
        specparam Tr2h_pp = 100.000000;

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
	$setup(posedge VDDP, negedge CSB &&& PGM_one, Tvs_pp, notify_vsp); 
	$hold(posedge CSB &&& PGM_one, negedge VDDP, Tvh_pp, notify_vhp); 

	$setup(posedge PGM, negedge CSB &&& RE_zero, Tws_pp, notify_wsp); 
	$setup(negedge RE, negedge CSB &&& PGM_one, Trs_pp, notify_rsp); 

	$setup(negedge CSB, posedge TWLB[0] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge TWLB[0] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge TWLB[1] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge TWLB[1] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[0] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[0] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[1] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[1] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[2] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[2] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[3] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[3] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[4] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[4] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[5] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[5] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[6] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[6] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[7] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[7] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[8] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[8] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[9] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[9] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[10] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[10] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[11] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[11] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[12] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[12] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[13] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[13] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, posedge A[14] &&& PGM_REB, Tas_pp, notify_asp);
	$setup(negedge CSB, negedge A[14] &&& PGM_REB, Tas_pp, notify_asp);

    	$setup(posedge TWLB[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge TWLB[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge TWLB[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
   	$setup(negedge TWLB[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[0], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[1], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[2], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[2], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[3], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[3], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[4], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[4], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[5], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[5], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[6], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[6], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[7], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[7], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[8], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[8], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[9], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[9], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[10], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[10], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[11], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[11], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[12], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[12], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[13], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[13], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(posedge A[14], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);
    	$setup(negedge A[14], posedge CLK &&& CS_PGM_REB, Tss_pp, notify_ssp);

	$width(posedge CLK &&& CS_PGM_REB, Tsw_min_pp, 0, notify_wh);
	//$width(posedge CLK &&& CS_PGM_REB, Tsw_min_pp, Tsw_max_pp, notify_wh);

	$hold(negedge CLK &&& CS_PGM_REB, posedge TWLB[0], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge TWLB[0], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge TWLB[1], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge TWLB[1], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[0], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[0], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[1], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[1], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[2], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[2], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[3], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[3], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[4], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[4], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[5], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[5], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[6], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[6], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[7], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[7], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[8], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[8], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[9], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[9], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[10], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[10], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[11], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[11], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[12], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[12], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[13], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[13], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, posedge A[14], Tsh_pp, notify_shp);
	$hold(negedge CLK &&& CS_PGM_REB, negedge A[14], Tsh_pp, notify_shp);

	$hold(posedge TWLB[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge TWLB[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge TWLB[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge TWLB[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[0] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[1] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[2] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[2] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[3] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[3] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[4] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[4] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[5] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[5] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[6] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[6] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[7] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[7] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[8] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[8] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[9] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[9] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[10] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[10] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[11] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[11] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[12] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[12] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[13] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[13] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(posedge A[14] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);
	$hold(negedge A[14] &&& PGM_REB, posedge CSB, Tah_pp, notify_ahp);

	$hold(posedge CSB &&& RE_zero, negedge PGM, Twh_pp, notify_whp);
	$hold(posedge CSB &&& PGM_one, posedge RE, Trh_pp, notify_hre);

	//Timing check for READ 
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

//TM timing check
//	$setup(negedge RE, posedge TM &&& tm_CSB_PGMB, Tts_pr, notify_ts); 
//	$hold(negedge TM &&& tm_CSB_PGMB, posedge RE, Tth_pr, notify_th); 

//VDDP timing check
	$setup(negedge VDDP, negedge CSB &&& RE_one, Tvs_pr, notify_vsr); 
	$hold(posedge CSB &&& RE_one, posedge VDDP, Tvh_pr, notify_vhr); 

	$setup(negedge PGM, negedge CSB &&& RE_one, Tws_pr, notify_wsr); 
	$setup(posedge RE, negedge CSB &&& PGM_zero, Trs_pr, notify_rsr); 

	$setup(negedge CSB, posedge TWLB[0] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge TWLB[0] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, posedge TWLB[1] &&& PGMB_RE, Tas_pr, notify_asr);
	$setup(negedge CSB, negedge TWLB[1] &&& PGMB_RE, Tas_pr, notify_asr);
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

    	$setup(posedge TWLB[0], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge TWLB[0], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(posedge TWLB[1], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
    	$setup(negedge TWLB[1], posedge CLK &&& CS_PGMB_RE, Tras, notify_ras);
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

	$width(posedge CLK &&& CS_PGMB_RE, Tckh, 0, notify_ckh);
	$width(negedge CLK &&& CS_PGMB_RE, Tckl, 0, notify_ckl);
	$period(posedge CLK &&& CS_PGMB_RE, Tcyc, notify_cyr);
	$period(negedge CLK &&& CS_PGMB_RE, Tcyc, notify_cyr);

	$hold(negedge CLK &&& CS_PGMB_RE, posedge TWLB[0], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge TWLB[0], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge TWLB[1], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge TWLB[1], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[0], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[0], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[1], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[1], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[2], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[2], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[3], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[3], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[4], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[4], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[5], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[5], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[6], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[6], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[7], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[7], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[8], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[8], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[9], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[9], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[10], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[10], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[11], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[11], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[12], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[12], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[13], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[13], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, posedge A[14], Trah, notify_hra);
	$hold(negedge CLK &&& CS_PGMB_RE, negedge A[14], Trah, notify_hra);

	$hold(posedge TWLB[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge TWLB[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge TWLB[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge TWLB[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[0] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[1] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[2] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[2] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[3] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[3] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[4] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[4] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[5] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[5] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[6] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[6] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[7] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[7] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[8] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[8] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[9] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[9] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[10] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[10] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[11] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[11] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[12] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[12] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[13] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[13] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(posedge A[14] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);
	$hold(negedge A[14] &&& PGMB_RE, posedge CSB, Tah_pr, notify_hrcb);

	$hold(posedge CSB &&& PGM_zero, negedge RE, Trh_pr, notify_rhr);
	$hold(posedge CSB &&& RE_one, posedge PGM, Twh_pr, notify_hrpgm);

/*
	$hold(posedge CSB &&& RE_one, Q[0],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[1],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[2],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[3],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[4],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[5],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[6],Tqh_pr,notify_hrcb);
	$hold(posedge CSB &&& RE_one, Q[7],Tqh_pr,notify_hrcb);
*/
/*
	$hold(posedge CLK &&& CS_RE, Q[0],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[1],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[2],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[3],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[4],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[5],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[6],Thold,notify_hrcb);
	$hold(posedge CLK &&& CS_RE, Q[7],Thold,notify_hrcb);
*/
	//define Tcd, Thold, Tqh_pr delay
	//Tqh_pr: data hold after CSB high
  	//if (PGMB_RE) (posedge CSB *> (Q +: Qe)) = Tqh_pr;   	//multi-path, Qe: Q at end of read 
  	if (PGMB_RE) (posedge CSB => (Q[0] +: Qe[0])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[1] +: Qe[1])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[2] +: Qe[2])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[3] +: Qe[3])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[4] +: Qe[4])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[5] +: Qe[5])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[6] +: Qe[6])) = Tqh_pr;   	//parallel connection 
  	if (PGMB_RE) (posedge CSB => (Q[7] +: Qe[7])) = Tqh_pr;   	//parallel connection 
  
	//Tcd: data out after CLK high
	//if (CS_PGMB_RE) (posedge CLK *> (Q +: Qm)) = Tcd;		//multi-path  
   	
	if (CS_RE) (negedge CLK => (Q[0] +: Qm[0])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[1] +: Qm[1])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[2] +: Qm[2])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[3] +: Qm[3])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[4] +: Qm[4])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[5] +: Qm[5])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[6] +: Qm[6])) = Tcd;	// negedge para connection
	if (CS_RE) (negedge CLK => (Q[7] +: Qm[7])) = Tcd;	// negedge para connection
   
	//Thold	
	//if (CS_PGMB_RE) (CLK *> Q) = Thold;				//multi-path: use simple delay
//  	if (CS_PGMB_RE) (CLK => Q[0]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[1]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[2]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[3]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[4]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[5]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[6]) = Thold;				//parallel connection
//  	if (CS_PGMB_RE) (CLK => Q[7]) = Thold;				//parallel connection
  	
//	if (CS_PGMB_RE) (CLK => (Q : 1'bx)) = Thold;			//parallel (sc)
  	if (CS_RE) (posedge CLK => (Q : 1'bx)) = Thold;			//parallel (sc:092018)
endspecify 

integer i, j, m;
/* initial clear cells*/
initial begin
        notify_r1s = 0;
        notify_r1h = 0;
        notify_r2s = 0;
        notify_r2s = 0;
        notify_ts = 0;
        notify_th = 0;

        notify_en = 0;

        notify_vsr = 0;
        notify_vhr = 0;
        notify_vsp = 0;
        notify_vhp = 0;

        notify_ckh = 0;
        notify_ckl = 0;
        notify_cyr = 0;
        notify_pd = 0;

        notify_rsp = 0;
        notify_wsp = 0;
        notify_asp = 0;

        notify_ssp = 0;
        notify_wh = 0;
        notify_shp = 0;
	notify_ahp = 0;
        notify_whp = 0;
        notify_hre = 0;

        notify_rsr = 0;    //old
        notify_ras = 0;
        notify_asr = 0;
        notify_wsr = 0;

        notify_ckh = 0;
        notify_hra = 0;
        notify_hrcb = 0;
        notify_rhr = 0;
        notify_hrpgm = 0;
	DUMMY_FLAG = 0;
	#0.1 notify_en = 1;    //flag to inhibit timing check during initiation

	//clear main array 
	for (i=0; i < 2**numAX; i=i +1)begin	
		for (j=0; j < 2**numAY; j=j+1)begin
			for (m=0; m < numQBIT; m=m+1) begin
	   			otpCell_normal[i][j][m] = 1'b0;
			end
		end
	end
	//clear redundant array 
	for (j=0; j < 2**numAY; j=j+1)begin
        	for (m=0; m < numQBIT; m=m+1) begin
                	otpCell_redundant[j][m] = 1'b0;
            	end
    	end
	silent_st = 0;
/*
	#100;
        if(LOAD_PROGRAM == 1)
                loadfile2otp;
*/
        #500;
end


// control signal check     // (design dependent)
assign control_set = {VDDP, CSB, PGM, RE}; // , RESET12N, RESET28N}; 
//decoded into PROGRAM,READ,CTRERR, default
always @(control_set) begin
	casex(control_set)
	  6'b1010 : mode_err = {1'b1 ,1'b0, 1'b0}; //PROGRAM
      	  6'b0001 : mode_err = {1'b0 ,1'b1, 1'b0}; //READ   //sc check!!
	  6'b1x11 : mode_err = {1'b0 ,1'b0, 1'b1}; //Both RE,PGM=1(CTRERR=1)
	  6'b1000 : mode_err = {1'b0 ,1'b0, 1'b1}; //VDDP high, CSB low, No READ,PGM (Stdby?)
	  //4'b00xx : mode_err = {1'b0 ,1'b0, 1'b1}; //VDDP low, CSB low. Either Read or Write can go
	  default: mode_err = {1'b0, 1'b0, 1'b0}; 
	endcase
end

//always @(posedge CTRERR)
//	$display("@%.2fns \tControl signal(s) is(are) arranged UNCORRECTLY!!!\n",$realtime);	

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
                        $display("@%.2fns \t Tsw_max_pp: CLK high time %.2fns over Max value!!!\n",$realtime, time_CLKH);
                end
        end
end

/*** program otpCell ***/
always @(posedge CLK) begin
	if(normal_access & PROGRAM) begin
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_normal[%h][%h][%h]\n",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM) begin
		otpCell_redundant [A_Y][A_BIT] <= 1'b1;
	    	//$display("@%.2fns \t program otpCell_redundant[%h][%h]\n",$realtime, A_Y, A_BIT);
	end else if(redundant_access & reserved_address_warning & PROGRAM) begin
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h program access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
	end
end

//program setup violation
always @(posedge notify_ssp) begin
	if(normal_access & PROGRAM) begin
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning & PROGRAM) begin
                 otpCell_redundant[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end 
end

always @(negedge notify_ssp) begin
        if(normal_access & PROGRAM) begin
                otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM) begin
                 otpCell_redundant[A_Y][A_BIT] <= 1'bx;
                $display("@%.2fns \t Tss_pp: A to CLK setup vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end
end
 

//PGM pulse high violation report
always @(posedge notify_wh) begin  //pulse width high violation
	if(normal_access) begin    //no PROGRAM
		otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;	
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
	end else if(redundant_access & ~reserved_address_warning) begin //no PRORAM
		otpCell_redundant[A_Y][A_BIT] <= 1'bx;
		if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
	end
end

always @(negedge notify_wh) begin  //pulse width high violation
        if(normal_access) begin
                otpCell_normal[A_X][A_Y][A_BIT] <= 1'bx;
                if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, A_X, A_Y, A_BIT);
        end else if(redundant_access & ~reserved_address_warning) begin
                otpCell_redundant[A_Y][A_BIT] <= 1'bx;
                if(notify_en) $display("@%.2fns \t Tsw_min_pp: min CLK high. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, A_Y, A_BIT);
        end
end

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
end

//hold time violation report
wire [numAddr-1:0] A_dP;
wire [numAddr-1:0] A_dF;
wire [numAX-1:0] AX_dP, AX_dF;
wire [numAY-1:0] AY_dP, AY_dF;
wire [numAQ-1:0] ABIT_dP, ABIT_dF;

assign #(Tsh_pp + 2) A_dP = A;  //A time delay to CLK hold (Tsh_pp?) 
assign #(Tah_pp + Twh_pp + 2) A_dF = A;  //A time delay to PGM low (?)
assign AX_dP = A_dP[AX_start:AX_end];
assign AY_dP = A_dP[AY_start:AY_end]; 
assign ABIT_dP = A_dP[AQ_start:AQ_end];
assign AX_dF = A_dF[AX_start:AX_end];
assign AY_dF = A_dF[AY_start:AY_end]; 
assign ABIT_dF = A_dF[AQ_start:AQ_end];

always @(posedge notify_shp) begin //Program Address to CLK hold time violation, A_dP??	
	if(normal_access & PROGRAM) begin
                otpCell_normal[AX_dP][AY_dP][ABIT_dP] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, AX_dP, AY_dP, ABIT_dP);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM) begin
                otpCell_redundant[AY_dP][ABIT_dP] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, AY_dP, ABIT_dP);
        end
end

always @(negedge notify_shp) begin     //Program Address to CLK hold time violation
        if(normal_access & PROGRAM) begin
                otpCell_normal[AX_dP][AY_dP][ABIT_dP] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, AX_dP, AY_dP, ABIT_dP);
        end else if(redundant_access & ~reserved_address_warning & PROGRAM) begin
                otpCell_redundant[AY_dP][ABIT_dP] <= 1'bx;
                $display("@%.2fns \t Tsh_pp: A to CLK hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, AY_dP, ABIT_dP);
        end
end

always @(posedge notify_ahp) begin       //CSB hold time violation, A_dF??
        if(normal_access & PGM) begin
                otpCell_normal[AX_dF][AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, AX_dF, AY_dF, ABIT_dF);
        end else if(redundant_access & ~reserved_address_warning & PGM) begin
                otpCell_redundant[AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, AY_dF, ABIT_dF);
        end
end

always @(negedge notify_ahp) begin       //CSB hold time violation
        if(normal_access & PGM) begin
                otpCell_normal[AX_dF][AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, AX_dF, AY_dF, ABIT_dF);
        end else if(redundant_access & ~reserved_address_warning & PGM) begin
                otpCell_redundant[AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Tah_pp: CSB to A hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, AY_dF, ABIT_dF);
        end
end

always @(posedge notify_whp) begin       //PGM hold time violation,  //sc (Use A_dF. OK)
        if(normal_access & !silent_st) begin
                otpCell_normal[AX_dF][AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, AX_dF, AY_dF, ABIT_dF);
        end else if(redundant_access & ~reserved_address_warning & !silent_st) begin
                otpCell_redundant[AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, AY_dF, ABIT_dF);
        end
end

always @(negedge notify_whp) begin       //PGM hold time violation
        if(normal_access & !silent_st) begin
                otpCell_normal[AX_dF][AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program normal cell[%d][%d] Bit[%d]!!",$realtime, AX_dF, AY_dF, ABIT_dF);
        end else if(redundant_access & ~reserved_address_warning & !silent_st) begin
                otpCell_redundant[AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Twh_pp: PGM to CSB hold vio. Fail to program redundant cell[%d] Bit[%d]!!",$realtime, AY_dF, ABIT_dF);
        end
end

always @(posedge notify_hre) begin       //RE hold time violation
        if(normal_access & !silent_st) begin
                otpCell_normal[AX_dF][AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Fail to program normal cell[%d][%d] Bit[%d]. RE active too soon!!",$realtime, AX_dF, AY_dF, ABIT_dF);
        end else if(redundant_access & ~reserved_address_warning & !silent_st) begin
                otpCell_redundant[AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Fail to program redundant cell[%d] Bit[%d]. RE active too soon!!",$realtime, AY_dF, ABIT_dF);
        end
end

always @(negedge notify_hre) begin       //RE hold time violation
        if(normal_access & !silent_st) begin
                otpCell_normal[AX_dF][AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Fail to program normal cell[%d][%d] Bit[%d]. RE active too soon!!",$realtime, AX_dF, AY_dF, ABIT_dF);
        end else if(redundant_access & ~reserved_address_warning & !silent_st) begin
                otpCell_redundant[AY_dF][ABIT_dF] <= 1'bx;
                $display("@%.2fns \t Fail to program redundant cell[%d] Bit[%d]. RE active too soon!!",$realtime, AY_dF, ABIT_dF);
        end
end


/* read cells to Q latch*/
reg notify_rs_d;
reg read_time_vio_before_clk;
always @(posedge CLK) begin
	if(READ & ~DUMMY_FLAG) begin
            $display("Read dummy cycle.\n");
            DUMMY_FLAG <=#2 1'b1;   //sc ?
	end
end

always @(posedge CLK) begin
	if(READ & DUMMY_FLAG & normal_access) begin
            Qm <= otpCell_normal[A_X][A_Y];
        end else if(READ & DUMMY_FLAG & redundant_access & ~reserved_address_warning) begin
            Qm <= otpCell_redundant[A_Y];
        end else if(READ & DUMMY_FLAG & redundant_access & reserved_address_warning) begin
	    Qm <=  Q0;    //sc output 0s when reading reserved address
	    $display("@%.2fns \tTWLB== 2'b%b, Reserved Address %d'h%h %d'h%h read access is not allowed!!!\n",$realtime, TWLB, numAQ, A_BIT, numAY, A_Y);
        end else if(READ & DUMMY_FLAG & odd_access) begin
                //if(A[0]== 1'b0)
		if(A[AX_end]== 1'b0)  //modified by YC on 06/23/2016
                   Qm <=  Q1;
                else
                   Qm <=  otpCell_normal[A_X][A_Y];
        end else if(READ & DUMMY_FLAG & even_access) begin
                //if(A[0]== 1'b1)
		if(A[AX_end]== 1'b1)  //modified by YC on 06/23/2016
                   Qm <=  Q1;
                else
                   Qm <=  otpCell_normal[A_X][A_Y];
        end else begin
		   Qm <= Qx;
	end
end


always @(notify_rsr) begin
	 read_time_vio_before_clk <=#1 1'b1;
	 if(notify_en) $display("@%.2fns \t Trs_pr: RE to CSB setup violation.\n",$realtime);  
end

always @(notify_wsr) begin
	 read_time_vio_before_clk <=#1 1'b1;
	 if(notify_en) $display("@%.2fns \t Tws_pr: PGM to CSB setup violation.\n",$realtime);  
end 


always @(notify_ras) begin
	 read_time_vio_before_clk <=#1 1'b1;
	 if(notify_en) $display("@%.2fns \t Tras_pr: Addr to CLK setup time violation.\n",$realtime);  
end

always @(notify_asr) begin
	 read_time_vio_before_clk <=#1 1'b1;
	 if(notify_en) $display("@%.2fns \t Tas_pr: CSB to Addr setup time violation.\n",$realtime);  
end

always @(notify_rhr) begin
	 read_time_vio_before_clk <=#1 1'b1;
	 if(notify_en) $display("@%.2fns \t Trh_pr: RE to CSB hold time violation.\n",$realtime);  
end

//
always @(notify_rsp) begin
	 if(notify_en) $display("@%.2fns \t Trs_pp: RE to CSB setup time violation.\n",$realtime);  
end

always @(notify_wsp) begin
	 if(notify_en) $display("@%.2fns \t Tws_pp: PGM to CSB setup time violation.\n",$realtime);  
end

always @(notify_asp) begin
	 if(notify_en) $display("@%.2fns \t Tas_pp: CSB to Addr setup time violation.\n",$realtime);  
end
//

always @(negedge RE) begin
	read_time_vio_before_clk <=#1 1'b0;  //clear flag after read 
end

always @(posedge notify_ckh) begin
	if(READ & DUMMY_FLAG) begin
                Qm <=  Qx;
		if(notify_en) $display("@%.2fns Tckh: Min CLK high period violation.\n", $realtime);  //sc check
	end
end

always @(negedge notify_ckh) begin
        if(READ & DUMMY_FLAG) begin
                Qm <=  Qx;
		if(notify_en) $display("@%.2fns Tckh: Min CLK high period violation.\n", $realtime);  //sc check
	end
end

assign #Thold CLK_Thold = CLK & CS_PGMB_RE;
assign #(Tcd) CLK_Tcd = CLK & CS_PGMB_RE;
//wire Tran_region = CLK_Thold & ~CLK_Tcd;     //Transition region for posedge CLK=>Tcd
wire Tran_region = CLK_Thold | CLK_Tcd;        //Transition region for negedge CLK=>Tcd
always @(posedge CLK_Thold or negedge CS_RE)  //sc "or?"
	Qt <= Qx;
//always @(posedge CLK_Tcd)        //del when change Tcd from pos to neg CLK
//	Qt <= Q1;   //sc  Q1?
	
always @(posedge CSB or posedge RE)
	DUMMY_FLAG <=#1 1'b0;   // reset DUMMY_FLAG
	

//assign Q = Tran_region ? Qt : CSB ? Qe : Qm;



always @(posedge CSB) begin
	if(PGMB_RE) begin
		Qe <= Qx;	//Read cycle finish 
	end
end

always @(negedge CSB) begin
        if(PGMB_RE) begin
                Qe <= Q1;       //start Reading 
        end
end

always @(posedge notify_ckl) begin
        if(notify_en) begin
            $display("@%.2fns \t Tckl: min CLK low period violation!!\n", $realtime);
        end
end

always @(negedge notify_ckl) begin
        if(notify_en) begin
            $display("@%.2fns \t Tckl: min CLK low period violation!!\n", $realtime);
        end
end

always @(posedge notify_cyr) begin
        if(notify_en) begin
            $display("@%.2fns \t Tcyc: Read CLK period vio!!\n", $realtime);
        end
end

always @(negedge notify_cyr) begin
        if(notify_en) begin
            $display("@%.2fns \t Tcyc: Read CLK period vio!!\n", $realtime);
        end
end

// VDDP
always @(posedge notify_vsr) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvs_pr: VDDP to CSB setup vio!!\n", $realtime);
        end
end

always @(negedge notify_vsr) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvs_pr: VDDP to CSB setup vio!!\n", $realtime);
        end
end

always @(posedge notify_vhr) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvh_pr: VDDP to CSB hold vio!!\n", $realtime);
        end
end

always @(negedge notify_vhr) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvh_pr: VDDP to CSB hold vio!!\n", $realtime);
        end
end

always @(posedge notify_vsp) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvs_pp: VDDP to CSB setup vio!!\n", $realtime);
        end
end

always @(negedge notify_vsp) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvs_pp: VDDP to CSB setup vio!!\n", $realtime);
        end
end

always @(posedge notify_vhp) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvh_pp: VDDP to CSB hold vio!!\n", $realtime);
        end
end

always @(negedge notify_vhp) begin
        if(notify_en) begin
            $display("@%.2fns \t Tvh_pp: VDDP to CSB hold vio!!\n", $realtime);
        end
end

always @(posedge notify_hra) begin
        if(READ) begin
            Qm <= Qx;
            $display("Address hold time violation!!\n");
        end
end

always @(negedge notify_hra) begin
	if(READ) begin
            Qm <= Qx;
            $display("Address hold time violation!!\n");
	end
end

// RE to TM timing check (aft read power down)
always @(notify_ts) begin
	if(!READ) begin
            Qm <= Qx;
            if(notify_en) $display("@%.2fns: Tts_pr: RE to TM setup time violation!!\n",$realtime);
	end
end

always @(notify_th) begin
	if(!READ) begin
            Qm <= Qx;
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


// translate_on
`ifdef FPGA
wire [7:0] dout_64, dout_8k;
wire [7:0] sel_dout = TWLB=='h3 ?dout_64 :dout_8k;
wire [7:0] sel_wdat = pswr ?pswdat :(sel_dout|(8'h1<<A[8:6]));
`ifdef SMIMS
dist_mem_8kx8 U0 (
	.a	({A[15:9],A[5:0]}),
	.d	(sel_wdat),
	.clk	(mclk),
	.we	(pgm_8k),
	.qspo	(dout_8k)
	);
dist_mem_64x8 U1 (
	.a	(A[5:0]),
	.d	(sel_wdat),
	.clk	(mclk),
	.we	(pgm_64),
	.qspo	(dout_64)
	);
`endif // SMIMS
reg [7:0] d_out;
assign Q = d_out;
reg d_clk;
always @(negedge mclk) if (CLK & ~PGM & ~VDDP) d_out <= ~CSB & RE ?sel_dout :'hdd; // CLK high
always @(posedge mclk) d_clk <= CLK;
assign pgm_8k = d_clk & ~CLK & PGM & (VDDP|pswr) & ~RE & ~CSB & (TWLB=='h0); // CLK fall
assign pgm_64 = d_clk & ~CLK & PGM & (VDDP|pswr) & ~RE & ~CSB & (TWLB=='h3);
`endif // FPGA
endmodule

