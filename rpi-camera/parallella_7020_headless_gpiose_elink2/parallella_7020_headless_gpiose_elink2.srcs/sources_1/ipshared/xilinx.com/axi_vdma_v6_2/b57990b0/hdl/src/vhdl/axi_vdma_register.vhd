-------------------------------------------------------------------------------
-- axi_vdma_register
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
-- Filename:        axi_vdma_register.vhd
--
-- Description:     This entity encompasses the channel register set.
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
entity  axi_vdma_register is
    generic(
        C_NUM_REGISTERS             : integer                   := 8        ;
        C_NUM_FSTORES               : integer range 1 to 32     := 3        ;
        C_CHANNEL_IS_MM2S           : integer range 0 to 1   := 1       ;

        C_LINEBUFFER_THRESH         : integer range 1 to 65536  := 1        ;
        --C_ENABLE_DEBUG_INFO         : string := "1111111111111111";		-- 1 to 16 -- 
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





        C_INTERNAL_GENLOCK_ENABLE   	: integer range 0 to 1          := 0;

        C_INCLUDE_SG                : integer range 0 to 1      := 1        ;
        C_GENLOCK_MODE              : integer range 0 to 3      := 0        ;
        C_ENABLE_FLUSH_ON_FSYNC     : integer range 0 to 1      := 0        ; -- CR591965
        C_S_AXI_LITE_DATA_WIDTH     : integer range 32 to 32    := 32       ;
        C_M_AXI_SG_ADDR_WIDTH       : integer range 32 to 64    := 32
    );
    port (
        prmry_aclk                  : in  std_logic                         ;               --
        prmry_resetn                : in  std_logic                         ;               --
                                                                                            --
        -- AXI Interface Control                                                            --
        axi2ip_wrce                 : in  std_logic_vector                                  --
                                        (C_NUM_REGISTERS-1 downto 0)        ;               --
        axi2ip_wrdata               : in  std_logic_vector                                  --
                                        (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);               --
        -- DMASR Control                                                                    --
        stop_dma                    : in  std_logic                         ;               --
        halted_clr                  : in  std_logic                         ;               --
        halted_set                  : in  std_logic                         ;               --
        idle_set                    : in  std_logic                         ;               --
        idle_clr                    : in  std_logic                         ;               --
        ioc_irq_set                 : in  std_logic                         ;               --
        dly_irq_set                 : in  std_logic                         ;               --
        frame_sync                  : in  std_logic                         ;               --
        fsync_mask                  : in  std_logic                         ;               -- CR 578591
        irqdelay_status             : in  std_logic_vector(7 downto 0)      ;               --
        irqthresh_status            : in  std_logic_vector(7 downto 0)      ;               --
        irqdelay_wren               : out std_logic                         ;               --
        irqthresh_wren              : out std_logic                         ;               --
        dlyirq_dsble                : out std_logic                         ;               --
                                                                                            --
        -- Error Control                                                                    --


        fsize_mismatch_err          : in  std_logic                         ;       --
        lsize_mismatch_err          : in  std_logic                         ;       --
        lsize_more_mismatch_err     : in  std_logic                         ;       --
        s2mm_fsize_more_or_sof_late : in  std_logic                         ;       --


        dma_interr_set_minus_frame_errors              : in  std_logic                         ;               --
        dma_interr_set              : in  std_logic                         ;               --
        dma_slverr_set              : in  std_logic                         ;               --
        dma_decerr_set              : in  std_logic                         ;               --
        ftch_slverr_set             : in  std_logic                         ;               --
        ftch_decerr_set             : in  std_logic                         ;               --
        ftch_err_addr               : in  std_logic_vector                                  --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;               --
        frmstr_err_addr             : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        soft_reset_clr              : in  std_logic                         ;               --
                                                                                            --
        -- CURDESC Update                                                                   --
        update_curdesc              : in  std_logic                         ;               --
        new_curdesc                 : in  std_logic_vector                                  --
                                        (C_M_AXI_SG_ADDR_WIDTH-1 downto 0)  ;               --
        update_frmstore             : in  std_logic                         ;               --
        new_frmstr                  : in  std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
        frm_store                   : out std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)     ;               --
                                                                                            --
        -- TAILDESC Update                                                                  --
        tailpntr_updated            : out std_logic                         ;               --
                                                                                            --
        -- Channel Register Out                                                             --
        dma_irq_mask                       : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --

        reg_index                       : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --


        dmacr                       : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --
        dmasr                       : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --
        curdesc_lsb                 : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --
        curdesc_msb                 : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --
        taildesc_lsb                : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --
        taildesc_msb                : out std_logic_vector                                  --
                                           (C_S_AXI_LITE_DATA_WIDTH-1 downto 0);            --
        num_frame_store_regmux      : out std_logic_vector                                  --
                                           (FRMSTORE_MSB_BIT downto 0);                     --
        num_frame_store             : out std_logic_vector                                  --
                                           (FRMSTORE_MSB_BIT downto 0);                     --
        linebuf_threshold           : out std_logic_vector                                  --
                                            (THRESH_MSB_BIT downto 0);                      --
                                                                                            --
        introut                     : out std_logic                                         --

    );
end axi_vdma_register;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_register is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
constant DMACR_INDEX            : integer := 0;         -- DMACR Register index
constant DMASR_INDEX            : integer := 1;         -- DMASR Register index
constant CURDESC_LSB_INDEX      : integer := 2;         -- CURDESC LSB Reg index
constant CURDESC_MSB_INDEX      : integer := 3;         -- CURDESC MSB Reg index
constant TAILDESC_LSB_INDEX     : integer := 4;         -- TAILDESC LSB Reg index
constant TAILDESC_MSB_INDEX     : integer := 5;         -- TAILDESC MSB Reg index
constant FRAME_STORE_INDEX      : integer := 6;         -- Frame Store Reg index
constant THRESHOLD_INDEX        : integer := 7;         -- Threshold Reg index
constant REG_IND        	: integer := 5;         --  Reg index
constant DMA_IRQ_MASK_IND  : integer := 3;         -- 



constant ZERO_VALUE             : std_logic_vector(31 downto 0) := (others => '0');

-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
signal reg_index_i              : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');

signal dma_irq_mask_i              : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');




signal dmacr_i              : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal dmasr_i              : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal curdesc_lsb_i        : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal curdesc_msb_i        : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal taildesc_lsb_i       : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal taildesc_msb_i       : std_logic_vector
                                (C_S_AXI_LITE_DATA_WIDTH-1 downto 0) := (others => '0');
signal num_frame_store_regmux_i    : std_logic_vector
                                (FRMSTORE_MSB_BIT downto 0)          := (others =>'0');
signal num_frame_store_i    : std_logic_vector
                                (FRMSTORE_MSB_BIT downto 0)          := (others =>'0');
