module vga_controller #(
    parameter H_ACTIVE      = 640,  // Horizontal active pixels
    parameter H_FRONT_PORCH = 16,   // Horizontal front porch
    parameter H_SYNC_PULSE  = 96,   // Horizontal sync pulse
    parameter H_BACK_PORCH  = 48,   // Horizontal back porch
    parameter V_ACTIVE      = 480,  // Vertical active lines
    parameter V_FRONT_PORCH = 10,   // Vertical front porch
    parameter V_SYNC_PULSE  = 2,    // Vertical sync pulse
    parameter V_BACK_PORCH  = 33    // Vertical back porch
)(
    input               clk,        // Pixel clock (25MHz for 640x480@60Hz)
    input               rst,        // Reset
    
    // VGA outputs
    output reg          hsync,      // Horizontal sync
    output reg          vsync,      // Vertical sync
    output reg          display_en, // Display enable (active area)
    output reg [9:0]    pixel_x,    // Current pixel X coordinate
    output reg [9:0]    pixel_y     // Current pixel Y coordinate
);
    
    // Horizontal timing constants
    localparam H_TOTAL      = H_ACTIVE + H_FRONT_PORCH + H_SYNC_PULSE + H_BACK_PORCH;
    localparam H_SYNC_START = H_ACTIVE + H_FRONT_PORCH;
    localparam H_SYNC_END   = H_SYNC_START + H_SYNC_PULSE;
    
    // Vertical timing constants
    localparam V_TOTAL      = V_ACTIVE + V_FRONT_PORCH + V_SYNC_PULSE + V_BACK_PORCH;
    localparam V_SYNC_START = V_ACTIVE + V_FRONT_PORCH;
    localparam V_SYNC_END   = V_SYNC_START + V_SYNC_PULSE;
    
    // Counter for horizontal and vertical positions
    reg [9:0] h_count;
    reg [9:0] v_count;
    
    // Horizontal counter
    always @(posedge clk) begin
        if (rst) begin
            h_count <= 0;
        end else begin
            if (h_count == H_TOTAL - 1)
                h_count <= 0;
            else
                h_count <= h_count + 1;
        end
    end
    
    // Vertical counter
    always @(posedge clk) begin
        if (rst) begin
            v_count <= 0;
        end else if (h_count == H_TOTAL - 1) begin
            if (v_count == V_TOTAL - 1)
                v_count <= 0;
            else
                v_count <= v_count + 1;
        end
    end
    
    // Sync signals
    always @(posedge clk) begin
        if (rst) begin
            hsync <= 1'b1;
            vsync <= 1'b1;
        end else begin
            // Active low sync pulses
            hsync <= ~((h_count >= H_SYNC_START) && (h_count < H_SYNC_END));
            vsync <= ~((v_count >= V_SYNC_START) && (v_count < V_SYNC_END));
        end
    end
    
    // Display enable and pixel coordinates
    always @(posedge clk) begin
        if (rst) begin
            display_en <= 1'b0;
            pixel_x <= 0;
            pixel_y <= 0;
        end else begin
            // Display is enabled only within active region
            display_en <= (h_count < H_ACTIVE) && (v_count < V_ACTIVE);
            
            // Current pixel coordinates
            if (h_count < H_ACTIVE)
                pixel_x <= h_count;
            
            if (v_count < V_ACTIVE)
                pixel_y <= v_count;
        end
    end
    
endmodule
