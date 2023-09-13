
`define MCU51MDU
module mcu51 (
//// ------------------------------------------------------------------
////
input		bclki2c		,
input	[15:0]	pc_ini		,
input		slp2wakeup	, // wakeup by pmuintreq is not long enough
		r_hold_mcu	,
		wdt_slow	,
output	[1:0]	wdtov		, // Watchdog Timer overflow/int wakeup
output		mdubsy		,
output		cs_run		, // cpu in RUN_STATE
output		t0_intr		, // timer0 overflow and its int enabled

input           clki2c		,
input           clkmdu		,
input           clkur0		,
input           clktm0		,
input           clktm1		,
input           clkwdt		,

input		i2c_autoack	,
output		i2c_con_ens1	,

//// ------------------------------------------------------------------
//// 
// Control signal inputs
input           clkcpu		, // CPU clock input
input           clkper		, // Peripheral clock input
input           reset		, // Hardware reset input
output          ro		, // Reset output

// Port inputs
input	[7:0]	port0i		,

// External interrupt/Port alternate signals
input		exint_9		, // external interrupt
input	[7:0]	exint		, // [0]0x03, fall/low, wakeup
				  // [1]0x13, fall/low, wakeup
				  // [2]0x4B, fall/rise
				  // [3]0x53, fall/rise
				  // [4]0x5B, rise
				  // [5]0x63, rise
				  // [6]0x6B, rise
				  // [7]0x43, rise

// Control signal outputs
output          clkcpuen	, // CPU clock enable output
output          clkperen	, // Peripheral clock enable output

// Port outputs
output  [ 7: 0] port0o, port0ff	,

// Serial/Port alternate signals
output          rxd0o		, // Serial 0 receive clock
output          txd0		, // Serial 0 transmit data
input           rxd0i		, // Serial 0 receive data
output		rxd0oe		,

//I2C
// Serial inputs
input           scli		, // I2C clock input
input           sdai		, // I2C data input
// Serial outputs
output          sclo		, // I2C clock output - registered
output          sdao		, // I2C data output  - registered

output          waitstaten	,

// Memory interface
input           mempsack	, // Memory interface
input           memack		, // Memory interface
input   [ 7: 0] memdatai	, // Memory interface

output  [ 7: 0] memdatao	, // Memory interface
output	[15: 0] memaddr		, // Memory interface
output          mempswr		, // Program store write enable
output          mempsrd		, // Program store read enable
output          memwr		, // Memory write enable
output          memrd		, // Memory read enable

// Combinational interface for posedge memories
output  [ 7: 0] memdatao_comb	, // Combintional interface for posedge memories
output	[15: 0]	memaddr_comb	, // Combintional interface for posedge memories
output          mempswr_comb	, // Program store write enable
output          mempsrd_comb	, // Program store read enable
output          memwr_comb	, // Memory write enable
output          memrd_comb	, // Memory read enable

// Data file interface
input   [ 7: 0] ramdatai	,
output  [ 7: 0] ramdatao	,
output  [ 7: 0] ramaddr		,
output		ramwe		, // Data file write enable
output		ramoe		, // Data file output enable

// debug port
output	[31: 0]	dbgpo		,

// Special function register interface
input		sfrack		, // SFR acknowledge input
input   [ 7: 0] sfrdatai	, // external SFR out-bus
output  [ 7: 0] sfrdatao	,
output  [ 6: 0] sfraddr		,
//tput	[ 6: 0]	sfridx		,
output		sfrwe		, // SFR write enable
output		sfroe		, // SFR output enable
//*******************************************************************//
input	[7:0]	esfrm_wrdata	, // external SFR master in-bus
input	[6:0]	esfrm_addr	,
//put	[6:0]	esfrm_idx	,
input		esfrm_we	,
		esfrm_oe	,
output	[7:0]	esfrm_rddata
);
  //-------------------------------------------------------------------
  // MCU51 CPU output signals
  //-------------------------------------------------------------------
  wire         [15: 0] memaddr16;  // Program / XDATA addres bus
  wire         [ 7: 0] cpumemdatai;// Data bus to CPU
  wire                 mempswr_s;  // Program Write Enable
  wire                 mempsrd_s;  // Program Read Enable
  wire                 memwr_s;    // XDATA Write Enable
  wire                 memrd_s;    // XDATA Read Enable
  wire         [15: 0] memaddr16_comb;  // Program / XDATA addres bus
  wire                 mempswr_comb_s;  // Program Write Enable
  wire                 mempsrd_comb_s;  // Program Read Enable
  wire                 memwr_comb_s;    // XDATA Write Enable
  wire                 memrd_comb_s;    // XDATA Read Enable
  wire         [ 7: 0] ramdatao_s; // RAM/SFR output data
  wire         [ 7: 0] ramsfraddr; // RAM/SFR address bus
  wire                 ramwe_s;    // RAM Write Enable
  wire                 ramoe_s;    // RAM Read Enable
  wire                 sfrwe_s;    // SFR Write Enable
  wire                 sfroe_s;    // SFR Read Enable
  wire                 sfroe_r;    // SFR read enable (registered)
  wire                 sfrwe_r;    // SFR write enable (registered)
  wire                 sfrack_int; // SFR acknowledge
  wire         [ 7: 0] ramdatao_comb;
  wire         [ 7: 0] ramsfraddr_comb;
  wire                 ramwe_comb;
  wire                 ramoe_comb;

  wire                 intcall;    // Interrupt in progress signal
  wire                 retiinstr;  // Return from Interrupt instr. indicator
  wire                 newinstr;   // New instruction beginning indicator
  wire                 rmwinstr;   // Read-Modify-Write instruction indicator
  wire         [ 7: 0] ckcon;      // Wait state control
  wire                 pmw;        // Program Memory Write bit
  wire                 smod;       // Serial Port Baudrate Doubler bit of PCON
  wire                 p2sel;      //
  wire                 gf0;        // General Purpose bit 0 of PCON
  wire                 stop;       // STOP mode request to the PMURSTCTRL
  wire                 idle;       // IDLE mode request to the PMURSTCTRL
  wire                 stop_flag;  // STOP mode request to the SFRMUX
  wire                 idle_flag;  // IDLE mode request to the SFRMUX
  wire         [ 7: 0] acc_s;      // Accumulator register
  wire         [ 7: 0] b;          // B register
  wire         [ 1: 0] rs;         // Register Bank Select field of the PSW
  wire                 c;          // Carry Flag of the PSW
  wire                 ac;         // Auxiliary Carry Flag of the PSW
  wire                 ov;         // Overflow Flag of the PSW
  wire                 f0;         // General Purpose Flag 0 of the PSW
  wire                 f1;         // General Purpose Flag 1 of the PSW
  wire                 p;          // Parity Flag of the PSW
  wire         [ 7: 0] dph;        // Data Pointer high-order byte
  wire         [ 7: 0] dpl;        // Data Pointer low-order byte
  wire         [ 3: 0] dps;        // Data Pointer Select register
  wire         [ 7: 0] p2;         // Port 2 register (for addressing)
  wire         [ 5: 0] dpc;        // Data Poitner Control register
  wire         [ 7: 0] sp;         // Stack Pointer register

  //-------------------------------------------------------------------
  // PMU / Reset Control signals
  //-------------------------------------------------------------------
  wire                 rstff;      // Global synchronous reset
  wire                 resetff;    // Global synchronous reset
  wire                 rst;        // Global synchronous reset
  wire                 rsttowdt;   // Synchronous reset of WATCHDOG
  wire                 rsttowdtff; // Synchronous reset of WATCHDOG
  wire                 rsttosrst;  // Synchronous reset of SRST
  wire                 rsttosrstff;// Synchronous reset of SRST
  wire                 cpu_resume;

  //-------------------------------------------------------------------
  // Power-down mode wake-up request (WAKEUPCTRL signals)
  //-------------------------------------------------------------------
  wire                 pmuintreq;  // Interrupt request from WAKEUPCTRL
  wire                 pmuintreq_rev; // extended pmuintreq

  //-------------------------------------------------------------------
  // Interrupt Service Routine signals
  //-------------------------------------------------------------------
  wire                 irq;        // Interrupt Request to the CPU
  wire         [ 4: 0] intvect;    // Intrerrupt vector
  wire         [ 3: 0] isreg;      // In-service register
  wire                 eal;        // Global interrupts enable
  wire         [ 7: 0] ien0;       // Interrupt enable register 0
  wire         [ 5: 0] ip0;        // Interrupt priority register 0
  wire         [ 5: 0] ien1;       // Interrupt enable register 1
  wire         [ 5: 0] ien2;       // Interrupt enable register 2
  wire         [ 5: 0] ip1;        // Interrupt priority register 1
  wire         [ 1: 0] intprior0;  // Ext. interrupt 0 priority
  wire                 eint0;      // Ext. interrupt 0 enable
  wire                 int0ack;    // Ext. interrupt 0 acknowledge
  wire         [ 1: 0] intprior1;  // Ext. interrupt priority bit 1
  wire                 eint1;      // Ext. interrupt 1 enable
  wire                 int1ack;    // Ext. interrupt 1 acknowledge
  wire                 t0ack;      // Timer 0 interrupt acknowledge
  wire                 t1ack;      // Timer 1 interrupt acknowledge
  wire                 iex2ack;    // Ext. interrupt 2 acknowledge
  wire                 iex3ack;    // Ext. interrupt 3 acknowledge
  wire                 iex4ack;    // Ext. interrupt 4 acknowledge
  wire                 iex5ack;    // Ext. interrupt 5 acknowledge
  wire                 iex6ack;    // Ext. interrupt 6 acknowledge
  wire                 iex7ack;    // Ext. interrupt 7 acknowledge
  wire                 iex8ack;    // Ext. interrupt 8 acknowledge
  wire                 iex9ack;    // Ext. interrupt 9 acknowledge
  wire                 iex10ack;   // Ext. interrupt 10 acknowledge
  wire                 iex11ack;   // Ext. interrupt 11 acknowledge
  wire                 iex12ack;   // Ext. interrupt 12 acknowledge


  //-------------------------------------------------------------------
  // Extenral Interrupts signals
  //-------------------------------------------------------------------
  wire                 it0;        // External Interrupt 0 edge/level control bit of TCON
  wire                 ie0;        // External Interrupt 0 request flag of TCON
  wire                 it1;        // External Interrupt 1 edge/level control bit of TCON
  wire                 ie1;        // External Interrupt 1 request flag of TCON
  wire                 iex2;       // External Interrupt 2 / CC0 request flag
  wire                 iex3;       // External Interrupt 3 / CC1 request flag
  wire                 iex4;       // External Interrupt 4 / CC2 request flag
  wire                 iex5;       // External Interrupt 5 / CC3 request flag
  wire                 iex6;       // External Interrupt 6 request flag
  wire                 iex7;       // External Interrupt 7 request flag
  wire                 iex8;       // External Interrupt 8 request flag
  wire                 iex9;       // External Interrupt 9 request flag
  wire                 iex10;      // External Interrupt 10 request flag
  wire                 iex11;      // External Interrupt 11 request flag
  wire                 iex12;      // External Interrupt 12 request flag
  wire                 i2fr;       // External Interrupt 2 rising/falling edge selection
  wire                 i3fr;       // External Interrupt 3 rising/falling edge selection

  //-------------------------------------------------------------------
  // DMA and External Interrupts signals
  //-------------------------------------------------------------------
  wire                 int_vect_8b;
  wire                 int_vect_93;
  wire                 int_vect_9b;
  wire                 int_vect_a3;

  //-------------------------------------------------------------------
  // Special Function Registers Mux signal
  //-------------------------------------------------------------------
  wire         [ 7: 0] sfrdata;
  wire                 tf1_gate;
  wire                 riti0_gate;

  //-------------------------------------------------------------------
  reg [13:0] timer_1ms;
  wire timer_1ms_to = timer_1ms==('d12*'d1000-'d1);
  always @(posedge clkper)
     if (reset | timer_1ms_to | ~ien2[1])
        timer_1ms <= 'h0;
     else
        timer_1ms <= timer_1ms + 'h1;
  //-------------------------------------------------------------------
  // Synchronization flip-flops for asynchronous inputs
  //-------------------------------------------------------------------
  wire                 int0ff;     // Ext. Interrupt 0 sample
  wire                 int1ff;     // Ext. Interrupt 1 sample
  wire                 int2ff = exint[2]; // Ext. Interrupt 2 sample
  wire                 int3ff = exint[3]; // Ext. Interrupt 3 sample
  wire                 int4ff = exint[4]; // Ext. Interrupt 4 sample
  wire                 int5ff = exint[5]; // Ext. Interrupt 5 sample
  wire                 int6ff = exint[6]; // Ext. Interrupt 6 sample
  wire                 int7ff = exint[7]; // Ext. Interrupt 7 sample
  wire                 int8ff = timer_1ms_to; // Ext. Interrupt 8 sample, 0x8B
  wire                 int9ff = exint_9;      // Ext. Interrupt 9 sample, 0x93
  wire                 int10ff;    // Ext. Interrupt 10 sample
  wire                 int11ff;    // Ext. Interrupt 11 sample
  wire                 int12ff;    // Ext. Interrupt 12 sample
  wire                 t0ff;       // Timer 0 input sample
  wire                 t1ff;       // Timer 1 input sample
  wire                 rxd0ff;     // Serial Interface 0 input sample

  //-------------------------------------------------------------------
  // I/O Port signals
  //-------------------------------------------------------------------
  wire         [ 7: 0] port0;      // PORT 0 output register

  //-------------------------------------------------------------------
  // Multiplication/Division Unit signals
  //-------------------------------------------------------------------
`ifdef MCU51MDU
  wire         [ 7: 0] arcon;      // MDU control register
  wire         [ 7: 0] md0;        // M/D register 0
  wire         [ 7: 0] md1;        // M/D register 1
  wire         [ 7: 0] md2;        // M/D register 2
  wire         [ 7: 0] md3;        // M/D register 3
  wire         [ 7: 0] md4;        // M/D register 4
  wire         [ 7: 0] md5;        // M/D register 5
