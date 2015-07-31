-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- axi_vdma_afifo_autord.vhd - entity/architecture pair
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
-- Filename:        axi_vdma_afifo_autord.vhd
-- Version:         initial
-- Description:
--    This file contains the logic to generate a CoreGen call to create a
-- asynchronous FIFO as part of the synthesis process of XST. This eliminates
-- the need for multiple fixed netlists for various sizes and widths of FIFOs.
--
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;

library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;


library lib_cdc_v1_0;
library lib_fifo_v1_0;
use lib_fifo_v1_0.async_fifo_fg;

-----------------------------------------------------------------------------
-- Entity section
-----------------------------------------------------------------------------

entity axi_vdma_afifo_autord is
  generic (
     C_DWIDTH        : integer := 32;
       -- Sets the width of the FIFO Data

     C_DEPTH         : integer := 16;
       -- Sets the depth of the FIFO

     C_CNT_WIDTH     : Integer := 5;
       -- Sets the width of the FIFO Data Count output

     C_USE_BLKMEM    : Integer := 1 ;
       -- Sets the type of memory to use for the FIFO
       -- 0 = Distributed Logic
       -- 1 = Block Ram

     C_FAMILY        : String  := "virtex7"
       -- Specifies the target FPGA Family

    );
  port (
    -- FIFO Inputs --------------------------------------------------------------
     AFIFO_Ainit                : In  std_logic;                               --
     AFIFO_Wr_clk               : In  std_logic;                               --
     AFIFO_Wr_en                : In  std_logic;                               --
     AFIFO_Din                  : In  std_logic_vector(C_DWIDTH-1 downto 0);   --
     AFIFO_Rd_clk               : In  std_logic;                               --
     AFIFO_Rd_en                : In  std_logic;                               --
     AFIFO_Clr_Rd_Data_Valid    : In  std_logic;                               --
     ----------------------------------------------------------------------------

    -- FIFO Outputs --------------------------------------------------------------
     AFIFO_DValid               : Out std_logic;                                --
     AFIFO_Dout                 : Out std_logic_vector(C_DWIDTH-1 downto 0);    --
     AFIFO_Full                 : Out std_logic;                                --
     AFIFO_Empty                : Out std_logic;                                --
     AFIFO_Almost_full          : Out std_logic;                                --
     AFIFO_Almost_empty         : Out std_logic;                                --
     AFIFO_Wr_count             : Out std_logic_vector(C_CNT_WIDTH-1 downto 0); --
     AFIFO_Rd_count             : Out std_logic_vector(C_CNT_WIDTH-1 downto 0); --
     AFIFO_Corr_Rd_count        : Out std_logic_vector(C_CNT_WIDTH downto 0);   --
     AFIFO_Corr_Rd_count_minus1 : Out std_logic_vector(C_CNT_WIDTH downto 0);   --
     AFIFO_Rd_ack               : Out std_logic                                 --
     -----------------------------------------------------------------------------

    );
end entity axi_vdma_afifo_autord;


-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of axi_vdma_afifo_autord is

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";


-- Constant declarations
constant ZERO_VALUE_VECT    : std_logic_vector(128 downto 0) := (others => '0');


-- Signal declarations
   signal write_data_lil_end       : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
   signal read_data_lil_end        : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');

--   signal wr_count_lil_end         : std_logic_vector(C_CNT_WIDTH-1 downto 0) := (others => '0');
--   signal rd_count_lil_end         : std_logic_vector(C_CNT_WIDTH-1 downto 0) := (others => '0');
   signal wr_count_lil_end         : std_logic_vector(C_CNT_WIDTH-2 downto 0) := (others => '0');
   signal rd_count_lil_end         : std_logic_vector(C_CNT_WIDTH-2 downto 0) := (others => '0');

   signal rd_count_int             : natural   :=  0;
   signal rd_count_int_corr        : natural   :=  0;
   signal rd_count_int_corr_minus1 : natural   :=  0;
   Signal corrected_empty          : std_logic := '0';
   Signal corrected_almost_empty   : std_logic := '0';
   Signal sig_afifo_empty          : std_logic := '0';
   Signal sig_afifo_almost_empty   : std_logic := '0';

 -- backend fifo read ack sample and hold
   Signal sig_rddata_valid         : std_logic := '0';
   Signal hold_ff_q                : std_logic := '0';
   Signal ored_ack_ff_reset        : std_logic := '0';
   Signal autoread                 : std_logic := '0';
   Signal sig_wrfifo_rdack         : std_logic := '0';
   Signal fifo_read_enable         : std_logic := '0';

   signal afifo_full_i             : std_logic := '0';
   signal AFIFO_Ainit_reg             : std_logic ;
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------
begin

 -- Bit ordering translations

    write_data_lil_end   <=  AFIFO_Din;  -- translate from Big Endian to little
                                         -- endian.
    AFIFO_Rd_ack         <= sig_wrfifo_rdack;

    AFIFO_Dout           <= read_data_lil_end;  -- translate from Little Endian to
                                                -- Big endian.

    AFIFO_Almost_empty   <= corrected_almost_empty;

    AFIFO_Empty          <= corrected_empty;

    AFIFO_Full          <= afifo_full_i;

