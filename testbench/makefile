include_dir = ../rtl
rtl = ../rtl/*.v


iverilog:
	iverilog -s a_tb -I $(include_dir)  $(rtl) ./tb_iverilog/a_tb.v
	vvp a.out

verilator:
	verilator -Wno-UNUSED -cc -top-module tb -I$(include_dir) --timescale 1ns/100ps --trace --exe ./tb_verilator/sim.cpp ./tb_verilator/tb.v $(rtl)  
	make -j -C obj_dir -f Vtb.mk Vtb
	echo "Runing"
	obj_dir/Vtb


# vsim win10
# modelsim:
#	rm -rf work
#	vsim -c -do ./tb_modelsim/sim.do

clear_iverilog:
	rm -rf a.out
clear_verilator:
	rm -rf ./obj_dir