signal linebuf_threshold_i  : std_logic_vector
                                (LINEBUFFER_THRESH_WIDTH-1 downto 0) := (others => '0');

-- DMASR Signals
signal halted               : std_logic := '0';
signal idle                 : std_logic := '0';
signal err                  : std_logic := '0';
signal err_p                  : std_logic := '0';
signal fsize_err            : std_logic := '0';
signal lsize_err            : std_logic := '0';
signal lsize_more_err       : std_logic := '0';
signal s2mm_fsize_more_or_sof_late_bit           : std_logic := '0';
signal dma_interr           : std_logic := '0';
signal dma_interr_minus_frame_errors           : std_logic := '0';
signal dma_slverr           : std_logic := '0';
signal dma_decerr           : std_logic := '0';
signal sg_slverr            : std_logic := '0';
signal sg_decerr            : std_logic := '0';
signal ioc_irq              : std_logic := '0';
signal dly_irq              : std_logic := '0';
signal err_d1               : std_logic := '0';
signal err_re               : std_logic := '0';
--signal err_fe               : std_logic := '0';
signal err_irq              : std_logic := '0';

signal sg_ftch_err          : std_logic := '0';
signal err_pointer_set      : std_logic := '0';
signal err_frmstore_set     : std_logic := '0';

-- Interrupt coalescing support signals
signal different_delay      : std_logic := '0';
signal different_thresh     : std_logic := '0';
signal threshold_is_zero    : std_logic := '0';

-- Soft reset support signals
signal soft_reset_i         : std_logic := '0';
signal run_stop_clr         : std_logic := '0';
signal reset_counts         : std_logic := '0';
signal irqdelay_wren_i      : std_logic := '0';
signal irqthresh_wren_i     : std_logic := '0';

-- Frame Store support signal
signal frmstore_is_zero     : std_logic := '0';
signal frm_store_i            : std_logic_vector                                  --
                                        (FRAME_NUMBER_WIDTH-1 downto 0)  := (others => '0')   ;               --

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

frm_store               <= frm_store_i          ;
dmacr                   <= dmacr_i          ;
dmasr                   <= dmasr_i          ;
curdesc_lsb             <= curdesc_lsb_i    ;
curdesc_msb             <= curdesc_msb_i    ;
taildesc_lsb            <= taildesc_lsb_i   ;
dma_irq_mask            	<= dma_irq_mask_i   ;
reg_index            	<= reg_index_i   ;
taildesc_msb            <= taildesc_msb_i   ;
num_frame_store         <= num_frame_store_i;
num_frame_store_regmux  <= num_frame_store_regmux_i;
linebuf_threshold       <= linebuf_threshold_i;

---------------------------------------------------------------------------
-- DMA Control Register

---------------------------------------------------------------------------
-- DMACR - Interrupt Delay Value
-------------------------------------------------------------------------------

DISABLE_DMACR_DELAY_CNTR : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_6 = 0 and C_ENABLE_DEBUG_ALL = 0) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_14 = 0 and C_ENABLE_DEBUG_ALL = 0) ))generate
begin

                irqdelay_wren <= '0';

                dmacr_i(DMACR_IRQDELAY_MSB_BIT
                 downto DMACR_IRQDELAY_LSB_BIT) <= (others => '0');

end generate DISABLE_DMACR_DELAY_CNTR;
  



ENABLE_DMACR_DELAY_CNTR : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_6 = 1 or C_ENABLE_DEBUG_ALL = 1) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_14 = 1 or C_ENABLE_DEBUG_ALL = 1) ))generate
begin

DMACR_DELAY : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_IRQDELAY_MSB_BIT
                 downto DMACR_IRQDELAY_LSB_BIT) <= (others => '0');
            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQDELAY_MSB_BIT
                 downto DMACR_IRQDELAY_LSB_BIT) <= axi2ip_wrdata(DMACR_IRQDELAY_MSB_BIT
                                                          downto DMACR_IRQDELAY_LSB_BIT);
            end if;
        end if;
    end process DMACR_DELAY;

-- If written delay is different than previous value then assert write enable
different_delay <= '1' when dmacr_i(DMACR_IRQDELAY_MSB_BIT downto DMACR_IRQDELAY_LSB_BIT)
                   /= axi2ip_wrdata(DMACR_IRQDELAY_MSB_BIT downto DMACR_IRQDELAY_LSB_BIT)
              else '0';

-- Delay value different, drive write of delay value to interrupt controller
NEW_DELAY_WRITE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                irqdelay_wren_i <= '0';
            -- If AXI Lite write to DMACR and delay different than current
            -- setting then update delay value
            elsif(axi2ip_wrce(DMACR_INDEX) = '1' and different_delay = '1')then
                irqdelay_wren_i <= '1';
            else
                irqdelay_wren_i <= '0';
            end if;
        end if;
    end process NEW_DELAY_WRITE;

-- Reset delay irq counter on new delay write, or reset, or frame sync
irqdelay_wren <= irqdelay_wren_i or reset_counts or frame_sync;

end generate ENABLE_DMACR_DELAY_CNTR;



-------------------------------------------------------------------------------
-- DMACR - Interrupt Threshold Value
-------------------------------------------------------------------------------


DISABLE_DMACR_FRM_CNTR : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_7 = 0 and C_ENABLE_DEBUG_ALL = 0) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_15 = 0 and C_ENABLE_DEBUG_ALL = 0) ))generate
begin

                irqthresh_wren <= '0';

                dmacr_i(DMACR_IRQTHRESH_MSB_BIT
                        downto DMACR_IRQTHRESH_LSB_BIT) <= ONE_THRESHOLD;

end generate DISABLE_DMACR_FRM_CNTR;
  






ENABLE_DMACR_FRM_CNTR : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_7 = 1 or C_ENABLE_DEBUG_ALL = 1) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_15 = 1 or C_ENABLE_DEBUG_ALL = 1) ))generate
begin


threshold_is_zero <= '1' when axi2ip_wrdata(DMACR_IRQTHRESH_MSB_BIT
                                     downto DMACR_IRQTHRESH_LSB_BIT) = ZERO_THRESHOLD
                else '0';

DMACR_THRESH : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_IRQTHRESH_MSB_BIT
                        downto DMACR_IRQTHRESH_LSB_BIT) <= ONE_THRESHOLD;
            -- On AXI Lite write
            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then

                -- If value is 0 then set threshold to 1
                if(threshold_is_zero='1')then
                    dmacr_i(DMACR_IRQTHRESH_MSB_BIT
                     downto DMACR_IRQTHRESH_LSB_BIT)    <= ONE_THRESHOLD;

                -- else set threshold to axi lite wrdata value
                else
                    dmacr_i(DMACR_IRQTHRESH_MSB_BIT
                     downto DMACR_IRQTHRESH_LSB_BIT)    <= axi2ip_wrdata(DMACR_IRQTHRESH_MSB_BIT
                                                                  downto DMACR_IRQTHRESH_LSB_BIT);
                end if;
            end if;
        end if;
    end process DMACR_THRESH;

