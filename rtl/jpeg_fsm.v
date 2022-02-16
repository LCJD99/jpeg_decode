module jpeg_fsm(
input clk,rst,

input        bit_avali,
input [63:0] bit_out,
input        rd,
output       ready,

output reg [3:0] state,
output reg [2:0] dqt_state,
output reg [2:0] sof_state,
output reg [3:0] dht_state,
output reg       dht_cal_state,
output reg [1:0] sos_state,
output reg [2:0] dec_state,
output reg [1:0] dc_state,
output reg [1:0] ac_state,
output reg [1:0] dq_state,
output reg [1:0] idct1_state,
output reg [1:0] idct2_state,
output reg [1:0] rgb_state,

input pic_is_411,
input [15:0] width,heigth,
output reg [12:0] mcu_w,mcu_h,

output soi_find,
output sof_find,
output dqt_find,
output dht_find,
output sos_find,
output eoi_find,

input  dqt_end,
input  dqt_item_end,


input  dht_item_end,
input  dht_cal_end,
input  dht_end,
input  dht_loop_end,

input dc_word_eq,
input ac_word_eq,
input ac_all_zero,
input [7:0] ac_i,


output dq_eat,
output reg [3:0] i_in_mcu,
output reg [3:0] i_in_mcu_i2,
output reg [12:0] x_mcu_rgb,y_mcu_rgb,

output pic_end,

input out_empty
);

wire sos_end;
wire sof_end;
wire dec_end;
wire mcu_end;
wire dc_end;
wire ac_end;
wire rd_end;

reg [3:0] i_in_mcu_o;

assign soi_find = bit_out[63:48] == 16'hffd8;
assign dqt_find = bit_out[63:48] == 16'hffdb;
assign sof_find = bit_out[63:48] == 16'hffc0;
assign dht_find = bit_out[63:48] == 16'hffc4;
assign sos_find = bit_out[63:48] == 16'hffda;
assign eoi_find = bit_out[63:48] == 16'hffd9;

assign pic_end = state == `state_rst;

always@(posedge clk)
  if(rst)
    state <= `state_idl;
  else if(bit_avali)begin
  	case(state)
  		`state_idl:  state <= `state_soi;
  		`state_soi:  state <= soi_find ? `state_app : `state_soi;
  		`state_app:  state <= `state_dqt;
  		`state_dqt:  state <= dqt_end ? `state_sof : `state_dqt;
  		`state_sof:  state <= sof_end ? `state_dht : `state_sof;
  		`state_dht:  state <= dht_end ? `state_sos : `state_dht;
  		`state_sos:  state <= sos_end ? `state_dec : `state_sos;
  		`state_dec:  state <= dec_end ? `state_end : `state_dec;
  		`state_end:  state <= rd_end  ? `state_eoi : `state_end;
  		`state_eoi:  state <= eoi_find ? `state_rst : `state_eoi;
  		`state_rst:  state <= `state_idl;
  		default:;
  	endcase
  end else begin
  	case(state)
  		`state_rst:  state <= `state_idl;
  		default:;
  	endcase
  end   


	assign rd_end = 
		state == `state_end & 
		dq_state == `dq_state_idle & 
		idct1_state == `idct1_state_idle &
        idct2_state == `idct2_state_idle & 
		rgb_state == `rgb_state_idle & out_empty;



always@(posedge clk)
  if(rst)
    dqt_state <= `dqt_state_idle;
  else if(bit_avali & state == `state_dqt)begin
    case(dqt_state)
    	`dqt_state_idle:  dqt_state <= dqt_find ? `dqt_state_size : `dqt_state_idle;
    	`dqt_state_size:  dqt_state <= `dqt_state_tabl;
    	`dqt_state_tabl:  dqt_state <= `dqt_state_item;
    	`dqt_state_item:  dqt_state <= dqt_item_end ? `dqt_state_judg : `dqt_state_item; 
    	`dqt_state_judg:  dqt_state <= dqt_end ? `dqt_state_idle : `dqt_state_size;                              
    	default:;
    endcase
  end   


assign sof_end = sof_state == `sof_state_cb;

always@(posedge clk)
  if(rst)
    sof_state <= `sof_state_idle;
  else if(bit_avali & state == `state_sof)begin
  	case(sof_state)
  		`sof_state_idle:  sof_state <= sof_find ? `sof_state_size : `sof_state_idle;
  		`sof_state_size:  sof_state <= `sof_state_reso;  
  		`sof_state_reso:  sof_state <= `sof_state_y;    //2,3,4,5
  		`sof_state_y:     sof_state <= `sof_state_cr;
  		`sof_state_cr:    sof_state <= `sof_state_cb;
  		`sof_state_cb:    sof_state <= `sof_state_idle;
  		default:;
  	endcase
  end   


always@(posedge clk)
  if(rst)
    dht_state <= `dht_state_idle;
  else if(bit_avali & state == `state_dht)begin
    case(dht_state)
    	`dht_state_idle:  dht_state <= dht_find ? `dht_state_size : `dht_state_idle;
    	`dht_state_size:  dht_state <= `dht_state_tabl;
    	`dht_state_tabl:  dht_state <= `dht_state_cnth;
      `dht_state_cnth:  dht_state <= `dht_state_calh;
      `dht_state_calh:  dht_state <= dht_cal_end ? `dht_state_cntl : `dht_state_calh;
      `dht_state_cntl:  dht_state <= `dht_state_call;
      `dht_state_call:  dht_state <= dht_cal_end ? `dht_state_item : `dht_state_call;
      `dht_state_item:  dht_state <= dht_item_end ? `dht_state_judg : `dht_state_item;
      `dht_state_judg:  dht_state <= dht_end ? `dht_state_idle : `dht_state_size;
    	default:;
    endcase
  end else if(state == `state_dht)begin
  	case(dht_state)
  		`dht_state_calh:  dht_state <= dht_cal_end ? `dht_state_cntl : `dht_state_calh;
  		`dht_state_call:  dht_state <= dht_cal_end ? `dht_state_item : `dht_state_call;
  		default:;
  	endcase
  end 


