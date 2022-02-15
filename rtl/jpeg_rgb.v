`include "timescale.v"
`include "jpeg_defines.v"

module jpeg_rgb(
input clk,rst,
input rd,

input [3:0] state,
input [1:0] idct2_state,
input [1:0] rgb_state,
input [1:0] out_state,


input pic_is_411,
input [3:0] i_in_mcu_i2,


input [15:0] out_00,out_01,out_02,out_03,out_04,out_05,out_06,out_07,
input [15:0] out_10,out_11,out_12,out_13,out_14,out_15,out_16,out_17,
input [15:0] out_20,out_21,out_22,out_23,out_24,out_25,out_26,out_27,
input [15:0] out_30,out_31,out_32,out_33,out_34,out_35,out_36,out_37,
input [15:0] out_40,out_41,out_42,out_43,out_44,out_45,out_46,out_47,
input [15:0] out_50,out_51,out_52,out_53,out_54,out_55,out_56,out_57,
input [15:0] out_60,out_61,out_62,out_63,out_64,out_65,out_66,out_67,
input [15:0] out_70,out_71,out_72,out_73,out_74,out_75,out_76,out_77,


output fifo_full,
output out_end,
output last_one,

output [7:0] rgb_i,
output reg [7:0] r,g,b,

input [12:0] x_mcu_rgb,y_mcu_rgb,
output reg [12:0] x_mcu_o,y_mcu_o,

output reg full_0,full_1

);


reg [15:0] y0 [255:0];
reg [15:0] y1 [255:0];

reg [15:0] cr0 [63:0];
reg [15:0] cr1 [63:0];

reg [15:0] cb0 [63:0];
reg [15:0] cb1 [63:0];

reg pp_rgb;

always@(posedge clk)
  if(rst)
    pp_rgb <= 0;
  else if(state == `state_rst)
    pp_rgb <= 0;
  else if(rgb_state == `rgb_state_wait & out_end)  
    pp_rgb <= ~pp_rgb;

