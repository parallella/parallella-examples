--
-- mipi_ecc.vhd
--
-- MIPI - ECC function (combinatorial)
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


entity mipi_ecc is
	port (
		hdr_b0	: in  std_logic_vector(7 downto 0);
		hdr_b1	: in  std_logic_vector(7 downto 0);
		hdr_b2	: in  std_logic_vector(7 downto 0);
		ecc		: out std_logic_vector(7 downto 0)
	);
end mipi_ecc;


architecture rtl of mipi_ecc is
begin

	ecc(7) <= '0';
	ecc(6) <= '0';
	ecc(5) <= hdr_b1(2) xor hdr_b1(3) xor hdr_b1(4) xor hdr_b1(5) xor hdr_b1(6) xor hdr_b1(7) xor hdr_b2(0) xor hdr_b2(1) xor hdr_b2(2) xor hdr_b2(3) xor hdr_b2(5) xor hdr_b2(6) xor hdr_b2(7);
	ecc(4) <= hdr_b0(4) xor hdr_b0(5) xor hdr_b0(6) xor hdr_b0(7) xor hdr_b1(0) xor hdr_b1(1) xor hdr_b2(0) xor hdr_b2(1) xor hdr_b2(2) xor hdr_b2(3) xor hdr_b2(4) xor hdr_b2(6) xor hdr_b2(7);
	ecc(3) <= hdr_b0(1) xor hdr_b0(2) xor hdr_b0(3) xor hdr_b0(7) xor hdr_b1(0) xor hdr_b1(1) xor hdr_b1(5) xor hdr_b1(6) xor hdr_b1(7) xor hdr_b2(3) xor hdr_b2(4) xor hdr_b2(5) xor hdr_b2(7);
	ecc(2) <= hdr_b0(0) xor hdr_b0(2) xor hdr_b0(3) xor hdr_b0(5) xor hdr_b0(6) xor hdr_b1(1) xor hdr_b1(3) xor hdr_b1(4) xor hdr_b1(7) xor hdr_b2(2) xor hdr_b2(4) xor hdr_b2(5) xor hdr_b2(6);
	ecc(1) <= hdr_b0(0) xor hdr_b0(1) xor hdr_b0(3) xor hdr_b0(4) xor hdr_b0(6) xor hdr_b1(0) xor hdr_b1(2) xor hdr_b1(4) xor hdr_b1(6) xor hdr_b2(1) xor hdr_b2(4) xor hdr_b2(5) xor hdr_b2(6) xor hdr_b2(7);
	ecc(0) <= hdr_b0(0) xor hdr_b0(1) xor hdr_b0(2) xor hdr_b0(4) xor hdr_b0(5) xor hdr_b0(7) xor hdr_b1(2) xor hdr_b1(3) xor hdr_b1(5) xor hdr_b2(0) xor hdr_b2(4) xor hdr_b2(5) xor hdr_b2(6) xor hdr_b2(7);

end rtl;
