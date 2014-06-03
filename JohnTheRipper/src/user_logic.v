/*
 * This file is part of John the Ripper password cracker,
 * Copyright (c) 2014 by Katja Malvoni <kmalvoni at gmail dot com>
 * It is hereby released to the general public under the following terms:
 * Redistribution and use in source and binary forms, 
 * with or without modification, are permitted.
 */

module user_logic
(
  Bus2IP_Clk,                     // Bus to IP clock
  Bus2IP_Resetn,                  // Bus to IP reset
  Bus2IP_Addr,                    // Bus to IP address bus
  Bus2IP_CS,                      // Bus to IP chip select for user logic memory selection
  Bus2IP_RNW,                     // Bus to IP read/not write
  Bus2IP_Data,                    // Bus to IP data bus
  Bus2IP_BE,                      // Bus to IP byte enables
  Bus2IP_RdCE,                    // Bus to IP read chip enable
  Bus2IP_WrCE,                    // Bus to IP write chip enable
  Bus2IP_Burst,                   // Bus to IP burst-mode qualifier
  Bus2IP_BurstLength,             // Bus to IP burst length
  Bus2IP_RdReq,                   // Bus to IP read request
  Bus2IP_WrReq,                   // Bus to IP write request
  Type_of_xfer,                   // Transfer Type
  IP2Bus_AddrAck,                 // IP to Bus address acknowledgement
  IP2Bus_Data,                    // IP to Bus data bus
  IP2Bus_RdAck,                   // IP to Bus read transfer acknowledgement
  IP2Bus_WrAck,                   // IP to Bus write transfer acknowledgement
  IP2Bus_Error                    // IP to Bus error response ------------------
);

parameter C_SLV_AWIDTH                   = 32;
parameter C_SLV_DWIDTH                   = 32;
parameter C_NUM_MEM                      = 3;
parameter NUM_CORES			  = 70;

input                                     Bus2IP_Clk;
input                                     Bus2IP_Resetn;
input      [C_SLV_AWIDTH-1 : 0]           Bus2IP_Addr;
input      [C_NUM_MEM-1 : 0]              Bus2IP_CS;
input                                     Bus2IP_RNW;
input      [C_SLV_DWIDTH-1 : 0]           Bus2IP_Data;
input      [C_SLV_DWIDTH/8-1 : 0]         Bus2IP_BE;
input      [C_NUM_MEM-1 : 0]              Bus2IP_RdCE;
input      [C_NUM_MEM-1 : 0]              Bus2IP_WrCE;
input                                     Bus2IP_Burst;
input      [7 : 0]                        Bus2IP_BurstLength;
input                                     Bus2IP_RdReq;
input                                     Bus2IP_WrReq;
input                                     Type_of_xfer;
output                                    IP2Bus_AddrAck;
output     [C_SLV_DWIDTH-1 : 0]           IP2Bus_Data;
output                                    IP2Bus_RdAck;
output                                    IP2Bus_WrAck;
output                                    IP2Bus_Error;

parameter NUM_BYTE_LANES = (C_SLV_DWIDTH+7)/8;
reg [5 : 0] mem_address_o [NUM_CORES : 0];
reg [9 : 0] mem_address_s [NUM_CORES : 0];
wire [C_NUM_MEM - 1 : 0] mem_select;
wire [C_NUM_MEM - 1 : 0] mem_read_enable;
reg  [C_SLV_DWIDTH-1 : 0] mem_ip2bus_data;
reg [C_NUM_MEM - 1 : 0] mem_read_ack_dly1;
reg [C_NUM_MEM - 1 : 0] mem_read_ack_dly2; 
wire[C_NUM_MEM - 1 : 0]  mem_read_ack; 
wire [C_NUM_MEM - 1 : 0] mem_write_ack; 
reg [NUM_BYTE_LANES-1 : 0] write_enable [C_NUM_MEM - 1 : 0];
reg [C_SLV_DWIDTH-1 : 0] data_in [C_NUM_MEM-1 : 0];

reg [C_SLV_DWIDTH-1 : 0] mem_handshake [1 : 0];
wire [NUM_CORES : 0] wea_o;
wire [NUM_CORES : 0] wea_s;
wire [NUM_CORES : 0] wea_PL_o;
reg [NUM_CORES : 0] wea_PS_o;
wire [NUM_CORES : 0] wea_PL_s;
reg [NUM_CORES : 0] wea_PS_s;
wire [NUM_CORES : 0] web_o;
wire [NUM_CORES : 0] web_s;
wire [5:0] addra_o [NUM_CORES : 0];
wire [9:0] addra_s [NUM_CORES : 0];
wire [5:0] addra_PL_o [NUM_CORES : 0];
wire [9:0] addra_PL_s [NUM_CORES : 0];
wire [5:0] addrb_o [NUM_CORES : 0];
wire [9:0] addrb_s [NUM_CORES : 0];
wire [31:0] dina_o [NUM_CORES : 0];
wire [31:0] dina_s [NUM_CORES : 0];
reg [31:0] dina_PS_o [NUM_CORES : 0];
reg [31:0] dina_PS_s [NUM_CORES : 0];
wire [31:0] dina_PL_o [NUM_CORES : 0];
wire [31:0] dina_PL_s [NUM_CORES : 0];
wire [31:0] dinb_o [NUM_CORES : 0];
wire [31:0] dinb_s [NUM_CORES : 0];
wire [31:0] douta_o [NUM_CORES : 0];
wire [31:0] douta_s [NUM_CORES : 0];
reg [31:0] douta_PL;
wire [31:0] doutb_o [NUM_CORES : 0];
wire [31:0] doutb_s [NUM_CORES : 0];
reg [NUM_CORES - 1 : 0] start = 0;
wire [NUM_CORES - 1 : 0] bcrypt_done;
reg [NUM_CORES - 1 : 0] done = 0;

wire [6 : 0] core_select_others;
wire [6 : 0] core_select_s;

integer i;
integer byte_index;

