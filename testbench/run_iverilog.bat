iverilog -s a_tb -I ../rtl  ../rtl/*.v ./a_tb.v
vvp a.out
pause