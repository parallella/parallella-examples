-------------------------------------------------------------------------------
-- axi_vdma_sm
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
-- Filename:          axi_vdma_sm.vhd
-- Description: This entity contains the DMA Controller State Machine and
--              manages primary data transfers.
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

library lib_cdc_v1_0;
library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
use lib_pkg_v1_0.lib_pkg.max2;


-------------------------------------------------------------------------------
entity  axi_vdma_sm is
    generic (
        C_INCLUDE_SF                : integer range 0 to 1      := 0;
            -- Include or exclude store and forward module
            -- 0 = excluded
            -- 1 = included

        C_USE_FSYNC                 : integer range 0 to 1      := 0;                       -- CR591965
            -- Specifies VDMA operation synchronized to frame sync input
            -- 0 = Free running
            -- 1 = Fsync synchronous

        C_ENABLE_FLUSH_ON_FSYNC     : integer range 0 to 1      := 0;                       -- CR591965
            -- Specifies VDMA Flush on Frame sync enabled
            -- 0 = Disabled
            -- 1 = Enabled

        C_M_AXI_ADDR_WIDTH          : integer range 32 to 64    := 32;
            -- Master AXI Memory Map Address Width for MM2S Read Port

        C_EXTEND_DM_COMMAND         : integer range 0 to 1      := 0;
            -- Extend datamover command by padding BTT with 1's for
            -- indeterminate BTT mode

        C_PRMY_CMDFIFO_DEPTH        : integer range 1 to 16     := 1;
            -- Depth of DataMover command FIFO
    
        C_PRMRY_IS_ACLK_ASYNC       : integer range 0 to 1      := 0 ;

        C_S2MM_SOF_ENABLE           : integer range 0 to 1      := 0;
        C_MM2S_SOF_ENABLE           : integer range 0 to 1      := 0;


        C_INCLUDE_MM2S              : integer range 0 to 1      := 1;
            -- Include or exclude MM2S primary data path
            -- 0 = Exclude MM2S primary data path
            -- 1 = Include MM2S primary data path

        C_INCLUDE_S2MM              : integer range 0 to 1      := 1
            -- Include or exclude S2MM primary data path
            -- 0 = Exclude S2MM primary data path
            -- 1 = Include S2MM primary data path

);
    port (
        prmry_aclk                  : in  std_logic                         ;               --
        prmry_resetn                : in  std_logic                         ;               --
 
        scndry_aclk                 : in  std_logic                             ;       --
        scndry_resetn               : in  std_logic                             ;       --
                                                                                           --
        -- Control and Status                                                               --
        frame_sync                  : in  std_logic                         ;               --
        video_prmtrs_valid          : in  std_logic                         ;               --
        packet_sof                  : in  std_logic                         ;               --
        run_stop                    : in  std_logic                         ;               --
        stop                        : in  std_logic                         ;               --
        halt                        : in  std_logic                         ;               --
                                                                                            --
        -- sm status                                                                        --
        cmnd_idle                   : out std_logic                         ;               --
        sts_idle                    : out std_logic                         ;               --
        zero_size_err               : out std_logic                         ;               -- CR579593/CR579597
        fsize_mismatch_err_flag     : out std_logic                         ;               -- CR591965
        fsize_mismatch_err          : out std_logic                         ;               -- CR591965
        s2mm_fsize_mismatch_err_s   : out std_logic                         ;               -- CR591965

        mm2s_fsize_mismatch_err_s   : in std_logic                         ;            
        mm2s_fsize_mismatch_err_m   : in std_logic                         ;            
        all_lines_xfred             : in  std_logic                         ;               -- CR616211
        all_lasts_rcvd              : in  std_logic                         ;               --                                                                                             --
        s2mm_strm_all_lines_rcvd    : in  std_logic                         ;               --
        drop_fsync_d_pulse_gen_fsize_less_err              : in  std_logic                         ;               --


        s2mm_fsync_core             : in  std_logic                         ;       
        s2mm_fsync_out_m            : in  std_logic                         ;       
        mm2s_fsync_out_m            : in  std_logic                         ;       



        -- DataMover Command                                                                --
        cmnd_wr                     : out std_logic                         ;               --
        cmnd_data                   : out std_logic_vector                                  --
                                        ((C_M_AXI_ADDR_WIDTH+CMD_BASE_WIDTH)-1 downto 0);   --
        cmnd_pending                : in std_logic                          ;               --
        sts_received                : in std_logic                          ;               --
                                                                                            --
        -- Descriptor Fields                                                                --
        crnt_start_address          : in  std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0);  --
                                                                                            --
        crnt_vsize                  : in  std_logic_vector                                  --
                                        (VSIZE_DWIDTH-1 downto 0)           ;               --
        crnt_hsize                  : in  std_logic_vector                                  --
                                        (HSIZE_DWIDTH-1 downto 0)           ;               --
        crnt_stride                 : in  std_logic_vector                                  --
                                        (STRIDE_DWIDTH-1 downto 0)                          --
    );

