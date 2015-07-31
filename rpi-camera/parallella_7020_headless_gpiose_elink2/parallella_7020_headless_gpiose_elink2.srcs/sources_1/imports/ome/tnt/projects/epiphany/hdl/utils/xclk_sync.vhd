--
-- xclk_sync.vhd
--
-- Simple cross-clock synchronizer
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


entity xclk_sync is
	port (
		sig_in	: in  std_logic;
		clk_in	: in  std_logic;

		sig_out	: out std_logic;
		clk_out : in  std_logic
	);
end xclk_sync;


architecture rtl of xclk_sync is

	signal reg_in	: std_logic;
	signal reg_out1	: std_logic;
	signal reg_out2	: std_logic;

	attribute dont_touch : string;
	attribute dont_touch of reg_in   : signal is "true";
	attribute dont_touch of reg_out1 : signal is "true";
	attribute dont_touch of reg_out2 : signal is "true";

begin

	process (clk_in)
	begin
		if rising_edge(clk_in) then
			reg_in <= sig_in;
		end if;
	end process;

	process (clk_out)
	begin
		if rising_edge(clk_out) then
			reg_out1 <= reg_in;
			reg_out2 <= reg_out1;
		end if;
	end process;

	sig_out <= reg_out2;

end rtl;
