--
-- vid_debayer.vhd
--
-- Video - Simple bilinear debayering
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


entity vid_debayer is
	port (
		-- Input
		in_data		: in  std_logic_vector(9 downto 0);
		in_last		: in  std_logic;
		in_sof		: in  std_logic;
		in_valid	: in  std_logic;

		-- Output
		out_red		: out std_logic_vector(7 downto 0);
		out_green	: out std_logic_vector(7 downto 0);
		out_blue	: out std_logic_vector(7 downto 0);
		out_last	: out std_logic;
		out_sof		: out std_logic;
		out_valid	: out std_logic;

		-- Polarity config
		pol_col		: in  std_logic;
		pol_line	: in  std_logic;

		-- Clock / Reset
		clk			: in  std_logic;
		rst			: in  std_logic
	);
end vid_debayer;


architecture rtl of vid_debayer is

	-- Flags
	signal valid_x		: std_logic_vector(0 to 4);
	signal last_x		: std_logic_vector(0 to 4);
	signal sof_x		: std_logic_vector(0 to 4);

	signal sel_col_3	: std_logic;
	signal sel_line_3	: std_logic;

	-- Line buffer
	signal lbuf_raddr_1	: std_logic_vector(10 downto 0);
	signal lbuf_waddr_3	: std_logic_vector(10 downto 0);
	signal lbuf_rdata_3	: std_logic_vector(17 downto 0);
	signal lbuf_wdata_3 : std_logic_vector(17 downto 0);
	signal lbuf_wen_3	: std_logic;

	signal lbuf_raw_do	: std_logic_vector(31 downto 0);
	signal lbuf_raw_di	: std_logic_vector(31 downto 0);
	signal lbuf_raw_dop	: std_logic_vector( 3 downto 0);
	signal lbuf_raw_dip	: std_logic_vector( 3 downto 0);
	signal lbuf_raw_ra	: std_logic_vector(15 downto 0);
	signal lbuf_raw_wa	: std_logic_vector(15 downto 0);
	signal lbuf_raw_we	: std_logic_vector( 7 downto 0);

	-- Column buffer
	signal pix_l0c0_3	: std_logic_vector(8 downto 0);
	signal pix_l0c1_3	: std_logic_vector(8 downto 0);
	signal pix_l0c2_3	: std_logic_vector(8 downto 0);
	signal pix_l1c0_3	: std_logic_vector(8 downto 0);
	signal pix_l1c1_3	: std_logic_vector(8 downto 0);
	signal pix_l1c2_3	: std_logic_vector(8 downto 0);
	signal pix_l2c0_3	: std_logic_vector(8 downto 0);
	signal pix_l2c1_3	: std_logic_vector(8 downto 0);
	signal pix_l2c2_3	: std_logic_vector(8 downto 0);

	signal pix_l1c02_3	: std_logic_vector(9 downto 0);
	signal pix_l02c0_3	: std_logic_vector(9 downto 0);
	signal pix_l02c1_3	: std_logic_vector(9 downto 0);
	signal pix_l02c2_3	: std_logic_vector(9 downto 0);

	-- Interpolated pixels
	signal pix_red_4	: std_logic_vector(10 downto 0);
	signal pix_green_4	: std_logic_vector(10 downto 0);
	signal pix_blue_4	: std_logic_vector(10 downto 0);

