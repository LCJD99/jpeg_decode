`include "timescale.v"
`include "jpeg_defines.v"

module jpeg_sos(
input clk,rst,

input        bit_avali,
input [63:0] bit_out,

input [3:0] state,
input [1:0] sos_state

);

reg [15:0] sos_size;
always@(posedge clk)
  if(rst)
    sos_size <= 0;
  else if(state == `state_rst)
    sos_size <= 0;  
  else if(bit_avali & sos_state == `sos_state_size)  
    sos_size <= bit_out[63:48];  

reg [7:0] sos_color_cnt;
reg [3:0] dc_ht_0,dc_ht_1,dc_ht_2;
reg [3:0] ac_ht_0,ac_ht_1,ac_ht_2;

always@(posedge clk)
  if(rst)begin
    sos_color_cnt <= 0;
    dc_ht_0 <= 0;
    dc_ht_1 <= 0;
    dc_ht_2 <= 0;
    ac_ht_0 <= 0;
    ac_ht_1 <= 0;
    ac_ht_2 <= 0;
  end else if(state == `state_rst)begin
  	sos_color_cnt <= 0;
    dc_ht_0 <= 0;
    dc_ht_1 <= 0;
    dc_ht_2 <= 0;
    ac_ht_0 <= 0;
    ac_ht_1 <= 0;
    ac_ht_2 <= 0;  
  end else if(bit_avali & sos_state == `sos_state_tabl)begin
  	sos_color_cnt <= bit_out[63:56];
    dc_ht_0 <= bit_out[47:44];
    ac_ht_0 <= bit_out[43:40];
    dc_ht_1 <= bit_out[31:28];
    ac_ht_1 <= bit_out[27:24];
    dc_ht_2 <= bit_out[15:12];
    ac_ht_2 <= bit_out[11:8];
  end   

reg [23:0] sos_spec;
always@(posedge clk)
  if(rst)
  	sos_spec <= 0;
  else if(bit_avali & sos_state == `sos_state_spec)
    sos_spec <= bit_out[63:40];

endmodule