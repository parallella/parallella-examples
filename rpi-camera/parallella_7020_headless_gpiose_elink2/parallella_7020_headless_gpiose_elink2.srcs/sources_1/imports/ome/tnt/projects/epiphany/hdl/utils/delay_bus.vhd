--
-- delay_bus.vhd
--
-- Simply delay a WIDTH bits bus for N clock cycles
-- The last stage is a true FlipFlop for better timings.
--
-- Warning : If DELAY = 0, this will act as a simple pass-thru
--           but with qp forced to 0 !!!
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
use ieee.numeric_std.all;

library unisim;
use unisim.vcomponents.all;


entity delay_bus is
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
end delay_bus;


architecture rtl of delay_bus is

	type pipe_t is array (integer range <>) of std_logic_vector(WIDTH-1 downto 0);
	signal pipeline : pipe_t((DELAY/33) downto 0);

begin

	-- Input
	pipeline(0) <= d;

	-- SRL + FF stage generate
	srl_gen: for i in 0 to DELAY/33 generate
		constant step_delay : integer := DELAY - (i*33);
	begin

		-- Complete stage
		full_stage_gen: if step_delay > 33 generate
			signal srl_q	: std_logic_vector(WIDTH-1 downto 0);
		begin

			b_gen: for j in WIDTH-1 downto 0 generate

				srl_I: SRLC32E
					generic map( INIT => x"00000000" )
					port map (
						Q	=> srl_q(j),
						Q31	=> open,
						D	=> pipeline(i)(j),
						CLK	=> clk,
						CE	=> '1',
						A	=> "11111"
					);

				ff_I: FD
					generic map (INIT => '0')
					port map (
						Q => pipeline(i+1)(j),
						C => clk,
						D => srl_q(j)
					);

			end generate;

		end generate;

		-- Final stage
		part_stage_gen: if (step_delay > 1) and (step_delay <= 33) generate
			signal srl_q		: std_logic_vector(WIDTH-1 downto 0);
			constant srl_addr	: std_logic_vector(4 downto 0) := std_logic_vector(to_unsigned(step_delay-2,5));
		begin

			b_gen: for j in WIDTH-1 downto 0 generate

				srl_I: SRLC32E
					generic map( INIT => x"00000000" )
					port map (
						Q	=> srl_q(j),
						Q31	=> open,
						D	=> pipeline(i)(j),
						CLK	=> clk,
						CE	=> '1',
						A	=> srl_addr
					);

				ff_I: FD
					generic map (INIT => '0')
					port map (
						Q => q(j),
						C => clk,
						D => srl_q(j)
					);

			end generate;

			qp <= srl_q;

		end generate;

		-- Final reg-only stage
		reg_gen: if step_delay = 1 generate

			b_gen: for j in WIDTH-1 downto 0 generate

				ff_I: FD
					generic map (INIT => '0')
					port map (
						Q => q(j),
						C => clk,
						D => pipeline(i)(j)
					);

			end generate;

			qp <= pipeline(i);

		end generate;

		-- Trivial case
		pt_gen: if step_delay = 0 generate
			q  <= pipeline(i);
			qp <= (others => '0');
		end generate;

	end generate;

end rtl;
