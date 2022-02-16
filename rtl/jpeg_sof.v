module jpeg_sof(
input clk,rst,

input        bit_avali,
input [63:0] bit_out,

input [3:0] state,
input [2:0] sof_state,

output pic_is_411,
output reg [15:0] width,heigth,
output reg res_avali,

output reg [1:0] sof_y_qt,sof_cr_qt,sof_cb_qt

);

reg [15:0] sof_size;
always@(posedge clk)
  if(rst)
    sof_size <= 0;
  else if(state == `state_rst)
    sof_size <= 0; 
  else if(bit_avali & sof_state == `sof_state_size)  
    sof_size <= bit_out[63:48];

reg [7:0] sof_pre;
reg [7:0] sof_color;


always@(posedge clk)
  if(rst)begin
  	sof_pre <= 0;
  	sof_color <= 0;
  	width <= 0;
  	heigth <= 0;
  	
  end else if(state == `state_rst)begin
  	sof_pre <= 0;
  	sof_color <= 0;
  	width <= 0;
  	heigth <= 0;
  	
  end else if(bit_avali & sof_state == `sof_state_reso)begin
  	sof_pre <= bit_out[63:56];
  	sof_color <= bit_out[23:16];
  	width <= bit_out[39:24];
  	heigth <= bit_out[55:40];
  	
  end 

reg [7:0] sof_y_factor ;
always@(posedge clk)
  if(rst)begin
  	sof_y_factor <= 0;
  	sof_y_qt <= 0;
  	res_avali <= 0;
  end else if(state == `state_rst)begin
  	sof_y_factor <= 0;
  	sof_y_qt <= 0;
  	res_avali <= 0;		
  end else if(bit_avali & sof_state == `sof_state_y)begin
  	sof_y_factor <= bit_out[55:48];
  	sof_y_qt <= bit_out[41:40];
  	res_avali <= 1'b1;
  end 
    


reg [7:0] sof_cr_factor; 
always@(posedge clk)
  if(rst)begin
  	sof_cr_factor <= 0;
  	sof_cr_qt <= 0;
  end else if(state == `state_rst)begin
  	sof_cr_factor <= 0;
  	sof_cr_qt <= 0;	
  end else if(bit_avali & sof_state == `sof_state_cr)begin
  	sof_cr_factor <= bit_out[55:48];
  	sof_cr_qt <= bit_out[41:40];
  end 


reg [7:0] sof_cb_factor;  
always@(posedge clk)
  if(rst)begin
  	sof_cb_factor <= 0;
  	sof_cb_qt <= 0;
  end else if(state == `state_rst)begin
  	sof_cb_factor <= 0;
  	sof_cb_qt <= 0;	
  end else if(bit_avali & sof_state == `sof_state_cb)begin
  	sof_cb_factor <= bit_out[55:48];
  	sof_cb_qt <= bit_out[41:40];
  end 

assign pic_is_411 = sof_y_factor[1] == 1'b1;  
  
endmodule