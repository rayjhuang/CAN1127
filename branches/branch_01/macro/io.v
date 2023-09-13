

`timescale 1ns/1ps



`celldefine
module BCTB2N3S_UUD( PAD, Y, C, A, PU, PD );
input C, A, PU, PD;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTB2N3S_func BCTB2N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTB2N3S_func BCTB2N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end

   pulldown(weak0)(pd0); tranif1(PAD,pd0,PD);
   pullup  (weak1)(pu0); tranif1(PAD,pu0,PU);


   specify

	// specify_block_begin 

	// comb arc A --> PAD
//	 (A => PAD) = (1.0,1.0); // ncelab: *F,INTERR: INTERNAL EXCEPTION

	// comb arc C --> PAD
//	 (C => PAD) = (1.0,1.0); // possiblly caused by multiple driver on PAD

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine

`celldefine
module BCTB2N3S_UUDA( PAD, Y, C, A, PU, PD, ANA );
input C, A, PU, PD;
output Y;
inout PAD,ANA;

   `ifdef FUNCTIONAL  //  functional //

        BCTB2N3S_func BCTB2N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

        BCTB2N3S_func BCTB2N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

        // spec_gates_begin


        // spec_gates_end

   tran (PAD,ANA);
   pulldown(weak0)(pd0); tranif1(PAD,pd0,PD);
   pullup  (weak1)(pu0); tranif1(PAD,pu0,PU);


   specify

        // specify_block_begin

        // comb arc A --> PAD
//       (A => PAD) = (1.0,1.0); // ncelab: *F,INTERR: INTERNAL EXCEPTION

        // comb arc C --> PAD
//       (C => PAD) = (1.0,1.0); // possiblly caused by multiple driver on PAD

        // comb arc PAD --> Y
         (PAD => Y) = (1.0,1.0);

        // specify_block_end

   endspecify

   `endif

endmodule
`endcelldefine

`celldefine
module IODMURUDA_A0( PAD, IE, DI, OE, DO, PU, PD, ANA_R, RSTB_5, VB );
input IE, OE, DO, PU, PD, RSTB_5, VB;
output DI, ANA_R;
inout PAD;

	and (odoe, OE, ~DO); // open-drain
    `ifdef FUNCTIONAL  //  functional //
        IOBPURUDA_A0_func IOBPURUDA_A0_behav_inst(.PAD(PAD),.DI(DI),.IE(IE),.OE(odoe),.DO(DO));
    `else
        IOBPURUDA_A0_func IOBPURUDA_A0_inst(.PAD(PAD),.DI(DI),.IE(IE),.OE(odoe),.DO(DO));
        pulldown(weak0)(pd0); tranif1(PAD,pd0,PD);
        pullup  (weak1)(pu0); tranif1(PAD,pu0,PU);
        specify
          (PAD => DI) = (1.0,1.0);
        endspecify
    `endif

endmodule
`endcelldefine

`celldefine
module IOBMURUDA_A0( PAD, IE, DI, OE, DO, PU, PD, ANA_R, RSTB_5, VB );
input IE, OE, DO, PU, PD, RSTB_5, VB;
output DI, ANA_R;
inout PAD;

    `ifdef FUNCTIONAL  //  functional //
        IOBPURUDA_A0_func IOBPURUDA_A0_behav_inst(.PAD(PAD),.DI(DI),.IE(IE),.OE(OE),.DO(DO));
    `else
        IOBPURUDA_A0_func IOBPURUDA_A0_inst(.PAD(PAD),.DI(DI),.IE(IE),.OE(OE),.DO(DO));
        pulldown(weak0)(pd0); tranif1(PAD,pd0,PD);
        pullup  (weak1)(pu0); tranif1(PAD,pu0,PU);
        specify
          (PAD => DI) = (1.0,1.0);
        endspecify
    `endif

endmodule
`endcelldefine

`celldefine
module IOBMURUDA_A1( PAD, ANA_P, IE, DI, OE, DO, PU, PD, ANA_R, RSTB_5, VB );
input IE, OE, DO, PU, PD, RSTB_5, VB, ANA_P;
output DI, ANA_R;
inout PAD;

    `ifdef FUNCTIONAL  //  functional //
        IOBPURUDA_A1_func IOBPURUDA_A1_behav_inst(.PAD(PAD),.DI(DI),.IE(IE),.OE(OE),.DO(DO));
    `else
        IOBPURUDA_A1_func IOBPURUDA_A1_inst(.PAD(PAD),.DI(DI),.IE(IE),.OE(OE),.DO(DO));
        tran (ANA_P,PAD);
        pulldown(weak0)(pd0); tranif1(PAD,pd0,PD);
        pullup  (weak1)(pu0); tranif1(PAD,pu0,PU);
        specify
          (PAD => DI) = (1.0,1.0);
        endspecify
    `endif

