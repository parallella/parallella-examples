--
-- utils_pkg.vhd
--
--
-- Copyright (C) 2015  Sylvain Munaut <tnt@246tNt.com>
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <http://www.gnu.org/licenses/>.
--
-- vim: ts=4 sw=4
--

library ieee;
use ieee.std_logic_1164.all;


package utils_pkg is

	-- Array types
	type slv64_array_t  is array (integer range <>) of std_logic_vector( 63 downto 0);
	type slv32_array_t  is array (integer range <>) of std_logic_vector( 31 downto 0);
	type slv16_array_t  is array (integer range <>) of std_logic_vector( 15 downto 0);
	type slv8_array_t   is array (integer range <>) of std_logic_vector(  7 downto 0);

	-- Utility functions
	function int_max(a : integer; b : integer) return integer;
	function int_min(a : integer; b : integer) return integer;
	function btsl(x : boolean) return std_logic;
	function log2(x : natural) return integer;
	function log2_floor(x : natural) return integer;
	function bin2gray(v : std_logic_vector) return std_logic_vector;

	-- Common vector reduction functions
	function and_reduce(v : std_logic_vector) return std_logic;
	function or_reduce(v : std_logic_vector) return std_logic;
	function xor_reduce(v : std_logic_vector) return std_logic;

	-- Selection functions
	function sel_int(sel : boolean; v1, v0 : integer) return integer;
	function sel_str(sel : boolean; v1, v0 : string) return string;
	function sel_sl (sel : boolean; v1, v0 : std_logic) return std_logic;
	function sel_slv(sel : boolean; v1, v0 : std_logic_vector)
		return std_logic_vector;

	-- Components

	component delay_bus is
		generic (
			DELAY	: integer := 2;
			WIDTH	: integer := 16
		);
		port (
			d		: in  std_logic_vector(WIDTH-1 downto 0);
			q		: out std_logic_vector(WIDTH-1 downto 0);
			qp		: out std_logic_vector(WIDTH-1 downto 0);
			clk		: in  std_logic
		);
	end component;

	component delay_line is
		generic (
			DELAY 	: integer := 2
		);
		port (
			d		: in  std_logic;
			q		: out std_logic;
			qp		: out std_logic;
			clk		: in  std_logic
		);
	end component;

	component fifo_srl is
		generic (
			FIFO_WIDTH		: integer := 4;
			FIFO_DEPTH		: integer := 16; -- 16 or 32
			AFULL_LEVEL		: integer := -1  -- -1 means no AFULL generation
		);
		port (
			fifo_di			: in  std_logic_vector(FIFO_WIDTH-1 downto 0);
			fifo_wren		: in  std_logic;
			fifo_full		: out std_logic;
			fifo_afull		: out std_logic;

			fifo_do			: out std_logic_vector(FIFO_WIDTH-1 downto 0);
			fifo_rden		: in  std_logic;
			fifo_empty		: out std_logic;

			clk				: in  std_logic;
			rst				: in  std_logic
		);
	end component;

	component xclk_sync
		port (
			sig_in	: in  std_logic;
			clk_in	: in  std_logic;

			sig_out	: out std_logic;
			clk_out : in  std_logic
		);
	end component;

	component xclk_pulse
		generic (
			CNT_WIDTH	: integer := 3
		);
		port (
			pulse_in	: in  std_logic;
			clk_in		: in  std_logic;

			pulse_out	: out std_logic;
			clk_out		: in  std_logic
		);
	end component;

end package utils_pkg;


package body utils_pkg is

	-- Utility functions
	-----------------------

	-- Integer max
	function int_max(a : integer; b : integer) return integer is
	begin
		if a > b then
			return a;
		else
			return b;
		end if;
	end int_max;

	-- Integer min
	function int_min(a : integer; b : integer) return integer is
	begin
		if a > b then
			return b;
		else
			return a;
		end if;
	end int_min;

	-- Boolean To Standard Logic
	function btsl(x : boolean) return std_logic is
	begin
		if x then
			return '1';
		else
			return '0';
		end if;
	end btsl;

	-- log2 rounded up
	function log2(x : natural) return integer is
		variable i  : integer := 0;
		variable val: integer := 1;
	begin
		if x = 0 then
			return 0;
		else
			for j in 0 to 29 loop -- for loop for XST
				if val >= x then
					null;
				else
					i := i+1;
					val := val*2;
				end if;
			end loop;
			if val < x then
				report "Function log2 received argument larger" &
						" than its capability of 2^30. "
					severity failure;
			end if;
			return i;
		end if;
	end function log2;

	-- log2 rounded down
	function log2_floor(x : natural) return integer is
		variable temp, log : integer;
	begin
		assert x /= 0
		report "Error : function missuse : log2_floor(zero)"
			severity failure;
		temp := x;
		log  := 0;
		while (temp > 1) loop
			temp := temp/2;
			log  := log+1;
		end loop;
		return log;
	end log2_floor;

	-- Binary to Gray
	function bin2gray(v : std_logic_vector) return std_logic_vector is
	begin
		if v'ascending then
			return v xor ('0' & v(v'left to v'right-1));
		else
			return v xor ('0' & v(v'left downto v'right+1));
		end if;
	end bin2gray;


	-- Common vector reduction functions
	---------------------------------------

	function and_reduce(v : std_logic_vector) return std_logic is
		variable result : std_logic;
	begin
		result := '1';
		for i in v'range loop
			result := result and v(i);
		end loop;
		return result;
	end function;

	function or_reduce(v : std_logic_vector) return std_logic is
		variable result : std_logic;
	begin
		result := '0';
		for i in v'range loop
			result := result or v(i);
		end loop;
		return result;
	end function;

	function xor_reduce(v : std_logic_vector) return std_logic is
		variable result : std_logic;
	begin
		result := '0';
		for i in v'range loop
			result := result xor v(i);
		end loop;
		return result;
	end function;


	-- Selection functions
	------------------------

	function sel_int(sel : boolean; v1, v0 : integer)
			return integer is
	begin
		if sel then
			return v1;
		else
			return v0;
		end if;
	end function;

	function sel_str(sel : boolean; v1, v0 : string)
			return string is
	begin
		if sel then
			return v1;
		else
			return v0;
		end if;
	end function;

	function sel_sl(sel : boolean; v1, v0 : std_logic)
			return std_logic is
	begin
		if sel then
			return v1;
		else
			return v0;
		end if;
	end function;

	function sel_slv(sel : boolean; v1, v0 : std_logic_vector)
			return std_logic_vector is
	begin
		if sel then
			return v1;
		else
			return v0;
		end if;
	end function;

end package body;
