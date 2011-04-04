
				
module VGA_Color_Switcher 
(
	oVGA_R,
	oVGA_G,
	oVGA_B,
	STEP_REG,
	NOTE_PLAYING
);

output [3:0] oVGA_R, oVGA_G, oVGA_B;
input [8:0] STEP_REG;
input NOTE_PLAYING;

reg [3:0] VGA_R;
reg [3:0] VGA_G;
reg [3:0] VGA_B;
reg [2:0] cc;

assign oVGA_R = NOTE_PLAYING ? 3'b111 : VGA_R;
assign oVGA_G = NOTE_PLAYING ? 3'b111 : VGA_G;
assign oVGA_B = NOTE_PLAYING ? 3'b111 : VGA_B;

initial
begin
	cc = 0;
	VGA_R = 0;
	VGA_G = 0;
	VGA_B = 0;
end
always @(posedge STEP_REG[7])
begin

	VGA_R <= 0;
	VGA_G <= 0;
	VGA_B <= 0;
	
	case(cc)
		0: VGA_R <= 3'b111;
		1: VGA_G <= 3'b111;
		2: VGA_B <= 3'b111;
	endcase
	cc <= cc + 1'b1;
	if(cc == 3)
		cc <= 0;
end


endmodule		
