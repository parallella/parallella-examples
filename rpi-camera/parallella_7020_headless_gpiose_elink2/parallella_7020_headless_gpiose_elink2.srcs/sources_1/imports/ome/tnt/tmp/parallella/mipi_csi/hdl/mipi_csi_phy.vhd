--
-- mipi_csi_phy.vhd
--
-- MIPI CSI RX - Physical layer
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


entity mipi_csi_phy is
	generic (
		N_LANES		: integer := 2;
		INV_CLK		: boolean := true;
		INV_DATA	: boolean := true
	);
	port (
		-- Pads
		pad_data_p	: in  std_logic_vector(N_LANES-1 downto 0);
		pad_data_n	: in  std_logic_Vector(N_LANES-1 downto 0);

		pad_clk_p	: in  std_logic;
		pad_clk_n	: in  std_logic;

		pad_lpdet_p	: in  std_logic;
		pad_lpdet_n	: in  std_logic;

		-- PHY output
		out_data	: out std_logic_vector(2*N_LANES-1 downto 0);
		out_lp		: out std_logic;
		out_clk		: out std_logic;

		-- Delay control
		dly_cnt		: in  std_logic_vector(4 downto 0);
		dly_ld_clk	: in  std_logic;
		dly_ld_data	: in  std_logic_vector(N_LANES-1 downto 0);
		dly_clk		: in  std_logic;	-- clk for dly_* signals
		dly_reset	: in  std_logic;

		dly_refclk	: in  std_logic		-- 200M ref clk for IDELAYCTRL
	);
end mipi_csi_phy;


architecture xilinx of mipi_csi_phy is

	-- Clock input
	signal clk_ibufg	: std_logic;
	signal clk_dly		: std_logic;
	signal clk_bufr		: std_logic;
	signal clk			: std_logic;

	-- Data input
	signal data_ibuf	: std_logic_vector(N_LANES-1 downto 0);
	signal data_dly		: std_logic_vector(N_LANES-1 downto 0);
	signal data_iddr	: std_logic_vector(2*N_LANES-1 downto 0);
	signal data_raw		: std_logic_vector(2*N_LANES-1 downto 0);

	-- LP detection
	signal lpdet_ibuf	: std_logic;
	signal lpdet_ior	: std_logic;
	signal lpdet_plr	: std_logic;
	signal lpdet_cnt	: std_logic_vector(2 downto 0);
	signal lpdet		: std_logic;

	attribute iob : string;
	attribute iob of lpdet_ior : signal is "TRUE";
	attribute bel : string;
	attribute bel of lpdet_ior : signal is "IDDR";

