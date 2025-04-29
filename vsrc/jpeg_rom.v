module jpeg_rom #(
    parameter MEM_FILE = "red.mem",
    parameter ADDR_WIDTH = 16
)(
    input                    clk,
    input                    rst,
    input                    rd_en,
    input  [ADDR_WIDTH-1:0]  addr_in,    // Address input from top module
    output [7:0]             data_out,
    output                   rom_done
);

    reg [7:0] rom [(2**ADDR_WIDTH)-1:0];
    
    // Load memory file at initialization
    initial begin
        $readmemh(MEM_FILE, rom);
    end
    
    assign data_out = rst ? 0 : rom[addr_in];
    
    // Signal when we've reached the end (based on the maximum address)
    assign rom_done = (addr_in == {(ADDR_WIDTH){1'b1}}) ? 1'b1 : 1'b0;

endmodule