begin

	-- Control
	------------

	-- Valid / Flags propagation
	valid_x(0) <= in_valid;
	last_x(0)  <= in_last;
	sof_x(0)   <= in_sof;

	process (clk)
	begin
		if rising_edge(clk) then
			valid_x(1 to 4) <= valid_x(0 to 3);
			last_x(1 to 4)  <= last_x(0 to 3);
			sof_x(1 to 4)   <= sof_x(0 to 3);
		end if;
	end process;

	-- Column / Line selection tracking
	process (clk)
	begin
		if rising_edge(clk) then
			if (valid_x(2) = '1' and sof_x(2) = '1') then
				sel_col_3  <= pol_col;
				sel_line_3 <= pol_line;
			elsif valid_x(3) = '1' then
				sel_col_3  <= (pol_col and last_x(3)) or (not sel_col_3 and not last_x(3));
				sel_line_3 <= sel_line_3 xor last_x(3);
			end if;
		end if;
	end process;


	-- Line buffer
	----------------

	-- RAM instance
	line_buf_I: RAMB36E1
		generic map (
			RDADDR_COLLISION_HWCONFIG => "PERFORMANCE",
			SIM_COLLISION_CHECK => "ALL",
			DOA_REG			=> 1,
			DOB_REG			=> 0,
			EN_ECC_READ		=> FALSE,
			EN_ECC_WRITE	=> FALSE,
			INIT_A			=> x"000000000",
			INIT_B			=> x"000000000",
			RAM_MODE		=> "TDP",
			RAM_EXTENSION_A	=> "NONE",
			RAM_EXTENSION_B	=> "NONE",
			READ_WIDTH_A	=> 18,
			READ_WIDTH_B	=> 0,
			WRITE_WIDTH_A	=> 0,
			WRITE_WIDTH_B	=> 18,
			RSTREG_PRIORITY_A => "RSTREG",
			RSTREG_PRIORITY_B => "RSTREG",
			SRVAL_A			=> X"000000000",
			SRVAL_B			=> X"000000000",
			SIM_DEVICE		=> "7SERIES",
			WRITE_MODE_A	=> "WRITE_FIRST",
			WRITE_MODE_B	=> "WRITE_FIRST"
		)
		port map (
			CASCADEOUTA 	=> open,
			CASCADEOUTB 	=> open,
			DBITERR			=> open,
			ECCPARITY		=> open,
			RDADDRECC		=> open,
			SBITERR			=> open,
			DOADO			=> lbuf_raw_do,
			DOPADOP			=> lbuf_raw_dop,
			DOBDO			=> open,
			DOPBDOP			=> open,
			CASCADEINA		=> '0',
			CASCADEINB		=> '0',
			INJECTDBITERR	=> '0',
			INJECTSBITERR	=> '0',
			ADDRARDADDR		=> lbuf_raw_ra,
			CLKARDCLK		=> clk,
			ENARDEN			=> '1',
			REGCEAREGCE		=> '1',
			RSTRAMARSTRAM	=> '0',
			RSTREGARSTREG	=> '0',
			WEA				=> (others => '0'),
			DIADI			=> (others => '0'),
			DIPADIP			=> (others => '0'),
			ADDRBWRADDR		=> lbuf_raw_wa,
			CLKBWRCLK		=> clk,
			ENBWREN			=> '1',
			REGCEB			=> '1',
			RSTRAMB			=> '0',
			RSTREGB			=> '0',
			WEBWE			=> lbuf_raw_we,
			DIBDI			=> lbuf_raw_di,
			DIPBDIP			=> lbuf_raw_dip
		);

	-- Mapping
	lbuf_raw_ra  <= '0' & lbuf_raddr_1 & x"0";
	lbuf_raw_wa  <= '0' & lbuf_waddr_3 & x"0";
	lbuf_raw_we  <= "000000" & lbuf_wen_3 & lbuf_wen_3;
	lbuf_rdata_3 <= lbuf_raw_dop(1 downto 0) & lbuf_raw_do(15 downto 0);

	lbuf_raw_di  <= x"0000" & lbuf_wdata_3(15 downto 0);
	lbuf_raw_dip <= "00" & lbuf_wdata_3(17 downto 16);

	-- Control
	lbuf_wen_3 <= valid_x(3);

	-- Address generation
	process (clk)
	begin
		if rising_edge(clk) then
			if (sof_x(0) = '1'  and valid_x(0) = '1') or
			   (last_x(1) = '1' and valid_x(1) = '1') then
				lbuf_raddr_1 <= (others => '0');
			elsif valid_x(1) = '1' then
				lbuf_raddr_1 <= lbuf_raddr_1 + 1;
			end if;
		end if;
	end process;

	addr_dly_I: delay_bus
		generic map (
			DELAY => 2,
			WIDTH => 11
		)
		port map (
			d   => lbuf_raddr_1,
			q   => lbuf_waddr_3,
			qp  => open,
			clk => clk
		);

	-- Data
	data_dly_I: delay_bus
		generic map (
			DELAY => 3,
			WIDTH => 9
		)
		port map (
			d   => in_data(9 downto 1),
			q	=> lbuf_wdata_3(8 downto 0),
			qp  => open,
			clk => clk
		);

	lbuf_wdata_3(17 downto 9) <= lbuf_rdata_3(8 downto 0);

	pix_l0c2_3 <= lbuf_rdata_3(17 downto 9);
	pix_l1c2_3 <= lbuf_rdata_3( 8 downto 0);
	pix_l2c2_3 <= lbuf_wdata_3( 8 downto 0);


	-- Column buffer
	------------------

	process (clk)
	begin
		if rising_edge(clk) then
			if valid_x(3) = '1' then
				pix_l0c0_3 <= pix_l0c1_3;
				pix_l0c1_3 <= pix_l0c2_3;
				pix_l1c0_3 <= pix_l1c1_3;
				pix_l1c1_3 <= pix_l1c2_3;
				pix_l2c0_3 <= pix_l2c1_3;
				pix_l2c1_3 <= pix_l2c2_3;
			end if;
		end if;
	end process;


	-- Color interpolation
	------------------------

	-- Prepare some sums
	pix_l1c02_3 <= ('0' & pix_l1c0_3) + ('0' & pix_l1c2_3);
	pix_l02c2_3 <= ('0' & pix_l0c2_3) + ('0' & pix_l2c2_3);

	process (clk)
	begin
		if rising_edge(clk) then
			if valid_x(3) = '1' then
				pix_l02c0_3 <= pix_l02c1_3;
				pix_l02c1_3 <= pix_l02c2_3;
			end if;
		end if;
	end process;

	-- Green
	process (clk)
	begin
		if rising_edge(clk) then
			if (sel_col_3 xor sel_line_3) = '1' then
				pix_green_4 <= pix_l1c1_3 & "00";
			else
				pix_green_4 <= ('0' & (('0' & pix_l1c0_3) + ('0' & pix_l1c2_3))) + ('0' & pix_l02c1_3);
			end if;
		end if;
	end process;

	-- Red
	process (clk)
	begin
		if rising_edge(clk) then
			if (sel_col_3 = '0') and (sel_line_3 = '0') then
				pix_red_4 <= pix_l1c1_3 & "00";
			elsif (sel_col_3 = '1') and (sel_line_3 = '0') then
				pix_red_4 <= (('0' & pix_l1c0_3) + ('0' & pix_l1c2_3)) & '0';
			elsif (sel_col_3 = '0') and (sel_line_3 = '1') then
				pix_red_4 <= pix_l02c1_3 & '0';
			else -- (sel_col_3 = '1') and (sel_line_3 = '1')
				pix_red_4 <= ('0' & pix_l02c0_3) + ('0' & pix_l02c2_3);
			end if;
		end if;
	end process;

	-- Blue
	process (clk)
	begin
		if rising_edge(clk) then
			if (sel_col_3 = '0') and (sel_line_3 = '0') then
				pix_blue_4 <= ('0' & pix_l02c0_3) + ('0' & pix_l02c2_3);
			elsif (sel_col_3 = '1') and (sel_line_3 = '0') then
				pix_blue_4 <= pix_l02c1_3 & '0';
			elsif (sel_col_3 = '0') and (sel_line_3 = '1') then
				pix_blue_4 <= (('0' & pix_l1c0_3) + ('0' & pix_l1c2_3)) & '0';
			else -- (sel_col_3 = '1') and (sel_line_3 = '1')
				pix_blue_4 <= pix_l1c1_3 & "00";
			end if;
		end if;
	end process;


	-- Output
	-----------

	out_red   <= pix_red_4(10 downto 3);
	out_green <= pix_green_4(10 downto 3);
	out_blue  <= pix_blue_4(10 downto 3);
	out_last  <= last_x(4);
	out_sof   <= sof_x(4);
	out_valid <= valid_x(4);

end rtl;
