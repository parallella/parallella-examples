-------------------------------------------------------------------------------
-- axi_vdma_sfifo_autord.vhd
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
-- Filename:        axi_vdma_sfifo_autord.vhd
-- Version:         initial
-- Description:
--    This file contains the logic to generate a CoreGen call to create a
-- synchronous FIFO as part of the synthesis process of XST. This eliminates
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

library lib_fifo_v1_0;
use lib_fifo_v1_0.sync_fifo_fg;


library axi_vdma_v6_2;
use axi_vdma_v6_2.axi_vdma_pkg.all;


-------------------------------------------------------------------------------

entity axi_vdma_sfifo_autord is
  generic (
     C_DWIDTH                : integer := 32;
       -- Sets the width of the FIFO Data

     C_DEPTH                 : integer := 128;
       -- Sets the depth of the FIFO

     C_DATA_CNT_WIDTH        : integer := 8;
       -- Sets the width of the FIFO Data Count output

     C_NEED_ALMOST_EMPTY     : Integer range 0 to 1 := 0;
       -- Indicates the need for an almost empty flag from the internal FIFO

     C_NEED_ALMOST_FULL      : Integer range 0 to 1 := 0;
       -- Indicates the need for an almost full flag from the internal FIFO

     C_USE_BLKMEM            : Integer range 0 to 1 := 1;
       -- Sets the type of memory to use for the FIFO
       -- 0 = Distributed Logic
       -- 1 = Block Ram

     C_FAMILY                : String  := "virtex7"
       -- Specifies the target FPGA Family

    );
  port (

    -- FIFO Inputs ------------------------------------------------------------------
     SFIFO_Sinit             : In  std_logic;                                      --
     SFIFO_Clk               : In  std_logic;                                      --
     SFIFO_Wr_en             : In  std_logic;                                      --
     SFIFO_Din               : In  std_logic_vector(C_DWIDTH-1 downto 0);          --
     SFIFO_Rd_en             : In  std_logic;                                      --
     SFIFO_Clr_Rd_Data_Valid : In  std_logic;                                      --
     --------------------------------------------------------------------------------

    -- FIFO Outputs -----------------------------------------------------------------
     SFIFO_DValid            : Out std_logic;                                      --
     SFIFO_Dout              : Out std_logic_vector(C_DWIDTH-1 downto 0);          --
     SFIFO_Full              : Out std_logic;                                      --
     SFIFO_Empty             : Out std_logic;                                      --
     SFIFO_Almost_full       : Out std_logic;                                      --
     SFIFO_Almost_empty      : Out std_logic;                                      --
     SFIFO_Rd_count          : Out std_logic_vector(C_DATA_CNT_WIDTH-1 downto 0);  --
     SFIFO_Rd_count_minus1   : Out std_logic_vector(C_DATA_CNT_WIDTH-1 downto 0);  --
     SFIFO_Wr_count          : Out std_logic_vector(C_DATA_CNT_WIDTH-1 downto 0);  --
     SFIFO_Rd_ack            : Out std_logic                                       --
     --------------------------------------------------------------------------------

    );
end entity axi_vdma_sfifo_autord;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of axi_vdma_sfifo_autord is
attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";


-- Constant declarations

   -- none

-- Signal declarations

   signal write_data_lil_end         : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
   signal read_data_lil_end          : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
   signal raw_data_cnt_lil_end       : std_logic_vector(C_DATA_CNT_WIDTH-1 downto 0) := (others => '0');
   signal raw_data_count_int         : natural := 0;
   signal raw_data_count_corr        : std_logic_vector(C_DATA_CNT_WIDTH-1 downto 0) := (others => '0');
   signal raw_data_count_corr_minus1 : std_logic_vector(C_DATA_CNT_WIDTH-1 downto 0) := (others => '0');
   Signal corrected_empty            : std_logic := '0';
   Signal corrected_almost_empty     : std_logic := '0';
   Signal sig_SFIFO_empty            : std_logic := '0';

   -- backend fifo read ack sample and hold
   Signal sig_rddata_valid           : std_logic := '0';
   Signal hold_ff_q                  : std_logic := '0';
   Signal ored_ack_ff_reset          : std_logic := '0';
   Signal autoread                   : std_logic := '0';
   Signal sig_sfifo_rdack            : std_logic := '0';
   Signal fifo_read_enable           : std_logic := '0';



