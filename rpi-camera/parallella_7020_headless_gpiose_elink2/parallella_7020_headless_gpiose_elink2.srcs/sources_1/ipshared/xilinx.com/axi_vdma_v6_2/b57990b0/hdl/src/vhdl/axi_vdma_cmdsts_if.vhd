-------------------------------------------------------------------------------
-- axi_vdma_cmdsts_if
-------------------------------------------------------------------------------
--
-- *************************************************************************
--
--  (c) Copyright 2010-2011, 2013 Xilinx, Inc. All rights reserved.
--
--  This file contains confidential and proprietary information
--  of Xilinx, Inc. and is protected under U.S. and
--  international copyright and other intellectual property
--  laws.
--
--  DISCLAIMER
--  This disclaimer is not a license and does not grant any
--  rights to the materials distributed herewith. Except as
--  otherwise provided in a valid license issued to you by
--  Xilinx, and to the maximum extent permitted by applicable
--  law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
--  WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
--  AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
--  BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
--  INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
--  (2) Xilinx shall not be liable (whether in contract or tort,
--  including negligence, or under any other theory of
--  liability) for any loss or damage of any kind or nature
--  related to, arising under or in connection with these
--  materials, including for any direct, or any indirect,
--  special, incidental, or consequential loss or damage
--  (including loss of data, profits, goodwill, or any type of
--  loss or damage suffered as a result of any action brought
--  by a third party) even if such damage or loss was
--  reasonably foreseeable or Xilinx had been advised of the
--  possibility of the same.
--
--  CRITICAL APPLICATIONS
--  Xilinx products are not designed or intended to be fail-
--  safe, or for use in any application requiring fail-safe
--  performance, such as life-support or safety devices or
--  systems, Class III medical devices, nuclear facilities,
--  applications related to the deployment of airbags, or any
--  other applications that could lead to death, personal
--  injury, or severe property or environmental damage
--  (individually and collectively, "Critical
--  Applications"). Customer assumes the sole risk and
--  liability of any use of Xilinx products in Critical
--  Applications, subject only to applicable laws and
--  regulations governing limitations on product liability.
--
--  THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
--  PART OF THIS FILE AT ALL TIMES. 
--
-- *************************************************************************
--
-------------------------------------------------------------------------------
-- Filename:    axi_vdma_cmdsts_if.vhd
-- Description: This entity is the descriptor fetch command and status inteface
--              for the Scatter Gather Engine AXI DataMover.
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
--                  axi_vdma.vhd
--                   |- axi_vdma_pkg.vhd
--                   |- axi_vdma_intrpt.vhd
--                   |- axi_vdma_rst_module.vhd
--                   |   |- axi_vdma_reset.vhd (mm2s)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |   |- axi_vdma_reset.vhd (s2mm)
--                   |   |   |- axi_vdma_cdc.vhd
--                   |
--                   |- axi_vdma_reg_if.vhd
--                   |   |- axi_vdma_lite_if.vhd
--                   |   |- axi_vdma_cdc.vhd (mm2s)
--                   |   |- axi_vdma_cdc.vhd (s2mm)
--                   |
--                   |- axi_vdma_sg_cdc.vhd (mm2s)
--                   |- axi_vdma_vid_cdc.vhd (mm2s)
--                   |- axi_vdma_fsync_gen.vhd (mm2s)
--                   |- axi_vdma_sof_gen.vhd (mm2s)
--                   |- axi_vdma_reg_module.vhd (mm2s)
--                   |   |- axi_vdma_register.vhd (mm2s)
--                   |   |- axi_vdma_regdirect.vhd (mm2s)
--                   |- axi_vdma_mngr.vhd (mm2s)
--                   |   |- axi_vdma_sg_if.vhd (mm2s)
--                   |   |- axi_vdma_sm.vhd (mm2s)
--                   |   |- axi_vdma_cmdsts_if.vhd (mm2s)
--                   |   |- axi_vdma_vidreg_module.vhd (mm2s)
--                   |   |   |- axi_vdma_sgregister.vhd (mm2s)
--                   |   |   |- axi_vdma_vregister.vhd (mm2s)
--                   |   |   |- axi_vdma_vaddrreg_mux.vhd (mm2s)
--                   |   |   |- axi_vdma_blkmem.vhd (mm2s)
--                   |   |- axi_vdma_genlock_mngr.vhd (mm2s)
--                   |       |- axi_vdma_genlock_mux.vhd (mm2s)
--                   |       |- axi_vdma_greycoder.vhd (mm2s)
--                   |- axi_vdma_mm2s_linebuf.vhd (mm2s)
--                   |   |- axi_vdma_sfifo_autord.vhd (mm2s)
--                   |   |- axi_vdma_afifo_autord.vhd (mm2s)
--                   |   |- axi_vdma_skid_buf.vhd (mm2s)
--                   |   |- axi_vdma_cdc.vhd (mm2s)
--                   |
--                   |- axi_vdma_sg_cdc.vhd (s2mm)
--                   |- axi_vdma_vid_cdc.vhd (s2mm)
--                   |- axi_vdma_fsync_gen.vhd (s2mm)
--                   |- axi_vdma_sof_gen.vhd (s2mm)
--                   |- axi_vdma_reg_module.vhd (s2mm)
--                   |   |- axi_vdma_register.vhd (s2mm)
--                   |   |- axi_vdma_regdirect.vhd (s2mm)
--                   |- axi_vdma_mngr.vhd (s2mm)
--                   |   |- axi_vdma_sg_if.vhd (s2mm)
--                   |   |- axi_vdma_sm.vhd (s2mm)
--                   |   |- axi_vdma_cmdsts_if.vhd (s2mm)
--                   |   |- axi_vdma_vidreg_module.vhd (s2mm)
--                   |   |   |- axi_vdma_sgregister.vhd (s2mm)
--                   |   |   |- axi_vdma_vregister.vhd (s2mm)
--                   |   |   |- axi_vdma_vaddrreg_mux.vhd (s2mm)
--                   |   |   |- axi_vdma_blkmem.vhd (s2mm)
--                   |   |- axi_vdma_genlock_mngr.vhd (s2mm)
--                   |       |- axi_vdma_genlock_mux.vhd (s2mm)
--                   |       |- axi_vdma_greycoder.vhd (s2mm)
--                   |- axi_vdma_s2mm_linebuf.vhd (s2mm)
--                   |   |- axi_vdma_sfifo_autord.vhd (s2mm)
--                   |   |- axi_vdma_afifo_autord.vhd (s2mm)
--                   |   |- axi_vdma_skid_buf.vhd (s2mm)
--                   |   |- axi_vdma_cdc.vhd (s2mm)
--                   |
--                   |- axi_datamover_v3_00_a.axi_datamover.vhd (FULL)
--                   |- axi_sg_v3_00_a.axi_sg.vhd
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

-------------------------------------------------------------------------------
entity  axi_vdma_cmdsts_if is
    generic (
        C_M_AXI_ADDR_WIDTH       	: integer range 32 to 64       := 32;
            -- Master AXI Memory Map Address Width for Scatter Gather R/W Port

        C_DM_STATUS_WIDTH               : integer               := 8;
            -- CR608521
            -- DataMover status width - is based on mode of operation

        C_INCLUDE_MM2S                  : integer range 0 to 1      := 1;


        C_INCLUDE_S2MM                  : integer range 0 to 1      := 1;
        --C_ENABLE_DEBUG_INFO             : string := "1111111111111111";		-- 1 to 16 -- 
        --C_ENABLE_DEBUG_INFO             : bit_vector(15 downto 0) 	:= (others => '1');		--15 downto 0  -- 
        C_ENABLE_DEBUG_ALL       : integer range 0 to 1      	:= 1;
            -- Setting this make core backward compatible to 2012.4 version in terms of ports and registers

        C_ENABLE_DEBUG_INFO_0       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 0
        C_ENABLE_DEBUG_INFO_1       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 1
        C_ENABLE_DEBUG_INFO_2       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 2
        C_ENABLE_DEBUG_INFO_3       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 3
        C_ENABLE_DEBUG_INFO_4       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 4
        C_ENABLE_DEBUG_INFO_5       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 5
        C_ENABLE_DEBUG_INFO_6       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 6
        C_ENABLE_DEBUG_INFO_7       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 7
        C_ENABLE_DEBUG_INFO_8       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 8
        C_ENABLE_DEBUG_INFO_9       : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 9
        C_ENABLE_DEBUG_INFO_10      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 10
        C_ENABLE_DEBUG_INFO_11      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 11
        C_ENABLE_DEBUG_INFO_12      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 12
        C_ENABLE_DEBUG_INFO_13      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 13
        C_ENABLE_DEBUG_INFO_14      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 14
        C_ENABLE_DEBUG_INFO_15      : integer range 0 to 1      	:= 1;
            -- Enable debug information bit 15

        C_ENABLE_FLUSH_ON_FSYNC     	: integer range 0 to 1      := 0                            -- CR591965
            -- Specifies VDMA Flush on Frame sync enabled
            -- 0 = Disabled
            -- 1 = Enabled

    );
    port (
        -----------------------------------------------------------------------
        -- AXI Scatter Gather Interface
        -----------------------------------------------------------------------
        prmry_aclk              : in  std_logic                             ;                   --
        prmry_resetn            : in  std_logic                             ;                   --
                                                                                                --
        -- Command write interface from mm2s sm                                                 --
        cmnd_wr                 : in  std_logic                             ;                   --
        cmnd_data               : in  std_logic_vector                                          --
                                    ((C_M_AXI_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);           --
        cmnd_pending            : out std_logic                             ;                   --
        sts_received            : out std_logic                             ;                   --
        halt                    : in  std_logic                             ;                   -- CR613214
        stop                    : in  std_logic                             ;                   --
        crnt_hsize              : in  std_logic_vector                                          --
                                    (HSIZE_DWIDTH-1 downto 0)               ;                   --
        dmasr_halt              : in  std_logic                             ;                   --
                                                                                                --
        -- User Command Interface Ports (AXI Stream)                                            --
        s_axis_cmd_tvalid       : out std_logic                             ;                   --
        s_axis_cmd_tready       : in  std_logic                             ;                   --
        s_axis_cmd_tdata        : out std_logic_vector                                          --
                                    ((C_M_AXI_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);           --
                                                                                                --
        -- User Status Interface Ports (AXI Stream)                                             --
        m_axis_sts_tvalid       : in  std_logic                             ;                   --
        m_axis_sts_tready       : out std_logic                             ;                   --
        m_axis_sts_tdata        : in  std_logic_vector                                          --
                                    (C_DM_STATUS_WIDTH-1 downto 0)          ;                   -- CR608521
        m_axis_sts_tkeep        : in  std_logic_vector                                          --
                                    ((C_DM_STATUS_WIDTH/8)-1  downto 0)     ;                   -- CR608521

    s2mm_fsize_more_or_sof_late : in  std_logic                         ;       --
      s2mm_dmasr_lsize_less_err : in  std_logic                         ;       --
                                                                                                --
        -- Zero Hsize and/or Vsize. mapped here to combine with interr                          --
        zero_size_err           : in  std_logic                             ;                   -- CR579593/CR579597
        -- Frame Mismatch. mapped here to combine with interr                                   --
        fsize_mismatch_err      : in  std_logic                             ;                   -- CR591965
        lsize_mismatch_err      : out std_logic                             ;                   -- CR591965
        lsize_more_mismatch_err : out std_logic                             ;                   -- CR591965
       
        capture_hsize_at_uf_err :  out std_logic_vector(15 downto 0) ;
                                                                                         --
        -- Datamover status                                                                     --
        err                     : in  std_logic                             ;                   --
        done                    : out std_logic                             ;                   --
        err_o                   : out std_logic                             ;                   --
        interr_minus_frame_errors                  : out std_logic                             ;                   --
        interr                  : out std_logic                             ;                   --
        slverr                  : out std_logic                             ;                   --
        decerr                  : out std_logic                             ;                   --
        tag                     : out std_logic_vector(3 downto 0)                              --

    );

end axi_vdma_cmdsts_if;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_cmdsts_if is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------

-- Bytes received MSB index bit
constant BRCVD_MSB_BIT 			: integer := (C_DM_STATUS_WIDTH - 2);
-- Bytes received LSB index bit
constant BRCVD_LSB_BIT 			: integer := (C_DM_STATUS_WIDTH - 2) - (BUFFER_LENGTH_WIDTH - 1);

constant PAD_HSIZE     			: std_logic_vector(22 - HSIZE_DWIDTH downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal sts_tready           		: std_logic := '0';
signal slverr_i             		: std_logic := '0';
signal decerr_i             		: std_logic := '0';
signal interr_i             		: std_logic := '0';
signal err_i              		: std_logic := '0';
signal err_or             		: std_logic := '0';
signal uf_err             		: std_logic := '0';
signal of_err             		: std_logic := '0';
signal undrflo_err   			: std_logic := '0';
signal ovrflo_err   			: std_logic := '0';
signal ext_crnt_hsize       		: std_logic_vector(22 downto 0) := (others => '0');
signal s2mm_dmasr_lsize_less_err_d1     : std_logic := '0';
signal s2mm_dmasr_lsize_less_err_fe     : std_logic := '0';


-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

slverr <= slverr_i;
decerr <= decerr_i;

interr_minus_frame_errors <= interr_i or zero_size_err;

interr <= interr_i or zero_size_err
                   or fsize_mismatch_err
		   or s2mm_fsize_more_or_sof_late	;                       -- CR591965


-- Asserted with each valid status
sts_received <= m_axis_sts_tvalid and sts_tready;

-------------------------------------------------------------------------------
-- DataMover Command Interface
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
-- When command by fetch sm, drive descriptor fetch command to data mover.
-- Hold until data mover indicates ready.
-------------------------------------------------------------------------------
GEN_DATAMOVER_CMND : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or dmasr_halt = '1')then
                s_axis_cmd_tvalid  <= '0';
                s_axis_cmd_tdata   <= (others => '0');
                cmnd_pending       <= '0';
            -- New command write and not flagged as stale descriptor
            elsif(cmnd_wr = '1')then
                s_axis_cmd_tvalid  <= '1';
                s_axis_cmd_tdata   <= cmnd_data;
                cmnd_pending       <= '1';
            -- Clear flags when command excepted by datamover or halt issued to datamover and command is pending (CR 671208 ("white line-shift" issue))
            elsif(s_axis_cmd_tready = '1'or halt = '1')then
                s_axis_cmd_tvalid  <= '0';
                s_axis_cmd_tdata   <= (others => '0');
                cmnd_pending       <= '0';

            end if;
        end if;
    end process GEN_DATAMOVER_CMND;

-------------------------------------------------------------------------------
-- DataMover Status Interface
-------------------------------------------------------------------------------
-- Drive ready low during reset to indicate not ready
REG_STS_READY : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                sts_tready <= '0';
            else
                sts_tready <= '1';
            end if;
        end if;
    end process REG_STS_READY;

-- Pass to DataMover
m_axis_sts_tready <= sts_tready;

-------------------------------------------------------------------------------
-- Log status bits out of data mover.
-------------------------------------------------------------------------------
DATAMOVER_STS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                done       <= '0';
                slverr_i   <= '0';
                decerr_i   <= '0';
                interr_i   <= '0';
                tag        <= (others => '0');
            -- Status valid, therefore capture status
            elsif(m_axis_sts_tvalid = '1')then
                done       <= m_axis_sts_tdata(DATAMOVER_STS_CMDDONE_BIT);
                slverr_i   <= m_axis_sts_tdata(DATAMOVER_STS_SLVERR_BIT);
                decerr_i   <= m_axis_sts_tdata(DATAMOVER_STS_DECERR_BIT);
                interr_i   <= m_axis_sts_tdata(DATAMOVER_STS_INTERR_BIT);
                tag        <= m_axis_sts_tdata(DATAMOVER_STS_TAGMSB_BIT downto DATAMOVER_STS_TAGLSB_BIT);
            else
                done       <= '0';
                slverr_i   <= '0';
                decerr_i   <= '0';
                interr_i   <= '0';
                tag        <= (others => '0');
            end if;
        end if;
    end process DATAMOVER_STS;


-------------------------------------------------------------------------------
-- Line MisMatch Detection (Datamover underflow or overflow)
-------------------------------------------------------------------------------
-- Status is for MM2S or S2MM with Store and Forward turned OFF
-- therefore Datamover detects overflow and underflow
GEN_STS_EQL_TO_8 : if C_DM_STATUS_WIDTH = 8 generate
begin
    of_err            	<= '0';
    uf_err            	<= '0';
    undrflo_err  	<= '0';
    ovrflo_err  	<= '0';

    lsize_mismatch_err  	<= '0';
    lsize_more_mismatch_err  	<= '0';

    capture_hsize_at_uf_err   	<= (others => '0');


end generate GEN_STS_EQL_TO_8;

-- Status is for S2MM with Store and Forward turned OON (i.e. Indeterimate BTT mode)
-- therefore need to detect overflow and underflow here
GEN_STS_GRTR_THAN_8 : if C_DM_STATUS_WIDTH > 8 generate
begin

    -- Pad current hsize up to the full 23 bit BTT
    ext_crnt_hsize <= PAD_HSIZE & crnt_hsize;

    -- CR608521 - Under Flow or Over Flow error detected
    uf_err <= '1' when m_axis_sts_tvalid = '1'
                   and  (ext_crnt_hsize /= m_axis_sts_tdata(BRCVD_MSB_BIT      -- Underflow
                                                 downto BRCVD_LSB_BIT))
           else '0';

    of_err <= '1' when m_axis_sts_tvalid = '1'
                   and  (ext_crnt_hsize = m_axis_sts_tdata(BRCVD_MSB_BIT      
                                                 downto BRCVD_LSB_BIT))
                   and  (m_axis_sts_tdata(DATAMOVER_STS_TLAST_BIT) = '0')      -- Overflow
           else '0';



GEN_CAPTURE_HSIZE_AT_LSIZE_LESS_ERR : if (C_INCLUDE_S2MM = 1  and (C_ENABLE_DEBUG_INFO_12 = 1 or C_ENABLE_DEBUG_ALL = 1)) generate
begin



S2MM_DMASR_BIT8_D1 : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                s2mm_dmasr_lsize_less_err_d1 <= '0';
            else
                s2mm_dmasr_lsize_less_err_d1 <= s2mm_dmasr_lsize_less_err;
            end if;
        end if;
    end process S2MM_DMASR_BIT8_D1;


s2mm_dmasr_lsize_less_err_fe <= s2mm_dmasr_lsize_less_err_d1 and not s2mm_dmasr_lsize_less_err;


    REG_HSIZE_AT_LSIZE_LESS_ERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or s2mm_dmasr_lsize_less_err_fe = '1')then
			
			capture_hsize_at_uf_err   <= (others => '0');

		elsif (( m_axis_sts_tvalid = '1' and (ext_crnt_hsize /= m_axis_sts_tdata(BRCVD_MSB_BIT downto BRCVD_LSB_BIT))) and s2mm_dmasr_lsize_less_err = '0')then

			capture_hsize_at_uf_err   <= m_axis_sts_tdata(23 downto 8);

            	end if;
            end if;
        end process REG_HSIZE_AT_LSIZE_LESS_ERR;

end generate GEN_CAPTURE_HSIZE_AT_LSIZE_LESS_ERR;


GEN_NO_CAPTURE_HSIZE_AT_LSIZE_LESS_ERR : if (C_INCLUDE_S2MM = 0 or (C_ENABLE_DEBUG_INFO_12 = 0 and C_ENABLE_DEBUG_ALL = 0)) generate
begin

		capture_hsize_at_uf_err   <= (others => '0');

end generate GEN_NO_CAPTURE_HSIZE_AT_LSIZE_LESS_ERR;




    -- CR608521- Under Flow or Over Flow error detected
    -- Register and hold error
    -- CR613214 - need to qualify overflow with datamover halt

    REG_UF_ERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    undrflo_err <= '0';
                -- set on underflow or overflow
                -- CR609038 qualify with error already being set because on
                -- datamover shut down the byte count in the rcved status is
                -- invalid.
                -- CR613214 - need to qualify overflow with datamover halt
                elsif(uf_err = '1' and err_i = '0' and stop = '0' and halt = '0')then
                    undrflo_err <= '1';
                else                                            -- CR591965
                    undrflo_err <= '0';                  -- CR591965
                end if;
            end if;
        end process REG_UF_ERR;

    REG_OF_ERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    ovrflo_err <= '0';
                -- set on underflow or overflow
                -- CR609038 qualify with error already being set because on
                -- datamover shut down the byte count in the rcved status is
                -- invalid.
                -- CR613214 - need to qualify overflow with datamover halt
                elsif(of_err = '1' and err_i = '0' and stop = '0' and halt = '0')then
                    ovrflo_err <= '1';
                else                                            -- CR591965
                    ovrflo_err <= '0';                  -- CR591965
                end if;
            end if;
        end process REG_OF_ERR;





    -- CR591965
    -- pass underflow/overflow to line size mismatch for use
    -- in genlock repeat frame logic
    lsize_mismatch_err 		<= undrflo_err;
    lsize_more_mismatch_err 	<= ovrflo_err;

end generate GEN_STS_GRTR_THAN_8;

-------------------------------------------------------------------------------
-- Register global error from data mover.
-------------------------------------------------------------------------------
-- Flush On Frame Sync disabled therefore...
-- Halt channel on all errors.  Done by OR'ing all errors and using
-- to set err_i which is used in axi_vdma_mngr to assert stop.  Stop
-- will shut down channel. (CR591965)
GEN_ERR_FOR_NO_FLUSH : if C_ENABLE_FLUSH_ON_FSYNC = 0 generate
begin
    err_or <= slverr_i            -- From DataMover
             or decerr_i            -- From DataMover
             or interr_i            -- From DataMover
             or zero_size_err       -- From axi_vdma_sm
             or fsize_mismatch_err;  -- From axi_vdma_sm (CR591965)

end generate GEN_ERR_FOR_NO_FLUSH;

-- Flush On Frame Sync enabled therefore...
-- Halt channel on all errors except underflow and overflow (line size mismatch)
-- and frame size mismatch errors.  Shutdown is accomplished by OR'ing select errors
-- and using to set err_i which is used in axi_vdma_mngr to assert stop.  Stop
-- will shut down channel. (CR591965)
GEN_ERR_FOR_FLUSH : if C_ENABLE_FLUSH_ON_FSYNC = 1 generate
begin
    err_or <= slverr_i            -- From DataMover
             or decerr_i            -- From DataMover
             or interr_i            -- From DataMover
             or zero_size_err;      -- From axi_vdma_sm

end generate GEN_ERR_FOR_FLUSH;

-- Log errors into a global error output
ERR_PROCESS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                err_i <= '0';
            -- If Datamover issues error on the transfer or if a stale descriptor is
            -- detected when in tailpointer mode then issue an error
            elsif(err_or = '1')then
                err_i <= '1';
            end if;
        end if;
    end process ERR_PROCESS;
---- CR609038
err_o <= err_i;

end implementation;
