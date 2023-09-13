// =============================================================================
// I2C/SMB implementation
// =============================================================================
task init;
input [31:0] mode;
// 0/1/2/others: 100KHz/400KHz/1000KHz/reserved
begin
//	spi_init (0);
	dev_en = 1;
	{Tcsb_max,Tcsb_min} = {32'd300,32'd100};
	{Tcsh_max,Tcsh_min} = {32'd200,32'd100};
	{Tsck_max,Tsck_min} = {32'd2000,32'd100};
	{Tpkt_max,Tpkt_min} = {32'd3000,32'd300};
	case (mode)
	0: begin
	   Tck_p = 10000; // standard mode, 100KHz
	   Tck_d = 43; // (4+0.3 : 10), Tr not simulated (lazy designer !!)
	   Tck_j = 300; // clock high (4000,4600), low (5400,6000)
	   Tsdo_min = 0; // T(HD,DAT)
	   Tsdo_max = 5150; // 5400-T(SU,DAT)
	end
	1: begin
	   Tck_p = 2500; // fast mode, 400KHz
	   Tck_d = 36; // (0.6+0.3 : 2.5)
	   Tck_j = 300; // clock high (600,1200), low (1300,1900)
	   Tsdo_min = 0; // T(HD,DAT)
//	   Tsdo_max = 1200; // 1300-T(SU,DAT), failed for 6MHz MCLK
	   Tsdo_max = 1140; // 1300-T(SU,DAT)
	end
	2: begin
	   Tck_p = 1000; // fast mode plus, 1000KHz
	   Tck_d = 38; // (0.26+0.12 : 1)
	   Tck_j = 120; // clock high (260,500), low (500,740)
	   Tsdo_min = 0; // T(HD,DAT)
	   Tsdo_max = 410; // 500-T(SU,DAT)
	end
	3: begin // // fast mode plus, 1000KHz, with more idealy timing
	   Tck_p = 1000; // 1000KHz
	   Tck_d = 30; // lower duty earns more setup-time
	   Tck_j = 10; //
	   Tsdo_min = 0; // T(HD,DAT)
//	   Tsdo_max = 450; // 500-T(SU,DAT), failed for 10MHz MCLK
	   Tsdo_max = 410; // 500-T(SU,DAT)
	end
	default: begin
	   Tck_p = mode; // <9000, sync. to main clock for CP/FT
	   Tck_d = 30;
	   Tck_j = 0;
	   Tsdo_min = 100;
	   Tsdo_max = 100;
	   $display ($time, "ns <%m> synchronized I2C mode: %0dKHz", 1000000/Tck_p);
	end
	endcase
	cpolar = 1; // SMB works only in mode 3
	cphase = 1;
	open_drain = 1;
	trans_io = 1;
	sdo = 1;
	$display ($time, "ns <%m> SSE master initialized, mode: SMB(%0d)", mode);
end
endtask // smb_init
// -----------------------------------------------------------------------------
task _tx_s;
// I2C start condition
integer tmp_tsdo;
event sev;
begin
->sev;	csb = 1;
	#({$random}%(2*Tck_j+1)-Tck_j+Tck_p*Tck_d/100); // T(SU,STA), over constraint in STD
	tmp_tsdo = Tsdo_max;
	Tsdo_max = Tsdo_min;
	sdo = 0;
	#({$random}%(2*Tck_j+1)-Tck_j+Tck_p*Tck_d/100); // T(HD,STA)
	Tsdo_max = tmp_tsdo;
->sev;	csb = 0;
end
endtask // _tx_s
task _tx_p;
// I2C stop condition
integer tmp_tsdo;
event pev;
begin
->pev;	csb = 0;
	_txrx (0,0);
	csb = 1;
	#({$random}%(2*Tck_j+1)-Tck_j+Tck_p*Tck_d/100) // T(SU,STO)
	tmp_tsdo = Tsdo_max;
	Tsdo_max = Tsdo_min;
	sdo = 1;
	#({$random}%(2*Tck_j+1)-Tck_j+Tck_p*(100-Tck_d)/100); // T(BUF)
->pev;	Tsdo_max = tmp_tsdo;
end
endtask // _tx_p
// -----------------------------------------------------------------------------
task _txrx_ack;
// transmit I2C ack/nak, and optionally check result
input txack; // 0/1: tx ACK/NAK
input rxack; // 0/1: ACK/NAK expected, 'hx to don't care
reg [7:0] tmp_crc8;
event xev;
begin
->xev;	tmp_crc8 = crc8_val;
	_txrx (0, txack);
	crc8_val = tmp_crc8;
	if (rxack!=='hx && rx_data[0]!==rxack) begin
	   if (rxack) $display ($time, "ns <%m> ERROR: NAK expected");
	   else       $display ($time, "ns <%m> ERROR: ACK expected");
	   #200 $finish;
	end
->xev;
end
endtask // _txrx_ack

// -----------------------------------------------------------------------------
parameter MAX_DATA_BIT = 15;
parameter MAX_DATA_DEP = 2**MAX_DATA_BIT;
parameter DEV_ADDR = 'h70; // [7:1]
reg [7:1] dev_addr = DEV_ADDR;


task bkwr;
input [7:0] addr;
input [MAX_DATA_BIT-1:0] cnt;
input [MAX_DATA_DEP*8-1:0] wdat;
reg [MAX_DATA_BIT:0] idx;
begin
	_tx_s;
	_txrx (7,{dev_addr,1'h0});	_txrx_ack (1,0);
	_txrx (7,addr[7:0]);		_txrx_ack (1,0);
	for (idx=0; idx<cnt; idx=idx+1) begin
	   _txrx (7,wdat>>8*idx);	_txrx_ack (1,0);
//	   if (idx==cnt-1)		_txrx_ack (1,1);
//	   else				_txrx_ack (1,0);
	end
	_tx_p;
end
endtask // bkwr

event ev_bkrd; // to latch rx_data
task bkrd;
input [7:0] addr;
input [MAX_DATA_BIT-1:0] cnt;
input [MAX_DATA_DEP*8-1:0] expdat;
begin
	_tx_s;
	_txrx (7,{dev_addr,1'h0});	_txrx_ack (1,0);
	_txrx (7,addr[7:0]);		_txrx_ack (1,0);
	_txrx (0,1); // one-bit to replace stop, causes a repeated start
	rd0 (addr, cnt, expdat); // repeated start
end
endtask // bkrd

task rd0;
input [7:0] addr;
input [MAX_DATA_BIT-1:0] cnt;
input [MAX_DATA_DEP*8-1:0] expdat;
reg [MAX_DATA_BIT:0] idx;
begin
	_tx_s;
	_txrx (7,{dev_addr,1'h1});	_txrx_ack (1,0);
	for (idx=0; idx<cnt; idx=idx+1) begin
	   _txrx (7,'hff); rddat = rx_data; ->ev_bkrd;
	   _rx_chk (7, rx_data, expdat>>8*idx, addr+(idx<<8));
	   if (idx==cnt-1)		_txrx_ack (1,1);
	   else				_txrx_ack (0,0);
        end
	_tx_p;
end
endtask // rd0


// -----------------------------------------------------------------------------
task sfrw;
input [7:0] addr, wdat;
	bkwr (addr,1,wdat);
endtask // sfrw
task sfrr;
input [7:0] addr, exp;
	bkrd (addr,1,exp);
endtask // sfrr


`include "pd_task.v"

