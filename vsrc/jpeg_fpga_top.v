module jpeg_fpga_top #(
    parameter ROM_FILE = "/home/lcjd/code-workspace/jpeg_decode/data/rom.mem",
    parameter ROM_ADDR_WIDTH = 16,
    
    // VGA parameters (640x480@60Hz)
    parameter VGA_H_ACTIVE = 32,
    parameter VGA_V_ACTIVE = 32 
)(
    // System signals
    input             clk,          // System clock
    input             rst,
    input             start,
    
    // Original outputs (kept for debugging)
    output            decode_done,
    output            frame_valid,
    output            pixel_valid,
    output            pixel_sof,    // Start of frame
    output            pixel_eof,    // End of frame
    output [7:0]      pixel_r,
    output [7:0]      pixel_g,
    output [7:0]      pixel_b,
    output [7:0]      pixel_addr,   // Pixel address in MCU
    output [12:0]     mcu_x,        // MCU X coordinate
    output [12:0]     mcu_y,        // MCU Y coordinate
    
    // Configuration outputs
    output            config_valid,
    output            config_411,   // JPEG format (4:1:1 or not)
    output [15:0]     img_width,    // Image width
    output [15:0]     img_height,   // Image height
    output [12:0]     mcu_count_x,  // MCU count in X direction
    output [12:0]     mcu_count_y,  // MCU count in Y direction
    
    // VGA outputs
    output            vga_hsync,
    output            vga_vsync,
    output [11:0]      vga_data_pin
);

    // Internal signals
    wire        rom_data_valid;
    wire [7:0]  rom_data;
    wire        next_data_req;
    wire        rom_done;
    // Address counter for ROM
    reg [ROM_ADDR_WIDTH-1:0] rom_addr_counter;
    
    
    // Generate VGA clock using clkgen (25MHz for 640x480@60Hz)
    wire clk_vga;
    clkgen #(
        .sys_clk_freq(100000000),   // Assuming system clock is 100MHz
        .out_clk_freq(25000000)     // VGA needs 25MHz for 640x480@60Hz
    ) vga_clk_gen (
        .clkin(clk),
        .rst(rst),
        .clken(1'b1),               // Always enable the clock
        .clkout(clk_vga)
    );
    
    // State machine for controlling data flow
    reg [1:0]   state;
    localparam  IDLE = 2'b00,
                DECODING = 2'b01,
                DONE = 2'b10;
    
    wire decoding_active = 1;
    wire next_pixel_req = 1;
    
    // // State machine
    // always @(posedge clk) begin
    //     if (rst) begin
    //         state <= IDLE;
    //         decoding_active <= 1'b0;
    //     end else begin
    //         case (state)
    //             IDLE: begin
    //                 if (start) begin
    //                     state <= DECODING;
    //                     decoding_active <= 1'b1;
    //                 end
    //             end
                
    //             DECODING: begin
    //                 if (bo_end && bo_x_mcu == mcu_count_x-1 && bo_y_mcu == mcu_count_y-1) begin
    //                     state <= DONE;
    //                     decoding_active <= 1'b0;
    //                 end
    //             end
                
    //             DONE: begin
    //                 // Stay in DONE until reset
    //                 decoding_active <= 1'b0;
    //             end
                
    //             default: state <= IDLE;
    //         endcase
    //     end
    // end
    
    
    // ROM address counter logic
    always @(posedge clk) begin
        if (rst)
            rom_addr_counter <= 0;
        else if (next_data_req && decoding_active)
            rom_addr_counter <= rom_addr_counter + 1;
    end
    
    // ROM instance
    jpeg_rom #(
        .MEM_FILE(ROM_FILE),
        .ADDR_WIDTH(ROM_ADDR_WIDTH)
    ) u_jpeg_rom (
        .clk(clk),
        .rst(rst),
        .rd_en(1'b1),  
        .addr_in(rom_addr_counter),
        .data_out(rom_data),
        .rom_done(rom_done)
    );

    // JPEG decoder instance
    wire bo_we;     // Renamed for clarity and to align with tb
    wire bo_begin;
    wire bo_end;
    wire [7:0] bo_r;
    wire [7:0] bo_g;
    wire [7:0] bo_b;
    wire [7:0] bo_adr;
    wire [12:0] bo_x_mcu;
    wire [12:0] bo_y_mcu;
    
    jpeg_top u_jpeg_top(
        // Input data interface
        .ai_we(decoding_active),
        .ai_data(rom_data),
        .ao_next(next_data_req),
        
        // Output pixel interface
        .bo_we(bo_we),
        .bo_begin(bo_begin),
        .bo_end(bo_end),
        .bo_r(bo_r),
        .bo_g(bo_g),
        .bo_b(bo_b),
        .bo_adr(bo_adr),
        .bo_x_mcu(bo_x_mcu),
        .bo_y_mcu(bo_y_mcu),
        .bi_next(next_pixel_req),
        
        // Configuration interface
        .co_en(config_valid),
        .co_411(config_411),
        .co_width(img_width),
        .co_heigth(img_height),
        .co_mcu_w(mcu_count_x),
        .co_mcu_h(mcu_count_y),
        
        // System interface
        .clk(clk),
        .rst(rst)
    );

    // Control next pixel request
    // always @(posedge clk) begin
    //     if (rst)
    //         next_pixel_req <= 1'b0;
    //     else
    //         // We're always ready for the next pixel in this implementation
    //         next_pixel_req <= 1'b1;
    // end



    // Connect internal signals to outputs
    assign pixel_valid = bo_we;
    assign pixel_sof = bo_begin;
    assign pixel_eof = bo_end;
    assign pixel_r = bo_r;
    assign pixel_g = bo_g;
    assign pixel_b = bo_b;
    assign pixel_addr = bo_adr;
    assign mcu_x = bo_x_mcu;
    assign mcu_y = bo_y_mcu;
    
    // Frame valid signal
    assign frame_valid = (state == DECODING);
    
    // Decode done signal
    assign decode_done = (state == DONE);
    
    // Frame buffer to store decoded image
    localparam FB_ADDR_WIDTH = 8; // Sufficient for 640x480 = 307,200 pixels
    
    // Calculate write address for frame buffer
    // Convert JPEG MCU-based addressing to linear frame buffer addressing
    wire [15:0] jpeg_pixel_x, jpeg_pixel_y;
    // Calculate actual pixel position based on MCU and pixel within MCU
    // For 4:1:1 format, each MCU is 16x16 pixels
    assign jpeg_pixel_x = bo_x_mcu * 16 + ({8'b0, bo_adr} % 16);
    assign jpeg_pixel_y = bo_y_mcu * 16 + ({8'b0, bo_adr} / 16);
    
    // Write address calculation
    // Clamp to frame buffer dimensions to avoid addressing outside buffer
    wire [FB_ADDR_WIDTH-1:0] fb_wr_addr;
    assign fb_wr_addr = (jpeg_pixel_x < VGA_H_ACTIVE && jpeg_pixel_y < VGA_V_ACTIVE) ?
                        (jpeg_pixel_y * VGA_H_ACTIVE + jpeg_pixel_x) : 0;
    
    // Read address calculation                    
    wire [FB_ADDR_WIDTH-1:0] fb_rd_addr;
    assign fb_rd_addr = {6'b0, vga_pixel_y} * VGA_H_ACTIVE + {6'b0, vga_pixel_x};
    
    // Frame buffer RGB data
    wire [23:0] fb_wr_data;
    wire [11:0] fb_rd_data;
    
    assign fb_wr_data = {bo_r, bo_g, bo_b};
    
    // Frame buffer instance
    frame_buffer #(
        .WIDTH(VGA_H_ACTIVE),
        .HEIGHT(VGA_V_ACTIVE),
        .ADDR_WIDTH(FB_ADDR_WIDTH)
    ) u_frame_buffer (
        .wr_clk(clk),
        .wr_en(bo_we && next_pixel_req && jpeg_pixel_x < VGA_H_ACTIVE && jpeg_pixel_y < VGA_V_ACTIVE),
        .wr_addr(fb_wr_addr),
        .wr_data(fb_wr_data),
        
        .rd_clk(clk_vga),
        .rd_addr(fb_rd_addr),
        .rd_data(fb_rd_data)
    );

    // VGA controller
    wire [9:0] vga_pixel_x;
    wire [9:0] vga_pixel_y;
    wire vga_display_en;
    wire [11:0] vga_pixel_data;
    wire [3:0] vga_r, vga_g, vga_b;
    assign vga_data_pin = {vga_r, vga_g, vga_b};
    
    // Connect frame buffer data to VGA input
    assign vga_pixel_data = vga_display_en ? fb_rd_data : 12'd0;
    
    vga_ctrl u_vga_ctrl (
        .pclk(clk_vga),          // 25MHz clock
        .reset(rst),             // reset signal
        .vga_data(vga_pixel_data), // RGB pixel data from frame buffer
        .h_addr(vga_pixel_x),    // current horizontal pixel address
        .v_addr(vga_pixel_y),    // current vertical pixel address
        .hsync(vga_hsync),       // horizontal sync
        .vsync(vga_vsync),       // vertical sync
        .valid(vga_display_en),  // display enable signal
        .vga_r(vga_r),           // red output
        .vga_g(vga_g),           // green output
        .vga_b(vga_b)            // blue output
    );
    

endmodule
