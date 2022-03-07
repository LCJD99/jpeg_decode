`include "jpeg_defines.v"

module tb(
    input clk,
    input rst
);

/*
    initial begin
        $dumpfile("./aaa.vcd");
        $dumpvars(0,tb);
        //$dumpoff;
    end 
*/

    reg [7:0] mem [1048575:0];
    reg [19:0] pc;
    initial $readmemh("../dat/test1.txt",mem);

    wire        ai_we = 1;
    wire [7:0]  ai_data = mem[pc];
    wire        ao_next;

    always@(posedge clk)begin
        if(rst)
            pc <= 0;
        else if(ai_we & ao_next)  
            pc <= pc + 1;    
    end
     
    wire        bi_next = 1;
    wire        bo_we;
    wire        bo_begin;
    wire        bo_end;
    wire [7:0]  bo_r;
    wire [7:0]  bo_g;
    wire [7:0]  bo_b;
    wire [7:0]  bo_adr;
    wire [12:0] bo_x_mcu;
    wire [12:0] bo_y_mcu;

    wire          co_en;
	wire          co_411;
	wire [15:0]   co_width;
	wire [15:0]   co_heigth;
	wire [12:0]   co_mcu_w;           
	wire [12:0]   co_mcu_h;       
    jpeg_top jpeg_top( 
        .ai_we    ( ai_we ),
        .ao_next  ( ao_next ),
        .ai_data  ( ai_data ), 
        
        .bo_we    ( bo_we ),
        .bi_next  ( bi_next ),
        .bo_begin ( bo_begin ),
        .bo_end   ( bo_end ),
        .bo_r     ( bo_r ),
        .bo_g     ( bo_g ),
        .bo_b     ( bo_b ),
        .bo_x_mcu ( bo_x_mcu ),
        .bo_y_mcu ( bo_y_mcu ),
        .bo_adr   ( bo_adr ),

        .co_en     ( co_en ),
	    .co_411    ( co_411 ),
	    .co_width  ( co_width ),
	    .co_heigth ( co_heigth ),
	    .co_mcu_w  ( co_mcu_w ),           
	    .co_mcu_h  ( co_mcu_h ),        

        .clk(clk),
        .rst(rst)
    );

   /* verilator lint_off WIDTH */
    reg [31:0] pix_cnt;
    always@(posedge clk)begin
        if(rst)
            pix_cnt <= 0;
        else if(bo_we & bi_next)begin
            if (bo_end)
                pix_cnt <= 0;
            else begin
                pix_cnt <= pix_cnt + 1;
                if (pix_cnt[9:0] == 'd0)begin
                    $display("%d\n",pix_cnt);
                    //$display("%h",bo_data);
                end
            end
                
        end
    end

    wire [31:0] block = pix_cnt / 256;   
    wire [7:0]  pix   = pix_cnt % 256; 


    wire [31:0] x = block % 61 * 16 + pix % 16;     
    wire [31:0] y = block / 61 * 16 + pix / 16;    


    reg [7:0] rr [952575 : 0];
    reg [7:0] gg [952575 : 0];
    reg [7:0] bb [952575 : 0];


    always@(posedge clk)begin
        if(bi_next & bo_we)begin
            rr[y*976 + x] <= bo_r;
            gg[y*976 + x] <= bo_g;
            bb[y*976 + x] <= bo_b;
        end
    end 


    reg wr_file;
    always @(posedge clk) begin
        if(rst)
            wr_file <= 'b0;
        else 
            wr_file <= bo_we & bi_next & bo_end;
    end

    reg [31:0] clk_cnt;
    always @(posedge clk) begin
        if(rst)
            clk_cnt <= 0;
        else
            clk_cnt <= clk_cnt + 1;
    end

    
    integer j;
    integer file;
    always@(posedge clk)begin
        if(wr_file)begin
            file = $fopen("res.pgm","w");
            $fdisplay (file,"%s","P3");
            $fdisplay (file,"976 976");	
            $fdisplay (file,"%s","#spicec dump");
            $fdisplay (file,"255");	
            for(j=0;j<952576;j=j+1)begin
                $fdisplay (file,"%d", rr[j]);
                $fdisplay (file,"%d", gg[j]);
                $fdisplay (file,"%d", bb[j]);
            end 
            $fclose(file);
            $display("clock: %d",clk_cnt); //5542142
            $finish;
        end
    end
    /* verilator lint_on WIDTH */

endmodule