end axi_vdma_sm;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_sm is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- DataMover Command Destination Stream Offset
constant CMD_DSA       : std_logic_vector(5 downto 0)  := (others => '0');
-- DataMover Cmnd Reserved Bits
constant CMD_RSVD      : std_logic_vector(
                                DATAMOVER_CMD_RSVMSB_BOFST + C_M_AXI_ADDR_WIDTH downto
                                DATAMOVER_CMD_RSVLSB_BOFST + C_M_AXI_ADDR_WIDTH)
                                := (others => '0');

-- Queued commands counter width
constant COUNTER_WIDTH      : integer := 8;
-- Queued commands zero count
constant ZERO_COUNT         : std_logic_vector(COUNTER_WIDTH - 1 downto 0)
                                := (others => '0');

constant PAD_VALUE          : std_logic_vector(22 - HSIZE_DWIDTH downto 0)
                                := (others => '0');

constant ONES_PAD_VALUE     : std_logic_vector(22 - HSIZE_DWIDTH downto 0)
                                := (others => '1');

constant ZERO_VCOUNT        : std_logic_vector(VSIZE_DWIDTH-1 downto 0)
                                := (others => '0');

constant EXTND_STRIDE_PAD   : std_logic_vector((C_M_AXI_ADDR_WIDTH - STRIDE_DWIDTH) - 1 downto 0)
                                := (others => '0');

-- Zero HSIZE Constant for error check
constant ZERO_HSIZE         : std_logic_vector(HSIZE_DWIDTH-1 downto 0) := (others => '0');
-- Zero VSIZE Constant for error check
constant ZERO_VSIZE         : std_logic_vector(VSIZE_DWIDTH-1 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
type SG_STATE_TYPE      is (
                                IDLE,
                                WAIT_PIPE1,
                                WAIT_PIPE2,
                                CALC_CMD_ADDR,
                                EXECUTE_XFER,
                                CHECK_DONE
                                );

signal dmacntrl_cs                  : SG_STATE_TYPE;
signal dmacntrl_ns                  : SG_STATE_TYPE;

-- State Machine Signals
signal calc_new_addr            : std_logic := '0';
signal load_new_addr            : std_logic := '0';
signal write_cmnd_cmb           : std_logic := '0';
signal cmnd_wr_i                : std_logic := '0';
signal cmnd_idle_i              : std_logic := '0';

-- address calc signals
signal extend_crnt_stride       : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0)
                                    := (others => '0');
signal dm_address               : std_logic_vector(C_M_AXI_ADDR_WIDTH-1 downto 0)
                                    := (others => '0');
signal vert_count               : std_logic_vector(VSIZE_DWIDTH - 1 downto 0)
                                    := (others => '0');
signal horz_count               : std_logic_vector(HSIZE_DWIDTH - 1 downto 0)
                                    := (others => '0');

signal cmnds_queued             : std_logic_vector(COUNTER_WIDTH - 1 downto 0) := (others => '0');
signal count_incr               : std_logic := '0';
signal count_decr               : std_logic := '0';

signal frame_sync_d1            : std_logic := '0';
signal frame_sync_d2            : std_logic := '0';
signal frame_sync_d3            : std_logic := '0';
signal frame_sync_reg           : std_logic := '0';

signal axis_data_available      : std_logic := '0';
signal zero_vsize_err           : std_logic := '0'; -- CR579593/CR579597
signal zero_hsize_err           : std_logic := '0'; -- CR579593/CR579597
signal xfers_done               : std_logic := '0'; -- CR616211

signal all_lines_xfred_d1       : std_logic := '0';
signal all_lines_xfred_fe       : std_logic := '0';
signal xfred_started            : std_logic := '0';
signal mm2s_fsize_mismatch_err_int            	: std_logic := '0';
signal fsize_mismatch_err_int            	: std_logic := '0';
signal fsize_mismatch_err_flag_int            	: std_logic := '0';
signal fsize_mismatch_err_flag_int_d1           : std_logic := '0';
signal fsize_mismatch_err_flag_int_d2           : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

cmnd_wr     <= cmnd_wr_i;
cmnd_idle   <= cmnd_idle_i;



REG_FRAME_SYCN : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                frame_sync_d1   <= '0';
                frame_sync_d2   <= '0';
                frame_sync_d3   <= '0';
                frame_sync_reg  <= '0';
            else
                frame_sync_d1   <= frame_sync;
                frame_sync_d2   <= frame_sync_d1;
                frame_sync_d3   <= frame_sync_d2;
                frame_sync_reg  <= frame_sync_d3;
            end if;
        end if;
    end process REG_FRAME_SYCN;

