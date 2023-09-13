//=============================================================================
//Copyright 2022 MACRONIX INTERNATIONAL Co., Ltd.  All Rights Reserved.
//CONFIDENTIAL SOFTWARE/DATA OF MACRONIX INTERNATIONAL Co., Ltd
//=============================================================================
//Program		Single Port SRAM Compiler
//Process		0.18μm CMOS SPDM/SPTM/SPQM BCD(5V/40V)
//Corner		TT
//Version		1.0
//Date			2022/11/07 14:00:49
//=============================================================================
//Instance Name		MSL18B_1536X8_RW10TM4_16_20221107
//Words			1536
//Bits			8
//Multiplexer Width	16
//=============================================================================
`timescale 1ns/10ps
`celldefine
module MSL18B_1536X8_RW10TM4_16_20221107
(
 CK,
 CSB,
 WEB,
 OEB,
 A,
 DI,
 DO
);
input		CK;	// Reference clock, rising
input		CSB;	// Chip Enable, 0/1=enable/disable
input		WEB;	// Write Enable, 0/1=write/read
input		OEB;	// DO Enable, 0/1=driven/float
input	 [10:0]	A;	// Address Bus
input	 [7:0]	DI;	// Input Data Bus
output	 [7:0]	DO;	// Output Data Bus
//--------------------------------------------------------------------------------
wire	ck_;		// Local CK
wire	csb_;		// Local CSB
wire	web_;		// Local WEB
wire	oeb_;		// Local OEB
wire	[10:0] a_;		// Local A
wire	[7:0] di_;		// Local DI
wire	[7:0] do_;		// Local DO
reg	[7:0] mem [0:(1536-1)];
reg	[7:0] rdata;
wire	cen;		// Chip Enable condition
wire	wen;		// Write Enable condition
reg	[16*20:1] mname;
initial	mname = "MSL18B_1536X8_RW10TM4_16_20221107";
//--------------------------------------------------------------------------------
// SDF buffers
 buf	(ck_, CK);
 buf	(csb_, CSB);
 buf	(web_, WEB);
 buf	(oeb_, OEB);
 buf	( a_[0], A[0] );
 buf	( a_[1], A[1] );
 buf	( a_[2], A[2] );
 buf	( a_[3], A[3] );
 buf	( a_[4], A[4] );
 buf	( a_[5], A[5] );
 buf	( a_[6], A[6] );
 buf	( a_[7], A[7] );
 buf	( a_[8], A[8] );
 buf	( a_[9], A[9] );
 buf	( a_[10], A[10] );
 buf	( di_[0], DI[0] );
 buf	( di_[1], DI[1] );
 buf	( di_[2], DI[2] );
 buf	( di_[3], DI[3] );
 buf	( di_[4], DI[4] );
 buf	( di_[5], DI[5] );
 buf	( di_[6], DI[6] );
 buf	( di_[7], DI[7] );
 bufif0	( DO[0] , do_[0], oeb_);
 bufif0	( DO[1] , do_[1], oeb_);
 bufif0	( DO[2] , do_[2], oeb_);
 bufif0	( DO[3] , do_[3], oeb_);
 bufif0	( DO[4] , do_[4], oeb_);
 bufif0	( DO[5] , do_[5], oeb_);
 bufif0	( DO[6] , do_[6], oeb_);
 bufif0	( DO[7] , do_[7], oeb_);
 not	(cen, CSB);
 nor	(wen, CSB, WEB);
