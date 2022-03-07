#include "Vtb.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    Vtb* top = new Vtb;

    Verilated::traceEverOn(true);
    VerilatedVcdC* tfp = new VerilatedVcdC;
    top->trace(tfp, 99);
    tfp->open("./Vtb.vcd");

    vluint64_t main_time = 0;

    top->clk = 0;
    top->rst = 0;

    int makeVCD = 1;
    int cnt = 0;  
    while (!Verilated::gotFinish()) { 
        top->eval();
        if (makeVCD) tfp->dump (main_time);	
        if (main_time == 3) top->rst = 1;
        if (main_time == 8) top->rst = 0;
        top->clk = !top->clk;
        main_time++;

       //if (top->Core0_Done & top->Core0_Pc == 0x100)   makeVCD = 1;
        //if (cnt == 20) makeVCD = 1;
        //if (top->Core0_Done & top->Core0_Pc == 0xb590)   break;
        
        
    }
    delete top;
    tfp->close();
    exit(0);
}