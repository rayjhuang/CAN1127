
`timescale 1ns/100ps
module bhv_cc_rcver ( // BMC receiver in anatop
input [15:0] v_cc,
output rx_sql, rx_d_pk, rx_d_49
);
   reg [15:0] peak_mid = 563;
   assign rx_d_pk = v_cc>peak_mid;
   assign rx_d_49 = v_cc>=490;
   wire cc_over  = v_cc>(peak_mid+200);
   wire cc_under = v_cc<(peak_mid-200);
   reg r_sqlch =1;
   reg s_over,s_under;
   event ev_cc_over,ev_cc_under;
   initial begin
	#111 ->ev_cc_over;
	#11  ->ev_cc_under;
	fork
	forever @(posedge cc_over)  begin disable sqlch_over;  #1 ->ev_cc_over;  end
	forever @(posedge cc_under) begin disable sqlch_under; #1 ->ev_cc_under; end
	forever @(s_over or s_under) #(1000*100) r_sqlch = ~(s_over&s_under);
	join
   end
   always @(ev_cc_over)  begin: sqlch_over  #(1000*10) disable ccv_over;  s_over=0;  end
   always @(ev_cc_under) begin: sqlch_under #(1000*10) disable ccv_under; s_under=0; end
   always @(ev_cc_over)  begin: ccv_over  #(1000*11) s_over=1;  end
   always @(ev_cc_under) begin: ccv_under #(1000*11) s_under=1; end
   assign rx_sql = r_sqlch;

endmodule // bhv_cc_rcver