endmodule
`endcelldefine



`celldefine
module BCTB2N3S_UUDAW( PAD, Y, C, A, PU, PD, ANA );
input C, A, PU, PD;
output Y;
inout PAD,ANA;

   `ifdef FUNCTIONAL  //  functional //

        BCTB2N3S_func BCTB2N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

        BCTB2N3S_func BCTB2N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

        // spec_gates_begin


        // spec_gates_end

   tran (PAD,ANA);
   pulldown(weak0)(pd0); tranif1(PAD,pd0,PD);
   pullup  (weak1)(pu0); tranif1(PAD,pu0,PU);


   specify

        // specify_block_begin

        // comb arc A --> PAD
//       (A => PAD) = (1.0,1.0); // ncelab: *F,INTERR: INTERNAL EXCEPTION

        // comb arc C --> PAD
//       (C => PAD) = (1.0,1.0); // possiblly caused by multiple driver on PAD

        // comb arc PAD --> Y
         (PAD => Y) = (1.0,1.0);

        // specify_block_end

   endspecify

   `endif

endmodule
`endcelldefine

`celldefine
module BCTB4N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTB4N3S_func BCTB4N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTB4N3S_func BCTB4N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTB8SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTB8SA3S_func BCTB8SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTB8SA3S_func BCTB8SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBD512SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBD512SA3S_func BCTBD512SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBD512SA3S_func BCTBD512SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBD51N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBD51N3S_func BCTBD51N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBD51N3S_func BCTBD51N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBD52N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBD52N3S_func BCTBD52N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBD52N3S_func BCTBD52N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBD54N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBD54N3S_func BCTBD54N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBD54N3S_func BCTBD54N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBD58SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBD58SA3S_func BCTBD58SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBD58SA3S_func BCTBD58SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBU512SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBU512SA3S_func BCTBU512SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBU512SA3S_func BCTBU512SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBU51N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBU51N3S_func BCTBU51N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBU51N3S_func BCTBU51N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBU52N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBU52N3S_func BCTBU52N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBU52N3S_func BCTBU52N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBU54N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBU54N3S_func BCTBU54N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBU54N3S_func BCTBU54N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTBU58SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTBU58SA3S_func BCTBU58SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTBU58SA3S_func BCTBU58SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTN12SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTN12SA3S_func BCTN12SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTN12SA3S_func BCTN12SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTN1N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTN1N3S_func BCTN1N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTN1N3S_func BCTN1N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTN2N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTN2N3S_func BCTN2N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTN2N3S_func BCTN2N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTN4N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTN4N3S_func BCTN4N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTN4N3S_func BCTN4N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTN8SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTN8SA3S_func BCTN8SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTN8SA3S_func BCTN8SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTND512SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTND512SA3S_func BCTND512SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTND512SA3S_func BCTND512SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTND51N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTND51N3S_func BCTND51N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTND51N3S_func BCTND51N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTND52N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTND52N3S_func BCTND52N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTND52N3S_func BCTND52N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTND54N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTND54N3S_func BCTND54N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTND54N3S_func BCTND54N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTND58SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTND58SA3S_func BCTND58SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTND58SA3S_func BCTND58SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTNU512SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTNU512SA3S_func BCTNU512SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTNU512SA3S_func BCTNU512SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTNU51N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTNU51N3S_func BCTNU51N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTNU51N3S_func BCTNU51N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTNU52N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTNU52N3S_func BCTNU52N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTNU52N3S_func BCTNU52N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTNU54N3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTNU54N3S_func BCTNU54N3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTNU54N3S_func BCTNU54N3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module BCTNU58SA3S( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

   `ifdef FUNCTIONAL  //  functional //

	BCTNU58SA3S_func BCTNU58SA3S_behav_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

   `else

	BCTNU58SA3S_func BCTNU58SA3S_inst(.PAD(PAD),.Y(Y),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module ICB3S( Y, PAD );
input PAD;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	ICB3S_func ICB3S_behav_inst(.Y(Y),.PAD(PAD));

   `else

	ICB3S_func ICB3S_inst(.Y(Y),.PAD(PAD));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module ICBD53S_U( Y, PAD );
input PAD;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	ICBD53S_func ICBD53S_behav_inst(.Y(Y),.PAD(PAD));

   `else

	ICBD53S_func ICBD53S_inst(.Y(Y),.PAD(PAD));

	// spec_gates_begin


	// spec_gates_end

   pulldown (weak0) (PAD);


   specify

	// specify_block_begin 

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module ICBU53S( Y, PAD );
input PAD;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	ICBU53S_func ICBU53S_behav_inst(.Y(Y),.PAD(PAD));

   `else

	ICBU53S_func ICBU53S_inst(.Y(Y),.PAD(PAD));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module ICN3S( Y, PAD );
input PAD;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	ICN3S_func ICN3S_behav_inst(.Y(Y),.PAD(PAD));

   `else

	ICN3S_func ICN3S_inst(.Y(Y),.PAD(PAD));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module ICND53S( Y, PAD );
input PAD;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	ICND53S_func ICND53S_behav_inst(.Y(Y),.PAD(PAD));

   `else

	ICND53S_func ICND53S_inst(.Y(Y),.PAD(PAD));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module ICNU53S( Y, PAD );
input PAD;
output Y;

   `ifdef FUNCTIONAL  //  functional //

	ICNU53S_func ICNU53S_behav_inst(.Y(Y),.PAD(PAD));

   `else

	ICNU53S_func ICNU53S_inst(.Y(Y),.PAD(PAD));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc PAD --> Y
	 (PAD => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCN12SA3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCN12SA3S_func OCN12SA3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCN12SA3S_func OCN12SA3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCN1N3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCN1N3S_func OCN1N3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCN1N3S_func OCN1N3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCN2N3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCN2N3S_func OCN2N3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCN2N3S_func OCN2N3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCN4N3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCN4N3S_func OCN4N3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCN4N3S_func OCN4N3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCN8SA3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCN8SA3S_func OCN8SA3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCN8SA3S_func OCN8SA3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCND12SA3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCND12SA3S_func OCND12SA3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCND12SA3S_func OCND12SA3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCND1N3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCND1N3S_func OCND1N3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCND1N3S_func OCND1N3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCND2N3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCND2N3S_func OCND2N3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCND2N3S_func OCND2N3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCND4N3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCND4N3S_func OCND4N3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCND4N3S_func OCND4N3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCND8SA3S( PAD, A );
input A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCND8SA3S_func OCND8SA3S_behav_inst(.PAD(PAD),.A(A));

   `else

	OCND8SA3S_func OCND8SA3S_inst(.PAD(PAD),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCT12SA3S( PAD, C, A );
input C, A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCT12SA3S_func OCT12SA3S_behav_inst(.PAD(PAD),.C(C),.A(A));

   `else

	OCT12SA3S_func OCT12SA3S_inst(.PAD(PAD),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCT1N3S( PAD, C, A );
input C, A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCT1N3S_func OCT1N3S_behav_inst(.PAD(PAD),.C(C),.A(A));

   `else

	OCT1N3S_func OCT1N3S_inst(.PAD(PAD),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCT2N3S( PAD, C, A );
input C, A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCT2N3S_func OCT2N3S_behav_inst(.PAD(PAD),.C(C),.A(A));

   `else

	OCT2N3S_func OCT2N3S_inst(.PAD(PAD),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCT4N3S( PAD, C, A );
input C, A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCT4N3S_func OCT4N3S_behav_inst(.PAD(PAD),.C(C),.A(A));

   `else

	OCT4N3S_func OCT4N3S_inst(.PAD(PAD),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OCT8SA3S( PAD, C, A );
input C, A;
output PAD;

   `ifdef FUNCTIONAL  //  functional //

	OCT8SA3S_func OCT8SA3S_behav_inst(.PAD(PAD),.C(C),.A(A));

   `else

	OCT8SA3S_func OCT8SA3S_inst(.PAD(PAD),.C(C),.A(A));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc A --> PAD
	 (A => PAD) = (1.0,1.0);

	// comb arc C --> PAD
	 (C => PAD) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine


`celldefine
module OSCL40C3S( PADO, Y, PADI );
input PADI;
output PADO, Y;

   `ifdef FUNCTIONAL  //  functional //

	OSCL40C3S_func OSCL40C3S_behav_inst(.PADO(PADO),.Y(Y),.PADI(PADI));

   `else

	OSCL40C3S_func OSCL40C3S_inst(.PADO(PADO),.Y(Y),.PADI(PADI));

	// spec_gates_begin


	// spec_gates_end



   specify

	// specify_block_begin 

	// comb arc PADI --> PADO
	 (PADI => PADO) = (1.0,1.0);

	// comb arc PADI --> Y
	 (PADI => Y) = (1.0,1.0);

	// specify_block_end 

   endspecify

   `endif 

endmodule
`endcelldefine