begin

 -- Bit ordering translations

    write_data_lil_end    <=  SFIFO_Din;  -- translate from Big Endian to little
                                          -- endian.

    SFIFO_Dout            <= read_data_lil_end;  -- translate from Little Endian to
                                                 -- Big endian.


 -- Other port usages and assignments
    SFIFO_Rd_ack          <= sig_sfifo_rdack;

    SFIFO_Almost_empty    <= corrected_almost_empty;

    SFIFO_Empty           <= corrected_empty;

    SFIFO_Wr_count        <= raw_data_cnt_lil_end;


    SFIFO_Rd_count        <= raw_data_count_corr;


    SFIFO_Rd_count_minus1 <= raw_data_count_corr_minus1;



    SFIFO_DValid          <= sig_rddata_valid; -- Output data valid indicator


    fifo_read_enable      <= SFIFO_Rd_en or autoread;








    ------------------------------------------------------------
    -- Instance: I_SYNC_FIFOGEN_FIFO
    --
    -- Description:
    --  Instance for the synchronous fifo from proc common.
    --
    ------------------------------------------------------------
    I_SYNC_FIFOGEN_FIFO : entity lib_fifo_v1_0.sync_fifo_fg
      generic map(
         C_FAMILY             =>  C_FAMILY,        -- requred for FIFO Gen
         C_DCOUNT_WIDTH       =>  C_DATA_CNT_WIDTH,
         C_ENABLE_RLOCS       =>  0,
         C_HAS_DCOUNT         =>  1,
          C_SYNCHRONIZER_STAGE          =>  MTBF_STAGES,
         C_HAS_RD_ACK         =>  1,
         C_HAS_RD_ERR         =>  0,
         C_HAS_WR_ACK         =>  1,
         C_HAS_WR_ERR         =>  0,
         C_MEMORY_TYPE        =>  C_USE_BLKMEM,
         C_PORTS_DIFFER       =>  0,
         C_RD_ACK_LOW         =>  0,
         C_READ_DATA_WIDTH    =>  C_DWIDTH,
         C_READ_DEPTH         =>  C_DEPTH,
         C_RD_ERR_LOW         =>  0,
         C_WR_ACK_LOW         =>  0,
         C_WR_ERR_LOW         =>  0,
         C_WRITE_DATA_WIDTH   =>  C_DWIDTH,
         C_WRITE_DEPTH        =>  C_DEPTH
         --C_WRITE_DEPTH        =>  C_DEPTH,
         --C_PRELOAD_REGS       =>  1, -- 1 = first word fall through
         --C_PRELOAD_LATENCY    =>  0, -- 0 = first word fall through
         --C_USE_EMBEDDED_REG   =>  1  -- 0 ;
         )
      port map(
         Clk                  =>  SFIFO_Clk,
         Sinit                =>  SFIFO_Sinit,
         Din                  =>  write_data_lil_end,
         Wr_en                =>  SFIFO_Wr_en,
         Rd_en                =>  fifo_read_enable,
         Dout                 =>  read_data_lil_end,
         Full                 =>  SFIFO_Full,
         Empty                =>  sig_SFIFO_empty,
         Rd_ack               =>  sig_sfifo_rdack,
         Wr_ack               =>  open,
         Rd_err               =>  open,
         Wr_err               =>  open,
         Data_count           =>  raw_data_cnt_lil_end
        );

   -------------------------------------------------------------------------------






   -------------------------------------------------------------------------------
   -- Read Ack assert & hold logic Needed because....
   -------------------------------------------------------------------------------
   --     1) The CoreGen Sync FIFO has to be read once to get valid
   --        data to the read data port.
   --     2) The Read ack from the fifo is only asserted for 1 clock.
   --     3) A signal is needed that indicates valid data is at the read
   --        port of the FIFO and has not yet been used. This signal needs
   --        to be held until the next read operation occurs or a clear
   --        signal is received.


    ored_ack_ff_reset  <=  fifo_read_enable or
                           SFIFO_Sinit or
                           SFIFO_Clr_Rd_Data_Valid;

    sig_rddata_valid   <=  hold_ff_q or
                           sig_sfifo_rdack;




    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_ACK_HOLD_FLOP
    --
    -- Process Description:
    --  Flop for registering the hold flag
    --
    -------------------------------------------------------------
    IMP_ACK_HOLD_FLOP : process (SFIFO_Clk)
       begin
         if (SFIFO_Clk'event and SFIFO_Clk = '1') then
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
            sig_SFIFO_empty = '0')      -- and the FIFO is not empty
      Else '0';


    raw_data_count_int <=  CONV_INTEGER(raw_data_cnt_lil_end);




    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: INCLUDE_ALMOST_EMPTY
    --
    -- If Generate Description:
    --  This IFGen corrects the FIFO Read Count output for the
    --  auto read function and includes the generation of the
    --  Almost_Empty flag.
    --
    ------------------------------------------------------------
    INCLUDE_ALMOST_EMPTY : if (C_NEED_ALMOST_EMPTY = 1) generate

       -- local signals

          Signal raw_data_count_int_corr        : integer := 0;
          Signal raw_data_count_int_corr_minus1 : integer := 0;

       begin


         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: CORRECT_RD_CNT_IAE
         --
         -- Process Description:
         --  This process corrects the FIFO Read Count output for the
         --  auto read function and includes the generation of the
         --  Almost_Empty flag.
         --
         -------------------------------------------------------------
         CORRECT_RD_CNT_IAE : process (sig_rddata_valid,
                                       sig_SFIFO_empty,
                                       raw_data_count_int)
            begin


               if (sig_rddata_valid = '0') then

                  raw_data_count_int_corr        <= 0;
                  raw_data_count_int_corr_minus1 <= 0;
                  corrected_empty                <= '1';
                  corrected_almost_empty         <= '0';

               elsif (sig_SFIFO_empty = '1') then   -- rddata valid and fifo empty

                  raw_data_count_int_corr        <= 1;
                  raw_data_count_int_corr_minus1 <= 0;
                  corrected_empty                <= '0';
                  corrected_almost_empty         <= '1';

               Elsif (raw_data_count_int = 1) Then  -- rddata valid and fifo almost empty

                  raw_data_count_int_corr        <= 2;
                  raw_data_count_int_corr_minus1 <= 1;
                  corrected_empty                <= '0';
                  corrected_almost_empty         <= '0';

               else                                 -- rddata valid and modify rd count from FIFO

                  raw_data_count_int_corr        <= raw_data_count_int+1;
                  raw_data_count_int_corr_minus1 <= raw_data_count_int;
                  corrected_empty                <= '0';
                  corrected_almost_empty         <= '0';

               end if;

            end process CORRECT_RD_CNT_IAE;


            raw_data_count_corr <= CONV_STD_LOGIC_VECTOR(raw_data_count_int_corr,
                                                         C_DATA_CNT_WIDTH);

            raw_data_count_corr_minus1 <= CONV_STD_LOGIC_VECTOR(raw_data_count_int_corr_minus1,
                                                                 C_DATA_CNT_WIDTH);

       end generate INCLUDE_ALMOST_EMPTY;



    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: OMIT_ALMOST_EMPTY
    --
    -- If Generate Description:
    --    This process corrects the FIFO Read Count output for the
    -- auto read function and omits the generation of the
    -- Almost_Empty flag.
    --
    ------------------------------------------------------------
    OMIT_ALMOST_EMPTY : if (C_NEED_ALMOST_EMPTY = 0) generate

       -- local signals

          Signal raw_data_count_int_corr : integer := 0;

       begin

          corrected_almost_empty  <= '0'; -- always low


          -------------------------------------------------------------
          -- Combinational Process
          --
          -- Label: CORRECT_RD_CNT
          --
          -- Process Description:
          --    This process corrects the FIFO Read Count output for the
          -- auto read function and omits the generation of the
          -- Almost_Empty flag.
          --
          -------------------------------------------------------------
          CORRECT_RD_CNT : process (sig_rddata_valid,
                                    sig_SFIFO_empty,
                                    raw_data_count_int)
             begin


                if (sig_rddata_valid = '0') then

                   raw_data_count_int_corr <= 0;
                   corrected_empty         <= '1';

                elsif (sig_SFIFO_empty = '1') then   -- rddata valid and fifo empty

                   raw_data_count_int_corr <= 1;
                   corrected_empty         <= '0';

                Elsif (raw_data_count_int = 1) Then  -- rddata valid and fifo almost empty

                   raw_data_count_int_corr <= 2;
                   corrected_empty         <= '0';

                else                                 -- rddata valid and modify rd count from FIFO

                   raw_data_count_int_corr <= raw_data_count_int+1;
                   corrected_empty         <= '0';

                end if;

             end process CORRECT_RD_CNT;


             raw_data_count_corr <= CONV_STD_LOGIC_VECTOR(raw_data_count_int_corr,
                                                          C_DATA_CNT_WIDTH);



       end generate OMIT_ALMOST_EMPTY;




    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: INCLUDE_ALMOST_FULL
    --
    -- If Generate Description:
    --  This IfGen Includes the generation of the Amost_Full flag.
    --
    --
    ------------------------------------------------------------
    INCLUDE_ALMOST_FULL : if (C_NEED_ALMOST_FULL = 1) generate

       -- Local Constants

         Constant ALMOST_FULL_VALUE : integer := 2**(C_DATA_CNT_WIDTH-1)-1;

       begin

          SFIFO_Almost_full <= '1'
             When raw_data_count_int = ALMOST_FULL_VALUE
             Else '0';


       end generate INCLUDE_ALMOST_FULL;




    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: OMIT_ALMOST_FULL
    --
    -- If Generate Description:
    --  This IfGen Omits the generation of the Amost_Full flag.
    --
    --
    ------------------------------------------------------------
    OMIT_ALMOST_FULL : if (C_NEED_ALMOST_FULL = 0) generate

       begin

           SFIFO_Almost_full <= '0';  -- always low

       end generate OMIT_ALMOST_FULL;



end imp;