assign mem_select = Bus2IP_CS;
assign mem_read_enable = Bus2IP_RdCE;
assign mem_read_ack = (mem_read_ack_dly1 && (!mem_read_ack_dly2));
assign mem_write_ack = Bus2IP_WrCE;
assign core_select_others = (mem_select == 'd2) ? Bus2IP_Addr[14 : 8] : 0;
assign core_select_s = (mem_select == 'd4) ? Bus2IP_Addr[18 : 12] : 0;

genvar t;
generate
	for(t=1;t<=NUM_CORES;t=t+1) begin : control
		assign wea_o[t] = (start[t - 1] == 1) ? wea_PL_o[t] : wea_PS_o[t];
		assign addra_o[t] = (start[t - 1] == 1) ? addra_PL_o[t] : mem_address_o[t];
		assign dina_o[t] = (start[t - 1] == 1) ? dina_PL_o[t] : dina_PS_o[t];
		assign wea_s[t] = (start[t - 1] == 1) ? wea_PL_s[t] : wea_PS_s[t];
		assign addra_s[t] = (start[t - 1] == 1) ? addra_PL_s[t] : mem_address_s[t];
		assign dina_s[t] = (start[t - 1] == 1) ? dina_PL_s[t] : dina_PS_s[t];
	end
endgenerate

assign douta_o[0] = douta_PL;

generate
	for(t=1;t<=NUM_CORES;t=t+1) begin : inst_bcrypt
		ram #(32, 6) mem_other (Bus2IP_Clk, wea_o[t], addra_o[t], dina_o[t], douta_o[t], 
					Bus2IP_Clk, web_o[t], addrb_o[t], dinb_o[t], doutb_o[t]);
		ram #(32, 10) mem_S (Bus2IP_Clk, wea_s[t], addra_s[t], dina_s[t], douta_s[t], 
					Bus2IP_Clk, web_s[t], addrb_s[t], dinb_s[t], doutb_s[t]);
		bcrypt_loop bcrypt (Bus2IP_Clk, wea_PL_o[t], wea_PL_s[t], web_o[t], web_s[t], addra_PL_o[t], addra_PL_s[t], 
					addrb_o[t], addrb_s[t], dina_PL_o[t], dina_PL_s[t], dinb_o[t], dinb_s[t], 
					douta_o[t], douta_s[t], doutb_o[t], doutb_s[t], start[t - 1], bcrypt_done[t - 1]);
	end
endgenerate