-------------------------------------------------------------------------------
-- Stream Data Started
-- On S2MM, this is used to prevent issuing CMDs to DataMover until axi_stream
-- data is present on the S2MM interface.  This prevents write requests
-- from being issued out to axi_interconnect when no data available to write.
-------------------------------------------------------------------------------
GEN_NO_STORE_AND_FORWARD : if C_INCLUDE_SF = 0 generate
begin
    STM_DATA_PROCESS : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    axis_data_available <= '0';
                elsif(cmnd_idle_i = '1' and run_stop = '0')then
                    axis_data_available <= '0';
                -- Set if sof detected on axi stream
                elsif(packet_sof = '1')then
                    axis_data_available <= '1';

                -- New set of video parameters, therefore clear flag
                -- New s2mm packets for new parameters must come after
                -- sync.
                elsif(frame_sync = '1' )then
                    axis_data_available <= '0';
                end if;
            end if;
        end process STM_DATA_PROCESS;
end generate GEN_NO_STORE_AND_FORWARD;

-- with store and forward then store-and-forward logic will
-- regulate datamover requests.
GEN_STORE_AND_FORWARD : if C_INCLUDE_SF = 1 generate
begin
    axis_data_available <= '1';
end generate GEN_STORE_AND_FORWARD;

-------------------------------------------------------------------------------
-- Transfer State Machine
-------------------------------------------------------------------------------
DMA_CNTRL_MACHINE : process(dmacntrl_cs,
                           frame_sync_reg,
                           video_prmtrs_valid,
                           cmnd_pending,
                           run_stop,fsize_mismatch_err_flag_int_d2,
                           stop,
                           halt,
                           vert_count,
                           axis_data_available)      -- CR579593/CR579597

    begin

        -- Default signal assignment
        calc_new_addr           <= '0';
        load_new_addr           <= '0';

        write_cmnd_cmb          <= '0';
        cmnd_idle_i             <= '0';
        dmacntrl_ns             <= dmacntrl_cs;

        case dmacntrl_cs is

            -------------------------------------------------------------------
            when IDLE =>
                -- If video parameters are valid and at frame sync and no errors
                -- then start
                if( video_prmtrs_valid = '1' and frame_sync_reg = '1'
                and stop = '0' and halt = '0' and run_stop = '1' and fsize_mismatch_err_flag_int_d2 = '0') then
                    dmacntrl_ns     <= WAIT_PIPE1;
                else
                    cmnd_idle_i     <= '1';
                end if;

            -------------------------------------------------------------------
            -- pipeline delay for valid address from vidreg_module
            when WAIT_PIPE1 =>
                -- CR589083 need to also look at run_Stop to compensate for
                -- pipeline delays when in frame count enable mode
                -- CR591965 need to reset to idle on frame sync
                --if(stop = '1' or halt = '1' or run_stop = '0')then
                if(stop = '1' or halt = '1' or run_stop = '0' or frame_sync_reg='1' or fsize_mismatch_err_flag_int_d2 = '1')then
                    dmacntrl_ns     <= IDLE;
                else
                    dmacntrl_ns     <= WAIT_PIPE2;
                end if;

            -------------------------------------------------------------------
            -- pipeline delay for valid address from vidreg_module
            when WAIT_PIPE2 =>
                -- CR589083 need to also look at run_Stop to compensate for
                -- pipeline delays when in frame count enable mode
                -- CR591965 need to reset to idle on frame sync
                --if(stop = '1' or halt = '1' or run_stop = '0')then
                if(stop = '1' or halt = '1' or run_stop = '0' or frame_sync_reg='1' or fsize_mismatch_err_flag_int_d2 = '1')then
                    dmacntrl_ns     <= IDLE;
                else
                    load_new_addr   <= '1';
                    dmacntrl_ns     <= EXECUTE_XFER;
                end if;

            -------------------------------------------------------------------
            when CALC_CMD_ADDR =>
                -- CR591965 need to reset to idle on frame sync
                --if(stop = '1' or halt = '1')then
                if(stop = '1' or halt = '1' or frame_sync_reg='1' or fsize_mismatch_err_flag_int_d2 = '1')then
                    dmacntrl_ns     <= IDLE;
                else
                    calc_new_addr   <= '1';
                    dmacntrl_ns     <= EXECUTE_XFER;
                end if;

            -------------------------------------------------------------------
            when EXECUTE_XFER =>
                -- error detected
                -- CR591965 need to reset to idle on frame sync
                --if(stop = '1' or halt = '1'
                --or zero_hsize_err = '1' or zero_vsize_err = '1')then  -- CR579593/CR579597
                if(stop = '1' or halt = '1' or frame_sync_reg='1' or fsize_mismatch_err_flag_int_d2 = '1') then -- CR591965
                    dmacntrl_ns     <= IDLE;
                -- Write another command if there is not one already pending
                -- and data available on stream (used for s2mm only)
                elsif(cmnd_pending = '0'
                and axis_data_available = '1')then
                    write_cmnd_cmb  <= '1';
                    dmacntrl_ns     <= CHECK_DONE;
                else
                    dmacntrl_ns     <= EXECUTE_XFER;
                end if;

            -------------------------------------------------------------------
            when CHECK_DONE =>
                -- VSIZE commands issued to datamover then done
                -- CR591965 need to reset to idle on frame sync
                --if(vert_count = ZERO_VCOUNT or stop = '1' or halt = '1')then
                if(vert_count = ZERO_VCOUNT or stop = '1'
                or halt = '1' or frame_sync_reg='1' or fsize_mismatch_err_flag_int_d2 = '1')then
                    dmacntrl_ns         <= IDLE;
                else
                    dmacntrl_ns         <= CALC_CMD_ADDR;
                end if;


            -------------------------------------------------------------------
    -- coverage off
            when others =>
                dmacntrl_ns <= IDLE;
    -- coverage on

        end case;
    end process DMA_CNTRL_MACHINE;

