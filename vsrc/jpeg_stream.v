//---------------------------------------------------------------
// jpeg stream buffer 
// if stream is 0xff00, discard 00
// if stream is end, user shoule pull in datas continue 
//---------------------------------------------------------------
module jpeg_stream(
    input         ai_we,
    output        ao_next,
    input [7:0]   ai_data,

    output        bit_avali,
    output [63:0] bit_out,
    input  [6:0]  bit_eaten,         

    input clk,
    input rst
);

    reg [7:0] lastword;
    always@(posedge clk)begin
        if(rst)
            lastword <= 0;
        else if(ai_we & ao_next)  
            lastword <= ai_data;
    end
    
    wire ridzero = ai_data == 8'h00 & lastword == 8'hff;    

    reg [6:0]   point;   // count of avali bits
    reg [127:0] bit_buffer;
    always@(posedge clk) begin
        if (rst) 
            point <= 'd0;
		else if (ai_we & ao_next)begin
            if (ridzero)
                point <= point - bit_eaten;
            else
                point <= point - bit_eaten + 'd8;
        end else
			point <= point - bit_eaten;
	end 

    always@(posedge clk)begin
        if(rst)
            bit_buffer <= 'd0;
        else if (ai_we & ao_next)begin
            if (ridzero)
                bit_buffer <= bit_buffer << bit_eaten ;      
            else
                bit_buffer <= (bit_buffer | ({ai_data,120'd0} >> point)) << bit_eaten ;      
        end else 
            bit_buffer <= bit_buffer << bit_eaten ;      
    end

    assign bit_out = bit_buffer[127:64];
    assign bit_avali = point[6];  //point > 63;
    assign ao_next = point < 7'd119;

endmodule 