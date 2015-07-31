-------------------------------------------------------------------------------
-- axi_datamover_strb_gen2.vhd
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
-- Filename:        axi_datamover_strb_gen2.vhd
--
-- Description:     
--   Second generation AXI Strobe Generator module. This design leverages
-- look up table approach vs real-time calculation. This design method is 
-- used to reduce logic levels and improve final Fmax timing.               
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

entity axi_datamover_strb_gen2 is
  generic (
    C_OP_MODE            : Integer range 0 to 1 := 0; 
      -- 0 = offset/length mode 
      -- 1 = offset/offset mode,
      
    C_STRB_WIDTH         : Integer := 8; 
    -- number of addr bits needed
    
    C_OFFSET_WIDTH       : Integer := 3; 
    -- log2(C_STRB_WIDTH)
    
    C_NUM_BYTES_WIDTH    : Integer := 4 
      -- log2(C_STRB_WIDTH)+1 in offset/length mode (C_OP_MODE = 0)
      -- log2(C_STRB_WIDTH) in offset/offset mode   (C_OP_MODE = 1)
    );
  port (
    
    -- Starting offset input -----------------------------------------------------
                                                                                --
    start_addr_offset    : In  std_logic_vector(C_OFFSET_WIDTH-1 downto 0);     --
      -- Specifies the starting address offset of the strobe value              --
    ------------------------------------------------------------------------------
      -- used in both offset/offset and offset/length modes
      
    
    
    -- Endig Offset Input --------------------------------------------------------
                                                                                --
    end_addr_offset      : In  std_logic_vector(C_OFFSET_WIDTH-1 downto 0);     --
      -- Specifies the ending address offset of the strobe value                --
      -- used in only offset/offset mode (C_OP_MODE = 1)                        --
    ------------------------------------------------------------------------------
    
      
    -- Number of valid Bytes input (from starting offset) ------------------------
                                                                                --
    num_valid_bytes      : In  std_logic_vector(C_NUM_BYTES_WIDTH-1 downto 0);  --
      -- Specifies the number of valid bytes from starting offset               --
      -- used in only offset/length mode (C_OP_MODE = 0)                        --
    ------------------------------------------------------------------------------  
      
    
    -- Generated Strobe output ---------------------------------------------------  
                                                                                --
    strb_out             : out std_logic_vector(C_STRB_WIDTH-1 downto 0)        --
    ------------------------------------------------------------------------------
    
    
    );

end entity axi_datamover_strb_gen2;


