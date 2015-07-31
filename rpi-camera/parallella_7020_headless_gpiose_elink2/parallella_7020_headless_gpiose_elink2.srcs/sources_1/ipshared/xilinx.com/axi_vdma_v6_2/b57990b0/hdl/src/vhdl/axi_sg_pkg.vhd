-------------------------------------------------------------------------------
-- axi_sg_pkg
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
-- (c) Copyright 2010, 2011 Xilinx, Inc. All rights reserved.
--
-- This file contains confidential and proprietary information
-- of Xilinx, Inc. and is protected under U.S. and
-- international copyright and other intellectual property
-- laws.
--
-- DISCLAIMER
-- This disclaimer is not a license and does not grant any
-- rights to the materials distributed herewith. Except as
-- otherwise provided in a valid license issued to you by
-- Xilinx, and to the maximum extent permitted by applicable
-- law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
-- WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
-- AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
-- BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
-- INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
-- (2) Xilinx shall not be liable (whether in contract or tort,
-- including negligence, or under any other theory of
-- liability) for any loss or damage of any kind or nature
-- related to, arising under or in connection with these
-- materials, including for any direct, or any indirect,
-- special, incidental, or consequential loss or damage
-- (including loss of data, profits, goodwill, or any type of
-- loss or damage suffered as a result of any action brought
-- by a third party) even if such damage or loss was
-- reasonably foreseeable or Xilinx had been advised of the
-- possibility of the same.
--
-- CRITICAL APPLICATIONS
-- Xilinx products are not designed or intended to be fail-
-- safe, or for use in any application requiring fail-safe
-- performance, such as life-support or safety devices or
-- systems, Class III medical devices, nuclear facilities,
-- applications related to the deployment of airbags, or any
-- other applications that could lead to death, personal
-- injury, or severe property or environmental damage
-- (individually and collectively, "Critical
-- Applications"). Customer assumes the sole risk and
-- liability of any use of Xilinx products in Critical
-- Applications, subject only to applicable laws and
-- regulations governing limitations on product liability.
--
-- THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
-- PART OF THIS FILE AT ALL TIMES.
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:          axi_sg_pkg.vhd
-- Description: This package contains various constants and functions for
--              AXI SG Engine.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_sg.vhd
--                  axi_sg_pkg.vhd
--                   |- axi_sg_ftch_mngr.vhd
--                   |   |- axi_sg_ftch_sm.vhd
--                   |   |- axi_sg_ftch_pntr.vhd
--                   |   |- axi_sg_ftch_cmdsts_if.vhd
--                   |- axi_sg_updt_mngr.vhd
--                   |   |- axi_sg_updt_sm.vhd
--                   |   |- axi_sg_updt_cmdsts_if.vhd
--                   |- axi_sg_ftch_q_mngr.vhd
--                   |   |- axi_sg_ftch_queue.vhd
--                   |   |   |- proc_common_v4_0.sync_fifo_fg.vhd
--                   |   |   |- proc_common_v4_0.axi_sg_afifo_autord.vhd
--                   |   |- axi_sg_ftch_noqueue.vhd
--                   |- axi_sg_updt_q_mngr.vhd
--                   |   |- axi_sg_updt_queue.vhd
--                   |   |   |- proc_common_v4_0.sync_fifo_fg.vhd
--                   |   |- proc_common_v4_0.axi_sg_afifo_autord.vhd
--                   |   |- axi_sg_updt_noqueue.vhd
--                   |- axi_sg_intrpt.vhd
--                   |- axi_datamover_v4_03.axi_datamover.vhd
--
-------------------------------------------------------------------------------
-- Author:      Gary Burch
-- History:
--  GAB     3/19/10    v1_00_a
-- ^^^^^^
--  - Initial Release
-- ~~~~~~
--  GAB     8/26/10    v2_00_a
-- ^^^^^^
--  Rolled axi_sg library version to version v2_00_a
-- ~~~~~~
--  GAB     10/21/10    v4_03
-- ^^^^^^
--  Rolled version to v4_03
-- ~~~~~~
--  GAB     6/13/11    v4_03
-- ^^^^^^
-- Update to AXI Datamover v4_03
-- Added aynchronous operation
-- ~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package axi_sg_pkg is

-------------------------------------------------------------------------------
-- Function declarations
-------------------------------------------------------------------------------
-- Convert boolean to a std_logic
function bo2int (value : boolean)
            return  integer;

-------------------------------------------------------------------------------
-- Constant Declarations
-------------------------------------------------------------------------------

-- AXI Response Values
constant OKAY_RESP                      : std_logic_vector(1 downto 0)  := "00";
constant EXOKAY_RESP                    : std_logic_vector(1 downto 0)  := "01";
constant SLVERR_RESP                    : std_logic_vector(1 downto 0)  := "10";
constant DECERR_RESP                    : std_logic_vector(1 downto 0)  := "11";

-- Misc Constants
constant CMD_BASE_WIDTH                 : integer := 40;
constant SG_BTT_WIDTH                   : integer := 7;
constant SG_ADDR_LSB                    : integer := 6;

-- Interrupt Coalescing
constant ZERO_THRESHOLD             : std_logic_vector(7 downto 0) := (others => '0');
constant ONE_THRESHOLD              : std_logic_vector(7 downto 0) := "00000001";
constant ZERO_DELAY                 : std_logic_vector(7 downto 0) := (others => '0');

-- Constants Used in Desc Updates
constant DESC_STS_TYPE                  : std_logic := '1';
constant DESC_DATA_TYPE                 : std_logic := '0';

-- DataMover Command / Status Constants
constant DATAMOVER_STS_CMDDONE_BIT      : integer := 7;
constant DATAMOVER_STS_SLVERR_BIT       : integer := 6;
constant DATAMOVER_STS_DECERR_BIT       : integer := 5;
constant DATAMOVER_STS_INTERR_BIT       : integer := 4;
constant DATAMOVER_STS_TAGMSB_BIT       : integer := 3;
constant DATAMOVER_STS_TAGLSB_BIT       : integer := 0;

constant DATAMOVER_CMD_BTTLSB_BIT       : integer := 0;
constant DATAMOVER_CMD_BTTMSB_BIT       : integer := 22;
constant DATAMOVER_CMD_TYPE_BIT         : integer := 23;
constant DATAMOVER_CMD_DSALSB_BIT       : integer := 24;
constant DATAMOVER_CMD_DSAMSB_BIT       : integer := 29;
constant DATAMOVER_CMD_EOF_BIT          : integer := 30;
constant DATAMOVER_CMD_DRR_BIT          : integer := 31;
constant DATAMOVER_CMD_ADDRLSB_BIT      : integer := 32;

-- Note: Bit offset require adding ADDR WIDTH to get to actual bit index
constant DATAMOVER_CMD_ADDRMSB_BOFST    : integer := 31;
constant DATAMOVER_CMD_TAGLSB_BOFST     : integer := 32;
constant DATAMOVER_CMD_TAGMSB_BOFST     : integer := 35;
constant DATAMOVER_CMD_RSVLSB_BOFST     : integer := 36;
constant DATAMOVER_CMD_RSVMSB_BOFST     : integer := 39;

-- Descriptor field bits
constant DESC_STS_INTERR_BIT            : integer := 28;
constant DESC_STS_SLVERR_BIT            : integer := 29;
constant DESC_STS_DECERR_BIT            : integer := 30;
constant DESC_STS_CMPLTD_BIT            : integer := 31;

-- IOC Bit on descriptor update
-- Stored in LSB of TAG field then catinated on status word from primary
-- datamover (i.e. DESCTYPE & IOC & STATUS & Bytes Transferred).
constant DESC_IOC_TAG_BIT               : integer := 32;


end axi_sg_pkg;

-------------------------------------------------------------------------------
-- PACKAGE BODY
-------------------------------------------------------------------------------
package body axi_sg_pkg is
-------------------------------------------------------------------------------
-- Boolean to Integer
-------------------------------------------------------------------------------
function bo2int ( value : boolean)
    return integer  is
variable value_int : integer;
begin
    if(value)then
        value_int := 1;
    else
        value_int := 0;
    end if;
    return value_int;
end function bo2int;

end package body axi_sg_pkg;
