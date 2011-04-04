/* 
	So, here it is.
	
	What works:
		Audio output. This is accomplished via the following:
			Audio_Config communicates with the device and sets the requisite values. 
				I2C...
			Audio handles having a sophisticated discussion with the DAC and convincing it to make pretty waves. 
			
			Funny story about audio: At first, I didn't have to configure it at all! This was quite upsetting seeing as I had spent ages on the I2C driver, 
			and I was a little confused. Fortunately, I suspected that the audio chip was remembering the sample code's configuration (which was permanently loaded on the device,
			whereas mine was programmed via JTAG), which made me test programming the code on the device permanently. Of course it broke, but it made me fix my I2C driver. 
		
		Sequencing
			Beat_Clock handles the stepping. Note-playing logic is largely assigned in this module for convenience. There is still a couple bugs, but 
			they do not hinder usability too extremely.
			
			'Tempo' (and I use that term loosely) can be modified. It sounds good, but it isn't standard tempos. 
			
			There is an 'octave' of available notes. This is signalled to the DAC via the NOTE register, and simply modifies the period of the wave
			to accomplish the change in tone. It sounds excellently 8-bit. 
		
			Volume is not working properly. I assumed that simply reducing the cap value of the square wave would accomplish a decrease, but it does 
			not behave regularly. It is not too high of a priority - hopefully the classroom speakers have a volume control. 
			
			Note that it is possible to set and store a sequence of notes and swap between that and 'live input' when sequencing. (hence CURR_NOTE_VALUE and STORED_NOTE_VALUE)
			
		VGA
			I have the VGA tied to the beat clock somewhat. Every 'cycle' (8 steps), the color of the 'background' changes. If a note is being played, 
			the screen turns to white. This was my visual indicator that everything was okay, before audio came in and rocked the house. 
	
			
*/
			
			


module Sequencer
(
	CLOCK_50,
	I2C_SCLK,
	I2C_SDAT,
	LEDR,
	LEDG,
	AUD_DACLRCK,					//	Audio CODEC DAC LR Clock
	AUD_DACDAT,						//	Audio CODEC DAC Data
	AUD_BCLK,						//	Audio CODEC Bit-Stream Clock
	AUD_XCK,						//	Audio CODEC Chip Clock
	VGA_R,
	VGA_G,
	VGA_B,
	VGA_HS,
	VGA_VS,
	KEY,
	SW
);
input CLOCK_50;
inout I2C_SDAT;
output I2C_SCLK;
output [9:0] LEDR;
output [7:0] LEDG;
input [9:0] SW;
input [3:0] KEY;
output[3:0] VGA_R, VGA_G, VGA_B;
output VGA_HS;
output VGA_VS;

wire [3:0] wVGA_R, wVGA_G, wVGA_B;
wire [7:0] STEP_REG;
wire VGA_ENABLE;
wire STEP_ENABLE;
wire ENABLE;
wire BEAT_CLOCK;
wire [3:0] STEP_NUM;
wire [15:0]	VOLUME;
wire [4:0]	BEAT_PRESCALER;
wire NOTE_KEY_DOWN;

assign LEDR[9:2] = LED_SEQ;
assign	I2C_SDAT	=	1'bz;
assign	AUD_XCK		=	CLOCK_13_5;

output	AUD_DACLRCK;			
output	AUD_DACDAT;				
inout		AUD_BCLK;			
output	AUD_XCK;				


wire [7:0] LED_SEQ = STEP_ENABLE ? STEP_REG : SW[9:2];

wire [3:0] NOTE = PLAY_NOTE ? (SW[0] ? CURR_NOTE_VALUE : STORED_NOTE_VALUE) : 4'b0000;
wire [3:0] CURR_NOTE_VALUE;
wire PLAY_NOTE = STEP_ENABLE && SW[0] && (STEP_REG & SW[9:2]) ? 1'b1 : (!SW[1] && NOTE_KEY_DOWN && SW[0] ? 1'b1 : (!SW[0] && STORED_NOTES[STEP_NUM] && STEP_ENABLE));
wire			CLOCK_13_5;
wire CLOCK_50;
reg [3:0] STORED_NOTE_VALUE;
reg [3:0] STORED_NOTES [7:0];
wire I2C_SDAT;
wire I2C_SCLK;

always @(negedge NOTE_KEY_DOWN)
begin
	if(!SW[1] && SW[0])
	begin
		STORED_NOTES[0] = SW[9] ? CURR_NOTE_VALUE : STORED_NOTES[0];
		STORED_NOTES[1] = SW[8] ? CURR_NOTE_VALUE : STORED_NOTES[1];
		STORED_NOTES[2] = SW[7] ? CURR_NOTE_VALUE : STORED_NOTES[2];
		STORED_NOTES[3] = SW[6] ? CURR_NOTE_VALUE : STORED_NOTES[3];
		STORED_NOTES[4] = SW[5] ? CURR_NOTE_VALUE : STORED_NOTES[4];
		STORED_NOTES[5] = SW[4] ? CURR_NOTE_VALUE : STORED_NOTES[5];
		STORED_NOTES[6] = SW[3] ? CURR_NOTE_VALUE : STORED_NOTES[6];
		STORED_NOTES[7] = SW[2] ? CURR_NOTE_VALUE : STORED_NOTES[7];
	end
end

always @(STEP_NUM)
begin
	STORED_NOTE_VALUE = STORED_NOTES[STEP_NUM];
end

assign LEDG[7:4] = STORED_NOTE_VALUE;
assign LEDG[3:0] = CURR_NOTE_VALUE;

Audio_Config audio_config(CLOCK_50, I2C_SCLK, I2C_SDAT);
BEAT_Clock beat_clock(CLOCK_50, BEAT_CLOCK, BEAT_PRESCALER);
Stepper stepper (STEP_REG, BEAT_CLOCK, STEP_ENABLE, STEP_NUM);
VGA_It_Up_VSync viuvs (CLOCK_50, VGA_VS, VGA_ENABLE);
VGA_It_Up_HSync viuhs(CLOCK_50, VGA_R, VGA_G, VGA_B, VGA_HS, wVGA_R, wVGA_G, wVGA_B, VGA_ENABLE);
VGA_Color_Switcher vcs (wVGA_R, wVGA_G, wVGA_B, STEP_REG, PLAY_NOTE);
PRESCALER prescaler(CLOCK_50, CLOCK_13_5, 2);
Audio	audio (AUD_BCLK, AUD_DACDAT, AUD_DACLRCK, CLOCK_13_5, NOTE, VOLUME);
Value_Control value_control (
	SW[1:0],
	KEY,
	VOLUME,
	CURR_NOTE_VALUE, 
	BEAT_PRESCALER,
	STEP_ENABLE,
	NOTE_KEY_DOWN
);
endmodule
