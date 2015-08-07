--
-- vid_pipeline.vhd
--
-- Complete video pipeline from CSI packed to lines ready for DMA
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

use work.mipi_csi_pkg.all;


entity vid_pipeline is
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
end vid_pipeline;


architecture rtl of vid_pipeline is

	-- Signals
	------------

	-- Video input
	signal vin_ready_8b		: std_logic;
	signal vin_ready_10b	: std_logic;

	-- Video unpacked RAW8
	signal vu8_data			: std_logic_vector(7 downto 0);
	signal vu8_last			: std_logic;
	signal vu8_sof			: std_logic;
	signal vu8_valid		: std_logic;

	-- Video unpacked RAW10 (to 40b, then 10b)
	signal vu40_data		: std_logic_vector(39 downto 0);
	signal vu40_last		: std_logic;
	signal vu40_sof			: std_logic;
	signal vu40_valid		: std_logic;
	signal vu40_ready		: std_logic;

	signal vu40_data_reord	: std_logic_vector(39 downto 0);

	signal vu10_data		: std_logic_vector(9 downto 0);
	signal vu10_last		: std_logic;
	signal vu10_sof			: std_logic;
	signal vu10_valid		: std_logic;

	-- Video unpacked mux
	signal vum_data			: std_logic_vector(9 downto 0);
	signal vum_last			: std_logic;
	signal vum_sof			: std_logic;
	signal vum_valid		: std_logic;

	-- Video color
	signal vcol_red			: std_logic_vector(7 downto 0);
	signal vcol_green		: std_logic_vector(7 downto 0);
	signal vcol_blue		: std_logic_vector(7 downto 0);
	signal vcol_last		: std_logic;
	signal vcol_sof			: std_logic;
	signal vcol_valid		: std_logic;

	-- Video format mux
	signal vufm_data		: std_logic_vector(15 downto 0);
	signal vcfm_data		: std_logic_vector(31 downto 0);

	signal vfm_data			: std_logic_vector(31 downto 0);
	signal vfm_last			: std_logic;
	signal vfm_sof			: std_logic;
	signal vfm_valid		: std_logic;

	-- Video cropped
	signal vcrop_data		: std_logic_vector(31 downto 0);
	signal vcrop_last		: std_logic;
	signal vcrop_sof		: std_logic;
	signal vcrop_valid		: std_logic;

	-- Video packed
	signal vpack_data		: std_logic_vector(31 downto 0);
	signal vpack_last		: std_logic;
	signal vpack_sof		: std_logic;
	signal vpack_valid		: std_logic;