always@(posedge clk)
  if(rst)
    dht_cal_state <= `dht_cal_state_idle;
  else if(dht_state == `dht_state_calh | dht_state == `dht_state_call)begin
  	case(dht_cal_state)
  		`dht_cal_state_idle: dht_cal_state <= `dht_cal_state_do;
  		`dht_cal_state_do:   dht_cal_state <= dht_loop_end ? 
  		                (dht_cal_end ? `dht_cal_state_idle : `dht_cal_state_do) 
  		                                                   : `dht_cal_state_do;
  		default:;
  	endcase
  end   

assign sos_end = sos_state == `sos_state_spec & bit_avali;

always@(posedge clk)
  if(rst)
    sos_state <= `sos_state_idle;
  else if(bit_avali & state == `state_sos)begin
  	case(sos_state)
  		`sos_state_idle:  sos_state <= sos_find ? `sos_state_size : `sos_state_idle;
  		`sos_state_size:  sos_state <= `sos_state_tabl;
  		`sos_state_tabl:  sos_state <= `sos_state_spec;
  		`sos_state_spec:  sos_state <= `sos_state_idle;
  		default:;
  	endcase
  end   
  




always@(posedge clk)
  if(rst)begin
  	mcu_w <= 0;
  	mcu_h <= 0;
  end else if(state == `state_rst)begin
  	mcu_w <= 0;
  	mcu_h <= 0;
  end else if(bit_avali & state == `state_sos & sos_end)begin
  	if(pic_is_411)begin
  		mcu_w <= width[3:0] == 4'd0  ? {1'b0,width[15:4]}  : {1'b0,width[15:4]} + 13'd1;
      mcu_h <= heigth[3:0] == 4'd0 ? {1'b0,heigth[15:4]} : {1'b0,heigth[15:4]} + 13'd1;   
  	end else begin
  		mcu_w <= width[2:0] == 4'd0  ? width[15:3]  : width[15:3] + 13'd1;
  	  mcu_h <= heigth[2:0] == 4'd0 ? heigth[15:3] : heigth[15:3] + 13'd1;
  	end 
  end 

reg [15:0] mcu_num;

reg [12:0] x_mcu,y_mcu;

always@(posedge clk)
  if(rst)begin
  	x_mcu <= 0;
  	y_mcu <= 0;
  	mcu_num <= 0;
  end else if(state == `state_rst)begin
  	x_mcu <= 0;
  	y_mcu <= 0;
  	mcu_num <= 0;	
  end else if(dec_state == `dec_state_updat)begin
  	x_mcu <= x_mcu == mcu_w - 13'd1 ? 0 : x_mcu + 13'd1;
  	y_mcu <= x_mcu == mcu_w - 13'd1 ? (y_mcu == mcu_h - 13'd1 ? 13'd0 : y_mcu + 13'd1) : y_mcu;
  	mcu_num <= dec_end ? mcu_num : mcu_num + 1;
  end 


always@(posedge clk)
  if(rst)
    i_in_mcu <= 4'd0;
  else if(state == `state_rst)
  	i_in_mcu <= 4'd0;  
  else if(dec_state == `dec_state_mupdat)begin
    if(pic_is_411)begin
    	i_in_mcu <= i_in_mcu == 4'd5 ? 4'd0 : i_in_mcu + 4'd1;
    end else begin
    	i_in_mcu <= i_in_mcu == 4'd2 ? 4'd0 : i_in_mcu + 4'd1;
    end 
  end  




  
assign dec_end = dec_state == `dec_state_updat & x_mcu == mcu_w - 13'd1 & y_mcu == mcu_h - 13'd1;  
assign mcu_end = dec_state == `dec_state_mupdat & 
               ((pic_is_411 & i_in_mcu == 4'd5) | (!pic_is_411 & i_in_mcu == 4'd2));
assign dc_end = dc_state == `dc_state_valu & bit_avali;
assign ac_end = ((ac_state == `ac_state_judg & ac_all_zero) | 
                 (ac_state == `ac_state_valu & ac_i == 62)) & bit_avali;
                
                
always@(posedge clk)
  if(rst)
    dec_state <= `dec_state_idle;
  else if(state == `state_dec)begin
  	case(dec_state)
  		`dec_state_idle:  dec_state <= `dec_state_dc;
  		`dec_state_dc:    dec_state <= dc_end ? `dec_state_ac : `dec_state_dc;
  		`dec_state_ac:    dec_state <= ac_end ? `dec_state_wait : `dec_state_ac;
  		`dec_state_wait:    dec_state <= dq_eat ? `dec_state_mupdat : `dec_state_wait;
  		`dec_state_mupdat:  dec_state <= mcu_end ? `dec_state_updat : `dec_state_dc;
  		`dec_state_updat:   dec_state <= dec_end ? `dec_state_idle  : `dec_state_dc;
  		default:;
  	endcase
  end 
 
 

    
   

 
always@(posedge clk)
  if(rst)
    dc_state <= `dc_state_idle;
  else if(bit_avali & dec_state == `dec_state_dc)begin
    case(dc_state)
    	`dc_state_idle:  dc_state <= `dc_state_comp;
    	`dc_state_comp:  dc_state <= dc_word_eq ? `dc_state_valu : `dc_state_comp; 
    	`dc_state_valu:  dc_state <= `dc_state_idle;
    	default:;
    endcase  
  end 	
  


       

always@(posedge clk)
  if(rst)
    ac_state <= `ac_state_idle;
  else if(bit_avali & dec_state == `dec_state_ac)begin
  	case(ac_state)
  		`ac_state_idle:  ac_state <= `ac_state_comp;
  		`ac_state_comp:  ac_state <= ac_word_eq ? `ac_state_judg : `ac_state_comp;
  		`ac_state_judg:  ac_state <= ac_all_zero ? `ac_state_idle : `ac_state_valu;
  		`ac_state_valu:  ac_state <= ac_i == 62 ? `ac_state_idle : `ac_state_comp;
  		default:;
  	endcase
  end    

wire idct1_eat = idct1_state == `idct1_state_idle;
wire idct2_eat = idct2_state == `idct2_state_idle;
wire dec_wait = dec_state == `dec_state_wait;
wire dq_wait = dq_state == `dq_state_wait;
wire idct1_wait = idct1_state == `idct1_state_wait;
wire idct2_wait = idct2_state == `idct2_state_wait;
assign dq_eat = dq_state == `dq_state_idle;
wire rgb_eat = rgb_state == `rgb_state_idle;


always@(posedge clk)
  if(rst)
    dq_state <= `dq_state_idle;
  else 
    case(dq_state) 
    	`dq_state_idle:  dq_state <= dec_wait ? `dq_state_dq : `dq_state_idle;
    	`dq_state_dq:    dq_state <= `dq_state_wait;
    	`dq_state_wait:  dq_state <= idct1_eat ? `dq_state_idle : `dq_state_wait;
    	default:;
    endcase