--    AFIFO_Wr_count       <= wr_count_lil_end;
    AFIFO_Wr_count       <= afifo_full_i & wr_count_lil_end;

--    AFIFO_Rd_count       <= 'rd_count_lil_end;
    AFIFO_Rd_count       <= '0' & rd_count_lil_end;


    AFIFO_Corr_Rd_count  <= CONV_STD_LOGIC_VECTOR(rd_count_int_corr,
                                                  C_CNT_WIDTH+1);

    AFIFO_Corr_Rd_count_minus1 <= CONV_STD_LOGIC_VECTOR(rd_count_int_corr_minus1,
                                                        C_CNT_WIDTH+1);

    AFIFO_DValid         <= sig_rddata_valid; -- Output data valid indicator


    fifo_read_enable     <= AFIFO_Rd_en or autoread;



   -------------------------------------------------------------------------------
   -- Instantiate the CoreGen FIFO
   --
   -- NOTE:
   -- This instance refers to a wrapper file that interm will use the
   -- CoreGen FIFO Generator Async FIFO utility.
   --
   -------------------------------------------------------------------------------
    I_ASYNC_FIFOGEN_FIFO : entity lib_fifo_v1_0.async_fifo_fg
       generic map (
          C_ALLOW_2N_DEPTH      =>  1 ,
          C_FAMILY              =>  C_FAMILY,
          C_DATA_WIDTH          =>  C_DWIDTH,
          C_ENABLE_RLOCS        =>  0,
          C_FIFO_DEPTH          =>  C_DEPTH,
          C_SYNCHRONIZER_STAGE          =>  MTBF_STAGES,
          C_HAS_ALMOST_EMPTY    =>  1,
          C_HAS_ALMOST_FULL     =>  1,
          C_HAS_RD_ACK          =>  1,
          C_HAS_RD_COUNT        =>  1,
          C_HAS_RD_ERR          =>  0,
          C_HAS_WR_ACK          =>  0,
          C_HAS_WR_COUNT        =>  1,
          C_HAS_WR_ERR          =>  0,
          C_RD_ACK_LOW          =>  0,
--          C_RD_COUNT_WIDTH      =>  C_CNT_WIDTH,
          C_RD_COUNT_WIDTH      =>  C_CNT_WIDTH-1,
          C_RD_ERR_LOW          =>  0,
          C_USE_BLOCKMEM        =>  C_USE_BLKMEM,
          C_WR_ACK_LOW          =>  0,
--          C_WR_COUNT_WIDTH      =>  C_CNT_WIDTH,
          C_WR_COUNT_WIDTH      =>  C_CNT_WIDTH-1,
          C_WR_ERR_LOW          =>  0
          --C_WR_ERR_LOW          =>  0,
          --C_USE_EMBEDDED_REG    =>  1, -- 0 ;
          --C_PRELOAD_REGS        =>  0, -- 0 ;
          --C_PRELOAD_LATENCY     =>  1  -- 1 ;
         )
      port Map (
         Din                 =>  write_data_lil_end,
         Wr_en               =>  AFIFO_Wr_en,
         Wr_clk              =>  AFIFO_Wr_clk,
         Rd_en               =>  fifo_read_enable,
         Rd_clk              =>  AFIFO_Rd_clk,
         Ainit               =>  AFIFO_Ainit,
         Dout                =>  read_data_lil_end,
--         Full                =>  AFIFO_Full,
         Full                =>  afifo_full_i,
         Empty               =>  sig_afifo_empty,
         Almost_full         =>  AFIFO_Almost_full,
         Almost_empty        =>  sig_afifo_almost_empty,
         Wr_count            =>  wr_count_lil_end,
         Rd_count            =>  rd_count_lil_end,
         Rd_ack              =>  sig_wrfifo_rdack,
         Rd_err              =>  open,
         Wr_ack              =>  open,
         Wr_err              =>  open
        );


   ----------------------------------------------------------------------------
   -- Read Ack assert & hold logic (needed because:
   --     1) The Async FIFO has to be read once to get valid
   --        data to the read data port (data is discarded).
   --     2) The Read ack from the fifo is only asserted for 1 clock.
   --     3) A signal is needed that indicates valid data is at the read
   --        port of the FIFO and has not yet been read. This signal needs
   --        to be held until the next read operation occurs or a clear
   --        signal is received.





    ---------------------------------------------------------------------------
    -- AFIFO_Ainit synchronization in AFIFO_Rd_clk domain
    ---------------------------------------------------------------------------

