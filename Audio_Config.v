module Audio_Config
(
	CLOCK,
	I2C_SCLK,
	I2C_SDAT
);

input CLOCK;

inout I2C_SDAT;

output I2C_SCLK;

wire CLOCK;
wire PRE_CLOCK;
wire START_TX;
wire TX_DONE;
wire ACK;


wire [23:0]  DATA;

parameter prescale = 2500;


	//	Audio Config Data
	
	// I based the choice of configuration options pretty heavily on the example code given. I've removed some of their unnecessary stuff. 
	
	parameter dev_addr = 8'h34;
	parameter audio_path =	16'h0A04;
	parameter dac_sel = 16'h0810;	
	parameter power =	16'h0C00;
	parameter data_format =	16'h0E01; 
	parameter sampling =	16'h1002;
	parameter activate =	16'h1201;

	parameter num_states = 11;
reg start_tx;
reg [23:0] data;
reg [7:0] state;
reg [3:0] step;

initial 
begin
	state = 0;
	data[23:0] <= {dev_addr, audio_path};
	start_tx <= 1;
end

always @(posedge ACK)
begin
	state <= state + 1'b1;
end
always @(posedge TX_DONE)
begin
start_tx <= 0;
	case(state)
		1: 
		begin
			data[23:0] <= {dev_addr, dac_sel};
			start_tx <= 1'b1;
		end
		2:
		begin
			data[23:0] <= {dev_addr, power};
			start_tx <=1'b1;
		end
		3: 
		begin
			data[23:0] <= {dev_addr, data_format};
			start_tx <=1'b1;
		end
		4: 
		begin
			data[23:0] <= {dev_addr, sampling};
			start_tx <= 1'b1;
		end
		5:
		begin
			data[23:0] <= {dev_addr, activate};
			start_tx <= 1'b1;
		end
		/*
		4: 
		begin
			data[23:0] <= {dev_addr, e};
			start_tx <=1'b1;
		end
		5: 
		begin
			data[23:0] <= {dev_addr, f};
			start_tx <=1'b1;
		end
		6: 
		begin
			data[23:0] <= {dev_addr, g};
			start_tx <=1'b1;
		end
		7: 
		begin
			data[23:0] <= {dev_addr, h};
			start_tx <=1'b1;
		end
		8: 
		begin
			data[23:0] <= {dev_addr, i};
			start_tx <=1'b1;
		end
		9: 
		begin
			data[23:0] <= {dev_addr, j};
			start_tx <=1'b1;
		end
		10: 
		begin
			data[23:0] <= {dev_addr, k};
			start_tx <=1'b1;
		end
		*/
	endcase
end

assign DATA = data;
assign START_TX = start_tx;
PRESCALER i2c_pre (CLOCK, PRE_CLOCK, prescale);
I2C_Control i2c_ctrl (PRE_CLOCK, I2C_SCLK, I2C_SDAT, DATA, START_TX, TX_DONE, ACK);

endmodule