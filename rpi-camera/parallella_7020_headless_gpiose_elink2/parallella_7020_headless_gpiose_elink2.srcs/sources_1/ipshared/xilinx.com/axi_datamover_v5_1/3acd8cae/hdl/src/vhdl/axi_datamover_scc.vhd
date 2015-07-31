  -------------------------------------------------------------------------------
  -- axi_datamover_scc.vhd
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
  -- Filename:        axi_datamover_scc.vhd
  --
  -- Description:     
  --    This file implements the DataMover Lite Master Simple Command Calculator (SCC).                 
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
  
  entity axi_datamover_scc is
    generic (
      
      C_SEL_ADDR_WIDTH     : Integer range  1 to  8 :=  5;
        -- Sets the width of the LS address bus used for 
        -- Muxing/Demuxing data to/from a wider AXI4 data bus
      
      C_ADDR_WIDTH         : Integer range 32 to 64 := 32;
        -- Sets the width of the AXi Address Channel 
      
      C_STREAM_DWIDTH      : Integer range  8 to 64 := 32;
        -- Sets the width of the Native Data width that
        -- is being supported by the PCC
      
      C_MAX_BURST_LEN      : Integer range 2 to 64 := 16;
        -- Indicates the max allowed burst length to use for
        -- AXI4 transfer calculations
      
      C_CMD_WIDTH          : Integer                := 68;
        -- Sets the width of the input command port

      C_MICRO_DMA          : integer range 0 to 1   := 0;
      
      C_TAG_WIDTH          : Integer range  1 to  8 := 4
        -- Sets the width of the Tag field in the input command
      
      );
    port (
      
      -- Clock and Reset inputs -------------------------------------
      primary_aclk         : in  std_logic;                        --
         -- Primary synchronization clock for the Master side      --
         -- interface and internal logic. It is also used          --
         -- for the User interface synchronization when            --
         -- C_STSCMD_IS_ASYNC = 0.                                 --
                                                                   --
      -- Reset input                                               --
      mmap_reset           : in  std_logic;                        --
        -- Reset used for the internal master logic                --
      ---------------------------------------------------------------
      
      
     
      -- Command Input Interface ---------------------------------------------------------
                                                                                        --
      cmd2mstr_command      : in std_logic_vector(C_CMD_WIDTH-1 downto 0);              --
         -- The next command value available from the Command FIFO/Register             --
                                                                                        --
      cache2mstr_command      : in std_logic_vector(7 downto 0);              --
         -- The next command value available from the Command FIFO/Register             --
                                                                                        --
      cmd2mstr_cmd_valid    : in std_logic;                                             --
         -- Handshake bit indicating if the Command FIFO/Register has at leasdt 1 entry --
                                                                                        --
      mst2cmd_cmd_ready     : out  std_logic;                                           --
         -- Handshake bit indicating the Command Calculator is ready to accept          --
         -- another command                                                             --
      ------------------------------------------------------------------------------------
      
      
      
      -- Address Channel Controller Interface --------------------------------------------
                                                                                        --
      mstr2addr_tag       : out std_logic_vector(C_TAG_WIDTH-1 downto 0);               --
         -- The next command tag                                                        --
                                                                                        --
      mstr2addr_addr      : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);              --
         -- The next command address to put on the AXI MMap ADDR                        --
                                                                                        --
      mstr2addr_len       : out std_logic_vector(7 downto 0);                           --
         -- The next command length to put on the AXI MMap LEN                          --
                                                                                        --
      mstr2addr_size      : out std_logic_vector(2 downto 0);                           --
         -- The next command size to put on the AXI MMap SIZE                           --
                                                                                        --
      mstr2addr_burst     : out std_logic_vector(1 downto 0);                           --
         -- The next command burst type to put on the AXI MMap BURST                    --
                                                                                        --
      mstr2addr_cache     : out std_logic_vector(3 downto 0);                           --
         -- The next command burst type to put on the AXI MMap BURST                    --
                                                                                        --
      mstr2addr_user      : out std_logic_vector(3 downto 0);                           --
         -- The next command burst type to put on the AXI MMap BURST                    --
                                                                                        --
      mstr2addr_cmd_cmplt : out std_logic;                                              --
         -- The indication to the Address Channel that the current                      --
         -- sub-command output is the last one compiled from the                        --
         -- parent command pulled from the Command FIFO                                 --
                                                                                        --
      mstr2addr_calc_error : out std_logic;                                             --
         -- Indication if the next command in the calculation pipe                      --
         -- has a calcualtion error                                                     --
                                                                                        --
      mstr2addr_cmd_valid : out std_logic;                                              --
         -- The next command valid indication to the Address Channel                    --
         -- Controller for the AXI MMap                                                 --
                                                                                        --
      addr2mstr_cmd_ready : In std_logic;                                               --
         -- Indication from the Address Channel Controller that the                     --
         -- command is being accepted                                                   --
      ------------------------------------------------------------------------------------
      
      
      
      -- Data Channel Controller Interface  ----------------------------------------------
                                                                                        --
      mstr2data_tag        : out std_logic_vector(C_TAG_WIDTH-1 downto 0);              --
         -- The next command tag                                                        --
                                                                                        --
      mstr2data_saddr_lsb  : out std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0);         --
         -- The next command start address LSbs to use for the read data                --
         -- mux (only used if Stream data width is 8 or 16 bits).                       --
                                                                                        --
      mstr2data_len        : out std_logic_vector(7 downto 0);                          --
         -- The LEN value output to the Address Channel                                 --
                                                                                        --
      mstr2data_strt_strb  : out std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);      --
         -- The starting strobe value to use for the data transfer                      --
                                                                                        --
      mstr2data_last_strb  : out std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);      --
         -- The endiing (LAST) strobe value to use for the data transfer                --
                                                                                        --
      mstr2data_sof        : out std_logic;                                             --
         -- The starting tranfer of a sequence of transfers                             --
                                                                                        --
      mstr2data_eof        : out std_logic;                                             --
         -- The endiing tranfer of a sequence of parent transfer commands               --
                                                                                        --
      mstr2data_calc_error : out std_logic;                                             --
         -- Indication if the next command in the calculation pipe                      --
         -- has a calculation error                                                     --
                                                                                        --
      mstr2data_cmd_cmplt  : out std_logic;                                             --
         -- The indication to the Data Channel that the current                         --
         -- sub-command output is the last one compiled from the                        --
         -- parent command pulled from the Command FIFO                                 --
                                                                                        --
      mstr2data_cmd_valid  : out std_logic;                                             --
         -- The next command valid indication to the Data Channel                       --
         -- Controller for the AXI MMap                                                 --
                                                                                        --
      data2mstr_cmd_ready  : In std_logic ;                                             --
         -- Indication from the Data Channel Controller that the                        --
         -- command is being accepted on the AXI Address                                --
         -- Channel                                                                     --
                                                                                        --
      calc_error           : Out std_logic                                              --
         -- Indication from the Command Calculator that a calculation                   --
         -- error has occured.                                                          --
      ------------------------------------------------------------------------------------
     
      );
  
  end entity axi_datamover_scc;
  
  
  architecture implementation of axi_datamover_scc is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
  
  
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_slice_width
    --
    -- Function Description:
    -- Calculates the bits to rip from the Command BTT field to calculate
    -- the LEN value output to the AXI Address Channel.
    --
    -------------------------------------------------------------------
    function funct_get_slice_width (max_burst_len : integer) return integer is
                                    
    
      Variable temp_slice_width : Integer := 0;
    
    begin
  
      case max_burst_len is
        
        when 64 =>
          temp_slice_width := 7;
        when 32 =>
          temp_slice_width := 6;
        when 16 =>
          temp_slice_width := 5;
        when 8 =>
          temp_slice_width := 4;
        when 4 =>
          temp_slice_width := 3;
        when others =>   -- assume 16 dbeats is max LEN
          temp_slice_width := 2;
      end case;
      
      Return (temp_slice_width);
     
    end function funct_get_slice_width;
    
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_residue_width
    --
    -- Function Description:
    --  Calculates the number of Least significant bits of the BTT field
    -- that are unused for the LEN calculation
    --
    -------------------------------------------------------------------
    function funct_get_btt_ls_unused (transfer_width : integer) return integer is
    
      Variable temp_btt_ls_unused : Integer := 0; -- 8-bit stream
      
    begin
    
      case transfer_width is
        when 64 =>
            temp_btt_ls_unused := 3;
        when 32 =>
            temp_btt_ls_unused := 2;
        when 16 =>
            temp_btt_ls_unused := 1;
        when others =>  -- assume 8-bit transfers
            temp_btt_ls_unused := 0;
      end case;
      
      Return (temp_btt_ls_unused);
     
    end function funct_get_btt_ls_unused;
    
    
    
    
    
    
    
    
    
    -- Constant Declarations  ----------------------------------------
    
    Constant BASE_CMD_WIDTH      : integer := 32; -- Bit Width of Command LS (no address)
    Constant CMD_TYPE_INDEX      : integer := 23;
    Constant CMD_ADDR_LS_INDEX   : integer := BASE_CMD_WIDTH;
    Constant CMD_EOF_INDEX     : integer := BASE_CMD_WIDTH-2;
    Constant CMD_ADDR_MS_INDEX   : integer := (C_ADDR_WIDTH+BASE_CMD_WIDTH)-1;
    Constant CMD_TAG_WIDTH       : integer := C_TAG_WIDTH;
    Constant CMD_TAG_LS_INDEX    : integer := C_ADDR_WIDTH+BASE_CMD_WIDTH;
    Constant CMD_TAG_MS_INDEX    : integer := (CMD_TAG_LS_INDEX+CMD_TAG_WIDTH)-1;
    Constant AXI_BURST_FIXED     : std_logic_vector(1 downto 0) := "00";
    Constant AXI_BURST_INCR      : std_logic_vector(1 downto 0) := "01";
    Constant AXI_BURST_WRAP      : std_logic_vector(1 downto 0) := "10";
    Constant AXI_BURST_RESVD     : std_logic_vector(1 downto 0) := "11";
    Constant AXI_SIZE_1BYTE      : std_logic_vector(2 downto 0) := "000"; 
    Constant AXI_SIZE_2BYTE      : std_logic_vector(2 downto 0) := "001"; 
    Constant AXI_SIZE_4BYTE      : std_logic_vector(2 downto 0) := "010"; 
    Constant AXI_SIZE_8BYTE      : std_logic_vector(2 downto 0) := "011"; 
    Constant AXI_SIZE_16BYTE     : std_logic_vector(2 downto 0) := "100"; 
    Constant AXI_SIZE_32BYTE     : std_logic_vector(2 downto 0) := "101"; 
    Constant AXI_SIZE_64BYTE     : std_logic_vector(2 downto 0) := "110"; 
    Constant AXI_SIZE_128BYTE    : std_logic_vector(2 downto 0) := "111"; 
    Constant BTT_SLICE_SIZE      : integer := funct_get_slice_width(C_MAX_BURST_LEN);
    Constant MAX_BURST_LEN_US    : unsigned(BTT_SLICE_SIZE-1 downto 0) := 
                                   TO_UNSIGNED(C_MAX_BURST_LEN-1, BTT_SLICE_SIZE);
    Constant BTT_LS_UNUSED_WIDTH : integer := funct_get_btt_ls_unused(C_STREAM_DWIDTH);
    Constant CMD_BTT_WIDTH       : integer :=  BTT_SLICE_SIZE+BTT_LS_UNUSED_WIDTH;
    Constant CMD_BTT_LS_INDEX    : integer :=  0;
    Constant CMD_BTT_MS_INDEX    : integer :=  CMD_BTT_WIDTH-1;
    Constant BTT_ZEROS           : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0'); 
    Constant BTT_RESIDUE_ZEROS   : unsigned(BTT_LS_UNUSED_WIDTH-1 downto 0) := (others => '0'); 
    Constant BTT_SLICE_ONE       : unsigned(BTT_SLICE_SIZE-1 downto 0) := TO_UNSIGNED(1, BTT_SLICE_SIZE); 
    Constant STRB_WIDTH          : integer := C_STREAM_DWIDTH/8; -- Number of bytes in the Stream
    Constant LEN_WIDTH           : integer := 8; 
    
               
               
    -- Type Declarations  --------------------------------------------
    
    type SCC_SM_STATE_TYPE is (
                INIT,
                POP_RECOVER,
                GET_NXT_CMD,
                CHK_AND_CALC,
                PUSH_TO_AXI,
                ERROR_TRAP
                );
  
  
    
    
    
    -- Signal Declarations  --------------------------------------------
  
    signal sm_scc_state              : SCC_SM_STATE_TYPE := INIT;
    signal sm_scc_state_ns           : SCC_SM_STATE_TYPE := INIT;
    signal sm_pop_input_cmd          : std_logic := '0';
    signal sm_pop_input_cmd_ns       : std_logic := '0';
    signal sm_set_push2axi           : std_logic := '0';
    signal sm_set_push2axi_ns        : std_logic := '0';
    signal sm_set_error              : std_logic := '0';
    signal sm_set_error_ns           : std_logic := '0';
    Signal sm_scc_sm_ready           : std_logic := '0';
    Signal sm_scc_sm_ready_ns        : std_logic := '0';
    signal sig_cmd2data_valid        : std_logic := '0';
    signal sig_clr_cmd2data_valid    : std_logic := '0';
    signal sig_cmd2addr_valid        : std_logic := '0';
    signal sig_clr_cmd2addr_valid    : std_logic := '0';
    signal sig_addr_data_rdy_pending : std_logic := '0';
    signal sig_cmd_btt_slice         : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_load_input_cmd        : std_logic := '0';
    signal sig_cmd_reg_empty         : std_logic := '0';
    signal sig_cmd_reg_full          : std_logic := '0';
    signal sig_cmd_addr_reg          : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_btt_reg           : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_type_reg          : std_logic := '0';
    signal sig_cmd_burst_reg         : std_logic_vector (1 downto 0) := "00";
    signal sig_cmd_tag_reg           : std_logic_vector(CMD_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_addr_data_rdy4cmd     : std_logic := '0';
    signal sig_btt_raw               : std_logic := '0';
    signal sig_btt_is_zero           : std_logic := '0';
    signal sig_btt_is_zero_reg       : std_logic := '0';
    signal sig_next_tag              : std_logic_vector(CMD_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_next_addr             : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_next_len              : std_logic_vector(LEN_WIDTH-1 downto 0) := (others => '0');
    signal sig_next_size             : std_logic_vector(2 downto 0) := (others => '0');
    signal sig_next_burst            : std_logic_vector(1 downto 0) := (others => '0');
    signal sig_next_cache            : std_logic_vector(3 downto 0) := (others => '0');
    signal sig_next_user             : std_logic_vector(3 downto 0) := (others => '0');
    signal sig_next_strt_strb        : std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0) := (others => '0');
    signal sig_next_end_strb         : std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0) := (others => '0');
    signal sig_input_eof_reg         : std_logic;
    
  
    
    
  begin --(architecture implementation)
     
    -- Assign calculation error output 
    calc_error            <= sm_set_error;
   
    -- Assign the ready output to the Command FIFO 
    mst2cmd_cmd_ready     <= sig_cmd_reg_empty and sm_scc_sm_ready;
    
    -- Assign the Address Channel Controller Qualifiers
    mstr2addr_tag         <= sig_next_tag  ; 
    mstr2addr_addr        <= sig_next_addr ; 
    mstr2addr_len         <= sig_next_len  ; 
    mstr2addr_size        <= sig_next_size ;
    mstr2addr_burst       <= sig_cmd_burst_reg; 
    mstr2addr_cache       <= sig_next_cache; 
    mstr2addr_user        <= sig_next_user; 
    mstr2addr_cmd_valid   <= sig_cmd2addr_valid;
    mstr2addr_calc_error  <= sm_set_error  ; 
    mstr2addr_cmd_cmplt   <= '1'           ;   -- Lite mode is always 1 
    
    -- Assign the Data Channel Controller Qualifiers
    mstr2data_tag         <= sig_next_tag ; 
    mstr2data_saddr_lsb   <= sig_cmd_addr_reg(C_SEL_ADDR_WIDTH-1 downto 0);
    
    mstr2data_len         <= sig_next_len ;
    
    mstr2data_strt_strb   <= sig_next_strt_strb;
    mstr2data_last_strb   <= sig_next_end_strb;
    mstr2data_sof         <= '1';  -- Lite mode is always 1 cmd
    mstr2data_eof         <= sig_input_eof_reg;  -- Lite mode is always 1 cmd
    mstr2data_cmd_cmplt   <= '1';  -- Lite mode is always 1 cmd
    mstr2data_cmd_valid   <= sig_cmd2data_valid;
    mstr2data_calc_error  <= sm_set_error;   
    
    
    -- Internal logic ------------------------------
    sig_addr_data_rdy_pending  <=  sig_cmd2addr_valid or 
                                   sig_cmd2data_valid;
   
    sig_clr_cmd2data_valid     <=  sig_cmd2data_valid and data2mstr_cmd_ready;
    
    sig_clr_cmd2addr_valid     <=  sig_cmd2addr_valid and addr2mstr_cmd_ready;
    
    
    sig_load_input_cmd         <=  cmd2mstr_cmd_valid and 
                                   sig_cmd_reg_empty  and
                                   sm_scc_sm_ready;
    
    sig_next_tag               <=  sig_cmd_tag_reg;
    
    sig_next_addr              <=  sig_cmd_addr_reg;
    
    sig_addr_data_rdy4cmd      <=  addr2mstr_cmd_ready and data2mstr_cmd_ready;
    
    sig_cmd_btt_slice          <=  cmd2mstr_command(CMD_BTT_MS_INDEX downto CMD_BTT_LS_INDEX);
    
    sig_btt_is_zero  <= '1'
      when  (sig_cmd_btt_slice = BTT_ZEROS)
      Else '0';
    
  
  
    
 
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_RESIDUE_BITS
    --
    -- If Generate Description:
    --
    --
    --
    ------------------------------------------------------------
    GEN_NO_RESIDUE_BITS : if (BTT_LS_UNUSED_WIDTH = 0) generate
    
    
       -- signals 
       signal sig_len_btt_slice         : unsigned(BTT_SLICE_SIZE-1 downto 0) := (others => '0');
       signal sig_len_btt_slice_minus_1 : unsigned(BTT_SLICE_SIZE-1 downto 0) := (others => '0');
       signal sig_len2use               : unsigned(BTT_SLICE_SIZE-1 downto 0) := (others => '0');
       
     
       begin
    
       -- LEN Calculation logic ------------------------------------------ 
        
         sig_next_len         <= STD_LOGIC_VECTOR(RESIZE(sig_len2use, LEN_WIDTH));
        
         sig_len_btt_slice    <= UNSIGNED(sig_cmd_btt_reg(CMD_BTT_MS_INDEX downto 0));
         
         sig_len_btt_slice_minus_1 <= sig_len_btt_slice-BTT_SLICE_ONE
          when sig_btt_is_zero_reg = '0'
          else (others => '0');    -- clip at zero
         
         
         -- If most significant bit of BTT set then limit to 
         -- Max Burst Len, else rip it from the BTT value,
         -- otheriwse subtract 1 from the BTT ripped value
         -- 1 from the BTT ripped value
         sig_len2use <= MAX_BURST_LEN_US 
           When (sig_cmd_btt_reg(CMD_BTT_MS_INDEX) = '1')
           Else sig_len_btt_slice_minus_1;
           
        
       end generate GEN_NO_RESIDUE_BITS;
        
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_HAS_RESIDUE_BITS
    --
    -- If Generate Description:
    --
    --
    --
    ------------------------------------------------------------
    GEN_HAS_RESIDUE_BITS : if (BTT_LS_UNUSED_WIDTH > 0) generate
    
       -- signals 
       signal sig_btt_len_residue       : unsigned(BTT_LS_UNUSED_WIDTH-1 downto 0) := (others => '0');
       signal sig_len_btt_slice         : unsigned(BTT_SLICE_SIZE-1 downto 0) := (others => '0');
       signal sig_len_btt_slice_minus_1 : unsigned(BTT_SLICE_SIZE-1 downto 0) := (others => '0');
       signal sig_len2use               : unsigned(BTT_SLICE_SIZE-1 downto 0) := (others => '0');
       
     
       begin
    
       -- LEN Calculation logic ------------------------------------------ 
        
         sig_next_len         <= STD_LOGIC_VECTOR(RESIZE(sig_len2use, LEN_WIDTH));
        
         sig_len_btt_slice    <= UNSIGNED(sig_cmd_btt_reg(CMD_BTT_MS_INDEX downto BTT_LS_UNUSED_WIDTH));
         
         sig_len_btt_slice_minus_1 <= sig_len_btt_slice-BTT_SLICE_ONE
          when sig_btt_is_zero_reg = '0'
          else (others => '0');    -- clip at zero
         
         sig_btt_len_residue  <= UNSIGNED(sig_cmd_btt_reg(BTT_LS_UNUSED_WIDTH-1 downto 0));
            
         
         -- If most significant bit of BTT set then limit to 
         -- Max Burst Len, else rip it from the BTT value
         -- However if residue bits are zeroes then subtract
         -- 1 from the BTT ripped value
         sig_len2use <= MAX_BURST_LEN_US 
           When (sig_cmd_btt_reg(CMD_BTT_MS_INDEX) = '1')
           Else sig_len_btt_slice_minus_1
           when (sig_btt_len_residue = BTT_RESIDUE_ZEROS)
           Else sig_len_btt_slice;

        
       end generate GEN_HAS_RESIDUE_BITS;
        
        
        
        
        
        
        
     
     
     
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_INPUT_CMD
    --
    -- Process Description:
    --  Implements the input command holding registers
    --
    -------------------------------------------------------------
    REG_INPUT_CMD : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset       = '1' or
                sm_pop_input_cmd = '1') then
            
              sig_cmd_btt_reg      <=  (others => '0');
              sig_cmd_type_reg     <=  '0';
              sig_cmd_addr_reg     <=  (others => '0');
              sig_cmd_tag_reg      <=  (others => '0');
              sig_btt_is_zero_reg  <=  '0';
              
              sig_cmd_reg_empty    <=  '1';
              sig_cmd_reg_full     <=  '0';
              sig_input_eof_reg    <= '0'; 
              sig_cmd_burst_reg    <=  "00";
            
            elsif (sig_load_input_cmd = '1') then
              
              sig_cmd_btt_reg      <= sig_cmd_btt_slice;
              sig_cmd_type_reg     <= cmd2mstr_command(CMD_TYPE_INDEX);
              sig_cmd_addr_reg     <= cmd2mstr_command(CMD_ADDR_MS_INDEX downto CMD_ADDR_LS_INDEX);  
              sig_cmd_tag_reg      <=  cmd2mstr_command(CMD_TAG_MS_INDEX downto CMD_TAG_LS_INDEX);
              sig_btt_is_zero_reg  <= sig_btt_is_zero;
              
              sig_cmd_reg_empty    <=  '0';
              sig_cmd_reg_full     <=  '1';

              sig_cmd_burst_reg    <= sig_next_burst;
              if (C_MICRO_DMA = 1) then  
                sig_input_eof_reg    <= cmd2mstr_command(CMD_EOF_INDEX);
              else
                sig_input_eof_reg    <= '1';
              end if;
            
            else
              null; -- Hold current State
            end if; 
         end if;       
       end process REG_INPUT_CMD; 
   
   
    
    
    -- Only Incrementing Burst type supported (per Interface_X guidelines)
    sig_next_burst <= AXI_BURST_INCR when (cmd2mstr_command(CMD_TYPE_INDEX) = '1') else
                      AXI_BURST_FIXED;
    sig_next_user <= cache2mstr_command (7 downto 4);   
    sig_next_cache  <= cache2mstr_command (3 downto 0);   
 
 
  
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_LEN_SDWIDTH_64
    --
    -- If Generate Description:
    --  This IfGen implements the AXI LEN qualifier calculation
    -- and the Stream data channel start/end STRB value.  
    --
    -- This IfGen is for the 64-bit Stream data Width case.
    --
    ------------------------------------------------------------
    GEN_LEN_SDWIDTH_64 : if (C_STREAM_DWIDTH = 64) generate
    
       -- Local Constants
       Constant AXI_SIZE2USE      : std_logic_vector(2 downto 0) := AXI_SIZE_8BYTE;
       Constant RESIDUE_BIT_WIDTH : integer := 3;
       
       
       
       -- local signals
       signal sig_last_strb2use              : std_logic_vector(STRB_WIDTH-1 downto 0) := (others => '0');
       signal sig_last_strb                  : std_logic_vector(STRB_WIDTH-1 downto 0) := (others => '0');
       Signal sig_btt_ms_bit_value           : std_logic := '0';
       signal lsig_btt_len_residue           : std_logic_vector(BTT_LS_UNUSED_WIDTH-1 downto 0) := (others => '0');
       signal sig_btt_len_residue_composite  : std_logic_vector(RESIDUE_BIT_WIDTH downto 0) := (others => '0');
                                                                -- note 1 extra bit implied
                                                                
       
       begin
           
         -- Assign the Address Channel Controller Size Qualifier Value
         sig_next_size        <= AXI_SIZE2USE;
         
         -- Assign the Strobe Values
         sig_next_strt_strb   <= (others => '1'); -- always aligned on first databeat for LITE DataMover
         sig_next_end_strb    <= sig_last_strb;
        
        
         -- Local calculations ------------------------------
         
         lsig_btt_len_residue  <= sig_cmd_btt_reg(BTT_LS_UNUSED_WIDTH-1 downto 0);
         
         sig_btt_ms_bit_value  <= sig_cmd_btt_reg(CMD_BTT_MS_INDEX);
         
         sig_btt_len_residue_composite <= sig_btt_ms_bit_value &
                                          lsig_btt_len_residue;
         
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_LAST_STRB_8bit
         --
         -- Process Description:
         -- Generates the Strobe values for the LAST databeat of the
         -- Burst to MMap when the Stream is 64 bits wide and 8 strobe
         -- bits are required.
         --
         -------------------------------------------------------------
         IMP_LAST_STRB_8bit : process (sig_btt_len_residue_composite)
            begin
         
             case sig_btt_len_residue_composite is
               when "0001" =>
                 sig_last_strb <= "00000001";
               when "0010" =>
                 sig_last_strb <= "00000011";
               when "0011" =>
                 sig_last_strb <= "00000111";
               when "0100" =>
                 sig_last_strb <= "00001111";
               when "0101" =>
                 sig_last_strb <= "00011111";
               when "0110" =>
                 sig_last_strb <= "00111111";
               when "0111" =>
                 sig_last_strb <= "01111111";
               when others =>
                 sig_last_strb <= "11111111";
             end case;
             
             
            end process IMP_LAST_STRB_8bit; 
         
         
       end generate GEN_LEN_SDWIDTH_64;
  
  
  
  
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_LEN_SDWIDTH_32
    --
    -- If Generate Description:
    --  This IfGen implements the AXI LEN qualifier calculation
    -- and the Stream data channel start/end STRB value.  
    --
    -- This IfGen is for the 32-bit Stream data Width case.
    --
    ------------------------------------------------------------
    GEN_LEN_SDWIDTH_32 : if (C_STREAM_DWIDTH = 32) generate
    
       -- Local Constants
       Constant AXI_SIZE2USE                 : std_logic_vector(2 downto 0) := AXI_SIZE_4BYTE;
       Constant RESIDUE_BIT_WIDTH            : integer := 2;
       
       -- local signals
       signal sig_last_strb2use              : std_logic_vector(STRB_WIDTH-1 downto 0) := (others => '0');
       signal sig_last_strb                  : std_logic_vector(STRB_WIDTH-1 downto 0) := (others => '0');
       Signal sig_btt_ms_bit_value           : std_logic := '0';
       signal sig_btt_len_residue_composite  : std_logic_vector(RESIDUE_BIT_WIDTH downto 0) := (others => '0'); -- 1 extra bit
       signal lsig_btt_len_residue           : std_logic_vector(BTT_LS_UNUSED_WIDTH-1 downto 0) := (others => '0');
       
       
       begin
           
         -- Assign the Address Channel Controller Size Qualifier Value
         sig_next_size        <= AXI_SIZE2USE;
         
         -- Assign the Strobe Values
         sig_next_strt_strb   <= (others => '1'); -- always aligned on first databeat for LITE DataMover
         sig_next_end_strb    <= sig_last_strb;
        
        
         -- Local calculations ------------------------------
         
         lsig_btt_len_residue  <= sig_cmd_btt_reg(BTT_LS_UNUSED_WIDTH-1 downto 0);
         
         sig_btt_ms_bit_value <= sig_cmd_btt_reg(CMD_BTT_MS_INDEX);
         
         sig_btt_len_residue_composite <= sig_btt_ms_bit_value &
                                          lsig_btt_len_residue;
         
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_LAST_STRB_4bit
         --
         -- Process Description:
         -- Generates the Strobe values for the LAST databeat of the
         -- Burst to MMap when the Stream is 32 bits wide and 4 strobe
         -- bits are required.
         --
         -------------------------------------------------------------
         IMP_LAST_STRB_4bit : process (sig_btt_len_residue_composite)
            begin
         
             case sig_btt_len_residue_composite is
               when "001" =>
                 sig_last_strb <= "0001";
               when "010" =>
                 sig_last_strb <= "0011";
               when "011" =>
                 sig_last_strb <= "0111";
               when others =>
                 sig_last_strb <= "1111";
             end case;
             
             
            end process IMP_LAST_STRB_4bit; 
          
       end generate GEN_LEN_SDWIDTH_32;
  
  
  
  
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_LEN_SDWIDTH_16
    --
    -- If Generate Description:
    --  This IfGen implements the AXI LEN qualifier calculation
    -- and the Stream data channel start/end STRB value.  
    --
    -- This IfGen is for the 16-bit Stream data Width case.
    --
    ------------------------------------------------------------
    GEN_LEN_SDWIDTH_16 : if (C_STREAM_DWIDTH = 16) generate
    
       -- Local Constants
       Constant AXI_SIZE2USE      : std_logic_vector(2 downto 0) := AXI_SIZE_2BYTE;
       Constant RESIDUE_BIT_WIDTH : integer := 1;
       
       
       -- local signals
       signal sig_last_strb2use              : std_logic_vector(STRB_WIDTH-1 downto 0) := (others => '0');
       signal sig_last_strb                  : std_logic_vector(STRB_WIDTH-1 downto 0) := (others => '0');
       Signal sig_btt_ms_bit_value           : std_logic := '0';
       signal sig_btt_len_residue_composite  : std_logic_vector(RESIDUE_BIT_WIDTH downto 0) := (others => '0'); -- 1 extra bit
       signal lsig_btt_len_residue           : std_logic_vector(BTT_LS_UNUSED_WIDTH-1 downto 0) := (others => '0');
       
       
       begin
           
         -- Assign the Address Channel Controller Size Qualifier Value
         sig_next_size        <= AXI_SIZE2USE;
         
         -- Assign the Strobe Values
         sig_next_strt_strb   <= (others => '1'); -- always aligned on first databeat for LITE DataMover
         sig_next_end_strb    <= sig_last_strb;
        
        
         -- Local calculations ------------------------------
         
         lsig_btt_len_residue  <= sig_cmd_btt_reg(BTT_LS_UNUSED_WIDTH-1 downto 0);
         
         sig_btt_ms_bit_value  <= sig_cmd_btt_reg(CMD_BTT_MS_INDEX);
         
         sig_btt_len_residue_composite <= sig_btt_ms_bit_value &
                                          lsig_btt_len_residue;
         
         
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: IMP_LAST_STRB_2bit
         --
         -- Process Description:
         -- Generates the Strobe values for the LAST databeat of the
         -- Burst to MMap when the Stream is 16 bits wide and 2 strobe
         -- bits are required.
         --
         -------------------------------------------------------------
         IMP_LAST_STRB_2bit : process (sig_btt_len_residue_composite)
            begin
         
             case sig_btt_len_residue_composite is
               when "01" =>
                 sig_last_strb <= "01";
               when others =>
                 sig_last_strb <= "11";
             end case;
             
             
            end process IMP_LAST_STRB_2bit; 
         
         
       end generate GEN_LEN_SDWIDTH_16;
  
  
  
  
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_LEN_SDWIDTH_8
    --
    -- If Generate Description:
    --  This IfGen implements the AXI LEN qualifier calculation
    -- and the Stream data channel start/end STRB value.  
    --
    -- This IfGen is for the 8-bit Stream data Width case.
    --
    ------------------------------------------------------------
    GEN_LEN_SDWIDTH_8 : if (C_STREAM_DWIDTH = 8) generate
       
       -- Local Constants
       Constant AXI_SIZE2USE : std_logic_vector(2 downto 0) := AXI_SIZE_1BYTE;
       
       begin
    
           -- Assign the Address Channel Controller Qualifiers
         sig_next_size        <= AXI_SIZE2USE;
           
         -- Assign the Data Channel Controller Qualifiers
         sig_next_strt_strb   <= (others => '1');
         sig_next_end_strb    <= (others => '1');
          
          
       end generate GEN_LEN_SDWIDTH_8;
  
  
  
  
  
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CMD2DATA_VALID_FLOP
    --
    -- Process Description:
    --  Implements the set/reset flop for the Command Ready control
    -- to the Data Controller Module.
    --
    -------------------------------------------------------------
    CMD2DATA_VALID_FLOP : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset             = '1' or
                sig_clr_cmd2data_valid = '1') then
    
              sig_cmd2data_valid <= '0';
              
            elsif (sm_set_push2axi_ns = '1') then
    
              sig_cmd2data_valid <= '1';
              
            else
              null; -- hold current state
            end if; 
         end if;       
       end process CMD2DATA_VALID_FLOP; 
      
      
      
      
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CMD2ADDR_VALID_FLOP
    --
    -- Process Description:
    --  Implements the set/reset flop for the Command Ready control
    -- to the Address Controller Module.
    --
    -------------------------------------------------------------
    CMD2ADDR_VALID_FLOP : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset             = '1' or
                sig_clr_cmd2addr_valid = '1') then
    
              sig_cmd2addr_valid <= '0';
              
            elsif (sm_set_push2axi_ns = '1') then
    
              sig_cmd2addr_valid <= '1';
              
            else
              null; -- hold current state
            end if; 
         end if;       
       end process CMD2ADDR_VALID_FLOP; 
      
      
      
      
    
    
    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: SCC_SM_COMB
    --
    -- Process Description:
    -- Implements combinational portion of state machine
    --
    -------------------------------------------------------------
    SCC_SM_COMB : process (sm_scc_state,
                           cmd2mstr_cmd_valid,
                           sig_addr_data_rdy_pending, 
                           sig_cmd_reg_full,
                           sig_btt_is_zero_reg
                          )
       begin
    
         -- Set default State machine outputs
         sm_pop_input_cmd_ns  <= '0';
         sm_set_push2axi_ns   <= '0';
         sm_scc_state_ns      <= sm_scc_state;
         sm_set_error_ns      <= '0';
         sm_scc_sm_ready_ns   <= '1';
          
          
         case sm_scc_state is
           
           ----------------------------------------------------
           when INIT =>
             
             -- if (sig_addr_data_rdy4cmd = '1') then
             if (cmd2mstr_cmd_valid = '1') then  -- wait for first cmd valid after reset
             
               sm_scc_state_ns   <= GET_NXT_CMD;  -- jump to get command
       
              else
               
               sm_scc_sm_ready_ns <= '0';
               sm_scc_state_ns    <= INIT;  -- Stay in Init
              
              End if;
             
               
           ----------------------------------------------------
           when POP_RECOVER =>
           
               sm_scc_state_ns    <= GET_NXT_CMD;  -- jump to next state
           
             
           ----------------------------------------------------
           when GET_NXT_CMD =>
             
             if (sig_cmd_reg_full = '1') then
             
               sm_scc_state_ns    <= CHK_AND_CALC;  -- jump to next state
               
             else
             
               sm_scc_state_ns    <= GET_NXT_CMD;  -- stay in this state
             
             end if;
             
           
           ----------------------------------------------------
           when CHK_AND_CALC =>
             
             sm_set_push2axi_ns <= '1';  -- Push the command to ADDR and DATA
             
             if (sig_btt_is_zero_reg = '1') then
             
               sm_scc_state_ns    <= ERROR_TRAP;  -- jump to error trap
               sm_set_error_ns    <= '1';         -- Set internal error flag
               
             else
             
               sm_scc_state_ns    <= PUSH_TO_AXI;  
             
             end if;
             
           
           ----------------------------------------------------
           when PUSH_TO_AXI =>
           
             if (sig_addr_data_rdy_pending = '1') then
             
               sm_scc_state_ns    <= PUSH_TO_AXI;  -- stay in this state
                                                   -- until both Addr and Data have taken commands
             else
             
               sm_pop_input_cmd_ns  <= '1';
               sm_scc_state_ns      <= POP_RECOVER; -- jump back to fetch new cmd input 
             
             end if;
             
           
           
           ----------------------------------------------------
           when ERROR_TRAP =>
           
             sm_scc_state_ns    <= ERROR_TRAP;  -- stay in this state
             sm_set_error_ns    <= '1';
           
             
           ----------------------------------------------------
           when others =>
               
             sm_scc_state_ns    <= INIT; -- error so always jump to init state
               
         end case;
         
    
       end process SCC_SM_COMB; 
    
  
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: SCC_SM_REG
    --
    -- Process Description:
    -- Implements registered portion of state machine
    --
    -------------------------------------------------------------
    SCC_SM_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sm_scc_state      <= INIT;
              sm_pop_input_cmd  <= '0' ;           
              sm_set_push2axi   <= '0' ;           
              sm_set_error      <= '0' ;
              sm_scc_sm_ready   <= '0' ;
              
            else
              
              sm_scc_state      <= sm_scc_state_ns     ;
              sm_pop_input_cmd  <= sm_pop_input_cmd_ns ;           
              sm_set_push2axi   <= sm_set_push2axi_ns  ;           
              sm_set_error      <= sm_set_error_ns     ;
              sm_scc_sm_ready   <= sm_scc_sm_ready_ns  ;
              
            end if; 
         end if;       
       end process SCC_SM_REG; 
    
    
  
  
  
  end implementation;
