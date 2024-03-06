
module serial0 (
   t_shift_clk,
   r_shift_clk,
   clkper,
   rst,
   newinstr,
   rxd0ff,
   t1ov,
   rxd0o, rxd0oe,
   txd0,
   sfrdatai,
   sfraddr,
   sfrwe,
   s0con,
   s0buf,
   s0rell,
   s0relh,
   smod,
   bd
   );
output
   t_shift_clk,
   r_shift_clk;

   //  Declarations
   `include  "mcu51_param.v"

   //  Control signals inputs
   input    clkper;             // Global clock input
   input    rst;                // Hardware reset input

   // CPU input signal
   input    newinstr;           // Start of new CPU instruction
   input    t1ov;               // Timer 1 overflow output

   //  Special function register interface
   input    [7:0] sfrdatai;     // SFR data bus input
   input    [6:0] sfraddr;      // SFR address bus
   input    sfrwe;              // SFR write enable
   output   [7:0] s0con;           // Output SFR data bu
   wire     [7:0] s0con;
   output   [7:0] s0buf; 
   wire     [7:0] s0buf;
   output   [7:0] s0rell; 
   wire     [7:0] s0rell;
   output   [7:0] s0relh; 
   wire     [7:0] s0relh;
   output   smod; 
   wire     smod;
   output   bd; 
   wire     bd;

   //  Serial outputs
   input    rxd0ff;             // Serial Port 0 receive data
   output   txd0;               // Serial Port 0 transmit data
   reg      txd0;
   output   rxd0o, rxd0oe;      // Serial Port 0 receive clock
   reg      rxd0o;

//*******************************************************************--

   //---------------------------------------------------------------
   // SMOD bit
   //---------------------------------------------------------------
   reg smod_s; 
   
   //------------------------------------------------------------------
   // Serial Port 0 Control register
   //------------------------------------------------------------------
   reg      [7:0] s0con_s;

   //------------------------------------------------------------------
   // Serial Data Buffer 0
   //------------------------------------------------------------------
   reg      [7:0] s0buf_r;

   //------------------------------------------------------------------
   // rxd0i input falling edge detector
   //------------------------------------------------------------------
   reg      rxd0_fall;
   reg      rxd0_ff;
   reg      rxd0_val;
   reg      [2:0] rxd0_vec;

   //------------------------------------------------------------------
   // Clock counter
   //------------------------------------------------------------------
   reg      [3:0] clk_count;
   reg      r_clk_ov2;
   reg      clk_ov12;

   //------------------------------------------------------------------
   // Timer 1 overflow counter
   //------------------------------------------------------------------
   reg      t1ov_ff;

   //------------------------------------------------------------------
   // Transmit baud counter
   //------------------------------------------------------------------
   reg      [3:0] t_baud_count;
   reg      t_baud_ov;
   wire     t_baud_clk;    // baud clock for transmit

   //------------------------------------------------------------------
   // Transmit shift register
   //------------------------------------------------------------------
   reg      [10:0] t_shift_reg;
   wire     t_shift_clk;

   //------------------------------------------------------------------
   // Transmit shift counter
   //------------------------------------------------------------------
   reg      [3:0] t_shift_count;

   //------------------------------------------------------------------
   // Transmit control signals
   //------------------------------------------------------------------
   reg      t_start;

   //------------------------------------------------------------------
   // Receive baud counter
   //------------------------------------------------------------------
   reg      [3:0] r_baud_count;

   //------------------------------------------------------------------
   // Receive shift register
   //------------------------------------------------------------------
   reg      [7:0] r_shift_reg;

   //------------------------------------------------------------------
   // Receive shift counter
   //------------------------------------------------------------------
   reg      [3:0] r_shift_count;

   //------------------------------------------------------------------
   // Receive control signal
   //------------------------------------------------------------------
   reg      r_start;
   reg      receive_11_bits;
   reg      ri0_fall;
   reg      ri0_ff;
   wire     r_shift_clk;
   reg      rxd0_fall_fl;
   reg      [1:0] fluctuation_conter;

   //------------------------------------------------------------------
   // Baud Rate Generator Reload register
   //------------------------------------------------------------------
   reg      [7:0] s0rell_s;
   reg      [7:0] s0relh_s;

   wire r_double_baud = s0relh_s[7];
   wire clk_ov2 = r_double_baud ? 1'h1 : r_clk_ov2;
   wire not_clk_ov2 = r_double_baud ? 1'h1 : !r_clk_ov2;

   wire r_half_divisor = s0relh_s[6];
   wire r_baud_mid = r_half_divisor ? r_baud_count == 4'b0101 || r_baud_count == 4'b1101 : r_baud_count == 4'b1001;
   wire r_baud_qua = r_half_divisor ? r_baud_count == 4'b0011 || r_baud_count == 4'b1011 : r_baud_count == 4'b0101;
   wire r_baud_up  = r_half_divisor ? r_baud_count[2] : r_baud_count[3];

   //------------------------------------------------------------------
   // Baud Rate Timer
   //------------------------------------------------------------------
   reg      [9:0] tim_baud;

   //------------------------------------------------------------------
   // Baud Rate Generator control signals
   //------------------------------------------------------------------
   reg      baud_rate_ov;
   reg      bd_s;
   reg      baud_r_count;
   wire     baud_rate_clk;
   wire     baud_r_clk;
   reg      baud_r2_clk;

   //------------------------------------------------------------------
   //  RI and TI temporary registers
   //------------------------------------------------------------------
   reg      ri_tmp;
   reg      ti_tmp;
   reg      s0con2_tmp;
   reg      s0con2_val;


   //------------------------------------------------------------------
   // Rising edge detection on the t1ov
   // t1ov_rise is high active during single clk period
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : t1ov_rise_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      t1ov_ff <= 1'b0 ;
      end
   else
      begin
      //--------------------------------
      // t1ov_rise flip-flop
      //--------------------------------
      t1ov_ff <= t1ov ;
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : ri_tmp_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      ri_tmp     <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      case (s0con_s[7:6])
      //----------------------------------
      // Mode 0
      //----------------------------------
      2'b00 :
         begin
         if (t_baud_clk & r_shift_count == 4'b0001)
            begin
            ri_tmp <= 1'b1 ;
            end
         else if (newinstr)
            begin
            ri_tmp <= 1'b0 ;
            end
         end

      //----------------------------------
      // Modes 1, 2, 3
      //----------------------------------
      default :
         begin
         if (r_shift_clk & r_shift_count == 4'b0001 & !s0con_s[0])
            begin
            if (s0con_s[5])
               begin
               ri_tmp <= rxd0_val; // rec. int. flag
               end
            else
               begin
               ri_tmp <= 1'b1 ;    // rec. int. flag
               end
            end
         else if (newinstr)
            begin
            ri_tmp     <= 1'b0 ;
            end
         end

      endcase
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0con2_tmp_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0con2_val <= 1'b0 ;
      s0con2_tmp <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      //----------------------------------
      // Modes 1, 2, 3
      //----------------------------------
      if (r_shift_clk & r_shift_count == 4'b0001 & !s0con_s[0] & s0con_s[7:6]!= 2'b00)
         begin
         if (!s0con_s[5] | rxd0_val)
            begin
            s0con2_val <= rxd0_val ;
            s0con2_tmp <= 1'b1 ;
            end
         end
      else if (newinstr)
         begin
         s0con2_tmp <= 1'b0 ;
         end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : ti_tmp_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      ti_tmp     <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (t_shift_clk & t_shift_count == 4'b0001)
         begin
         ti_tmp <= 1'b1 ;
         end
      else if (newinstr)
         begin
         ti_tmp <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0con_0_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0con_s[0] <= S0CON_RV[0] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0CON_ID )
         begin
         s0con_s[0] <= sfrdatai[0] ;
         end
      else
         begin
         if (ri_tmp)
            begin
            s0con_s[0] <= 1'b1 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0con_1_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0con_s[1] <= S0CON_RV[1] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0CON_ID )
         begin
         s0con_s[1] <= sfrdatai[1] ;
         end
      else
         begin
         if (ti_tmp)
            begin
            s0con_s[1] <= 1'b1 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0con_2_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0con_s[2]      <= S0CON_RV[2] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0CON_ID )
         begin
         s0con_s[2] <= sfrdatai[2] ;
         end
      else
         begin
         if (s0con2_tmp)
            begin
            s0con_s[2] <= s0con2_val ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0con_7_3_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0con_s[7:3] <= S0CON_RV[7:3] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0CON_ID )
         begin
         s0con_s[7:3] <= sfrdatai[7:3] ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0rell_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0rell_s <= S0RELL_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0RELL_ID )
         begin
         s0rell_s <= sfrdatai ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0relh_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0relh_s <= S0RELH_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0RELH_ID )
         begin
         s0relh_s <= sfrdatai ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : adcon_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      bd_s <= ADCON_RV[7] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Special function register write
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == ADCON_ID )
         begin
         bd_s <= sfrdatai[7] ;
         end
      end
   end

   //------------------------------------------------------------------
   // Timer Baud Rate overflow
   // baud_rate_ov is high active during single clk period
   //------------------------------------------------------------------
   wire pre_baud_ov = clk_ov2 & tim_baud[9:0] == 10'b1111111111;
   always @(posedge clkper)
   begin : baud_rate_ov_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      baud_rate_ov <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (pre_baud_ov)
         begin
         baud_rate_ov <= 1'b1 ;
         end
      else
         begin
         baud_rate_ov <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : tim_baud_reload_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      tim_baud <= 10'b1111110011 ;  // this value is not specified
                                    // in instruction of SAB80C517
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (r_double_baud ? pre_baud_ov : baud_rate_ov)
         begin
         tim_baud[7:0] <= s0rell_s ;
         tim_baud[9:8] <= s0relh_s[1:0] ;
         end
      else if (not_clk_ov2)
         begin
         tim_baud <= tim_baud + 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : clk_count_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      clk_count <= 4'b0000 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // clk counter
      //--------------------------------
      begin
      if (clk_count == 4'b1011)
         begin
         clk_count <= 4'b0000 ;
         end
      else
         begin
         clk_count <= clk_count + 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : clk_ov2_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      r_clk_ov2 <= 1'b0 ;
      end
   else
      begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // clk divide by 2
      //--------------------------------
      if (clk_count[0])
         begin
         r_clk_ov2 <= 1'b1 ;
         end
      else
         begin
         r_clk_ov2 <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : clk_ov12_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      clk_ov12 <= 1'b0 ;
      end
   else
      begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // clk divide by 12
      //--------------------------------
      if (clk_count == 4'b1001)
         begin
         clk_ov12 <= 1'b1 ;
         end
      else
         begin
         clk_ov12 <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   assign baud_r_clk =
        (s0con_s[6] & !bd_s)     ? t1ov_ff      :
        (s0con_s[6])             ? baud_rate_ov :
        (s0con_s[7:6] == 2'b10)  ? clk_ov2      : 1'b0 ;

   //------------------------------------------------------------------
   // assign b_clk = baud_rate_clk ;

   //------------------------------------------------------------------
   assign r_shift_clk = (r_start &
                         r_baud_mid &
                         baud_rate_clk) ? 1'b1 : 1'b0 ;

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : baud_r_count_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      baud_r_count <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // baud_r_clk overflow count
      //--------------------------------
      begin
      if (baud_r_clk)
         begin
         baud_r_count <= ~(baud_r_count) ;
         end
      end
   end
   
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : smod_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      smod_s <= PCON_RV[7] ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // baud_r_clk overflow count
      //--------------------------------
      begin
      if (sfraddr == PCON_ID && sfrwe == 1'b1)
         begin
            smod_s <= sfrdatai[7] ; 
         end 
      end
   end
   
   //------------------------------------------------------------------
   // smod bit
   //------------------------------------------------------------------
   assign smod = smod_s ;

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : baud_r2_clk_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      baud_r2_clk <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Overflow divide by 2
      //--------------------------------
      begin
      if (baud_r_clk & baud_r_count)
         begin
         baud_r2_clk <= 1'b1 ;
         end
      else
         begin
         baud_r2_clk <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   assign baud_rate_clk =
      (smod_s) ? baud_r_clk :
      baud_r2_clk ;

   //------------------------------------------------------------------
   assign t_baud_clk =
      (s0con_s[7:6] == 2'b00) ? clk_ov12 :  // mode=0
      t_baud_ov ;                         // mode=1,2,3

   //------------------------------------------------------------------
   assign t_shift_clk =
      (t_start) ? t_baud_clk :
      1'b0 ;

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : t_baud_count_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      t_baud_count <= 4'b0000 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Transmit clk divide by 16 or 8
      //--------------------------------
      begin
      if (baud_rate_clk & t_start)
         begin
         t_baud_count <= (r_half_divisor && t_baud_count==4'h7) ? 4'h0 : t_baud_count + 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : t_baud_ov_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      t_baud_ov <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Transmit clk divide by 16 or 8
      //--------------------------------
      begin
      if (baud_rate_clk & t_baud_count == 4'b0001)
         begin
         t_baud_ov <= 1'b1 ;
         end
      else
         begin
         t_baud_ov <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : t_start_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      t_start <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Transmit shift enable
      //--------------------------------
      begin
      //--------------------------------
      if (t_shift_count == 4'b0000 &
         ~(sfrwe && sfraddr == S0BUF_ID ))
         begin
         t_start <= 1'b0 ;
         end
      else if (sfrwe && sfraddr == S0BUF_ID )
         begin
         t_start <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : t_shift_reg_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      t_shift_reg <= 11'b11111111111 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Transmit registers load
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0BUF_ID )
         begin
         case (s0con_s[7:6])
         //-----------------------------
         // Mode 0
         //-----------------------------
         2'b00 :
            begin
            t_shift_reg[10:9]<= 2'b11;
            t_shift_reg[8:1] <= sfrdatai;
            t_shift_reg[0]   <= 1'b1;
            end

         //-----------------------------
         // Mode 1
         //-----------------------------
         2'b01 :
            begin
            t_shift_reg[10] <= 1'b1 ;
            t_shift_reg[9:2] <= sfrdatai ;
            t_shift_reg[1] <= 1'b0 ;
            t_shift_reg[0] <= 1'b1 ;
            end

         //-----------------------------
         // Mode 2, 3
         //-----------------------------
         default :
            begin
            t_shift_reg[10] <= s0con_s[3] ;
            t_shift_reg[9:2] <= sfrdatai ;
            t_shift_reg[1] <= 1'b0 ;
            t_shift_reg[0] <= 1'b1 ;
            end

         endcase
         end
      else
         //--------------------------------
         // Transmit register shift
         //--------------------------------
         begin
         if (t_shift_clk)
            begin
            t_shift_reg[9:0] <= t_shift_reg[10:1];
            t_shift_reg[10]  <= 1'b1;
            end
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : t_shift_count_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      t_shift_count <= 4'b0000 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Transmit data count load
      //--------------------------------
      begin
      if (sfrwe == 1'b1 && sfraddr == S0BUF_ID )
         begin
         case (s0con_s[7:6])
         //-----------------------------
         // Mode 0
         //-----------------------------
         2'b00 :
            begin
            t_shift_count <= 4'b1001;
            end

         //-----------------------------
         // Mode 1
         //-----------------------------
         2'b01 :
            begin
            t_shift_count <= 4'b1010 ;
            end

         //-----------------------------
         // Mode 2, 3
         //-----------------------------
         default :
            begin
            t_shift_count <= 4'b1011 ;
            end

         endcase
         end
      else
         begin
         //--------------------------------
         // Transmit data count
         //--------------------------------
         if (t_shift_clk)
            begin
            t_shift_count <= t_shift_count - 1'b1 ;
            end
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : transmit_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      txd0 <= 1'b1 ;
      rxd0o <= 1'b1 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Transmit output
      //--------------------------------
      begin
      if (t_start | r_start)
         begin
         case (s0con_s[7:6])
         2'b00 :  // mode 0
            begin
            if (clk_count > 4'b0010 & clk_count < 4'b1001)
               begin
               if (~(t_shift_count == 4'b1001))
                  begin
                  txd0 <= 1'b0 ;
                  end
               end
            else
               begin
               txd0 <= 1'b1 ;
               end

            rxd0o <= t_shift_reg[0] ;
            end

         default :  // mode 1,2,3
            begin
            txd0 <= t_shift_reg[0] ;
            rxd0o <= 1'b1 ;
            end

         endcase
         end
      else
         begin
         txd0 <= 1'b1 ;
         rxd0o <= 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   // Falling edge detection on the external input rxd0i
   // rxd0_fall is high active during single clk period
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : rxd0_fall_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      rxd0_fall <= 1'b0 ;
      rxd0_ff <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      //--------------------------------
      // Falling edge detection
      //--------------------------------
      begin
      if (((!rxd0ff & rxd0_ff) | rxd0_fall_fl) &
          !r_start & !receive_11_bits & !rxd0_fall)
         begin
         rxd0_fall <= 1'b1 ;
         end
      else
         begin
         rxd0_fall <= 1'b0 ;
         end

      //--------------------------------
      // rxd0ff signal flip-flop
      //--------------------------------
      rxd0_ff <= rxd0ff ;

      end
   end

   //------------------------------------------------------------------
   // Falling edge detection on the external input rxd0i
   // rxd0_fall is high active during single clk period
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : rxd0_fall_fl_proc
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      rxd0_fall_fl <= 1'b0;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      begin
      if (!rxd0ff & rxd0_ff & r_shift_count==4'b0001 & 
          r_baud_up & s0con_s[7:6]== 2'b01)
         //--------------------------------
         // Falling edge detection
         //--------------------------------
         begin
         rxd0_fall_fl <= 1'b1;
         end
      else if ((rxd0_fall & r_shift_count==4'b0000) | !r_baud_up)
         begin
         rxd0_fall_fl <= 1'b0;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : fluct_conter_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      fluctuation_conter <= 2'b00;
      end
   else
      begin
      if (rxd0_fall_fl)
         begin
         if (baud_rate_clk)
            begin
            fluctuation_conter <= fluctuation_conter + 1'b1;
            end
         end
      else
         begin
         fluctuation_conter <= 2'b00;
         end
      end
   end

   //------------------------------------------------------------------
   // RXD vector
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : rxd0_vec_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      rxd0_vec <= 3'b111 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // RXD vector write
      //--------------------------------
      begin
      if (baud_rate_clk)
         begin
         rxd0_vec <= {rxd0_vec[1:0], rxd0ff} ;
         end
      end
   end

   //------------------------------------------------------------------
   // rxd0i input pin falling edge detector
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : rxd0_val_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      rxd0_val <= 1'b1 ;
      end
   else
      begin
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // rxd0i pin value
      //--------------------------------
      case (s0con_s[7:6])
      2'b00 :  // mode 0
         begin
         rxd0_val <= rxd0ff ;
         end

      default :  // mode 1,2,3
         begin
         if (rxd0_vec == 3'b001 |
             rxd0_vec == 3'b010 |
             rxd0_vec == 3'b100 |
             rxd0_vec == 3'b000)
            begin
            rxd0_val <= 1'b0 ;
            end
         else
            begin
            rxd0_val <= 1'b1 ;
            end
         end

      endcase
      end
   end

   //------------------------------------------------------------------
   //
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : receive_9_bits_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      receive_11_bits <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Falling edge detection
      //--------------------------------
      begin
      if (s0con_s[7])
         begin
         if (r_baud_mid & r_shift_count == 4'b0001)
            begin
            receive_11_bits <= 1'b1 ;
            end
         else if (r_baud_qua)
            begin
            receive_11_bits <= 1'b0 ;
            end
         end
      else
         begin
         receive_11_bits <= 1'b0 ;
         end
      end
   end

   //------------------------------------------------------------------
   // Falling edge detection on the ri0
   // ri0_fall is high active during single clk period
   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : ri0_fall_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      ri0_fall <= 1'b0 ;
      ri0_ff <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Falling edge detection
      //--------------------------------
      begin
      if (s0con_s[7:6]==2'b00)
        begin
        if (!(s0con_s[0]) & ri0_ff)
           begin
           ri0_fall <= 1'b1 ;
           end
        else if (t_baud_clk)
           begin
           ri0_fall <= 1'b0 ;
           end
        end

      //--------------------------------
      // RI flag flip-flop
      //--------------------------------
      ri0_ff <= s0con_s[0] ;

      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : r_baud_count_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      r_baud_count  <= 4'b0000 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // receive clk divide by 16 or 8
      //--------------------------------
      begin
      if (rxd0_fall)
         begin
         if (rxd0_fall_fl)
            begin
            r_baud_count <= {2'b00, fluctuation_conter};
            end
         else
            begin
            r_baud_count <= 4'b0000;
            end
         end
      else if (baud_rate_clk & r_start)
         begin
         r_baud_count <= r_baud_count + 1'b1 ;
         end
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : r_shift_reg_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      r_shift_reg   <= 8'b11111111 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Receive register shift
      //--------------------------------
      begin
      case (s0con_s[7:6])
      //-----------------------------
      // Mode 0
      //-----------------------------
      2'b00 :
         begin
         if (r_start & t_baud_clk)
            begin
            r_shift_reg[6:0] <= r_shift_reg[7:1] ;
            r_shift_reg[7]   <= rxd0_val ;
            end
         end

      //-----------------------------
      // Mode 1, 2, 3
      //-----------------------------
      default :
         begin
         if (r_baud_mid & baud_rate_clk & r_start)
            begin
            r_shift_reg[6:0] <= r_shift_reg[7:1] ;
            r_shift_reg[7]   <= rxd0_val ;
            end
         end
      endcase
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : r_shift_count_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      r_shift_count <= 4'b0000 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Receive register shift
      //--------------------------------
      begin
      case (s0con_s[7:6])
      //-----------------------------
      // Mode 0
      //-----------------------------
      2'b00 :
         begin
         if (ri0_fall & s0con_s[4] & t_baud_clk)
            begin
            r_shift_count <= 4'b1000 ;
            end
         else if (r_start & t_baud_clk)
            begin
            r_shift_count    <= r_shift_count - 1'b1 ;
            end
         end
      //-----------------------------
      // Mode 1, 2, 3
      //-----------------------------
      default :
         begin
         if (rxd0_fall & s0con_s[4])
            begin
            r_shift_count <= 4'b1010 ;
            end
         else if (r_shift_clk)
            begin
            r_shift_count <= r_shift_count - 1'b1 ;
            if (r_shift_count == 4'b1010)
               begin
               if (rxd0_val)
                  begin
                  r_shift_count <= 4'b0000 ;
                  end
               end
            end
         end
      endcase
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : r_start_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      r_start       <= 1'b0 ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // Receive register shift
      //--------------------------------
      begin
      case (s0con_s[7:6])
      //-----------------------------
      // Mode 0
      //-----------------------------
      2'b00 :
         begin
         if (r_start & t_baud_clk)
            begin
            if (r_shift_count == 4'b0001)
               begin
               r_start <= 1'b0 ;
               end
            end
         else if (ri0_fall & s0con_s[4] & t_baud_clk)
            begin
            r_start <= 1'b1 ;
            end
         end
      //-----------------------------
      // Mode 1, 2, 3
      //-----------------------------
      default :
         begin
         if (r_shift_count == 4'b0000)
            begin
            if (rxd0_fall & s0con_s[4])
               begin
               r_start <= 1'b1 ;
               end
            end
         else
            begin
            if (baud_rate_clk & r_baud_mid)
               begin
               if (r_shift_count == 4'b0001)
                  begin
                  r_start <= 1'b0 ;
                  end
               else if (r_shift_count == 4'b1010)
                  begin
                  if (rxd0_val)
                     begin
                     r_start <= 1'b0 ;
                     end
                  end
               end
            end
         end
      endcase
      end
   end

   //------------------------------------------------------------------
   always @(posedge clkper)
   begin : s0buf_r_proc
   //------------------------------------------------------------------
   if (rst)
      //-----------------------------------
      // Synchronous reset
      //-----------------------------------
      begin
      s0buf_r       <= S0BUF_RV ;
      end
   else
      //-----------------------------------
      // Synchronous write
      //-----------------------------------
      // receive clk divide by 16 or 8
      //--------------------------------
      begin
      if (r_shift_count == 4'b0001)
         begin
         if (s0con_s[7:6] == 2'b00 & t_baud_clk)
            begin
            s0buf_r <= {rxd0_val, r_shift_reg[7:1]};
            end
         else
            begin
            if (!s0con_s[0] & r_shift_clk)
               begin
               if (s0con_s[5])
                  begin
                  if (rxd0_val)
                     begin
                     s0buf_r <= r_shift_reg[7:0] ;
                     end
                  end
               else
                  begin
                  s0buf_r <= r_shift_reg[7:0] ;
                  end
               end
            end
         end
      end
   end

   //------------------------------------------------------------------
   // Special Function registers read
   //------------------------------------------------------------------
   //------------------------------------------------------------------
   assign s0con = s0con_s ;
   //------------------------------------------------------------------
   //------------------------------------------------------------------
   assign s0buf = s0buf_r ;
   //------------------------------------------------------------------
   //------------------------------------------------------------------
   assign s0rell = s0rell_s ;
   //------------------------------------------------------------------
   //------------------------------------------------------------------
   assign s0relh = s0relh_s ;
   //------------------------------------------------------------------
   //------------------------------------------------------------------
   assign bd = bd_s ;

   assign rxd0oe = (s0con[7:6]=='h0) & t_start;

endmodule // serial0

