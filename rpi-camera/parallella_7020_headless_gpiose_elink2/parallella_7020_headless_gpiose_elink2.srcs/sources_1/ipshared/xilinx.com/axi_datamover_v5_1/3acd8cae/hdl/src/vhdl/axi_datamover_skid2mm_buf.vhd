-------------------------------------------------------------------------------
-- axi_datamover_skid2mm_buf.vhd
-------------------------------------------------------------------------------
--
-- *************************************************************************
--                                                                      
--  (c) Copyright 2010-2011 Xilinx, Inc. All rights reserved.
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
-- Filename:        axi_datamover_skid2mm_buf.vhd
--
-- Description:     
--  Implements the AXi Skid Buffer in the Option 2 (Registerd outputs) mode.                
--
--  This Module also provides Write Data Bus Mirroring and WSTRB
--  Demuxing to match a narrow Stream to a wider MMap Write 
--  Channel. By doing this in the skid buffer, the resource 
--  utilization of the skid buffer can be minimized by only
--  having to buffer/mux the Stream data width, not the MMap
--  Data width.   
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;


library axi_datamover_v5_1; 
use axi_datamover_v5_1.axi_datamover_wr_demux;

-------------------------------------------------------------------------------

entity axi_datamover_skid2mm_buf is
  generic (
    
    C_MDATA_WIDTH         : INTEGER range 32 to 1024 := 32 ;
       --  Width of the MMap Write Data bus (in bits)
    C_SDATA_WIDTH         : INTEGER range 8 to 1024 := 32 ;
       --  Width of the Stream Data bus (in bits)
    C_ADDR_LSB_WIDTH      : INTEGER range 1 to 8 := 5
       --  Width of the LS address bus needed to Demux the WSTRB
       
    );
  port (
     
     -- Clock and Reset Inputs -------------------------------------------
                                                                        --
     ACLK         : In  std_logic ;                                     --
     ARST         : In  std_logic ;                                     --
     ---------------------------------------------------------------------
     
      
     -- Slave Side (Wr Data Controller Input Side) -----------------------
                                                                        --
     S_ADDR_LSB   : in  std_logic_vector(C_ADDR_LSB_WIDTH-1 downto 0);  --
     S_VALID      : In  std_logic ;                                     --
     S_READY      : Out std_logic ;                                     --
     S_DATA       : In  std_logic_vector(C_SDATA_WIDTH-1 downto 0);     --
     S_STRB       : In  std_logic_vector((C_SDATA_WIDTH/8)-1 downto 0); --
     S_LAST       : In  std_logic ;                                     --
     ---------------------------------------------------------------------
     

     -- Master Side (MMap Write Data Output Side) ------------------------
     M_VALID      : Out std_logic ;                                     --
     M_READY      : In  std_logic ;                                     --
     M_DATA       : Out std_logic_vector(C_MDATA_WIDTH-1 downto 0);     --
     M_STRB       : Out std_logic_vector((C_MDATA_WIDTH/8)-1 downto 0); --
     M_LAST       : Out std_logic                                       --
     ---------------------------------------------------------------------
     
    );

end entity axi_datamover_skid2mm_buf;


architecture implementation of axi_datamover_skid2mm_buf is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";


  Constant IN_DATA_WIDTH       : integer := C_SDATA_WIDTH;
  Constant MM2STRM_WIDTH_RATIO : integer := C_MDATA_WIDTH/C_SDATA_WIDTH;
  
  
