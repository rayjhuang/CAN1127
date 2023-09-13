
module usbpd_analyzer (input cc);
usbpd_phy ANAPHY (.rxd(cc));
packet rxpkt = new;
wire [15:0] pkt_bicnt  = rxpkt.get_bicnt();
wire [15:0] pkt_ordrs  = rxpkt.get_ordrs_bit();
wire [15:0] pkt_eop    = rxpkt.get_eop_bit();
wire [5:0]  pkt_ncnt   = rxpkt.get_rx_ncnt();
//re [4:0]  pkt_nibble = rxpkt.bitstr[rxpkt.bicnt-1-:5];

wire [31:0] pkt_do1    = rxpkt.get_do(0);
wire [31:0] pkt_do2    = rxpkt.get_do(1);
wire [15:0] pkt_header = rxpkt.get_header();
wire [3:0]  pkt_ndo    = pkt_header[12+:3];
wire [2:0]  pkt_msgid  = pkt_header[9+:3];
wire        pkt_p_role = pkt_header[8]; // cable plug if SOP'/SOP"
wire [1:0]  pkt_spec   = pkt_header[7:6];
wire        pkt_d_role = pkt_header[5];
wire [4:0]  pkt_msgtyp = pkt_header[0+:5];

wire [8*30-1:0] message_type = rxpkt.str_msgtyp(rxpkt.get_header()>>15,rxpkt.get_ndo()>0,rxpkt.get_msgtyp());
wire [8*12-1:0] ordered_set = rxpkt.str_ordrs(rxpkt.get_ordrs());
wire [8*10-1:0] pwr_role = rxpkt.str_pwr_role(pkt_p_role,rxpkt.get_ordrs());
wire [8*10-1:0] dat_role = rxpkt.str_dat_role(pkt_d_role,rxpkt.get_ordrs());

event ev_pktrcvd;
initial
forever begin: loop
	ANAPHY.rx_packet (rxpkt);
	#0 ->ev_pktrcvd;
	if (pkt_ordrs>0) // print
	   if (pkt_ncnt>0) pkt;
	              else ordrs;
	else begin
	   if (pkt_bicnt>rxpkt.MAX_LENGTH*10) $display ($time,"ns <%m> WARNING: packet lenth overflow");
	end
	   
//	else $display ($time,"ns <%m> NOTE: idle-ended packet");
end // loop

/* reg [2:0] show_level = 1;
   function void pkt;
	if (show_level>2) begin
	$write ($time,"ns <%m>");
	$write (" bit:%0d",   rxpkt.bicnt);
	$write (" ordrs:%0d", rxpkt.ordrs_bit);
	$write (" eop:%0d",   rxpkt.eop_bit);
	$write (" nibble:%0d",rxpkt.rx_ncnt);
	$write ("\n");
	end
	if (show_level>1) begin
	$write ($time,"ns <%m>");
	$write (" %0s",       rxpkt.str_ordrs(rxpkt.get_ordrs()));
	$write (":hdr:%04x",  rxpkt.get_header());
	$write (" crc32:%08x",rxpkt.rx_data[rxpkt.rx_ncnt*4-1-:32]);
	$write (":%0s",       rxpkt.is_crc32_ok(rxpkt.get_crc32()) ? "ok" : "bad");
	$write ("\n");
	end
	if (show_level>0) begin
*/ function void pkt;
        reg [3:0] ii;
	$write ($time,"ns <%m>");
	$write (" %0s", rxpkt.str_ordrs_short(rxpkt.get_ordrs()));
	if (rxpkt.is_crc32_ok(rxpkt.get_crc32()))
	   if (rxpkt.is_header('b0000xxxx_xxx00001)) // GoodCRC
	      $write ("%04x", rxpkt.get_header()); // in short for GoodCRC
	   else begin
	      $write ("%0s (hdr:%04x)", message_type, rxpkt.get_header());
	      for (ii=0;ii<rxpkt.get_ndo();ii++)
	      $write (" DO%0d:%08x", ii, rxpkt.get_do(ii));
	   end
	else
	   $write ("(bad-crc)");
	$write ("\n");
//	end
   endfunction // pkt

   function void ordrs;
	$write ($time,"ns <%m>");
	$write (" %0s\n", rxpkt.str_ordrs(rxpkt.get_ordrs()));
   endfunction // ordrs

   task calc_period_retry;
   time period;
	@(ev_pktrcvd)
	period = $time;
	repeat (2) @(posedge cc);
	period = ($time-period)/1000;
	if (period < 1500 && period > 500) begin
	   $display ($time,"ns <%m> retry detected within %0d us", period);
	   if (period > 1090 || period < 910) begin
	      $display ($time,"ns <%m> ERROR: tReceive viilated", period);
	      $finish;
	   end
	end
   endtask // calc_period_retry;

endmodule // usbpd_analyzer