always@(posedge clk)
  if(rst)
    idct1_state <= `idct1_state_idle;
  else 
    case(idct1_state)
    	`idct1_state_idle:   idct1_state <= dq_wait ? `idct1_state_do : `idct1_state_idle;
    	`idct1_state_do:     idct1_state <= `idct1_state_cal;
    	`idct1_state_cal:    idct1_state <= `idct1_state_wait;
    	`idct1_state_wait:   idct1_state <= idct2_eat ? `idct1_state_idle : `idct1_state_wait;
    	default:;
    endcase




always@(posedge clk)
  if(rst)
    idct2_state <= `idct2_state_idle;
  else 
    case(idct2_state)
    	`idct2_state_idle:   idct2_state <= idct1_wait ? `idct2_state_do : `idct2_state_idle;
    	`idct2_state_do:     idct2_state <= `idct2_state_cal;
    	`idct2_state_cal:    idct2_state <= `idct2_state_wait;
    	`idct2_state_wait:   idct2_state <= rgb_eat ? `idct2_state_idle : `idct2_state_wait;
    	default:;
    endcase




always@(posedge clk)
  if(rst)
    rgb_state <= `rgb_state_idle;
  else 
    case(rgb_state)
    	`rgb_state_idle:    rgb_state <= idct2_wait ? `rgb_state_store : `rgb_state_idle;
    	`rgb_state_store:   rgb_state <= pic_is_411 ? 
    	                                 (i_in_mcu_o == 5 ? `rgb_state_wait : `rgb_state_idle) :
    	                                 (i_in_mcu_o == 2 ? `rgb_state_wait : `rgb_state_idle);
    	`rgb_state_wait:    rgb_state <= out_empty ? `rgb_state_idle : `rgb_state_wait;
    	default:;
    endcase



