vlib work
vmap work work

vlog +incdir+../rtl ./tb_modelsim/a_tb.v  ../rtl/*.v 

vsim -lib work -c a_tb 
# vcd file aa.vcd
# vcd add -r /*
run -all