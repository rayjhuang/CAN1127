
module phyff // linear FIFO
// =============================================================================
// USBPD physical layer submodule
// TX/RX buffer by a linear FIFO
// 2015/04/13 created, RAY HUANG, rayhuang@canyon-semi.com.tw
// 2017/03/07 '1v' postfix for can1110a0
// 2018/10/03 remove postfix for new naming rule
// ALL RIGHTS ARE RESERVED
// =============================================================================
#(
parameter
	DEPTH_NUM = 32, DEPTH_NBT = 5,
	WIDTH_NUM = 8
)(
input			r_psh, r_pop, // push first and then pop if simultanuosly
			prx_psh, ptx_pop,
			r_last, r_unlock, i_lockena, r_fiforst,
			i_ccidle,
input	[WIDTH_NUM-1:0]	r_wdat, prx_wdat,
output			txreq,
output	[1:0]		ffack,
output	[WIDTH_NUM-1:0]	rdat0,
output			full, empty, one, half,
output			obsd, // obsoleted, be reset with non-empty
output	[WIDTH_NUM*7-1:0] dat_7_1, // additional data for decoding Canyon_mode_0
output	[DEPTH_NBT-1:0]	ptr,
output	[WIDTH_NUM-1:0]	fifowdat,
output			fifopsh,
input			clk, srstz
);
   wire l_psh = r_psh & r_last; // lastpush
   wire l_pop = r_pop & one; // lastpop

   reg locked; // uP locks FIFO
   wire ps_locked =
       (~srstz | r_fiforst | ptx_pop | prx_psh) ?'h0
      :((r_psh | r_pop) & i_lockena) ?'h1 :locked;
   always @(posedge clk)
         locked <= ps_locked;
   wire lock_ok = ps_locked | r_unlock;
   wire req_ok = l_psh & lock_ok;

   assign ffack[0] = (l_psh | l_pop) & lock_ok; // success, ACK
   assign ffack[1] = (r_psh | r_pop) &~lock_ok | // discarded, NAK
                             req_ok &~i_ccidle | // discarded
               full & r_psh | r_pop & empty; // over/under-flow

   wire   fifopop = ptx_pop | r_pop & lock_ok;
   assign fifopsh = prx_psh | r_psh & lock_ok;
   assign fifowdat = prx_psh ?prx_wdat :r_wdat; // phyrx gets high priority
   assign txreq = req_ok & i_ccidle;

// reg [DEPTH_NBT:0] pshptr; // additional full flag only for DEPTH_NUM = 2**DEPTH_NBT
// assign full = pshptr[DEPTH_NBT];
   reg [DEPTH_NBT-1:0] pshptr;
   assign ptr = pshptr[DEPTH_NBT-1:0];
   assign full = pshptr[DEPTH_NBT-1:0]>=$unsigned(DEPTH_NUM);
   assign half = pshptr[DEPTH_NBT-1:0]==$unsigned(DEPTH_NUM)>>1;
   assign one = pshptr=='h1;
   assign empty = pshptr=='h0;
   assign obsd = ~empty && ~srstz;

`define FIFO_USE_ARCH2
`ifdef FIFO_USE_ARCH1
// linear FIFO
// push and pop simultaneously works except two conditions:
// 1. full : pushed data lost, pop mechanism works, full de-asserted
// 2. empty: pushed data lost, FIFO expose the next invalid entry
   reg [WIDTH_NUM*DEPTH_NUM-1:0] mem;
   assign rdat0 = mem[WIDTH_NUM-1:0];
   always @(posedge clk) begin: pshpop_mem
      if (~srstz | r_fiforst) pshptr = 'h0; // to reset pshptr before push data
      if (fifopsh &~full) mem[pshptr*WIDTH_NUM+:WIDTH_NUM] = fifowdat;
      if (fifopop &~empty)
         mem = mem >> WIDTH_NUM;
`endif // FIFO_USE_ARCH1
`ifdef FIFO_USE_ARCH2
// linear FIFO
// push and pop simultaneously works except two conditions:
// 1. empty: pushed data saved, FIFO expose the invalid entry (empty)
   reg [WIDTH_NUM-1:0] mem [0:DEPTH_NUM-1];
   assign rdat0 = mem[0];
   assign dat_7_1 = {
		mem[7],mem[6],mem[5],mem[4], // DO#1
		mem[3],mem[2], // message header
		mem[1]}; // ordered-set [15:8]
   always @(posedge clk) begin: pshpop_mem
      reg [7:0] idx;
      if (~srstz | r_fiforst) pshptr = 'h0; // to reset pshptr before push data
      if (fifopsh &~full) mem[pshptr] = fifowdat;
      if (fifopop &~empty)
         for (idx=0;idx<DEPTH_NUM;idx=idx+1)
            if (idx==$unsigned(DEPTH_NUM-1)) begin
               if (fifopsh & full)
                          mem[idx] = fifowdat;
            end else if (pshptr>idx)
                          mem[idx] = mem[idx+1];
`endif // FIFO_USE_ARCH2
      if (fifopsh ^ fifopop)
         pshptr = (fifopop) ?pshptr -{1'h0,~empty}
                            :pshptr +{1'h0,~full}; // over/under-flow protecting
   end

endmodule // phyff

