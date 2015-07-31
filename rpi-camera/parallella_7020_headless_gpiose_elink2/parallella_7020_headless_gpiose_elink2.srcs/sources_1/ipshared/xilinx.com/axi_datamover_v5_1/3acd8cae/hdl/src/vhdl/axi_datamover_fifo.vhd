-------------------------------------------------------------------------------
-- axi_datamover_fifo.vhd - entity/architecture pair

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
-- Filename:        axi_datamover_fifo.vhd
-- Version:         initial
-- Description:     
--    This file is a wrapper file for the Synchronous FIFO used by the DataMover. 
-- 
--                  
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
---------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;



library lib_pkg_v1_0;
use lib_pkg_v1_0.lib_pkg.all;
use lib_pkg_v1_0.lib_pkg.clog2;

library lib_srl_fifo_v1_0;
use lib_srl_fifo_v1_0.srl_fifo_f;


library axi_datamover_v5_1;
use axi_datamover_v5_1.axi_datamover_sfifo_autord;
use axi_datamover_v5_1.axi_datamover_afifo_autord;


-------------------------------------------------------------------------------

entity axi_datamover_fifo is
  generic (
     C_DWIDTH            : integer := 32  ;
       -- Bit width of the FIFO
       
     C_DEPTH             : integer := 4   ;
       -- Depth of the fifo in fifo width words
     
     C_IS_ASYNC          : Integer range 0 to 1 := 0 ;
       -- 0 = Syncronous FIFO
       -- 1 = Asynchronous (2 clock) FIFO
     
     C_PRIM_TYPE         : Integer range 0 to 2 := 2 ;
       -- 0 = Register
       -- 1 = Block Memory
       -- 2 = SRL
     
     C_FAMILY            : String  := "virtex7"
       -- Specifies the Target FPGA device family
     
    );
  port (
     
     
     
     -- Write Clock and reset -----------------
     fifo_wr_reset        : In  std_logic;   --
     fifo_wr_clk          : In  std_logic;   --
     ------------------------------------------
     
     -- Write Side ------------------------------------------------------
     fifo_wr_tvalid       : In  std_logic;                             --
     fifo_wr_tready       : Out std_logic;                             --
     fifo_wr_tdata        : In  std_logic_vector(C_DWIDTH-1 downto 0); --
     fifo_wr_full         : Out std_logic;                             --
     --------------------------------------------------------------------
    
    
     -- Read Clock and reset -----------------------------------------------
     fifo_async_rd_reset  : In  std_logic; -- only used if C_IS_ASYNC = 1 --  
     fifo_async_rd_clk    : In  std_logic; -- only used if C_IS_ASYNC = 1 --
     -----------------------------------------------------------------------
     
     -- Read Side --------------------------------------------------------
     fifo_rd_tvalid       : Out std_logic;                              --
     fifo_rd_tready       : In  std_logic;                              --
     fifo_rd_tdata        : Out std_logic_vector(C_DWIDTH-1 downto 0);  --
     fifo_rd_empty        : Out std_logic                               --
     ---------------------------------------------------------------------
    
    );
end entity axi_datamover_fifo;

-----------------------------------------------------------------------------
-- Architecture section
-----------------------------------------------------------------------------

architecture imp of axi_datamover_fifo is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of imp : architecture is "yes";

 -- function Declarations
  
  -------------------------------------------------------------------
  -- Function
  --
  -- Function Name: funct_get_prim_type
  --
  -- Function Description:
  --  Sorts out the FIFO Primitive type selection based on fifo
  -- depth and original primitive choice.
  --
  -------------------------------------------------------------------
  function funct_get_prim_type (depth            : integer;
                                input_prim_type  : integer) return integer is
  
    Variable temp_prim_type : Integer := 0;
  
  begin
  
    If (depth > 64) Then
    
      temp_prim_type := 1;  -- use BRAM
   
    Elsif (depth <= 64 and 
           input_prim_type = 0) Then
    
      temp_prim_type := 0;  -- use regiaters
    
    else

      temp_prim_type := 1;  -- use BRAM
    
    End if;
    
    
    Return (temp_prim_type);
    
  end function funct_get_prim_type;
  
 
  
  
-- Signal declarations
  
  Signal sig_init_reg          : std_logic := '0';
  Signal sig_init_reg2         : std_logic := '0';
  Signal sig_init_done         : std_logic := '0';
  signal sig_inhibit_rdy_n     : std_logic := '0';
 
   
   
 
