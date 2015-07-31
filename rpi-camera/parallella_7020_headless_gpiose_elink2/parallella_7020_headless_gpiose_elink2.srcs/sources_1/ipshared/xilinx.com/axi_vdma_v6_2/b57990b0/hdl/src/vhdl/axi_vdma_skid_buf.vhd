-------------------------------------------------------------------------------
-- axi_vdma_skid_buf.vhd
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
-- Filename:        axi_vdma_skid_buf.vhd
--
-- Description:
--  Implements the AXi Skid Buffer in the Option 2 (Registerd outputs) mode.
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
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



-------------------------------------------------------------------------------

entity axi_vdma_skid_buf is
  generic (
    C_WDATA_WIDTH : INTEGER range 8 to 1024 := 32;
       --  Width of the Stream Data bus (in bits)
    C_TUSER_WIDTH : INTEGER range 1 to 128  := 1
       -- Width of tuser bus (in bits)

    );
  port (
  -- System Ports
     ACLK         : In  std_logic ;                                         --
     ARST         : In  std_logic ;                                         --
                                                                            --
   -- Shutdown control (assert for 1 clk pulse)                             --
     skid_stop    : In std_logic  ;                                         --
   -- Slave Side (Stream Data Input)                                        --
     S_VALID      : In  std_logic ;                                         --
     S_READY      : Out std_logic ;                                         --
     S_Data       : In  std_logic_vector(C_WDATA_WIDTH-1 downto 0);         --
     S_STRB       : In  std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0);     --
     S_Last       : In  std_logic ;                                         --
     S_User       : In  std_logic_vector(C_TUSER_WIDTH-1 downto 0);         --
   -- Master Side (Stream Data Output                                       --
     M_VALID      : Out std_logic ;                                         --
     M_READY      : In  std_logic ;                                         --
     M_Data       : Out std_logic_vector(C_WDATA_WIDTH-1 downto 0);         --
     M_STRB       : Out std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0);     --
     M_Last       : Out std_logic;                                          --
     M_User       : Out std_logic_vector(C_TUSER_WIDTH-1 downto 0)          --
    );

end entity axi_vdma_skid_buf;


architecture implementation of axi_vdma_skid_buf is

attribute DowngradeIPIdentifiedWarnings: string;
attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

