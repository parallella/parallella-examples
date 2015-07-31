-------------------------------------------------------------------------------
-- axi_vdma_genlock_mngr
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
-- Filename:        axi_vdma_genlock_mngr.vhd
--
-- Description:     This entity encompasses the Gen Lock Manager
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-- Structure:
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

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;

library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.clog2;
use lib_pkg_v1_0.lib_pkg.max2;

-------------------------------------------------------------------------------
entity  axi_vdma_genlock_mngr is
    generic(
        C_GENLOCK_MODE          	: integer range 0 to 3      := 0                ;
            -- Specifies Gen-Lock Mode of operation
            -- 0 = Master - Channel configured to be Gen-Lock Master
            -- 1 = Slave - Channel configured to be Gen-Lock Slave

        C_GENLOCK_NUM_MASTERS   	: integer range 1 to 16     := 1                ;
            -- Number of Gen-Lock masters capable of controlling Gen-Lock Slave

        C_INTERNAL_GENLOCK_ENABLE   	: integer range 0 to 1  := 0                ;
            -- Enable internal genlock bus
            -- 0 = disable internal genlock bus
            -- 1 = enable internal genlock bus

        C_NUM_FSTORES           	: integer range 1 to 32     := 5
            -- Number of Frame Stores
    );
    port (

        -- Secondary Clock Domain
        prmry_aclk              : in  std_logic                                     ;       --
        prmry_resetn            : in  std_logic                                     ;       --
                                                                                            --
        -- Dynamic Frame Store Support                                                      --
        num_frame_store         : in  std_logic_vector                                      --
                                    (NUM_FRM_STORE_WIDTH-1 downto 0)                ;       --
        num_fstore_minus1       : in  std_logic_vector                                      --
                                    (FRAME_NUMBER_WIDTH-1 downto 0)                 ;       --
                                                                                            --
        -- Gen-Lock Slave Signals                                                           --
        mstr_in_control         : in  std_logic_vector(3 downto 0)                  ;       --
        genlock_select          : in  std_logic                                     ;       --
        frame_ptr_in            : in  std_logic_vector                                      --
                                    ((C_GENLOCK_NUM_MASTERS                                 --
                                    *NUM_FRM_STORE_WIDTH)-1 downto 0)               ;       --
        internal_frame_ptr_in   : in  std_logic_vector                                      --
                                    (NUM_FRM_STORE_WIDTH-1 downto 0)                ;       --
        slv_frame_ref_out       : out std_logic_vector                                      --
                                    (FRAME_NUMBER_WIDTH-1 downto 0)                 ;       --
        fsize_mismatch_err_flag : in std_logic                                      ;               
                                                                                            --
        -- Gen-Lock Master Signals                                                          --
        dmasr_halt              : in  std_logic                                     ;       --
        circular_prk_mode       : in  std_logic                                     ;       --
        mstr_frame_update       : in  std_logic                                     ;       --
        mstr_frame_ref_in       : in  std_logic_vector                                      --
                                    (FRAME_NUMBER_WIDTH-1 downto 0)                 ;       --
        mstrfrm_tstsync_out     : out std_logic                                     ;       --
        frame_ptr_out           : out std_logic_vector                                      --
                                    (NUM_FRM_STORE_WIDTH-1 downto 0)                        --
    );
end axi_vdma_genlock_mngr;

-------------------------------------------------------------------------------
-- Architecture
-------------------------------------------------------------------------------
architecture implementation of axi_vdma_genlock_mngr is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-------------------------------------------------------------------------------
-- Functions
-------------------------------------------------------------------------------

-- No Functions Declared

-------------------------------------------------------------------------------
-- Constants Declarations
-------------------------------------------------------------------------------
-- Zero vector for tying off unused inputs
constant ZERO_VALUE         	: std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0) := (others => '0');

-- Number of bits to analyze for grey code enconding and decoding
 constant GREY_NUM_BITS   	: integer := max2(1,clog2(C_NUM_FSTORES));


-------------------------------------------------------------------------------
-- Signal / Type Declarations
-------------------------------------------------------------------------------
-- Slave only signals
signal grey_frame_ptr           : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)  := (others => '0');
signal grey_frmstr_adjusted     : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)  := (others => '0');
signal partial_frame_ptr        : std_logic_vector(GREY_NUM_BITS-1 downto 0)        := (others => '0');
signal padded_partial_frame_ptr : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');

-- Master and Slave signals
signal s_binary_frame_ptr      : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal ds_binary_frame_ptr      : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal dm_binary_frame_ptr      : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal binary_frame_ptr         : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal raw_frame_ptr            : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal rvc_frame_ref_in         : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal dm_inv_raw_frame_ptr     : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal s_inv_raw_frame_ptr     : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal ds_inv_raw_frame_ptr     : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal inv_raw_frame_ptr        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal reg_raw_frame_ptr        : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal grey_frame_ptr_out       : std_logic_vector(FRAME_NUMBER_WIDTH-1 downto 0)   := (others => '0');
signal s_frame_ptr_out          : std_logic_vector(NUM_FRM_STORE_WIDTH-1 downto 0)  := (others => '0');
signal num_fstore_equal_one     : std_logic := '0';

signal dm_mstr_reverse_order    : std_logic := '0';
signal dm_mstr_reverse_order_d1 : std_logic := '0';
signal s_mstr_reverse_order    : std_logic := '0';
signal ds_mstr_reverse_order    : std_logic := '0';
signal s_mstr_reverse_order_d1 : std_logic := '0';
signal ds_mstr_reverse_order_d1 : std_logic := '0';
signal mstr_reverse_order       : std_logic := '0';
signal mstr_reverse_order_d1    : std_logic := '0';
signal mstr_reverse_order_d2    : std_logic := '0';

-- Test signals
signal mstrfrm_tstsync_d1       : std_logic := '0';
signal mstrfrm_tstsync_d2       : std_logic := '0';
signal mstrfrm_tstsync_d3       : std_logic := '0';
signal mstrfrm_tstsync_d4       : std_logic := '0';

-------------------------------------------------------------------------------
-- Begin architecture logic
-------------------------------------------------------------------------------
begin

-- Number of fstore value set in register is 0x01.
num_fstore_equal_one <= '1' when num_fstore_minus1 = ZERO_VALUE(FRAME_NUMBER_WIDTH-1 downto 0)
                   else '0';



-------------------------------------------------------------------------------
-- Generate genlock decoding logic for slave
-------------------------------------------------------------------------------
GENLOCK_FOR_SLAVE : if C_GENLOCK_MODE = 1 generate
begin


-----------------------------------------------------------------------------------------------------------------------------------
    --Output GenLock Slave's working frame number in grey
