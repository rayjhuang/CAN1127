
class bmc_codec;
   function [4:0] encode (bit [4:0] k_nibble);
   case (k_nibble)
      'h00: encode = 'b11110;
      'h01: encode = 'b01001;
      'h02: encode = 'b10100;
      'h03: encode = 'b10101;
      'h04: encode = 'b01010;
      'h05: encode = 'b01011;
      'h06: encode = 'b01110;
      'h07: encode = 'b01111;
      'h08: encode = 'b10010;
      'h09: encode = 'b10011;
      'h0a: encode = 'b10110;
      'h0b: encode = 'b10111;
      'h0c: encode = 'b11010;
      'h0d: encode = 'b11011;
      'h0e: encode = 'b11100;
      'h0f: encode = 'b11101;
//    'h10: encode = 'b00000; // skip nibble
      'h11: encode = 'b11000; // Sync-1
      'h12: encode = 'b10001; // Sync-2
      'h13: encode = 'b00110; // Sync-3
      'h14: encode = 'b01010; // preamble, 8-bit-01
      'h15: encode = 'b00111; // RST-1
      'h16: encode = 'b11001; // RST-2
      'h17: encode = 'b01101; // EOP
      'h18: encode = 'b00000; // 8-bit-0
      'h19: encode = 'b11111; // 8-bit-1
      default:
            encode = $random;
   endcase
   endfunction // encode 
   function [4:0] decode (bit [4:0] five_bit);
   case (five_bit)
      'b11110: decode = 'h00;
      'b01001: decode = 'h01;
      'b10100: decode = 'h02;
      'b10101: decode = 'h03;
      'b01010: decode = 'h04;
      'b01011: decode = 'h05;
      'b01110: decode = 'h06;
      'b01111: decode = 'h07;
      'b10010: decode = 'h08;
      'b10011: decode = 'h09;
      'b10110: decode = 'h0a;
      'b10111: decode = 'h0b;
      'b11010: decode = 'h0c;
      'b11011: decode = 'h0d;
      'b11100: decode = 'h0e;
      'b11101: decode = 'h0f;
      'b11000: decode = 'h11; // Sync-1
      'b10001: decode = 'h12; // Sync-2
      'b00110: decode = 'h13; // Sync-3
      'b00111: decode = 'h15; // RST-1
      'b11001: decode = 'h16; // RST-2
      'b01101: decode = 'h17; // EOP
      default: decode = $random;
   endcase
   endfunction // decode

   function is_crc32_ok (bit [31:0] crc32);
      is_crc32_ok = crc32==32'hc704_dd7b; // residual, for receiver
   endfunction // is_crc32_ok
   function [31:0] inv_comp (bit [31:0] crc32); // inverse complement
      reg [8:0] ii;
      for (ii=0; ii<32; ii++)
         inv_comp[ii] = ~crc32[31-ii]; // inverse complement
   endfunction // inv_comp
   function [31:0] crc32 (bit [8*34-1:0] dat, bit [5:0] bycnt); // MAX_BYTE_CNT 34
      reg [8:0] ii;
      crc32 = 'hffff_ffff; // start
      for (ii=0; ii<bycnt*8; ii++)
         crc32 = (dat[ii]^crc32[31]) ?crc32<<1 ^ 32'h04c1_1db7 :crc32<<1; // bit shift-in
   endfunction // crc32

   function [19:0] enc_ordrs (bit [2:0] idx);
   reg [4:0] s1,s2,s3,r1,r2;
   {s1,s2,s3,r1,r2} = {encode('h11),encode('h12),encode('h13),
                       encode('h15),encode('h16)};
      case (idx)
         'h1: enc_ordrs = {s2,s1,s1,s1}; // SOP
         'h2: enc_ordrs = {s3,s3,s1,s1}; // SOP'
         'h3: enc_ordrs = {s3,s1,s3,s1}; // SOP"
         'h4: enc_ordrs = {s3,r2,s1,s1}; // SOP'_Debug
         'h5: enc_ordrs = {s2,s3,r2,s1}; // SOP"_Debug
         'h6: enc_ordrs = {r2,r1,r1,r1}; // Hard Reset
         'h7: enc_ordrs = {s3,r1,s1,r1}; // Cable Reset
         default: enc_ordrs = $random;// $display (" <%m> WARNING: invalid encoding request");
      endcase
   endfunction // enc_ordrs

   function [2:0] dec_ordrs (bit [19:0] raw);
   reg [19:0] sym; sym = {decode(raw[19-:5]),
                          decode(raw[14-:5]),
                          decode(raw[9-:5]),
                          decode(raw[4-:5])};
      case (sym)
         {5'h12,5'h11,5'h11,5'h11}: dec_ordrs = 1; // SOP
         {5'h13,5'h13,5'h11,5'h11}: dec_ordrs = 2; // SOP'
         {5'h13,5'h11,5'h13,5'h11}: dec_ordrs = 3; // SOP"
         {5'h13,5'h16,5'h11,5'h11}: dec_ordrs = 4; // SOP'_Debug
         {5'h12,5'h13,5'h16,5'h11}: dec_ordrs = 5; // SOP"_Debug
         {5'h16,5'h15,5'h15,5'h15}: dec_ordrs = 6; // Hard Reset
         {5'h13,5'h15,5'h11,5'h15}: dec_ordrs = 7; // Cable Reset
         default:                   dec_ordrs = 0; // N/A
         // $display (" <%m> WARNING: %02x_%02x_%02x_%02x not found",sym[19-:5],sym[14-:5],sym[9-:5],sym[4-:5]);
      endcase
   endfunction // dec_ordrs

   function [8*10-1:0] str_pwr_role (bit idx, bit [2:0] ordrs);
      casex ({ordrs,idx})
	'b0010: str_pwr_role = "Sink"; // SOP
	'b0011: str_pwr_role = "Source";
	'b01x0: str_pwr_role = "DFP/UFP"; // SOP'/SOP"
	'b01x1: str_pwr_role = "Cable Plug";
	'bxxx0: str_pwr_role = "0";
	'bxxx1: str_pwr_role = "1";
      endcase
   endfunction // str_pwr_role

   function [8*10-1:0] str_dat_role (bit idx, bit [2:0] ordrs);
      casex ({ordrs,idx})
	'b0010: str_dat_role = "UFP"; // SOP
	'b0011: str_dat_role = "DFP";
	'b01x0: str_dat_role = "Reserved"; // SOP'/SOP"
	'b01x1: str_dat_role = "ILLEGAL";
	'bxxx0: str_dat_role = "0";
	'bxxx1: str_dat_role = "1";
      endcase
   endfunction // str_dat_role

   function [8*12-1:0] str_ordrs (bit [2:0] idx);
      case (idx)
         1: str_ordrs = "SOP";
         2: str_ordrs = "SOP'";
         3: str_ordrs = "SOP\"";
         4: str_ordrs = "SOP'_Debug";
         5: str_ordrs = "SOP\"_Debug";
         6: str_ordrs = "Hard Reset";
         7: str_ordrs = "Cable Reset";
         default: str_ordrs = "?";
      endcase
   endfunction // str_ordrs

   function [8*2-1:0] str_ordrs_short (bit [2:0] idx);
      case (idx)
         1: str_ordrs_short = "";
         2: str_ordrs_short = "'";
         3: str_ordrs_short = "\"";
         4: str_ordrs_short = "D'";
         5: str_ordrs_short = "D\"";
         6: str_ordrs_short = "HR";
         7: str_ordrs_short = "CR";
         default: str_ordrs_short = "?";
      endcase
   endfunction // str_ordrs_short

   function [8*30-1:0] str_msgtyp (bit ext, bit data, bit [4:0] idx);
      case ({ext,data,idx})
	'h01: str_msgtyp = "GoodCRC";
	'h02: str_msgtyp = "GotoMin";
	'h03: str_msgtyp = "Accept";
	'h04: str_msgtyp = "Reject";
	'h05: str_msgtyp = "Ping";
	'h06: str_msgtyp = "PS_RDY";
	'h07: str_msgtyp = "Get_Source_Cap";
	'h08: str_msgtyp = "Get_Sink_Cap";
	'h09: str_msgtyp = "DR_Swap";
	'h0a: str_msgtyp = "PR_Swap";
	'h0b: str_msgtyp = "VCONN_Swap";
	'h0c: str_msgtyp = "Wait";
	'h0d: str_msgtyp = "Soft Reset";
	'h10: str_msgtyp = "Not_Supported";
	'h11: str_msgtyp = "Get_Source_Cap_Extended"; // 23-char
	'h12: str_msgtyp = "Get_Status";
	'h14: str_msgtyp = "Get_PPS_Status";
	'h21: str_msgtyp = "Source Capabilities"; // 19-char
	'h22: str_msgtyp = "Request";
	'h23: str_msgtyp = "BIST";
	'h24: str_msgtyp = "Sink Capabilities";
	'h26: str_msgtyp = "Alert";
	'h29: str_msgtyp = "EPR_Request";
	'h2a: str_msgtyp = "EPR_Mode";
	'h2f: str_msgtyp = "Vendor Defined";
	'h61: str_msgtyp = "Source_Capabilities_Extended"; // 28-char
	'h62: str_msgtyp = "Status";
	'h63: str_msgtyp = "Get_Battery_Cap";
	'h64: str_msgtyp = "Get_Battery_Status";
	'h65: str_msgtyp = "Battery_Capabilities";
	'h66: str_msgtyp = "Get_Manufacturer_Info";
	'h67: str_msgtyp = "Manufacturer_Info";
	'h68: str_msgtyp = "Security_Request";
	'h69: str_msgtyp = "Security_Response";
	'h6a: str_msgtyp = "Firmware_Update_Request";
	'h6b: str_msgtyp = "Firmware_Update_Response";
	'h6c: str_msgtyp = "PPS_Status";
	'h6d: str_msgtyp = "Country_Info";
	'h6e: str_msgtyp = "Country_Codes";
	'h70: str_msgtyp = "Extended_Control";
	'h71: str_msgtyp = "EPR_Source_Capabilities";
	'h72: str_msgtyp = "EPR_Sink_Capabilities";
	default: str_msgtyp = "rsvd";
      endcase
   endfunction // str_msgtyp

endclass // bmc_codec


class packet extends bmc_codec; // packet buffer for RX
   parameter MAX_LENGTH = 256; // 256-byte, CSP command format limits
   bit [MAX_LENGTH*10-1:0] bitstr; // bit stream
   bit [15:0] bicnt, // bit count
              ordrs_bit, eop_bit; // bit count of the ends
   bit [MAX_LENGTH*8-1:0] rx_data;
   bit [15:0] rx_ncnt; // nibble count

   function reset ();
      reset = bicnt>0;
      bicnt = 0;
      ordrs_bit = 0;
      eop_bit = 0;
      rx_ncnt = 0;
   endfunction // reset

   function void app_bits (bit [30:0] dat, bit [4:0] bicnt);
      reg [7:0] ii;
      for (ii=0; ii<bicnt; ii++)
         if (push_bit(dat[ii]));
   endfunction // app_bits

   function [3:0] push_bit (bit dat);
      if (bicnt<MAX_LENGTH*10) begin
         bitstr[bicnt] = dat;
         if (ordrs_bit>0 && ((bicnt-ordrs_bit)%5)==0)
            push_bit = 1; // nibble ends
         else
            push_bit = 0; // no message
      end else begin
         push_bit = -1;
//       $display ($time,"ns <%m> ERROR: overflow");
      end
      bicnt++; // wrap??
   endfunction // push_bit

   task push_nibble (bit [3:0] dat);
      rx_data[rx_ncnt++*4+:4] = dat;
   endtask // push_nibble

   function [2:0]  get_ordrs;  if (ordrs_bit)   get_ordrs  = dec_ordrs(bitstr[ordrs_bit-:20]); endfunction
   function [15:0] get_header; if (rx_ncnt>=4)  get_header = rx_data[0+:16]; endfunction
   function [4:0]  get_msgtyp; if (rx_ncnt>=4)  get_msgtyp = rx_data[0+:5]; endfunction
   function [2:0]  get_msgid;  if (rx_ncnt>=4)  get_msgid  = rx_data[9+:3]; endfunction
   function [2:0]  get_ndo;    if (rx_ncnt>=4)  get_ndo    = rx_data[12+:3]; endfunction
   function [31:0] get_do (bit [2:0] num);
                               if (rx_ncnt>=4+num*8)
                                                get_do     = rx_data[(2+num*4)*8+:32]; endfunction
   function [31:0] get_crc32;  if (rx_ncnt>=12) get_crc32  = crc32(rx_data,rx_ncnt/2); endfunction

   function is_header (input [15:0] exp);
      reg [7:0] ii;
      is_header = 1;
      if (rx_ncnt>=4)
         for (ii=0; ii<16; ii++)
            is_header &= exp[ii]===1'hx || rx_data[ii]===exp[ii];
   endfunction // is_header

endclass // packet


module usbpd_phy (
input rxd,
output txd, txoe
);
   reg [15:0] bit_rate = 300; // KHz
   reg [7:0] duty = 50, // %
             jitter = 0; // ns
   reg txdat = 0,
       txena = 0;
   assign txd = txdat;
   assign txoe = txena;
   wire #100 rxdat = rxd; // debounce

   reg cc_idle = 1;
   event ev_idle;
   time rx_edgeN = 0, rx_edgeNm = 0, rx_edgeNm2 = 0; // edge N, edge N-1, edge N-2
   always @(rxdat) begin
      if (~cc_idle) begin
         disable idle_dec;
         #1 ->ev_idle;
      end else if (cc_idle &&
                rx_edgeNm > 0 &&
          $time-rx_edgeNm <= 16*1000) cc_idle = 0; // busy detected
      rx_edgeNm2 = rx_edgeNm; // the prior edge for idle detection
      rx_edgeNm = rx_edgeN; // the prior edge for busy detection
      rx_edgeN = $time;
   end
   always @(ev_idle or negedge cc_idle)
   begin: idle_dec
      #(rx_edgeNm2+16*1000-$time) cc_idle = 1; // idle detected
   end

   function void show;
      $display ($time,"ns <%m> bit_rate: %0dKHz", bit_rate);
      $display ($time,"ns <%m> duty: %0d%", duty);
      $display ($time,"ns <%m> jitter: %0dns", jitter);
   endfunction // show

   task bmc_tx (input [7:0] bicnt, // bit count (127 max.)
                input [127:0] txbuf);
      reg [7:0] ii;
      for (ii=0; ii<bicnt; ii++) begin
         txdat = ~txdat;
         #(1000000.0/2/bit_rate) if (txbuf[ii]===1'h1) txdat = ~txdat;
         #(1000000.0/2/bit_rate);
      end
   endtask // bmc_tx

   parameter MAX_TX_BCNT = 1024*4; // 4K-byte
   parameter TX_BCNT_BIT = 13; // bits
   task tx_packet (input [2:0] ordrs,
                   input crc32 = 1,
                   input eop = 1,
                   input [TX_BCNT_BIT-1:0] bycnt = 0,
                   input [8*MAX_TX_BCNT-1:0] txbuf = 0,
                   input encode = 1,
                   input [6:0] preamble = 32); // 64-bit
      reg [TX_BCNT_BIT-1:0] ii;
      bmc_codec codec; codec = new;
      txena = 1;
      txdat = 1;
      if (!cc_idle) $display ($time,"ns <%m> WARNING: TX starts on CC not idle");
      if (preamble) for (ii=0; ii<preamble; ii++)
                    bmc_tx (2,2'b10); // preamble
      if (ordrs)    bmc_tx (20,codec.enc_ordrs(ordrs)); // ordered set
      if (bycnt)    for (ii=0; ii<bycnt*2; ii++)
                    bmc_tx (encode ? 5 : 4,
                            encode ? codec.encode('hf&(txbuf>>ii*4)) : txbuf>>ii*4);
      if (crc32) begin: crcgen
         reg [31:0] r_crc32;
            r_crc32 = codec.inv_comp(codec.crc32(txbuf,bycnt));
                    for (ii=0; ii<4*2; ii++)
                    bmc_tx (5,codec.encode('hf&(r_crc32>>ii*4))); // CRC32
      end // crcgen
      if (eop)      bmc_tx (5,codec.encode('h17)); // EOP
      if (txdat==0) bmc_tx (1,0); // dummy
                    bmc_tx (1,0); // tail
      txena = 0;
   endtask // tx_packet

   event ev_edge, ev_bit, ev_nibble;
   task rx_packet (packet pkt,
                   input end_at_eop = 1,
                   input end_at_rst = 1); // ordered set by 3 symbol??
      time stb, delta1, delta2;
      delta1 = 0;
      @rxdat stb = $time; // wait for the starting edge without timeout
      if (pkt.reset());
      begin: rx_loop
         forever fork begin
            ->ev_edge;
            @rxdat delta2 = delta1; delta1 = $time-stb; stb = $time;
            if (delta1>10000/4 || delta2<=10000/4 && delta2>0) begin
               if (pkt.push_bit(delta1<=10000/4)==1) begin // nibble ends
                  ->ev_nibble;
                  if (pkt.decode(pkt.bitstr[pkt.bicnt-1-:5])=='h17) begin // EOP can only be detected at nibble bondaries
                     pkt.eop_bit = pkt.bicnt-1;
                     if (end_at_eop) disable rx_loop;
                  end else if (pkt.ordrs_bit>0 && pkt.eop_bit==0)
                     pkt.push_nibble(pkt.decode(pkt.bitstr[pkt.bicnt-1-:5]));
               end
               delta1 = 0;
               if (pkt.ordrs_bit==0 && pkt.bicnt>30) begin
                  ->ev_bit;
                  case (pkt.dec_ordrs(pkt.bitstr[pkt.bicnt-1-:20]))
                     6,7: begin
                             pkt.ordrs_bit = pkt.bicnt-1;
                             if (end_at_rst) disable rx_loop;
                          end
                     1,2,3,4,5: pkt.ordrs_bit = pkt.bicnt-1;
                  endcase
               end
            end
            // else wait for the next short
            disable idle_to;
         end begin: idle_to
            #(1000*10) ->ev_edge;
            disable rx_loop; // forced end at idle
         end
         join
      end // tx_loop
   endtask // rx_packet

endmodule // usbpd_phy


