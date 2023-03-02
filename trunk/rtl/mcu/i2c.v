
module i2c (
   clk,
   rst,
   bclksel,
// bclk,
   scli,
   sdai,
   sclo,
   sdao,
   intack,
   si,
   sfrwe,
   sfraddr,
   sfrdatai,
   i2cdat_o,
   i2cadr_o,
   i2ccon_o,
   i2csta_o
   );

   // Declarations
   `include "mcu51_param.v"

   //  Control signals inputs
   input    clk;                       // Global clock input
   input    rst;                       // Global reset input

   //  Timer 1 overflow input
// input    bclk;                      //
   input    bclksel;

   //  Serial inputs
   input    scli;                      // I2C clock input
   input    sdai;                      // I2C data input

   //  Special function register interface
   input    sfrwe;                     // data write enable
   input    [ 6: 0] sfraddr; // data address
   input    [ 7: 0] sfrdatai;// data input
 //  Interrupt acknowledge
   input    intack;                    //

   //  Serial outputs
   output   sclo;                      // I2C clock output // registered
   wire     sclo;
   output   sdao;                      // I2C data output  // registered
   wire     sdao;

   //  Interrupt flag
   output   si;                        // SI flag          // registered
   wire     si;

   //  Special function register interface
   output   [ 7: 0] i2cdat_o;
   wire     [ 7: 0] i2cdat_o;
   output   [ 7: 0] i2cadr_o;
   wire     [ 7: 0] i2cadr_o;
   output   [ 7: 0] i2ccon_o;
   wire     [ 7: 0] i2ccon_o;
   output   [ 7: 0] i2csta_o;
   wire     [ 7: 0] i2csta_o;

   //parameter DELLONGINX = LD(GLITCHREG+3);
   parameter DELLONGINX = 3;
   //parameter [DELLONGINX-1 :0] INFILTERDELAY = GLITCHREG+3;
   parameter [DELLONGINX-1 :0] INFILTERDELAY = 6;
   parameter COUNT1_FSMSYNC5 = (GLITCHREG+1) % 10;
   parameter COUNT2_FSMSYNC5 = (GLITCHREG+1) / 10;
   parameter COUNT1_FSMSYNC4 = (GLITCHREG+7) % 10;
   parameter COUNT2_FSMSYNC4 = (GLITCHREG+7) / 10;
   //parameter SETUP_COUNT_LENGTH = LD(SETUP_REG-1);
   parameter SETUP_COUNT_LENGTH = 3;

   //---------------------------------------------------------------
   // FSM registers and signals
   //---------------------------------------------------------------
   reg   [2:0] fsmmod;     // Master/slave mode detection FSM state
   reg   [2:0] fsmmod_nxt; // Master/slave mode detection FSM next state
   reg   [2:0] fsmsync;    // Clock synchronization FSM
   reg   [2:0] fsmsync_nxt;// Clock synchronization FSM next state
   reg   [2:0] fsmdet;     // stop/start detector FSM
   reg   [2:0] fsmdet_nxt; // stop/start detector FSM next state
   reg   [4:0] fsmsta;     // I2C status FSM
   reg   [4:0] fsmsta_nxt; // I2C status FSM next state

   //---------------------------------------------------------------
   // I2C serial channel special function registers
   //---------------------------------------------------------------
   reg   [7:0] i2ccon;     // i2ccon special function register
   reg   [7:0] i2cdat;     // i2cdat special function register
   reg   [7:0] i2cadr;     // i2cadr special function register
   reg   [4:0] i2csta;     // i2csta special function register

   //---------------------------------------------------------------
   // i2ccon bits
   //---------------------------------------------------------------
   wire  [2:0] cr210;      // cr2, cr1, cr0 bits
   wire  ens1;             // "enable serial 1" bit
   wire  sta;              // start bit
   wire  sto;              // stop bit
   wire  aa;               // acknowledge bit

   //---------------------------------------------------------------
   // serial data bit 7
   //---------------------------------------------------------------
   reg   bsd7;             // serial data bit 7
   reg   bsd7_tmp;         // serial data temporary bit 7

   //---------------------------------------------------------------
   // acknowledge bit
   //---------------------------------------------------------------
   reg   ack;              // acknowledge bit
   reg   ack_bit;          // acknowledge temporary bit

   //---------------------------------------------------------------
   // input filters
   //---------------------------------------------------------------
   reg   [GLITCHREG-1:0] sdai_ff_reg; // serial data input buffers
   reg   sdaint;           // serial data input - internal register
   reg   [GLITCHREG-1:0] scli_ff_reg; // serial clock input buffers
   reg   sclint;           // serial clock input - internal register

   //---------------------------------------------------------------
   // address comparator
   //---------------------------------------------------------------
   reg   adrcomp;          // address comparator output
   reg   adrcompen;        // address comparator enable

   //---------------------------------------------------------------
   // scl edge detector
   //---------------------------------------------------------------
   reg   nedetect;         // sclint negative edge det.
   reg   pedetect;         // sclint positive edge det.

   //---------------------------------------------------------------
   // clock generator signals
   //---------------------------------------------------------------
   reg   [3:0] clk_count1; // clock counter 1
   reg   clk_count1_ov;    // clk_count1 overflow
   reg   [3:0] clk_count2; // clock counter 2
   reg   clk_count2_ov;    // clk_count2 overflow
   reg   clkint;           // internal clk generator
   reg   clkint_ff;        // int. clk gen. flip-flop
   wire  clkint_p1;        // positive edge clkint det.
   wire  clkint_p2;        // negative edge clkint det.
   reg   rst_delay;        // delayed reset

   //---------------------------------------------------------------
   // clock counter reset
   //---------------------------------------------------------------
   wire  counter_rst;

   //---------------------------------------------------------------
   // frame synchronization counter
   //---------------------------------------------------------------
   reg   [3:0] framesync;

   //---------------------------------------------------------------
   // master mode indicator
   //---------------------------------------------------------------
   reg   mst;

   //---------------------------------------------------------------
   // input filter delay counter
   //---------------------------------------------------------------
   reg   [DELLONGINX-1:0] indelay;

   //---------------------------------------------------------------
   //---------------------------------------------------------------
   reg   busfree;          // I2C bus free detector
   reg   sdao_int;         // serial data output register
   reg   sclo_int;         // serial clock output register
   wire  si_int;           // interrupt flag output
   reg   sclscl;           // two cycles scl
   reg   starto_en;        // transmit START condiion enable
// reg   bclk_ff0;         // baud rate clock flip flop 0
// reg   bclk_ff;          // baud rate clock flip flop
   wire  bclke;            // baud rate clock edge detector

   reg   [SETUP_COUNT_LENGTH-1:0] setup_counter_r;  //
   reg                            write_data_r;     //
   reg                            wait_for_setup_r; //

   //-------------------------------------------------------------------
   // FF prevents metastability issues
   //-------------------------------------------------------------------
   reg   scli_ff;          // FF
   reg   sdai_ff;          // FF


//// ------------------------------------------------------------------
////


   //-------------------------------------------------------------------
   // FF prevents metastability issues
   //-------------------------------------------------------------------
   always @(posedge clk)
   begin: meta_scli_ff_proc
   if (rst == 1'b1)
      begin
      scli_ff <= 1'b1;
      end
   else
      begin
      scli_ff <= scli;
      end
   end

   always @(posedge clk)
   begin: meta_sdai_ff_proc
   if (rst == 1'b1)
      begin
      sdai_ff <= 1'b1;
      end
   else
      begin
      sdai_ff <= sdai;
      end
   end

   //------------------------------------------------------------------
   // Serial data output driver
   // Registered output
   //------------------------------------------------------------------
   assign sdao = sdao_int ;

   //------------------------------------------------------------------
   // Serial clock output driver
   // Registered output
   //------------------------------------------------------------------
   assign sclo = sclo_int & ~wait_for_setup_r;

   //------------------------------------------------------------------
   // Interrupt flag output
   // Registered output
   //------------------------------------------------------------------
   assign si = si_int ;

   //------------------------------------------------------------------
   // serial data output write
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : sdao_int_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sdao_int <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (
            (!ens1) ||                        // i2c disable
            (fsmmod == FSMMOD3) ||            // repeated START transmit
            (fsmmod == FSMMOD0 && !adrcomp)   // or -- n.a.slave
         )
         begin // arbit lost
         sdao_int <= 1'b1 ;
         end
      else if (
            (
               fsmmod == FSMMOD1 ||
               fsmmod == FSMMOD4 ||
               fsmmod == FSMMOD6
            ) ||   // START / STOP transmit
            (adrcomp && adrcompen)
         )
         begin
         sdao_int <= 1'b0 ;
         end
      else if (fsmsta == FSMSTA38)
         begin
         sdao_int <= 1'b1 ;
         end
      else if (
            (
               //-----------------------------------
               // data ack
               //-----------------------------------
               // master receiver
               //-----------------------------------
               fsmsta == FSMSTA40 || fsmsta == FSMSTA50 ||
               //-----------------------------------
               // slave receiver
               //-----------------------------------
               fsmsta == FSMSTA60 || fsmsta == FSMSTA68 ||
               fsmsta == FSMSTA80 || fsmsta == FSMSTA70 ||
               fsmsta == FSMSTA78 || fsmsta == FSMSTA90
            ) &&
            (framesync == 4'b0111 || framesync == 4'b1000)
         )
         begin
         if (framesync == 4'b0111 && nedetect)
            begin
            sdao_int <= ~ack_bit ; //i2cdat(7); -- data ACK
            end
         end
      else if (
            //-----------------------------------
            // transmit data
            //-----------------------------------
            // master transmitter
            //-----------------------------------
            fsmsta == FSMSTA08 || fsmsta == FSMSTA10 ||
            fsmsta == FSMSTA18 || fsmsta == FSMSTA20 ||
            fsmsta == FSMSTA28 || fsmsta == FSMSTA30 ||
            //-----------------------------------
            // slave transmitter
            //-----------------------------------
            fsmsta == FSMSTAA8 || fsmsta == FSMSTAB0 ||
            fsmsta == FSMSTAB8
         )
         begin
         if (framesync < 4'b1000 || framesync == 4'b1001)
            begin
            sdao_int <= bsd7 ;
            end
         else
            begin
            sdao_int <= 1'b1 ;
            end
         end
      else
         begin
         sdao_int <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // i2ccon bits
   //------------------------------------------------------------------
   assign cr210 = {i2ccon[7], i2ccon[1:0]} ;

   //------------------------------------------------------------------
   assign ens1 = i2ccon[6] ;

   //------------------------------------------------------------------
   assign sta = i2ccon[5] & (~sto);

   //------------------------------------------------------------------
   assign sto = i2ccon[4] ;

   //------------------------------------------------------------------
   assign si_int = i2ccon[3] ;

   //------------------------------------------------------------------
   assign aa = i2ccon[2] ;

   //------------------------------------------------------------------
   // i2ccon special function register
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : i2ccon_write_proc
   //------------------------------------------------------------------
   reg  set_si_v ;
   set_si_v = 1'b0 ;
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      i2ccon <= I2CCON_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // setting si flag
      //-----------------------------
      begin
      if ((ens1) &&

            (
               (
                  (fsmmod == FSMMOD1 || fsmmod == FSMMOD6) &&
                  (fsmdet == FSMDET3)
               ) ||               // transmitted START or Sr condition
               (
                  (framesync == 4'b1000 && pedetect) &&
                  (mst || adrcomp)// master operation, slave operation
                                 // or own addr received
               ) ||
               (
                  (framesync == 4'b0000 || framesync == 4'b1001) &&
                  (fsmdet == FSMDET3 || fsmdet == FSMDET5) &&
                            // received START or STOP
                  (adrcomp) // addressed slave switched to FSMSTAA0
               ) ||
               (
                  (framesync == 4'b0001 || framesync == 4'b0010 ||
                   framesync == 4'b0011 || framesync == 4'b0100 ||
                   framesync == 4'b0101 || framesync == 4'b0110 ||
                   framesync == 4'b0111 || framesync == 4'b1000) &&
                  (fsmdet == FSMDET3 || fsmdet == FSMDET5) &&
                                  // received START or STOP
                  (mst || adrcomp) // bus ERROR
               )
            )
         )
         begin
         set_si_v = 1'b1 ;
         end
      else
         begin
         set_si_v = 1'b0 ;
         end

      //-----------------------------
      // Special function register write
      //--------------------------------
      if (sfrwe && sfraddr == I2CCON_ID)
         begin
         i2ccon[7:5] <= sfrdatai[7:5] ;
         if (sfrdatai[4] == 1'b1)
           begin
           i2ccon[4]  <= sfrdatai[4] ;
           end
         i2ccon[2:0] <= sfrdatai[2:0] ;
         if (sfrdatai[3])
            begin
            if (set_si_v)
               begin
               i2ccon[3] <= 1'b1 ;
               end
            end
         else  // !sfrdatai[3] - clear interrupt request
            begin
            i2ccon[3] <= 1'b0 ;
            end
         end
      else
         //-----------------------------
         // setting si flag
         //-----------------------------
         begin
         if (set_si_v)
            begin
            i2ccon[3] <= 1'b1 ;
            end
         else if (intack)
            begin
            i2ccon[3] <= 1'b0 ;
            end
         //-----------------------------
         // clearing sto flag
         //-----------------------------
         if ((fsmmod == FSMMOD4 && clkint_p2) || // transmitted STOP
             (fsmdet == FSMDET5) ||             // received STOP
             (!mst && sto) ||                    // internal stop
             (!ens1))                          // ENS1 == 1'b0
            begin
            i2ccon[4] <= 1'b0 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // i2cdat special function register
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : i2cdat_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      i2cdat   <= I2CDAT_RV ;
      ack      <= 1'b1 ;
      ack_bit  <= 1'b1 ;
      bsd7     <= 1'b1 ;
      bsd7_tmp <= 1'b1 ;
      write_data_r <= 1'b0;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!ens1)
         begin
         if (sfrwe && sfraddr == I2CDAT_ID)      // load data byte
            begin
            i2cdat <= sfrdatai ;
            write_data_r <= 1'b1;
            end
         else
            write_data_r <= 1'b0;
         end
      else // enable i2c
         begin
         if (fsmdet == FSMDET3)  // START
            begin
            if (sfrwe && sfraddr == I2CDAT_ID)   // load data byte
               begin
               i2cdat <= sfrdatai ;
               write_data_r <= 1'b1;
               end
            else
              write_data_r <= 1'b0;
            bsd7 <= 1'b0 ;
            bsd7_tmp <= 1'b0 ;

            end
         else if (
               //-----------------------------------
               // master transmitter
               //-----------------------------------
               fsmsta == FSMSTA08 || fsmsta == FSMSTA10 ||
               fsmsta == FSMSTA18 || fsmsta == FSMSTA20 ||
               fsmsta == FSMSTA28 || fsmsta == FSMSTA30 ||
               //-----------------------------------
               // slave transmitter
               //-----------------------------------
               fsmsta == FSMSTAA8 || fsmsta == FSMSTAB0 ||
               fsmsta == FSMSTAB8
            )
            begin
            if (si_int) // interrupt process
               begin
               ack <= 1'b1 ; // high Z on i2c bus after transmitted byte

               //--------------------------------
               // Special function register write
               //--------------------------------
               if (sfrwe && sfraddr == I2CDAT_ID)   // load data byte
                  begin
                  i2cdat <= sfrdatai ;
                  write_data_r <= 1'b1;
                  bsd7_tmp <= sfrdatai[7] ;
                  end
               else
                  begin
                  if (!sclint)
                     begin
                     bsd7 <= bsd7_tmp ;
                     end
                  else
                     begin
                     bsd7 <= 1'b1 ;
                     end
                  write_data_r <= 1'b0;
                  end
               end
            else    // transmit data byte
               begin
               if (sfrwe && sfraddr == I2CDAT_ID)   // load data byte
                  begin
                  i2cdat <= sfrdatai ;
                  write_data_r <= 1'b1;
                  bsd7 <= sfrdatai[7] ;
                  end
               else
                  begin
                  if (pedetect)
                     begin
                     i2cdat <= {i2cdat[6:0], ack} ;
                     ack <= sdaint ;
                     end
                  else if (nedetect)
                     begin
                     bsd7 <= i2cdat[7] ;
                     bsd7_tmp <= 1'b1 ;
                     end
                  write_data_r <= 1'b0;
                  end
               end
            end
         else if (
               //-----------------------------------
               // master receiver
               //-----------------------------------
               fsmsta == FSMSTA40 || fsmsta == FSMSTA50 ||
               //-----------------------------------
               // slave receiver
               //-----------------------------------
               fsmsta == FSMSTA60 || fsmsta == FSMSTA68 ||
               fsmsta == FSMSTA80 || fsmsta == FSMSTA70 ||
               fsmsta == FSMSTA78 || fsmsta == FSMSTA90
            )
            begin
            if (si_int) // intrrupt process
               begin
               if (sfrwe && sfraddr == I2CCON_ID)
                  begin
                  ack_bit <= sfrdatai[2] ; //aa
                  end
               else if (sfrwe && sfraddr == I2CDAT_ID)   // load data byte
                  begin
                  i2cdat <= sfrdatai ;
                  write_data_r <= 1'b1;
                  end
               else
                  write_data_r <= 1'b0;
               end
            else        // receiving data byte
               begin
               if (sfrwe && sfraddr == I2CDAT_ID)   // load data byte
                  begin
                  i2cdat <= sfrdatai ;
                  write_data_r <= 1'b1;
                  end
               else 
                 begin
                 if (pedetect)
                    begin
                    i2cdat <= {i2cdat[6:0], ack} ;
                    ack <= sdaint ;
                    end
                 write_data_r <= 1'b0;
                 end
               end

            bsd7 <= 1'b1 ;

            end
         else           // not addressed slave
            begin
            if (sfrwe && sfraddr == I2CDAT_ID)      // load data byte
               begin
               i2cdat <= sfrdatai ;
               write_data_r <= 1'b1;
               end
            else 
               begin
               if (pedetect)
                  begin
                  i2cdat <= {i2cdat[6:0], ack} ;
                  ack <= sdaint ;
                  end
               write_data_r <= 1'b0;
               end
            bsd7 <= 1'b1 ;
            end
         end
      end
   end

   //--------------------------------------------------------------
   // data setup time process
   //--------------------------------------------------------------
   always @(posedge clk)
   begin : data_setup_time_proc
   //--------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      setup_counter_r <= {SETUP_COUNT_LENGTH{1'b0}};
      wait_for_setup_r <= 1'b0;
      end
   else
      //-----------------------------------
      // wait for setup time
      //-----------------------------------
      begin
      if (write_data_r && !sclint)
         begin
         setup_counter_r <= {1'h0,SETUP_REG}-1'h1;
         wait_for_setup_r <= 1'b1;
         end
      else
         begin
         if (setup_counter_r != {SETUP_COUNT_LENGTH{1'b0}})
            begin
            setup_counter_r <= setup_counter_r - 1'b1;
            wait_for_setup_r <= 1'b1;
            end
         else
            begin
            wait_for_setup_r <= 1'b0;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // i2cadr special function register
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : i2cadr_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      i2cadr <= I2CADR_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe && sfraddr == I2CADR_ID)
         begin
         i2cadr <= sfrdatai ;
         end
      end
   end

   //------------------------------------------------------------------
   // i2csta special function register
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : i2csta_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      i2csta[4:0] <= I2CSTA_RV[7:3] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register read-only
      //--------------------------------
      begin
      if (si_int)
         begin
         case (fsmsta)
         FSMSTA08 :
            begin
            i2csta <= 5'b00001 ; //08H -- start has been trx/rcv
            end
         FSMSTA10 :
            begin
            i2csta <= 5'b00010 ; //10H  -- repeated start has been trx/rcv
            end
         FSMSTA18 :
            begin
            i2csta <= 5'b00011 ;
            end
         FSMSTA20 :
            begin
            i2csta <= 5'b00100 ;
            end
         FSMSTA28 :
            begin
            i2csta <= 5'b00101 ;
            end
         FSMSTA30 :
            begin
            i2csta <= 5'b00110 ;
            end
         FSMSTA38 :
            begin
            i2csta <= 5'b00111 ;
            end
         FSMSTA40 :
            begin
            i2csta <= 5'b01000 ;
            end
         FSMSTA48 :
            begin
            i2csta <= 5'b01001 ;
            end
         FSMSTA50 :
            begin
            i2csta <= 5'b01010 ;
            end
         FSMSTA58 :
            begin
            i2csta <= 5'b01011 ;
            end
         FSMSTA60 :
            begin
            i2csta <= 5'b01100 ;
            end
         FSMSTA68 :
            begin
            i2csta <= 5'b01101 ;
            end
         FSMSTA70 :
            begin
            i2csta <= 5'b01110 ;
            end
         FSMSTA78 :
            begin
            i2csta <= 5'b01111 ;
            end
         FSMSTA80 :
            begin
            i2csta <= 5'b10000 ;
            end
         FSMSTA88 :
            begin
            i2csta <= 5'b10001 ;
            end
         FSMSTA90 :
            begin
            i2csta <= 5'b10010 ;
            end
         FSMSTA98 :
            begin
            i2csta <= 5'b10011 ;
            end
         FSMSTAA0 :
            begin
            i2csta <= 5'b10100 ;
            end
         FSMSTAA8 :
            begin
            i2csta <= 5'b10101 ;
            end
         FSMSTAB0 :
            begin
            i2csta <= 5'b10110 ;
            end
         FSMSTAB8 :
            begin
            i2csta <= 5'b10111 ;
            end
         FSMSTAC0 :
            begin
            i2csta <= 5'b11000 ;
            end
         FSMSTAC8 :
            begin
            i2csta <= 5'b11001 ;
            end
         default : //FSMSTA00 :
            begin
            i2csta <= 5'b00000 ;
            end
         // FSMSTAF8 not included
         // (interrupt is not generated initial this state)
         endcase
         end
      else
         begin
         i2csta <= 5'b11111 ;
         end
      end
   end

   //------------------------------------------------------------------
   // scl input filter
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : sclint_filter_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      scli_ff_reg <= {GLITCHREG{1'b1}};
      end
   else
      begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
         // i2c enable
         scli_ff_reg <= {scli_ff_reg[GLITCHREG-2:0], scli_ff};
      end
   end

   //------------------------------------------------------------------
   // scl write
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : sclint_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sclint   <= 1'b1 ;
      nedetect <= 1'b0 ; // negative edge of scli
      pedetect <= 1'b0 ; // positive edge of scli
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (|scli_ff_reg == 1'b0 || wait_for_setup_r)
         begin
         sclint <= 1'b0 ;
         if (sclint)
            begin
            nedetect <= 1'b1 ;
            end
         else
            begin
            nedetect <= 1'b0 ;
            end
         end
      else if (&scli_ff_reg == 1'b1)
         begin
         sclint <= 1'b1 ;
         if (!sclint)
            begin
            pedetect <= 1'b1 ;
            end
         else
            begin
            pedetect <= 1'b0 ;
            end
         end
      else
         begin
         pedetect <= 1'b0 ;
         nedetect <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   // sda input filter
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : sdai_ff_reg_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sdai_ff_reg <= {GLITCHREG{1'b1}};
      end
    else
      begin
      //-----------------------------------
      //     Synchronous write
      //-----------------------------------
        // i2c enable
        sdai_ff_reg <= {sdai_ff_reg[GLITCHREG-2:0], sdai_ff};
      end
    end

  //------------------------------------------------------------------
  always @(posedge clk)
    begin : sdaint_write_proc
    if (rst)
      begin
      sdaint <= 1'b1 ;
      end
    else
      begin
      //-----------------------------------
      //     Synchronous reset
      //-----------------------------------
      if (|sdai_ff_reg == 1'b0)
        begin
        sdaint <= 1'b0 ;
        end
      else if (&sdai_ff_reg == 1'b1)
         begin
         sdaint <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // address comparator enable
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : adrcompen_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      adrcompen <= 1'b0 ; // address comparator enable
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!mst && sto)   // intstop /internal stop condition/
         begin
          adrcompen <= 1'b0 ;
         end
      else
         //----------------------------------
         // adrcompen write
         //----------------------------------
         begin
         if (fsmdet == FSMDET3)  // START condition detected
            begin
            adrcompen <= 1'b1 ;
            end
         else if (framesync == 4'b1000 && nedetect)
            begin
            adrcompen <= 1'b0 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // address comparator
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : adrcomp_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      adrcomp   <= 1'b0 ; // address comparator output
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!mst && sto)   // intstop /internal stop condition/
         begin
         adrcomp <= 1'b0 ;
         end
      else
         begin
         //----------------------------------
         // adrcomp write
         //----------------------------------
         if (
               (fsmdet == FSMDET3 || fsmdet == FSMDET5) || //START or STOP
               (
                  (fsmsta == FSMSTA88 || fsmsta == FSMSTA98 ||
                   fsmsta == FSMSTAC8 || fsmsta == FSMSTAC0 ||
                   fsmsta == FSMSTA38 || fsmsta == FSMSTAA0 ||
                   fsmsta == FSMSTA00
                  ) &&
                  (si_int)    // switched to n.a.slave
               )
            )
            begin
            adrcomp <= 1'b0 ;
            end
          else if (
               (adrcompen &&
                framesync == 4'b0111 &&
                nedetect &&
                aa) &&
               (~(i2cdat[6:0] == 7'b0000000 && ack)) &&//read from adr=00h
               (
                  (i2cdat[6:0] == i2cadr[7:1]) ||   // own address
                  (
                     i2cdat[6:0] == 7'b0000000 &&
                     (i2cadr[0])             // GC address (only write)
                  )
               ) &&
               (!mst || fsmsta == FSMSTA38)
            )
            begin
            adrcomp <= 1'b1 ;
            end
          end
      end
   end

   //------------------------------------------------------------------
   // input filter delay
   // count 4*fosc after each positive edge scl
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : indelay_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      indelay <= {DELLONGINX{1'b0}};
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmsync == FSMSYNC3)
         begin
         if (~(indelay == INFILTERDELAY))
            begin
            indelay <= indelay + 1'b1 ;
            end
         end
      else
         begin
         indelay <= {DELLONGINX{1'b0}};
         end
      end
   end

   //------------------------------------------------------------------
   // frame synchronization counter
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : framesync_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      framesync <= 4'b1111 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmdet == FSMDET3)     // START condition
         begin
         framesync <= 4'b1111 ;
         end
      else if (
            (fsmdet == FSMDET5) ||   // STOP condition
            (si_int && !sclint)
         )
         begin // interrupt process
         framesync <= 4'b1001 ;
         end
      else if (framesync == 4'b1001)
         begin
         if (fsmsta == FSMSTAA0 || fsmsta == FSMSTA88 ||
             fsmsta == FSMSTAC8 || fsmsta == FSMSTA98 ||
             fsmsta == FSMSTAC0)
            begin
            framesync <= 4'b0000 ;
            end
         else
            begin
            if (
                  (!si_int) &&
                  (!sto) &&
                  (!sta || fsmsta == FSMSTA08 || fsmsta == FSMSTA10)
               )
               begin
               framesync <= 4'b0000 ;
               end
            else     // START / repeated START / STOP
               begin
               framesync <= 4'b1001 ;
               end
            end
         end
      else if (nedetect)
         begin
         if (framesync == 4'b1000)
            begin
            if (
                  (!si_int) &&
                  (!sto) &&
                  (!sta || fsmsta == FSMSTA08 || fsmsta == FSMSTA10)
               )
               begin
               framesync <= 4'b0000 ;
               end
            else     // START / repeated START / STOP
               begin
               framesync <= 4'b1001 ;
               end
            end
         else
            begin
            framesync <= framesync + 1'b1 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // reset counters signal
   //------------------------------------------------------------------
   assign counter_rst =
      (
         (fsmsync == FSMSYNC1 ||
          fsmsync == FSMSYNC4 ||
          fsmsync == FSMSYNC5) || // scl synchronization
         (!mst && sto) ||          // internal stop
         (fsmdet == FSMDET5) ||
         (fsmmod == FSMMOD4 &&
          !sclint &&
          sclo_int) ||            // transmit START condition
         (busfree &&
          !sclint &&              // impossible (?)
          ~(fsmmod == FSMMOD5))
      ) ? 1'b1 : 1'b0 ;

   //------------------------------------------------------------------
   // bclk edge detector
   //------------------------------------------------------------------
// always @(posedge clk)
// begin : bclk_ff_proc
   //------------------------------------------------------------------
// if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
//    begin
//    bclk_ff0 <= 1'b1 ;
//    bclk_ff  <= 1'b1 ;
//    end
// else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
//    begin
//    bclk_ff0 <= bclk ;
//    bclk_ff  <= bclk_ff0 ;
//    end
// end

   //------------------------------------------------------------------
   // bclk edge detector
   //------------------------------------------------------------------
// assign bclke = bclk_ff0 & ~bclk_ff ; // rising edge
   reg [1:0] bclkcnt;
   assign bclke = bclkcnt==(bclksel ?'h2 :'h3);
   always @(posedge clk)
      bclkcnt <= (rst|bclke) ?'h0 :bclkcnt+'h1;

   //------------------------------------------------------------------
   // clock counter
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : clk_counter1_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      clk_count1    <= 4'b0000 ;
      clk_count1_ov <= 1'b0 ;
      rst_delay     <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      rst_delay     <= 1'b0 ;
      if (rst_delay == 1'b0)
        begin
        if (counter_rst)           // scl synchronization
           begin
           if (fsmsync == FSMSYNC5)
             begin
             clk_count1    <= COUNT1_FSMSYNC5 ;
             end
           else if (fsmsync == FSMSYNC4)
             begin
             clk_count1    <= COUNT1_FSMSYNC4 ;
             end
           else
             begin
             clk_count1 <= 4'b0000 ; // counter reset
             end
           clk_count1_ov <= 1'b0 ;
           end
        else                       // normal operation
           begin
           case (cr210)
           3'b000 :                                     // 1/256
              begin
              if (clk_count1 < 4'b1111)                 // 1/16
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           3'b001 :                                     // 1/224
              begin
              if (clk_count1 < 4'b1101)                 // 1/14
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           3'b010 :                                     // 1/192
              begin
              if (clk_count1 < 4'b1011)                 // 1/12
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           3'b011 :                                     // 1/160
              begin
              if (clk_count1 < 4'b1001)                 // 1/10
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           3'b100 :                                     // 1/960
              begin
              if (clk_count1 < 4'b1110)                 // 1/15
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           3'b101 :                                     // 1/120
              begin
              if (clk_count1 < 4'b1110)                 // 1/15
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           3'b110 :                                     // 1/60
              begin
              if (clk_count1 < 4'b1110)                 // 1/15
                 begin
                 clk_count1 <= clk_count1 + 1'b1 ;
                 clk_count1_ov <= 1'b0 ;
                 end
              else
                 begin
                 clk_count1 <= 4'b0000 ;
                 clk_count1_ov <= 1'b1 ;
                 end
              end
           default :                  // 1/8 -- baud rate clock
              begin
              if (bclke)                                // 1/2
                 begin
                 if (clk_count1 < 4'b0001)
                    begin
                    clk_count1 <= clk_count1 + 1'b1 ;
                    clk_count1_ov <= 1'b0 ;
                    end
                 else
                    begin
                    clk_count1 <= 4'b0000 ;
                    clk_count1_ov <= 1'b1 ;
                    end
                 end
              else
                 begin
                 clk_count1_ov <= 1'b0 ;
                 end
              end
           endcase
           end
        end
      end
   end

   //------------------------------------------------------------------
   // clock counter
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : clk_count2_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      clk_count2 <= 4'b0000 ;
      clk_count2_ov <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (counter_rst)     // scl synchronization
         begin
         if (fsmsync == FSMSYNC5)
           begin
           clk_count2    <= COUNT2_FSMSYNC5 ;
           end
         else if (fsmsync == FSMSYNC4)
           begin
           clk_count2    <= COUNT2_FSMSYNC4 ;
           end
         else
           begin
         clk_count2 <= 4'b0000 ; // counter reset
           end
         clk_count2_ov <= 1'b0 ;
         end
      else                 // normal operation
         begin
         if (clk_count1_ov)
            begin
            clk_count2 <= clk_count2 + 1'b1 ;
            case (cr210)
            3'b101 :       // 1/2
               begin
               if (clk_count2[0])
                  begin
                  clk_count2_ov <= 1'b1 ;
                  end
               else
                  begin
                  clk_count2_ov <= 1'b0 ;
                  end
               end
            3'b000,
            3'b001,
            3'b010,
            3'b011 :       // 1/4
               begin
               if (clk_count2[1:0] == 2'b11)
                  begin
                  clk_count2_ov <= 1'b1 ;
                  end
               else
                  begin
                  clk_count2_ov <= 1'b0 ;
                  end
               end
            3'b100 :       // 1/16
               begin
               if (clk_count2 == 4'b1111)
                  begin
                  clk_count2_ov <= 1'b1 ;
                  end
               else
                  begin
                  clk_count2_ov <= 1'b0 ;
                  end
               end
            default :
               begin
               clk_count2_ov <= 1'b1 ;
               end
            endcase
            end
         else
            begin
            clk_count2_ov <= 1'b0 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   // internal clock generator
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : clkint_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      clkint <= 1'b1 ;
      clkint_ff <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (counter_rst)  // scl synchronization
         begin
         clkint <= 1'b1 ;
         clkint_ff <= 1'b1 ;
         end
      else              // normal operation
         begin
         if (clk_count2_ov)
            begin
            clkint <= ~clkint ;
            end
         clkint_ff <= clkint ;
         end
      end
   end

   //------------------------------------------------------------------
   // internal clock generator clkint_p1
   //------------------------------------------------------------------
   assign clkint_p1 = (~clkint_ff) & clkint ; // positive edge

   //------------------------------------------------------------------
   // internal clock generator clkint_p2
   //------------------------------------------------------------------
   assign clkint_p2 = clkint_ff & (~clkint) ; // negative edge

   //------------------------------------------------------------------
   // scl synchronization
   //------------------------------------------------------------------
   always @(fsmsync or sclint or clkint_p1 or indelay or si_int or
      sdaint or sto or framesync or fsmmod)
   begin : fsmsync_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Combinational value
   //-----------------------------
   case (fsmsync)
   //-----------------------------
   FSMSYNC0 :
   //-----------------------------
      begin
      if (!sclint)
         begin
         fsmsync_nxt = FSMSYNC1 ;
         end
      else
         begin
         if (clkint_p1 &&
            ~(fsmmod == FSMMOD3 || fsmmod == FSMMOD4))
            begin
            fsmsync_nxt = FSMSYNC2 ;
            end
         else
            begin
            fsmsync_nxt = FSMSYNC0 ;
            end
         end
      end

   //-----------------------------
   FSMSYNC1 :
   //-----------------------------
      begin
      fsmsync_nxt = FSMSYNC2 ;
      end

   //-----------------------------
   FSMSYNC2 :
   //-----------------------------
      begin
      if (clkint_p1)
         begin
         if (si_int)
            begin
            fsmsync_nxt = FSMSYNC5 ;
            end
         else
            begin
            if (sto && framesync == 4'b1001)
               begin
               fsmsync_nxt = FSMSYNC6 ;
               end
            else
               begin
               fsmsync_nxt = FSMSYNC3 ;
               end
            end
         end
      else
         begin
         fsmsync_nxt = FSMSYNC2 ;
         end
      end

   //-----------------------------
   FSMSYNC3 :
   //-----------------------------
      begin
      if (indelay == INFILTERDELAY)
         begin
         if (sclint)
            begin
            fsmsync_nxt = FSMSYNC0 ;
            end
         else
            begin
            fsmsync_nxt = FSMSYNC4 ;
            end
         end
      else
         begin
         fsmsync_nxt = FSMSYNC3 ;
         end
      end

   //-----------------------------
   FSMSYNC4 :
   //-----------------------------
      begin
      if (sclint)
         begin
         fsmsync_nxt = FSMSYNC0 ;
         end
      else
         begin
         fsmsync_nxt = FSMSYNC4 ;
         end
      end

   //-----------------------------
   FSMSYNC5 :
   //-----------------------------
      begin
      if (!si_int)
         begin
         if (sto)
            begin
            fsmsync_nxt = FSMSYNC6 ;
            end
         else
            begin
            fsmsync_nxt = FSMSYNC3 ;
            end
         end
      else
         begin
         fsmsync_nxt = FSMSYNC5 ;
         end
      end

   //-----------------------------
   FSMSYNC6 :
   //-----------------------------
      begin
      if (!sdaint)
         begin
         fsmsync_nxt = FSMSYNC7 ;
         end
      else
         begin
         fsmsync_nxt = FSMSYNC6 ;
         end
      end

   //-----------------------------
   default :      // when FSMSYNC7
   //-----------------------------
      begin
      fsmsync_nxt = FSMSYNC7 ;
      end
   endcase
   end

   //------------------------------------------------------------------
   // Registered sclo output
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : fsmsync_sync_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmsync <= FSMSYNC0 ;
      sclo_int <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmmod == FSMMOD0)  // slave mode
         begin
         fsmsync <= FSMSYNC0 ;
         end
      else
         begin
         fsmsync <= fsmsync_nxt ;
         end

      if (
            (ens1) &&
              // i2c enable
            (
               //-------------------------------------
               // master clock generator
               //-------------------------------------
               (fsmsync == FSMSYNC1 || fsmsync == FSMSYNC2 ||
                fsmsync == FSMSYNC5 || fsmsync == FSMSYNC6) ||
               //-------------------------------------
               // slave stretch when interrupt process
               //-------------------------------------
               (
                  ( // slave transmitter
                   fsmsta == FSMSTAA8 || fsmsta == FSMSTAB0 ||
                   fsmsta == FSMSTAC0 || fsmsta == FSMSTAC8 ||
                   fsmsta == FSMSTAB8 ||
                   // slave receiver
                   fsmsta == FSMSTA60 || fsmsta == FSMSTA68 ||
                   fsmsta == FSMSTA80 || fsmsta == FSMSTA88 ||
                   fsmsta == FSMSTA70 || fsmsta == FSMSTA78 ||
                   fsmsta == FSMSTA90 || fsmsta == FSMSTA98 ||
                   fsmsta == FSMSTAA0) &&
                  (!sclint) &&
                  (si_int)
               )
            )
         )
         begin
         sclo_int <= 1'b0 ;
         end
      else
         begin
         sclo_int <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // I2C status FSM
   //------------------------------------------------------------------
   always @(fsmsta or pedetect or ack or sdaint or sdao_int or
      framesync or aa or adrcomp or adrcompen or i2cdat or i2cadr)
   begin : fsmsta_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Combinational value
   //-----------------------------
   case (fsmsta)

   //==========================================--
   // MASTER TRANSMITTER
   //==========================================--

   //-----------------------------
   FSMSTA08 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (!ack)                  // R/nW='0' --master transmitter
            begin
            if (sdaint)             // not ACK
               begin
               fsmsta_nxt = FSMSTA20 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA18 ;
               end
            end
         else                       // R/nW='1'  --master receiver
            begin
            if (sdaint)             // not ACK
               begin
               fsmsta_nxt = FSMSTA48 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA40 ;
               end
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA08 ;
            end
         end
      end

   //-----------------------------
   FSMSTA10 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (!ack)                  // R/nW='0' --master transmitter
            begin
            if (sdaint)             // not ACK
               begin
               fsmsta_nxt = FSMSTA20 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA18 ;
               end
            end
         else                       // R/nW='1' --master receiver
            begin
            if (sdaint)             // not ACK
               begin
               fsmsta_nxt = FSMSTA48 ;
               end
            else                    // ACK
               begin
               fsmsta_nxt = FSMSTA40 ;
               end
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA10 ;
            end
         end
      end

   //-----------------------------
   FSMSTA18 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA18 ;
            end
         end
      end

   //-----------------------------
   FSMSTA20 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   //arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA20 ;
            end
         end
      end

   //-----------------------------
   FSMSTA28 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      end

   //-----------------------------
   FSMSTA30 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         else                       // ACK
            begin
            fsmsta_nxt = FSMSTA28 ;
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTA30 ;
            end
         end
      end

   //-----------------------------
   FSMSTA38 :
   //----------------------------
      begin
      if (adrcomp && adrcompen &&
         framesync == 4'b1000)      // ACK receiving
         begin
         if (ack)                   // SLA+R
            begin
            fsmsta_nxt = FSMSTAB0 ;
            end
         else                       // SLA+W
            begin
            if (i2cdat[6:0] == 7'b0000000 &&  // GC Address
               (i2cadr[0]))
               begin
               fsmsta_nxt = FSMSTA78 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTA68 ;
               end
            end
         end
      else
         begin
         fsmsta_nxt = FSMSTA38 ;
         end
      end

   //==========================================--
   // MASTER RECEIVER
   //==========================================--

   //-----------------------------
   FSMSTA40 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (sdao_int &&
            !sdaint &&
            pedetect)
            begin                   // arbitration lost in not ACK
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            if (!sdao_int)          // ACK transmitting
               begin
               fsmsta_nxt = FSMSTA50 ;
               end
            else                    // not ACK transmitting
               begin
               fsmsta_nxt = FSMSTA58 ;
               end
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA40 ;
         end
      end

   //-----------------------------
   FSMSTA48 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA48 ;
      end

   //-----------------------------
   FSMSTA50 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost in not ACK
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            if (!sdao_int)          // ACK transmitting
               begin
               fsmsta_nxt = FSMSTA50 ;
               end
            else                    // not ACK transmitting
               begin
               fsmsta_nxt = FSMSTA58 ;
               end
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA50 ;
         end
      end

   //-----------------------------
   FSMSTA58 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA58 ;
      end

   //==========================================--
   // SLAVE RECEIVER
   //==========================================--

   //-----------------------------
   FSMSTA60 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!sdao_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA80 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA88 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA60 ;
         end
      end

   //-----------------------------
   FSMSTA68 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!sdao_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA80 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA88 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA68 ;
         end
      end

   //-----------------------------
   FSMSTA80 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!sdao_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA80 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA88 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA80 ;
         end
      end

   //-----------------------------
   FSMSTA88 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA88 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTA70 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!sdao_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA90 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA98 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA70 ;
         end
      end

   //-----------------------------
   FSMSTA78 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!sdao_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA90 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA98 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA78 ;
         end
      end

   //-----------------------------
   FSMSTA90 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK transmitting
         begin
         if (!sdao_int)             // ACK transmitting
            begin
            fsmsta_nxt = FSMSTA90 ;
            end
         else                       // not ACK transmitting
            begin
            fsmsta_nxt = FSMSTA98 ;
            end
         end
      else                          // receiving data
         begin
         fsmsta_nxt = FSMSTA90 ;
         end
      end

   //-----------------------------
   FSMSTA98 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA98 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTAA0 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAA0 ;      // go to n.a. slv
      end

   //==========================================--
   // SLAVE TRANSMITTER
   //==========================================--

   //-----------------------------
   FSMSTAA8 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTAC0 ;
            end
         else                       // ACK
            begin
            if (!aa)                // transmit last data
               begin
               fsmsta_nxt = FSMSTAC8 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTAB8 ;
               end
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTAA8 ;
            end
         end
      end

   //-----------------------------
   FSMSTAB0 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTAC0 ;
            end
         else                       // ACK
            begin
            if (!aa)                // transmit last data
               begin
               fsmsta_nxt = FSMSTAC8 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTAB8 ;
               end
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   // arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTAB0 ;
            end
         end
      end

   //-----------------------------
   FSMSTAB8 :
   //-----------------------------
      begin
      if (framesync == 4'b1000)     // ACK receiving
         begin
         if (sdaint)                // not ACK
            begin
            fsmsta_nxt = FSMSTAC0 ;
            end
         else                       // ACK
            begin
            if (!aa)                // transmit last data
               begin
               fsmsta_nxt = FSMSTAC8 ;
               end
            else
               begin
               fsmsta_nxt = FSMSTAB8 ;
               end
            end
         end
      else
         begin
         if (sdao_int && !sdaint && pedetect)
            begin                   //arbitration lost
            fsmsta_nxt = FSMSTA38 ;
            end
         else
            begin
            fsmsta_nxt = FSMSTAB8 ;
            end
         end
      end

   //-----------------------------
   FSMSTAC0 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAC0 ;      // go to n.a. slv
      end

   //-----------------------------
   FSMSTAC8 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTAC8 ;      // go to n.a. slv
      end

   //==========================================--
   // BUS ERROR
   //==========================================--

   //-----------------------------
   FSMSTA00 :
   //-----------------------------
      begin
      fsmsta_nxt = FSMSTA00 ;      // go to n.a. slv
      end

   //-----------------------------
   default :
   //----------------------------
      begin
      fsmsta_nxt = FSMSTAF8 ;      // go to n.a. slv
      end

   endcase
   end

   //------------------------------------------------------------------
   always @(posedge clk)
   begin : fsmsta_sync_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmsta <= FSMSTAF8 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmdet == FSMDET3 && fsmmod == FSMMOD1)
         begin
         fsmsta <= FSMSTA08 ;          // START has been trx
         end
      else if (fsmdet == FSMDET3 && fsmmod == FSMMOD6)
         begin
         fsmsta <= FSMSTA10 ;          // repeated START has been trx
         end
      else if (fsmdet == FSMDET3 || fsmdet == FSMDET5)
         begin                         // START or STOP has been rcv
         if ((framesync == 4'b0000 || framesync == 4'b1001) &&
            (!si_int))
            begin
            if (adrcomp)               // addressed slave
               begin
               fsmsta <= FSMSTAA0 ;    // switched to n.a.slv. mode
               end
            else
               begin
               fsmsta <= FSMSTAF8 ;
               end
            end
         else if (
               (framesync == 4'b0001 || framesync == 4'b0010 ||
                framesync == 4'b0011 || framesync == 4'b0100 ||
                framesync == 4'b0101 || framesync == 4'b0110 ||
                framesync == 4'b0111 || framesync == 4'b1000) &&
               (adrcomp || mst)
            )
            begin
            fsmsta <= FSMSTA00 ;       // frame error
            end
         end
      else if (
            framesync == 4'b1000 &&
            pedetect &&
            adrcomp &&
            adrcompen &&
            ~(fsmsta == FSMSTA38)
         )
         begin                      // switched to addressed slv. mode
         if (!ack)                  // R/nW = 0
            begin
            if (i2cdat[6:0] == 7'b0000000)
               begin
               fsmsta <= FSMSTA70 ; // GC Address
               end
            else
               begin
               fsmsta <= FSMSTA60 ; // slave address
               end
            end
         else                       // R/nW = 1
            begin
            fsmsta <= FSMSTAA8 ;    // slave address (R/nW = 1)
            end
         end
      else
         begin
         if (pedetect)
            begin
            fsmsta <= fsmsta_nxt ;
            end
         end
      end
   end


   //------------------------------------------------------------------
   // stop/start condition detector
   //------------------------------------------------------------------
   always @(fsmdet or sdaint)
   begin : fsmdet_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Combinational value
   //-----------------------------

   case (fsmdet)

   //-----------------------------
   FSMDET0 :
   //-----------------------------
      begin
      if (!sdaint)
         begin
         fsmdet_nxt = FSMDET2 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET1 ;
         end
      end

   //-----------------------------
   FSMDET1 :
   //-----------------------------
      begin
      if (!sdaint)
         begin
         fsmdet_nxt = FSMDET3 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET1 ;
         end
      end

   //-----------------------------
   FSMDET2 :
   //-----------------------------
      begin
      if (!sdaint)
         begin
         fsmdet_nxt = FSMDET2 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET5 ;
         end
      end

   //-----------------------------
   FSMDET3 :
   //-----------------------------
      begin
      fsmdet_nxt = FSMDET4 ;
      end

   //-----------------------------
   FSMDET4 :
   //-----------------------------
      begin
      if (!sdaint)
         begin
         fsmdet_nxt = FSMDET4 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET5 ;
         end
      end

   //-----------------------------
   FSMDET5 :
   //-----------------------------
      begin
      fsmdet_nxt = FSMDET6 ;
      end

   //-----------------------------
   default :   // when FSMDET6
   //-----------------------------
      begin
      if (!sdaint)
         begin
         fsmdet_nxt = FSMDET3 ;
         end
      else
         begin
         fsmdet_nxt = FSMDET6 ;
         end
      end

   endcase
   end

   //------------------------------------------------------------------
   always @(posedge clk)
   begin : fsmdet_sync_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmdet <= FSMDET0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!sclint)
         begin
         fsmdet <= FSMDET0 ;
         end
      else
         begin
         fsmdet <= fsmdet_nxt ;
         end
      end
   end

   //------------------------------------------------------------------
   // I2C bus free detector
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : busfree_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      busfree <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmdet == FSMDET3)           // START condition
         begin
         busfree <= 1'b0 ;
         end
      else if (
            (fsmdet == FSMDET5) ||      // STOP condition rcv
            (fsmmod == FSMMOD4 && clkint_p2 &&
            sclint) ||                  // STOP transmitted
            (!mst && sto) ||             // internal stop
            (!ens1)                      // i2c disable

         )
         begin
         busfree <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // two cycles scl
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : sclscl_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      sclscl <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (fsmmod == FSMMOD5)
         begin
         if (pedetect)
            begin
            sclscl <= 1'b1 ;
            end
         end
      else
         begin
         sclscl <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   // transmit START condition enable
   //------------------------------------------------------------------
   always @(posedge clk)
   begin : starto_en_write_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      starto_en <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (busfree && sclint && ~(fsmmod == FSMMOD5))
         begin
         if (clkint_p2)
            begin
            starto_en <= 1'b1 ;
            end
         end
      else
         begin
         starto_en <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   // master/slave mode detector
   //------------------------------------------------------------------
   always @(fsmmod or sdaint or sclint or clkint_p2 or clkint_p1 or
      sto or sta or nedetect or framesync or starto_en or si_int or
      fsmsta or pedetect or sclscl)
   begin : fsmmod_comb_proc
   //------------------------------------------------------------------
   //-----------------------------
   // Initial value
   //-----------------------------
   mst = 1'b1 ;

   //-----------------------------
   // Combinational value
   //-----------------------------
   case (fsmmod)
   //-----------------------------
   FSMMOD0 :
   //-----------------------------
      begin
      mst = 1'b0 ;
      if (starto_en && sta && !si_int && clkint_p2)
         begin
         if (!sdaint)
            begin
            fsmmod_nxt = FSMMOD5 ; // transmit 2*SCL
            end
         else
            begin
            fsmmod_nxt = FSMMOD1 ; // transmit START
            end
         end
      else
         begin
         fsmmod_nxt = FSMMOD0 ;
         end
      end

   //-----------------------------
   FSMMOD1 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (nedetect)
         begin
         // sclint neg. edge deteted
         fsmmod_nxt = FSMMOD2 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD1 ;
         end
      end

   //-----------------------------
   FSMMOD2 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (framesync == 4'b1001 && !si_int)
         begin
         if (sto)
            begin
            fsmmod_nxt = FSMMOD4 ; // transmit STOP
            end
         else if (sta && ~(fsmsta == FSMSTA08 || fsmsta == FSMSTA10) &&
            clkint_p2)
            begin
            fsmmod_nxt = FSMMOD3 ; // transmit repeated START (Sr)
            end
         else
            begin
            fsmmod_nxt = FSMMOD2 ;
            end
         end
      else
         begin
         fsmmod_nxt = FSMMOD2 ;
         end
      end

   //-----------------------------
   FSMMOD3 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if ((clkint_p1 || clkint_p2) && sclint)
         begin
         fsmmod_nxt = FSMMOD6 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD3 ;
         end
      end

   //-----------------------------
   FSMMOD4 :
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (sclint && clkint_p2)
         begin
         fsmmod_nxt = FSMMOD0 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD4 ;
         end
      end

   //-----------------------------
   FSMMOD5 :
   //-----------------------------
      begin
      mst = 1'b0 ;
      if (sclscl && pedetect)        // two cycles sclo
         begin
         fsmmod_nxt = FSMMOD0 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD5 ;
         end
      end

   //-----------------------------
   default :      //when FSMMOD6
   //-----------------------------
      begin
      mst = 1'b1 ;
      if (nedetect)     // Sr
         begin
         fsmmod_nxt = FSMMOD2 ;
         end
      else
         begin
         fsmmod_nxt = FSMMOD6 ;
         end
      end
   endcase
   end

   //------------------------------------------------------------------
   always @(posedge clk)
   begin : fsmmod_sync_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fsmmod <= FSMMOD0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
         if (
            (fsmdet == FSMDET5) ||         // STOP
            (
               fsmsta == FSMSTA38 &&
               framesync == 4'b1000 &&
               pedetect
            ) ||
            (!ens1)                       // i2c disable
         )
         begin
         fsmmod <= FSMMOD0 ;
         end
      else
         begin
         fsmmod <= fsmmod_nxt ;
         end
      end
   end

   //------------------------------------------------------------------
   // Special Function registers read
   //------------------------------------------------------------------
   assign i2cdat_o = i2cdat;
   assign i2cadr_o = i2cadr;
   assign i2ccon_o = i2ccon;
   assign i2csta_o = {i2csta, 3'b000};

endmodule // i2c

