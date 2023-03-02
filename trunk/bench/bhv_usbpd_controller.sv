
module bhv_usbpd_controller (
input rxd
);
////////////////////////////////////////////////////////////////////////////////
reg	[2:0]	ExpOrdrs = 1; // target (SOP*) for TX/RX
reg		PwrRole = 0, // 0/1: sink/source, if SOP' 0: DFP/UFP, 1: Cable Plug
		DatRole = 0; // 0/1: UFP/DFP, should be 0 in SOP'
reg	[2:0]	MyMsgId0 = 0; //for SOP
reg	[2:0]	MyMsgId1 = 0; //for SOP'
reg		Nego1st = 1; // first time nego. since attached/HR
reg	[1:0]	SpecMax = 2; // MAX_REV = PD3.0, max.rev FW supports
reg	[1:0]	SpecRev = SpecMax; // UPD controller used to sending messages (include GoodCRC)
		                   //                 and checing RX messages (exclude GoodCRC)
reg	[1:0]	DutsGdCrcSpec = 1; // DUT's auto-TX-GdCrc depends 
wire	[3:0]	nRetry = (SpecRev==2) ? 3
		       : (SpecRev==1) ? 4 : 'hx; // PD3.0/PD2.0, nRetryCount + 1

usbpd_phy UPDPHY (.rxd(rxd),.txd(),.txoe());
packet prlpkt = new;
wire [15:0] pkt_header = prlpkt.rx_data[0+:16];

task rcvmsg (input [15:0] timeout);
	fork
        begin
           if (prlpkt.reset());
           while (prlpkt.ordrs_bit==0) UPDPHY.rx_packet (prlpkt);
           disable TIMEOUT_RCV;
        end
        begin: TIMEOUT_RCV
           #(1000*1000*timeout)
           $display ($time,"ns <%m> ERROR: timeout");
           $finish;
        end // TIMEOUT_RCV
	join
endtask // rcvmsg

task WaitRcvHr; // wait and pass those incomming packets
input integer timeout; // ms
	$display ($time,"ns <%m> starts.....%0d",timeout);
	if (prlpkt.reset());
	fork
	begin
	   while (prlpkt.get_ordrs()!==6) rcvmsg (timeout); // wiat for Hard Reset
	   $display ($time,"ns <%m> Hard Reset received");
	   disable TIMEOUT_RCV_PICK;
	end
	begin: TIMEOUT_RCV_PICK
	   #(1000*1000*timeout)
	   $display ($time,"ns <%m> ERROR: timeout");
	   $finish;
	end // TIMEOUT_RCV_PICK
	join
endtask // WaitRcvHr

task RcvChkOrdrs; // check the next incomming packet
input [2:0] ordrs;
input integer timeout; // ms
//	$display ($time,"ns <%m> starts.....%0d",timeout);
	rcvmsg (timeout); // wiat and get a message
	if (prlpkt.get_ordrs()!==ordrs) begin
	   $display ($time,"ns <%m> ERROR: ordrs %0d expected, rcvd:%0d", ordrs, prlpkt.get_ordrs());
	   $finish;
	end
endtask // RcvChkOrdrs

task ChkRxHdr;
input [5:0] mtyp;
input [2:0] ndo, MsgId;
input [1:0] SpecRev;
input ChkRole;
reg [5:0] mis;
reg [8*2-1:0] RxHdr;
	RxHdr = prlpkt.get_header();
	// ChkRole is only for TD differs from DUT
	$display ($time,"ns <%m> rx:%04x, exp:%04x",RxHdr,{mtyp[5],ndo,MsgId,~PwrRole,SpecRev,~DatRole,mtyp[4:0]});
	if ({RxHdr[15],RxHdr[4:0]}==13 && prlpkt.get_msgid()!==0) begin
	   $display ($time,"ns <%m> ERROR: Soft Reset with non-zero Message ID, 0x%04x", RxHdr);
	   $finish;
	end
	mis[0] =    mtyp!==6'hx &&    mtyp!={RxHdr[15],RxHdr[4:0]};
	mis[1] =     ndo!==3'hx &&     ndo!=RxHdr[14:12];
	mis[2] =   MsgId!==3'hx &&   MsgId!=RxHdr[11:9];
	mis[3] = SpecRev!==2'hx && SpecRev!=RxHdr[7:6];
	mis[4] = PwrRole!==1'hx && PwrRole==RxHdr[8] && ChkRole==1; // only for TD differs from DUT
	mis[5] = DatRole!==1'hx && DatRole==RxHdr[5] && ChkRole==1 && prlpkt.get_ordrs()==1 ||
	         DatRole!==1'hx &&    1'h0!=RxHdr[5] && ChkRole==1 && prlpkt.get_ordrs() >1;
	if (|mis) begin
	   if (mis[0]) $display ($time,"ns <%m> ERROR MsgType,   exp:0x%x",mtyp);
	   if (mis[1]) $display ($time,"ns <%m> ERROR NDO,       exp:%d",  ndo);
	   if (mis[2]) $display ($time,"ns <%m> ERROR MessageID, exp:%d",  MsgId);
	   if (mis[3]) $display ($time,"ns <%m> ERROR SpecRev,   exp:%d",  SpecRev);
	   if (mis[4]) $display ($time,"ns <%m> ERROR PowerRole, exp:%d", ~PwrRole);
	   if (mis[5]) $display ($time,"ns <%m> ERROR DataRole,  exp:%d", ~DatRole);
	   $display ($time,"ns <%m> ERROR: mismatch: %bb",mis);
	   #0 $finish;
	end
