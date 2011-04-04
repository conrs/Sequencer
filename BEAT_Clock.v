

/* Beat clock simply provides a clock of frequency 100 Hz 
	Apparently people love BPM, which can be translated to BPS,
	which can be triggered by this. Most of the time, it is something like 2. I
	will have to handle smaller values eventually, but that should not be too too bad. 
*/
module BEAT_Clock (
	CLOCK_50,
	BEAT_CLOCK,
	BEAT_PRESCALER
);
input CLOCK_50;
input[4:0] BEAT_PRESCALER;
wire CLOCK_50;
output BEAT_CLOCK;


reg beat_clock;
reg [12:0] ticks;

parameter prescaler = 27'd500000;
wire [26:0] PRESCALER = prescaler;

initial
begin
	beat_clock = 0;
	count = 0;
end 

reg [26:0] count;
wire CLOCK_X;

// note: this will half the frequency with a prescaler of 0 
// with a prescaler of 1 etc works 
always @(posedge CLOCK_X)
begin
	if(count >= BEAT_PRESCALER)
	begin
		beat_clock <= ~beat_clock;
		count <= 0;
	end 
	else 
	begin
		count <= count + 1'b1;
	end 
end

PRESCALER beat_pre (CLOCK_50, CLOCK_X, PRESCALER);

assign BEAT_CLOCK = beat_clock;
endmodule