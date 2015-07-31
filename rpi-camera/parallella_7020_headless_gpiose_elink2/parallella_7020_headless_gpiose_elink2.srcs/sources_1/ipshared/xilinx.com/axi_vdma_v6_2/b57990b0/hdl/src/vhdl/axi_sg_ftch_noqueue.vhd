-------------------------------------------------------------------------------
-- axi_sg_ftch_noqueue
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
-- Filename:          axi_sg_ftch_noqueue.vhd
-- Description: This entity is the no queue version
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
--  GAB     6/16/10    v4_03
-- ^^^^^^
--  - Initial Release
-- ~~~~~~
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_sg_pkg.all;

library lib_pkg_v1_0;
library lib_fifo_v1_0;
use lib_fifo_v1_0.sync_fifo_fg;
use lib_pkg_v1_0.lib_pkg.all;

-------------------------------------------------------------------------------
entity  axi_sg_ftch_noqueue is
    generic (
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64        := 32;
            -- Master AXI Memory Map Address Width

        C_M_AXIS_SG_TDATA_WIDTH     : integer range 32 to 32        := 32
            -- Master AXI Stream Data Width

    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        m_axi_sg_aclk               : in  std_logic                         ;                   --
        m_axi_sg_aresetn            : in  std_logic                         ;                   --
                                                                                                --
        -- Channel Control                                                                    --
        desc_flush                  : in  std_logic                         ;                   --
        ftch_active                 : in  std_logic                         ;                   --
        ftch_queue_empty            : out std_logic                         ;                   --
        ftch_queue_full             : out std_logic                         ;                   --
                                                                                                --
        writing_nxtdesc_in          : in  std_logic                         ;                   --
        writing_curdesc_out         : out std_logic                         ;                   --

        -- DataMover Command                                                                    --
        ftch_cmnd_wr                : in  std_logic                         ;                   --
        ftch_cmnd_data              : in  std_logic_vector                                      --
                                        ((C_M_AXI_SG_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);    --
                                                                                                --
        -- MM2S Stream In from DataMover                                                        --
        m_axis_mm2s_tdata           : in  std_logic_vector                                      --
                                        (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) ;                  --
        m_axis_mm2s_tlast           : in  std_logic                         ;                   --
        m_axis_mm2s_tvalid          : in  std_logic                         ;                   --
        m_axis_mm2s_tready          : out std_logic                         ;                   --
                                                                                                --
        -- Channel 1 AXI Fetch Stream Out                                                       --
        m_axis_ftch_tdata           : out std_logic_vector                                      --
                                            (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) ;              --
        m_axis_ftch_tvalid          : out std_logic                         ;                   --
        m_axis_ftch_tready          : in  std_logic                         ;                   --
        m_axis_ftch_tlast           : out std_logic                                             --
    );

end axi_sg_ftch_noqueue;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_sg_ftch_noqueue is
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
-- Channel 1 internal signals
signal curdesc_tdata            : std_logic_vector
                                    (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) := (others => '0');
signal curdesc_tvalid           : std_logic := '0';
signal ftch_tvalid              : std_logic := '0';
signal ftch_tdata               : std_logic_vector
                                    (C_M_AXIS_SG_TDATA_WIDTH-1 downto 0) := (others => '0');
signal ftch_tlast               : std_logic := '0';
signal ftch_tready              : std_logic := '0';

-- Misc Signals
signal writing_curdesc          : std_logic := '0';
signal writing_nxtdesc          : std_logic := '0';
signal msb_curdesc              : std_logic_vector(31 downto 0) := (others => '0');


signal writing_lsb              : std_logic := '0';
signal writing_msb              : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

---------------------------------------------------------------------------
-- Write current descriptor to FIFO or out channel port
---------------------------------------------------------------------------
WRITE_CURDESC_PROCESS : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk = '1')then
            if(m_axi_sg_aresetn = '0' )then
                curdesc_tdata       <= (others => '0');
                curdesc_tvalid      <= '0';
                writing_lsb         <= '0';
                writing_msb         <= '0';

            -- Write LSB Address on command write
            elsif(ftch_cmnd_wr = '1' and ftch_active = '1')then
                curdesc_tdata       <= ftch_cmnd_data(DATAMOVER_CMD_ADDRMSB_BOFST
                                                        + DATAMOVER_CMD_ADDRLSB_BIT
                                                        downto DATAMOVER_CMD_ADDRLSB_BIT);
                curdesc_tvalid      <= '1';
                writing_lsb         <= '1';
                writing_msb         <= '0';

            -- On ready write MSB address
            elsif(writing_lsb = '1' and ftch_tready = '1')then
                curdesc_tdata       <= msb_curdesc;
                curdesc_tvalid      <= '1';
                writing_lsb         <= '0';
                writing_msb         <= '1';

            -- On MSB write and ready then clear all
            elsif(writing_msb = '1' and ftch_tready = '1')then
                curdesc_tdata       <= (others => '0');
                curdesc_tvalid      <= '0';
                writing_lsb         <= '0';
                writing_msb         <= '0';

            end if;
        end if;
    end process WRITE_CURDESC_PROCESS;