endtask // ChkRxHdr

task ChkRxDO;
input [2:0] ndo;
input [32*7-1:0] exp_do; // expected DOx
reg [7:0] ii,jj,mis;
reg [8*4-1:0] tmpdo;
	mis =0;
	for (ii=0; ii<prlpkt.get_ndo; ii++) begin
	   tmpdo = prlpkt.get_do(ii);
	   for (jj=0;jj<32;jj=jj+1)
	      if (exp_do[ii*32+jj]!==1'hx && exp_do[ii*32+jj]!==tmpdo[jj])
	         mis[ii] =1;
	end
	if (|mis) begin
	   for (ii=0;ii<ndo;ii=ii+1) begin
	      tmpdo = exp_do>>(32*ii);
	      if (mis[ii]) $display ($time,"ns <%m> ERROR DO%0d, exp:%xh",ii+1,tmpdo);
	   end
	   $display ($time,"ns <%m> ERROR: mismatch: %bb",mis);
	   #0 $finish;
	end
endtask // ChkRxDO

parameter INTERFRAM = 1000*20; // 20us
parameter INTERFRAM6 = INTERFRAM*6; // 120us
parameter WAITMSG_DEFAULT = 1000*15; // 15ms
integer tWaitMessage = WAITMSG_DEFAULT;
integer tReceive = 1000; // us

task ReturnGoodCRC (
input inv = 0 // w/ msgid inversed
);
reg [15:0] hdr; // Local static variable with initializer requires 'static' keyword
	hdr = {1'h0,3'h0,
	    (inv) ? ~prlpkt.get_msgid() : prlpkt.get_msgid(), // CpMsgId
	             PwrRole, // ~prlpkt.rx_data[8]
	             SpecRev,
	             DatRole, // ~prlpkt.rx_data[5] if SOP
	             5'h1}; // GoodCRC
	if (prlpkt.rx_data[8]==PwrRole ||
	    prlpkt.rx_data[6+:2]!=((Nego1st)?SpecMax:SpecRev) ||
	    ExpOrdrs==1 && prlpkt.rx_data[5]==DatRole ||
	    ExpOrdrs >1 && (prlpkt.rx_data[5]>0 || DatRole>0)) begin
	   $display ($time,"ns <%m> ERROR: to return a GoodCRC w/ suspicious header, rcv:%04x, rtn:%04x",
	                                  prlpkt.get_header(), hdr);
	   $finish;
	end
	UPDPHY.tx_packet (ExpOrdrs,,,2,hdr);
endtask // RetuenGoodCRC

task RcvCmd (
input [5:0] mtyp,
input [2:0] ndo = 0,
input [32*7-1:0] exp_do = 0, // expected DOx
input [1:0] chk_type = 0
);
	RcvMsg_wo_GoodCRC (mtyp,ndo,exp_do,chk_type);
	#({$random}%INTERFRAM6+INTERFRAM)
	ReturnGoodCRC;
endtask // RcvCmd

task RcvMsg_wo_GoodCRC ( // to receive a Message without returning a GoodCRC
input [5:0] mtyp,
input [2:0] ndo = 0,
input [32*7-1:0] exp_do = 0,
input [1:0] chk_type = 0 // 0: check it out
                         // 1: do not check RX packet
                         // 2: don't check CRC32
);
	RcvChkOrdrs (ExpOrdrs,tWaitMessage/1000);
	if (!prlpkt.is_crc32_ok(prlpkt.get_crc32()) &&
	    chk_type!=2) begin
	   $display ($time,"ns <%m> ERROR: CRC32 failed");
	   #(1000) $finish;
	end
	if (chk_type!=1) begin
	   ChkRxHdr (mtyp,ndo,'hx,'hx,0);
	   ChkRxDO (ndo,exp_do);
	end
endtask // RcvMsg_wo_GoodCRC

task SndHr;
	$display ($time,"ns <%m> starts.....");
	UPDPHY.tx_packet (6,0,0);
endtask // SndHr

task SndCmd (
input [5:0] mtyp, // [5]:extended
input [2:0] ndo = 0,
input [32*7-1:0] DOx = 0, // sending DOx
input [1:0] Wait4GdCRC = 0, // exit when 0: GoodCRC rcvd, 1: TX done, 2: TX begins
input report = 1 // normal report
);
reg [7:0] ii,cnt;
reg [8*2-1:0] hdr;
	if(ExpOrdrs==2) // SOP'
           hdr = {mtyp[5],ndo,MyMsgId1,PwrRole,SpecRev,DatRole,mtyp[4:0]};
	else
           hdr = {mtyp[5],ndo,MyMsgId0,PwrRole,SpecRev,DatRole,mtyp[4:0]};

	if (report) begin
	   $write ($time,"ns <%m> hdr:%04x",hdr);
	   for (ii=1;ii<=ndo;ii=ii+1)
	      $write (" DO%1x:%08x",ii,(DOx>>32*(ii-1))&'hffff_ffff);
	   $display ();
	end
	if (Wait4GdCRC!=2) UPDPHY.tx_packet (ExpOrdrs,,,ndo*4+2,{DOx,hdr});
	if (Wait4GdCRC==0) begin
	   RcvChkOrdrs (ExpOrdrs,3);
	   hdr = hdr & 16'h0f20 | (16'h0|DutsGdCrcSpec) << 6 | 16'h1; // GoodCRC w/ 'auto-TX-GdCRC' always returns PD2
	   if (ExpOrdrs==1) // SOP, 'auto-TX-GdCRC' always returns opposite roles
	      hdr ^= 16'h0120;
	   else // non-SOP
`ifdef FW_FIX0 // FW support to fix the returned GoodCRC's port (power) role
	      hdr[8] = 0; // still expects DUT is a PORT (20220303, FW support)
`else	      hdr ^= 16'h0100; // AUTOTXGDCRC returns a inverted port/power role, with data role '0'
`endif
	   if (!prlpkt.is_header(hdr)) begin // check GoodCRC
	      $display ($time,"ns <%m> ERROR: GoodCRC mismatch, exp:%04x, dat:%04x",
	                         hdr, prlpkt.get_header());
	      #(1000) $finish;
	   end
	   if (ExpOrdrs==2) MyMsgId1 = MyMsgId1 +1;
	               else MyMsgId0 = MyMsgId0 +1;
	end
endtask // SndCmd

////////////////////////////////////////////////////////////////////////////////
task CspW (
input [7:0] adr,
input [8*1024*4-1:0] dat,
input [15:0] cnt = 0, // N+1
input mode = 0 // 0/1 mem/IO
);
reg [16:0] ii;
	$write ($time,"ns <%m> adr:%x dat:", adr);
	for (ii=0; ii<5 && ii<=cnt; ii++) $write ("%02x", dat[8*ii+:8]); // LSB first
	               if (ii<=cnt)       $write ("...%0d", cnt);
                                          $write ("\n");
	SndCmd (15,1,{16'h412a,16'h412a},0,0); // SetMode0
	#({$random}%INTERFRAM6+INTERFRAM)
	UPDPHY.tx_packet (
	      .ordrs(ExpOrdrs),
	      .crc32(0),
	      .bycnt(2+cnt+1),
	      .txbuf({dat,6'h0,mode,1'h1,adr})); // EOP will be referred, cmd=1
endtask // CspW

task CspR (
input [7:0] adr,
input [8*256-1:0] exp,
input [7:0] cnt = 0, // N+1, command-format-liminted
input mode = 0 // 0/1 mem/IO
);
reg [8:0] ii,jj;
	$write ($time,"ns <%m> adr:%x exp:", adr);
	for (ii=0; ii<5 && ii<=cnt; ii++) $write ("%02x", exp[8*ii+:8]); // LSB first
	               if (ii<=cnt)       $write ("...%0d", cnt);
                                          $write ("\n");
	SndCmd (15,1,{16'h412a,16'h412a},0,0); // SetMode0
	#({$random}%INTERFRAM6+INTERFRAM)
	UPDPHY.tx_packet (
	      .ordrs(ExpOrdrs),
	      .crc32(0),
	      .bycnt(3),
	      .txbuf({cnt,6'h0,mode,1'h0,adr})); // EOP will be referred, cmd=0
	#INTERFRAM
	RcvChkOrdrs (ExpOrdrs,3+cnt/30);
	for (ii=0; ii<=cnt; ii++)
	   for (jj=0; jj<8; jj++)
	      if (exp[8*ii+jj]!==prlpkt.rx_data[8*ii+jj] &&
	          exp[8*ii+jj]!==1'hx) begin
	         $display ($time,"ns <%m> ERROR: read data mismatch, adr:%02x[%0d], exp:%02x, dat:%02x",
	                                          adr, ii, exp[8*ii+:8], prlpkt.rx_data[8*ii+:8]);
	         $finish;
	      end
endtask // CspR

endmodule // bhv_usbpd_controller

