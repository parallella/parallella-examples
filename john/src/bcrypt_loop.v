/*
 * This file is part of John the Ripper password cracker,
 * Copyright (c) 2013, 2014 by Katja Malvoni <kmalvoni at gmail dot com>
 * It is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, 
 * with or without modification, are permitted.
 */

module bcrypt_loop
(
	clk,
	wea, 
	weaS, 
	web, 
	webS,
	addra, 
	addraS, 
	addrb, 
	addrbS,
	dina, 
	dinaS, 
	dinb, 
	dinbS,
	douta, 
	doutaS, 
	doutb, 
	doutbS,
	start,
	done
);

parameter INIT				= 4'b0000;
parameter P_XOR_EXP			= 4'b0001;
parameter ENCRYPT_INIT			= 4'b0010;
parameter FEISTEL			= 4'b0011;
parameter STORE_L_R			= 4'b0100;
parameter P_XOR_SALT			= 4'b0101;
parameter LOOP				= 4'b0110;
parameter DONE				= 4'b0111;
parameter SET				= 4'b1000;
parameter LOAD_S			= 4'b1100;
parameter UPDATE_L_R			= 4'b1101;

parameter C_MST_NATIVE_DATA_WIDTH      = 32;
parameter C_LENGTH_WIDTH               = 12;
parameter C_MST_AWIDTH                 = 32;
parameter C_NUM_REG                    = 6;
parameter C_SLV_DWIDTH                 = 32;

input 	clk;
output	wea;
output 	weaS;
output 	web;
output 	webS;
output  [9:0] addraS;
output  [9:0] addrbS;
output  [5:0] addra;
output  [5:0] addrb;
output  [31:0] dina;
output  [31:0] dinaS;
output  [31:0] dinb;
output  [31:0] dinbS;
input   [31:0] douta;
input   [31:0] doutaS;
input   [31:0] doutb;
input   [31:0] doutbS;
input	start;
output	done;
  
reg done_reg;
reg [4:0] P_index = 0;
reg [10:0] S_index = 0;
reg [4:0] ROUND_index = 0;
reg [10:0] ptr = 0;
reg tmp_cnt = 0;
reg first_or_second = 0;
reg P_or_S = 0;
reg [1:0] mem_delay = 0;
reg [31:0] count = 0;

reg [31:0] L = 0;
reg [31:0] R = 0;
reg [31:0] tmp1 = 0;
reg [3:0] state = INIT;
reg [3:0] substate1 = SET;
reg [3:0] substate3 = 0;
		
reg wea_1, web_1, wea_2, web_2;
reg [5:0] addra_1, addrb_1;
reg [9:0] addra_2, addrb_2;
reg [31:0] dina_1, dinb_1;
reg [31:0] dina_2, dinb_2;

assign done = done_reg;

assign wea = wea_1;
assign weaS = wea_2;
assign web = web_1;
assign webS = web_2;
assign addra = addra_1;
assign addraS = addra_2;
assign addrb = addrb_1;
assign addrbS = addrb_2;
assign dina = dina_1;
assign dinaS = dina_2;
assign dinb = dinb_1;
assign dinbS = dinb_2;

