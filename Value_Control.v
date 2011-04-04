module Value_Control
(
	SW,
	KEY,
	VOLUME,
	NOTE, 
	BEAT_PRESCALER,
	SEQUENCER_ENABLE,
	NOTE_KEY_DOWN
);
	input [1:0] SW; 
	input [3:0] KEY;
	
	output [15:0] VOLUME; 
	output [3:0] NOTE = note;
	output [4:0] BEAT_PRESCALER = beat_prescaler[4:0];
	output SEQUENCER_ENABLE;
	output NOTE_KEY_DOWN;
	
	wire [3:0] NOTE;
	
	reg [8:0] beat_prescaler; 
	reg [3:0] note; 
	reg [15:0] volume;

	parameter NOTE_MIN = 4'd0;
	parameter NOTE_CAP = 4'd12;
	parameter VOLUME_CAP = 32500;
	parameter VOLUME_MIN = 25000;
	parameter VOLUME_STEP = 500;
	parameter BEAT_CAP = 31;
	
	assign VOLUME = volume;
	assign SEQUENCER_ENABLE = SW[1];
	initial
	begin
		beat_prescaler = 4;
		note = NOTE_MIN;
		volume = 32000;
	end 
	wire NOTE_KEY_DOWN = !(KEY[3] & KEY[2]);
	
	
	always @(posedge NOTE_KEY_DOWN)
	begin
			if(!KEY[3])
			begin
				// note down
				if(note > NOTE_MIN)
				begin
					note[3:0] = note[3:0] - 1'b1;
				end
			end 
			else 
			begin
				if(note < NOTE_CAP)
				begin
					note[3:0] = note[3:0] + 1'b1;
				end
			end 
	end 
	
	always @(negedge (KEY[1] & KEY[0]))
		if(!KEY[1])
		begin
			if(beat_prescaler < BEAT_CAP)
				beat_prescaler = beat_prescaler + 1'b1;
		end 
		else 
		begin
			if(beat_prescaler > 0)
			begin
					beat_prescaler = beat_prescaler - 1'b1;
			end
	end		
endmodule