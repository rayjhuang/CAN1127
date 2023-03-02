
`ifdef GATE
// included by bench.v

//pulldown (`DUT.U0_CODE.VSS);
//pulldown (`DUT.U0_CODE.HV_VSS);
//pulldown (`DUT_ANA.CC1_DI);
//pulldown (`DUT_ANA.CC2_DI);
//pullup (`DUT_ANA.DN_COMP);

initial $sdf_annotate ("gate.sdf",`DUT);

// grep ordsbuf_reg_  gate.v
// grep txbuf_reg_    gate.v
// grep d_i2c_reg_0_  gate.v
// grep cc_buf_reg_0_ gate.v
// grep drstz_reg_0_  gate.v
reg [31:0] randini;
`define FF_SDN {`DUT_CORE.u0_updphy.u0_phyrx.ordsbuf_reg_0_.int_fwire_s, \
                `DUT_CORE.u0_updphy.u0_phyrx.ordsbuf_reg_1_.int_fwire_s, \
                `DUT_CORE.u0_updphy.u0_phyrx.ordsbuf_reg_2_.int_fwire_s, \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_0_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_1_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_2_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_3_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_4_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_5_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_6_.int_fwire_s,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_7_.int_fwire_s}
`define FF_CDN {`DUT_CORE.u0_updphy.u0_phyrx.ordsbuf_reg_0_.int_fwire_r, \
                `DUT_CORE.u0_updphy.u0_phyrx.ordsbuf_reg_1_.int_fwire_r, \
                `DUT_CORE.u0_updphy.u0_phyrx.ordsbuf_reg_2_.int_fwire_r, \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_0_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_1_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_2_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_3_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_4_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_5_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_6_.int_fwire_r,  \
                `DUT_CORE.u0_updphy.u0_updprl.txbuf_reg_7_.int_fwire_r}
`define FF_SET {`DUT_CORE.u0_updphy.u0_phycrc.i_start \
               }
initial begin // initial FF for not being unknown
	randini = $random;
	#(1000*100) force `FF_SDN =  randini; // I2C will read this in stm_sfr.v
                    force `FF_CDN = ~randini; // txbuf for ptx_cc reference
	            force `FF_SET=1;
	#(100)      release `FF_SDN;
                    release `FF_CDN;
                    release `FF_SET;
	#(1000*1000*12) // for stm_tm.v, txbuf for ptx_cc reference
	randini = $random;
	#(1000*100) force `FF_SDN =  randini;
                    force `FF_CDN = ~randini;
	#(100)      release `FF_SDN;
                    release `FF_CDN;
end

`define NS 1
`define MF_TASK0 \
   always @(`MF_CELL.Q) \
      if (`MF_CELL.Q!=='h0 && `MF_CELL.Q!=='h1 && (`MF_CELL.D==='h1 || `MF_CELL.D==='h0)) begin \
         $write ($time/`NS, "ns WARNING: <%m> %s got metastable, going to be ", `MF_MSG); \
         if ($random%2) begin \
            #(`NS*3) $display ("reset"); force `MF_CELL.int_fwire_r = 'h1; \
            #(`NS*3) release `MF_CELL.int_fwire_r; \
         end else begin \
            #(`NS*3) $display ("set");   force `MF_CELL.int_fwire_s = 'h1; \
            #(`NS*3) release `MF_CELL.int_fwire_s; \
         end \
         #0; $display ($time/`NS, "ns WARNING: <%m> %s force done", `MF_MSG); \
      end

`define MF_MSG "SCL"
`define MF_CELL `DUT_CORE.u0_i2cslv.db_scl.d_i2c_reg_0_
       `MF_TASK0 `undef MF_CELL
                 `undef MF_MSG
`define MF_MSG "SDA"
`define MF_CELL `DUT_CORE.u0_i2cslv.db_sda.d_i2c_reg_0_
       `MF_TASK0 `undef MF_CELL
                 `undef MF_MSG
`define MF_MSG "CC_BUF"
`define MF_CELL `DUT_CORE.u0_updphy.u0_phyrx.u0_phyrx_db.cc_buf_reg_0_
       `MF_TASK0 `undef MF_CELL
                 `undef MF_MSG
`define MF_MSG "drstz"
`define MF_CELL `DUT_CORE.u0_regbank.drstz_reg_0_
       `MF_TASK0 `undef MF_CELL
                 `undef MF_MSG

`endif // GATE

