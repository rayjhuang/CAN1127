
module mdu (
  clkper,
  rst,
  mdubsy,
  sfrdatai,
  sfraddr,
  sfrwe,
  sfroe,
  arcon,
  md0,
  md1,
  md2,
  md3,
  md4,
  md5
  );

  // Declarations
  `include  "mcu51_param.v"

  //  Control signals inputs
  input             clkper;           // Global clock input
  input             rst;              // Hardware reset input

  //  Special function register interface
  input     [ 7: 0] sfrdatai;         // SFR data bus inputs
  input     [ 6: 0] sfraddr;          // SFR address bus
  input             sfrwe;            // SFR write enable
  input             sfroe;            // SFR output snable
  output            mdubsy;
  wire              mdubsy;
  output    [ 7: 0] arcon;            // Output ARCON register
  wire      [ 7: 0] arcon;
  output    [ 7: 0] md0;              // Output MD0 register
  wire      [ 7: 0] md0;
  output    [ 7: 0] md1;              // Output MD1 register
  wire      [ 7: 0] md1;
  output    [ 7: 0] md2;              // Output MD2 register
  wire      [ 7: 0] md2;
  output    [ 7: 0] md3;              // Output MD3 register
  wire      [ 7: 0] md3;
  output    [ 7: 0] md4;              // Output MD4 register
  wire      [ 7: 0] md4;
  output    [ 7: 0] md5;              // Output MD5 register
  wire      [ 7: 0] md5;

//*******************************************************************--

  //---------------------------------------------------------------
  // FSM states enumeration type
  //---------------------------------------------------------------
  parameter         ST13   = 4'b1101;
  parameter         ST12   = 4'b1100;
  parameter         ST11   = 4'b1011;
  parameter         ST10   = 4'b1010;
  parameter         ST9    = 4'b1001;
  parameter         ST8    = 4'b1000;
  parameter         ST7    = 4'b0111;
  parameter         ST6    = 4'b0110;
  parameter         ST5    = 4'b0101;
  parameter         ST4    = 4'b0100;
  parameter         ST3    = 4'b0011;
  parameter         ST2    = 4'b0010;
  parameter         ST1    = 4'b0001;
  parameter         ST0    = 4'b0000;

  //---------------------------------------------------------------
  // Operation select enumeration type
  //---------------------------------------------------------------
  parameter         MUL      = 4'b0000;
  parameter         DIV32    = 4'b0001;
  parameter         LDRES    = 4'b0010;
  parameter         DIV16    = 4'b0011;
  parameter         SHR      = 4'b0100;
  parameter         SHL      = 4'b0101;
  parameter         NORM     = 4'b0110;
  parameter         NOP_     = 4'b0111;
  parameter         MD32RST  = 4'b1000;

  //---------------------------------------------------------------
  // MDU operation select enumeration type
  //---------------------------------------------------------------
  parameter         MDU_MUL    = 2'b00;
  parameter         MDU_DIV16  = 2'b01;
  parameter         MDU_DIV32  = 2'b10;
  parameter         MDU_SHIFT  = 2'b11;

  //---------------------------------------------------------------
  // Special Function Registers
  //---------------------------------------------------------------
  // Arithmetic Control Register
  reg       [ 7: 0] arcon_s;

  // Multiplication/Division Registers
  reg       [ 7: 0] md0_s;
  reg       [ 7: 0] md1_s;
  reg       [ 7: 0] md2_s;
  reg       [ 7: 0] md3_s;
  reg       [ 7: 0] md4_s;
  reg       [ 7: 0] md5_s;

  //---------------------------------------------------------------
  // Utility registers
  //---------------------------------------------------------------
  reg       [15: 0] norm_reg;
  reg       [ 4: 0] counter_st;
  reg       [ 4: 0] counter_nxt;

  // Combinational adder
  wire      [17: 0] sum;
  wire      [17: 0] sum1;

  // FSM registers and signals
  reg       [ 3: 0] oper_reg;         // arithmetic operation FSM
  reg       [ 3: 0] oper_nxt;

assign mdubsy = oper_reg!=ST0;

  // Control signals
  reg       [ 3: 0] md30_sel;         // md3 ... md0 mux addr
  reg       [ 1: 0] counter_sel;      //count select
  reg               ld_sc;            // load sc (in arcon register)
  reg       [ 1: 0] mdu_op;           // mdu operation
  reg               opend;            // mdu operation end
  reg               setmdef;          // set mdef flag
  reg               setmdov;          // set mdov flag
  reg               clrmdov;          // clear mdov flag
  reg               set_div32;        // set div32 operation
  reg               set_div16;        // set div16 operation

  reg       [17: 0] arg_a;
  reg       [17: 0] arg_b;
  reg       [17: 0] arg_c;
  reg       [17: 0] arg_d;

  wire sfraddr_MD0   = sfraddr == MD0_ID;
  wire sfraddr_MD1   = sfraddr == MD1_ID;
  wire sfraddr_MD2   = sfraddr == MD2_ID;
  wire sfraddr_MD3   = sfraddr == MD3_ID;
  wire sfraddr_MD4   = sfraddr == MD4_ID;
  wire sfraddr_MD5   = sfraddr == MD5_ID;
  wire sfraddr_ARCON = sfraddr == ARCON_ID;

  //------------------------------------------------------------------
  // SFR arcon register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : arcon_sc_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    arcon_s[5:0] <= ARCON_RV[5:0] ;
    end
  else
    begin
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    ////if (sfrwe & sfraddr == ARCON_ID)
    if (sfrwe & sfraddr_ARCON )
      begin
      arcon_s[5:0] <= sfrdatai[5:0] ;
      end
    else
      begin
      //--------------------------------
      // load sc
      //--------------------------------
      if (ld_sc)
        begin
        arcon_s[4:0] <= ~(counter_st - 1'b1) ;
        end
      else if (oper_reg == ST5 | oper_reg == ST6)
        begin
        arcon_s[4:0] <= counter_nxt ;
        end
      end
    end
  end

  //------------------------------------------------------------------
  // SFR arcon register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : arcon_mdef_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    arcon_s[7] <= ARCON_RV[7] ;
    end
  else
    begin
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    if (sfroe & ( sfraddr_ARCON ) )
      begin
      arcon_s[7] <= 1'b0 ;
      end
    else
      begin
      //--------------------------------
      // mdef flag
      //--------------------------------
      if (setmdef)
        begin
        arcon_s[7] <= 1'b1 ;
        end
      end
    end
  end

  //------------------------------------------------------------------
  // SFR arcon register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : arcon_mdov_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    arcon_s[6] <= ARCON_RV[6] ;
    end
  else
    begin
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    // arcon[6] is read only
    // set or clear by hardware
    if      (setmdov == 1'b1)
      begin
      arcon_s[6] <= 1'b1;
      end
    else if (clrmdov == 1'b1)
      begin
      arcon_s[6] <= 1'b0;
      end
    end
  end

  //------------------------------------------------------------------
  // SFR md0 register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : md0_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    md0_s <= MD0_RV ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    begin
    if (sfrwe & sfraddr_MD0 )
      begin
      md0_s <= sfrdatai ;
      end
    else
      begin
      case (md30_sel)
        SHL :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md0_s <= {md0_s[5:0], 2'b00} ;
          end
        else
          begin
          md0_s <= {md0_s[6:0], 1'b0} ;
          end
        end

        SHR :
        begin
        if (counter_st[4] | counter_st[3] |
           counter_st[2] | counter_st[1])
          begin
          md0_s <= {md1_s[1:0], md0_s[7:2]} ;
          end
        else
          begin
          md0_s <= {md1_s[0], md0_s[7:1]} ;
          end
        end

        NORM :
        begin
        if (md3_s[6])
           begin
           md0_s <= {md0_s[6:0], 1'b0} ;
           end
        else
           begin
           md0_s <= {md0_s[5:0], 2'b00} ;
           end
        end

        DIV32, DIV16, LDRES :
        begin
        md0_s <= {md0_s[5:0], sum1[17], sum[17]} ;
        end

        MUL :
        begin
        md0_s <= {md1_s[1:0], md0_s[7:2]} ;
        end
        
        default : ;

      endcase
      end
    end
  end

  //------------------------------------------------------------------
  // SFR md1 register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : md1_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    md1_s <= MD1_RV ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    begin
    if (sfrwe & sfraddr_MD1 )
      begin
      md1_s <= sfrdatai ;
      end
    else
      begin
      case (md30_sel)
        SHL :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md1_s <= {md1_s[5:0], md0_s[7:6]} ;
          end
        else
          begin
          md1_s <= {md1_s[6:0], md0_s[7]} ;
          end
        end

        SHR :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md1_s <= {md2_s[1:0], md1_s[7:2]} ;
          end
        else
          begin
          md1_s <= {md2_s[0], md1_s[7:1]} ;
          end
        end

        NORM :
        begin
        if (md3_s[6])
          begin
          md1_s <= {md1_s[6:0], md0_s[7]} ;
          end
        else
          begin
          md1_s <= {md1_s[5:0], md0_s[7:6]} ;
          end
        end

        DIV32, DIV16, LDRES :
        begin
        md1_s <= {md1_s[5:0], md0_s[7:6]} ;
        end

        MUL :
        begin
        md1_s <= {sum[1], sum1[1], md1_s[7:2]} ;
        end
        
        default : ;

      endcase
      end
    end
  end

  //------------------------------------------------------------------
  // SFR md2 register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : md2_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    md2_s <= MD2_RV ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    begin
    if (sfrwe & sfraddr_MD2)
      begin
      md2_s <= sfrdatai ;
      end
    else
      begin
      case (md30_sel)
        SHL :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md2_s <= {md2_s[5:0], md1_s[7:6]} ;
          end
        else
          begin
          md2_s <= {md2_s[6:0], md1_s[7]} ;
          end
        end

        SHR :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md2_s <= {md3_s[1:0], md2_s[7:2]} ;
          end
        else
          begin
          md2_s <= {md3_s[0], md2_s[7:1]} ;
          end
        end

        NORM :
        begin
        if (md3_s[6])
          begin
          md2_s <= {md2_s[6:0], md1_s[7]} ;
          end
        else
          begin
          md2_s <= {md2_s[5:0], md1_s[7:6]} ;
          end
        end

        DIV32, LDRES :
        begin
        md2_s <= {md2_s[5:0], md1_s[7:6]} ;
        end

        MUL :
        begin
        md2_s <= sum[9:2] ;
        end

        MD32RST :
        begin
        md2_s <= 8'b00000000 ;
        end
        
        default : ;

      endcase
      end
    end
  end

  //------------------------------------------------------------------
  // SFR md3 register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : md3_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    md3_s <= MD3_RV ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    begin
    if (sfrwe & sfraddr_MD3)
      begin
      md3_s <= sfrdatai ;
      end
    else
      begin
      case (md30_sel)
        SHL :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md3_s <= {md3_s[5:0], md2_s[7:6]} ;
          end
        else
          begin
          md3_s <= {md3_s[6:0], md2_s[7]} ;
          end
        end

        SHR :
        begin
        if (counter_st[4] | counter_st[3] |
            counter_st[2] | counter_st[1])
          begin
          md3_s <= {2'b00, md3_s[7:2]} ;
          end
        else
          begin
          md3_s <= {1'b0, md3_s[7:1]} ;
          end
        end

        NORM :
        begin
        if (md3_s[6])
          begin
          md3_s <= {md3_s[6:0], md2_s[7]} ;
          end
        else
          begin
          md3_s <= {md3_s[5:0], md2_s[7:6]} ;
          end
        end

        DIV32, LDRES :
        begin
        md3_s <= {md3_s[5:0], md2_s[7:6]} ;
        end

        MUL :
        begin
        md3_s <= sum[17:10] ;
        end

        MD32RST :
        begin
        md3_s <= 8'b00000000 ;
        end
        
        default : ;

       endcase
       end
    end
  end

  //------------------------------------------------------------------
  // SFR md4 register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : md4_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    md4_s <= MD4_RV ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    begin
    if (sfrwe & sfraddr_MD4 )
      begin
      md4_s <= sfrdatai ;
      end
    else
      begin
      case (md30_sel)
        LDRES :
        begin
        case (mdu_op)
          MDU_DIV32 :
          begin
          if (sum[17])
            begin
            md4_s <= sum[8:1] ;
            end
          else
            begin
            if (sum1[17])
              begin
              md4_s <= {sum1[7:1], md3_s[6]} ;
              end
            else
              begin
              md4_s <= {norm_reg[5:0], md3_s[7:6]} ;
              end
            end
          end

          default : // MDU_DIV16
          begin
          if (sum[17])
            begin
            md4_s <= sum[8:1] ;
            end
          else
            begin
            if (sum1[17])
              begin
              md4_s <= {sum1[7:1], md1_s[6]} ;
              end
            else
              begin
              md4_s <= {norm_reg[5:0], md1_s[7:6]} ;
              end
            end
          end

        endcase
        end
        
        default : ;

      endcase
      end
    end
  end

  //------------------------------------------------------------------
  // SFR md5 register write
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : md5_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    md5_s <= MD5_RV ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    // Special function register write
    //--------------------------------
    begin
    if (sfrwe & sfraddr_MD5 )
      begin
      md5_s <= sfrdatai ;
      end
    else
      begin
      case (md30_sel)
        LDRES :
        begin
        if (sum[17])
          begin
          md5_s <= sum[16:9] ;
          end
        else
          begin
          if (sum1[17])
            begin
            md5_s <= sum1[15:8] ;
            end
          else
            begin
            md5_s <= norm_reg[13:6] ;
            end
          end
        end
        
        default : ;

      endcase
      end
    end
  end

  //------------------------------------------------------------------
  // norm_reg register
  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : norm_reg_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    norm_reg <= 16'b0000000000000000 ;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    begin
    case (md30_sel)
      DIV32 :
      begin
      if (sum[17])
        begin
        norm_reg <= sum[16:1] ;
        end
      else
        begin
        if (sum1[17])
          begin
          norm_reg <= {sum1[15:1], md3_s[6]} ;
          end
        else
          begin
          norm_reg <= {norm_reg[13:0], md3_s[7:6]} ;
          end
        end
      end

      DIV16 :
      begin
      if (sum[17])
        begin
        norm_reg <= sum[16:1] ;
        end
      else
        begin
        if (sum1[17])
          begin
          norm_reg <= {sum1[15:1], md1_s[6]} ;
          end
        else
          begin
          norm_reg <= {norm_reg[13:0], md1_s[7:6]} ;
          end
        end
      end

      default :
      begin
      norm_reg <= 16'b0000000000000000 ;
      end

    endcase
    end
  end

  //------------------------------------------------------------------
  // counter
  //------------------------------------------------------------------
  always @(counter_sel or counter_st or arcon_s or md3_s or md30_sel)
  begin : counter_comb_proc
  //------------------------------------------------------------------
  // Initial assignment
  counter_nxt = 5'b00000 ;
  
  case (counter_sel)
    2'b11 :   //dec
    begin
    case (md30_sel)
      DIV16, DIV32, MUL :
      begin
      counter_nxt = counter_st - 2'b10 ;
      end

      SHR :
      begin
      if (
            counter_st[4] |
            counter_st[3] |
            counter_st[2] |
            counter_st[1]
         )
        begin
        counter_nxt = counter_st - 2'b10 ;
        end
      else
        begin
        counter_nxt = counter_st - 1'b1 ;
        end
      end

      SHL :
      begin
      if (
            counter_st[4] |
            counter_st[3] |
            counter_st[2] |
            counter_st[1]
         )
        begin
        counter_nxt = counter_st - 2'b10 ;
        end
      else
        begin
        counter_nxt = counter_st - 1'b1 ;
        end
      end

      default :
      begin
      if (md3_s[6])
        begin
        counter_nxt = counter_st - 1'b1 ;
        end
      else
        begin
        counter_nxt = counter_st - 2'b10 ;
        end
      end

    endcase
    end

    2'b01 :   //load
    begin
    counter_nxt = arcon_s[4:0] ;
    end

    default : // reset
    begin
    counter_nxt = 5'b00000 ;
    end

  endcase
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : counter_sync_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    counter_st <= 5'b00000 ;
    end
  else
    begin
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    counter_st <= counter_nxt ;
    end
  end

  //------------------------------------------------------------------
  // adder
  //------------------------------------------------------------------
  always @(md1_s or md2_s or md3_s or mdu_op or norm_reg)
  begin : arg_a_comb_proc
  //------------------------------------------------------------------
  //-------------------------------
  //           arg_a             --
  //-------------------------------
  // default
  arg_a = {1'b0, md3_s, md2_s, 1'b0};
  
  case (mdu_op)
    MDU_DIV16 :
    begin
    arg_a = {norm_reg, md1_s[7], 1'b1};
    end

    MDU_DIV32 :
    begin
    arg_a = {norm_reg, md3_s[7], 1'b1};
    end

    default :
    begin
    arg_a = {1'b0, md3_s, md2_s, 1'b0};
    end

  endcase
  end

  //------------------------------------------------------------------
  // adder
  //------------------------------------------------------------------
  always @(md0_s or md4_s or md5_s or mdu_op)
  begin : arg_b_comb_proc
  //------------------------------------------------------------------
  //-------------------------------
  //           arg_b             --
  //-------------------------------
  // default
  arg_b = {1'b0, ~md5_s, ~md4_s, 1'b1};
  
  case (mdu_op)
    MDU_MUL :
    begin
    if (md0_s[0])
      begin
      arg_b = {1'b0, md5_s, md4_s, 1'b0};
      end
    else
      begin
      arg_b = {18{1'b0}};
      end
    end

    default :
    begin
    arg_b = {1'b0, ~md5_s, ~md4_s, 1'b1};
    end

  endcase
  end

  //------------------------------------------------------------------
  // adder
  //------------------------------------------------------------------
  // sum1_drv
  //------------------------------------------------------------------
  assign sum1 = arg_a + arg_b ;

  //------------------------------------------------------------------
  // adder
  //------------------------------------------------------------------
  always @(md1_s or md3_s or mdu_op or norm_reg or sum1)
  begin : arg_c_comb_proc
  //------------------------------------------------------------------
  //-------------------------------
  //           arg_c             --
  //-------------------------------
  case (mdu_op)
    MDU_DIV16 :
    begin
    if (sum1[17])  //CY=1
      begin
      arg_c = {sum1[16:1], md1_s[6], 1'b1};
      end
    else
      begin
      arg_c = {norm_reg [14:0], md1_s[7:6], 1'b1};
      end
    end

    MDU_DIV32 :
    begin
    if (sum1[17])  //CY=1
      begin
      arg_c = {sum1[16:1], md3_s[6], 1'b1};
      end
    else
      begin
      arg_c = {norm_reg [14:0], md3_s[7:6], 1'b1};
      end
    end

    default :
    begin
    arg_c = {1'b0, sum1[17:2], 1'b0};
    end

  endcase
  end

  //------------------------------------------------------------------
  // adder
  //------------------------------------------------------------------
  always @(md0_s or md4_s or md5_s or mdu_op)
  begin : arg_d_comb_proc
  //------------------------------------------------------------------
  //-------------------------------
  //           arg_d             --
  //-------------------------------
  case (mdu_op)
    MDU_MUL :
    begin
    if (md0_s[1])
      begin
      arg_d = {1'b0, md5_s, md4_s, 1'b0};
      end
    else
      begin
      arg_d = {18{1'b0}};
      end
    end

    default :
    begin
    arg_d = {1'b0, ~md5_s, ~md4_s, 1'b1};
    end

  endcase
  end

  //------------------------------------------------------------------
  // adder
  //------------------------------------------------------------------
  // sum_drv
  //------------------------------------------------------------------
  assign sum = arg_c + arg_d ;

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : set_div16_mul
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    set_div16 <= 1'b0;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    begin
    if      (sfrwe & sfraddr_MD4 )
      begin
      set_div16 <= 1'b1; // division 16/16
      end
    else if (sfrwe & sfraddr_MD1 )
      begin
      set_div16 <= 1'b0; // multiplication 16x16
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : set_div32_proc
  //------------------------------------------------------------------
  if (rst)
    //----------------------------------
    // Synchronous reset
    //----------------------------------
    begin
    set_div32 <= 1'b0;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    begin
    if      (sfrwe & (sfraddr_MD2 | sfraddr_MD3 ))
      begin
      set_div32 <= 1'b1; // division 32/16
      end
    else if (sfrwe & (sfraddr_MD0 | sfraddr_MD5 |
                      sfraddr_ARCON ))
      begin
      set_div32 <= 1'b0; // division 16/16 or multiplication
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : set_mdu
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    mdu_op <= MDU_MUL;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    begin
    if      (sfrwe & sfraddr_ARCON )
      begin
      mdu_op <= MDU_SHIFT;
      end
    else if (sfrwe & sfraddr_MD5 )
      begin
      if (set_div32)
        begin
        mdu_op <= MDU_DIV32;
        end
      else if (set_div16)
        begin
        mdu_op <= MDU_DIV16;
        end
      else
        begin
        mdu_op <= MDU_MUL;
        end
      end
    end
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : set_error_flag
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    setmdef <= 1'b0;
    end
  else
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    begin
    if (((sfrwe & sfraddr_ARCON ) |
         (sfrwe & sfraddr_MD5 ) |
         (sfrwe & sfraddr_MD4 ) |
         (sfrwe & sfraddr_MD3 ) |
         (sfrwe & sfraddr_MD2 ) |
         (sfrwe & sfraddr_MD1 ) |
         (sfrwe & sfraddr_MD0 ) |
         (sfroe & sfraddr_MD5 ) |
         (sfroe & sfraddr_MD4 ) |
         (sfroe & sfraddr_MD3 ) |
         (sfroe & sfraddr_MD2 ) |
         (sfroe & sfraddr_MD1 ) |
         (sfroe & sfraddr_MD0 )) & !opend)
      begin
      setmdef <= 1'b1;
      end
    else
      begin
      setmdef <= 1'b0;
      end
    end
  end

  //------------------------------------------------------------------
  // arithmetic operation FSM
  //------------------------------------------------------------------
  always @(oper_reg or md2_s or md3_s or md4_s or md5_s or counter_st
           or mdu_op or arcon_s)
  begin : oper_comb_proc
  //------------------------------------------------------------------
  // Default values
  md30_sel      = NOP_ ;
  counter_sel   = 2'b10 ;       //reset
  ld_sc         = 1'b0 ;        //nop
  opend         = 1'b1 ;        //operation end
  setmdov       = 1'b0 ;        //set mdov flag
  clrmdov       = 1'b0 ;        //clear mdov flag
  oper_nxt      = ST0 ;

  case (oper_reg)
    ST1 :
    begin
    md30_sel      = NOP_ ;
    counter_sel   = 2'b01 ;       //load(count<-sc)
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    if (arcon_s[4:0] == 5'b00000)
      begin
      if (md3_s[7])
        begin
        oper_nxt = ST8 ;
        end
      else
        begin
        oper_nxt = ST7 ;
        end
      end
    else
      begin
      if (arcon_s[5])
        begin
        oper_nxt = ST5 ;
        end
      else
        begin
        oper_nxt = ST6 ;
        end
      end
    end

    ST2 :
    begin
    md30_sel      = MUL ;
    counter_sel   = 2'b11 ;       //dec
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    if (counter_st == 5'b10010)
      begin
      oper_nxt = ST9 ;
      end
    else
      begin
      oper_nxt = ST2 ;
      end
    end

    ST3 :
    begin
    md30_sel      = DIV16 ;
    counter_sel   = 2'b11 ;       //dec
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    if (counter_st == 5'b10100)
      begin
      oper_nxt = ST10 ;
      end
    else
      begin
      oper_nxt = ST3 ;
      end
    end

    ST4 :
    begin
    md30_sel      = DIV32 ;
    counter_sel   = 2'b11 ;       //dec
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    if (counter_st == 5'b00100)
      begin
      oper_nxt = ST10 ;
      end
    else
      begin
      oper_nxt = ST4 ;
      end
    end

    ST5 :
    begin
    md30_sel      = SHR ;
    counter_sel   = 2'b11 ;       //dec
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    if (counter_st[4:2] == 3'b000 &
        counter_st[1:0] != 2'b11)
      begin
      oper_nxt = ST0 ;
      end
    else
      begin
      oper_nxt = ST5 ;
      end
    end

    ST6 :
    begin
    md30_sel      = SHL ;
    counter_sel   = 2'b11 ;       //dec
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    if (counter_st[4:2] == 3'b000 &
        counter_st[1:0] != 2'b11)
      begin
      oper_nxt = ST0 ;
      end
    else
      begin
      oper_nxt = ST6 ;
      end
    end

    ST7 :
    begin
    md30_sel      = NORM ;
    counter_sel   = 2'b11 ;       //dec
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b1 ;        //clear mdov flag
    if ((md3_s[6]) | (md3_s[5]) | counter_st == 5'b00010)
      begin
      oper_nxt = ST11 ;
      end
    else
      begin
      oper_nxt = ST7 ;
      end
    end

    ST8 :
    begin
    md30_sel      = NOP_ ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b1 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    oper_nxt      = ST0 ;
    end

    ST9 :
    begin
    md30_sel      = NOP_ ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    if (md2_s == 8'b00000000 &
        md3_s == 8'b00000000)       // result greater then 0000FFFFH
      begin
      setmdov  = 1'b0 ;
      clrmdov  = 1'b1 ;           //clear mdov flag
      end
    else
      begin
      setmdov  = 1'b1 ;           //set mdov flag
      clrmdov  = 1'b0 ;
      end
    oper_nxt      = ST0 ;
    end

    ST10 :
    begin
    md30_sel      = LDRES ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    if (md4_s == 8'b00000000 & md5_s == 8'b00000000)
      begin
      setmdov = 1'b1 ;            //set mdov flag
      clrmdov = 1'b0 ;
      end
    else
      begin
      setmdov = 1'b0 ;
      clrmdov = 1'b1 ;            //clear mdov flag
      end
    oper_nxt      = ST0 ;
    end

    ST11 :
    begin
    md30_sel      = NOP_ ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b1 ;        //load sc
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    oper_nxt      = ST0 ;
    end

    ST12 :
    begin
    md30_sel      = NOP_ ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    case (mdu_op)
      MDU_SHIFT :
      begin
      oper_nxt = ST1 ;
      end

      MDU_DIV16 :
      begin
      oper_nxt = ST3 ;
      end

      MDU_DIV32 :
      begin
      oper_nxt = ST4 ;
      end

      default :
      begin
      oper_nxt = ST13 ;
      end

    endcase
    end

    ST13 :
    begin
    md30_sel      = MD32RST ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b0 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    oper_nxt      = ST2 ;
    end

    default : // ST0
    begin
    md30_sel      = NOP_ ;
    counter_sel   = 2'b10 ;       //reset
    ld_sc         = 1'b0 ;        //nop
    opend         = 1'b1 ;        //operation end
    setmdov       = 1'b0 ;        //set mdov flag
    clrmdov       = 1'b0 ;        //clear mdov flag
    oper_nxt      = ST0 ;
    end

  endcase
  end

  //------------------------------------------------------------------
  always @(posedge clkper)
  begin : oper_sync_proc
  //------------------------------------------------------------------
  if (rst)
    //-----------------------------------
    // Synchronous reset
    //-----------------------------------
    begin
    oper_reg <= ST0 ;
    end
  else
    begin
    //-----------------------------------
    // Synchronous write
    //-----------------------------------
    if (sfrwe & (sfraddr_ARCON | sfraddr_MD5 ))
      begin
      oper_reg <= ST12 ;
      end
    else
      begin
      oper_reg <= oper_nxt ;
      end
    end
  end

  //------------------------------------------------------------------
  // SFR outputs
  //------------------------------------------------------------------
  assign arcon = arcon_s;
  assign md0   = md0_s;
  assign md1   = md1_s;
  assign md2   = md2_s;
  assign md3   = md3_s;
  assign md4   = md4_s;
  assign md5   = md5_s;

endmodule // mdu