begin

	-- Ready signal generation depending on selected path
	process (vin_ready_8b, vin_ready_10b, ctrl_vfm, ctrl_vum)
	begin
		vin_ready <= '0';

		if ctrl_vfm(1) = '0' then
			vin_ready <= '1';
		elsif ctrl_vfm(1) = '1' then
			if ctrl_vum = '0' then
				vin_ready <= vin_ready_8b;
			elsif ctrl_vum = '1' then
				vin_ready <= vin_ready_10b;
			end if;
		end if;
	end process;

	-- Unpack RAW8 path
	repack_32b_to_8b_I: vid_32b_to_8b
		port map (
			in_data		=> vin_data,
			in_last		=> vin_last,
			in_sof		=> vin_sof,
			in_valid	=> vin_valid,
			in_ready	=> vin_ready_8b,
			out_data	=> vu8_data,
			out_last	=> vu8_last,
			out_sof		=> vu8_sof,
			out_valid	=> vu8_valid,
			out_ready	=> '1',
			clk			=> clk,
			rst			=> rst
		);

	-- Unpack RAW10 path
	repack_32b_to_40b_I: vid_32b_to_40b
		port map (
			in_data		=> vin_data,
			in_last		=> vin_last,
			in_sof		=> vin_sof,
			in_valid	=> vin_valid,
			in_ready	=> vin_ready_10b,
			out_data	=> vu40_data,
			out_last	=> vu40_last,
			out_sof		=> vu40_sof,
			out_valid	=> vu40_valid,
			out_ready	=> vu40_ready,
			clk			=> clk,
			rst			=> rst
		);

	vu40_data_reord <=
		vu40_data(31 downto 24) & vu40_data(39 downto 38) &
		vu40_data(23 downto 16) & vu40_data(37 downto 36) &
		vu40_data(15 downto  8) & vu40_data(35 downto 34) &
		vu40_data( 7 downto  0) & vu40_data(33 downto 32);

	repack_40b_to_10b_I: vid_40b_to_10b
		port map (
			in_data		=> vu40_data_reord,
			in_last		=> vu40_last,
			in_sof		=> vu40_sof,
			in_valid	=> vu40_valid,
			in_ready	=> vu40_ready,
			out_data	=> vu10_data,
			out_last	=> vu10_last,
			out_sof		=> vu10_sof,
			out_valid	=> vu10_valid,
			out_ready	=> '1',
			clk			=> clk,
			rst			=> rst
		);

	-- Unpack mode selection / mux
	process (clk)
	begin
		if rising_edge(clk) then
			if ctrl_vum = '1' then
				vum_data  <= vu10_data;
				vum_last  <= vu10_last;
				vum_sof   <= vu10_sof;
				vum_valid <= vu10_valid;
			else
				vum_data  <= vu8_data & vu8_data(7 downto 6);
				vum_last  <= vu8_last;
				vum_sof   <= vu8_sof;
				vum_valid <= vu8_valid;
			end if;
		end if;
	end process;

	-- Debayering
	debayer_I: vid_debayer
		port map (
			in_data		=> vum_data,
			in_last		=> vum_last,
			in_sof		=> vum_sof,
			in_valid	=> vum_valid,
			out_red		=> vcol_red,
			out_green	=> vcol_green,
			out_blue	=> vcol_blue,
			out_last	=> vcol_last,
			out_sof		=> vcol_sof,
			out_valid	=> vcol_valid,
			pol_col		=> ctrl_pol(0),
			pol_line	=> ctrl_pol(1),
			clk			=> clk,
			rst			=> rst
		);

	-- Format mux
		-- Unpacked format mux
	with ctrl_ufm select vufm_data <=
		x"00" & vum_data(9 downto 2)	when "00",
		"000000" & vum_data				when "10",
		vum_data & vum_data(9 downto 4)	when "11",
		x"0000" when others;

		-- Color format mux
	with ctrl_cfm(7 downto 6) select vcfm_data(31 downto 24) <=
		x"00"		when "00",
		vcol_red	when "01",
		vcol_green	when "10",
		vcol_blue	when "11",
		x"00"		when others;

	with ctrl_cfm(5 downto 4) select vcfm_data(23 downto 16) <=
		x"00"		when "00",
		vcol_red	when "01",
		vcol_green	when "10",
		vcol_blue	when "11",
		x"00"		when others;

	with ctrl_cfm(3 downto 2) select vcfm_data(15 downto  8) <=
		x"00"		when "00",
		vcol_red	when "01",
		vcol_green	when "10",
		vcol_blue	when "11",
		x"00"		when others;

	with ctrl_cfm(1 downto 0) select vcfm_data( 7 downto  0) <=
		x"00"		when "00",
		vcol_red	when "01",
		vcol_green	when "10",
		vcol_blue	when "11",
		x"00"		when others;

		-- Final mux
	process (clk)
	begin
		if rising_edge(clk) then
			case ctrl_vfm is
				when "00" =>
					vfm_data  <= vin_data;
					vfm_last  <= vin_last;
					vfm_sof   <= vin_sof;
					vfm_valid <= vin_valid;

				when "10" =>
					vfm_data  <= x"0000" & vufm_data;
					vfm_last  <= vum_last;
					vfm_sof   <= vum_sof;
					vfm_valid <= vum_valid;

				when "11" =>
					vfm_data  <= vcfm_data;
					vfm_last  <= vcol_last;
					vfm_sof   <= vcol_sof;
					vfm_valid <= vcol_valid;

				when others =>
					vfm_data  <= (others => '0');
					vfm_last  <= '0';
					vfm_sof   <= '0';
					vfm_valid <= '0';
			end case;
		end if;
	end process;

	-- Cropping
	crop_I: vid_crop
		generic map (
			DATA_WIDTH	=> 32,
			CNT_WIDTH	=> 12
		)
		port map (
			in_data		=> vfm_data,
			in_last		=> vfm_last,
			in_sof		=> vfm_sof,
			in_valid	=> vfm_valid,
			out_data	=> vcrop_data,
			out_last	=> vcrop_last,
			out_sof		=> vcrop_sof,
			out_valid	=> vcrop_valid,
			win_cs		=> ctrl_crp_cs,
			win_ce		=> ctrl_crp_ce,
			win_ls		=> ctrl_crp_ls,
			win_le		=> ctrl_crp_le,
			clk			=> clk,
			rst			=> rst
		);

	-- Packing
	packer_I: vid_packer
		port map (
			in_data		=> vcrop_data,
			in_last		=> vcrop_last,
			in_sof		=> vcrop_sof,
			in_valid	=> vcrop_valid,
			out_data	=> vpack_data,
			out_last	=> vpack_last,
			out_sof		=> vpack_sof,
			out_valid	=> vpack_valid,
			mode		=> ctrl_pack,
			clk			=> clk,
			rst			=> rst
		);

	-- Output
	vout_data	<= vpack_data;
	vout_last	<= vpack_last;
	vout_sof	<= vpack_sof;
	vout_valid	<= vpack_valid;

end rtl;
