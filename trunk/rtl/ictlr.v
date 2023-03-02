
module ictlr #(
// =============================================================================
// instruction memory (program memory, pmem) controller
// 20210427 copy from CAN1123 (ATO0004KX8VI150BG33NA)
//          modification for 2-8K64x8 (ATO0008KX8VI150BG34DB) configuration
//          remove checksum
//          add BIT_ADDR, OTP_ADDR, INF_ADDR
// ALL RIGHTS ARE RESERVED
// =============================================================================
parameter BIT_ADDR = 15, // memory bus width
parameter OTP_ADDR = 16, // OTP address width, for 2-IP config. -> OTP_ADDR = BIT_ADDR-2+3
parameter INF_ADDR = 6,  // [INF_ADDR-1:0] for information row
parameter BIT_DEPTH = 5, // pointer width with FULL indicator
parameter N_DEPTH   = 24 // storage depth, <= MAX_DEPTH (2**BIT_DEPTH-1)
)(
input		bkpt_ena,
input	[BIT_ADDR-1:0]
		bkpt_pc,
		memaddr_c,
		memaddr,
input		mcu_psr_c,
		mcu_psw,
		hit_ps_c,
		hit_ps,
output		mempsack,
input	[7:0]	memdatao,
output		o_set_hold,
		o_bkp_hold,
		o_ofs_inc,
output	[7:0]	o_inst,
		d_inst,
// -----------------------------------------------------------------------------
output		sfr_psrack,
input	[BIT_ADDR-1:0]sfr_psofs,
input		sfr_psr,
		sfr_psw, // 1T pulse
		dw_rst,
		dw_ena,
input	[7:0]	sfr_wdat,
// -----------------------------------------------------------------------------
output		pmem_pgm,
		pmem_re,
		pmem_csb,
output	[1:0]	pmem_clk,
output	[OTP_ADDR-1:0]pmem_a, // 3-bit bit-address for programming
input	[7:0]	pmem_q0,
		pmem_q1,
output	[1:0]	pmem_twlb,
// -----------------------------------------------------------------------------
input	[1:0]	wd_twlb,
input		we_twlb,
		pwrdn_rst,
		r_pwdn_en,
		r_multi, // can1124a0eco1
		r_hold_mcu,
		clk, srst
);

   wire [7:0] pmem_qz;
   wire cksrd = 1'h0;
   wire cks_busy = 1'h0;

   reg [3:0] d_hold; // short-hold filter
   wire r_hold = &{d_hold,r_hold_mcu};
   always @(posedge clk)
      if (srst) d_hold <= 'h0;
      else d_hold <= {d_hold,r_hold_mcu};

   reg [1:0] dummy;
   wire act_psw = sfr_psw & (dummy=='h0);
   always @(posedge clk)
      if (srst | dw_rst)
         dummy <= 'h0;
      else if (dw_ena & sfr_psw)
         dummy <= (dummy>'h1) ? 'h0 : dummy + 'h1;

   wire m_psrd = mcu_psr_c & hit_ps_c & ~cks_busy;
   wire r_psrd = sfr_psr & r_hold;
   wire r_pswr = act_psw & r_hold | mcu_psw & hit_ps;

   reg [3:0] cs_ft;
   parameter ft_idle = 4'h0;
   parameter ft_dmmy = 4'h4;
   parameter ft_dmrw = 4'h5;
   parameter ft_dmck = 4'h6;
   parameter ft_stby = 4'h1; // standby
   parameter ft_rclk = 4'h2;
   parameter ft_rwai = 4'h3; // wait for address transit
   parameter ft_pwdn = 4'h9; // power down
   parameter ft_sfak = 4'ha; // ack sfr_psr/psw
   parameter ft_psw0 = 4'h8;
   parameter ft_psw1 = 4'hd;
   parameter ft_pswp = 4'hc;
   wire cs_rclk = cs_ft==ft_rclk;
   wire cs_stby = cs_ft==ft_stby;
   wire cs_sfak = cs_ft==ft_sfak;
   wire cs_psw1 = cs_ft==ft_psw1;

   parameter N_PP_WIDTH = 120; // 10us
   reg [6:0] wspp_cnt;
   reg [1:0] r_twlb;
   reg [2:0] a_bit;
   reg [BIT_ADDR-1:0] c_adr; // cache address
   reg [BIT_ADDR-1:0] adr_p; // OTP address
   reg [7:0] c_buf [N_DEPTH-1:0];
   reg [BIT_DEPTH-1:0] c_ptr; // cache push pointer
   wire c_full  = c_ptr==N_DEPTH;
   wire p_full  = c_ptr==N_DEPTH-'h1;
   wire c_vld   = c_ptr>'h0;
   wire c_hit   = memaddr_c< (c_adr+c_ptr) && memaddr_c>=c_adr && c_vld;
   wire p_hit   = memaddr_c==(c_adr+c_ptr); // pre-hit
   wire p_conti = memaddr_c==(c_adr+c_ptr+'h1); // pre-continuous

   wire a_sel_0 = adr_p[BIT_ADDR-1:BIT_ADDR-2]==2'h0
               || adr_p[BIT_ADDR-1:BIT_ADDR-2]==2'h2 && adr_p[OTP_ADDR-3-1:INF_ADDR]=='h0;
   wire a_sel_1 = adr_p[BIT_ADDR-1:BIT_ADDR-2]==2'h1
               || adr_p[BIT_ADDR-1:BIT_ADDR-2]==2'h2 && adr_p[OTP_ADDR-3-1:INF_ADDR]=='h1;
   assign pmem_qz = a_sel_0 ? ~pmem_q0 :
                    a_sel_1 ? ~pmem_q1 : 'hee; // out-of-range value for d_psrd

   wire [7:0] rd_buf = c_buf['h0],
              dbg_01 = c_buf['h1],
              dbg_02 = c_buf['h2],
              dbg_03 = c_buf['h3],
              dbg_04 = c_buf['h4],
              dbg_05 = c_buf['h5],
              dbg_06 = c_buf['h6],
              dbg_07 = c_buf['h7],
              dbg_08 = c_buf['h8],
              dbg_09 = c_buf['h9],
              dbg_0a = c_buf['ha],
              dbg_0b = c_buf['hb],
              dbg_0c = c_buf['hc],
              dbg_0d = c_buf['hd],
              dbg_0e = c_buf['he],
              dbg_0f = c_buf['hf],
              wr_buf = c_buf[N_DEPTH-1];

   reg pgm_p, re_p, r_rdy, d_psrd;
   wire [BIT_ADDR-1:0] pre_0_adr = mcu_psw ? memaddr : sfr_psofs;
   wire [BIT_ADDR-1:0] pre_1_adr = adr_p + 'h1;
   always @(posedge clk)
      if (srst | pwrdn_rst) begin
         cs_ft <= ft_idle;
         c_adr <= {BIT_ADDR{1'h1}};
         c_ptr <= 'h0;
         r_rdy <= 1'h0;
         pgm_p <= 1'h0;
         re_p <= 1'h0;
         adr_p <= 'h0;
         d_psrd <= 1'h0;
         r_twlb <= 2'h0;
      end else case (cs_ft)
      ft_idle:
         if (m_psrd | r_psrd | cksrd) begin
            cs_ft <= ft_dmmy;
            re_p <= 1'h1; // dummy read
            d_psrd <= r_psrd & ~m_psrd;
            a_bit <= 'h0;
         end else if (r_pswr) begin
            cs_ft <= ft_psw0;
            pgm_p <= 1'h1;
            c_ptr <= 'h0;
            a_bit <= 'h0;
            adr_p <= pre_0_adr;
            r_twlb <= (pre_0_adr[BIT_ADDR-1:BIT_ADDR-2]==2'h2) ? 2'h3 : 2'h0;
            c_buf [N_DEPTH-1] <= ~(mcu_psw ? memdatao : sfr_wdat);
         end else if (we_twlb)
            r_twlb <= wd_twlb;
      ft_psw1,
      ft_psw0:
         if (mcu_psw) begin // byte-write for MON51
            wspp_cnt <= 'h0;
            cs_ft <= cs_psw1 ? ft_sfak
                             : ft_pswp;
         end else begin
            c_buf [N_DEPTH-1] <= (wr_buf >> 1);
            if (cs_psw1) a_bit <= a_bit + 'h1;
            if (wr_buf[0]) begin
               cs_ft <= ft_pswp;
               wspp_cnt <= N_PP_WIDTH-'h1;
            end else if (wr_buf=='h0) begin
               cs_ft <= ft_sfak;
               a_bit <= 'h0;
            end else
               cs_ft <= ft_psw1;
         end
      ft_pswp: // 10us CLK pulse
         if (wspp_cnt=='h0) // Tsw_pp timeout
            cs_ft <= ft_psw1;
         else
            wspp_cnt <= wspp_cnt - 'h1;
      ft_dmmy: cs_ft <= ft_dmrw;
      ft_dmrw: cs_ft <= ft_dmck;
      ft_dmck: begin
            cs_ft <= ft_rwai;
            if (d_psrd) begin
               c_ptr <= 'h0;
               adr_p <= sfr_psofs;
               r_twlb <= (sfr_psofs[BIT_ADDR-1:BIT_ADDR-2]==2'h2) ? 2'h3 : 2'h0;
            end else if (~cksrd)
               if (c_hit)
                  cs_ft <= ft_stby;
               else begin
                  adr_p <= memaddr_c;
                  r_twlb <= (memaddr_c[BIT_ADDR-1:BIT_ADDR-2]==2'h2) ? 2'h3 : 2'h0;
                  if (~p_hit) begin
                     c_adr <= memaddr_c;
                     c_ptr <= 'h0;
                  end
               end
         end
      ft_rwai: begin
            cs_ft <= ft_rclk;
            r_rdy <= (m_psrd & c_hit | cksrd) ? 1'h1 : 1'h0;
         end
      ft_stby,
      ft_rclk: begin
            cs_ft <= ft_rwai;
            r_rdy <= (m_psrd & (cs_rclk & p_hit | c_hit)) ? 1'h1 : 1'h0;
            if (cks_busy) begin
               if (adr_p=='h8ff) begin // @ft_rclk
                  cs_ft <= ft_stby;
                  adr_p <= 'h0;
               end else if (cs_rclk)
                  adr_p <= adr_p + 'h1;
            end else if (d_psrd) begin
               cs_ft <= ft_sfak;
               r_rdy <= 1'h0;
               c_buf[c_ptr] <= pmem_qz;
            // 'bx11xx, not possible
            // 'bx011x, not possible
            // 'bx101x, not possible
            // case {m_psrd,p_conti,p_hit,c_hit,c_full}
            // 'b11001
            // 'b10101
            end else if (m_psrd & (p_conti | cs_rclk & p_hit) & c_full) begin: shift_buf
               reg [BIT_DEPTH-1:0] ii;
               for (ii=0;ii<N_DEPTH-1;ii=ii+1) c_buf[ii] <= c_buf[ii+1];
               c_buf[N_DEPTH-1] <= pmem_qz;
               c_adr <= c_adr + 'h1;
               adr_p <= pre_1_adr;
               r_twlb <= (pre_1_adr[BIT_ADDR-1:BIT_ADDR-2]==2'h2) ? 2'h3 : 2'h0;
            // 'b1000x
            end else if (m_psrd & ~(c_hit | p_conti | p_hit)) begin
               c_adr <= memaddr_c;
               c_ptr <= 'h0;
               adr_p <= memaddr_c;
               r_twlb <= (memaddr_c[BIT_ADDR-1:BIT_ADDR-2]==2'h2) ? 2'h3 : 2'h0;
            // 'b1+++0, '+++': 3-case 1-hot
            // 'b0...0, '...': 4-case 1-or-none
            end else if (~c_full) begin
               c_buf[c_ptr] <= pmem_qz;
               c_ptr <= c_ptr + 'h1;
               adr_p <= pre_1_adr;
               r_twlb <= (pre_1_adr[BIT_ADDR-1:BIT_ADDR-2]==2'h2) ? 2'h3 : 2'h0;
               if (p_full & c_hit) cs_ft <= ft_stby;
            // 'b0...1 // full w/o request, '...' 4-case 1-or-one
            // 'b10011 // full w/ hit
            end else if (~m_psrd | c_hit)
               cs_ft <= (cs_stby & (r_pwdn_en
                                  | r_hold
                                  | mcu_psw & hit_ps))
                        ? ft_pwdn
                        : ft_stby;
         end
      ft_sfak: begin
            cs_ft <= ft_idle;
            pgm_p <= 1'h0;
            re_p <= 1'h0;
            d_psrd <= 1'h0;
         end
      ft_pwdn: begin
            if (m_psrd & ~c_hit) cs_ft <= ft_dmmy;
            else if (~m_psrd & (r_hold
                              | mcu_psw & hit_ps)) cs_ft <= ft_idle;
            r_rdy <= m_psrd & c_hit;
            re_p <= m_psrd & ~c_hit;
         end
      endcase

   wire multi_pls = wspp_cnt<'h28 && wspp_cnt>='h08 ||
                    wspp_cnt<'h50 && wspp_cnt>='h30 ||
                    wspp_cnt<'h78 && wspp_cnt>='h58; // can1124a0eco1
   reg cs_n;
   reg [1:0] ck_n;
   always @(negedge clk)
      if (srst | pwrdn_rst) begin
               cs_n <= 1'h0;
               ck_n <= 2'h0;
      end else case (cs_ft)
      ft_psw0,
      ft_dmmy: cs_n <= 1'h1;
      ft_sfak,
      ft_pwdn: cs_n <= 1'h0;
      ft_psw1,
      ft_dmck,
      ft_rclk: ck_n <= 2'h0;
      ft_dmrw: ck_n <= 2'h3;
      ft_pswp,
//    ft_rwai: ck_n <= {a_sel_1,a_sel_0} & {2{~r_multi | multi_pls}}; // can1124a0eco1
      ft_rwai: ck_n <= {a_sel_1,a_sel_0} & {2{~r_multi | multi_pls | re_p}};
      endcase

   reg un_hold; // do not hold again (by bkpt) when the first fetch on exiting hold
   always @(posedge clk)
      if (srst) un_hold <= 'h0;
      else un_hold <= r_hold_mcu | (un_hold & ~r_rdy);

   wire   memps_rdy = ~cksrd & r_rdy;

   wire [BIT_DEPTH-1:0] popptr = memaddr - c_adr;
   assign o_inst = c_buf[popptr];
   assign d_inst = d_psrd ? rd_buf : 'hee; // to prevent SSE read from 'hxx
// assign o_set_hold = 1'h0; // don't wanna set r_hold_mcu
   assign o_set_hold = memaddr=='h0 && memps_rdy && (o_inst=='hff) // to set r_hold_mcu
                    || o_bkp_hold;
   assign o_bkp_hold = memaddr==bkpt_pc && memps_rdy && bkpt_ena && ~un_hold; // pre-state r_hold_mcu
   assign o_ofs_inc  = cs_sfak;
   assign sfr_psrack = d_psrd ? cs_sfak : sfr_psr;

   assign pmem_a = {adr_p[OTP_ADDR-3-1:INF_ADDR],a_bit[2:0],adr_p[INF_ADDR-1:0]};
   assign pmem_csb = ~cs_n;
   assign pmem_re = re_p;
   assign pmem_pgm = pgm_p;
   assign pmem_clk = ck_n;
   assign pmem_twlb = r_twlb;

   assign mempsack = mcu_psw ? cs_sfak : memps_rdy;
// assign mempsack = hit_ps ? mcu_psw ? cs_sfak : memps_rdy
//                          : ~srst; // include non-defined area

endmodule // ictlr

