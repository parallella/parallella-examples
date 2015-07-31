  -------------------------------------------------------------------------------
  -- axi_datamover_stbs_set_nodre.vhd
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
  -- Filename:        axi_datamover_stbs_set_nodre.vhd
  --
  -- Description:     
  --    This file implements a module to count the number of strobe bits that 
  --    are asserted active high on the input strobe bus. This module does not
  --    support sparse strobe assertions.              
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  


  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_stbs_set_nodre is
    generic (
      
      C_STROBE_WIDTH    : Integer range 1 to 128 := 8
        -- Specifies the width (in bits) of the input strobe bus.
      
      );
    port (
      
      -- Input Strobe bus ----------------------------------------------------
                                                                            --
      tstrb_in          : in  std_logic_vector(C_STROBE_WIDTH-1 downto 0);  --
      ------------------------------------------------------------------------
      
      
      -- Asserted Strobes count output ---------------------------------------
                                                                            --
      num_stbs_asserted : Out std_logic_vector(7 downto 0)                  --
        -- Indicates the number of asserted tstrb_in bits                   --
      ------------------------------------------------------------------------
     
      );
  
  end entity axi_datamover_stbs_set_nodre;
  
  
  architecture implementation of axi_datamover_stbs_set_nodre is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    -- Function
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_8bit_stbs_set
    --
    -- Function Description:
    --  Implements an 8-bit lookup table for calculating the number
    -- of asserted bits within an 8-bit strobe vector.
    --
    -- Note that this function assumes that asserted strobes are 
    -- contiguous with each other (no sparse strobe assertions). 
    --
    -------------------------------------------------------------------
    function funct_8bit_stbs_set (strb_8 : std_logic_vector(7 downto 0)) return unsigned is
    
      Constant ASSERTED_VALUE_WIDTH : integer := 4;-- 4 bits needed
      
      
      Variable lvar_num_set : Integer range 0 to 8 := 0;
    
    begin
    
      case strb_8 is
        
        -------  1 bit --------------------------
        when "00000001" =>
        
          lvar_num_set := 1;
        
        
        -------  2 bit --------------------------
        when "00000011" =>
        
          lvar_num_set := 2;
        
        
        -------  3 bit --------------------------
        when "00000111" =>
        
          lvar_num_set := 3;
        
        
        -------  4 bit --------------------------
        when "00001111" =>
             
        
          lvar_num_set := 4;
        
        
        -------  5 bit --------------------------
        when "00011111" =>
        
          lvar_num_set := 5;
        
        
        -------  6 bit --------------------------
        when "00111111" =>
        
          lvar_num_set := 6;
        
        
        -------  7 bit --------------------------
        when "01111111" =>
        
          lvar_num_set := 7;
        
        
        -------  8 bit --------------------------
        when "11111111" =>
        
          lvar_num_set := 8;
        
        
        ------- all zeros or sparse strobes ------
        When others =>  
        
          lvar_num_set := 0;
        
      end case;
      
      
      Return (TO_UNSIGNED(lvar_num_set, ASSERTED_VALUE_WIDTH));
       
       
      
    end function funct_8bit_stbs_set;


    function funct_256bit_stbs_set (strb_3 : std_logic_vector(2 downto 0)) return unsigned is
    
      Constant ASSERTED_VALUE_WIDTH : integer := 5;-- 4 bits needed
      
      
      Variable lvar_num_set : Integer range 0 to 24 := 0;
    
    begin
    
      case strb_3 is
        
--        when "0000000" =>
        
--          lvar_num_set := 0;
        -------  1 bit --------------------------
        when "001" =>
        
          lvar_num_set := 8;
        
        -------  2 bit --------------------------
        when "011" =>
        
          lvar_num_set := 16;
        
        -------  3 bit --------------------------
        when "111" =>
        
          lvar_num_set := 24;

        ------- all zeros or sparse strobes ------
        When others =>  
        
          lvar_num_set := 0;
        
      end case;
      
      
      Return (TO_UNSIGNED(lvar_num_set, ASSERTED_VALUE_WIDTH));
       
       
      
    end function funct_256bit_stbs_set;




    function funct_512bit_stbs_set (strb_3 : std_logic_vector(6 downto 0)) return unsigned is
    
      Constant ASSERTED_VALUE_WIDTH : integer := 6;-- 4 bits needed
      
      
      Variable lvar_num_set : Integer range 0 to 56 := 0;
    
    begin
    
      case strb_3 is
        
