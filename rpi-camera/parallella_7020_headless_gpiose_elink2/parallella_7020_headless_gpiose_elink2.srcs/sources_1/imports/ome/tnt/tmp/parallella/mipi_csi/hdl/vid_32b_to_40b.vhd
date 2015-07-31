--
-- vid_32b_to_40b.vhd
--
-- Video - 32b to 40b expansion (LSB first)
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
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

use work.utils_pkg.all;


entity vid_32b_to_40b is
	port (
		-- Input
		in_data		: in  std_logic_vector(31 downto 0);
		in_last		: in  std_logic;
		in_sof		: in  std_logic;
		in_valid	: in  std_logic;
		in_ready	: out std_logic;

		-- Output
		out_data	: out std_logic_vector(39 downto 0);
		out_last	: out std_logic;
		out_sof		: out std_logic;
		out_valid	: out std_logic;
		out_ready	: in  std_logic;

		-- Clock / Reset
		clk			: in  std_logic;
		rst			: in  std_logic
	);
end vid_32b_to_40b;


architecture rtl of vid_32b_to_40b is

	signal data_bs		: std_logic_vector(111 downto 0);
	signal data_reg		: std_logic_vector( 79 downto 0);

	signal cnt			: std_logic_vector(3 downto 0);

	signal ce			: std_logic;
	signal do_out		: std_logic;
	signal do_load		: std_logic;
	signal has_last		: std_logic;
	
	signal in_ready_i	: std_logic;
	signal out_valid_i	: std_logic;

begin

	-- Data
	data_bs <=
		x"00000000000000000000" & in_data                         when cnt = x"0" else
		x"000000000000000000"   & in_data & data_reg( 7 downto 0) when cnt = x"1" else
		x"0000000000000000"     & in_data & data_reg(15 downto 0) when cnt = x"2" else
		x"00000000000000"       & in_data & data_reg(23 downto 0) when cnt = x"3" else
		x"000000000000"         & in_data & data_reg(31 downto 0) when cnt = x"4" else
		x"0000000000"           & in_data & data_reg(39 downto 0) when cnt = x"5" else
		x"00000000"             & in_data & data_reg(47 downto 0) when cnt = x"6" else
		x"000000"               & in_data & data_reg(55 downto 0) when cnt = x"7" else
		x"0000"                 & in_data & data_reg(63 downto 0) when cnt = x"8" else
		x"00"                   & in_data & data_reg(71 downto 0) when cnt = x"9" else
		                          in_data & data_reg(79 downto 0) when cnt = x"a" else
		(others => '0');

	process (clk)
	begin
		if rising_edge(clk) then
			if ce = '1' then
				if do_out = '1' then
					data_reg <= x"00" & data_bs(111 downto 40);
				else
					data_reg <= data_bs( 79 downto  0);
				end if;
			end if;
		end if;
	end process;

	out_data <= data_reg(39 downto 0);

	-- Counter
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cnt <= x"0";
			elsif ce = '1' then
				if do_load = '1' and do_out = '1' then
					-- Load and Output at the same time, remove 5 add 4
					cnt <= cnt - 1;
				elsif do_out = '1' then
					-- Output 5 bytes, remove 5 bytes (with a 0 min)
					if cnt >= x"5" then
						cnt <= cnt - 5;
					else
						cnt <= x"0";
					end if;
				elsif do_load = '1' then
					-- Load new data, 4 more bytes
					cnt <= cnt + 4;
				end if;
			end if;
		end if;
	end process;

	-- Valid flag
	out_valid_i <= btsl(cnt >= x"5") or has_last;
	out_valid <= out_valid_i;

	-- SoF flag
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				out_sof <= '0';
			else
				if do_load = '1' and in_sof = '1' then
					out_sof <= '1';
				elsif do_out = '1' then
					out_sof <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Last flag
	out_last <= btsl(cnt <= x"5") and has_last;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				has_last <= '0';
			else
				if do_load = '1' and in_last = '1' then
					has_last <= '1';
				elsif do_out = '1' and cnt <= x"5" then
					has_last <= '0';
				end if;
			end if;
		end if;
	end process;

	-- Control
	do_out  <= out_valid_i and out_ready;
	do_load <= in_valid and in_ready_i;
	ce      <= do_out or do_load;

	-- Upstream ready flag
	in_ready <= in_ready_i;
	in_ready_i <= ((btsl(cnt <= x"6") or (btsl(cnt <= x"9") and do_out)) and not has_last) or btsl(cnt = x"0");

end rtl;
