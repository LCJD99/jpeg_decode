module frame_buffer #(
    parameter WIDTH = 640,
    parameter HEIGHT = 480,
    parameter ADDR_WIDTH = 19    // log2(WIDTH*HEIGHT) rounded up
)(
    // Write port (from JPEG decoder)
    input                   wr_clk,
    input                   wr_en,
    input [ADDR_WIDTH-1:0]  wr_addr,
    input [23:0]            wr_data,  // {R,G,B} 8 bits each
    
    // Read port (to VGA controller)
    input                   rd_clk,
    input [ADDR_WIDTH-1:0]  rd_addr,
    output reg [11:0]       rd_data   // {R,G,B} 8 bits each
);

    // Memory array
    (* ram_style = "block" *) reg [11:0] memory [(2**ADDR_WIDTH)-1:0];
    
    // Write port
    always @(posedge wr_clk) begin
        if (wr_en) begin
            memory[wr_addr] <= {wr_data[23:10], wr_data[15:12], wr_data[7:4]}; // Store as {B,G,R}
        end
    end
    
    // Read port
    always @(posedge rd_clk) begin
        rd_data <= memory[rd_addr];
    end

endmodule
