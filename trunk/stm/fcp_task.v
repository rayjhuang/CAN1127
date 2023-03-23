
reg[31:0] FCP_UI = 160*1000; // ns

`define D_MINUS `USBCONN.DN_COMP

function FcpParity;
input [7:0] dat;
reg [7:0] ii;
begin
	FcpParity = 1; // odd parity
	for (ii=0; ii<8; ii=ii+1)
	   FcpParity = FcpParity + dat[ii];
end
endfunction // FcpParity

task CheckHVDCP;
fork
	begin
	   wait (`USBCONN.v_DN > 415) $display ($time,"ns <%m> D+/D- short (DCP)");
	   wait (`USBCONN.v_DN < 415) $display ($time,"ns <%m> D- pull-down (HVDCP)");
	   disable HVDCP_to;
	end begin: HVDCP_to
	   #(1000*1000*30) $display ($time,"ns <%m> HVDCP initial timeout");
	   $finish;
	end
join
endtask // CheckHVDCP

task KeepDmIdle;
input [7:0] to; // ms
fork: keep_idle
	#(1000*1000*to) disable keep_idle;
	@(`D_MINUS) begin
	   $display ($time,"ns <%m> ERROR: D- should keep idle");
	   $finish;
	end
join
endtask // KeepDmIdle

`define FcpDevDrv(v) `USBCONN.USBDN.FcpDrv = v

task FcpDevTx;
input [2:0] typ; // [0]:start,[1]:parity ending,[2]:fewer sync
input [8:0] dat; // including PARITY bit at [0]
reg [7:0] idx;
reg cmp;
begin
	//`DPDNMUX.DevDrvDn =1;
	$display ($time,"ns <%m> %0s0x%02x%s", typ[0]?"+":"", dat[8:1], typ[1]?(dat[0]?",1":",0"):"");
	cmp = `D_MINUS;
	if (typ[0]) begin
	   if (~typ[2]) repeat (2) begin
	      cmp = 1 - cmp;
	      `FcpDevDrv (cmp); #(FCP_UI/4);
	   end
	   cmp = 1 - cmp;
	   if (cmp!=dat[8]) begin
	      `FcpDevDrv (cmp); #(FCP_UI/4);
	   end
	end
	for (idx=0; idx<8; idx=idx+1) begin
	   `FcpDevDrv (dat[8-idx]); #(FCP_UI);
	end
	if (typ[1]) begin
	   `FcpDevDrv (dat[0]*typ[0]); #(FCP_UI);
	end
  	
->ev;	`FcpDevDrv (1'hx);
end
endtask // FcpDevTx

task FcpDevReset;
begin
	repeat (12) FcpDevTx (0,'h1ff);
	FcpDevTx (2,'h1ff);
end
endtask // FcpDevReset

task FcpDevPing;
input start;
begin
	FcpDevTx (start,'h1ff);
	FcpDevTx (2,    'h1ff);
end
endtask // FcpDevPing

task FcpDevRx;
input [8:0] exp; // including PARITY bit at [0]
time delta;
reg [7:0] ii;
integer rx_ui;
reg [8:0] FcpData; // including PARITY bit at [0]
event ev;
fork
begin
	rx_ui = FCP_UI;
	@(`D_MINUS) #1 if (`D_MINUS===1'hx) @(`D_MINUS) #1;
	repeat (3)
	   fork
	   begin: sync
	         delta = $time;
	         @(`D_MINUS) #1 if (`D_MINUS===1'hx) @(`D_MINUS) #1;
	         delta = $time - delta;
	         disable sample;
//	         $display ($time,"ns <%m> %0dns SYNC (%.1f%%)",delta,100.0*delta/(FCP_UI/4));
	         if (delta<(0.8*FCP_UI/4) || delta>(1.2*FCP_UI/4)) `HW_FIN (($time,"ns <%m> ERROR: invalid SYNC"))
	         rx_ui = delta*4;
	   end // sync
	   begin: sample
	               #(rx_ui/2) FcpData = FcpData<<1 | `D_MINUS;
	         delta = 0;
	         disable sync;
	   end // sample
	   join
	if (delta>0)   #(rx_ui/2) FcpData = FcpData<<1 | `D_MINUS;
	->ev;
	repeat (8) begin #(rx_ui) FcpData = FcpData<<1 | `D_MINUS; ->ev; end
	#(0.3*rx_ui) ->ev; // to exit before the end of this bit
	for (ii=0; ii<9; ii=ii+1)
	   if (exp[ii]!==FcpData[ii] && exp[ii]!==1'bx) begin
	      $display ($time,"ns <%m> ERROR: FCP read mismatch, exp: %02x,%d, dat:%02x,%d",
	                                               exp>>1, exp[0], FcpData>>1, FcpData[0]);
	      #266 $finish;
	   end
	disable timeout;
end begin: timeout
	#(1000*1000*10) begin
	   $display ($time,"ns <%m> ERROR: timeout");
	   $finish;
	end
end
join
endtask // FcpDevRx


// tasks for FCP cycles by I2C
// -----------------------------------------------------------------------------
parameter MAX_D_BIT = 15;
parameter MAX_D_DEP = 2**MAX_D_BIT;
parameter I2C_POLL_MAX = 10; // 10 ms

task I2cFcpOut;
input [1:0] typ; // [0]:SYNC,[1]:PARITY
input [7:0] dat;
input poll;
begin
	`I2CMST.sfrw (`FCPCTL,{6'h4,typ}); // FCP_EN
	`I2CMST.sfrw (`FCPDAT,dat);
	if (poll) I2cFcpPol ('h02); // polling TxEmpty
end
endtask // I2cFcpOut

task I2cFcpPol; // polling and clear
input [7:0] msk;
begin
	fork
	begin
	   `I2CMST.sfrw (`FCPSTA,msk); // clear status before polling it
	   `I2CMST.rddat =0;
	   while (!(`I2CMST.rddat & msk)) `I2CMST.sfrr (`FCPSTA,'hxx);
	   disable I2cFcpPol;
	end
	#(1000*1000*I2C_POLL_MAX) `HW_FIN (($time,"ns <%m> ERROR: I2C polling timeout"))
	join
end
endtask // I2cFcpPol

task ChkAdpPing;
input start;
time delta;
event ev;
fork
	#(1000*1000*6) `HW_FIN (($time,"ns <%m> ERROR: PING time-out"))
	begin
	   ->ev;
	   if (start)
	   @(posedge `D_MINUS) if (`D_MINUS===1'hx) @(posedge `D_MINUS);
	   @(posedge `D_MINUS) if (`D_MINUS===1'hx) @(posedge `D_MINUS); delta = $time;
	   @(negedge `D_MINUS) if (`D_MINUS===1'hx) @(negedge `D_MINUS); delta = $time - delta;
//	   $display ($time,"ns <%m> %0dns PING (%.1f%%)",delta,100.0*delta/(FCP_UI*16));
	   if (delta>(1.2*16*FCP_UI)
	    || delta<(0.8*16*FCP_UI)) `HW_FIN (($time,"ns <%m> ERROR: invalid PING, %0dus",delta/1000))
	   #(FCP_UI*0.9) // keep low for a UI, SLAVE may faster 10% than MASTER
	   if (`D_MINUS!==0) `HW_FIN (($time,"ns <%m> ERROR: invalid PING ending"))
	   #(FCP_UI*0.1)
	   disable ChkAdpPing;
	end
join
endtask // ChkAdpPing

task FcpAptTx;
input [MAX_D_BIT-1:0] cnt;
input [MAX_D_DEP*8-1:0] wdat;
reg [MAX_D_BIT-1:0] ii,jj;
begin
	$write ($time,"ns <%m> cnt:%0d",cnt);
	if (cnt>0) $write (", dat:");
	for (ii=0;ii<cnt;ii=ii+1) begin
	   if ((cnt-ii)%4==0 && ii) $write ("_");
	   $write ("%02x",wdat[(cnt-ii-1)*8+:8]);
	end
	$write ("\n");
	fork
	begin
	   for (ii=0; ii<cnt; ii=ii+1)
	      FcpDevRx ( { wdat>>(ii*8), FcpParity(wdat>>(ii*8)) } );
	   ChkAdpPing (cnt>0);
	end
	begin
	   for (jj=0; jj<cnt; jj=jj+1)
	      I2cFcpOut (3, wdat>>(jj*8), 1);
	   I2cFcpOut (cnt>0?1:0, 'hff, 1); // PING 1st part without START/SYNC/END
	   I2cFcpOut (2, 'hff, 1); // PING 2nd part with a '0'
	   I2cFcpPol ('h01); // polling TxComplete
	   `I2CMST.sfrw (`FCPSTA, 'h03); // clear TX status
	end
	join
end
endtask // FcpAptTx

task FcpAptRx;
input [MAX_D_BIT-1:0] cnt;
input [MAX_D_DEP*8-1:0] exp;
input [MAX_D_DEP-1:0] err; // parity error in purpose
reg [MAX_D_BIT-1:0] ii,jj;
reg [7:0] dbuf;
begin
	$write ($time,"ns <%m> cnt:%0d",cnt);
	if (cnt>0) $write (", exp:");
	for (ii=0;ii<cnt;ii=ii+1) begin
	   if ((cnt-ii)%4==0 && ii) $write ("_");
	   $write ("%02x",exp[(cnt-ii-1)*8+:8]);
	end
	$write ("\n");
	fork
	begin
	   for (ii=0; ii<cnt; ii=ii+1)
	      FcpDevTx (3, { exp>>(ii*8), err[ii]^FcpParity(exp>>(ii*8)) });
	   FcpDevPing (cnt>0);
	end
	begin
	   for (jj=0; jj<=cnt; jj=jj+1)
	      if (cnt>0) begin
	         I2cFcpPol ('h08); // polling short rcvd (SYNC)
	         `I2CMST.sfrr (`FCPSTA,'hxx);
	         if (jj==0) begin
	            if ((`I2CMST.rddat & 'h7c) !== 'h08) // only short rcvd asserted
	               `HW_FIN (($time,"ns <%m> ERROR: RX status (=0) error"))
	         end else begin
	            if ((`I2CMST.rddat & 'h7c) !== ('h18 ^ ({7'h0,err[jj-1]}<<5)))
	               `HW_FIN (($time,"ns <%m> ERROR: RX status (>0) error")) // short/data/pariry may asserted
	            dbuf = exp>>((jj-1)*8);
	            `I2CMST.sfrr (`FCPDAT, dbuf);
	            `I2CMST.sfrw (`FCPSTA, 'h30); // clear data/parity status
	         end
	      end
	   I2cFcpPol ('h04); // polling long-pulse rcvd
	   `I2CMST.sfrw (`FCPSTA,'h7c); // clear RX status
	end
	join
end
endtask // FcpAptRx


task Fcpmode1Rx; // for generation canyonmode1 waveform
input [MAX_D_BIT-1:0] cnt;
input [MAX_D_DEP*8-1:0] exp;
input [MAX_D_DEP-1:0] err; // parity error in purpose
reg [MAX_D_BIT-1:0] ii;
        begin
           for (ii=0; ii<cnt; ii=ii+1)
              FcpDevTx (3, { exp>>(ii*8), err[ii]^FcpParity(exp>>(ii*8)) });
           FcpDevPing (cnt>0);
        end
endtask // Fcpmode1Rx

//-----------------------------------------------------
//++ crc generation ++
parameter CRC_KEY = 8'h39;

function [7:0] CrcAcc;
input	[7:0] crc; // initial value
input	[MAX_D_BIT-1:0] cnt; // should include the shift-out if want
input	[MAX_D_DEP*8-1:0] dat; // one-additional-0-byte for shift out the last byte
integer i, j;
begin
	CrcAcc = crc;
	for (i=0;i<cnt;i=i+1)
	   for (j=0;j<8;j=j+1)
	      CrcAcc = {CrcAcc[6:0],dat[i*8+7-j]} ^ (CrcAcc[7] ? CRC_KEY : 0);
end
endfunction // CrcAcc

task CrcGen;
input   [MAX_D_BIT-1:0] cnt;
input   [MAX_D_DEP*8-1:0] exp;
output  [7:0] crc_gen;
integer i, j;
reg     crc_msb;
reg     [7:0]   dat, crc_buf;

begin
  crc_gen = 8'h00;
  for (i=0; i<=cnt; i=i+1) begin
    dat = exp >> (i*8);
    for (j=0; j<8; j=j+1) begin
      {crc_msb, crc_buf} = {crc_gen[7:0], dat[7-j]};
      if (crc_msb)
        crc_gen = crc_buf ^ CRC_KEY;
      else
        crc_gen = crc_buf;
    end // for (j=...)
  end // for (i=...)
end

endtask
//-----------------------------------------------------

`ifdef CAN1121A0 wire wr_crc = `DUT_CORE.u0_fcp.r_wr[5]; `endif
`ifdef CAN1127A0 wire wr_crc = `DUT_CORE.u0_fcp.r_wr[5]; `endif
`ifdef CAN1127A0 wire crc_en = `DUT_CORE.u0_fcp.r_crc_en; `endif

initial
#(1000*1000) forever @(posedge `DUT_ANA.OSC_O)
	if (crc_en==0 && wr_crc==1) begin
	   $display ($time,"ns <%m> ERROR: encode CRC without enabled in channel A");
	   #100 $finish;
	end

event evSampleDN; // to see how sync is the sample points (for CAN1112A FW-version SCP PHY)
initial
#(1000*1000) forever @(posedge `DUT_ANA.OSC_O)
	if (`DUT_CORE.sfr_r & ({1'h1,`DUT_CORE.sfr_adr}==`COMPI))
	   ->evSampleDN;

parameter ACK0 =8'h08;
parameter NAK0 =8'h03;
parameter SBRWR=8'h0B;
parameter SBRRD=8'h0C;
parameter MBRWR=8'h1B;
parameter MBRRD=8'h1C;

task ScpSingleBlockWr;
input [7:0] wadr, wdat;
reg [7:0] crc;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, dat:%02x",wadr,wdat);
	crc = CrcAcc (0,3+1,{8'h0,wdat,wadr,SBRWR});
	FcpDevTx (3,{SBRWR,~(^SBRWR)}); // write
	FcpDevTx (3,{wadr, ~(^wadr)}); // address
	FcpDevTx (3,{wdat, ~(^wdat)}); // data
	FcpDevTx (3,{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	crc = CrcAcc (0,1+1,{8'h0,ACK0});
	FcpDevRx ({ACK0,~(^ACK0)});
	FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
end
endtask // ScpSingleBlockWr

task ScpSingleBlockRd;
input [7:0] radr, rdat;
reg [7:0] crc;
begin
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, exp:%02x",radr,rdat);
	crc = CrcAcc (0,2+1,{8'h0,radr,SBRRD});
	FcpDevTx (3,{SBRRD,~(^SBRRD)});
	FcpDevTx (3,{radr, ~(^radr)});
	FcpDevTx (3,{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	crc = CrcAcc (0,2+1,{8'h0,rdat,ACK0});
	FcpDevRx ({ACK0,~(^ACK0)});
	FcpDevRx ({rdat,~(^rdat)}); // expected data
	FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
end
endtask // ScpSingleBlockRd

task ScpMultipleBlockWr;
input [7:0] wadr, wlen;
input [8*16-1:0] wdat;
reg [7:0] byt,crc,ii;
begin
	if (wlen>16) begin
	   $display ($time,"ns <%m> ERROR: length %d not supported", wlen);
	   $finish;
	end
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, cnt:%0d",wadr,wlen);
	CrcGen (3+wlen,{wdat,wlen,wadr,MBRWR},crc);
	FcpDevTx (3,{MBRWR,~(^MBRWR)}); // write
	FcpDevTx (3,{wadr, ~(^wadr)}); // address
	FcpDevTx (3,{wlen, ~(^wlen)}); // length of data
	for (ii=0;ii<wlen;ii=ii+1) begin
	   byt = wdat[8*ii+:8];
	   FcpDevTx (3,{byt,~(^byt)});
	end
	FcpDevTx (3,{crc,~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	CrcGen (1,{ACK0},crc);
	FcpDevRx ({ACK0,~(^ACK0)});
	FcpDevRx ({crc, ~(^crc)}); ChkAdpPing (1);
end
endtask // ScpMultipleBlockWr

task ScpMultipleBlockRd;
input [7:0] radr, rlen;
input [8*16-1:0] rdat;
reg [7:0] byt,crc,ii;
begin
	if (rlen>16) begin
	   $display ($time,"ns <%m> ERROR: length %d not supported", rlen);
	   $finish;
	end
	FcpDevPing (0);
	ChkAdpPing (0); #({$random}%FCP_UI+FCP_UI/4)
	$display ($time,"ns <%m> adr:%02x, exp:%0x",radr,rdat);
	CrcGen (3,{rlen,radr,MBRRD},crc);
	FcpDevTx (3,{MBRRD,~(^MBRRD)}); // read
	FcpDevTx (3,{radr, ~(^radr)}); // address
	FcpDevTx (3,{rlen, ~(^rlen)}); // length of data
	FcpDevTx (3,{crc,  ~(^crc)}); FcpDevPing (1);
	ChkAdpPing (0);
	CrcGen (1+rlen,{rdat,ACK0},crc);
	FcpDevRx ({ACK0,~(^ACK0)});
	for (ii=0;ii<rlen;ii=ii+1) begin
	   byt = rdat[8*ii+:8];
	   FcpDevRx ({byt,~(^byt)});
	end
	FcpDevRx ({crc,~(^crc)}); ChkAdpPing (1);
end
endtask // ScpMultipleBlockRd


