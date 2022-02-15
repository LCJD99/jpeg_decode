`include "timescale.v"
`include "jpeg_defines.v"

module jpeg_stream(
input clk,rst,

input [7:0] din,
input we,
output next,


input [7:0] pc_delta,
output [63:0] bit_out,
output bit_avali

);

reg [95:0] bit_stream;
reg [7:0] point;


assign bit_out = bit_stream[95:32];
assign bit_avali = point > 8'd63;

wire ridzero;
wire addff;
reg close_next;


always@(posedge clk)
  if(rst)
    point <= 0;
  else if(we & next)begin
  	if(ridzero)
  	  point <= point - pc_delta;
  	else if(addff)  
  	  point <= 8'd95;
  	else
      point <= point - pc_delta + 8'd8;
  end else if(close_next)
    point <= 8'd95;
  else   
    point <= point - pc_delta;
    
    
assign next = point < 8'd89;
wire [95:0] din_ext = we & next ? {88'b0,din} << (8'd88 - point) : 96'd0;

always@(posedge clk)
  if(rst)
    bit_stream <= 0;
  else 
    bit_stream <= (bit_stream | din_ext) << pc_delta ;      
      
reg [7:0] lastword;
always@(posedge clk)
  if(rst)
    lastword <= 0;
  else if(we & next)  
    lastword <= din;
    
assign ridzero = we & next & din == 8'h00 & lastword == 8'hff;    
assign addff   = we & next & din == 8'hd9 & lastword == 8'hff; 


always@(posedge clk)
  if(rst)
    close_next <= 0;
  else if(addff)  
    close_next <= 1;
  else if(close_next & bit_stream[95:80] == 16'hffd9)
    close_next <= 0;

endmodule 