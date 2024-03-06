
module updprl (
// =============================================================================
// USBPD protocol layer submodule
// support auto-GoodCRC response
// support CopiedMessageID (no MessageIDCounter)
// support UVDM (Canyon_mode_0)
// 2015/06/23 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2016/03/23 remap r_txauto
// 2017/03/07 '1v' postfix for can1110a0
// 2017/07/12 '2v' fix Canyon Mode 0 read data packet returns too soon
// 2018/01/09 EOP to exit write data
// 2018/10/03 remove postfix
// ALL RIGHTS ARE RESERVED
// =============================================================================
input	[1:0]	r_spec, r_dat_spec,
input		r_auto_txgdcrc, r_dat_portrole, r_dat_datarole,
		r_auto_discard,
		r_set_cpmsgid,
input	[2:0]	r_dat_cpmsgid,
input	[7:0]	r_rdat,
input		r_rdy,
		pid_ccidle, r_discard,
		ptx_ack,
		ptx_txact,
		ptx_fifopop,
		prx_fifopsh,
		prx_gdmsgrcvd,
		prx_eoprcvd,
input	[2:0]	prx_rcvdords,
input	[7:0]	prx_fifowdat,
input	[47:0]	pff_c0dat, // 32-bit VDM HEADER, 16-bit message header
output	[7:0]	prl_rdat, // for PHYTX to transmit
output	[6:0]	prl_txauto,
output		prl_last, // last data to transmit
		prl_txreq,
		prl_c0set, prl_cany0,
		prl_cany0r, prl_cany0w,
		prl_idle,
		prl_discard, prl_GCTxDone,
output	[3:0]	prl_fsm,
output	[2:0]	prl_cpmsgid,
output	[7:0]	prl_cany0adr,
input		clk, srstz
);
parameter // prl- (protocol in spec.)
   prcl_idle = 4'h0, // prcl- (protocol in 4-char naming)
   prcl_tgap = 4'h1, // wait for tInterFrameGap
   prcl_gcc0 = 4'h2, // send GoodCRC low-byte
   prcl_gcc1 = 4'h3, // send GoodCRC high-byte
   prcl_wgcc = 4'h4, // wait for GoodCRC TX done
   prcl_addr = 4'h5, // wait for Canyon_mode_0 address
   prcl_cmmd = 4'h6, // wait for Canyon_mode_0 command
   prcl_bcnt = 4'h7, // wait for Canyon_mode_0 read_byte_count
   prcl_rxda = 4'h8, // wait for Canyon_mode_0 rx-data
   prcl_txda = 4'h9; // wait for Canyon_mode_0 tx-data
   reg [3:0] cs_prcl;
   wire cs_prcl_idle = cs_prcl==prcl_idle;
   wire cs_prcl_tgap = cs_prcl==prcl_tgap;
   wire cs_prcl_gcc0 = cs_prcl==prcl_gcc0;
   wire cs_prcl_gcc1 = cs_prcl==prcl_gcc1;
   wire cs_prcl_wgcc = cs_prcl==prcl_wgcc;
   wire cs_prcl_addr = cs_prcl==prcl_addr;
   wire cs_prcl_cmmd = cs_prcl==prcl_cmmd;
   wire cs_prcl_bcnt = cs_prcl==prcl_bcnt;
   wire cs_prcl_rxda = cs_prcl==prcl_rxda;
   wire cs_prcl_txda = cs_prcl==prcl_txda;

   assign prl_fsm = cs_prcl;
   assign prl_idle = cs_prcl_idle;

   wire gdmsgrcvd = prx_gdmsgrcvd; // EOP with correct-CRC is arriving, except GoodCRC
   wire sendgdcrc = gdmsgrcvd & r_auto_txgdcrc | prl_c0set;
        /* to transmit auto GoodCRC */

   wire [1:0] PrlTo;
   wire InterFramTimeout = PrlTo[0];
   wire TransmitTimeout = PrlTo[1];
   wire tgap2gcc0 = InterFramTimeout & pid_ccidle;
   wire discard = r_discard | prl_discard; // discarded by MCU or PRL
   wire stoptimer = tgap2gcc0 | ~r_auto_discard & InterFramTimeout | discard;
   PrlTimer_1112a0 u0_PrlTimer (PrlTo, sendgdcrc, stoptimer, clk, srstz);
   assign prl_discard = cs_prcl_tgap & r_auto_discard & TransmitTimeout; // auto-discard, set STA1, goes idle
   assign prl_GCTxDone = cs_prcl_wgcc & ptx_ack &~prl_cany0;

   reg c0_iop; // IO port (fixed address)
   reg [7:0] c0_adr;
   reg [8:0] c0_cnt;

   // [4]: data role: reserved in SOP'/SOP"
   // [8]: port role: in SOP'/SOP"(0:UFP/DFP, 1:cable plug), in SOP(0:Sink, 1:Source)
   reg [2:0] CpMsgId;
   reg [7:0] txbuf;
   wire [2:0] ords = prx_rcvdords;
   wire PortRole = ~r_dat_portrole; // power-role/cable-plug
   wire DataRole = (ords=='h1) ?~r_dat_datarole :1'h0; // data_role (=0 if not SOP)
   wire [1:0] SpecRev = (r_spec=='h3) ?r_dat_spec :r_spec;
   wire [15:0] GdCRCHdr = {4'h0,CpMsgId,PortRole,
				SpecRev,DataRole,1'h0,4'h1};
   assign prl_last   = cs_prcl_gcc1 | cs_prcl_txda & (c0_cnt=='h0);
   assign prl_rdat   = cs_prcl_gcc1 ?GdCRCHdr[15:8]
                     : cs_prcl_gcc0 ?GdCRCHdr[7:0] :txbuf;

   assign prl_txreq  = cs_prcl_tgap & tgap2gcc0  | cs_prcl_txda & ~ptx_txact;
         wire c0exit = cs_prcl_rxda & pid_ccidle | cs_prcl_txda & ptx_ack
                     | cs_prcl_rxda & prx_eoprcvd
                     | cs_prcl_cmmd & prx_fifopsh & (prx_fifowdat>'h3);

   assign prl_cany0r = cs_prcl_bcnt & prx_fifopsh | cs_prcl_txda & ptx_fifopop & ~prl_last;
   assign prl_cany0w = cs_prcl_rxda & prx_fifopsh;
   assign prl_cany0adr = c0_adr; // SFR is above 80h
   always @(posedge clk)
      if (prl_cany0r | r_rdy)
         txbuf <= r_rdat;

   always @(posedge clk)
      if (~srstz)
         cs_prcl <= prcl_idle;
      else case (cs_prcl)
      prcl_idle:
         if (sendgdcrc) cs_prcl <= prcl_tgap;
      prcl_tgap:
         if (discard) cs_prcl <= prcl_idle; // discard only affects in prcl_tgap state
         else if (tgap2gcc0) cs_prcl <= prcl_gcc0;
      prcl_gcc0:
         if (ptx_fifopop) cs_prcl <= prcl_gcc1;
      prcl_gcc1:
         if (ptx_fifopop) cs_prcl <= prcl_wgcc;
      prcl_wgcc:
         if (ptx_ack)
            if (prl_cany0)
               cs_prcl <= prcl_addr;
            else
               cs_prcl <= prcl_idle;
      default: // Canyon_mode_0 (c0)
         if (c0exit)
            cs_prcl <= prcl_idle;
         else case (cs_prcl)
         prcl_addr: // address
            if (prx_fifopsh) begin
               cs_prcl <= prcl_cmmd;
               c0_adr <= prx_fifowdat;
            end
         prcl_cmmd: // command
            if (prx_fifopsh)
               case (prx_fifowdat)
               'h0, // memory read
               'h1, // memory write
               'h2, // IO read
               'h3: begin // IO write
                  cs_prcl <= prx_fifowdat[0] ?prcl_rxda :prcl_bcnt; // 0/1: r/w
                  c0_iop <= prx_fifowdat[1]; // DigitalDesignNote.ppt-defined
               end
               default:
                  cs_prcl <= prcl_idle;
               endcase
         prcl_bcnt: // byte-count (only for read)
         begin
            if (pid_ccidle) begin // '2v' reference design for aull-mask rev.
               cs_prcl <= prcl_txda;
               if (~c0_iop) c0_adr <= c0_adr +'h1;
            end
            if (prx_fifopsh)
               c0_cnt <= prx_fifowdat;
         end
         prcl_rxda, // rx-data (mode 0 write)
         prcl_txda: // tx-data (mode 0 read)
            if (cs_prcl_rxda & prx_fifopsh | cs_prcl_txda & ptx_fifopop) begin
               if (~c0_iop) c0_adr <= c0_adr +'h1;
               if (|c0_cnt & cs_prcl_txda) c0_cnt <= c0_cnt -'h1;
            end
         endcase
      endcase

   wire [15:0] cany0hdr = pff_c0dat[15:0]; // message header
   wire [31:0] cany0vhd = pff_c0dat>>(16); // VDM HEADER
   reg canyon_m0;
   wire cany0dec = {cany0vhd,cany0hdr[15:12],cany0hdr[3:0]}=={16'h412a,16'h412a,8'h1f};
   wire c0set =~canyon_m0 & gdmsgrcvd
//			& (CpMsgId!=rcvdmsgid) // not a retried message // 20160623 for less complexity
                        & cany0dec;
   always @(posedge clk)
      if (~srstz | c0exit)
         canyon_m0 <= 'h0;
      else if (prl_c0set)
         canyon_m0 <= 'h1;

   always @(posedge clk)
      if (~srstz) // include Soft Reset / Hard Reset / Cable Reset / MCU-issued reset
         CpMsgId <= 'h7;
      else if (r_set_cpmsgid)
         CpMsgId <= r_dat_cpmsgid;
      else if (gdmsgrcvd)
         CpMsgId <= cany0hdr[11:9];

   assign prl_cpmsgid = CpMsgId;
   assign prl_cany0 = canyon_m0; // to stop MCU
   assign prl_c0set = c0set;
   assign prl_txauto = {1'h0,1'h1,~cs_prcl_txda,1'h1,ords}; // auto SOP*,preamble,CRC32/or/not,EOP

endmodule // updprl

