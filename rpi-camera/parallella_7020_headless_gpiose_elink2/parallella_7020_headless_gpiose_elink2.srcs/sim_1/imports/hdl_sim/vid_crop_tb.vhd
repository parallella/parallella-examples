--
-- vid_crop_tb.vhd
--
-- Test bench fo vid_crop block
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
use ieee.math_real.all;
use ieee.numeric_std.all;

library work;
use work.utils_pkg.all;


entity vid_crop_tb is
end vid_crop_tb;


architecture Behavioral of vid_crop_tb is

	-- DUT
	--------

	component vid_crop
		generic (
			DATA_WIDTH	: integer := 32;
			CNT_WIDTH	: integer := 12
		);
		port (
			-- Input
			in_data		: in  std_logic_vector(DATA_WIDTH-1 downto 0);
			in_last		: in  std_logic;
			in_sof		: in  std_logic;
			in_valid	: in  std_logic;

			-- Output
			out_data	: out std_logic_vector(DATA_WIDTH-1 downto 0);
			out_last	: out std_logic;
			out_sof		: out std_logic;
			out_valid	: out std_logic;

			-- Config
			win_cs		: in  std_logic_vector(CNT_WIDTH-1 downto 0);
			win_ce		: in  std_logic_vector(CNT_WIDTH-1 downto 0);
			win_ls		: in  std_logic_vector(CNT_WIDTH-1 downto 0);
			win_le		: in  std_logic_vector(CNT_WIDTH-1 downto 0);

			-- Clock / Reset
			clk			: in  std_logic;
			rst			: in  std_logic
		);
	end component;


	-- Signals
	------------

	signal random		: std_logic;
	signal cnt_x		: std_logic_vector(7 downto 0);
	signal cnt_y		: std_logic_vector(7 downto 0);

	signal in_data		: std_logic_vector(31 downto 0);
	signal in_last		: std_logic;
	signal in_sof		: std_logic;
	signal in_valid		: std_logic;

	signal out_data		: std_logic_vector(31 downto 0);
	signal out_last		: std_logic;
	signal out_sof		: std_logic;
	signal out_valid	: std_logic;

	signal clk			: std_logic := '0';
	signal rst			: std_logic;

begin

	-- DUT
	crop_I: vid_crop
		generic map (
			DATA_WIDTH	=> 32,
			CNT_WIDTH	=> 12
		)
		port map (
			in_data		=> in_data,
			in_last		=> in_last,
			in_sof		=> in_sof,
			in_valid	=> in_valid,
			out_data	=> out_data,
			out_last	=> out_last,
			out_sof		=> out_sof,
			out_valid	=> out_valid,
			win_cs		=> x"002",
			win_ce		=> x"01a",
			win_ls		=> x"005",
			win_le		=> x"01c",
			clk			=> clk,
			rst			=> rst
		);

	-- Data source
	process (clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				cnt_x <= (others => '0');
				cnt_y <= (others => '0');
			elsif in_valid='1' then
				if cnt_x = x"1f" then
					cnt_x <= x"00";
					if cnt_y = x"1f" then
						cnt_y <= x"00";
					else
						cnt_y <= cnt_y + 1;
					end if;
				else
					cnt_x <= cnt_x + 1;
				end if;
			end if;
		end if;
	end process;

	in_data		<= x"BABE" & cnt_x & cnt_y;
	in_last		<= btsl(cnt_x = x"1f");
	in_sof		<= btsl(cnt_x = x"00" and cnt_y = x"00");
	in_valid	<= not rst and random;

	-- Randomness
	process
		variable seed1, seed2 : positive; 
		variable rand : real;
	begin
		-- Reset
		random <= '0';

		wait until rst = '0';

		-- Write to output
		while true loop
			wait until rising_edge(clk);

			-- Random 'input valid'
			uniform(seed1, seed2, rand);

			if (rand > 0.50) then
				random <= '1';
			else
				random <= '0';
			end if;
		end loop;
	end process;

	-- Clock / Reset
	clk <= not clk after 5 ns;
	rst <= '1', '0' after 100 ns;

end Behavioral;
