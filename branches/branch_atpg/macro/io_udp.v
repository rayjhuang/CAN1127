

`timescale 1ns/1ps

// udp_data_begin


`celldefine
module BCTB12SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTB12SA3S;

	not MGM_BG_0( C_inv_for_BCTB12SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTB12SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTB1N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTB1N3S;

	not MGM_BG_0( C_inv_for_BCTB1N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTB1N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTB2N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTB2N3S;

	not MGM_BG_0( C_inv_for_BCTB2N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTB2N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin

`celldefine
module IOBPURUDA_A0_func( PAD, DI, IE,  OE , DO );
input IE, OE, DO;
output DI;
inout PAD;

        wire MGM_WB_0;

        wire MGM_WB_1;

        wire MGM_WB_2;

        and MGM_BG_1( MGM_WB_0, DO, OE );

        buf MGM_BG_2( MGM_WB_1, OE );

        bufif1 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

        buf MGM_BG_4( MGM_WB_2, IE );

        and MGM_BG_5 (DI, PAD, MGM_WB_2);

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin

`celldefine
module IOBPURUDA_A1_func( PAD, DI, IE,  OE , DO );
input IE, OE, DO;
output DI;
inout PAD;

        wire MGM_WB_0;

        wire MGM_WB_1;

        wire MGM_WB_2;

        and MGM_BG_1( MGM_WB_0, DO, OE );

        buf MGM_BG_2( MGM_WB_1, OE );

        bufif1 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

        buf MGM_BG_4( MGM_WB_2, IE );

        and MGM_BG_5 (DI, PAD, MGM_WB_2);

endmodule
`endcelldefine

`celldefine
module IOB3PURUDA_A0_func( PAD, DI, IE,  OE , DO );
input IE, OE, DO;
output DI;
inout PAD;

        wire MGM_WB_0;

        wire MGM_WB_1;

        wire MGM_WB_2;

        and MGM_BG_1( MGM_WB_0, DO, OE );

        buf MGM_BG_2( MGM_WB_1, OE );

        bufif1 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

        buf MGM_BG_4( MGM_WB_2, IE );

        and MGM_BG_5 (DI, PAD, MGM_WB_2);

endmodule
`endcelldefine

`celldefine
module IOB3PURUDA_A1_func( PAD, DI, IE,  OE , DO );
input IE, OE, DO;
output DI;
inout PAD;

        wire MGM_WB_0;

        wire MGM_WB_1;

        wire MGM_WB_2;

        and MGM_BG_1( MGM_WB_0, DO, OE );

        buf MGM_BG_2( MGM_WB_1, OE );

        bufif1 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

        buf MGM_BG_4( MGM_WB_2, IE );

        and MGM_BG_5 (DI, PAD, MGM_WB_2);

endmodule
`endcelldefine


`celldefine
module IOD3PURUDA_A0_func( PAD, DI, IE,  OE , DO );
input IE, OE, DO;
output DI;
inout PAD;

        wire MGM_WB_0;

        wire MGM_WB_1;

        wire MGM_WB_2;

        and MGM_BG_1( MGM_WB_0, DO, OE );

//        buf MGM_BG_2( MGM_WB_1, OE );

        and MGM_BG_2( MGM_WB_1, ~DO, OE);  //open drain, don't drive high

        bufif1 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

        buf MGM_BG_4( MGM_WB_2, IE );

        and MGM_BG_5 (DI, PAD, MGM_WB_2);

endmodule
`endcelldefine


`celldefine
module BCTB4N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTB4N3S;

	not MGM_BG_0( C_inv_for_BCTB4N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTB4N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTB8SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTB8SA3S;

	not MGM_BG_0( C_inv_for_BCTB8SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTB8SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBD512SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBD512SA3S;

	not MGM_BG_0( C_inv_for_BCTBD512SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBD512SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBD51N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBD51N3S;

	not MGM_BG_0( C_inv_for_BCTBD51N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBD51N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBD52N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBD52N3S;

	not MGM_BG_0( C_inv_for_BCTBD52N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBD52N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBD54N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBD54N3S;

	not MGM_BG_0( C_inv_for_BCTBD54N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBD54N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBD58SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBD58SA3S;

	not MGM_BG_0( C_inv_for_BCTBD58SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBD58SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBU512SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBU512SA3S;

	not MGM_BG_0( C_inv_for_BCTBU512SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBU512SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBU51N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBU51N3S;

	not MGM_BG_0( C_inv_for_BCTBU51N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBU51N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBU52N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBU52N3S;

	not MGM_BG_0( C_inv_for_BCTBU52N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBU52N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBU54N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBU54N3S;

	not MGM_BG_0( C_inv_for_BCTBU54N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBU54N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTBU58SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTBU58SA3S;

	not MGM_BG_0( C_inv_for_BCTBU58SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTBU58SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTN12SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTN12SA3S;

	not MGM_BG_0( C_inv_for_BCTN12SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTN12SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTN1N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTN1N3S;

	not MGM_BG_0( C_inv_for_BCTN1N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTN1N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTN2N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTN2N3S;

	not MGM_BG_0( C_inv_for_BCTN2N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTN2N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTN4N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTN4N3S;

	not MGM_BG_0( C_inv_for_BCTN4N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTN4N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTN8SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTN8SA3S;

	not MGM_BG_0( C_inv_for_BCTN8SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTN8SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTND512SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTND512SA3S;

	not MGM_BG_0( C_inv_for_BCTND512SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTND512SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTND51N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTND51N3S;

	not MGM_BG_0( C_inv_for_BCTND51N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTND51N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTND52N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTND52N3S;

	not MGM_BG_0( C_inv_for_BCTND52N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTND52N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTND54N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTND54N3S;

	not MGM_BG_0( C_inv_for_BCTND54N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTND54N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTND58SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTND58SA3S;

	not MGM_BG_0( C_inv_for_BCTND58SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTND58SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTNU512SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTNU512SA3S;

	not MGM_BG_0( C_inv_for_BCTNU512SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTNU512SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTNU51N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTNU51N3S;

	not MGM_BG_0( C_inv_for_BCTNU51N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTNU51N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTNU52N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTNU52N3S;

	not MGM_BG_0( C_inv_for_BCTNU52N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTNU52N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTNU54N3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTNU54N3S;

	not MGM_BG_0( C_inv_for_BCTNU54N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTNU54N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module BCTNU58SA3S_func( PAD, Y, C, A );
input C, A;
output Y;
inout PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_BCTNU58SA3S;

	not MGM_BG_0( C_inv_for_BCTNU58SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_BCTNU58SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

	buf MGM_BG_4( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module ICB3S_func( Y, PAD );
input PAD;
output Y;

	buf MGM_BG_0( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module ICBD53S_func( Y, PAD );
input PAD;
output Y;

	buf MGM_BG_0( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module ICBU53S_func( Y, PAD );
input PAD;
output Y;

	buf MGM_BG_0( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module ICN3S_func( Y, PAD );
input PAD;
output Y;

	buf MGM_BG_0( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module ICND53S_func( Y, PAD );
input PAD;
output Y;

	buf MGM_BG_0( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module ICNU53S_func( Y, PAD );
input PAD;
output Y;

	buf MGM_BG_0( Y, PAD );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCN12SA3S_func( PAD, A );
input A;
output PAD;

	buf MGM_BG_0( PAD, A );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCN1N3S_func( PAD, A );
input A;
output PAD;

	buf MGM_BG_0( PAD, A );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCN2N3S_func( PAD, A );
input A;
output PAD;

	buf MGM_BG_0( PAD, A );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCN4N3S_func( PAD, A );
input A;
output PAD;

	buf MGM_BG_0( PAD, A );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCN8SA3S_func( PAD, A );
input A;
output PAD;

	buf MGM_BG_0( PAD, A );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCND12SA3S_func( PAD, A );
input A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	assign MGM_WB_0 = 1'b0;

	buf MGM_BG_0( MGM_WB_1, A );

	bufif0 MGM_BG_1( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCND1N3S_func( PAD, A );
input A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	assign MGM_WB_0 = 1'b0;

	buf MGM_BG_0( MGM_WB_1, A );

	bufif0 MGM_BG_1( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCND2N3S_func( PAD, A );
input A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	assign MGM_WB_0 = 1'b0;

	buf MGM_BG_0( MGM_WB_1, A );

	bufif0 MGM_BG_1( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCND4N3S_func( PAD, A );
input A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	assign MGM_WB_0 = 1'b0;

	buf MGM_BG_0( MGM_WB_1, A );

	bufif0 MGM_BG_1( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCND8SA3S_func( PAD, A );
input A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	assign MGM_WB_0 = 1'b0;

	buf MGM_BG_0( MGM_WB_1, A );

	bufif0 MGM_BG_1( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCT12SA3S_func( PAD, C, A );
input C, A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_OCT12SA3S;

	not MGM_BG_0( C_inv_for_OCT12SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_OCT12SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCT1N3S_func( PAD, C, A );
input C, A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_OCT1N3S;

	not MGM_BG_0( C_inv_for_OCT1N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_OCT1N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCT2N3S_func( PAD, C, A );
input C, A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_OCT2N3S;

	not MGM_BG_0( C_inv_for_OCT2N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_OCT2N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCT4N3S_func( PAD, C, A );
input C, A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_OCT4N3S;

	not MGM_BG_0( C_inv_for_OCT4N3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_OCT4N3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OCT8SA3S_func( PAD, C, A );
input C, A;
output PAD;

	wire MGM_WB_0;

	wire MGM_WB_1;

	wire C_inv_for_OCT8SA3S;

	not MGM_BG_0( C_inv_for_OCT8SA3S, C );

	and MGM_BG_1( MGM_WB_0, C_inv_for_OCT8SA3S, A );

	buf MGM_BG_2( MGM_WB_1, C );

	bufif0 MGM_BG_3( PAD, MGM_WB_0,MGM_WB_1 );

endmodule
`endcelldefine
// udp_data_end
// udp_data_begin


`celldefine
module OSCL40C3S_func( PADO, Y, PADI );
input PADI;
output PADO, Y;

	not MGM_BG_0( PADO, PADI );

	not MGM_BG_1( Y, PADI );

endmodule
`endcelldefine
// udp_data_end
