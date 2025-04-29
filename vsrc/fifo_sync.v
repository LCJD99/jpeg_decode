/* ****************************************************************************
//	This Source Code is A Synchronous FIFO Ctrl.
// 
//  File Name   : fifo_sync.v
//  Creator(s)  : 13943761963@163.com
//  Description : A Synchronous FIFO Ctrl.
//
//	Parameters  :
//      AW: addr(ptr) width.
//      DW: data width.
//		MODE: to set the rd signal read access behavior mode.
//			"SHOWAHEAD" : show-ahead mode.
//			"NORMAL":     normal mode.
//  
***************************************************************************** */
module fifo_sync #(
    parameter AW = 1,
	parameter DW = 1,
	parameter MODE = "SHOWAHEAD"   //"NORMAL"
)(
    input           wr,
    input           rd,
    input [DW-1:0]  din,

    output          full,
    output          empty,
    output [DW-1:0] dout,

    input clk,
    input rst
);

    reg [DW-1:0] mem [(1<<AW)-1:0];
	reg [AW:0] wp;
	reg [AW:0] rp;

    always@( posedge clk ) begin
		if (rst) 
			wp <= 0;
		else if (wr & !full) 
			wp <= wp + 1;
	end

	always@( posedge clk ) begin
		if (wr & !full) 
			mem[wp[AW-1:0]] <= din;
	end

    always@( posedge clk ) begin
		if (rst) 
			rp <= 0;
		else if (rd & !empty) 
			rp <= rp + 1;
	end

    assign full = wp[AW-1:0] == rp[AW-1:0] & wp[AW] != rp[AW];
    assign empty = wp == rp;

generate
	if (MODE == "SHOWAHEAD") begin: show_ahead_mode

		assign dout = mem[rp[AW-1:0]];

	end else if (MODE == "NORMAL") begin: normal_mode

		reg [DW-1:0] dout_r;
		always@( posedge clk ) begin
			if (rd & !empty)begin
				dout_r <= mem[rp[AW-1:0]];
			end
		end 

		assign dout = dout_r;

	end else begin

		always@( posedge clk )
			$display("FIFO_SYNC MODE ERROR");

	end
endgenerate



endmodule