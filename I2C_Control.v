module I2C_Control
(
	CLOCK,
	I2C_SCLK,
	I2C_SDAT,
	DATA_REG,
	START_TX,
	TX_DONE,
	ACK
);

output I2C_SCLK;
inout I2C_SDAT;
output TX_DONE;
output ACK;
input [23:0] DATA_REG;		// 8 [ device addr ] + 8 [ sub address] + 8 [data]

wire [23:0] DATA_REG;
reg [23:0] data;
input CLOCK;
input START_TX;

wire START_TX;
wire CLOCK;
wire TX_DONE;

wire I2C_SCLK;
wire I2C_SDAT;

reg [5:0] step;
reg sdat;
reg sclk;
reg sclk_enable;


// we need these to determine our ack value; we will send 3 chunks of eight, each byte
// needs acknowledgement
reg ack1;
reg ack2;
reg ack3;
reg done;

assign ACK = ~( ack1 | ack2 | ack3);
assign I2C_SDAT=sdat?1'bz:1'b0 ;
assign I2C_SCLK = (step == 33 ? 1'b1 : sclk | (sclk_enable ? ~CLOCK : 1'b0));
assign TX_DONE = done;

// we will want the i2c clock to be one-off from whatever clock we're using to drive our writing 
// to I2C_SDAT

initial
begin
	step <= 33;
	ack1 = 1;
	ack2 = 1;
	ack3 = 1;
end
always @(posedge CLOCK)
begin
	if(START_TX)
	begin
		if(step == 33)
		begin
			data <= DATA_REG;
			step <= 0;
			sdat = 1;
			sclk = 1;
		end
	end
	if(CLOCK)
	begin
		if(step != 33)
		begin
			case(step)
				0: begin ack1 = 1; ack2 = 1; ack3 = 1; sclk_enable = 0; sdat = 1; sclk = 1; end
				// indicate packet transmit (sdat low, then sclk)
				1: sdat = 0;
				2: sclk = 0; 
				// first word
				3: begin sdat = data[23]; sclk_enable = 1; end
				4: sdat = data[22];
				5: sdat = data[21];
				6: sdat = data[20];
				7: sdat = data[19];
				8: sdat = data[18];
				9: sdat = data[17];
				10: sdat = data[16];
				// set up for ack
				11: sdat = 1; 

				12: begin ack1 = I2C_SDAT; sdat = data[15];   end
				13: sdat = data[14];
				14: sdat = data[13];
				15: sdat = data[12];
				16: sdat = data[11];
				17: sdat = data[10];
				18: sdat = data[9];
				19: sdat = data[8];
				// set up for ack
				20: sdat = 1;
				
				21: begin  ack2 = I2C_SDAT; sdat = data[7];  end
				22: sdat = data[6];
				23: sdat = data[5];
				24: sdat = data[4];
				25: sdat = data[3];
				26: sdat = data[2];
				27: sdat = data[1];
				28: sdat = data[0];
				// last ack! 
				29: sdat = 1;
				
				// stop xfer
				30: begin   ack3 = I2C_SDAT; sclk_enable = 1'b0; sdat = 1'b0; sclk = 1'b0;  end
				31: begin done = 1'b1; sclk = 1'b1;end			// signal xfer complete (sclk transitions to 1, *then* sdat transitions)
				32: begin done = 1'b0; sdat = 1'b1; end
			endcase
			step <= step + 1'b1;
		end
	end
end

endmodule