--
-- mipi_csi_top.vhd
--
-- MIPI CSI RX - Top Level
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
use work.mipi_csi_pkg.all;

library unimacro;
use unimacro.vcomponents.all;
library unisim;
use unisim.vcomponents.all;


entity mipi_csi_top is
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
end mipi_csi_top;


architecture rtl of mipi_csi_top is

	-- Components
	---------------

	component axilite2slb
		generic (
			ADDR_WIDTH		: integer := 16;
			READ_CHANS		: integer := 1
		);
		port (
			-- SLB
			slb_addr		: out std_logic_vector(ADDR_WIDTH-1 downto 0);
			slb_wdata		: out std_logic_vector(31 downto 0);
			slb_rdata		: in  slv32_array_t(0 to READ_CHANS-1);
			slb_wstb		: out std_logic;
			slb_rstb		: out std_logic;

			-- AXI Lite interface
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

				-- Common
			saxi_aclk		: in  std_logic;
			saxi_rst_n		: in  std_logic
		);
	end component;

	component slb_reg
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
	end component;

	component ila_0
		port(
			clk		: in std_logic;
			probe0	: in std_logic_vector(35 downto 0);
			probe1	: in std_logic_vector(35 downto 0);
			probe2	: in std_logic_vector(35 downto 0);
			probe3	: in std_logic_vector(35 downto 0);
			probe4	: in std_logic_vector(15 downto 0)
		);
	end component;


	-- Signals
	------------

	-- PHY raw output
	signal phy_data				: std_logic_vector(2*N_LANES-1 downto 0);
	signal phy_lp				: std_logic;
	signal phy_clk				: std_logic;

	-- PHY delay control (sync to clk)
	signal ctrl_dly_cnt			: std_logic_vector(4 downto 0);
	signal ctrl_dly_ld_clk		: std_logic;
	signal ctrl_dly_ld_data		: std_logic_vector(N_LANES-1 downto 0);

	-- Packet receiver control / status / errors (PHY side)
	signal phy_ctrl_active		: std_logic;
	signal phy_ctrl_lpdet_byp	: std_logic;

	signal phy_stat_running		: std_logic;

	signal phy_err_late_sync	: std_logic;
	signal phy_err_bad_ecc		: std_logic;
	signal phy_err_early_lp		: std_logic;
	signal phy_err_overflow		: std_logic;

	-- Packet receiver control / status / errors (control side)
	signal ctrl_phy_active		: std_logic;
	signal ctrl_phy_lpdet_byp	: std_logic;

	signal stat_phy_running		: std_logic;

	signal err_phy_late_sync	: std_logic;
	signal err_phy_bad_ecc		: std_logic;
	signal err_phy_early_lp		: std_logic;
	signal err_phy_overflow		: std_logic;

	-- Packet receiver - write to FIFO
	signal pktw_data			: std_logic_vector(31 downto 0);
	signal pktw_hdr				: std_logic;
	signal pktw_last			: std_logic;
	signal pktw_valid			: std_logic;
	signal pktw_wren			: std_logic;
	signal pktw_full			: std_logic;

	-- Packet FIFO
	signal pkt_fifo_rdcount		: std_logic_vector(9 downto 0);
	signal pkt_fifo_wrcount		: std_logic_vector(9 downto 0);

	-- Packet parser - read from FIFO
	signal pktr_data			: std_logic_vector(31 downto 0);
	signal pktr_hdr				: std_logic;
	signal pktr_last			: std_logic;
	signal pktr_valid			: std_logic;
	signal pktr_ready			: std_logic;
	signal pktr_rden			: std_logic;
	signal pktr_empty			: std_logic;

	-- Packet parser control / status / errors
	signal ctrl_pp_active		: std_logic;
	signal ctrl_pp_hlt_on_err	: std_logic;
	signal ctrl_pp_purge		: std_logic;

	signal stat_pp_running		: std_logic;
	signal stat_pp_err_pending	: std_logic;

	signal err_pp_no_hdr		: std_logic;
	signal err_pp_early_sof		: std_logic;
	signal err_pp_unk_pkt		: std_logic;
	signal err_pp_early_last	: std_logic;
	signal err_pp_late_last		: std_logic;

	-- Video input to pipeline
	signal vin_data				: std_logic_vector(31 downto 0);
	signal vin_last				: std_logic;
	signal vin_sof				: std_logic;
	signal vin_valid			: std_logic;
	signal vin_ready			: std_logic;

	-- Video output from pipeline
	signal vout_data			: std_logic_vector(31 downto 0);
	signal vout_last			: std_logic;
	signal vout_sof				: std_logic;
	signal vout_valid			: std_logic;

	-- Pixel FIFO
	signal pix_fifo_afull		: std_logic;
	signal pix_fifo_aempty		: std_logic;
	signal pix_fifo_empty		: std_logic;
	signal pix_fifo_rden		: std_logic;

	signal pix_fifo_rdcount		: std_logic_vector(9 downto 0);
	signal pix_fifo_wrcount		: std_logic_vector(9 downto 0);

	signal pix_fifo_empty_fwft	: std_logic;
	signal pix_fifo_rden_fwft	: std_logic;
	signal pix_fifo_cnt			: std_logic_vector(5 downto 0);

	signal pix_fifo_valid		: std_logic;

	-- Output
	signal vaxi_sof_i			: std_logic;
	signal vaxi_last_i			: std_logic;
	signal vaxi_data_i			: std_logic_vector(31 downto 0);

	-- SLB
	signal slb_addr				: std_logic_vector( 3 downto 0);
	signal slb_wdata			: std_logic_vector(31 downto 0);
	signal slb_rdata			: std_logic_vector(31 downto 0);
	signal slb_wstb				: std_logic;
	signal slb_rstb				: std_logic;

	-- Registers
	signal reg_cr				: std_logic_vector(31 downto 0);
	signal reg_sr				: std_logic_vector(31 downto 0);
	signal reg_er				: std_logic_vector(31 downto 0);
	signal reg_er_set			: std_logic_vector(31 downto 0);
	signal reg_imr				: std_logic_vector(31 downto 0);
	signal reg_vpcr				: std_logic_vector(31 downto 0);
	signal reg_vccs				: std_logic_vector(11 downto 0);
	signal reg_vcce				: std_logic_vector(11 downto 0);
	signal reg_vcls				: std_logic_vector(11 downto 0);
	signal reg_vcle				: std_logic_vector(11 downto 0);

	-- Misc control
	signal phy_rst_req			: std_logic;
	signal phy_rst				: std_logic;
	signal phy_rst_cnt			: std_logic_vector(3 downto 0);

	signal rst_req_axi			: std_logic_vector(1 downto 0);
	signal rst_req				: std_logic;
	signal rst_i				: std_logic;
	signal rst_cnt				: std_logic_vector(3 downto 0);

	signal saxi_rst_n			: std_logic;

	signal debug_cnt			: std_logic_vector(15 downto 0);

