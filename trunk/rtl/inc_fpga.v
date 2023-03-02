
// -----------------------------------------------------------------------------
// this file in used (by `include) in FPGA simulation and synthesis
// Note :
// both DUT and FPGA stand for the chiptop
// FPGA/AFE interface is the interface betweem FPGA and AFE
// DIGITAL/ANA interface is the interface betweem DIGITAL and analog_top
// -----------------------------------------------------------------------------

// FPGA/AFE interface, not in DIGITAL/ANA interface (mismatch implemented)
// TODO :
// FPGA simulation/synthesis :
//     -> : give default constant/derived values
   assign rp_type_en = {RP_SEL==2'h2,RP_SEL==2'h1,RP_SEL==2'h0};

   assign oeb_cc = TX_EN ?'h0 :'hz;
   assign doe_cc = TX_EN ? TX_DAT :'hz; // for the RV-divider on AFE

   assign dac_pwr_v = DAC0[9:2];
   assign dac1_9_2 = DAC1[9:2];

   assign RX_D_49 = RX_D;
   assign RX_D_PK = RX_D;

// DIGITAL/ANA interface, not in FPGA_DUT/AFE interface
// TODO :
//     ANA -> DIGITAL : only for FPGA synthesis
//                      (assigned by test bench in simulation)
`ifdef FPGA_SYNTHESIS
   assign DN_FAULT = 0;
   assign RX_SQL = 0;

   assign DP = DPDEN ?DPDO :1'hz;
   assign DN = DNDEN ?DNDO :1'hz;
   assign DP_COMP = DP; // digital input
   assign DN_COMP = DN; // digital input

   assign CC1 = CCI2C_EN & CC1_DOB ? 1'h0 : 1'hz;
   assign CC2 = CCI2C_EN & CC2_DOB ? 1'h0 : 1'hz;
   assign CC1_DI = CCI2C_EN & CC1; // digital inputs/open-drain outputs
   assign CC2_DI = CCI2C_EN & CC2; // ANA does the CCI2C_EN gating
`else
// signals shall be assign in test bench
`endif

// DIGITAL IO
   assign DI_GPIO = {GPIO5,GPIO4,GPIO3,GPIO2,GPIO1,SDA&sda,SCL&scl};
   assign scl   = OE_GPIO[0] ?DO_GPIO[0] :1'hz;
   assign sda   = OE_GPIO[1] ?DO_GPIO[1] :1'hz;
   assign SCL   = OE_GPIO[0] ?DO_GPIO[0] :1'hz;
   assign SDA   = OE_GPIO[1] ?DO_GPIO[1] :1'hz;
   assign GPIO1 = OE_GPIO[2] ?DO_GPIO[2] :1'hz;
   assign GPIO2 = OE_GPIO[3] ?DO_GPIO[3] :1'hz;
   assign GPIO3 = OE_GPIO[4] ?DO_GPIO[4] :1'hz;
   assign GPIO4 = OE_GPIO[5] ?DO_GPIO[5] :1'hz;
   assign GPIO5 = OE_GPIO[6] ?DO_GPIO[6] :1'hz;
   assign GPIO6 = 1'h0;
   assign TS = DO_TS[2] ?DO_TS[3] :1'hz;
   wire DI_TS = TS;
   wire DI_TST = TST;

   wire [7:0] o_leddrv;
   assign smims_ledz = o_leddrv; // LED indicators
   wire [31:0] o_dbgpo;
   assign smims_j8_o = o_dbgpo; // debug port output

   wire [1:0] i_clksel = {~smims_j8_i[0],1'h0}; // 0/1/2/3: i_osc/clk45m/clkgen/clkafe, FPGA pullup
   wire i_pcsel = smims_j8_i[1]; // 0/1: mon51/normal, FPGA pullup
   wire i_osc = smims_osc48;
   wire i_clkgen = smims_clkgen;
   wire i_clkafe =0;
   wire pc_sel;
   wire [15:0] pc_ini = pc_sel ?'h0 :'h8000;

   wire cpurst, mempswr_c, memwr_c;
   wire [15:0] memaddr, memaddr_c;
   wire hi_byte = memaddr[0];
   wire hit_mo   = cpurst ?'h0
                 : {memaddr  [15:13],13'h0}=='h8000; // 8000h~9FFFh
   wire hit_mo_c = {memaddr_c[15:13],13'h0}=='h8000; // 8000h~9FFFh
// wire monm_r = (mempsrd_c|memrd_c) & hit_mo_c &~cpurst;
   wire monm_w = (mempswr_c|memwr_c) & hit_mo_c;
   wire [12:0] memaddr_c_13 = memaddr_c[12:0]; // cast
   wire [7:0] memdatao, memdatao_c;

// assign xdat_o = XDAT_RDAT; // to emulate Artisan's SRAM
// reg [7:0] d_xdat_o; // to emulate Maxchip SRAM data output
// always @(negedge xdat_clk) if (xdat_cen &~xdat_wen) d_xdat_o <= XDAT_RDAT;
   wire [7:0] MONM_RDAT;
   wire #2 MONM_WE = monm_w;
   wire [12:0] #2 MONM_A = memaddr_c_13;
   wire [7:0] #2 MONM_D = memdatao_c;
   wire [7:0] #2 monm_rdat = MONM_RDAT;
`ifdef ALTERA
   alt_pll_50to48 u0_pll (
	.inclk0	(i_osc),
	.c0	(clk48m),
	.c1	(clk45m));
   alt_ram_512x8 U0_XDAT ( // 512x8
	.address(XDAT_A),
	.clock	(mclk),
	.data	(XDAT_D),
	.wren	(~XDAT_WEB), // high-active
	.q	(XDAT_RDAT)); // xdat_o));
   alt_ram_8kx8 u0_mon51_c (	// initialized by elaborating with 'MON51.mif'
	.address(MONM_A),
	.clock	(mclk),
	.data	(MONM_D),
	.wren	(MONM_WE),	// there's no address-combinational output read in Altera Mega-CORE
	.q	(MONM_RDAT));	// the read data is mux-ed from clocked address, so the 'q' should not be clocked again
`endif // ALTERA
`ifdef SMIMS
// [Xst 2035] Port <smims_osc48> has illegal connections. This port is connected to an input buffer and other components.
// clk_wiz_48to45 u0_pll (  // to prevent from [Xst 2035] error,
//	.CLK_IN1(i_osc),    // don't source to a input buffer in IP customizing
//	.CLK_OUT1(clk45m)); // in page 1 of 6, use 'Global buffer' instead
   wire clk45m =0;
   wire clk48m = i_osc;
   dist_mem_1536x8 U0_SRAM ( // 1.5KB
	.a	(SRAM_A),
	.clk	(mclk),
	.d	(SRAM_D),
	.we	(~SRAM_WEB), // high-active
	.qspo	(SRAM_RDAT));
   dist_mem_6kx8 u0_mon51_c (	// initialized by elaborating with 'mon51.coe'
	.a	(MONM_A),
	.clk	(mclk),
	.d	(MONM_D),
	.we	(MONM_WE),	// there's an address-combinational out in Xilinx distributed-RAM
	.qspo	(MONM_RDAT));	// registered output is preferred
`endif // SMIMS
   wire i_clk = i_clksel[1] ?i_clksel[0] ?i_clkafe :i_clkgen
                            :i_clksel[0] ?clk45m :clk48m;

   wire rstz = smims_rstzbtn;
   reg shft01; always @(posedge i_clk  or negedge rstz) if (~rstz) shft01 <='h0; else shft01 <= ~shft01;
   reg shft02; always @(posedge shft01 or negedge rstz) if (~rstz) shft02 <='h0; else shft02 <= ~shft02;
   reg shft03; always @(posedge shft02 or negedge rstz) if (~rstz) shft03 <='h0; else shft03 <= ~shft03;
   reg shft04; always @(posedge shft03 or negedge rstz) if (~rstz) shft04 <='h0; else shft04 <= ~shft04;
   reg shft05; always @(posedge shft04 or negedge rstz) if (~rstz) shft05 <='h0; else shft05 <= ~shft05;
   reg shft06; always @(posedge shft05 or negedge rstz) if (~rstz) shft06 <='h0; else shft06 <= ~shft06;
   reg shft07; always @(posedge shft06 or negedge rstz) if (~rstz) shft07 <='h0; else shft07 <= ~shft07;
   reg shft08; always @(posedge shft07 or negedge rstz) if (~rstz) shft08 <='h0; else shft08 <= ~shft08;
   reg shft09; always @(posedge shft08 or negedge rstz) if (~rstz) shft09 <='h0; else shft09 <= ~shft09;
   reg shft10; always @(posedge shft09 or negedge rstz) if (~rstz) shft10 <='h0; else shft10 <= ~shft10;
   reg shft11; always @(posedge shft10 or negedge rstz) if (~rstz) shft11 <='h0; else shft11 <= ~shft11;
   reg shft12; always @(posedge shft11 or negedge rstz) if (~rstz) shft12 <='h0; else shft12 <= ~shft12;
   reg shft13; always @(posedge shft12 or negedge rstz) if (~rstz) shft13 <='h0; else shft13 <= ~shft13;
   reg shft14; always @(posedge shft13 or negedge rstz) if (~rstz) shft14 <='h0; else shft14 <= ~shft14;
   reg shft15; always @(posedge shft14 or negedge rstz) if (~rstz) shft15 <='h0; else shft15 <= ~shft15;
   reg shft16; always @(posedge shft15 or negedge rstz) if (~rstz) shft16 <='h0; else shft16 <= ~shft16;
   reg shft17; always @(posedge shft16 or negedge rstz) if (~rstz) shft17 <='h0; else shft17 <= ~shft17;
   reg shft18; always @(posedge shft17 or negedge rstz) if (~rstz) shft18 <='h0; else shft18 <= ~shft18;
   reg shft19; always @(posedge shft18 or negedge rstz) if (~rstz) shft19 <='h0; else shft19 <= ~shft19;
   reg shft20; always @(posedge shft19 or negedge rstz) if (~rstz) shft20 <='h0; else shft20 <= ~shft20;
   reg shft21; always @(posedge shft20 or negedge rstz) if (~rstz) shft21 <='h0; else shft21 <= ~shft21;
   reg shft22; always @(posedge shft21 or negedge rstz) if (~rstz) shft22 <='h0; else shft22 <= ~shft22;
   reg shft23; always @(posedge shft22 or negedge rstz) if (~rstz) shft23 <='h0; else shft23 <= ~shft23;
   reg shft24; always @(posedge shft23 or negedge rstz) if (~rstz) shft24 <='h0; else shft24 <= ~shft24;
   reg shft25; always @(posedge shft24 or negedge rstz) if (~rstz) shft25 <='h0; else shft25 <= ~shft25;
   reg shft26; always @(posedge shft25 or negedge rstz) if (~rstz) shft26 <='h0; else shft26 <= ~shft26;

   reg mclk_en;
   assign mclk = shft02; // & mclk_en; // gated-clock in FPGA causes XDAT timing issues?
   always @(negedge shft02 or negedge rstz)
      if (~rstz) mclk_en <= 'h1;
            else mclk_en <= ~OSC_STOP;

   reg r_rstz;
   reg [3:0] d_rstz; // FPGA-only
   always @(negedge shft12 or negedge rstz)
      if (~rstz) {d_rstz,r_rstz} <= 'h0;
            else {d_rstz,r_rstz} <= {d_rstz[2:0],r_rstz,1'h1};
// wire pc_sel = i_pcsel; // VC1/2 reset should not reset MON51
   assign pc_sel = d_rstz[3] ?1'h1 :i_pcsel; // only refer to i_pcsel when reset button
   assign core_rstz = r_rstz & i_porz; // let FPGA clock starts earlier than reset

   wire i_srx = uart_rx;
   wire srx_oe, srx_do;
   assign uart_rx = srx_oe ?srx_do :'hz;

   wire reqclk = shft12;
   dgreg_rf u0_degltch (dummy_o,shft_rise,dummy_f,shft26,mclk,r_rstz);
   synchr_pls u0_synchr_ack (req_ack,reqclk,r_rstz,shft_rise,mclk,r_rstz); // to gen. a fake ack
   synchr_l2h u0_synchr_tri (req_tri,r_rstz,mclk,req_rdy);
   wire req_btn = ~smims_cmdbtn; // low-active button
   wire [7:0] req_bus;
   cmd_req_gen u0_cmdreq (req_rdy,req_vld,req_bus,req_btn,req_ack,reqclk,r_rstz); // 11.7KHz

// assign o_hi = {8{1'h1}};
   assign o_lo = {8{1'h0}};
   wire [7:0] leddrv = req_vld ?req_bus :o_dbgpo[7:0];
   assign o_leddrv =
`ifdef ALTERA
		 leddrv; // to ALTERA FPGA board LED0~7, high-active
`endif
`ifdef SMIMS
		~leddrv; // to SMIMS FPGA board DS0~7, low-active
`endif

   wire [3:0] o_indic;
   wire [3:0] i_indic = {i_srx^uart_tx,SCL^scl,RX_D_PK,req_rdy};
   wire [3:0] beacon = {o_indic[3:1], o_indic[0] ?1'h1 :shft26};
   ev_indic u0_led_indic [3:0] (o_indic,{4{shft19}},{4{mclk}},{4{r_rstz}},4'b0001,i_indic);

   wire [7:0] top_bus = {uart_tx,i_srx,GPIO2,GPIO1,SDA,SCL,rstz,i_porz};
   wire [31:0] core_dbgpo;
   assign o_dbgpo = // to SMIMS FPGA board J8
	 (smims_dipmux==4'hb) ?{16'h55aa,8'h0,4'hb,1'h0,OSC_STOP,RX_D_PK,mclk}
	:(smims_dipmux==4'hc) ?{16'h55aa,top_bus[3:0],~top_bus[7:6],top_bus[5:4],beacon}
	:(smims_dipmux==4'hd) ?{16'h55aa,8'hd,top_bus}
	:(smims_dipmux==4'he) ?{16'h55aa,8'he,dac1_9_2}
	:(smims_dipmux==4'hf) ?{16'h55aa,8'hf,6'h15,cpurst,pc_sel}
	:core_dbgpo;

   assign o_pull = {
	PU_GPIO[6]^PD_GPIO[6] ?PU_GPIO[6] :1'hz,
	PU_GPIO[5]^PD_GPIO[5] ?PU_GPIO[5] :1'hz,
	PU_GPIO[4]^PD_GPIO[4] ?PU_GPIO[4] :1'hz,
	PU_GPIO[3]^PD_GPIO[3] ?PU_GPIO[3] :1'hz,
	PU_GPIO[2]^PD_GPIO[2] ?PU_GPIO[2] :1'hz,
	PU_GPIO[1]^PD_GPIO[1] ?PU_GPIO[1] :1'hz,
	PU_GPIO[0]^PD_GPIO[0] ?PU_GPIO[0] :1'hz};

