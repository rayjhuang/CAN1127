
`include "can1127_reg.v"

task r_poll; // SFR polling
input [7:0] addr;
input [7:0] msk;
input [1:0] exp; // 0/1/2/3:all-0/all-1/one-0/one-1
input [15:0] period; // us
begin
	rddat = {8{~exp[0]}};
	while (exp==0 && |(rddat&msk)!=0 ||	// not all-0
	       exp==1 && &(rddat&msk|~msk)!=1 ||// not all-1
	       exp==2 && &(rddat&msk|~msk)!=0 ||// not at-least-one-0
	       exp==3 && |(rddat&msk)!=1)	// not at-least-one-1
		#(period*1000) sfrr (addr,'hxx);
end
endtask // r_poll

task s_poll; // signal polling
input [2:0] sel;
	while (~wait_sig[sel]) #({$random}%1_000+1_000);
endtask // s_poll

reg [15:0] Timer0Val;
always @(negedge Timer0Exp) #('d1000*Timer0Val) Timer0Exp = 1;
task Timer0Set;
input [15:0] val; // us
begin
	Timer0Val = val;
	#({$random}%200+200);
	Timer0Exp = 0;
	#({$random}%100+100);
end
endtask // TimerSet


// -----------------------------------------------------------------------------
reg [2:0]
	CpMsgId0 =-1,  // stored Message ID
	MsgIdCnt0 =0, // Message ID of SOP
	MsgIdCnt1 =0, // Message ID of SOP'
	MsgIdCnt2 =0; // Message ID of SOP"

reg [15:0] TxHdr, RxHdr;
reg [31:0] DatObj [0:6], DoTmp;

wire [2:0] RxNdo = RxHdr[14:12];
wire [2:0] RxMid = RxHdr[11:9];
wire [3:0] RxType = RxHdr[3:0];
wire [4:0] RxMsgTyp = {|RxNdo,RxType};
wire [2:0] TxNdo = TxHdr[14:12];
wire [2:0] TxMid = TxHdr[11:9];
wire [3:0] TxType = TxHdr[3:0];
wire [4:0] TxMsgTyp = {|TxNdo,TxType};
wire [31:0]
	dbg_DatObj_0 = DatObj[0],
	dbg_DatObj_1 = DatObj[1],
	dbg_DatObj_2 = DatObj[2],
	dbg_DatObj_3 = DatObj[3],
	dbg_DatObj_4 = DatObj[4],
	dbg_DatObj_5 = DatObj[5],
	dbg_DatObj_6 = DatObj[6];

task PacketTx;
input [2:0] numdo;
reg [4:0] numk, idxi;
begin
	s_poll (`TMR0); // Timer0Exp
	sfrw (`STA1,'h06); // clear TX status
	sfrw (`FFSTA,'h00); // clear FIFO
	sfrr (`TXCTL,'hxx); // check setting
	if (numk>0 && ~rddat[6]) // there's not-auto-enc-k
	   $display ($time,"ns <%m> WARNING: there's not-auto-enc-K code, non-enceded data transmitted");
	sfrr (`FFCTL,'hxx);
	sfrw (`FFCTL,rddat|'h40); // set first
	sfrw (`FFIO,TxHdr[7:0]);
	if (numdo==0) begin sfrr (`FFCTL,'hxx); sfrw (`FFCTL,rddat|'h80); end // set last
	sfrw (`FFIO,TxHdr[15:8]);
	for (idxi=0;idxi<numdo;idxi=idxi+1) begin
	   DoTmp = DatObj[idxi];
	   repeat (3) begin sfrw (`FFIO,DoTmp); DoTmp = DoTmp>>8; end
	   if (idxi==numdo-1) begin sfrr (`FFCTL,'hxx); sfrw (`FFCTL,rddat|'h80); end // set last
	                    sfrw (`FFIO,DoTmp); DoTmp = DoTmp>>8;
	end
	sfrr (`STA1,'hxx);
	if (rddat[5]) // NAK
	   $display ($time,"ns <%m> WARNING: TX packet discarded");
	else begin // not NAK-ed
	   s_poll (`IRQ1); // i_int[1], after sending Policy Engine Message
	   Timer0Set (25+25); // tInterFrameGap (>=25us)
	   sfrr (`STA1,'b00010xx1); // FifoAck, TxAck (TX goes idle)
	   sfrw (`STA1,'h11); // clear status
	end
end
endtask // PacketTx

task PacketRx;
input [3:0] mtyp, ndo;
begin
	s_poll (`IRQ0); // i_int[0]
	Timer0Set (25+25); // tInterFrameGap (>=25us)
	sfrw (`FFCTL,'h40); // set first
	repeat (2) begin sfrr (`FFIO,'hxx); RxHdr = {rddat,RxHdr}>>8; end
	#10 if (mtyp!=='hx && RxType!==mtyp
              || ndo!=='hx && RxNdo!==ndo) begin
	   $display ($time,"<%m> ERROR: ExpMsg:%0d(NDO %0d), Rcvd:%0d(NDO %0d)",mtyp,ndo,RxType,RxNdo);
	   $finish;
	end
	#({$random}%100+100)
	if (RxNdo>0) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[0] = {rddat,DatObj[0]}>>8; end
	if (RxNdo>1) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[1] = {rddat,DatObj[1]}>>8; end
	if (RxNdo>2) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[2] = {rddat,DatObj[2]}>>8; end
	if (RxNdo>3) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[3] = {rddat,DatObj[3]}>>8; end
	if (RxNdo>4) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[4] = {rddat,DatObj[4]}>>8; end
	if (RxNdo>5) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[5] = {rddat,DatObj[5]}>>8; end
	if (RxNdo>6) repeat (4) begin sfrr (`FFIO,'hxx); DatObj[6] = {rddat,DatObj[6]}>>8; end
	repeat (4) sfrr (`FFIO,'hxx); // pop CRC32
//	sfrw (`FFSTA,'h00); // clear FIFO
	sfrr (`STA0,'b0000_101x);
	sfrw (`STA0,'h0a); // clear status
	sfrw (`STA1,'h14); // clear FifoAck, GoBusy
end
endtask // PacketRx

reg TxPortRole =1, // or CablePlug
    TxDataRole =1;
reg [1:0]
    SpecRev =1; // rev.2.0

task SendCmd;
input [3:0] mtyp, ndo;
input [31:0] do1;
reg [2:0] sopsel, tmpid;
begin
	sfrr (`TXCTL,'hxx); // check TX setting
	sopsel = rddat[2:0];
	tmpid = (sopsel=='h3 || sopsel=='h5) ?MsgIdCnt2 // SOP", SOP"_Debug
	      : (sopsel=='h2 || sopsel=='h4) ?MsgIdCnt1 // SOP', SOP'_Debug
	      : (sopsel=='h1) ?MsgIdCnt0 // SOP
	      : 'hx; // not support yet
	TxHdr = {ndo,tmpid,TxPortRole,SpecRev,TxDataRole,1'h0,mtyp};
	DatObj[0] = do1;
->ev;	PacketTx (ndo);
->ev;	while (rddat[5]) begin // TX NAK-ed
	   $display ($time,"ns <%m> WARNING: TX NAK-ed, retry when bus idle, (Hdr: %4x)",TxHdr);
	   r_poll (`STA1,'h02,1,100); // bus goes idle
	   sfrw (`FFSTA,'h0);
	   sfrw (`STA0,'h3f);
	   sfrw (`STA1,'h2a);
           Timer0Set (25+25); // tInterFrameGap (>=25us)
	   PacketTx (ndo);
	end
->ev;	PacketRx (1,0); // wait for the GoodCRC
->ev;	if (RxMid==tmpid) begin
	   if (sopsel=='h3 || sopsel=='h7) MsgIdCnt0 = tmpid +1;
	   if (sopsel=='h2 || sopsel=='h6) MsgIdCnt1 = tmpid +1;
	   if (sopsel=='h1 || sopsel=='h5) MsgIdCnt2 = tmpid +1;
	end else
	   $display ($time,"ns <%m> WARNING: received a GoodCRC with a wrong MessageID");
->ev;	if ({ndo,mtyp}=={4'h0,4'hD}) begin // Soft Reset
	   CpMsgId0 =-1;
	   MsgIdCnt0 =0;
	end
end
endtask // SendCmd

task RcvCmd;
input [3:0] mtyp, ndo;
input [31:0] exp1; // expected DO1
reg [7:0] idx;
begin
	PacketRx (mtyp,ndo);
	if (RxMid==CpMsgId0)
	   $display ($time,"ns <%m> WARNING: received a message with a same MessageID");
	else
	   CpMsgId0 = RxMid;
	for (idx=0;idx<32;idx=idx+1)
	   if (exp1[idx]!==1'hx && exp1[idx]!==dbg_DatObj_0[idx]) begin
	      $display ($time,"ns <%m> ERROR: exp: %x, dat: %x (%0d)", exp1, dbg_DatObj_0, idx);
	      $finish;
	   end
	TxHdr = {4'h0,CpMsgId0,TxPortRole,SpecRev,TxDataRole,1'h0,4'd1}; // GoodCRC
	PacketTx (0);
end
endtask // RcvCmd

reg [7:0] lt_TXCTL, lt_MISC;
task SetCanMode0;
input isp0;
begin
	if (~isp0) SendCmd (15,1,{16'h412a,16'h412a});// VDM of setting canyon mode 0
	sfrr (`TXCTL,'hxx); lt_TXCTL = rddat;
//	sfrw (`TXCTL,rddat&~'h30); // no CRC/EOP in the mode 0, remember to recover when exit the mode
	sfrw (`TXCTL,rddat&~'h10); // no CRC     in the mode 0, CAN1112 version of Mode 0
	sfrr (`MISC,'hxx); lt_MISC = rddat;
	sfrw (`MISC,rddat|'h04); // shorten preamble
end
endtask // SetCanMode0

task ExitCanMode0;
begin
	Timer0Set (25+25); // tInterFrameGap (>=25us)
	sfrw (`TXCTL,lt_TXCTL); // recover auto-CRC
	sfrw (`MISC,lt_MISC); // disable shorten
end
endtask // ExitCanMode0

task cspr; // hang if no return (DUT didn't enter Canyon_mode_0)
input [7:0] adr, cnt; // N+1
input [1:0] mode; // [0]: 0/1 register/OTP, [1]: 0/1 normal/no-enter-exit
input [8*256-1:0] expr;
reg [8:0] idx;
reg [7:0] msk0,txctl; // save MSK0,TXCTL
begin
	SetCanMode0 (mode[1]);
	$display ($time,"ns <%m> Canyon0 read adr:%x, cnt:%0d", adr, cnt);
	s_poll (`TMR0); // Timer0Exp
	sfrr (`TXCTL,'hxx); txctl = rddat; // save TXCTL
	sfrw (`TXCTL,txctl&~'h20); // no EOP in read, remember to recover when exit the mode
->ev;	sfrw (`STA1,'h06); // clear GoIdle, GoBusy
	sfrw (`FFCTL,{3'h6,5'h0}); // set first/last
	sfrw (`FFSTA,'h00); // clear FIFO
	sfrw (`FFIO,adr); // address
	sfrw (`FFIO,{6'h0,mode[0],1'h0}); // command
	sfrw (`FFIO,cnt); // count, N+1

	sfrr (`MSK0,'hxx); msk0 = rddat; // save MSK0
	sfrw (`MSK0,'h02); // enable SOP* IRQ
	sfrw (`FFCTL,'h20); // enable unlocked access
	s_poll (`IRQ0); // wait for SOP*
->ev;	for (idx=0;idx<=cnt;idx=idx+1) begin
	   r_poll (`FFSTA,'h80,0,10); // wait for not empty
	   sfrr (`FFIO,expr>>idx*8);
	end
	sfrr (`STA1,'b00010xx1); // status of prior TX and the following RX, unlock
	sfrw (`STA1,'h15); // clear status

	sfrw (`FFCTL,'h00); // recover lock
	sfrw (`MSK0,'h18);
	s_poll (`IRQ0); // wait for EOP
	sfrw (`MSK0,msk0); // recover MSK0
	sfrw (`TXCTL,txctl);
->ev;	sfrr (`STA0,'h12); // prior TX and the following RX, not pyld, crc
	sfrw (`STA0,'h12); // clear status
	ExitCanMode0;
end
endtask // cspr

task cspw;
input [7:0] adr;
input [15:0] cnt; // N+1
input [1:0] mode; // [0]: 0/1 register/OTP, [1]: 0/1 normal/no-enter-exit
input [8*64*1024-1:0] wdat;
reg [15:0] idx;
reg [7:0] dbg_wdat;
begin
	SetCanMode0 (mode[1]);
	$display ($time,"ns <%m> Canyon0 write adr:%x, cnt:%0d", adr, cnt);
	s_poll (`TMR0); // Timer0Exp
->ev;	PhyReset;
	sfrw (`FFCTL,{3'h6,5'h0}); // set first/last
	sfrw (`FFIO,adr); // address
	sfrw (`FFIO,{6'h0,mode[0],1'h1}); // command
	sfrw (`FFCTL,'h20); // enable unlocked access
	for (idx=0;idx<=cnt;idx=idx+1)
//	   if (mode[0]) begin
//	      rddat ='hff;
//	      while (rddat[5:0]>'h18) #10_000 sfrr (`FFSTA,'hxx); // FF space available
//	      sfrw (`FFIO,wdat[8*idx+:8]);
//	      repeat (7) sfrw (`FFIO,'h00);
//	   end else
	   begin
	      r_poll (`FFSTA,'h40,0,10); // wait for not full
	      dbg_wdat = wdat[8*idx+:8];
	      sfrw (`FFIO,dbg_wdat);
	   end
	sfrw (`FFCTL,'h00); // recover lock
	s_poll (`IRQ1); // i_int[1], after sending Policy Engine Message
->ev;	sfrr (`STA1,'b00010xx1); // FifoAck, TxAck (TX goes idle)
	sfrw (`STA1,'h11); // clear status
	ExitCanMode0;
end
endtask // cspw

task ReqBasicContract;
input [2:0] opos; // request position
begin
	SendCmd (2,1,{1'h0,opos,1'h0,1'h0,1'h0,1'h0,4'h0,10'd50,10'd100}); // Request, PDO#1,0.5A,1.0A
	RcvCmd (3,0,'hx); // wait for Accept
	RcvCmd (6,0,'hx); // wait for PS_RDY
end
endtask // ReqBasicContract

task RcvBasicContract;
input [2:0] opos; // request position
begin
	RcvCmd (1,4,'hxxxx_xx32); // wait for Source Capabilities
	SendCmd (2,1,{1'h0,opos,1'h0,1'h0,1'h0,1'h0,4'h0,10'd50,10'd100}); // Request, PDO#1,0.5A,1.0A
	RcvCmd (3,0,'hx); // wait for Accept
	RcvCmd (6,0,'hx); // wait for PS_RDY
end
endtask // RcvBasicContract

task SndBasicContract;
begin
	SendCmd (1,1,{12'h0,10'd100,10'd50}); // Source Capabilities, 5V, 0.5A
	RcvCmd (2,1,'hx); // wait for Request
	SendCmd (3,0,0); // Accept
	SendCmd (6,0,0); // PS_RDY
end
endtask // SndBasicContract

task SndMoreContract;
begin
	DatObj[1] = {12'h0,10'd320,10'd500}; // 16V, 5A
	SendCmd (1,2,{12'h0,10'd100,10'd50}); // Source Capabilities, 5V, 0.5A
	RcvCmd (2,1,'hx); // wait for Request
	SendCmd (3,0,0); // Accept
	SendCmd (6,0,0); // PS_RDY
end
endtask // SndMoreContract

task PhyReset;
begin
//	$display ($time,"ns <%m>");
	sfrw (`FFSTA,'h00); // clear FIFO
	sfrw (`STA0,'h7f); // clear all status
	sfrw (`STA1,'hff); // clear all status
end
endtask // PhyReset

task PrlReset; // protocol reset
begin
//	$display ($time,"ns <%m>");
	MsgIdCnt0 =0;
	MsgIdCnt1 =0;
	MsgIdCnt2 =0;
	CpMsgId0 =-1;
	PhyReset;
end
endtask // PrlReset