//--------------------------------------------------------------------------------
// Function
 always @(posedge ck_)
 if (csb_ === 1'bx) Unknown("CSB");
 else if (csb_ === 1'b0) begin
  if (web_ === 1'bx) Unknown("WEB");
  if ((^a_) === 1'bx) Unknown("A");
 else begin
   if (web_ === 1'b0) begin
    mem[a_] = di_;
    rdata = mem[a_];
    end
   else if (web_ === 1'b1) rdata = mem[a_];
  end
 end
 assign do_ = rdata;
 task Unknown;
  input [16*64:1] pin;
  $display("%0t %0s @ %m, pin %0s is unknown",$time,mname,pin);
 endtask // Unknown
//--------------------------------------------------------------------------------
// Timings
 specify
  specparam
   tSCSH = 0.416,		// CSB Setup time (CSB=H)
   tSCSL = 0.638,		// CSB Setup time (CSB=L)
   tHCSH = 0.000,		// CSB Hold time (CSB=H)
   tHCSL = 0.318,		// CSB Hold time (CSB=L)
   tSWEH = 0.707,		// WEB Setup time (WEB=H)
   tSWEL = 0.846,		// WEB Setup time (WEB=L)
   tHWEH = 0.000,		// WEB Hold time (WEB=H)
   tHWEL = 0.000,		// WEB Hold time (WEB=L)
   tSAH = 0.450,		// A Setup time (A=H)
   tSAL = 0.563,		// A Setup time (A=L)
   tHAH = 0.328,		// A Hold time (A=H)
   tHAL = 0.348,		// A Hold time (A=L)
   tSDIH = 0.906,		// DI Setup time (DI=H)
   tSDIL = 1.102,		// DI Setup time (DI=L)
   tHDIH = 0.000,		// DI Hold time (DI=H)
   tHDIL = 0.000,		// DI Hold time (DI=L)
   tPQLH = 3.046,		// Max(CK rise -> DO rise)
   tPQHL = 2.932,		// Max(CK rise -> DO fall)
   tPOLZ = 0.433,		// OEB (DO=L->Z)
   tPOHZ = 0.433,		// OEB (DO=H->Z)
   tPOZL = 0.807,		// OEB (DO=Z->L)
   tPOZH = 0.793,		// OEB (DO=Z->H)
   tMKHI = 0.139,		// CK minimum high time
   tMKLO = 0.442;		// CK minimum low time
  $setuphold(posedge CK, posedge CSB, tSCSH, tHCSH);
  $setuphold(posedge CK, negedge CSB, tSCSL, tHCSL);
  $setuphold(posedge CK &&& cen, posedge WEB, tSWEH, tHWEH);
  $setuphold(posedge CK &&& cen, negedge WEB, tSWEL, tHWEL);
  $setuphold(posedge CK &&& cen, posedge A[0] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[0] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[1] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[1] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[2] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[2] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[3] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[3] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[4] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[4] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[5] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[5] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[6] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[6] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[7] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[7] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[8] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[8] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[9] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[9] , tSAL, tHAL);
  $setuphold(posedge CK &&& cen, posedge A[10] , tSAH, tHAH);
  $setuphold(posedge CK &&& cen, negedge A[10] , tSAL, tHAL);
  $setuphold(posedge CK &&& wen, posedge DI[0] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[0] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[1] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[1] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[2] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[2] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[3] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[3] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[4] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[4] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[5] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[5] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[6] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[6] , tSDIL, tHDIL);
  $setuphold(posedge CK &&& wen, posedge DI[7] , tSDIH, tHDIH);
  $setuphold(posedge CK &&& wen, negedge DI[7] , tSDIL, tHDIL);
  if (CK == 1) (posedge CK *> ( DO[0] +:DI[0] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[1] +:DI[1] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[2] +:DI[2] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[3] +:DI[3] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[4] +:DI[4] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[5] +:DI[5] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[6] +:DI[6] )) = (tPQLH,tPQHL);
  if (CK == 1) (posedge CK *> ( DO[7] +:DI[7] )) = (tPQLH,tPQHL);
  ( OEB *> DO[0] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[1] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[2] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[3] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[4] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[5] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[6] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  ( OEB *> DO[7] ) = (0, 0, tPOLZ, tPOZH, tPOHZ, tPOZL);
  $width(posedge CK, tMKHI);
  $width(negedge CK, tMKLO);
 endspecify
endmodule //MSL18B_1536X8_RW10TM4_16_20221107
`endcelldefine