always@(posedge clk)begin
  if(rgb_state == `rgb_state_idle & idct2_state == `idct2_state_wait & pp_rgb == 0)begin
  	if(pic_is_411)begin
  		case(i_in_mcu_i2)
  			0:begin
  				y0[0] <= out_00; y0[1] <= out_01; y0[2] <= out_02; y0[3] <= out_03;
  				y0[4] <= out_04; y0[5] <= out_05; y0[6] <= out_06; y0[7] <= out_07;
  				y0[16] <= out_10; y0[17] <= out_11; y0[18] <= out_12; y0[19] <= out_13;
  				y0[20] <= out_14; y0[21] <= out_15; y0[22] <= out_16; y0[23] <= out_17;
  				y0[32] <= out_20; y0[33] <= out_21; y0[34] <= out_22; y0[35] <= out_23;
  				y0[36] <= out_24; y0[37] <= out_25; y0[38] <= out_26; y0[39] <= out_27;
          y0[48] <= out_30; y0[49] <= out_31; y0[50] <= out_32; y0[51] <= out_33;
  				y0[52] <= out_34; y0[53] <= out_35; y0[54] <= out_36; y0[55] <= out_37;
  				y0[64] <= out_40; y0[65] <= out_41; y0[66] <= out_42; y0[67] <= out_43;
  				y0[68] <= out_44; y0[69] <= out_45; y0[70] <= out_46; y0[71] <= out_47;
  				y0[80] <= out_50; y0[81] <= out_51; y0[82] <= out_52; y0[83] <= out_53;
  				y0[84] <= out_54; y0[85] <= out_55; y0[86] <= out_56; y0[87] <= out_57;
  				y0[96] <= out_60; y0[97] <= out_61; y0[98] <= out_62; y0[99] <= out_63;
  				y0[100] <= out_64; y0[101] <= out_65; y0[102] <= out_66; y0[103] <= out_67;
  				y0[112] <= out_70; y0[113] <= out_71; y0[114] <= out_72; y0[115] <= out_73;
  				y0[116] <= out_74; y0[117] <= out_75; y0[118] <= out_76; y0[119] <= out_77;
  			end 
  			1:begin
  				y0[8] <= out_00; y0[9] <= out_01; y0[10] <= out_02; y0[11] <= out_03;
  				y0[12] <= out_04; y0[13] <= out_05; y0[14] <= out_06; y0[15] <= out_07;
  				y0[24] <= out_10; y0[25] <= out_11; y0[26] <= out_12; y0[27] <= out_13;
  				y0[28] <= out_14; y0[29] <= out_15; y0[30] <= out_16; y0[31] <= out_17;
  				y0[40] <= out_20; y0[41] <= out_21; y0[42] <= out_22; y0[43] <= out_23;
  				y0[44] <= out_24; y0[45] <= out_25; y0[46] <= out_26; y0[47] <= out_27;
          y0[56] <= out_30; y0[57] <= out_31; y0[58] <= out_32; y0[59] <= out_33;
  				y0[60] <= out_34; y0[61] <= out_35; y0[62] <= out_36; y0[63] <= out_37;
  				y0[72] <= out_40; y0[73] <= out_41; y0[74] <= out_42; y0[75] <= out_43;
  				y0[76] <= out_44; y0[77] <= out_45; y0[78] <= out_46; y0[79] <= out_47;
  				y0[88] <= out_50; y0[89] <= out_51; y0[90] <= out_52; y0[91] <= out_53;
  				y0[92] <= out_54; y0[93] <= out_55; y0[94] <= out_56; y0[95] <= out_57;
  				y0[104] <= out_60; y0[105] <= out_61; y0[106] <= out_62; y0[107] <= out_63;
  				y0[108] <= out_64; y0[109] <= out_65; y0[110] <= out_66; y0[111] <= out_67;
  				y0[120] <= out_70; y0[121] <= out_71; y0[122] <= out_72; y0[123] <= out_73;
  				y0[124] <= out_74; y0[125] <= out_75; y0[126] <= out_76; y0[127] <= out_77;
  			end 
  			2:begin
  				y0[128] <= out_00; y0[129] <= out_01; y0[130] <= out_02; y0[131] <= out_03;
  				y0[132] <= out_04; y0[133] <= out_05; y0[134] <= out_06; y0[135] <= out_07;
  				y0[144] <= out_10; y0[145] <= out_11; y0[146] <= out_12; y0[147] <= out_13;
  				y0[148] <= out_14; y0[149] <= out_15; y0[150] <= out_16; y0[151] <= out_17;
  				y0[160] <= out_20; y0[161] <= out_21; y0[162] <= out_22; y0[163] <= out_23;
  				y0[164] <= out_24; y0[165] <= out_25; y0[166] <= out_26; y0[167] <= out_27;
          y0[176] <= out_30; y0[177] <= out_31; y0[178] <= out_32; y0[179] <= out_33;
  				y0[180] <= out_34; y0[181] <= out_35; y0[182] <= out_36; y0[183] <= out_37;
  				y0[192] <= out_40; y0[193] <= out_41; y0[194] <= out_42; y0[195] <= out_43;
  				y0[196] <= out_44; y0[197] <= out_45; y0[198] <= out_46; y0[199] <= out_47;
  				y0[208] <= out_50; y0[209] <= out_51; y0[210] <= out_52; y0[211] <= out_53;
  				y0[212] <= out_54; y0[213] <= out_55; y0[214] <= out_56; y0[215] <= out_57;
  				y0[224] <= out_60; y0[225] <= out_61; y0[226] <= out_62; y0[227] <= out_63;
  				y0[228] <= out_64; y0[229] <= out_65; y0[230] <= out_66; y0[231] <= out_67;
  				y0[240] <= out_70; y0[241] <= out_71; y0[242] <= out_72; y0[243] <= out_73;
  				y0[244] <= out_74; y0[245] <= out_75; y0[246] <= out_76; y0[247] <= out_77;
  			end 
  			3:begin
  				y0[136] <= out_00; y0[137] <= out_01; y0[138] <= out_02; y0[139] <= out_03;
  				y0[140] <= out_04; y0[141] <= out_05; y0[142] <= out_06; y0[143] <= out_07;
  				y0[152] <= out_10; y0[153] <= out_11; y0[154] <= out_12; y0[155] <= out_13;
  				y0[156] <= out_14; y0[157] <= out_15; y0[158] <= out_16; y0[159] <= out_17;
  				y0[168] <= out_20; y0[169] <= out_21; y0[170] <= out_22; y0[171] <= out_23;
  				y0[172] <= out_24; y0[173] <= out_25; y0[174] <= out_26; y0[175] <= out_27;
          y0[184] <= out_30; y0[185] <= out_31; y0[186] <= out_32; y0[187] <= out_33;
  				y0[188] <= out_34; y0[189] <= out_35; y0[190] <= out_36; y0[191] <= out_37;
  				y0[200] <= out_40; y0[201] <= out_41; y0[202] <= out_42; y0[203] <= out_43;
  				y0[204] <= out_44; y0[205] <= out_45; y0[206] <= out_46; y0[207] <= out_47;
  				y0[216] <= out_50; y0[217] <= out_51; y0[218] <= out_52; y0[219] <= out_53;
  				y0[220] <= out_54; y0[221] <= out_55; y0[222] <= out_56; y0[223] <= out_57;
  				y0[232] <= out_60; y0[233] <= out_61; y0[234] <= out_62; y0[235] <= out_63;
  				y0[236] <= out_64; y0[237] <= out_65; y0[238] <= out_66; y0[239] <= out_67;
  				y0[248] <= out_70; y0[249] <= out_71; y0[250] <= out_72; y0[251] <= out_73;
  				y0[252] <= out_74; y0[253] <= out_75; y0[254] <= out_76; y0[255] <= out_77;
  			end 
  			4:begin
  				cr0[0] <= out_00; cr0[1] <= out_01; cr0[2] <= out_02; cr0[3] <= out_03;
  				cr0[4] <= out_04; cr0[5] <= out_05; cr0[6] <= out_06; cr0[7] <= out_07;
  				cr0[8] <= out_10; cr0[9] <= out_11; cr0[10] <= out_12; cr0[11] <= out_13;
  				cr0[12] <= out_14; cr0[13] <= out_15; cr0[14] <= out_16; cr0[15] <= out_17;
  				cr0[16] <= out_20; cr0[17] <= out_21; cr0[18] <= out_22; cr0[19] <= out_23;
  				cr0[20] <= out_24; cr0[21] <= out_25; cr0[22] <= out_26; cr0[23] <= out_27;
          cr0[24] <= out_30; cr0[25] <= out_31; cr0[26] <= out_32; cr0[27] <= out_33;
  				cr0[28] <= out_34; cr0[29] <= out_35; cr0[30] <= out_36; cr0[31] <= out_37;
  				cr0[32] <= out_40; cr0[33] <= out_41; cr0[34] <= out_42; cr0[35] <= out_43;
  				cr0[36] <= out_44; cr0[37] <= out_45; cr0[38] <= out_46; cr0[39] <= out_47;
  				cr0[40] <= out_50; cr0[41] <= out_51; cr0[42] <= out_52; cr0[43] <= out_53;
  				cr0[44] <= out_54; cr0[45] <= out_55; cr0[46] <= out_56; cr0[47] <= out_57;
  				cr0[48] <= out_60; cr0[49] <= out_61; cr0[50] <= out_62; cr0[51] <= out_63;
  				cr0[52] <= out_64; cr0[53] <= out_65; cr0[54] <= out_66; cr0[55] <= out_67;
  				cr0[56] <= out_70; cr0[57] <= out_71; cr0[58] <= out_72; cr0[59] <= out_73;
  				cr0[60] <= out_74; cr0[61] <= out_75; cr0[62] <= out_76; cr0[63] <= out_77;
  				
  			end 
  			5:begin
  				cb0[0] <= out_00; cb0[1] <= out_01; cb0[2] <= out_02; cb0[3] <= out_03;
  				cb0[4] <= out_04; cb0[5] <= out_05; cb0[6] <= out_06; cb0[7] <= out_07;
  				cb0[8] <= out_10; cb0[9] <= out_11; cb0[10] <= out_12; cb0[11] <= out_13;
  				cb0[12] <= out_14; cb0[13] <= out_15; cb0[14] <= out_16; cb0[15] <= out_17;
  				cb0[16] <= out_20; cb0[17] <= out_21; cb0[18] <= out_22; cb0[19] <= out_23;
  				cb0[20] <= out_24; cb0[21] <= out_25; cb0[22] <= out_26; cb0[23] <= out_27;
          cb0[24] <= out_30; cb0[25] <= out_31; cb0[26] <= out_32; cb0[27] <= out_33;
  				cb0[28] <= out_34; cb0[29] <= out_35; cb0[30] <= out_36; cb0[31] <= out_37;
  				cb0[32] <= out_40; cb0[33] <= out_41; cb0[34] <= out_42; cb0[35] <= out_43;
  				cb0[36] <= out_44; cb0[37] <= out_45; cb0[38] <= out_46; cb0[39] <= out_47;
  				cb0[40] <= out_50; cb0[41] <= out_51; cb0[42] <= out_52; cb0[43] <= out_53;
  				cb0[44] <= out_54; cb0[45] <= out_55; cb0[46] <= out_56; cb0[47] <= out_57;
  				cb0[48] <= out_60; cb0[49] <= out_61; cb0[50] <= out_62; cb0[51] <= out_63;
  				cb0[52] <= out_64; cb0[53] <= out_65; cb0[54] <= out_66; cb0[55] <= out_67;
  				cb0[56] <= out_70; cb0[57] <= out_71; cb0[58] <= out_72; cb0[59] <= out_73;
  				cb0[60] <= out_74; cb0[61] <= out_75; cb0[62] <= out_76; cb0[63] <= out_77;
  			end 
  			default:;
  		endcase
  	end else begin
  		if(i_in_mcu_i2 == 0)begin
  			y0[0] <= out_00; y0[1] <= out_01; y0[2] <= out_02; y0[3] <= out_03;
  		  y0[4] <= out_04; y0[5] <= out_05; y0[6] <= out_06; y0[7] <= out_07;
  			y0[8] <= out_10; y0[9] <= out_11; y0[10] <= out_12; y0[11] <= out_13;
  			y0[12] <= out_14; y0[13] <= out_15; y0[14] <= out_16; y0[15] <= out_17;
  			y0[16] <= out_20; y0[17] <= out_21; y0[18] <= out_22; y0[19] <= out_23;
  			y0[20] <= out_24; y0[21] <= out_25; y0[22] <= out_26; y0[23] <= out_27;
        y0[24] <= out_30; y0[25] <= out_31; y0[26] <= out_32; y0[27] <= out_33;
  			y0[28] <= out_34; y0[29] <= out_35; y0[30] <= out_36; y0[31] <= out_37;
  			y0[32] <= out_40; y0[33] <= out_41; y0[34] <= out_42; y0[35] <= out_43;
  			y0[36] <= out_44; y0[37] <= out_45; y0[38] <= out_46; y0[39] <= out_47;
  			y0[40] <= out_50; y0[41] <= out_51; y0[42] <= out_52; y0[43] <= out_53;
  			y0[44] <= out_54; y0[45] <= out_55; y0[46] <= out_56; y0[47] <= out_57;
  			y0[48] <= out_60; y0[49] <= out_61; y0[50] <= out_62; y0[51] <= out_63;
  			y0[52] <= out_64; y0[53] <= out_65; y0[54] <= out_66; y0[55] <= out_67;
  			y0[56] <= out_70; y0[57] <= out_71; y0[58] <= out_72; y0[59] <= out_73;
  			y0[60] <= out_74; y0[61] <= out_75; y0[62] <= out_76; y0[63] <= out_77;
  		end else if(i_in_mcu_i2 == 1)begin
  			cr0[0] <= out_00; cr0[1] <= out_01; cr0[2] <= out_02; cr0[3] <= out_03;
  			cr0[4] <= out_04; cr0[5] <= out_05; cr0[6] <= out_06; cr0[7] <= out_07;
  			cr0[8] <= out_10; cr0[9] <= out_11; cr0[10] <= out_12; cr0[11] <= out_13;
  			cr0[12] <= out_14; cr0[13] <= out_15; cr0[14] <= out_16; cr0[15] <= out_17;
  			cr0[16] <= out_20; cr0[17] <= out_21; cr0[18] <= out_22; cr0[19] <= out_23;
  			cr0[20] <= out_24; cr0[21] <= out_25; cr0[22] <= out_26; cr0[23] <= out_27;
        cr0[24] <= out_30; cr0[25] <= out_31; cr0[26] <= out_32; cr0[27] <= out_33;
  			cr0[28] <= out_34; cr0[29] <= out_35; cr0[30] <= out_36; cr0[31] <= out_37;
  			cr0[32] <= out_40; cr0[33] <= out_41; cr0[34] <= out_42; cr0[35] <= out_43;
  			cr0[36] <= out_44; cr0[37] <= out_45; cr0[38] <= out_46; cr0[39] <= out_47;
  			cr0[40] <= out_50; cr0[41] <= out_51; cr0[42] <= out_52; cr0[43] <= out_53;
  			cr0[44] <= out_54; cr0[45] <= out_55; cr0[46] <= out_56; cr0[47] <= out_57;
  			cr0[48] <= out_60; cr0[49] <= out_61; cr0[50] <= out_62; cr0[51] <= out_63;
  			cr0[52] <= out_64; cr0[53] <= out_65; cr0[54] <= out_66; cr0[55] <= out_67;
  			cr0[56] <= out_70; cr0[57] <= out_71; cr0[58] <= out_72; cr0[59] <= out_73;
  			cr0[60] <= out_74; cr0[61] <= out_75; cr0[62] <= out_76; cr0[63] <= out_77;
  		end else begin
  			cb0[0] <= out_00; cb0[1] <= out_01; cb0[2] <= out_02; cb0[3] <= out_03;
  			cb0[4] <= out_04; cb0[5] <= out_05; cb0[6] <= out_06; cb0[7] <= out_07;
  			cb0[8] <= out_10; cb0[9] <= out_11; cb0[10] <= out_12; cb0[11] <= out_13;
  			cb0[12] <= out_14; cb0[13] <= out_15; cb0[14] <= out_16; cb0[15] <= out_17;
  			cb0[16] <= out_20; cb0[17] <= out_21; cb0[18] <= out_22; cb0[19] <= out_23;
  			cb0[20] <= out_24; cb0[21] <= out_25; cb0[22] <= out_26; cb0[23] <= out_27;
        cb0[24] <= out_30; cb0[25] <= out_31; cb0[26] <= out_32; cb0[27] <= out_33;
  			cb0[28] <= out_34; cb0[29] <= out_35; cb0[30] <= out_36; cb0[31] <= out_37;
  			cb0[32] <= out_40; cb0[33] <= out_41; cb0[34] <= out_42; cb0[35] <= out_43;
  			cb0[36] <= out_44; cb0[37] <= out_45; cb0[38] <= out_46; cb0[39] <= out_47;
  			cb0[40] <= out_50; cb0[41] <= out_51; cb0[42] <= out_52; cb0[43] <= out_53;
  			cb0[44] <= out_54; cb0[45] <= out_55; cb0[46] <= out_56; cb0[47] <= out_57;
  			cb0[48] <= out_60; cb0[49] <= out_61; cb0[50] <= out_62; cb0[51] <= out_63;
  			cb0[52] <= out_64; cb0[53] <= out_65; cb0[54] <= out_66; cb0[55] <= out_67;
  			cb0[56] <= out_70; cb0[57] <= out_71; cb0[58] <= out_72; cb0[59] <= out_73;
  			cb0[60] <= out_74; cb0[61] <= out_75; cb0[62] <= out_76; cb0[63] <= out_77;
  		end 
  		
  	end 
  end 
