
module PRESCALER
(
	CLOCK_50,
	oCLOCK,
	PRESCALER
);

input CLOCK_50;
input [26:0] PRESCALER;
output oCLOCK;


wire CLOCK_50;

reg clock;
reg [26:0] count;
// note: this will half the frequency with a prescaler of 0 
// with a prescaler of 1, will 1/4 it. 
always @(posedge CLOCK_50)
begin
	if(count >= PRESCALER)
	begin
		clock <= ~clock;
		count <= 0;
	end 
	else 
	begin
		count <= count + 1'b1;
	end 
end

assign oCLOCK = clock;

endmodule