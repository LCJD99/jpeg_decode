module clkgen(
    input clkin,
    input rst,
    input clken,
    output reg clkout
    );
    parameter sys_clk_freq=100000000;  
    parameter out_clk_freq=25000000; 
    parameter countlimit=sys_clk_freq/2/out_clk_freq; 

  reg[31:0] clkcount;
  always @ (posedge clkin)
    if(rst)
    begin
        clkcount=0;
        clkout=1'b0;
    end
    else
    begin
    if(clken)
        begin
            clkcount=clkcount+1;
            if(clkcount>=countlimit)
            begin
                clkcount=32'd0;
                clkout=~clkout;
            end
            else
                clkout=clkout;
        end
      else
        begin
            clkcount=clkcount;
            clkout=clkout;
        end
    end
endmodule