-- If written threshold is different than previous value then assert write enable
different_thresh <= '1' when dmacr_i(DMACR_IRQTHRESH_MSB_BIT downto DMACR_IRQTHRESH_LSB_BIT)
                    /= axi2ip_wrdata(DMACR_IRQTHRESH_MSB_BIT downto DMACR_IRQTHRESH_LSB_BIT)
              else '0';

-- new treshold written therefore drive write of threshold out
NEW_THRESH_WRITE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                irqthresh_wren_i <= '0';
            -- If AXI Lite write to DMACR and threshold different than current
            -- setting then update threshold value
            -- If paused then hold frame counter from counting
            elsif(axi2ip_wrce(DMACR_INDEX) = '1' and different_thresh = '1')then

                irqthresh_wren_i <= '1';
            else
                irqthresh_wren_i <= '0';
            end if;
        end if;
    end process NEW_THRESH_WRITE;


irqthresh_wren <= irqthresh_wren_i or reset_counts;


end generate ENABLE_DMACR_FRM_CNTR;



-- Due to seperate MM2S and S2MM resets the delay and frame count registers
-- is axi_sg must be reset with a physical write to axi_sg during a soft reset.
REG_RESET_IRQ_COUNTS : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(soft_reset_clr = '1')then
                reset_counts <= '0';
            elsif(prmry_resetn = '0' and dmacr_i(DMACR_RESET_BIT) = '1')then
                reset_counts <= '1';
            end if;
        end if;
    end process REG_RESET_IRQ_COUNTS;

-----------------------------------------------------------------------------------
------ DMACR - Remainder of DMA Control Register
-----------------------------------------------------------------------------------

GEN_NO_INTERNAL_GENLOCK : if C_INTERNAL_GENLOCK_ENABLE = 0 generate
begin


