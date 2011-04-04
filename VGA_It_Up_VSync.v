module VGA_It_Up_VSync 
(
	VGA_CLOCK,
	VGA_VS,
	ENABLE
);

input VGA_CLOCK;
wire VGA_CLOCK;
output VGA_VS;
output ENABLE;

reg[27:0] VSync_Counter;

assign VGA_VS = VSync_Counter <= VSYNC_DOWN_WAIT ? 1'b0 : 1'b1;
assign ENABLE = (VSync_Counter > VSYNC_DOWN_WAIT+RGB_DOWN_WAIT && 
					  VSync_Counter <= VSYNC_DOWN_WAIT+RGB_DOWN_WAIT+RGB_UP_WAIT+END_WAIT_WAIT) ?
					  1'b1 :
					  1'b0 ;
parameter HSYNC_TOTAL = 1575;
parameter VSYNC_DOWN_WAIT = (4*HSYNC_TOTAL) - 1, RGB_DOWN_WAIT = (30*HSYNC_TOTAL), RGB_UP_WAIT = (480*HSYNC_TOTAL), END_WAIT_WAIT = 10*HSYNC_TOTAL;


initial 
begin
	VSync_Counter = 0;
end 

always @(posedge VGA_CLOCK)
begin
	// Need to know when to go low and when to reset. 
	VSync_Counter <= VSync_Counter + 1'b1;

	if (VSync_Counter >= VSYNC_DOWN_WAIT+RGB_DOWN_WAIT+RGB_UP_WAIT+END_WAIT_WAIT)
	begin
		VSync_Counter <= 0;
	end 
end 


endmodule
