module jpeg_sof(
	input        bit_avali,
	input [63:0] bit_out,

	input [3:0]  state,
	input [2:0]  sof_state,

	output reg        co_en,
	output            co_411,
	output reg [15:0] co_width,
	output reg [15:0] co_heigth,
	output reg [12:0] co_mcu_w,           
	output reg [12:0] co_mcu_h,           

	output reg [1:0] sof_y_qt,
	output reg [1:0] sof_cr_qt,
	output reg [1:0] sof_cb_qt,

	input clk,
	input rst

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
  	co_width <= 0;
  	co_heigth <= 0;
  	
  end else if(state == `state_rst)begin
  	sof_pre <= 0;
  	sof_color <= 0;
  	co_width <= 0;
  	co_heigth <= 0;
  	
  end else if(bit_avali & sof_state == `sof_state_reso)begin
  	sof_pre <= bit_out[63:56];
  	sof_color <= bit_out[23:16];
  	co_width <= bit_out[39:24];
  	co_heigth <= bit_out[55:40];
  	
  end 

reg [7:0] sof_y_factor ;
always@(posedge clk)
	if(rst)begin
		sof_y_factor <= 0;
		sof_y_qt <= 0;
	end else if(state == `state_rst)begin
		sof_y_factor <= 0;
		sof_y_qt <= 0;
	end else if(bit_avali & sof_state == `sof_state_y)begin
		sof_y_factor <= bit_out[55:48];
		sof_y_qt <= bit_out[41:40];
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

	assign co_411 = sof_y_factor[1] == 1'b1;  
  

	always @(posedge clk) begin
		if(rst)begin
			co_en <= 0;
		end else if(state == `state_rst)begin
			co_en <= 0;
		end else if(sof_state == `sof_state_cb)begin
			co_en <= 1;
			if(co_411)begin
				co_mcu_w <= co_width[3:0] == 4'd0  ? {1'b0,co_width[15:4]}  : {1'b0,co_width[15:4]} + 13'd1;
				co_mcu_h <= co_heigth[3:0] == 4'd0 ? {1'b0,co_heigth[15:4]} : {1'b0,co_heigth[15:4]} + 13'd1;   
			end else begin
				co_mcu_w <= co_width[2:0] == 'd0  ? co_width[15:3]  : co_width[15:3] + 13'd1;
				co_mcu_h <= co_heigth[2:0] == 'd0 ? co_heigth[15:3] : co_heigth[15:3] + 13'd1;
			end 
		end
	end




endmodule