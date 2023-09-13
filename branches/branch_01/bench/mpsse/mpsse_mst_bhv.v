//`timescale 1ns/1ns
//module mpsse_mst_bhv (
// *****************************************************************************
// project      MPSSE implementation
// description  multi-protocol synchronous serial engine
//              support SMB/SPI
// designer     RAY HUANG, ray@ene.com.tw
// created      2011/7/8
// revised
// All Rights Are Reserved
// -----------------------------------------------------------------------------
// output list
        CSB,
        SCK,
        SDO,
// input list
        SDI
);
output  CSB,
        SCK,
        SDO;
input   SDI;

// =============================================================================
// GLOBAL USAGE OPTIONS
// =============================================================================
reg     dev_en,         // connect control, can be changed only when bus idle
        no_data_err,    // data mismatch error don't finish
        inter_pkt_en,   // inter-packet delay
        smb_pec_en,     // SMB PEC mode
        sck_busy_en,    // slave drives SCK for wait state (open-drain mode)
        msg_en;         // enable detailed messages
initial begin: public_init
        dev_en          = 0;
        msg_en          = 0;
        no_data_err     = 0;
        inter_pkt_en    = 0;
        smb_pec_en      = 0;
        sck_busy_en     = 1;
end // public_init
reg     [15:0]
        rx_data;        // received data

// =============================================================================
// PRIVATE USAGE OPTIONS, use them carefully
// =============================================================================
reg     open_drain,     // open-drain mode enable
        cpolar,         // don't change this in #CS
        cphase,         // don't change this in #CS
        trans_io,       // to connect SDI and SDO
        sck_delay;      // to delay sck
integer Tsdo_min,       // ns, drive SDO after SCK
        Tsdo_max,
        Tcsb_min,       // ns, de-assert CSB after SCK
        Tcsb_max,
        Tcsh_min,       // ns, de-assert CSB and wait for a hold time
        Tcsh_max,
        Tsck_min,       // ns, drive SCK after asserting CSB
        Tsck_max,
        Tpkt_min,       // ns, inter-packet delay
        Tpkt_max,
        Tck_p,          // clock period
        Tck_d,          // clock duty
        Tck_j;          // clock jitter
parameter
        CRC8_POLY = 8'b111,
        CRC8_INIT = 8'b0;
initial begin: private_init
        sck_delay = 0;
end // private_init

// =============================================================================
// SERIAL ENGINE
// =============================================================================
reg     csb,
        sck,
        sdo,
        dly_sdo;
wire    [1:0]
        mode = {cpolar,cphase}; // setting mode will terminate CS#

initial #1_000 sdo = 1; // to prevent SDA (I2C) be unknown when enabling dev_en

assign  CSB = (dev_en) ? csb : 1'hz;
assign  SCK = (dev_en) ? (open_drain) ? (sck) ? 1'hz : 1'h0 : sck : 1'hz;
assign  SDO = (~(dly_sdo & open_drain) & dev_en) ? dly_sdo : 1'hz;

always @(dev_en or open_drain or sdo)
        #({$random}%(Tsdo_max-Tsdo_min+1)+Tsdo_min) dly_sdo = sdo;

wire    sdi = dev_en & (trans_io ? SDO : SDI);
// -----------------------------------------------------------------------------
event ev_sck_gen, ev_inter_pkt;
always @(negedge csb or ev_sck_gen) begin: sck_gen
   #({$random}%(Tsck_max-Tsck_min+1)+Tsck_min) sck = ~sck;
   fork
   forever begin
      if (sck) #({$random}%(2*Tck_j+1)-Tck_j+Tck_p*Tck_d/100);
      else     #({$random}%(2*Tck_j+1)-Tck_j+Tck_p*(100-Tck_d)/100);
      wait (~sck_delay) sck = ~sck;
      if (sck_busy_en)
         wait (sck===SCK);
   end
   forever @(ev_inter_pkt) if (inter_pkt_en) begin
      sck_delay = 1;
      #({$random}%(Tpkt_max-Tpkt_min+1)+Tpkt_min)
      sck_delay = 0;
   end
   join
end // sck_gen
always @(posedge csb or cpolar or cphase or dev_en) begin
   disable sck_gen;
// #({$random}%(Tsck_min/2)+1)
   sck = cpolar;
   sck_delay = 0;
   if (csb!==1) sdo = cphase;
   csb = 1;
end
// -----------------------------------------------------------------------------
task _set_mode;
input [1:0] mode;
begin
   {cpolar,cphase} = mode;
   #(Tsck_min*2); // wait for sck, csb being ready
end
endtask //_set _mode
// -----------------------------------------------------------------------------
reg [7:0] crc8_val;
wire crc8_rem = sdi ^ crc8_val[7];
event ev_sample, ev;
wire #1 rsck = SCK; // de-glitch
task _txrx;
input [3:0] cnt; // bit count, 0/1~15: 1/2~16 bit(s)
input [15:0] data;
reg [15:0] tmp;
begin
   tmp = data<<(15-cnt);
   #1 repeat (cnt+1) fork // delay needed in stretched SCL (gate-level)
   begin // tx
      if ( cphase & rsck==cpolar) @(rsck) #0;
      {sdo, tmp} = {tmp, 1'h0};
      if (~cphase) @(rsck);
      @(rsck);
   end
   begin // rx
      if (rsck==cpolar) @(rsck) #0;
      if ( cphase) @(rsck) #0;
      -> ev_sample;
      rx_data = rx_data<<1 | sdi;
      crc8_val = crc8_val<<1 ^ (CRC8_POLY&{8{crc8_rem}});
      if (~cphase) @(rsck);
   end
   join
   -> ev_inter_pkt;
end
endtask // _txrx
// -----------------------------------------------------------------------------
task _rx_chk;
input [3:0] nbit; // 0/1~: 1/2~
input [15:0] rx_data, exp_data;
input [31:0] adr; // [31:24]:print format, [23:8]:idx, [7:0]:address
integer idxi;
begin
//      if ((rx_data ^ exp_data) !== (exp_data ^ exp_data)) begin
        for (idxi=0; idxi<=nbit; idxi=idxi+1)
           if (exp_data[idxi]!==1'bx && exp_data[idxi]!==rx_data[idxi]) begin
                          $write ("\n",$time,"ns <%m> ERROR: data mismatch, exp:");
              if (nbit>7) $write ("%x, dat:%x", exp_data,      rx_data);
              else        $write ("%b, dat:%b", exp_data[7:0], rx_data[7:0]);
              if (adr[31:24]!='hff) begin
                          $write (", @%02x", adr[7:0]); if (adr[31:8])
	                  $write ("[%0d]=0x%02x", adr[23:8], adr[23:8]+adr[7:0]); end
                          $write ("\n");
                          $finish;
           end
end
endtask // _rx_chk
// -----------------------------------------------------------------------------
reg [7:0] rddat; // read data
reg Timer0Exp =1;
wire [1:0] intr; // this should be assigned by BENCH
wire [7:0] wait_sig = {5'h0,Timer0Exp,intr[1:0]};
// `include "mpsse_i2c_task.v"
// `include "mpsse_spi_task.v"
// *****************************************************************************
//endmodule // mpsse_mst_bhv

