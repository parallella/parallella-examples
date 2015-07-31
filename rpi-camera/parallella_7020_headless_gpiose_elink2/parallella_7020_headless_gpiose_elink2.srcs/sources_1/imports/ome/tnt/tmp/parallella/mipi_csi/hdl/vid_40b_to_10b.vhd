--
-- vid_40b_to_10b.vhd
--
-- Video - 40b to 10b unpacking (LSB first)
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


entity vid_40b_to_10b is
	port (
		-- Input
		in_data		: in  std_logic_vector(39 downto 0);
		in_last		: in  std_logic;
		in_sof		: in  std_logic;
		in_valid	: in  std_logic;
		in_ready	: out std_logic;

		-- Output
		out_data	: out std_logic_vector(9 downto 0);
		out_last	: out std_logic;
		out_sof		: out std_logic;
		out_valid	: out std_logic;
		out_ready	: in  std_logic;

		-- Clock / Reset
		clk			: in  std_logic;
		rst			: in  std_logic
	);
end vid_40b_to_10b;


architecture rtl of vid_40b_to_10b is

	signal cnt			: std_logic_vector(1 downto 0);
	signal ce			: std_logic;
	signal out_valid_i	: std_logic;

begin

	-- Misc control
	ce <= not out_valid_i or out_ready;
	in_ready <= btsl(cnt = "11") and out_ready;

	-- Counter
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cnt <= "00";
			elsif ce = '1' then
				if (in_last = '1' and cnt = "11") or (in_valid = '0') then
					cnt <= "00";
				else
					cnt <= cnt + 1;
				end if;
			end if;
		end if;
	end process;

	-- Output data mux
	process (clk)
	begin
		if rising_edge(clk) then
			if ce = '1' then
				case cnt is
					when "00" =>	out_data <= in_data( 9 downto  0);
					when "01" =>	out_data <= in_data(19 downto 10);
					when "10" =>	out_data <= in_data(29 downto 20);
					when "11" =>	out_data <= in_data(39 downto 30);
					when others =>	out_data <= (others => '0');
				end case;
			end if;
		end if;
	end process;

	-- Output valid flag
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				out_valid_i <= '0';
			elsif ce = '1' then
				out_valid_i <= in_valid;
			end if;
		end if;
	end process;

	out_valid <= out_valid_i;

	-- Output last flag
	process (clk)
	begin
		if rising_edge(clk) then
			if ce = '1' then
				out_last <= btsl(cnt = "11") and in_last;
			end if;
		end if;
	end process;

	-- Output SoF flag
	process (clk)
	begin
		if rising_edge(clk) then
			if ce = '1' then
				out_sof <= btsl(cnt = "00") and in_sof;
			end if;
		end if;
	end process;

end rtl;