reg [3:0] i_in_mcu_dq;
reg [12:0] x_mcu_dq,y_mcu_dq;
always@(posedge clk)
  if(rst)begin
  	i_in_mcu_dq <= 0;
  	x_mcu_dq <= 0;
  	y_mcu_dq <= 0;
  end else if(state == `state_rst)begin
  	i_in_mcu_dq <= 0;
  	x_mcu_dq <= 0;
  	y_mcu_dq <= 0;	
  end else if(dec_wait & dq_eat)begin
  	i_in_mcu_dq <= i_in_mcu;
  	x_mcu_dq <= x_mcu;
  	y_mcu_dq <= y_mcu;
  end 


reg [3:0] i_in_mcu_i1;
reg [12:0] x_mcu_i1,y_mcu_i1;
always@(posedge clk)
  if(rst)begin
  	i_in_mcu_i1 <= 0;
  	x_mcu_i1 <= 0;
  	y_mcu_i1 <= 0;
  end else if(state == `state_rst)begin
  	i_in_mcu_i1 <= 0;
  	x_mcu_i1 <= 0;
  	y_mcu_i1 <= 0;	
  end else if(dq_wait & idct1_eat)begin
  	i_in_mcu_i1 <= i_in_mcu_dq;
  	x_mcu_i1 <= x_mcu_dq;
  	y_mcu_i1 <= y_mcu_dq;
  end
  

reg [12:0] x_mcu_i2,y_mcu_i2;  

always@(posedge clk)
  if(rst)begin
  	i_in_mcu_i2 <= 0;
  	x_mcu_i2 <= 0;
  	y_mcu_i2 <= 0;
  end else if(state == `state_rst)begin
  	i_in_mcu_i2 <= 0;
  	x_mcu_i2 <= 0;
  	y_mcu_i2 <= 0;	
  end else if(idct1_wait & idct2_eat)begin
  	i_in_mcu_i2 <= i_in_mcu_i1;
  	x_mcu_i2 <= x_mcu_i1;
  	y_mcu_i2 <= y_mcu_i1;
  end

always@(posedge clk)
  if(rst)begin
  	i_in_mcu_o <= 0;
  	x_mcu_rgb <= 0;
  	y_mcu_rgb <= 0;
  end else if(state == `state_rst)begin
  	i_in_mcu_o <= 0;
  	x_mcu_rgb <= 0;
  	y_mcu_rgb <= 0;	
  end else if(idct2_wait & rgb_eat)begin
  	i_in_mcu_o <= i_in_mcu_i2;
  	x_mcu_rgb <= x_mcu_i2;
  	y_mcu_rgb <= y_mcu_i2;
  	
  end 




endmodule 