--        when "0000000" =>
        
--          lvar_num_set := 0;
        -------  1 bit --------------------------
        when "0000001" =>
        
          lvar_num_set := 8;
        
        -------  2 bit --------------------------
        when "0000011" =>
        
          lvar_num_set := 16;
        
        -------  3 bit --------------------------
        when "0000111" =>
        
          lvar_num_set := 24;

        when "0001111" =>
        
          lvar_num_set := 32;

        when "0011111" =>
        
          lvar_num_set := 40;

        when "0111111" =>
        
          lvar_num_set := 48;

        when "1111111" =>
        
          lvar_num_set := 56;

        ------- all zeros or sparse strobes ------
        When others =>  
        
          lvar_num_set := 0;
        
      end case;
      
      
      Return (TO_UNSIGNED(lvar_num_set, ASSERTED_VALUE_WIDTH));
       
       
      
    end function funct_512bit_stbs_set;


    function funct_1024bit_stbs_set (strb_3 : std_logic_vector(14 downto 0)) return unsigned is
    
      Constant ASSERTED_VALUE_WIDTH : integer := 7;-- 4 bits needed
      
      
      Variable lvar_num_set : Integer range 0 to 120 := 0;
    
    begin
    
      case strb_3 is
        
        -------  1 bit --------------------------
        when "000000000000001" =>
        
          lvar_num_set := 8;
        
        -------  2 bit --------------------------
        when "000000000000011" =>
        
          lvar_num_set := 16;
        
        -------  3 bit --------------------------
        when "000000000000111" =>
        
          lvar_num_set := 24;

        when "000000000001111" =>
        
          lvar_num_set := 32;

        when "000000000011111" =>
        
          lvar_num_set := 40;

        when "000000000111111" =>
        
          lvar_num_set := 48;

        when "000000001111111" =>
        
          lvar_num_set := 56;

        when "000000011111111" =>
        
          lvar_num_set := 64;

        when "000000111111111" =>
        
          lvar_num_set := 72;

        when "000001111111111" =>
        
          lvar_num_set := 80;

        when "000011111111111" =>
        
          lvar_num_set := 88;

        when "000111111111111" =>
        
          lvar_num_set := 96;

        when "001111111111111" =>
        
          lvar_num_set := 104;

        when "011111111111111" =>
        
          lvar_num_set := 112;

        when "111111111111111" =>
        
          lvar_num_set := 120;

        ------- all zeros or sparse strobes ------
        When others =>  
        
          lvar_num_set := 0;
        
      end case;
      
      
      Return (TO_UNSIGNED(lvar_num_set, ASSERTED_VALUE_WIDTH));
       
       
      
    end function funct_1024bit_stbs_set;


