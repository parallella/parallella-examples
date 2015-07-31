--
-- fifo_srl.vhd
--
-- Very small/light-weight FIFO using SRL.
--
-- Only for synchronous design. Has a fixed depth of 15 or 31 entries and
-- always work in the so-called first-word-fall-thru mode.
-- (Note that to implement the not fwft mode, i think only the empty
--  flag generation and srl_read need to be modified.
--  srl_read <= fifo_rden might just do the trick actually or not ...)
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

library unisim;
use unisim.vcomponents.all;

use work.utils_pkg.all;


entity fifo_srl is
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
end fifo_srl;


architecture rtl_xilinx of fifo_srl is

	-- Components
	---------------

	component updown_cnt is
		generic (
			WIDTH : integer := 5
		);
		port (
			d	: in  std_logic_vector(WIDTH-1 downto 0);
			q	: out std_logic_vector(WIDTH-1 downto 0);
			up_down	: in  std_logic
		);
	end component;


	-- Constants
	--------------

	constant AW			: integer := log2(FIFO_DEPTH);


	-- Signals
	------------

	-- The SRL output / counter / control / flag
	signal srl_q		: std_logic_vector(FIFO_WIDTH-1 downto 0);

	signal srl_addr		: std_logic_vector(AW-1 downto 0);
	signal srl_addr_nxt	: std_logic_vector(AW-1 downto 0);
	signal srl_addr_move: std_logic;

	signal srl_write	: std_logic;
	signal srl_read		: std_logic;

	signal srl_full		: std_logic;
	signal srl_afull	: std_logic := '0'; -- Default value if no afull
	signal srl_empty	: std_logic;
	signal srl_aempty	: std_logic;

	-- Control/Buffer
	signal fifo_empty_i	: std_logic;

begin

	-- Instantiate the SRLs
	s16_gen: if FIFO_DEPTH = 16 generate
		isrls: for i in 0 to FIFO_WIDTH-1 generate
			isrl_I: SRL16E
				port map (
					D	=> fifo_di(i),
					Q	=> srl_q(i),
					A0	=> srl_addr(0),
					A1	=> srl_addr(1),
					A2	=> srl_addr(2),
					A3	=> srl_addr(3),
					CE	=> srl_write,
					CLK	=> clk
				);
		end generate;
	end generate;

	s32_gen: if FIFO_DEPTH = 32 generate
		isrls: for i in 0 to FIFO_WIDTH-1 generate
			isrl_I: SRLC32E
				port map (
					D 	=> fifo_di(i),
					Q 	=> srl_q(i),
					Q31 => open,
					A 	=> srl_addr,
					CLK => clk,
					CE 	=> srl_write
				);
		end generate;
	end generate;

	-- Internal address counter
	srl_addr_move <= srl_write xor srl_read;

		-- This component does that, but better than XST :
		-- srl_addr_nxt <= (srl_addr+1) when srl_write = '1' else (srl_addr-1);
	counter : updown_cnt
		generic map (
			WIDTH => AW
		)
		port map (
			d		=> srl_addr,
			q		=> srl_addr_nxt,
			up_down	=> srl_write
		);

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				srl_addr <= (others => '1');
			elsif srl_addr_move = '1' then
				srl_addr <= srl_addr_nxt;
			end if;
		end if;
	end process;

	-- SRL status flag
	srl_full  <= btsl(srl_addr = ((AW-1 downto 1 => '1') & '0'));

	srl_afull_gen: if AFULL_LEVEL /= -1 generate
		srl_afull <= btsl((srl_addr >= conv_std_logic_vector(AFULL_LEVEL,AW))
						and (srl_addr /= (AW-1 downto 0 => '1')));
	end generate;

	srl_aempty <= btsl(srl_addr = (AW-1 downto 0 => '0'));

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				srl_empty <= '1';
			elsif srl_addr_move = '1' then
				srl_empty <= srl_aempty and srl_read;
			end if;
		end if;
	end process;

	-- The output register (to capture when we expulse from SRL)
	process (clk)
	begin
		if rising_edge(clk) then
			if srl_read = '1' then
				fifo_do <= srl_q;
			end if;
		end if;
	end process;

	-- Control and flag generation
		-- Write/Full is easy
	srl_write <= fifo_wren;
	fifo_full <= srl_full;
	fifo_afull <= srl_afull;

		-- Read/Empty is tricky
	process (clk)
	begin
		if rising_edge(clk) then
			if rst='1' then
				fifo_empty_i <= '1';
			elsif fifo_rden='1' or srl_read='1' then
				fifo_empty_i <= srl_empty;
			end if;
		end if;
	end process;

	srl_read <= (fifo_rden or fifo_empty_i) and not srl_empty;

	fifo_empty <= fifo_empty_i;

end rtl_xilinx;


-- ---------------------------------------------------------------------------

--
-- This little combinatorial block implements
-- q <= d - 1 when up_down = '1' else d + 1;
-- It's just that XST doesn't infer that optimally at all
-- for 4 bits vectors.
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

library unisim;
use unisim.vcomponents.all;


entity updown_cnt is
	generic (
		WIDTH : integer := 5
	);
	port (
		d	: in  std_logic_vector(WIDTH-1 downto 0);
		q	: out std_logic_vector(WIDTH-1 downto 0);
		up_down	: in  std_logic
	);
end updown_cnt;


architecture structure_xilinx of updown_cnt is

	signal carry	: std_logic_vector(WIDTH-1 downto 0);
	signal lo		: std_logic_vector(WIDTH-1 downto 0);

begin

	-- Upper cells
	adder_cell: for i in 1 to WIDTH-1 generate
	begin

		-- The LUT
		lut_I: LUT2_L
			generic map (
				INIT => "1001"
			)
			port map (
				I0	=> d(i),
				I1	=> up_down,
				LO	=> lo(i)
			);

		-- The muxcy for the preceding cell
		muxcy_I: MUXCY_L
			port map (
				DI	=> d(i-1),
				CI	=> carry(i-1),
				S	=> lo(i-1),
				LO	=> carry(i)
			);

		-- The XORCY of this cell
		xorcy_I: XORCY_L
			port map (
				LI	=> lo(i),
				CI	=> carry(i),
				LO	=> q(i)
			);

	end generate;

	-- Bottom cell
	lut_bottom: LUT1_L
		generic map (
			INIT => "01"
		)
		port map (
			I0	=> d(0),
			LO	=> lo(0)
		);

	carry(0) <= '0';
	q(0) <= lo(0);

end structure_xilinx;
