
module phytx (
// =============================================================================
// USBPD physical layer submodule
// TX controller with a BMC encoder
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2016/03/23 remap r_txauto
// 2016/11/22 add zero-payload special case
// 2017/03/07 '1v' postfix for can1110a0
// 2018/10/03 remove postfix for new naming rule
// ALL RIGHTS ARE RESERVED
// =============================================================================

input	[4:0]	r_txnumk, // number of k-coded in byte
input		r_txendk, r_txshrt,
input	[6:0]	r_txauto, // {DbgSOP,EncK,EOP,CRC,SOP[1:0],preamble}
input	[1:0]	prx_cccnt,
output		ptx_txact,
output	reg	ptx_cc,
output		ptx_goidle,
output		ptx_fifopop, ptx_pspyld, // go txph_pyld
input	[7:0]	i_rdat,
input		i_txreq, i_one,
output		ptx_crcstart, ptx_crcshfi4, ptx_crcshfo4,
output	[3:0]	ptx_crcsidat,
output	[2:0]	ptx_fsm,
input	[3:0]	pcc_crc30,
input		clk, srstz
);
   reg [2:0] cs_txph, ps_txph; // TX phase
   parameter txph_idle = 3'h0;
   parameter txph_pamb = 3'h1; // auto-preamble
   parameter txph_asop = 3'h3; // auto-SOP
   parameter txph_pyld = 3'h2; // payload
   parameter txph_acrc = 3'h6; // auto-CRC32 check
   parameter txph_aeop = 3'h4; // auto-EOP
   parameter txph_endu = 3'h5; // ending UI
   wire cs_idle = cs_txph==txph_idle;
   wire cs_pamb = cs_txph==txph_pamb;
   wire cs_asop = cs_txph==txph_asop;
   wire cs_pyld = cs_txph==txph_pyld;
   wire cs_acrc = cs_txph==txph_acrc;
   wire cs_aeop = cs_txph==txph_aeop;
   wire cs_endu = cs_txph==txph_endu;
   wire ps_pyld = ps_txph==txph_pyld;

   wire autoenk = r_txauto[6];//r_txauto[5]; // encode K-code, ortherwise, output raw data
   wire autoeop = r_txauto[5];//r_txauto[4];
   wire autocrc = r_txauto[4];//r_txauto[3];
   wire autopam = r_txauto[3];//r_txauto[0];
   wire [2:0] autosop = r_txauto[2:0];//{r_txauto[6],r_txauto[2:1]};
   wire [7:1] sopsel = {
		autosop=='h7, // Cable Reset
		autosop=='h6, // Hard Reset
		autosop=='h5,//autosop=='h5,  // SOP"_Debug
		autosop=='h4,//autosop=='h6,  // SOP'_Debug
		autosop=='h3,//autosop=='h3 || autosop=='h7, // SOP
		autosop=='h2,//autosop=='h2,  // SOP'
		autosop=='h1};//autosop=='h1}; // SOP"
   reg hinib;
   reg [3:0] bitcnt; // 10-bit / 16-bit
   reg [4:0] bytcnt;
   wire [3:0] dat0 = hinib ?i_rdat[7:4] :i_rdat[3:0];
   wire [3:0] dat1 = i_rdat[3:0]; // 20180316: to fix TBC19 (TX_AUTO_K), refer to ../bench/rtl
   wire bitsent = ~cs_idle & prx_cccnt[0];

   // r_txnumk is higher priority than r_txendk
   wire kcod = ((bytcnt<r_txnumk) | (r_txnumk=='h1f) | i_one & r_txendk) & cs_pyld; // K-code in payload state
   wire bit8nib = (dat0=='h4) | (dat0=='h8) | (dat0=='h9) | ~autoenk; // 8-bit nibble
   wire bit8enc = kcod & bit8nib | cs_pamb;
   wire [3:0] earlyptr = bit8enc ?'h7 :'h4;
   wire [3:0] ffpopptr = bit8enc ?'hf :'h9;
   wire nibsent = bitsent & (bitcnt==earlyptr); // low-nibble/raw-byte sent
   wire bytepop = bitsent & (bitcnt==ffpopptr); // high-nibble sent
   wire earlypop = kcod & nibsent & (~autoenk | (i_rdat[7:4]=='h0)); // no high-nibble
   wire pyldpop = (bytepop | earlypop) & cs_pyld;
   wire asop2 = bytepop & (bytcnt=='h1); // asop-to-(next state)
   wire emptypop = cs_asop & asop2 & i_one & r_txendk & (i_rdat[7:0]=='h0); // zero-payload
   wire fifopop = pyldpop | emptypop;

   wire [3:0] ptr = hinib ?bitcnt-earlyptr-'h1 :bitcnt;
   wire [4:0] enc0 = bmc_encoder ({kcod, cs_acrc ?pcc_crc30 :dat0});
   wire [7:0] enc8 = autoenk ?
	{(dat0=='h4) ?3'h5 // 3'b101,5'b01010 (8-bit-01)
	:(dat0=='h9) ?3'h7 :3'h0, bmc_encoder ({1'h1,dat0})} :i_rdat; // 8-bit-raw
   wire [7:0] encout =
                 cs_endu ?{3'h0, 5'h0} // 20151006, not in CAN1106
		:cs_aeop ?{3'h0, bmc_encoder ('h17)}
		:cs_asop ?{3'h0, ordrs_enc (autosop,bytcnt[0],hinib)}
		:cs_pamb ?8'haa
		:bit8enc ?enc8 :{3'h0,enc0};

   always @(posedge clk)
      if (i_txreq | bytepop | earlypop | nibsent & cs_aeop)
         bitcnt <= 'h0;
      else if (bitsent)
         bitcnt <= bitcnt +'h1;

   always @(posedge clk)
      if (i_txreq | (cs_txph!=ps_txph)
		 )//| (r_txauto[4:0]=='h0)) // BIST, keep bytecnt 0, to prevent from bytcnt>=r_txnumk
         bytcnt <= 'h0;
      else if ((pyldpop | bytepop & (cs_pamb | cs_asop | cs_acrc)) & (bytcnt<'h1f))
         bytcnt <= bytcnt +'h1;

   always @(posedge clk)
      if (i_txreq | bytepop | earlypop) hinib <= 'h0;
      else if (nibsent & ~cs_aeop) hinib <= 'h1;

   wire tx_bmc = encout[ptr];
   always @(posedge clk)
      if (~srstz)
         ptx_cc <= 'h1;
      else if (i_txreq)
         ptx_cc <= ~ptx_cc; // the first transit
      else if (~cs_idle)
         case (1)
         prx_cccnt[1]: if (tx_bmc) ptx_cc <= ~ptx_cc;
         prx_cccnt[0]: ptx_cc <= ~ptx_cc;
         endcase

   always @(posedge clk)
      cs_txph <= (srstz) ?ps_txph :txph_idle;
   always @*
   begin
      ps_txph = cs_txph;
      case (1)
      cs_idle: if (i_txreq)
			ps_txph =
			 autopam ?txph_pamb
			:(|sopsel) ?txph_asop :txph_pyld;
      cs_pamb: if (bytepop & ((bytcnt=='h3) | r_txshrt /* & (bytcnt=='h1) */))
			ps_txph = 
			 (|sopsel) ?txph_asop :txph_pyld;
      cs_asop: if (asop2)
			ps_txph = // zero-payload special case
			 emptypop ?txph_endu :txph_pyld;
      cs_pyld: if (pyldpop & i_one)
			ps_txph =
			 autocrc ?txph_acrc
			:autoeop ?txph_aeop :txph_endu;
      cs_acrc: if (bytepop & (bytcnt=='h3))
			ps_txph = 
			 autoeop ?txph_aeop :txph_endu;
      cs_aeop: if (nibsent)
			ps_txph = txph_endu;
      cs_endu: if (bitsent & ~ptx_cc)
			ps_txph = txph_idle;
      endcase
   end

   assign ptx_fsm = cs_txph;
   assign ptx_txact = ~cs_idle;
   assign ptx_goidle = cs_endu & bitsent & ~ptx_cc;
   assign ptx_fifopop = fifopop;
   assign ptx_pspyld = ~cs_pyld & ps_pyld;
   assign ptx_crcstart = cs_pyld & ~kcod &  nibsent & (bytcnt==r_txnumk) & (r_txnumk!='h1f);
   assign ptx_crcshfi4 = cs_pyld & ~kcod & (nibsent | bytepop);
   assign ptx_crcshfo4 = cs_acrc & (nibsent | bytepop);
   assign ptx_crcsidat = dat0;

function [4:0] bmc_encoder;
input [4:0] dat;
   case (dat)
      'h00: bmc_encoder = 'b11110;
      'h01: bmc_encoder = 'b01001;
      'h02: bmc_encoder = 'b10100;
      'h03: bmc_encoder = 'b10101;
      'h04: bmc_encoder = 'b01010;
      'h05: bmc_encoder = 'b01011;
      'h06: bmc_encoder = 'b01110;
      'h07: bmc_encoder = 'b01111;
      'h08: bmc_encoder = 'b10010;
      'h09: bmc_encoder = 'b10011;
      'h0a: bmc_encoder = 'b10110;
      'h0b: bmc_encoder = 'b10111;
      'h0c: bmc_encoder = 'b11010;
      'h0d: bmc_encoder = 'b11011;
      'h0e: bmc_encoder = 'b11100;
      'h0f: bmc_encoder = 'b11101;
//    'h10: bmc_encoder = 'b00000; // skip nibble
      'h11: bmc_encoder = 'b11000; // Sync-1
      'h12: bmc_encoder = 'b10001; // Sync-2
      'h13: bmc_encoder = 'b00110; // Sync-3
      'h14: bmc_encoder = 'b01010; // preamble, 8-bit-01
      'h15: bmc_encoder = 'b00111; // RST-1
      'h16: bmc_encoder = 'b11001; // RST-2
      'h17: bmc_encoder = 'b01101; // EOP
      'h18: bmc_encoder = 'b00000; // 8-bit-0
      'h19: bmc_encoder = 'b11111; // 8-bit-1
      default:
            bmc_encoder = 'h10;
   endcase
endfunction // bmc_encoder

function [4:0] ordrs_enc;
input [2:0] sel;
input hiby,hinib;
   ordrs_enc = (sel=='h1) ? bmc_encoder ((hiby & hinib) ?'h12 :'h11) // SOP
             : (sel=='h2) ? bmc_encoder ( hiby          ?'h13 :'h11) // SOP'
             : (sel=='h3) ? bmc_encoder (        hinib  ?'h13 :'h11) // SOP"
             : (sel=='h4) ? bmc_encoder ((hiby & hinib) ?'h13 :(hiby | hinib) ?'h16 :'h11) // SOP'_Debug
             : (sel=='h5) ? bmc_encoder ( hiby ? hinib  ?'h12 :'h13 :hinib ?'h16 :'h11) // SOP"_Debug
             : (sel=='h6) ? bmc_encoder ((hiby & hinib) ?'h16 :'h15) // Hard Reset
             : (sel=='h7) ? bmc_encoder (        hinib  ?hiby ?'h13 :'h11 :'h15) // Cable Reset
             : 'h0;
endfunction // ordrs_enc

endmodule // phytx

