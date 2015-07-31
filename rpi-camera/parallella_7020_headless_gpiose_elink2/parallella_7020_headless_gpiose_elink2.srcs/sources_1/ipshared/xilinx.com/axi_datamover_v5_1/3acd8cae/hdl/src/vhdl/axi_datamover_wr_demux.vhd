  -------------------------------------------------------------------------------
  -- axi_datamover_wr_demux.vhd
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
  -- Filename:        axi_datamover_wr_demux.vhd
  --
  -- Description:     
  --    This file implements the DataMover Master Write Strobe De-Multiplexer.                 
  --  This is needed when the native data width of the DataMover is narrower 
  --  than the AXI4 Write Data Channel.                
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
  
  entity axi_datamover_wr_demux is
    generic (
      
      C_SEL_ADDR_WIDTH     : Integer range  1  to  8 :=  5;
        -- Sets the width of the select control bus
      
      C_MMAP_DWIDTH        : Integer range 32 to 1024 := 32;
        -- Indicates the width of the AXI4 Write Data Channel
      
      C_STREAM_DWIDTH      : Integer range  8 to 1024 := 32
        -- Indicates the native data width of the DataMover S2MM. If 
        -- S2MM Store and Forward with upsizer is enabled, the width is 
        -- the AXi4 Write Data Channel, else it is the S2MM Stream data width.
      
      );
    port (
      
     
      -- AXI MMap Data Channel Input  --------------------------------------------
                                                                                --
      wstrb_in         : In  std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);  --
        -- data input                                                           --
      ----------------------------------------------------------------------------
     
      
      
      -- AXI Master Stream  ------------------------------------------------------
                                                                                --
      demux_wstrb_out    : Out std_logic_vector((C_MMAP_DWIDTH/8)-1 downto 0);  --       
        --De-Mux strb output                                                    --
      ----------------------------------------------------------------------------
               
                
                
      -- Command Calculator Interface --------------------------------------------
                                                                                --
      debeat_saddr_lsb : In std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0)       --
         -- The next command start address LSbs to use for the read data        --
         -- mux (only used if Stream data width is less than the MMap Data      --
         -- Width).                                                             --
      ----------------------------------------------------------------------------
      
         
      );
  
  end entity axi_datamover_wr_demux;
  
  
  architecture implementation of axi_datamover_wr_demux is
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
         --when 2 =>
         --    var_sel_width := 1;
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
             var_sel_width := 1; 
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
    function func_sel_ls_index (stream_width : integer) return integer is
    
     Variable var_sel_ls_index : integer := 0;
    
    begin
    
       case stream_width is
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
         when others =>  -- assume 1024 bit width
             var_sel_ls_index := 7;
       end case;
       
       Return (var_sel_ls_index);
        
        
    end function func_sel_ls_index;
    
    
    
    
    
    -- Constant Decalarations -------------------------------------------------
    
    Constant OMIT_DEMUX    : boolean := (C_STREAM_DWIDTH = C_MMAP_DWIDTH);
    Constant INCLUDE_DEMUX : boolean := not(OMIT_DEMUX);
    
    
    
    
    Constant STREAM_WSTB_WIDTH   : integer := C_STREAM_DWIDTH/8;
    Constant MMAP_WSTB_WIDTH     : integer := C_MMAP_DWIDTH/8;
    Constant NUM_MUX_CHANNELS    : integer := MMAP_WSTB_WIDTH/STREAM_WSTB_WIDTH;
    Constant MUX_SEL_WIDTH       : integer := func_mux_sel_width(NUM_MUX_CHANNELS);
    Constant MUX_SEL_LS_INDEX    : integer := func_sel_ls_index(C_STREAM_DWIDTH);
    
    
    -- Signal Declarations  --------------------------------------------
 
    signal sig_demux_wstrb_out   : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');



    
  begin --(architecture implementation)
  
  
  
  
   -- Assign the Output data port 
    demux_wstrb_out        <= sig_demux_wstrb_out;
  


    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_STRM_EQ_MMAP
    --
    -- If Generate Description:
    --   This IfGen implements the case where the Stream Data Width is 
    -- the same as the Memeory Map read Data width.
    --
    --
    ------------------------------------------------------------
    GEN_STRM_EQ_MMAP : if (OMIT_DEMUX) generate
        
       begin
        
          sig_demux_wstrb_out <= wstrb_in;
        
        
       end generate GEN_STRM_EQ_MMAP;
   
   
    
    
    
     
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_2XN
    --
    -- If Generate Description:
    --  2 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_2XN : if (INCLUDE_DEMUX and 
                  NUM_MUX_CHANNELS = 2) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);  -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                     -- with locally static subtype error in each of the
                                                                     -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_2XN_DEMUX
         --
         -- Process Description:
         --  Implement the 2XN DeMux
         --
         -------------------------------------------------------------
         DO_2XN_DEMUX : process (lsig_demux_sel_int_local,
                                  wstrb_in)
            begin
              
              -- Set default value
              lsig_demux_wstrb_out <=  (others => '0');
              
              case lsig_demux_sel_int_local is
                when 0 =>
                    lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
                
                when others => -- 1 case
                    lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1) <=  wstrb_in;
              end case;
              
            end process DO_2XN_DEMUX; 
 
         
       end generate GEN_2XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_4XN
    --
    -- If Generate Description:
    --  4 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_4XN : if (INCLUDE_DEMUX and 
                  NUM_MUX_CHANNELS = 4) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);  -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_4XN_DEMUX
         --
         -- Process Description:
         --  Implement the 4XN DeMux
         --
         -------------------------------------------------------------
         DO_4XN_DEMUX : process (lsig_demux_sel_int_local,
                                 wstrb_in)
           begin
              
             -- Set default value
             lsig_demux_wstrb_out <=  (others => '0');
              
             case lsig_demux_sel_int_local is
               when 0 =>
                   lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
               when 1 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1) <=  wstrb_in;
               when 2 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*3)-1 downto STREAM_WSTB_WIDTH*2) <=  wstrb_in;
               
               when others =>  -- 3 case
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*4)-1 downto STREAM_WSTB_WIDTH*3) <=  wstrb_in;
             end case;
             
           end process DO_4XN_DEMUX; 
  
         
       end generate GEN_4XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_8XN
    --
    -- If Generate Description:
    --  8 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_8XN : if (INCLUDE_DEMUX and 
                  NUM_MUX_CHANNELS = 8) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);    -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                     -- with locally static subtype error in each of the
                                                                     -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_8XN_DEMUX
         --
         -- Process Description:
         --  Implement the 8XN DeMux
         --
         -------------------------------------------------------------
         DO_8XN_DEMUX : process (lsig_demux_sel_int_local,
                                 wstrb_in)
           begin
             
             -- Set default value
             lsig_demux_wstrb_out <=  (others => '0');
              
             case lsig_demux_sel_int_local is
               when 0 =>
                   lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
               when 1 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1) <=  wstrb_in;
               when 2 =>                                                             
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*3)-1 downto STREAM_WSTB_WIDTH*2) <=  wstrb_in;
               when 3 =>                                                             
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*4)-1 downto STREAM_WSTB_WIDTH*3) <=  wstrb_in;
               when 4 =>                                                             
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*5)-1 downto STREAM_WSTB_WIDTH*4) <=  wstrb_in;
               when 5 =>                                                             
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*6)-1 downto STREAM_WSTB_WIDTH*5) <=  wstrb_in;
               when 6 =>                                                             
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*7)-1 downto STREAM_WSTB_WIDTH*6) <=  wstrb_in;
               
               when others => -- 7 case
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*8)-1 downto STREAM_WSTB_WIDTH*7) <=  wstrb_in;
             end case;
                 
           end process DO_8XN_DEMUX; 
 
         
       end generate GEN_8XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_16XN
    --
    -- If Generate Description:
    --  16 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_16XN : if (INCLUDE_DEMUX and 
                   NUM_MUX_CHANNELS = 16) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);  -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_16XN_DEMUX
         --
         -- Process Description:
         --  Implement the 16XN DeMux
         --
         -------------------------------------------------------------
         DO_16XN_DEMUX : process (lsig_demux_sel_int_local,
                                  wstrb_in)
           begin
             
             -- Set default value
             lsig_demux_wstrb_out <=  (others => '0');
              
             case lsig_demux_sel_int_local is
               when 0 =>
                   lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
               when 1 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1)   <=  wstrb_in;
               when 2 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*3)-1 downto STREAM_WSTB_WIDTH*2)   <=  wstrb_in;
               when 3 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*4)-1 downto STREAM_WSTB_WIDTH*3)   <=  wstrb_in;
               when 4 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*5)-1 downto STREAM_WSTB_WIDTH*4)   <=  wstrb_in;
               when 5 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*6)-1 downto STREAM_WSTB_WIDTH*5)   <=  wstrb_in;
               when 6 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*7)-1 downto STREAM_WSTB_WIDTH*6)   <=  wstrb_in;
               when 7 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*8)-1 downto STREAM_WSTB_WIDTH*7)   <=  wstrb_in;
               when 8 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*9)-1 downto STREAM_WSTB_WIDTH*8)   <=  wstrb_in;
               when 9 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*10)-1 downto STREAM_WSTB_WIDTH*9)  <=  wstrb_in;
               when 10 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*11)-1 downto STREAM_WSTB_WIDTH*10) <=  wstrb_in;
               when 11 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*12)-1 downto STREAM_WSTB_WIDTH*11) <=  wstrb_in;
               when 12 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*13)-1 downto STREAM_WSTB_WIDTH*12) <=  wstrb_in;
               when 13 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*14)-1 downto STREAM_WSTB_WIDTH*13) <=  wstrb_in;
               when 14 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*15)-1 downto STREAM_WSTB_WIDTH*14) <=  wstrb_in;
               
               when others => -- 15 case
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*16)-1 downto STREAM_WSTB_WIDTH*15) <=  wstrb_in;
             end case;
          
           end process DO_16XN_DEMUX; 
 
         
       end generate GEN_16XN;
  
 
 
 
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_32XN
    --
    -- If Generate Description:
    --  32 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_32XN : if (INCLUDE_DEMUX and 
                   NUM_MUX_CHANNELS = 32) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);  -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_32XN_DEMUX
         --
         -- Process Description:
         --  Implement the 32XN DeMux
         --
         -------------------------------------------------------------
         DO_32XN_DEMUX : process (lsig_demux_sel_int_local,
                                  wstrb_in)
           begin
             
             -- Set default value
             lsig_demux_wstrb_out <=  (others => '0');
              
             case lsig_demux_sel_int_local is
               when 0 =>
                   lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
               when 1 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1)   <=  wstrb_in;
               when 2 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*3)-1 downto STREAM_WSTB_WIDTH*2)   <=  wstrb_in;
               when 3 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*4)-1 downto STREAM_WSTB_WIDTH*3)   <=  wstrb_in;
               when 4 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*5)-1 downto STREAM_WSTB_WIDTH*4)   <=  wstrb_in;
               when 5 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*6)-1 downto STREAM_WSTB_WIDTH*5)   <=  wstrb_in;
               when 6 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*7)-1 downto STREAM_WSTB_WIDTH*6)   <=  wstrb_in;
               when 7 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*8)-1 downto STREAM_WSTB_WIDTH*7)   <=  wstrb_in;
               when 8 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*9)-1 downto STREAM_WSTB_WIDTH*8)   <=  wstrb_in;
               when 9 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*10)-1 downto STREAM_WSTB_WIDTH*9)  <=  wstrb_in;
               when 10 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*11)-1 downto STREAM_WSTB_WIDTH*10) <=  wstrb_in;
               when 11 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*12)-1 downto STREAM_WSTB_WIDTH*11) <=  wstrb_in;
               when 12 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*13)-1 downto STREAM_WSTB_WIDTH*12) <=  wstrb_in;
               when 13 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*14)-1 downto STREAM_WSTB_WIDTH*13) <=  wstrb_in;
               when 14 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*15)-1 downto STREAM_WSTB_WIDTH*14) <=  wstrb_in;
               when 15 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*16)-1 downto STREAM_WSTB_WIDTH*15) <=  wstrb_in;
               when 16 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*17)-1 downto STREAM_WSTB_WIDTH*16) <=  wstrb_in;
               when 17 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*18)-1 downto STREAM_WSTB_WIDTH*17) <=  wstrb_in;
               when 18 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*19)-1 downto STREAM_WSTB_WIDTH*18) <=  wstrb_in;
               when 19 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*20)-1 downto STREAM_WSTB_WIDTH*19) <=  wstrb_in;
               when 20 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*21)-1 downto STREAM_WSTB_WIDTH*20) <=  wstrb_in;
               when 21 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*22)-1 downto STREAM_WSTB_WIDTH*21) <=  wstrb_in;
               when 22 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*23)-1 downto STREAM_WSTB_WIDTH*22) <=  wstrb_in;
               when 23 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*24)-1 downto STREAM_WSTB_WIDTH*23) <=  wstrb_in;
               when 24 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*25)-1 downto STREAM_WSTB_WIDTH*24) <=  wstrb_in;
               when 25 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*26)-1 downto STREAM_WSTB_WIDTH*25) <=  wstrb_in;
               when 26 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*27)-1 downto STREAM_WSTB_WIDTH*26) <=  wstrb_in;
               when 27 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*28)-1 downto STREAM_WSTB_WIDTH*27) <=  wstrb_in;
               when 28 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*29)-1 downto STREAM_WSTB_WIDTH*28) <=  wstrb_in;
               when 29 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*30)-1 downto STREAM_WSTB_WIDTH*29) <=  wstrb_in;
               when 30 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*31)-1 downto STREAM_WSTB_WIDTH*30) <=  wstrb_in;
               
               when others => -- 31 case
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*32)-1 downto STREAM_WSTB_WIDTH*31) <=  wstrb_in;
             end case;
          
           end process DO_32XN_DEMUX; 
 
         
       end generate GEN_32XN;
  
 
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_64XN
    --
    -- If Generate Description:
    --  64 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_64XN : if (INCLUDE_DEMUX and 
                   NUM_MUX_CHANNELS = 64) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);  -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                 -- with locally static subtype error in each of the
                                                                 -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_64XN_DEMUX
         --
         -- Process Description:
         --  Implement the 32XN DeMux
         --
         -------------------------------------------------------------
         DO_64XN_DEMUX : process (lsig_demux_sel_int_local,
                                  wstrb_in)
           begin
             
             -- Set default value
             lsig_demux_wstrb_out <=  (others => '0');
              
             case lsig_demux_sel_int_local is
               
               when 0 =>
                   lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
               when 1 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1)   <=  wstrb_in;
               when 2 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*3)-1 downto STREAM_WSTB_WIDTH*2)   <=  wstrb_in;
               when 3 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*4)-1 downto STREAM_WSTB_WIDTH*3)   <=  wstrb_in;
               when 4 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*5)-1 downto STREAM_WSTB_WIDTH*4)   <=  wstrb_in;
               when 5 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*6)-1 downto STREAM_WSTB_WIDTH*5)   <=  wstrb_in;
               when 6 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*7)-1 downto STREAM_WSTB_WIDTH*6)   <=  wstrb_in;
               when 7 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*8)-1 downto STREAM_WSTB_WIDTH*7)   <=  wstrb_in;
               when 8 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*9)-1 downto STREAM_WSTB_WIDTH*8)   <=  wstrb_in;
               when 9 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*10)-1 downto STREAM_WSTB_WIDTH*9)  <=  wstrb_in;
               when 10 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*11)-1 downto STREAM_WSTB_WIDTH*10) <=  wstrb_in;
               when 11 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*12)-1 downto STREAM_WSTB_WIDTH*11) <=  wstrb_in;
               when 12 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*13)-1 downto STREAM_WSTB_WIDTH*12) <=  wstrb_in;
               when 13 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*14)-1 downto STREAM_WSTB_WIDTH*13) <=  wstrb_in;
               when 14 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*15)-1 downto STREAM_WSTB_WIDTH*14) <=  wstrb_in;
               when 15 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*16)-1 downto STREAM_WSTB_WIDTH*15) <=  wstrb_in;
               when 16 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*17)-1 downto STREAM_WSTB_WIDTH*16) <=  wstrb_in;
               when 17 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*18)-1 downto STREAM_WSTB_WIDTH*17) <=  wstrb_in;
               when 18 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*19)-1 downto STREAM_WSTB_WIDTH*18) <=  wstrb_in;
               when 19 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*20)-1 downto STREAM_WSTB_WIDTH*19) <=  wstrb_in;
               when 20 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*21)-1 downto STREAM_WSTB_WIDTH*20) <=  wstrb_in;
               when 21 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*22)-1 downto STREAM_WSTB_WIDTH*21) <=  wstrb_in;
               when 22 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*23)-1 downto STREAM_WSTB_WIDTH*22) <=  wstrb_in;
               when 23 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*24)-1 downto STREAM_WSTB_WIDTH*23) <=  wstrb_in;
               when 24 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*25)-1 downto STREAM_WSTB_WIDTH*24) <=  wstrb_in;
               when 25 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*26)-1 downto STREAM_WSTB_WIDTH*25) <=  wstrb_in;
               when 26 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*27)-1 downto STREAM_WSTB_WIDTH*26) <=  wstrb_in;
               when 27 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*28)-1 downto STREAM_WSTB_WIDTH*27) <=  wstrb_in;
               when 28 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*29)-1 downto STREAM_WSTB_WIDTH*28) <=  wstrb_in;
               when 29 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*30)-1 downto STREAM_WSTB_WIDTH*29) <=  wstrb_in;
               when 30 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*31)-1 downto STREAM_WSTB_WIDTH*30) <=  wstrb_in;
               when 31 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*32)-1 downto STREAM_WSTB_WIDTH*31) <=  wstrb_in;
             
             
               when 32 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*33)-1 downto STREAM_WSTB_WIDTH*32) <=  wstrb_in;
               when 33 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*34)-1 downto STREAM_WSTB_WIDTH*33) <=  wstrb_in;
               when 34 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*35)-1 downto STREAM_WSTB_WIDTH*34) <=  wstrb_in;
               when 35 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*36)-1 downto STREAM_WSTB_WIDTH*35) <=  wstrb_in;
               when 36 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*37)-1 downto STREAM_WSTB_WIDTH*36) <=  wstrb_in;
               when 37 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*38)-1 downto STREAM_WSTB_WIDTH*37) <=  wstrb_in;
               when 38 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*39)-1 downto STREAM_WSTB_WIDTH*38) <=  wstrb_in;
               when 39 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*40)-1 downto STREAM_WSTB_WIDTH*39) <=  wstrb_in;
               when 40 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*41)-1 downto STREAM_WSTB_WIDTH*40) <=  wstrb_in;
               when 41 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*42)-1 downto STREAM_WSTB_WIDTH*41) <=  wstrb_in;
               when 42 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*43)-1 downto STREAM_WSTB_WIDTH*42) <=  wstrb_in;
               when 43 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*44)-1 downto STREAM_WSTB_WIDTH*43) <=  wstrb_in;
               when 44 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*45)-1 downto STREAM_WSTB_WIDTH*44) <=  wstrb_in;
               when 45 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*46)-1 downto STREAM_WSTB_WIDTH*45) <=  wstrb_in;
               when 46 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*47)-1 downto STREAM_WSTB_WIDTH*46) <=  wstrb_in;
               when 47 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*48)-1 downto STREAM_WSTB_WIDTH*47) <=  wstrb_in;
               when 48 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*49)-1 downto STREAM_WSTB_WIDTH*48) <=  wstrb_in;
               when 49 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*50)-1 downto STREAM_WSTB_WIDTH*49) <=  wstrb_in;
               when 50 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*51)-1 downto STREAM_WSTB_WIDTH*50) <=  wstrb_in;
               when 51 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*52)-1 downto STREAM_WSTB_WIDTH*51) <=  wstrb_in;
               when 52 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*53)-1 downto STREAM_WSTB_WIDTH*52) <=  wstrb_in;
               when 53 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*54)-1 downto STREAM_WSTB_WIDTH*53) <=  wstrb_in;
               when 54 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*55)-1 downto STREAM_WSTB_WIDTH*54) <=  wstrb_in;
               when 55 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*56)-1 downto STREAM_WSTB_WIDTH*55) <=  wstrb_in;
               when 56 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*57)-1 downto STREAM_WSTB_WIDTH*56) <=  wstrb_in;
               when 57 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*58)-1 downto STREAM_WSTB_WIDTH*57) <=  wstrb_in;
               when 58 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*59)-1 downto STREAM_WSTB_WIDTH*58) <=  wstrb_in;
               when 59 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*60)-1 downto STREAM_WSTB_WIDTH*59) <=  wstrb_in;
               when 60 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*61)-1 downto STREAM_WSTB_WIDTH*60) <=  wstrb_in;
               when 61 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*62)-1 downto STREAM_WSTB_WIDTH*61) <=  wstrb_in;
               when 62 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*63)-1 downto STREAM_WSTB_WIDTH*62) <=  wstrb_in;
               
               when others => -- 63 case
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*64)-1 downto STREAM_WSTB_WIDTH*63) <=  wstrb_in;
             
             
             end case;
          
           end process DO_64XN_DEMUX; 
 
         
       end generate GEN_64XN;
  
 
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_128XN
    --
    -- If Generate Description:
    --  128 channel demux case
    --
    --
    ------------------------------------------------------------
    GEN_128XN : if (INCLUDE_DEMUX and 
                    NUM_MUX_CHANNELS = 128) generate
    
       -- local signals
       signal sig_demux_sel_slice      : std_logic_vector(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_unsgnd     : unsigned(MUX_SEL_WIDTH-1 downto 0) := (others => '0');
       signal sig_demux_sel_int        : integer := 0;
       signal lsig_demux_sel_int_local : integer := 0;
       signal lsig_demux_wstrb_out     : std_logic_vector(MMAP_WSTB_WIDTH-1 downto 0) := (others => '0');
       
       begin
    
         
        -- Rip the Mux Select bits needed for the Mux case from the input select bus
         sig_demux_sel_slice   <= debeat_saddr_lsb((MUX_SEL_LS_INDEX + MUX_SEL_WIDTH)-1 downto MUX_SEL_LS_INDEX);
        
         sig_demux_sel_unsgnd  <=  UNSIGNED(sig_demux_sel_slice);    -- convert to unsigned
        
         sig_demux_sel_int     <=  TO_INTEGER(sig_demux_sel_unsgnd); -- convert to integer for MTI compile issue
                                                                     -- with locally static subtype error in each of the
                                                                     -- Mux IfGens
        
         lsig_demux_sel_int_local <= sig_demux_sel_int;
         
         sig_demux_wstrb_out      <= lsig_demux_wstrb_out;
       
          
          
          
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_128XN_DEMUX
         --
         -- Process Description:
         --  Implement the 32XN DeMux
         --
         -------------------------------------------------------------
         DO_128XN_DEMUX : process (lsig_demux_sel_int_local,
                                  wstrb_in)
           begin
             
             -- Set default value
             lsig_demux_wstrb_out <=  (others => '0');
              
             case lsig_demux_sel_int_local is
               
               when 0 =>
                   lsig_demux_wstrb_out(STREAM_WSTB_WIDTH-1 downto 0) <=  wstrb_in;
               when 1 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*2)-1 downto STREAM_WSTB_WIDTH*1)   <=  wstrb_in;
               when 2 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*3)-1 downto STREAM_WSTB_WIDTH*2)   <=  wstrb_in;
               when 3 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*4)-1 downto STREAM_WSTB_WIDTH*3)   <=  wstrb_in;
               when 4 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*5)-1 downto STREAM_WSTB_WIDTH*4)   <=  wstrb_in;
               when 5 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*6)-1 downto STREAM_WSTB_WIDTH*5)   <=  wstrb_in;
               when 6 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*7)-1 downto STREAM_WSTB_WIDTH*6)   <=  wstrb_in;
               when 7 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*8)-1 downto STREAM_WSTB_WIDTH*7)   <=  wstrb_in;
               when 8 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*9)-1 downto STREAM_WSTB_WIDTH*8)   <=  wstrb_in;
               when 9 =>                                                               
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*10)-1 downto STREAM_WSTB_WIDTH*9)  <=  wstrb_in;
               when 10 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*11)-1 downto STREAM_WSTB_WIDTH*10) <=  wstrb_in;
               when 11 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*12)-1 downto STREAM_WSTB_WIDTH*11) <=  wstrb_in;
               when 12 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*13)-1 downto STREAM_WSTB_WIDTH*12) <=  wstrb_in;
               when 13 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*14)-1 downto STREAM_WSTB_WIDTH*13) <=  wstrb_in;
               when 14 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*15)-1 downto STREAM_WSTB_WIDTH*14) <=  wstrb_in;
               when 15 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*16)-1 downto STREAM_WSTB_WIDTH*15) <=  wstrb_in;
               when 16 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*17)-1 downto STREAM_WSTB_WIDTH*16) <=  wstrb_in;
               when 17 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*18)-1 downto STREAM_WSTB_WIDTH*17) <=  wstrb_in;
               when 18 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*19)-1 downto STREAM_WSTB_WIDTH*18) <=  wstrb_in;
               when 19 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*20)-1 downto STREAM_WSTB_WIDTH*19) <=  wstrb_in;
               when 20 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*21)-1 downto STREAM_WSTB_WIDTH*20) <=  wstrb_in;
               when 21 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*22)-1 downto STREAM_WSTB_WIDTH*21) <=  wstrb_in;
               when 22 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*23)-1 downto STREAM_WSTB_WIDTH*22) <=  wstrb_in;
               when 23 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*24)-1 downto STREAM_WSTB_WIDTH*23) <=  wstrb_in;
               when 24 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*25)-1 downto STREAM_WSTB_WIDTH*24) <=  wstrb_in;
               when 25 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*26)-1 downto STREAM_WSTB_WIDTH*25) <=  wstrb_in;
               when 26 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*27)-1 downto STREAM_WSTB_WIDTH*26) <=  wstrb_in;
               when 27 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*28)-1 downto STREAM_WSTB_WIDTH*27) <=  wstrb_in;
               when 28 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*29)-1 downto STREAM_WSTB_WIDTH*28) <=  wstrb_in;
               when 29 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*30)-1 downto STREAM_WSTB_WIDTH*29) <=  wstrb_in;
               when 30 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*31)-1 downto STREAM_WSTB_WIDTH*30) <=  wstrb_in;
               when 31 =>                                                              
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*32)-1 downto STREAM_WSTB_WIDTH*31) <=  wstrb_in;
             
             
               when 32 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*33)-1 downto STREAM_WSTB_WIDTH*32) <=  wstrb_in;
               when 33 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*34)-1 downto STREAM_WSTB_WIDTH*33) <=  wstrb_in;
               when 34 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*35)-1 downto STREAM_WSTB_WIDTH*34) <=  wstrb_in;
               when 35 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*36)-1 downto STREAM_WSTB_WIDTH*35) <=  wstrb_in;
               when 36 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*37)-1 downto STREAM_WSTB_WIDTH*36) <=  wstrb_in;
               when 37 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*38)-1 downto STREAM_WSTB_WIDTH*37) <=  wstrb_in;
               when 38 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*39)-1 downto STREAM_WSTB_WIDTH*38) <=  wstrb_in;
               when 39 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*40)-1 downto STREAM_WSTB_WIDTH*39) <=  wstrb_in;
               when 40 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*41)-1 downto STREAM_WSTB_WIDTH*40) <=  wstrb_in;
               when 41 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*42)-1 downto STREAM_WSTB_WIDTH*41) <=  wstrb_in;
               when 42 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*43)-1 downto STREAM_WSTB_WIDTH*42) <=  wstrb_in;
               when 43 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*44)-1 downto STREAM_WSTB_WIDTH*43) <=  wstrb_in;
               when 44 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*45)-1 downto STREAM_WSTB_WIDTH*44) <=  wstrb_in;
               when 45 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*46)-1 downto STREAM_WSTB_WIDTH*45) <=  wstrb_in;
               when 46 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*47)-1 downto STREAM_WSTB_WIDTH*46) <=  wstrb_in;
               when 47 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*48)-1 downto STREAM_WSTB_WIDTH*47) <=  wstrb_in;
               when 48 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*49)-1 downto STREAM_WSTB_WIDTH*48) <=  wstrb_in;
               when 49 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*50)-1 downto STREAM_WSTB_WIDTH*49) <=  wstrb_in;
               when 50 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*51)-1 downto STREAM_WSTB_WIDTH*50) <=  wstrb_in;
               when 51 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*52)-1 downto STREAM_WSTB_WIDTH*51) <=  wstrb_in;
               when 52 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*53)-1 downto STREAM_WSTB_WIDTH*52) <=  wstrb_in;
               when 53 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*54)-1 downto STREAM_WSTB_WIDTH*53) <=  wstrb_in;
               when 54 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*55)-1 downto STREAM_WSTB_WIDTH*54) <=  wstrb_in;
               when 55 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*56)-1 downto STREAM_WSTB_WIDTH*55) <=  wstrb_in;
               when 56 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*57)-1 downto STREAM_WSTB_WIDTH*56) <=  wstrb_in;
               when 57 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*58)-1 downto STREAM_WSTB_WIDTH*57) <=  wstrb_in;
               when 58 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*59)-1 downto STREAM_WSTB_WIDTH*58) <=  wstrb_in;
               when 59 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*60)-1 downto STREAM_WSTB_WIDTH*59) <=  wstrb_in;
               when 60 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*61)-1 downto STREAM_WSTB_WIDTH*60) <=  wstrb_in;
               when 61 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*62)-1 downto STREAM_WSTB_WIDTH*61) <=  wstrb_in;
               when 62 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*63)-1 downto STREAM_WSTB_WIDTH*62) <=  wstrb_in;
               when 63 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*64)-1 downto STREAM_WSTB_WIDTH*63) <=  wstrb_in;
              
               
               when 64 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*65)-1 downto STREAM_WSTB_WIDTH*64) <=  wstrb_in;
               when 65 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*66)-1 downto STREAM_WSTB_WIDTH*65) <=  wstrb_in;
               when 66 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*67)-1 downto STREAM_WSTB_WIDTH*66) <=  wstrb_in;
               when 67 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*68)-1 downto STREAM_WSTB_WIDTH*67) <=  wstrb_in;
               when 68 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*69)-1 downto STREAM_WSTB_WIDTH*68) <=  wstrb_in;
               when 69 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*70)-1 downto STREAM_WSTB_WIDTH*69) <=  wstrb_in;
               when 70 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*71)-1 downto STREAM_WSTB_WIDTH*70) <=  wstrb_in;
               when 71 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*72)-1 downto STREAM_WSTB_WIDTH*71) <=  wstrb_in;
               when 72 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*73)-1 downto STREAM_WSTB_WIDTH*72) <=  wstrb_in;
               when 73 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*74)-1 downto STREAM_WSTB_WIDTH*73) <=  wstrb_in;
               when 74 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*75)-1 downto STREAM_WSTB_WIDTH*74) <=  wstrb_in;
               when 75 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*76)-1 downto STREAM_WSTB_WIDTH*75) <=  wstrb_in;
               when 76 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*77)-1 downto STREAM_WSTB_WIDTH*76) <=  wstrb_in;
               when 77 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*78)-1 downto STREAM_WSTB_WIDTH*77) <=  wstrb_in;
               when 78 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*79)-1 downto STREAM_WSTB_WIDTH*78) <=  wstrb_in;
               when 79 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*80)-1 downto STREAM_WSTB_WIDTH*79) <=  wstrb_in;
               when 80 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*81)-1 downto STREAM_WSTB_WIDTH*80) <=  wstrb_in;
               when 81 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*82)-1 downto STREAM_WSTB_WIDTH*81) <=  wstrb_in;
               when 82 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*83)-1 downto STREAM_WSTB_WIDTH*82) <=  wstrb_in;
               when 83 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*84)-1 downto STREAM_WSTB_WIDTH*83) <=  wstrb_in;
               when 84 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*85)-1 downto STREAM_WSTB_WIDTH*84) <=  wstrb_in;
               when 85 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*86)-1 downto STREAM_WSTB_WIDTH*85) <=  wstrb_in;
               when 86 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*87)-1 downto STREAM_WSTB_WIDTH*86) <=  wstrb_in;
               when 87 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*88)-1 downto STREAM_WSTB_WIDTH*87) <=  wstrb_in;
               when 88 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*89)-1 downto STREAM_WSTB_WIDTH*88) <=  wstrb_in;
               when 89 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*90)-1 downto STREAM_WSTB_WIDTH*89) <=  wstrb_in;
               when 90 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*91)-1 downto STREAM_WSTB_WIDTH*90) <=  wstrb_in;
               when 91 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*92)-1 downto STREAM_WSTB_WIDTH*91) <=  wstrb_in;
               when 92 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*93)-1 downto STREAM_WSTB_WIDTH*92) <=  wstrb_in;
               when 93 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*94)-1 downto STREAM_WSTB_WIDTH*93) <=  wstrb_in;
               when 94 =>                                                                   
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*95)-1 downto STREAM_WSTB_WIDTH*94) <=  wstrb_in;
               when 95 =>                                                                 
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*96)-1 downto STREAM_WSTB_WIDTH*95) <=  wstrb_in;
             
             
               when 96 =>
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*97 )-1 downto STREAM_WSTB_WIDTH*96 ) <=  wstrb_in;
               when 97 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*98 )-1 downto STREAM_WSTB_WIDTH*97 ) <=  wstrb_in;
               when 98 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*99 )-1 downto STREAM_WSTB_WIDTH*98 ) <=  wstrb_in;
               when 99 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*100)-1 downto STREAM_WSTB_WIDTH*99 ) <=  wstrb_in;
               when 100 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*101)-1 downto STREAM_WSTB_WIDTH*100) <=  wstrb_in;
               when 101 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*102)-1 downto STREAM_WSTB_WIDTH*101) <=  wstrb_in;
               when 102 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*103)-1 downto STREAM_WSTB_WIDTH*102) <=  wstrb_in;
               when 103 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*104)-1 downto STREAM_WSTB_WIDTH*103) <=  wstrb_in;
               when 104 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*105)-1 downto STREAM_WSTB_WIDTH*104) <=  wstrb_in;
               when 105 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*106)-1 downto STREAM_WSTB_WIDTH*105) <=  wstrb_in;
               when 106 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*107)-1 downto STREAM_WSTB_WIDTH*106) <=  wstrb_in;
               when 107 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*108)-1 downto STREAM_WSTB_WIDTH*107) <=  wstrb_in;
               when 108 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*109)-1 downto STREAM_WSTB_WIDTH*108) <=  wstrb_in;
               when 109 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*110)-1 downto STREAM_WSTB_WIDTH*109) <=  wstrb_in;
               when 110 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*111)-1 downto STREAM_WSTB_WIDTH*110) <=  wstrb_in;
               when 111 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*112)-1 downto STREAM_WSTB_WIDTH*111) <=  wstrb_in;
               when 112 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*113)-1 downto STREAM_WSTB_WIDTH*112) <=  wstrb_in;
               when 113 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*114)-1 downto STREAM_WSTB_WIDTH*113) <=  wstrb_in;
               when 114 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*115)-1 downto STREAM_WSTB_WIDTH*114) <=  wstrb_in;
               when 115 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*116)-1 downto STREAM_WSTB_WIDTH*115) <=  wstrb_in;
               when 116 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*117)-1 downto STREAM_WSTB_WIDTH*116) <=  wstrb_in;
               when 117 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*118)-1 downto STREAM_WSTB_WIDTH*117) <=  wstrb_in;
               when 118 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*119)-1 downto STREAM_WSTB_WIDTH*118) <=  wstrb_in;
               when 119 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*120)-1 downto STREAM_WSTB_WIDTH*119) <=  wstrb_in;
               when 120 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*121)-1 downto STREAM_WSTB_WIDTH*120) <=  wstrb_in;
               when 121 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*122)-1 downto STREAM_WSTB_WIDTH*121) <=  wstrb_in;
               when 122 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*123)-1 downto STREAM_WSTB_WIDTH*122) <=  wstrb_in;
               when 123 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*124)-1 downto STREAM_WSTB_WIDTH*123) <=  wstrb_in;
               when 124 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*125)-1 downto STREAM_WSTB_WIDTH*124) <=  wstrb_in;
               when 125 =>                                                                    
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*126)-1 downto STREAM_WSTB_WIDTH*125) <=  wstrb_in;
               when 126 =>                                                                 
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*127)-1 downto STREAM_WSTB_WIDTH*126) <=  wstrb_in;
               
               when others => -- 127 case
                   lsig_demux_wstrb_out((STREAM_WSTB_WIDTH*128)-1 downto STREAM_WSTB_WIDTH*127) <=  wstrb_in;
             
             
             
             end case;
          
           end process DO_128XN_DEMUX; 
 
         
       end generate GEN_128XN;
  
 
  
  
  
  
  
  
  
  
  end implementation;
