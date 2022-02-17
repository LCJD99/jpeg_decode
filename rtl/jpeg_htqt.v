module jpeg_htqt(
input clk,rst,

input        bit_avali,
input [63:0] bit_out,

input [3:0] state,
input [3:0] dht_state,
input       dht_cal_state,
input [2:0] dec_state,
input [1:0] dc_state,
input [1:0] ac_state,
input [2:0] dqt_state,
input [1:0] dq_state,

output      dqt_item_end,
output      dqt_end,

input  dht_find,
output dht_item_end,
output dht_cal_end,
output dht_end,
output dht_loop_end,

input  pic_is_411,
input [3:0] i_in_mcu,

output dc_word_eq,
output ac_word_eq,
output ac_all_zero,
output reg [7:0] ac_i,
output     [4:0] dc_size_i,
output     [4:0] ac_size_i,
output reg [7:0] dc_value,
output reg [7:0] ac_value,

input [1:0] sof_y_qt,sof_cr_qt,sof_cb_qt,
input dq_eat,

output reg signed [23:0] qt_out_00,qt_out_01,qt_out_02,qt_out_03,qt_out_04,qt_out_05,qt_out_06,qt_out_07,
output reg signed [23:0] qt_out_10,qt_out_11,qt_out_12,qt_out_13,qt_out_14,qt_out_15,qt_out_16,qt_out_17,
output reg signed [23:0] qt_out_20,qt_out_21,qt_out_22,qt_out_23,qt_out_24,qt_out_25,qt_out_26,qt_out_27,
output reg signed [23:0] qt_out_30,qt_out_31,qt_out_32,qt_out_33,qt_out_34,qt_out_35,qt_out_36,qt_out_37,
output reg signed [23:0] qt_out_40,qt_out_41,qt_out_42,qt_out_43,qt_out_44,qt_out_45,qt_out_46,qt_out_47,
output reg signed [23:0] qt_out_50,qt_out_51,qt_out_52,qt_out_53,qt_out_54,qt_out_55,qt_out_56,qt_out_57,
output reg signed [23:0] qt_out_60,qt_out_61,qt_out_62,qt_out_63,qt_out_64,qt_out_65,qt_out_66,qt_out_67,
output reg signed [23:0] qt_out_70,qt_out_71,qt_out_72,qt_out_73,qt_out_74,qt_out_75,qt_out_76,qt_out_77

);


reg [15:0] dqt_size;

always@(posedge clk)
  if(rst)
    dqt_size <= 0;
  else if(state == `state_rst)
    dqt_size <= 0;  
  else if(bit_avali & dqt_state == `dqt_state_size)
  	dqt_size <= bit_out[63:48];
    
