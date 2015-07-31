--
-- axilite2slb.vhd
--
-- AXI-lite slave converting access to SLB
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

library work;
use work.utils_pkg.all;


entity axilite2slb is
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
end axilite2slb;


architecture rtl of axilite2slb is

	-- FSM
	--------

	type fsm_state_t is (
		IDLE,
		WRITE_PREPARE,
		WRITE_STROBE,
		WRITE_RESPONSE,
		READ_PREPARE,
		READ_STROBE,
		READ_CAPTURE,
		READ_RESPONSE
	);

	signal state_cur : fsm_state_t;
	signal state_nxt : fsm_state_t;


	-- Signals
	------------

	-- Clock / Reset
	signal clk		: std_logic;
	signal rst		: std_logic;

begin

	-- FSM
	--------

	-- State register
	process (clk)
	begin
		if rising_edge(clk) then
			if rst = '1' then
				state_cur <= IDLE;
			else
				state_cur <= state_nxt;
			end if;
		end if;
	end process;

	-- Next state
	process (state_cur, saxi_awvalid, saxi_wvalid, saxi_arvalid, saxi_bready, saxi_rready)
	begin
		-- Default is to stay the same
		state_nxt <= state_cur;

		-- Transistions
		case state_cur is
			when IDLE =>
				if saxi_awvalid = '1' and saxi_wvalid = '1' then
					state_nxt <= WRITE_PREPARE;
				elsif saxi_arvalid = '1' then
					state_nxt <= READ_PREPARE;
				end if;

			when WRITE_PREPARE =>
				state_nxt <= WRITE_STROBE;

			when WRITE_STROBE =>
				state_nxt <= WRITE_RESPONSE;

			when WRITE_RESPONSE =>
				if saxi_bready = '1' then
					state_nxt <= IDLE;
				end if;

			when READ_PREPARE =>
				state_nxt <= READ_STROBE;

			when READ_STROBE =>
				state_nxt <= READ_CAPTURE;

			when READ_CAPTURE =>
				state_nxt <= READ_RESPONSE;

			when READ_RESPONSE =>
				if saxi_rready = '1' then
					state_nxt <= IDLE;
				end if;
		end case;
	end process;


	-- Registers and handshake
	----------------------------

	-- Address register
	process (clk)
	begin
		if rising_edge(clk) then
			if state_nxt = WRITE_PREPARE then
				slb_addr <= saxi_awaddr(ADDR_WIDTH+1 downto 2);
			elsif state_nxt = READ_PREPARE then
				slb_addr <= saxi_araddr(ADDR_WIDTH+1 downto 2);
			end if;
		end if;
	end process;

	-- Write data register
	process (clk)
	begin
		if rising_edge(clk) then
			if state_nxt = WRITE_PREPARE then
				slb_wdata <= saxi_wdata;
			end if;
		end if;
	end process;

	-- Strobes
	slb_wstb <= btsl(state_cur = WRITE_STROBE);
	slb_rstb <= btsl(state_cur = READ_STROBE);

	-- Read data register
	process (clk)
		variable data :  std_logic_vector(31 downto 0);
	begin
		if rising_edge(clk) then
			if state_cur = READ_CAPTURE then
				data := (others => '0');
				for i in 0 to READ_CHANS-1 loop
					data := data or slb_rdata(i);
				end loop;
				saxi_rdata <= data;
			end if;
		end if;
	end process;

	-- Handshake
	saxi_awready <= btsl(state_cur = WRITE_PREPARE);
	saxi_wready  <= btsl(state_cur = WRITE_PREPARE);

	saxi_bvalid  <= btsl(state_cur = WRITE_RESPONSE);
	saxi_bresp   <= "00";

	saxi_arready <= btsl(state_cur = READ_PREPARE);

	saxi_rvalid  <= btsl(state_cur = READ_RESPONSE);
	saxi_rresp   <= "00";


	-- Clock / Reset
	------------------

	clk <= saxi_aclk;
	rst <= not saxi_rst_n;

end rtl;
