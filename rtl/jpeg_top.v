module jpeg_top( 
   clk, rst, 
   ai_we, ai_data, ao_next,
   bi_next, bo_we, bo_begin, bo_end, bo_data, bo_type
   
);

input clk,rst;
input ai_we;
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
wire bo_we;
wire [7:0] bo_r,bo_g,bo_b;
wire [7:0] bo_adr;


    jpeg_dec jpeg_dec(
        .clk(clk),
        .rst(rst),
        .ai_we     ( ai_we ),
        .ao_next   ( ao_next ),
        .ai_data   ( ai_data ),

        .width(width),
        .heigth(heigth),
        .pic_is_411(pic_is_411),

        .mcu_w(mcu_w),
        .mcu_h(mcu_h),
        .res_avali(res_avali),
        
        .x_mcu_o(x_mcu_o),
        .y_mcu_o(y_mcu_o),

        .bo_we    ( bo_we ),
        .bi_next  ( bi_next ),
        .bo_r     ( bo_r ),
        .bo_g     ( bo_g ),
        .bo_b     ( bo_b ),
        .bo_adr   ( bo_adr )
    );

assign bo_begin = bo_we & x_mcu_o == 0 & y_mcu_o == 0 & bo_adr == 0;
assign bo_end   = bo_we & x_mcu_o == mcu_w - 13'd1 & y_mcu_o == mcu_h - 13'd1 & 
                 ((bo_adr == 8'd255 & pic_is_411) | (bo_adr == 8'd63 & !pic_is_411));
assign bo_data = {bo_r,bo_g,bo_b,8'b0};
assign bo_type = pic_is_411;


endmodule