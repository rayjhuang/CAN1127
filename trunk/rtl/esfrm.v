
module esfrm (
// =============================================================================
// external SFR master
// two masters can/shall not work together
// 2016/11/25 new created, Ray Huang, rayhuang@canyon-semi.com.tw
// 2018/01/19 function summary
//            1. primary bus (peripheral masters, i.e. I2CSLV/UPDPRL)
//            2. secondary bus
//               a) ESFRM (external SFR master, a master to MCU)
//               b) Page0 access
// ALL RIGHTS ARE RESERVED
// =============================================================================
input	[1:0]	i_rd,
		i_wr,
input	[7:0]	wdat0, wdat1,
		addr0, addr1,
// -----------------------------------------------------------------------------
output		esfrm_oe, esfrm_we, sfrack,
output	[7:0]	esfrm_wdat,
output	[6:0]	esfrm_adr,
input	[7:0]	mcu_esfrrdat,
		delay_rdat,
input		delay_rrdy,
output		esfrm_rrdy,
output	[7:0]	esfrm_rdat,
// -----------------------------------------------------------------------------
output		pg0_acc, pg0_wr, pg0_wait,
input	[7:0]	pg0_rdat,
input		memacc_c, ramacc,
		mclk, srstz
//output        pg0_wrintr,
//input [1:0]   r_i2c_attr,
);

   assign esfrm_wdat =         i_wr[1] ?wdat1 :wdat0;
   wire [7:0] muxadr = i_rd[1]|i_wr[1] ?addr1 :addr0;
   wire pg0_sel = muxadr[7]=='h0;
   wire esfrm_acc = |{i_rd,i_wr};
   assign esfrm_adr = muxadr[6:0];
   assign esfrm_oe = ~pg0_sel & (|i_rd),
          esfrm_we = ~pg0_sel & (|i_wr),
          sfrack = ~esfrm_acc;


   reg r_pg0_rdrdy, pg0_rdwait, pg0_wrwait, r_pg0_wait;

     wire pg0_rd  = pg0_sel & (|i_rd) | pg0_rdwait;
   assign pg0_wr  = pg0_sel & (|i_wr) | pg0_wrwait;
   assign pg0_acc = pg0_rd | pg0_wr;
//   assign pg0_wrintr = r_pg0_wrintr[muxadr];

   always @(posedge mclk or negedge srstz)
      if (~srstz) r_pg0_wait <= 'h0;
             else r_pg0_wait <= memacc_c & (pg0_acc|pg0_wrwait|pg0_rdwait);
   always @(posedge mclk or negedge srstz)
      if (~srstz) pg0_wrwait <= 'h0;
             else pg0_wrwait <= pg0_wr & ramacc;
   always @(posedge mclk or negedge srstz)
      if (~srstz) pg0_rdwait <= 'h0;
             else pg0_rdwait <= pg0_rdwait ?ramacc :pg0_rd & ramacc;
   always @(posedge mclk or negedge srstz)
      if (~srstz) r_pg0_rdrdy <= 'h0;
             else r_pg0_rdrdy <= pg0_rd &~ramacc;

   assign pg0_wait = r_pg0_wait;
   assign esfrm_rdat = r_pg0_rdrdy ?pg0_rdat :delay_rrdy ?delay_rdat :mcu_esfrrdat;
   assign esfrm_rrdy = esfrm_oe // SFR access returns immediately
		   | r_pg0_rdrdy // Page0 access may wait
		   | delay_rrdy; // the additional ictlr ACK for update the read buffer

endmodule // esfrm