DS_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 3 generate
begin
DS_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <= (others => '0');

            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <=   axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & axi2ip_wrdata(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & ZERO_VALUE(DMACR_GENLOCK_SEL_BIT)  -- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process DS_DMACR_REGISTER;
end generate DS_GEN_DMACR_REGISTER;

DM_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 2 generate
begin
DM_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <= (others => '0');

            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <=   axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & axi2ip_wrdata(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & ZERO_VALUE(DMACR_GENLOCK_SEL_BIT)  -- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process DM_DMACR_REGISTER;
end generate DM_GEN_DMACR_REGISTER;


S_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 1 generate
begin
S_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <= (others => '0');

            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <= axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & axi2ip_wrdata(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & ZERO_VALUE(DMACR_GENLOCK_SEL_BIT)  -- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process S_DMACR_REGISTER;
end generate S_GEN_DMACR_REGISTER;

end generate GEN_NO_INTERNAL_GENLOCK;




-------------------------------------------------------------------------------
-- DMACR - Remainder of DMA Control Register
-------------------------------------------------------------------------------


GEN_FOR_INTERNAL_GENLOCK : if C_INTERNAL_GENLOCK_ENABLE = 1 generate
begin

DS_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 3 generate
begin
DS_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then

		dmacr_i(14 downto 8) <= (others => '0');
		dmacr_i(7) 	     <= '1';
		dmacr_i(6 downto 4)  <= (others => '0');


            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <=   axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & axi2ip_wrdata(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & axi2ip_wrdata(DMACR_GENLOCK_SEL_BIT)  -- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process DS_DMACR_REGISTER;
end generate DS_GEN_DMACR_REGISTER;

DM_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 2 generate
begin
DM_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then

		dmacr_i(14 downto 8) <= (others => '0');
		dmacr_i(7) 	     <= '1';
		dmacr_i(6 downto 4)  <= (others => '0');



            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <=   axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & axi2ip_wrdata(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & axi2ip_wrdata(DMACR_GENLOCK_SEL_BIT)  -- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process DM_DMACR_REGISTER;
end generate DM_GEN_DMACR_REGISTER;


S_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 1 generate
begin
S_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then

		dmacr_i(14 downto 8) <= (others => '0');
		dmacr_i(7) 	     <= '1';
		dmacr_i(6 downto 4)  <= (others => '0');



            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <=  axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & axi2ip_wrdata(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & axi2ip_wrdata(DMACR_GENLOCK_SEL_BIT)  -- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process S_DMACR_REGISTER;
end generate S_GEN_DMACR_REGISTER;
end generate GEN_FOR_INTERNAL_GENLOCK;



----M_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 0 generate
----begin
----M_DMACR_REGISTER : process(prmry_aclk)
----    begin
----        if(prmry_aclk'EVENT and prmry_aclk = '1')then
----            if(prmry_resetn = '0')then
----                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-1
----                        downto DMACR_FRMCNTEN_BIT)   <= (others => '0');
----
----            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
----                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-1
----                        downto DMACR_FRMCNTEN_BIT)   <= axi2ip_wrdata(DMACR_REPEAT_EN_BIT)        -- bit  15
----                                                        & axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
----                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
----                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
----                                                        & ZERO_VALUE(DMACR_PNTR_NUM_MSB
----                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
----                                                        & '0'  					-- bit  7
----                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
----                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
----                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
----            end if;
----        end if;
----    end process M_DMACR_REGISTER;
----end generate M_GEN_DMACR_REGISTER;

M_GEN_DMACR_REGISTER : if C_GENLOCK_MODE = 0 generate
begin
M_DMACR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <= (others => '0');

            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_IRQTHRESH_LSB_BIT-2
                        downto DMACR_FRMCNTEN_BIT)   <=   axi2ip_wrdata(DMACR_ERR_IRQEN_BIT)    -- bit  14
                                                        & axi2ip_wrdata(DMACR_DLY_IRQEN_BIT)    -- bit  13
                                                        & axi2ip_wrdata(DMACR_IOC_IRQEN_BIT)    -- bit  12
                                                        & ZERO_VALUE(DMACR_PNTR_NUM_MSB
                                                                 downto DMACR_PNTR_NUM_LSB)     -- bits 11 downto 8
                                                        & '0'  					-- bit  7
                                                        & axi2ip_wrdata(DMACR_FSYNCSEL_MSB
                                                                 downto DMACR_FSYNCSEL_LSB)     -- bits 6 downto 5
                                                        & axi2ip_wrdata(DMACR_FRMCNTEN_BIT);    -- bit  4
            end if;
        end if;
    end process M_DMACR_REGISTER;
end generate M_GEN_DMACR_REGISTER;




-------------------------------------------------------------------------------
-- DMACR - GenLock Sync Enable Bit (CR577698)
-------------------------------------------------------------------------------

-- Dynamic Genlock Slave mode therefore instantiate a register for sync enable.
DS_GEN_SYNCEN_BIT : if C_GENLOCK_MODE = 3 generate
begin
    DS_DMACR_SYNCEN : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' )then
                    dmacr_i(DMACR_SYNCEN_BIT)  <= '0';

                -- If DMACR Write then pass axi lite write bus to DMARC reset bit
                elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                    dmacr_i(DMACR_SYNCEN_BIT)  <= axi2ip_wrdata(DMACR_SYNCEN_BIT);

                end if;
            end if;
        end process DS_DMACR_SYNCEN;
end generate DS_GEN_SYNCEN_BIT;



-- Dynamic Genlock Master mode therefore instantiate a register for sync enable.
DM_GEN_SYNCEN_BIT : if C_GENLOCK_MODE = 2 generate
begin
    DM_DMACR_SYNCEN : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' )then
                    dmacr_i(DMACR_SYNCEN_BIT)  <= '0';
                    --dmacr_i(DMACR_REPEAT_EN_BIT)  <= '1';
                    dmacr_i(DMACR_REPEAT_EN_BIT)  <= '0';	--CR 713581

                -- If DMACR Write then pass axi lite write bus to DMARC reset bit
                elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                    dmacr_i(DMACR_SYNCEN_BIT)  <= axi2ip_wrdata(DMACR_SYNCEN_BIT);
                    dmacr_i(DMACR_REPEAT_EN_BIT)  <= axi2ip_wrdata(DMACR_REPEAT_EN_BIT);

                end if;
            end if;
        end process DM_DMACR_SYNCEN;
end generate DM_GEN_SYNCEN_BIT;








-- Genlock Slave mode therefore instantiate a register for sync enable.
GEN_SYNCEN_BIT : if C_GENLOCK_MODE = 1 generate
begin
    DMACR_SYNCEN : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' )then
                    dmacr_i(DMACR_SYNCEN_BIT)  <= '0';

                -- If DMACR Write then pass axi lite write bus to DMARC reset bit
                elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                    dmacr_i(DMACR_SYNCEN_BIT)  <= axi2ip_wrdata(DMACR_SYNCEN_BIT);

                end if;
            end if;
        end process DMACR_SYNCEN;
end generate GEN_SYNCEN_BIT;

-- Genlock Master mode therefore make DMACR.SyncEn bit RO and set to zero
GEN_NOSYNCEN_BIT : if C_GENLOCK_MODE = 0 generate
begin
    dmacr_i(DMACR_SYNCEN_BIT)  <= '0';

    M_DMACR_REPEAT_EN : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' )then
                    --dmacr_i(DMACR_REPEAT_EN_BIT)  <= '1';
                    dmacr_i(DMACR_REPEAT_EN_BIT)  <= '0';	-- CR 713581

                -- If DMACR Write then pass axi lite write bus to DMACR bit
                elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                    dmacr_i(DMACR_REPEAT_EN_BIT)  <= axi2ip_wrdata(DMACR_REPEAT_EN_BIT);

                end if;
            end if;
        end process M_DMACR_REPEAT_EN;



end generate GEN_NOSYNCEN_BIT;



-------------------------------------------------------------------------------
-- DMACR - Reset Bit
-------------------------------------------------------------------------------
DMACR_RESET : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(soft_reset_clr = '1')then
                dmacr_i(DMACR_RESET_BIT)  <= '0';

            -- If DMACR Write then pass axi lite write bus to DMARC reset bit
            elsif(soft_reset_i = '0' and axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_RESET_BIT)  <= axi2ip_wrdata(DMACR_RESET_BIT);

            end if;
        end if;
    end process DMACR_RESET;

soft_reset_i <= dmacr_i(DMACR_RESET_BIT);

-------------------------------------------------------------------------------
-- Circular Buffere/ Park Enable
-------------------------------------------------------------------------------
DMACR_TAILPTREN : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_CRCLPRK_BIT)  <= '1';

            -- If DMACR Write then pass axi lite write bus to DMARC tailptr en bit
            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_CRCLPRK_BIT)  <= axi2ip_wrdata(DMACR_CRCLPRK_BIT);

            end if;
        end if;
    end process DMACR_TAILPTREN;

-------------------------------------------------------------------------------
-- DMACR - Run/Stop Bit
-------------------------------------------------------------------------------
run_stop_clr   <= '1' when (stop_dma = '1')                     -- Stop due to error/rs clear
                        or (soft_reset_i = '1')                 -- Soft Reset
                        or (dmacr_i(DMACR_FRMCNTEN_BIT) = '1'   -- Frame Count Enable
                            and ioc_irq_set = '1')              -- and threshold met


             else '0';

DMACR_RUNSTOP : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dmacr_i(DMACR_RS_BIT)  <= '0';
            -- Clear on sg error (i.e. error) or dma error or soft reset
            elsif(run_stop_clr = '1')then
                dmacr_i(DMACR_RS_BIT)  <= '0';
            elsif(axi2ip_wrce(DMACR_INDEX) = '1')then
                dmacr_i(DMACR_RS_BIT)  <= axi2ip_wrdata(DMACR_RS_BIT);
            end if;
        end if;
    end process DMACR_RUNSTOP;

---------------------------------------------------------------------------
-- DMA Status Halted bit (BIT 0) - Set by dma controller indicating DMA
-- channel is halted.
---------------------------------------------------------------------------
DMASR_HALTED : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or halted_set = '1')then
                halted <= '1';
            elsif(halted_clr = '1')then
                halted <= '0';
            end if;
        end if;
    end process DMASR_HALTED;

---------------------------------------------------------------------------
-- DMA Status Idle bit (BIT 1) - Set by dma controller indicating DMA
-- channel is IDLE waiting at tail pointer.  Update of Tail Pointer
-- will cause engine to resume.  Note: Halted channels return to a
-- reset condition.
---------------------------------------------------------------------------
GEN_FOR_SG : if C_INCLUDE_SG = 1 generate
begin
    DMASR_IDLE : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0'
                or idle_clr = '1'
                or halted_set = '1')then
                    idle   <= '0';

                elsif(idle_set = '1')then
                    idle   <= '1';
                end if;
            end if;
        end process DMASR_IDLE;
end generate GEN_FOR_SG;
--  CR588712 - Hard code Idle to 0 when Scatter Gather engine not included
GEN_NO_SG : if C_INCLUDE_SG = 0 generate
begin
    idle <= '0';
end generate GEN_NO_SG;

---------------------------------------------------------------------------
-- DMA Status Error bit (BIT 3)
-- Note: any error will cause entire engine to halt
---------------------------------------------------------------------------

MM2S_ERR_FOR_IRQ : if  C_CHANNEL_IS_MM2S = 1 generate
begin

err  <= dma_interr
            or lsize_err
            or lsize_more_err
            or dma_slverr
            or dma_decerr
            or sg_slverr
            or sg_decerr;


FRMSTR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' )then
                    frm_store_i           <= (others => '0');
--            elsif(err = '1')then
--                    frm_store_i           <= frm_store_i;
            elsif(err = '0')then
                    frm_store_i           <= new_frmstr;
            end if;
        end if;
    end process FRMSTR_REGISTER;



end generate MM2S_ERR_FOR_IRQ;



S2MM_ERR_FOR_IRQ : if  C_CHANNEL_IS_MM2S = 0 generate
begin

err_p  <= dma_interr
            or lsize_err
            or lsize_more_err
            or dma_slverr
            or dma_decerr
            or sg_slverr
            or sg_decerr;



err  <= dma_interr_minus_frame_errors
            or (fsize_err                       and not dma_irq_mask_i(0))
            or (lsize_err                       and not dma_irq_mask_i(1))
            or (s2mm_fsize_more_or_sof_late_bit and not dma_irq_mask_i(2))
            or (lsize_more_err                  and not dma_irq_mask_i(3))
            or dma_slverr
            or dma_decerr
            or sg_slverr
            or sg_decerr;

FRMSTR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' )then
                    frm_store_i           <= (others => '0');
--            elsif(err = '1')then
--                    frm_store_i           <= frm_store_i;
            elsif(err_p = '0')then
                    frm_store_i           <= new_frmstr;
            end if;
        end if;
    end process FRMSTR_REGISTER;


    DMAINTERR_MINUS_FRAME_ERRORS : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    dma_interr_minus_frame_errors <= '0';

                elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                    dma_interr_minus_frame_errors <= (dma_interr_minus_frame_errors and not(axi2ip_wrdata(DMASR_DMAINTERR_BIT)))
                                 or dma_interr_set_minus_frame_errors;

                elsif(dma_interr_set_minus_frame_errors = '1' )then
                    dma_interr_minus_frame_errors <= '1';
                end if;
            end if;
        end process DMAINTERR_MINUS_FRAME_ERRORS;




end generate S2MM_ERR_FOR_IRQ;

-- Scatter Gather Error
sg_ftch_err <= ftch_slverr_set or ftch_decerr_set;

---------------------------------------------------------------------------
-- DMA Status DMA Internal Error bit (BIT 4)
---------------------------------------------------------------------------
-- If flush on frame sync disable then only reset will clear bit
GEN_FOR_NO_FLUSH : if C_ENABLE_FLUSH_ON_FSYNC = 0 generate
begin
    ----DMASR_DMAINTERR : process(prmry_aclk)
    ----    begin
    ----        if(prmry_aclk'EVENT and prmry_aclk = '1')then
    ----            if(prmry_resetn = '0')then
    ----                dma_interr <= '0';
    ----            elsif(dma_interr_set = '1' )then
    ----                dma_interr <= '1';
    ----            end if;
    ----        end if;
    ----    end process DMASR_DMAINTERR;

    DMASR_FSIZEERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    fsize_err <= '0';
                elsif(fsize_mismatch_err = '1' )then
                    fsize_err <= '1';
                end if;
            end if;
        end process DMASR_FSIZEERR;


----    DMASR_LSIZE_ERR : process(prmry_aclk)
----        begin
----            if(prmry_aclk'EVENT and prmry_aclk = '1')then
----                if(prmry_resetn = '0')then
----                    lsize_err <= '0';
----                elsif(lsize_mismatch_err = '1' )then
----                    lsize_err <= '1';
----                end if;
----            end if;
----        end process DMASR_LSIZE_ERR;
----
----    DMASR_LSIZE_MORE_ERR : process(prmry_aclk)
----        begin
----            if(prmry_aclk'EVENT and prmry_aclk = '1')then
----                if(prmry_resetn = '0')then
----                    lsize_more_err <= '0';
----                elsif(lsize_more_mismatch_err = '1' )then
----                    lsize_more_err <= '1';
----                end if;
----            end if;
----        end process DMASR_LSIZE_MORE_ERR;

end generate GEN_FOR_NO_FLUSH;

-- Flush on frame sync enabled therefore can clear with a write of '1'
GEN_FOR_FLUSH : if C_ENABLE_FLUSH_ON_FSYNC = 1 generate
begin
   ---- DMASR_DMAINTERR : process(prmry_aclk)
   ----     begin
   ----         if(prmry_aclk'EVENT and prmry_aclk = '1')then
   ----             if(prmry_resetn = '0')then
   ----                 dma_interr <= '0';

   ----             -- CPU Writing a '1' to clear - OR'ed with setting to prevent
   ----             -- missing a 'set' during the write.
   ----             elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

   ----                 dma_interr <= (dma_interr and not(axi2ip_wrdata(DMASR_DMAINTERR_BIT)))
   ----                              or dma_interr_set;

   ----             elsif(dma_interr_set = '1' )then
   ----                 dma_interr <= '1';
   ----             end if;
   ----         end if;
   ----     end process DMASR_DMAINTERR;


    DMASR_FSIZEERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    fsize_err <= '0';

                -- CPU Writing a '1' to clear - OR'ed with setting to prevent
                -- missing a 'set' during the write.
                elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                    fsize_err <= (fsize_err and not(axi2ip_wrdata(DMASR_FSIZEERR_BIT)))
                                 or fsize_mismatch_err;

                elsif(fsize_mismatch_err = '1' )then
                    fsize_err <= '1';
                end if;
            end if;
        end process DMASR_FSIZEERR;


    DMASR_FSIZE_MORE_OR_SOF_LATE_ERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    s2mm_fsize_more_or_sof_late_bit <= '0';

                -- CPU Writing a '1' to clear - OR'ed with setting to prevent
                -- missing a 'set' during the write.
                elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                    s2mm_fsize_more_or_sof_late_bit <= (s2mm_fsize_more_or_sof_late_bit and not(axi2ip_wrdata(DMASR_FSIZE_MORE_OR_SOF_LATE_ERR_BIT)))
                                 or s2mm_fsize_more_or_sof_late;

                elsif(s2mm_fsize_more_or_sof_late = '1' )then
                    s2mm_fsize_more_or_sof_late_bit <= '1';
                end if;
            end if;
        end process DMASR_FSIZE_MORE_OR_SOF_LATE_ERR;

end generate GEN_FOR_FLUSH;


    DMASR_LSIZE_ERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    lsize_err <= '0';

                -- CPU Writing a '1' to clear - OR'ed with setting to prevent
                -- missing a 'set' during the write.
                elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                    lsize_err <= (lsize_err and not(axi2ip_wrdata(DMASR_LSIZEERR_BIT)))
                                 or lsize_mismatch_err;

                elsif(lsize_mismatch_err = '1' )then
                    lsize_err <= '1';
                end if;
            end if;
        end process DMASR_LSIZE_ERR;

    DMASR_LSIZE_MORE_ERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    lsize_more_err <= '0';

                -- CPU Writing a '1' to clear - OR'ed with setting to prevent
                -- missing a 'set' during the write.
                elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                    lsize_more_err <= (lsize_more_err and not(axi2ip_wrdata(DMASR_LSIZE_MORE_ERR_BIT)))
                                 or lsize_more_mismatch_err;

                elsif(lsize_more_mismatch_err = '1' )then
                    lsize_more_err <= '1';
                end if;
            end if;
        end process DMASR_LSIZE_MORE_ERR;

    DMASR_DMAINTERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    dma_interr <= '0';

                -- CPU Writing a '1' to clear - OR'ed with setting to prevent
                -- missing a 'set' during the write.
                elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                    dma_interr <= (dma_interr and not(axi2ip_wrdata(DMASR_DMAINTERR_BIT)))
                                 or dma_interr_set;

                elsif(dma_interr_set = '1' )then
                    dma_interr <= '1';
                end if;
            end if;
        end process DMASR_DMAINTERR;



---------------------------------------------------------------------------
-- DMA Status DMA Slave Error bit (BIT 5)
---------------------------------------------------------------------------
DMASR_DMASLVERR : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dma_slverr <= '0';

            elsif(dma_slverr_set = '1' )then
                dma_slverr <= '1';

            end if;
        end if;
    end process DMASR_DMASLVERR;

---------------------------------------------------------------------------
-- DMA Status DMA Decode Error bit (BIT 6)
---------------------------------------------------------------------------
DMASR_DMADECERR : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dma_decerr <= '0';

            elsif(dma_decerr_set = '1' )then
                dma_decerr <= '1';

            end if;
        end if;
    end process DMASR_DMADECERR;


---------------------------------------------------------------------------
-- DMA Status IOC Interrupt status bit (BIT 11)
---------------------------------------------------------------------------
DMASR_IOCIRQ : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                ioc_irq <= '0';

            -- CPU Writing a '1' to clear - OR'ed with setting to prevent
            -- missing a 'set' during the write.
            elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                ioc_irq <= (ioc_irq and not(axi2ip_wrdata(DMASR_IOCIRQ_BIT)))
                             or ioc_irq_set;

            elsif(ioc_irq_set = '1')then
                ioc_irq <= '1';

            end if;
        end if;
    end process DMASR_IOCIRQ;

---------------------------------------------------------------------------
-- DMA Status Delay Interrupt status bit (BIT 12)
---------------------------------------------------------------------------
DMASR_DLYIRQ : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                dly_irq <= '0';

            -- CPU Writing a '1' to clear - OR'ed with setting to prevent
            -- missing a 'set' during the write.
            elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                dly_irq <= (dly_irq and not(axi2ip_wrdata(DMASR_DLYIRQ_BIT)))
                             or dly_irq_set;

            elsif(dly_irq_set = '1')then
                dly_irq <= '1';

            end if;
        end if;
    end process DMASR_DLYIRQ;

-- Disable delay timer if halted or on delay irq set
dlyirq_dsble    <= dmasr_i(DMASR_HALTED_BIT) or dmasr_i(DMASR_DLYIRQ_BIT)
                   or fsync_mask;   -- CR 578591

---------------------------------------------------------------------------
-- DMA Status Error Interrupt status bit (BIT 12)
---------------------------------------------------------------------------
-- Delay error setting for generation of error strobe
GEN_ERR_RE : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                err_d1 <= '0';
            else
                err_d1 <= err;
            end if;
        end if;
    end process GEN_ERR_RE;

-- Generate rising edge pulse on error
err_re   <= err and not err_d1;
--err_fe   <= not err and err_d1;

DMASR_ERRIRQ : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                err_irq <= '0';

            -- CPU Writing a '1' to clear - OR'ed with setting to prevent
            -- missing a 'set' during the write.
            elsif(axi2ip_wrce(DMASR_INDEX) = '1' )then

                err_irq <= (err_irq and not(axi2ip_wrdata(DMASR_ERRIRQ_BIT)))
                             or err_re;

            elsif(err_re = '1')then
                err_irq <= '1';

            end if;
        end if;
    end process DMASR_ERRIRQ;

---------------------------------------------------------------------------
-- DMA Interrupt OUT
---------------------------------------------------------------------------
REG_INTR : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0' or soft_reset_i = '1')then
                introut <= '0';
            else
                introut <= (dly_irq and dmacr_i(DMACR_DLY_IRQEN_BIT))
                        or (ioc_irq and dmacr_i(DMACR_IOC_IRQEN_BIT))
                        or (err_irq and dmacr_i(DMACR_ERR_IRQEN_BIT));
            end if;
        end if;
    end process;

---------------------------------------------------------------------------
-- DMA Status Register
---------------------------------------------------------------------------
dmasr_i    <=  irqdelay_status    -- Bits 31 downto 24
                    & irqthresh_status -- Bits 23 downto 16
                    & lsize_more_err              -- Bit  15
                    & err_irq          -- Bit  14
                    & dly_irq          -- Bit  13
                    & ioc_irq          -- Bit  12
                    & s2mm_fsize_more_or_sof_late_bit              -- Bit  11
                    & sg_decerr        -- Bit  10
                    & sg_slverr        -- Bit  9
                    & lsize_err              -- Bit  8
                    & fsize_err              -- Bit  7
                    & dma_decerr       -- Bit  6
                    & dma_slverr       -- Bit  5
                    & dma_interr       -- Bit  4
                    & '0'              -- Bit  3
                    & '0'              -- Bit  2
                    & idle             -- Bit  1
                    & halted;          -- Bit  0




-------------------------------------------------------------------------------
-- Frame Store Pointer Field - Reference of current frame buffer pointer being
-- used.
-------------------------------------------------------------------------------
----FRMSTR_REGISTER : process(prmry_aclk)
----    begin
----        if(prmry_aclk'EVENT and prmry_aclk = '1')then
----            --if(prmry_resetn = '0' or err_fe = '1')then
----            if(prmry_resetn = '0' )then
----                frm_store           <= (others => '0');
----                err_frmstore_set  <= '0';
----            -- Detected error has NOT register a desc pointer
----            elsif(err_frmstore_set = '0')then
----
----                -- CR582182 qualified with update_frmstore
----                -- DMA Error Error
----                if(update_frmstore = '1' and err = '1')then
----                    frm_store           <= frmstr_err_addr;
----                    err_frmstore_set  <= '1';
----
----                -- CR582182 qualified with update_frmstore
----                -- Commanded to update frame store value - used for indicating
----                -- current frame begin processed by dma controller
----                elsif(update_frmstore = '1' and dmacr_i(DMACR_RS_BIT)  = '1')then
----                    frm_store           <= new_frmstr;
----                    err_frmstore_set  <= err_frmstore_set;
----
----                end if;
----            end if;
----        end if;
----    end process FRMSTR_REGISTER;

-- If SG engine is included then instantiate sg specific logic
GEN_SCATTER_GATHER_MODE : if C_INCLUDE_SG = 1 generate

    reg_index_i      <= (others => '0'); -- Not used in SCATTER GATHER mode


    ---------------------------------------------------------------------------
    -- DMA Status SG Slave Error bit (BIT 9)
    ---------------------------------------------------------------------------
    DMASR_SGSLVERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    sg_slverr <= '0';

                elsif(ftch_slverr_set = '1')then
                    sg_slverr <= '1';

                end if;
            end if;
        end process DMASR_SGSLVERR;

    ---------------------------------------------------------------------------
    -- DMA Status SG Decode Error bit (BIT 10)
    ---------------------------------------------------------------------------
    DMASR_SGDECERR : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    sg_decerr <= '0';

                elsif(ftch_decerr_set = '1')then
                    sg_decerr <= '1';

                end if;
            end if;
        end process DMASR_SGDECERR;

    ---------------------------------------------------------------------------
    -- Current Descriptor LSB Register
    ---------------------------------------------------------------------------
    CURDESC_LSB_REGISTER : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    curdesc_lsb_i   <= (others => '0');
                    err_pointer_set   <= '0';

                -- Detected error has NOT register a desc pointer
                elsif(err_pointer_set = '0')then

                    -- Scatter Gather Fetch Error
                    if(sg_ftch_err = '1')then
                        curdesc_lsb_i <= ftch_err_addr(CURDESC_LOWER_MSB_BIT -- Curdesc  bit 31 downto
                                                  downto CURDESC_LOWER_LSB_BIT)-- Curdesc  bit 5
                                       & "00000";                              -- Reserved bits 4 downto 0

                        err_pointer_set   <= '1';

                    -- Commanded to update descriptor value - used for indicating
                    -- current descriptor begin processed by dma controller
                    elsif(update_curdesc = '1' and dmacr_i(DMACR_RS_BIT)  = '1')then
                        curdesc_lsb_i   <= new_curdesc(CURDESC_LOWER_MSB_BIT  -- Curdesc  bit 31 downto
                                                downto CURDESC_LOWER_LSB_BIT)   -- Curdesc  bit 5
                                       & "00000";                               -- Reserved bit 4 downto 0

                        err_pointer_set <= err_pointer_set;

                    -- CPU update of current descriptor pointer.  CPU
                    -- only allowed to update when engine is halted.
                    elsif(axi2ip_wrce(CURDESC_LSB_INDEX) = '1' and dmasr_i(DMASR_HALTED_BIT) = '1')then
                        curdesc_lsb_i   <= axi2ip_wrdata(CURDESC_LOWER_MSB_BIT   -- Curdesc  bit 31 downto
                                                  downto CURDESC_LOWER_LSB_BIT)  -- Curdesc  bit 5
                                       & "00000";                                -- Reserved bit 4 downto 0

                        err_pointer_set <= err_pointer_set;

                    end if;
                end if;
            end if;
        end process CURDESC_LSB_REGISTER;


    ---------------------------------------------------------------------------
    -- Tail Descriptor LSB Register
    ---------------------------------------------------------------------------
    TAILDESC_LSB_REGISTER : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    taildesc_lsb_i  <= (others => '0');
                elsif(axi2ip_wrce(TAILDESC_LSB_INDEX) = '1')then
                    taildesc_lsb_i  <= axi2ip_wrdata(TAILDESC_LOWER_MSB_BIT
                                              downto TAILDESC_LOWER_LSB_BIT)
                                     & "00000";
                end if;
            end if;
        end process TAILDESC_LSB_REGISTER;

    ---------------------------------------------------------------------------
    -- Current Descriptor MSB Register
    ---------------------------------------------------------------------------
    -- Scatter Gather Interface configured for 64-Bit SG Addresses
    GEN_SG_ADDR_EQL64 :if C_M_AXI_SG_ADDR_WIDTH = 64 generate
    begin
        CURDESC_MSB_REGISTER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        curdesc_msb_i  <= (others => '0');

                    elsif(err_pointer_set = '0')then
                        -- Scatter Gather Fetch Error
                        if(sg_ftch_err = '1')then
                            curdesc_msb_i   <= ftch_err_addr((C_M_AXI_SG_ADDR_WIDTH
                                                - C_S_AXI_LITE_DATA_WIDTH)-1
                                                downto 0);

                        -- Commanded to update descriptor value - used for indicating
                        -- current descriptor begin processed by dma controller
                        elsif(update_curdesc = '1' and dmacr_i(DMACR_RS_BIT)  = '1')then
                            curdesc_msb_i <= new_curdesc
                                                ((C_M_AXI_SG_ADDR_WIDTH
                                                - C_S_AXI_LITE_DATA_WIDTH)-1
                                                downto 0);

                        -- CPU update of current descriptor pointer.  CPU
                        -- only allowed to update when engine is halted.
                        elsif(axi2ip_wrce(CURDESC_MSB_INDEX) = '1' and dmasr_i(DMASR_HALTED_BIT) = '1')then
                            curdesc_msb_i  <= axi2ip_wrdata;

                        end if;
                    end if;
                end if;
            end process CURDESC_MSB_REGISTER;

        ---------------------------------------------------------------------------
        -- Tail Descriptor MSB Register
        ---------------------------------------------------------------------------
        TAILDESC_MSB_REGISTER : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        taildesc_msb_i  <= (others => '0');
                    elsif(axi2ip_wrce(TAILDESC_MSB_INDEX) = '1')then
                        taildesc_msb_i  <= axi2ip_wrdata;
                    end if;
                end if;
            end process TAILDESC_MSB_REGISTER;

        end generate GEN_SG_ADDR_EQL64;

    -- Scatter Gather Interface configured for 32-Bit SG Addresses
    GEN_SG_ADDR_EQL32 : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
    begin
        curdesc_msb_i  <= (others => '0');
        taildesc_msb_i <= (others => '0');
    end generate GEN_SG_ADDR_EQL32;


    -- Scatter Gather Interface configured for 32-Bit SG Addresses
    GEN_TAILUPDATE_EQL32 : if C_M_AXI_SG_ADDR_WIDTH = 32 generate
    begin
        TAILPNTR_UPDT_PROCESS : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0' or dmacr_i(DMACR_RS_BIT)='0')then
                        tailpntr_updated    <= '0';
                    elsif(axi2ip_wrce(TAILDESC_LSB_INDEX) = '1')then
                        tailpntr_updated    <= '1';
                    else
                        tailpntr_updated    <= '0';
                    end if;
                end if;
            end process TAILPNTR_UPDT_PROCESS;


    end generate GEN_TAILUPDATE_EQL32;

    -- Scatter Gather Interface configured for 64-Bit SG Addresses
    GEN_TAILUPDATE_EQL64 : if C_M_AXI_SG_ADDR_WIDTH = 64 generate
    begin
        TAILPNTR_UPDT_PROCESS : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0' or dmacr_i(DMACR_RS_BIT)='0')then
                        tailpntr_updated    <= '0';
                    elsif(axi2ip_wrce(TAILDESC_MSB_INDEX) = '1')then
                        tailpntr_updated    <= '1';
                    else
                        tailpntr_updated    <= '0';
                    end if;
                end if;
            end process TAILPNTR_UPDT_PROCESS;

    end generate GEN_TAILUPDATE_EQL64;


end generate GEN_SCATTER_GATHER_MODE;

-- If SG engine is not included then instantiate register direct mode
GEN_NO_SCATTER_GATHER_MODE : if C_INCLUDE_SG = 0 generate
begin
    -- Tie off unused scatter gather specific signals
    sg_decerr           <= '0';             -- Not used in Register Direct Mode
    sg_slverr           <= '0';             -- Not used in Register Direct Mode
    curdesc_lsb_i       <= (others => '0'); -- Not used in Register Direct Mode
    curdesc_msb_i       <= (others => '0'); -- Not used in Register Direct Mode
    taildesc_lsb_i      <= (others => '0'); -- Not used in Register Direct Mode
    taildesc_msb_i      <= (others => '0'); -- Not used in Register Direct Mode
    tailpntr_updated    <= '0';             -- Not used in Register Direct Mode


 GEN_NO_REG_INDEX_REG : if C_NUM_FSTORES < 17 generate
 begin
    reg_index_i      <= (others => '0'); -- Not used if C_NUM_FSTORE =< 16

 end generate GEN_NO_REG_INDEX_REG;


 GEN_REG_INDEX_REG : if C_NUM_FSTORES > 16 generate
 begin
        ---------------------------------------------------------------------------
        --  Reg Index
        ---------------------------------------------------------------------------
        reg_index : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_index_i  <= (others => '0');
                    elsif(axi2ip_wrce(REG_IND) = '1')then
                        reg_index_i(0)  <= axi2ip_wrdata(0);
                    end if;
                end if;
            end process reg_index;


 end generate GEN_REG_INDEX_REG;



end generate GEN_NO_SCATTER_GATHER_MODE;



---------------------------------------------------------------------------
-- Number of Frame Stores
---------------------------------------------------------------------------


ENABLE_NUM_FRMSTR_REGISTER : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_5 = 1 or C_ENABLE_DEBUG_ALL = 1) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_13 = 1 or C_ENABLE_DEBUG_ALL = 1) ))generate
begin



NUM_FRMSTR_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                num_frame_store_i  <= std_logic_vector(to_unsigned(C_NUM_FSTORES,NUM_FRM_STORE_WIDTH));
            elsif(axi2ip_wrce(FRAME_STORE_INDEX) = '1')then

                -- If value is 0 then set frame store to 1
                if(frmstore_is_zero='1')then
                    num_frame_store_i   <= ONE_FRAMESTORE;
                else
                    num_frame_store_i   <= axi2ip_wrdata(FRMSTORE_MSB_BIT
                                                  downto FRMSTORE_LSB_BIT);
                end if;
            end if;
        end if;
    end process NUM_FRMSTR_REGISTER;

frmstore_is_zero <= '1' when axi2ip_wrdata(FRMSTORE_MSB_BIT
                                    downto FRMSTORE_LSB_BIT) = ZERO_FRAMESTORE
                else '0';

num_frame_store_regmux_i <= num_frame_store_i;

end generate ENABLE_NUM_FRMSTR_REGISTER;


DISABLE_NUM_FRMSTR_REGISTER : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_5 = 0 and C_ENABLE_DEBUG_ALL = 0) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_13 = 0 and C_ENABLE_DEBUG_ALL = 0) ))generate
begin

                num_frame_store_i  <= std_logic_vector(to_unsigned(C_NUM_FSTORES,NUM_FRM_STORE_WIDTH));

		num_frame_store_regmux_i <= (others => '0');

