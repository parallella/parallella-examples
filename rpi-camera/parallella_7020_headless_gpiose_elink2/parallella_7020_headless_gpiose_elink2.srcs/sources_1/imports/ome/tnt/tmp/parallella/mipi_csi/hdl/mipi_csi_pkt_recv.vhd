--
-- mipi_csi_pkt_recv.vhd
--
-- MIPI CSI RX - Packetizer
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


entity mipi_csi_pkt_recv is
	generic (
		N_LANES			: integer := 2
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
end mipi_csi_pkt_recv;


architecture rtl of mipi_csi_pkt_recv is

	-- Components
	---------------

	component mipi_ecc
		port (
			hdr_b0	: in  std_logic_vector(7 downto 0);
			hdr_b1	: in  std_logic_vector(7 downto 0);
			hdr_b2	: in  std_logic_vector(7 downto 0);
			ecc		: out std_logic_vector(7 downto 0)
		);
	end component;


	-- FSM
	--------

	type fsm_state_t is (
		HALTED,			-- Halted (not active)
		IDLE,			-- Idle
		SOT,			-- Searching for SoT
		HEADER,			-- Wait for Header capture
		DATA			-- Data
	);

	signal state_cur : fsm_state_t;
	signal state_nxt : fsm_state_t;


	-- Signals
	------------

	constant LANE_SHIFT_LEN : integer := int_min(16, 32 / N_LANES);

	-- Input
	signal data_shift	: std_logic_vector(N_LANES*LANE_SHIFT_LEN-1 downto 0);
	signal data_word_0	: std_logic_vector(31 downto 0);
	signal data_word_1	: std_logic_vector(31 downto 0);

	-- ECC
	signal ecc_rx_0		: std_logic_vector(7 downto 0);
	signal ecc_exp_0	: std_logic_vector(7 downto 0);
	signal ecc_valid_1	: std_logic;

	-- Sync & Capture generation
	signal sync_lane	: std_logic_vector(N_LANES-1 downto 0);
	signal sync_detect	: std_logic;
	signal sync_cnt		: std_logic_vector(3-log2(N_LANES) downto 0);

	signal capture_1	: std_logic;

	-- LP transition
	signal lp_r			: std_logic;
	signal lp_fall		: std_logic;

	-- Payload length
	signal pl_len_1		: std_logic_vector(16 downto 0);

	-- Error signals (combinatorial)
	signal err_late_sync_c	: std_logic;
	signal err_bad_ecc_c	: std_logic;
	signal err_early_lp_c	: std_logic;

begin

	-- Input
	----------

	-- Per-lane logic
	lane_gen: for lane in N_LANES-1 downto 0 generate
		constant lo_idx : integer :=  lane    * LANE_SHIFT_LEN;
		constant hi_idx : integer := (lane+1) * LANE_SHIFT_LEN - 1;
	begin
		process (clk)
		begin
			if rising_edge(clk) then
				-- Shift register for each lane
				data_shift(hi_idx downto lo_idx) <=
					phy_data(2*lane+1 downto 2*lane) &
					data_shift(hi_idx downto lo_idx+2);

				-- Sync pattern detect
				sync_lane(lane) <= btsl(data_shift(hi_idx downto hi_idx-15) = x"B800");
			end if;
		end process;
	end generate;

	-- Map the shift registers to a 32 bit data word in the right order
	byte_map_gen: for byte in 3 downto 0 generate
		constant lane_sel	: integer := byte mod N_LANES;
		constant lane_byte	: integer := (3 - byte) / N_LANES;
		constant hi_idx		: integer := (lane_sel + 1) * LANE_SHIFT_LEN - lane_byte * 8 - 1;
		constant lo_idx		: integer := hi_idx - 7;
	begin
		data_word_0(byte*8+7 downto byte*8) <=  data_shift(hi_idx downto lo_idx);
	end generate;

	-- Register
		-- (note that most of these will be equivalent to some data_shift
		--  registers and should be optimized out)
	process (clk)
	begin
		if rising_edge(clk) then
			data_word_1 <= data_word_0;
		end if;
	end process;


	-- ECC validation
	-------------------

	ecc_I: mipi_ecc
		port map (
			hdr_b0	=> data_word_0( 7 downto  0),
			hdr_b1	=> data_word_0(15 downto  8),
			hdr_b2	=> data_word_0(23 downto 16),
			ecc		=> ecc_exp_0
		);

	ecc_rx_0 <= data_word_0(31 downto 24);

	process (clk)
	begin
		if rising_edge(clk) then
			ecc_valid_1 <= btsl(ecc_rx_0 = ecc_exp_0);
		end if;
	end process;


	-- Sync
	---------

	sync_detect <= btsl(sync_lane = (sync_lane'range => '1'));

	process (clk)
	begin
		if rising_edge(clk) then
			if sync_detect = '1' then
				sync_cnt  <= (sync_cnt'left downto 1 => '0') & '1';
				capture_1 <= '0';
			else
				sync_cnt  <= sync_cnt + 1;
				capture_1 <= btsl(sync_cnt = (sync_cnt'range => '1'));
			end if;
		end if;
	end process;


	-- Misc
	---------

	-- LP transition
		-- We have a control option to bypass the LP logic. If active,
		-- we simulate a LP being LOW and continuously 'falling'
	process (clk)
	begin
		if rising_edge(clk) then
			if ctrl_lpdet_byp = '1' then
				lp_r <= '0';
				lp_fall <= '1';
			else
				lp_r <= phy_lp;
				lp_fall <= not phy_lp and lp_r;
			end if;
		end if;
	end process;

	-- Payload length
	process (clk)
	begin
		if rising_edge(clk) then
			if capture_1 = '1' then
				if state_cur = HEADER then
					pl_len_1 <= ('1' & data_word_1(23 downto 8)) - 3;
				elsif pl_len_1(pl_len_1'left) = '1' then
					pl_len_1 <= pl_len_1 - 4;
				end if;
			end if;
		end if;
	end process;


	-- FSM
	--------

	-- State register
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state_cur <= HALTED;
			else
				state_cur <= state_nxt;
			end if;
		end if;
	end process;

	-- Next state & error
	process (state_cur, ctrl_active, lp_r, lp_fall, sync_detect,
	         capture_1, ecc_valid_1, data_word_1, pl_len_1)
	begin
		-- Default is to stay the same
		state_nxt <= state_cur;

		-- Default is no errors
		err_late_sync_c <= '0';
		err_bad_ecc_c   <= '0';
		err_early_lp_c  <= '0';

		-- Transitions
		case state_cur is
			when HALTED =>
				if ctrl_active = '1' then
					state_nxt <= IDLE;
				end if;

			when IDLE =>
				if ctrl_active = '0' then
					state_nxt <= HALTED;
				elsif lp_fall = '1' then
					state_nxt <= SOT;
				end if;

			when SOT =>
				-- FIXME Add timeout and error detection/reporting
				if sync_detect = '1' then
					state_nxt <= HEADER;
				end if;

			when HEADER =>
				if capture_1 = '1' then
					if ecc_valid_1 = '0' then
						state_nxt <= IDLE;
						err_bad_ecc_c <= '1';
					elsif data_word_1(7 downto 4) = x"0" then
						-- Short packet
						state_nxt <= IDLE;
					else
						-- Long packet
						state_nxt <= DATA;
					end if;
				end if;

			when DATA =>
				if capture_1 = '1' then
					if lp_r = '1' then
						state_nxt <= IDLE;
						err_early_lp_c <= '1';
					elsif pl_len_1(pl_len_1'left) = '0' then
						state_nxt <= IDLE;
					end if;
				end if;
		end case;
	end process;


	-- Output
	-----------

	-- Data
	process (clk)
	begin
		if rising_edge(clk) then
			pkt_data  <= data_word_1;
			pkt_hdr   <= btsl(state_cur = HEADER);
			pkt_last  <= btsl(state_nxt = IDLE);
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				pkt_valid <= '0';
			else
				pkt_valid <= capture_1 and btsl(
								((state_cur = HEADER) and (ecc_valid_1 = '1')) or
								(state_cur = DATA)
							);
			end if;
		end if;
	end process;

	-- Status
	process (clk)
	begin
		if rising_edge(clk) then
			stat_running  <= btsl(state_cur /= HALTED);
			err_late_sync <= err_late_sync_c;
			err_bad_ecc   <= err_bad_ecc_c;
			err_early_lp  <= err_early_lp_c;
		end if;
	end process;

end rtl;
