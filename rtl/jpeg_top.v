`include "timescale.v"
`include "jpeg_defines.v"

module jpeg_top( 
   clk, rst, 
   ai_we, ai_begin, ai_end, ai_data, ao_next,
   bi_next, bo_we, bo_begin, bo_end, bo_data, 
   
   bo_type
   
   
);

input clk,rst;
input ai_we;
input ai_begin;
input ai_end;
input [7:0] ai_data;
output ao_next;

input bi_next;
output bo_we;
output bo_begin;
output bo_end;
output [31:0] bo_data;

output bo_type;

wire [15:0] width,heigth;
wire [12:0] mcu_w,mcu_h;
wire res_avali;


wire [12:0] x_mcu_o,y_mcu_o;
wire [7:0] rgb_i;
wire [7:0] r,g,b;

wire pic_end;

jpeg_dec jpeg_dec(
  .clk(clk),.rst(rst),
  .din(ai_data),.we(ai_we),.next(ao_next),
  .width(width),.heigth(heigth),.pic_is_411(pic_is_411),
  .mcu_w(mcu_w),.mcu_h(mcu_h),
  .res_avali(res_avali),
  
  .rd(bi_next),.ready(bo_we),
  .x_mcu_o(x_mcu_o),.y_mcu_o(y_mcu_o),
  .rgb_i(rgb_i),.r(r),.g(g),.b(b),

  .pic_end(pic_end)
);

assign bo_begin = bo_we & x_mcu_o == 0 & y_mcu_o == 0 & rgb_i == 0;
assign bo_end   = bo_we & x_mcu_o == mcu_w - 13'd1 & y_mcu_o == mcu_h - 13'd1 & 
                 ((rgb_i == 8'd255 & pic_is_411) | (rgb_i == 8'd63 & !pic_is_411));
assign bo_data = {r,g,b,8'b0};
assign bo_type = pic_is_411;


endmodule