end 

always@(posedge clk)begin
  if(rgb_state == `rgb_state_idle & idct2_state == `idct2_state_wait & pp_rgb == 1)begin
  	if(pic_is_411)begin
  		case(i_in_mcu_i2)
  			0:begin
  				y1[0] <= out_00; y1[1] <= out_01; y1[2] <= out_02; y1[3] <= out_03;
  				y1[4] <= out_04; y1[5] <= out_05; y1[6] <= out_06; y1[7] <= out_07;
  				y1[16] <= out_10; y1[17] <= out_11; y1[18] <= out_12; y1[19] <= out_13;
  				y1[20] <= out_14; y1[21] <= out_15; y1[22] <= out_16; y1[23] <= out_17;
  				y1[32] <= out_20; y1[33] <= out_21; y1[34] <= out_22; y1[35] <= out_23;
  				y1[36] <= out_24; y1[37] <= out_25; y1[38] <= out_26; y1[39] <= out_27;
          y1[48] <= out_30; y1[49] <= out_31; y1[50] <= out_32; y1[51] <= out_33;
  				y1[52] <= out_34; y1[53] <= out_35; y1[54] <= out_36; y1[55] <= out_37;
  				y1[64] <= out_40; y1[65] <= out_41; y1[66] <= out_42; y1[67] <= out_43;
  				y1[68] <= out_44; y1[69] <= out_45; y1[70] <= out_46; y1[71] <= out_47;
  				y1[80] <= out_50; y1[81] <= out_51; y1[82] <= out_52; y1[83] <= out_53;
  				y1[84] <= out_54; y1[85] <= out_55; y1[86] <= out_56; y1[87] <= out_57;
  				y1[96] <= out_60; y1[97] <= out_61; y1[98] <= out_62; y1[99] <= out_63;
  				y1[100] <= out_64; y1[101] <= out_65; y1[102] <= out_66; y1[103] <= out_67;
  				y1[112] <= out_70; y1[113] <= out_71; y1[114] <= out_72; y1[115] <= out_73;
  				y1[116] <= out_74; y1[117] <= out_75; y1[118] <= out_76; y1[119] <= out_77;
  			end 
  			1:begin
  				y1[8] <= out_00; y1[9] <= out_01; y1[10] <= out_02; y1[11] <= out_03;
  				y1[12] <= out_04; y1[13] <= out_05; y1[14] <= out_06; y1[15] <= out_07;
  				y1[24] <= out_10; y1[25] <= out_11; y1[26] <= out_12; y1[27] <= out_13;
  				y1[28] <= out_14; y1[29] <= out_15; y1[30] <= out_16; y1[31] <= out_17;
  				y1[40] <= out_20; y1[41] <= out_21; y1[42] <= out_22; y1[43] <= out_23;
  				y1[44] <= out_24; y1[45] <= out_25; y1[46] <= out_26; y1[47] <= out_27;
          y1[56] <= out_30; y1[57] <= out_31; y1[58] <= out_32; y1[59] <= out_33;
  				y1[60] <= out_34; y1[61] <= out_35; y1[62] <= out_36; y1[63] <= out_37;
  				y1[72] <= out_40; y1[73] <= out_41; y1[74] <= out_42; y1[75] <= out_43;
  				y1[76] <= out_44; y1[77] <= out_45; y1[78] <= out_46; y1[79] <= out_47;
  				y1[88] <= out_50; y1[89] <= out_51; y1[90] <= out_52; y1[91] <= out_53;
  				y1[92] <= out_54; y1[93] <= out_55; y1[94] <= out_56; y1[95] <= out_57;
  				y1[104] <= out_60; y1[105] <= out_61; y1[106] <= out_62; y1[107] <= out_63;
  				y1[108] <= out_64; y1[109] <= out_65; y1[110] <= out_66; y1[111] <= out_67;
  				y1[120] <= out_70; y1[121] <= out_71; y1[122] <= out_72; y1[123] <= out_73;
  				y1[124] <= out_74; y1[125] <= out_75; y1[126] <= out_76; y1[127] <= out_77;
  			end 
  			2:begin
  				y1[128] <= out_00; y1[129] <= out_01; y1[130] <= out_02; y1[131] <= out_03;
  				y1[132] <= out_04; y1[133] <= out_05; y1[134] <= out_06; y1[135] <= out_07;
  				y1[144] <= out_10; y1[145] <= out_11; y1[146] <= out_12; y1[147] <= out_13;
  				y1[148] <= out_14; y1[149] <= out_15; y1[150] <= out_16; y1[151] <= out_17;
  				y1[160] <= out_20; y1[161] <= out_21; y1[162] <= out_22; y1[163] <= out_23;
  				y1[164] <= out_24; y1[165] <= out_25; y1[166] <= out_26; y1[167] <= out_27;
          y1[176] <= out_30; y1[177] <= out_31; y1[178] <= out_32; y1[179] <= out_33;
  				y1[180] <= out_34; y1[181] <= out_35; y1[182] <= out_36; y1[183] <= out_37;
  				y1[192] <= out_40; y1[193] <= out_41; y1[194] <= out_42; y1[195] <= out_43;
  				y1[196] <= out_44; y1[197] <= out_45; y1[198] <= out_46; y1[199] <= out_47;
  				y1[208] <= out_50; y1[209] <= out_51; y1[210] <= out_52; y1[211] <= out_53;
  				y1[212] <= out_54; y1[213] <= out_55; y1[214] <= out_56; y1[215] <= out_57;
  				y1[224] <= out_60; y1[225] <= out_61; y1[226] <= out_62; y1[227] <= out_63;
  				y1[228] <= out_64; y1[229] <= out_65; y1[230] <= out_66; y1[231] <= out_67;
  				y1[240] <= out_70; y1[241] <= out_71; y1[242] <= out_72; y1[243] <= out_73;
  				y1[244] <= out_74; y1[245] <= out_75; y1[246] <= out_76; y1[247] <= out_77;
  			end 
  			3:begin
  				y1[136] <= out_00; y1[137] <= out_01; y1[138] <= out_02; y1[139] <= out_03;
  				y1[140] <= out_04; y1[141] <= out_05; y1[142] <= out_06; y1[143] <= out_07;
  				y1[152] <= out_10; y1[153] <= out_11; y1[154] <= out_12; y1[155] <= out_13;
  				y1[156] <= out_14; y1[157] <= out_15; y1[158] <= out_16; y1[159] <= out_17;
  				y1[168] <= out_20; y1[169] <= out_21; y1[170] <= out_22; y1[171] <= out_23;
  				y1[172] <= out_24; y1[173] <= out_25; y1[174] <= out_26; y1[175] <= out_27;
          y1[184] <= out_30; y1[185] <= out_31; y1[186] <= out_32; y1[187] <= out_33;
  				y1[188] <= out_34; y1[189] <= out_35; y1[190] <= out_36; y1[191] <= out_37;
  				y1[200] <= out_40; y1[201] <= out_41; y1[202] <= out_42; y1[203] <= out_43;
  				y1[204] <= out_44; y1[205] <= out_45; y1[206] <= out_46; y1[207] <= out_47;
  				y1[216] <= out_50; y1[217] <= out_51; y1[218] <= out_52; y1[219] <= out_53;
  				y1[220] <= out_54; y1[221] <= out_55; y1[222] <= out_56; y1[223] <= out_57;
  				y1[232] <= out_60; y1[233] <= out_61; y1[234] <= out_62; y1[235] <= out_63;
  				y1[236] <= out_64; y1[237] <= out_65; y1[238] <= out_66; y1[239] <= out_67;
  				y1[248] <= out_70; y1[249] <= out_71; y1[250] <= out_72; y1[251] <= out_73;
  				y1[252] <= out_74; y1[253] <= out_75; y1[254] <= out_76; y1[255] <= out_77;
  			end 
  			4:begin
  				cr1[0] <= out_00; cr1[1] <= out_01; cr1[2] <= out_02; cr1[3] <= out_03;
  				cr1[4] <= out_04; cr1[5] <= out_05; cr1[6] <= out_06; cr1[7] <= out_07;
  				cr1[8] <= out_10; cr1[9] <= out_11; cr1[10] <= out_12; cr1[11] <= out_13;
  				cr1[12] <= out_14; cr1[13] <= out_15; cr1[14] <= out_16; cr1[15] <= out_17;
  				cr1[16] <= out_20; cr1[17] <= out_21; cr1[18] <= out_22; cr1[19] <= out_23;
  				cr1[20] <= out_24; cr1[21] <= out_25; cr1[22] <= out_26; cr1[23] <= out_27;
          cr1[24] <= out_30; cr1[25] <= out_31; cr1[26] <= out_32; cr1[27] <= out_33;
  				cr1[28] <= out_34; cr1[29] <= out_35; cr1[30] <= out_36; cr1[31] <= out_37;
  				cr1[32] <= out_40; cr1[33] <= out_41; cr1[34] <= out_42; cr1[35] <= out_43;
  				cr1[36] <= out_44; cr1[37] <= out_45; cr1[38] <= out_46; cr1[39] <= out_47;
  				cr1[40] <= out_50; cr1[41] <= out_51; cr1[42] <= out_52; cr1[43] <= out_53;
  				cr1[44] <= out_54; cr1[45] <= out_55; cr1[46] <= out_56; cr1[47] <= out_57;
  				cr1[48] <= out_60; cr1[49] <= out_61; cr1[50] <= out_62; cr1[51] <= out_63;
  				cr1[52] <= out_64; cr1[53] <= out_65; cr1[54] <= out_66; cr1[55] <= out_67;
  				cr1[56] <= out_70; cr1[57] <= out_71; cr1[58] <= out_72; cr1[59] <= out_73;
  				cr1[60] <= out_74; cr1[61] <= out_75; cr1[62] <= out_76; cr1[63] <= out_77;
  				
  			end 
  			5:begin
  				cb1[0] <= out_00; cb1[1] <= out_01; cb1[2] <= out_02; cb1[3] <= out_03;
  				cb1[4] <= out_04; cb1[5] <= out_05; cb1[6] <= out_06; cb1[7] <= out_07;
  				cb1[8] <= out_10; cb1[9] <= out_11; cb1[10] <= out_12; cb1[11] <= out_13;
  				cb1[12] <= out_14; cb1[13] <= out_15; cb1[14] <= out_16; cb1[15] <= out_17;
  				cb1[16] <= out_20; cb1[17] <= out_21; cb1[18] <= out_22; cb1[19] <= out_23;
  				cb1[20] <= out_24; cb1[21] <= out_25; cb1[22] <= out_26; cb1[23] <= out_27;
          cb1[24] <= out_30; cb1[25] <= out_31; cb1[26] <= out_32; cb1[27] <= out_33;
  				cb1[28] <= out_34; cb1[29] <= out_35; cb1[30] <= out_36; cb1[31] <= out_37;
  				cb1[32] <= out_40; cb1[33] <= out_41; cb1[34] <= out_42; cb1[35] <= out_43;
  				cb1[36] <= out_44; cb1[37] <= out_45; cb1[38] <= out_46; cb1[39] <= out_47;
  				cb1[40] <= out_50; cb1[41] <= out_51; cb1[42] <= out_52; cb1[43] <= out_53;
  				cb1[44] <= out_54; cb1[45] <= out_55; cb1[46] <= out_56; cb1[47] <= out_57;
  				cb1[48] <= out_60; cb1[49] <= out_61; cb1[50] <= out_62; cb1[51] <= out_63;
  				cb1[52] <= out_64; cb1[53] <= out_65; cb1[54] <= out_66; cb1[55] <= out_67;
  				cb1[56] <= out_70; cb1[57] <= out_71; cb1[58] <= out_72; cb1[59] <= out_73;
  				cb1[60] <= out_74; cb1[61] <= out_75; cb1[62] <= out_76; cb1[63] <= out_77;
  			end 
  			default:;
  		endcase
  	end else begin
  		if(i_in_mcu_i2 == 0)begin
  			y1[0] <= out_00; y1[1] <= out_01; y1[2] <= out_02; y1[3] <= out_03;
  		  y1[4] <= out_04; y1[5] <= out_05; y1[6] <= out_06; y1[7] <= out_07;
  			y1[8] <= out_10; y1[9] <= out_11; y1[10] <= out_12; y1[11] <= out_13;
  			y1[12] <= out_14; y1[13] <= out_15; y1[14] <= out_16; y1[15] <= out_17;
  			y1[16] <= out_20; y1[17] <= out_21; y1[18] <= out_22; y1[19] <= out_23;
  			y1[20] <= out_24; y1[21] <= out_25; y1[22] <= out_26; y1[23] <= out_27;
        y1[24] <= out_30; y1[25] <= out_31; y1[26] <= out_32; y1[27] <= out_33;
  			y1[28] <= out_34; y1[29] <= out_35; y1[30] <= out_36; y1[31] <= out_37;
  			y1[32] <= out_40; y1[33] <= out_41; y1[34] <= out_42; y1[35] <= out_43;
  			y1[36] <= out_44; y1[37] <= out_45; y1[38] <= out_46; y1[39] <= out_47;
  			y1[40] <= out_50; y1[41] <= out_51; y1[42] <= out_52; y1[43] <= out_53;
  			y1[44] <= out_54; y1[45] <= out_55; y1[46] <= out_56; y1[47] <= out_57;
  			y1[48] <= out_60; y1[49] <= out_61; y1[50] <= out_62; y1[51] <= out_63;
  			y1[52] <= out_64; y1[53] <= out_65; y1[54] <= out_66; y1[55] <= out_67;
  			y1[56] <= out_70; y1[57] <= out_71; y1[58] <= out_72; y1[59] <= out_73;
  			y1[60] <= out_74; y1[61] <= out_75; y1[62] <= out_76; y1[63] <= out_77;
  		end else if(i_in_mcu_i2 == 1)begin
  			cr1[0] <= out_00; cr1[1] <= out_01; cr1[2] <= out_02; cr1[3] <= out_03;
  			cr1[4] <= out_04; cr1[5] <= out_05; cr1[6] <= out_06; cr1[7] <= out_07;
  			cr1[8] <= out_10; cr1[9] <= out_11; cr1[10] <= out_12; cr1[11] <= out_13;
  			cr1[12] <= out_14; cr1[13] <= out_15; cr1[14] <= out_16; cr1[15] <= out_17;
  			cr1[16] <= out_20; cr1[17] <= out_21; cr1[18] <= out_22; cr1[19] <= out_23;
  			cr1[20] <= out_24; cr1[21] <= out_25; cr1[22] <= out_26; cr1[23] <= out_27;
        cr1[24] <= out_30; cr1[25] <= out_31; cr1[26] <= out_32; cr1[27] <= out_33;
  			cr1[28] <= out_34; cr1[29] <= out_35; cr1[30] <= out_36; cr1[31] <= out_37;
  			cr1[32] <= out_40; cr1[33] <= out_41; cr1[34] <= out_42; cr1[35] <= out_43;
  			cr1[36] <= out_44; cr1[37] <= out_45; cr1[38] <= out_46; cr1[39] <= out_47;
  			cr1[40] <= out_50; cr1[41] <= out_51; cr1[42] <= out_52; cr1[43] <= out_53;
  			cr1[44] <= out_54; cr1[45] <= out_55; cr1[46] <= out_56; cr1[47] <= out_57;
  			cr1[48] <= out_60; cr1[49] <= out_61; cr1[50] <= out_62; cr1[51] <= out_63;
  			cr1[52] <= out_64; cr1[53] <= out_65; cr1[54] <= out_66; cr1[55] <= out_67;
  			cr1[56] <= out_70; cr1[57] <= out_71; cr1[58] <= out_72; cr1[59] <= out_73;
  			cr1[60] <= out_74; cr1[61] <= out_75; cr1[62] <= out_76; cr1[63] <= out_77;
  		end else begin
  			cb1[0] <= out_00; cb1[1] <= out_01; cb1[2] <= out_02; cb1[3] <= out_03;
  			cb1[4] <= out_04; cb1[5] <= out_05; cb1[6] <= out_06; cb1[7] <= out_07;
  			cb1[8] <= out_10; cb1[9] <= out_11; cb1[10] <= out_12; cb1[11] <= out_13;
  			cb1[12] <= out_14; cb1[13] <= out_15; cb1[14] <= out_16; cb1[15] <= out_17;
  			cb1[16] <= out_20; cb1[17] <= out_21; cb1[18] <= out_22; cb1[19] <= out_23;
  			cb1[20] <= out_24; cb1[21] <= out_25; cb1[22] <= out_26; cb1[23] <= out_27;
        cb1[24] <= out_30; cb1[25] <= out_31; cb1[26] <= out_32; cb1[27] <= out_33;
  			cb1[28] <= out_34; cb1[29] <= out_35; cb1[30] <= out_36; cb1[31] <= out_37;
  			cb1[32] <= out_40; cb1[33] <= out_41; cb1[34] <= out_42; cb1[35] <= out_43;
  			cb1[36] <= out_44; cb1[37] <= out_45; cb1[38] <= out_46; cb1[39] <= out_47;
  			cb1[40] <= out_50; cb1[41] <= out_51; cb1[42] <= out_52; cb1[43] <= out_53;
  			cb1[44] <= out_54; cb1[45] <= out_55; cb1[46] <= out_56; cb1[47] <= out_57;
  			cb1[48] <= out_60; cb1[49] <= out_61; cb1[50] <= out_62; cb1[51] <= out_63;
  			cb1[52] <= out_64; cb1[53] <= out_65; cb1[54] <= out_66; cb1[55] <= out_67;
  			cb1[56] <= out_70; cb1[57] <= out_71; cb1[58] <= out_72; cb1[59] <= out_73;
  			cb1[60] <= out_74; cb1[61] <= out_75; cb1[62] <= out_76; cb1[63] <= out_77;
  		end 
  		
  	end 
  end 