architecture implementation of axi_datamover_strb_gen2 is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";


  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_2
  --
  -- Function Description:
  --   returns the 2-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_2 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(1 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        var_start_vector := "11";
      when others =>
        var_start_vector := "10";
    end case;
   
    Return (var_start_vector);
   
  end function get_start_2;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_2
  --
  -- Function Description:
  --   Returns the 2-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_2 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(1 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        var_end_vector := "01";
      when others =>
        var_end_vector := "11";
    end case;
   
    Return (var_end_vector);
   
  end function get_end_2; 
  
  
  
  
  
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_4
  --
  -- Function Description:
  --   returns the 4-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_4 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(3 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        var_start_vector := "1111";
      when 1 =>
        var_start_vector := "1110";
      when 2 =>
        var_start_vector := "1100";
      when others =>
        var_start_vector := "1000";
    end case;
   
    Return (var_start_vector);
   
  end function get_start_4;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_4
  --
  -- Function Description:
  --   Returns the 4-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_4 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(3 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        var_end_vector := "0001";
      when 1 =>
        var_end_vector := "0011";
      when 2 =>
        var_end_vector := "0111";
      when others =>
        var_end_vector := "1111";
    end case;
   
    Return (var_end_vector);
   
  end function get_end_4; 
  
  
  
  
  
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_8
  --
  -- Function Description:
  --   returns the 8-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_8 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(7 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        var_start_vector := "11111111";
      when 1 =>
        var_start_vector := "11111110";
      when 2 =>
        var_start_vector := "11111100";
      when 3 =>
        var_start_vector := "11111000";
      when 4 =>
        var_start_vector := "11110000";
      when 5 =>
        var_start_vector := "11100000";
      when 6 =>
        var_start_vector := "11000000";
      when others =>
        var_start_vector := "10000000";
    end case;
   
    Return (var_start_vector);
   
  end function get_start_8;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_8
  --
  -- Function Description:
  --   Returns the 8-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_8 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(7 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        var_end_vector := "00000001";
      when 1 =>
        var_end_vector := "00000011";
      when 2 =>
        var_end_vector := "00000111";
      when 3 =>
        var_end_vector := "00001111";
      when 4 =>
        var_end_vector := "00011111";
      when 5 =>
        var_end_vector := "00111111";
      when 6 =>
        var_end_vector := "01111111";
      when others =>
        var_end_vector := "11111111";
    end case;
   
    Return (var_end_vector);
   
  end function get_end_8; 
  
  
  
  
  
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_16
  --
  -- Function Description:
  --   returns the 16-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_16 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(15 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        var_start_vector := "1111111111111111";
      when 1 =>
        var_start_vector := "1111111111111110";
      when 2 =>
        var_start_vector := "1111111111111100";
      when 3 =>
        var_start_vector := "1111111111111000";
      when 4 =>
        var_start_vector := "1111111111110000";
      when 5 =>
        var_start_vector := "1111111111100000";
      when 6 =>
        var_start_vector := "1111111111000000";
      when 7 =>
        var_start_vector := "1111111110000000";
      when 8 =>
        var_start_vector := "1111111100000000";
      when 9 =>
        var_start_vector := "1111111000000000";
      when 10 =>
        var_start_vector := "1111110000000000";
      when 11 =>
        var_start_vector := "1111100000000000";
      when 12 =>
        var_start_vector := "1111000000000000";
      when 13 =>
        var_start_vector := "1110000000000000";
      when 14 =>
        var_start_vector := "1100000000000000";
      when others =>
        var_start_vector := "1000000000000000";
    end case;
   
    Return (var_start_vector);
   
  end function get_start_16;
  
  
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_16
  --
  -- Function Description:
  --   Returns the 16-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_16 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(15 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        var_end_vector := "0000000000000001";
      when 1 =>
        var_end_vector := "0000000000000011";
      when 2 =>
        var_end_vector := "0000000000000111";
      when 3 =>
        var_end_vector := "0000000000001111";
      when 4 =>
        var_end_vector := "0000000000011111";
      when 5 =>
        var_end_vector := "0000000000111111";
      when 6 =>
        var_end_vector := "0000000001111111";
      when 7 =>
        var_end_vector := "0000000011111111";
      when 8 =>
        var_end_vector := "0000000111111111";
      when 9 =>
        var_end_vector := "0000001111111111";
      when 10 =>
        var_end_vector := "0000011111111111";
      when 11 =>
        var_end_vector := "0000111111111111";
      when 12 =>
        var_end_vector := "0001111111111111";
      when 13 =>
        var_end_vector := "0011111111111111";
      when 14 =>
        var_end_vector := "0111111111111111";
      when others =>
        var_end_vector := "1111111111111111";
    end case;
   
    Return (var_end_vector);
   
  end function get_end_16;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_32
  --
  -- Function Description:
  --   returns the 32-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_32 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(31 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        var_start_vector := "11111111111111111111111111111111";
      when 1 =>
        var_start_vector := "11111111111111111111111111111110";
      when 2 =>
        var_start_vector := "11111111111111111111111111111100";
      when 3 =>
        var_start_vector := "11111111111111111111111111111000";
      when 4 =>
        var_start_vector := "11111111111111111111111111110000";
      when 5 =>
        var_start_vector := "11111111111111111111111111100000";
      when 6 =>
        var_start_vector := "11111111111111111111111111000000";
      when 7 =>
        var_start_vector := "11111111111111111111111110000000";
      when 8 =>
        var_start_vector := "11111111111111111111111100000000";
      when 9 =>
        var_start_vector := "11111111111111111111111000000000";
      when 10 =>
        var_start_vector := "11111111111111111111110000000000";
      when 11 =>
        var_start_vector := "11111111111111111111100000000000";
      when 12 =>
        var_start_vector := "11111111111111111111000000000000";
      when 13 =>
        var_start_vector := "11111111111111111110000000000000";
      when 14 =>
        var_start_vector := "11111111111111111100000000000000";
      when 15 =>
        var_start_vector := "11111111111111111000000000000000";
      when 16 =>
        var_start_vector := "11111111111111110000000000000000";
      when 17 =>
        var_start_vector := "11111111111111100000000000000000";
      when 18 =>
        var_start_vector := "11111111111111000000000000000000";
      when 19 =>
        var_start_vector := "11111111111110000000000000000000";
      when 20 =>
        var_start_vector := "11111111111100000000000000000000";
      when 21 =>
        var_start_vector := "11111111111000000000000000000000";
      when 22 =>
        var_start_vector := "11111111110000000000000000000000";
      when 23 =>
        var_start_vector := "11111111100000000000000000000000";
      when 24 =>
        var_start_vector := "11111111000000000000000000000000";
      when 25 =>
        var_start_vector := "11111110000000000000000000000000";
      when 26 =>
        var_start_vector := "11111100000000000000000000000000";
      when 27 =>
        var_start_vector := "11111000000000000000000000000000";
      when 28 =>
        var_start_vector := "11110000000000000000000000000000";
      when 29 =>
        var_start_vector := "11100000000000000000000000000000";
      when 30 =>
        var_start_vector := "11000000000000000000000000000000";
      when others =>
        var_start_vector := "10000000000000000000000000000000";
    end case;
   
    Return (var_start_vector);
   
  end function get_start_32;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_32
  --
  -- Function Description:
  --   Returns the 32-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_32 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(31 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        var_end_vector := "00000000000000000000000000000001";
      when 1 =>
        var_end_vector := "00000000000000000000000000000011";
      when 2 =>
        var_end_vector := "00000000000000000000000000000111";
      when 3 =>
        var_end_vector := "00000000000000000000000000001111";
      when 4 =>
        var_end_vector := "00000000000000000000000000011111";
      when 5 =>
        var_end_vector := "00000000000000000000000000111111";
      when 6 =>
        var_end_vector := "00000000000000000000000001111111";
      when 7 =>
        var_end_vector := "00000000000000000000000011111111";
      when 8 =>
        var_end_vector := "00000000000000000000000111111111";
      when 9 =>
        var_end_vector := "00000000000000000000001111111111";
      when 10 =>
        var_end_vector := "00000000000000000000011111111111";
      when 11 =>
        var_end_vector := "00000000000000000000111111111111";
      when 12 =>
        var_end_vector := "00000000000000000001111111111111";
      when 13 =>
        var_end_vector := "00000000000000000011111111111111";
      when 14 =>
        var_end_vector := "00000000000000000111111111111111";
      when 15 =>
        var_end_vector := "00000000000000001111111111111111";
      when 16 =>
        var_end_vector := "00000000000000011111111111111111";
      when 17 =>
        var_end_vector := "00000000000000111111111111111111";
      when 18 =>
        var_end_vector := "00000000000001111111111111111111";
      when 19 =>
        var_end_vector := "00000000000011111111111111111111";
      when 20 =>
        var_end_vector := "00000000000111111111111111111111";
      when 21 =>
        var_end_vector := "00000000001111111111111111111111";
      when 22 =>
        var_end_vector := "00000000011111111111111111111111";
      when 23 =>
        var_end_vector := "00000000111111111111111111111111";
      when 24 =>
        var_end_vector := "00000001111111111111111111111111";
      when 25 =>
        var_end_vector := "00000011111111111111111111111111";
      when 26 =>
        var_end_vector := "00000111111111111111111111111111";
      when 27 =>
        var_end_vector := "00001111111111111111111111111111";
      when 28 =>
        var_end_vector := "00011111111111111111111111111111";
      when 29 =>
        var_end_vector := "00111111111111111111111111111111";
      when 30 =>
        var_end_vector := "01111111111111111111111111111111";
      when others =>
        var_end_vector := "11111111111111111111111111111111";
    end case;
   
    Return (var_end_vector);
   
  end function get_end_32;
  
  
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_64
  --
  -- Function Description:
  --   returns the 64-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_64 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(63 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111111111";
      when 1 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111111110";
      when 2 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111111100";
      when 3 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111111000";
      when 4 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111110000";
      when 5 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111100000";
      when 6 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111111000000";
      when 7 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111110000000";
      when 8 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111100000000";
      when 9 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111111000000000";
      when 10 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111110000000000";
      when 11 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111100000000000";
      when 12 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111111000000000000";
      when 13 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111110000000000000";
      when 14 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111100000000000000";
      when 15 =>
        var_start_vector := "1111111111111111111111111111111111111111111111111000000000000000";
      when 16 =>
        var_start_vector := "1111111111111111111111111111111111111111111111110000000000000000";
      when 17 =>
        var_start_vector := "1111111111111111111111111111111111111111111111100000000000000000";
      when 18 =>
        var_start_vector := "1111111111111111111111111111111111111111111111000000000000000000";
      when 19 =>
        var_start_vector := "1111111111111111111111111111111111111111111110000000000000000000";
      when 20 =>
        var_start_vector := "1111111111111111111111111111111111111111111100000000000000000000";
      when 21 =>
        var_start_vector := "1111111111111111111111111111111111111111111000000000000000000000";
      when 22 =>
        var_start_vector := "1111111111111111111111111111111111111111110000000000000000000000";
      when 23 =>
        var_start_vector := "1111111111111111111111111111111111111111100000000000000000000000";
      when 24 =>
        var_start_vector := "1111111111111111111111111111111111111111000000000000000000000000";
      when 25 =>
        var_start_vector := "1111111111111111111111111111111111111110000000000000000000000000";
      when 26 =>
        var_start_vector := "1111111111111111111111111111111111111100000000000000000000000000";
      when 27 =>
        var_start_vector := "1111111111111111111111111111111111111000000000000000000000000000";
      when 28 =>
        var_start_vector := "1111111111111111111111111111111111110000000000000000000000000000";
      when 29 =>
        var_start_vector := "1111111111111111111111111111111111100000000000000000000000000000";
      when 30 =>
        var_start_vector := "1111111111111111111111111111111111000000000000000000000000000000";
      when 31 =>
        var_start_vector := "1111111111111111111111111111111110000000000000000000000000000000";
      when 32 =>
        var_start_vector := "1111111111111111111111111111111100000000000000000000000000000000";
      when 33 =>
        var_start_vector := "1111111111111111111111111111111000000000000000000000000000000000";
      when 34 =>
        var_start_vector := "1111111111111111111111111111110000000000000000000000000000000000";
      when 35 =>                                                                             
        var_start_vector := "1111111111111111111111111111100000000000000000000000000000000000";
      when 36 =>                                                                             
        var_start_vector := "1111111111111111111111111111000000000000000000000000000000000000";
      when 37 =>                                                                             
        var_start_vector := "1111111111111111111111111110000000000000000000000000000000000000";
      when 38 =>                                                                             
        var_start_vector := "1111111111111111111111111100000000000000000000000000000000000000";
      when 39 =>                                                                             
        var_start_vector := "1111111111111111111111111000000000000000000000000000000000000000";
      when 40 =>                                                                             
        var_start_vector := "1111111111111111111111110000000000000000000000000000000000000000";
      when 41 =>                                                                             
        var_start_vector := "1111111111111111111111100000000000000000000000000000000000000000";
      when 42 =>                                                                             
        var_start_vector := "1111111111111111111111000000000000000000000000000000000000000000";
      when 43 =>                                                                             
        var_start_vector := "1111111111111111111110000000000000000000000000000000000000000000";
      when 44 =>                                                                             
        var_start_vector := "1111111111111111111100000000000000000000000000000000000000000000";
      when 45 =>                                                                             
        var_start_vector := "1111111111111111111000000000000000000000000000000000000000000000";
      when 46 =>                                                                             
        var_start_vector := "1111111111111111110000000000000000000000000000000000000000000000";
      when 47 =>                                                                             
        var_start_vector := "1111111111111111100000000000000000000000000000000000000000000000";
      when 48 =>                                                                             
        var_start_vector := "1111111111111111000000000000000000000000000000000000000000000000";
      when 49 =>                                                                             
        var_start_vector := "1111111111111110000000000000000000000000000000000000000000000000";
      when 50 =>                                                                             
        var_start_vector := "1111111111111100000000000000000000000000000000000000000000000000";
      when 51 =>                                                                             
        var_start_vector := "1111111111111000000000000000000000000000000000000000000000000000";
      when 52 =>                                                                             
        var_start_vector := "1111111111110000000000000000000000000000000000000000000000000000";
      when 53 =>                                                                             
        var_start_vector := "1111111111100000000000000000000000000000000000000000000000000000";
      when 54 =>                                                                             
        var_start_vector := "1111111111000000000000000000000000000000000000000000000000000000";
      when 55 =>                                                                             
        var_start_vector := "1111111110000000000000000000000000000000000000000000000000000000";
      when 56 =>                                                                             
        var_start_vector := "1111111100000000000000000000000000000000000000000000000000000000";
      when 57 =>                                                                             
        var_start_vector := "1111111000000000000000000000000000000000000000000000000000000000";
      when 58 =>                                                                             
        var_start_vector := "1111110000000000000000000000000000000000000000000000000000000000";
      when 59 =>                                                                             
        var_start_vector := "1111100000000000000000000000000000000000000000000000000000000000";
      when 60 =>                                                                             
        var_start_vector := "1111000000000000000000000000000000000000000000000000000000000000";
      when 61 =>                                                                             
        var_start_vector := "1110000000000000000000000000000000000000000000000000000000000000";
      when 62 =>                                                                             
        var_start_vector := "1100000000000000000000000000000000000000000000000000000000000000";
      when others =>                                                                         
        var_start_vector := "1000000000000000000000000000000000000000000000000000000000000000";
    end case;
   
    Return (var_start_vector);
   
  end function get_start_64;
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_64
  --
  -- Function Description:
  --   Returns the 64-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_64 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(63 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000000000001";
      when 1 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000000000011";
      when 2 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000000000111";
      when 3 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000000001111";                    
      when 4 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000000011111";
      when 5 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000000111111";
      when 6 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000001111111";
      when 7 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000011111111";
      when 8 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000000111111111";
      when 9 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000001111111111";
      when 10 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000011111111111";
      when 11 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000000111111111111";
      when 12 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000001111111111111";
      when 13 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000011111111111111";
      when 14 =>
        var_end_vector := "0000000000000000000000000000000000000000000000000111111111111111";
      when 15 =>
        var_end_vector := "0000000000000000000000000000000000000000000000001111111111111111";
      when 16 =>
        var_end_vector := "0000000000000000000000000000000000000000000000011111111111111111";
      when 17 =>
        var_end_vector := "0000000000000000000000000000000000000000000000111111111111111111";
      when 18 =>
        var_end_vector := "0000000000000000000000000000000000000000000001111111111111111111";
      when 19 =>
        var_end_vector := "0000000000000000000000000000000000000000000011111111111111111111";
      when 20 =>
        var_end_vector := "0000000000000000000000000000000000000000000111111111111111111111";
      when 21 =>
        var_end_vector := "0000000000000000000000000000000000000000001111111111111111111111";
      when 22 =>
        var_end_vector := "0000000000000000000000000000000000000000011111111111111111111111";
      when 23 =>
        var_end_vector := "0000000000000000000000000000000000000000111111111111111111111111";
      when 24 =>
        var_end_vector := "0000000000000000000000000000000000000001111111111111111111111111";
      when 25 =>
        var_end_vector := "0000000000000000000000000000000000000011111111111111111111111111";
      when 26 =>
        var_end_vector := "0000000000000000000000000000000000000111111111111111111111111111";
      when 27 =>
        var_end_vector := "0000000000000000000000000000000000001111111111111111111111111111";
      when 28 =>
        var_end_vector := "0000000000000000000000000000000000011111111111111111111111111111";
      when 29 =>
        var_end_vector := "0000000000000000000000000000000000111111111111111111111111111111";
      when 30 =>
        var_end_vector := "0000000000000000000000000000000001111111111111111111111111111111";
      when 31 =>
        var_end_vector := "0000000000000000000000000000000011111111111111111111111111111111";
      
      when 32 =>
        var_end_vector := "0000000000000000000000000000000111111111111111111111111111111111";
      when 33 =>
        var_end_vector := "0000000000000000000000000000001111111111111111111111111111111111";
      when 34 =>
        var_end_vector := "0000000000000000000000000000011111111111111111111111111111111111";
      when 35 =>
        var_end_vector := "0000000000000000000000000000111111111111111111111111111111111111";
      when 36 =>
        var_end_vector := "0000000000000000000000000001111111111111111111111111111111111111";
      when 37 =>
        var_end_vector := "0000000000000000000000000011111111111111111111111111111111111111";
      when 38 =>
        var_end_vector := "0000000000000000000000000111111111111111111111111111111111111111";
      when 39 =>
        var_end_vector := "0000000000000000000000001111111111111111111111111111111111111111";
      when 40 =>
        var_end_vector := "0000000000000000000000011111111111111111111111111111111111111111";
      when 41 =>
        var_end_vector := "0000000000000000000000111111111111111111111111111111111111111111";
      when 42 =>
        var_end_vector := "0000000000000000000001111111111111111111111111111111111111111111";
      when 43 =>
        var_end_vector := "0000000000000000000011111111111111111111111111111111111111111111";
      when 44 =>
        var_end_vector := "0000000000000000000111111111111111111111111111111111111111111111";
      when 45 =>
        var_end_vector := "0000000000000000001111111111111111111111111111111111111111111111";
      when 46 =>
        var_end_vector := "0000000000000000011111111111111111111111111111111111111111111111";
      when 47 =>
        var_end_vector := "0000000000000000111111111111111111111111111111111111111111111111";
      when 48 =>
        var_end_vector := "0000000000000001111111111111111111111111111111111111111111111111";
      when 49 =>
        var_end_vector := "0000000000000011111111111111111111111111111111111111111111111111";
      when 50 =>
        var_end_vector := "0000000000000111111111111111111111111111111111111111111111111111";
      when 51 =>
        var_end_vector := "0000000000001111111111111111111111111111111111111111111111111111";
      when 52 =>
        var_end_vector := "0000000000011111111111111111111111111111111111111111111111111111";
      when 53 =>
        var_end_vector := "0000000000111111111111111111111111111111111111111111111111111111";
      when 54 =>
        var_end_vector := "0000000001111111111111111111111111111111111111111111111111111111";
      when 55 =>
        var_end_vector := "0000000011111111111111111111111111111111111111111111111111111111";
      when 56 =>
        var_end_vector := "0000000111111111111111111111111111111111111111111111111111111111";
      when 57 =>
        var_end_vector := "0000001111111111111111111111111111111111111111111111111111111111";
      when 58 =>
        var_end_vector := "0000011111111111111111111111111111111111111111111111111111111111";
      when 59 =>
        var_end_vector := "0000111111111111111111111111111111111111111111111111111111111111";
      when 60 =>
        var_end_vector := "0001111111111111111111111111111111111111111111111111111111111111";
      when 61 =>
        var_end_vector := "0011111111111111111111111111111111111111111111111111111111111111";
      when 62 =>
        var_end_vector := "0111111111111111111111111111111111111111111111111111111111111111";
      
      when others =>
        var_end_vector := "1111111111111111111111111111111111111111111111111111111111111111";
    end case;
   
    Return (var_end_vector);
   
  end function get_end_64;
 
 
 
 
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_start_128
  --
  -- Function Description:
  --   returns the 128-bit vector filled with '1's from the start
  -- offset to the end of of the vector
  --
  -------------------------------------------------------------------
  function get_start_128 (start_offset : natural) return std_logic_vector is
  
    Variable var_start_vector : std_logic_vector(127 downto 0) := (others => '0');
  
  begin
  
    case start_offset is
      when 0 =>
        
        var_start_vector(127 downto 0) := (others => '1');
      
      when 1 =>
        
        var_start_vector(127 downto 1) := (others => '1');
        var_start_vector(  0 downto 0) := (others => '0');
      
      when 2 =>
        
        var_start_vector(127 downto 2) := (others => '1');
        var_start_vector(  1 downto 0) := (others => '0');
      
      when 3 =>
        
        var_start_vector(127 downto 3) := (others => '1');
        var_start_vector(  2 downto 0) := (others => '0');
      
      when 4 =>
        
        var_start_vector(127 downto 4) := (others => '1');
        var_start_vector(  3 downto 0) := (others => '0');
      
      when 5 =>
        
        var_start_vector(127 downto 5) := (others => '1');
        var_start_vector(  4 downto 0) := (others => '0');
      
      when 6 =>
        
        var_start_vector(127 downto 6) := (others => '1');
        var_start_vector(  5 downto 0) := (others => '0');
      
      when 7 =>
        
        var_start_vector(127 downto 7) := (others => '1');
        var_start_vector(  6 downto 0) := (others => '0');
      
      when 8 =>
        
        var_start_vector(127 downto 8) := (others => '1');
        var_start_vector(  7 downto 0) := (others => '0');
      
      when 9 =>
        
        var_start_vector(127 downto 9) := (others => '1');
        var_start_vector(  8 downto 0) := (others => '0');
      
      when 10 =>
        
        var_start_vector(127 downto 10) := (others => '1');
        var_start_vector(  9 downto 0) := (others => '0');
      
      when 11 =>
        
        var_start_vector(127 downto 11) := (others => '1');
        var_start_vector( 10 downto  0) := (others => '0');
      
      when 12 =>
        
        var_start_vector(127 downto 12) := (others => '1');
        var_start_vector( 11 downto  0) := (others => '0');
      
      when 13 =>
        
        var_start_vector(127 downto 13) := (others => '1');
        var_start_vector( 12 downto  0) := (others => '0');
      
      when 14 =>
        
        var_start_vector(127 downto 14) := (others => '1');
        var_start_vector( 13 downto  0) := (others => '0');
      
      when 15 =>
        
        var_start_vector(127 downto 15) := (others => '1');
        var_start_vector( 14 downto  0) := (others => '0');
      
      when 16 =>
        
        var_start_vector(127 downto 16) := (others => '1');
        var_start_vector( 15 downto  0) := (others => '0');
      
      when 17 =>
        
        var_start_vector(127 downto 17) := (others => '1');
        var_start_vector( 16 downto  0) := (others => '0');
      
      when 18 =>
        
        var_start_vector(127 downto 18) := (others => '1');
        var_start_vector( 17 downto  0) := (others => '0');
      
      when 19 =>
        
        var_start_vector(127 downto 19) := (others => '1');
        var_start_vector( 18 downto  0) := (others => '0');
      
      when 20 =>
        
        var_start_vector(127 downto 20) := (others => '1');
        var_start_vector( 19 downto  0) := (others => '0');
      
      when 21 =>
        
        var_start_vector(127 downto 21) := (others => '1');
        var_start_vector( 20 downto  0) := (others => '0');
      
      when 22 =>
        
        var_start_vector(127 downto 22) := (others => '1');
        var_start_vector( 21 downto  0) := (others => '0');
      
      when 23 =>
        
        var_start_vector(127 downto 23) := (others => '1');
        var_start_vector( 22 downto  0) := (others => '0');
      
      when 24 =>
        
        var_start_vector(127 downto 24) := (others => '1');
        var_start_vector( 23 downto  0) := (others => '0');
      
      when 25 =>
        
        var_start_vector(127 downto 25) := (others => '1');
        var_start_vector( 24 downto  0) := (others => '0');
      
      when 26 =>
        
        var_start_vector(127 downto 26) := (others => '1');
        var_start_vector( 25 downto  0) := (others => '0');
      
      when 27 =>
        
        var_start_vector(127 downto 27) := (others => '1');
        var_start_vector( 26 downto  0) := (others => '0');
      
      when 28 =>
        
        var_start_vector(127 downto 28) := (others => '1');
        var_start_vector( 27 downto  0) := (others => '0');
      
      when 29 =>
        
        var_start_vector(127 downto 29) := (others => '1');
        var_start_vector( 28 downto  0) := (others => '0');
      
      when 30 =>
        
        var_start_vector(127 downto 30) := (others => '1');
        var_start_vector( 29 downto  0) := (others => '0');
      
      when 31 =>
        
        var_start_vector(127 downto 31) := (others => '1');
        var_start_vector( 30 downto  0) := (others => '0');
      
      
      
      when 32 =>
        
        var_start_vector(127 downto 32) := (others => '1');
        var_start_vector( 31 downto  0) := (others => '0');
      
      when 33 =>
        
        var_start_vector(127 downto 33) := (others => '1');
        var_start_vector( 32 downto  0) := (others => '0');
      
      when 34 =>
        
        var_start_vector(127 downto 34) := (others => '1');
        var_start_vector( 33 downto  0) := (others => '0');
      
      when 35 =>
        
        var_start_vector(127 downto 35) := (others => '1');
        var_start_vector( 34 downto  0) := (others => '0');
      
      when 36 =>
        
        var_start_vector(127 downto 36) := (others => '1');
        var_start_vector( 35 downto  0) := (others => '0');
      
      when 37 =>
        
        var_start_vector(127 downto 37) := (others => '1');
        var_start_vector( 36 downto  0) := (others => '0');
      
      when 38 =>
        
        var_start_vector(127 downto 38) := (others => '1');
        var_start_vector( 37 downto  0) := (others => '0');
      
      when 39 =>
        
        var_start_vector(127 downto 39) := (others => '1');
        var_start_vector( 38 downto  0) := (others => '0');
      
      when 40 =>
        
        var_start_vector(127 downto 40) := (others => '1');
        var_start_vector( 39 downto  0) := (others => '0');
      
      when 41 =>
        
        var_start_vector(127 downto 41) := (others => '1');
        var_start_vector( 40 downto  0) := (others => '0');
      
      when 42 =>
        
        var_start_vector(127 downto 42) := (others => '1');
        var_start_vector( 41 downto  0) := (others => '0');
      
      when 43 =>
        
        var_start_vector(127 downto 43) := (others => '1');
        var_start_vector( 42 downto  0) := (others => '0');
      
      when 44 =>
        
        var_start_vector(127 downto 44) := (others => '1');
        var_start_vector( 43 downto  0) := (others => '0');
      
      when 45 =>
        
        var_start_vector(127 downto 45) := (others => '1');
        var_start_vector( 44 downto  0) := (others => '0');
      
      when 46 =>
        
        var_start_vector(127 downto 46) := (others => '1');
        var_start_vector( 45 downto  0) := (others => '0');
      
      when 47 =>
        
        var_start_vector(127 downto 47) := (others => '1');
        var_start_vector( 46 downto  0) := (others => '0');
      
      when 48 =>
        
        var_start_vector(127 downto 48) := (others => '1');
        var_start_vector( 47 downto  0) := (others => '0');
      
      when 49 =>
        
        var_start_vector(127 downto 49) := (others => '1');
        var_start_vector( 48 downto  0) := (others => '0');
      
      when 50 =>
        
        var_start_vector(127 downto 50) := (others => '1');
        var_start_vector( 49 downto  0) := (others => '0');
      
      when 51 =>
        
        var_start_vector(127 downto 51) := (others => '1');
        var_start_vector( 50 downto  0) := (others => '0');
      
      when 52 =>
        
        var_start_vector(127 downto 52) := (others => '1');
        var_start_vector( 51 downto  0) := (others => '0');
      
      when 53 =>
        
        var_start_vector(127 downto 53) := (others => '1');
        var_start_vector( 52 downto  0) := (others => '0');
      
      when 54 =>
        
        var_start_vector(127 downto 54) := (others => '1');
        var_start_vector( 53 downto  0) := (others => '0');
      
      when 55 =>
        
        var_start_vector(127 downto 55) := (others => '1');
        var_start_vector( 54 downto  0) := (others => '0');
      
      when 56 =>
        
        var_start_vector(127 downto 56) := (others => '1');
        var_start_vector( 55 downto  0) := (others => '0');
      
      when 57 =>
        
        var_start_vector(127 downto 57) := (others => '1');
        var_start_vector( 56 downto  0) := (others => '0');
      
      when 58 =>
        
        var_start_vector(127 downto 58) := (others => '1');
        var_start_vector( 57 downto  0) := (others => '0');
      
      when 59 =>
        
        var_start_vector(127 downto 59) := (others => '1');
        var_start_vector( 58 downto  0) := (others => '0');
      
      when 60 =>
        
        var_start_vector(127 downto 60) := (others => '1');
        var_start_vector( 59 downto  0) := (others => '0');
      
      when 61 =>
        
        var_start_vector(127 downto 61) := (others => '1');
        var_start_vector( 60 downto  0) := (others => '0');
      
      when 62 =>
        
        var_start_vector(127 downto 62) := (others => '1');
        var_start_vector( 61 downto  0) := (others => '0');
      
      when 63 =>
        
        var_start_vector(127 downto 63) := (others => '1');
        var_start_vector( 62 downto  0) := (others => '0');
      
      
      
      
      when 64 =>
        
        var_start_vector(127 downto 64) := (others => '1');
        var_start_vector( 63 downto  0) := (others => '0');
 
      when 65 =>
        
        var_start_vector(127 downto 65) := (others => '1');
        var_start_vector( 64 downto  0) := (others => '0');
      
      when 66 =>                                                                           
        
        var_start_vector(127 downto 66) := (others => '1');
        var_start_vector( 65 downto  0) := (others => '0');
      
      when 67 =>                                                                           
        
        var_start_vector(127 downto 67) := (others => '1');
        var_start_vector( 66 downto  0) := (others => '0');
      
      when 68 =>                                                                           
        
        var_start_vector(127 downto 68) := (others => '1');
        var_start_vector( 67 downto  0) := (others => '0');
      
      when 69 =>                                                                           
        
        var_start_vector(127 downto 69) := (others => '1');
        var_start_vector( 68 downto  0) := (others => '0');
      
      when 70 =>                                                                           
        
        var_start_vector(127 downto 70) := (others => '1');
        var_start_vector( 69 downto  0) := (others => '0');
      
      when 71 =>                                                                           
        
        var_start_vector(127 downto 71) := (others => '1');
        var_start_vector( 70 downto  0) := (others => '0');
      
      when 72 =>                                                                           
        
        var_start_vector(127 downto 72) := (others => '1');
        var_start_vector( 71 downto  0) := (others => '0');
      
      when 73 =>                                                                           
        
        var_start_vector(127 downto 73) := (others => '1');
        var_start_vector( 72 downto  0) := (others => '0');
      
      when 74 =>                                                                           
        
        var_start_vector(127 downto 74) := (others => '1');
        var_start_vector( 73 downto  0) := (others => '0');
      
      when 75 =>                                                                           
        
        var_start_vector(127 downto 75) := (others => '1');
        var_start_vector( 74 downto  0) := (others => '0');
      
      when 76 =>                                                                           
        
        var_start_vector(127 downto 76) := (others => '1');
        var_start_vector( 75 downto  0) := (others => '0');
      
      when 77 =>                                                                           
        
        var_start_vector(127 downto 77) := (others => '1');
        var_start_vector( 76 downto  0) := (others => '0');
      
      when 78 =>                                                                           
        
        var_start_vector(127 downto 78) := (others => '1');
        var_start_vector( 77 downto  0) := (others => '0');
      
      when 79 =>                                                                           
        
        var_start_vector(127 downto 79) := (others => '1');
        var_start_vector( 78 downto  0) := (others => '0');
      
      when 80 =>                                                                           
        
        var_start_vector(127 downto 80) := (others => '1');
        var_start_vector( 79 downto  0) := (others => '0');
      
      when 81 =>                                                                           
        
        var_start_vector(127 downto 81) := (others => '1');
        var_start_vector( 80 downto  0) := (others => '0');
      
      when 82 =>                                                                           
        
        var_start_vector(127 downto 82) := (others => '1');
        var_start_vector( 81 downto  0) := (others => '0');
      
      when 83 =>                                                                           
        
        var_start_vector(127 downto 83) := (others => '1');
        var_start_vector( 82 downto  0) := (others => '0');
      
      when 84 =>                                                                           
        
        var_start_vector(127 downto 84) := (others => '1');
        var_start_vector( 83 downto  0) := (others => '0');
      
      when 85 =>                                                                           
        
        var_start_vector(127 downto 85) := (others => '1');
        var_start_vector( 84 downto  0) := (others => '0');
      
      when 86 =>                                                                           
        
        var_start_vector(127 downto 86) := (others => '1');
        var_start_vector( 85 downto  0) := (others => '0');
      
      when 87 =>                                                                           
        
        var_start_vector(127 downto 87) := (others => '1');
        var_start_vector( 86 downto  0) := (others => '0');
      
      when 88 =>                                                                           
        
        var_start_vector(127 downto 88) := (others => '1');
        var_start_vector( 87 downto  0) := (others => '0');
      
      when 89 =>                                                                           
        
        var_start_vector(127 downto 89) := (others => '1');
        var_start_vector( 88 downto  0) := (others => '0');
      
      when 90 =>                                                                           
        
        var_start_vector(127 downto 90) := (others => '1');
        var_start_vector( 89 downto  0) := (others => '0');
      
      when 91 =>                                                                           
        
        var_start_vector(127 downto 91) := (others => '1');
        var_start_vector( 90 downto  0) := (others => '0');
      
      when 92 =>                                                                           
        
        var_start_vector(127 downto 92) := (others => '1');
        var_start_vector( 91 downto  0) := (others => '0');
      
      when 93 =>                                                                           
        
        var_start_vector(127 downto 93) := (others => '1');
        var_start_vector( 92 downto  0) := (others => '0');
      
      when 94 =>                                                                           
        
        var_start_vector(127 downto 94) := (others => '1');
        var_start_vector( 93 downto  0) := (others => '0');
      
      when 95 =>                                                                           
        
        var_start_vector(127 downto 95) := (others => '1');
        var_start_vector( 94 downto  0) := (others => '0');
      
      when 96 =>                                                                           
        
        var_start_vector(127 downto 96) := (others => '1');
        var_start_vector( 95 downto  0) := (others => '0');
      
      when 97 =>                                                                           
        
        var_start_vector(127 downto 97) := (others => '1');
        var_start_vector( 96 downto  0) := (others => '0');
      
      when 98 =>                                                                           
        
        var_start_vector(127 downto 98) := (others => '1');
        var_start_vector( 97 downto  0) := (others => '0');
      
      when 99 =>                                                                           
        
        var_start_vector(127 downto 99) := (others => '1');
        var_start_vector( 98 downto  0) := (others => '0');
      
      when 100 =>                                                                          
        
        var_start_vector(127 downto 100) := (others => '1');
        var_start_vector( 99 downto   0) := (others => '0');
      
      when 101 =>                                                                          
        
        var_start_vector(127 downto 101) := (others => '1');
        var_start_vector(100 downto   0) := (others => '0');
      
      when 102 =>                                                                          
        
        var_start_vector(127 downto 102) := (others => '1');
        var_start_vector(101 downto   0) := (others => '0');
      
      when 103 =>                                                                          
        
        var_start_vector(127 downto 103) := (others => '1');
        var_start_vector(102 downto   0) := (others => '0');
      
      when 104 =>                                                                          
        
        var_start_vector(127 downto 104) := (others => '1');
        var_start_vector(103 downto   0) := (others => '0');
      
      when 105 =>                                                                          
        
        var_start_vector(127 downto 105) := (others => '1');
        var_start_vector(104 downto   0) := (others => '0');
      
      when 106 =>                                                                          
        
        var_start_vector(127 downto 106) := (others => '1');
        var_start_vector(105 downto   0) := (others => '0');
      
      when 107 =>                                                                          
        
        var_start_vector(127 downto 107) := (others => '1');
        var_start_vector(106 downto   0) := (others => '0');
      
      when 108 =>                                                                          
        
        var_start_vector(127 downto 108) := (others => '1');
        var_start_vector(107 downto   0) := (others => '0');
      
      when 109 =>                                                                          
        
        var_start_vector(127 downto 109) := (others => '1');
        var_start_vector(108 downto   0) := (others => '0');
      
      when 110 =>                                                                          
        
        var_start_vector(127 downto 110) := (others => '1');
        var_start_vector(109 downto   0) := (others => '0');
      
      when 111 =>                                                                          
        
        var_start_vector(127 downto 111) := (others => '1');
        var_start_vector(110 downto   0) := (others => '0');
      
      when 112 =>                                                                          
        
        var_start_vector(127 downto 112) := (others => '1');
        var_start_vector(111 downto   0) := (others => '0');
      
      when 113 =>                                                                          
        
        var_start_vector(127 downto 113) := (others => '1');
        var_start_vector(112 downto   0) := (others => '0');
      
      when 114 =>                                                                          
        
        var_start_vector(127 downto 114) := (others => '1');
        var_start_vector(113 downto   0) := (others => '0');
      
      when 115 =>                                                                          
        
        var_start_vector(127 downto 115) := (others => '1');
        var_start_vector(114 downto   0) := (others => '0');
      
      when 116 =>                                                                          
        
        var_start_vector(127 downto 116) := (others => '1');
        var_start_vector(115 downto   0) := (others => '0');
      
      when 117 =>                                                                          
        
        var_start_vector(127 downto 117) := (others => '1');
        var_start_vector(116 downto   0) := (others => '0');
      
      when 118 =>                                                                          
        
        var_start_vector(127 downto 118) := (others => '1');
        var_start_vector(117 downto   0) := (others => '0');
      
      when 119 =>                                                                          
        
        var_start_vector(127 downto 119) := (others => '1');
        var_start_vector(118 downto   0) := (others => '0');
      
      when 120 =>                                                                          
        
        var_start_vector(127 downto 120) := (others => '1');
        var_start_vector(119 downto   0) := (others => '0');
      
      when 121 =>                                                                          
        
        var_start_vector(127 downto 121) := (others => '1');
        var_start_vector(120 downto   0) := (others => '0');
      
      when 122 =>                                                                          
        
        var_start_vector(127 downto 122) := (others => '1');
        var_start_vector(121 downto   0) := (others => '0');
      
      when 123 =>                                                                          
        
        var_start_vector(127 downto 123) := (others => '1');
        var_start_vector(122 downto   0) := (others => '0');
      
      when 124 =>                                                                          
        
        var_start_vector(127 downto 124) := (others => '1');
        var_start_vector(123 downto   0) := (others => '0');
      
      when 125 =>                                                                          
        
        var_start_vector(127 downto 125) := (others => '1');
        var_start_vector(124 downto   0) := (others => '0');
      
      when 126 =>                                                                          
        
        var_start_vector(127 downto 126) := (others => '1');
        var_start_vector(125 downto   0) := (others => '0');
      
      when others =>
        
        var_start_vector(127 downto 127) := (others => '1');
        var_start_vector(126 downto   0) := (others => '0');
      
    end case;
   
    Return (var_start_vector);
   
  end function get_start_128;
  
  
 
  
  
  
  
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: get_end_128
  --
  -- Function Description:
  --   Returns the 128-bit vector filled with '1's from the lsbit
  -- of the vector to the end offset.
  --
  -------------------------------------------------------------------
  function get_end_128 (end_offset : natural) return std_logic_vector is
  
    Variable var_end_vector : std_logic_vector(127 downto 0) := (others => '0');
  
  begin
  
    case end_offset is
      when 0 =>
        
        var_end_vector(127 downto 1) := (others => '0');
        var_end_vector(  0 downto 0) := (others => '1');
      
      when 1 =>
        
        var_end_vector(127 downto 2) := (others => '0');
        var_end_vector(  1 downto 0) := (others => '1');
      
      when 2 =>
        
        var_end_vector(127 downto 3) := (others => '0');
        var_end_vector(  2 downto 0) := (others => '1');
      
      when 3 =>
        
        var_end_vector(127 downto 4) := (others => '0');
        var_end_vector(  3 downto 0) := (others => '1');
      
      when 4 =>
        
        var_end_vector(127 downto 5) := (others => '0');
        var_end_vector(  4 downto 0) := (others => '1');
      
      when 5 =>
        
        var_end_vector(127 downto 6) := (others => '0');
        var_end_vector(  5 downto 0) := (others => '1');
      
      when 6 =>
        
        var_end_vector(127 downto 7) := (others => '0');
        var_end_vector(  6 downto 0) := (others => '1');
      
      when 7 =>
        
        var_end_vector(127 downto 8) := (others => '0');
        var_end_vector(  7 downto 0) := (others => '1');
      
      when 8 =>
        
        var_end_vector(127 downto 9) := (others => '0');
        var_end_vector(  8 downto 0) := (others => '1');
      
      when 9 =>
        
        var_end_vector(127 downto 10) := (others => '0');
        var_end_vector(  9 downto 0) := (others => '1');
      
      when 10 =>
        
        var_end_vector(127 downto 11) := (others => '0');
        var_end_vector( 10 downto  0) := (others => '1');
      
      when 11 =>
        
        var_end_vector(127 downto 12) := (others => '0');
        var_end_vector( 11 downto  0) := (others => '1');
      
      when 12 =>
        
        var_end_vector(127 downto 13) := (others => '0');
        var_end_vector( 12 downto  0) := (others => '1');
      
      when 13 =>
        
        var_end_vector(127 downto 14) := (others => '0');
        var_end_vector( 13 downto  0) := (others => '1');
      
      when 14 =>
        
        var_end_vector(127 downto 15) := (others => '0');
        var_end_vector( 14 downto  0) := (others => '1');
      
      when 15 =>
        
        var_end_vector(127 downto 16) := (others => '0');
        var_end_vector( 15 downto  0) := (others => '1');
      
      when 16 =>
        
        var_end_vector(127 downto 17) := (others => '0');
        var_end_vector( 16 downto  0) := (others => '1');
      
      when 17 =>
        
        var_end_vector(127 downto 18) := (others => '0');
        var_end_vector( 17 downto  0) := (others => '1');
      
      when 18 =>
        
        var_end_vector(127 downto 19) := (others => '0');
        var_end_vector( 18 downto  0) := (others => '1');
      
      when 19 =>
        
        var_end_vector(127 downto 20) := (others => '0');
        var_end_vector( 19 downto  0) := (others => '1');
      
      when 20 =>
        
        var_end_vector(127 downto 21) := (others => '0');
        var_end_vector( 20 downto  0) := (others => '1');
      
      when 21 =>
        
        var_end_vector(127 downto 22) := (others => '0');
        var_end_vector( 21 downto  0) := (others => '1');
      
      when 22 =>
        
        var_end_vector(127 downto 23) := (others => '0');
        var_end_vector( 22 downto  0) := (others => '1');
      
      when 23 =>
        
        var_end_vector(127 downto 24) := (others => '0');
        var_end_vector( 23 downto  0) := (others => '1');
      
      when 24 =>
        
        var_end_vector(127 downto 25) := (others => '0');
        var_end_vector( 24 downto  0) := (others => '1');
      
      when 25 =>
        
        var_end_vector(127 downto 26) := (others => '0');
        var_end_vector( 25 downto  0) := (others => '1');
      
      when 26 =>
        
        var_end_vector(127 downto 27) := (others => '0');
        var_end_vector( 26 downto  0) := (others => '1');
      
      when 27 =>
        
        var_end_vector(127 downto 28) := (others => '0');
        var_end_vector( 27 downto  0) := (others => '1');
      
      when 28 =>
        
        var_end_vector(127 downto 29) := (others => '0');
        var_end_vector( 28 downto  0) := (others => '1');
      
      when 29 =>
        
        var_end_vector(127 downto 30) := (others => '0');
        var_end_vector( 29 downto  0) := (others => '1');
      
      when 30 =>
        
        var_end_vector(127 downto 31) := (others => '0');
        var_end_vector( 30 downto  0) := (others => '1');
      
      when 31 =>
        
        var_end_vector(127 downto 32) := (others => '0');
        var_end_vector( 31 downto  0) := (others => '1');
      
      
      when 32 =>
        
        var_end_vector(127 downto 33) := (others => '0');
        var_end_vector( 32 downto  0) := (others => '1');
      
      when 33 =>
        
        var_end_vector(127 downto 34) := (others => '0');
        var_end_vector( 33 downto  0) := (others => '1');
      
      when 34 =>
        
        var_end_vector(127 downto 35) := (others => '0');
        var_end_vector( 34 downto  0) := (others => '1');
      
      when 35 =>
        
        var_end_vector(127 downto 36) := (others => '0');
        var_end_vector( 35 downto  0) := (others => '1');
      
      when 36 =>
        
        var_end_vector(127 downto 37) := (others => '0');
        var_end_vector( 36 downto  0) := (others => '1');
      
      when 37 =>
        
        var_end_vector(127 downto 38) := (others => '0');
        var_end_vector( 37 downto  0) := (others => '1');
      
      when 38 =>
        
        var_end_vector(127 downto 39) := (others => '0');
        var_end_vector( 38 downto  0) := (others => '1');
      
      when 39 =>
        
        var_end_vector(127 downto 40) := (others => '0');
        var_end_vector( 39 downto  0) := (others => '1');
      
      when 40 =>
        
        var_end_vector(127 downto 41) := (others => '0');
        var_end_vector( 40 downto  0) := (others => '1');
      
      when 41 =>
        
        var_end_vector(127 downto 42) := (others => '0');
        var_end_vector( 41 downto  0) := (others => '1');
      
      when 42 =>
        
        var_end_vector(127 downto 43) := (others => '0');
        var_end_vector( 42 downto  0) := (others => '1');
      
      when 43 =>
        
        var_end_vector(127 downto 44) := (others => '0');
        var_end_vector( 43 downto  0) := (others => '1');
      
      when 44 =>
        
        var_end_vector(127 downto 45) := (others => '0');
        var_end_vector( 44 downto  0) := (others => '1');
      
      when 45 =>
        
        var_end_vector(127 downto 46) := (others => '0');
        var_end_vector( 45 downto  0) := (others => '1');
      
      when 46 =>
        
        var_end_vector(127 downto 47) := (others => '0');
        var_end_vector( 46 downto  0) := (others => '1');
      
      when 47 =>
        
        var_end_vector(127 downto 48) := (others => '0');
        var_end_vector( 47 downto  0) := (others => '1');
      
      when 48 =>
        
        var_end_vector(127 downto 49) := (others => '0');
        var_end_vector( 48 downto  0) := (others => '1');
      
      when 49 =>
        
        var_end_vector(127 downto 50) := (others => '0');
        var_end_vector( 49 downto  0) := (others => '1');
      
      when 50 =>
        
        var_end_vector(127 downto 51) := (others => '0');
        var_end_vector( 50 downto  0) := (others => '1');
      
      when 51 =>
        
        var_end_vector(127 downto 52) := (others => '0');
        var_end_vector( 51 downto  0) := (others => '1');
      
      when 52 =>
        
        var_end_vector(127 downto 53) := (others => '0');
        var_end_vector( 52 downto  0) := (others => '1');
      
      when 53 =>
        
        var_end_vector(127 downto 54) := (others => '0');
        var_end_vector( 53 downto  0) := (others => '1');
      
      when 54 =>
        
        var_end_vector(127 downto 55) := (others => '0');
        var_end_vector( 54 downto  0) := (others => '1');
      
      when 55 =>
        
        var_end_vector(127 downto 56) := (others => '0');
        var_end_vector( 55 downto  0) := (others => '1');
      
      when 56 =>
        
        var_end_vector(127 downto 57) := (others => '0');
        var_end_vector( 56 downto  0) := (others => '1');
      
      when 57 =>
        
        var_end_vector(127 downto 58) := (others => '0');
        var_end_vector( 57 downto  0) := (others => '1');
      
      when 58 =>
        
        var_end_vector(127 downto 59) := (others => '0');
        var_end_vector( 58 downto  0) := (others => '1');
      
      when 59 =>
        
        var_end_vector(127 downto 60) := (others => '0');
        var_end_vector( 59 downto  0) := (others => '1');
      
      when 60 =>
        
        var_end_vector(127 downto 61) := (others => '0');
        var_end_vector( 60 downto  0) := (others => '1');
      
      when 61 =>
        
        var_end_vector(127 downto 62) := (others => '0');
        var_end_vector( 61 downto  0) := (others => '1');
      
      when 62 =>
        
        var_end_vector(127 downto 63) := (others => '0');
        var_end_vector( 62 downto  0) := (others => '1');
      
      when 63 =>
        
        var_end_vector(127 downto 64) := (others => '0');
        var_end_vector( 63 downto  0) := (others => '1');
      
 
 
 
 
      when 64 =>
        
        var_end_vector(127 downto 65) := (others => '0');
        var_end_vector( 64 downto  0) := (others => '1');
      
      when 65 =>
        
        var_end_vector(127 downto 66) := (others => '0');
        var_end_vector( 65 downto  0) := (others => '1');
      
      when 66 =>                                                                           
        
        var_end_vector(127 downto 67) := (others => '0');
        var_end_vector( 66 downto  0) := (others => '1');
      
      when 67 =>                                                                           
        
        var_end_vector(127 downto 68) := (others => '0');
        var_end_vector( 67 downto  0) := (others => '1');
      
      when 68 =>                                                                           
        
        var_end_vector(127 downto 69) := (others => '0');
        var_end_vector( 68 downto  0) := (others => '1');
      
      when 69 =>                                                                           
        
        var_end_vector(127 downto 70) := (others => '0');
        var_end_vector( 69 downto  0) := (others => '1');
      
      when 70 =>                                                                           
        
        var_end_vector(127 downto 71) := (others => '0');
        var_end_vector( 70 downto  0) := (others => '1');
      
      when 71 =>                                                                           
        
        var_end_vector(127 downto 72) := (others => '0');
        var_end_vector( 71 downto  0) := (others => '1');
      
      when 72 =>                                                                           
        
        var_end_vector(127 downto 73) := (others => '0');
        var_end_vector( 72 downto  0) := (others => '1');
      
      when 73 =>                                                                           
        
        var_end_vector(127 downto 74) := (others => '0');
        var_end_vector( 73 downto  0) := (others => '1');
      
      when 74 =>                                                                           
        
        var_end_vector(127 downto 75) := (others => '0');
        var_end_vector( 74 downto  0) := (others => '1');
      
      when 75 =>                                                                           
        
        var_end_vector(127 downto 76) := (others => '0');
        var_end_vector( 75 downto  0) := (others => '1');
      
      when 76 =>                                                                           
        
        var_end_vector(127 downto 77) := (others => '0');
        var_end_vector( 76 downto  0) := (others => '1');
      
      when 77 =>                                                                           
        
        var_end_vector(127 downto 78) := (others => '0');
        var_end_vector( 77 downto  0) := (others => '1');
      
      when 78 =>                                                                           
        
        var_end_vector(127 downto 79) := (others => '0');
        var_end_vector( 78 downto  0) := (others => '1');
      
      when 79 =>                                                                           
        
        var_end_vector(127 downto 80) := (others => '0');
        var_end_vector( 79 downto  0) := (others => '1');
      
      when 80 =>                                                                           
        
        var_end_vector(127 downto 81) := (others => '0');
        var_end_vector( 80 downto  0) := (others => '1');
      
      when 81 =>                                                                           
        
        var_end_vector(127 downto 82) := (others => '0');
        var_end_vector( 81 downto  0) := (others => '1');
      
      when 82 =>                                                                           
        
        var_end_vector(127 downto 83) := (others => '0');
        var_end_vector( 82 downto  0) := (others => '1');
      
      when 83 =>                                                                           
        
        var_end_vector(127 downto 84) := (others => '0');
        var_end_vector( 83 downto  0) := (others => '1');
      
      when 84 =>                                                                           
        
        var_end_vector(127 downto 85) := (others => '0');
        var_end_vector( 84 downto  0) := (others => '1');
      
      when 85 =>                                                                           
        
        var_end_vector(127 downto 86) := (others => '0');
        var_end_vector( 85 downto  0) := (others => '1');
      
      when 86 =>                                                                           
        
        var_end_vector(127 downto 87) := (others => '0');
        var_end_vector( 86 downto  0) := (others => '1');
      
      when 87 =>                                                                           
        
        var_end_vector(127 downto 88) := (others => '0');
        var_end_vector( 87 downto  0) := (others => '1');
      
      when 88 =>                                                                           
        
        var_end_vector(127 downto 89) := (others => '0');
        var_end_vector( 88 downto  0) := (others => '1');
      
      when 89 =>                                                                           
        
        var_end_vector(127 downto 90) := (others => '0');
        var_end_vector( 89 downto  0) := (others => '1');
      
      when 90 =>                                                                           
        
        var_end_vector(127 downto 91) := (others => '0');
        var_end_vector( 90 downto  0) := (others => '1');
      
      when 91 =>                                                                           
        
        var_end_vector(127 downto 92) := (others => '0');
        var_end_vector( 91 downto  0) := (others => '1');
      
      when 92 =>                                                                           
        
        var_end_vector(127 downto 93) := (others => '0');
        var_end_vector( 92 downto  0) := (others => '1');
      
      when 93 =>                                                                           
        
        var_end_vector(127 downto 94) := (others => '0');
        var_end_vector( 93 downto  0) := (others => '1');
      
      when 94 =>                                                                           
        
        var_end_vector(127 downto 95) := (others => '0');
        var_end_vector( 94 downto  0) := (others => '1');
      
      when 95 =>                                                                           
        
        var_end_vector(127 downto 96) := (others => '0');
        var_end_vector( 95 downto  0) := (others => '1');
      
      when 96 =>                                                                           
        
        var_end_vector(127 downto 97) := (others => '0');
        var_end_vector( 96 downto  0) := (others => '1');
      
      when 97 =>                                                                           
        
        var_end_vector(127 downto 98) := (others => '0');
        var_end_vector( 97 downto  0) := (others => '1');
      
      when 98 =>                                                                           
        
        var_end_vector(127 downto 99) := (others => '0');
        var_end_vector( 98 downto  0) := (others => '1');
      
      when 99 =>                                                                           
        
        var_end_vector(127 downto 100) := (others => '0');
        var_end_vector( 99 downto   0) := (others => '1');
      
      when 100 =>                                                                          
        
        var_end_vector(127 downto 101) := (others => '0');
        var_end_vector(100 downto   0) := (others => '1');
      
      when 101 =>                                                                          
        
        var_end_vector(127 downto 102) := (others => '0');
        var_end_vector(101 downto   0) := (others => '1');
      
      when 102 =>                                                                          
        
        var_end_vector(127 downto 103) := (others => '0');
        var_end_vector(102 downto   0) := (others => '1');
      
      when 103 =>                                                                          
        
        var_end_vector(127 downto 104) := (others => '0');
        var_end_vector(103 downto   0) := (others => '1');
      
      when 104 =>                                                                          
        
        var_end_vector(127 downto 105) := (others => '0');
        var_end_vector(104 downto   0) := (others => '1');
      
      when 105 =>                                                                          
        
        var_end_vector(127 downto 106) := (others => '0');
        var_end_vector(105 downto   0) := (others => '1');
      
      when 106 =>                                                                          
        
        var_end_vector(127 downto 107) := (others => '0');
        var_end_vector(106 downto   0) := (others => '1');
      
      when 107 =>                                                                          
        
        var_end_vector(127 downto 108) := (others => '0');
        var_end_vector(107 downto   0) := (others => '1');
      
      when 108 =>                                                                          
        
        var_end_vector(127 downto 109) := (others => '0');
        var_end_vector(108 downto   0) := (others => '1');
      
      when 109 =>                                                                          
        
        var_end_vector(127 downto 110) := (others => '0');
        var_end_vector(109 downto   0) := (others => '1');
      
      when 110 =>                                                                          
        
        var_end_vector(127 downto 111) := (others => '0');
        var_end_vector(110 downto   0) := (others => '1');
      
      when 111 =>                                                                          
        
        var_end_vector(127 downto 112) := (others => '0');
        var_end_vector(111 downto   0) := (others => '1');
      
      when 112 =>                                                                          
        
        var_end_vector(127 downto 113) := (others => '0');
        var_end_vector(112 downto   0) := (others => '1');
      
      when 113 =>                                                                          
        
        var_end_vector(127 downto 114) := (others => '0');
        var_end_vector(113 downto   0) := (others => '1');
      
      when 114 =>                                                                          
        
        var_end_vector(127 downto 115) := (others => '0');
        var_end_vector(114 downto   0) := (others => '1');
      
      when 115 =>                                                                          
        
        var_end_vector(127 downto 116) := (others => '0');
        var_end_vector(115 downto   0) := (others => '1');
      
      when 116 =>                                                                          
        
        var_end_vector(127 downto 117) := (others => '0');
        var_end_vector(116 downto   0) := (others => '1');
      
      when 117 =>                                                                          
        
        var_end_vector(127 downto 118) := (others => '0');
        var_end_vector(117 downto   0) := (others => '1');
      
      when 118 =>                                                                          
        
        var_end_vector(127 downto 119) := (others => '0');
        var_end_vector(118 downto   0) := (others => '1');
      
      when 119 =>                                                                          
        
        var_end_vector(127 downto 120) := (others => '0');
        var_end_vector(119 downto   0) := (others => '1');
      
      when 120 =>                                                                          
        
        var_end_vector(127 downto 121) := (others => '0');
        var_end_vector(120 downto   0) := (others => '1');
      
      when 121 =>                                                                          
        
        var_end_vector(127 downto 122) := (others => '0');
        var_end_vector(121 downto   0) := (others => '1');
      
      when 122 =>                                                                          
        
        var_end_vector(127 downto 123) := (others => '0');
        var_end_vector(122 downto   0) := (others => '1');
      
      when 123 =>                                                                          
        
        var_end_vector(127 downto 124) := (others => '0');
        var_end_vector(123 downto   0) := (others => '1');
      
      when 124 =>                                                                          
        
        var_end_vector(127 downto 125) := (others => '0');
        var_end_vector(124 downto   0) := (others => '1');
      
      when 125 =>                                                                          
        
        var_end_vector(127 downto 126) := (others => '0');
        var_end_vector(125 downto   0) := (others => '1');
      
      when 126 =>                                                                          
        
        var_end_vector(127 downto 127) := (others => '0');
        var_end_vector(126 downto   0) := (others => '1');
      
      when others =>
        
        var_end_vector(127 downto   0) := (others => '1');
      
    end case;
   
    Return (var_end_vector);
   
  end function get_end_128;
  
  
 
  
  
  
  
  
  
  
  
  
  
 
   
   
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: funct_clip_value
  --
  -- Function Description:
  --   Returns a value that cannot exceed a clip value.
  --
  -------------------------------------------------------------------
  function funct_clip_value (input_value : natural;
                             max_value   : natural) return natural is
  
    Variable temp_value : Natural := 0;
  
  begin
  
    If (input_value <= max_value) Then
    
      temp_value := input_value;
    
    Else 
    
      temp_value := max_value;
    
    End if;
   
    Return (temp_value);
   
   
  end function funct_clip_value;
  
   
   
  -- Constants
  Constant INTERNAL_CALC_WIDTH   : integer  := C_NUM_BYTES_WIDTH+(C_OP_MODE*2); -- Add 2 bits of math headroom
                                                                                -- if op Mode = 1
  
  
  -- Signals
  signal sig_ouput_stbs       : std_logic_vector(C_STRB_WIDTH-1 downto 0) := (others => '0');
  signal sig_start_offset_un  : unsigned(INTERNAL_CALC_WIDTH-1 downto 0)  := (others => '0');
  signal sig_end_offset_un    : unsigned(INTERNAL_CALC_WIDTH-1 downto 0)  := (others => '0');
 
  

begin --(architecture implementation)

 
  -- Assign the output strobe value
  strb_out <= sig_ouput_stbs ;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_OFF_OFF_CASE
  --
  -- If Generate Description:
  --  Calculates the internal start and end offsets for the 
  -- case when start and end offsets are being provided.
  --
  --
  ------------------------------------------------------------
  GEN_OFF_OFF_CASE : if (C_OP_MODE = 1) generate
 
 
    begin
     
      sig_start_offset_un <= RESIZE(UNSIGNED(start_addr_offset), INTERNAL_CALC_WIDTH);
     
      sig_end_offset_un   <= RESIZE(UNSIGNED(end_addr_offset), INTERNAL_CALC_WIDTH);
     
     
   
    end generate GEN_OFF_OFF_CASE;
  
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_OFF_LEN_CASE
  --
  -- If Generate Description:
  --  Calculates the internal start and end offsets for the 
  -- case when start offset and length are being provided.
  --
  ------------------------------------------------------------
  GEN_OFF_LEN_CASE : if (C_OP_MODE = 0) generate

   -- Local Constants Declarations
    Constant L_INTERNAL_CALC_WIDTH   : integer  := INTERNAL_CALC_WIDTH;
    Constant L_ONE                   : unsigned := TO_UNSIGNED(1, L_INTERNAL_CALC_WIDTH);
    Constant L_ZERO                  : unsigned := TO_UNSIGNED(0, L_INTERNAL_CALC_WIDTH);
    Constant MAX_VALUE               : natural  := C_STRB_WIDTH-1;
    
    
    
   -- local signals
    signal lsig_addr_offset_us       : unsigned(L_INTERNAL_CALC_WIDTH-1 downto 0) := (others => '0');
    signal lsig_num_valid_bytes_us   : unsigned(L_INTERNAL_CALC_WIDTH-1 downto 0) := (others => '0');
    signal lsig_length_adjust_us     : unsigned(L_INTERNAL_CALC_WIDTH-1 downto 0) := (others => '0');
    signal lsig_incr_offset_bytes_us : unsigned(L_INTERNAL_CALC_WIDTH-1 downto 0) := (others => '0');
    signal lsig_end_addr_us          : unsigned(L_INTERNAL_CALC_WIDTH-1 downto 0) := (others => '0');
    signal lsig_end_addr_int         : integer := 0;
    signal lsig_strt_addr_int        : integer := 0;
   
    

    begin
  
      lsig_addr_offset_us       <= RESIZE(UNSIGNED(start_addr_offset), L_INTERNAL_CALC_WIDTH); 
                                                                                            
      lsig_num_valid_bytes_us   <= RESIZE(UNSIGNED(num_valid_bytes)  , L_INTERNAL_CALC_WIDTH); 
      
      lsig_length_adjust_us     <= L_ZERO
        When (lsig_num_valid_bytes_us = L_ZERO)
        Else L_ONE;
      
      lsig_incr_offset_bytes_us <= lsig_num_valid_bytes_us - lsig_length_adjust_us;                             
                                                                                            
      lsig_end_addr_us          <= lsig_addr_offset_us + lsig_incr_offset_bytes_us;            
                                                                                            
      lsig_strt_addr_int        <= TO_INTEGER(lsig_addr_offset_us);                           
                                                                                            
      lsig_end_addr_int         <= TO_INTEGER(lsig_end_addr_us);                              
      
   
   
   
      
      sig_start_offset_un       <= TO_UNSIGNED(funct_clip_value(lsig_strt_addr_int, MAX_VALUE), INTERNAL_CALC_WIDTH);
                                  
      sig_end_offset_un         <= TO_UNSIGNED(funct_clip_value(lsig_end_addr_int, MAX_VALUE), INTERNAL_CALC_WIDTH) ;
      
    
    
    
    
                                                                                            
   
    end generate GEN_OFF_LEN_CASE;
  
  
  
  
  
  
  
 
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_1BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 1-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_1BIT_CASE : if (C_STRB_WIDTH = 1) generate
 
 
    begin
  
      sig_ouput_stbs    <=  (others => '1') ;
      
   
    end generate GEN_1BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_2BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 2-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_2BIT_CASE : if (C_STRB_WIDTH = 2) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=  0;
    Signal lsig_end_offset   : Natural :=  1;
    
    Signal lsig_start_vect   : std_logic_vector(1 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(1 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(1 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_2(lsig_start_offset);
      lsig_end_vect     <=  get_end_2(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_2BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_4BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 4-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_4BIT_CASE : if (C_STRB_WIDTH = 4) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=  0;
    Signal lsig_end_offset   : Natural :=  3;
    
    Signal lsig_start_vect   : std_logic_vector(3 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(3 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(3 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_4(lsig_start_offset);
      lsig_end_vect     <=  get_end_4(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_4BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_8BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 8-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_8BIT_CASE : if (C_STRB_WIDTH = 8) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=  0;
    Signal lsig_end_offset   : Natural :=  7;
    
    Signal lsig_start_vect   : std_logic_vector(7 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(7 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(7 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_8(lsig_start_offset);
      lsig_end_vect     <=  get_end_8(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_8BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_16BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 16-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_16BIT_CASE : if (C_STRB_WIDTH = 16) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=  0;
    Signal lsig_end_offset   : Natural := 15;
    
    Signal lsig_start_vect   : std_logic_vector(15 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(15 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(15 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_16(lsig_start_offset);
      lsig_end_vect     <=  get_end_16(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_16BIT_CASE;
  
  
  
  
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_32BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 32-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_32BIT_CASE : if (C_STRB_WIDTH = 32) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=  0;
    Signal lsig_end_offset   : Natural := 31;
    
    Signal lsig_start_vect   : std_logic_vector(31 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(31 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(31 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_32(lsig_start_offset);
      lsig_end_vect     <=  get_end_32(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_32BIT_CASE;
  
  
  
  
  
 
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_64BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 64-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_64BIT_CASE : if (C_STRB_WIDTH = 64) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=  0;
    Signal lsig_end_offset   : Natural := 63;
    
    Signal lsig_start_vect   : std_logic_vector(63 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(63 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(63 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_64(lsig_start_offset);
      lsig_end_vect     <=  get_end_64(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_64BIT_CASE;
  
  
  
 
 
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: GEN_128BIT_CASE
  --
  -- If Generate Description:
  --  Generates the strobes for the 64-bit strobe width case.
  --
  --
  ------------------------------------------------------------
  GEN_128BIT_CASE : if (C_STRB_WIDTH = 128) generate
 
    -- local signals
    Signal lsig_start_offset : Natural :=   0;
    Signal lsig_end_offset   : Natural := 127;
    
    Signal lsig_start_vect   : std_logic_vector(127 downto 0) := (others => '0');
    Signal lsig_end_vect     : std_logic_vector(127 downto 0) := (others => '0');
    Signal lsig_cmplt_vect   : std_logic_vector(127 downto 0) := (others => '0');
    
 
    begin
 
  
      lsig_start_offset <=  TO_INTEGER(sig_start_offset_un) ;
      lsig_end_offset   <=  TO_INTEGER(sig_end_offset_un  ) ;
      
  
      lsig_start_vect   <=  get_start_128(lsig_start_offset);
      lsig_end_vect     <=  get_end_128(lsig_end_offset)    ;
  
  
      lsig_cmplt_vect   <=  lsig_start_vect and
                            lsig_end_vect; 
  
      sig_ouput_stbs    <=  lsig_cmplt_vect ;
      
   
    end generate GEN_128BIT_CASE;
  
  
  
  
  
 
 
 
 
 

end implementation;
