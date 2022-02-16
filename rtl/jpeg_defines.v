`define state_idl 4'd0
`define state_soi 4'd1
`define state_app 4'd2
`define state_dqt 4'd3
`define state_sof 4'd4
`define state_dht 4'd5
`define state_dri 4'd6
`define state_sos 4'd7
`define state_dec 4'd8
`define state_end 4'd9
`define state_eoi 4'd10
`define state_rst 4'd11

`define dqt_state_idle 3'd0
`define dqt_state_size 3'd1
`define dqt_state_tabl 3'd2
`define dqt_state_item 3'd3
`define dqt_state_judg 3'd4


`define sof_state_idle 3'd0
`define sof_state_size 3'd1
`define sof_state_reso 3'd2
`define sof_state_y    3'd3
`define sof_state_cr   3'd4
`define sof_state_cb   3'd5


`define dht_state_idle 4'd0
`define dht_state_size 4'd1
`define dht_state_tabl 4'd2
`define dht_state_cnth 4'd3
`define dht_state_calh 4'd4
`define dht_state_cntl 4'd5
`define dht_state_call 4'd6
`define dht_state_item 4'd7
`define dht_state_judg 4'd8

`define dht_cal_state_idle 1'd0
`define dht_cal_state_do   1'd1

`define sos_state_idle 2'd0
`define sos_state_size 2'd1
`define sos_state_tabl 2'd2
`define sos_state_spec 2'd3

`define dec_state_idle   3'd0
`define dec_state_dc     3'd1
`define dec_state_ac     3'd2
`define dec_state_mupdat 3'd3
`define dec_state_updat  3'd4
`define dec_state_wait   3'd5

`define dc_state_idle 2'd0
`define dc_state_comp 2'd1
`define dc_state_valu 2'd2


`define ac_state_idle 2'd0
`define ac_state_comp 2'd1
`define ac_state_judg 2'd2
`define ac_state_valu 2'd3

`define dq_state_idle 2'd0
`define dq_state_dq   2'd1
`define dq_state_wait 2'd2


`define idct1_state_idle 2'd0
`define idct1_state_do   2'd1
`define idct1_state_cal  2'd3
`define idct1_state_wait 2'd2

`define idct2_state_idle 2'd0
`define idct2_state_do   2'd1
`define idct2_state_cal  2'd3
`define idct2_state_wait 2'd2


`define rgb_state_idle  2'd0
`define rgb_state_store 2'd1
`define rgb_state_wait  2'd3


/*
`define c1_16  35'd4017
`define c2_16  35'd3784
`define c3_16  35'd3406
`define c4_16  35'd2896
`define c5_16  35'd2276
`define c6_16  35'd1567
`define c7_16  35'd799
*/