`endif // MCU51MDU
  //-------------------------------------------------------------------
  // Timer 0 signals
  //-------------------------------------------------------------------
  wire         [ 3: 0] t0_tmod;    // Timer 0 related part of TMOD
  wire                 t0_tf0;     // Timer 0 overflow flag
  wire                 t0_tf1;     // Timer 1 overflow flag generated by Timer0 in mode 3
  wire                 t0_tr0;     // Timer 0 enable flag
  wire                 t0_tr1;     // Timer 0 enable flag
  wire         [ 7: 0] tl0;        // Timer 0 low-order byte
  wire         [ 7: 0] th0;        // Timer 0 high-order byte

  //-------------------------------------------------------------------
  // Timer 1 signals
  //-------------------------------------------------------------------
  wire         [ 3: 0] t1_tmod;    // Timer 1 related part of TMOD
  wire                 t1_tf1;     // Timer 1 overflow flag
  wire                 t1_tr1;     // Timer 1 enable flag
  wire         [ 7: 0] tl1;        // Timer 1 low-order byte
  wire         [ 7: 0] th1;        // Timer 1 high-order byte
  wire                 t1ov;       // Timer 1 overflow / Serial 0 baud rate source

  wire         [ 7: 0] t2con;      // Timer 2 Control register (Combined with EXTINT)

  //-------------------------------------------------------------------
  // Watchdog Timer signals
  //-------------------------------------------------------------------
  wire         [ 7: 0] wdtrel;     // Watchdog Reload register
  wire                 wdts;       // Watchdog Timer overflow
  wire                 ip0wdts;    // WDT status flag
  wire                 wdt_tm;     // WDT test mode

  //-------------------------------------------------------------------
  // Software reset signals
  //-------------------------------------------------------------------
  wire                 srst;       // Software reset
  wire                 srstflag;   // Software reset status flag

  //-------------------------------------------------------------------
  // Serial 0 signals
  //-------------------------------------------------------------------
  wire         [ 7: 0] s0con;      // Serial 0 Control register
  wire         [ 7: 0] s0buf;      // Serial 0 Data Buffer register
  wire         [ 7: 0] s0rell;     // Serial 0 Baudrate Reload register
  wire         [ 7: 0] s0relh;     // Serial 0 Baudrate Reload register
  wire                 bd;         // Serial 0 baudrate doubler


  //---------------------------------------------------------------
  // I2C Serial signals
  //---------------------------------------------------------------
  wire         [ 7: 0] i2cdat_o;
  wire         [ 7: 0] i2cadr_o;
  wire         [ 7: 0] i2ccon_o;
  wire         [ 7: 0] i2csta_o;
  wire                 i2c_int;
  wire                 sdaiff;
  wire                 iex7_gate;

  wire                 iex2_gate;

  wire                 isr_tm;

  wire                 waitstaten_s;
  wire           [4:0] intvect_int;
  wire           [7:0] sfrdata_cpu;
  wire                 sfrwe_mcu51_per;
  wire                 sfroe_mcu51_per;
  wire                 sfrwe_ext_per;
  wire                 sfroe_ext_per;
  wire                 newinstr_cpu;
  wire                 ext_sfr_sel; // isfr_sel
  wire                 intcall_int;
  wire                 retiinstr_int;

//// ------------------------------------------------------------------
////
// wire [6:0] isfr_idx;
// wire sfrwe_comb_s, sfroe_comb_s;
// wire pre_sfrreq = sfrwe_comb_s | sfroe_comb_s;
// wire pre_sfrreqT1 = pre_sfrreq & waitstaten; // low-active waitstate

// sfridx u_sfridx (
//	.i_clk		(clkcpu),
//	.i_rstz		(1'h1),
//	.i_srst		(rstff),
//	.pre_reqT1	(pre_sfrreqT1),
//	.pre_we		(sfrwe_comb_s),
//	.pre_paddr	(ramsfraddr_comb[6:0]),
//	.idx		(isfr_idx)
//); // u_sfridx

   wire t_shift_clk, r_shift_clk, codefetch;
   wire   [7:0]  instr;
   wire   [15:0] pc_o;
   assign dbgpo = {	instr,
//			codefetch, txd0, r_shift_clk,
//			rxd0oe,
			rxd0i, ro, retiinstr, irq,
			t0_tf1|t1_tf1, t0_tr1|t1_tr1, t0_tf0, t0_tr0,
			pc_o[15:0]
			};

  //-------------------------------------------------------------------
  // CPU <-> MEMMUX signals
  //-------------------------------------------------------------------
  wire                         memack_s;
  wire [7:0]                   memdatai_s;

  //*******************************************************************--

  assign memaddr = memaddr16;

  assign memaddr_comb = memaddr16_comb;


  //------------------------------------------------------------------
  // Reset output
  // ro_drv :
  //------------------------------------------------------------------
  assign ro = rstff;

  //------------------------------------------------------------------
  // Memory interface; Data bus output
  // memdatao_drv :
  //------------------------------------------------------------------
  assign memdatao = ramdatao_s;
  assign memdatao_comb = ramdatao_comb;

  //------------------------------------------------------------------
  // Memory interface; Program write enable output
  // mempswr_drv :
  //------------------------------------------------------------------
  assign mempswr =
                   mempswr_s
                  ;

  assign mempswr_comb =
                   mempswr_comb_s
                  ;

  //------------------------------------------------------------------
  // STOP flag for SFRMUX
  //------------------------------------------------------------------
  assign stop_flag =
                 stop
                 ;

  //------------------------------------------------------------------
  // IDLE flag for SFRMUX
  //------------------------------------------------------------------
  assign idle_flag =
                 idle
                 ;

  //------------------------------------------------------------------
  // Memory interface; Program read enable output
  // mempsrd_drv :
  //------------------------------------------------------------------
  assign mempsrd = mempsrd_s;
  assign mempsrd_comb = mempsrd_comb_s;

  //------------------------------------------------------------------
  // Memory interface; Data write enable output
  // memwr_drv :
  //------------------------------------------------------------------
  assign memwr = memwr_s;
  assign memwr_comb = memwr_comb_s;

  //------------------------------------------------------------------
  // Memory interface; Data read enable output
  // memrd_drv :
  //------------------------------------------------------------------
  assign memrd = memrd_s;
  assign memrd_comb = memrd_comb_s;

  //------------------------------------------------------------------
  // Data file interface; Data bus output
  // ramdatao_drv :
  //------------------------------------------------------------------
  assign ramdatao = ramdatao_comb;
  //------------------------------------------------------------------
  // Data file interface; Address bus output
  // ramaddr_drv :
  //------------------------------------------------------------------
  assign ramaddr = ramsfraddr_comb;
  //------------------------------------------------------------------
  // Data file interface; Write enable output
  // ramwe_drv :
  //------------------------------------------------------------------
  assign ramwe = ramwe_comb;

  //------------------------------------------------------------------
  // Data file interface; Read enable output
  // ramoe_drv :
  //------------------------------------------------------------------
  assign ramoe = ramoe_comb;

  //------------------------------------------------------------------
  // External Special function register interface; Data bus output
  // sfrdatao_drv :
  //------------------------------------------------------------------
  wire [6:0] isfraddr = sfraddr;
  wire [7:0] isfrdatai = sfrdatao;
  wire isfrwait = esfrm_we | esfrm_oe;

  assign sfrdatao = isfrwait ? esfrm_wrdata : ramdatao_s;
//assign sfridx = isfrwait ? esfrm_idx : isfr_idx;

  //------------------------------------------------------------------
  // External Special function register interface; Data bus output
  // sfrdatao_drv :
  //------------------------------------------------------------------
  assign sfrdata_cpu = sfrdata;
  assign esfrm_rddata = sfrdata;

  //------------------------------------------------------------------
  // External Special function register interface; Address bus output
  // sfraddr_drv :
  //------------------------------------------------------------------
  assign sfraddr = isfrwait ? esfrm_addr : ramsfraddr[6:0];

  //------------------------------------------------------------------
  // External Special function register interface; Write enable output
  // sfrwe_drv :
  //------------------------------------------------------------------
  assign sfrwe = sfrwe_ext_per;

  //------------------------------------------------------------------
  // External Special function register interface; Output enable output
  // sfroe_drv :
  //------------------------------------------------------------------
  assign sfroe = sfroe_ext_per;


   //------------------------------------------------------------------
   // SFR acknowledge
   //------------------------------------------------------------------
   assign sfrack_int =
   ((sfrack) // | ext_sfr_sel)
   ) ;

   //------------------------------------------------------------------
   // Internal signal Internal Special function register interface
   // Write enable output
   //------------------------------------------------------------------
   assign sfroe_mcu51_per =
   (sfroe_s | esfrm_oe
   ) ;

   //------------------------------------------------------------------
   // Internal signal for External Special function register
   // Write enable output
   //------------------------------------------------------------------
   assign sfroe_ext_per =
   (sfroe_s & ~reset | esfrm_oe
   ) ;



   //------------------------------------------------------------------
   // Internal signal for Internal Special function register
   // Write enable output
   //------------------------------------------------------------------
   assign sfrwe_mcu51_per =
   (sfrwe_s & ~isfrwait | esfrm_we
   ) ;

   //------------------------------------------------------------------
   // Internal signal for External Special function register
   // Write enable output
   //------------------------------------------------------------------
   assign sfrwe_ext_per =
   (sfrwe_s & ~isfrwait & ~reset | esfrm_we
   ) ;


   //------------------------------------------------------------------
   // Start of new CPU instruction
   //------------------------------------------------------------------
   assign newinstr =
   (newinstr_cpu
   ) ;


   assign intvect_int =
   intvect
   ;

   //------------------------------------------------------------------
   //
   //------------------------------------------------------------------
   assign intcall_int =
   (intcall
    ) ;

   //------------------------------------------------------------------
   //
   //------------------------------------------------------------------
   assign retiinstr_int =
   (retiinstr
   ) ;


  //------------------------------------------------------------------
  // CPU instance
  //------------------------------------------------------------------
  mcu51_cpu u_cpu (
    .clkcpu           (clkcpu),
    .rst              (rstff),
    .mempsack         (mempsack),
    .memack           (memack_s),
    .memdatai         (cpumemdatai),
    .memaddr          (memaddr16),
    .mempsrd          (mempsrd_s),
    .mempswr          (mempswr_s),
    .memrd            (memrd_s),
    .memwr            (memwr_s),
    .memaddr_comb     (memaddr16_comb),
    .mempsrd_comb     (mempsrd_comb_s),
    .mempswr_comb     (mempswr_comb_s),
    .memrd_comb       (memrd_comb_s),
    .memwr_comb       (memwr_comb_s),
    .cpu_hold         (r_hold_mcu),
    .cpu_resume       (cpu_resume),
    .irq              (irq),
    .intvect          (intvect_int),
    .intcall          (intcall),
    .retiinstr        (retiinstr),
    .newinstr         (newinstr_cpu),
    .rmwinstr         (rmwinstr),
    .waitstaten       (waitstaten_s),
    .ramdatai         (ramdatai),
    .sfrdatai         (sfrdata_cpu),
    .ramsfraddr       (ramsfraddr),
    .ramdatao         (ramdatao_s),
    .ramoe            (ramoe_s),
    .ramwe            (ramwe_s),
    .sfroe            (sfroe_s),
    .sfrwe            (sfrwe_s),
    .sfroe_r          (sfroe_r),
    .sfrwe_r          (sfrwe_r),

    .sfroe_comb_s     (sfroe_comb_s),
    .sfrwe_comb_s     (sfrwe_comb_s),
    .pc_o             (pc_o),
    .pc_ini           (pc_ini),
    .cs_run           (cs_run),
    .instr            (instr),
    .codefetch_s      (codefetch),

    .sfrack           (sfrack_int),
    .ramsfraddr_comb  (ramsfraddr_comb),
    .ramdatao_comb    (ramdatao_comb),
    .ramoe_comb       (ramoe_comb),
    .ramwe_comb       (ramwe_comb),
    .ckcon            (ckcon),
    .pmw              (pmw),
    .p2sel            (p2sel),
    .gf0              (gf0),
    .stop             (stop),
    .idle             (idle),
    .dph              (dph),
    .dpl              (dpl),
    .dps              (dps),
    .p2               (p2),
    .dpc              (dpc),
    .sp               (sp),
    .acc              (acc_s),
    .b                (b),
    .rs               (rs),
    .c                (c),
    .ac               (ac),
    .ov               (ov),
    .f0               (f0),
    .f1               (f1),
    .p                (p)
    );



  //------------------------------------------------------------------
  // Reset Synchronization Flip-flops instance
  //------------------------------------------------------------------
  syncneg u_syncneg (
  //------------------------------------------------------------------
    .clk              (clkper),
    .reset            (reset),
    .rsttowdt         (rsttowdt),
    .rsttosrst        (rsttosrst),
    .rst              (rst),
    .int0             (exint[0]),
    .int1             (exint[1]),
    .port0i           (port0i),
    .rxd0i            (rxd0i),
    .sdai             (sdai),
    .int0ff           (int0ff),
    .int1ff           (int1ff),
    .port0ff          (port0ff),
    .t0ff             (t0ff),
    .t1ff             (t1ff),
    .rxd0ff           (rxd0ff),
    .sdaiff           (sdaiff),
    .rsttowdtff       (rsttowdtff),
    .rsttosrstff      (rsttosrstff),
    .rstff            (rstff),
    .resetff          (resetff)
    );

  //------------------------------------------------------------------
  // SFR Read Multiplexer
  //------------------------------------------------------------------
  sfrmux u_sfrmux (
    .isfrwait         (isfrwait),
    .sfraddr          (isfraddr),
    .c                (c),
    .ac               (ac),
    .f0               (f0),
    .rs               (rs),
    .ov               (ov),
    .f1               (f1),
    .p                (p),
    .acc              (acc_s),
    .b                (b),
    .dpl              (dpl),
    .dph              (dph),
    .dps              (dps),
    .dpc              (dpc),
    .p2               (p2),
    .sp               (sp),
    .smod             (smod),
    .pmw              (pmw),
    .p2sel            (p2sel),
    .gf0              (gf0),
    .stop             (stop_flag),
    .idle             (idle_flag),
    .ckcon            (ckcon),
    .port0            (port0),
    .port0ff          (port0ff),
    .rmwinstr         (rmwinstr),
    .arcon            (arcon),
    .md0              (md0),
    .md1              (md1),
    .md2              (md2),
    .md3              (md3),
    .md4              (md4),
    .md5              (md5),
    .t0_tmod          (t0_tmod),
    .t0_tf0           (t0_tf0),
    .t0_tf1           (t0_tf1),
    .t0_tr0           (t0_tr0),
    .t0_tr1           (t0_tr1),
    .tl0              (tl0),
    .th0              (th0),
    .t1_tmod          (t1_tmod),
    .t1_tf1           (t1_tf1),
    .t1_tr1           (t1_tr1),
    .tl1              (tl1),
    .th1              (th1),
    .wdtrel           (wdtrel),
    .ip0wdts          (ip0wdts),
    .wdt_tm           (wdt_tm),
    .t2con            (t2con),
    .s0con            (s0con),
    .s0buf            (s0buf),
    .s0rell           (s0rell),
    .s0relh           (s0relh),
    .bd               (bd),
    .ie0              (ie0),
    .it0              (it0),
    .ie1              (ie1),
    .it1              (it1),
    .iex2             (iex2),
    .iex3             (iex3),
    .iex4             (iex4),
    .iex5             (iex5),
    .iex6             (iex6),
    .iex7             (iex7),
    .iex8             (iex8),
    .iex9             (iex9),
    .iex10            (iex10),
    .iex11            (iex11),
    .iex12            (iex12),
    .ien0             (ien0),
    .ien1             (ien1),
    .ien2             (ien2),
    .ip0              (ip0),
    .ip1              (ip1),
    .isr_tm           (isr_tm),
    // I2C inputs
    .i2c_int          (i2c_int),
    .i2cdat_o         (i2cdat_o),
    .i2cadr_o         (i2cadr_o),
    .i2ccon_o         (i2ccon_o),
    .i2csta_o         (i2csta_o),
    .sfrdatai         (sfrdatai),
    .tf1_gate         (tf1_gate),
    .riti0_gate       (riti0_gate),
    .iex7_gate        (iex7_gate),
    .iex2_gate        (iex2_gate),
    .srstflag         (srstflag),

    .int_vect_8b      (int_vect_8b),
    .int_vect_93      (int_vect_93),
    .int_vect_9b      (int_vect_9b),
    .int_vect_a3      (int_vect_a3),
    .ext_sfr_sel      (ext_sfr_sel),
    .sfrdatao         (sfrdata)
    );

  //-----------------------------------------------------------------
  // Power Management and Reset Control Unit
  //-----------------------------------------------------------------

      pmurstctrl u_pmurstctrl (
          .resetff    (resetff),
          .wdts       (wdts),
          .srst       (srst),
          .pmuintreq  (pmuintreq_rev),
          .stop       (stop),
          .idle       (idle),
          .clkcpu_en  (clkcpuen),
          .clkper_en  (clkperen),
          .cpu_resume (cpu_resume),
          .rsttowdt   (rsttowdt),
          .rsttosrst  (rsttosrst),
          .rst        (rst)
          );

  //---------------------------------------------------------------
  // Exit from Power-down Mode request
  //---------------------------------------------------------------
    //---------------------------------------------------------------
      wakeupctrl u_wakeupctrl (
    //---------------------------------------------------------------
      .irq            (irq),
      .int0ff         (exint[0]),
      .int1ff         (exint[1]),
      .it0            (it0),
      .it1            (it1),
      .isreg          (isreg),
      .intprior0      (intprior0),
      .intprior1      (intprior1),
      .eal            (eal),
      .eint0          (eint0),
      .eint1          (eint1),
      .pmuintreq      (pmuintreq)
      );


      assign pmuintreq_rev = pmuintreq | slp2wakeup;
      assign intprior0 = {ip0[2],ip0[0]};
      assign intprior1 = {ip1[2],ip1[0]};


  //---------------------------------------------------------------
  // Multiplication Division Unit
  //---------------------------------------------------------------
`ifdef MCU51MDU
      mdu u_mdu (
        .clkper        (clkmdu),
        .rst           (rstff),
        .mdubsy        (mdubsy),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per),
        .sfroe         (sfroe_mcu51_per),
        .arcon         (arcon),
        .md0           (md0),
        .md1           (md1),
        .md2           (md2),
        .md3           (md3),
        .md4           (md4),
        .md5           (md5)
        );