always @(*)
begin
	wea_1 <= 0;
	web_1 <= 0;
	addra_1 <= 0;
	addrb_1 <= 0;
	dina_1 <= 0;
	dinb_1 <= 0;
	wea_2 <= 0;
	web_2 <= 0;
	addra_2 <= 0;
	addrb_2 <= 0;
	dina_2 <= 0;
	dinb_2 <= 0;
	if(state == INIT) begin
		if(mem_delay < 'd1)
			addra_1 <= 6'd40;
	end
	else if(state == P_XOR_EXP) begin
		if(mem_delay < 'd1) begin
			addra_1 <= P_index;
			addrb_1 <= 6'd18 + P_index;
		end
		else begin
			wea_1 <= 1;
			addra_1 <= P_index;
			dina_1 <= douta ^ doutb;
		end
	end
	else if(state == ENCRYPT_INIT) begin
		if(mem_delay == 'd1) begin
			addra_1 <= 'd1;
			addra_2[9:8] <= 2'b00;
			addrb_2[9:8] <= 2'b01;
			addra_2[7:0] <= L[31:24] ^ douta[31:24];
			addrb_2[7:0] <= L[23:16] ^ douta[23:16];
		end
	end
	else if(state == FEISTEL) begin
		if(mem_delay == 0) begin
			addra_2[9:0] <= 'h200 + L[15:8];
			addrb_2[9:0] <= 'h300 + L[7:0];
			if(ROUND_index == 'd15)
				addra_1 <= 'd17;
		end
		else begin
			addra_1 <= ROUND_index + 'd2;
			addra_2[9:8] <= 2'b00;
			addrb_2[9:8] <= 2'b01;
			addra_2[7:0] <= ((R ^ ((tmp1 ^ doutaS) + doutbS))&32'hFF000000)>>24;
			addrb_2[7:0] <= ((R ^ ((tmp1 ^ doutaS) + doutbS))&32'h00FF0000)>>16;
		end
	end
	else if(state == STORE_L_R) begin
		if(ptr < 'd18) begin
			wea_1 <= 1;
			web_1 <= 1;
			dina_1 <= L;
			dinb_1 <= R;
			addra_1 <= ptr;
			addrb_1 <= ptr + 'd1;
		end
		else if (ptr >= 'd18 && ptr < 'd1042) begin
			wea_2 <= 1;
			web_2 <= 1;
			dina_2 <= L;
			dinb_2 <= R;
			addra_2 <= ptr - 'd18;
			addrb_2 <= ptr - 'd17;
		end
	end
	else if(state == P_XOR_SALT) begin
		if(mem_delay < 'd1) begin
			addra_1 <= P_index;
			addrb_1 <= 6'd36 + P_index%'d4;
		end
		else begin
			wea_1 <= 1;
			addra_1 <= P_index;
			dina_1 <= douta ^ doutb;
		end
	end
end

always @ (posedge clk)
begin
	if (start == 1) begin
		if(state == INIT) begin
			if(mem_delay < 'd1) begin
				mem_delay <= mem_delay + 'd1;
			end
			else begin
				count <= douta;
				mem_delay <= 0;
				state <= SET;
			end
		end
		else if(state == SET) begin
			count <= 'd1 << count;
			state <= P_XOR_EXP;
		end
		else if(state == P_XOR_EXP) begin
			if(P_index < 5'd18) begin
				if(mem_delay < 'd1) begin
					mem_delay <= mem_delay + 'd1;
				end
				else begin
					P_index <= P_index + 5'd1;
					mem_delay <= 0;
				end
			end
			else begin
				P_index <= 5'd0;
				L <= 0;
				R <= 0;
				state <= ENCRYPT_INIT;
				ptr <= 0;
			end
		end
		else if(state == ENCRYPT_INIT) begin
			if(mem_delay < 'd1) begin
				mem_delay <= mem_delay + 'd1;
			end
			else begin
				mem_delay <= 3'd0;
				L <= L ^ douta;
				state <= FEISTEL;
			end
		end
		else if(state == FEISTEL) begin
			if(ROUND_index < 15) begin
				if(mem_delay == 0) begin
					tmp1 <= doutaS + doutbS;
					R <= R ^ douta;
					mem_delay <= 'd1;
				end
				else if(mem_delay == 'd1) begin
					L <= R ^ ((tmp1 ^ doutaS) + doutbS);
					R <= L;
					mem_delay <= 0;
					ROUND_index <= ROUND_index + 5'd1;
				end
			end
			else begin
				if(mem_delay == 'd0) begin
					tmp1 <= doutaS + doutbS;
					R <= R ^ douta;
					mem_delay <= 'd1;
				end
				else if(mem_delay == 'd1) begin
					R <= R ^ ((tmp1 ^ doutaS) + doutbS);
					L <= L ^ douta;
					mem_delay <= 0;
					ROUND_index <= 5'd0;
					state <= STORE_L_R;
				end
			end
		end
		else if(state == STORE_L_R) begin
			if(ptr < 'd1042) begin
				ptr <= ptr + 'd2;
				state <= ENCRYPT_INIT;
			end
			else begin
				if(first_or_second == 0) begin
					ptr <= 0;
					P_or_S <= 0;
					first_or_second <= 'b1;
					state <= P_XOR_SALT;
				end
				else begin
					first_or_second <= 'b0;
					state <= LOOP;
					ptr <= 0;
					P_or_S <= 0;
				end
			end	
		end		
		else if(state == P_XOR_SALT) begin
			if(P_index < 5'd18) begin
				if(mem_delay < 'd1) begin
					mem_delay <= mem_delay + 'd1;
				end
				else begin
					P_index <= P_index + 5'd1;
					mem_delay <= 0;
				end
			end
			else begin
				P_index <= 5'd0;
				L <= 0;
				R <= 0;
				state <= ENCRYPT_INIT;
			end
		end
		else if(state == LOOP) begin
			if(count > 1) begin
				count <= count - 32'd1;
				state <= P_XOR_EXP;
			end
			else begin
				state <= DONE;
			end
		end
		else if (state == DONE) begin
			done_reg <= 1;
		end	
	end
	else begin
		count <= 0;
		state <= INIT;
		done_reg <= 0;
	end
end

endmodule