reg [3:0] dqt_item_i;
always@(posedge clk)
  if(rst)
    dqt_item_i <= 0;
  else if(state == `state_rst)
    dqt_item_i <= 0;
  else if(dqt_state == `dqt_state_tabl) 
    dqt_item_i <= 0; 
  else if(bit_avali & dqt_state == `dqt_state_item)
  	dqt_item_i <= dqt_item_i + 1;  



wire [5:0] dqt_item_ix8 = {dqt_item_i[2:0],3'b0};
wire [5:0] dqt_item_ix4 = {dqt_item_i[3:0],2'b0};

reg       dqt_pre;
reg [1:0] dqt_id;

always@(posedge clk)
  if(rst)begin
    dqt_pre <= 0;
    dqt_id  <= 0;
  end else if(state == `state_rst)begin
  	dqt_pre <= 0;
    dqt_id  <= 0;  
  end else if(bit_avali & dqt_state == `dqt_state_tabl)begin
    dqt_pre <= bit_out[63:60] == 4'd0 ? 1'b0 : 1'b1;  
    dqt_id  <= bit_out[57:56];
  end 

assign dqt_end = dqt_state == `dqt_state_judg & bit_out[63:48] != 16'hffdb;
assign dqt_item_end = (dqt_pre & dqt_item_i == 4'd15) | (!dqt_pre & dqt_item_i == 4'd7);


reg dqt_pre_0;
reg dqt_pre_1;
reg dqt_pre_2;
reg dqt_pre_3;

always@(posedge clk)
  if(rst)begin
  	dqt_pre_0 <= 0;
  	dqt_pre_1 <= 0;
  	dqt_pre_2 <= 0;
  	dqt_pre_3 <= 0;
  end else if(state == `state_rst)begin
  	dqt_pre_0 <= 0;
  	dqt_pre_1 <= 0;
  	dqt_pre_2 <= 0;
  	dqt_pre_3 <= 0;	
  end else if(dqt_state == `dqt_state_item)begin
  	if(dqt_id == 0)
  	  dqt_pre_0 <= dqt_pre;
  	else if(dqt_id == 1)
  	  dqt_pre_1 <= dqt_pre; 
  	else if(dqt_id == 2)
  	  dqt_pre_2 <= dqt_pre;  
  	else
  	  dqt_pre_3 <= dqt_pre;      
  end

reg [15:0] dqt_table_0 [63:0];
reg [15:0] dqt_table_1 [63:0];
reg [15:0] dqt_table_2 [63:0];
reg [15:0] dqt_table_3 [63:0];

always@(posedge clk)
  if(bit_avali & dqt_state == `dqt_state_item & dqt_id == 0)begin
    if(dqt_pre == 0)begin
  	  dqt_table_0[dqt_item_ix8]     <= {8'b0,bit_out[63:56]};
  	  dqt_table_0[dqt_item_ix8 + 1] <= {8'b0,bit_out[55:48]};
  	  dqt_table_0[dqt_item_ix8 + 2] <= {8'b0,bit_out[47:40]}; 
  	  dqt_table_0[dqt_item_ix8 + 3] <= {8'b0,bit_out[39:32]}; 
  	  dqt_table_0[dqt_item_ix8 + 4] <= {8'b0,bit_out[31:24]}; 
  	  dqt_table_0[dqt_item_ix8 + 5] <= {8'b0,bit_out[23:16]}; 
  	  dqt_table_0[dqt_item_ix8 + 6] <= {8'b0,bit_out[15:8]}; 
  	  dqt_table_0[dqt_item_ix8 + 7] <= {8'b0,bit_out[7:0]};   
    end else begin
    	dqt_table_0[dqt_item_ix4]     <= bit_out[63:48];
    	dqt_table_0[dqt_item_ix4 + 1] <= bit_out[47:32];
    	dqt_table_0[dqt_item_ix4 + 2] <= bit_out[31:16];
    	dqt_table_0[dqt_item_ix4 + 3] <= bit_out[15:0];
    end 
  end 
   
always@(posedge clk)
  if(bit_avali & dqt_state == `dqt_state_item & dqt_id == 1)begin
    if(dqt_pre == 0)begin
  	  dqt_table_1[dqt_item_ix8]     <= {8'b0,bit_out[63:56]};
  	  dqt_table_1[dqt_item_ix8 + 1] <= {8'b0,bit_out[55:48]};
  	  dqt_table_1[dqt_item_ix8 + 2] <= {8'b0,bit_out[47:40]}; 
  	  dqt_table_1[dqt_item_ix8 + 3] <= {8'b0,bit_out[39:32]}; 
  	  dqt_table_1[dqt_item_ix8 + 4] <= {8'b0,bit_out[31:24]}; 
  	  dqt_table_1[dqt_item_ix8 + 5] <= {8'b0,bit_out[23:16]}; 
  	  dqt_table_1[dqt_item_ix8 + 6] <= {8'b0,bit_out[15:8]}; 
  	  dqt_table_1[dqt_item_ix8 + 7] <= {8'b0,bit_out[7:0]};   
    end else begin
    	dqt_table_1[dqt_item_ix4]     <= bit_out[63:48];
    	dqt_table_1[dqt_item_ix4 + 1] <= bit_out[47:32];
    	dqt_table_1[dqt_item_ix4 + 2] <= bit_out[31:16];
    	dqt_table_1[dqt_item_ix4 + 3] <= bit_out[15:0];
    end 
  end     

always@(posedge clk)
  if(bit_avali & dqt_state == `dqt_state_item & dqt_id == 2)begin
    if(dqt_pre == 0)begin
  	  dqt_table_2[dqt_item_ix8]     <= {8'b0,bit_out[63:56]};
  	  dqt_table_2[dqt_item_ix8 + 1] <= {8'b0,bit_out[55:48]};
  	  dqt_table_2[dqt_item_ix8 + 2] <= {8'b0,bit_out[47:40]}; 
  	  dqt_table_2[dqt_item_ix8 + 3] <= {8'b0,bit_out[39:32]}; 
  	  dqt_table_2[dqt_item_ix8 + 4] <= {8'b0,bit_out[31:24]}; 
  	  dqt_table_2[dqt_item_ix8 + 5] <= {8'b0,bit_out[23:16]}; 
  	  dqt_table_2[dqt_item_ix8 + 6] <= {8'b0,bit_out[15:8]}; 
  	  dqt_table_2[dqt_item_ix8 + 7] <= {8'b0,bit_out[7:0]};   
    end else begin
    	dqt_table_2[dqt_item_ix4]     <= bit_out[63:48];
    	dqt_table_2[dqt_item_ix4 + 1] <= bit_out[47:32];
    	dqt_table_2[dqt_item_ix4 + 2] <= bit_out[31:16];
    	dqt_table_2[dqt_item_ix4 + 3] <= bit_out[15:0];
    end 
  end 
  
always@(posedge clk)
  if(bit_avali & dqt_state == `dqt_state_item & dqt_id == 3)begin
    if(dqt_pre == 0)begin
  	  dqt_table_3[dqt_item_ix8]     <= {8'b0,bit_out[63:56]};
  	  dqt_table_3[dqt_item_ix8 + 1] <= {8'b0,bit_out[55:48]};
  	  dqt_table_3[dqt_item_ix8 + 2] <= {8'b0,bit_out[47:40]}; 
  	  dqt_table_3[dqt_item_ix8 + 3] <= {8'b0,bit_out[39:32]}; 
  	  dqt_table_3[dqt_item_ix8 + 4] <= {8'b0,bit_out[31:24]}; 
  	  dqt_table_3[dqt_item_ix8 + 5] <= {8'b0,bit_out[23:16]}; 
  	  dqt_table_3[dqt_item_ix8 + 6] <= {8'b0,bit_out[15:8]}; 
  	  dqt_table_3[dqt_item_ix8 + 7] <= {8'b0,bit_out[7:0]};   
    end else begin
    	dqt_table_3[dqt_item_ix4]     <= bit_out[63:48];
    	dqt_table_3[dqt_item_ix4 + 1] <= bit_out[47:32];
    	dqt_table_3[dqt_item_ix4 + 2] <= bit_out[31:16];
    	dqt_table_3[dqt_item_ix4 + 3] <= bit_out[15:0];
    end 
  end 





//------------------------------
reg [15:0] dht_size;
always@(posedge clk)
  if(rst)
    dht_size <= 0;
  else if(state == `state_rst)
    dht_size <= 0; 
  else if(bit_avali & dht_state == `dht_state_size)
    dht_size <= bit_out[63:48];  

reg dht_type;   //0: dc 1: ac
reg dht_id;
always@(posedge clk)
  if(rst)begin
  	dht_type <= 0;
  	dht_id   <= 0;
  end else if(state == `state_rst)begin
  	dht_type <= 0;
  	dht_id   <= 0;	
  end else if(bit_avali & dht_state == `dht_state_tabl)begin
  	dht_type <= bit_out[60] == 1'd0 ? 1'b0 : 1'b1;
  	dht_id   <= bit_out[56];
  end 

reg [63:0] dht_cnt_dat;
always@(posedge clk)
  if(rst)
    dht_cnt_dat <= 0;
  else if(state == `state_rst)
    dht_cnt_dat <= 0;
  else if(bit_avali & (dht_state == `dht_state_cnth | dht_state == `dht_state_cntl))
  	dht_cnt_dat <= bit_out;

reg [2:0] dht_cal_i;
always@(posedge clk)
  if(rst)
    dht_cal_i <= 0;
  else if(state == `state_rst)
    dht_cal_i <= 0;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end)  
    dht_cal_i <= dht_cal_i + 1;

wire [5:0] dht_cal_ix8 = {dht_cal_i,3'd0};

assign dht_cal_end = dht_cal_state == `dht_cal_state_do & dht_cal_i == 3'd7 & dht_loop_end;
   


wire [7:0] dht_cnt_cur = dht_cnt_dat[63 - dht_cal_ix8 -: 8];
wire [7:0] dht_cnt_cur_m1 = dht_cnt_cur - 'd1;

reg [15:0] dht_cnt_acc;
always@(posedge clk)
  if(rst)
    dht_cnt_acc <= 0;
  else if(state == `state_rst)
    dht_cnt_acc <= 0;
  else if(dht_state == `dht_state_size)  
    dht_cnt_acc <= 0;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end)
    dht_cnt_acc <= dht_cnt_acc + {8'b0,dht_cnt_cur};  


wire [4:0] dht_size_din = dht_state == `dht_state_calh ? {2'b0,dht_cal_i} + 5'b1 : 
                          dht_state == `dht_state_call ? {2'b0,dht_cal_i} + 5'd9 : 5'd0;

reg [15:0] dht_word_din;
always@(posedge clk)
  if(rst)
    dht_word_din <= 16'd0;
  else if(state == `state_rst)
    dht_word_din <= 16'd0;
  else if(dht_state == `dht_state_item)  
    dht_word_din <= 16'd0;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end)
    dht_word_din <= (dht_word_din + {8'b0,dht_cnt_cur}) << 1;
 
    
reg [15:0] dht_item_i;
always@(posedge clk)
  if(rst) 
    dht_item_i <= 0;
  else if(state == `state_rst)
    dht_item_i <= 0;
  else if(dht_state == `dht_state_size)  
    dht_item_i <= 0;  
  else if(bit_avali & dht_state == `dht_state_item) 
    dht_item_i <= dht_item_i + 1; 

assign dht_item_end = dht_state == `dht_state_item & dht_item_i == dht_cnt_acc - 1;
assign dht_end = dht_state == `dht_state_judg & (!dht_find | {dht_type,dht_id} == 2'b11);

reg [15:0] dht_cnt_tot_dc0;
reg [15:0] dht_cnt_tot_dc1;
reg [15:0] dht_cnt_tot_ac0;
reg [15:0] dht_cnt_tot_ac1;
    
always@(posedge clk)
  if(rst)begin
  	dht_cnt_tot_dc0 <= 0;
  	dht_cnt_tot_dc1 <= 0;
  	dht_cnt_tot_ac0 <= 0;
  	dht_cnt_tot_ac1 <= 0;
  end else if(state == `state_rst)begin
  	dht_cnt_tot_dc0 <= 0;
  	dht_cnt_tot_dc1 <= 0;
  	dht_cnt_tot_ac0 <= 0;
  	dht_cnt_tot_ac1 <= 0;	
  end else if(dht_state == `dht_state_judg)begin
  	if(dht_type == 0 & dht_id == 0)
  	  dht_cnt_tot_dc0 <= dht_cnt_acc;
  	else if(dht_type == 0 & dht_id == 1) 
  	  dht_cnt_tot_dc1 <= dht_cnt_acc; 
  	else if(dht_type == 1 & dht_id == 0) 
  	  dht_cnt_tot_ac0 <= dht_cnt_acc;   
  	else
  	  dht_cnt_tot_ac1 <= dht_cnt_acc;    
  end     

reg [7:0] i_dc0;
always@(posedge clk)
  if(rst)
    i_dc0 <= 0;
  else if(state == `state_rst) 
    i_dc0 <= 0;
  else if(dht_cal_state == `dht_cal_state_idle) 
    i_dc0 <= 0;
  else if(dht_cal_state == `dht_cal_state_do & !dht_loop_end & dht_type == 0 & dht_id == 0)
    i_dc0 <= i_dc0 + 8'd1;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end & dht_type == 0 & dht_id == 0)    
    i_dc0 <= 0;  




reg [4:0]  dht_size_dc0 [255:0];
reg [15:0] dht_word_dc0 [255:0];
reg [7:0]  dht_valu_dc0 [255:0];

always@(posedge clk)
  if(dht_cal_state == `dht_cal_state_do & dht_type == 0 & dht_id == 0)begin
  	dht_size_dc0[i_dc0 + dht_cnt_acc] <= dht_size_din;
  	dht_word_dc0[i_dc0 + dht_cnt_acc] <= dht_word_din + i_dc0;
  end
  
  
always@(posedge clk)
  if(bit_avali & dht_state == `dht_state_item & dht_type == 0 & dht_id == 0)
    dht_valu_dc0[dht_item_i] <= bit_out[63:56];

reg [4:0]  dht_size_dc1 [255:0];
reg [15:0] dht_word_dc1 [255:0];
reg [7:0]  dht_valu_dc1 [255:0];


reg [7:0] i_dc1;
always@(posedge clk)
  if(rst)
    i_dc1 <= 0;
  else if(state == `state_rst)
    i_dc1 <= 0;
  else if(dht_cal_state == `dht_cal_state_idle) 
    i_dc1 <= 0;
  else if(dht_cal_state == `dht_cal_state_do & !dht_loop_end & dht_type == 0 & dht_id == 1)
    i_dc1 <= i_dc1 + 8'd1;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end & dht_type == 0 & dht_id == 1)    
    i_dc1 <= 0;  



always@(posedge clk)
  if(dht_cal_state == `dht_cal_state_do & dht_type == 0 & dht_id == 1)begin
  		dht_size_dc1[i_dc1 + dht_cnt_acc] <= dht_size_din;
  		dht_word_dc1[i_dc1 + dht_cnt_acc] <= dht_word_din + i_dc1;
  end
  
  
always@(posedge clk)
  if(bit_avali & dht_state == `dht_state_item & dht_type == 0 & dht_id == 1)
    dht_valu_dc1[dht_item_i] <= bit_out[63:56];





reg [4:0]  dht_size_ac0 [255:0];
reg [15:0] dht_word_ac0 [255:0];
reg [7:0]  dht_valu_ac0 [255:0];



reg [7:0] i_ac0;
always@(posedge clk)
  if(rst)
    i_ac0 <= 0;
  else if(state == `state_rst)
    i_ac0 <= 0;
  else if(dht_cal_state == `dht_cal_state_idle) 
    i_ac0 <= 0;
  else if(dht_cal_state == `dht_cal_state_do & !dht_loop_end & dht_type == 1 & dht_id == 0)
    i_ac0 <= i_ac0 + 8'd1;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end & dht_type == 1 & dht_id == 0)    
    i_ac0 <= 0;  



always@(posedge clk)
  if(dht_cal_state == `dht_cal_state_do & dht_type == 1 & dht_id == 0)begin
  		dht_size_ac0[i_ac0 + dht_cnt_acc] <= dht_size_din;
  		dht_word_ac0[i_ac0 + dht_cnt_acc] <= dht_word_din + i_ac0;
  end
  
  
always@(posedge clk)
  if(bit_avali & dht_state == `dht_state_item & dht_type == 1 & dht_id == 0)
    dht_valu_ac0[dht_item_i] <= bit_out[63:56];

reg [4:0]  dht_size_ac1 [255:0];
reg [15:0] dht_word_ac1 [255:0];
reg [7:0]  dht_valu_ac1 [255:0];



reg [7:0] i_ac1;
always@(posedge clk)
  if(rst)
    i_ac1 <= 0;
  else if(state == `state_rst)
    i_ac1 <= 0;
  else if(dht_cal_state == `dht_cal_state_idle) 
    i_ac1 <= 0;
  else if(dht_cal_state == `dht_cal_state_do & !dht_loop_end & dht_type == 1 & dht_id == 1)
    i_ac1 <= i_ac1 + 8'd1;
  else if(dht_cal_state == `dht_cal_state_do & dht_loop_end & dht_type == 1 & dht_id == 1)    
    i_ac1 <= 0;  


always@(posedge clk)
  if(dht_cal_state == `dht_cal_state_do & dht_type == 1 & dht_id == 1)begin
  		dht_size_ac1[i_ac1 + dht_cnt_acc] <= dht_size_din;
  		dht_word_ac1[i_ac1 + dht_cnt_acc] <= dht_word_din + i_ac1;
  end
  
  
always@(posedge clk)
  if(bit_avali & dht_state == `dht_state_item & dht_type == 1 & dht_id == 1)
    dht_valu_ac1[dht_item_i] <= bit_out[63:56];

wire 
assign dht_loop_end = (dht_type == 0 & dht_id == 0 ? i_dc0 == dht_cnt_cur_m1 : 
                       dht_type == 0 & dht_id == 1 ? i_dc1 == dht_cnt_cur_m1 :
                       dht_type == 1 & dht_id == 0 ? i_ac0 == dht_cnt_cur_m1 :
                                                     i_ac1 == dht_cnt_cur_m1 ;
//------------------------------

wire is_y = (pic_is_411 & i_in_mcu < 4) | (!pic_is_411 & i_in_mcu == 0);
wire is_cr = (pic_is_411 & i_in_mcu == 4) | (!pic_is_411 & i_in_mcu == 1);
wire is_cb = (pic_is_411 & i_in_mcu == 5) | (!pic_is_411 & i_in_mcu == 2);


reg [15:0] i_dc_dec;
always@(posedge clk)
  if(rst)
    i_dc_dec <= 0;
  else if(state == `state_rst)
    i_dc_dec <= 0;
  else if(dc_state == `dc_state_idle)
    i_dc_dec <= 0;
  else if(dc_state == `dc_state_comp & bit_avali & !dc_word_eq) 
    i_dc_dec <= i_dc_dec + 1; 

assign dc_size_i = is_y ? dht_size_dc0[i_dc_dec] : dht_size_dc1[i_dc_dec];
wire [15:0] dc_word_i = is_y ? dht_word_dc0[i_dc_dec] : dht_word_dc1[i_dc_dec];

assign dc_word_eq = ({bit_out[63:48]} >> (16 - dc_size_i)) == dc_word_i;


always@(posedge clk)
  if(rst)
    dc_value <= 0;
  else if(state == `state_rst)
    dc_value <= 0;
  else if(dc_state == `dc_state_comp & bit_avali & dc_word_eq)
    dc_value <= is_y ? dht_valu_dc0[i_dc_dec] : dht_valu_dc1[i_dc_dec];

wire [15:0] dc_output_tmp1 = bit_out[63:48] >> (16 - dc_value);
wire [15:0] dc_output_tmp2 = dc_output_tmp1 < (16'b1 << (dc_value - 1)) ? 
                      dc_output_tmp1 - (16'b1 << dc_value) + 16'b1 : 
                      dc_output_tmp1;
    
reg [15:0] dc_output_y;
reg [15:0] dc_output_cr;
reg [15:0] dc_output_cb;
always@(posedge clk)
  if(rst)begin
    dc_output_y <= 0;
    dc_output_cr <= 0;
    dc_output_cb <= 0; 
  end else if(state == `state_rst)begin
  	dc_output_y <= 0;
    dc_output_cr <= 0;
    dc_output_cb <= 0;     
  end else if(bit_avali & dc_state == `dc_state_valu)begin
  	if(is_y)
      dc_output_y <= dc_output_tmp2 + dc_output_y;  
    else if(is_cr)
      dc_output_cr <= dc_output_tmp2 + dc_output_cr;  
    else
      dc_output_cb <= dc_output_tmp2 + dc_output_cb;  
  end 




reg [15:0] i_ac_dec;
always@(posedge clk)
  if(rst)
    i_ac_dec <= 0;
  else if(state == `state_rst)
    i_ac_dec <= 0;
  else if(ac_state == `ac_state_idle | 
         (ac_state == `ac_state_valu & ac_i != 62) & bit_avali)
    i_ac_dec <= 0;
  else if(ac_state == `ac_state_comp & bit_avali & !ac_word_eq)
    i_ac_dec <= i_ac_dec + 1;   

assign ac_size_i = is_y ? dht_size_ac0[i_ac_dec] : dht_size_ac1[i_ac_dec];
wire [15:0] ac_word_i = is_y ? dht_word_ac0[i_ac_dec] : dht_word_ac1[i_ac_dec];

assign ac_word_eq = ({bit_out[63:48]} >> (16 - ac_size_i)) == ac_word_i;


always@(posedge clk)
  if(rst)
    ac_value <= 0;
  else if(state == `state_rst)
    ac_value <= 0;
  else if(ac_state == `ac_state_comp & bit_avali & ac_word_eq)
    ac_value <= is_y ? dht_valu_ac0[i_ac_dec] : dht_valu_ac1[i_ac_dec];

always@(posedge clk)
  if(rst)
    ac_i <= 8'hff;
  else if(state == `state_rst)
    ac_i <= 8'hff;
  else if(ac_state == `ac_state_idle) 
    ac_i <= 8'hff;
  else if(ac_state == `ac_state_judg)  
    ac_i <= ac_i + 8'b1 + {4'b0,ac_value[7:4]};


reg [15:0] ac_output [62:0];

wire [15:0] ac_output_tmp1 = {bit_out[63:48]} >> (16 - ac_value[3:0]);
wire [15:0] ac_output_tmp2 = ac_output_tmp1 < (16'b1 << (ac_value[3:0] - 1)) ? 
                      ac_output_tmp1 - (16'b1 << ac_value[3:0]) + 16'b1 : 
                      ac_output_tmp1;


integer i_rst_ac;
always@(posedge clk)
  if(rst)begin
  	for(i_rst_ac = 0 ; i_rst_ac < 63; i_rst_ac = i_rst_ac + 1)begin
  		ac_output[i_rst_ac] <= 0;
  	end
  end else if(state == `state_rst)begin
  	for(i_rst_ac = 0 ; i_rst_ac < 63; i_rst_ac = i_rst_ac + 1)begin
  		ac_output[i_rst_ac] <= 0;
  	end	 
  end else if(dec_state == `dec_state_wait & dq_eat)begin
  	for(i_rst_ac = 0 ; i_rst_ac < 63; i_rst_ac = i_rst_ac + 1)begin
  		ac_output[i_rst_ac] <= 0;
  	end 
  end else if(ac_state == `ac_state_valu & bit_avali)begin
  	ac_output[ac_i] <= ac_output_tmp2;  
  end 

assign ac_all_zero = ac_state == `ac_state_judg & ac_value == 8'b0;


//-----------------------
reg [1:0] color_qt;

always@(posedge clk)
  if(rst)
  	color_qt <= 0;
  else if(state == `state_rst)
    color_qt <= 0;	
  else if(dq_state == `dq_state_idle & dec_state == `dec_state_wait)begin
  	if(is_y)
  	  color_qt <= 0;
  	else if(is_cr)
  	  color_qt <= 1; 
  	else 
  	  color_qt <= 2;  
  end 
    
reg [15:0] qt_tmp [63:0];
reg [15:0] ot_tmp [63:0];

integer i_qt;
always@(posedge clk)
  if(dq_state == `dq_state_idle & dec_state == `dec_state_wait)begin
  	if((is_y & sof_y_qt == 0) | (is_cr & sof_cr_qt == 0) | (is_cb & sof_cb_qt == 0))begin
      for(i_qt=0; i_qt < 64; i_qt = i_qt + 1)begin
  		  qt_tmp[i_qt] <= dqt_table_0[i_qt];
  		end 
  	end else if((is_y & sof_y_qt == 1) | (is_cr & sof_cr_qt == 1) | (is_cb & sof_cb_qt == 1))begin
      for(i_qt=0; i_qt < 64; i_qt = i_qt + 1)begin
  		  qt_tmp[i_qt] <= dqt_table_1[i_qt];
  		end 
  	end else if((is_y & sof_y_qt == 2) | (is_cr & sof_cr_qt == 2) | (is_cb & sof_cb_qt == 2))begin
      for(i_qt=0; i_qt < 64; i_qt = i_qt + 1)begin
  		  qt_tmp[i_qt] <= dqt_table_2[i_qt];
  		end 
  	end else begin
  		for(i_qt=0; i_qt < 64; i_qt = i_qt + 1)begin
  		  qt_tmp[i_qt] <= dqt_table_3[i_qt];
  		end 
  	end   
  end 

integer i_ot;
always@(posedge clk)
  if(dq_state == `dq_state_idle & dec_state == `dec_state_wait)begin
  	if(is_y)
  	  ot_tmp[0] <= dc_output_y;
  	else if(is_cr)
  	  ot_tmp[0] <= dc_output_cr;  
  	else
  	  ot_tmp[0] <= dc_output_cb; 
  	
  	for(i_ot=0; i_ot < 63; i_ot = i_ot + 1)begin
  		ot_tmp[i_ot + 1] <= ac_output[i_ot];
  	end      
  end 




always@(posedge clk)
  if(rst)begin
  	qt_out_00 <= 0;qt_out_01 <= 0;qt_out_02 <= 0;qt_out_03 <= 0;
  	qt_out_04 <= 0;qt_out_05 <= 0;qt_out_06 <= 0;qt_out_07 <= 0;
  	qt_out_10 <= 0;qt_out_11 <= 0;qt_out_12 <= 0;qt_out_13 <= 0;
  	qt_out_14 <= 0;qt_out_15 <= 0;qt_out_16 <= 0;qt_out_17 <= 0;
  	qt_out_20 <= 0;qt_out_21 <= 0;qt_out_22 <= 0;qt_out_23 <= 0;
  	qt_out_24 <= 0;qt_out_25 <= 0;qt_out_26 <= 0;qt_out_27 <= 0;
  	qt_out_30 <= 0;qt_out_31 <= 0;qt_out_32 <= 0;qt_out_33 <= 0;
  	qt_out_34 <= 0;qt_out_35 <= 0;qt_out_36 <= 0;qt_out_37 <= 0;
  	qt_out_40 <= 0;qt_out_41 <= 0;qt_out_42 <= 0;qt_out_43 <= 0;
  	qt_out_44 <= 0;qt_out_45 <= 0;qt_out_46 <= 0;qt_out_47 <= 0;
  	qt_out_50 <= 0;qt_out_51 <= 0;qt_out_52 <= 0;qt_out_53 <= 0;
  	qt_out_54 <= 0;qt_out_55 <= 0;qt_out_56 <= 0;qt_out_57 <= 0;
  	qt_out_60 <= 0;qt_out_61 <= 0;qt_out_62 <= 0;qt_out_63 <= 0;
  	qt_out_64 <= 0;qt_out_65 <= 0;qt_out_66 <= 0;qt_out_67 <= 0;
  	qt_out_70 <= 0;qt_out_71 <= 0;qt_out_72 <= 0;qt_out_73 <= 0;
  	qt_out_74 <= 0;qt_out_75 <= 0;qt_out_76 <= 0;qt_out_77 <= 0;
  end else if(dq_state == `dq_state_dq)begin
  	qt_out_00 <= $signed(qt_tmp[0])  * $signed(ot_tmp[0]);
  	qt_out_01 <= $signed(qt_tmp[1])  * $signed(ot_tmp[1]);
  	qt_out_02 <= $signed(qt_tmp[5])  * $signed(ot_tmp[5]);
  	qt_out_03 <= $signed(qt_tmp[6])  * $signed(ot_tmp[6]);
  	qt_out_04 <= $signed(qt_tmp[14]) * $signed(ot_tmp[14]);
  	qt_out_05 <= $signed(qt_tmp[15]) * $signed(ot_tmp[15]);
  	qt_out_06 <= $signed(qt_tmp[27]) * $signed(ot_tmp[27]);
  	qt_out_07 <= $signed(qt_tmp[28]) * $signed(ot_tmp[28]);
  	qt_out_10 <= $signed(qt_tmp[2])  * $signed(ot_tmp[2]);
  	qt_out_11 <= $signed(qt_tmp[4])  * $signed(ot_tmp[4]);
  	qt_out_12 <= $signed(qt_tmp[7])  * $signed(ot_tmp[7]);
  	qt_out_13 <= $signed(qt_tmp[13]) * $signed(ot_tmp[13]);
  	qt_out_14 <= $signed(qt_tmp[16]) * $signed(ot_tmp[16]);
  	qt_out_15 <= $signed(qt_tmp[26]) * $signed(ot_tmp[26]);
  	qt_out_16 <= $signed(qt_tmp[29]) * $signed(ot_tmp[29]);
  	qt_out_17 <= $signed(qt_tmp[42]) * $signed(ot_tmp[42]);
  	qt_out_20 <= $signed(qt_tmp[3])  * $signed(ot_tmp[3]);
  	qt_out_21 <= $signed(qt_tmp[8])  * $signed(ot_tmp[8]);
  	qt_out_22 <= $signed(qt_tmp[12]) * $signed(ot_tmp[12]);
  	qt_out_23 <= $signed(qt_tmp[17]) * $signed(ot_tmp[17]);
  	qt_out_24 <= $signed(qt_tmp[25]) * $signed(ot_tmp[25]);
  	qt_out_25 <= $signed(qt_tmp[30]) * $signed(ot_tmp[30]);
  	qt_out_26 <= $signed(qt_tmp[41]) * $signed(ot_tmp[41]);
  	qt_out_27 <= $signed(qt_tmp[43]) * $signed(ot_tmp[43]);
  	qt_out_30 <= $signed(qt_tmp[9])  * $signed(ot_tmp[9]);
  	qt_out_31 <= $signed(qt_tmp[11]) * $signed(ot_tmp[11]);
  	qt_out_32 <= $signed(qt_tmp[18]) * $signed(ot_tmp[18]);
  	qt_out_33 <= $signed(qt_tmp[24]) * $signed(ot_tmp[24]);
  	qt_out_34 <= $signed(qt_tmp[31]) * $signed(ot_tmp[31]);
  	qt_out_35 <= $signed(qt_tmp[40]) * $signed(ot_tmp[40]);
  	qt_out_36 <= $signed(qt_tmp[44]) * $signed(ot_tmp[44]);
  	qt_out_37 <= $signed(qt_tmp[53]) * $signed(ot_tmp[53]);
  	qt_out_40 <= $signed(qt_tmp[10]) * $signed(ot_tmp[10]);
  	qt_out_41 <= $signed(qt_tmp[19]) * $signed(ot_tmp[19]);
  	qt_out_42 <= $signed(qt_tmp[23]) * $signed(ot_tmp[23]);
  	qt_out_43 <= $signed(qt_tmp[32]) * $signed(ot_tmp[32]);
  	qt_out_44 <= $signed(qt_tmp[39]) * $signed(ot_tmp[39]);
  	qt_out_45 <= $signed(qt_tmp[45]) * $signed(ot_tmp[45]);
  	qt_out_46 <= $signed(qt_tmp[52]) * $signed(ot_tmp[52]);
  	qt_out_47 <= $signed(qt_tmp[54]) * $signed(ot_tmp[54]);
  	qt_out_50 <= $signed(qt_tmp[20]) * $signed(ot_tmp[20]);
  	qt_out_51 <= $signed(qt_tmp[22]) * $signed(ot_tmp[22]);
  	qt_out_52 <= $signed(qt_tmp[33]) * $signed(ot_tmp[33]);
  	qt_out_53 <= $signed(qt_tmp[38]) * $signed(ot_tmp[38]);
  	qt_out_54 <= $signed(qt_tmp[46]) * $signed(ot_tmp[46]);
  	qt_out_55 <= $signed(qt_tmp[51]) * $signed(ot_tmp[51]);
  	qt_out_56 <= $signed(qt_tmp[55]) * $signed(ot_tmp[55]);
  	qt_out_57 <= $signed(qt_tmp[60]) * $signed(ot_tmp[60]);
  	qt_out_60 <= $signed(qt_tmp[21]) * $signed(ot_tmp[21]);
  	qt_out_61 <= $signed(qt_tmp[34]) * $signed(ot_tmp[34]);
  	qt_out_62 <= $signed(qt_tmp[37]) * $signed(ot_tmp[37]);
  	qt_out_63 <= $signed(qt_tmp[47]) * $signed(ot_tmp[47]);
  	qt_out_64 <= $signed(qt_tmp[50]) * $signed(ot_tmp[50]);
  	qt_out_65 <= $signed(qt_tmp[56]) * $signed(ot_tmp[56]);
  	qt_out_66 <= $signed(qt_tmp[59]) * $signed(ot_tmp[59]);
  	qt_out_67 <= $signed(qt_tmp[61]) * $signed(ot_tmp[61]);
  	qt_out_70 <= $signed(qt_tmp[35]) * $signed(ot_tmp[35]);
  	qt_out_71 <= $signed(qt_tmp[36]) * $signed(ot_tmp[36]);
  	qt_out_72 <= $signed(qt_tmp[48]) * $signed(ot_tmp[48]);
  	qt_out_73 <= $signed(qt_tmp[49]) * $signed(ot_tmp[49]);
  	qt_out_74 <= $signed(qt_tmp[57]) * $signed(ot_tmp[57]);
  	qt_out_75 <= $signed(qt_tmp[58]) * $signed(ot_tmp[58]);
  	qt_out_76 <= $signed(qt_tmp[62]) * $signed(ot_tmp[62]);
  	qt_out_77 <= $signed(qt_tmp[63]) * $signed(ot_tmp[63]);
  end 

endmodule