#include <nvboard.h>
#include "Vjpeg_fpga_top.h"
#include "verilated.h"
#include "verilated_vcd_c.h"

static TOP_NAME* top = nullptr;
static VerilatedVcdC* tfp = nullptr;

static vluint64_t main_time = 0;

void nvboard_bind_all_pins(TOP_NAME* top);

static void single_cycle() {
    top->clk = 0;
    top->eval();
    if (tfp) tfp->dump(main_time++);
    top->clk = 1;
    top->eval();
    if (tfp) tfp->dump(main_time++);
}

static void reset(int n) {
    top->rst = 1;
    while (n--) {
        single_cycle();
    }
    top->rst = 0;
}

int main(int argc, char** argv, char** env) {
    Verilated::commandArgs(argc, argv);
    top = new TOP_NAME("top");

    nvboard_bind_all_pins(top);
    nvboard_init();

    Verilated::traceEverOn(true);
    tfp = new VerilatedVcdC;

    top->trace(tfp, 99);
    tfp->open("./wave.vcd");

    top->clk = 0;
    top->rst = 0;

    reset(5);

    top->start = 1;
    while (!Verilated::gotFinish() && !top->decode_done) { 
        nvboard_update();
        single_cycle();
    }
    delete top;
    tfp->close();
    nvboard_quit();
    exit(0);
}