end 


reg [12:0] x_mcu_0,y_mcu_0;
reg [12:0] x_mcu_1,y_mcu_1;


always@(posedge clk)
  if(rst)begin
    full_0 <= 0;
    x_mcu_0 <= 0;  y_mcu_0 <= 0;
  end else if(state == `state_rst)begin
  	full_0 <= 0;
    x_mcu_0 <= 0;  y_mcu_0 <= 0;  
  end else if(rgb_state == `rgb_state_store & pp_rgb == 0)begin
    full_0 <= 1;
    x_mcu_0 <= x_mcu_rgb;  y_mcu_0 <= y_mcu_rgb;
  end else if(out_state == `out_state_out2 & rd & pp_rgb == 1)
    full_0 <= 0; 

always@(posedge clk)
  if(rst)begin
    full_1 <= 0;
    x_mcu_1 <= 0;  y_mcu_1 <= 0;
  end else if(state == `state_rst)begin
  	full_1 <= 0;
    x_mcu_1 <= 0;  y_mcu_1 <= 0;  
  end else if(rgb_state == `rgb_state_store & pp_rgb == 1)begin
    full_1 <= 1;
    x_mcu_1 <= x_mcu_rgb;  y_mcu_1 <= y_mcu_rgb;
  end else if(out_state == `out_state_out2 & rd & pp_rgb == 0)
    full_1 <= 0; 
    

