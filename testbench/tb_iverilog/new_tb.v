module new_tb();
    reg clk, rst;

    initial begin
        clk = 1'b1;
        rst = 1'b0;
        #180 rst = 1'b1;
        #360 rst = 1'b0;
        #3000000 $stop;
    end

    always #50 clk = ~clk;

    initial begin
        $dumpfile("./new.vcd");
        $dumpvars(0, new_tb);
    end

    jpeg_fpga_top top(
        .clk(clk),
        .rst(rst),
        .start(1'b1)
    );


endmodule