-- Signals decalrations -------------------------

  Signal sig_reset_reg         : std_logic := '0';
  signal sig_spcl_s_ready_set  : std_logic := '0';
  signal sig_data_skid_reg     : std_logic_vector(IN_DATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_skid_reg     : std_logic_vector((C_MDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_skid_reg     : std_logic := '0';
  signal sig_skid_reg_en       : std_logic := '0';
  signal sig_data_skid_mux_out : std_logic_vector(IN_DATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_skid_mux_out : std_logic_vector((C_MDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_skid_mux_out : std_logic := '0';
  signal sig_skid_mux_sel      : std_logic := '0';
  signal sig_data_reg_out      : std_logic_vector(IN_DATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_strb_reg_out      : std_logic_vector((C_MDATA_WIDTH/8)-1 downto 0) := (others => '0');
  signal sig_last_reg_out      : std_logic := '0';
  signal sig_data_reg_out_en   : std_logic := '0';
  signal sig_m_valid_out       : std_logic := '0';
  signal sig_m_valid_dup       : std_logic := '0';
  signal sig_m_valid_comb      : std_logic := '0';
  signal sig_s_ready_out       : std_logic := '0';
  signal sig_s_ready_dup       : std_logic := '0';
  signal sig_s_ready_comb      : std_logic := '0';
  signal sig_mirror_data_out   : std_logic_vector(C_MDATA_WIDTH-1 downto 0) := (others => '0');
  signal sig_wstrb_demux_out   : std_logic_vector((C_MDATA_WIDTH/8)-1 downto 0) := (others => '0');
                                         
                                         
                                         
 
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
   M_LAST  <= sig_last_reg_out;                
   M_DATA  <= sig_mirror_data_out;
            
   -- Assign the special S_READY FLOP set signal
   sig_spcl_s_ready_set <= sig_reset_reg;
  
            
   -- Generate the ouput register load enable control
   sig_data_reg_out_en <= M_READY or not(sig_m_valid_dup);

   -- Generate the skid inpit register load enable control
   sig_skid_reg_en     <= sig_s_ready_dup;
  
   -- Generate the skid mux select control
   sig_skid_mux_sel    <= not(sig_s_ready_dup);
   
   
   -- Skid Mux  
   sig_data_skid_mux_out <=  sig_data_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_DATA;
  
   sig_strb_skid_mux_out <=  sig_strb_skid_reg
     When (sig_skid_mux_sel = '1')
     --Else  S_STRB;
     Else  sig_wstrb_demux_out;
  
   sig_last_skid_mux_out <=  sig_last_skid_reg
     When (sig_skid_mux_sel = '1')
     Else  S_LAST;
  
   
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
           if (ARST = '1') then

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
               sig_spcl_s_ready_set = '1') then -- Fix from AXI DMA

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
   -- Label: SKID_DATA_REG
   --
   -- Process Description:
   -- This process implements the Skid register for the 
   -- Skid Buffer Data signals.
   --
   -------------------------------------------------------------
   SKID_DATA_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           
           if  (sig_skid_reg_en = '1') then
             
             sig_data_skid_reg <= S_DATA;
             
           else
             null;  -- hold current state
           end if;
            
        end if;       
      end process SKID_DATA_REG; 
            
            
   
            
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: SKID_CNTL_REG
   --
   -- Process Description:
   -- This process implements the Output registers for the 
   -- Skid Buffer Control signals
   --
   -------------------------------------------------------------
   SKID_CNTL_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then
             
             sig_strb_skid_reg <= (others => '0');
             sig_last_skid_reg <= '0';
             
           elsif (sig_skid_reg_en = '1') then
             
             sig_strb_skid_reg <= sig_wstrb_demux_out;
             sig_last_skid_reg <= S_LAST;
             
           else
             null;  -- hold current state
           end if; 
        end if;       
      end process SKID_CNTL_REG; 
            
            
   
            
            
            
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: OUTPUT_DATA_REG
   --
   -- Process Description:
   -- This process implements the Output register for the 
   -- Data signals.
   --
   -------------------------------------------------------------
   OUTPUT_DATA_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           
           if (sig_data_reg_out_en = '1') then
             
             sig_data_reg_out <= sig_data_skid_mux_out;
             
           else
             null;  -- hold current state
           end if;
            
        end if;       
      end process OUTPUT_DATA_REG; 
            
            
 
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: OUTPUT_CNTL_REG
   --
   -- Process Description:
   -- This process implements the Output registers for the 
   -- control signals.
   --
   -------------------------------------------------------------
   OUTPUT_CNTL_REG : process (ACLK)
      begin
        if (ACLK'event and ACLK = '1') then
           if (ARST = '1') then
             
             sig_strb_reg_out <= (others => '0');
             sig_last_reg_out <= '0';
             
           elsif (sig_data_reg_out_en = '1') then
             
             sig_strb_reg_out <= sig_strb_skid_mux_out;
             sig_last_reg_out <= sig_last_skid_mux_out;
             
           else
             null;  -- hold current state
           end if; 
        end if;       
      end process OUTPUT_CNTL_REG; 
            
            
 
 
 
 
 
 
   -------------------------------------------------------------
   -- Combinational Process
   --
   -- Label: DO_WR_DATA_MIRROR
   --
   -- Process Description:
   -- Implement the Write Data Mirror structure
   -- 
   -- Note that it is required that the Stream Width be less than
   -- or equal to the MMap WData width.
   --
   -------------------------------------------------------------
   DO_WR_DATA_MIRROR : process (sig_data_reg_out)
      begin
   
        for slice_index in 0 to MM2STRM_WIDTH_RATIO-1 loop
        
          sig_mirror_data_out(((C_SDATA_WIDTH*slice_index)+C_SDATA_WIDTH)-1 
                              downto C_SDATA_WIDTH*slice_index)
                              
                              <= sig_data_reg_out;
        
        end loop;
 
   
      end process DO_WR_DATA_MIRROR; 
   
 
 
 
 
        
    ------------------------------------------------------------
    -- Instance: I_WSTRB_DEMUX 
    --
    -- Description:
    -- Instance for the Write Strobe DeMux.    
    --
    ------------------------------------------------------------
     I_WSTRB_DEMUX : entity axi_datamover_v5_1.axi_datamover_wr_demux
     generic map (
      
       C_SEL_ADDR_WIDTH     =>  C_ADDR_LSB_WIDTH   ,  
       C_MMAP_DWIDTH        =>  C_MDATA_WIDTH      ,  
       C_STREAM_DWIDTH      =>  C_SDATA_WIDTH         
      
       )
     port map (
   
       wstrb_in             =>  S_STRB              , 
       demux_wstrb_out      =>  sig_wstrb_demux_out ,        
       debeat_saddr_lsb     =>  S_ADDR_LSB            
   
       );
   
 
 

end implementation;
