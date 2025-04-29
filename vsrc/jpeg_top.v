//-----------------------------------------------
// output sequence:
//-----------------------------------------------
// adr in mcu(16x16):  
//    +----+----+----+----+---------+
//    | a0 | a1 | a2 | a3 | ... a15 | 
//    +----+----+----+----+---------+
//    |a16 |a17 | ......            
//    +----+----+
//    
// mcu in picture eg. 80x80
//    +----+----+----+-----------+
//    | m0 | m1 | m2 | ...    m4 |
//    +----+----+----+-----------+
//    | m5 | ...... 
//    +----+
// 
// sequence:
//   m0a0,  m0a1, ... m0a255, m1a0, ... mxa255
//-----------------------------------------------
module jpeg_top(
    input           ai_we,      // input data write enable
    input  [7:0]    ai_data,    // input data
    output          ao_next,    // request for next input data

    output          bo_we,      // output enable
    output          bo_begin,   // first pix of a mcu
    output          bo_end,     // last pix of a mcu
	output [7:0]    bo_r,       // output red
	output [7:0]    bo_g,       // output green
	output [7:0]    bo_b,       // output blue
	output [7:0]    bo_adr,     // pixel address in one mcu
    output [12:0]   bo_x_mcu,   // mcu x coordinate
    output [12:0]   bo_y_mcu,   // mcu y coordinate
	input           bi_next,    // next data request

    output          co_en,      // config output enable
	output          co_411,     // 411 format or not
	output [15:0]   co_width,   // picture width
	output [15:0]   co_heigth,  // picture heigth
	output [12:0]   co_mcu_w,   // mcu count in width         
	output [12:0]   co_mcu_h,   // mcu count in heigth                

    input clk,
    input rst
);

    wire [3:0] state;
    wire [2:0] dqt_state;
    wire [2:0] sof_state;
    wire [3:0] dht_state;
    wire       dht_cal_state;
    wire [1:0] sos_state;
    wire [2:0] dec_state;
    wire [1:0] dc_state;
    wire [1:0] ac_state;
    wire [1:0] dq_state;
    wire [1:0] idct1_state;
    wire [1:0] idct2_state;
    wire [1:0] rgb_state;

    wire soi_find;
    wire sof_find;
    wire dqt_find;
    wire dht_find;
    wire sos_find;
    wire eoi_find;

    wire dqt_end;
    wire dqt_item_end;
    wire dht_end;
    wire dht_item_end;
    wire dht_cal_end;
    wire dht_loop_end;

    wire dc_word_eq;
    wire ac_word_eq;
    wire ac_all_zero;
    wire [7:0] ac_i;
    wire [3:0] i_in_mcu;
    wire [3:0] i_in_mcu_i2;

    wire [4:0] dc_size_i;
    wire [4:0] ac_size_i;
    wire [7:0] dc_value;
    wire [7:0] ac_value;

    wire dq_eat;

    wire [1:0] sof_y_qt,sof_cr_qt,sof_cb_qt;

    wire [23:0] qt_out_00,qt_out_01,qt_out_02,qt_out_03,qt_out_04,qt_out_05,qt_out_06,qt_out_07;
    wire [23:0] qt_out_10,qt_out_11,qt_out_12,qt_out_13,qt_out_14,qt_out_15,qt_out_16,qt_out_17;
    wire [23:0] qt_out_20,qt_out_21,qt_out_22,qt_out_23,qt_out_24,qt_out_25,qt_out_26,qt_out_27;
    wire [23:0] qt_out_30,qt_out_31,qt_out_32,qt_out_33,qt_out_34,qt_out_35,qt_out_36,qt_out_37;
    wire [23:0] qt_out_40,qt_out_41,qt_out_42,qt_out_43,qt_out_44,qt_out_45,qt_out_46,qt_out_47;
    wire [23:0] qt_out_50,qt_out_51,qt_out_52,qt_out_53,qt_out_54,qt_out_55,qt_out_56,qt_out_57;
    wire [23:0] qt_out_60,qt_out_61,qt_out_62,qt_out_63,qt_out_64,qt_out_65,qt_out_66,qt_out_67;
    wire [23:0] qt_out_70,qt_out_71,qt_out_72,qt_out_73,qt_out_74,qt_out_75,qt_out_76,qt_out_77;


    wire [15:0] out_00,out_01,out_02,out_03,out_04,out_05,out_06,out_07;
    wire [15:0] out_10,out_11,out_12,out_13,out_14,out_15,out_16,out_17;
    wire [15:0] out_20,out_21,out_22,out_23,out_24,out_25,out_26,out_27;
    wire [15:0] out_30,out_31,out_32,out_33,out_34,out_35,out_36,out_37;
    wire [15:0] out_40,out_41,out_42,out_43,out_44,out_45,out_46,out_47;
    wire [15:0] out_50,out_51,out_52,out_53,out_54,out_55,out_56,out_57;
    wire [15:0] out_60,out_61,out_62,out_63,out_64,out_65,out_66,out_67;
    wire [15:0] out_70,out_71,out_72,out_73,out_74,out_75,out_76,out_77;

    wire out_empty;
    wire [12:0] x_mcu_rgb,y_mcu_rgb;

    wire [7:0]  pc_delta;
    wire [63:0] bit_out;
    wire        bit_avali;
    jpeg_stream jpeg_stream(
        .ai_we     ( ai_we ),
        .ao_next   ( ao_next ),
        .ai_data   ( ai_data ),

        .bit_avali ( bit_avali ),
        .bit_out   ( bit_out ),
        .bit_eaten ( pc_delta[6:0] ),

        .clk(clk),
        .rst(rst)
    );

    jpeg_fsm jpeg_fsm(
        .bit_avali(bit_avali),
        .bit_out(bit_out),
        .state(state),
        .dqt_state(dqt_state),
        .sof_state(sof_state),
        .dht_state(dht_state),
        .dht_cal_state(dht_cal_state),
        .sos_state(sos_state),
        .dec_state(dec_state),
        .dc_state(dc_state),
        .ac_state(ac_state),
        .dq_state(dq_state),
        .idct1_state(idct1_state),
        .idct2_state(idct2_state),
        .rgb_state(rgb_state),

        .width(co_width),
        .heigth(co_heigth),
        .pic_is_411(co_411),
        .soi_find(soi_find),.sof_find(sof_find),.dqt_find(dqt_find),
        .dht_find(dht_find),.sos_find(sos_find),.eoi_find(eoi_find),
        .dqt_end(dqt_end),.dqt_item_end(dqt_item_end),.dht_loop_end(dht_loop_end),
        .dht_end(dht_end),.dht_item_end(dht_item_end),.dht_cal_end(dht_cal_end),
        .dc_word_eq(dc_word_eq),
        .ac_word_eq(ac_word_eq),
        .ac_all_zero(ac_all_zero),
        .ac_i(ac_i),
        .i_in_mcu(i_in_mcu),
        .i_in_mcu_i2(i_in_mcu_i2),
        .dq_eat(dq_eat),
        .mcu_w(co_mcu_w),
        .mcu_h(co_mcu_h),
        .x_mcu_rgb(x_mcu_rgb),
        .y_mcu_rgb(y_mcu_rgb),
        .out_empty(out_empty),

        .clk(clk),
        .rst(rst)
    );

    jpeg_pc jpeg_pc(
        .state(state),
        .dqt_state(dqt_state),
        .sof_state(sof_state),
        .dht_state(dht_state),
        .sos_state(sos_state),
        .dec_state(dec_state),
        .dc_state(dc_state),
        .ac_state(ac_state),
        .bit_avali(bit_avali),
        .soi_find(soi_find),.dqt_find(dqt_find),.sof_find(sof_find),
        .dht_find(dht_find),.sos_find(sos_find),.eoi_find(eoi_find),
        .dqt_end(dqt_end),.dht_end(dht_end),
        .dc_word_eq(dc_word_eq),.ac_word_eq(ac_word_eq),
        .dc_size_i(dc_size_i),.ac_size_i(ac_size_i),
        .dc_value(dc_value),.ac_value(ac_value),
        
        .pc_delta(pc_delta),

        .clk(clk),
        .rst(rst)
    );


    jpeg_sof jpeg_sof(
        .bit_avali(bit_avali),
        .bit_out(bit_out),
        .state(state),
        .sof_state(sof_state),

        .sof_y_qt(sof_y_qt),
        .sof_cr_qt(sof_cr_qt),
        .sof_cb_qt(sof_cb_qt),

        .co_en     ( co_en ),
	    .co_411    ( co_411 ),
	    .co_width  ( co_width ),
	    .co_heigth ( co_heigth ),
	    .co_mcu_w  ( co_mcu_w ),           
	    .co_mcu_h  ( co_mcu_h ),        

        .clk(clk),
        .rst(rst)
    );

    jpeg_htqt jpeg_htqt(
        .bit_avali(bit_avali),.bit_out(bit_out),
        .dht_state(dht_state),.dht_cal_state(dht_cal_state),
        .dec_state(dec_state),.dc_state(dc_state),.ac_state(ac_state),
        .dqt_state(dqt_state),.dq_state(dq_state),.state(state),
        .dqt_item_end(dqt_item_end),.dqt_end(dqt_end),.dht_loop_end(dht_loop_end),
        .dht_find(dht_find),.dht_end(dht_end),.dht_item_end(dht_item_end),.dht_cal_end(dht_cal_end),
        .dc_word_eq(dc_word_eq),.ac_word_eq(ac_word_eq),
        .dc_size_i(dc_size_i),.ac_size_i(ac_size_i),
        .dc_value(dc_value),.ac_value(ac_value),.pic_is_411(co_411),
        .ac_all_zero(ac_all_zero),.ac_i(ac_i),.i_in_mcu(i_in_mcu),
        .sof_y_qt(sof_y_qt),.sof_cr_qt(sof_cr_qt),.sof_cb_qt(sof_cb_qt),
        .dq_eat(dq_eat),
        .qt_out_00(qt_out_00),.qt_out_01(qt_out_01),.qt_out_02(qt_out_02),.qt_out_03(qt_out_03),
        .qt_out_04(qt_out_04),.qt_out_05(qt_out_05),.qt_out_06(qt_out_06),.qt_out_07(qt_out_07),
        .qt_out_10(qt_out_10),.qt_out_11(qt_out_11),.qt_out_12(qt_out_12),.qt_out_13(qt_out_13),
        .qt_out_14(qt_out_14),.qt_out_15(qt_out_15),.qt_out_16(qt_out_16),.qt_out_17(qt_out_17),
        .qt_out_20(qt_out_20),.qt_out_21(qt_out_21),.qt_out_22(qt_out_22),.qt_out_23(qt_out_23),
        .qt_out_24(qt_out_24),.qt_out_25(qt_out_25),.qt_out_26(qt_out_26),.qt_out_27(qt_out_27),
        .qt_out_30(qt_out_30),.qt_out_31(qt_out_31),.qt_out_32(qt_out_32),.qt_out_33(qt_out_33),
        .qt_out_34(qt_out_34),.qt_out_35(qt_out_35),.qt_out_36(qt_out_36),.qt_out_37(qt_out_37),
        .qt_out_40(qt_out_40),.qt_out_41(qt_out_41),.qt_out_42(qt_out_42),.qt_out_43(qt_out_43),
        .qt_out_44(qt_out_44),.qt_out_45(qt_out_45),.qt_out_46(qt_out_46),.qt_out_47(qt_out_47),
        .qt_out_50(qt_out_50),.qt_out_51(qt_out_51),.qt_out_52(qt_out_52),.qt_out_53(qt_out_53),
        .qt_out_54(qt_out_54),.qt_out_55(qt_out_55),.qt_out_56(qt_out_56),.qt_out_57(qt_out_57),
        .qt_out_60(qt_out_60),.qt_out_61(qt_out_61),.qt_out_62(qt_out_62),.qt_out_63(qt_out_63),
        .qt_out_64(qt_out_64),.qt_out_65(qt_out_65),.qt_out_66(qt_out_66),.qt_out_67(qt_out_67),
        .qt_out_70(qt_out_70),.qt_out_71(qt_out_71),.qt_out_72(qt_out_72),.qt_out_73(qt_out_73),
        .qt_out_74(qt_out_74),.qt_out_75(qt_out_75),.qt_out_76(qt_out_76),.qt_out_77(qt_out_77),
        .clk(clk),
        .rst(rst)
    );

    jpeg_sos jpeg_sos(
        .bit_avali(bit_avali),
        .bit_out(bit_out),
        .state(state),
        .sos_state(sos_state),
        .clk(clk),
        .rst(rst)
    );

    jpeg_idct jpeg_idct(
        
        .dq_state(dq_state),.idct1_state(idct1_state),.idct2_state(idct2_state),
        .qt_out_00(qt_out_00),.qt_out_01(qt_out_01),.qt_out_02(qt_out_02),.qt_out_03(qt_out_03),
        .qt_out_04(qt_out_04),.qt_out_05(qt_out_05),.qt_out_06(qt_out_06),.qt_out_07(qt_out_07),
        .qt_out_10(qt_out_10),.qt_out_11(qt_out_11),.qt_out_12(qt_out_12),.qt_out_13(qt_out_13),
        .qt_out_14(qt_out_14),.qt_out_15(qt_out_15),.qt_out_16(qt_out_16),.qt_out_17(qt_out_17),
        .qt_out_20(qt_out_20),.qt_out_21(qt_out_21),.qt_out_22(qt_out_22),.qt_out_23(qt_out_23),
        .qt_out_24(qt_out_24),.qt_out_25(qt_out_25),.qt_out_26(qt_out_26),.qt_out_27(qt_out_27),
        .qt_out_30(qt_out_30),.qt_out_31(qt_out_31),.qt_out_32(qt_out_32),.qt_out_33(qt_out_33),
        .qt_out_34(qt_out_34),.qt_out_35(qt_out_35),.qt_out_36(qt_out_36),.qt_out_37(qt_out_37),
        .qt_out_40(qt_out_40),.qt_out_41(qt_out_41),.qt_out_42(qt_out_42),.qt_out_43(qt_out_43),
        .qt_out_44(qt_out_44),.qt_out_45(qt_out_45),.qt_out_46(qt_out_46),.qt_out_47(qt_out_47),
        .qt_out_50(qt_out_50),.qt_out_51(qt_out_51),.qt_out_52(qt_out_52),.qt_out_53(qt_out_53),
        .qt_out_54(qt_out_54),.qt_out_55(qt_out_55),.qt_out_56(qt_out_56),.qt_out_57(qt_out_57),
        .qt_out_60(qt_out_60),.qt_out_61(qt_out_61),.qt_out_62(qt_out_62),.qt_out_63(qt_out_63),
        .qt_out_64(qt_out_64),.qt_out_65(qt_out_65),.qt_out_66(qt_out_66),.qt_out_67(qt_out_67),
        .qt_out_70(qt_out_70),.qt_out_71(qt_out_71),.qt_out_72(qt_out_72),.qt_out_73(qt_out_73),
        .qt_out_74(qt_out_74),.qt_out_75(qt_out_75),.qt_out_76(qt_out_76),.qt_out_77(qt_out_77),
        
        .out_00(out_00),.out_01(out_01),.out_02(out_02),.out_03(out_03),
        .out_04(out_04),.out_05(out_05),.out_06(out_06),.out_07(out_07),
        .out_10(out_10),.out_11(out_11),.out_12(out_12),.out_13(out_13),
        .out_14(out_14),.out_15(out_15),.out_16(out_16),.out_17(out_17),
        .out_20(out_20),.out_21(out_21),.out_22(out_22),.out_23(out_23),
        .out_24(out_24),.out_25(out_25),.out_26(out_26),.out_27(out_27),
        .out_30(out_30),.out_31(out_31),.out_32(out_32),.out_33(out_33),
        .out_34(out_34),.out_35(out_35),.out_36(out_36),.out_37(out_37),
        .out_40(out_40),.out_41(out_41),.out_42(out_42),.out_43(out_43),
        .out_44(out_44),.out_45(out_45),.out_46(out_46),.out_47(out_47),
        .out_50(out_50),.out_51(out_51),.out_52(out_52),.out_53(out_53),
        .out_54(out_54),.out_55(out_55),.out_56(out_56),.out_57(out_57),
        .out_60(out_60),.out_61(out_61),.out_62(out_62),.out_63(out_63),
        .out_64(out_64),.out_65(out_65),.out_66(out_66),.out_67(out_67),
        .out_70(out_70),.out_71(out_71),.out_72(out_72),.out_73(out_73),
        .out_74(out_74),.out_75(out_75),.out_76(out_76),.out_77(out_77),

        .clk(clk),
        .rst(rst)
    );

    jpeg_rgb jpeg_rgb(
        .state(state),
        .idct2_state(idct2_state),
        .rgb_state(rgb_state),
        .pic_is_411(co_411),
        .i_in_mcu_i2(i_in_mcu_i2),
        .x_mcu_rgb(x_mcu_rgb),
        .y_mcu_rgb(y_mcu_rgb),
        .mcu_w(co_mcu_w),
        .mcu_h(co_mcu_h),
        
        .out_00(out_00),.out_01(out_01),.out_02(out_02),.out_03(out_03),
        .out_04(out_04),.out_05(out_05),.out_06(out_06),.out_07(out_07),
        .out_10(out_10),.out_11(out_11),.out_12(out_12),.out_13(out_13),
        .out_14(out_14),.out_15(out_15),.out_16(out_16),.out_17(out_17),
        .out_20(out_20),.out_21(out_21),.out_22(out_22),.out_23(out_23),
        .out_24(out_24),.out_25(out_25),.out_26(out_26),.out_27(out_27),
        .out_30(out_30),.out_31(out_31),.out_32(out_32),.out_33(out_33),
        .out_34(out_34),.out_35(out_35),.out_36(out_36),.out_37(out_37),
        .out_40(out_40),.out_41(out_41),.out_42(out_42),.out_43(out_43),
        .out_44(out_44),.out_45(out_45),.out_46(out_46),.out_47(out_47),
        .out_50(out_50),.out_51(out_51),.out_52(out_52),.out_53(out_53),
        .out_54(out_54),.out_55(out_55),.out_56(out_56),.out_57(out_57),
        .out_60(out_60),.out_61(out_61),.out_62(out_62),.out_63(out_63),
        .out_64(out_64),.out_65(out_65),.out_66(out_66),.out_67(out_67),
        .out_70(out_70),.out_71(out_71),.out_72(out_72),.out_73(out_73),
        .out_74(out_74),.out_75(out_75),.out_76(out_76),.out_77(out_77),
  
        .out_empty(out_empty),

        .bo_we    ( bo_we ),
        .bi_next  ( bi_next ),
        .bo_begin ( bo_begin ),
        .bo_end   ( bo_end ),
        .bo_r     ( bo_r ),
        .bo_g     ( bo_g ),
        .bo_b     ( bo_b ),
        .bo_x_mcu ( bo_x_mcu ),
        .bo_y_mcu ( bo_y_mcu ),
        .bo_adr   ( bo_adr ),

        .clk(clk),
        .rst(rst)
    );



endmodule