begin

	--------------------------------------------------------------------------
	-- CSI PHY clock domain
	--------------------------------------------------------------------------

	-- PHY
	phy_I: mipi_csi_phy
		generic map (
			N_LANES		=> N_LANES,
			INV_CLK		=> PHY_INV_CLK,
			INV_DATA	=> PHY_INV_DATA
		)
		port map (
			pad_data_p	=> pad_data_p,
			pad_data_n	=> pad_data_n,
			pad_clk_p	=> pad_clk_p,
			pad_clk_n	=> pad_clk_n,
			pad_lpdet_p	=> pad_lpdet_p,
			pad_lpdet_n	=> pad_lpdet_n,
			out_data	=> phy_data,
			out_lp		=> phy_lp,
			out_clk		=> phy_clk,
			dly_cnt		=> ctrl_dly_cnt,
			dly_ld_clk	=> ctrl_dly_ld_clk,
			dly_ld_data	=> ctrl_dly_ld_data,
			dly_clk		=> clk,
			dly_reset	=> rst_i,
			dly_refclk	=> refclk
		);

	-- Packet receiver
	pkt_recv_I: mipi_csi_pkt_recv
		generic map (
			N_LANES		=> N_LANES
		)
		port map (
			phy_data		=> phy_data,
			phy_lp			=> phy_lp,
			pkt_data		=> pktw_data,
			pkt_hdr			=> pktw_hdr,
			pkt_last		=> pktw_last,
			pkt_valid		=> pktw_valid,
			ctrl_active		=> phy_ctrl_active,
			ctrl_lpdet_byp	=> phy_ctrl_lpdet_byp,
			stat_running	=> phy_stat_running,
			err_late_sync	=> phy_err_late_sync,
			err_bad_ecc		=> phy_err_bad_ecc,
			err_early_lp	=> phy_err_early_lp,
			clk				=> phy_clk,
			rst				=> phy_rst
		);

	-- FIFO write
	pktw_wren <= pktw_valid and not pktw_full;

	-- Overflow detect
	process (phy_clk)
	begin
		if rising_edge(phy_clk) then
			phy_err_overflow <= pktw_valid and pktw_full;
		end if;
	end process;

	-- Reset
	process (phy_clk, rst_i)
	begin
		if rst_i = '1' then
			phy_rst_req <= '1';
		elsif rising_edge(phy_clk) then
			phy_rst_req <= '0';
		end if;
	end process;

	process (phy_clk, phy_rst_req)
	begin
		if phy_rst_req = '1' then
			phy_rst_cnt <= (others => '1');
		elsif rising_edge(phy_clk) then
			if phy_rst_cnt(phy_rst_cnt'left) = '1' then
				phy_rst_cnt <= phy_rst_cnt - 1;
			end if;
		end if;
	end process;

	phy_rst <= phy_rst_cnt(phy_rst_cnt'left);


	--------------------------------------------------------------------------
	-- Inter clock domain
	--------------------------------------------------------------------------

	-- CSI packet FIFO
	pkt_fifo_I: FIFO_DUALCLOCK_MACRO
		generic map (
				DEVICE					=> "7SERIES",
				ALMOST_FULL_OFFSET		=> x"0080",
				ALMOST_EMPTY_OFFSET		=> x"0080",
				DATA_WIDTH				=> 34,
				FIFO_SIZE				=> "36Kb",
				FIRST_WORD_FALL_THROUGH	=> TRUE
		)
		port map (
			DI(33)			=> pktw_hdr,
			DI(32)			=> pktw_last,
			DI(31 downto 0)	=> pktw_data,
			WREN			=> pktw_wren,
			ALMOSTFULL		=> open,
			FULL			=> pktw_full,
			WRCOUNT			=> pkt_fifo_wrcount,
			WRERR			=> open,
			WRCLK			=> phy_clk,
			DO(33)			=> pktr_hdr,
			DO(32)			=> pktr_last,
			DO(31 downto 0)	=> pktr_data,
			RDEN			=> pktr_rden,
			ALMOSTEMPTY		=> open,
			EMPTY			=> pktr_empty,
			RDCOUNT			=> pkt_fifo_rdcount,
			RDERR			=> open,
			RDCLK			=> clk,
			RST				=> rst_i
		);

	-- PHY side control and error reporting
	phy_ctrl_active_I: xclk_sync
		port map (
			sig_in	=> ctrl_phy_active,
			clk_in	=> clk,
			sig_out	=> phy_ctrl_active,
			clk_out	=> phy_clk
		);

	phy_ctrl_lpdet_byp_I: xclk_sync
		port map (
			sig_in	=> ctrl_phy_lpdet_byp,
			clk_in	=> clk,
			sig_out	=> phy_ctrl_lpdet_byp,
			clk_out	=> phy_clk
		);

	phy_stat_running_I: xclk_sync
		port map (
			sig_in	=> phy_stat_running,
			clk_in	=> phy_clk,
			sig_out	=> stat_phy_running,
			clk_out	=> clk
		);

	phy_err_late_sync_I: xclk_pulse
		port map (
			pulse_in  => phy_err_late_sync,
			clk_in    => phy_clk,
			pulse_out => err_phy_late_sync,
			clk_out   => clk
		);

	phy_err_bad_ecc_I: xclk_pulse
		port map (
			pulse_in  => phy_err_bad_ecc,
			clk_in    => phy_clk,
			pulse_out => err_phy_bad_ecc,
			clk_out   => clk
		);

	phy_err_early_lp_I: xclk_pulse
		port map (
			pulse_in  => phy_err_early_lp,
			clk_in    => phy_clk,
			pulse_out => err_phy_early_lp,
			clk_out   => clk
		);

	phy_err_overflow_I: xclk_pulse
		port map (
			pulse_in  => phy_err_overflow,
			clk_in    => phy_clk,
			pulse_out => err_phy_overflow,
			clk_out   => clk
		);


	--------------------------------------------------------------------------
	-- AXI clock domain
	--------------------------------------------------------------------------

	-- Data path
	--------------

	-- FIFO read
	pktr_valid <= not pktr_empty;
	pktr_rden  <= not pktr_empty and pktr_ready;

	-- Packet parser to video
	pkt_parser_I: mipi_csi_pkt_parse
		port map (
			pkt_data		=> pktr_data,
			pkt_hdr			=> pktr_hdr,
			pkt_last		=> pktr_last,
			pkt_valid		=> pktr_valid,
			pkt_ready		=> pktr_ready,
			vid_data		=> vin_data,
			vid_last		=> vin_last,
			vid_sof			=> vin_sof,
			vid_valid		=> vin_valid,
			vid_ready		=> vin_ready,
			ctrl_active		=> ctrl_pp_active,
			ctrl_hlt_on_err	=> ctrl_pp_hlt_on_err,
			ctrl_purge		=> ctrl_pp_purge,
			ctrl_pause		=> pix_fifo_afull,
			stat_running	=> stat_pp_running,
			stat_err_pending=> stat_pp_err_pending,
			err_no_hdr		=> err_pp_no_hdr,
			err_early_sof	=> err_pp_early_sof,
			err_unk_pkt		=> err_pp_unk_pkt,
			err_early_last	=> err_pp_early_last,
			err_late_last	=> err_pp_late_last,
			clk				=> clk,
			rst				=> rst_i
		);

	-- Video pipeline
	vid_pipeline_I: vid_pipeline
		port map (
			vin_data    => vin_data,
			vin_last    => vin_last,
			vin_sof     => vin_sof,
			vin_valid   => vin_valid,
			vin_ready   => vin_ready,
			vout_data   => vout_data,
			vout_last   => vout_last,
			vout_sof    => vout_sof,
			vout_valid  => vout_valid,
			ctrl_vum	=> reg_vpcr(23),
			ctrl_ufm	=> reg_vpcr(21 downto 20),
			ctrl_cfm	=> reg_vpcr(15 downto  8),
			ctrl_vfm	=> reg_vpcr( 5 downto  4),
			ctrl_pack	=> reg_vpcr( 1 downto  0),
			ctrl_pol	=> reg_vpcr(17 downto 16),
			ctrl_crp_cs	=> reg_vccs,
			ctrl_crp_ce	=> reg_vcce,
			ctrl_crp_ls	=> reg_vcls,
			ctrl_crp_le	=> reg_vcle,
			clk         => clk,
			rst         => rst_i
		);

	-- Video pixel FIFO
		-- (!!! Not FWFT !!!)
	pix_fifo_I: FIFO_SYNC_MACRO
		generic map (
			DEVICE				=> "7SERIES",
			ALMOST_FULL_OFFSET	=> x"0080",
			ALMOST_EMPTY_OFFSET	=> x"0080",
			DATA_WIDTH			=> 34,
			FIFO_SIZE			=> "36Kb"
		)
		port map (
			DI(33)			=> vout_sof,
			DI(32)			=> vout_last,
			DI(31 downto 0)	=> vout_data,
			WREN			=> vout_valid,
			ALMOSTFULL		=> pix_fifo_afull,
			FULL			=> open,
			WRCOUNT			=> pix_fifo_wrcount,
			WRERR			=> open,
			DO(33)			=> vaxi_sof_i,
			DO(32)			=> vaxi_last_i,
			DO(31 downto 0)	=> vaxi_data_i,
			RDEN			=> pix_fifo_rden,
			ALMOSTEMPTY		=> pix_fifo_aempty,
			EMPTY			=> pix_fifo_empty,
			RDCOUNT			=> pix_fifo_rdcount,
			RDERR			=> open,
			CLK				=> clk,
			RST				=> rst_i
		);

	-- Convert to FWFT
	process (clk)
	begin
		if rising_edge(clk) then
			if rst_i = '1' then
				pix_fifo_empty_fwft <= '1';
			elsif (pix_fifo_rden_fwft = '1') or (pix_fifo_empty_fwft = '1') then
				pix_fifo_empty_fwft <= pix_fifo_empty;
			end if;
		end if;
	end process;

	pix_fifo_rden <= not pix_fifo_empty and (pix_fifo_rden_fwft or pix_fifo_empty_fwft);

	-- FIFO to AXI stream, trying to ensure minimum burst len
	pix_fifo_valid     <= not pix_fifo_empty_fwft and pix_fifo_cnt(pix_fifo_cnt'left);
	pix_fifo_rden_fwft <= pix_fifo_valid and vaxi_ready;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst_i = '1' then
				pix_fifo_cnt <= (others => '0');
			else
				if pix_fifo_empty_fwft = '1' then
					pix_fifo_cnt <= (others => '0');
				elsif pix_fifo_aempty = '0' then
					pix_fifo_cnt <= '1' & (pix_fifo_cnt'left-1 downto 0 => '0');
				elsif pix_fifo_cnt(pix_fifo_cnt'left) = '0' then
					pix_fifo_cnt <= pix_fifo_cnt + 1;
				end if;
			end if;
		end if;
	end process;

	vaxi_data  <= vaxi_data_i;
	vaxi_last  <= vaxi_last_i;
	vaxi_sof   <= vaxi_sof_i;
	vaxi_valid <= pix_fifo_valid;


	-- AXI control
	----------------

	-- AXI to SLB
	axi_ctrl_I: axilite2slb
		generic map (
			ADDR_WIDTH		=> 4,
			READ_CHANS		=> 1 
		)
		port map (
			slb_addr		=> slb_addr,
			slb_wdata		=> slb_wdata,
			slb_rdata(0)	=> slb_rdata,
			slb_wstb		=> slb_wstb,
			slb_rstb		=> slb_rstb,
			saxi_awvalid	=> saxi_awvalid,
			saxi_awready	=> saxi_awready,
			saxi_awaddr		=> saxi_awaddr,
			saxi_wvalid		=> saxi_wvalid,
			saxi_wready		=> saxi_wready,
			saxi_wdata		=> saxi_wdata,
			saxi_wstrb		=> saxi_wstrb,
			saxi_bvalid		=> saxi_bvalid,
			saxi_bready		=> saxi_bready,
			saxi_bresp		=> saxi_bresp,
			saxi_arvalid	=> saxi_arvalid,
			saxi_arready	=> saxi_arready,
			saxi_araddr		=> saxi_araddr,
			saxi_rvalid		=> saxi_rvalid,
			saxi_rready		=> saxi_rready,
			saxi_rdata		=> saxi_rdata,
			saxi_rresp		=> saxi_rresp,
			saxi_aclk		=> clk,
			saxi_rst_n		=> saxi_rst_n
		);

	-- Registers
	reg_cr_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 32,
			ADDR	=> x"0",
			INIT	=> x"00000000"
		)
		port map (
			reg			=> reg_cr,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	reg_imr_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 32,
			ADDR	=> x"3",
			INIT	=> x"00000000"
		)
		port map (
			reg			=> reg_imr,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	reg_vpcr_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 32,
			ADDR	=> x"5",
			INIT	=> x"00133930"
		)
		port map (
			reg			=> reg_vpcr,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	reg_crop_colstart_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 12,
			ADDR	=> x"8",
			INIT	=> x"000"
		)
		port map (
			reg			=> reg_vccs,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	reg_crop_colend_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 12,
			ADDR	=> x"9",
			INIT	=> x"fff"
		)
		port map (
			reg			=> reg_vcce,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	reg_crop_linestart_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 12,
			ADDR	=> x"A",
			INIT	=> x"000"
		)
		port map (
			reg			=> reg_vcls,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	reg_crop_lineend_I: slb_reg
		generic map (
			AWIDTH	=>  4,
			RWIDTH	=> 12,
			ADDR	=> x"B",
			INIT	=> x"fff"
		)
		port map (
			reg			=> reg_vcle,
			slb_addr	=> slb_addr,
			slb_wdata	=> slb_wdata,
			slb_wstb	=> slb_wstb,
			clk			=> clk,
			rst			=> rst_i
		);

	-- IDELAY control
	process (clk)
	begin
		if rising_edge(clk) then
			if rst_i = '1' then
				ctrl_dly_cnt     <= (others => '0');
				ctrl_dly_ld_clk  <= '0';
				ctrl_dly_ld_data <= (others => '0');
			else
				-- Data
				ctrl_dly_cnt <= slb_wdata(4 downto 0);

				-- Load strobes
				if (slb_wstb = '1') and (slb_addr = x"4") then
					ctrl_dly_ld_clk  <= slb_wdata(28);
					ctrl_dly_ld_data <= slb_wdata(N_LANES+23 downto 24);
				else
					ctrl_dly_ld_clk  <= '0';
					ctrl_dly_ld_data <= (others => '0');
				end if;
			end if;
		end if;
	end process;

	-- 0x00 - CR - Control Regiser
	ctrl_pp_purge      <= reg_cr(18);
	ctrl_pp_hlt_on_err <= reg_cr(17);
	ctrl_pp_active     <= reg_cr(16);
	ctrl_phy_lpdet_byp <= reg_cr( 1);
	ctrl_phy_active    <= reg_cr( 0);

	-- 0x01 - SR - Status register
	reg_sr <=
		pix_fifo_empty &
		pktr_empty &
		(29 downto 18 => '0') &
		stat_pp_err_pending &
		stat_pp_running &
		(15 downto 1 => '0') &
		stat_phy_running;

	-- 0x02 - ER - Error register
	reg_er_set <=
		(31 downto 20 => '0') &
		err_phy_overflow &
		err_phy_early_lp &
		err_phy_bad_ecc &
		err_phy_late_sync &
		(15 downto  5 => '0') &
		err_pp_late_last &
		err_pp_early_last &
		err_pp_unk_pkt &
		err_pp_early_sof &
		err_pp_no_hdr;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst_i = '1' then
				reg_er <= (others => '0');
			else
				if (slb_wstb = '1' and slb_addr = x"2") then
					reg_er <= (reg_er or reg_er_set) and not slb_wdata;
				else
					reg_er <=  reg_er or reg_er_set;
				end if;
			end if;
		end if;
	end process;

	-- 0x03 - IMR - Interrupt Mask Register
	process (clk)
	begin
		if rising_edge(clk) then
			if rst_i = '1' then
				intr <= '0';
			else
				intr <= or_reduce(reg_er and reg_imr);
			end if;
		end if;
	end process;

	-- Read mux
	process (clk)
	begin
		if rising_edge(clk) then
			if slb_addr = x"1" then
				slb_rdata <= reg_sr;
			elsif slb_addr = x"2" then
				slb_rdata <= reg_er;
			else
				slb_rdata <= (others => '0');
			end if;
		end if;
	end process;

	-- Reset request
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				rst_req_axi <= "00";
			else
				if (slb_wstb = '1') and (slb_addr = x"0") then
					rst_req_axi(0) <= slb_wdata(31);
					rst_req_axi(1) <= slb_wdata(30);
				else
					rst_req_axi(0) <= '0';
					rst_req_axi(1) <= rst_req_axi(1);
				end if;
			end if;
		end if;
	end process;


	-- Reset
	----------

	rst_req <= rst or rst_req_axi(0) or rst_req_axi(1);

	process (clk)
	begin
		if rising_edge(clk) then
			if rst_req = '1' then
				rst_cnt <= (others => '1');
			elsif rst_cnt(rst_cnt'left) = '1' then
				rst_cnt <= rst_cnt - 1;
			end if;
		end if;
	end process;

	rst_i <= rst_cnt(rst_cnt'left);

	saxi_rst_n <= not rst;


	-- Misc
	---------

	-- Debug
	process (clk)
	begin
		if rising_edge(clk) then
			debug(0) <= pktr_empty;
			debug(1) <= pktr_rden;
			debug(2) <= pix_fifo_empty;
			debug(3) <= pix_fifo_rden;
		end if;
	end process;

	process (phy_clk)
	begin
		if rising_edge(phy_clk) then
			debug(4) <= phy_lp;
			debug(5) <= pktw_hdr;
			debug(6) <= pktw_last;
			debug(7) <= pktw_valid;
		end if;
	end process;

	ila_I: ila_0
		port map (
			clk					=> clk,
			probe0(35)			=> pktr_ready,
			probe0(34)			=> pktr_valid,
			probe0(33)			=> pktr_hdr,
			probe0(32)			=> pktr_last,
			probe0(31 downto 0) => pktr_data,
			probe1(35)			=> vin_ready,
			probe1(34)			=> vin_valid,
			probe1(33)			=> vin_sof,
			probe1(32)			=> vin_last,
			probe1(31 downto 0) => vin_data,
			probe2(35)			=> pix_fifo_afull,
			probe2(34)			=> vout_valid,
			probe2(33)			=> vout_sof,
			probe2(32)			=> vout_last,
			probe2(31 downto 0) => vout_data,
			probe3(35)			=> vaxi_ready,
			probe3(34)			=> pix_fifo_valid,	-- vaxi_valid
			probe3(33)			=> vaxi_sof_i,
			probe3(32)			=> vaxi_last_i,
			probe3(31 downto 0)	=> vaxi_data_i,
			probe4				=> debug_cnt
		);

	process (clk)
	begin
		if rising_edge(clk) then
			if rst_i = '1' then
				debug_cnt <= (others => '0');
			else
				if pix_fifo_valid = '1' and vaxi_ready = '1' then
					if vaxi_last_i = '1' then
						debug_cnt <= (others => '0');
					else
						debug_cnt <= debug_cnt + 1;
					end if;
				end if;
			end if;
		end if;
	end process;

end rtl;
