--
-- vid_packer.vhd
--
-- Crops oa configurable window out of a video stream
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


entity vid_crop is
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
end vid_crop;


architecture rtl of vid_crop is

	signal last_1			: std_logic;
	signal last_2			: std_logic;
	signal last_3			: std_logic;

	signal sof_1			: std_logic;
	signal sof_2			: std_logic;
	signal sof_3			: std_logic;

	signal valid_1			: std_logic;
	signal valid_2			: std_logic;
	signal valid_3			: std_logic;

	signal data_3			: std_logic_vector(DATA_WIDTH-1 downto 0);

	signal cnt_col_1		: std_logic_vector(CNT_WIDTH-1 downto 0);
	signal cnt_line_1		: std_logic_vector(CNT_WIDTH-1 downto 0);

	signal win_cs_ok_2		: std_logic;
	signal win_ce_ok_2		: std_logic;
	signal win_ls_ok_2		: std_logic;
	signal win_le_ok_2		: std_logic;
	signal win_ce_last_2	: std_logic;
	signal win_ok_2			: std_logic;

begin

	-- Position counters
	----------------------

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				cnt_col_1  <= (others => '0');
				cnt_line_1 <= (others => '0');
			else
				if in_sof = '1' and in_valid = '1' then
					cnt_col_1  <= (others => '0');
					cnt_line_1 <= (others => '0');
				elsif valid_1 = '1' then
					if last_1 = '1' then
						cnt_col_1  <= (others => '0');
						cnt_line_1 <= cnt_line_1 + 1;
					else
						cnt_col_1 <= cnt_col_1 + 1;
					end if;
				end if;
			end if;
		end if;
	end process;


	-- Comparators
	----------------

	process (clk)
	begin
		if rising_edge(clk) then
			win_cs_ok_2 <= btsl(cnt_col_1 >= win_cs);
			win_ce_ok_2 <= btsl(cnt_col_1 <= win_ce);
			win_ls_ok_2 <= btsl(cnt_line_1 >= win_ls);
			win_le_ok_2 <= btsl(cnt_line_1 <= win_le);
			win_ce_last_2 <= btsl(cnt_col_1 = win_ce);
		end if;
	end process;

	win_ok_2 <= win_cs_ok_2 and win_ce_ok_2 and win_ls_ok_2 and win_le_ok_2;


	-- Flags
	----------

	process (clk)
	begin
		if rising_edge(clk) then
			-- Last flag
			last_1 <= in_last;
			last_2 <= last_1;
			last_3 <= valid_2 and win_ok_2 and (last_2 or win_ce_last_2);

			-- SOF
			sof_1 <= in_sof;
			sof_2 <= sof_1;

			if sof_2 = '1' and valid_2 = '1' then
				sof_3 <= '1';
			elsif valid_3 = '1' then
				sof_3 <= '0';
			end if;

			-- Valid flag
			valid_1 <= in_valid;
			valid_2 <= valid_1;
			valid_3 <= valid_2 and win_ok_2;
		end if;
	end process;


	-- Data delay
	---------------

	data_dly_I: delay_bus
		generic map (
			DELAY => 3,
			WIDTH => DATA_WIDTH
		)
		port map (
			d   => in_data,
			q   => data_3,
			qp  => open,
			clk => clk
		);


	-- Output
	-----------

	out_data	<= data_3;
	out_last	<= last_3;
	out_sof		<= sof_3;
	out_valid	<= valid_3;

end rtl;