-----------------------------------------------------------------------------------------------------------------------------------

    -- Create flag to indicate when to reverse frame order for genlock output
    -- 0= normal frame order, 1= reverse frame order
    RVRS_ORDER_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                --if(prmry_resetn = '0' )then
                    mstr_reverse_order  <= '1';

                -- On update if at frame 0 then toggle reverse order flag.
                -- Do not toggle flag if in park mode.
                elsif(fsize_mismatch_err_flag = '0' and mstr_frame_update = '1' and mstr_frame_ref_in = num_fstore_minus1
                and circular_prk_mode = '1')then
                    mstr_reverse_order  <=  not mstr_reverse_order; -- toggle reverse flag

                end if;
            end if;
        end process RVRS_ORDER_FLAG;

    -- Register reverse flag twice to align flag with phase 4 grey encoded tag
    -- process
    REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstr_reverse_order_d1 <= '1';
                    mstr_reverse_order_d2 <= '1';
                else
                    mstr_reverse_order_d1 <= mstr_reverse_order;
                    mstr_reverse_order_d2 <= mstr_reverse_order_d1;
                end if;
            end if;
        end process REG_DELAY_FLAG;

    -- For FSTORE > 1 then gray coding is needed for proper clock crossing
    -- in Gen-Lock slave. (CR578234 - added generate for fstores > 1)
    GEN_FSTORES_GRTR_ONE : if C_NUM_FSTORES > 1 generate
    begin
        ---------------------------------------------------------------------------
        -- Phase 1: Based on reverse order flag convert master frame in into a
        -- reverse order frame number (i.e. 3,2,1,0)
        -- or normal order (i.e. 0,1,2,3)
        ---------------------------------------------------------------------------

        --rvc_frame_ref_in <= std_logic_vector((C_NUM_FSTORES - 1) - unsigned(mstr_frame_ref_in));
        rvc_frame_ref_in <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(mstr_frame_ref_in));

        FRAME_CONVERT_P1 : process(mstr_reverse_order,mstr_frame_ref_in,rvc_frame_ref_in,num_fstore_equal_one)
            begin
                if(mstr_reverse_order = '1' and num_fstore_equal_one = '0')then
                    raw_frame_ptr <= rvc_frame_ref_in;
                else
                    raw_frame_ptr <= mstr_frame_ref_in;
                end if;
            end process FRAME_CONVERT_P1;

        -- Register to break long timing paths
        REG_P1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_raw_frame_ptr <= (others => '0');
                    else
                        reg_raw_frame_ptr <= raw_frame_ptr;
                    end if;
                end if;
            end process REG_P1;


        ---------------------------------------------------------------------------
        -- Phase 2: Partial Invert of raw frame pointer (invert only the
        -- log2(C_NUM_FSTORE) bits
        -- GREY_NUM_BITS = 1 which is C_NUM_FSTORE = 1 to 2     then invert 1 LSB
        -- GREY_NUM_BITS = 2 which is C_NUM_FSTORE = 3 to 4,    then invert 2 LSBs
        -- GREY_NUM_BITS = 3 which is C_NUM_FSTORE = 5 to 8,    then invert 3 LSBs
        -- GREY_NUM_BITS = 4 which is C_NUM_FSTORE = 9 to 16,   then invert 4 LSBs
        -- GREY_NUM_BITS = 5 which is C_NUM_FSTORE = 17 to 32,  then invert 5 LSBs (all bits)
        ---------------------------------------------------------------------------
        -- CR604657 - shifted FSTORE 2 to the correct inverse
        PARTIAL_NOT_P2 : process(num_frame_store,reg_raw_frame_ptr)
            begin
                case num_frame_store is
                    -- Number of Frame Stores =  1 and 2
                    when "000001" | "000010" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  3 and 4
                    when "000011" | "000100" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  5, 6, 7, and 8
                    when "000101" | "000110" | "000111" | "001000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 9 to 16
                    when "001001" | "001010" | "001011" | "001100" | "001101"
                       | "001110" | "001111" | "010000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 17 to 32
                    when others =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= not reg_raw_frame_ptr(4);
                end case;
            end process PARTIAL_NOT_P2;


        -- Register pratial not to break timing paths
        REG_P2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        binary_frame_ptr <= (others => '0');
                    else
                        binary_frame_ptr <= inv_raw_frame_ptr;
                    end if;
                end if;
            end process REG_P2;


        ---------------------------------------------------------------------------
        -- Phase 3 : Grey Encode
        -- Encode binary coded frame pointer
        ---------------------------------------------------------------------------
        GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
            generic map(
                C_DWIDTH                    => FRAME_NUMBER_WIDTH
            )
            port map(
                -- Grey Encode
                binary_in                   => binary_frame_ptr             ,
                grey_out                    => grey_frame_ptr_out           ,

                -- Grey Decode
                grey_in                     => ZERO_VALUE(FRAME_NUMBER_WIDTH-1 downto 0)       ,
                binary_out                  => open
            );


        ---------------------------------------------------------------------------
        -- Phase 4 : Tag Grey Encoded Pointer
        -- Tag grey code with the inverse of the reverse flag.  This provides
        -- two sets of grey codes representing 2 passes through frame buffer.
        ---------------------------------------------------------------------------



        -- If C_NUM_FSTORES is 17 to 32 then all 5 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_5_BITS : if GREY_NUM_BITS = 5 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is

                        -- Number of Frame Stores = 1
                        when "000001" =>
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 2
                        when "000010" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 3 and 4
                        when "000011" | "000100" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 5 to 8
                        when "000101" | "000110" | "000111" | "001000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 9 to 16
                        when "001001" | "001010" | "001011" | "001100" | "001101"
                           | "001110" | "001111" | "010000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 17 to 32
                        when others =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= grey_frame_ptr_out(4);
                            s_frame_ptr_out(5)  <= not mstr_reverse_order_d2;
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_5_BITS;


        -- If C_NUM_FSTORES is 8 to 16 then all 4 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_4_BITS : if GREY_NUM_BITS = 4 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000101" | "000110" | "000111" | "001000" => -- 5, 6, 7, and 8
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 9 to 16
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_4_BITS;



        -- C_NUM_FSTORES = 4 to 7
        GEN_EQL_3_BITS : if GREY_NUM_BITS = 3 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 5 to 7
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_3_BITS;

        -- C_NUM_FSTORES = 3
        GEN_EQL_2_BITS : if GREY_NUM_BITS = 2 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 3
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_2_BITS;

        -- C_NUM_FSTORES = 2
        GEN_EQL_1_BITS : if GREY_NUM_BITS = 1 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_1_BITS;

    end generate GEN_FSTORES_GRTR_ONE;

    -- CR606861
    -- For FSTORE = 1 then gray coding is not needed.  Simply
    -- pass the reverse order flag out.
    -- (CR578234 - added generate for fstores = 1)
    GEN_FSTORES_EQL_ONE : if C_NUM_FSTORES = 1 generate
    begin

        s_frame_ptr_out <= "00000" & not(mstr_reverse_order_d2);


    end generate GEN_FSTORES_EQL_ONE;

    -- Register Master Frame Pointer Out
    REG_FRAME_PTR_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    frame_ptr_out <= (others => '0');
                else
                    frame_ptr_out <= s_frame_ptr_out;
                end if;
            end if;
        end process REG_FRAME_PTR_OUT;








-------------------------------------------------------------------------------------------------------------------


    -- Mux frame pointer in from Master based on master in control
    GENLOCK_MUX_I : entity  axi_vdma_v6_2.axi_vdma_genlock_mux
        generic map(
            C_GENLOCK_NUM_MASTERS       => C_GENLOCK_NUM_MASTERS    ,
            C_INTERNAL_GENLOCK_ENABLE   => C_INTERNAL_GENLOCK_ENABLE
        )
        port map(

            prmry_aclk              => prmry_aclk                   ,
            prmry_resetn            => prmry_resetn                 ,

            mstr_in_control         => mstr_in_control              ,
            genlock_select          => genlock_select               ,
            internal_frame_ptr_in   => internal_frame_ptr_in        ,
            frame_ptr_in            => frame_ptr_in                 ,
            frame_ptr_out           => grey_frame_ptr
        );

    ---------------------------------------------------------------------------
    -- Phase 1:
    -- Decode Grey coded frame pointer
    ---------------------------------------------------------------------------
    ADJUST_4_FRM_STRS : process(num_frame_store,grey_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1 and 2
                when "000001" | "000010" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= '0';
                    grey_frmstr_adjusted(2) <= '0';
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= '0';
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 5, 6, 7, and 8
                when "000101" | "000110" | "000111" | "001000" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= grey_frame_ptr(3);
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores =  17 to 32
                when others => -- 17 to 32
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= grey_frame_ptr(3);
                    grey_frmstr_adjusted(4) <= grey_frame_ptr(4);
                    grey_frmstr_adjusted(5) <= '0';

            end case;
        end process ADJUST_4_FRM_STRS;

    S_GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
        generic map(
            C_DWIDTH                    => GREY_NUM_BITS
        )
        port map(
            -- Grey Encode
            binary_in                   => ZERO_VALUE(GREY_NUM_BITS - 1 downto 0)       ,
            grey_out                    => open             ,

            -- Grey Decode
            grey_in                     => grey_frmstr_adjusted(GREY_NUM_BITS - 1 downto 0)    ,
            binary_out                  => partial_frame_ptr
        );

    ---------------------------------------------------------------------------
    -- Phase 2:
    -- Invert partial frame pointer and pad to full frame pointer width
    ---------------------------------------------------------------------------
    -- FSTORES = 1 or 2 therefore pad decoded frame pointer with 4 bits
    -- CR604657 - shifted FSTORE 2 case to the correct padding location
    GEN_FSTORES_12 : if C_NUM_FSTORES = 1 or C_NUM_FSTORES = 2 generate
    begin
        padded_partial_frame_ptr <= "0000" & partial_frame_ptr;
    end generate GEN_FSTORES_12;

    -- FSTORES = 3 or 4 therefore pad decoded frame pointer with 3 bits
    GEN_FSTORES_34 : if C_NUM_FSTORES > 2 and C_NUM_FSTORES < 5 generate
    begin
        padded_partial_frame_ptr <= "000" & partial_frame_ptr;
    end generate GEN_FSTORES_34;

    -- FSTORES = 5,6,7 or 8 therefore pad decoded frame pointer with 2 bit
    GEN_FSTORES_5678 : if C_NUM_FSTORES > 4 and C_NUM_FSTORES < 9 generate
    begin
        padded_partial_frame_ptr <= "00" & partial_frame_ptr;
    end generate GEN_FSTORES_5678;

    -- FSTORES = 9 to 16 therefore pad decoded frame pointer with 1 bit
    GEN_FSTORES_9TO16 : if C_NUM_FSTORES > 8 and C_NUM_FSTORES < 17 generate
    begin
        padded_partial_frame_ptr <= '0' & partial_frame_ptr;
    end generate GEN_FSTORES_9TO16;

    -- FSTORES > 16 therefore no need to pad decoded frame pointer
    GEN_FSTORES_17NUP : if C_NUM_FSTORES > 16 generate
    begin
        padded_partial_frame_ptr <= partial_frame_ptr;
    end generate GEN_FSTORES_17NUP;

    -- CR604640 - fixed wrong signal in sensitivity list.
    -- CR604657 - shifted FSTORE 2 to the correct inverse
    S_PARTIAL_NOT_P2 : process(num_frame_store,padded_partial_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1 and 2
                when "000001" | "000010" =>
                    s_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    s_inv_raw_frame_ptr(1) <= '0';
                    s_inv_raw_frame_ptr(2) <= '0';
                    s_inv_raw_frame_ptr(3) <= '0';
                    s_inv_raw_frame_ptr(4) <= '0';

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    s_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    s_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    s_inv_raw_frame_ptr(2) <= '0';
                    s_inv_raw_frame_ptr(3) <= '0';
                    s_inv_raw_frame_ptr(4) <= '0';
                -- Number of Frame Stores = 5 to 8
                when "000101" | "000110" | "000111" | "001000" =>
                    s_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    s_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    s_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    s_inv_raw_frame_ptr(3) <= '0';
                    s_inv_raw_frame_ptr(4) <= '0';

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    s_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    s_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    s_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    s_inv_raw_frame_ptr(3) <= not padded_partial_frame_ptr(3);
                    s_inv_raw_frame_ptr(4) <= '0';

                when others => -- 17 to 32
                    s_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    s_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    s_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    s_inv_raw_frame_ptr(3) <= not padded_partial_frame_ptr(3);
                    s_inv_raw_frame_ptr(4) <= not padded_partial_frame_ptr(4);

            end case;
        end process S_PARTIAL_NOT_P2;

    -- Register to break long timing paths
    S_REG_P2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    s_binary_frame_ptr <= (others => '0');
                else
                    s_binary_frame_ptr <= s_inv_raw_frame_ptr;
                end if;
            end if;
        end process S_REG_P2;


    ---------------------------------------------------------------------------
    -- Phase 3:
    -- Convert to frame pointer (i.e. reverse if need or pass through)
    ---------------------------------------------------------------------------
    -- Reverse order indication
    -- 1 = frame order reversed, 0 = frame order normal
    --mstr_reverse_order  <= not grey_frame_ptr(GREY_NUM_BITS);
    REVERSE_INDICATOR : process(num_frame_store,grey_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1
                when "000001" =>
                    s_mstr_reverse_order   <= not grey_frame_ptr(0);

                -- Number of Frame Stores = 2
                when "000010" =>
                    s_mstr_reverse_order   <= not grey_frame_ptr(1);

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    s_mstr_reverse_order   <= not grey_frame_ptr(2);

                -- Number of Frame Stores = 5, 6, 7, and 8
                when "000101" | "000110" | "000111" | "001000" =>
                    s_mstr_reverse_order   <= not grey_frame_ptr(3);

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    s_mstr_reverse_order   <= not grey_frame_ptr(4);

                -- Number of Frame Stores = 16 to 32
                when others =>
                    s_mstr_reverse_order   <= not grey_frame_ptr(5);

            end case;
        end process REVERSE_INDICATOR;

    -- Register reverse flag to align flag with phase 3 process
    S_REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    s_mstr_reverse_order_d1 <= '1';
                else
                    s_mstr_reverse_order_d1 <= s_mstr_reverse_order;
                end if;
            end if;
        end process S_REG_DELAY_FLAG;

    FRAME_CONVERT_P3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    slv_frame_ref_out <= (others => '0');

                -- reverse order frames (reverse the frame)
                elsif(s_mstr_reverse_order_d1='1' and num_fstore_equal_one = '0')then
                    slv_frame_ref_out <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(s_binary_frame_ptr));

                -- reverse order frames with only 1 frame store (reverse the frame)
                -- CR607439 - If 1 fstore then frame is always just 0
                elsif(num_fstore_equal_one = '1')then
                    slv_frame_ref_out <= (others => '0');

                -- forward order frame (simply pass through)
                else
                    slv_frame_ref_out <= s_binary_frame_ptr;
                end if;
            end if;
        end process FRAME_CONVERT_P3;

    mstrfrm_tstsync_out <= '0'; -- Not used for slaves

end generate GENLOCK_FOR_SLAVE;


-------------------------------------------------------------------------------
-- Generate genlock decoding logic for master
-------------------------------------------------------------------------------
GENLOCK_FOR_MASTER : if C_GENLOCK_MODE = 0 generate
begin

    -- Only used for slave mode
    slv_frame_ref_out <= (others => '0');

    -- Create flag to indicate when to reverse frame order for genlock output
    -- 0= normal frame order, 1= reverse frame order
    RVRS_ORDER_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                --if(prmry_resetn = '0' )then
                    mstr_reverse_order  <= '1';

                -- On update if at frame 0 then toggle reverse order flag.
                -- Do not toggle flag if in park mode.
                elsif(fsize_mismatch_err_flag = '0' and mstr_frame_update = '1' and mstr_frame_ref_in = num_fstore_minus1
                and circular_prk_mode = '1')then
                    mstr_reverse_order  <=  not mstr_reverse_order; -- toggle reverse flag

                end if;
            end if;
        end process RVRS_ORDER_FLAG;

    -- Register reverse flag twice to align flag with phase 4 grey encoded tag
    -- process
    REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstr_reverse_order_d1 <= '1';
                    mstr_reverse_order_d2 <= '1';
                else
                    mstr_reverse_order_d1 <= mstr_reverse_order;
                    mstr_reverse_order_d2 <= mstr_reverse_order_d1;
                end if;
            end if;
        end process REG_DELAY_FLAG;

    -- For FSTORE > 1 then gray coding is needed for proper clock crossing
    -- in Gen-Lock slave. (CR578234 - added generate for fstores > 1)
    GEN_FSTORES_GRTR_ONE : if C_NUM_FSTORES > 1 generate
    begin
        ---------------------------------------------------------------------------
        -- Phase 1: Based on reverse order flag convert master frame in into a
        -- reverse order frame number (i.e. 3,2,1,0)
        -- or normal order (i.e. 0,1,2,3)
        ---------------------------------------------------------------------------

        --rvc_frame_ref_in <= std_logic_vector((C_NUM_FSTORES - 1) - unsigned(mstr_frame_ref_in));
        rvc_frame_ref_in <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(mstr_frame_ref_in));

        FRAME_CONVERT_P1 : process(mstr_reverse_order,mstr_frame_ref_in,rvc_frame_ref_in,num_fstore_equal_one)
            begin
                if(mstr_reverse_order = '1' and num_fstore_equal_one = '0')then
                    raw_frame_ptr <= rvc_frame_ref_in;
                else
                    raw_frame_ptr <= mstr_frame_ref_in;
                end if;
            end process FRAME_CONVERT_P1;

        -- Register to break long timing paths
        REG_P1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_raw_frame_ptr <= (others => '0');
                    else
                        reg_raw_frame_ptr <= raw_frame_ptr;
                    end if;
                end if;
            end process REG_P1;


        ---------------------------------------------------------------------------
        -- Phase 2: Partial Invert of raw frame pointer (invert only the
        -- log2(C_NUM_FSTORE) bits
        -- GREY_NUM_BITS = 1 which is C_NUM_FSTORE = 1 to 2     then invert 1 LSB
        -- GREY_NUM_BITS = 2 which is C_NUM_FSTORE = 3 to 4,    then invert 2 LSBs
        -- GREY_NUM_BITS = 3 which is C_NUM_FSTORE = 5 to 8,    then invert 3 LSBs
        -- GREY_NUM_BITS = 4 which is C_NUM_FSTORE = 9 to 16,   then invert 4 LSBs
        -- GREY_NUM_BITS = 5 which is C_NUM_FSTORE = 17 to 32,  then invert 5 LSBs (all bits)
        ---------------------------------------------------------------------------
        -- CR604657 - shifted FSTORE 2 to the correct inverse
        PARTIAL_NOT_P2 : process(num_frame_store,reg_raw_frame_ptr)
            begin
                case num_frame_store is
                    -- Number of Frame Stores =  1 and 2
                    when "000001" | "000010" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  3 and 4
                    when "000011" | "000100" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  5, 6, 7, and 8
                    when "000101" | "000110" | "000111" | "001000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 9 to 16
                    when "001001" | "001010" | "001011" | "001100" | "001101"
                       | "001110" | "001111" | "010000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 17 to 32
                    when others =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= not reg_raw_frame_ptr(4);
                end case;
            end process PARTIAL_NOT_P2;


        -- Register pratial not to break timing paths
        REG_P2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        binary_frame_ptr <= (others => '0');
                    else
                        binary_frame_ptr <= inv_raw_frame_ptr;
                    end if;
                end if;
            end process REG_P2;


        ---------------------------------------------------------------------------
        -- Phase 3 : Grey Encode
        -- Encode binary coded frame pointer
        ---------------------------------------------------------------------------
        GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
            generic map(
                C_DWIDTH                    => FRAME_NUMBER_WIDTH
            )
            port map(
                -- Grey Encode
                binary_in                   => binary_frame_ptr             ,
                grey_out                    => grey_frame_ptr_out           ,

                -- Grey Decode
                grey_in                     => ZERO_VALUE(FRAME_NUMBER_WIDTH-1 downto 0)       ,
                binary_out                  => open
            );

        ---------------------------------------------------------------------------
        -- Phase 4 : Tag Grey Encoded Pointer
        -- Tag grey code with the inverse of the reverse flag.  This provides
        -- two sets of grey codes representing 2 passes through frame buffer.
        ---------------------------------------------------------------------------



        -- If C_NUM_FSTORES is 17 to 32 then all 5 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_5_BITS : if GREY_NUM_BITS = 5 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is

                        -- Number of Frame Stores = 1
                        when "000001" =>
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 2
                        when "000010" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 3 and 4
                        when "000011" | "000100" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 5 to 8
                        when "000101" | "000110" | "000111" | "001000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 9 to 16
                        when "001001" | "001010" | "001011" | "001100" | "001101"
                           | "001110" | "001111" | "010000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 17 to 32
                        when others =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= grey_frame_ptr_out(4);
                            s_frame_ptr_out(5)  <= not mstr_reverse_order_d2;
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_5_BITS;


        -- If C_NUM_FSTORES is 8 to 16 then all 4 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_4_BITS : if GREY_NUM_BITS = 4 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000101" | "000110" | "000111" | "001000" => -- 5, 6, 7, and 8
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 9 to 16
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_4_BITS;



        -- C_NUM_FSTORES = 4 to 7
        GEN_EQL_3_BITS : if GREY_NUM_BITS = 3 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 5 to 7
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_3_BITS;

        -- C_NUM_FSTORES = 3
        GEN_EQL_2_BITS : if GREY_NUM_BITS = 2 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 3
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_2_BITS;

        -- C_NUM_FSTORES = 2
        GEN_EQL_1_BITS : if GREY_NUM_BITS = 1 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_1_BITS;

    end generate GEN_FSTORES_GRTR_ONE;

    -- CR606861
    -- For FSTORE = 1 then gray coding is not needed.  Simply
    -- pass the reverse order flag out.
    -- (CR578234 - added generate for fstores = 1)
    GEN_FSTORES_EQL_ONE : if C_NUM_FSTORES = 1 generate
    begin

        s_frame_ptr_out <= "00000" & not(mstr_reverse_order_d2);


    end generate GEN_FSTORES_EQL_ONE;

    -- Register Master Frame Pointer Out
    REG_FRAME_PTR_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    frame_ptr_out <= (others => '0');
                else
                    frame_ptr_out <= s_frame_ptr_out;
                end if;
            end if;
        end process REG_FRAME_PTR_OUT;


    --*********************************************************************
    --** TEST VECTOR SIGNALS - For Xilinx Internal Testing Only
    --*********************************************************************
    -- Coverage Off
    REG_SCNDRY_TSTSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstrfrm_tstsync_d1 <= '0';
                    mstrfrm_tstsync_d2 <= '0';
                    mstrfrm_tstsync_d3 <= '0';
                    mstrfrm_tstsync_d4 <= '0';
                else
                    mstrfrm_tstsync_d1 <= mstr_frame_update;
                    mstrfrm_tstsync_d2 <= mstrfrm_tstsync_d1;
                    mstrfrm_tstsync_d3 <= mstrfrm_tstsync_d2;
                    mstrfrm_tstsync_d4 <= mstrfrm_tstsync_d3;
                end if;
            end if;
        end process REG_SCNDRY_TSTSYNC_OUT;

    mstrfrm_tstsync_out <= mstrfrm_tstsync_d4;
    -- Coverage On
    --*********************************************************************
    --** END TEST SECTION
    --*********************************************************************

end generate GENLOCK_FOR_MASTER;

-------------------------------------------------------------------------------
-- Generate genlock decoding logic for master
-------------------------------------------------------------------------------
DYNAMIC_GENLOCK_FOR_MASTER : if C_GENLOCK_MODE = 2 generate
begin


----------------------------------------------------------------------------------------------------------
--un-greying Dynamic slave's (internal or external) frame number 
----------------------------------------------------------------------------------------------------------


    -- Mux frame pointer in from Master based on master in control
    GENLOCK_MUX_I : entity  axi_vdma_v6_2.axi_vdma_genlock_mux
        generic map(
            C_GENLOCK_NUM_MASTERS       => C_GENLOCK_NUM_MASTERS    ,
            C_INTERNAL_GENLOCK_ENABLE   => C_INTERNAL_GENLOCK_ENABLE
        )
        port map(

            prmry_aclk              => prmry_aclk                   ,
            prmry_resetn            => prmry_resetn                 ,

            mstr_in_control         => mstr_in_control              ,
            genlock_select          => genlock_select               ,
            internal_frame_ptr_in   => internal_frame_ptr_in        ,
            frame_ptr_in            => frame_ptr_in                 ,
            frame_ptr_out           => grey_frame_ptr
        );

    ---------------------------------------------------------------------------
    -- Phase 1:
    -- Decode Grey coded frame pointer
    ---------------------------------------------------------------------------
    ADJUST_4_FRM_STRS : process(num_frame_store,grey_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1 and 2
                when "000001" | "000010" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= '0';
                    grey_frmstr_adjusted(2) <= '0';
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= '0';
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 5, 6, 7, and 8
                when "000101" | "000110" | "000111" | "001000" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= grey_frame_ptr(3);
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores =  17 to 32
                when others => -- 17 to 32
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= grey_frame_ptr(3);
                    grey_frmstr_adjusted(4) <= grey_frame_ptr(4);
                    grey_frmstr_adjusted(5) <= '0';

            end case;
        end process ADJUST_4_FRM_STRS;

    GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
        generic map(
            C_DWIDTH                    => GREY_NUM_BITS
        )
        port map(
            -- Grey Encode
            binary_in                   => ZERO_VALUE(GREY_NUM_BITS - 1 downto 0)       ,
            grey_out                    => open             ,

            -- Grey Decode
            grey_in                     => grey_frmstr_adjusted(GREY_NUM_BITS - 1 downto 0)    ,
            binary_out                  => partial_frame_ptr
        );

    ---------------------------------------------------------------------------
    -- Phase 2:
    -- Invert partial frame pointer and pad to full frame pointer width
    ---------------------------------------------------------------------------
    -- FSTORES = 1 or 2 therefore pad decoded frame pointer with 4 bits
    -- CR604657 - shifted FSTORE 2 case to the correct padding location
    GEN_FSTORES_12 : if C_NUM_FSTORES = 1 or C_NUM_FSTORES = 2 generate
    begin
        padded_partial_frame_ptr <= "0000" & partial_frame_ptr;
    end generate GEN_FSTORES_12;

    -- FSTORES = 3 or 4 therefore pad decoded frame pointer with 3 bits
    GEN_FSTORES_34 : if C_NUM_FSTORES > 2 and C_NUM_FSTORES < 5 generate
    begin
        padded_partial_frame_ptr <= "000" & partial_frame_ptr;
    end generate GEN_FSTORES_34;

    -- FSTORES = 5,6,7 or 8 therefore pad decoded frame pointer with 2 bit
    GEN_FSTORES_5678 : if C_NUM_FSTORES > 4 and C_NUM_FSTORES < 9 generate
    begin
        padded_partial_frame_ptr <= "00" & partial_frame_ptr;
    end generate GEN_FSTORES_5678;

    -- FSTORES = 9 to 16 therefore pad decoded frame pointer with 1 bit
    GEN_FSTORES_9TO16 : if C_NUM_FSTORES > 8 and C_NUM_FSTORES < 17 generate
    begin
        padded_partial_frame_ptr <= '0' & partial_frame_ptr;
    end generate GEN_FSTORES_9TO16;

    -- FSTORES > 16 therefore no need to pad decoded frame pointer
    GEN_FSTORES_17NUP : if C_NUM_FSTORES > 16 generate
    begin
        padded_partial_frame_ptr <= partial_frame_ptr;
    end generate GEN_FSTORES_17NUP;

    -- CR604640 - fixed wrong signal in sensitivity list.
    -- CR604657 - shifted FSTORE 2 to the correct inverse
    DM_PARTIAL_NOT_P2 : process(num_frame_store,padded_partial_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1 and 2
                when "000001" | "000010" =>
                    dm_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    dm_inv_raw_frame_ptr(1) <= '0';
                    dm_inv_raw_frame_ptr(2) <= '0';
                    dm_inv_raw_frame_ptr(3) <= '0';
                    dm_inv_raw_frame_ptr(4) <= '0';

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    dm_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    dm_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    dm_inv_raw_frame_ptr(2) <= '0';
                    dm_inv_raw_frame_ptr(3) <= '0';
                    dm_inv_raw_frame_ptr(4) <= '0';
                -- Number of Frame Stores = 5 to 8
                when "000101" | "000110" | "000111" | "001000" =>
                    dm_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    dm_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    dm_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    dm_inv_raw_frame_ptr(3) <= '0';
                    dm_inv_raw_frame_ptr(4) <= '0';

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    dm_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    dm_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    dm_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    dm_inv_raw_frame_ptr(3) <= not padded_partial_frame_ptr(3);
                    dm_inv_raw_frame_ptr(4) <= '0';

                when others => -- 17 to 32
                    dm_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    dm_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    dm_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    dm_inv_raw_frame_ptr(3) <= not padded_partial_frame_ptr(3);
                    dm_inv_raw_frame_ptr(4) <= not padded_partial_frame_ptr(4);

            end case;
        end process DM_PARTIAL_NOT_P2;

    -- Register to break long timing paths
    DM_REG_P2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    dm_binary_frame_ptr <= (others => '0');
                else
                    dm_binary_frame_ptr <= dm_inv_raw_frame_ptr;
                end if;
            end if;
        end process DM_REG_P2;


    ---------------------------------------------------------------------------
    -- Phase 3:
    -- Convert to frame pointer (i.e. reverse if need or pass through)
    ---------------------------------------------------------------------------
    -- Reverse order indication
    -- 1 = frame order reversed, 0 = frame order normal
    --mstr_reverse_order  <= not grey_frame_ptr(GREY_NUM_BITS);
    DM_REVERSE_INDICATOR : process(num_frame_store,grey_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1
                when "000001" =>
                    dm_mstr_reverse_order   <= not grey_frame_ptr(0);

                -- Number of Frame Stores = 2
                when "000010" =>
                    dm_mstr_reverse_order   <= not grey_frame_ptr(1);

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    dm_mstr_reverse_order   <= not grey_frame_ptr(2);

                -- Number of Frame Stores = 5, 6, 7, and 8
                when "000101" | "000110" | "000111" | "001000" =>
                    dm_mstr_reverse_order   <= not grey_frame_ptr(3);

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    dm_mstr_reverse_order   <= not grey_frame_ptr(4);

                -- Number of Frame Stores = 16 to 32
                when others =>
                    dm_mstr_reverse_order   <= not grey_frame_ptr(5);

            end case;
        end process DM_REVERSE_INDICATOR;

    -- Register reverse flag to align flag with phase 3 process
    DM_REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    dm_mstr_reverse_order_d1 <= '1';
                else
                    dm_mstr_reverse_order_d1 <= dm_mstr_reverse_order;
                end if;
            end if;
        end process DM_REG_DELAY_FLAG;

    DM_FRAME_CONVERT_P3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    slv_frame_ref_out <= (others => '0');

                -- reverse order frames (reverse the frame)
                elsif(dm_mstr_reverse_order_d1='1' and num_fstore_equal_one = '0')then
                    slv_frame_ref_out <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(dm_binary_frame_ptr));

                -- reverse order frames with only 1 frame store (reverse the frame)
                -- CR607439 - If 1 fstore then frame is always just 0
                elsif(num_fstore_equal_one = '1')then
                    slv_frame_ref_out <= (others => '0');

                -- forward order frame (simply pass through)
                else
                    slv_frame_ref_out <= dm_binary_frame_ptr;
                end if;
            end if;
        end process DM_FRAME_CONVERT_P3;
-----------------------------------------------------------------------------------------------------------
--grey frame number out for dynamic genlock master
-----------------------------------------------------------------------------------------------------------
    -- Create flag to indicate when to reverse frame order for genlock output
    -- 0= normal frame order, 1= reverse frame order
    RVRS_ORDER_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                --if(prmry_resetn = '0' )then
                    mstr_reverse_order  <= '1';

                -- On update if at frame 0 then toggle reverse order flag.
                -- Do not toggle flag if in park mode.
                elsif(fsize_mismatch_err_flag = '0' and mstr_frame_update = '1' and mstr_frame_ref_in = num_fstore_minus1
                and circular_prk_mode = '1')then
                    mstr_reverse_order  <=  not mstr_reverse_order; -- toggle reverse flag

                end if;
            end if;
        end process RVRS_ORDER_FLAG;

    -- Register reverse flag twice to align flag with phase 4 grey encoded tag
    -- process
    REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstr_reverse_order_d1 <= '1';
                    mstr_reverse_order_d2 <= '1';
                else
                    mstr_reverse_order_d1 <= mstr_reverse_order;
                    mstr_reverse_order_d2 <= mstr_reverse_order_d1;
                end if;
            end if;
        end process REG_DELAY_FLAG;

    -- For FSTORE > 1 then gray coding is needed for proper clock crossing
    -- in Gen-Lock slave. (CR578234 - added generate for fstores > 1)
    GEN_FSTORES_GRTR_ONE : if C_NUM_FSTORES > 1 generate
    begin
        ---------------------------------------------------------------------------
        -- Phase 1: Based on reverse order flag convert master frame in into a
        -- reverse order frame number (i.e. 3,2,1,0)
        -- or normal order (i.e. 0,1,2,3)
        ---------------------------------------------------------------------------

        --rvc_frame_ref_in <= std_logic_vector((C_NUM_FSTORES - 1) - unsigned(mstr_frame_ref_in));
        rvc_frame_ref_in <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(mstr_frame_ref_in));

        FRAME_CONVERT_P1 : process(mstr_reverse_order,mstr_frame_ref_in,rvc_frame_ref_in,num_fstore_equal_one)
            begin
                if(mstr_reverse_order = '1' and num_fstore_equal_one = '0')then
                    raw_frame_ptr <= rvc_frame_ref_in;
                else
                    raw_frame_ptr <= mstr_frame_ref_in;
                end if;
            end process FRAME_CONVERT_P1;

        -- Register to break long timing paths
        REG_P1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_raw_frame_ptr <= (others => '0');
                    else
                        reg_raw_frame_ptr <= raw_frame_ptr;
                    end if;
                end if;
            end process REG_P1;


        ---------------------------------------------------------------------------
        -- Phase 2: Partial Invert of raw frame pointer (invert only the
        -- log2(C_NUM_FSTORE) bits
        -- GREY_NUM_BITS = 1 which is C_NUM_FSTORE = 1 to 2     then invert 1 LSB
        -- GREY_NUM_BITS = 2 which is C_NUM_FSTORE = 3 to 4,    then invert 2 LSBs
        -- GREY_NUM_BITS = 3 which is C_NUM_FSTORE = 5 to 8,    then invert 3 LSBs
        -- GREY_NUM_BITS = 4 which is C_NUM_FSTORE = 9 to 16,   then invert 4 LSBs
        -- GREY_NUM_BITS = 5 which is C_NUM_FSTORE = 17 to 32,  then invert 5 LSBs (all bits)
        ---------------------------------------------------------------------------
        -- CR604657 - shifted FSTORE 2 to the correct inverse
        PARTIAL_NOT_P2 : process(num_frame_store,reg_raw_frame_ptr)
            begin
                case num_frame_store is
                    -- Number of Frame Stores =  1 and 2
                    when "000001" | "000010" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  3 and 4
                    when "000011" | "000100" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  5, 6, 7, and 8
                    when "000101" | "000110" | "000111" | "001000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 9 to 16
                    when "001001" | "001010" | "001011" | "001100" | "001101"
                       | "001110" | "001111" | "010000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 17 to 32
                    when others =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= not reg_raw_frame_ptr(4);
                end case;
            end process PARTIAL_NOT_P2;


        -- Register pratial not to break timing paths
        REG_P2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        binary_frame_ptr <= (others => '0');
                    else
                        binary_frame_ptr <= inv_raw_frame_ptr;
                    end if;
                end if;
            end process REG_P2;


        ---------------------------------------------------------------------------
        -- Phase 3 : Grey Encode
        -- Encode binary coded frame pointer
        ---------------------------------------------------------------------------
        GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
            generic map(
                C_DWIDTH                    => FRAME_NUMBER_WIDTH
            )
            port map(
                -- Grey Encode
                binary_in                   => binary_frame_ptr             ,
                grey_out                    => grey_frame_ptr_out           ,

                -- Grey Decode
                grey_in                     => ZERO_VALUE(FRAME_NUMBER_WIDTH-1 downto 0)       ,
                binary_out                  => open
            );

        ---------------------------------------------------------------------------
        -- Phase 4 : Tag Grey Encoded Pointer
        -- Tag grey code with the inverse of the reverse flag.  This provides
        -- two sets of grey codes representing 2 passes through frame buffer.
        ---------------------------------------------------------------------------



        -- If C_NUM_FSTORES is 17 to 32 then all 5 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_5_BITS : if GREY_NUM_BITS = 5 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is

                        -- Number of Frame Stores = 1
                        when "000001" =>
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 2
                        when "000010" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 3 and 4
                        when "000011" | "000100" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 5 to 8
                        when "000101" | "000110" | "000111" | "001000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 9 to 16
                        when "001001" | "001010" | "001011" | "001100" | "001101"
                           | "001110" | "001111" | "010000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 17 to 32
                        when others =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= grey_frame_ptr_out(4);
                            s_frame_ptr_out(5)  <= not mstr_reverse_order_d2;
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_5_BITS;


        -- If C_NUM_FSTORES is 8 to 16 then all 4 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_4_BITS : if GREY_NUM_BITS = 4 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000101" | "000110" | "000111" | "001000" => -- 5, 6, 7, and 8
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 9 to 16
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_4_BITS;



        -- C_NUM_FSTORES = 4 to 7
        GEN_EQL_3_BITS : if GREY_NUM_BITS = 3 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 5 to 7
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_3_BITS;

        -- C_NUM_FSTORES = 3
        GEN_EQL_2_BITS : if GREY_NUM_BITS = 2 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 3
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_2_BITS;

        -- C_NUM_FSTORES = 2
        GEN_EQL_1_BITS : if GREY_NUM_BITS = 1 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_1_BITS;

    end generate GEN_FSTORES_GRTR_ONE;

    -- CR606861
    -- For FSTORE = 1 then gray coding is not needed.  Simply
    -- pass the reverse order flag out.
    -- (CR578234 - added generate for fstores = 1)
    GEN_FSTORES_EQL_ONE : if C_NUM_FSTORES = 1 generate
    begin

        s_frame_ptr_out <= "00000" & not(mstr_reverse_order_d2);


    end generate GEN_FSTORES_EQL_ONE;

    -- Register Master Frame Pointer Out
    REG_FRAME_PTR_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    frame_ptr_out <= (others => '0');
                else
                    frame_ptr_out <= s_frame_ptr_out;
                end if;
            end if;
        end process REG_FRAME_PTR_OUT;


    --*********************************************************************
    --** TEST VECTOR SIGNALS - For Xilinx Internal Testing Only
    --*********************************************************************
    -- Coverage Off
    REG_SCNDRY_TSTSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstrfrm_tstsync_d1 <= '0';
                    mstrfrm_tstsync_d2 <= '0';
                    mstrfrm_tstsync_d3 <= '0';
                    mstrfrm_tstsync_d4 <= '0';
                else
                    mstrfrm_tstsync_d1 <= mstr_frame_update;
                    mstrfrm_tstsync_d2 <= mstrfrm_tstsync_d1;
                    mstrfrm_tstsync_d3 <= mstrfrm_tstsync_d2;
                    mstrfrm_tstsync_d4 <= mstrfrm_tstsync_d3;
                end if;
            end if;
        end process REG_SCNDRY_TSTSYNC_OUT;

    mstrfrm_tstsync_out <= mstrfrm_tstsync_d4;
    -- Coverage On
    --*********************************************************************
    --** END TEST SECTION
    --*********************************************************************

end generate DYNAMIC_GENLOCK_FOR_MASTER;




-------------------------------------------------------------------------------
-- Generate genlock decoding logic for Dynamic slave
-------------------------------------------------------------------------------
DYNAMIC_GENLOCK_FOR_SLAVE : if C_GENLOCK_MODE = 3 generate
begin


    -- Mux frame pointer in from Master based on master in control
    GENLOCK_MUX_I : entity  axi_vdma_v6_2.axi_vdma_genlock_mux
        generic map(
            C_GENLOCK_NUM_MASTERS       => C_GENLOCK_NUM_MASTERS    ,
            C_INTERNAL_GENLOCK_ENABLE   => C_INTERNAL_GENLOCK_ENABLE
        )
        port map(

            prmry_aclk              => prmry_aclk                   ,
            prmry_resetn            => prmry_resetn                 ,

            mstr_in_control         => mstr_in_control              ,
            genlock_select          => genlock_select               ,
            internal_frame_ptr_in   => internal_frame_ptr_in        ,
            frame_ptr_in            => frame_ptr_in                 ,
            frame_ptr_out           => grey_frame_ptr
        );

    ---------------------------------------------------------------------------
    -- Phase 1:
    -- Decode Grey coded frame pointer
    ---------------------------------------------------------------------------
    ADJUST_4_FRM_STRS : process(num_frame_store,grey_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1 and 2
                when "000001" | "000010" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= '0';
                    grey_frmstr_adjusted(2) <= '0';
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= '0';
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 5, 6, 7, and 8
                when "000101" | "000110" | "000111" | "001000" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= '0';
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= grey_frame_ptr(3);
                    grey_frmstr_adjusted(4) <= '0';
                    grey_frmstr_adjusted(5) <= '0';

                -- Number of Frame Stores =  17 to 32
                when others => -- 17 to 32
                    grey_frmstr_adjusted(0) <= grey_frame_ptr(0);
                    grey_frmstr_adjusted(1) <= grey_frame_ptr(1);
                    grey_frmstr_adjusted(2) <= grey_frame_ptr(2);
                    grey_frmstr_adjusted(3) <= grey_frame_ptr(3);
                    grey_frmstr_adjusted(4) <= grey_frame_ptr(4);
                    grey_frmstr_adjusted(5) <= '0';

            end case;
        end process ADJUST_4_FRM_STRS;

    GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
        generic map(
            C_DWIDTH                    => GREY_NUM_BITS
        )
        port map(
            -- Grey Encode
            binary_in                   => ZERO_VALUE(GREY_NUM_BITS - 1 downto 0)       ,
            grey_out                    => open             ,

            -- Grey Decode
            grey_in                     => grey_frmstr_adjusted(GREY_NUM_BITS - 1 downto 0)    ,
            binary_out                  => partial_frame_ptr
        );

    ---------------------------------------------------------------------------
    -- Phase 2:
    -- Invert partial frame pointer and pad to full frame pointer width
    ---------------------------------------------------------------------------
    -- FSTORES = 1 or 2 therefore pad decoded frame pointer with 4 bits
    -- CR604657 - shifted FSTORE 2 case to the correct padding location
    GEN_FSTORES_12 : if C_NUM_FSTORES = 1 or C_NUM_FSTORES = 2 generate
    begin
        padded_partial_frame_ptr <= "0000" & partial_frame_ptr;
    end generate GEN_FSTORES_12;

    -- FSTORES = 3 or 4 therefore pad decoded frame pointer with 3 bits
    GEN_FSTORES_34 : if C_NUM_FSTORES > 2 and C_NUM_FSTORES < 5 generate
    begin
        padded_partial_frame_ptr <= "000" & partial_frame_ptr;
    end generate GEN_FSTORES_34;

    -- FSTORES = 5,6,7 or 8 therefore pad decoded frame pointer with 2 bit
    GEN_FSTORES_5678 : if C_NUM_FSTORES > 4 and C_NUM_FSTORES < 9 generate
    begin
        padded_partial_frame_ptr <= "00" & partial_frame_ptr;
    end generate GEN_FSTORES_5678;

    -- FSTORES = 9 to 16 therefore pad decoded frame pointer with 1 bit
    GEN_FSTORES_9TO16 : if C_NUM_FSTORES > 8 and C_NUM_FSTORES < 17 generate
    begin
        padded_partial_frame_ptr <= '0' & partial_frame_ptr;
    end generate GEN_FSTORES_9TO16;

    -- FSTORES > 16 therefore no need to pad decoded frame pointer
    GEN_FSTORES_17NUP : if C_NUM_FSTORES > 16 generate
    begin
        padded_partial_frame_ptr <= partial_frame_ptr;
    end generate GEN_FSTORES_17NUP;

    -- CR604640 - fixed wrong signal in sensitivity list.
    -- CR604657 - shifted FSTORE 2 to the correct inverse
    DS_PARTIAL_NOT_P2 : process(num_frame_store,padded_partial_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1 and 2
                when "000001" | "000010" =>
                    ds_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    ds_inv_raw_frame_ptr(1) <= '0';
                    ds_inv_raw_frame_ptr(2) <= '0';
                    ds_inv_raw_frame_ptr(3) <= '0';
                    ds_inv_raw_frame_ptr(4) <= '0';

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    ds_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    ds_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    ds_inv_raw_frame_ptr(2) <= '0';
                    ds_inv_raw_frame_ptr(3) <= '0';
                    ds_inv_raw_frame_ptr(4) <= '0';
                -- Number of Frame Stores = 5 to 8
                when "000101" | "000110" | "000111" | "001000" =>
                    ds_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    ds_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    ds_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    ds_inv_raw_frame_ptr(3) <= '0';
                    ds_inv_raw_frame_ptr(4) <= '0';

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    ds_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    ds_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    ds_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    ds_inv_raw_frame_ptr(3) <= not padded_partial_frame_ptr(3);
                    ds_inv_raw_frame_ptr(4) <= '0';

                when others => -- 17 to 32
                    ds_inv_raw_frame_ptr(0) <= not padded_partial_frame_ptr(0);
                    ds_inv_raw_frame_ptr(1) <= not padded_partial_frame_ptr(1);
                    ds_inv_raw_frame_ptr(2) <= not padded_partial_frame_ptr(2);
                    ds_inv_raw_frame_ptr(3) <= not padded_partial_frame_ptr(3);
                    ds_inv_raw_frame_ptr(4) <= not padded_partial_frame_ptr(4);

            end case;
        end process DS_PARTIAL_NOT_P2;

    -- Register to break long timing paths
    DS_REG_P2 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    ds_binary_frame_ptr <= (others => '0');
                else
                    ds_binary_frame_ptr <= ds_inv_raw_frame_ptr;
                end if;
            end if;
        end process DS_REG_P2;


    ---------------------------------------------------------------------------
    -- Phase 3:
    -- Convert to frame pointer (i.e. reverse if need or pass through)
    ---------------------------------------------------------------------------
    -- Reverse order indication
    -- 1 = frame order reversed, 0 = frame order normal
    --mstr_reverse_order  <= not grey_frame_ptr(GREY_NUM_BITS);
    DS_REVERSE_INDICATOR : process(num_frame_store,grey_frame_ptr)
        begin
            case num_frame_store is
                -- Number of Frame Stores = 1
                when "000001" =>
                    ds_mstr_reverse_order   <= not grey_frame_ptr(0);

                -- Number of Frame Stores = 2
                when "000010" =>
                    ds_mstr_reverse_order   <= not grey_frame_ptr(1);

                -- Number of Frame Stores = 3 and 4
                when "000011" | "000100" =>
                    ds_mstr_reverse_order   <= not grey_frame_ptr(2);

                -- Number of Frame Stores = 5, 6, 7, and 8
                when "000101" | "000110" | "000111" | "001000" =>
                    ds_mstr_reverse_order   <= not grey_frame_ptr(3);

                -- Number of Frame Stores = 9 to 16
                when "001001" | "001010" | "001011" | "001100" | "001101"
                   | "001110" | "001111" | "010000" =>
                    ds_mstr_reverse_order   <= not grey_frame_ptr(4);

                -- Number of Frame Stores = 16 to 32
                when others =>
                    ds_mstr_reverse_order   <= not grey_frame_ptr(5);

            end case;
        end process DS_REVERSE_INDICATOR;

    -- Register reverse flag to align flag with phase 3 process
    DS_REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    ds_mstr_reverse_order_d1 <= '1';
                else
                    ds_mstr_reverse_order_d1 <= ds_mstr_reverse_order;
                end if;
            end if;
        end process DS_REG_DELAY_FLAG;

    DS_FRAME_CONVERT_P3 : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    slv_frame_ref_out <= (others => '0');

                -- reverse order frames (reverse the frame)
                elsif(ds_mstr_reverse_order_d1='1' and num_fstore_equal_one = '0')then
                    slv_frame_ref_out <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(ds_binary_frame_ptr));

                -- reverse order frames with only 1 frame store (reverse the frame)
                -- CR607439 - If 1 fstore then frame is always just 0
                elsif(num_fstore_equal_one = '1')then
                    slv_frame_ref_out <= (others => '0');

                -- forward order frame (simply pass through)
                else
                    slv_frame_ref_out <= ds_binary_frame_ptr;
                end if;
            end if;
        end process DS_FRAME_CONVERT_P3;



-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
    --Output Dynamic GenLock Slave's working frame number in grey
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------------------------

    -- Create flag to indicate when to reverse frame order for genlock output
    -- 0= normal frame order, 1= reverse frame order
    RVRS_ORDER_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0' or dmasr_halt = '1')then
                --if(prmry_resetn = '0' )then
                    mstr_reverse_order  <= '1';

                -- On update if at frame 0 then toggle reverse order flag.
                -- Do not toggle flag if in park mode.
                elsif(fsize_mismatch_err_flag = '0' and mstr_frame_update = '1' and mstr_frame_ref_in = num_fstore_minus1
                and circular_prk_mode = '1')then
                    mstr_reverse_order  <=  not mstr_reverse_order; -- toggle reverse flag

                end if;
            end if;
        end process RVRS_ORDER_FLAG;

    -- Register reverse flag twice to align flag with phase 4 grey encoded tag
    -- process
    DS2_REG_DELAY_FLAG : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstr_reverse_order_d1 <= '1';
                    mstr_reverse_order_d2 <= '1';
                else
                    mstr_reverse_order_d1 <= mstr_reverse_order;
                    mstr_reverse_order_d2 <= mstr_reverse_order_d1;
                end if;
            end if;
        end process DS2_REG_DELAY_FLAG;

    -- For FSTORE > 1 then gray coding is needed for proper clock crossing
    -- in Gen-Lock slave. (CR578234 - added generate for fstores > 1)
    GEN_FSTORES_GRTR_ONE : if C_NUM_FSTORES > 1 generate
    begin
        ---------------------------------------------------------------------------
        -- Phase 1: Based on reverse order flag convert master frame in into a
        -- reverse order frame number (i.e. 3,2,1,0)
        -- or normal order (i.e. 0,1,2,3)
        ---------------------------------------------------------------------------

        --rvc_frame_ref_in <= std_logic_vector((C_NUM_FSTORES - 1) - unsigned(mstr_frame_ref_in));
        rvc_frame_ref_in <= std_logic_vector(unsigned(num_fstore_minus1) - unsigned(mstr_frame_ref_in));

        FRAME_CONVERT_P1 : process(mstr_reverse_order,mstr_frame_ref_in,rvc_frame_ref_in,num_fstore_equal_one)
            begin
                if(mstr_reverse_order = '1' and num_fstore_equal_one = '0')then
                    raw_frame_ptr <= rvc_frame_ref_in;
                else
                    raw_frame_ptr <= mstr_frame_ref_in;
                end if;
            end process FRAME_CONVERT_P1;

        -- Register to break long timing paths
        REG_P1 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        reg_raw_frame_ptr <= (others => '0');
                    else
                        reg_raw_frame_ptr <= raw_frame_ptr;
                    end if;
                end if;
            end process REG_P1;


        ---------------------------------------------------------------------------
        -- Phase 2: Partial Invert of raw frame pointer (invert only the
        -- log2(C_NUM_FSTORE) bits
        -- GREY_NUM_BITS = 1 which is C_NUM_FSTORE = 1 to 2     then invert 1 LSB
        -- GREY_NUM_BITS = 2 which is C_NUM_FSTORE = 3 to 4,    then invert 2 LSBs
        -- GREY_NUM_BITS = 3 which is C_NUM_FSTORE = 5 to 8,    then invert 3 LSBs
        -- GREY_NUM_BITS = 4 which is C_NUM_FSTORE = 9 to 16,   then invert 4 LSBs
        -- GREY_NUM_BITS = 5 which is C_NUM_FSTORE = 17 to 32,  then invert 5 LSBs (all bits)
        ---------------------------------------------------------------------------
        -- CR604657 - shifted FSTORE 2 to the correct inverse
        PARTIAL_NOT_P2 : process(num_frame_store,reg_raw_frame_ptr)
            begin
                case num_frame_store is
                    -- Number of Frame Stores =  1 and 2
                    when "000001" | "000010" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  3 and 4
                    when "000011" | "000100" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores =  5, 6, 7, and 8
                    when "000101" | "000110" | "000111" | "001000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 9 to 16
                    when "001001" | "001010" | "001011" | "001100" | "001101"
                       | "001110" | "001111" | "010000" =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= reg_raw_frame_ptr(4);

                    -- Number of Frame Stores = 17 to 32
                    when others =>
                        inv_raw_frame_ptr(0) <= not reg_raw_frame_ptr(0);
                        inv_raw_frame_ptr(1) <= not reg_raw_frame_ptr(1);
                        inv_raw_frame_ptr(2) <= not reg_raw_frame_ptr(2);
                        inv_raw_frame_ptr(3) <= not reg_raw_frame_ptr(3);
                        inv_raw_frame_ptr(4) <= not reg_raw_frame_ptr(4);
                end case;
            end process PARTIAL_NOT_P2;


        -- Register pratial not to break timing paths
        REG_P2 : process(prmry_aclk)
            begin
                if(prmry_aclk'EVENT and prmry_aclk = '1')then
                    if(prmry_resetn = '0')then
                        binary_frame_ptr <= (others => '0');
                    else
                        binary_frame_ptr <= inv_raw_frame_ptr;
                    end if;
                end if;
            end process REG_P2;


        ---------------------------------------------------------------------------
        -- Phase 3 : Grey Encode
        -- Encode binary coded frame pointer
        ---------------------------------------------------------------------------
        GREY_CODER_I : entity  axi_vdma_v6_2.axi_vdma_greycoder
            generic map(
                C_DWIDTH                    => FRAME_NUMBER_WIDTH
            )
            port map(
                -- Grey Encode
                binary_in                   => binary_frame_ptr             ,
                grey_out                    => grey_frame_ptr_out           ,

                -- Grey Decode
                grey_in                     => ZERO_VALUE(FRAME_NUMBER_WIDTH-1 downto 0)       ,
                binary_out                  => open
            );


        ---------------------------------------------------------------------------
        -- Phase 4 : Tag Grey Encoded Pointer
        -- Tag grey code with the inverse of the reverse flag.  This provides
        -- two sets of grey codes representing 2 passes through frame buffer.
        ---------------------------------------------------------------------------



        -- If C_NUM_FSTORES is 17 to 32 then all 5 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_5_BITS : if GREY_NUM_BITS = 5 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is

                        -- Number of Frame Stores = 1
                        when "000001" =>
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 2
                        when "000010" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 3 and 4
                        when "000011" | "000100" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 5 to 8
                        when "000101" | "000110" | "000111" | "001000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 9 to 16
                        when "001001" | "001010" | "001011" | "001100" | "001101"
                           | "001110" | "001111" | "010000" =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';

                        -- Number of Frame Stores = 17 to 32
                        when others =>
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= grey_frame_ptr_out(4);
                            s_frame_ptr_out(5)  <= not mstr_reverse_order_d2;
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_5_BITS;


        -- If C_NUM_FSTORES is 8 to 16 then all 4 bits are used of frame number therefore
        -- no need to pad grey encoded result
        GEN_EQL_4_BITS : if GREY_NUM_BITS = 4 generate
        begin

            -- CR606861
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000101" | "000110" | "000111" | "001000" => -- 5, 6, 7, and 8
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 9 to 16
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= grey_frame_ptr_out(3);
                            s_frame_ptr_out(4)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_4_BITS;



        -- C_NUM_FSTORES = 4 to 7
        GEN_EQL_3_BITS : if GREY_NUM_BITS = 3 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000011" | "000100" => -- 3 and 4
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- 5 to 7
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= grey_frame_ptr_out(2);
                            s_frame_ptr_out(3)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_3_BITS;

        -- C_NUM_FSTORES = 3
        GEN_EQL_2_BITS : if GREY_NUM_BITS = 2 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when "000010" => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 3
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= grey_frame_ptr_out(1);
                            s_frame_ptr_out(2)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_2_BITS;

        -- C_NUM_FSTORES = 2
        GEN_EQL_1_BITS : if GREY_NUM_BITS = 1 generate
        begin
            S_FRM_PTR_OUT_PROCESS : process(num_frame_store,grey_frame_ptr_out,mstr_reverse_order_d2)
                begin
                    case num_frame_store is
                        when "000001" => -- Number of Frame Stores = 1
                            s_frame_ptr_out(0)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(1)  <= '0';
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                        when others => -- Number of Frame Stores = 2
                            s_frame_ptr_out(0)  <= grey_frame_ptr_out(0);
                            s_frame_ptr_out(1)  <= not mstr_reverse_order_d2;
                            s_frame_ptr_out(2)  <= '0';
                            s_frame_ptr_out(3)  <= '0';
                            s_frame_ptr_out(4)  <= '0';
                            s_frame_ptr_out(5)  <= '0';
                    end case;
                end process S_FRM_PTR_OUT_PROCESS;

        end generate GEN_EQL_1_BITS;

    end generate GEN_FSTORES_GRTR_ONE;

    -- CR606861
    -- For FSTORE = 1 then gray coding is not needed.  Simply
    -- pass the reverse order flag out.
    -- (CR578234 - added generate for fstores = 1)
    GEN_FSTORES_EQL_ONE : if C_NUM_FSTORES = 1 generate
    begin

        s_frame_ptr_out <= "00000" & not(mstr_reverse_order_d2);


    end generate GEN_FSTORES_EQL_ONE;

    -- Register Master Frame Pointer Out
    REG_FRAME_PTR_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    frame_ptr_out <= (others => '0');
                else
                    frame_ptr_out <= s_frame_ptr_out;
                end if;
            end if;
        end process REG_FRAME_PTR_OUT;


    --*********************************************************************
    --** TEST VECTOR SIGNALS - For Xilinx Internal Testing Only
    --*********************************************************************
    -- Coverage Off
    REG_SCNDRY_TSTSYNC_OUT : process(prmry_aclk)
        begin
            if(prmry_aclk'EVENT and prmry_aclk = '1')then
                if(prmry_resetn = '0')then
                    mstrfrm_tstsync_d1 <= '0';
                    mstrfrm_tstsync_d2 <= '0';
                    mstrfrm_tstsync_d3 <= '0';
                    mstrfrm_tstsync_d4 <= '0';
                else
                    mstrfrm_tstsync_d1 <= mstr_frame_update;
                    mstrfrm_tstsync_d2 <= mstrfrm_tstsync_d1;
                    mstrfrm_tstsync_d3 <= mstrfrm_tstsync_d2;
                    mstrfrm_tstsync_d4 <= mstrfrm_tstsync_d3;
                end if;
            end if;
        end process REG_SCNDRY_TSTSYNC_OUT;

    mstrfrm_tstsync_out <= mstrfrm_tstsync_d4;
    -- Coverage On
    --*********************************************************************
    --** END TEST SECTION
    --*********************************************************************


end generate DYNAMIC_GENLOCK_FOR_SLAVE;



end implementation;
