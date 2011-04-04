
module VGA_It_Up_HSync
(
	VGA_CLOCK, 
	oVGA_R, 
	oVGA_G, 
	oVGA_B, 
	VGA_HS, 
	iVGA_R,
	iVGA_G,
	iVGA_B,
	ENABLE
);
input VGA_CLOCK;
input ENABLE; 

input [3:0] iVGA_R, iVGA_G, iVGA_B;
output [3:0] oVGA_R, oVGA_G, oVGA_B;
output VGA_HS;
wire ENABLE;
reg vga_hs;

reg[15:0] HSync_Counter;


assign oVGA_R = ENABLE ? (HSync_Counter > A_TIME + B_TIME && HSync_Counter <= A_TIME+B_TIME+C_TIME ? iVGA_R : 1'b0) : 1'b0;
assign oVGA_G = ENABLE ? (HSync_Counter > A_TIME + B_TIME && HSync_Counter <= A_TIME+B_TIME+C_TIME ? iVGA_G :1'b0) : 1'b0;
assign oVGA_B = ENABLE ? (HSync_Counter > A_TIME + B_TIME && HSync_Counter <= A_TIME+B_TIME+C_TIME ? iVGA_B :1'b0) : 1'b0;

assign VGA_HS = ENABLE ? vga_hs : ENABLE; 
// define a set of states to transition between
initial
begin
	vga_hs = 1; 
	HSync_Counter <= 0;
end

parameter A_TIME = 190, B_TIME = 90, C_TIME = 1285, D_TIME = 5;
always @(posedge VGA_CLOCK)
begin
	// Need to know when to go low and when to reset. 
	
	HSync_Counter <= HSync_Counter + 1'b1;
	
	if(ENABLE == 0)
	begin
		HSync_Counter <= 0;
	end 
	else 
	begin
		if(HSync_Counter <= A_TIME)
		begin
			vga_hs <= 0;
		end 
		else if(HSync_Counter <= A_TIME+B_TIME)
		begin
			vga_hs <= 1;

		end 
		else if(HSync_Counter <= A_TIME+B_TIME+C_TIME)
		begin
		// this is irrelevant now (handled in the assign)
		end 
		else if(HSync_Counter <=  A_TIME+B_TIME+C_TIME+D_TIME)
		begin
			// this is irrelevant now
		end
		else
		begin
			HSync_Counter <= 0;
		end 
		
		
	end

	
		
end 

endmodule		