-- Signals decalrations -------------------------

  Signal sig_reset_reg         : std_logic := '0';
  signal sig_spcl_s_ready_set  : std_logic := '0';

  signal sig_data_skid_reg     : std_logic_vector(C_WDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_skid_reg     : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_skid_reg     : std_logic := '0';
  signal sig_skid_reg_en       : std_logic := '0';

  signal sig_data_skid_mux_out : std_logic_vector(C_WDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_skid_mux_out : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_skid_mux_out : std_logic := '0';
  signal sig_skid_mux_sel      : std_logic := '0';

  signal sig_data_reg_out      : std_logic_vector(C_WDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_reg_out      : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_reg_out      : std_logic := '0';
  signal sig_data_reg_out_en   : std_logic := '0';

  signal sig_m_valid_out       : std_logic := '0';
  signal sig_m_valid_dup       : std_logic := '0';
  signal sig_m_valid_comb      : std_logic := '0';

  signal sig_s_ready_out       : std_logic := '0';
  signal sig_s_ready_dup       : std_logic := '0';
  signal sig_s_ready_comb      : std_logic := '0';

  signal sig_stop_request      : std_logic := '0';
--  signal sig_stopped           : std_logic := '0';
  signal sig_sready_stop       : std_logic := '0';
  signal sig_sready_stop_reg   : std_logic := '0';
  signal sig_s_last_xfered     : std_logic := '0';

  signal sig_m_last_xfered     : std_logic := '0';
  signal sig_mvalid_stop_reg   : std_logic := '0';
  signal sig_mvalid_stop       : std_logic := '0';

  signal sig_slast_with_stop   : std_logic := '0';
  signal sig_sstrb_stop_mask   : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_sstrb_with_stop   : std_logic_vector((C_WDATA_WIDTH/8)-1 downto 0) := (others => '0');


  signal sig_user_skid_mux_out : std_logic_vector(C_TUSER_WIDTH-1 downto 0) := (others => '0');
  signal sig_user_skid_reg     : std_logic_vector(C_TUSER_WIDTH-1 downto 0) := (others => '0');
  signal sig_user_reg_out      : std_logic_vector(C_TUSER_WIDTH-1 downto 0) := (others => '0');


-- Register duplication attribute assignments to control fanout
-- on handshake output signals

  Attribute KEEP : string; -- declaration
  Attribute EQUIVALENT_REGISTER_REMOVAL : string; -- declaration

  Attribute KEEP of sig_m_valid_out : signal is "TRUE"; -- definition
  Attribute KEEP of sig_m_valid_dup : signal is "TRUE"; -- definition
  Attribute KEEP of sig_s_ready_out : signal is "TRUE"; -- definition
  Attribute KEEP of sig_s_ready_dup : signal is "TRUE"; -- definition

  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_m_valid_out : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_m_valid_dup : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s_ready_out : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_s_ready_dup : signal is "no";


begin --(architecture implementation)

   M_VALID <= sig_m_valid_out;
   S_READY <= sig_s_ready_out;

   M_STRB  <= sig_strb_reg_out;
   M_Last  <= sig_last_reg_out;
   M_Data  <= sig_data_reg_out;
   M_User  <= sig_user_reg_out;

  -- Special shutdown logic version od Slast.
  -- A halt request forces a tlast through the skig buffer
  sig_slast_with_stop <= s_last or sig_stop_request;
  sig_sstrb_with_stop <= s_strb or sig_sstrb_stop_mask;
  -- Assign the special S_READY FLOP set signal
  sig_spcl_s_ready_set <= sig_reset_reg;


  -- Generate the ouput register load enable control
   sig_data_reg_out_en <= M_READY or not(sig_m_valid_dup);

  -- Generate the skid input register load enable control
   sig_skid_reg_en     <= sig_s_ready_dup;

  -- Generate the skid mux select control
   sig_skid_mux_sel    <= not(sig_s_ready_dup);


 -- Skid Mux
   sig_data_skid_mux_out <=  sig_data_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_Data;

   sig_user_skid_mux_out <= sig_user_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_User;


   sig_strb_skid_mux_out <=  sig_strb_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  sig_sstrb_with_stop;

   sig_last_skid_mux_out <=  sig_last_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  sig_slast_with_stop;


   -- m_valid combinational logic
   sig_m_valid_comb <= S_VALID or
                      (sig_m_valid_dup and
                      (not(sig_s_ready_dup) or
                       not(M_READY)));



   -- s_ready combinational logic
   sig_s_ready_comb <= M_READY or
                      (sig_s_ready_dup and
                      (not(sig_m_valid_dup) or
                       not(S_VALID)));



   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: REG_THE_RST
   --
   -- Process Description:
   -- Register input reset
   --
   -------------------------------------------------------------
   REG_THE_RST : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then

            sig_reset_reg <= ARST;

        end if;
      end process REG_THE_RST;




   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: S_READY_FLOP
   --
   -- Process Description:
   -- Registers S_READY handshake signals per Skid Buffer
   -- Option 2 scheme
   --
   -------------------------------------------------------------
   S_READY_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST            = '1' or
               sig_sready_stop = '1') then  -- Special stop condition

             sig_s_ready_out  <= '0';
             sig_s_ready_dup  <= '0';

           Elsif (sig_spcl_s_ready_set = '1') Then

             sig_s_ready_out  <= '1';
             sig_s_ready_dup  <= '1';

           else

             sig_s_ready_out  <= sig_s_ready_comb;
             sig_s_ready_dup  <= sig_s_ready_comb;

           end if;
        end if;
      end process S_READY_FLOP;






   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: M_VALID_FLOP
   --
   -- Process Description:
   -- Registers M_VALID handshake signals per Skid Buffer
   -- Option 2 scheme
   --
   -------------------------------------------------------------
   M_VALID_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST                 = '1' or
               sig_spcl_s_ready_set = '1' or    -- Fix from AXI DMA
               sig_mvalid_stop      = '1') then -- Special stop condition
             sig_m_valid_out  <= '0';
             sig_m_valid_dup  <= '0';

           else

             sig_m_valid_out  <= sig_m_valid_comb;
             sig_m_valid_dup  <= sig_m_valid_comb;

           end if;
        end if;
      end process M_VALID_FLOP;






   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: SKID_REG
   --
   -- Process Description:
   -- This process implements the output registers for the
   -- Skid Buffer Data signals
   --
   -------------------------------------------------------------
   SKID_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_data_skid_reg <= (others => '0');
             sig_strb_skid_reg <= (others => '0');
             sig_last_skid_reg <= '0';
             sig_user_skid_reg <= (others => '0');

           elsif (sig_skid_reg_en = '1') then

             sig_data_skid_reg <= S_Data;
             sig_strb_skid_reg <= sig_sstrb_with_stop;
             sig_last_skid_reg <= sig_slast_with_stop;
             sig_user_skid_reg <= S_User;
           else
             null;  -- hold current state
           end if;
        end if;
      end process SKID_REG;





   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: OUTPUT_REG
   --
   -- Process Description:
   -- This process implements the output registers for the
   -- Skid Buffer Data signals
   --
   -------------------------------------------------------------
   OUTPUT_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST                = '1' or
               sig_mvalid_stop_reg = '1') then

             sig_data_reg_out <= (others => '0');
             sig_strb_reg_out <= (others => '0');
             sig_last_reg_out <= '0';
             sig_user_reg_out <= (others => '0');

           elsif (sig_data_reg_out_en = '1') then

             sig_data_reg_out <= sig_data_skid_mux_out;
             sig_strb_reg_out <= sig_strb_skid_mux_out;
             sig_last_reg_out <= sig_last_skid_mux_out;
             sig_user_reg_out <= sig_user_skid_mux_out;

           else
             null;  -- hold current state
           end if;
        end if;
      end process OUTPUT_REG;




   -------- Special Stop Logic --------------------------------------


   sig_s_last_xfered  <=  sig_s_ready_dup and
                          s_valid         and
                          sig_slast_with_stop;


   sig_sready_stop    <=  (sig_s_last_xfered and
                          sig_stop_request) or
                          sig_sready_stop_reg;






   sig_m_last_xfered  <=  sig_m_valid_dup and
                          m_ready         and
                          sig_last_reg_out;


   sig_mvalid_stop    <=  (sig_m_last_xfered and
                          sig_stop_request)  or
                          sig_mvalid_stop_reg;




   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_STOP_REQ_FLOP
   --
   -- Process Description:
   -- This process implements the Stop request flop. It is a
   -- sample and hold register that can only be cleared by reset.
   --
   -------------------------------------------------------------
   IMP_STOP_REQ_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_stop_request <= '0';
             sig_sstrb_stop_mask <= (others => '0');

           elsif (skid_stop = '1') then

             sig_stop_request <= '1';
             sig_sstrb_stop_mask <= (others => '1');

           else
             null;  -- hold current state
           end if;
        end if;
      end process IMP_STOP_REQ_FLOP;









   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_CLR_SREADY_FLOP
   --
   -- Process Description:
   -- This process implements the flag to clear the s_ready
   -- flop at a stop condition.
   --
   -------------------------------------------------------------
   IMP_CLR_SREADY_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_sready_stop_reg <= '0';

           elsif (sig_s_last_xfered = '1' and
                  sig_stop_request  = '1') then

             sig_sready_stop_reg <= '1';

           else
             null;  -- hold current state
           end if;
        end if;
      end process IMP_CLR_SREADY_FLOP;





   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_CLR_MREADY_FLOP
   --
   -- Process Description:
   -- This process implements the flag to clear the m_ready
   -- flop at a stop condition.
   --
   -------------------------------------------------------------
   IMP_CLR_MVALID_FLOP : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then

             sig_mvalid_stop_reg <= '0';

           elsif (sig_m_last_xfered = '1' and
                  sig_stop_request  = '1') then

             sig_mvalid_stop_reg <= '1';

           else
             null;  -- hold current state
           end if;
        end if;
      end process IMP_CLR_MVALID_FLOP;



end implementation;
