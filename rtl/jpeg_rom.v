module jpeg_rom #(
    parameter MEM_FILE = "red.mem",
    parameter ADDR_WIDTH = 16
)(
    input                    clk,
    input                    rst,
    input                    rd_en,
    output reg [7:0]         data_out,
    output                   rom_done
);

    reg [7:0] rom [(2**ADDR_WIDTH)-1:0];
    reg [(ADDR_WIDTH-1):0] addr_counter;
    
    // Load memory file at initialization
    initial begin
        $readmemh(MEM_FILE, rom);
    end
    
    // Address counter
    always @(posedge clk) begin
        if (rst)
            addr_counter <= 0;
        else if (rd_en)
            addr_counter <= addr_counter + 1;
    end
    
    // Data output
    always @(posedge clk) begin
        if (rst)
            data_out <= 8'h0;
        else if (rd_en)
            data_out <= rom[addr_counter];
    end
    
    // Signal when we've reached the end (can be modified based on specific implementation needs)
    assign rom_done = (addr_counter == {(ADDR_WIDTH){1'b1}}) ? 1'b1 : 1'b0;

endmodule
