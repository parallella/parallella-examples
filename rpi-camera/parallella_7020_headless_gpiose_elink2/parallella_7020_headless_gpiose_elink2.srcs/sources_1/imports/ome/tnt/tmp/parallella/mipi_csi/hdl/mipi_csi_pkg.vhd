--
-- mipi_csi_pkg.vhd
--
-- All components defined in this IP
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


package mipi_csi_pkg is

	component mipi_csi_top
		generic (
			N_LANES			: integer := 2;
			PHY_INV_CLK		: boolean := true;
			PHY_INV_DATA	: boolean := true
		);
		port (
			-- PHY external connection
			pad_data_p		: in  std_logic_vector(N_LANES-1 downto 0);
			pad_data_n		: in  std_logic_Vector(N_LANES-1 downto 0);

			pad_clk_p		: in  std_logic;
			pad_clk_n		: in  std_logic;

			pad_lpdet_p		: in  std_logic;
			pad_lpdet_n		: in  std_logic;

			-- Video output [AXI Stream master]
			vaxi_data		: out std_logic_vector(31 downto 0);
			vaxi_last		: out std_logic;
			vaxi_sof		: out std_logic;
			vaxi_valid		: out std_logic;
			vaxi_ready		: in  std_logic;

			-- Control interface [AXI Lite slave]
				-- Write channel
			saxi_awvalid	: in  std_logic;
			saxi_awready	: out std_logic;
			saxi_awaddr		: in  std_logic_vector(31 downto 0);

			saxi_wvalid		: in  std_logic;
			saxi_wready		: out std_logic;
			saxi_wdata		: in  std_logic_vector(31 downto 0);
			saxi_wstrb		: in  std_logic_vector( 3 downto 0);

			saxi_bvalid		: out std_logic;
			saxi_bready		: in  std_logic;
			saxi_bresp		: out std_logic_vector( 1 downto 0);

				-- Read channel
			saxi_arvalid	: in  std_logic;
			saxi_arready	: out std_logic;
			saxi_araddr		: in  std_logic_vector(31 downto 0);

			saxi_rvalid		: out std_logic;
			saxi_rready		: in  std_logic;
			saxi_rdata		: out std_logic_vector(31 downto 0);
			saxi_rresp		: out std_logic_vector( 1 downto 0);

			-- Misc
			intr			: out std_logic;
			debug			: out std_logic_vector(7 downto 0);

			-- Common
			refclk			: in  std_logic;	-- 200 MHz ref for IDELAY
			clk				: in  std_logic;
			rst				: in  std_logic
		);
	end component;

	component mipi_csi_phy
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
	end component;

	component mipi_csi_pkt_recv
		generic (
			N_LANES		: integer := 2
		);
		port (
			-- PHY link
			phy_data		: in  std_logic_vector(2*N_LANES-1 downto 0);
			phy_lp			: in  std_logic;

			-- Packet output
			pkt_data		: out std_logic_vector(31 downto 0);
			pkt_hdr			: out std_logic;
			pkt_last		: out std_logic;
			pkt_valid		: out std_logic;

			-- Control
			ctrl_active		: in  std_logic;	-- Should be active ?
			ctrl_lpdet_byp	: in  std_logic;	-- Bypass LP detect
			stat_running	: out std_logic;	-- Currently active ?

			err_late_sync	: out std_logic;	-- No SYNC after falling LP
			err_bad_ecc		: out std_logic;	-- Invalid ECC
			err_early_lp	: out std_logic;	-- LP rise before pkt end

			-- Clock / Reset
			clk				: in  std_logic;
			rst				: in  std_logic
		);
	end component;

	component mipi_csi_pkt_parse
		port (
			-- Packet input
			pkt_data		: in  std_logic_vector(31 downto 0);
			pkt_hdr			: in  std_logic;
			pkt_last		: in  std_logic;
			pkt_valid		: in  std_logic;
			pkt_ready		: out std_logic;

			-- Video output
			vid_data		: out std_logic_vector(31 downto 0);
			vid_last		: out std_logic;
			vid_sof			: out std_logic;
			vid_valid		: out std_logic;
			vid_ready		: in  std_logic;

			-- Control
			ctrl_active		: in  std_logic;
			ctrl_hlt_on_err	: in  std_logic;
			ctrl_purge		: in  std_logic;
			ctrl_pause		: in  std_logic;

			stat_running	: out std_logic;
			stat_err_pending: out std_logic;

			err_no_hdr		: out std_logic;
			err_early_sof	: out std_logic;
			err_unk_pkt		: out std_logic;
			err_early_last	: out std_logic;
			err_late_last	: out std_logic;

			-- Clock / Reset
			clk				: in  std_logic;
			rst				: in  std_logic
		);
	end component;

	component vid_pipeline
		port (
			-- Video input
			vin_data	: in  std_logic_vector(31 downto 0);
			vin_last	: in  std_logic;
			vin_sof		: in  std_logic;
			vin_valid	: in  std_logic;
			vin_ready	: out std_logic;

			-- Video output
			vout_data	: out std_logic_vector(31 downto 0);
			vout_last	: out std_logic;
			vout_sof	: out std_logic;
			vout_valid	: out std_logic;

			-- Control
			ctrl_vum	: in  std_logic;
			ctrl_ufm	: in  std_logic_vector( 1 downto 0);
			ctrl_cfm	: in  std_logic_vector( 7 downto 0);
			ctrl_vfm	: in  std_logic_vector( 1 downto 0);
			ctrl_pack	: in  std_logic_vector( 1 downto 0);
			ctrl_pol	: in  std_logic_vector( 1 downto 0);
			ctrl_crp_cs	: in  std_logic_vector(11 downto 0);
			ctrl_crp_ce	: in  std_logic_vector(11 downto 0);
			ctrl_crp_ls	: in  std_logic_vector(11 downto 0);
			ctrl_crp_le	: in  std_logic_vector(11 downto 0);

			-- Clock / Reset
			clk			: in  std_logic;
			rst			: in  std_logic
		);
	end component;

	component vid_32b_to_40b
		port (
			-- Input
			in_data		: in  std_logic_vector(31 downto 0);
			in_last		: in  std_logic;
			in_sof		: in  std_logic;
			in_valid	: in  std_logic;
			in_ready	: out std_logic;

			-- Output
			out_data	: out std_logic_vector(39 downto 0);
			out_last	: out std_logic;
			out_sof		: out std_logic;
			out_valid	: out std_logic;
			out_ready	: in  std_logic;

			-- Clock / Reset
			clk			: in  std_logic;
			rst			: in  std_logic
		);
	end component;

	component vid_40b_to_10b
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
	end component;

	component vid_32b_to_8b
		port (
			-- Input
			in_data		: in  std_logic_vector(31 downto 0);
			in_last		: in  std_logic;
			in_sof		: in  std_logic;
			in_valid	: in  std_logic;
			in_ready	: out std_logic;

			-- Output
			out_data	: out std_logic_vector(7 downto 0);
			out_last	: out std_logic;
			out_sof		: out std_logic;
			out_valid	: out std_logic;
			out_ready	: in  std_logic;

			-- Clock / Reset
			clk			: in  std_logic;
			rst			: in  std_logic
		);
	end component;

	component vid_debayer
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
	end component;

	component vid_crop is
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

	component vid_packer
		port (
			-- Input
			in_data		: in  std_logic_vector(31 downto 0);
			in_last		: in  std_logic;
			in_sof		: in  std_logic;
			in_valid	: in  std_logic;

			-- Output
			out_data	: out std_logic_vector(31 downto 0);
			out_last	: out std_logic;
			out_sof		: out std_logic;
			out_valid	: out std_logic;

			-- Config
				-- 00: 32b , 10: 16b, 11: 8b
			mode		: in  std_logic_vector(1 downto 0);

			-- Clock / Reset
			clk			: in  std_logic;
			rst			: in  std_logic
		);
	end component;

end package mipi_csi_pkg;
