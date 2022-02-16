module jpeg_pc(
input clk,rst,

input [3:0] state,
input [2:0] dqt_state,
input [2:0] sof_state,
input [3:0] dht_state,
input [1:0] sos_state,
input [2:0] dec_state,
input [1:0] dc_state,
input [1:0] ac_state,

input bit_avali,

input soi_find,
input dqt_find,
input dht_find,
input sof_find,
input sos_find,
input eoi_find,

input dqt_end,
input dht_end,


input dc_word_eq,
input ac_word_eq,
input [4:0] dc_size_i,
input [4:0] ac_size_i,
input [7:0] dc_value,
input [7:0] ac_value,

output reg [7:0] pc_delta

);

always@( * )
  if(bit_avali)begin
  	case(state)
  		`state_soi:  pc_delta = soi_find ? 8'd16 : 8'd1;
  		`state_dqt: 
  		  case(dqt_state)
  		  	`dqt_state_idle:  pc_delta = dqt_find ? 8'd16 : 8'd8;
  		  	`dqt_state_size:  pc_delta = 8'd16;
  		  	`dqt_state_tabl:  pc_delta = 8'd8;
  		  	`dqt_state_item:  pc_delta = 8'd64;
  		  	`dqt_state_judg:  pc_delta = dqt_end ? 8'd0 : 8'd16;
  		  	default:  pc_delta = 8'd0;
  		  endcase
  		`state_sof:
  		  case(sof_state)
  		  	`sof_state_idle:  pc_delta = sof_find ? 8'd16 : 8'd8;
  		  	`sof_state_size:  pc_delta = 8'd16;
  		  	`sof_state_reso:  pc_delta = 8'd48;
  		  	`sof_state_y,`sof_state_cr,`sof_state_cb:
  		  	                  pc_delta = 8'd24;
  		  	default:  pc_delta = 8'd0;
  		  endcase
  		`state_dht:
  		  case(dht_state)
  		  	`dht_state_idle:  pc_delta = dht_find ? 8'd16 : 8'd8;
    	    `dht_state_size:  pc_delta = 8'd16;
    	    `dht_state_tabl:  pc_delta = 8'd8;
          `dht_state_cnth:  pc_delta = 8'd64;
          `dht_state_cntl:  pc_delta = 8'd64;
          `dht_state_item:  pc_delta = 8'd8;
          `dht_state_judg:  pc_delta = dht_end ? 8'd0 : 8'd16;
  		  	default:pc_delta = 8'd0;
  		  endcase
  		`state_sos:
  		  case(sos_state)
  		  	`sos_state_idle:  pc_delta = sos_find ? 8'd16 : 8'd8;
  		  	`sos_state_size:  pc_delta = 8'd16;
  		  	`sos_state_tabl:  pc_delta = 8'd56;
  		  	`sos_state_spec:  pc_delta = 8'd24;
  		  	default:pc_delta = 8'd0;
  		  endcase
  		`state_dec:  
  		  if(dec_state == `dec_state_dc)begin
  		  	case(dc_state)
  		  		`dc_state_comp:  pc_delta = dc_word_eq ? {3'b0,dc_size_i} : 8'd0;
  		  		`dc_state_valu:  pc_delta = dc_value;
  		  		default:pc_delta = 8'd0;
  		  	endcase
  		  end else if(dec_state == `dec_state_ac)begin
  		  	case(ac_state)
  		  		`ac_state_comp:  pc_delta = ac_word_eq ? {3'b0,ac_size_i} : 8'd0;
  		  		`ac_state_valu:  pc_delta = {4'b0,ac_value[3:0]};
  		  		default:pc_delta = 8'd0;
  		  	endcase
  		  end else
  		    pc_delta = 8'd0;
  		`state_eoi:  pc_delta = eoi_find ? 8'd16 : 8'd1;     
  		default:  pc_delta = 8'd0;
  	endcase
  end else 
    pc_delta = 8'd0;



endmodule