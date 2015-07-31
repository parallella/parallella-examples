  -------------------------------------------------------------------------------
  -- axi_datamover_rdmux.vhd
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
  -- Filename:        axi_datamover_rdmux.vhd
  --
  -- Description:     
  --    This file implements the DataMover Master Read Data Multiplexer.                 
  --                  
  --                  
  --                  
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_rdmux is
    generic (
      
      C_SEL_ADDR_WIDTH     : Integer range 1  to   8 :=  5;
        -- Sets the width of the select control bus
      
      C_MMAP_DWIDTH        : Integer range 32 to 1024 := 32;
        -- Indicates the width of the AXI4 Data Channel
      
      C_STREAM_DWIDTH      : Integer range  8 to 1024 := 32
        -- Indicates the width of the AXI Stream Data Channel
      
      );
    port (
      
     
      -- AXI MMap Data Channel Input  -----------------------------------------------
                                                                                   --
      mmap_read_data_in         : In  std_logic_vector(C_MMAP_DWIDTH-1 downto 0);  --
        -- AXI Read data input                                                     --
      -------------------------------------------------------------------------------
      
      
      -- AXI Master Stream  ---------------------------------------------------------
                                                                                   --
      mux_data_out    : Out std_logic_vector(C_STREAM_DWIDTH-1 downto 0);          --
        --Mux data output                                                          --
      -------------------------------------------------------------------------------         
                
                
      -- Command Calculator Interface -----------------------------------------------
                                                                                   --
      mstr2data_saddr_lsb : In std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0)       --
         -- The next command start address LSbs to use for the read data           --
         -- mux (only used if Stream data width is less than the MMap Data         --
         -- Width).                                                                --
      -------------------------------------------------------------------------------
         
      );
  
  end entity axi_datamover_rdmux;
  
  
  architecture implementation of axi_datamover_rdmux is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    -- Function Decalarations -------------------------------------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_mux_sel_width
    --
    -- Function Description:
    --   Calculates the number of needed bits for the Mux Select control
    -- based on the number of input channels to the mux.
    --
    -- Note that the number of input mux channels are always a 
    -- power of 2.
    --
    -------------------------------------------------------------------
    function func_mux_sel_width (num_channels : integer) return integer is
    
     Variable var_sel_width : integer := 0;
    
    begin
    
       case num_channels is
         when 2 =>
             var_sel_width := 1;
         when 4 =>
             var_sel_width := 2;
         when 8 =>
             var_sel_width := 3;
         when 16 =>
             var_sel_width := 4;
         when 32 =>
             var_sel_width := 5;
         when 64 =>
             var_sel_width := 6;
         when 128 =>
             var_sel_width := 7;
         
         when others => 
             var_sel_width := 0; 
       end case;
       
       Return (var_sel_width);
        
        
    end function func_mux_sel_width;
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_sel_ls_index
    --
    -- Function Description:
    --   Calculates the LS index of the select field to rip from the
    -- input select bus.
    --
    -- Note that the number of input mux channels are always a 
    -- power of 2.
    --
    -------------------------------------------------------------------
    function func_sel_ls_index (channel_width : integer) return integer is
    
     Variable var_sel_ls_index : integer := 0;
    
    begin
    
       case channel_width is
         when 8 => 
             var_sel_ls_index := 0;
         when 16 =>
             var_sel_ls_index := 1;
         when 32 =>
             var_sel_ls_index := 2;
         when 64 =>
             var_sel_ls_index := 3;
         when 128 =>
             var_sel_ls_index := 4;
         when 256 =>
             var_sel_ls_index := 5;
         when 512 =>
             var_sel_ls_index := 6;
         
         when others => -- 1024-bit channel case
             var_sel_ls_index := 7;
       end case;
       
       Return (var_sel_ls_index);
        
        
    end function func_sel_ls_index;
    
    
    
    
    
    -- Constant Decalarations -------------------------------------------------
    
    Constant CHANNEL_DWIDTH   : integer := C_STREAM_DWIDTH;
    Constant NUM_MUX_CHANNELS : integer := C_MMAP_DWIDTH/CHANNEL_DWIDTH;
    Constant MUX_SEL_WIDTH    : integer := func_mux_sel_width(NUM_MUX_CHANNELS);
    Constant MUX_SEL_LS_INDEX : integer := func_sel_ls_index(CHANNEL_DWIDTH);
    
    
    
    
    -- Signal Declarations  --------------------------------------------
 
    signal sig_rdmux_dout     : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');



    
  begin --(architecture implementation)
  
  
  
  
   -- Assign the Output data port 
    mux_data_out        <= sig_rdmux_dout;
  
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_STRM_EQ_MMAP
    --
    -- If Generate Description:
    --   This IfGen implements the case where the Stream Data Width is 
    -- the same as the Memory Map read Data width.
    --
    --
    ------------------------------------------------------------
    GEN_STRM_EQ_MMAP : if (NUM_MUX_CHANNELS = 1) generate
        
       begin
    
          sig_rdmux_dout <= mmap_read_data_in;
        
       end generate GEN_STRM_EQ_MMAP;
   
   
    
    
    
     
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_2XN
    --
    -- If Generate Description:
    --  2 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_2XN : if (NUM_MUX_CHANNELS = 2) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice   <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd  <=  UNSIGNED(sig_mux_sel_slice);  -- convert to unsigned
        
         sig_mux_sel_int     <=  TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_2XN_NUX
         --
         -- Process Description:
         --  Implement the 2XN Mux
         --
         -------------------------------------------------------------
         DO_2XN_NUX : process (sig_mux_sel_int_local,
                               mmap_read_data_in)
            begin
              
              case sig_mux_sel_int_local is
                when 0 =>
                    sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
                
                when others => -- 1 case
                    sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
              end case;
              
            end process DO_2XN_NUX; 
 
         
       end generate GEN_2XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_4XN
    --
    -- If Generate Description:
    --  4 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_4XN : if (NUM_MUX_CHANNELS = 4) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice     <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd    <= UNSIGNED(sig_mux_sel_slice);    -- convert to unsigned
        
         sig_mux_sel_int       <= TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                  -- with locally static subtype error in each of the
                                                                  -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_4XN_NUX
         --
         -- Process Description:
         --  Implement the 4XN Mux
         --
         -------------------------------------------------------------
         DO_4XN_NUX : process (sig_mux_sel_int_local,
                               mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 0 =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               
               when others => -- 3 case
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
             end case;
             
           end process DO_4XN_NUX; 
  
         
       end generate GEN_4XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_8XN
    --
    -- If Generate Description:
    --  8 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_8XN : if (NUM_MUX_CHANNELS = 8) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice     <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd    <= UNSIGNED(sig_mux_sel_slice);    -- convert to unsigned
        
         sig_mux_sel_int       <= TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                  -- with locally static subtype error in each of the
                                                                  -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_8XN_NUX
         --
         -- Process Description:
         --  Implement the 8XN Mux
         --
         -------------------------------------------------------------
         DO_8XN_NUX : process (sig_mux_sel_int_local,
                               mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 0 =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when 4 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4);
               when 5 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5);
               when 6 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6);
               
               when others =>  -- 7 case
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7);
             end case;
                 
           end process DO_8XN_NUX; 
 
         
       end generate GEN_8XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_16XN
    --
    -- If Generate Description:
    --  16 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_16XN : if (NUM_MUX_CHANNELS = 16) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice     <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd    <= UNSIGNED(sig_mux_sel_slice);    -- convert to unsigned
        
         sig_mux_sel_int       <= TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                  -- with locally static subtype error in each of the
                                                                  -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_16XN_NUX
         --
         -- Process Description:
         --  Implement the 16XN Mux
         --
         -------------------------------------------------------------
         DO_16XN_NUX : process (sig_mux_sel_int_local,
                                mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               when 0 =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when 4 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4);
               when 5 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5);
               when 6 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6);
               when 7 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7);
               when 8 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*9)-1 downto CHANNEL_DWIDTH*8);
               when 9 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*10)-1 downto CHANNEL_DWIDTH*9);
               when 10 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*11)-1 downto CHANNEL_DWIDTH*10);
               when 11 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*12)-1 downto CHANNEL_DWIDTH*11);
               when 12 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*13)-1 downto CHANNEL_DWIDTH*12);
               when 13 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*14)-1 downto CHANNEL_DWIDTH*13);
               when 14 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*15)-1 downto CHANNEL_DWIDTH*14);
               
               when others => -- 15 case
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*16)-1 downto CHANNEL_DWIDTH*15);
             end case;
          
           end process DO_16XN_NUX; 
 
         
       end generate GEN_16XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_32XN
    --
    -- If Generate Description:
    --  32 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_32XN : if (NUM_MUX_CHANNELS = 32) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice     <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd    <= UNSIGNED(sig_mux_sel_slice);    -- convert to unsigned
        
         sig_mux_sel_int       <= TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                  -- with locally static subtype error in each of the
                                                                  -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_32XN_NUX
         --
         -- Process Description:
         --  Implement the 32XN Mux
         --
         -------------------------------------------------------------
         DO_32XN_NUX : process (sig_mux_sel_int_local,
                                mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               
               when 0 =>
                   sig_mux_dout <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0);
               when 1 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1);
               when 2 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2);
               when 3 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3);
               when 4 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4);
               when 5 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5);
               when 6 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6);
               when 7 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7);
               when 8 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*9)-1 downto CHANNEL_DWIDTH*8);
               when 9 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*10)-1 downto CHANNEL_DWIDTH*9);
               when 10 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*11)-1 downto CHANNEL_DWIDTH*10);
               when 11 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*12)-1 downto CHANNEL_DWIDTH*11);
               when 12 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*13)-1 downto CHANNEL_DWIDTH*12);
               when 13 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*14)-1 downto CHANNEL_DWIDTH*13);
               when 14 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*15)-1 downto CHANNEL_DWIDTH*14);
               when 15 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*16)-1 downto CHANNEL_DWIDTH*15);
               when 16 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*17)-1 downto CHANNEL_DWIDTH*16);
               when 17 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*18)-1 downto CHANNEL_DWIDTH*17);
               when 18 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*19)-1 downto CHANNEL_DWIDTH*18);
               when 19 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*20)-1 downto CHANNEL_DWIDTH*19);
               when 20 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*21)-1 downto CHANNEL_DWIDTH*20);
               when 21 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*22)-1 downto CHANNEL_DWIDTH*21);
               when 22 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*23)-1 downto CHANNEL_DWIDTH*22);
               when 23 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*24)-1 downto CHANNEL_DWIDTH*23);
               when 24 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*25)-1 downto CHANNEL_DWIDTH*24);
               when 25 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*26)-1 downto CHANNEL_DWIDTH*25);
               when 26 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*27)-1 downto CHANNEL_DWIDTH*26);
               when 27 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*28)-1 downto CHANNEL_DWIDTH*27);
               when 28 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*29)-1 downto CHANNEL_DWIDTH*28);
               when 29 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*30)-1 downto CHANNEL_DWIDTH*29);
               when 30 =>
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*31)-1 downto CHANNEL_DWIDTH*30);
               
               when others => -- 31 case
                   sig_mux_dout <=  mmap_read_data_in((CHANNEL_DWIDTH*32)-1 downto CHANNEL_DWIDTH*31);
             end case;
          
           end process DO_32XN_NUX; 
 
         
       end generate GEN_32XN;
  
 
 
 
 
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_64XN
    --
    -- If Generate Description:
    --  64 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_64XN : if (NUM_MUX_CHANNELS = 64) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0)          := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice     <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd    <= UNSIGNED(sig_mux_sel_slice);    -- convert to unsigned
        
         sig_mux_sel_int       <= TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                  -- with locally static subtype error in each of the
                                                                  -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_64XN_NUX
         --
         -- Process Description:
         --  Implement the 64XN Mux
         --
         -------------------------------------------------------------
         DO_64XN_NUX : process (sig_mux_sel_int_local,
                                mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
             
               when 0 =>
                   sig_mux_dout  <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0)                     ;
               when 1 =>
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1)  ;
               when 2 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2)  ;
               when 3 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3)  ;
               when 4 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4)  ;
               when 5 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5)  ;
               when 6 =>                                                               
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6)  ;
               when 7 =>                                                               
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7)  ;
               when 8 =>                                                               
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*9)-1 downto CHANNEL_DWIDTH*8)  ;
               when 9 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*10)-1 downto CHANNEL_DWIDTH*9) ;
               when 10 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*11)-1 downto CHANNEL_DWIDTH*10);
               when 11 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*12)-1 downto CHANNEL_DWIDTH*11);
               when 12 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*13)-1 downto CHANNEL_DWIDTH*12);
               when 13 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*14)-1 downto CHANNEL_DWIDTH*13);
               when 14 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*15)-1 downto CHANNEL_DWIDTH*14);
               when 15 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*16)-1 downto CHANNEL_DWIDTH*15);
               when 16 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*17)-1 downto CHANNEL_DWIDTH*16);
               when 17 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*18)-1 downto CHANNEL_DWIDTH*17);
               when 18 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*19)-1 downto CHANNEL_DWIDTH*18);
               when 19 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*20)-1 downto CHANNEL_DWIDTH*19);
               when 20 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*21)-1 downto CHANNEL_DWIDTH*20);
               when 21 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*22)-1 downto CHANNEL_DWIDTH*21);
               when 22 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*23)-1 downto CHANNEL_DWIDTH*22);
               when 23 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*24)-1 downto CHANNEL_DWIDTH*23);
               when 24 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*25)-1 downto CHANNEL_DWIDTH*24);
               when 25 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*26)-1 downto CHANNEL_DWIDTH*25);
               when 26 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*27)-1 downto CHANNEL_DWIDTH*26);
               when 27 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*28)-1 downto CHANNEL_DWIDTH*27);
               when 28 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*29)-1 downto CHANNEL_DWIDTH*28);
               when 29 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*30)-1 downto CHANNEL_DWIDTH*29);
               when 30 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*31)-1 downto CHANNEL_DWIDTH*30);
               when 31 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*32)-1 downto CHANNEL_DWIDTH*31);
             
             
               when 32 =>
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*33)-1 downto CHANNEL_DWIDTH*32);
               when 33 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*34)-1 downto CHANNEL_DWIDTH*33);
               when 34 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*35)-1 downto CHANNEL_DWIDTH*34);
               when 35 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*36)-1 downto CHANNEL_DWIDTH*35);
               when 36 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*37)-1 downto CHANNEL_DWIDTH*36);
               when 37 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*38)-1 downto CHANNEL_DWIDTH*37);
               when 38 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*39)-1 downto CHANNEL_DWIDTH*38);
               when 39 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*40)-1 downto CHANNEL_DWIDTH*39);
               when 40 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*41)-1 downto CHANNEL_DWIDTH*40);
               when 41 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*42)-1 downto CHANNEL_DWIDTH*41);
               when 42 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*43)-1 downto CHANNEL_DWIDTH*42);
               when 43 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*44)-1 downto CHANNEL_DWIDTH*43);
               when 44 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*45)-1 downto CHANNEL_DWIDTH*44);
               when 45 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*46)-1 downto CHANNEL_DWIDTH*45);
               when 46 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*47)-1 downto CHANNEL_DWIDTH*46);
               when 47 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*48)-1 downto CHANNEL_DWIDTH*47);
               when 48 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*49)-1 downto CHANNEL_DWIDTH*48);
               when 49 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*50)-1 downto CHANNEL_DWIDTH*49);
               when 50 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*51)-1 downto CHANNEL_DWIDTH*50);
               when 51 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*52)-1 downto CHANNEL_DWIDTH*51);
               when 52 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*53)-1 downto CHANNEL_DWIDTH*52);
               when 53 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*54)-1 downto CHANNEL_DWIDTH*53);
               when 54 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*55)-1 downto CHANNEL_DWIDTH*54);
               when 55 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*56)-1 downto CHANNEL_DWIDTH*55);
               when 56 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*57)-1 downto CHANNEL_DWIDTH*56);
               when 57 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*58)-1 downto CHANNEL_DWIDTH*57);
               when 58 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*59)-1 downto CHANNEL_DWIDTH*58);
               when 59 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*60)-1 downto CHANNEL_DWIDTH*59);
               when 60 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*61)-1 downto CHANNEL_DWIDTH*60);
               when 61 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*62)-1 downto CHANNEL_DWIDTH*61);
               when 62 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*63)-1 downto CHANNEL_DWIDTH*62);
               
               when others => -- 63 case
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*64)-1 downto CHANNEL_DWIDTH*63);
             
             end case;
          
           end process DO_64XN_NUX; 
 
         
       end generate GEN_64XN;
  
 
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_128XN
    --
    -- If Generate Description:
    --  128 channel input mux case
    --
    --
    ------------------------------------------------------------
    GEN_128XN : if (NUM_MUX_CHANNELS = 128) generate
    
       -- local signals
       signal sig_mux_sel_slice     : std_logic_vector(MUX_SEL_WIDTH-1 downto 0)  := (others => '0');
       signal sig_mux_sel_unsgnd    : unsigned(MUX_SEL_WIDTH-1 downto 0)          := (others => '0');
       signal sig_mux_sel_int       : integer := 0;
       signal sig_mux_sel_int_local : integer := 0;
       signal sig_mux_dout          : std_logic_vector(CHANNEL_DWIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_mux_sel_slice     <= mstr2data_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_mux_sel_unsgnd    <= UNSIGNED(sig_mux_sel_slice);    -- convert to unsigned
        
         sig_mux_sel_int       <= TO_INTEGER(sig_mux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                  -- with locally static subtype error in each of the
                                                                  -- Mux IfGens
        
         sig_mux_sel_int_local <= sig_mux_sel_int;
         
         sig_rdmux_dout        <= sig_mux_dout;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_128XN_NUX
         --
         -- Process Description:
         --  Implement the 64XN Mux
         --
         -------------------------------------------------------------
         DO_128XN_NUX : process (sig_mux_sel_int_local,
                                 mmap_read_data_in)
           begin
             
             case sig_mux_sel_int_local is
               
               when 0 =>
                   sig_mux_dout  <=  mmap_read_data_in(CHANNEL_DWIDTH-1 downto 0)                     ;
               when 1 =>
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*2)-1 downto CHANNEL_DWIDTH*1)  ;
               when 2 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*3)-1 downto CHANNEL_DWIDTH*2)  ;
               when 3 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*4)-1 downto CHANNEL_DWIDTH*3)  ;
               when 4 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*5)-1 downto CHANNEL_DWIDTH*4)  ;
               when 5 =>                                                              
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*6)-1 downto CHANNEL_DWIDTH*5)  ;
               when 6 =>                                                               
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*7)-1 downto CHANNEL_DWIDTH*6)  ;
               when 7 =>                                                               
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*8)-1 downto CHANNEL_DWIDTH*7)  ;
               when 8 =>                                                               
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*9)-1 downto CHANNEL_DWIDTH*8)  ;
               when 9 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*10)-1 downto CHANNEL_DWIDTH*9) ;
               when 10 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*11)-1 downto CHANNEL_DWIDTH*10);
               when 11 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*12)-1 downto CHANNEL_DWIDTH*11);
               when 12 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*13)-1 downto CHANNEL_DWIDTH*12);
               when 13 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*14)-1 downto CHANNEL_DWIDTH*13);
               when 14 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*15)-1 downto CHANNEL_DWIDTH*14);
               when 15 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*16)-1 downto CHANNEL_DWIDTH*15);
               when 16 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*17)-1 downto CHANNEL_DWIDTH*16);
               when 17 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*18)-1 downto CHANNEL_DWIDTH*17);
               when 18 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*19)-1 downto CHANNEL_DWIDTH*18);
               when 19 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*20)-1 downto CHANNEL_DWIDTH*19);
               when 20 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*21)-1 downto CHANNEL_DWIDTH*20);
               when 21 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*22)-1 downto CHANNEL_DWIDTH*21);
               when 22 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*23)-1 downto CHANNEL_DWIDTH*22);
               when 23 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*24)-1 downto CHANNEL_DWIDTH*23);
               when 24 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*25)-1 downto CHANNEL_DWIDTH*24);
               when 25 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*26)-1 downto CHANNEL_DWIDTH*25);
               when 26 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*27)-1 downto CHANNEL_DWIDTH*26);
               when 27 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*28)-1 downto CHANNEL_DWIDTH*27);
               when 28 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*29)-1 downto CHANNEL_DWIDTH*28);
               when 29 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*30)-1 downto CHANNEL_DWIDTH*29);
               when 30 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*31)-1 downto CHANNEL_DWIDTH*30);
               when 31 =>                                                           
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*32)-1 downto CHANNEL_DWIDTH*31);
             
             
               when 32 =>
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*33)-1 downto CHANNEL_DWIDTH*32);
               when 33 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*34)-1 downto CHANNEL_DWIDTH*33);
               when 34 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*35)-1 downto CHANNEL_DWIDTH*34);
               when 35 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*36)-1 downto CHANNEL_DWIDTH*35);
               when 36 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*37)-1 downto CHANNEL_DWIDTH*36);
               when 37 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*38)-1 downto CHANNEL_DWIDTH*37);
               when 38 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*39)-1 downto CHANNEL_DWIDTH*38);
               when 39 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*40)-1 downto CHANNEL_DWIDTH*39);
               when 40 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*41)-1 downto CHANNEL_DWIDTH*40);
               when 41 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*42)-1 downto CHANNEL_DWIDTH*41);
               when 42 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*43)-1 downto CHANNEL_DWIDTH*42);
               when 43 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*44)-1 downto CHANNEL_DWIDTH*43);
               when 44 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*45)-1 downto CHANNEL_DWIDTH*44);
               when 45 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*46)-1 downto CHANNEL_DWIDTH*45);
               when 46 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*47)-1 downto CHANNEL_DWIDTH*46);
               when 47 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*48)-1 downto CHANNEL_DWIDTH*47);
               when 48 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*49)-1 downto CHANNEL_DWIDTH*48);
               when 49 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*50)-1 downto CHANNEL_DWIDTH*49);
               when 50 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*51)-1 downto CHANNEL_DWIDTH*50);
               when 51 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*52)-1 downto CHANNEL_DWIDTH*51);
               when 52 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*53)-1 downto CHANNEL_DWIDTH*52);
               when 53 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*54)-1 downto CHANNEL_DWIDTH*53);
               when 54 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*55)-1 downto CHANNEL_DWIDTH*54);
               when 55 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*56)-1 downto CHANNEL_DWIDTH*55);
               when 56 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*57)-1 downto CHANNEL_DWIDTH*56);
               when 57 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*58)-1 downto CHANNEL_DWIDTH*57);
               when 58 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*59)-1 downto CHANNEL_DWIDTH*58);
               when 59 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*60)-1 downto CHANNEL_DWIDTH*59);
               when 60 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*61)-1 downto CHANNEL_DWIDTH*60);
               when 61 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*62)-1 downto CHANNEL_DWIDTH*61);
               when 62 =>                                                            
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*63)-1 downto CHANNEL_DWIDTH*62);
               when 63 => 
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*64)-1 downto CHANNEL_DWIDTH*63);
             
             
               when 64 =>
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*65)-1 downto CHANNEL_DWIDTH*64) ;
               when 65 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*66)-1 downto CHANNEL_DWIDTH*65) ;
               when 66 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*67)-1 downto CHANNEL_DWIDTH*66) ;
               when 67 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*68)-1 downto CHANNEL_DWIDTH*67) ;
               when 68 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*69)-1 downto CHANNEL_DWIDTH*68) ;
               when 69 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*70)-1 downto CHANNEL_DWIDTH*69) ;
               when 70 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*71)-1 downto CHANNEL_DWIDTH*70) ;
               when 71 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*72)-1 downto CHANNEL_DWIDTH*71) ;
               when 72 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*73)-1 downto CHANNEL_DWIDTH*72) ;
               when 73 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*74)-1 downto CHANNEL_DWIDTH*73) ;
               when 74 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*75)-1 downto CHANNEL_DWIDTH*74) ;
               when 75 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*76)-1 downto CHANNEL_DWIDTH*75) ;
               when 76 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*77)-1 downto CHANNEL_DWIDTH*76) ;
               when 77 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*78)-1 downto CHANNEL_DWIDTH*77) ;
               when 78 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*79)-1 downto CHANNEL_DWIDTH*78) ;
               when 79 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*80)-1 downto CHANNEL_DWIDTH*79) ;
               when 80 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*81)-1 downto CHANNEL_DWIDTH*80) ;
               when 81 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*82)-1 downto CHANNEL_DWIDTH*81) ;
               when 82 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*83)-1 downto CHANNEL_DWIDTH*82) ;
               when 83 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*84)-1 downto CHANNEL_DWIDTH*83) ;
               when 84 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*85)-1 downto CHANNEL_DWIDTH*84) ;
               when 85 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*86)-1 downto CHANNEL_DWIDTH*85) ;
               when 86 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*87)-1 downto CHANNEL_DWIDTH*86) ;
               when 87 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*88)-1 downto CHANNEL_DWIDTH*87) ;
               when 88 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*89)-1 downto CHANNEL_DWIDTH*88) ;
               when 89 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*90)-1 downto CHANNEL_DWIDTH*89) ;
               when 90 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*91)-1 downto CHANNEL_DWIDTH*90) ;
               when 91 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*92)-1 downto CHANNEL_DWIDTH*91) ;
               when 92 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*93)-1 downto CHANNEL_DWIDTH*92) ;
               when 93 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*94)-1 downto CHANNEL_DWIDTH*93) ;
               when 94 =>                                                                   
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*95)-1 downto CHANNEL_DWIDTH*94) ;
               when 95 =>                                                                 
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*96)-1 downto CHANNEL_DWIDTH*95) ;
             
             
               when 96 =>
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*97 )-1 downto CHANNEL_DWIDTH*96 ) ;
               when 97 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*98 )-1 downto CHANNEL_DWIDTH*97 ) ;
               when 98 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*99 )-1 downto CHANNEL_DWIDTH*98 ) ;
               when 99 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*100)-1 downto CHANNEL_DWIDTH*99 ) ;
               when 100 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*101)-1 downto CHANNEL_DWIDTH*100) ;
               when 101 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*102)-1 downto CHANNEL_DWIDTH*101) ;
               when 102 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*103)-1 downto CHANNEL_DWIDTH*102) ;
               when 103 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*104)-1 downto CHANNEL_DWIDTH*103) ;
               when 104 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*105)-1 downto CHANNEL_DWIDTH*104) ;
               when 105 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*106)-1 downto CHANNEL_DWIDTH*105) ;
               when 106 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*107)-1 downto CHANNEL_DWIDTH*106) ;
               when 107 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*108)-1 downto CHANNEL_DWIDTH*107) ;
               when 108 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*109)-1 downto CHANNEL_DWIDTH*108) ;
               when 109 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*110)-1 downto CHANNEL_DWIDTH*109) ;
               when 110 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*111)-1 downto CHANNEL_DWIDTH*110) ;
               when 111 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*112)-1 downto CHANNEL_DWIDTH*111) ;
               when 112 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*113)-1 downto CHANNEL_DWIDTH*112) ;
               when 113 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*114)-1 downto CHANNEL_DWIDTH*113) ;
               when 114 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*115)-1 downto CHANNEL_DWIDTH*114) ;
               when 115 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*116)-1 downto CHANNEL_DWIDTH*115) ;
               when 116 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*117)-1 downto CHANNEL_DWIDTH*116) ;
               when 117 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*118)-1 downto CHANNEL_DWIDTH*117) ;
               when 118 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*119)-1 downto CHANNEL_DWIDTH*118) ;
               when 119 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*120)-1 downto CHANNEL_DWIDTH*119) ;
               when 120 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*121)-1 downto CHANNEL_DWIDTH*120) ;
               when 121 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*122)-1 downto CHANNEL_DWIDTH*121) ;
               when 122 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*123)-1 downto CHANNEL_DWIDTH*122) ;
               when 123 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*124)-1 downto CHANNEL_DWIDTH*123) ;
               when 124 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*125)-1 downto CHANNEL_DWIDTH*124) ;
               when 125 =>                                                                    
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*126)-1 downto CHANNEL_DWIDTH*125) ;
               when 126 =>                                                                 
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*127)-1 downto CHANNEL_DWIDTH*126) ;
               
               when others => -- 127 case
                   sig_mux_dout  <=  mmap_read_data_in((CHANNEL_DWIDTH*128)-1 downto CHANNEL_DWIDTH*127) ;
             
             
             end case;
          
           end process DO_128XN_NUX; 
 
         
       end generate GEN_128XN;
  
 
  
  
  
  
  
  
  end implementation;