`else
      assign mdubsy = 'h0;
      assign arcon = 8'hff;
      assign md0 = 8'hff;
      assign md1 = 8'hff;
      assign md2 = 8'hff;
      assign md3 = 8'hff;
      assign md4 = 8'hff;
      assign md5 = 8'hff;
`endif // MCU51MDU
  //---------------------------------------------------------------
  // Port 0..3 output registers
  //---------------------------------------------------------------
    //---------------------------------------------------------------
      ports u_ports (
        .clkper        (clkper),
        .rst           (rstff),
        .port0         (port0),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per)
      );

      assign port0o = port0;




  //---------------------------------------------------------------
  // Serial Interface Unit 0
  //---------------------------------------------------------------
      serial0 u_serial0 (
	.t_shift_clk   (t_shift_clk),
	.r_shift_clk   (r_shift_clk),
        .clkper        (clkur0),
        .rst           (rstff),
        .newinstr      (newinstr),
        .rxd0ff        (rxd0ff),
        .t1ov          (t1ov),
        .rxd0o         (rxd0o),
	.rxd0oe        (rxd0oe),
        .txd0          (txd0),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per),
        .s0con         (s0con),
        .s0buf         (s0buf),
        .s0rell        (s0rell),
        .s0relh        (s0relh),
        .smod          (smod),
        .bd            (bd)
        );


  //---------------------------------------------------------------
  // Timer/Counter 0
  //---------------------------------------------------------------
      timer0 u_timer0 (
       .clkper         (clktm0),
       .rst            (rstff),
       .newinstr       (newinstr),
       .t0ff           (t0ff),
       .t0ack          (t0ack),
       .t1ack          (t1ack),
       .int0ff         (int0ff),
       .t0_tf0         (t0_tf0),
       .t0_tf1         (t0_tf1),
       .sfrdatai       (isfrdatai),
       .sfraddr        (isfraddr),
       .sfrwe          (sfrwe_mcu51_per),
       .t0_tmod        (t0_tmod),
       .t0_tr0         (t0_tr0),
       .t0_tr1         (t0_tr1),
       .tl0            (tl0),
       .th0            (th0)
       );

  //---------------------------------------------------------------
  // Timer/Counter 1
  //---------------------------------------------------------------
      timer1 u_timer1 (
        .clkper        (clktm1),
        .rst           (rstff),
        .newinstr      (newinstr),
        .t1ff          (t1ff),
        .t1ack         (t1ack),
        .int1ff        (int1ff),
        .t1_tf1        (t1_tf1),
        .t1ov          (t1ov),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per),
        .t1_tmod       (t1_tmod),
        .t1_tr1        (t1_tr1),
        .tl1           (tl1),
        .th1           (th1)
        );


  assign t2con = {1'b0, i3fr, i2fr, 5'b00000};



  //---------------------------------------------------------------
  // Programmable Watchdog Timer
  //---------------------------------------------------------------
      watchdog u_watchdog (
        .wdt_slow      (wdt_slow),
        .clkwdt        (clkwdt),
        .clkper        (clkper),
        .resetff       (rsttowdtff),
        .newinstr      (newinstr),
        .wdts_s        (wdtov),
        .wdts          (wdts),
        .ip0wdts       (ip0wdts),
        .wdt_tm        (wdt_tm),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per),
        .wdtrel        (wdtrel)
        );

  //---------------------------------------------------------------
  // Interrupt Service Routine Unit
  //---------------------------------------------------------------
      isr u_isr (
        .clkper        (clkper),
        .rst           (rstff),
        .intcall       (intcall_int),
        .retiinstr     (retiinstr_int),
        .int_vect_03   (ie0),
        .int_vect_0b   (t0_tf0),
        .t0ff          (t0ff),
        .int_vect_13   (ie1),
        .int_vect_1b   (tf1_gate),
        .t1ff          (t1ff),
        .int_vect_23   (riti0_gate),
        .i2c_int       (i2c_int),
        .rxd0ff        (rxd0ff),
        .int_vect_43   (iex7_gate),
        .int_vect_4b   (iex2_gate),
        .int_vect_53   (iex3),
        .int_vect_5b   (iex4),
        .int_vect_63   (iex5),
        .int_vect_6b   (iex6),
        .int_vect_8b   (int_vect_8b),
        .int_vect_93   (int_vect_93),
        .int_vect_9b   (int_vect_9b),
        .int_vect_a3   (int_vect_a3),
        .int_vect_ab   (iex12),
        // Interrupt request to CPU signal
        .irq           (isr_irq),
        // Interrupt vector signal
        .intvect       (intvect),
        // Interrupt acknowledge signals
        .int_ack_03    (int0ack),
        .int_ack_0b    (t0ack),
        .int_ack_13    (int1ack),
        .int_ack_1b    (t1ack),
        .int_ack_43    (iex7ack),
        .int_ack_4b    (iex2ack),
        .int_ack_53    (iex3ack),
        .int_ack_5b    (iex4ack),
        .int_ack_63    (iex5ack),
        .int_ack_6b    (iex6ack),
        .int_ack_8b    (iex8ack),
        .int_ack_93    (iex9ack),
        .int_ack_9b    (iex10ack),
        .int_ack_a3    (iex11ack),
        .int_ack_ab    (iex12ack),
        .sdaiff        (sdaiff),
        // In service register
        .is_reg        (isreg),
        // interrupt priority SFR registers output
        .ip0           (ip0),
        .ip1           (ip1),

        // interrupt enable SFR registers output
        .ien0          (ien0),
        .ien1          (ien1),
        .ien2          (ien2),
        .isr_tm        (isr_tm),
        // Special function register interface
        .sfraddr       (isfraddr),
        .sfrdatai      (isfrdatai),
        .sfrwe         (sfrwe_mcu51_per)
        );

      assign eal   = ien0[7];
      assign eint0 = ien0[0];
      assign eint1 = ien0[2];
      assign t0_intr = t0_tf0 & eint0;
      assign irq = isr_irq & ~r_hold_mcu;


  //---------------------------------------------------------------
  // External Interrupt 0-12 service unit
  //---------------------------------------------------------------
      extint u_extint (
        .clkper        (clkper),
        .rst           (rstff),
        .newinstr      (newinstr),
        .int0ff        (int0ff),
        .int0ack       (int0ack),
        .int1ff        (int1ff),
        .int1ack       (int1ack),
        .int2ff        (int2ff),
        .iex2ack       (iex2ack),
        .int3ff        (int3ff),
        .iex3ack       (iex3ack),
        .int4ff        (int4ff),
        .iex4ack       (iex4ack),
        .int5ff        (int5ff),
        .iex5ack       (iex5ack),
        .int6ff        (int6ff),
        .iex6ack       (iex6ack),
        .int7ff        (int7ff),
        .iex7ack       (iex7ack),
        .int8ff        (int8ff),
        .iex8ack       (iex8ack),
        .int9ff        (int9ff),
        .iex9ack       (iex9ack),
////    .int10ff       (int10ff),
////    .iex10ack      (iex10ack),
////    .int11ff       (int11ff),
////    .iex11ack      (iex11ack),
////    .int12ff       (int12ff),
////    .iex12ack      (iex12ack),
        .ie0           (ie0),
        .it0           (it0),
        .ie1           (ie1),
        .it1           (it1),
        .i2fr          (i2fr),
        .iex2          (iex2),
        .i3fr          (i3fr),
        .iex3          (iex3),
        .iex4          (iex4),
        .iex5          (iex5),
        .iex6          (iex6),
        .iex7          (iex7),
        .iex8          (iex8),
        .iex9          (iex9),
        .iex10         (iex10),
        .iex11         (iex11),
        .iex12         (iex12),
        // Special function register interface
        .sfraddr       (isfraddr),
        .sfrdatai      (isfrdatai),
        .sfrwe         (sfrwe_mcu51_per)
        );

  assign waitstaten  = waitstaten_s;

  //---------------------------------------------------------------
  // I2C Serial Channel
  //---------------------------------------------------------------
      i2c u_i2c (
        .clk           (clki2c),
        .rst           (rstff),
////    .bclk          (t1ov),
//      .bclk          (bclki2c),
        .bclksel       (bclki2c),
        .scli          (scli),
        .sdai          (sdai),
        .sclo          (sclo),
        .sdao          (sdao),
        .intack        (i2c_autoack),
        .si            (i2c_int),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per),