-------------------------------------------------------------------------------
-- register state machine states
-------------------------------------------------------------------------------
REGISTER_STATE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacntrl_cs     <= IDLE;
            else
                dmacntrl_cs     <= dmacntrl_ns;
            end if;
        end if;
    end process REGISTER_STATE;

-------------------------------------------------------------------------------
-- Stride Holding Register
-------------------------------------------------------------------------------
----STRIDE_REGISTER : process(prmry_aclk)
----    begin
----        if(prmry_aclk'EVENT and prmry_aclk = '1')then
----            if(prmry_resetn = '0')then
----                extend_crnt_stride <= (others => '0');
----
----            elsif(load_new_addr = '1')then
----                -- 0 extend stride to match addr width
----                extend_crnt_stride <= EXTND_STRIDE_PAD & crnt_stride;
----            end if;
----        end if;
----    end process STRIDE_REGISTER;

                extend_crnt_stride <= EXTND_STRIDE_PAD & crnt_stride;
-------------------------------------------------------------------------------
-- Command Address Calculator
-------------------------------------------------------------------------------
ADDRESS_CALC : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dm_address <= (others => '0');

            elsif(load_new_addr = '1')then
                dm_address <= crnt_start_address;

            elsif(calc_new_addr = '1')then
                dm_address <= std_logic_vector(unsigned(dm_address) + unsigned(extend_crnt_stride));

            end if;
        end if;
    end process ADDRESS_CALC;

-------------------------------------------------------------------------------
-- Vertical Line Counter
-------------------------------------------------------------------------------
VERT_COUNTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                vert_count <= (others => '0');
            elsif(load_new_addr = '1')then
                vert_count <= crnt_vsize;
            elsif(write_cmnd_cmb = '1')then
                vert_count <= std_logic_vector(unsigned(vert_count) - 1);
            end if;
        end if;
    end process VERT_COUNTER;

-------------------------------------------------------------------------------
-- Horizontal Holding Register
-------------------------------------------------------------------------------
----HORZ_REGISTER : process(prmry_aclk)
----    begin
----        if(prmry_aclk'EVENT and prmry_aclk = '1')then
----            if(prmry_resetn = '0')then
----                horz_count <= (others => '0');
----            elsif(load_new_addr = '1')then
----                horz_count <= crnt_hsize;
----            end if;
----        end if;
----    end process HORZ_REGISTER;

                horz_count <= crnt_hsize;

-------------------------------------------------------------------------------
-- HSIZE Zero Error
-- If hsize is set to zero on address load then flag an internal error
-- CR579593/CR579597
-------------------------------------------------------------------------------
CHECK_ZERO_HSIZE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                zero_hsize_err  <= '0';
            elsif(load_new_addr = '1' and crnt_hsize = ZERO_HSIZE)then
                zero_hsize_err  <= '1';
            else
                zero_hsize_err  <= '0'; -- CR591965
            end if;
        end if;
    end process CHECK_ZERO_HSIZE;

-------------------------------------------------------------------------------
-- VSIZE Zero Error
-- If vsize is set to zero on address load then flag an internal error
-- CR579593/CR579597
-------------------------------------------------------------------------------
CHECK_ZERO_VSIZE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                zero_vsize_err  <= '0';
            elsif(load_new_addr = '1' and crnt_vsize = ZERO_VSIZE)then
                zero_vsize_err  <= '1';
            else
                zero_vsize_err  <= '0'; -- CR591965
            end if;
        end if;
    end process CHECK_ZERO_VSIZE;

-- Drive out for register status bit setting
zero_size_err <= zero_vsize_err or zero_hsize_err;



-- For MM2S and for S2MM when not in Store-And-Forward Mode
GEN_NORMAL_DM_COMMAND : if C_EXTEND_DM_COMMAND = 0 generate
begin
    -------------------------------------------------------------------------------
    -- Build DataMover command
    -------------------------------------------------------------------------------
    -- When command by sm, drive command to cmdsts_if
    GEN_DATAMOVER_CMND : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    cmnd_wr_i  <= '0';
                    cmnd_data  <= (others => '0');

                -- Fetch SM issued a command write
                --
                -- Note: change to mode where EOF generates IOC interrupt as
                -- opposed to a IOC bit in the descriptor negated need for an
                -- EOF and IOC tag.  Given time, these two bits could be combined
                -- into 1.  Associated logic in SG engine would also need to be
                -- modified as well as in sg_if.
                elsif(write_cmnd_cmb = '1')then
                    cmnd_wr_i  <= '1';
                    cmnd_data  <=  CMD_RSVD
                                        -- Command Tag
                                        & '0'
                                        & '0'
                                        & '1'           -- modified for video
                                        & '1'           -- not used by video
                                        -- Command
                                        & dm_address    -- Calculate address
                                        & '1'           -- CMD DRR modified for video
                                        & '1'           -- CMD EOF modified for video
                                        & CMD_DSA       -- No Destination stream offset
                                        & '1'           -- Type no longer used
                                        & PAD_VALUE
                                        & horz_count;

                else
                    cmnd_wr_i  <= '0';

                end if;
            end if;
        end process GEN_DATAMOVER_CMND;
end generate GEN_NORMAL_DM_COMMAND;

-- For S2MM in Store-And-Forward Mode and DRE turned off
-- Need to set the BTT to a greater value than hsize.  This will allow
-- the indeterminate BTT mode of the datamover to not generate a bus error
-- on overflow when the hsize values are not stream data width aligned
GEN_EXTENDED_DM_COMMAND : if C_EXTEND_DM_COMMAND = 1 generate
begin
    -------------------------------------------------------------------------------
    -- Build DataMover command
    -------------------------------------------------------------------------------
    -- When command by sm, drive command to cmdsts_if
    GEN_DATAMOVER_CMND : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    cmnd_wr_i  <= '0';
                    cmnd_data  <= (others => '0');

                -- Fetch SM issued a command write
                --
                -- Note: change to mode where EOF generates IOC interrupt as
                -- opposed to a IOC bit in the descriptor negated need for an
                -- EOF and IOC tag.  Given time, these two bits could be combined
                -- into 1.  Associated logic in SG engine would also need to be
                -- modified as well as in sg_if.
                elsif(write_cmnd_cmb = '1')then
                    cmnd_wr_i  <= '1';
                    cmnd_data  <=  CMD_RSVD
                                        -- Command Tag
                                        & '0'
                                        & '0'
                                        & '1'           -- modified for video
                                        & '1'           -- not used by video
                                        -- Command
                                        & dm_address    -- Calculate address
                                        & '1'           -- CMD DRR modified for video
                                        & '1'           -- CMD EOF modified for video
                                        & CMD_DSA       -- No Destination stream offset
                                        & '1'           -- Type no longer used
                                        & ONES_PAD_VALUE -- pad with 1's - want greater than hsize btt
                                        & horz_count;

                else
                    cmnd_wr_i  <= '0';

                end if;
            end if;
        end process GEN_DATAMOVER_CMND;
end generate GEN_EXTENDED_DM_COMMAND;

-------------------------------------------------------------------------------
-- Counter for keepting track of pending commands/status in primary datamover
-- Use this to determine if primary datamover for mm2s is Idle.
-------------------------------------------------------------------------------
-- increment with each command written
count_incr  <= '1' when cmnd_wr_i = '1' and sts_received = '0'
          else '0';

-- decrement with each status received
count_decr  <= '1' when cmnd_wr_i = '0' and sts_received = '1'
          else '0';

-- count number of queued commands to keep track of what datamover is still
-- working on
CMD2STS_COUNTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or stop = '1' or halt = '1')then
                cmnds_queued <= (others => '0');
            elsif(count_incr = '1')then
                cmnds_queued <= std_logic_vector(unsigned(cmnds_queued(COUNTER_WIDTH - 1 downto 0)) + 1);
            elsif(count_decr = '1')then
                cmnds_queued <= std_logic_vector(unsigned(cmnds_queued(COUNTER_WIDTH - 1 downto 0)) - 1);
            end if;
        end if;
    end process CMD2STS_COUNTER;

-- Indicate status is idle when no cmnd/sts queued
sts_idle <= '1' when  cmnds_queued = ZERO_COUNT and xfers_done = '1'
            else '0';

-- CR616211
-- For store-and-foward need to keep track of when
-- AXIS stream is actually complete (For MM2S)
GEN_DONE_FOR_SNF : if C_INCLUDE_SF = 1 generate
begin
    -- In free run then condition xfers done with a indication
    -- transfers have started.  This fixes issue with double
    -- frame sync.
    GEN_FOR_FREE_RUN : if C_USE_FSYNC = 0 generate
    begin
        REG_ALLL_XFRED : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        all_lines_xfred_d1 <= '0';
                    else
                        all_lines_xfred_d1 <= all_lines_xfred;
                    end if;
                end if;
            end process REG_ALLL_XFRED;

        all_lines_xfred_fe <= not all_lines_xfred and all_lines_xfred_d1;

        -- Flag when a transfer as started
        REG_XFRED_STARTED : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    -- at start want to be able to gen first fsync so
                    -- intially set flag to 1 so sts_idle will assert
                    -- gen first fsync
                    if(prmry_resetn = '0' or run_stop = '0')then
                        xfred_started <= '1';
                    -- when running then utilize frame_sync to clear flag
                    elsif(frame_sync = '1')then
                        xfred_started <= '0';
                    -- set flag whith each falling edge
                    elsif(all_lines_xfred_fe='1')then
                        xfred_started <= '1';
                    end if;
                end if;
            end process REG_XFRED_STARTED;

    end generate GEN_FOR_FREE_RUN;

    -- Not in free run so logic not needed
    GEN_FOR_XTERN_FSYNC : if C_USE_FSYNC = 1 generate
    begin
        xfred_started <= '1';
    end generate GEN_FOR_XTERN_FSYNC;


    xfers_done <= '1' when (xfred_started='1' and all_lines_xfred = '1')
                            or stop = '1'
                            or halt = '1'
                            or run_stop = '0' --CR622584
             else '0';

end generate GEN_DONE_FOR_SNF;

-- If store-and-foward off then do not need to keep track
GEN_DONE_NO_SNF : if C_INCLUDE_SF = 0 generate
begin
    xfers_done <= '1';
end generate GEN_DONE_NO_SNF;


-------------------------------------------------------------------------------
-- Frame Size MisMatch (CR591965)
-------------------------------------------------------------------------------

-- Frame size mismatch for external frame sync
GEN_FSIZE_MISMATCH : if C_USE_FSYNC = 1 generate
begin

GEN_S2MM_MISMATCH_NON_FLUSH : if C_INCLUDE_S2MM = 1 and  C_ENABLE_FLUSH_ON_FSYNC = 0 generate
begin

    -- Frame Size Mismatch Detection - Frame size mismatch error detection to detect when
    -- VDMA channel configured for more lines than what could fit in a frame.
    FSIZE_MISMATCH : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    fsize_mismatch_err_int <= '0';
                -- frame sync occurred when not all lines transferred
--                elsif(frame_sync = '1' and all_lines_xfred = '0')then
                elsif(frame_sync = '1' and all_lasts_rcvd = '0')then
                    fsize_mismatch_err_int <= '1';
                else
                    fsize_mismatch_err_int <= '0';
                end if;
            end if;
        end process FSIZE_MISMATCH;

    fsize_mismatch_err_flag_int_d2 <= '0';
    s2mm_fsize_mismatch_err_s           <= '0';
end generate GEN_S2MM_MISMATCH_NON_FLUSH;



GEN_S2MM_MISMATCH_FLUSH_NON_SOF : if C_INCLUDE_S2MM = 1 and  C_ENABLE_FLUSH_ON_FSYNC = 1 and  C_S2MM_SOF_ENABLE = 0 generate
begin

    -- Frame Size Mismatch Detection - Frame size mismatch error detection to detect when
    -- VDMA channel configured for more lines than what could fit in a frame.
    FSIZE_MISMATCH : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    fsize_mismatch_err_int <= '0';
                -- frame sync occurred when not all lines transferred
--                elsif(frame_sync = '1' and all_lines_xfred = '0')then
                elsif(frame_sync = '1' and all_lasts_rcvd = '0')then
                    fsize_mismatch_err_int <= '1';
                else
                    fsize_mismatch_err_int <= '0';
                end if;
            end if;
        end process FSIZE_MISMATCH;

    fsize_mismatch_err_flag_int_d2 <= '0';
    s2mm_fsize_mismatch_err_s           <= '0';
end generate GEN_S2MM_MISMATCH_FLUSH_NON_SOF;


GEN_S2MM_MISMATCH_FLUSH_SOF : if C_INCLUDE_S2MM = 1  and  C_ENABLE_FLUSH_ON_FSYNC = 1 and  C_S2MM_SOF_ENABLE = 1 generate


constant ZERO_VALUE_VECT            		: std_logic_vector(255 downto 0) := (others => '0');


signal s2mm_fsync_out_m_d1            		: std_logic := '0';
signal fsize_mismatch_err_s1            	: std_logic := '0';
signal fsize_mismatch_err_s            		: std_logic := '0';
signal drop_fsync_d_pulse_gen_fsize_less_err_d1 : std_logic := '0';

begin

    -- Frame Size Mismatch Detection - Frame size mismatch error detection to detect when
    -- VDMA channel configured for more lines than what could fit in a frame.
    FSIZE_MISMATCH_STRM_FLUSH_SOF : process(scndry_aclk)
        begin
            if(scndry_aclk'EVENT and scndry_aclk='1')then
                if(scndry_resetn = '0')then
                    fsize_mismatch_err_s1 <= '0';
                -- frame sync occurred when not all lines transferred
--                elsif(frame_sync = '1' and all_lines_xfred = '0')then
                --elsif(s2mm_fsync_core = '1'  and (s2mm_strm_all_lines_rcvd = '0' or drop_fsync_d_pulse_gen_fsize_less_err = '1'))then
                elsif(s2mm_fsync_core = '1'  and s2mm_strm_all_lines_rcvd = '0')then
                    fsize_mismatch_err_s1 <= '1';
                else
                    fsize_mismatch_err_s1 <= '0';
                end if;
            end if;
        end process FSIZE_MISMATCH_STRM_FLUSH_SOF;


D1_DROP_DELAY_FSYNC : process(scndry_aclk)
    begin
        if(scndry_aclk'EVENT and scndry_aclk = '1')then
            if(scndry_resetn = '0')then
                drop_fsync_d_pulse_gen_fsize_less_err_d1  <= '0';
            else
                drop_fsync_d_pulse_gen_fsize_less_err_d1  <= drop_fsync_d_pulse_gen_fsize_less_err;
            end if;
        end if;
    end process D1_DROP_DELAY_FSYNC;



    fsize_mismatch_err_s                <= fsize_mismatch_err_s1 or drop_fsync_d_pulse_gen_fsize_less_err_d1 ;



    s2mm_fsize_mismatch_err_s           <= fsize_mismatch_err_s;


GEN_FOR_ASYNC : if C_PRMRY_IS_ACLK_ASYNC = 1 generate
begin


----    FSIZE_MISMATCH_CDC_I_FLUSH_SOF : entity axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE              => CDC_TYPE_PULSE_S_P_OPEN_ENDED                           ,
----            C_VECTOR_WIDTH          => 1
----        )
----        port map (
----            prmry_aclk              => prmry_aclk                               ,
----            prmry_resetn            => prmry_resetn                             ,
----            scndry_aclk             => scndry_aclk                              ,
----            scndry_resetn           => scndry_resetn                            ,
----            scndry_in               => fsize_mismatch_err_s                                      ,   -- Not Used
----            prmry_out               => fsize_mismatch_err_int                                     ,   -- Not Used
----            prmry_in                => '0'                         ,
----            scndry_out              =>  open                         ,
----            scndry_vect_s_h         => '0'                                      ,   -- Not Used
----            scndry_vect_in          => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            prmry_vect_out          => open                                     ,   -- Not Used
----            prmry_vect_s_h          => '0'                                      ,   -- Not Used
----            prmry_vect_in           => ZERO_VALUE_VECT(0 downto 0)              ,   -- Not Used
----            scndry_vect_out         => open                                         -- Not Used
----        );
----

FSIZE_MISMATCH_CDC_I_FLUSH_SOF : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 0,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 1,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => scndry_aclk,
        prmry_resetn               => scndry_resetn, 
        prmry_in                   => fsize_mismatch_err_s, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => prmry_aclk, 
        scndry_resetn              => prmry_resetn,
        scndry_out                 => fsize_mismatch_err_int,
        scndry_vect_out            => open
    );



end generate GEN_FOR_ASYNC;
GEN_FOR_SYNC : if C_PRMRY_IS_ACLK_ASYNC = 0 generate
begin
    fsize_mismatch_err_int           <= fsize_mismatch_err_s;

end generate GEN_FOR_SYNC;

					
		D1_S2MM_FSYNC_OUT_M : process(prmry_aclk)
		    begin
		        if(prmry_aclk'EVENT and prmry_aclk = '1')then
		            if(prmry_resetn = '0')then
		                s2mm_fsync_out_m_d1  <= '0';
		            else
		                s2mm_fsync_out_m_d1  <= s2mm_fsync_out_m;
		            end if;
		        end if;
		    end process D1_S2MM_FSYNC_OUT_M;
		
	
		FSIZE_LESS_ERR_FLAG : process(prmry_aclk)
		    begin
		        if(prmry_aclk'EVENT and prmry_aclk = '1')then
		            if(prmry_resetn = '0' or s2mm_fsync_out_m_d1 = '1')then
		                fsize_mismatch_err_flag_int  <= '0';
		            elsif(fsize_mismatch_err_int = '1')then
		                fsize_mismatch_err_flag_int  <= '1';
		            end if;
		        end if;
		    end process FSIZE_LESS_ERR_FLAG;
		
				


    fsize_mismatch_err_flag_int_d2  <= fsize_mismatch_err_flag_int or fsize_mismatch_err_int;


end generate GEN_S2MM_MISMATCH_FLUSH_SOF;




GEN_MM2S_MISMATCH_NO_FLUSH_SOF : if (C_INCLUDE_MM2S = 1  and (C_ENABLE_FLUSH_ON_FSYNC = 0 or C_MM2S_SOF_ENABLE  = 0)) generate
begin


    -- Frame Size Mismatch Detection - Frame size mismatch error detection to detect when
    -- VDMA channel configured for more lines than what could fit in a frame.
    FSIZE_MISMATCH : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk='1')then
                if(prmry_resetn = '0')then
                    mm2s_fsize_mismatch_err_int <= '0';
                -- frame sync occurred when not all lines transferred
                elsif(frame_sync = '1' and all_lines_xfred = '0')then
                    mm2s_fsize_mismatch_err_int <= '1';
                else
                    mm2s_fsize_mismatch_err_int <= '0';
                end if;
            end if;
        end process FSIZE_MISMATCH;


    s2mm_fsize_mismatch_err_s           <= '0';
fsize_mismatch_err_flag_int_d2 	<= '0';
fsize_mismatch_err_int 		<= mm2s_fsize_mismatch_err_int;

end generate GEN_MM2S_MISMATCH_NO_FLUSH_SOF;


GEN_MM2S_MISMATCH_FLUSH_SOF : if (C_INCLUDE_MM2S = 1  and (C_ENABLE_FLUSH_ON_FSYNC = 1 and C_MM2S_SOF_ENABLE  = 1)) generate

signal mm2s_fsync_out_m_d1            : std_logic := '0';

begin

fsize_mismatch_err_int 		<= mm2s_fsize_mismatch_err_m;




				
		D1_MM2S_FSYNC_OUT_M : process(prmry_aclk)
		    begin
		        if(prmry_aclk'EVENT and prmry_aclk = '1')then
		            if(prmry_resetn = '0')then
		                mm2s_fsync_out_m_d1  <= '0';
		            else
		                mm2s_fsync_out_m_d1  <= mm2s_fsync_out_m;
		            end if;
		        end if;
		    end process D1_MM2S_FSYNC_OUT_M;
		

		MM2S_FSIZE_LESS_ERR_FLAG : process(prmry_aclk)
		    begin
		        if(prmry_aclk'EVENT and prmry_aclk = '1')then
		            if(prmry_resetn = '0' or mm2s_fsync_out_m_d1 = '1')then
		                fsize_mismatch_err_flag_int_d1  <= '0';
		            elsif(mm2s_fsize_mismatch_err_m = '1')then
		                fsize_mismatch_err_flag_int_d1  <= '1';
		            end if;
		        end if;
		    end process MM2S_FSIZE_LESS_ERR_FLAG;

    fsize_mismatch_err_flag_int_d2  <= fsize_mismatch_err_flag_int_d1 or mm2s_fsize_mismatch_err_m;
    s2mm_fsize_mismatch_err_s           <= '0';

end generate GEN_MM2S_MISMATCH_FLUSH_SOF;


end generate GEN_FSIZE_MISMATCH;

-- No frame size mismatch if in free run mode
GEN_NO_FSIZE_MISMATCH : if C_USE_FSYNC = 0 generate
begin
    fsize_mismatch_err_int <= '0';
    fsize_mismatch_err_flag_int_d2 <= '0';
    s2mm_fsize_mismatch_err_s           <= '0';
end generate GEN_NO_FSIZE_MISMATCH;
fsize_mismatch_err_flag <= fsize_mismatch_err_flag_int_d2;
fsize_mismatch_err <= fsize_mismatch_err_int;
end implementation;