end generate DISABLE_NUM_FRMSTR_REGISTER;



---------------------------------------------------------------------------
-- Line Buffer Threshold
---------------------------------------------------------------------------




ENABLE_LB_THRESH_REGISTER : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_1 = 1 or C_ENABLE_DEBUG_ALL = 1) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_9 = 1 or C_ENABLE_DEBUG_ALL = 1) ))generate
begin

LB_THRESH_REGISTER : process(prmry_aclk)
    begin
        if(prmry_aclk'EVENT and prmry_aclk = '1')then
            if(prmry_resetn = '0')then
                linebuf_threshold_i  <= std_logic_vector(to_unsigned(C_LINEBUFFER_THRESH,LINEBUFFER_THRESH_WIDTH));
            elsif(axi2ip_wrce(THRESHOLD_INDEX) = '1')then
                linebuf_threshold_i  <= axi2ip_wrdata(THRESH_MSB_BIT
                                              downto THRESH_LSB_BIT);
            end if;
        end if;
    end process LB_THRESH_REGISTER;

end generate ENABLE_LB_THRESH_REGISTER;
  

DISABLE_LB_THRESH_REGISTER : if ((C_CHANNEL_IS_MM2S = 1 and (C_ENABLE_DEBUG_INFO_1 = 0 and C_ENABLE_DEBUG_ALL = 0) ) or (C_CHANNEL_IS_MM2S = 0 and (C_ENABLE_DEBUG_INFO_9 = 0 and C_ENABLE_DEBUG_ALL = 0) ))generate
begin

             linebuf_threshold_i  <= (others => '0');

end generate DISABLE_LB_THRESH_REGISTER;
  

DMA_IRQ_MASK_GEN : if  C_CHANNEL_IS_MM2S = 0 generate
begin

        ---------------------------------------------------------------------------
        --  S2MM DMA IRQ MASK
        ---------------------------------------------------------------------------
        dma_irq_mask : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        dma_irq_mask_i  <= (others => '0');
                    elsif(axi2ip_wrce(DMA_IRQ_MASK_IND) = '1')then
                        dma_irq_mask_i(3 downto 0)  <= axi2ip_wrdata(3 downto 0);
                    end if;
                end if;
            end process dma_irq_mask;

end generate DMA_IRQ_MASK_GEN;

NO_DMA_IRQ_MASK_GEN : if  C_CHANNEL_IS_MM2S = 1 generate
begin

                        dma_irq_mask_i  <= (others => '0');

end generate NO_DMA_IRQ_MASK_GEN;



end implementation;