----    AFIFO_Ainit_RESET_CDC_I : entity  axi_vdma_v6_2.axi_vdma_cdc
----        generic map(
----            C_CDC_TYPE          => CDC_TYPE_LEVEL_P_S_NO_RST                   ,
----            C_VECTOR_WIDTH      => 1
----        )
----        port map(
----            prmry_aclk                  => AFIFO_Wr_clk           ,
----            prmry_resetn                => '1'                      ,
----
----            scndry_aclk                 => AFIFO_Rd_clk          ,
----            scndry_resetn               => '1'                      ,
----
----            -- Secondary to Primary Clock Crossing
----            scndry_in                   => '0'                      ,
----            prmry_out                   => open                     ,
----
----            -- Primary to Secondary Clock Crossing
----            prmry_in                    => AFIFO_Ainit        ,
----            scndry_out                  => AFIFO_Ainit_reg       ,
----
----            -- Secondary Vector to Primary Vector Clock Crossing
----            scndry_vect_s_h             => '0'                      ,
----            scndry_vect_in              => ZERO_VALUE_VECT(0 downto 0),
----            prmry_vect_out              => open                     ,
----
----            -- Primary Vector to Secondary Vector Clock Crossing
----            prmry_vect_s_h              => '0'                      ,
----            prmry_vect_in               => ZERO_VALUE_VECT(0 downto 0),
----            scndry_vect_out             => open
----
----        );
----



AFIFO_Ainit_RESET_CDC_I : entity lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_FLOP_INPUT               => 1,	--valid only for level CDC
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => AFIFO_Wr_clk,
        prmry_resetn               => '1', 
        prmry_in                   => AFIFO_Ainit, 
        prmry_vect_in              => (others => '0'),
        prmry_ack                  => open,
                                    
        scndry_aclk                => AFIFO_Rd_clk, 
        scndry_resetn              => '1',
        scndry_out                 => AFIFO_Ainit_reg,
        scndry_vect_out            => open
    );







    ored_ack_ff_reset  <=  fifo_read_enable or
                           AFIFO_Ainit_reg or
                           AFIFO_Clr_Rd_Data_Valid;

    sig_rddata_valid   <=  hold_ff_q or
                           sig_wrfifo_rdack;




    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_ACK_HOLD_FLOP
    --
    -- Process Description:
    --  Flop for registering the hold flag
    --
    -------------------------------------------------------------
    IMP_ACK_HOLD_FLOP : process (AFIFO_Rd_clk)
       begin
         if (AFIFO_Rd_clk'event and AFIFO_Rd_clk = '1') then
           if (ored_ack_ff_reset = '1') then
             hold_ff_q  <= '0';
           else
             hold_ff_q  <= sig_rddata_valid;
           end if;
         end if;
       end process IMP_ACK_HOLD_FLOP;



  -- generate auto-read enable. This keeps fresh data at the output
  -- of the FIFO whenever it is available.
    autoread <= '1'                     -- create a read strobe when the
      when (sig_rddata_valid = '0' and  -- output data is NOT valid
            sig_afifo_empty = '0')      -- and the FIFO is not empty
      Else '0';


    rd_count_int <=  CONV_INTEGER(rd_count_lil_end);


    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: CORRECT_RD_CNT
    --
    -- Process Description:
    --  This process corrects the FIFO Read Count output for the
    -- auto read function.
    --
    -------------------------------------------------------------
    CORRECT_RD_CNT : process (sig_rddata_valid,
                              sig_afifo_empty ,
                              sig_afifo_almost_empty,
                              rd_count_int)
       begin

          if (sig_rddata_valid = '0') then

             rd_count_int_corr        <= 0;
             rd_count_int_corr_minus1 <= 0;
             corrected_empty          <= '1';
             corrected_almost_empty   <= '0';

          elsif (sig_afifo_empty = '1') then         -- rddata valid and fifo empty

             rd_count_int_corr        <= 1;
             rd_count_int_corr_minus1 <= 0;
             corrected_empty          <= '0';
             corrected_almost_empty   <= '1';

          Elsif (sig_afifo_almost_empty = '1') Then  -- rddata valid and fifo almost empty

             rd_count_int_corr        <= 2;
             rd_count_int_corr_minus1 <= 1;
             corrected_empty          <= '0';
             corrected_almost_empty   <= '0';

          else                                       -- rddata valid and modify rd count from FIFO

             rd_count_int_corr        <= rd_count_int+1;
             rd_count_int_corr_minus1 <= rd_count_int;
             corrected_empty          <= '0';
             corrected_almost_empty   <= '0';

          end if;

       end process CORRECT_RD_CNT;



end imp;