--    function funct_8bit_stbs_set (strb_8 : std_logic_vector(7 downto 0)) return unsigned is
--    
--      Constant ASSERTED_VALUE_WIDTH : integer := 4;-- 4 bits needed
--      
--      
--      Variable lvar_num_set : Integer range 0 to 8 := 0;
--    
--    begin
--    
--      case strb_8 is
--        
----        -------  1 bit --------------------------
--        when "00000001" | "00000010" | "00000100" | "00001000" | 
--             "00010000" | "00100000" | "01000000" | "10000000" =>
--        
--          lvar_num_set := 1;
--        
--        
--        -------  2 bit --------------------------
--        when "00000011" | "00000110" | "00001100" | "00011000" | 
--             "00110000" | "01100000" | "11000000"  =>
--        
--          lvar_num_set := 2;
--        
--        
--        -------  3 bit --------------------------
--        when "00000111" | "00001110" | "00011100" | "00111000" | 
--             "01110000" | "11100000"   =>
--        
--          lvar_num_set := 3;
--        
--        
--        -------  4 bit --------------------------
--        when "00001111" | "00011110" | "00111100" | "01111000" | 
--             "11110000"    =>
--        
--          lvar_num_set := 4;
--        
--        
--        -------  5 bit --------------------------
--        when "00011111" | "00111110" | "01111100" | "11111000"  =>
--        
--          lvar_num_set := 5;
--        
--        
--        -------  6 bit --------------------------
--        when "00111111" | "01111110" | "11111100"  =>
--        
--          lvar_num_set := 6;
--        
--        
--        -------  7 bit --------------------------
--        when "01111111" | "11111110"   =>
--        
--          lvar_num_set := 7;
--        
--        
--        -------  8 bit --------------------------
--        when "11111111"    =>
--        
--          lvar_num_set := 8;
--        
--        
--        ------- all zeros or sparse strobes ------
--        When others =>  
--        
--          lvar_num_set := 0;
--        
--      end case;
--      
--      
--      Return (TO_UNSIGNED(lvar_num_set, ASSERTED_VALUE_WIDTH));
--       
--       
--      
--    end function funct_8bit_stbs_set;
    
    
    
    
    
    
    -- Constants
    
    Constant LOGIC_LOW              : std_logic := '0';
    Constant LOGIC_HIGH             : std_logic := '1';
    Constant BITS_FOR_STBS_ASSERTED : integer := 8; -- increments of 8 bits
    Constant NUM_ZEROS_WIDTH        : integer := BITS_FOR_STBS_ASSERTED;
    
    
    -- Signals
    
    signal sig_strb_input           : std_logic_vector(C_STROBE_WIDTH-1 downto 0) := (others => '0');
    signal sig_stbs_asserted        : std_logic_vector(BITS_FOR_STBS_ASSERTED-1 downto 0) := (others => '0');


    
    
  begin --(architecture implementation)
  
   
   num_stbs_asserted     <= sig_stbs_asserted;
   
   sig_strb_input        <= tstrb_in         ;
    
    
    
    
 
 
    -------------------------------------------------------------------------
    ----------------  Asserted TSTRB calculation logic  --------------------- 
    -------------------------------------------------------------------------
    
    
 
   
     
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_1_STRB
     --
     -- If Generate Description:
     --   1-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_1_STRB : if (C_STROBE_WIDTH = 1) generate
     
     
        begin
     
          -------------------------------------------------------------
          -- Combinational Process
          --
          -- Label: IMP_1BIT_STRB
          --
          -- Process Description:
          --
          --
          -------------------------------------------------------------
          IMP_1BIT_STRB : process (sig_strb_input)
             begin
          
               
               -- Concatonate the strobe to the ls bit of
               -- the asserted value
               sig_stbs_asserted <= "0000000" &
                                    sig_strb_input(0);
          
             end process IMP_1BIT_STRB; 
        
        end generate GEN_1_STRB;
   
   
   
   
   
   
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_2_STRB
     --
     -- If Generate Description:
     --   2-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_2_STRB : if (C_STROBE_WIDTH = 2) generate
     
     
        signal lsig_num_set     : integer range 0 to 2 := 0;
        signal lsig_strb_vect   : std_logic_vector(1 downto 0) := (others => '0');
        
        begin
     
          
          lsig_strb_vect <=  sig_strb_input;
          
          
          -------------------------------------------------------------
          -- Combinational Process
          --
          -- Label: IMP_2BIT_STRB
          --
          -- Process Description:
          --  Calculates the number of strobes set fo the 2-bit 
          -- strobe case
          --
          -------------------------------------------------------------
          IMP_2BIT_STRB : process (lsig_strb_vect)
             begin
              
               case lsig_strb_vect is
                 when "01" | "10" =>
                   lsig_num_set <= 1;
                 when "11" =>
                   lsig_num_set <= 2;
                 when others =>
                   lsig_num_set <= 0;
               end case;
               
             end process IMP_2BIT_STRB; 
             
          
          sig_stbs_asserted <= STD_LOGIC_VECTOR(TO_UNSIGNED(lsig_num_set,
                                                            BITS_FOR_STBS_ASSERTED));
     
        
        end generate GEN_2_STRB;
   
   
   
   
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_4_STRB
     --
     -- If Generate Description:
     --   4-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_4_STRB : if (C_STROBE_WIDTH = 4) generate
     
     
       signal lsig_strb_vect   : std_logic_vector(7 downto 0) := (others => '0');
        
       begin
     
          
         lsig_strb_vect <=  "0000" & sig_strb_input; -- make and 8-bit vector 
                                                     -- for the function call
          
          
         sig_stbs_asserted <= STD_LOGIC_VECTOR(RESIZE(funct_8bit_stbs_set(lsig_strb_vect),
                                                      BITS_FOR_STBS_ASSERTED));
     
     
       end generate GEN_4_STRB;
   
   
  
  
   
   
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_8_STRB
     --
     -- If Generate Description:
     --   8-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_8_STRB : if (C_STROBE_WIDTH = 8) generate
     
     
       signal lsig_strb_vect   : std_logic_vector(7 downto 0) := (others => '0');
        
       begin
     
          
         lsig_strb_vect <=  sig_strb_input; -- make and 8-bit vector 
                                            -- for the function call
          
          
         sig_stbs_asserted <= STD_LOGIC_VECTOR(RESIZE(funct_8bit_stbs_set(lsig_strb_vect),
                                                           BITS_FOR_STBS_ASSERTED));
     
     
       end generate GEN_8_STRB;
   
   
   
   
   
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_16_STRB
     --
     -- If Generate Description:
     --   16-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_16_STRB : if (C_STROBE_WIDTH = 16) generate
     
       Constant RESULT_BIT_WIDTH : integer := 8;
       
       signal lsig_strb_vect1    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect2    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_num_in_stbs1  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs2  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_total     : unsigned(RESULT_BIT_WIDTH-1 downto 0) := (others => '0');
        
       begin
     
          
         lsig_strb_vect1   <=  sig_strb_input(7 downto 0); -- make and 8-bit vector 
                                                           -- for the function call
          
         lsig_strb_vect2   <=  sig_strb_input(15 downto 8); -- make and 8-bit vector 
                                                            -- for the function call
          
          
         lsig_num_in_stbs1 <=  funct_8bit_stbs_set(lsig_strb_vect1) ;
          
         lsig_num_in_stbs2 <=  funct_8bit_stbs_set(lsig_strb_vect2) ;
          
          
         lsig_num_total    <= RESIZE(lsig_num_in_stbs1 , RESULT_BIT_WIDTH) +
                              RESIZE(lsig_num_in_stbs2 , RESULT_BIT_WIDTH);
          
          
          
         sig_stbs_asserted <= STD_LOGIC_VECTOR(lsig_num_total);
     
     
       end generate GEN_16_STRB;
   
   
   
   
   
   
   
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_32_STRB
     --
     -- If Generate Description:
     --   32-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_32_STRB : if (C_STROBE_WIDTH = 32) generate
     
       Constant RESULT_BIT_WIDTH : integer := 8;
       
       signal lsig_strb_vect1   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect2   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect3   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect4   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_num_in_stbs1 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs2 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs3 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs4 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_total    : unsigned(RESULT_BIT_WIDTH-1 downto 0) := (others => '0');

       signal lsig_new_vect     : std_logic_vector (2 downto 0) := (others => '0'); 
       signal lsig_num_new_stbs1 : unsigned(4 downto 0) := (others => '0');
       signal lsig_new_vect1 : std_logic_vector (7 downto 0) := (others => '0');
       signal lsig_num_new_vect1 : unsigned(3 downto 0) := (others => '0');
        
       begin
     
          
         lsig_strb_vect1   <=  sig_strb_input(7 downto 0);   -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect2   <=  sig_strb_input(15 downto 8);  -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect3   <=  sig_strb_input(23 downto 16); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect4   <=  sig_strb_input(31 downto 24); -- make and 8-bit vector 
                                                       -- for the function call
          
          
         lsig_num_in_stbs1 <=  funct_8bit_stbs_set(lsig_strb_vect1) ;
          
         lsig_num_in_stbs2 <=  funct_8bit_stbs_set(lsig_strb_vect2) ;
         
         lsig_num_in_stbs3 <=  funct_8bit_stbs_set(lsig_strb_vect3) ;
         
         lsig_num_in_stbs4 <=  funct_8bit_stbs_set(lsig_strb_vect4) ;
          
          
     --    lsig_num_total    <= RESIZE(lsig_num_in_stbs1 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs2 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs3 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs4 , RESULT_BIT_WIDTH);
          
         sig_stbs_asserted <= STD_LOGIC_VECTOR(lsig_num_total);

         lsig_new_vect <= sig_strb_input (24) & sig_strb_input (16) & sig_strb_input (8); 

         lsig_num_new_stbs1 <=  funct_256bit_stbs_set(lsig_new_vect) ;

         lsig_num_new_vect1 <= funct_8bit_stbs_set(lsig_new_vect1);

         lsig_num_total    <= RESIZE(lsig_num_new_stbs1 , RESULT_BIT_WIDTH) +
                              RESIZE(lsig_num_new_vect1 , RESULT_BIT_WIDTH);

     process (lsig_new_vect, sig_strb_input)
     begin
      case lsig_new_vect is
        
        -------  1 bit --------------------------
        when "000" =>
          lsig_new_vect1 <= sig_strb_input (7 downto 0); 

        when "001" =>

          lsig_new_vect1 <= sig_strb_input (15 downto 8); 

        -------  2 bit --------------------------
        when "011" =>

          lsig_new_vect1 <= sig_strb_input (23 downto 16); 

        -------  3 bit --------------------------
        when "111" =>

          lsig_new_vect1 <= sig_strb_input (31 downto 24); 


        ------- all zeros or sparse strobes ------
        When others =>

          lsig_new_vect1 <= (others => '0');

      end case;
      end process;
     
     
       end generate GEN_32_STRB;
   
   
   
 
 
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_64_STRB
     --
     -- If Generate Description:
     --   64-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_64_STRB : if (C_STROBE_WIDTH = 64) generate
     
       Constant RESULT_BIT_WIDTH : integer := 8;
       
       signal lsig_strb_vect1   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect2   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect3   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect4   : std_logic_vector(7 downto 0) := (others => '0');
       
       signal lsig_strb_vect5   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect6   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect7   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect8   : std_logic_vector(7 downto 0) := (others => '0');
       
       signal lsig_num_in_stbs1 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs2 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs3 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs4 : unsigned(3 downto 0) := (others => '0');
       
       signal lsig_num_in_stbs5 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs6 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs7 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs8 : unsigned(3 downto 0) := (others => '0');
       
       signal lsig_num_total    : unsigned(RESULT_BIT_WIDTH-1 downto 0) := (others => '0');
       signal lsig_num_total1    : unsigned(RESULT_BIT_WIDTH-1 downto 0) := (others => '0');
       signal lsig_new_vect     : std_logic_vector (6 downto 0) := (others => '0'); 
       signal lsig_num_new_stbs1 : unsigned(5 downto 0) := (others => '0');
       signal lsig_new_vect1 : std_logic_vector (7 downto 0) := (others => '0');
       signal lsig_num_new_vect1 : unsigned(3 downto 0) := (others => '0');
       
        
       begin
     
          
         lsig_strb_vect1   <=  sig_strb_input(7 downto 0);   -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect2   <=  sig_strb_input(15 downto 8);  -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect3   <=  sig_strb_input(23 downto 16); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect4   <=  sig_strb_input(31 downto 24); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect5   <=  sig_strb_input(39 downto 32);   -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect6   <=  sig_strb_input(47 downto 40);  -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect7   <=  sig_strb_input(55 downto 48); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect8   <=  sig_strb_input(63 downto 56); -- make and 8-bit vector 
                                                       -- for the function call
          



          
         lsig_num_in_stbs1 <=  funct_8bit_stbs_set(lsig_strb_vect1) ;
          
         lsig_num_in_stbs2 <=  funct_8bit_stbs_set(lsig_strb_vect2) ;
         
         lsig_num_in_stbs3 <=  funct_8bit_stbs_set(lsig_strb_vect3) ;
         
         lsig_num_in_stbs4 <=  funct_8bit_stbs_set(lsig_strb_vect4) ;
   
   
         lsig_num_in_stbs5 <=  funct_8bit_stbs_set(lsig_strb_vect5) ;
   
         lsig_num_in_stbs6 <=  funct_8bit_stbs_set(lsig_strb_vect6) ;
   
         lsig_num_in_stbs7 <=  funct_8bit_stbs_set(lsig_strb_vect7) ;
   
         lsig_num_in_stbs8 <=  funct_8bit_stbs_set(lsig_strb_vect8) ;
   
          
          
     --    lsig_num_total    <= RESIZE(lsig_num_in_stbs1 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs2 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs3 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs4 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs5 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs6 , RESULT_BIT_WIDTH) +
     --                         RESIZE(lsig_num_in_stbs7 , RESULT_BIT_WIDTH) +
      --                        RESIZE(lsig_num_in_stbs8 , RESULT_BIT_WIDTH);
          
          
          
         sig_stbs_asserted <= STD_LOGIC_VECTOR(lsig_num_total);


         lsig_new_vect <=  sig_strb_input(56) & sig_strb_input (48) & sig_strb_input (40)  
                         & sig_strb_input(32) & sig_strb_input (24) & sig_strb_input (16) & sig_strb_input (8); 

         lsig_num_new_stbs1 <=  funct_512bit_stbs_set(lsig_new_vect) ;

         lsig_num_new_vect1 <= funct_8bit_stbs_set(lsig_new_vect1);

         lsig_num_total    <= RESIZE(lsig_num_new_stbs1 , RESULT_BIT_WIDTH) +
                              RESIZE(lsig_num_new_vect1 , RESULT_BIT_WIDTH);

     process (lsig_new_vect, sig_strb_input)
     begin
      case lsig_new_vect is
        
        -------  1 bit --------------------------
        when "0000000" =>
          lsig_new_vect1 <= sig_strb_input (7 downto 0); 

        when "0000001" =>

          lsig_new_vect1 <= sig_strb_input (15 downto 8); 

        -------  2 bit --------------------------
        when "0000011" =>

          lsig_new_vect1 <= sig_strb_input (23 downto 16); 

        -------  3 bit --------------------------
        when "0000111" =>

          lsig_new_vect1 <= sig_strb_input (31 downto 24); 

        when "0001111" =>

          lsig_new_vect1 <= sig_strb_input (39 downto 32); 

        when "0011111" =>

          lsig_new_vect1 <= sig_strb_input (47 downto 40); 

        when "0111111" =>

          lsig_new_vect1 <= sig_strb_input (55 downto 48); 

        when "1111111" =>

          lsig_new_vect1 <= sig_strb_input (63 downto 56); 


        ------- all zeros or sparse strobes ------
        When others =>

          lsig_new_vect1 <= (others => '0');

      end case;
      end process;

     
     
       end generate GEN_64_STRB;
   
   
   
 
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_128_STRB
     --
     -- If Generate Description:
     --   128-bit strobe bus width case
     --
     --
     ------------------------------------------------------------
     GEN_128_STRB : if (C_STROBE_WIDTH = 128) generate
     
       Constant RESULT_BIT_WIDTH : integer := 8;
       
       signal lsig_strb_vect1    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect2    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect3    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect4    : std_logic_vector(7 downto 0) := (others => '0');
       
       signal lsig_strb_vect5    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect6    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect7    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect8    : std_logic_vector(7 downto 0) := (others => '0');
       
       signal lsig_strb_vect9    : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect10   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect11   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect12   : std_logic_vector(7 downto 0) := (others => '0');
       
       signal lsig_strb_vect13   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect14   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect15   : std_logic_vector(7 downto 0) := (others => '0');
       signal lsig_strb_vect16   : std_logic_vector(7 downto 0) := (others => '0');
       
       
       
       signal lsig_num_in_stbs1  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs2  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs3  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs4  : unsigned(3 downto 0) := (others => '0');
       
       signal lsig_num_in_stbs5  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs6  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs7  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs8  : unsigned(3 downto 0) := (others => '0');
       
       signal lsig_num_in_stbs9  : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs10 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs11 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs12 : unsigned(3 downto 0) := (others => '0');
       
       signal lsig_num_in_stbs13 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs14 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs15 : unsigned(3 downto 0) := (others => '0');
       signal lsig_num_in_stbs16 : unsigned(3 downto 0) := (others => '0');
       
       signal lsig_num_total     : unsigned(RESULT_BIT_WIDTH-1 downto 0) := (others => '0');
       signal lsig_num_total1    : unsigned(RESULT_BIT_WIDTH-1 downto 0) := (others => '0');
       signal lsig_new_vect     : std_logic_vector (14 downto 0) := (others => '0'); 
       signal lsig_num_new_stbs1 : unsigned(6 downto 0) := (others => '0');
       signal lsig_new_vect1 : std_logic_vector (7 downto 0) := (others => '0');
       signal lsig_num_new_vect1 : unsigned(3 downto 0) := (others => '0');
        
       begin
     
          
         lsig_strb_vect1   <=  sig_strb_input(7 downto 0);   -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect2   <=  sig_strb_input(15 downto 8);  -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect3   <=  sig_strb_input(23 downto 16); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect4   <=  sig_strb_input(31 downto 24); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect5   <=  sig_strb_input(39 downto 32);   -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect6   <=  sig_strb_input(47 downto 40);  -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect7   <=  sig_strb_input(55 downto 48); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect8   <=  sig_strb_input(63 downto 56); -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect9   <=  sig_strb_input(71 downto 64);   -- make and 8-bit vector 
                                                       -- for the function call
          
         lsig_strb_vect10  <=  sig_strb_input(79 downto 72);  -- make and 8-bit vector 
                                                      -- for the function call
          
         lsig_strb_vect11  <=  sig_strb_input(87 downto 80); -- make and 8-bit vector 
                                                      -- for the function call
          
         lsig_strb_vect12  <=  sig_strb_input(95 downto 88); -- make and 8-bit vector 
                                                      -- for the function call
          
         lsig_strb_vect13  <=  sig_strb_input(103 downto 96);   -- make and 8-bit vector 
                                                      -- for the function call
          
         lsig_strb_vect14  <=  sig_strb_input(111 downto 104);  -- make and 8-bit vector 
                                                      -- for the function call
          
         lsig_strb_vect15  <=  sig_strb_input(119 downto 112); -- make and 8-bit vector 
                                                      -- for the function call
          
         lsig_strb_vect16  <=  sig_strb_input(127 downto 120); -- make and 8-bit vector 
                                                       -- for the function call
          
          
          
         lsig_num_in_stbs1  <=  funct_8bit_stbs_set(lsig_strb_vect1) ;
          
         lsig_num_in_stbs2  <=  funct_8bit_stbs_set(lsig_strb_vect2) ;
         
         lsig_num_in_stbs3  <=  funct_8bit_stbs_set(lsig_strb_vect3) ;
         
         lsig_num_in_stbs4  <=  funct_8bit_stbs_set(lsig_strb_vect4) ;
   
   
         lsig_num_in_stbs5  <=  funct_8bit_stbs_set(lsig_strb_vect5) ;
   
         lsig_num_in_stbs6  <=  funct_8bit_stbs_set(lsig_strb_vect6) ;
   
         lsig_num_in_stbs7  <=  funct_8bit_stbs_set(lsig_strb_vect7) ;
   
         lsig_num_in_stbs8  <=  funct_8bit_stbs_set(lsig_strb_vect8) ;
         
   
         lsig_num_in_stbs9  <=  funct_8bit_stbs_set(lsig_strb_vect9) ;
          
         lsig_num_in_stbs10 <=  funct_8bit_stbs_set(lsig_strb_vect10) ;
         
         lsig_num_in_stbs11 <=  funct_8bit_stbs_set(lsig_strb_vect11) ;
         
         lsig_num_in_stbs12 <=  funct_8bit_stbs_set(lsig_strb_vect12) ;
   
   
         lsig_num_in_stbs13 <=  funct_8bit_stbs_set(lsig_strb_vect13) ;
   
         lsig_num_in_stbs14 <=  funct_8bit_stbs_set(lsig_strb_vect14) ;
   
         lsig_num_in_stbs15 <=  funct_8bit_stbs_set(lsig_strb_vect15) ;
   
         lsig_num_in_stbs16 <=  funct_8bit_stbs_set(lsig_strb_vect16) ;
   
          
          
  --       lsig_num_total     <= RESIZE(lsig_num_in_stbs1  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs2  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs3  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs4  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs5  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs6  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs7  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs8  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs9  , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs10 , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs11 , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs12 , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs13 , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs14 , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs15 , RESULT_BIT_WIDTH) +
  --                             RESIZE(lsig_num_in_stbs16 , RESULT_BIT_WIDTH);
          
          
          
         sig_stbs_asserted  <= STD_LOGIC_VECTOR(lsig_num_total);

         lsig_new_vect <= sig_strb_input (120) & sig_strb_input (112)   
                          & sig_strb_input(104) & sig_strb_input (96) & sig_strb_input (88)   
                          & sig_strb_input(80) & sig_strb_input (72) & sig_strb_input (64)   
                          & sig_strb_input(56) & sig_strb_input (48) & sig_strb_input (40)  
                          & sig_strb_input(32) & sig_strb_input (24) & sig_strb_input (16) & sig_strb_input (8); 

         lsig_num_new_stbs1 <=  funct_1024bit_stbs_set(lsig_new_vect) ;

         lsig_num_new_vect1 <= funct_8bit_stbs_set(lsig_new_vect1);

         lsig_num_total    <= RESIZE(lsig_num_new_stbs1 , RESULT_BIT_WIDTH) +
                              RESIZE(lsig_num_new_vect1 , RESULT_BIT_WIDTH);

     process (lsig_new_vect, sig_strb_input)
     begin
      case lsig_new_vect is
        
        -------  1 bit --------------------------
        when "000000000000000" =>
          lsig_new_vect1 <= sig_strb_input (7 downto 0); 

        when "000000000000001" =>

          lsig_new_vect1 <= sig_strb_input (15 downto 8); 

        -------  2 bit --------------------------
        when "000000000000011" =>

          lsig_new_vect1 <= sig_strb_input (23 downto 16); 

        -------  3 bit --------------------------
        when "000000000000111" =>

          lsig_new_vect1 <= sig_strb_input (31 downto 24); 

        when "000000000001111" =>

          lsig_new_vect1 <= sig_strb_input (39 downto 32); 

        when "000000000011111" =>

          lsig_new_vect1 <= sig_strb_input (47 downto 40); 

        when "000000000111111" =>

          lsig_new_vect1 <= sig_strb_input (55 downto 48); 

        when "000000001111111" =>

          lsig_new_vect1 <= sig_strb_input (63 downto 56); 

        when "000000011111111" =>

          lsig_new_vect1 <= sig_strb_input (71 downto 64); 

        when "000000111111111" =>

          lsig_new_vect1 <= sig_strb_input (79 downto 72); 

        when "000001111111111" =>

          lsig_new_vect1 <= sig_strb_input (87 downto 80); 

        when "000011111111111" =>

          lsig_new_vect1 <= sig_strb_input (95 downto 88); 

        when "000111111111111" =>

          lsig_new_vect1 <= sig_strb_input (103 downto 96); 

        when "001111111111111" =>

          lsig_new_vect1 <= sig_strb_input (111 downto 104); 

        when "011111111111111" =>

          lsig_new_vect1 <= sig_strb_input (119 downto 112); 

        when "111111111111111" =>

          lsig_new_vect1 <= sig_strb_input (127 downto 120); 

        ------- all zeros or sparse strobes ------
        When others =>

          lsig_new_vect1 <= (others => '0');

      end case;
      end process;

     
     
       end generate GEN_128_STRB;
   
  
  
  end implementation;
