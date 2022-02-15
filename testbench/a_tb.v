`include "timescale.v"
`include "jpeg_defines.v"

module a_tb();


reg clk,rst; 

initial begin          
	clk = 1'b1;    
	rst = 1'b0;
	#180 rst = 1'b1;
	#360 rst = 1'b0;
	//#300000000 $stop;
end


always 	#50 clk = ~clk;

reg [7:0] mem [0:300000];

initial begin

  $readmemh("dat/13 35 80.txt",mem);

end 

reg [31:0] pc;
reg  [2:0] cnta,cntb;

always@(posedge clk)
  if(rst)
    cnta <= 0;
  else 
    cnta <= cnta + 1;  

wire ai_we = 1;
wire ai_begin = pc == 0 & ai_we;
wire ai_end = pc == 32'd181487 & ai_we;
wire [7:0] ai_data = mem[pc];
wire ao_next;

wire bi_next = 1;
wire bo_we;
wire bo_begin;
wire bo_end;
wire [31:0] bo_data;
wire bo_type;



jpeg_top jpeg_top( 
   .clk(clk),.rst(rst), 
   .ai_we(ai_we), .ai_begin(ai_begin), .ai_end(ai_end), 
   .ai_data(ai_data), .ao_next(ao_next),
   .bi_next(bi_next), .bo_we(bo_we), .bo_begin(bo_begin), 
   .bo_end(bo_end), .bo_data(bo_data), .bo_type(bo_type)
);



always@(posedge clk)
  if(rst)
    pc <= 0;
  else if(ai_we & ao_next)begin  
    pc <= pc + 1;   
  end 



reg [2:0] write;
always@(posedge clk)
  if(rst)
    write <= 0;
  else if(bo_end & bi_next & write == 0)
    write <= 1;  
  else if(write == 1)
    write <= 2; 
  else if(bo_end & bi_next & write == 2) 
    write <= 3; 
  else if(write == 3)
    write <= 4;    
  else if(bo_end & bi_next & write == 4) 
    write <= 5; 
  else if(write == 5)
    write <= 6;  
    
reg [31:0] pix_cnt;
always@(posedge clk)
  if(rst)
    pix_cnt <= 0;
  else if(bo_end & bi_next)  
    pix_cnt <= 0;
  else if(bo_we & bi_next)  
    pix_cnt <= pix_cnt + 1;

wire [31:0] a = pix_cnt / 256;
wire [31:0] b = pix_cnt % 256;
wire [31:0] x = a % 64 * 16 + b % 16;
wire [31:0] y = a / 64 * 16 + b / 16;    
    
integer j;
integer file,file2,file3;

reg [7:0] rr [681983 : 0];
reg [7:0] gg [681983 : 0];
reg [7:0] bb [681983 : 0];


always@(posedge clk)
  if(bi_next & bo_we)begin
  	rr[y*1024 + x] <= bo_data[31:24];
  	gg[y*1024 + x] <= bo_data[23:16];
  	bb[y*1024 + x] <= bo_data[15:8];
  end 




always@(posedge clk)
  if(rst)begin
  	file = $fopen("a.pgm","w");
  	file2 = $fopen("b.pgm","w");
  	file3 = $fopen("c.pgm","w");
  	$fdisplay (file,"%s","P3");
  	$fdisplay (file,"1024 666");	
  	$fdisplay (file,"%s","#spicec dump");
		$fdisplay (file,"255");	
		$fdisplay (file2,"%s","P3");
  	$fdisplay (file2,"1024 666");	
  	$fdisplay (file2,"%s","#spicec dump");
		$fdisplay (file2,"255");	
		$fdisplay (file3,"%s","P3");
  	$fdisplay (file3,"1024 666");	
  	$fdisplay (file3,"%s","#spicec dump");
		$fdisplay (file3,"255");
  end else if(write == 1)begin
  	for(j=0;j<681984;j=j+1)begin
  		$fdisplay (file,"%d", rr[j]);
  		$fdisplay (file,"%d", gg[j]);
  		$fdisplay (file,"%d", bb[j]);
  	end 
  	$fclose(file);
  end else if(write == 3)begin
  	for(j=0;j<681984;j=j+1)begin
  		$fdisplay (file2,"%d", rr[j]);
  		$fdisplay (file2,"%d", gg[j]);
  		$fdisplay (file2,"%d", bb[j]);
  	end 
  	$fclose(file2);
  end else if(write == 5)begin
  	for(j=0;j<681984;j=j+1)begin
  		$fdisplay (file3,"%d", rr[j]);
  		$fdisplay (file3,"%d", gg[j]);
  		$fdisplay (file3,"%d", bb[j]);
  	end 
  	$fclose(file3);
  end


endmodule