assign fifo_full = pp_rgb == 0 ? full_1 : full_0;
assign out_end = pp_rgb == 0 ? ~full_1 : ~full_0;

reg [7:0] rgb_x;

wire [7:0] rgb_x_n = rgb_x + 8'd1;

always@(posedge clk)
  if(rst)
    rgb_x <= 0;
  else if(state == `state_rst)
    rgb_x <= 0;
  else if(out_state == `out_state_idle & fifo_full)  
    rgb_x <= rgb_x_n;
  else if(out_state == `out_state_out & rd)  
    rgb_x <= rgb_x_n;
  else if(out_state == `out_state_out2 & rd)
    rgb_x <= 0;  
 
reg [5:0] c_adr;  
always@(posedge clk)
  if(rst)
    c_adr <= 0;
  else if(state == `state_rst)
    c_adr <= 0;
  else if(out_state == `out_state_idle & fifo_full)  
    c_adr <= pic_is_411 ? {rgb_x_n[7:5],rgb_x_n[3:1]} : rgb_x_n[5:0];
  else if(out_state == `out_state_out & rd)  
    c_adr <= pic_is_411 ? {rgb_x_n[7:5],rgb_x_n[3:1]} : rgb_x_n[5:0];
  else if(out_state == `out_state_out2 & rd)
    c_adr <= 0;  

    
