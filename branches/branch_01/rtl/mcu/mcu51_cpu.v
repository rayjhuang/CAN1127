
module mcu51_cpu (
  clkcpu,
  rst,
  mempsack,
  memack,
  memdatai,
  memaddr,
  mempsrd,
  mempswr,
  memrd,
  memwr,
  memaddr_comb,
  mempsrd_comb,
  mempswr_comb,
  memrd_comb,
  memwr_comb,
  cpu_hold,
  cpu_resume,
  irq,
  intvect,
  intcall,
  retiinstr,
  newinstr,
  rmwinstr,
  waitstaten,
  ramdatai,
  sfrdatai,
  ramsfraddr,
  ramdatao,
  ramoe,
  ramwe,
  sfroe,
  sfrwe,
  sfroe_r,
  sfrwe_r,

  sfroe_comb_s,
  sfrwe_comb_s,

  pc_o,
  pc_ini,
  cs_run,
  instr,
  codefetch_s,

  sfrack,
  ramsfraddr_comb,
  ramdatao_comb,
  ramoe_comb,
  ramwe_comb,
  ckcon,
  pmw,
  p2sel,
  gf0,
  stop,
  idle,
  acc,
  b,
  rs,
  c,
  ac,
  ov,
  p,
  f0,
  f1,
  dph,
  dpl,
  dps,
  dpc,
  p2,
  sp
  );

  // Parameter definition file
  `include "mcu51_param.v"

  // Global signals
  input             clkcpu;    // Main clock input
  input             rst;       // Synchronous reset input

  // Program Memory / External Data Memory interface
  input             mempsack;  // Program Memory acknowledge
  input             memack;    // Ext. Data Memory acknowledge
  input     [ 7: 0] memdatai;  // Program / Ext. Data Memory data bus
  output    [15: 0] memaddr;   // Program / Ext. Data Memory address bus
  wire      [15: 0] memaddr;
  output            mempsrd;   // Program Memory Read output
  wire              mempsrd;
  output            mempswr;   // Program Memory Write output
  wire              mempswr;
  output            memrd;     // External Data Memory Read output
  wire              memrd;
  output            memwr;     // External Data Memory Write output
  wire              memwr;

  // Combinational interface to work with positive edge clocked memories
  output    [15: 0] memaddr_comb;   // Program / Ext. Data Memory address bus
  wire      [15: 0] memaddr_comb;
  output            mempsrd_comb;   // Program Memory Read output
  wire              mempsrd_comb;
  output            mempswr_comb;   // Program Memory Write output
  wire              mempswr_comb;
  output            memrd_comb;     // External Data Memory Read output
  wire              memrd_comb;
  output            memwr_comb;     // External Data Memory Write output
  wire              memwr_comb;

  // Power Management Unit interface
  input             cpu_resume;// Resume from Power-down Mode
  input             cpu_hold;
  // Interrupt Controller interface
  input             irq;       // Interrupt Request signal
  input     [ 4: 0] intvect;   // Interrupt Vector input
  output            intcall;   // Interrupt Call indicator (acknowledge)
  wire              intcall;
  output            retiinstr; // Return From Interrupt indicator
  wire              retiinstr;
  // Instruction decoder outputs
  output            newinstr;  // Beginning of new instruction indicator
  wire              newinstr;
  output            rmwinstr;  // Read-Modify-Write instruction indicator
  reg               rmwinstr;
  output            waitstaten;
  wire              waitstaten;
  // On-Chip RAM (IRAM) and SFR interface
  input     [ 7: 0] ramdatai;   // IRAM data bus input
  input     [ 7: 0] sfrdatai;
  output    [ 7: 0] ramsfraddr; // Shared IRAM / SFR address bus
  wire      [ 7: 0] ramsfraddr;
  output    [ 7: 0] ramdatao;   // Shared IRAM / SFR / Program /
  wire      [ 7: 0] ramdatao;   // / Ext. Data Memory data output (for writing)
  output            ramoe;      // IRAM read enable
  wire              ramoe;
  output            ramwe;      // IRAM write enable
  wire              ramwe;
  output            sfroe;      // SFR read enable
  wire              sfroe;
  output            sfrwe;      // SFR write enable
  wire              sfrwe;
  output            sfroe_r;    // SFR read enable (registered)
  reg               sfroe_r;
  output            sfrwe_r;    // SFR write enable (registered)
  reg               sfrwe_r;

  output            sfroe_comb_s,
                    sfrwe_comb_s;
  output            cs_run;
  output    [15:0]  pc_o;
  input     [15:0]  pc_ini;
  output    [7:0]   instr;
  output            codefetch_s;

  input             sfrack;     // SFR acknowledge
  // Combinational interface for positive edge clocked memories
  output    [ 7: 0] ramsfraddr_comb; // Shared IRAM / SFR address bus
  wire      [ 7: 0] ramsfraddr_comb;
  output    [ 7: 0] ramdatao_comb;   // Shared IRAM / SFR / Program /
  wire      [ 7: 0] ramdatao_comb;   // / Ext. Data Memory data output (for writing)
  output            ramoe_comb;      // IRAM read enable
  wire              ramoe_comb;
  output            ramwe_comb;      // IRAM write enable
  wire              ramwe_comb;

  // Special Function Registers outputs (to the mux)
  output    [ 7: 0] ckcon;      // Clock Control Register
  wire      [ 7: 0] ckcon;      //   (wait state control)
  output            pmw;        // Program Memory Write flag of PCON
  wire              pmw;
  output            p2sel;      // Port 2 or Constant value
  wire              p2sel;      //  for MOVX @Ri selection flag of PCON
  output            gf0;        // General Purpose flag of PCON
  reg               gf0;
  output            stop;       // Stop Mode request to PMU
  wire              stop;
  output            idle;       // Idle Mode request to PMU
  wire              idle;
  output    [ 7: 0] acc;        // Accumulator register
  wire      [ 7: 0] acc;
  output    [ 7: 0] b;          // B register
  wire      [ 7: 0] b;
  output    [ 1: 0] rs;         // Register Bank select field of PSW
  wire      [ 1: 0] rs;
  output            c;          // Carry flag of PSW
  wire              c;
  output            ac;         // Auxiliary Carry flag of PSW
  wire              ac;
  output            ov;         // Overflow flag of PSW
  wire              ov;
  output            p;          // Parity flag of PSW
  reg               p;
  output            f0;         // General purpose flag 0 of PSW
  reg               f0;
  output            f1;         // General purpose flag 1 of PSW
  reg               f1;
  output    [ 7: 0] dph;        // Data Pointer higher byte
  wire      [ 7: 0] dph;
  output    [ 7: 0] dpl;        // Data Pointer lower byte
  wire      [ 7: 0] dpl;
  output    [ 3: 0] dps;        // Data Pointer select register
  wire      [ 3: 0] dps;
  output    [ 5: 0] dpc;        // Data Pointer Configuration register
  wire      [ 5: 0] dpc;
  output    [ 7: 0] p2;         // Port 2 register (used for addressing)
  wire      [ 7: 0] p2;
  output    [ 7: 0] sp;         // Stack Pointer register
  wire      [ 7: 0] sp;

//*******************************************************************--

  // Internally generated Wait States
  reg       [ 2: 0] waitcnt;    // Internal wait state counter (sync)
  wire      [ 7: 0] ckcon_s;    // Clock Control SFR register
  reg       [ 7: 0] ckcon_r;    // Clock Control SFR register

  // Program Counter
  reg      [15: 0] pc_comb;
  reg      [15: 0] pc;
assign pc_o = pc;
  wire     [15: 0] pc_i;	// increased PC
  // Program Counter control signals
  wire             pc_inc;      // Increment
  wire             dptrbranch;  // Branch after DPTR
  wire             apcbranch;   // Branch after acc+PC


  // RAM/SFR access
  reg              ramwe_r;     // RAM write signal
  reg              ramoe_r;     // RAM read signal
  reg              ramwe_r_int;
  reg              ramoe_r_int;
  reg              ramsfrwe;    // RAM write signal (direct addressing mode)
  reg              ramsfroe;    // RAM read signal (direct addressing mode)
  wire     [ 7: 0] ramsfrdata;  // Data returned from RAM/SFR (direct addr.mode)
  reg      [ 2: 0] bitno;       // Bit number decoder for bitwise addressing mode

  // Control Unit FSM
  reg      [ 2: 0] state;       // State register
  reg      [ 2: 0] state_nxt;   // Next state
  // FSM state codes
  `define  STATE_IDLE  3'b000
  `define  STATE_RUN   3'b001
  assign            cs_run = state == `STATE_RUN;

  // Instruction register
  reg      [ 7: 0] instr;
  reg              interrupt;   // interrupt in progress
  wire             irq_int;

  // 8-bit ALU
  reg      [ 7: 0] adder_out;   // data output
  reg              adder_ov;    // overflow output
  reg              adder_c;     // carry output
  reg              adder_ac;    // auxiliary carry output

  // Temporary registers
  reg      [ 7: 0] temp;
  reg      [ 7: 0] temp2;

  // 16-bit ALU (for PC/DPTR operations)
  reg      [16: 0] alu_out;

  // Instruction microoperations decoder
  parameter MAX_CYCLES = 5;

  reg      [MAX_CYCLES: 0] phase;               // phase counter
  reg      [MAX_CYCLES: 0] dec_newinstr;        // instruction length
  reg      [MAX_CYCLES: 0] dec_fetch;           // 2nd or 3rd byte fetch

  reg      [MAX_CYCLES: 0] dec_ramsfr_dir;      // RAM/SFR direct addressing mode
  reg      [MAX_CYCLES: 0] dec_ramsfr_rn;       // RAM Rn access
  reg      [MAX_CYCLES: 0] dec_ramsfr_ri;       // RAM Ri access
  reg      [MAX_CYCLES: 0] dec_ramsfr_bit;      // RAM/SFR bit addressing mode
  reg      [MAX_CYCLES: 0] dec_ramsfr_temp;     //
  reg      [MAX_CYCLES: 0] dec_ramsfr_sp;       // RAM stack addressing mode
  reg      [MAX_CYCLES: 0] dec_ramsfr_spinc;    // RAM stack addressing mode
  reg      [MAX_CYCLES: 0] dec_ramsfr_wr;       // RAM/SFR write
  reg      [MAX_CYCLES: 0] dec_ramsfr_rd;       // RAM/SFR read
  reg      [MAX_CYCLES: 0] dec_ram_rd;          // RAM read
  reg      [MAX_CYCLES: 0] dec_ram_wr;          // RAM write
  reg      [MAX_CYCLES: 0] dec_pcdptr_exch;     // PC<->DPTR exchange
  reg      [MAX_CYCLES: 0] dec_dparith_exe;     // DPTR auto-modify
  reg      [MAX_CYCLES: 0] dec_memwr;           // Ext.data memory read
  reg      [MAX_CYCLES: 0] dec_memrd;           // Ext.data memory write
  reg      [MAX_CYCLES: 0] dec_mempsrd;         // Program memory read
  reg      [MAX_CYCLES: 0] dec_movxp2pc;        // MOVX @Ri loads PC temporarily
  reg      [MAX_CYCLES: 0] dec_pcl_mem;         //
  reg      [MAX_CYCLES: 0] dec_pch_temp;        //
  reg      [MAX_CYCLES: 0] dec_dpl_temp;        //
  reg      [MAX_CYCLES: 0] dec_dph_temp;        //

  reg      [MAX_CYCLES: 0] dec_acc_ramsfr;      // acc write from RAM/SFR
  reg      [MAX_CYCLES: 0] dec_acc_ramdata;     // acc write from RAM
  reg      [MAX_CYCLES: 0] dec_acc_mem;         // acc write from Program/Ext.data mem.

  reg      [MAX_CYCLES: 0] dec_temp_mem;        // Temporary register load from Program/Ext.data mem.
  reg      [MAX_CYCLES: 0] dec_temp2_mem;       // Temporary register 2 load from Program/Ext.data mem.
  reg      [MAX_CYCLES: 0] dec_temp2temp;       // Temporary register 2 load from temporary reg. 1
  reg      [MAX_CYCLES: 0] dec_temp_acc;        // Temporary register load from acc
  reg      [MAX_CYCLES: 0] dec_acc2temp;        // Temporary register 2 load from acc
  reg      [MAX_CYCLES: 0] dec_pc2temp;         // Temporary register 2 load from PC
  reg      [MAX_CYCLES: 0] dec_pci2temp;
  reg      [MAX_CYCLES: 0] dec_acc_rn;          //
  reg      [MAX_CYCLES: 0] dec_temp2acc;        // acc_reg load from temporary register 2
  reg      [MAX_CYCLES: 0] dec_temp_ramdata;    // Temporary register load from RAM
  reg      [MAX_CYCLES: 0] dec_temp2_ramdata;   // Temporary register 2 load from RAM
  reg      [MAX_CYCLES: 0] dec_tempint;         // Temporary register 2 load with interrupt vector

  reg      [MAX_CYCLES: 0] dec_relbranch;       // Relative branch
  reg      [MAX_CYCLES: 0] dec_absbranch;       // Absolute branch
  reg      [MAX_CYCLES: 0] dec_longbranch;      // Long branch
  reg      [MAX_CYCLES: 0] dec_dptrbranch;      // Branch after DPTR
  reg      [MAX_CYCLES: 0] dec_apcbranch;       // Branch after acc+PC

  reg      [MAX_CYCLES: 0] dec_rn_inc;          //
  reg      [MAX_CYCLES: 0] dec_rn_dec;          //
  reg      [MAX_CYCLES: 0] dec_rn_acc;
  reg      [MAX_CYCLES: 0] dec_ramdata_inc;     //
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_inc;     //
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_dec;     //
  reg      [MAX_CYCLES: 0] dec_ramdata_dec;     //
  reg      [MAX_CYCLES: 0] dec_incdec_store;    //

  reg      [MAX_CYCLES: 0] dec_anlorl_temp;

  reg      [MAX_CYCLES: 0] dec_ramsfrdata_setb;
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_clrb;
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_cplb;
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_movb;

  reg      [MAX_CYCLES: 0] dec_temp_ramsfrdata;
  reg      [MAX_CYCLES: 0] dec_temp2_rn;


  reg      [MAX_CYCLES: 0] dec_acccomb_store;

  reg      [MAX_CYCLES: 0] dec_pch_store;
  reg      [MAX_CYCLES: 0] dec_pcl_store;
  reg      [MAX_CYCLES: 0] dec_pchinc_store;
  reg      [MAX_CYCLES: 0] dec_pclinc_store;
  reg      [MAX_CYCLES: 0] dec_pclinc2_store;
  reg      [MAX_CYCLES: 0] dec_pchinc2_store;

  wire                     dec_xchd;            // XCHD instruction decoder

  reg                      accactv;         // ALU activity decoder

  reg                      finishmul;       // MUL instruction decoder
  reg                      finishdiv;       // DIV instruction decoder


  reg      [MAX_CYCLES: 0] dec_spinc;           // Stack pointer increment
  reg      [MAX_CYCLES: 0] dec_spdec;           // Stack pointer decrement

  reg      [MAX_CYCLES: 0] dec_ramsfrdata_anl;
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_orl;
  reg      [MAX_CYCLES: 0] dec_ramsfrdata_xrl;
  reg      [MAX_CYCLES: 0] dec_anlorl_store;
  reg              [ 7: 0] anlorl_out;

  reg      [MAX_CYCLES: 0] dec_flush;
  wire                     flush_s;

  reg                      rmwinstr_comb;

  reg              [ 7: 0] dec_rn_ramsfr;
  reg              [ 7: 0] dec_ramsfrdata_ramsfrdata;
  reg              [ 7: 0] dec_ramsfrdata_ramdata;

  reg              [ 7: 0] dec_pcl_ramdata;

  reg                      dec_dptrinc;

  wire                     pcdptr_exch;         // PC<->DPTR exchange
  wire                     relbranch;           // Relative branch
  wire                     absbranch;           // Absolute branch
  wire                     longbranch;          // Long branch
  wire                     newinstr_c;          // New instruction decoder

  wire                     datafetch_s;         // 2nd or 3rd byte fetch decoder
  reg                      mempsrd_r;
  wire                     mempsrd_s;
  reg                      mempswr_s;
  reg                      memrd_s;
  reg                      memwr_s;
  reg              [ 7: 0] ramsfraddr_s;
  wire                     datafetch_nxt;
  wire                     waitstate;

  wire             [ 7: 0] ramdatao_s;
  reg              [ 7: 0] ramdatao_r;
