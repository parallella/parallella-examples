--
-- mipi_csi_pkt_parse.vhd
--
-- Parse CSI packets into a video stream
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


entity mipi_csi_pkt_parse is
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
		clk			: in  std_logic;
		rst			: in  std_logic
	);
end mipi_csi_pkt_parse;


architecture rtl of mipi_csi_pkt_parse is

	-- FSM
	--------

	type fsm_state_t is (
		HALTED,
		WAIT_SOF,
		LINE_HEADER,
		LINE_DATA,
		LINE_FOOTER
	);

	signal state_cur : fsm_state_t;
	signal state_nxt : fsm_state_t;


	-- Signals
	------------

	-- Misc
	signal xfer				: std_logic;
	signal pause			: std_logic;
	signal pkt_ready_i		: std_logic;

	signal cnt				: std_logic_vector(16 downto 0);
	signal has_footer		: std_logic;

	-- Error
	signal err_pending		: std_logic;
	signal err_any_c		: std_logic;

	signal err_no_hdr_c		: std_logic;
	signal err_early_sof_c	: std_logic;
	signal err_unk_pkt_c	: std_logic;
	signal err_early_last_c	: std_logic;
	signal err_late_last_c	: std_logic;

begin


	-- FSM
	-------

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

	-- Next state and error set signals
	process (state_cur, ctrl_active, ctrl_hlt_on_err,
		err_pending, err_any_c, xfer, has_footer, cnt,
		pkt_data, pkt_hdr, pkt_last, pkt_valid, pkt_ready_i)
	begin
		-- Default is to stay the same
		state_nxt <= state_cur;

		-- No error set
		err_no_hdr_c     <= '0';
		err_early_sof_c  <= '0';
		err_unk_pkt_c    <= '0';
		err_early_last_c <= '0';
		err_late_last_c  <= '0';

		-- Transitions
		case state_cur is
			when HALTED =>
				-- If we're active and no error is pending,
				-- go wait for Start Of Frame
				if ctrl_active = '1' and err_pending = '0' then
					state_nxt <= WAIT_SOF;
				end if;
				
			when WAIT_SOF =>
				if ctrl_active = '0' then
					-- Should we stop ?
					state_nxt <= HALTED;
				elsif pkt_valid = '1' and pkt_hdr = '1' and pkt_data(7 downto 0) = x"0" then
					-- Valid packet header that's a SoF
					state_nxt <= LINE_HEADER;
				end if;

			when LINE_HEADER =>
				-- Wait for valid data
				if pkt_valid = '1' then
					-- Must be a header
					if pkt_hdr = '1' then
						-- Act depending on the packer type
						case pkt_data(7 downto 0) is
							when x"00" =>	-- Start Of Frame
								-- Weird to get one here
								err_early_sof_c <= '1';
								state_nxt <= LINE_HEADER;

							when x"01" =>	-- End Of Frame
								-- Done !
								state_nxt <= WAIT_SOF;

							when x"02" =>	-- Line Start
								-- Ignore
								state_nxt <= LINE_HEADER;

							when x"03" =>	-- Line End
								-- Ignore
								state_nxt <= LINE_HEADER;

							when x"2A" =>	-- RAW8
								state_nxt <= LINE_DATA;

							when x"2B" =>	-- RAW10
								state_nxt <= LINE_DATA;

							when others =>	-- Unknown
								err_unk_pkt_c <= '1';
								state_nxt <= LINE_HEADER;
						end case;
					else
						-- Not a header ? Something's wrong !
						err_no_hdr_c <= '1';
						state_nxt <= LINE_HEADER;
					end if;
				end if;

			when LINE_DATA =>
				-- Wait for actual data transfer
				if xfer = '1' then
					if pkt_last = '1' then
						if has_footer = '1' or cnt(cnt'left) = '1' then
							-- Packet is over before we expected it
							err_early_last_c <= '1';
							state_nxt <= LINE_HEADER;
						else
							-- Got everything, wait for next line
							state_nxt <= LINE_HEADER;
						end if;
					elsif cnt(cnt'left) = '0' then
						if has_footer = '0' then
							-- Packet should be over but isn't !
							err_late_last_c <= '1';
							state_nxt <= LINE_FOOTER;
						else
							-- Got all the data, drop CRC
							state_nxt <= LINE_FOOTER;
						end if;
					end if;
				end if;

			when LINE_FOOTER =>
				-- Drop the CRC
				if pkt_valid = '1' then
					if pkt_last = '1' then
						-- CRC done, read next line
						state_nxt <= LINE_HEADER;
					else
						-- Err, this should be the end !
						err_late_last_c <= '1';
						state_nxt <= LINE_FOOTER;
					end if;
				end if;

		end case;

		-- Special case, abort to HALTED on errors
		if ctrl_hlt_on_err = '1' and err_any_c = '1' then
			state_nxt <= HALTED;
		end if;
	end process;


	-- Control
	------------

	-- Active xfer
	xfer <= pkt_valid and pkt_ready_i;

	-- Pause
	-- (because this drives the outbound ready signal, we can only rise it
	--  after a transfer)
	process (clk)
	begin
		if rising_edge(clk) then
			if state_cur = LINE_DATA then
				if ctrl_pause = '0' then
					pause <= '0';
				elsif pkt_valid = '0' or vid_ready = '1' then
					pause <= ctrl_pause;
				end if;
			else
				pause <= ctrl_pause;
			end if;
		end if;
	end process;

	-- Packet length counter
	process (clk)
	begin
		if rising_edge(clk) then
			if xfer = '1' then
				if state_cur = LINE_HEADER then
					cnt <= ('1' &  pkt_data(23 downto 8)) - 5;
				else
					cnt <= cnt - 4;
				end if;
			end if;
		end if;
	end process;

	process (clk)
	begin
		if rising_edge(clk) then
			if xfer = '1' and state_cur = LINE_HEADER then
				has_footer <= not (pkt_data(9) xor pkt_data(8));
			end if;
		end if;
	end process;

	-- Upstream ready signal
	pkt_ready <= pkt_ready_i;

	with state_cur select pkt_ready_i <=
		ctrl_purge				when HALTED,
		'1'						when WAIT_SOF,
		'1'						when LINE_HEADER,
		vid_ready and not pause	when LINE_DATA,
		'1' 					when LINE_FOOTER,
		'0' 					when others;

	-- Error latching
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				err_pending <= '0';
			else
				err_pending <= ctrl_hlt_on_err and ctrl_active and (err_pending or err_any_c);
			end if;
		end if;
	end process;

	err_any_c <=
		err_no_hdr_c or
		err_early_sof_c or
		err_unk_pkt_c or
		err_early_last_c or
		err_late_last_c;


	-- Output
	-----------

	-- Data directy from input
	vid_data <= pkt_data;

	-- Last from counter (or from input when packet is short)
	vid_last <= pkt_last or not cnt(cnt'left);

	-- SoF
	process (clk)
	begin
		if rising_edge(clk) then
			if (state_cur = WAIT_SOF) and (state_nxt = LINE_HEADER) then
				vid_sof <= '1';
			elsif (state_cur = LINE_DATA) and (xfer = '1') then
				vid_sof <= '0';
			end if;
		end if;
	end process;

	-- Valid when processing line data and input is valid
	vid_valid <= pkt_valid and btsl(state_cur = LINE_DATA) and not pause;

	-- Status
	process (clk)
	begin
		if rising_edge(clk) then
			stat_running <= btsl(state_cur /= HALTED);
		end if;
	end process;

	stat_err_pending <= err_pending;

	-- Error registering
	process (clk)
	begin
		if rising_edge(clk) then
			err_no_hdr		<= err_no_hdr_c;
			err_early_sof	<= err_early_sof_c;
			err_unk_pkt		<= err_unk_pkt_c;
			err_early_last	<= err_early_last_c;
			err_late_last	<= err_late_last_c;
		end if;
	end process;

end rtl;
