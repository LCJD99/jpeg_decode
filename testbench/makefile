include_dir = ../vsrc
rtl = ../vsrc/*.v

TOP = new_tb

iverilog:
	iverilog -s $(TOP) -I $(include_dir)  $(rtl) ./tb_iverilog/$(TOP).v
	vvp a.out

verilator:
	verilator -Wno-UNUSED -cc -top-module tb -I$(include_dir) --timescale 1ns/100ps --trace --exe ./tb_verilator/sim.cpp ./tb_verilator/tb.v $(rtl)  
	make -j -C obj_dir -f Vtb.mk Vtb
	echo "Runing"
	obj_dir/Vtb


clear_iverilog:
	rm -rf a.out
clear_verilator:
	rm -rf ./obj_dir