begin


	-- Clock input path
	---------------------

	clk_ibufg_I: IBUFGDS
		generic map (
			IOSTANDARD => "LVDS_25",
			DIFF_TERM => true
		)
		port map (
			I  => pad_clk_p,
			IB => pad_clk_n,
			O  => clk_ibufg
		);

	clk_idelay_I: IDELAYE2
		generic map (
			CINVCTRL_SEL          => "FALSE",
			DELAY_SRC             => "IDATAIN",
			HIGH_PERFORMANCE_MODE => "FALSE",
			IDELAY_TYPE           => "VAR_LOAD",
			IDELAY_VALUE          => 0,
			PIPE_SEL              => "FALSE",
			REFCLK_FREQUENCY      => 200.0,
			SIGNAL_PATTERN        => "CLOCK"
		)
		port map (
			CNTVALUEOUT	=> open,
			DATAOUT		=> clk_dly,
			C			=> dly_clk,
			CE			=> '0',
			CINVCTRL	=> '0',
			CNTVALUEIN	=> dly_cnt,
			DATAIN		=> '0',
			IDATAIN		=> clk_ibufg,
			INC			=> '0',
			LD			=> dly_ld_clk,
			LDPIPEEN	=> '0',
			REGRST		=> dly_reset
		);

	csi_clk_bufr: BUFR
		generic map (
			BUFR_DIVIDE => "BYPASS",
			SIM_DEVICE  => "7SERIES"
		)
		port map (
			O   => clk_bufr,
			CE  => '1',
			CLR => '0',
			I   => clk_dly
		);

	clk_noinv_gen: if INV_CLK = FALSE generate
		clk <= clk_bufr;
	end generate;

	clk_inv_gen: if INV_CLK = TRUE generate
		clk <= not clk_bufr;
	end generate;


	-- Data input path
	--------------------

	lane_gen: for lane in N_LANES-1 downto 0 generate

		data_ibuf_I: IBUFDS
			generic map (
				IOSTANDARD => "LVDS_25",
				DIFF_TERM => true
			)
			port map (
				I  => pad_data_p(lane),
				IB => pad_data_n(lane),
				O  => data_ibuf(lane)
			);

		data_idelay_I: IDELAYE2
			generic map (
				CINVCTRL_SEL          => "FALSE",
				DELAY_SRC             => "IDATAIN",
				HIGH_PERFORMANCE_MODE => "FALSE",
				IDELAY_TYPE           => "VAR_LOAD",
				IDELAY_VALUE          => 0,
				PIPE_SEL              => "FALSE",
				REFCLK_FREQUENCY      => 200.0,
				SIGNAL_PATTERN        => "DATA"
			)
			port map (
				CNTVALUEOUT	=> open,
				DATAOUT		=> data_dly(lane),
				C			=> dly_clk,
				CE			=> '0',
				CINVCTRL	=> '0',
				CNTVALUEIN	=> dly_cnt,
				DATAIN		=> '0',
				IDATAIN		=> data_ibuf(lane),
				INC			=> '0',
				LD			=> dly_ld_data(lane),
				LDPIPEEN	=> '0',
				REGRST		=> dly_reset
			);

		data_iddr_I: IDDR
			generic map (
				DDR_CLK_EDGE => "SAME_EDGE_PIPELINED",
				INIT_Q1      => '0',
				INIT_Q2      => '0',
				SRTYPE       => "SYNC"
			)
			port map (
				Q1 => data_iddr(2*lane+0),
				Q2 => data_iddr(2*lane+1),
				C  => clk,
				CE => '1',
				D  => data_dly(lane),
				R  => '0',
				S  => '0'
			);

	end generate;

	lane_noinv_gen: if INV_DATA = FALSE generate
		data_raw <= data_iddr;
	end generate;

	lane_inv_gen: if INV_DATA = TRUE generate
		data_raw <= not data_iddr;
	end generate;


	-- LP detection
	-----------------

	-- Input differential buffer
	lpdet_ibuf_I: IBUFDS
		generic map (
			IOSTANDARD => "LVDS_25",
			DIFF_TERM => false
		)
		port map (
			I  => pad_lpdet_p,
			IB => pad_lpdet_n,
			O  => lpdet_ibuf
		);

	-- Detect logic
	process (clk)
	begin
		if rising_edge(clk) then
			-- IO Register
			lpdet_ior <= lpdet_ibuf;

			-- PL register
			lpdet_plr <= lpdet_ior;

			-- Counter
			if (lpdet_plr = '1') and (lpdet_cnt /= (lpdet_cnt'range => '1')) then
				lpdet_cnt <= lpdet_cnt + 1;
			elsif (lpdet_plr = '0') and (lpdet_cnt /= (lpdet_cnt'range => '0')) then
				lpdet_cnt <= lpdet_cnt - 1;
			end if;

			-- Flip/Flop
			if lpdet_cnt = (lpdet_cnt'range => '0') then
				lpdet <= '0';
			elsif lpdet_cnt = (lpdet_cnt'range => '1') then
				lpdet <= '1';
			end if;
		end if;
	end process;


	-- Output
	-----------

	out_data <= data_raw;
	out_lp   <= lpdet;
	out_clk  <= clk;


	-- Delay control
	------------------

	idelayctrl_I: IDELAYCTRL
		port map (
			RDY    => open,
			REFCLK => dly_refclk,
			RST    => dly_reset
		);

end xilinx;