generate
	for(t=0;t<NUM_CORES;t=t+1) begin : check_done			
		always @(posedge Bus2IP_Clk)
		begin
			if(bcrypt_done[t] == 1) begin
				done[t] <= 1;
			end
			if(mem_handshake[0] == 'd0) begin
				done[t] <= 0;
			end
		end
	end
endgenerate

generate
	for(t=0;t<NUM_CORES;t=t+1) begin : start_cores	
		always @(posedge Bus2IP_Clk) 
		begin
			if(mem_handshake[0] == 1 && (done[t] != 'd1))begin
				start[t] <= 1;
			end
			else begin
				start[t] <= 0;
			end
		end
	end
endgenerate

always @(posedge Bus2IP_Clk)
begin
	if(Bus2IP_Resetn == 0) begin
		mem_read_ack_dly1 <= 0;
		mem_read_ack_dly2 <= 0;
	end
	else begin
		mem_read_ack_dly1 <= mem_read_enable;
		mem_read_ack_dly2 <= mem_read_ack_dly1;
	end
end

always @(*) 
begin
	for (i=0;i<=C_NUM_MEM-1;i=i+1) begin
		for (byte_index=0;byte_index<=NUM_BYTE_LANES-1;byte_index=byte_index+1) begin
			write_enable[i][byte_index] <= Bus2IP_WrCE[i] && Bus2IP_BE[byte_index];
			data_in[i][(byte_index*8) +: 8] <= Bus2IP_Data[(byte_index*8) +: 8];
		end
	end
end

always @(posedge Bus2IP_Clk) 
begin
	if(mem_address_o[0] == 'd0) begin
		if(write_enable[0][0] == 1) begin 
			mem_handshake[mem_address_o[0]] <= dina_PS_o[0];
			douta_PL <= dina_PS_o[0];
			mem_handshake[1] <= 0;
		end
		else begin
			douta_PL <= mem_handshake[0];
		end
	end
	else if(mem_address_o[0] == 'd1) begin
		douta_PL <= mem_handshake[1];
	end
	
	if(done == 70'h3FFFFFFFFFFFFFFFFF) begin
		mem_handshake[0] <= 0;
		mem_handshake[1] <= 32'hFF;
	end
end

always @(*)
begin
	for (i=0;i<=NUM_CORES;i=i+1) begin
		mem_address_o[i] <= 0;
	end
	for (i=1;i<=NUM_CORES;i=i+1) begin
		mem_address_s[i] <= 0;
	end
	case(mem_select)
		1: mem_address_o[0] <= Bus2IP_Addr[11:2];
		2: begin
			case(core_select_others)
				0: mem_address_o[1] <= Bus2IP_Addr[7:2];
				1: mem_address_o[2] <= Bus2IP_Addr[7:2];
				2: mem_address_o[3] <= Bus2IP_Addr[7:2];
				3: mem_address_o[4] <= Bus2IP_Addr[7:2];
				4: mem_address_o[5] <= Bus2IP_Addr[7:2];
				5: mem_address_o[6] <= Bus2IP_Addr[7:2];
				6: mem_address_o[7] <= Bus2IP_Addr[7:2];
				7: mem_address_o[8] <= Bus2IP_Addr[7:2];
				8: mem_address_o[9] <= Bus2IP_Addr[7:2];
				9: mem_address_o[10] <= Bus2IP_Addr[7:2];
				10: mem_address_o[11] <= Bus2IP_Addr[7:2];
				11: mem_address_o[12] <= Bus2IP_Addr[7:2];
				12: mem_address_o[13] <= Bus2IP_Addr[7:2];
				13: mem_address_o[14] <= Bus2IP_Addr[7:2];
				14: mem_address_o[15] <= Bus2IP_Addr[7:2];
				15: mem_address_o[16] <= Bus2IP_Addr[7:2];
				16: mem_address_o[17] <= Bus2IP_Addr[7:2];
				17: mem_address_o[18] <= Bus2IP_Addr[7:2];
				18: mem_address_o[19] <= Bus2IP_Addr[7:2];
				19: mem_address_o[20] <= Bus2IP_Addr[7:2];
				20: mem_address_o[21] <= Bus2IP_Addr[7:2];
				21: mem_address_o[22] <= Bus2IP_Addr[7:2];
				22: mem_address_o[23] <= Bus2IP_Addr[7:2];
				23: mem_address_o[24] <= Bus2IP_Addr[7:2];
				24: mem_address_o[25] <= Bus2IP_Addr[7:2];
				25: mem_address_o[26] <= Bus2IP_Addr[7:2];
				26: mem_address_o[27] <= Bus2IP_Addr[7:2];
				27: mem_address_o[28] <= Bus2IP_Addr[7:2];
				28: mem_address_o[29] <= Bus2IP_Addr[7:2];
				29: mem_address_o[30] <= Bus2IP_Addr[7:2];
				30: mem_address_o[31] <= Bus2IP_Addr[7:2];
				31: mem_address_o[32] <= Bus2IP_Addr[7:2];
				32: mem_address_o[33] <= Bus2IP_Addr[7:2];
				33: mem_address_o[34] <= Bus2IP_Addr[7:2];
				34: mem_address_o[35] <= Bus2IP_Addr[7:2];
				35: mem_address_o[36] <= Bus2IP_Addr[7:2];
				36: mem_address_o[37] <= Bus2IP_Addr[7:2];
				37: mem_address_o[38] <= Bus2IP_Addr[7:2];
				38: mem_address_o[39] <= Bus2IP_Addr[7:2];
				39: mem_address_o[40] <= Bus2IP_Addr[7:2];
				40: mem_address_o[41] <= Bus2IP_Addr[7:2];
				41: mem_address_o[42] <= Bus2IP_Addr[7:2];
				42: mem_address_o[43] <= Bus2IP_Addr[7:2];
				43: mem_address_o[44] <= Bus2IP_Addr[7:2];
				44: mem_address_o[45] <= Bus2IP_Addr[7:2];
				45: mem_address_o[46] <= Bus2IP_Addr[7:2];
				46: mem_address_o[47] <= Bus2IP_Addr[7:2];
				47: mem_address_o[48] <= Bus2IP_Addr[7:2];
				48: mem_address_o[49] <= Bus2IP_Addr[7:2];
				49: mem_address_o[50] <= Bus2IP_Addr[7:2];
				50: mem_address_o[51] <= Bus2IP_Addr[7:2];
				51: mem_address_o[52] <= Bus2IP_Addr[7:2];
				52: mem_address_o[53] <= Bus2IP_Addr[7:2];
				53: mem_address_o[54] <= Bus2IP_Addr[7:2];
				54: mem_address_o[55] <= Bus2IP_Addr[7:2];
				55: mem_address_o[56] <= Bus2IP_Addr[7:2];
				56: mem_address_o[57] <= Bus2IP_Addr[7:2];
				57: mem_address_o[58] <= Bus2IP_Addr[7:2];
				58: mem_address_o[59] <= Bus2IP_Addr[7:2];
				59: mem_address_o[60] <= Bus2IP_Addr[7:2];
				60: mem_address_o[61] <= Bus2IP_Addr[7:2];
				61: mem_address_o[62] <= Bus2IP_Addr[7:2];
				62: mem_address_o[63] <= Bus2IP_Addr[7:2];
				63: mem_address_o[64] <= Bus2IP_Addr[7:2];
				64: mem_address_o[65] <= Bus2IP_Addr[7:2];
				65: mem_address_o[66] <= Bus2IP_Addr[7:2];
				66: mem_address_o[67] <= Bus2IP_Addr[7:2];
				67: mem_address_o[68] <= Bus2IP_Addr[7:2];
				68: mem_address_o[69] <= Bus2IP_Addr[7:2];
				69: mem_address_o[70] <= Bus2IP_Addr[7:2];
			endcase
		end 
		4: begin
			case(core_select_s)
				0: mem_address_s[1] <= Bus2IP_Addr[11:2];
				1: mem_address_s[2] <= Bus2IP_Addr[11:2];
				2: mem_address_s[3] <= Bus2IP_Addr[11:2];
				3: mem_address_s[4] <= Bus2IP_Addr[11:2];
				4: mem_address_s[5] <= Bus2IP_Addr[11:2];
				5: mem_address_s[6] <= Bus2IP_Addr[11:2];
				6: mem_address_s[7] <= Bus2IP_Addr[11:2];
				7: mem_address_s[8] <= Bus2IP_Addr[11:2];
				8: mem_address_s[9] <= Bus2IP_Addr[11:2];
				9: mem_address_s[10] <= Bus2IP_Addr[11:2];
				10: mem_address_s[11] <= Bus2IP_Addr[11:2];
				11: mem_address_s[12] <= Bus2IP_Addr[11:2];
				12: mem_address_s[13] <= Bus2IP_Addr[11:2];
				13: mem_address_s[14] <= Bus2IP_Addr[11:2];
				14: mem_address_s[15] <= Bus2IP_Addr[11:2];
				15: mem_address_s[16] <= Bus2IP_Addr[11:2];
				16: mem_address_s[17] <= Bus2IP_Addr[11:2];
				17: mem_address_s[18] <= Bus2IP_Addr[11:2];
				18: mem_address_s[19] <= Bus2IP_Addr[11:2];
				19: mem_address_s[20] <= Bus2IP_Addr[11:2];
				20: mem_address_s[21] <= Bus2IP_Addr[11:2];
				21: mem_address_s[22] <= Bus2IP_Addr[11:2];
				22: mem_address_s[23] <= Bus2IP_Addr[11:2];
				23: mem_address_s[24] <= Bus2IP_Addr[11:2];
				24: mem_address_s[25] <= Bus2IP_Addr[11:2];
				25: mem_address_s[26] <= Bus2IP_Addr[11:2];
				26: mem_address_s[27] <= Bus2IP_Addr[11:2];
				27: mem_address_s[28] <= Bus2IP_Addr[11:2];
				28: mem_address_s[29] <= Bus2IP_Addr[11:2];
				29: mem_address_s[30] <= Bus2IP_Addr[11:2];
				30: mem_address_s[31] <= Bus2IP_Addr[11:2];
				31: mem_address_s[32] <= Bus2IP_Addr[11:2];
				32: mem_address_s[33] <= Bus2IP_Addr[11:2];
				33: mem_address_s[34] <= Bus2IP_Addr[11:2];
				34: mem_address_s[35] <= Bus2IP_Addr[11:2];
				35: mem_address_s[36] <= Bus2IP_Addr[11:2];
				36: mem_address_s[37] <= Bus2IP_Addr[11:2];
				37: mem_address_s[38] <= Bus2IP_Addr[11:2];
				38: mem_address_s[39] <= Bus2IP_Addr[11:2];
				39: mem_address_s[40] <= Bus2IP_Addr[11:2];
				40: mem_address_s[41] <= Bus2IP_Addr[11:2];
				41: mem_address_s[42] <= Bus2IP_Addr[11:2];
				42: mem_address_s[43] <= Bus2IP_Addr[11:2];
				43: mem_address_s[44] <= Bus2IP_Addr[11:2];
				44: mem_address_s[45] <= Bus2IP_Addr[11:2];
				45: mem_address_s[46] <= Bus2IP_Addr[11:2];
				46: mem_address_s[47] <= Bus2IP_Addr[11:2];
				47: mem_address_s[48] <= Bus2IP_Addr[11:2];
				48: mem_address_s[49] <= Bus2IP_Addr[11:2];
				49: mem_address_s[50] <= Bus2IP_Addr[11:2];
				50: mem_address_s[51] <= Bus2IP_Addr[11:2];
				51: mem_address_s[52] <= Bus2IP_Addr[11:2];
				52: mem_address_s[53] <= Bus2IP_Addr[11:2];
				53: mem_address_s[54] <= Bus2IP_Addr[11:2];
				54: mem_address_s[55] <= Bus2IP_Addr[11:2];
				55: mem_address_s[56] <= Bus2IP_Addr[11:2];
				56: mem_address_s[57] <= Bus2IP_Addr[11:2];
				57: mem_address_s[58] <= Bus2IP_Addr[11:2];
				58: mem_address_s[59] <= Bus2IP_Addr[11:2];
				59: mem_address_s[60] <= Bus2IP_Addr[11:2];
				60: mem_address_s[61] <= Bus2IP_Addr[11:2];
				61: mem_address_s[62] <= Bus2IP_Addr[11:2];
				62: mem_address_s[63] <= Bus2IP_Addr[11:2];
				63: mem_address_s[64] <= Bus2IP_Addr[11:2];
				64: mem_address_s[65] <= Bus2IP_Addr[11:2];
				65: mem_address_s[66] <= Bus2IP_Addr[11:2];
				66: mem_address_s[67] <= Bus2IP_Addr[11:2];
				67: mem_address_s[68] <= Bus2IP_Addr[11:2];
				68: mem_address_s[69] <= Bus2IP_Addr[11:2];
				69: mem_address_s[70] <= Bus2IP_Addr[11:2];

			endcase
		end
	endcase
end

always @(*)
begin
	for (i=1;i<=NUM_CORES;i=i+1) begin
		dina_PS_s[i] <= 0;
	end
	for (i=0;i<=NUM_CORES;i=i+1) begin
		dina_PS_o[i] <= 0;
	end
	case(mem_select)
		1: dina_PS_o[0] <= data_in[0];
		2: begin
			case(core_select_others)
				0: dina_PS_o[1] <= data_in[1];
				1: dina_PS_o[2] <= data_in[1];
				2: dina_PS_o[3] <= data_in[1];
				3: dina_PS_o[4] <= data_in[1];
				4: dina_PS_o[5] <= data_in[1];
				5: dina_PS_o[6] <= data_in[1];
				6: dina_PS_o[7] <= data_in[1];
				7: dina_PS_o[8] <= data_in[1];
				8: dina_PS_o[9] <= data_in[1];
				9: dina_PS_o[10] <= data_in[1];
				10: dina_PS_o[11] <= data_in[1];
				11: dina_PS_o[12] <= data_in[1];
				12: dina_PS_o[13] <= data_in[1];
				13: dina_PS_o[14] <= data_in[1];
				14: dina_PS_o[15] <= data_in[1];
				15: dina_PS_o[16] <= data_in[1];
				16: dina_PS_o[17] <= data_in[1];
				17: dina_PS_o[18] <= data_in[1];
				18: dina_PS_o[19] <= data_in[1];
				19: dina_PS_o[20] <= data_in[1];
				20: dina_PS_o[21] <= data_in[1];
				21: dina_PS_o[22] <= data_in[1];
				22: dina_PS_o[23] <= data_in[1];
				23: dina_PS_o[24] <= data_in[1];
				24: dina_PS_o[25] <= data_in[1];
				25: dina_PS_o[26] <= data_in[1];
				26: dina_PS_o[27] <= data_in[1];
				27: dina_PS_o[28] <= data_in[1];
				28: dina_PS_o[29] <= data_in[1];
				29: dina_PS_o[30] <= data_in[1];
				30: dina_PS_o[31] <= data_in[1];
				31: dina_PS_o[32] <= data_in[1];
				32: dina_PS_o[33] <= data_in[1];
				33: dina_PS_o[34] <= data_in[1];
				34: dina_PS_o[35] <= data_in[1];
				35: dina_PS_o[36] <= data_in[1];
				36: dina_PS_o[37] <= data_in[1];
				37: dina_PS_o[38] <= data_in[1];
				38: dina_PS_o[39] <= data_in[1];
				39: dina_PS_o[40] <= data_in[1];
				40: dina_PS_o[41] <= data_in[1];
				41: dina_PS_o[42] <= data_in[1];
				42: dina_PS_o[43] <= data_in[1];
				43: dina_PS_o[44] <= data_in[1];
				44: dina_PS_o[45] <= data_in[1];
				45: dina_PS_o[46] <= data_in[1];
				46: dina_PS_o[47] <= data_in[1];
				47: dina_PS_o[48] <= data_in[1];
				48: dina_PS_o[49] <= data_in[1];
				49: dina_PS_o[50] <= data_in[1];
				50: dina_PS_o[51] <= data_in[1];
				51: dina_PS_o[52] <= data_in[1];
				52: dina_PS_o[53] <= data_in[1];
				53: dina_PS_o[54] <= data_in[1];
				54: dina_PS_o[55] <= data_in[1];
				55: dina_PS_o[56] <= data_in[1];
				56: dina_PS_o[57] <= data_in[1];
				57: dina_PS_o[58] <= data_in[1];
				58: dina_PS_o[59] <= data_in[1];
				59: dina_PS_o[60] <= data_in[1];
				60: dina_PS_o[61] <= data_in[1];
				61: dina_PS_o[62] <= data_in[1];
				62: dina_PS_o[63] <= data_in[1];
				63: dina_PS_o[64] <= data_in[1];
				64: dina_PS_o[65] <= data_in[1];
				65: dina_PS_o[66] <= data_in[1];
				66: dina_PS_o[67] <= data_in[1];
				67: dina_PS_o[68] <= data_in[1];
				68: dina_PS_o[69] <= data_in[1];
				69: dina_PS_o[70] <= data_in[1];

			endcase
		end 
		4: begin
			case(core_select_s)
				0: dina_PS_s[1] <= data_in[2];
				1: dina_PS_s[2] <= data_in[2];
				2: dina_PS_s[3] <= data_in[2];
				3: dina_PS_s[4] <= data_in[2];
				4: dina_PS_s[5] <= data_in[2];
				5: dina_PS_s[6] <= data_in[2];
				6: dina_PS_s[7] <= data_in[2];
				7: dina_PS_s[8] <= data_in[2];
				8: dina_PS_s[9] <= data_in[2];
				9: dina_PS_s[10] <= data_in[2];
				10: dina_PS_s[11] <= data_in[2];
				11: dina_PS_s[12] <= data_in[2];
				12: dina_PS_s[13] <= data_in[2];
				13: dina_PS_s[14] <= data_in[2];
				14: dina_PS_s[15] <= data_in[2];
				15: dina_PS_s[16] <= data_in[2];
				16: dina_PS_s[17] <= data_in[2];
				17: dina_PS_s[18] <= data_in[2];
				18: dina_PS_s[19] <= data_in[2];
				19: dina_PS_s[20] <= data_in[2];
				20: dina_PS_s[21] <= data_in[2];
				21: dina_PS_s[22] <= data_in[2];
				22: dina_PS_s[23] <= data_in[2];
				23: dina_PS_s[24] <= data_in[2];
				24: dina_PS_s[25] <= data_in[2];
				25: dina_PS_s[26] <= data_in[2];
				26: dina_PS_s[27] <= data_in[2];
				27: dina_PS_s[28] <= data_in[2];
				28: dina_PS_s[29] <= data_in[2];
				29: dina_PS_s[30] <= data_in[2];
				30: dina_PS_s[31] <= data_in[2];
				31: dina_PS_s[32] <= data_in[2];
				32: dina_PS_s[33] <= data_in[2];
				33: dina_PS_s[34] <= data_in[2];
				34: dina_PS_s[35] <= data_in[2];
				35: dina_PS_s[36] <= data_in[2];
				36: dina_PS_s[37] <= data_in[2];
				37: dina_PS_s[38] <= data_in[2];
				38: dina_PS_s[39] <= data_in[2];
				39: dina_PS_s[40] <= data_in[2];
				40: dina_PS_s[41] <= data_in[2];
				41: dina_PS_s[42] <= data_in[2];
				42: dina_PS_s[43] <= data_in[2];
				43: dina_PS_s[44] <= data_in[2];
				44: dina_PS_s[45] <= data_in[2];
				45: dina_PS_s[46] <= data_in[2];
				46: dina_PS_s[47] <= data_in[2];
				47: dina_PS_s[48] <= data_in[2];
				48: dina_PS_s[49] <= data_in[2];
				49: dina_PS_s[50] <= data_in[2];
				50: dina_PS_s[51] <= data_in[2];
				51: dina_PS_s[52] <= data_in[2];
				52: dina_PS_s[53] <= data_in[2];
				53: dina_PS_s[54] <= data_in[2];
				54: dina_PS_s[55] <= data_in[2];
				55: dina_PS_s[56] <= data_in[2];
				56: dina_PS_s[57] <= data_in[2];
				57: dina_PS_s[58] <= data_in[2];
				58: dina_PS_s[59] <= data_in[2];
				59: dina_PS_s[60] <= data_in[2];
				60: dina_PS_s[61] <= data_in[2];
				61: dina_PS_s[62] <= data_in[2];
				62: dina_PS_s[63] <= data_in[2];
				63: dina_PS_s[64] <= data_in[2];
				64: dina_PS_s[65] <= data_in[2];
				65: dina_PS_s[66] <= data_in[2];
				66: dina_PS_s[67] <= data_in[2];
				67: dina_PS_s[68] <= data_in[2];
				68: dina_PS_s[69] <= data_in[2];
				69: dina_PS_s[70] <= data_in[2];

			endcase
		end
	endcase
end

always @(*)
begin
	for (i=1;i<=NUM_CORES;i=i+1) begin
		wea_PS_o[i] <= 0;
	end
	for (i=1;i<=NUM_CORES;i=i+1) begin
		wea_PS_s[i] <= 0;
	end
	case(mem_select)
		2: begin
			case(core_select_others)
				0: wea_PS_o[1] <= write_enable[1][0];
				1: wea_PS_o[2] <= write_enable[1][0];
				2: wea_PS_o[3] <= write_enable[1][0];
				3: wea_PS_o[4] <= write_enable[1][0];
				4: wea_PS_o[5] <= write_enable[1][0];
				5: wea_PS_o[6] <= write_enable[1][0];
				6: wea_PS_o[7] <= write_enable[1][0];
				7: wea_PS_o[8] <= write_enable[1][0];
				8: wea_PS_o[9] <= write_enable[1][0];
				9: wea_PS_o[10] <= write_enable[1][0];
				10: wea_PS_o[11] <= write_enable[1][0];
				11: wea_PS_o[12] <= write_enable[1][0];
				12: wea_PS_o[13] <= write_enable[1][0];
				13: wea_PS_o[14] <= write_enable[1][0];
				14: wea_PS_o[15] <= write_enable[1][0];
				15: wea_PS_o[16] <= write_enable[1][0];
				16: wea_PS_o[17] <= write_enable[1][0];
				17: wea_PS_o[18] <= write_enable[1][0];
				18: wea_PS_o[19] <= write_enable[1][0];
				19: wea_PS_o[20] <= write_enable[1][0];
				20: wea_PS_o[21] <= write_enable[1][0];
				21: wea_PS_o[22] <= write_enable[1][0];
				22: wea_PS_o[23] <= write_enable[1][0];
				23: wea_PS_o[24] <= write_enable[1][0];
				24: wea_PS_o[25] <= write_enable[1][0];
				25: wea_PS_o[26] <= write_enable[1][0];
				26: wea_PS_o[27] <= write_enable[1][0];
				27: wea_PS_o[28] <= write_enable[1][0];
				28: wea_PS_o[29] <= write_enable[1][0];
				29: wea_PS_o[30] <= write_enable[1][0];
				30: wea_PS_o[31] <= write_enable[1][0];
				31: wea_PS_o[32] <= write_enable[1][0];
				32: wea_PS_o[33] <= write_enable[1][0];
				33: wea_PS_o[34] <= write_enable[1][0];
				34: wea_PS_o[35] <= write_enable[1][0];
				35: wea_PS_o[36] <= write_enable[1][0];
				36: wea_PS_o[37] <= write_enable[1][0];
				37: wea_PS_o[38] <= write_enable[1][0];
				38: wea_PS_o[39] <= write_enable[1][0];
				39: wea_PS_o[40] <= write_enable[1][0];
				40: wea_PS_o[41] <= write_enable[1][0];
				41: wea_PS_o[42] <= write_enable[1][0];
				42: wea_PS_o[43] <= write_enable[1][0];
				43: wea_PS_o[44] <= write_enable[1][0];
				44: wea_PS_o[45] <= write_enable[1][0];
				45: wea_PS_o[46] <= write_enable[1][0];
				46: wea_PS_o[47] <= write_enable[1][0];
				47: wea_PS_o[48] <= write_enable[1][0];
				48: wea_PS_o[49] <= write_enable[1][0];
				49: wea_PS_o[50] <= write_enable[1][0];
				50: wea_PS_o[51] <= write_enable[1][0];
				51: wea_PS_o[52] <= write_enable[1][0];
				52: wea_PS_o[53] <= write_enable[1][0];
				53: wea_PS_o[54] <= write_enable[1][0];
				54: wea_PS_o[55] <= write_enable[1][0];
				55: wea_PS_o[56] <= write_enable[1][0];
				56: wea_PS_o[57] <= write_enable[1][0];
				57: wea_PS_o[58] <= write_enable[1][0];
				58: wea_PS_o[59] <= write_enable[1][0];
				59: wea_PS_o[60] <= write_enable[1][0];
				60: wea_PS_o[61] <= write_enable[1][0];
				61: wea_PS_o[62] <= write_enable[1][0];
				62: wea_PS_o[63] <= write_enable[1][0];
				63: wea_PS_o[64] <= write_enable[1][0];
				64: wea_PS_o[65] <= write_enable[1][0];
				65: wea_PS_o[66] <= write_enable[1][0];
				66: wea_PS_o[67] <= write_enable[1][0];
				67: wea_PS_o[68] <= write_enable[1][0];
				68: wea_PS_o[69] <= write_enable[1][0];
				69: wea_PS_o[70] <= write_enable[1][0];

			endcase
		end 
		4: begin
			case(core_select_s)
				0: wea_PS_s[1] <= write_enable[2][0];
				1: wea_PS_s[2] <= write_enable[2][0];
				2: wea_PS_s[3] <= write_enable[2][0];
				3: wea_PS_s[4] <= write_enable[2][0];
				4: wea_PS_s[5] <= write_enable[2][0];
				5: wea_PS_s[6] <= write_enable[2][0];
				6: wea_PS_s[7] <= write_enable[2][0];
				7: wea_PS_s[8] <= write_enable[2][0];
				8: wea_PS_s[9] <= write_enable[2][0];
				9: wea_PS_s[10] <= write_enable[2][0];
				10: wea_PS_s[11] <= write_enable[2][0];
				11: wea_PS_s[12] <= write_enable[2][0];
				12: wea_PS_s[13] <= write_enable[2][0];
				13: wea_PS_s[14] <= write_enable[2][0];
				14: wea_PS_s[15] <= write_enable[2][0];
				15: wea_PS_s[16] <= write_enable[2][0];
				16: wea_PS_s[17] <= write_enable[2][0];
				17: wea_PS_s[18] <= write_enable[2][0];
				18: wea_PS_s[19] <= write_enable[2][0];
				19: wea_PS_s[20] <= write_enable[2][0];
				20: wea_PS_s[21] <= write_enable[2][0];
				21: wea_PS_s[22] <= write_enable[2][0];
				22: wea_PS_s[23] <= write_enable[2][0];
				23: wea_PS_s[24] <= write_enable[2][0];
				24: wea_PS_s[25] <= write_enable[2][0];
				25: wea_PS_s[26] <= write_enable[2][0];
				26: wea_PS_s[27] <= write_enable[2][0];
				27: wea_PS_s[28] <= write_enable[2][0];
				28: wea_PS_s[29] <= write_enable[2][0];
				29: wea_PS_s[30] <= write_enable[2][0];
				30: wea_PS_s[31] <= write_enable[2][0];
				31: wea_PS_s[32] <= write_enable[2][0];
				32: wea_PS_s[33] <= write_enable[2][0];
				33: wea_PS_s[34] <= write_enable[2][0];
				34: wea_PS_s[35] <= write_enable[2][0];
				35: wea_PS_s[36] <= write_enable[2][0];
				36: wea_PS_s[37] <= write_enable[2][0];
				37: wea_PS_s[38] <= write_enable[2][0];
				38: wea_PS_s[39] <= write_enable[2][0];
				39: wea_PS_s[40] <= write_enable[2][0];
				40: wea_PS_s[41] <= write_enable[2][0];
				41: wea_PS_s[42] <= write_enable[2][0];
				42: wea_PS_s[43] <= write_enable[2][0];
				43: wea_PS_s[44] <= write_enable[2][0];
				44: wea_PS_s[45] <= write_enable[2][0];
				45: wea_PS_s[46] <= write_enable[2][0];
				46: wea_PS_s[47] <= write_enable[2][0];
				47: wea_PS_s[48] <= write_enable[2][0];
				48: wea_PS_s[49] <= write_enable[2][0];
				49: wea_PS_s[50] <= write_enable[2][0];
				50: wea_PS_s[51] <= write_enable[2][0];
				51: wea_PS_s[52] <= write_enable[2][0];
				52: wea_PS_s[53] <= write_enable[2][0];
				53: wea_PS_s[54] <= write_enable[2][0];
				54: wea_PS_s[55] <= write_enable[2][0];
				55: wea_PS_s[56] <= write_enable[2][0];
				56: wea_PS_s[57] <= write_enable[2][0];
				57: wea_PS_s[58] <= write_enable[2][0];
				58: wea_PS_s[59] <= write_enable[2][0];
				59: wea_PS_s[60] <= write_enable[2][0];
				60: wea_PS_s[61] <= write_enable[2][0];
				61: wea_PS_s[62] <= write_enable[2][0];
				62: wea_PS_s[63] <= write_enable[2][0];
				63: wea_PS_s[64] <= write_enable[2][0];
				64: wea_PS_s[65] <= write_enable[2][0];
				65: wea_PS_s[66] <= write_enable[2][0];
				66: wea_PS_s[67] <= write_enable[2][0];
				67: wea_PS_s[68] <= write_enable[2][0];
				68: wea_PS_s[69] <= write_enable[2][0];
				69: wea_PS_s[70] <= write_enable[2][0];

			endcase
		end
	endcase
end

always @(*)
begin
	case(mem_select)
		1 : mem_ip2bus_data <= douta_o[0];
		2: begin
			case(core_select_others)
				0: mem_ip2bus_data <= douta_o[1];
				1: mem_ip2bus_data <= douta_o[2];
				2: mem_ip2bus_data <= douta_o[3];
				3: mem_ip2bus_data <= douta_o[4];
				4: mem_ip2bus_data <= douta_o[5];
				5: mem_ip2bus_data <= douta_o[6];
				6: mem_ip2bus_data <= douta_o[7];
				7: mem_ip2bus_data <= douta_o[8];
				8: mem_ip2bus_data <= douta_o[9];
				9: mem_ip2bus_data <= douta_o[10];
				10: mem_ip2bus_data <= douta_o[11];
				11: mem_ip2bus_data <= douta_o[12];
				12: mem_ip2bus_data <= douta_o[13];
				13: mem_ip2bus_data <= douta_o[14];
				14: mem_ip2bus_data <= douta_o[15];
				15: mem_ip2bus_data <= douta_o[16];
				16: mem_ip2bus_data <= douta_o[17];
				17: mem_ip2bus_data <= douta_o[18];
				18: mem_ip2bus_data <= douta_o[19];
				19: mem_ip2bus_data <= douta_o[20];
				20: mem_ip2bus_data <= douta_o[21];
				21: mem_ip2bus_data <= douta_o[22];
				22: mem_ip2bus_data <= douta_o[23];
				23: mem_ip2bus_data <= douta_o[24];
				24: mem_ip2bus_data <= douta_o[25];
				25: mem_ip2bus_data <= douta_o[26];
				26: mem_ip2bus_data <= douta_o[27];
				27: mem_ip2bus_data <= douta_o[28];
				28: mem_ip2bus_data <= douta_o[29];
				29: mem_ip2bus_data <= douta_o[30];
				30: mem_ip2bus_data <= douta_o[31];
				31: mem_ip2bus_data <= douta_o[32];
				32: mem_ip2bus_data <= douta_o[33];
				33: mem_ip2bus_data <= douta_o[34];
				34: mem_ip2bus_data <= douta_o[35];
				35: mem_ip2bus_data <= douta_o[36];
				36: mem_ip2bus_data <= douta_o[37];
				37: mem_ip2bus_data <= douta_o[38];
				38: mem_ip2bus_data <= douta_o[39];
				39: mem_ip2bus_data <= douta_o[40];
				40: mem_ip2bus_data <= douta_o[41];
				41: mem_ip2bus_data <= douta_o[42];
				42: mem_ip2bus_data <= douta_o[43];
				43: mem_ip2bus_data <= douta_o[44];
				44: mem_ip2bus_data <= douta_o[45];
				45: mem_ip2bus_data <= douta_o[46];
				46: mem_ip2bus_data <= douta_o[47];
				47: mem_ip2bus_data <= douta_o[48];
				48: mem_ip2bus_data <= douta_o[49];
				49: mem_ip2bus_data <= douta_o[50];
				50: mem_ip2bus_data <= douta_o[51];
				51: mem_ip2bus_data <= douta_o[52];
				52: mem_ip2bus_data <= douta_o[53];
				53: mem_ip2bus_data <= douta_o[54];
				54: mem_ip2bus_data <= douta_o[55];
				55: mem_ip2bus_data <= douta_o[56];
				56: mem_ip2bus_data <= douta_o[57];
				57: mem_ip2bus_data <= douta_o[58];
				58: mem_ip2bus_data <= douta_o[59];
				59: mem_ip2bus_data <= douta_o[60];
				60: mem_ip2bus_data <= douta_o[61];
				61: mem_ip2bus_data <= douta_o[62];
				62: mem_ip2bus_data <= douta_o[63];
				63: mem_ip2bus_data <= douta_o[64];
				64: mem_ip2bus_data <= douta_o[65];
				65: mem_ip2bus_data <= douta_o[66];
				66: mem_ip2bus_data <= douta_o[67];
				67: mem_ip2bus_data <= douta_o[68];
				68: mem_ip2bus_data <= douta_o[69];
				69: mem_ip2bus_data <= douta_o[70];
			endcase
		end 
		4: begin
			case(core_select_s)
				0: mem_ip2bus_data <= douta_s[1];
				1: mem_ip2bus_data <= douta_s[2];
				2: mem_ip2bus_data <= douta_s[3];
				3: mem_ip2bus_data <= douta_s[4];
				4: mem_ip2bus_data <= douta_s[5];
				5: mem_ip2bus_data <= douta_s[6];
				6: mem_ip2bus_data <= douta_s[7];
				7: mem_ip2bus_data <= douta_s[8];
				8: mem_ip2bus_data <= douta_s[9];
				9: mem_ip2bus_data <= douta_s[10];
				10: mem_ip2bus_data <= douta_s[11];
				11: mem_ip2bus_data <= douta_s[12];
				12: mem_ip2bus_data <= douta_s[13];
				13: mem_ip2bus_data <= douta_s[14];
				14: mem_ip2bus_data <= douta_s[15];
				15: mem_ip2bus_data <= douta_s[16];
				16: mem_ip2bus_data <= douta_s[17];
				17: mem_ip2bus_data <= douta_s[18];
				18: mem_ip2bus_data <= douta_s[19];
				19: mem_ip2bus_data <= douta_s[20];
				20: mem_ip2bus_data <= douta_s[21];
				21: mem_ip2bus_data <= douta_s[22];
				22: mem_ip2bus_data <= douta_s[23];
				23: mem_ip2bus_data <= douta_s[24];
				24: mem_ip2bus_data <= douta_s[25];
				25: mem_ip2bus_data <= douta_s[26];
				26: mem_ip2bus_data <= douta_s[27];
				27: mem_ip2bus_data <= douta_s[28];
				28: mem_ip2bus_data <= douta_s[29];
				29: mem_ip2bus_data <= douta_s[30];
				30: mem_ip2bus_data <= douta_s[31];
				31: mem_ip2bus_data <= douta_s[32];
				32: mem_ip2bus_data <= douta_s[33];
				33: mem_ip2bus_data <= douta_s[34];
				34: mem_ip2bus_data <= douta_s[35];
				35: mem_ip2bus_data <= douta_s[36];
				36: mem_ip2bus_data <= douta_s[37];
				37: mem_ip2bus_data <= douta_s[38];
				38: mem_ip2bus_data <= douta_s[39];
				39: mem_ip2bus_data <= douta_s[40];
				40: mem_ip2bus_data <= douta_s[41];
				41: mem_ip2bus_data <= douta_s[42];
				42: mem_ip2bus_data <= douta_s[43];
				43: mem_ip2bus_data <= douta_s[44];
				44: mem_ip2bus_data <= douta_s[45];
				45: mem_ip2bus_data <= douta_s[46];
				46: mem_ip2bus_data <= douta_s[47];
				47: mem_ip2bus_data <= douta_s[48];
				48: mem_ip2bus_data <= douta_s[49];
				49: mem_ip2bus_data <= douta_s[50];
				50: mem_ip2bus_data <= douta_s[51];
				51: mem_ip2bus_data <= douta_s[52];
				52: mem_ip2bus_data <= douta_s[53];
				53: mem_ip2bus_data <= douta_s[54];
				54: mem_ip2bus_data <= douta_s[55];
				55: mem_ip2bus_data <= douta_s[56];
				56: mem_ip2bus_data <= douta_s[57];
				57: mem_ip2bus_data <= douta_s[58];
				58: mem_ip2bus_data <= douta_s[59];
				59: mem_ip2bus_data <= douta_s[60];
				60: mem_ip2bus_data <= douta_s[61];
				61: mem_ip2bus_data <= douta_s[62];
				62: mem_ip2bus_data <= douta_s[63];
				63: mem_ip2bus_data <= douta_s[64];
				64: mem_ip2bus_data <= douta_s[65];
				65: mem_ip2bus_data <= douta_s[66];
				66: mem_ip2bus_data <= douta_s[67];
				67: mem_ip2bus_data <= douta_s[68];
				68: mem_ip2bus_data <= douta_s[69];
				69: mem_ip2bus_data <= douta_s[70];

			endcase
		end
		default: mem_ip2bus_data <= 0;
	endcase
end

assign IP2Bus_Data  = (mem_read_ack[0] == 1'b1 || mem_read_ack[1] == 1'b1 || mem_read_ack[2] == 1'b1) ? mem_ip2bus_data : 0;
assign IP2Bus_AddrAck = ((mem_write_ack[0] == 1'b1 || mem_write_ack[1] == 1'b1 || mem_write_ack[2] == 1'b1) || 
		((mem_read_enable[0] == 1'b1 || mem_read_enable[1] == 1'b1 || mem_read_enable[2] == 1'b1) && 
		(mem_read_ack[0] == 1'b1 || mem_read_ack[1] == 1'b1 || mem_read_ack[2] == 1'b1)));
assign IP2Bus_WrAck = (mem_write_ack[0] == 1'b1 || mem_write_ack[1] == 1'b1 || mem_write_ack[2] == 1'b1);
assign IP2Bus_RdAck = (mem_read_ack[0] == 1'b1 || mem_read_ack[1] == 1'b1 || mem_read_ack[2] == 1'b1);
assign IP2Bus_Error = 0;

endmodule