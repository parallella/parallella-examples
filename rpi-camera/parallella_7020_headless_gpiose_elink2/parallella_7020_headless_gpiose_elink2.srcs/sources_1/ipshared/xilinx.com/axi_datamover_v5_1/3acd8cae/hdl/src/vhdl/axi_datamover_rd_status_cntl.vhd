  -------------------------------------------------------------------------------
  -- axi_datamover_rd_status_cntl.vhd
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
  -- Filename:        axi_datamover_rd_status_cntl.vhd
  --
  -- Description:     
  --    This file implements the DataMover Master Read Status Controller.                 
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
  
  entity axi_datamover_rd_status_cntl is
    generic (
      
      C_STS_WIDTH          : Integer               := 8;
        -- sets the width of the Status ports
      
      C_TAG_WIDTH          : Integer range  1 to 8 := 4
        -- Sets the width of the Tag field in the Status reply
      
      );
    port (
      
      -- Clock and Reset input --------------------------------------
                                                                   --
      primary_aclk           : in  std_logic;                      --
         -- Primary synchronization clock for the Master side      --
         -- interface and internal logic. It is also used          --
         -- for the User interface synchronization when            --
         -- C_STSCMD_IS_ASYNC = 0.                                 --
                                                                   --
      -- Reset input                                               --
      mmap_reset             : in  std_logic;                      --
         -- Reset used for the internal master logic               --
      ---------------------------------------------------------------
      
      
      
                
                
      -- Command Calculator Status Interface  ---------------------------
                                                                       --
      calc2rsc_calc_error    : in std_logic ;                          --
         -- Indication from the Command Calculator that a calculation  --
         -- error has occured.                                         --
      -------------------------------------------------------------------
     
     
     
      
        
      -- Address Controller Status Interface ----------------------------
                                                                       --
      addr2rsc_calc_error    : In std_logic ;                          --
         -- Indication from the Data Channel Controller FIFO that it   --
         -- is empty (no commands pending)                             --
                                                                       --
      addr2rsc_fifo_empty    : In std_logic ;                          --
         -- Indication from the Address Controller FIFO that it        --
         -- is empty (no commands pending)                             --
      -------------------------------------------------------------------

                    
                    
                    
      --  Data Controller Status Interface ---------------------------------------------
                                                                                      --
      data2rsc_tag           : In std_logic_vector(C_TAG_WIDTH-1 downto 0);           --
         -- The command tag                                                           --
                                                                                      --
      data2rsc_calc_error    : In std_logic ;                                         --
         -- Indication from the Data Channel Controller FIFO that it                  --
         -- is empty (no commands pending)                                            --
                                                                                      --
      data2rsc_okay          : In std_logic ;                                         --
         -- Indication that the AXI Read transfer completed with OK status            --
                                                                                      --
      data2rsc_decerr        : In std_logic ;                                         --
         -- Indication that the AXI Read transfer completed with decode error status  --
                                                                                      --
      data2rsc_slverr        : In std_logic ;                                         --
         -- Indication that the AXI Read transfer completed with slave error status   --
                                                                                      --
      data2rsc_cmd_cmplt     : In std_logic ;                                         --
         -- Indication by the Data Channel Controller that the                        --
         -- corresponding status is the last status for a parent command              --
         -- pulled from the command FIFO                                              --
                                                                                      --
      rsc2data_ready         : Out  std_logic;                                        --
         -- Handshake bit from the Read Status Controller Module indicating           --
         -- that the it is ready to accept a new Read status transfer                 --
                                                                                      --
      data2rsc_valid         : in  std_logic ;                                        --
         -- Handshake bit output to the Read Status Controller Module                 --
         -- indicating that the Data Controller has valid tag and status              --
         -- indicators to transfer                                                    --
      ----------------------------------------------------------------------------------


      
      -- Command/Status Module Interface ----------------------------------------------
                                                                                     --
      rsc2stat_status        : Out std_logic_vector(C_STS_WIDTH-1 downto 0);         --
         -- Read Status value collected during a Read Data transfer                  --
         -- Output to the Command/Status Module                                      --
                                                                                     --
      stat2rsc_status_ready  : In  std_logic;                                        --
         -- Input from the Command/Status Module indicating that the                 --
         -- Status Reg/FIFO is ready to accept a transfer                            --
                                                                                     --
      rsc2stat_status_valid  : Out std_logic ;                                       --
         -- Control Signal to the Status Reg/FIFO indicating a new status            --
         -- output value is valid and ready for transfer                             --
      ---------------------------------------------------------------------------------

  
    
    
      -- Address and Data Controller Pipe halt ----------------------------------
                                                                               --
      rsc2mstr_halt_pipe     : Out std_logic                                   --
         -- Indication to Halt the Data and Address Command pipeline due       --
         -- to the Status FIFO going full or an internal error being logged    --
      ---------------------------------------------------------------------------

  
      );
  
  end entity axi_datamover_rd_status_cntl;
  
  
  architecture implementation of axi_datamover_rd_status_cntl is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    -- Constant Declarations  --------------------------------------------
    
    Constant OKAY               : std_logic_vector(1 downto 0) := "00";
    Constant EXOKAY             : std_logic_vector(1 downto 0) := "01";
    Constant SLVERR             : std_logic_vector(1 downto 0) := "10";
    Constant DECERR             : std_logic_vector(1 downto 0) := "11";
    Constant STAT_RSVD          : std_logic_vector(3 downto 0) := "0000";
    Constant TAG_WIDTH          : integer := C_TAG_WIDTH;
    Constant STAT_REG_TAG_WIDTH : integer := 4;
    
    
    -- Signal Declarations  --------------------------------------------
    
    signal sig_tag2status            : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_rsc2status_valid      : std_logic := '0';
    signal sig_rsc2data_ready        : std_logic := '0';
    signal sig_rd_sts_okay_reg       : std_logic := '0';
    signal sig_rd_sts_interr_reg     : std_logic := '0';
    signal sig_rd_sts_decerr_reg     : std_logic := '0';
    signal sig_rd_sts_slverr_reg     : std_logic := '0';
    signal sig_rd_sts_tag_reg        : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_pop_rd_sts_reg        : std_logic := '0';
    signal sig_push_rd_sts_reg       : std_logic := '0';
    Signal sig_rd_sts_push_ok        : std_logic := '0';
    signal sig_rd_sts_reg_empty      : std_logic := '0';
    signal sig_rd_sts_reg_full       : std_logic := '0';
    
    
    
    
    
            
  begin --(architecture implementation)
  
    -- Assign the status write output control
    rsc2stat_status_valid  <= sig_rsc2status_valid ;
    
    sig_rsc2status_valid   <= sig_rd_sts_reg_full;
    
                                           
    -- Formulate the status outout value (assumes an 8-bit status width)
    rsc2stat_status        <=  sig_rd_sts_okay_reg    &   
                               sig_rd_sts_slverr_reg  &
                               sig_rd_sts_decerr_reg  & 
                               sig_rd_sts_interr_reg  &
                               sig_tag2status;
    
    -- Detect that a push of a new status word is completing
    sig_rd_sts_push_ok   <= sig_rsc2status_valid and 
                            stat2rsc_status_ready;
    
    -- Signal a halt to the execution pipe if new status
    -- is valid but the Status FIFO is not accepting it
    rsc2mstr_halt_pipe   <=  sig_rsc2status_valid and
                             (not(stat2rsc_status_ready) ); 
   
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_TAG_LE_STAT
    --
    -- If Generate Description:
    -- Populates the TAG bits into the availble Status bits when
    -- the TAG width is less than or equal to the available number
    -- of bits in the Status word. 
    --
    ------------------------------------------------------------
    GEN_TAG_LE_STAT : if (TAG_WIDTH <= STAT_REG_TAG_WIDTH) generate
    
       -- local signals
         signal lsig_temp_tag_small : std_logic_vector(STAT_REG_TAG_WIDTH-1 downto 0) := (others => '0');
         
         
       begin
    
         sig_tag2status <= lsig_temp_tag_small;
         
         
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: POPULATE_SMALL_TAG
         --
         -- Process Description:
         --
         --
         -------------------------------------------------------------
         POPULATE_SMALL_TAG : process (sig_rd_sts_tag_reg)
            begin
         
              -- Set default value
              lsig_temp_tag_small <= (others => '0');
          
              -- Now overload actual TAG bits
              lsig_temp_tag_small(TAG_WIDTH-1 downto 0) <= sig_rd_sts_tag_reg;
          
         
            end process POPULATE_SMALL_TAG; 
         
         
       end generate GEN_TAG_LE_STAT;
     
     
     
     
     
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_TAG_GT_STAT
    --
    -- If Generate Description:
    -- Populates the TAG bits into the availble Status bits when
    -- the TAG width is greater than the available number of 
    -- bits in the Status word. The upper bits of the TAG are 
    -- clipped off (discarded). 
    --
    ------------------------------------------------------------
    GEN_TAG_GT_STAT : if (TAG_WIDTH > STAT_REG_TAG_WIDTH) generate
    
       -- local signals
         signal lsig_temp_tag_big : std_logic_vector(STAT_REG_TAG_WIDTH-1 downto 0);
         
         
       begin
    
         
         sig_tag2status <= lsig_temp_tag_big;
         
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: POPULATE_BIG_TAG
         --
         -- Process Description:
         --
         --
         -------------------------------------------------------------
         POPULATE_SMALL_TAG : process (sig_rd_sts_tag_reg)
            begin
         
              -- Set default value
              lsig_temp_tag_big <= (others => '0');
          
              -- Now overload actual TAG bits
              lsig_temp_tag_big <= sig_rd_sts_tag_reg(STAT_REG_TAG_WIDTH-1 downto 0);
          
         
            end process POPULATE_SMALL_TAG; 
         
         
       end generate GEN_TAG_GT_STAT;
     
     
     
     
     
          
   ------- Read Status Collection Logic --------------------------------       
    
    rsc2data_ready      <=  sig_rsc2data_ready ;
    
    sig_rsc2data_ready  <= sig_rd_sts_reg_empty;
    
    
    sig_push_rd_sts_reg <= data2rsc_valid and
                           sig_rsc2data_ready;
          
    sig_pop_rd_sts_reg  <= sig_rd_sts_push_ok;
    
    
          
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: RD_STATUS_FIFO_REG
    --
    -- Process Description:
    --   Implement Read status FIFO register. 
    -- This register holds the Read status from the Data Controller
    -- until it is transfered to the Status FIFO.
    --
    -------------------------------------------------------------
    RD_STATUS_FIFO_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset         = '1' or
                sig_pop_rd_sts_reg = '1') then
              
              sig_rd_sts_tag_reg       <= (others => '0');
              sig_rd_sts_interr_reg    <= '0';
              sig_rd_sts_decerr_reg    <= '0';
              sig_rd_sts_slverr_reg    <= '0';
              sig_rd_sts_okay_reg      <= '1'; -- set back to default of "OKAY"
  
              sig_rd_sts_reg_full      <= '0';
              sig_rd_sts_reg_empty     <= '1';
  
  
              
            Elsif (sig_push_rd_sts_reg = '1') Then
            
              sig_rd_sts_tag_reg       <= data2rsc_tag;                             
              sig_rd_sts_interr_reg    <= data2rsc_calc_error or 
                                          sig_rd_sts_interr_reg;
              sig_rd_sts_decerr_reg    <= data2rsc_decerr or sig_rd_sts_decerr_reg;
              sig_rd_sts_slverr_reg    <= data2rsc_slverr or sig_rd_sts_slverr_reg;
              sig_rd_sts_okay_reg      <= data2rsc_okay and 
                                          not(data2rsc_decerr          or 
                                              sig_rd_sts_decerr_reg    or
                                              data2rsc_slverr          or 
                                              sig_rd_sts_slverr_reg    or
                                              data2rsc_calc_error      or
                                              sig_rd_sts_interr_reg      
                                              );
              
              sig_rd_sts_reg_full      <= data2rsc_cmd_cmplt or
                                          data2rsc_calc_error;
              sig_rd_sts_reg_empty     <= not(data2rsc_cmd_cmplt or
                                              data2rsc_calc_error);
                                            
            else
              
              null;  -- hold current state
              
            end if; 
         end if;       
       end process RD_STATUS_FIFO_REG; 
      
    
    
    
    
          
          
          
  
  end implementation;
