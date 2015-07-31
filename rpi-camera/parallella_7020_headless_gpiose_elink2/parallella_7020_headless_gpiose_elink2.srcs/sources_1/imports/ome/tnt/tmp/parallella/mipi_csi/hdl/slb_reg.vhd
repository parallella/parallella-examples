--
-- slb_reg.vhd
--
-- SLB Write-Only register
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

library work;
use work.utils_pkg.all;


entity slb_reg is
	generic (
		AWIDTH	: integer := 8;
		RWIDTH	: integer := 32;
		ADDR	: std_logic_vector;
		INIT	: std_logic_vector
	);
	port (
		reg			: out std_logic_vector(RWIDTH-1 downto 0);
		slb_addr	: in  std_logic_vector(AWIDTH-1 downto 0);
		slb_wdata	: in  std_logic_vector(31 downto 0);
		slb_wstb	: in  std_logic;
		clk			: in  std_logic;
		rst			: in  std_logic
	);
end slb_reg;


architecture rtl of slb_reg is

	signal wen : std_logic;

begin

	-- Write Enable
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				wen <= '0';
			else
				wen <= btsl(slb_addr = ADDR) and slb_wstb;
			end if;
		end if;
	end process;

	-- Data
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				reg <= INIT;
			elsif wen = '1' then
				reg <= slb_wdata(RWIDTH-1 downto 0);
			end if;
		end if;
	end process;

end rtl;