assign last_one = pic_is_411 ? rgb_x == 8'd255 : rgb_x == 8'd63;

wire [15:0] y_cur = pp_rgb == 0 ? y1[rgb_x] : y0[rgb_x];
wire [15:0] cr_cur = pp_rgb == 0 ? cr1[c_adr] : cr0[c_adr];                                                                 
wire [15:0] cb_cur = pp_rgb == 0 ? cb1[c_adr] : cb0[c_adr];


wire [7:0] outr,outg,outb;

calrgb calrgb(
.y(y_cur),.cr(cr_cur),.cb(cb_cur),
.outr(outr),.outg(outg),.outb(outb));

always@(posedge clk)
  if(rst)begin
     r <= 0;
     g <= 0;
     b <= 0;  
  end else if(out_state == `out_state_idle & fifo_full)begin
   	r <= outr;
    g <= outg;
    b <= outb;
  end else if(out_state == `out_state_out & rd)begin
  	r <= outr;
    g <= outg;
    b <= outb;
  end 
      
assign rgb_i = rgb_x - 8'd1;  
 
always@(posedge clk)
  if(rst)begin
  	x_mcu_o <= 0;
  	y_mcu_o <= 0;
  end else if(out_state == `out_state_idle & fifo_full)begin
  	if(pp_rgb == 0)begin
  		x_mcu_o <= x_mcu_1;
  	  y_mcu_o <= y_mcu_1;
  	end else begin
  		x_mcu_o <= x_mcu_0;
  	  y_mcu_o <= y_mcu_0;
  	end 	
  end  
 
    
    
endmodule


module calrgb(
input [15:0] y , cr, cb,
output [7:0] outr,outg,outb
);

wire [22:0] cb_ = {{7{cb[15]}},cb};
wire [22:0] cr_ = {{7{cr[15]}},cr};

//$signed({{12{cb[15]}},cb}) * $signed(28'd5742);
wire [22:0] cb_r_4096 = (cb_ << 12) + (cb_ << 10) + (cb_ << 9) + (cb_ << 7) - (cb_ << 4) - (cb_ << 1);
//$signed({{12{cr[15]}},cr}) * $signed(28'd1409)
wire [22:0] cr_g_4096 = (cr_ << 10) + (cr_ << 8) + (cr_ << 7) + cr_;
//$signed({{12{cb[15]}},cb}) * $signed(28'd2925)
wire [22:0] cb_g_4096 = (cb_ << 11) + (cb_ << 9) + (cb_ << 8) + (cb_ << 6) + 
                        (cb_ << 5) + (cb_ << 3) + (cb_ << 2) + cb_;
//$signed({{12{cr[15]}},cr}) * $signed(28'd7258)                                             
wire [22:0] cr_b_4096 = (cr_ << 12) + (cr_ << 11) + (cr_ << 10) + (cr_ << 6) + 
                        (cr_ << 4) + (cr_ << 3) + (cr_ << 1);

wire[10:0] outr_ = 11'd128 + y[10:0] + cb_r_4096[22:12];
wire[10:0] outg_ = 11'd128 + y[10:0] - cr_g_4096[22:12] - cb_g_4096[22:12];
wire[10:0] outb_ = 11'd128 + y[10:0] + cr_b_4096[22:12];

assign outr = outr_[10] ? 8'b0 : 
              outr_ > 11'd255 ? 8'd255 : outr_[7:0];

assign outg = outg_[10] ? 8'b0 : 
              outg_ > 11'd255 ? 8'd255 : outg_[7:0];
              
assign outb = outb_[10] ? 8'b0 : 
              outb_ > 11'd255 ? 8'd255 : outb_[7:0];              

endmodule