////    .sfrwe         (sfrwe4I2C),
        .i2cdat_o      (i2cdat_o),
        .i2cadr_o      (i2cadr_o),
        .i2ccon_o      (i2ccon_o),
        .i2csta_o      (i2csta_o)
        );
  //-----------------------------------------------------------------
  // Interrupt acknowdedge from DMA to I2C
  //-----------------------------------------------------------------



  //-----------------------------------------------------------------
  // Data bus to CPU
  //-----------------------------------------------------------------
      assign cpumemdatai = memdatai_s; // from MEMMUX




  //---------------------------------------------------------------
  // Multiplication Division Unit
  //---------------------------------------------------------------
      softrstctrl u_softrstctrl (
        .clkcpu        (clkcpu),
        .resetff       (rsttosrstff),
        .newinstr      (newinstr),
        .srstreq       (srst),
        .srstflag      (srstflag),
        .sfrdatai      (isfrdatai),
        .sfraddr       (isfraddr),
        .sfrwe         (sfrwe_mcu51_per)
        );

    //----------------------------------------------------------
    // Memory DATAI driver
    //----------------------------------------------------------
       assign memdatai_s = memdatai;
    //----------------------------------------------------------
    // Memory MEMACK driver
    //----------------------------------------------------------
       assign memack_s = memack;

       assign i2c_con_ens1 = i2ccon_o[6];

endmodule // mcu51

`undef MCU51MDU

