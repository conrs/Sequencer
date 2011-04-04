
module Audio (	//	Memory Side
					//	Audio Side
					oAUD_BCK,
					oAUD_DATA,
					oAUD_LRCK,
					//	Control Signals
				    iCLK,
					 NOTE,
					 VOLUME
					);				

output			oAUD_DATA;
output			oAUD_LRCK;
output			oAUD_BCK;
//	Control Signals
input			iCLK;
input [3:0] NOTE;

input[15:0] VOLUME;
reg [DATA_SIZE:0] data; 
reg [5:0] data_index;
reg [13:0] counter; 
reg [DATA_SIZE:0] data_cap;

reg[13:0] period_amt;// = STEP_START - (step * STEP);

wire [1:0] KEY;
wire [3:0] NOTE;

wire KEY1;
wire KEY0;

parameter DATA_SIZE = 16;

// the letters aren't accurate, but they are in order! 
parameter c = 14'd2093;
parameter b = 14'd1975;
parameter as = 14'd1864;
parameter a = 14'd1760;
parameter gs = 14'd1661;
parameter g = 14'd1567;
parameter fs = 14'd1479;
parameter f = 14'd1396;
parameter e =14'd1318;
parameter ds = 14'd1244;
parameter d = 14'd1174;
parameter cs = 14'd1108;

wire ENABLE = NOTE == 0? 1'b0 : 1'b1;


assign oAUD_LRCK = ENABLE ? cCLK : 1'b0;
assign oAUD_BCK = ENABLE ? iCLK : 1'b0;	// bit clock 
assign oAUD_DATA = ENABLE ? data[data_index] : 1'b0;

initial begin
	counter = 1'b0;
	data_index = 1'b0;
	// My code is probably a little screwed up, this value yields the best tone, varying it does 
	// not yield expected results
	data_cap = 16'd65532;
end

wire sCLK;
wire cCLK;

PRESCALER dataclk (iCLK, sCLK, DATA_SIZE);
PRESCALER lrclk (sCLK, cCLK, 2);

always @(NOTE)
begin
	case(NOTE)
		4'b0000: period_amt = 1;
		4'b0001: period_amt = c;
		4'b0010: period_amt = b;
		4'b0011: period_amt = as;
		4'b0100: period_amt = a;
		4'b0101: period_amt = gs;
		4'b0110: period_amt = g;
		4'b0111: period_amt = fs;
		4'b1000: period_amt = f;
		4'b1001: period_amt = e;
		4'b1010: period_amt = ds;
		4'b1011: period_amt = d;
		4'b1100: period_amt = cs;
		default: period_amt = 1;
	endcase
end

always @(posedge iCLK)
begin
	data_index <= data_index + 1'b1;
	if(data_index == DATA_SIZE)
	begin
		data_index <= 1'b0;
	end
end 

always @(posedge sCLK)
begin
	if(counter < period_amt / 2)
	begin
		data <= data_cap;
	end
	else if(counter < period_amt)
	begin
		data <= 0;
	end
	else
	begin
		counter = 0;
	end
	counter <= counter + 1'b1;
	
end





//////////////////////////////////////////////////

endmodule
