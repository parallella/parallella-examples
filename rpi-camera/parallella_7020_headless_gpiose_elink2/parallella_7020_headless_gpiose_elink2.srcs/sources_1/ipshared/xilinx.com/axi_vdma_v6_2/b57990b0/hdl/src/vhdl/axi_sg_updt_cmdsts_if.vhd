-------------------------------------------------------------------------------
-- axi_sg_updt_cmdsts_if
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
-- Filename:    axi_sg_updt_cmdsts_if.vhd
-- Description: This entity is the descriptor update command and status inteface
--              for the Scatter Gather Engine AXI DataMover.
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
--                   |- axi_datamover_v5_0.axi_datamover.vhd
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
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_sg_pkg.all;

-------------------------------------------------------------------------------
entity  axi_sg_updt_cmdsts_if is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64        := 32
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                   --
        m_axi_sg_aresetn            : in  std_logic                         ;                   --
                                                                                                --
        -- Update command write interface from fetch sm                                         --
        updt_cmnd_wr                : in  std_logic                         ;                   --
        updt_cmnd_data              : in  std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
                                                                                                --
        -- User Command Interface Ports (AXI Stream)                                            --
        s_axis_updt_cmd_tvalid      : out std_logic                         ;                   --
        s_axis_updt_cmd_tready      : in  std_logic                         ;                   --
        s_axis_updt_cmd_tdata       : out std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
                                                                                                --
        -- User Status Interface Ports (AXI Stream)                                             --
        m_axis_updt_sts_tvalid      : in  std_logic                         ;                   --
        m_axis_updt_sts_tready      : out std_logic                         ;                   --
        m_axis_updt_sts_tdata       : in  std_logic_vector(7 downto 0)      ;                   --
        m_axis_updt_sts_tkeep       : in  std_logic_vector(0 downto 0)      ;                   --
                                                                                                --
        -- Scatter Gather Fetch Status                                                          --
        s2mm_err                    : in  std_logic                         ;                   --
        updt_done                   : out std_logic                         ;                   --
        updt_error                  : out std_logic                         ;                   --
        updt_interr                 : out std_logic                         ;                   --
        updt_slverr                 : out std_logic                         ;                   --
        updt_decerr                 : out std_logic                                             --
    );

end axi_sg_updt_cmdsts_if;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_updt_cmdsts_if is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

-- No Constants Declared

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal updt_slverr_i    : std_logic := '0';
signal updt_decerr_i    : std_logic := '0';
signal updt_interr_i    : std_logic := '0';
signal s2mm_error       : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

updt_slverr <= updt_slverr_i;
updt_decerr <= updt_decerr_i;
updt_interr <= updt_interr_i;


-------------------------------------------------------------------------------
-- DataMover Command Interface
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- When command by fetch sm, drive descriptor update command to data mover.
-- Hold until data mover indicates ready.
-------------------------------------------------------------------------------
GEN_DATAMOVER_CMND : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                s_axis_updt_cmd_tvalid  <= '0';
                s_axis_updt_cmd_tdata   <= (others => '0');

            elsif(updt_cmnd_wr = '1')then
                s_axis_updt_cmd_tvalid  <= '1';
                s_axis_updt_cmd_tdata   <= updt_cmnd_data;

            elsif(s_axis_updt_cmd_tready = '1')then
                s_axis_updt_cmd_tvalid  <= '0';
                s_axis_updt_cmd_tdata   <= (others => '0');

            end if;
        end if;
    end process GEN_DATAMOVER_CMND;

-------------------------------------------------------------------------------
-- DataMover Status Interface
-------------------------------------------------------------------------------
-- Drive ready low during reset to indicate not ready
REG_STS_READY : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                m_axis_updt_sts_tready <= '0';
            else
                m_axis_updt_sts_tready <= '1';
            end if;
        end if;
    end process REG_STS_READY;

-------------------------------------------------------------------------------
-- Log status bits out of data mover.
-------------------------------------------------------------------------------
DATAMOVER_STS : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                updt_slverr_i  <= '0';
                updt_decerr_i  <= '0';
                updt_interr_i  <= '0';
            -- Status valid, therefore capture status
            elsif(m_axis_updt_sts_tvalid = '1')then
                updt_slverr_i  <= m_axis_updt_sts_tdata(DATAMOVER_STS_SLVERR_BIT);
                updt_decerr_i  <= m_axis_updt_sts_tdata(DATAMOVER_STS_DECERR_BIT);
                updt_interr_i  <= m_axis_updt_sts_tdata(DATAMOVER_STS_INTERR_BIT);
            -- Only assert when valid
            else
                updt_slverr_i  <= '0';
                updt_decerr_i  <= '0';
                updt_interr_i  <= '0';
            end if;
        end if;
    end process DATAMOVER_STS;


-------------------------------------------------------------------------------
-- Transfer Done
-------------------------------------------------------------------------------
XFER_DONE : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                updt_done      <= '0';
            -- Status valid, therefore capture status
            elsif(m_axis_updt_sts_tvalid = '1')then
                updt_done      <= m_axis_updt_sts_tdata(DATAMOVER_STS_CMDDONE_BIT)
                                  or  m_axis_updt_sts_tdata(DATAMOVER_STS_SLVERR_BIT)
                                  or  m_axis_updt_sts_tdata(DATAMOVER_STS_DECERR_BIT)
                                  or  m_axis_updt_sts_tdata(DATAMOVER_STS_INTERR_BIT);
            -- Only assert when valid
            else
                updt_done      <= '0';
            end if;
        end if;
    end process XFER_DONE;

-------------------------------------------------------------------------------
-- Register global error from data mover.
-------------------------------------------------------------------------------
s2mm_error <= updt_slverr_i or updt_decerr_i or updt_interr_i;

-- Log errors into a global error output
UPDATE_ERROR_PROCESS : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0')then
                updt_error <= '0';
            elsif(s2mm_error = '1')then
                updt_error <= '1';
            end if;
        end if;
    end process UPDATE_ERROR_PROCESS;

end implementation;