-----------------------------------------------------------------------------
-- Begin architecture
-----------------------------------------------------------------------------
begin  


  -------------------------------------------------------------
  -- Synchronous Process with Sync Reset
  --
  -- Label: IMP_INIT_REG
  --
  -- Process Description:
  --  Registers the reset signal input.
  --
  -------------------------------------------------------------
  IMP_INIT_REG : process (fifo_wr_clk)
     begin
       if (fifo_wr_clk'event and fifo_wr_clk = '1') then
          if (fifo_wr_reset = '1') then
            sig_init_reg  <= '1';
            sig_init_reg2 <= '1';
          else
            sig_init_reg <= '0';
            sig_init_reg2 <= sig_init_reg;
          end if; 
       end if;       
     end process IMP_INIT_REG; 
  
  
  -------------------------------------------------------------
  -- Synchronous Process with Sync Reset
  --
  -- Label: IMP_INIT_DONE_REG
  --
  -- Process Description:
  -- Create a 1 clock wide init done pulse. 
  --
  -------------------------------------------------------------
  IMP_INIT_DONE_REG : process (fifo_wr_clk)
     begin
       if (fifo_wr_clk'event and fifo_wr_clk = '1') then
          if (fifo_wr_reset = '1' or
              sig_init_done = '1') then
            
            sig_init_done <= '0';
          
          Elsif (sig_init_reg  = '1' and
                 sig_init_reg2 = '1') Then
          
            sig_init_done <= '1';
          
          else
            null;  -- hold current state
          end if; 
       end if;       
     end process IMP_INIT_DONE_REG; 
  
  
  -------------------------------------------------------------
  -- Synchronous Process with Sync Reset
  --
  -- Label: IMP_RDY_INHIBIT_REG
  --
  -- Process Description:
  --  Implements a ready inhibit flop.
  --
  -------------------------------------------------------------
  IMP_RDY_INHIBIT_REG : process (fifo_wr_clk)
     begin
       if (fifo_wr_clk'event and fifo_wr_clk = '1') then
          if (fifo_wr_reset = '1') then
            
            sig_inhibit_rdy_n  <= '0';
          
          Elsif (sig_init_done = '1') Then
          
            sig_inhibit_rdy_n <= '1';
          
          else
            null;  -- hold current state
          end if; 
       end if;       
     end process IMP_RDY_INHIBIT_REG; 
  
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: USE_SINGLE_REG
  --
  -- If Generate Description:
  --  Implements a 1 deep register FIFO (synchronous mode only)
  --
  --
  ------------------------------------------------------------
  USE_SINGLE_REG : if (C_IS_ASYNC  = 0 and 
                       C_DEPTH    <= 1) generate
  
     -- Local Constants
     
     -- local signals
     signal sig_data_in           : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
     signal sig_regfifo_dout_reg  : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
     signal sig_regfifo_full_reg  : std_logic := '0';
     signal sig_regfifo_empty_reg : std_logic := '0';
     signal sig_push_regfifo      : std_logic := '0';
     signal sig_pop_regfifo       : std_logic := '0';
     
     
  
     begin

       -- Internal signals
       
       -- Write signals
       fifo_wr_tready    <=  sig_regfifo_empty_reg;
       
       fifo_wr_full      <=  sig_regfifo_full_reg ;
       
       sig_push_regfifo  <=  fifo_wr_tvalid and
                             sig_regfifo_empty_reg;
       
       sig_data_in       <=  fifo_wr_tdata ; 

       
       -- Read signals
       fifo_rd_tdata     <=  sig_regfifo_dout_reg ;
       
       fifo_rd_tvalid    <=  sig_regfifo_full_reg ;
       
       fifo_rd_empty     <=  sig_regfifo_empty_reg;
       
       sig_pop_regfifo   <=  sig_regfifo_full_reg and
                             fifo_rd_tready;
       
       
       
       
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_REG_FIFO
       --
       -- Process Description:
       --    This process implements the data and full flag for the 
       -- register fifo.
       --
       -------------------------------------------------------------
       IMP_REG_FIFO : process (fifo_wr_clk)
          begin
            if (fifo_wr_clk'event and fifo_wr_clk = '1') then
               if (fifo_wr_reset    = '1' or
                   sig_pop_regfifo  = '1') then
                 
                 sig_regfifo_full_reg  <= '0';
                 
               elsif (sig_push_regfifo = '1') then
                 
                 sig_regfifo_full_reg  <= '1';
                 
               else
                 null;  -- don't change state
               end if; 
            end if;       
          end process IMP_REG_FIFO; 
       
      
       IMP_REG_FIFO1 : process (fifo_wr_clk)
          begin
            if (fifo_wr_clk'event and fifo_wr_clk = '1') then
               if (fifo_wr_reset    = '1') then
                
                 
                 sig_regfifo_dout_reg  <= (others => '0');
                 
               elsif (sig_push_regfifo = '1') then
                 
                 sig_regfifo_dout_reg  <= sig_data_in;
                 
               else
                 null;  -- don't change state
               end if; 
            end if;       
          end process IMP_REG_FIFO1; 
       
       
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: IMP_REG_EMPTY_FLOP
       --
       -- Process Description:
       --    This process implements the empty flag for the 
       -- register fifo.
       --
       -------------------------------------------------------------
       IMP_REG_EMPTY_FLOP : process (fifo_wr_clk)
          begin
            if (fifo_wr_clk'event and fifo_wr_clk = '1') then
               if (fifo_wr_reset    = '1') then
                 
                 sig_regfifo_empty_reg <= '0'; -- since this is used for the ready (invertd)
                                               -- it can't be asserted during reset
                 
               elsif (sig_pop_regfifo  = '1' or
                      sig_init_done    = '1') then
                 
                 sig_regfifo_empty_reg <= '1';
                 
               elsif (sig_push_regfifo = '1') then
                 
                 sig_regfifo_empty_reg <= '0';
                 
               else
                 null;  -- don't change state
               end if; 
            end if;       
          end process IMP_REG_EMPTY_FLOP; 
       

  
     end generate USE_SINGLE_REG;
 
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: USE_SRL_FIFO
  --
  -- If Generate Description:
  --  Generates a fifo implementation usinf SRL based FIFOa
  --
  --
  ------------------------------------------------------------
  USE_SRL_FIFO : if (C_IS_ASYNC  =  0 and
                     C_DEPTH    <= 64 and
                     C_DEPTH     >  1 and
                     C_PRIM_TYPE =  2 ) generate
                     
  
  
    -- Local Constants
    Constant  LOGIC_LOW         : std_logic := '0';
    Constant  NEED_ALMOST_EMPTY : Integer := 0;
    Constant  NEED_ALMOST_FULL  : Integer := 0;
    
    
    -- local signals

    signal sig_wr_full          : std_logic := '0';
    signal sig_wr_fifo          : std_logic := '0';
    signal sig_wr_ready         : std_logic := '0';
    signal sig_rd_fifo          : std_logic := '0';
    signal sig_rd_empty         : std_logic := '0';
    signal sig_rd_valid         : std_logic := '0';
    signal sig_fifo_rd_data     : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_wr_data     : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
      
    begin
  
       

      -- Write side signals
      fifo_wr_tready    <=  sig_wr_ready;
      
      fifo_wr_full      <=  sig_wr_full;
      
      sig_wr_ready      <=  not(sig_wr_full) and 
                            sig_inhibit_rdy_n;
 
      sig_wr_fifo       <=  fifo_wr_tvalid and 
                            sig_wr_ready;
      
      sig_fifo_wr_data  <=  fifo_wr_tdata;
      
      
      
      
      -- Read Side Signals
      fifo_rd_tvalid    <=  sig_rd_valid;
      
      sig_rd_valid      <=  not(sig_rd_empty);
      
      fifo_rd_tdata     <=  sig_fifo_rd_data ;
      
      fifo_rd_empty     <=  not(sig_rd_valid);
      
      sig_rd_fifo       <=  sig_rd_valid and
                            fifo_rd_tready;
       
      
       
      ------------------------------------------------------------
      -- Instance: I_SYNC_FIFO 
      --
      -- Description:
      -- Implement the synchronous FIFO using SRL FIFO elements    
      --
      ------------------------------------------------------------
       I_SYNC_FIFO : entity lib_srl_fifo_v1_0.srl_fifo_f
       generic map (

         C_DWIDTH            =>  C_DWIDTH   ,  
         C_DEPTH             =>  C_DEPTH    ,  
         C_FAMILY            =>  C_FAMILY      

         )
       port map (

         Clk           =>  fifo_wr_clk      ,  
         Reset         =>  fifo_wr_reset    ,  
         FIFO_Write    =>  sig_wr_fifo      ,  
         Data_In       =>  sig_fifo_wr_data ,  
         FIFO_Read     =>  sig_rd_fifo      ,  
         Data_Out      =>  sig_fifo_rd_data ,  
         FIFO_Empty    =>  sig_rd_empty     ,  
         FIFO_Full     =>  sig_wr_full      ,  
         Addr          =>  open                
     
         );

       
       
     end generate USE_SRL_FIFO;




 
 
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: USE_SYNC_FIFO
  --
  -- If Generate Description:
  --  Instantiates a synchronous FIFO design for use in the 
  -- synchronous operating mode.
  --
  ------------------------------------------------------------
  USE_SYNC_FIFO : if (C_IS_ASYNC  =  0 and
                     (C_DEPTH     > 64  or
                     (C_DEPTH     >  1 and C_PRIM_TYPE < 2 ))) 
                     or 
                     (C_IS_ASYNC  =  0 and
                     C_DEPTH    <= 64 and
                     C_DEPTH     >  1 and
                     C_PRIM_TYPE =  0 ) 
generate
  
    -- Local Constants
    Constant  LOGIC_LOW         : std_logic := '0';
    Constant  NEED_ALMOST_EMPTY : Integer   := 0;
    Constant  NEED_ALMOST_FULL  : Integer   := 0;
    Constant  DATA_CNT_WIDTH    : Integer   := clog2(C_DEPTH)+1;
    Constant  PRIM_TYPE         : Integer   := funct_get_prim_type(C_DEPTH, C_PRIM_TYPE);
    
    
    -- local signals
    signal sig_wr_full          : std_logic := '0';
    signal sig_wr_fifo          : std_logic := '0';
    signal sig_wr_ready         : std_logic := '0';
    signal sig_rd_fifo          : std_logic := '0';
    signal sig_rd_valid         : std_logic := '0';
    signal sig_fifo_rd_data     : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_wr_data     : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
    
    begin

      -- Write side signals
      fifo_wr_tready    <=  sig_wr_ready;
      
      fifo_wr_full      <=  sig_wr_full;
      
      sig_wr_ready      <=  not(sig_wr_full) and 
                            sig_inhibit_rdy_n;
 
      sig_wr_fifo       <=  fifo_wr_tvalid and 
                            sig_wr_ready;
      
      sig_fifo_wr_data  <=  fifo_wr_tdata;
      
      
      
      
      -- Read Side Signals
      fifo_rd_tvalid    <=  sig_rd_valid;
      
      fifo_rd_tdata     <=  sig_fifo_rd_data ;
      
      fifo_rd_empty     <=  not(sig_rd_valid);
      
      sig_rd_fifo       <=  sig_rd_valid and
                            fifo_rd_tready;
       
      
      
      
      ------------------------------------------------------------
      -- Instance: I_SYNC_FIFO 
      --
      -- Description:
      -- Implement the synchronous FIFO    
      --
      ------------------------------------------------------------
       I_SYNC_FIFO : entity axi_datamover_v5_1.axi_datamover_sfifo_autord
       generic map (

         C_DWIDTH                =>  C_DWIDTH          ,  
         C_DEPTH                 =>  C_DEPTH           ,  
         C_DATA_CNT_WIDTH        =>  DATA_CNT_WIDTH    ,  
         C_NEED_ALMOST_EMPTY     =>  NEED_ALMOST_EMPTY ,  
         C_NEED_ALMOST_FULL      =>  NEED_ALMOST_FULL  ,  
         C_USE_BLKMEM            =>  PRIM_TYPE         ,  
         C_FAMILY                =>  C_FAMILY             

         )
       port map (

        -- Inputs 
         SFIFO_Sinit             =>  fifo_wr_reset     ,  
         SFIFO_Clk               =>  fifo_wr_clk       ,  
         SFIFO_Wr_en             =>  sig_wr_fifo       ,  
         SFIFO_Din               =>  fifo_wr_tdata     ,  
         SFIFO_Rd_en             =>  sig_rd_fifo       ,  
         SFIFO_Clr_Rd_Data_Valid =>  LOGIC_LOW         ,  
         
        -- Outputs
         SFIFO_DValid            =>  sig_rd_valid      ,  
         SFIFO_Dout              =>  sig_fifo_rd_data  ,  
         SFIFO_Full              =>  sig_wr_full       ,  
         SFIFO_Empty             =>  open              ,  
         SFIFO_Almost_full       =>  open              ,  
         SFIFO_Almost_empty      =>  open              ,  
         SFIFO_Rd_count          =>  open              ,  
         SFIFO_Rd_count_minus1   =>  open              ,  
         SFIFO_Wr_count          =>  open              ,  
         SFIFO_Rd_ack            =>  open                 

         );


      
 
     end generate USE_SYNC_FIFO;
 
 
 
 
 
 
  
  ------------------------------------------------------------
  -- If Generate
  --
  -- Label: USE_ASYNC_FIFO
  --
  -- If Generate Description:
  --  Instantiates an asynchronous FIFO design for use in the 
  -- asynchronous operating mode.
  --
  ------------------------------------------------------------
  USE_ASYNC_FIFO : if (C_IS_ASYNC = 1) generate
  
    -- Local Constants
    Constant  LOGIC_LOW         : std_logic := '0';
    Constant  CNT_WIDTH         : Integer := clog2(C_DEPTH);
    
    
    -- local signals

    signal sig_async_wr_full       : std_logic := '0';
    signal sig_async_wr_fifo       : std_logic := '0';
    signal sig_async_wr_ready      : std_logic := '0';
    signal sig_async_rd_fifo       : std_logic := '0';
    signal sig_async_rd_valid      : std_logic := '0';
    signal sig_afifo_rd_data       : std_logic_vector(C_DWIDTH-1 downto 0);
    signal sig_afifo_wr_data       : std_logic_vector(C_DWIDTH-1 downto 0);
    signal sig_fifo_ainit          : std_logic := '0';
    Signal sig_init_reg            : std_logic := '0';
    
    
    begin

      sig_fifo_ainit  <= fifo_async_rd_reset or fifo_wr_reset;
      
      

      -- Write side signals
      fifo_wr_tready      <=  sig_async_wr_ready;
      
      fifo_wr_full        <=  sig_async_wr_full;
      
      sig_async_wr_ready  <=  not(sig_async_wr_full) and
                              sig_inhibit_rdy_n;
 
      sig_async_wr_fifo   <=  fifo_wr_tvalid and 
                              sig_async_wr_ready;
      
      sig_afifo_wr_data   <=  fifo_wr_tdata;
      
      
      
      
      -- Read Side Signals
      fifo_rd_tvalid    <=  sig_async_rd_valid;
      
      fifo_rd_tdata     <=  sig_afifo_rd_data ;
      
      fifo_rd_empty     <=  not(sig_async_rd_valid);
      
      sig_async_rd_fifo <=  sig_async_rd_valid and
                            fifo_rd_tready;
       
      
 
       
       
       
      ------------------------------------------------------------
      -- Instance: I_ASYNC_FIFO 
      --
      -- Description:
      -- Implement the asynchronous FIFO    
      --
      ------------------------------------------------------------
       I_ASYNC_FIFO : entity axi_datamover_v5_1.axi_datamover_afifo_autord
       generic map (

         C_DWIDTH                   =>  C_DWIDTH          ,  
         C_DEPTH                    =>  C_DEPTH           ,  
         C_CNT_WIDTH                =>  CNT_WIDTH         ,  
         C_USE_BLKMEM               =>  C_PRIM_TYPE       ,  
         C_FAMILY                   =>  C_FAMILY             

         )
       port map (

        -- Inputs 
         AFIFO_Ainit                =>  sig_fifo_ainit    ,  
         AFIFO_Ainit_Rd_clk         =>  fifo_async_rd_reset    ,  
         AFIFO_Wr_clk               =>  fifo_wr_clk       ,  
         AFIFO_Wr_en                =>  sig_async_wr_fifo ,  
         AFIFO_Din                  =>  sig_afifo_wr_data ,  
         AFIFO_Rd_clk               =>  fifo_async_rd_clk ,  
         AFIFO_Rd_en                =>  sig_async_rd_fifo ,  
         AFIFO_Clr_Rd_Data_Valid    =>  LOGIC_LOW         ,  
         
        -- Outputs
         AFIFO_DValid               =>  sig_async_rd_valid,  
         AFIFO_Dout                 =>  sig_afifo_rd_data ,  
         AFIFO_Full                 =>  sig_async_wr_full ,  
         AFIFO_Empty                =>  open              ,  
         AFIFO_Almost_full          =>  open              ,  
         AFIFO_Almost_empty         =>  open              ,  
         AFIFO_Wr_count             =>  open              ,   
         AFIFO_Rd_count             =>  open              ,  
         AFIFO_Corr_Rd_count        =>  open              ,  
         AFIFO_Corr_Rd_count_minus1 =>  open              ,  
         AFIFO_Rd_ack               =>  open                 

         );


      
 
     end generate USE_ASYNC_FIFO;
 
 

end imp;
