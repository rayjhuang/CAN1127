
module srambist#(
parameter IRAM_SIZE = 'd1536, // non-DMA macro
parameter XRAM_SIZE = 'd0, // DMA-capble macro
parameter BIT_ADDR = 'd11 // max. of all macro
)(

input        		clk,
input        		srstz,
input   [1:0]		reg_hit,
input			reg_w, reg_r,
input   [7:0]		reg_wdat,     //Data write in to reg
input   [7:0]		iram_rdat, xram_rdat,
output       		bist_en,      //bist enable signal
output       		bist_xram,    //bist for XRAM
output       		bist_wr,      //bist wr to xram
output [BIT_ADDR-1:0]	bist_adr,
output	[7:0]		bist_wdat,    //write data
output	[6:0]		o_bistctl,    //bist_control
output	[7:0]		o_bistdat     //bist read/write data
);
// register interface
   wire [7:0] wdat = reg_wdat, // rename
              rdat = bist_xram ? xram_rdat : iram_rdat;
   wire [5:0] we = reg_hit & {6{reg_w}};
   reg bistctl_re;
   always @(posedge clk or negedge srstz)
      if (~srstz) bistctl_re <= 'h0;
             else bistctl_re <= reg_hit[0] & reg_r;

// memory BIST
  parameter  reada    = 2'h0,
	     writeb   = 2'h1,
             readb    = 2'h2;

  wire [6:0] r_bistctl;
  wire [7:0] r_bistdat, rd_datA, rd_datB;
  wire bist_rd;
  wire bist_fault;              //compare data
  wire bist_sel;                //0/1: (r,w)/(r,w,r)
  wire r_incdec = r_bistctl[1]; //0/1: inc adr/dec adr
  wire bist_go = we[0] & wdat[0] & (r_bistdat[7:6]=='h2) ; // fool-proof
  reg  r_bist_go;
  
  wire [BIT_ADDR-1:0] MEM_SIZE = bist_xram ? XRAM_SIZE : IRAM_SIZE;
  wire ps_selxram = 1'h0; // wdat[4];
  wire [BIT_ADDR-1:0] PRE_SIZE = ps_selxram ? XRAM_SIZE : IRAM_SIZE;
  reg [BIT_ADDR-1:0] adr;
  reg  [1:0] rw_sta; //read/write state
  wire cs_rda = rw_sta == reada;
  wire cs_wrb = rw_sta == writeb;
  wire cs_rdb = rw_sta == readb;
  wire stop   =  adr == (('d2**BIT_ADDR)-'h1) | adr == MEM_SIZE;
  wire busy   = ~stop ; 
  wire ps_incdec = we[0] ? wdat[1] : r_incdec;
  reg r_bistfault;
  reg busy_dly;
  always@(posedge clk)
    busy_dly <= busy;
 
  always@(posedge clk)begin //address  
      if(~srstz)adr <= ('d2**BIT_ADDR)-'h1; // not '0', due to stop condition
      else if(bist_go)  adr <= ps_incdec ?  PRE_SIZE -'h1 : 'h0;
      else if ( (~bist_sel) & cs_wrb 
               || bist_sel  & cs_rdb) adr <= ps_incdec ? adr-'h1 : adr+'h1;  
  end 
 
  always@(posedge clk)begin  //read or writestate
    if(~srstz) rw_sta  <= reada;
    else begin
        if(busy)
          case(rw_sta)
            reada : rw_sta <= writeb;
            writeb: rw_sta <= bist_sel ? readb : reada;
            readb : rw_sta <= reada;
          endcase
    end 
  end 

  always@(posedge clk)begin //check read data
    if(~srstz|bistctl_re) r_bistfault <='h0;
    else begin
      if(cs_wrb) r_bistfault <=  r_bistfault ? 'h1 : (rd_datA!= rdat) ? 'h1 :'h0;
      else if (cs_rda & bist_sel & busy_dly) r_bistfault <=  r_bistfault? 'h1 : (rd_datB!= rdat) ? 'h1 : 'h0; //(r,w,r) use busy_dly to  don't check data in first cs_rda
    end
  end
  
  wire upd_fault = r_bistfault | bistctl_re ;
  wire wd_fault  = bistctl_re ? 'h0 : r_bistfault ? 'h1 : r_bistfault;
  glreg #(1) u0_bistfault (clk, srstz, upd_fault, wd_fault, bist_fault);
  glreg #(5) u0_bistctl (clk, srstz, we[0], {wdat[6:4],wdat[2:1]}, {r_bistctl[6:4],r_bistctl[2:1]}); // BISTCTL
  glreg      u0_bistdat (clk, srstz, we[1], wdat, r_bistdat); // BISTDAT
  wire [1:0] Asel = r_bistdat[1:0];
  wire [1:0] Bsel = r_bistdat[3:2];
  wire [7:0] Adat = Asel=='h0 ? 'h00 : Asel=='h1 ? 'h55 : Asel=='h2 ? 'h33 : 'h0f;
  wire [7:0] Bdat = Bsel=='h0 ? 'h00 : Bsel=='h1 ? 'h55 : Bsel=='h2 ? 'h33 : 'h0f;
  wire [7:0] bist_dat_A = r_bistdat[4] ? ~Adat : Adat;
  wire [7:0] bist_dat_B = r_bistdat[5] ? ~Bdat : Bdat;
  assign rd_datA = bist_dat_A;
  assign rd_datB = bist_dat_B;
  assign bist_sel  = r_bistctl[2];   
  assign bist_xram = 1'h0;
  assign r_bistctl[3] = bist_fault;
  assign r_bistctl[0] = busy; //as dacmux.v
  assign o_bistdat = r_bistdat;
  assign o_bistctl = r_bistctl;
  assign bist_en   = busy;              //switch xram adr/dat to BIST
  assign bist_adr  = adr; // BIST adr to SRAM adr
  assign bist_wr   = cs_wrb & busy; // BIST write
  assign bist_wdat = bist_dat_B; // BIST write data to SRAM

endmodule // srambist

