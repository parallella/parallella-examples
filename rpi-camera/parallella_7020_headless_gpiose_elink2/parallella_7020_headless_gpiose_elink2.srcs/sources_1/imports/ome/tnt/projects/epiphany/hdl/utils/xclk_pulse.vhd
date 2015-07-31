--
-- xclk_pulse.vhd
--
-- Simple cross-clock pulse transfer
-- The pulses _must_ be several clock sources appart
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


entity xclk_pulse is
	generic (
		CNT_WIDTH	: integer := 3
	);
	port (
		pulse_in	: in  std_logic;
		clk_in		: in  std_logic;

		pulse_out	: out std_logic;
		clk_out		: in  std_logic
	);
end xclk_pulse;


architecture rtl of xclk_pulse is

	signal cnt			: std_logic_vector(CNT_WIDTH downto 0) := (others => '0');
	signal line_in		: std_logic := '0';
	signal line_out		: std_logic;
	signal line_out_r	: std_logic;

begin

	process (clk_in)
	begin
		if rising_edge(clk_in) then
			if cnt(cnt'left) = '0' then
				cnt <= cnt + 1;
			elsif pulse_in = '1' then
				cnt <= (others => '0');
			end if;
		end if;
	end process;

	process (clk_in)
	begin
		if rising_edge(clk_in) then
			if cnt(cnt'left) = '1' then
				line_in <= line_in xor pulse_in;
			end if;
		end if;
	end process;

	sync_I: xclk_sync
		port map (
			sig_in  => line_in,
			clk_in  => clk_in,
			sig_out => line_out,
			clk_out => clk_out
		);

	process (clk_out)
	begin
		if rising_edge(clk_out) then
			line_out_r <= line_out;
			pulse_out  <= line_out xor line_out_r;
		end if;
	end process;

end rtl;
