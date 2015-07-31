--
-- vid_packer.vhd
--
-- Packs 8/10/16/32b video data into 32 bit word
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


entity vid_packer is
	port (
		-- Input
		in_data		: in  std_logic_vector(31 downto 0);
		in_last		: in  std_logic;
		in_sof		: in  std_logic;
		in_valid	: in  std_logic;

		-- Output
		out_data	: out std_logic_vector(31 downto 0);
		out_last	: out std_logic;
		out_sof		: out std_logic;
		out_valid	: out std_logic;

		-- Config
			-- 00: 32b , 10: 16b, 11: 8b
		mode		: in  std_logic_vector(1 downto 0);

		-- Clock / Reset
		clk			: in  std_logic;
		rst			: in  std_logic
	);
end vid_packer;


architecture rtl of vid_packer is

	signal data			: std_logic_vector(31 downto 0);
	signal cnt			: std_logic_vector(1 downto 0);
	signal out_valid_i	: std_logic;

begin

	-- Main data register
		-- (can't simply use a shift reg because we want the data LSB aligned
		--  even when we have less bytes than needed for a full word)
	process (clk)
	begin
		if rising_edge(clk) then
			if in_valid = '1' then
				if mode = "00" then
					-- 32b mode: load all
					data <= in_data;
				elsif mode = "10" then
					-- 16b mode: load the correct half
					if cnt(1) = '1' then
						data <= in_data(15 downto 0) & data(15 downto 0);
					else
						data <= x"0000" & in_data(15 downto 0);
					end if;
				elsif mode = "11" then
					-- 8b mode: load the correct byte
					if cnt = "11" then
						data <= in_data(7 downto 0) & data(23 downto 0);
					elsif cnt = "10" then
						data <= x"00" & in_data(7 downto 0) & data(15 downto 0);
					elsif cnt = "01" then
						data <= x"0000" & in_data(7 downto 0) & data(7 downto 0);
					else
						data <= x"000000" & in_data(7 downto 0);
					end if;
				else
					data <= (others => '0');
				end if;
			end if;
		end if;
	end process;

	out_data <= data;

	-- Position counter
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cnt <= "00";
			elsif in_valid = '1' then
				if in_last = '1' then
					cnt <= "00";
				else
					if mode = "11" then
						-- 8b mode
						cnt <= cnt + 1;
					elsif mode = "10" then
						-- 16b mode
						cnt <= cnt + 2;
					else
						-- 32b mode
						cnt <= "00";
					end if;
				end if;
			end if;
		end if;
	end process;

	-- Flags
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				out_valid_i <= '0';
			else
				out_valid_i <= in_valid and (in_last or btsl(cnt = mode));
			end if;
		end if;
	end process;

	out_valid <= out_valid_i;

	process (clk)
	begin
		if rising_edge(clk) then
			if out_valid_i = '1' then
				out_sof <= '0';
				out_last <= '0';
			end if;

			if in_valid = '1' and in_sof = '1' then
				out_sof <= '1';
			end if;

			if in_valid = '1' and in_last = '1' then
				out_last <= '1';
			end if;
		end if;
	end process;

end rtl;