---------------------------------------------------------------------------
-- TVALID MUX
-- MUX tvalid out channel port
---------------------------------------------------------------------------
TVALID_TDATA_MUX : process(writing_curdesc,
                                writing_nxtdesc,
                                ftch_active,
                                curdesc_tvalid,
                                curdesc_tdata,
                                m_axis_mm2s_tvalid,
                                m_axis_mm2s_tdata,
                                m_axis_mm2s_tlast)
    begin
        -- Select current descriptor to drive out (Queue or Channel Port)
        if(writing_curdesc = '1')then
            ftch_tvalid  <= curdesc_tvalid;
            ftch_tdata   <= curdesc_tdata;
            ftch_tlast   <= '0';
        -- Deassert tvalid when capturing next descriptor pointer
        elsif(writing_nxtdesc = '1')then
            ftch_tvalid  <= '0';
            ftch_tdata   <= (others => '0');
            ftch_tlast   <= '0';
        -- Otherwise drive data from Datamover out (Queue or Channel Port)
        elsif(ftch_active = '1')then
            ftch_tvalid  <= m_axis_mm2s_tvalid;
            ftch_tdata   <= m_axis_mm2s_tdata;
            ftch_tlast   <= m_axis_mm2s_tlast;
        else
            ftch_tvalid  <= '0';
            ftch_tdata   <= (others => '0');
            ftch_tlast   <= '0';
        end if;
    end process TVALID_TDATA_MUX;

---------------------------------------------------------------------------
-- Map internal stream to external
---------------------------------------------------------------------------
m_axis_ftch_tdata       <= ftch_tdata;
m_axis_ftch_tlast       <= ftch_tlast;
m_axis_ftch_tvalid      <= ftch_tvalid;
ftch_tready             <= m_axis_ftch_tready;


m_axis_mm2s_tready      <= ftch_tready;

---------------------------------------------------------------------------
-- generate psuedo empty flag for Idle generation
---------------------------------------------------------------------------
Q_EMPTY_PROCESS : process(m_axi_sg_aclk)
    begin
        if(m_axi_sg_aclk'EVENT and m_axi_sg_aclk='1')then
            if(m_axi_sg_aresetn = '0' or desc_flush = '1')then
                ftch_queue_empty <= '1';

            -- Else on valid and ready modify empty flag
            elsif(ftch_tvalid = '1' and m_axis_ftch_tready = '1')then
                -- On last mark as empty
                if(ftch_tlast = '1' )then
                    ftch_queue_empty <= '1';
                -- Otherwise mark as not empty
                else
                    ftch_queue_empty <= '0';
                end if;
            end if;
        end if;
    end process Q_EMPTY_PROCESS;

-- do not need to indicate full to axi_sg_ftch_sm.  Only
-- needed for queue case to allow other channel to be serviced
-- if it had queue room
ftch_queue_full <= '0';

-- If writing curdesc out then flag for proper mux selection
writing_curdesc     <= curdesc_tvalid;
-- Map intnal signal to port
writing_curdesc_out <= writing_curdesc;
-- Map port to internal signal
writing_nxtdesc     <= writing_nxtdesc_in;


end implementation;
