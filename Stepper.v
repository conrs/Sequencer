module Stepper
(
	ACTIVE_STEP,
	CLOCK,
	ENABLE,
	STEP_NUM
);

	reg [8:0] value;
	reg [3:0] step_num;


	input CLOCK;
	input ENABLE;
	output [8 : 0] ACTIVE_STEP;
	output [3:0] STEP_NUM;
	
	wire CLOCK;
	wire ENABLE;
	
	initial 
	begin
		step_num = 0;
	end 
	
	
	
	always @(posedge CLOCK or negedge ENABLE)
	begin
		if(!ENABLE)
		begin
			step_num <= 1'b0;
		end 
		else 
		begin
			step_num = step_num + 1'b1;
			if(step_num == 8)
				step_num <= 1'b0;
		end 
	end 
	
	assign ACTIVE_STEP[8:0] = 8'b10000000 >> STEP_NUM;
	assign STEP_NUM[3:0] = step_num[3:0];
endmodule