//`ifdef FPGA
//   LCELL_BUS8 dly_ramdo (.in(ramdatao_r),.out(ramdatao_s));
//   LCELL dy0x_mempsrd   (.in(mempsrd_r),   .out(dy0_mempsrd)),
//         dy1x_mempsrd   (.in(dy0_mempsrd), .out(mempsrd));
//   assign mempsrd_s  = mempsrd_r;
//`else
   assign ramdatao_s = ramdatao_r;
   assign mempsrd_s  = mempsrd_r;
   assign mempsrd    = mempsrd_s;
//`endif

  reg              [ 7: 0] ramsfraddr_comb_s;
  wire             [ 7: 0] ramsfraddr_comb_nxt;
  reg              [ 7: 0] ramdatao_comb_s;
  reg                      ramsfroe_comb;
  reg                      ramsfrwe_comb;
  reg                      ramoe_comb_int;
  reg                      ramwe_comb_int;

  reg                      mempsrd_comb_s;
  reg                      mempswr_comb_s;
  reg                      memrd_comb_s;
  reg                      memwr_comb_s;

  wire                     ramoe_comb_s;
  wire                     ramwe_comb_s;
  wire                     sfroe_comb_s;
  wire                     sfrwe_comb_s;

  // ALU operation decoder
  parameter MAX_ACCDEC = 18;

  reg      [MAX_ACCDEC: 0] dec_accop;           // ALU operation
  `define  ACC_RR      [0]
  `define  ACC_RRC     [1]
  `define  ACC_SWAP    [2]
  `define  ACC_RL      [3]
  `define  ACC_RLC     [4]
  `define  ACC_INC     [5]
  `define  ACC_DEC     [6]
  `define  ACC_ADDTMP  [7]
  `define  ACC_ADDCTMP [8]
  `define  ACC_SUBTMP  [9]
  `define  ACC_SUBBTMP [10]
  `define  ACC_ORLTMP2 [11]
  `define  ACC_ANLTMP2 [12]
  `define  ACC_XRLTMP2 [13]
  `define  ACC_CLR     [14]
  `define  ACC_CPL     [15]
  `define  ACC_MUL     [16]
  `define  ACC_DIV     [17]
  `define  ACC_DA      [18]

  // Bitwise carry operations decoder
  parameter MAX_CDEC = 7;

  reg      [MAX_CDEC: 0] dec_cop;               // Carry operation
  `define  C_SET    [0]
  `define  C_CLR    [1]
  `define  C_MOV    [2]
  `define  C_ORL    [3]
  `define  C_ANL    [4]
  `define  C_ORLN   [5]
  `define  C_ANLN   [6]
  `define  C_CPL    [7]

  // Branch condition decoder
  parameter MAX_BRANCHCOND = 6;
  reg      [MAX_BRANCHCOND:0] dec_branchcond;   // Branch condition decoder

  `define  BRANCH_TRUE      [0]
  `define  BRANCH_ACCZERO   [1]
  `define  BRANCH_ACCNZERO  [2]
  `define  BRANCH_BIT       [3]
  `define  BRANCH_NBIT      [4]
  `define  BRANCH_C         [5]
  `define  BRANCH_NC        [6]

  // Special Function Registers
  reg      [ 7: 0] acc_reg;                         // Accumulator
  reg      [ 7: 0] b_reg;                           // b_reg register
  reg      [ 7: 0] dpl_reg [NO_DPTRS-1:0];          // Data Pointer Low table
  reg      [ 7: 0] dph_reg [NO_DPTRS-1:0];          // Data Pointer High table
  reg      [ 3: 0] dps_reg;                         // Data Pointer Select Flag
  wire     [ 3: 0] dps_comb;                        // DPTR select flag - next value
  reg      [ 5: 0] dpc_tab [NO_DPTRS-1:0];          // Data Pointer Control Register array
  wire     [ 5: 0] dpc_reg;                         // Data Pointer Control Register
  wire     [15: 0] dparith_result;                  // DPTR Arithmetic Unit output
  `define          INC1            3'b001
  `define          INC2            3'b101
  `define          DEC1            3'b011
  `define          DEC2            3'b111

  reg      [ 7: 0] sp_reg;                          // Stack Pointer
  reg      [ 7: 0] sp_comb;
  wire     [ 7: 0] p2_comb;                         // Port 2 register (for MOVX @Ri addressing)
  reg      [ 7: 0] p2_reg;                          // Port 2 register (for MOVX @Ri addressing)

  reg      [ 7: 0] dpl_comb;                        // Data Pointer Low
  reg      [ 7: 0] dph_comb;                        // Data Pointer High
  wire     [ 7: 0] dpl_current;                     // Data Pointer Low (chosen from table)
  wire     [ 7: 0] dph_current;                     // Data Pointer High (chosen from table)

  reg              c_reg;                           // Carry flag
  reg              ac_reg;                          // Auxiliary carry
  reg      [ 1: 0] rs_reg;                          // Register bank select
  reg              ov_reg;                          // Overflow flag
  reg              pmw_reg;                         // Program Memory Write flag
  wire             pmw_comb;                        // PMW Early value
  wire             pmw_s;                           // Derived after flag and OCDS

  wire             cpu_stop;
  reg              stop_r;
  reg              stop_s;
  reg              idle_r;
  reg              idle_s;
  wire             stop_comb;
  wire             idle_comb;
  reg              p2sel_s;
  wire             p2sel_comb;
  reg              pdmode;
  reg              cpu_resume_ff1;
  reg              cpu_resume_fff;

  reg              condbranch_ineff;

  wire             codefetch_s;

  reg      [ 7: 0] acc_comb;
  reg      [ 7: 0] acc_nxt;
  reg      [ 7: 0] b_comb;
  reg      [ 7: 0] temp2_comb;
  reg              ac_comb;
  reg              c_comb;
  reg              ov_comb;

  wire     [ 1: 0] rs_comb;

  reg      [ 7: 0] incdec_out;
  reg              incdec_write_comb;
  reg      [ 7: 0] incdec_nxt;

  wire     [15: 0] dptr_inc;
  // Rn registers
  reg      [ 7: 0] rn_reg [0:31];               // 4 banks of 8 registers
  wire     [ 4: 0] rnindex;
  wire     [ 7: 0] rn;
  wire     [ 7: 0] rn_comb;

  // MUL instruction related signals
  wire      [ 8: 0] multemp1;       // Temporary signal for multiplication
  wire      [ 9: 0] multemp2;       // Temporary signal for multiplication
  reg       [ 7: 0] multempreg;     // Temporary register for multiplication

  // DIV instruction related signals
  reg       [ 6: 0] divtemp1;       // Temporary signal for division
  reg       [ 7: 0] divtemp2;       // Temporary signal for division
  reg       [ 6: 0] divtempreg;     // Temporary register for division
  reg               divres1;        // Temporary signal for division
  reg               divres2;        // Temporary signal for division

  reg               phase0_ff;
  reg               newinstrlock;   // Stops the generation of NEWINSTR
  reg               async_write_r;
  wire              async_write;

  reg               israccess_comb;
  reg               israccess;
  //--------------------------------------------------------------------
  // MUL/DIV instruction start/finish decoder
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : finishmul_dec
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      finishmul <= 1'b0;
      finishdiv <= 1'b0;
      end
    else if (waitstate == 1'b0)
      begin
      finishmul <= 1'b0;
      finishdiv <= 1'b0;

      case (instr)
      MUL_AB  :  finishmul <= (|(phase & dec_newinstr));
      DIV_AB  :  finishdiv <= (|(phase & dec_newinstr));
      default :
        begin
        end
      endcase
      end

  end

  //--------------------------------------------------------------------
  // Program Counter
  //--------------------------------------------------------------------
  always @(pc or pcdptr_exch or absbranch or phase or pc_i or
           dec_pch_temp or dec_pcl_ramdata or temp or longbranch or
           dec_movxp2pc or p2sel_s or p2_comb or pc_inc or relbranch or
           dptrbranch or apcbranch or alu_out or dpl_comb or memdatai or
           cpu_stop or codefetch_s or
           ramdatai or dec_pcl_mem or temp2 or rn_comb or dph_comb or
           instr)
  begin : pc_comb_proc
  //--------------------------------------------------------------------

    pc_comb = pc; // default

    if (!(cpu_stop == 1'b1 && codefetch_s == 1'b1 && relbranch == 1'b0))
      begin
      case (1'b1)
      relbranch, dptrbranch, apcbranch :
        begin
        pc_comb[15:8] = alu_out[15:8];
        end
      pcdptr_exch :
        begin
        pc_comb[15:8] = dph_comb;
        end
      absbranch :
        begin
          pc_comb[15:8] = {pc_i[15:11], instr[7:5]};
        end
      (|(phase & (dec_pch_temp | dec_pcl_ramdata))),
      longbranch :
        begin
        pc_comb[15:8] = temp;
        end
      (|(phase & dec_movxp2pc)) :
        begin
        if (p2sel_s == 1'b1)
          begin
          pc_comb[15:8] = ADDR_HIGH_RI;
          end
        else
          begin
          pc_comb[15:8] = p2_comb;
          end
        end
      pc_inc :
        begin
        pc_comb[15:8] = pc_i[15:8];
        end
      default:
        begin
        end
      endcase

      case (1'b1)
      absbranch,
      (|(phase & dec_pcl_mem)) :
        begin
        pc_comb[7:0] = memdatai;
        end
      (|(phase & dec_movxp2pc)) :
        begin
        pc_comb[7:0] = rn_comb;
        end
      (|(phase & dec_pcl_ramdata)) :
        begin
        pc_comb[7:0] = ramdatai;
        end
      relbranch, dptrbranch, apcbranch :
        begin
        pc_comb[7:0] = alu_out[7:0];
        end
      pcdptr_exch :
        begin
        pc_comb[7:0] = dpl_comb;
        end
      longbranch :
        begin
        pc_comb[7:0] = temp2;
        end
      pc_inc :
        begin
        pc_comb[7:0] = pc_i[7:0];
        end
      default:
        begin
        end
      endcase

      end
  end

  //--------------------------------------------------------------------
  // Program Counter
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : pc_proc
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      pc <= pc_ini;
      end
    else if (waitstate == 1'b0)
      begin
      pc <= /*(pc=='hffff) ?pc :*/pc_comb;
      end

  end

  //--------------------------------------------------------------------
reg d_hold;
always @(posedge clkcpu) d_hold <= cpu_hold;
wire hold_req  =  cpu_hold & ~idle_r & newinstr_c; // 20201201 Steven find problem in CAN1122
wire hold_fall = ~cpu_hold &  d_hold;
wire cpu_resume_ff2 = cpu_resume_fff | hold_fall;

  always @(posedge clkcpu)
  begin : power_down_proc
  //--------------------------------------------------------------------

    if (rst == 1'b1)
      begin
      idle_r  <= PCON_RV[0];
      idle_s  <= PCON_RV[0];
      stop_r  <= PCON_RV[1];
      stop_s  <= PCON_RV[1];
      gf0     <= PCON_RV[2];
      p2sel_s <= PCON_RV[3];
      end
    else if (waitstate == 1'b0)
      begin
      p2sel_s <= p2sel_comb;
      if ((ramsfraddr_s == {1'b1, PCON_ID}) && ramsfrwe == 1'b1)
        begin
        gf0     <= ramdatao_s[2];
        end
      idle_r  <= idle_r | idle_comb;
      stop_r  <= stop_r | stop_comb;
      if ((ramsfraddr_comb_nxt == {1'b1, PCON_ID}) && ramsfrwe_comb == 1'b1)
        begin
        idle_r  <= ramdatao_comb_s[0];
        stop_r  <= ramdatao_comb_s[1];
        end
      else if (((state != `STATE_RUN && state_nxt == `STATE_RUN)
               )
               && (
1'h1//             irq_int == 1'b1
                   )
               )
        begin
        idle_r  <= 1'b0;
        stop_r  <= 1'b0;
        end

      if (state != `STATE_RUN && state_nxt == `STATE_RUN)
        begin
        idle_s  <= 1'b0;
        stop_s  <= 1'b0;
        end
      else if (
               (state_nxt == `STATE_IDLE
               )
              )
        begin
        idle_s <= idle_r;
        stop_s <= stop_r;
        end
      end

  end

  assign p2sel_comb = (
                        (ramsfraddr_comb_nxt == {1'b1, PCON_ID}) && ramsfrwe_comb == 1'b1
                      ) ? ramdatao_comb_s[3] : p2sel_s;

  assign idle_comb = hold_req | idle_r | ((
                       ramsfraddr_comb_nxt == {1'b1, PCON_ID} && ramsfrwe_comb == 1'b1
                     ) ? ramdatao_comb_s[0] : idle_s);

  assign stop_comb = (
                       ramsfraddr_comb_nxt == {1'b1, PCON_ID} && ramsfrwe_comb == 1'b1
                     ) ? ramdatao_comb_s[1] : stop_s;

  assign cpu_stop = idle_comb | stop_comb;
  assign idle = idle_s;
  assign stop = stop_s;
  assign p2sel = p2sel_s;

  //--------------------------------------------------------------------
  // PC increment control
  //--------------------------------------------------------------------
  assign pc_inc = ((codefetch_s | datafetch_s) &
                   !(
                     codefetch_s == 1'b1
                     && irq_int == 1'b1
                     )
                   & !(
                        codefetch_s == 1'b1 && (idle_r == 1'b1 || stop_r == 1'b1)
                       )
//                   & !(cpu_stop == 1'b1 && codefetch_s == 1'b1)
                   );

  //--------------------------------------------------------------------
  // Program / External Data Memory address bus
  //--------------------------------------------------------------------
  assign memaddr = pc;
  assign memaddr_comb = (waitstate == 1'b0) ? pc_comb : pc;



  //--------------------------------------------------------------------
  // Program / External Data Memory access control
  //--------------------------------------------------------------------
  always @(
           cpu_stop or pdmode or
           state_nxt or cpu_resume_ff2 or
           irq_int or
           newinstr_c or
           codefetch_s or phase or dec_fetch or dec_memrd or
           dec_mempsrd or dec_memwr or mempsrd_s or state_nxt or
           pmw_s or
           interrupt or
           state)
  begin : fetch_comb_proc
  //--------------------------------------------------------------------

    // Defaults
    mempsrd_comb_s = 1'b0;
    mempswr_comb_s = 1'b0;
    memrd_comb_s   = 1'b0;
    memwr_comb_s   = 1'b0;

    case (state)
    `STATE_IDLE:
      begin
      if (
           (
           cpu_stop == 1'b0 && pdmode == 1'b0
           && interrupt == 1'b0
           )
           ||
           (
             state_nxt == `STATE_RUN && cpu_resume_ff2 == 1'b1
             && irq_int == 1'b0
           )
         )
        begin
        mempsrd_comb_s   = 1'b1;
        end
      end

    `STATE_RUN:
      begin
      if (state_nxt == `STATE_RUN && (newinstr_c == 1'b1 || codefetch_s == 1'b1 || (|(phase & {1'b0, dec_fetch[MAX_CYCLES-1:1]}) == 1'b1)))
        begin
        mempsrd_comb_s   = 1'b1;
        end
      if (
          ((phase & dec_memrd) != 0 && pmw_s == 1'b1) ||
          ((phase & dec_mempsrd) != 0))
        begin
        mempsrd_comb_s   = 1'b1;
        end
      end

    default:
      begin
      end
    endcase

    case (1'b1)
    (|(phase & dec_memrd)) : memrd_comb_s = !pmw_s;
    (|(phase & dec_memwr)) :
      begin
      memwr_comb_s   = !pmw_s;
      mempswr_comb_s = pmw_s;
      end

    default :
      begin
      end
    endcase


  end

  //--------------------------------------------------------------------
  // Program / External Data Memory access control
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : fetch_proc
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      mempsrd_r   <= 1'b0;
      mempswr_s   <= 1'b0;
      memrd_s     <= 1'b0;
      memwr_s     <= 1'b0;
      end
    else if (waitstate == 1'b0)
      begin
      mempsrd_r   <= mempsrd_comb_s;
      mempswr_s   <= mempswr_comb_s;
      memrd_s     <= memrd_comb_s;
      memwr_s     <= memwr_comb_s;
      end
  end

  assign mempsrd_comb = (waitstate == 1'b0) ? mempsrd_comb_s : mempsrd_s;
  assign mempswr_comb = (waitstate == 1'b0) ? mempswr_comb_s : mempswr_s;
  assign memrd_comb = (waitstate == 1'b0) ? memrd_comb_s : memrd_s;
  assign memwr_comb = (waitstate == 1'b0) ? memwr_comb_s : memwr_s;

  //--------------------------------------------------------------------
  // Internal Program Memory Write request
  //--------------------------------------------------------------------
  assign pmw_s =
                 pmw_comb
                 ;

  //--------------------------------------------------------------------
  // FSM State register
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : fsm_sync_proc
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      state <= `STATE_IDLE;
      end
    else if (waitstate == 1'b0)
      begin
      state <= state_nxt;
      end

  end

  //--------------------------------------------------------------------
  // FSM combinational part
  //--------------------------------------------------------------------
  always @(state or
           cpu_resume_ff2 or cpu_stop or stop_r or idle_r or
           irq_int or
           codefetch_s)
  begin : fsm_comb_proc
  //--------------------------------------------------------------------
    state_nxt = state;

    case (state)
    `STATE_IDLE: // Just after reset or power-down or debug
      begin
      if (codefetch_s == 1'b1)
        begin
          state_nxt = `STATE_RUN;
        end
      else if (cpu_resume_ff2 == 1'b1
               )
        begin
        state_nxt = `STATE_RUN;
        end
      end

    `STATE_RUN: // Normal instruction execution
      begin
      if (codefetch_s == 1'b1) // State change can only occur at new fetch
        begin
        if (cpu_stop == 1'b1
            || ((idle_r == 1'b1 || stop_r == 1'b1)
                 && cpu_resume_ff2 == 1'b0
               )
            ) // Power-down
          begin
          state_nxt = `STATE_IDLE;
          end
        else // Normal operation
          begin
          state_nxt = `STATE_RUN;
          end
        end
      end
    default:
      begin
      end

    endcase

  end

  //--------------------------------------------------------------------
  // Instruction register, phase counter, interrupt & power/down
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : instr_proc
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      instr <= NOP;
      phase <= {{1'b0}};
      interrupt <= 1'b0;
      pdmode <= 1'b0;
      phase0_ff  <= 1'b0;
      rmwinstr <= 1'b0;
////  condbranch_ineff <= 1'b0;
      newinstrlock <= 1'b1;
      end
    else if (waitstate == 1'b0)
      begin

////  condbranch_ineff <= !relbranch & ((phase & dec_relbranch) != 0);

      rmwinstr <= rmwinstr_comb;

      phase0_ff <= phase[0]
                   & !newinstrlock
                   ;
      if (
           (state_nxt == `STATE_IDLE && cpu_stop == 1'b1)
         )
        begin
        newinstrlock <= 1'b1;
        end
      else if (state_nxt == `STATE_RUN
               )
        begin
        newinstrlock <= 1'b0;
        end

      if (codefetch_s == 1'b1) // Reloading the instruction register
                               // can be done only at new fetch
        begin
        instr     <= memdatai;
        phase     <= {{1'b0}};
        interrupt <= 1'b0;
          phase     <= {{1'b0}};
          phase[0]  <= 1'b1;
          if (cpu_stop == 1'b1 && pdmode == 1'b0
              ) // Power Down mode
            begin
            pdmode    <= 1'b1;
            instr     <= NOP;
            phase     <= {{1'b0}};
            end
          else
            if (irq_int == 1'b1
                )      // Interrupt
              begin
              instr     <= UNKNOWN;
              interrupt <= 1'b1;
              end
        end
      else
        begin
        // Phase counter
        phase    <= phase << 1;

        if (idle_r == 1'b0 && stop_r == 1'b0)
          begin
          pdmode <= 1'b0;
          end

        case (state)
        `STATE_IDLE: // Power Down mode
          begin
          phase     <= {{1'b0}};
          if (cpu_resume_ff2 == 1'b1
              && (!(pdmode == 1'b0 && irq_int == 1'b0) || irq_int == 1'b1)
              )
            begin
            pdmode <= 1'b0; // Exit from power down mode
            if (irq_int == 1'b1)
              begin
              instr     <= UNKNOWN;
              interrupt <= 1'b1;
              phase     <= {{1'b0}};
              phase[0]  <= 1'b1;
              end
            phase     <= {{1'b0}};
            phase[0]  <= 1'b1;
            if (state_nxt == `STATE_RUN
                && irq_int == 1'b0
                )
              begin
              phase[0] <= 1'b0;
              end
            end
          else if (cpu_stop == 1'b1)
            begin
            pdmode <= 1'b1;
            end

          end
        default:
          begin
          end
        endcase
        end
      end

  end

  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           )
  begin : rn_dec
  //--------------------------------------------------------------------

    dec_rn_inc            = {{1'b0}};
    dec_rn_dec            = {{1'b0}};
    dec_rn_acc            = {{1'b0}};
    dec_ramdata_inc       = {{1'b0}};
    dec_ramsfrdata_inc    = {{1'b0}};
    dec_ramsfrdata_dec    = {{1'b0}};
    dec_ramdata_dec       = {{1'b0}};
    dec_incdec_store      = {{1'b0}};
    dec_rn_ramsfr         = {{1'b0}};
    dec_ramsfrdata_ramsfrdata = {{1'b0}};
    dec_ramsfrdata_ramdata    = {{1'b0}};
    dec_acccomb_store     = {{1'b0}};

    dec_ramsfrdata_anl    = {{1'b0}};
    dec_ramsfrdata_orl    = {{1'b0}};
    dec_ramsfrdata_xrl    = {{1'b0}};
    dec_anlorl_store      = {{1'b0}};
    dec_ramsfrdata_setb   = {{1'b0}};
    dec_ramsfrdata_clrb   = {{1'b0}};
    dec_ramsfrdata_cplb   = {{1'b0}};
    dec_ramsfrdata_movb   = {{1'b0}};

    dec_pch_store         = {{1'b0}};
    dec_pcl_store         = {{1'b0}};
    dec_pchinc_store      = {{1'b0}};
    dec_pclinc_store      = {{1'b0}};
    dec_pclinc2_store     = {{1'b0}};
    dec_pchinc2_store     = {{1'b0}};

    dec_anlorl_temp       = {{1'b0}};

    case (instr)
    LCALL :
      begin
      dec_pclinc2_store[0] = 1'b1;
      dec_pchinc2_store[1] = 1'b1;
      end
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_pclinc_store[0] = 1'b1;
      dec_pchinc_store[1] = 1'b1;
      end
    INC_R0, INC_R1, INC_R2, INC_R3,
    INC_R4, INC_R5, INC_R6, INC_R7 :
      begin
      dec_rn_inc[0]       = 1'b1;
      dec_incdec_store[0] = 1'b1;
      end
    DEC_R0, DEC_R1, DEC_R2, DEC_R3,
    DEC_R4, DEC_R5, DEC_R6, DEC_R7 :
      begin
      dec_rn_dec[0]       = 1'b1;
      dec_incdec_store[0] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_rn_dec[0]       = 1'b1;
      dec_incdec_store[0] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_rn_ramsfr[1] = 1'b1;
      dec_incdec_store[1] = 1'b1;
      end
    MOV_ADDR_ADDR :
      begin
      dec_ramsfrdata_ramsfrdata[1] = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    PUSH :
      begin
      dec_ramsfrdata_ramsfrdata[1] = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_ramsfrdata_ramsfrdata[1] = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_ramsfrdata_ramdata[1] = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    POP :
      begin
      dec_ramsfrdata_ramdata[1] = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    SETB_BIT :
      begin
      dec_ramsfrdata_setb[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_ramsfrdata_clrb[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    CLR_BIT :
      begin
      dec_ramsfrdata_clrb[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    CPL_BIT :
      begin
      dec_ramsfrdata_cplb[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    MOV_BIT_C :
      begin
      dec_ramsfrdata_movb[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    INC_ADDR :
      begin
      dec_ramsfrdata_inc[1]  = 1'b1;
      dec_incdec_store[1] = 1'b1;
      end
    DEC_ADDR :
      begin
      dec_ramsfrdata_dec[1]  = 1'b1;
      dec_incdec_store[1] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_ramsfrdata_dec[1]  = 1'b1;
      dec_incdec_store[1] = 1'b1;
      end
    INC_IR0, INC_IR1 :
      begin
      dec_ramdata_inc[1]  = 1'b1;
      dec_incdec_store[1] = 1'b1;
      end
    DEC_IR0, DEC_IR1 :
      begin
      dec_ramdata_dec[1]  = 1'b1;
      dec_incdec_store[1] = 1'b1;
      end
    ANL_ADDR_A :
      begin
      dec_ramsfrdata_anl[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_ramsfrdata_anl[2]  = 1'b1;
      dec_anlorl_temp[2] = 1'b1;
      dec_anlorl_store[2] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      dec_ramsfrdata_orl[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_ramsfrdata_orl[2]  = 1'b1;
      dec_anlorl_temp[2] = 1'b1;
      dec_anlorl_store[2] = 1'b1;
      end
    XRL_ADDR_A :
      begin
      dec_ramsfrdata_xrl[1]  = 1'b1;
      dec_anlorl_store[1] = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_ramsfrdata_xrl[2]  = 1'b1;
      dec_anlorl_temp[2] = 1'b1;
      dec_anlorl_store[2] = 1'b1;
      end
    XCH_R0, XCH_R1, XCH_R2, XCH_R3,
    XCH_R4, XCH_R5, XCH_R6, XCH_R7 :
      begin
      dec_rn_acc[0] = 1'b1;
      dec_acccomb_store[0] = 1'b1;
      end
    MOV_R0_A, MOV_R1_A, MOV_R2_A, MOV_R3_A,
    MOV_R4_A, MOV_R5_A, MOV_R6_A, MOV_R7_A :
      begin
      dec_rn_acc[0] = 1'b1;
      dec_acccomb_store[0] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_acccomb_store[1] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_acccomb_store[1] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_acccomb_store[1] = 1'b1;
      end
    UNKNOWN:
      begin
      if (interrupt == 1'b1)
        begin
        dec_pcl_store[0] = 1'b1;
        dec_pch_store[1] = 1'b1;
        end
      end
    default:
      begin
      end
    endcase
  end

  always @(phase or dec_rn_inc or dec_rn_dec or rn_comb or
           ramdatai or sfrdatai or dec_ramsfrdata_inc or
           dec_rn_ramsfr or dec_ramdata_inc or dec_ramdata_dec or
           dec_ramsfrdata_dec or
           ramsfraddr_s)
  begin : incdec_alu_proc

    reg  [7:0] datain1;
    reg  [7:0] datain2;

    datain1 = rn_comb;
    datain2 = 8'b00000000;

    incdec_out = {8{1'b0}};

    case (1'b1)
    (|(phase & dec_rn_inc)),
    (|(phase & dec_rn_dec))         : datain1 = rn_comb;
    (|(phase & dec_ramsfrdata_inc)),
    (|(phase & dec_ramsfrdata_dec)),
    (|(phase & dec_rn_ramsfr))      : if (ramsfraddr_s[7] == 1'b1)
                                        begin
                                        datain1 = sfrdatai;
                                        end
                                      else
                                        begin
                                        datain1 = ramdatai;
                                        end
    (|(phase & dec_ramdata_inc)),
    (|(phase & dec_ramdata_dec)) : datain1 = ramdatai;
    default
      begin
      end
    endcase

    case (1'b1)
    (|(phase & dec_rn_inc)),
    (|(phase & dec_ramdata_inc)),
    (|(phase & dec_ramsfrdata_inc)) : datain2 = 8'b00000001;
    (|(phase & dec_rn_dec)),
    (|(phase & dec_ramdata_dec)),
    (|(phase & dec_ramsfrdata_dec)) : datain2 = 8'b11111111;

    default
      begin
      end
    endcase

    incdec_out = datain1 + datain2;

  end

  always @(acc_reg or c_reg or phase or dec_ramsfrdata_anl or
           dec_ramsfrdata_orl or dec_ramsfrdata_xrl or
           ramsfraddr_s or sfrdatai or ramdatai or dec_ramsfrdata_setb or
           dec_ramsfrdata_clrb or dec_ramsfrdata_cplb or
           dec_ramsfrdata_movb or dec_anlorl_temp or temp or rn_comb or
           dec_ramsfrdata_ramdata or dec_ramsfrdata_ramsfrdata or bitno)

  begin : anlorl_alu_proc

    reg  [7:0] datain1;
    reg  [7:0] datain2;

    datain1 = rn_comb;
    datain2 = acc_reg;

    anlorl_out = datain1 & datain2;

    case (1'b1)
    (|(phase & dec_ramsfrdata_anl)),
    (|(phase & dec_ramsfrdata_orl)),
    (|(phase & dec_ramsfrdata_xrl)),
    (|(phase & dec_ramsfrdata_setb)),
    (|(phase & dec_ramsfrdata_clrb)),
    (|(phase & dec_ramsfrdata_cplb)),
    (|(phase & dec_ramsfrdata_movb)),
    (|(phase & dec_ramsfrdata_ramsfrdata)) : if (ramsfraddr_s[7] == 1'b1)
                                               begin
                                               datain1 = sfrdatai;
                                               end
                                             else
                                               begin
                                               datain1 = ramdatai;
                                               end
    (|(phase & dec_ramsfrdata_ramdata)) : datain1 = ramdatai;

    default:
      begin
      end
    endcase

    case (1'b1)
    (|(phase & dec_anlorl_temp)) : datain2 = temp;
    default:
      begin
      end
    endcase

    case (1'b1)
    (|(phase & dec_ramsfrdata_ramdata)),
    (|(phase & dec_ramsfrdata_ramsfrdata)) : anlorl_out = datain1;
    (|(phase & dec_ramsfrdata_anl)) : anlorl_out = datain1 & datain2;
    (|(phase & dec_ramsfrdata_orl)) : anlorl_out = datain1 | datain2;
    (|(phase & dec_ramsfrdata_xrl)) : anlorl_out = datain1 ^ datain2;
    (|(phase & dec_ramsfrdata_setb)) :
      begin
      anlorl_out = datain1;
      anlorl_out[bitno] = 1'b1;
      end
    (|(phase & dec_ramsfrdata_clrb)) :
      begin
      anlorl_out = datain1;
      anlorl_out[bitno] = 1'b0;
      end
    (|(phase & dec_ramsfrdata_cplb)) :
      begin
      anlorl_out = datain1;
      anlorl_out[bitno] = ~datain1[bitno];
      end
    (|(phase & dec_ramsfrdata_movb)) :
      begin
      anlorl_out = datain1;
      anlorl_out[bitno] = c_reg;
      end

    default
      begin
      end
    endcase


  end


  //--------------------------------------------------------------------
  // Data to output selection
  //--------------------------------------------------------------------
  always @(acc_comb or dec_pclinc2_store or pc or
           dec_pchinc2_store or dec_pchinc_store or dec_pclinc_store or
           dec_pch_store or dec_pcl_store or
           dec_incdec_store or dec_anlorl_store or dec_acccomb_store or
           dec_xchd or pc_i or temp2 or incdec_out or anlorl_out or
           ramdatai or phase)
  begin : incdec_write_proc
    incdec_nxt        = acc_comb;
    incdec_write_comb = 1'b0; // default

    case (1'b1)
    (|(phase & dec_pcl_store)) :
      begin
      incdec_nxt   = pc[7:0];
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_pch_store)) :
      begin
      incdec_nxt   = pc[15:8];
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_pclinc2_store)) :
      begin
        incdec_nxt   = pc[7:0] + 2'b10;
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_pchinc2_store)) :
      begin
        incdec_nxt   = pc_i[15:8];
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_pchinc_store)) :
      begin
      incdec_nxt   = temp2;
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_pclinc_store)) :
      begin
        incdec_nxt   = pc_i[7:0];
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_incdec_store)) :
      begin
      incdec_nxt   = incdec_out;
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_anlorl_store)) :
      begin
      incdec_nxt   = anlorl_out;
      incdec_write_comb = 1'b1;
      end
    (|(phase & dec_acccomb_store)) :
      begin
      incdec_write_comb = 1'b1;
      if (dec_xchd == 1'b1)
        begin
        incdec_nxt   = {ramdatai[7:4], acc_comb[3:0]};
        end
      else
        begin
        incdec_nxt   = acc_comb;
        end
      end
    default :
      begin
      end
    endcase
  end

  assign pc_i = pc + 1'b1;

  //--------------------------------------------------------------------
  // New instruction / end of current instruction decoder
  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           or async_write
           )
  begin : raminstr_dec
  //--------------------------------------------------------------------

    dec_newinstr = {{1'b0}};
    rmwinstr_comb     = 1'b0;

    case (instr)
    MOV_ADDR_N:
      begin
      dec_newinstr[2] = 1'b1;
      end
    MOV_A_ADDR:
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_A_N:
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOVX_IDPTR_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_newinstr[4] = 1'b1;
        end
      else
        begin
        dec_newinstr[2] = 1'b1;
        end
      end
    MOVX_A_IDPTR :
      begin
      dec_newinstr[2] = 1'b1;
      end
    INC_DPTR :
      begin
      dec_newinstr[0] = 1'b1;
      end
    NOP :
      begin
      dec_newinstr[0] = 1'b1;
      end
    SJMP :
      begin
      dec_newinstr[2] = 1'b1;
      end
    JC :
      begin
      dec_newinstr[2] = 1'b1;
      end
    JNC :
      begin
      dec_newinstr[2] = 1'b1;
      end
    JZ :
      begin
      dec_newinstr[2] = 1'b1;
      end
    JNZ :
      begin
      dec_newinstr[2] = 1'b1;
      end
    AJMP_0, AJMP_1, AJMP_2, AJMP_3,
    AJMP_4, AJMP_5, AJMP_6, AJMP_7 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    LJMP :
      begin
      dec_newinstr[2] = 1'b1;
      end
    RR_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    RL_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    RLC_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    RRC_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    INC_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    DEC_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    INC_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    DEC_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    MOV_R0_A, MOV_R1_A, MOV_R2_A, MOV_R3_A,
    MOV_R4_A, MOV_R5_A, MOV_R6_A, MOV_R7_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    MOV_IR0_A, MOV_IR1_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_newinstr[3] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_newinstr[1] = 1'b1;
      end
    INC_IR0, INC_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    DEC_IR0, DEC_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_A_IR0, MOV_A_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    SETB_C :
      begin
      dec_newinstr[0] = 1'b1;
      end
    CLR_C :
      begin
      dec_newinstr[0] = 1'b1;
      end
    CPL_C :
      begin
      dec_newinstr[0] = 1'b1;
      end
    MOV_BIT_C :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    SETB_BIT :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    CLR_BIT :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    CPL_BIT :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    MOV_A_R0, MOV_A_R1, MOV_A_R2, MOV_A_R3,
    MOV_A_R4, MOV_A_R5, MOV_A_R6, MOV_A_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    INC_R0, INC_R1, INC_R2, INC_R3,
    INC_R4, INC_R5, INC_R6, INC_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    DEC_R0, DEC_R1, DEC_R2, DEC_R3,
    DEC_R4, DEC_R5, DEC_R6, DEC_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_newinstr[3] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    JB_BIT :
      begin
      dec_newinstr[3] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_newinstr[3] = 1'b1;
      end
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    POP :
      begin
      dec_newinstr[1] = 1'b1;
      end
    PUSH :
      begin
      dec_newinstr[1] = 1'b1;
      end
    LCALL :
      begin
      dec_newinstr[2] = 1'b1;
      end
    RET, RETI :
      begin
      dec_newinstr[3] = 1'b1;
      end
    ADD_N:
      begin
      dec_newinstr[1] = 1'b1;
      end
    ADD_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ADD_IR0, ADD_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ADD_R0, ADD_R1, ADD_R2, ADD_R3,
    ADD_R4, ADD_R5, ADD_R6, ADD_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    ADDC_N:
      begin
      dec_newinstr[1] = 1'b1;
      end
    ADDC_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ADDC_IR0, ADDC_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ADDC_R0, ADDC_R1, ADDC_R2, ADDC_R3,
    ADDC_R4, ADDC_R5, ADDC_R6, ADDC_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_newinstr[2] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    ORL_A_N :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ORL_A_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ORL_A_IR0, ORL_A_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ORL_A_R0, ORL_A_R1, ORL_A_R2, ORL_A_R3,
    ORL_A_R4, ORL_A_R5, ORL_A_R6, ORL_A_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    ANL_ADDR_A :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_newinstr[2] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    ANL_A_N :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ANL_A_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ANL_A_IR0, ANL_A_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ANL_A_R0, ANL_A_R1, ANL_A_R2, ANL_A_R3,
    ANL_A_R4, ANL_A_R5, ANL_A_R6, ANL_A_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    XRL_ADDR_A :
      begin
      dec_newinstr[1] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_newinstr[2] = 1'b1;
      rmwinstr_comb        = 1'b1;
      end
    XRL_A_N :
      begin
      dec_newinstr[1] = 1'b1;
      end
    XRL_A_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    XRL_A_IR0, XRL_A_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    XRL_A_R0, XRL_A_R1, XRL_A_R2, XRL_A_R3,
    XRL_A_R4, XRL_A_R5, XRL_A_R6, XRL_A_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    ORL_C_BIT :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ORL_C_NBIT :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_C_BIT :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ANL_C_BIT :
      begin
      dec_newinstr[1] = 1'b1;
      end
    ANL_C_NBIT :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_ADDR_ADDR :
      begin
      dec_newinstr[2] = 1'b1;
      end
    MOV_DPTR_N :
      begin
      dec_newinstr[2] = 1'b1;
      end
    JMP_A_DPTR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOVC_A_PC :
      begin
      dec_newinstr[2] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_newinstr[2] = 1'b1;
      end
    MOV_ADDR_A :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    SUBB_N:
      begin
      dec_newinstr[1] = 1'b1;
      end
    SUBB_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    SUBB_IR0, SUBB_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    SUBB_R0, SUBB_R1, SUBB_R2, SUBB_R3,
    SUBB_R4, SUBB_R5, SUBB_R6, SUBB_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_newinstr[3] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_newinstr[3] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_newinstr[4] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_newinstr[3] = 1'b1;
      end
    SWAP_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    CLR_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    CPL_A :
      begin
      dec_newinstr[0] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_newinstr[1] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    XCH_R0, XCH_R1, XCH_R2, XCH_R3,
    XCH_R4, XCH_R5, XCH_R6, XCH_R7 :
      begin
      dec_newinstr[0] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_newinstr[1] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_newinstr[2] = 1'b1;
      end
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_newinstr[4] = 1'b1;
        end
      else
        begin
        dec_newinstr[2] = 1'b1;
        end
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_newinstr[2] = 1'b1;
      end
    MUL_AB :
      begin
      dec_newinstr[3] = 1'b1;
      end
    DIV_AB :
      begin
      dec_newinstr[3] = 1'b1;
      end
    DA_A :
      begin
      dec_newinstr[0] = 1'b1;
      end

    default: // UNKNOWN / interrupt
      begin
      if (interrupt == 1'b0)
        dec_newinstr[0] = 1'b1;
      else
        dec_newinstr[2] = 1'b1;
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Additional fetch decoder (2nd or 3rd byte of instruction)
  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           or async_write
           )
  begin : fetch_dec
  //--------------------------------------------------------------------

    dec_fetch      = {{1'b0}};
    dec_flush      = {{1'b0}};

    case (instr)
    JMP_A_DPTR :
      begin
      dec_fetch[1] = 1'b1;
      dec_flush[1] = 1'b1;
      end
    RET, RETI :
      begin
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    MOVX_IDPTR_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_fetch[4] = 1'b1;
        end
      else
        begin
        dec_fetch[2] = 1'b1;
        end
      end
    MOVX_A_IDPTR :
      begin
      dec_fetch[2] = 1'b1;
      end
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_fetch[4] = 1'b1;
        end
      else
        begin
        dec_fetch[2] = 1'b1;
        end
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_fetch[2] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_fetch[2] = 1'b1;
      end
    MOVC_A_PC :
      begin
      dec_fetch[2] = 1'b1;
      end
    MUL_AB :
      begin
      dec_fetch[3] = 1'b1;
      end
    DIV_AB :
      begin
      dec_fetch[3] = 1'b1;
      end
    MOV_ADDR_N:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      end
    MOV_A_ADDR:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_A_N:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ANL_A_IR0, ANL_A_IR1:
      begin
      dec_fetch[1] = 1'b1;
      end
    ORL_A_IR0, ORL_A_IR1:
      begin
      dec_fetch[1] = 1'b1;
      end
    XRL_A_IR0, XRL_A_IR1:
      begin
      dec_fetch[1] = 1'b1;
      end
    ADD_IR0, ADD_IR1:
      begin
      dec_fetch[1] = 1'b1;
      end
    ADDC_IR0, ADDC_IR1:
      begin
      dec_fetch[1] = 1'b1;
      end
    SJMP:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    JC :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    JNC :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    JZ :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    JNZ :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    AJMP_0, AJMP_1, AJMP_2, AJMP_3,
    AJMP_4, AJMP_5, AJMP_6, AJMP_7 :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_flush[1] = 1'b1;
      end
    LJMP :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    INC_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    INC_IR0, INC_IR1 :
      begin
      dec_fetch[1] = 1'b1;
      end
    DEC_IR0, DEC_IR1 :
      begin
      dec_fetch[1] = 1'b1;
      end
    DEC_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_BIT_C :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    SETB_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    CLR_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    CPL_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    JB_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_flush[1] = 1'b1;
      end
    POP :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    PUSH :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    LCALL :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    ADD_N:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ADD_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ADDC_N:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ADDC_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      end
    ORL_A_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ORL_A_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ANL_ADDR_A :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      end
    ANL_A_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ANL_A_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    XRL_ADDR_A :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      end
    XRL_A_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    XRL_A_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ORL_C_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ORL_C_NBIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_C_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ANL_C_BIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    ANL_C_NBIT :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_ADDR_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      end
    MOV_DPTR_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[2] = 1'b1;
      end
    MOV_ADDR_A :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    SUBB_N:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    SUBB_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    SUBB_IR0, SUBB_IR1 :
      begin
      dec_fetch[1] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_fetch[4] = 1'b1;
      dec_flush[4] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      dec_fetch[3] = 1'b1;
      dec_flush[3] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[1] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_fetch[1] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_fetch[1] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_fetch[0] = 1'b1;
      dec_fetch[2] = 1'b1;
      dec_flush[2] = 1'b1;
      end
    MOV_A_IR0, MOV_A_IR1 :
      begin
      dec_fetch[1] = 1'b1;
      end


    UNKNOWN:
      begin
      if (interrupt == 1'b1)
        begin
        dec_fetch[2] = 1'b1;
        dec_flush[2] = 1'b1;
        end
      end
    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Program Counter to Temporary Register load decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : pc2temp_dec
  //--------------------------------------------------------------------

    dec_pc2temp = {{1'b0}};
    dec_pci2temp = {{1'b0}};

    case (instr)
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_pci2temp[0] = 1'b1;
      end
    LCALL :
      begin
      end
    MOVC_A_PC :
      begin
      dec_pc2temp[0] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_pc2temp[0] = 1'b1;
      end
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      dec_pc2temp[0] = 1'b1;
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_pc2temp[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Branch after DPTR decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : dptrbranch_dec
  //--------------------------------------------------------------------

    dec_dptrbranch = {{1'b0}};

    case (instr)
    JMP_A_DPTR :
      begin
      dec_dptrbranch[0] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_dptrbranch[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // acc+PC branch decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : apcbranch_dec
  //--------------------------------------------------------------------

    dec_apcbranch = {{1'b0}};

    case (instr)
    MOVC_A_PC :
      begin
      dec_apcbranch[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Stack pointer operations decoder
  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           )
  begin : spop_dec
  //--------------------------------------------------------------------

    dec_spinc = {{1'b0}};
    dec_spdec = {{1'b0}};

    case (instr)
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_spinc[0] = 1'b1;
      dec_spinc[1] = 1'b1;
      end
    LCALL :
      begin
      dec_spinc[0] = 1'b1;
      dec_spinc[1] = 1'b1;
      end
    POP :
      begin
      dec_spdec[1] = 1'b1;
      end
    PUSH :
      begin
      dec_spinc[1] = 1'b1;
      end
    RET, RETI :
      begin
      dec_spdec[1] = 1'b1;
      dec_spdec[2] = 1'b1;
      end
    UNKNOWN : // interrupt
      begin
      if (interrupt == 1'b1)
        begin
        dec_spinc[0] = 1'b1;
        dec_spinc[1] = 1'b1;
        end
      end
    default:
      begin
      end

    endcase

  end


  //--------------------------------------------------------------------
  // Direct addressing mode decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ramsfr_dir_dec
  //--------------------------------------------------------------------

    dec_ramsfr_dir = {{1'b0}};

    case (instr)
    MOV_ADDR_N:
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    MOV_A_ADDR:
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    INC_ADDR:
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    DEC_ADDR:
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    POP :
      begin
      end
    PUSH :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ADD_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ADDC_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ORL_A_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ANL_ADDR_A :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    ANL_A_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    XRL_ADDR_A :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    XRL_A_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    MOV_ADDR_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      dec_ramsfr_dir[1] = 1'b1;
      end
    MOV_ADDR_A :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    SUBB_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_ramsfr_dir[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Rn operation decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ramsfr_rn_dec
  //--------------------------------------------------------------------

    dec_ramsfr_rn = {{1'b0}};
    dec_acc_rn = {{1'b0}};

    case (instr)
    MOV_R0_A, MOV_R1_A, MOV_R2_A, MOV_R3_A,
    MOV_R4_A, MOV_R5_A, MOV_R6_A, MOV_R7_A :
      begin
      dec_ramsfr_rn[0] = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_ramsfr_rn[0] = 1'b1;
      end
    MOV_A_R0, MOV_A_R1, MOV_A_R2, MOV_A_R3,
    MOV_A_R4, MOV_A_R5, MOV_A_R6, MOV_A_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    INC_R0, INC_R1, INC_R2, INC_R3,
    INC_R4, INC_R5, INC_R6, INC_R7 :
      begin
      dec_ramsfr_rn[0] = 1'b1;
      end
    DEC_R0, DEC_R1, DEC_R2, DEC_R3,
    DEC_R4, DEC_R5, DEC_R6, DEC_R7 :
      begin
      dec_ramsfr_rn[0] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_ramsfr_rn[1] = 1'b1;
      end
    ADD_R0, ADD_R1, ADD_R2, ADD_R3,
    ADD_R4, ADD_R5, ADD_R6, ADD_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    ADDC_R0, ADDC_R1, ADDC_R2, ADDC_R3,
    ADDC_R4, ADDC_R5, ADDC_R6, ADDC_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    ORL_A_R0, ORL_A_R1, ORL_A_R2, ORL_A_R3,
    ORL_A_R4, ORL_A_R5, ORL_A_R6, ORL_A_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    ANL_A_R0, ANL_A_R1, ANL_A_R2, ANL_A_R3,
    ANL_A_R4, ANL_A_R5, ANL_A_R6, ANL_A_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    XRL_A_R0, XRL_A_R1, XRL_A_R2, XRL_A_R3,
    XRL_A_R4, XRL_A_R5, XRL_A_R6, XRL_A_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    SUBB_R0, SUBB_R1, SUBB_R2, SUBB_R3,
    SUBB_R4, SUBB_R5, SUBB_R6, SUBB_R7 :
      begin
      dec_acc_rn[0] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      end
    XCH_R0, XCH_R1, XCH_R2, XCH_R3,
    XCH_R4, XCH_R5, XCH_R6, XCH_R7 :
      begin
      dec_ramsfr_rn[0] = 1'b1;
      dec_acc_rn[0] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_ramsfr_rn[0] = 1'b1;
      dec_acc_rn[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Ri operation decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ramsfr_ri_dec
  //--------------------------------------------------------------------

    dec_ramsfr_ri = {{1'b0}};

    case (instr)
    MOV_IR0_A, MOV_IR1_A :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    INC_IR0, INC_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    DEC_IR0, DEC_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    MOV_A_IR0, MOV_A_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    ADD_IR0, ADD_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    ADDC_IR0, ADDC_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    ORL_A_IR0, ORL_A_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    ANL_A_IR0, ANL_A_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    XRL_A_IR0, XRL_A_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    SUBB_IR0, SUBB_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_ramsfr_ri[1] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_ramsfr_ri[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Bitwise addressing mode decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ramsfr_bit_dec
  //--------------------------------------------------------------------

    dec_ramsfr_bit = {{1'b0}};

    case (instr)
    MOV_BIT_C :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    SETB_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    CLR_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    CPL_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    JB_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    ORL_C_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    ORL_C_NBIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    MOV_C_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    ANL_C_BIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end
    ANL_C_NBIT :
      begin
      dec_ramsfr_bit[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Stack operation decoder
  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           )
  begin : ramsfr_sp_dec
  //--------------------------------------------------------------------

    dec_ramsfr_sp = {{1'b0}};
    dec_ramsfr_spinc = {{1'b0}};

    case (instr)
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_ramsfr_spinc[0] = 1'b1;
      dec_ramsfr_spinc[1] = 1'b1;
      end
    LCALL :
      begin
      dec_ramsfr_spinc[0] = 1'b1;
      dec_ramsfr_spinc[1] = 1'b1;
      end
    POP :
      begin
      dec_ramsfr_sp[0] = 1'b1;
      end
    PUSH :
      begin
      dec_ramsfr_spinc[1] = 1'b1;
      end
    RET, RETI :
      begin
      dec_ramsfr_sp[0] = 1'b1;
      dec_ramsfr_sp[1] = 1'b1;
      end
    UNKNOWN : // interrupt
      begin
      if (interrupt == 1'b1)
        begin
        dec_ramsfr_sp[0] = 1'b1;
        dec_ramsfr_sp[1] = 1'b1;
        end
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // RAM/SFR write operation decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ramsfr_wr_dec
  //--------------------------------------------------------------------

    dec_ramsfr_wr = {{1'b0}};

    case (instr)
    MOV_ADDR_N :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    INC_ADDR :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    DEC_ADDR :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    MOV_BIT_C :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    SETB_BIT :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    CLR_BIT :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    CPL_BIT :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    POP :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_ramsfr_wr[2] = 1'b1;
      end
    ANL_ADDR_A :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_ramsfr_wr[2] = 1'b1;
      end
    XRL_ADDR_A :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_ramsfr_wr[2] = 1'b1;
      end
    MOV_ADDR_ADDR :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    MOV_ADDR_A :
      begin
      dec_ramsfr_wr[0] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_ramsfr_wr[0] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_ramsfr_wr[1] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // RAM/SFR read operation decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ramsfr_rd_dec
  //--------------------------------------------------------------------

    dec_ramsfr_rd = {{1'b0}};

    case (instr)
    MOV_A_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    INC_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    DEC_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    MOV_BIT_C :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    SETB_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    CLR_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    CPL_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    JB_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    PUSH :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ADD_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ADDC_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_ramsfr_rd[1] = 1'b1;
      end
    ORL_A_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ANL_ADDR_A :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_ramsfr_rd[1] = 1'b1;
      end
    ANL_A_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    XRL_ADDR_A :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_ramsfr_rd[1] = 1'b1;
      end
    XRL_A_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ORL_C_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ORL_C_NBIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    MOV_C_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ANL_C_BIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    ANL_C_NBIT :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    MOV_ADDR_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    SUBB_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_ramsfr_rd[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // RAM write operation decoder
  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           )
  begin : ram_wr_dec
  //--------------------------------------------------------------------

    dec_ram_wr = {{1'b0}};

    case (instr)
    MOV_R0_A, MOV_R1_A, MOV_R2_A, MOV_R3_A,
    MOV_R4_A, MOV_R5_A, MOV_R6_A, MOV_R7_A :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    MOV_IR0_A, MOV_IR1_A :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    INC_IR0, INC_IR1 :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    DEC_IR0, DEC_IR1 :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    INC_R0, INC_R1, INC_R2, INC_R3,
    INC_R4, INC_R5, INC_R6, INC_R7 :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    DEC_R0, DEC_R1, DEC_R2, DEC_R3,
    DEC_R4, DEC_R5, DEC_R6, DEC_R7 :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    MOV_R0_ADDR, MOV_R1_ADDR, MOV_R2_ADDR, MOV_R3_ADDR,
    MOV_R4_ADDR, MOV_R5_ADDR, MOV_R6_ADDR, MOV_R7_ADDR :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_ram_wr[0] = 1'b1;
      dec_ram_wr[1] = 1'b1;
      end
    LCALL :
      begin
      dec_ram_wr[0] = 1'b1;
      dec_ram_wr[1] = 1'b1;
      end
    PUSH :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    MOV_IR0_ADDR, MOV_IR1_ADDR :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_ram_wr[1] = 1'b1;
      end
    XCH_R0, XCH_R1, XCH_R2, XCH_R3,
    XCH_R4, XCH_R5, XCH_R6, XCH_R7 :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_ram_wr[0] = 1'b1;
      end
    UNKNOWN : // interrupt
      begin
      if (interrupt == 1'b1)
        begin
        dec_ram_wr[0] = 1'b1;
        dec_ram_wr[1] = 1'b1;
        end
      end
    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // RAM write operation decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : ram_rd_dec
  //--------------------------------------------------------------------

    dec_ram_rd = {{1'b0}};

    case (instr)
    INC_IR0, INC_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    DEC_IR0, DEC_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    MOV_A_IR0, MOV_A_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    POP :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    RET, RETI :
      begin
      dec_ram_rd[0] = 1'b1;
      dec_ram_rd[1] = 1'b1;
      end
    ADD_IR0, ADD_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    ADDC_IR0, ADDC_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    ORL_A_IR0, ORL_A_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    ANL_A_IR0, ANL_A_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    XRL_A_IR0, XRL_A_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    SUBB_IR0, SUBB_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_ram_rd[0] = 1'b1;
      end
    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // MOVX @Ri decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : movxp2pc_dec
  //--------------------------------------------------------------------

    dec_movxp2pc = {{1'b0}};

    case (instr)
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      dec_movxp2pc[0] = 1'b1;
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_movxp2pc[0] = 1'b1;
      end

    default :
      begin
      end

    endcase
  end

  //--------------------------------------------------------------------
  // Temporary register 2 from acc load decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : acc2temp_dec
  //--------------------------------------------------------------------

    dec_acc2temp = {{1'b0}};

    case (instr)
    MOV_ADDR_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    JB_BIT :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADD_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADD_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADD_IR0, ADD_IR1 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADD_R0, ADD_R1, ADD_R2, ADD_R3,
    ADD_R4, ADD_R5, ADD_R6, ADD_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADDC_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADDC_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADDC_IR0, ADDC_IR1 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ADDC_R0, ADDC_R1, ADDC_R2, ADDC_R3,
    ADDC_R4, ADDC_R5, ADDC_R6, ADDC_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ORL_ADDR_A :
      begin
      end
    ORL_ADDR_N :
      begin
      end
    ORL_A_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ORL_A_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ORL_A_IR0, ORL_A_IR1 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ORL_A_R0, ORL_A_R1, ORL_A_R2, ORL_A_R3,
    ORL_A_R4, ORL_A_R5, ORL_A_R6, ORL_A_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ANL_A_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ANL_A_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ANL_A_IR0, ANL_A_IR1 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    ANL_A_R0, ANL_A_R1, ANL_A_R2, ANL_A_R3,
    ANL_A_R4, ANL_A_R5, ANL_A_R6, ANL_A_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    XRL_A_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    XRL_A_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    XRL_A_IR0, XRL_A_IR1 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    XRL_A_R0, XRL_A_R1, XRL_A_R2, XRL_A_R3,
    XRL_A_R4, XRL_A_R5, XRL_A_R6, XRL_A_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    SUBB_N :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    SUBB_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    SUBB_IR0, SUBB_IR1 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    SUBB_R0, SUBB_R1, SUBB_R2, SUBB_R3,
    SUBB_R4, SUBB_R5, SUBB_R6, SUBB_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_acc2temp[0] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_acc2temp[0] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_acc2temp[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Temporary register load from acc decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : temp_acc_dec
  //--------------------------------------------------------------------

    dec_temp_acc = {{1'b0}};
    dec_temp_ramsfrdata = {{1'b0}};

    case (instr)
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_temp_acc[0] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_temp_acc[0] = 1'b1;
      end
    MOV_C_BIT :
      begin
      dec_temp_ramsfrdata[1] = 1'b1;
      end
    ANL_C_BIT :
      begin
      dec_temp_ramsfrdata[1] = 1'b1;
      end
    ANL_C_NBIT :
      begin
      dec_temp_ramsfrdata[1] = 1'b1;
      end
    ORL_C_BIT :
      begin
      dec_temp_ramsfrdata[1] = 1'b1;
      end
    ORL_C_NBIT :
      begin
      dec_temp_ramsfrdata[1] = 1'b1;
      end

    default :
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // acc load from temporary register 2 decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : exch_temp2acc_dec
  //--------------------------------------------------------------------

    dec_temp2acc = {{1'b0}};

    case (instr)
    DJNZ_ADDR :
      begin
      dec_temp2acc[2] = 1'b1;
      end
    MOV_ADDR_N :
      begin
      dec_temp2acc[2] = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_temp2acc[1] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_temp2acc[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_temp2acc[2] = 1'b1;
      end
    JB_BIT :
      begin
      dec_temp2acc[2] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_temp2acc[2] = 1'b1;
      end
    MOV_ADDR_R0, MOV_ADDR_R1, MOV_ADDR_R2, MOV_ADDR_R3,
    MOV_ADDR_R4, MOV_ADDR_R5, MOV_ADDR_R6, MOV_ADDR_R7 :
      begin
      dec_temp2acc[1] = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_temp2acc[3] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_temp2acc[3] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_temp2acc[3] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_temp2acc[2] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_temp2acc[2] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // PC increment & interrupt branch decoder
  //--------------------------------------------------------------------
  always @(instr or interrupt)
  begin : pcinc_dec
  //--------------------------------------------------------------------

    dec_tempint = {{1'b0}};

    case (instr)

    UNKNOWN : // int
      begin
      if (interrupt == 1'b1)
        dec_tempint[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // acc write from RAM/SFR
  //--------------------------------------------------------------------
  always @(instr)
  begin : acc_ramsfr_dec
  //--------------------------------------------------------------------

    dec_acc_ramsfr = {{1'b0}};

    case (instr)
    MOV_A_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    JB_BIT :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    ADD_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    ADDC_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    ORL_A_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    ANL_A_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    XRL_A_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    SUBB_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end
    XCH_ADDR :
      begin
      dec_acc_ramsfr[1] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // acc write from RAM
  //--------------------------------------------------------------------
  always @(instr)
  begin : acc_ramdata_dec
  //--------------------------------------------------------------------

    dec_acc_ramdata = {{1'b0}};

    case (instr)
    MOV_A_IR0, MOV_A_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    ADD_IR0, ADD_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    ADDC_IR0, ADDC_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    ORL_A_IR0, ORL_A_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    ANL_A_IR0, ANL_A_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    XRL_A_IR0, XRL_A_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    SUBB_IR0, SUBB_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    XCH_IR0, XCH_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end
    XCHD_IR0, XCHD_IR1 :
      begin
      dec_acc_ramdata[1] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // acc write from Program/Ext.data mem.
  //--------------------------------------------------------------------
  always @(instr)
  begin : acc_mem_dec
  //--------------------------------------------------------------------

    dec_acc_mem = {{1'b0}};

    case (instr)
    MOV_A_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    MOV_ADDR_N:
      begin
      dec_acc_mem[1] = 1'b1;
      end
    MOV_R0_N, MOV_R1_N, MOV_R2_N, MOV_R3_N,
    MOV_R4_N, MOV_R5_N, MOV_R6_N, MOV_R7_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    MOV_IR0_N, MOV_IR1_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    ADD_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    ADDC_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    ORL_A_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    ANL_A_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    XRL_A_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    MOVC_A_PC :
      begin
      dec_acc_mem[1] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_acc_mem[1] = 1'b1;
      end
    SUBB_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_acc_mem[0] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_acc_mem[0] = 1'b1;
      end
    MOVX_A_IDPTR :
      begin
      dec_acc_mem[1] = 1'b1;
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_acc_mem[1] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // ALU activity decoder
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : accactv_dec
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      accactv <= 1'b0;
      dec_accop   <= {{1'b0}}; //`ACC_NOP;
      dec_cop     <= {{1'b0}}; //`C_NOP;
      end
    else if (waitstate == 1'b0)
      begin
      accactv     <= 1'b0;
      dec_accop   <= {{1'b0}}; //`ACC_NOP;
      dec_cop     <= {{1'b0}}; //`C_NOP;

      case (instr)
      MUL_AB :
        begin
        accactv <= (|(phase & dec_newinstr) | phase[0] | phase[1] | phase[2]);
        dec_accop`ACC_MUL <= 1'b1;
        end
      DIV_AB :
        begin
        accactv <= (|(phase & dec_newinstr) | phase[0] | phase[1] | phase[2]);
        dec_accop`ACC_DIV <= 1'b1;
        end
      DA_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_DA <= 1'b1;
        end
      RR_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_RR <= 1'b1;
        end
      RL_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_RL <= 1'b1;
        end
      RRC_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_RRC <= 1'b1;
        end
      RLC_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_RLC <= 1'b1;
        end
      INC_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_INC <= 1'b1;
        end
      DEC_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_DEC <= 1'b1;
        end
      DJNZ_ADDR :
        begin
        accactv <= (phase[1]);
        dec_accop`ACC_DEC <= 1'b1;
        end
      SETB_C :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_SET <= 1'b1;
        end
      CLR_C :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_CLR <= 1'b1;
        end
      CPL_C :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_CPL <= 1'b1;
        end
      ADD_N :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDTMP <= 1'b1;
        end
      ADD_ADDR :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDTMP <= 1'b1;
        end
      ADD_IR0, ADD_IR1 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDTMP <= 1'b1;
        end
      ADD_R0, ADD_R1, ADD_R2, ADD_R3,
      ADD_R4, ADD_R5, ADD_R6, ADD_R7 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDTMP <= 1'b1;
        end
      ADDC_N :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDCTMP <= 1'b1;
        end
      ADDC_ADDR :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDCTMP <= 1'b1;
        end
      ADDC_IR0, ADDC_IR1 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDCTMP <= 1'b1;
        end
      ADDC_R0, ADDC_R1, ADDC_R2, ADDC_R3,
      ADDC_R4, ADDC_R5, ADDC_R6, ADDC_R7 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ADDCTMP <= 1'b1;
        end
      ORL_A_N :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ORLTMP2 <= 1'b1;
        end
      ORL_A_ADDR :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ORLTMP2 <= 1'b1;
        end
      ORL_A_IR0, ORL_A_IR1 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ORLTMP2 <= 1'b1;
        end
      ORL_A_R0, ORL_A_R1, ORL_A_R2, ORL_A_R3,
      ORL_A_R4, ORL_A_R5, ORL_A_R6, ORL_A_R7 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ORLTMP2 <= 1'b1;
        end
      ANL_A_N :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ANLTMP2 <= 1'b1;
        end
      ANL_A_ADDR :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ANLTMP2 <= 1'b1;
        end
      ANL_A_IR0, ANL_A_IR1 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ANLTMP2 <= 1'b1;
        end
      ANL_A_R0, ANL_A_R1, ANL_A_R2, ANL_A_R3,
      ANL_A_R4, ANL_A_R5, ANL_A_R6, ANL_A_R7 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_ANLTMP2 <= 1'b1;
        end
      XRL_A_N :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_XRLTMP2 <= 1'b1;
        end
      XRL_A_ADDR :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_XRLTMP2 <= 1'b1;
        end
      XRL_A_IR0, XRL_A_IR1 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_XRLTMP2 <= 1'b1;
        end
      XRL_A_R0, XRL_A_R1, XRL_A_R2, XRL_A_R3,
      XRL_A_R4, XRL_A_R5, XRL_A_R6, XRL_A_R7 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_XRLTMP2 <= 1'b1;
        end
      ORL_C_BIT :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_ORL <= 1'b1;
        end
      ORL_C_NBIT :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_ORLN <= 1'b1;
        end
      MOV_C_BIT :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_MOV <= 1'b1;
        end
      ANL_C_BIT :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_ANL <= 1'b1;
        end
      ANL_C_NBIT :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_cop`C_ANLN <= 1'b1;
        end
      SUBB_N :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_SUBBTMP <= 1'b1;
        end
      SUBB_ADDR :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_SUBBTMP <= 1'b1;
        end
      SUBB_IR0, SUBB_IR1 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_SUBBTMP <= 1'b1;
        end
      SUBB_R0, SUBB_R1, SUBB_R2, SUBB_R3,
      SUBB_R4, SUBB_R5, SUBB_R6, SUBB_R7 :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_SUBBTMP <= 1'b1;
        end
      CJNE_A_N:
        begin
        accactv <= (phase[0]);
        dec_accop`ACC_SUBTMP <= 1'b1;
        end
      CJNE_A_ADDR :
        begin
        accactv <= (phase[1]);
        dec_accop`ACC_SUBTMP <= 1'b1;
        end
      CJNE_IR0_N, CJNE_IR1_N :
        begin
        accactv <= (phase[1]);
        dec_accop`ACC_SUBTMP <= 1'b1;
        end
      CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
      CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
        begin
        accactv <= (phase[0]);
        dec_accop`ACC_SUBTMP <= 1'b1;
        end
      SWAP_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_SWAP <= 1'b1;
        end
      CLR_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_CLR <= 1'b1;
        end
      CPL_A :
        begin
        accactv <= (|(phase & dec_newinstr));
        dec_accop`ACC_CPL <= 1'b1;
        end
      DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
      DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
        begin
        accactv <= (phase[0]);
        dec_accop`ACC_DEC <= 1'b1;
        end

      default:
        begin
        end
      endcase
      end
  end

  //--------------------------------------------------------------------
  // PC<->DPTR exchange decoder
  //--------------------------------------------------------------------
  always @(instr
           or async_write
           )
  begin : pcdptr_exch_dec
  //--------------------------------------------------------------------

    dec_dptrinc = 1'b0;
    dec_dph_temp = {{1'b0}};
    dec_dpl_temp = {{1'b0}};
    dec_pcdptr_exch = {{1'b0}};
    dec_dparith_exe = {{1'b0}};

    case (instr)
    MOVX_IDPTR_A :
      begin
      dec_pcdptr_exch[0] = 1'b1;
      if (async_write == 1'b1)
        begin
        dec_pcdptr_exch[3] = 1'b1;
        dec_dparith_exe[3] = 1'b1;
        end
      else
        begin
        dec_pcdptr_exch[1] = 1'b1;
        dec_dparith_exe[1] = 1'b1;
        end
      end
    MOVX_A_IDPTR :
      begin
      dec_pcdptr_exch[0] = 1'b1;
      dec_pcdptr_exch[1] = 1'b1;
      dec_dparith_exe[1] = 1'b1;
      end
    INC_DPTR :
      begin
      dec_dptrinc = 1'b1;
      end
    MOV_DPTR_N :
      begin
      dec_dph_temp[1] = 1'b1;
      dec_dpl_temp[2]  = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Ext.data memory read/write decoder
  //--------------------------------------------------------------------
  always @(instr
           or async_write
           )
  begin : memwr_s_dec
  //--------------------------------------------------------------------

    dec_memwr = {{1'b0}};
    dec_memrd = {{1'b0}};

    case (instr)
    MOVX_IDPTR_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_memwr[1] = 1'b1;
        end
      else
        begin
        dec_memwr[0] = 1'b1;
        end
      end
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_memwr[1] = 1'b1;
        end
      else
        begin
        dec_memwr[0] = 1'b1;
        end
      end
    MOVX_A_IDPTR :
      begin
      dec_memrd[0] = 1'b1;
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_memrd[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Program memory read decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : mempsrd_s_dec
  //--------------------------------------------------------------------

    dec_mempsrd = {{1'b0}};

    case (instr)
    MOVC_A_PC :
      begin
      dec_mempsrd[0] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_mempsrd[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Temporary register 1 & 2 load from Program/Ext.data mem.
  //--------------------------------------------------------------------
  always @(instr)
  begin : temp_mem_dec
  //--------------------------------------------------------------------

    dec_temp_mem = {{1'b0}};
    dec_temp2_mem = {{1'b0}};
    dec_ramsfr_temp = {{1'b0}};

    case (instr)
    POP :
      begin
      dec_ramsfr_temp[1] = 1'b1;
      dec_temp_mem[0] = 1'b1;
      end
    SJMP :
      begin
      dec_temp_mem[0] = 1'b1;
      end
    JC :
      begin
      dec_temp_mem[0] = 1'b1;
      end
    JNC :
      begin
      dec_temp_mem[0] = 1'b1;
      end
    JZ :
      begin
      dec_temp_mem[0] = 1'b1;
      end
    JNZ :
      begin
      dec_temp_mem[0] = 1'b1;
      end
    LJMP :
      begin
      dec_temp_mem[0] = 1'b1;
      dec_temp2_mem[1] = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    JBC_BIT :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    JB_BIT :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    JNB_BIT :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    LCALL :
      begin
      dec_temp_mem[0] = 1'b1;
      end
    ORL_ADDR_N :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    ANL_ADDR_N :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    XRL_ADDR_N :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    MOV_ADDR_IR0, MOV_ADDR_IR1 :
      begin
      dec_temp_mem[0] = 1'b1;
      dec_ramsfr_temp[1] = 1'b1;
      end
    MOV_DPTR_N :
      begin
      dec_temp_mem[0] = 1'b1;
      dec_temp_mem[1] = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_temp_mem[1] = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_temp_mem[2] = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_temp_mem[1] = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_temp_mem[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Temporary register 1 & 2 load from RAM
  //--------------------------------------------------------------------
  always @(instr)
  begin : temp_ramdata_dec
  //--------------------------------------------------------------------

    dec_temp_ramdata  = {{1'b0}};
    dec_temp2_ramdata = {{1'b0}};
    dec_temp2_rn = {{1'b0}};

    case (instr)
    RET, RETI :
      begin
      dec_temp_ramdata[1]  = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_temp2_ramdata[1]  = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_temp2_rn[0]  = 1'b1;
      end

    default :
      begin
      end
    endcase
  end

  //--------------------------------------------------------------------
  // Temporary register 2 load from temporary register 1 decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : temp2temp_dec
  //--------------------------------------------------------------------

    dec_temp2temp = {{1'b0}};

    case (instr)
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_temp2temp[2]  = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_temp2temp[1]  = 1'b1;
      end

    default :
      begin
      end
    endcase
  end

  //--------------------------------------------------------------------
  // Relative branch & condition decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : relbranch_dec
  //--------------------------------------------------------------------

    dec_relbranch = {{1'b0}};
    dec_branchcond = {{1'b0}}; // `BRANCH_FALSE;

    case (instr)
    SJMP :
      begin
      dec_relbranch[1] = 1'b1;
      dec_branchcond`BRANCH_TRUE = 1'b1;
      end
    JC :
      begin
      dec_relbranch[1] = 1'b1;
      dec_branchcond`BRANCH_C = 1'b1;
      end
    JNC :
      begin
      dec_relbranch[1] = 1'b1;
      dec_branchcond`BRANCH_NC = 1'b1;
      end
    JZ :
      begin
      dec_relbranch[1] = 1'b1;
      dec_branchcond`BRANCH_ACCZERO = 1'b1;
      end
    JNZ :
      begin
      dec_relbranch[1] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end
    DJNZ_ADDR :
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end
    JBC_BIT :
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_BIT = 1'b1;
      end
    JB_BIT :
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_BIT = 1'b1;
      end
    JNB_BIT :
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_NBIT = 1'b1;
      end
    CJNE_A_N:
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end
    CJNE_A_ADDR :
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end
    CJNE_IR0_N, CJNE_IR1_N :
      begin
      dec_relbranch[3] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end
    CJNE_R0_N, CJNE_R1_N, CJNE_R2_N, CJNE_R3_N,
    CJNE_R4_N, CJNE_R5_N, CJNE_R6_N, CJNE_R7_N :
      begin
      dec_relbranch[2] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end
    DJNZ_R0, DJNZ_R1, DJNZ_R2, DJNZ_R3,
    DJNZ_R4, DJNZ_R5, DJNZ_R6, DJNZ_R7 :
      begin
      dec_relbranch[1] = 1'b1;
      dec_branchcond`BRANCH_ACCNZERO = 1'b1;
      end

    default:
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Absolute branch decoder
  //--------------------------------------------------------------------
  always @(instr)
  begin : absbranch_dec
  //--------------------------------------------------------------------

    dec_absbranch = {{1'b0}};

    case (instr)
    AJMP_0, AJMP_1, AJMP_2, AJMP_3,
    AJMP_4, AJMP_5, AJMP_6, AJMP_7 :
      begin
      dec_absbranch[0] = 1'b1;
      end
    ACALL_0, ACALL_1, ACALL_2, ACALL_3,
    ACALL_4, ACALL_5, ACALL_6, ACALL_7 :
      begin
      dec_absbranch[0] = 1'b1;
      end

    default:
      begin
      end
    endcase

  end


  //--------------------------------------------------------------------
  // Long branch decoder
  //--------------------------------------------------------------------
  always @(instr
           or interrupt
           or async_write
           )
  begin : longbranch_dec
  //--------------------------------------------------------------------

    dec_longbranch = {{1'b0}};
    dec_pcl_mem = {{1'b0}};
    dec_pch_temp = {{1'b0}};
    dec_pcl_ramdata = {{1'b0}};

    case (instr)
    LJMP :
      begin
      dec_pch_temp[1] = 1'b1;
      dec_pcl_mem[1] = 1'b1;
      end
    RET, RETI :
      begin
      dec_pch_temp[2] = 1'b1;
      dec_pcl_ramdata[2] = 1'b1;
      end
    LCALL :
      begin
      dec_pch_temp[1] = 1'b1;
      dec_pcl_mem[1] = 1'b1;
      end
    MOVC_A_PC :
      begin
      dec_longbranch[1] = 1'b1;
      end
    MOVC_A_DPTR :
      begin
      dec_longbranch[1] = 1'b1;
      end
    MOVX_IR0_A, MOVX_IR1_A :
      begin
      if (async_write == 1'b1)
        begin
        dec_longbranch[3] = 1'b1;
        end
      else
        begin
        dec_longbranch[1] = 1'b1;
        end
      end
    MOVX_A_IR0, MOVX_A_IR1 :
      begin
      dec_longbranch[1] = 1'b1;
      end
    UNKNOWN : // interrupt
      begin
      if (interrupt == 1'b1)
        begin
        dec_longbranch[1] = 1'b1;
        end
      end

    default:
      begin
      end
    endcase

  end

  assign  ramsfraddr_comb_nxt =
    (|(phase & dec_ramsfr_dir))                ? memdatai :
    (|(phase & dec_ramsfr_bit) & ~memdatai[7]) ? {4'b0010, memdatai[6:3]} :
    (|(phase & dec_ramsfr_bit) &  memdatai[7]) ? {memdatai[7:3], 3'b000}  :
                                                 ramsfraddr_comb_s;

  //--------------------------------------------------------------------
  // RAM/SFR control
  //--------------------------------------------------------------------
  always @(ramsfraddr_s or phase or dec_ramsfr_rn or
           dec_ramsfr_ri or dec_ramsfr_sp or dec_ramsfr_spinc or
           dec_ramsfr_temp or rs_comb or
           instr or sp_comb or temp or dec_ramsfr_wr or rn_comb or
           dec_ramsfr_rd or dec_ram_wr or dec_ram_rd or
           ramsfrwe)
  begin : ramsfr_comb_proc
  //--------------------------------------------------------------------
    // Defaults
    ramsfraddr_comb_s = ramsfraddr_s;

    //Defaults
    ramoe_comb_int      = 1'b0;
    ramwe_comb_int      = 1'b0;
    ramsfroe_comb   = 1'b0;
    ramsfrwe_comb   = 1'b0;

    // RAM/SFR address bus
    case (1'b1)
    (|(phase & dec_ramsfr_rn))      : ramsfraddr_comb_s = {3'b000, rs_comb, instr[2:0]};
    (|(phase & dec_ramsfr_ri))      : ramsfraddr_comb_s = rn_comb;
    (|(phase & dec_ramsfr_sp))      : ramsfraddr_comb_s = sp_comb;
    (|(phase & dec_ramsfr_spinc))   : ramsfraddr_comb_s = sp_comb;
    (|(phase & dec_ramsfr_temp))    : ramsfraddr_comb_s = temp;
    default :
      begin
      end
    endcase

    // RAM/SFR write
    case (1'b1)
    (|(phase & dec_ramsfr_wr)) : ramsfrwe_comb = 1'b1;

    default :
      begin
      end
    endcase

    // RAM/SFR read
    case (1'b1)
    (|(phase & dec_ramsfr_rd)) : ramsfroe_comb = 1'b1;

    default :
      begin
      end
    endcase

    // RAM write
    case (1'b1)
    (|(phase & dec_ram_wr)) : ramwe_comb_int = 1'b1;

    default :
      begin
      end
    endcase

    // RAM read
    case (1'b1)
    (|(phase & dec_ram_rd)) : ramoe_comb_int = 1'b1;

    default :
      begin
      end
    endcase

  end

  assign ramsfraddr_comb = (waitstate == 1'b0) ? ramsfraddr_comb_nxt : ramsfraddr_s;

  assign ramoe_comb_s = ramoe_comb_int | (!ramsfraddr_comb_nxt[7] &
                                          ramsfroe_comb);
  assign ramwe_comb_s = ramwe_comb_int | (!ramsfraddr_comb_nxt[7] &
                                          ramsfrwe_comb);

  assign ramoe_comb = (waitstate == 1'b0) ? ramoe_comb_s : ramoe_r;
  assign ramwe_comb = (waitstate == 1'b0) ? ramwe_comb_s : ramwe_r;

  assign sfroe_comb_s = (ramsfraddr_comb_nxt[7]
                        ) & ramsfroe_comb;
  assign sfrwe_comb_s = (ramsfraddr_comb_nxt[7]
                        ) & ramsfrwe_comb;

  //--------------------------------------------------------------------
  // RAM/SFR control
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : ramsfr_proc
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      ramsfraddr_s  <= {{1'b0}};
      ramoe_r       <= 1'b0;
      ramwe_r       <= 1'b0;
      sfroe_r       <= 1'b0;
      sfrwe_r       <= 1'b0;
////  ramoe_r_int   <= 1'b0;
////  ramwe_r_int   <= 1'b0;
////  ramsfroe      <= 1'b0;
      ramsfrwe      <= 1'b0;
      bitno         <= 3'b000;
      end
    else if (waitstate == 1'b0)
      begin
      ramsfraddr_s  <= ramsfraddr_comb_nxt;
      ramoe_r       <= ramoe_comb_s;
      ramwe_r       <= ramwe_comb_s;
      sfroe_r       <= sfroe_comb_s;
      sfrwe_r       <= sfrwe_comb_s;
////  ramoe_r_int   <= ramoe_comb_int;
////  ramwe_r_int   <= ramwe_comb_int;
////  ramsfroe      <= ramsfroe_comb;
      ramsfrwe      <= ramsfrwe_comb;
      if (|(phase & dec_ramsfr_bit))
        begin
        bitno     <= memdatai[2:0];
        end
      end

  end

  //--------------------------------------------------------------------
  // RAM/SFR data output - always from acc
  //--------------------------------------------------------------------
  always @(ramdatao_s or incdec_write_comb or incdec_nxt or
           acc_nxt)
  begin : ramdatao_comb_proc

    ramdatao_comb_s = ramdatao_s;

    if (incdec_write_comb == 1'b1)
      begin
      ramdatao_comb_s = incdec_nxt;
      end
    else
      begin
      ramdatao_comb_s = acc_nxt;
      end

  end

  assign ramdatao_comb = (waitstate == 1'b0) ? ramdatao_comb_s : ramdatao_s;

  //--------------------------------------------------------------------
  // Data output register
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : ramdatao_proc

    if (rst == 1'b1)
      begin
      ramdatao_r <= {{1'b0}};
      end
    else if (waitstate == 1'b0)
      begin
      ramdatao_r <= ramdatao_comb_s;
      end

  end

  assign ramdatao = ramdatao_s;

  //--------------------------------------------------------------------
  // Combinational 8-bit ALU
  //--------------------------------------------------------------------
  always @(acc_reg or temp2 or c_reg or dec_accop or
           ov_reg or ac_reg)
  begin : alu_adder
  //--------------------------------------------------------------------
    // Temporary variables
    reg  [4:0] alu_temp1;
    reg  [7:4] alu_temp2;
    reg  [8:7] alu_temp3;
    reg        cin;

    reg  [7:0] adder_in1;
    reg  [7:0] adder_in2;

    // Defaults
    adder_out = {{1'b0}};
    adder_ov  = 1'b0;
    adder_c   = 1'b0;
    adder_ac  = 1'b0;

    alu_temp1 = {{1'b0}};
    alu_temp2 = {{1'b0}};
    alu_temp3 = {{1'b0}};

    cin = 1'b0;

    adder_in1 = temp2;
    adder_in2 = acc_reg;

    // Input carry & data selection
    case (1'b1)
    dec_accop`ACC_SUBBTMP :
      begin
      cin = c_reg;
      end
    dec_accop`ACC_ADDCTMP :
      begin
      cin = c_reg;
      end
    dec_accop`ACC_SUBTMP :
      begin
      cin = 1'b0;
      end
    dec_accop`ACC_INC :
      begin
      adder_in1 = 8'b00000001;
      end
    dec_accop`ACC_DEC :
      begin
      adder_in1 = 8'b11111111;
      end
//     (|(phase & dec_spinc)) :
//       begin
//       adder_in1 = 8'b00000001;
//       adder_in2 = sp_reg;
//       end
//     (|(phase & dec_spdec)) :
//       begin
//       adder_in1 = 8'b11111111;
//       adder_in2 = sp_reg;
//       end
    dec_accop`ACC_DA :
      begin
      adder_in1 = 8'b00000000;
      if (acc_reg[3:0] > 4'b1001 || ac_reg == 1'b1)
        begin
        adder_in1[3:0] = 4'b0110;
        end
      if (c_reg == 1'b1 || acc_reg[7:4] > 4'b1001 ||
          (acc_reg[3:0] > 4'b1001 && acc_reg[7:4] > 4'b1000))
        begin
        adder_in1[7:4] = 4'b0110;
        end
      end

    default: // used also by DA, not using dec_accop
    // `ACC_ADDTMP, `ACC_MUL, `ACC_DIV :
      begin
      end

    endcase

    // Invert incomming operand for subtraction
    case (1'b1)
    dec_accop`ACC_ADDTMP,
    dec_accop`ACC_ADDCTMP,
    dec_accop`ACC_MUL,
    dec_accop`ACC_DA,
    dec_accop`ACC_INC,
    dec_accop`ACC_DEC :
//     (|(phase & dec_spinc)),
//     (|(phase & dec_spdec)) :
      begin
      end
    default:
      begin
      adder_in2 = ~adder_in2;
      cin       = ~cin;
      end
    endcase

    // Main ALU 8-bit adder
    alu_temp1 = {1'b0, adder_in1[3:0]} + {1'b0, adder_in2[3:0]} + {3'b000, cin};
    adder_ac  = alu_temp1[4];
    alu_temp2 = {1'b0, adder_in1[6:4]} + {1'b0, adder_in2[6:4]} + {2'b00, alu_temp1[4]};
    alu_temp3 = {1'b0, adder_in1[7]}   + {1'b0, adder_in2[7]}   + {1'b0, alu_temp2[7]};
    adder_ov  = alu_temp2[7] ^ alu_temp3[8];
    adder_c   = alu_temp3[8];
    adder_out = {alu_temp3[7], alu_temp2[6:4], alu_temp1[3:0]};

    // Output carry inversion for subtraction
    case (1'b1)
    dec_accop`ACC_SUBBTMP :
      begin
      adder_c  = ~adder_c;
      adder_ac = ~adder_ac;
      end
    dec_accop`ACC_SUBTMP :
      begin
      adder_c  = ~adder_c;
      adder_ac = ac_reg;
      adder_ov = ov_reg;
      end
    default :
      begin
      end
    endcase

  end

  always @(accactv or dec_accop or acc_reg or
           c_reg or adder_out or temp or temp2 or bitno or
           adder_c or adder_ov or adder_ac or b_reg or
           multemp2 or finishmul or divres1 or divres2 or
           finishdiv or
           ramsfraddr_s or
           ramsfrwe or ramdatao_s or
           divtemp2 or ac_reg or ov_reg or dec_cop)
  begin : acc_comb_proc

    //default
    acc_comb = acc_reg;
    c_comb   = c_reg;
    ac_comb  = ac_reg;
    ov_comb  = ov_reg;
    temp2_comb = temp2;
    b_comb = b_reg;

    case (1'b1)
    ((ramsfraddr_s == {1'b1, ACC_ID}) && ramsfrwe == 1'b1) :
                                       acc_comb = ramdatao_s;

    (accactv & dec_accop`ACC_RR)     : acc_comb = {acc_reg[0], acc_reg[7:1]};
    (accactv & dec_accop`ACC_RRC)    : begin
                                                      acc_comb = {c_reg, acc_reg[7:1]};
                                                      c_comb   = acc_reg[0];
                                                      end
    (accactv & dec_accop`ACC_RL)     : acc_comb = {acc_reg[6:0], acc_reg[7]};
    (accactv & dec_accop`ACC_RLC)    : begin
                                       acc_comb = {acc_reg[6:0], c_reg};
                                       c_comb   = acc_reg[7];
                                       end
    (accactv & dec_accop`ACC_INC)    : acc_comb = adder_out;
    (accactv & dec_accop`ACC_DEC)    : acc_comb = adder_out;
    (accactv & dec_accop`ACC_ORLTMP2): acc_comb = acc_reg | temp2;
    (accactv & dec_accop`ACC_ANLTMP2): acc_comb = acc_reg & temp2;
    (accactv & dec_accop`ACC_XRLTMP2): acc_comb = acc_reg ^ temp2;
    (accactv & dec_accop`ACC_SWAP)   : acc_comb = {acc_reg[3:0], acc_reg[7:4]};
    (accactv & dec_accop`ACC_CLR)    : acc_comb = {{1'b0}};
    (accactv & dec_accop`ACC_CPL)    : acc_comb = ~acc_reg;
    (accactv & dec_accop`ACC_ADDTMP),
    (accactv & dec_accop`ACC_ADDCTMP),
    (accactv & dec_accop`ACC_SUBTMP),
    (accactv & dec_accop`ACC_SUBBTMP) :
      begin
      acc_comb = adder_out;
      c_comb   = adder_c;
      ov_comb  = adder_ov;
      ac_comb  = adder_ac;
      end
    (accactv & dec_accop`ACC_DA)     :
      begin
      acc_comb = adder_out;
      c_comb   = c_reg | adder_c;
      end
    (accactv & dec_accop`ACC_MUL) :
      begin
      // Multiplication results
      acc_comb            = {multemp2[1:0], acc_reg[7:2]} ;
      c_comb              = 1'b0 ;
      if (multemp2[9:2] != 8'b00000000)
        begin
        ov_comb           = 1'b1 ;
        end
      else
        begin
        ov_comb           = 1'b0 ;
        end

      if (finishmul)
        begin
        b_comb = multemp2[9:2] ;
        end

      end

    (accactv & dec_accop`ACC_DIV) :
      begin
      // Division results
      acc_comb            = {acc_reg[5:0], divres1, divres2} ;
      c_comb              = 1'b0 ;
      if (b_reg == 8'b00000000)
        begin
        ov_comb           = 1'b1;
        end
      else
        begin
        ov_comb           = 1'b0;
        end
      if (finishdiv)
        begin
        b_comb            = divtemp2;
        end
      end

    (accactv & dec_cop`C_SET)      : c_comb = 1'b1;
    (accactv & dec_cop`C_CLR)      : c_comb = 1'b0;
    (accactv & dec_cop`C_MOV)      : c_comb = temp[bitno];
    (accactv & dec_cop`C_ORL)      : c_comb = c_reg | temp[bitno];
    (accactv & dec_cop`C_ANL)      : c_comb = c_reg & temp[bitno];
    (accactv & dec_cop`C_ORLN)     : c_comb = c_reg | ~temp[bitno];
    (accactv & dec_cop`C_ANLN)     : c_comb = c_reg & ~temp[bitno];
    (accactv & dec_cop`C_CPL)      : c_comb = ~c_reg;

    default : begin
              end
    endcase

  end

  assign dpc = dpc_reg;

  assign dparith_result = (dpc_reg[2:0] == `INC1) ? pc + 16'b0000000000000001 :
                          (dpc_reg[2:0] == `INC2) ? pc + 16'b0000000000000010 :
                          (dpc_reg[2:0] == `DEC1) ? pc + 16'b1111111111111111 :
                          (dpc_reg[2:0] == `DEC2) ? pc + 16'b1111111111111110 :
                                                    pc + 16'b0000000000000000;

  assign dptr_inc = {dph_current, dpl_current} + 1'b1;

  assign dpl_current = ((ramsfraddr_s == {1'b1, DPL_ID}) && ramsfrwe == 1'b1) ? ramdatao_s : dpl_reg[dps_comb[2:0]];

  assign dph_current = ((ramsfraddr_s == {1'b1, DPH_ID}) && ramsfrwe == 1'b1) ? ramdatao_s : dph_reg[dps_comb[2:0]];

  always @(phase or dec_dph_temp or temp or
           dec_dptrinc or dptr_inc or
           dec_dpl_temp or
           dpl_current or dph_current)
  begin : dptr_comb_proc

    dpl_comb = dpl_current;
    dph_comb = dph_current;

    // DPTR
    case (1'b1)
    (dec_dptrinc)             : dph_comb = dptr_inc[15:8];
    (|(phase & dec_dph_temp)) : dph_comb = temp;
    default:
      begin
      end

    endcase

    case (1'b1)
    (dec_dptrinc)             : dpl_comb = dptr_inc[7:0];
    (|(phase & dec_dpl_temp)) : dpl_comb = temp;
    default:
      begin
      end

    endcase

  end

  assign dps_comb =
                    (ramsfraddr_s == {1'b1, PSW_ID} && ramsfrwe == 1'b1 && dps_reg[3] == 1'b1) ? {dps_reg[3], ramdatao_s[4:3], dps_reg[0]} :
                    (ramsfraddr_s == {1'b1, DPS_ID} && ramsfrwe == 1'b1 && ramdatao_s[3] == 1'b1) ? {ramdatao_s[3], rs_reg, ramdatao_s[0]} :
                    (ramsfraddr_s == {1'b1, DPS_ID} && ramsfrwe == 1'b1) ? ramdatao_s[3:0] :
                    (dps_reg[3] == 1'b1) ? {dps_reg[3], rs_comb, dps_reg[0]} :
                    dps_reg;

  assign dps = dps_reg;


  assign rs_comb = ((ramsfraddr_s == {1'b1, PSW_ID}) && ramsfrwe == 1'b1) ? ramdatao_s[4:3] : rs_reg;

  //--------------------------------------------------------------------
  // ACC load
  //--------------------------------------------------------------------
  always @(acc_comb or dec_acc_mem or dec_acc_rn or
           dec_acc_ramsfr or dec_acc_ramdata or
           memdatai or rn_comb or ramsfrdata or dec_xchd or ramdatai or
           phase or dec_temp2acc or temp2 or
           ramsfraddr_s or
           ramsfrwe)
  begin : acc_nxt_proc

    // Default
    acc_nxt = acc_comb;

    case (1'b1)
    (|(phase & dec_acc_mem))     : acc_nxt = memdatai;
    (|(phase & dec_acc_rn))      : acc_nxt = rn_comb;
    (|(phase & dec_acc_ramsfr))  : acc_nxt = ramsfrdata;
    (|(phase & dec_acc_ramdata)) : begin
                                   if (dec_xchd == 1'b1)
                                     acc_nxt[3:0] = ramdatai[3:0];
                                   else
                                     acc_nxt = ramdatai;
                                   end
    (|(phase & dec_temp2acc) &
     ~((ramsfraddr_s == {1'b1, ACC_ID}) && ramsfrwe == 1'b1))
                                 : acc_nxt = temp2;

    default :
      begin
      end
    endcase

  end

  //--------------------------------------------------------------------
  // Special Function Registers
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : regs_proc
  integer i;
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      acc_reg       <= ACC_RV;
      b_reg         <= B_RV;
      for (i=0; i< NO_DPTRS; i=i+1)
        begin
        dpl_reg[i]  <= DPL_RV;
        dph_reg[i]  <= DPH_RV;
        dpc_tab[i]  <= {DPC_RV[8*(7-i)+5],
                        DPC_RV[8*(7-i)+4],
                        DPC_RV[8*(7-i)+3],
                        DPC_RV[8*(7-i)+2],
                        DPC_RV[8*(7-i)+1],
                        DPC_RV[8*(7-i)]};
        end
      dps_reg       <= DPS_RV[3:0];
      sp_reg        <= SP_RV;
      c_reg         <= PSW_RV[7];
      ac_reg        <= PSW_RV[6];
      f0            <= PSW_RV[5];
      rs_reg        <= PSW_RV[4:3];
      ov_reg        <= PSW_RV[2];
      f1            <= PSW_RV[1];
      pmw_reg       <= PCON_RV[4];
      temp      <= {{1'b0}};
      temp2     <= {{1'b0}};
      p2_reg        <= P2_RV;
      end
    else if (waitstate == 1'b0)
      begin
      acc_reg <= acc_nxt;
      ov_reg <= ov_comb;
      ac_reg <= ac_comb;
      c_reg  <= c_comb;
      b_reg <= b_comb;
      temp2 <= temp2_comb;
      dph_reg[dps_comb[2:0]] <= dph_comb;
      dpl_reg[dps_comb[2:0]] <= dpl_comb;
      if ((ramsfraddr_s == {1'b1, DPC_ID}) && ramsfrwe == 1'b1)
        begin
        dpc_tab[dps_reg[2:0]] <= ramdatao_s[5:0];
        end
      dps_reg <= dps_comb;

      if (pcdptr_exch)
        begin
        if (|(phase & dec_dparith_exe))
          begin
          dph_reg[dps_comb[2:0]] <= dparith_result[15:8];
          dpl_reg[dps_comb[2:0]] <= dparith_result[7:0];
          dps_reg[2:0]           <= dpc_reg[5:3];
          end
        else
          begin
          dph_reg[dps_comb[2:0]] <= pc[15:8];
          dpl_reg[dps_comb[2:0]] <= pc[7:0];
          end
        end


      rs_reg  <= rs_comb;

      if ((ramsfraddr_s == {1'b1, PSW_ID}) && ramsfrwe == 1'b1)
        begin
        // PSW write
        c_reg  <= ramdatao_s[7];
        ac_reg <= ramdatao_s[6];
        ov_reg <= ramdatao_s[2];
        f0 <= ramdatao_s[5];
        f1 <= ramdatao_s[1];
        end


      // B register
      case (1'b1)
      ((ramsfraddr_s == {1'b1, B_ID}) && ramsfrwe == 1'b1) :
        begin
        b_reg <= ramdatao_s;
        end
      default:
        begin
        end

      endcase

      // Stack Pointer
      sp_reg <= sp_comb;

      // Port 2
      p2_reg <= p2_comb;

      // pmw_reg flag of PCON
      pmw_reg <= pmw_comb;

      // Temporary register 1
      case (1'b1)
      (|(phase & dec_temp_mem))     : temp <= memdatai;
      (|(phase & dec_temp_ramdata)) : temp <= ramdatai;
      (|(phase & dec_temp_ramsfrdata)) : temp <= ramsfrdata;
      (|(phase & dec_pc2temp))      : temp <= pc[15:8];
      (|(phase & dec_temp_acc))     : temp <= acc_comb;
      (|(phase & dec_tempint))      : temp <= {8{1'b0}};

      default:
        begin
        end

      endcase

      // Temporary register 2
      case (1'b1)
      (|(phase & dec_tempint))       : temp2 <= {intvect, 3'b011};
      (|(phase & dec_temp2_mem))     : temp2 <= memdatai;
      (|(phase & dec_temp2_ramdata)) : temp2 <= ramdatai;
      (|(phase & dec_acc2temp))      : temp2 <= acc_comb;
      (|(phase & dec_temp2_rn))      : temp2 <= rn_comb;
      (|(phase & dec_pc2temp))       : temp2 <= pc[7:0];
      (|(phase & dec_pci2temp))      :
                                         temp2 <= pc_i[15:8];
      (|(phase & dec_temp2temp))     : temp2 <= temp;

      default:
        begin
        end

      endcase

      end
  end

  assign dpc_reg = dpc_tab[dps_reg[2:0]];

  assign pmw_comb =
     ((ramsfraddr_s == {1'b1, PCON_ID}) && ramsfrwe == 1'b1) ?
    ramdatao_s[4] : pmw_reg;

  always @(sp_reg or phase or dec_spinc or dec_spdec or incdec_out or
           ramsfraddr_s or
           ramsfrwe or ramdatao_s)
  begin : sp_comb_proc
    // default
    sp_comb = sp_reg;

    if ((ramsfraddr_s == {1'b1, SP_ID}) && ramsfrwe == 1'b1)
      begin
      sp_comb = ramdatao_s;
      end

    case (1'b1)
    (|(phase & dec_spinc)) : sp_comb = sp_comb + 8'b00000001;
    (|(phase & dec_spdec)) : sp_comb = sp_comb + 8'b11111111;

    default:
      begin
      end

    endcase

  end

  assign p2_comb =
    (
      (ramsfraddr_s == {1'b1, P2_ID}) && ramsfrwe == 1'b1) ?
    ramdatao_s : p2_reg;

  // RAM/SFR data selection for reading
  assign ramsfrdata = (ramsfraddr_s[7] == 1'b1) ? sfrdatai : ramdatai;

  // RAM read signal generation
  assign ramoe = ramoe_r;

  // RAM write signal generation
  assign ramwe = ramwe_r;

  // SFR read signal generation
  assign sfroe = (sfroe_r & !waitstate);

  // SFR write signal generation
  assign sfrwe = (sfrwe_r & !waitstate);

  //--------------------------------------------------------------------
  // Combinational 16-bit ALU for PC/DPTR calculation
  //--------------------------------------------------------------------
  always @(pc or temp or acc_comb or dptrbranch or
           apcbranch or dpl_comb or dph_comb)
  begin : alu_proc
  //--------------------------------------------------------------------

    reg [15:0] adder_in1;
    reg [15:0] adder_in2;

    alu_out = {{1'b0}};
    adder_in1 = {{8{temp[7]}}, temp};
    adder_in2 = pc;


    case (1'b1)
    dptrbranch    : begin
                    adder_in1 = {8'b00000000, acc_comb};
                    adder_in2 = {dph_comb, dpl_comb};
                    end
    apcbranch     : begin
                    adder_in1 = {8'b00000000, acc_comb};
                    end

    default       :
      begin
      end
    endcase

    alu_out = adder_in1 + adder_in2;

  end

  //--------------------------------------------------------------------
  // Branch after DPTR
  //--------------------------------------------------------------------
  assign dptrbranch = ((phase & dec_dptrbranch) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // acc_reg+PC branch
  //--------------------------------------------------------------------
  assign apcbranch = ((phase & dec_apcbranch) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // New instruction
  //--------------------------------------------------------------------
  assign newinstr_c = ((phase & dec_newinstr) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // New instruction output to the peripherals
  //--------------------------------------------------------------------
  assign newinstr = phase0_ff & ~waitstate;

  //--------------------------------------------------------------------
  // Data fetch to the OCDS
  //--------------------------------------------------------------------
  assign datafetch_nxt = ((phase & dec_fetch) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // PC<->DPTR exchange
  //--------------------------------------------------------------------
  assign pcdptr_exch = ((phase & dec_pcdptr_exch) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // Relative / conditional branch decision
  //--------------------------------------------------------------------
  assign relbranch   = ((phase & dec_relbranch) != 0 &&
                        (
                          (dec_branchcond`BRANCH_TRUE) ||
                          (dec_branchcond`BRANCH_ACCZERO  && acc_comb == {8{1'b0}}) ||
                          (dec_branchcond`BRANCH_ACCNZERO && acc_comb != {8{1'b0}}) ||
                          (dec_branchcond`BRANCH_BIT      && acc_reg[bitno] == 1'b1) ||
                          (dec_branchcond`BRANCH_NBIT     && acc_reg[bitno] == 1'b0) ||
                          (dec_branchcond`BRANCH_C        && c_comb == 1'b1) ||
                          (dec_branchcond`BRANCH_NC       && c_comb == 1'b0)
                        )
                       ) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // Absolute branch
  //--------------------------------------------------------------------
  assign absbranch   = ((phase & dec_absbranch) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // Long branch
  //--------------------------------------------------------------------
  assign longbranch  = ((phase & dec_longbranch) != 0) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // XCHD instruction decoder
  //--------------------------------------------------------------------
  assign dec_xchd = (instr == XCHD_IR0 || instr == XCHD_IR1) ? 1'b1 : 1'b0;

  //--------------------------------------------------------------------
  // acc_reg output
  //--------------------------------------------------------------------
  assign acc = acc_reg;

  //--------------------------------------------------------------------
  // b_reg output
  //--------------------------------------------------------------------
  assign b   = b_reg;

  //--------------------------------------------------------------------
  // DPTR low part output
  //--------------------------------------------------------------------
  assign dpl = dpl_reg[dps_reg[2:0]];

  //--------------------------------------------------------------------
  // DPTR high part output
  //--------------------------------------------------------------------
  assign dph = dph_reg[dps_reg[2:0]];

  //--------------------------------------------------------------------
  // Stack Pointer output
  //--------------------------------------------------------------------
  assign sp  = sp_reg;

  //--------------------------------------------------------------------
  // Carry output
  //--------------------------------------------------------------------
  assign c   = c_reg;

  //--------------------------------------------------------------------
  // Auxiliary carry output
  //--------------------------------------------------------------------
  assign ac  = ac_reg;

  //--------------------------------------------------------------------
  // Register select output
  //--------------------------------------------------------------------
  assign rs  = rs_reg;

  //--------------------------------------------------------------------
  // Overflow flag output
  //--------------------------------------------------------------------
  assign ov  = ov_reg;

  //--------------------------------------------------------------------
  // Parity flag output
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : p_proc
    if (rst == 1'b1)
      begin
      p <= PSW_ID[0];
      end
    else if (waitstate == 1'b0)
      begin
      p <= ^acc_nxt;
      end
  end

  //--------------------------------------------------------------------
  // Program Memory Write flag output
  //--------------------------------------------------------------------
  assign pmw = pmw_reg;

  //--------------------------------------------------------------------
  // Interrupt acknowledge output
  //--------------------------------------------------------------------
  assign intcall = interrupt & phase[0];

  //--------------------------------------------------------------------
  // RETI instruction decoder
  //--------------------------------------------------------------------
  assign retiinstr = (instr == RETI && phase[1] == 1'b1) ? 1'b1 : 1'b0;

  always @(israccess or instr or
           ramsfraddr_comb_s or
           ramsfrwe_comb)
  begin : israccess_comb_proc

    israccess_comb = israccess;
    if (instr == RETI ||
        (
         ramsfraddr_comb_s == {1'b1, IEN0_ID} ||
         ramsfraddr_comb_s == {1'b1, IEN1_ID} ||
         ramsfraddr_comb_s == {1'b1, IEN2_ID} ||
         ramsfraddr_comb_s == {1'b1, IEN3_ID} ||
         ramsfraddr_comb_s == {1'b1, IEN4_ID} ||
         ramsfraddr_comb_s == {1'b1, IP0_ID}  ||
         ramsfraddr_comb_s == {1'b1, IP1_ID}
        ) && ramsfrwe_comb
       )
      begin
      israccess_comb = 1'b1;
      end
  end

  always @(posedge clkcpu)
  begin : israccess_proc

    if (rst == 1'b1)
      begin
      israccess <= 1'b0;
      end
    else if (waitstate == 1'b0)
      begin
      israccess <= israccess_comb & !newinstr_c;
      end
  end

  assign codefetch_s = mempsrd_s & (newinstr_c | (state == `STATE_IDLE) | (phase == {MAX_CYCLES+1{1'b0}}))
                       ;
  assign datafetch_s = mempsrd_s & !newinstr_c & (|(phase & dec_fetch));

  assign irq_int = irq & ~israccess_comb;

//assign mempsrd = mempsrd_s;
  assign mempswr = mempswr_s;
  assign memrd = memrd_s;
  assign memwr = memwr_s;
  assign ramsfraddr = ramsfraddr_s;
  assign p2 = p2_reg;

  assign waitstate = (
                       (mempsrd_s
                        | mempswr_s
                       ) & (!mempsack
                            | !(waitcnt >= ckcon_r[6:4])
                            )
                     ) |
                     (
                       (memrd_s | memwr_s)
                       & (!memack
                          | !(waitcnt >= ckcon_r[2:0])
                          )
                     ) |
                     ((sfroe_r | sfrwe_r) & !sfrack);

  assign waitstaten = !waitstate;

  assign async_write =
                       (pmw_s == 1'b1 && (ramsfraddr_s == {1'b1, CKCON_ID}) && ramsfrwe == 1'b1) ? ramdatao_s[7] :
                       (pmw_s == 1'b1) ? ckcon_s[7] :
                       ((ramsfraddr_s == {1'b1, CKCON_ID}) && ramsfrwe == 1'b1) ? ramdatao_s[3] :
                       ckcon_s[3];

  assign ckcon_s = ((ramsfraddr_s == {1'b1, CKCON_ID}) && ramsfrwe == 1'b1) ? ramdatao_s : ckcon_r;

  always @(posedge clkcpu)
  begin : waitstate_gen_proc
    if (rst == 1'b1)
      begin
      ckcon_r <= 8'h00 ;////CKCON_RV;
      waitcnt <= {{1'b0}};
////  async_write_r <= 1'b0;
      end
    else
      begin
      if (waitstate == 1'b0)
        begin
        ckcon_r <= ckcon_s;

////    if (phase[0] == 1'b1)
////      begin
////      // Sample at the beginning of new instruction
////      async_write_r <= async_write;
////      end
        end
      // New waitstate
      if (mempsrd_s == 1'b1
          || mempswr_s == 1'b1
          )
        begin
        if (waitcnt >= ckcon_r[6:4])
          begin
          if (mempsack == 1'b1 && !((sfroe_r == 1'b1 || sfrwe_r == 1'b1) && sfrack == 1'b0))
            begin
            waitcnt <= 3'b000;
            end
          end
        else
          begin
          waitcnt <= waitcnt + 1'b1;
          end
        end

      if (memrd_s == 1'b1 || memwr_s == 1'b1)
        begin
        if (waitcnt >= ckcon_r[2:0])
          begin
          if (memack == 1'b1 && !((sfroe_r == 1'b1 || sfrwe_r == 1'b1) && sfrack == 1'b0))
            begin
            waitcnt <= 3'b000;
            end
          end
        else
          begin
          waitcnt <= waitcnt + 1'b1;
          end
        end

      end
  end

  assign ckcon = ckcon_r;

  //--------------------------------------------------------------------
  // Working Registers R0..R7 by 4 banks
  //--------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : rn_proc
  integer i;
  //--------------------------------------------------------------------
    if (rst == 1'b1)
      begin
      for (i=0;i<32;i=i+1)
        begin
        rn_reg[i] <= 8'b00000000;
        end
      end
    else if (waitstate == 1'b0)
      begin
      case (1'b1)
//       (|(phase & (dec_rn_inc | dec_rn_dec | dec_rn_ramsfr))) :
//         begin
//         rn_reg[rnindex] <= incdec_out;
//         end
//       (|(phase & (dec_rn_acc))) :
//         begin
//         rn_reg[rnindex] <= acc_comb;
//         end
//    ((ramsfrwe | ramwe_r) && ramsfraddr_s[7:5] == 3'b000) :
      (ramwe_r & (ramsfraddr_s[7:5] == 3'b000)) :
        begin
        rn_reg[ramsfraddr_s[4:0]] <= ramdatao_s;
        end
      default :
        begin
        end
      endcase
      end
  end

  assign rnindex = (|dec_ramsfr_ri) ? {rs_comb, 2'b00, instr[0]} : {rs_comb, instr[2:0]};

  assign rn = rn_reg[rnindex];
  assign rn_comb = ((ramsfraddr_s == {3'b000, rnindex}) && ((ramwe_r) == 1'b1)) ? ramdatao_s : rn;

  // ----------------------------------------------
  // Partial adder for multiplication
  // ----------------------------------------------
  assign multemp1 = (acc_reg[0] == 1'b1) ? {1'b0, multempreg} + {1'b0, b_reg} :
                                           {1'b0, multempreg} ;

  // ----------------------------------------------
  // Partial adder for multiplication
  // ----------------------------------------------
  assign multemp2 = (acc_reg[1] == 1'b1) ? {({1'b0, multemp1[8:1]} +
                                             {1'b0, b_reg}), multemp1[0]} :
                                             {1'b0, multemp1[8:0]} ;

  // ----------------------------------------------
  // Temporary result register for multiplication
  // ----------------------------------------------
  always @(posedge clkcpu)
  begin : multempreg_proc
    if (rst == 1'b1)
    // ----------------------------------------------
    // Synchronous reset
    // ----------------------------------------------
      begin
      multempreg <= {8{1'b0}} ;
      end
    else
    // ----------------------------------------------
    // Synchronous write
    // ----------------------------------------------
      begin
      if (waitstate == 1'b0) // No operation during a waitstate
        begin
        if (finishmul)
          begin
          multempreg <= {8{1'b0}} ; // Cleared by default
          end
        else if (accactv & dec_accop`ACC_MUL)    // Perform multiplication
          begin
          multempreg <= multemp2[9:2] ;
          end
        end
      end
  end

  // ----------------------------------------------
  // Partial subtractor for division
  // ----------------------------------------------
  always @(divtempreg or acc_reg or b_reg)
  begin : divtemp1_proc

    reg       [ 8: 0] div1temp;

    div1temp = {1'b0, divtempreg[6:0], acc_reg[7]} - {1'b0, b_reg};
    divres1  = ~div1temp[8] ;
    if ((div1temp[8]) == 1'b1)
      begin
      divtemp1 = {divtempreg[5:0], acc_reg[7]} ;
      end
    else
      begin
      divtemp1 = div1temp[6:0] ;
      end
  end

  // ----------------------------------------------
  // Partial subtractor for division
  // ----------------------------------------------
  always @(divtemp1 or acc_reg or b_reg)
  begin : divtemp2_proc
    reg       [ 8: 0] div2temp;

    div2temp = {1'b0, divtemp1[6:0], acc_reg[6]} - {1'b0, b_reg};
    divres2  = ~div2temp[8] ;
    if ((div2temp[8]) == 1'b1)
      begin
      divtemp2 = {divtemp1[6:0], acc_reg[6]} ;
      end
    else
      begin
      divtemp2 = div2temp[7:0] ;
      end
  end

  // ----------------------------------------------
  // Partial result register for division
  // ----------------------------------------------
  always @(posedge clkcpu)
  begin : divtempreg_proc
    if (rst == 1'b1)
    // ----------------------------------------------
    // Synchronous reset
    // ----------------------------------------------
      begin
      divtempreg <= {7{1'b0}} ;
      end
    else
    // ----------------------------------------------
    // Synchronous write
    // ----------------------------------------------
      begin
      if (waitstate == 1'b0) // No operation during a waitstate
        begin
        if (finishdiv)
          begin
          divtempreg <= {7{1'b0}} ;     // Cleared by default
          end
        else if (accactv & dec_accop`ACC_DIV)
          begin
          divtempreg <= divtemp2[6:0] ; // Perform division
          end
        end
      end
  end

//assign flush_s = |(phase & dec_flush) & ~waitstate & !(condbranch_ineff)
//               ;
  //-------------------------------------------------------------------
  // cpu_resume flip-flops
  //-------------------------------------------------------------------
  always @(posedge clkcpu)
  begin : cpu_resume_proc
    if (rst == 1'b1)
    begin
      cpu_resume_ff1 <= 1'b0;
      cpu_resume_fff <= 1'b0;
    end
    else
    begin
      cpu_resume_ff1 <= cpu_resume
                        | irq
                        ;
      cpu_resume_fff <= cpu_resume_ff1;
    end
  end

endmodule // mcu51_cpu

