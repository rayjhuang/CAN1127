
module cvctl (
// =============================================================================
// CV control
// 2022/07/26 Ray Huang, rayhuang@canyon-semi.com.tw
//            rename from halflsb.v (from CAN1124A0)
// ALL RIGHTS ARE RESERVED
// =============================================================================
input [5:0] r_cvcwr,
input [7:0] wdat,
output [7:0] r_sdischg, r_vcomp, r_idacsh, r_cvofsx,
output [4*4-1:0] r_cvofs,
output sdischg_duty,

input r_hlsb_en, r_hlsb_sel, r_hlsb_freq, r_hlsb_duty,
input [11:0] r_fw_pwrv,
output [10:0] r_dac0, // DAC0
output [5:0] r_dac3, // DAC3, CAN1124A0: add bit5
input clk_100k, clk, srstz
);
   wire rrstz = srstz;

// PWR_V =======================================================================
   reg [4:0] div20_cnt;
   reg clk_5k; // minus period
   always@(posedge clk_100k or negedge srstz)
      if (~srstz) clk_5k <= 'h0;
      else if (r_hlsb_en)
         case ({r_hlsb_freq,r_hlsb_duty})
         2'b00: clk_5k <= div20_cnt > 5'd9;
         2'b01: clk_5k <= div20_cnt > 5'd8;
         2'b10: clk_5k <= div20_cnt > 5'd4;
         2'b11: clk_5k <= div20_cnt > 5'd3;
         endcase
      else clk_5k <= 'h0;

   always@(posedge clk_100k or negedge srstz)
      if (~srstz) div20_cnt <='d0;
      else if (div20_cnt >= (r_hlsb_freq?'d9:'d19)
                         || ~r_hlsb_en) div20_cnt<= 'd0;
      else div20_cnt <= div20_cnt +'d1;

   glreg u0_v_comp     (clk, rrstz, r_cvcwr[3], wdat, r_vcomp); // V_COMP
   glreg u0_idac_shift (clk, rrstz, r_cvcwr[4], wdat, r_idacsh); // IDACSH
   glreg u0_cv_ofsx    (clk, rrstz, r_cvcwr[5], wdat, r_cvofsx); // CV_OFSX
   wire [11:0] cv_code = r_fw_pwrv
                       + r_vcomp
                       - r_idacsh
                       + (r_hlsb_en&clk_5k ? (r_hlsb_sel ? 'h1 : 'h2) : 'h0)
                       + {{5{r_cvofsx[7]}},r_cvofsx};

// CVOFS =======================================================================
   wire [7:0] r_cvofs01, r_cvofs23;
   wire [3:0] r_cvofs0 ={r_cvofs01[7],r_cvofs01[2:0]}, r_cvofs1 = r_cvofs01[6:3],
              r_cvofs2 ={r_cvofs23[7],r_cvofs23[2:0]}, r_cvofs3 = r_cvofs23[6:3];
   assign r_cvofs = {r_cvofs23,r_cvofs01};
   glreg u0_cvofs01 (clk, rrstz, r_cvcwr[0], wdat, r_cvofs01); // CVOFS01
   glreg u0_cvofs23 (clk, rrstz, r_cvcwr[1], wdat, r_cvofs23); // CVOFS23

   // to separate the FW value into DAC0/DAC3 codes
   assign r_dac0 =  cv_code > 'd2047 ? {10'd1023,cv_code[0]} : cv_code[10:0];
   assign r_dac3 = (cv_code > 'd2047 ? cv_code[11:1]-'d1023 : 'h0) +
                   (cv_code < 'd512  ? r_cvofs0 
                   :cv_code < 'd1024 ? r_cvofs1
                   :cv_code < 'd1536 ? r_cvofs2 : r_cvofs3);

// SDISCHG =====================================================================
   glreg u0_sdischg (clk, rrstz, r_cvcwr[2], wdat, r_sdischg); // SDISCHG
   wire [4:0] r_sdis_duty = r_sdischg[4:0];
   wire r_sdis_vin = r_sdischg[5];
   wire r_sdis_vbus = r_sdischg[6];

   reg [4:0] sdischg_cnt;
   reg sdischg;
   always@(posedge clk_100k or negedge srstz)
      if (~srstz) begin
         sdischg_cnt <= 'h0;
         sdischg <= 'h0;
      end else if (|{r_sdis_vin,r_sdis_vbus,sdischg_cnt})
         if (r_sdis_vin | r_sdis_vbus) begin
            sdischg_cnt <= sdischg_cnt + 'h1;
            sdischg <= r_sdis_duty >= sdischg_cnt;
         end else
            sdischg_cnt <= 'h0;

   assign sdischg_duty = sdischg;

endmodule // cvctl

