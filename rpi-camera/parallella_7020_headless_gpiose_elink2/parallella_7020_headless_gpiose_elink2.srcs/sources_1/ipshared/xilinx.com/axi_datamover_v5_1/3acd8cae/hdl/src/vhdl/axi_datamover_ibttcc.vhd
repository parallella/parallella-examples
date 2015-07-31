  -------------------------------------------------------------------------------
  -- axi_datamover_ibttcc.vhd
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
  -- Filename:        axi_datamover_ibttcc.vhd
  --
  -- Description:     
  --    This file implements the DataMover Indeterminate BTT Command Calculator
  -- (SFCC) for the Indeterminate BTT operation mode of the DataMover S2MM 
  -- function.  Since Indeterminate BTT is totally dependent on the data                
  -- received from the S2MM input Stream for command generation, Predictive 
  -- child request calculation is not needed.  
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
  
  entity axi_datamover_ibttcc is
    generic (
      
      C_SF_XFER_BYTES_WIDTH : Integer range  1 to  14 :=  8;
        -- sets the width of the sf2pcc_xfer_bytes port which is
        -- used to indicate the number of actual bytes received
        -- by the IBTT functions
      
      
      C_DRE_ALIGN_WIDTH     : Integer range  1 to   3 :=  2;
        -- Sets the width of the DRE Aligment output ports
        
      C_SEL_ADDR_WIDTH      : Integer range  1 to   8 :=  5;
        -- Sets the width of the LS address bus used for 
        -- Muxing/Demuxing data to/from a wider AXI4 data bus
      
      C_ADDR_WIDTH          : Integer range 32 to  64 := 32;
        -- Sets the width of the AXi Address Channel 
      
      C_STREAM_DWIDTH       : Integer range  8 to 1024 := 32;
        -- Sets the width of the Native Data width that
        -- is being supported by the PCC
      
      C_MAX_BURST_LEN       : Integer range 2 to 256 := 16;
        -- Indicates the max allowed burst length to use for
        -- AXI4 transfer calculations
      
      C_CMD_WIDTH           : Integer                 := 68;
        -- Sets the width of the input command port
      
      C_TAG_WIDTH           : Integer range  1 to   8 :=  4;
        -- Sets the width of the Tag field in the input command
      
      C_BTT_USED            : Integer range  8 to  23 := 16 ;
        -- Sets the width of the used portion of the BTT field
        -- of the input command
      
      C_NATIVE_XFER_WIDTH    : Integer range  8 to 1024 :=  32;
        -- Indicates the Native transfer width to use for all
        -- transfer calculations. This will either be the DataMover
        -- input Stream width or the AXI4 MMap data width depending
        -- on DataMover parameterization.
      
      C_STRT_SF_OFFSET_WIDTH : Integer range  1 to   7 :=  1
        -- Indicates the width of the starting address offset
        -- bus passed to Store and Forward functions incorporating
        -- upsizer/downsizer logic.                                                    

      );
    port (
      
      -- Clock and Reset input ------------------------------------------
                                                                       --
      primary_aclk         : in  std_logic;                            --
         -- Primary synchronization clock for the Master side          --
         -- interface and internal logic. It is also used              --
         -- for the User interface synchronization when                --
         -- C_STSCMD_IS_ASYNC = 0.                                     --
                                                                       --
      -- Reset input                                                   --
      mmap_reset           : in  std_logic;                            --
        -- Reset used for the internal master logic                    --
      -------------------------------------------------------------------
      
       
       
     
      -- Master Command FIFO/Register Interface ------------------------------------------
                                                                                        --
      cmd2mstr_command      : in std_logic_vector(C_CMD_WIDTH-1 downto 0);              --
         -- The next command value available from the Command FIFO/Register             --
      cache2mstr_command      : in std_logic_vector(7 downto 0);                --
         -- The next command value available from the Command FIFO/Register               --
                                                                                        --
      cmd2mstr_cmd_valid    : in std_logic;                                             --
         -- Handshake bit indicating if the Command FIFO/Register has at least 1 entry  --
                                                                                        --
      mst2cmd_cmd_ready     : out  std_logic;                                           --
         -- Handshake bit indicating the Command Calculator is ready to accept          --
         -- another command                                                             --
      ------------------------------------------------------------------------------------
      
      
      
      -- Store and Forward Block Interface -----------------------------------------------
                                                                                        --
      sf2pcc_xfer_valid       : In std_logic;                                           --
        -- Indicates that at least 1 xfer descriptor entry is in in the IBtt            --
        -- XFER_DESCR_FIFO.                                                             --
                                                                                        --
      pcc2sf_xfer_ready       : Out std_logic;                                          --
        -- Indicates to the Store and Forward module that the xfer descriptor           --
        -- is being accepted by the SFCC.                                               --
                                                                                        --
                                                                                        --
      sf2pcc_cmd_cmplt        : In std_logic;                                           --
        -- Indicates that the next Store and Forward pending data block                 --
        -- is the last one associated with the corresponding command loaded             --
        -- into the Realigner.                                                          --
                                                                                        --
                                                                                        --
      sf2pcc_packet_eop       : In  std_logic;                                          --
        -- Indicates the end of a Stream Packet corresponds to the pending              --
        -- xfer data described by this xfer descriptor.                                 --
                                                                                        --
                                                                                        --
      sf2pcc_xfer_bytes       : In std_logic_vector(C_SF_XFER_BYTES_WIDTH-1 downto 0);  --
        -- This data byte count is used by the SFCC to increment the Address            --
        -- Counter to the next starting address for the next sequential transfer.       --
      ------------------------------------------------------------------------------------
 
      
      
       
      -- Address Channel Controller Interface --------------------------------------------
                                                                                        --
      mstr2addr_tag        : out std_logic_vector(C_TAG_WIDTH-1 downto 0);              --
         -- The next command tag                                                        --
                                                                                        --
      mstr2addr_addr       : out std_logic_vector(C_ADDR_WIDTH-1 downto 0);             --
         -- The next command address to put on the AXI MMap ADDR                        --
                                                                                        --
      mstr2addr_len        : out std_logic_vector(7 downto 0);                          --
         -- The next command length to put on the AXI MMap LEN                          --
                                                                                        --
      mstr2addr_size       : out std_logic_vector(2 downto 0);                          --
         -- The next command size to put on the AXI MMap SIZE                           --
                                                                                        --
      mstr2addr_burst      : out std_logic_vector(1 downto 0);                          --
         -- The next command burst type to put on the AXI MMap BURST                    --
                                                                                        --
      mstr2addr_cache     : out std_logic_vector(3 downto 0);                  --
         -- The next command burst type to put on the AXI MMap BURST           --

      mstr2addr_user     : out std_logic_vector(3 downto 0);                  --
         -- The next command burst type to put on the AXI MMap BURST           --
      mstr2addr_cmd_cmplt  : out std_logic;                                             --
         -- The indication to the Address Channel that the current                      --
         -- sub-command output is the last one compiled from the                        --
         -- parent command pulled from the Command FIFO                                 --
                                                                                        --
      mstr2addr_calc_error : out std_logic;                                             --
         -- Indication if the next command in the calculation pipe                      --
         -- has a calcualtion error                                                     --
                                                                                        --
      mstr2addr_cmd_valid  : out std_logic;                                             --
         -- The next command valid indication to the Address Channel                    --
         -- Controller for the AXI MMap                                                 --
                                                                                        --
      addr2mstr_cmd_ready  : In std_logic;                                              --
         -- Indication from the Address Channel Controller that the                     --
         -- command is being accepted                                                   --
      ------------------------------------------------------------------------------------
      
      
      
      
      -- Data Channel Controller Interface -----------------------------------------------
                                                                                        --
      mstr2data_tag        : out std_logic_vector(C_TAG_WIDTH-1 downto 0);              --
         -- The next command tag                                                        --
                                                                                        --
      mstr2data_saddr_lsb  : out std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0);         --
         -- The next command start address LSbs to use for the read data                --
         -- mux (only used if Stream data width is less than the MMap data              --
         -- width).                                                                     --
                                                                                        --
      mstr2data_len        : out std_logic_vector(7 downto 0);                          --
         -- The LEN value output to the Address Channel                                 --
                                                                                        --
      mstr2data_strt_strb  : out std_logic_vector((C_NATIVE_XFER_WIDTH/8)-1 downto 0);  --
         -- The starting strobe value to use for the data transfer                      --
                                                                                        --
      mstr2data_last_strb  : out std_logic_vector((C_NATIVE_XFER_WIDTH/8)-1 downto 0);  --
         -- The endiing (LAST) strobe value to use for the data transfer                --
                                                                                        --
      mstr2data_drr        : out std_logic;                                             --
         -- The starting tranfer of a sequence of transfers                             --
                                                                                        --
      mstr2data_eof        : out std_logic;                                             --
         -- The endiing tranfer of a sequence of parent transfer commands               --
                                                                                        --
      mstr2data_sequential : Out std_logic;                                             --
         -- The next sequential tranfer of a sequence of transfers                      --
         -- spawned from a single parent command                                        --
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
      ------------------------------------------------------------------------------------
     
      
      
      -- Output flag indicating that a calculation error has occured ---------------------
                                                                                        --
      calc_error               : Out std_logic;                                         --
         -- Indication from the Command Calculator that a calculation                   --
         -- error has occured.                                                          --
      ------------------------------------------------------------------------------------  
      
      
         
         
      -- Special S2MM DRE Controller Interface -------------------------------------------
                                                                                        --
      dre2mstr_cmd_ready        : In std_logic ;                                        --
         -- Indication from the S2MM DRE Controller that it can                         --
         -- accept another command.                                                     --
                                                                                        --
      mstr2dre_cmd_valid        : out std_logic ;                                       --
         -- The next command valid indication to the S2MM DRE                           --
         -- Controller.                                                                 --
                                                                                        --
      mstr2dre_tag              : out std_logic_vector(C_TAG_WIDTH-1 downto 0);         --
         -- The next command tag                                                        --
                                                                                        --
      mstr2dre_dre_src_align    : Out std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0) ;  --
         -- The source (S2MM Stream) alignment for the S2MM DRE                         --
                                                                                        --
      mstr2dre_dre_dest_align   : Out std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0) ;  --
         -- The destinstion (S2MM MMap) alignment for the S2MM DRE                      --
                                                                                        --
      mstr2dre_btt              : out std_logic_vector(C_BTT_USED-1 downto 0) ;         --
         -- The BTT value output to the S2MM DRE. This is needed for                    --
         -- Scatter operations.                                                         --
                                                                                        --
      mstr2dre_drr              : out std_logic ;                                       --
         -- The starting tranfer of a sequence of transfers                             --
                                                                                        --
      mstr2dre_eof              : out std_logic ;                                       --
         -- The endiing tranfer of a sequence of parent transfer commands               --
                                                                                        --
      mstr2dre_cmd_cmplt        : Out std_logic ;                                       --
         -- The next sequential tranfer of a sequence of transfers                      --
         -- spawned from a single parent command                                        --
                                                                                        --
      mstr2dre_calc_error       : out std_logic ;                                       --
         -- Indication if the next command in the calculation pipe                      --
         -- has a calculation error                                                     --
      ------------------------------------------------------------------------------------

     
     
     -- Store and Forward Support Start Offset --------------------------------------------- 
                                                                                          -- 
     mstr2dre_strt_offset       : out std_logic_vector(C_STRT_SF_OFFSET_WIDTH-1 downto 0) -- 
       -- Relays the starting address offset for a transfer to the Store and Forward      -- 
       -- functions incorporating upsizer/downsizer logic                                 -- 
     ---------------------------------------------------------------------------------------    


     
      );
  
  end entity axi_datamover_ibttcc;
  
  
  architecture implementation of axi_datamover_ibttcc is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
  
  
  
  -- Function declarations  -------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_dbeat_residue_width
    --
    -- Function Description:
    --  Calculates the number of Least significant bits of the BTT field
    -- that are unused for the LEN calculation
    --
    -------------------------------------------------------------------
    function funct_get_dbeat_residue_width (bytes_per_beat : integer) return integer is

      Variable temp_dbeat_residue_width : Integer := 0; -- 8-bit stream

    begin

      case bytes_per_beat is
        when 1 =>  
            temp_dbeat_residue_width := 0;
        when 2 =>
            temp_dbeat_residue_width := 1;
        when 4 =>
            temp_dbeat_residue_width := 2;
        when 8 =>
            temp_dbeat_residue_width := 3;
        when 16 =>
            temp_dbeat_residue_width := 4;
        when 32 =>
            temp_dbeat_residue_width := 5;
        when 64 =>
            temp_dbeat_residue_width := 6;
        
        when others =>  -- 128-byte transfers
            temp_dbeat_residue_width := 7;
      end case;

      Return (temp_dbeat_residue_width);

    end function funct_get_dbeat_residue_width;
    
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_burstcnt_offset
    --
    -- Function Description:
    -- Calculates the bit offset from the residue bits needed to detirmine
    -- the load value for the burst counter.
    --
    -------------------------------------------------------------------
    function funct_get_burst_residue_width (max_burst_len : integer) return integer is
                                    
    
      Variable temp_burst_residue_width : Integer := 0;
    
    begin

      case max_burst_len is
        
        when 256 =>
          temp_burst_residue_width := 8;
        when 128 =>
          temp_burst_residue_width := 7;
        when 64 =>
          temp_burst_residue_width := 6;
        when 32 =>
          temp_burst_residue_width := 5;
        when 16 =>
          temp_burst_residue_width := 4;
        when 8 =>
          temp_burst_residue_width := 3;
        when 4 =>
          temp_burst_residue_width := 2;
        when others =>   -- assume 2 dbeats
          temp_burst_residue_width := 1;
      end case;
      
      Return (temp_burst_residue_width);
     
    end function funct_get_burst_residue_width;
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_get_axi_size
    --
    -- Function Description:
    --  Calcilates the AXi MMAP Size qualifier based on the data width
    --
    -------------------------------------------------------------------
    function func_get_axi_size (native_dwidth : integer) return std_logic_vector is
    
        
      Constant AXI_SIZE_1BYTE    : std_logic_vector(2 downto 0) := "000"; 
      Constant AXI_SIZE_2BYTE    : std_logic_vector(2 downto 0) := "001"; 
      Constant AXI_SIZE_4BYTE    : std_logic_vector(2 downto 0) := "010"; 
      Constant AXI_SIZE_8BYTE    : std_logic_vector(2 downto 0) := "011"; 
      Constant AXI_SIZE_16BYTE   : std_logic_vector(2 downto 0) := "100"; 
      Constant AXI_SIZE_32BYTE   : std_logic_vector(2 downto 0) := "101"; 
      Constant AXI_SIZE_64BYTE   : std_logic_vector(2 downto 0) := "110"; 
      Constant AXI_SIZE_128BYTE  : std_logic_vector(2 downto 0) := "111"; 
      
      Variable temp_size : std_logic_vector(2 downto 0) := (others => '0');
    
    begin
    
      
       case native_dwidth is
         when 8 =>  
           temp_size := AXI_SIZE_1BYTE;
         when 16 =>
           temp_size := AXI_SIZE_2BYTE;
         when 32 =>
           temp_size := AXI_SIZE_4BYTE;
         when 64 =>
           temp_size := AXI_SIZE_8BYTE;
         when 128 =>
           temp_size := AXI_SIZE_16BYTE;
         when 256 =>
           temp_size := AXI_SIZE_32BYTE;
         when 512 =>
           temp_size := AXI_SIZE_64BYTE;
         
         when others => -- 1024 bit dwidth
           temp_size := AXI_SIZE_128BYTE;
       end case;
       
      
       Return (temp_size);
      
      
    end function func_get_axi_size;
    
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_sf_offset_ls_index
    --
    -- Function Description:
    --   Calculates the Ls index of the Store and Forward
    --  starting offset bus based on the User Stream Width.
    --
    -------------------------------------------------------------------
    function funct_get_sf_offset_ls_index (stream_width : integer) return integer is
    
      Variable lvar_temp_ls_index : Integer := 0;
    
    begin
    
      case stream_width is
        when 8 =>
          lvar_temp_ls_index := 0;
        when 16 =>
          lvar_temp_ls_index := 1;
        when 32 =>
          lvar_temp_ls_index := 2;
        when 64 =>
          lvar_temp_ls_index := 3;
        when 128 =>
          lvar_temp_ls_index := 4;
        when 256 =>
          lvar_temp_ls_index := 5;
        when 512 =>
          lvar_temp_ls_index := 6;
        when others => -- 1024
          lvar_temp_ls_index := 7;
      end case;
      
      Return (lvar_temp_ls_index);
    
    
    end function funct_get_sf_offset_ls_index;
    


                                     
    
    -- Constant Declarations  ----------------------------------------
    
    Constant BASE_CMD_WIDTH         : integer  := 32; -- Bit Width of Command LS (no address)
    Constant CMD_BTT_WIDTH          : integer  := C_BTT_USED;
    Constant CMD_BTT_LS_INDEX       : integer  := 0;
    Constant CMD_BTT_MS_INDEX       : integer  := CMD_BTT_WIDTH-1;
    Constant CMD_TYPE_INDEX         : integer  := 23;
    Constant CMD_DRR_INDEX          : integer  := BASE_CMD_WIDTH-1;
    Constant CMD_EOF_INDEX          : integer  := BASE_CMD_WIDTH-2;
    Constant CMD_DSA_WIDTH          : integer  := 6;
    Constant CMD_DSA_LS_INDEX       : integer  := CMD_TYPE_INDEX+1;
    Constant CMD_DSA_MS_INDEX       : integer  := (CMD_DSA_LS_INDEX+CMD_DSA_WIDTH)-1;
    Constant CMD_ADDR_LS_INDEX      : integer  := BASE_CMD_WIDTH;
    Constant CMD_ADDR_MS_INDEX      : integer  := (C_ADDR_WIDTH+BASE_CMD_WIDTH)-1;
    Constant CMD_TAG_WIDTH          : integer  := C_TAG_WIDTH;
    Constant CMD_TAG_LS_INDEX       : integer  := C_ADDR_WIDTH+BASE_CMD_WIDTH;
    Constant CMD_TAG_MS_INDEX       : integer  := (CMD_TAG_LS_INDEX+CMD_TAG_WIDTH)-1;
    
    
    ----------------------------------------------------------------------------------------
    -- Command calculation constants
    
    Constant SIZE_TO_USE            : std_logic_vector(2 downto 0) := func_get_axi_size(C_NATIVE_XFER_WIDTH);
    Constant BYTES_PER_DBEAT        : integer  := C_NATIVE_XFER_WIDTH/8;
    Constant DBEATS_PER_BURST       : integer  := C_MAX_BURST_LEN;
    Constant BYTES_PER_MAX_BURST    : integer  := DBEATS_PER_BURST*BYTES_PER_DBEAT;
    Constant LEN_WIDTH              : integer  := 8;  -- 8 bits fixed 
    Constant DBEAT_RESIDUE_WIDTH    : integer  := funct_get_dbeat_residue_width(BYTES_PER_DBEAT);
    Constant BURST_RESIDUE_WIDTH    : integer  := funct_get_burst_residue_width(C_MAX_BURST_LEN);
    Constant BTT_RESIDUE_WIDTH      : integer  := DBEAT_RESIDUE_WIDTH+BURST_RESIDUE_WIDTH + 1;
    Constant BTT_ZEROS              : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0'); 
    Constant BTT_RESIDUE_0          : unsigned := TO_UNSIGNED( 0, BTT_RESIDUE_WIDTH);
    Constant ADDR_CNTR_WIDTH        : integer  := 16;  -- Addres Counter slice 
    Constant ADDR_CNTR_MAX_VALUE    : unsigned := TO_UNSIGNED((2**ADDR_CNTR_WIDTH)-1, ADDR_CNTR_WIDTH);   
    Constant ADDR_CNTR_ONE          : unsigned := TO_UNSIGNED(1, ADDR_CNTR_WIDTH);   
    Constant MBAA_ADDR_SLICE_WIDTH  : integer  := DBEAT_RESIDUE_WIDTH+BURST_RESIDUE_WIDTH;
    Constant SF_BYTE_XFERED_WIDTH   : integer  := C_SF_XFER_BYTES_WIDTH;
    Constant BTT_UPPER_WIDTH        : integer  := CMD_BTT_WIDTH - BTT_RESIDUE_WIDTH;
    Constant BTT_UPPER_MS_INDEX     : integer  := CMD_BTT_WIDTH-1;
    Constant BTT_UPPER_LS_INDEX     : integer  := BTT_RESIDUE_WIDTH;
    Constant BTT_UPPER_ZERO         : unsigned(BTT_UPPER_WIDTH-1 downto 0) := (others => '0');
    

    Constant SF_OFFSET_LS_INDEX     : integer  := funct_get_sf_offset_ls_index(C_STREAM_DWIDTH);
    Constant SF_OFFSET_MS_INDEX     : integer  := (SF_OFFSET_LS_INDEX + C_STRT_SF_OFFSET_WIDTH)-1;
    
    
               
    -- Type Declarations  --------------------------------------------
    
    type PARENT_SM_STATE_TYPE is (
                P_INIT,
                P_WAIT_FOR_CMD,
                P_LD_FIRST_CMD,
                P_LD_CHILD_CMD,
                P_LD_LAST_CMD ,
                EXTRA, EXTRA2,
                P_ERROR_TRAP
                );
  
    type CHILD_SM_STATE_TYPE is (
                CH_INIT,
                WAIT_FOR_PCMD,
                CH_WAIT_FOR_SF_CMD,
                CH_LD_CHILD_CMD,
                CH_CHK_IF_DONE,
                CH_ERROR_TRAP1,
                CH_ERROR_TRAP2
                );
  
  
  
    
    
    
    -- Signal Declarations  --------------------------------------------
    
    
    -- Parent Command State Machine
    Signal sig_psm_state                     : PARENT_SM_STATE_TYPE := P_INIT;
    Signal sig_psm_state_ns                  : PARENT_SM_STATE_TYPE := P_INIT;
    signal sig_psm_halt_ns                   : std_logic := '0';
    signal sig_psm_halt                      : std_logic := '0';
    signal sig_psm_pop_input_cmd_ns          : std_logic := '0';
    signal sig_psm_pop_input_cmd             : std_logic := '0';
    signal sig_psm_ld_calc1_ns               : std_logic := '0';
    signal sig_psm_ld_calc1                  : std_logic := '0';
    signal sig_psm_ld_calc2_ns               : std_logic := '0';
    signal sig_psm_ld_calc2                  : std_logic := '0';
    signal sig_psm_ld_realigner_reg_ns       : std_logic := '0';
    signal sig_psm_ld_realigner_reg          : std_logic := '0';
    signal sig_psm_ld_chcmd_reg_ns           : std_logic := '0';
    signal sig_psm_ld_chcmd_reg              : std_logic := '0';
    
    -- Child Command State Machine
    Signal sig_csm_state                     : CHILD_SM_STATE_TYPE := CH_INIT;
    Signal sig_csm_state_ns                  : CHILD_SM_STATE_TYPE := CH_INIT;
    signal sig_csm_ld_xfer                   : std_logic := '0';
    signal sig_csm_ld_xfer_ns                : std_logic := '0';
    signal sig_csm_pop_sf_fifo               : std_logic := '0';
    signal sig_csm_pop_sf_fifo_ns            : std_logic := '0';
    signal sig_csm_pop_child_cmd             : std_logic := '0';
    signal sig_csm_pop_child_cmd_ns          : std_logic := '0';
    
    ----------------------------------------------------------------------------------------
    -- Burst Buster signals
    signal sig_last_xfer_valid               : std_logic := '0';
    signal sig_btt_residue_slice             : Unsigned(BTT_RESIDUE_WIDTH-1 downto 0) := (others => '0');

    -- Input command register
    signal sig_push_input_reg                : std_logic := '0';
    signal sig_pop_input_reg                 : std_logic := '0';
    signal sig_xfer_cache_reg               : std_logic_vector (3 downto 0) := "0000";
    signal sig_xfer_user_reg                : std_logic_vector (3 downto 0) := "0000";
    signal sig_input_burst_type_reg          : std_logic := '0';
    signal sig_input_cache_type_reg         : std_logic_vector (3 downto 0) := "0000";
    signal sig_input_user_type_reg          : std_logic_vector (3 downto 0) := "0000";
    signal sig_input_dsa_reg                 : std_logic_vector(CMD_DSA_WIDTH-1 downto 0) := (others => '0');
    signal sig_input_drr_reg                 : std_logic := '0';
    signal sig_input_eof_reg                 : std_logic := '0';
    signal sig_input_tag_reg                 : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_input_reg_empty               : std_logic := '0';
    signal sig_input_reg_full                : std_logic := '0';
  
    -- Output qualifier Register
    signal sig_push_xfer_reg                 : std_logic := '0';
    signal sig_pop_xfer_reg                  : std_logic := '0';
    signal sig_xfer_addr_reg                 : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_xfer_type_reg                 : std_logic := '0';
    signal sig_xfer_len_reg                  : std_logic_vector(LEN_WIDTH-1 downto 0) := (others => '0');
    signal sig_xfer_tag_reg                  : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_xfer_drr_reg                  : std_logic := '0';
    signal sig_xfer_eof_reg                  : std_logic := '0';
    signal sig_xfer_strt_strb_reg            : std_logic_vector(BYTES_PER_DBEAT-1 downto 0) := (others => '0');
    signal sig_xfer_end_strb_reg             : std_logic_vector(BYTES_PER_DBEAT-1 downto 0) := (others => '0');
    signal sig_xfer_is_seq_reg               : std_logic := '0';
    signal sig_xfer_cmd_cmplt_reg            : std_logic := '0';
    signal sig_xfer_calc_err_reg             : std_logic := '0';
    signal sig_xfer_reg_empty                : std_logic := '0';
    signal sig_xfer_reg_full                 : std_logic := '0';
    
    -- Address Counter
    signal sig_ld_child_addr_cntr            : std_logic := '0';
    signal sig_incr_child_addr_cntr          : std_logic := '0';
    signal sig_child_addr_cntr_incr          : Unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_byte_change_minus1            : Unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
  
    -- misc
    signal sig_xfer_is_seq                   : std_logic := '0';
    signal sig_xfer_len                      : std_logic_vector(LEN_WIDTH-1 downto 0);
    signal sig_xfer_strt_strb                : std_logic_vector(BYTES_PER_DBEAT-1 downto 0) := (others => '0');
    signal sig_xfer_end_strb                 : std_logic_vector(BYTES_PER_DBEAT-1 downto 0) := (others => '0');
    signal sig_xfer_address                  : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_xfer_size                     : std_logic_vector(2 downto 0) := (others => '0');
    signal sig_cmd_addr_slice                : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_btt_slice                 : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_type_slice                : std_logic := '0';
    signal sig_cmd_cache_slice              : std_logic_vector (3 downto 0) := "0000";
    signal sig_cmd_user_slice               : std_logic_vector (3 downto 0) := "0000";
    signal sig_cmd_tag_slice                 : std_logic_vector(CMD_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_dsa_slice                 : std_logic_vector(CMD_DSA_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_drr_slice                 : std_logic := '0';
    signal sig_cmd_eof_slice                 : std_logic := '0';
    signal sig_calc_error_reg                : std_logic := '0';
        
   -- PCC2 stuff 
    signal sig_first_child_xfer              : std_logic := '0';
    signal sig_bytes_to_mbaa                 : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_addr_lsh_rollover       : std_logic := '0';
    signal sig_child_addr_lsh_rollover_reg   : std_logic := '0';
    --signal sig_child_addr_msh_rollover       : std_logic := '0';
    --signal sig_child_addr_msh_rollover_reg   : std_logic := '0';
    signal sig_child_addr_msh_eq_max         : std_logic := '0';
    --signal sig_child_addr_msh_eq_max_reg     : std_logic := '0';
    signal sig_predict_child_addr_lsh_slv    : std_logic_vector(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_predict_child_addr_lsh        : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_addr_cntr_lsh           : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_addr_cntr_lsh_slv       : std_logic_vector(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_addr_cntr_msh           : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_ld_btt_cntr                   : std_logic := '0';
    signal sig_decr_btt_cntr                 : std_logic := '0';
    signal sig_btt_cntr                      : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_btt_is_zero                   : std_logic := '0';
    signal sig_btt_lt_b2mbaa                 : std_logic := '0';
    signal sig_btt_eq_b2mbaa                 : std_logic := '0';
    signal sig_cmd2data_valid                : std_logic := '0';
    signal sig_clr_cmd2data_valid            : std_logic := '0';
    signal sig_cmd2addr_valid                : std_logic := '0';
    signal sig_clr_cmd2addr_valid            : std_logic := '0';
    
    -- Unaligned start address support
    signal sig_adjusted_addr_incr            : Unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    --signal sig_adjusted_child_addr_incr_reg  : Unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_start_addr_offset_slice       : Unsigned(DBEAT_RESIDUE_WIDTH-1 downto 0) := (others => '0');
    signal sig_mbaa_addr_cntr_slice          : Unsigned(MBAA_ADDR_SLICE_WIDTH-1 downto 0) := (others => '0');
    signal sig_addr_aligned                  : std_logic := '0';
    
    -- S2MM DRE Support
    signal sig_cmd2dre_valid                 : std_logic := '0';
    signal sig_realigner_btt                 : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_realigner_btt2                 : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    
    -- Store and forward signals
    signal sig_ld_realigner_cmd              : std_logic := '0';
    signal sig_sf2pcc_xfer_valid             : std_logic := '0';
    signal sig_pcc2sf_xfer_ready             : std_logic := '0';
    signal sig_sf2pcc_cmd_cmplt              : std_logic := '0';
    signal sig_sf2pcc_xfer_bytes             : std_logic_vector(SF_BYTE_XFERED_WIDTH-1 downto 0) := (others => '0');
    signal sig_sf2pcc_packet_eop             : std_logic := '0';
    signal sig_push_realign_reg              : std_logic := '0';
    signal sig_pop_realign_reg               : std_logic := '0';
    signal sig_realign_reg_empty             : std_logic := '0';
    signal sig_realign_reg_full              : std_logic := '0';
    signal sig_first_realigner_cmd           : std_logic := '0';
    signal sig_realign_tag_reg               : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_realign_src_align_reg         : std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_realign_dest_align_reg        : std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_realign_btt_reg               : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_realign_drr_reg               : std_logic := '0';
    signal sig_realign_eof_reg               : std_logic := '0';
    signal sig_realign_cmd_cmplt_reg         : std_logic := '0';
    signal sig_realign_calc_err_reg          : std_logic := '0';
    signal sig_last_s_f_xfer_ld              : std_logic := '0';
    signal sig_skip_align2mbaa               : std_logic := '0';
    signal sig_skip_align2mbaa_s_h           : std_logic := '0';
    signal sig_dre_dest_align                : std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);
    signal sig_realign_btt_cntr_decr         : Unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_input_addr_reg                : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_input_addr_reg1                : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_push_child_cmd_reg            : std_logic := '0';
    signal sig_pop_child_cmd_reg             : std_logic := '0';
    signal sig_child_cmd_reg_empty           : std_logic := '0';
    signal sig_child_cmd_reg_full            : std_logic := '0';
    signal sig_child_burst_type_reg          : std_logic := '0';
    signal sig_child_cache_type_reg          : std_logic_vector (3 downto 0) := (others =>'0');
    signal sig_child_user_type_reg          : std_logic_vector (3 downto 0) := (others =>'0');
    signal sig_child_tag_reg                 : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_addr_reg                : std_logic_vector(C_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_error_reg               : std_logic := '0';
    signal sig_ld_child_qual_reg             : std_logic := '0';
    signal sig_child_qual_tag_reg            : std_logic_vector(C_TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_child_qual_burst_type         : std_logic := '0';
    signal sig_child_qual_cache_type         : std_logic_vector (3 downto 0)  := (others => '0');
    signal sig_child_qual_user_type         : std_logic_vector (3 downto 0)  := (others => '0');
    signal sig_child_qual_first_of_2         : std_logic := '0';
    signal sig_child_qual_error_reg          : std_logic := '0';
    signal sig_needed_2_realign_cmds         : std_logic := '0';
    signal sig_btt_upper_slice               : unsigned(BTT_UPPER_WIDTH-1 downto 0) := (others => '0');
    signal sig_btt_upper_eq_0                : std_logic := '0';
    
    signal sig_mmap_reset_reg                : std_logic := '0';
    
    signal sig_realign_strt_offset_reg       : std_logic_vector(C_STRT_SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
    signal sig_realign_strt_offset           : std_logic_vector(C_STRT_SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
  
      Attribute KEEP : string; -- declaration
  Attribute EQUIVALENT_REGISTER_REMOVAL : string; -- declaration

  Attribute KEEP of sig_input_addr_reg1   : signal is "TRUE"; -- definition
  Attribute KEEP of sig_input_addr_reg : signal is "TRUE"; -- definition

  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_input_addr_reg1   : signal is "no";
  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_input_addr_reg : signal is "no";
 
  
  begin --(architecture implementation)
     
    
    -- sf Interface signals
    pcc2sf_xfer_ready        <=  sig_pcc2sf_xfer_ready  ;
    sig_sf2pcc_xfer_valid    <=  sf2pcc_xfer_valid      ;
    sig_sf2pcc_cmd_cmplt     <=  sf2pcc_cmd_cmplt       ;
    sig_sf2pcc_xfer_bytes    <=  sf2pcc_xfer_bytes      ;
    sig_sf2pcc_packet_eop    <=  sf2pcc_packet_eop      ;
    
    
    -- Assign calculation error output 
    calc_error               <= sig_calc_error_reg;
   
    -- Assign the ready output to the Command FIFO 
    mst2cmd_cmd_ready        <= not(sig_psm_halt)    and 
                                sig_input_reg_empty;
    
    -- Assign the Address Channel Controller Qualifiers
    mstr2addr_tag            <=  sig_xfer_tag_reg  ; 
    mstr2addr_addr           <=  sig_xfer_addr_reg ; 
    mstr2addr_len            <=  sig_xfer_len_reg  ; 
    mstr2addr_size           <=  sig_xfer_size     ;
    mstr2addr_burst          <=  '0' & sig_xfer_type_reg; -- only fixed or increment supported
    mstr2addr_cache          <=  sig_xfer_cache_reg; -- only fixed or increment supported
    mstr2addr_user           <=  sig_xfer_user_reg; -- only fixed or increment supported
    mstr2addr_cmd_valid      <=  sig_cmd2addr_valid     ;
    mstr2addr_calc_error     <=  sig_xfer_calc_err_reg  ;
    mstr2addr_cmd_cmplt      <=  sig_xfer_cmd_cmplt_reg ;
    
    -- Assign the Data Channel Controller Qualifiers
    mstr2data_tag            <= sig_xfer_tag_reg      ; 
    mstr2data_saddr_lsb      <= sig_xfer_addr_reg(C_SEL_ADDR_WIDTH-1 downto 0);
    mstr2data_len            <= sig_xfer_len_reg      ;
    mstr2data_strt_strb      <= sig_xfer_strt_strb_reg;
    mstr2data_last_strb      <= sig_xfer_end_strb_reg ;
    mstr2data_drr            <= sig_xfer_drr_reg      ;  
    mstr2data_eof            <= sig_xfer_eof_reg      ;  
    mstr2data_sequential     <= sig_xfer_is_seq_reg   ;  
    mstr2data_cmd_cmplt      <= sig_xfer_cmd_cmplt_reg;  
    mstr2data_cmd_valid      <= sig_cmd2data_valid    ;
    
    
    mstr2data_calc_error     <= sig_xfer_calc_err_reg ;   
    
    
    -- Assign the S2MM Realigner Qualifiers
    mstr2dre_cmd_valid       <= sig_cmd2dre_valid         ;   -- Used by S2MM DRE
    
    mstr2dre_tag             <= sig_realign_tag_reg       ;   -- Used by S2MM DRE
    mstr2dre_dre_src_align   <= sig_realign_src_align_reg ;   -- Used by S2MM DRE
    mstr2dre_dre_dest_align  <= sig_realign_dest_align_reg;   -- Used by S2MM DRE
    mstr2dre_btt             <= sig_realign_btt_reg       ;   -- Used by S2MM DRE
    mstr2dre_drr             <= sig_realign_drr_reg       ;   -- Used by S2MM DRE
    mstr2dre_eof             <= sig_realign_eof_reg       ;   -- Used by S2MM DRE
    mstr2dre_cmd_cmplt       <= sig_realign_cmd_cmplt_reg ;   -- Used by S2MM DRE
    mstr2dre_calc_error      <= sig_realign_calc_err_reg  ;   -- Used by S2MM DRE
    
    
    -- Store and Forward Support Start Offset (used by Packer/Unpacker logic)
    mstr2dre_strt_offset     <= sig_realign_strt_offset_reg;  
    
    

   
   -- Start internal logic.
   
    sig_cmd_user_slice       <= cache2mstr_command(7 downto 4);
    sig_cmd_cache_slice        <= cache2mstr_command(3 downto 0);
                
    sig_cmd_type_slice        <=  cmd2mstr_command(CMD_TYPE_INDEX);   -- always incrementing (per Interface_X guidelines)
    sig_cmd_addr_slice        <=  cmd2mstr_command(CMD_ADDR_MS_INDEX downto CMD_ADDR_LS_INDEX);  
    sig_cmd_tag_slice         <=  cmd2mstr_command(CMD_TAG_MS_INDEX downto CMD_TAG_LS_INDEX);
    sig_cmd_btt_slice         <=  cmd2mstr_command(CMD_BTT_MS_INDEX downto CMD_BTT_LS_INDEX);
    
    sig_cmd_dsa_slice         <=  cmd2mstr_command(CMD_DSA_MS_INDEX downto CMD_DSA_LS_INDEX);
    sig_cmd_drr_slice         <=  cmd2mstr_command(CMD_DRR_INDEX);
    sig_cmd_eof_slice         <=  cmd2mstr_command(CMD_EOF_INDEX);
     
     
     
    -- Check for a zero length BTT (error condition) 
    sig_btt_is_zero  <= '1'
      when  (sig_cmd_btt_slice = BTT_ZEROS)
      Else '0';
        
    sig_xfer_size <= SIZE_TO_USE;
    
    
    
    
    
    -----------------------------------------------------------------
    -- Reset fanout control
    -----------------------------------------------------------------
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_RESET_REG
    --
    -- Process Description:
    --  Registers the input reset to reduce fanout. This module
    --  has a high number of register bits to reset.
    --
    -------------------------------------------------------------
    IMP_RESET_REG : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
        
          sig_mmap_reset_reg <= mmap_reset;
        
        end if;       
      end process IMP_RESET_REG; 

    
    
    
    
    
    
    

    -----------------------------------------------------------------
    -- Input Parent command Register design
    
    sig_push_input_reg  <=  not(sig_psm_halt)    and
                            cmd2mstr_cmd_valid   and                          
                            sig_input_reg_empty  and 
                            not(sig_calc_error_reg);                                
     
    sig_pop_input_reg   <= sig_psm_pop_input_cmd;
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_INPUT_QUAL
    --
    -- Process Description:
    --  Implements the input command qualifier holding register
    -- used by the parent Command calculation.
    -------------------------------------------------------------

HIGH_STREAM_WIDTH_REG_GEN : if (C_STREAM_DWIDTH >= 128) generate     
begin     

    REG_INPUT_DUP_QUAL : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg  = '1' or
                sig_pop_input_reg   = '1') then
            
              sig_input_addr_reg1                <=  (others => '0');
              
            elsif (sig_push_input_reg = '1') then
              
              sig_input_addr_reg1                <=  sig_cmd_addr_slice;
            
            else
              null; -- Hold current State
            end if; 
         end if;       
       end process REG_INPUT_DUP_QUAL; 
     
end generate HIGH_STREAM_WIDTH_REG_GEN;


    REG_INPUT_QUAL : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg  = '1' or
                sig_pop_input_reg   = '1') then
            
              sig_input_cache_type_reg          <=  (others => '0');
              sig_input_user_type_reg           <=  (others => '0');
              sig_input_addr_reg                <=  (others => '0');
              sig_input_burst_type_reg          <=  '0';
              sig_input_tag_reg                 <=  (others => '0');
              sig_input_dsa_reg                 <=  (others => '0');
              sig_input_drr_reg                 <=  '0';
              sig_input_eof_reg                 <=  '0';
              
              sig_input_reg_empty               <=  '1';
              sig_input_reg_full                <=  '0';
            
            elsif (sig_push_input_reg = '1') then
              
              sig_input_cache_type_reg          <=  sig_cmd_cache_slice;
              sig_input_user_type_reg           <=  sig_cmd_user_slice;
              sig_input_addr_reg                <=  sig_cmd_addr_slice;
              sig_input_burst_type_reg          <=  sig_cmd_type_slice;
              sig_input_tag_reg                 <=  sig_cmd_tag_slice;
              sig_input_dsa_reg                 <=  sig_cmd_dsa_slice;
              sig_input_drr_reg                 <=  sig_cmd_drr_slice;
              sig_input_eof_reg                 <=  sig_cmd_eof_slice;
              
              sig_input_reg_empty               <=  '0';
              sig_input_reg_full                <=  '1';
            
            else
              null; -- Hold current State
            end if; 
         end if;       
       end process REG_INPUT_QUAL; 
   
    
    
    
    


   
    -------------------------------------------------------------------------
    -- SFCC Parent State machine Logic
    
   
   
   
   
    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: PARENT_SM_COMBINATIONAL
    --
    -- Process Description:
    -- SFCC Parent State Machine combinational implementation,
    -- This state machine controls the loading of commands into
    -- the Realigner block. There is a maximum of two cmds per  
    -- DataMover input command to be loaded in the realigner.
    --
    -------------------------------------------------------------
    PARENT_SM_COMBINATIONAL : process (sig_psm_state           ,
                                       sig_push_input_reg      ,
                                       sig_calc_error_reg      ,
                                       sig_first_realigner_cmd ,
                                       sig_skip_align2mbaa     ,
                                       sig_skip_align2mbaa_s_h ,
                                       sig_realign_reg_empty   ,
                                       sig_child_cmd_reg_full)  
       begin
    
         -- SM Defaults  
         sig_psm_state_ns                 <=  P_INIT;
         sig_psm_halt_ns                  <=  '0'   ; 
         sig_psm_pop_input_cmd_ns         <=  '0'   ;
         sig_psm_ld_calc1_ns              <=  '0'   ;
         sig_psm_ld_calc2_ns              <=  '0'   ;
         sig_psm_ld_realigner_reg_ns      <=  '0'   ;
         sig_psm_ld_chcmd_reg_ns          <=  '0'   ;
         
         
         
     
         case sig_psm_state is
           
           --------------------------------------------
           when P_INIT => 
             
             sig_psm_state_ns  <=  P_WAIT_FOR_CMD;
             sig_psm_halt_ns   <=  '1'; 
             
           --------------------------------------------
           when P_WAIT_FOR_CMD => 
             
             If (sig_push_input_reg = '1') Then
    
               sig_psm_state_ns            <=  P_LD_FIRST_CMD;
             
             else
             
               sig_psm_state_ns <=  P_WAIT_FOR_CMD;
             
             End if;
             

           
           --------------------------------------------
           when P_LD_FIRST_CMD => -- (load first Realigner Command)
           
             If  (sig_realign_reg_empty = '1') Then
    
               sig_psm_state_ns            <=  P_LD_CHILD_CMD; --EXTRA;
               sig_psm_ld_realigner_reg_ns <= '1';
               sig_psm_ld_calc1_ns         <= '1';
             
             else
             
               sig_psm_state_ns <=  P_LD_FIRST_CMD;
             
             End if;
          
   --       when EXTRA =>
   --            sig_psm_state_ns            <=  P_LD_CHILD_CMD;
   --            sig_psm_ld_realigner_reg_ns <= '1';
   --            sig_psm_ld_calc1_ns         <= '1';
 
          
          --------------------------------------------
           when P_LD_CHILD_CMD => -- (load Child Command Register)
           
             If  (sig_child_cmd_reg_full = '1') Then
             
               sig_psm_state_ns         <=  P_LD_CHILD_CMD;
             
             
             Elsif (sig_calc_error_reg = '1') Then
    
               sig_psm_state_ns                 <=  P_ERROR_TRAP;
               sig_psm_ld_chcmd_reg_ns          <= '1' ;
             
             
             Elsif ((sig_skip_align2mbaa    = '1'  and
                    sig_first_realigner_cmd = '1') or
                    sig_skip_align2mbaa_s_h = '1') Then
             
               sig_psm_state_ns         <=  P_WAIT_FOR_CMD;
               sig_psm_ld_chcmd_reg_ns  <= '1' ;
               sig_psm_pop_input_cmd_ns <= '1' ;
             
             else
             
               sig_psm_state_ns         <=  P_LD_LAST_CMD;
               sig_psm_ld_chcmd_reg_ns  <= '1';
             
             End if;
           
           
           --------------------------------------------
           when P_LD_LAST_CMD => -- (load second Realigner Command if needed)
           
             If (sig_realign_reg_empty = '1') Then
             
               sig_psm_state_ns            <=  P_WAIT_FOR_CMD; --EXTRA2;
               sig_psm_ld_realigner_reg_ns <= '1' ;
               sig_psm_ld_calc2_ns         <= '1' ;
               sig_psm_pop_input_cmd_ns    <= '1' ;
             
             else
             
               sig_psm_state_ns            <=  P_LD_LAST_CMD;
             
             End if;
           
--           when EXTRA2 =>
 
--               sig_psm_state_ns            <=  P_WAIT_FOR_CMD;
--               sig_psm_ld_realigner_reg_ns <= '1' ;
--               sig_psm_ld_calc2_ns         <= '1' ;
--               sig_psm_pop_input_cmd_ns    <= '1' ;
           --------------------------------------------
           when P_ERROR_TRAP =>
           
             sig_psm_state_ns <=  P_ERROR_TRAP;
             sig_psm_halt_ns  <=  '1'; 
           
           --------------------------------------------
           when others =>
           
             sig_psm_state_ns <=  P_INIT;
             
         end case;
         

    
       end process PARENT_SM_COMBINATIONAL; 
    
      
  
     
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: SFCC_SM_REGISTERED
    --
    -- Process Description:
    -- SFCC State Machine registered implementation
    --
    -------------------------------------------------------------
    SFCC_SM_REGISTERED : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
            
              sig_psm_state                     <= P_INIT;
              sig_psm_halt                      <= '1' ; 
              sig_psm_pop_input_cmd             <= '0' ;
              sig_psm_ld_calc1                  <= '0' ;
              sig_psm_ld_calc2                  <= '0' ;
              sig_psm_ld_realigner_reg          <= '0' ;
              sig_psm_ld_chcmd_reg              <= '0' ;
            
            else
            
              sig_psm_state                     <=  sig_psm_state_ns                ;
              sig_psm_halt                      <=  sig_psm_halt_ns                 ; 
              sig_psm_pop_input_cmd             <=  sig_psm_pop_input_cmd_ns        ;
              sig_psm_ld_calc1                  <=  sig_psm_ld_calc1_ns             ;
              sig_psm_ld_calc2                  <=  sig_psm_ld_calc2_ns             ;
              sig_psm_ld_realigner_reg          <=  sig_psm_ld_realigner_reg_ns     ;
              sig_psm_ld_chcmd_reg              <=  sig_psm_ld_chcmd_reg_ns         ;
            
            end if; 
         end if;       
       end process SFCC_SM_REGISTERED; 
        
     
     
     
 
 
 
   
   
    
       
     -------------------------------------------------------------
     -- Synchronous Process with Sync Reset
     --
     -- Label: IMP_FIRST_REALIGNER_CMD
     --
     -- Process Description:
     --  Implements the register flop signalling the first realigner 
     -- transfer flag. The Realigner is loaded with 1 command if 
     -- the starting address is aligned to the mbaa, else two
     -- commands are required.
     --
     -------------------------------------------------------------
     IMP_FIRST_REALIGNER_CMD : process (primary_aclk)
        begin
          if (primary_aclk'event and primary_aclk = '1') then
             if (sig_mmap_reset_reg        = '1' or
                 (sig_psm_ld_realigner_reg = '1' and
                  sig_push_input_reg       = '0')) then

               sig_first_realigner_cmd <= '0';
               
             elsif (sig_push_input_reg = '1') then

               sig_first_realigner_cmd <= '1';
               
             else
               null;  -- hold current state
             end if; 
          end if;       
        end process IMP_FIRST_REALIGNER_CMD; 
    






    
    
   --------------------------------------------------------------
   -- Parent BTT Counter Logic (for Realigner cmd calc)
   
   
   sig_ld_btt_cntr   <= sig_push_input_reg;
   
   sig_decr_btt_cntr <= sig_push_realign_reg;
   
                                               
   -- Rip the BTT residue field from the BTT counter value
   sig_btt_residue_slice   <=  sig_btt_cntr(BTT_RESIDUE_WIDTH-1 downto 0);
      
      
   
   
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_BTT_CNTR
   --
   -- Process Description:
   -- Bytes to transfer counter implementation. This is only used
   -- to set up the Realigner commands.
   --
   -------------------------------------------------------------
   IMP_BTT_CNTR : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (sig_mmap_reset_reg = '1') then
             
             sig_btt_cntr <= (others => '0');
           
           elsif (sig_ld_btt_cntr = '1') then
             
             sig_btt_cntr <= UNSIGNED(sig_cmd_btt_slice);
           
           Elsif (sig_decr_btt_cntr = '1') Then
             
             sig_btt_cntr <= sig_btt_cntr-UNSIGNED(sig_realigner_btt2);
           
           else
             null;  -- hold current state
           end if; 
        end if;       
      end process IMP_BTT_CNTR; 
  
 
   IMP_BTT_CNTR2 : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (sig_mmap_reset_reg = '1') then
             
             sig_realigner_btt2 <= (others => '0');
           
           Else
             
             sig_realigner_btt2 <= sig_realigner_btt;
           
           end if; 
        end if;       
      end process IMP_BTT_CNTR2; 
       
 
 
 
  
   
    -- Convert to logic vector for the S2MM DRE use
    -- The DRE will only use this value prior to the first 
    -- decrement of the BTT Counter. Using this saves a separate
    -- BTT register.
    --     sig_realigner_btt <=  STD_LOGIC_VECTOR(RESIZE(sig_child_addr_cntr_incr, CMD_BTT_WIDTH))
    sig_realigner_btt <=  STD_LOGIC_VECTOR(sig_realign_btt_cntr_decr)
      when (sig_first_realigner_cmd = '1' and 
            sig_skip_align2mbaa     = '0')
      else STD_LOGIC_VECTOR(sig_btt_cntr);
 
 
 
    
    
     
     ----------------- Parent Address Calculations ------------------------------
HIGH_STREAM_WIDTH : if (C_STREAM_DWIDTH >= 128) generate     
begin     
    sig_mbaa_addr_cntr_slice <= UNSIGNED(sig_input_addr_reg1(MBAA_ADDR_SLICE_WIDTH-1 downto 0)); 

end generate HIGH_STREAM_WIDTH;    


LOW_STREAM_WIDTH : if (C_STREAM_DWIDTH < 128) generate     
begin     
    sig_mbaa_addr_cntr_slice <= UNSIGNED(sig_input_addr_reg(MBAA_ADDR_SLICE_WIDTH-1 downto 0)); 

end generate LOW_STREAM_WIDTH;    
    
    -- Check to see if the starting address is already aligned to Max Burst byte aligned
    -- boubdary
    sig_addr_aligned <= '1'
      when (sig_mbaa_addr_cntr_slice = BTT_RESIDUE_0)
      Else '0';
    
    
    
    -- Calculate the distance in bytes from the starting address to the next max
    -- burst aligned address boundary
    sig_bytes_to_mbaa <= TO_UNSIGNED(BYTES_PER_MAX_BURST, ADDR_CNTR_WIDTH) 
    When (sig_addr_aligned = '1')
    else TO_UNSIGNED(BYTES_PER_MAX_BURST, ADDR_CNTR_WIDTH) -
                     RESIZE(sig_mbaa_addr_cntr_slice,ADDR_CNTR_WIDTH);
    
    
    
    
    sig_btt_upper_slice <= sig_btt_cntr(BTT_UPPER_MS_INDEX downto BTT_UPPER_LS_INDEX);
    
    
 
    sig_btt_upper_eq_0 <= '1'
      When (sig_btt_upper_slice = BTT_UPPER_ZERO) or
           (BTT_RESIDUE_WIDTH = CMD_BTT_WIDTH)
      Else '0';
 
 
    
    sig_btt_lt_b2mbaa <= '1'
      when ((RESIZE(sig_btt_residue_slice, ADDR_CNTR_WIDTH) < sig_bytes_to_mbaa) and
            (sig_first_realigner_cmd = '1') and
            (sig_btt_upper_eq_0      = '1')) 
      Else '0';
    


    
    sig_btt_eq_b2mbaa <= '1'
      when ((RESIZE(sig_btt_residue_slice, ADDR_CNTR_WIDTH) = sig_bytes_to_mbaa) and
            (sig_first_realigner_cmd = '1') and
            (sig_btt_upper_eq_0      = '1'))
      Else '0';


    
    
    
    -- This signal used to flag if the SFCC can skip the initial split and 
    -- align process to get subsequent burst starting addresses aligned to 
    -- the Max burst aligned address boundary (needed to support the 4k byte
    -- boundary crossing guard function).
    sig_skip_align2mbaa <= '1'
      when (sig_addr_aligned        = '1' or
            sig_btt_lt_b2mbaa       = '1' or
            sig_btt_eq_b2mbaa       = '1' or
            sig_calc_error_reg      = '1')
      Else '0';
    
    
   
   
   
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: SKIP_ALIGN_FLOP
    --
    -- Process Description:
    --  Just a FLOP to sample and hold the flag indicating that a 
    -- aligment to a Max Burst align address is not required. This
    -- is used by the parent command state machine.
    --
    -------------------------------------------------------------
    SKIP_ALIGN_FLOP : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (sig_mmap_reset_reg       = '1' or
               (sig_psm_ld_chcmd_reg    = '1' and
               sig_psm_ld_realigner_reg = '0')) then
    
             sig_skip_align2mbaa_s_h <= '0';
    
           elsif (sig_psm_ld_realigner_reg = '1') then
    
             sig_skip_align2mbaa_s_h <= sig_skip_align2mbaa;
    
           else
    
             null;  -- Hold current state
    
           end if; 
        end if;       
      end process SKIP_ALIGN_FLOP; 
   
   
   
   
    
                                        
    
    -- Select the Realigner BTT counter decrement value to use
    sig_realign_btt_cntr_decr <= RESIZE(sig_btt_residue_slice, CMD_BTT_WIDTH)
      When (sig_first_realigner_cmd = '1' and
           (sig_btt_lt_b2mbaa       = '1' or
            sig_btt_eq_b2mbaa       = '1'))
      else RESIZE(sig_bytes_to_mbaa, CMD_BTT_WIDTH)
      when (sig_first_realigner_cmd = '1' and 
            sig_skip_align2mbaa     = '0')
      else sig_btt_cntr;  
                                                                

  
  
 

 
 
     
 
 
 
     -----------------------------------------------------------------
     -- Realigner Qualifier Register design
     
     
     sig_dre_dest_align <= sig_input_addr_reg(C_DRE_ALIGN_WIDTH-1 downto 0)
       When (sig_psm_ld_calc1 = '1') -- Specified starting addr offset
       Else (others => '0');         -- Second command is always aligned to addr offset 0
     
     
     
     sig_realign_strt_offset <= sig_input_addr_reg(SF_OFFSET_MS_INDEX downto SF_OFFSET_LS_INDEX)
       When (sig_psm_ld_calc1 = '1') -- Specified starting addr offset used for IBTT Upsizer
       Else (others => '0');         -- Second command is always aligned to addr offset 0
     
     
     sig_cmd2dre_valid      <= sig_realign_reg_full;  
     
     sig_push_realign_reg   <= sig_psm_ld_realigner_reg;    -- a clock of latency
    
     sig_pop_realign_reg    <= sig_cmd2dre_valid  and 
                               dre2mstr_cmd_ready;       -- Realigner taking xfer
    


     -------------------------------------------------------------
     -- Synchronous Process with Sync Reset
     --
     -- Label: REG_REALIGNER_QUAL
     --
     -- Process Description:
     --  Implements the output Realigner qualifier holding register 
     -- for the Realigner Block used with the Store and Forward
     -- module.
     --
     -------------------------------------------------------------
     REG_REALIGNER_QUAL : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
           if (sig_mmap_reset_reg   = '1' or
              (sig_pop_realign_reg  = '1' and
               sig_push_realign_reg = '0')) then
           
             sig_realign_tag_reg         <=  (others => '0');
             sig_realign_src_align_reg   <=  (others => '0');
             sig_realign_dest_align_reg  <=  (others => '0');
             sig_realign_btt_reg         <=  (others => '0');
             sig_realign_drr_reg         <=  '0';
             sig_realign_eof_reg         <=  '0';
             sig_realign_cmd_cmplt_reg   <=  '0';
             sig_realign_calc_err_reg    <=  '0';
             sig_realign_strt_offset_reg <=  (others => '0');
                                                 
             
             sig_realign_reg_empty       <=  '1';
             sig_realign_reg_full        <=  '0';
           
           elsif (sig_push_realign_reg = '1') then
             
             sig_realign_tag_reg         <=  sig_input_tag_reg        ;
             sig_realign_src_align_reg   <=  sig_input_dsa_reg(C_DRE_ALIGN_WIDTH-1 downto 0);
             sig_realign_dest_align_reg  <=  sig_dre_dest_align       ;
             sig_realign_btt_reg         <=  sig_realigner_btt2        ;
             sig_realign_drr_reg         <=  sig_input_drr_reg and
                                             sig_first_realigner_cmd  ;
             
             sig_realign_eof_reg         <=  (sig_input_eof_reg         and 
                                              sig_skip_align2mbaa       and 
                                              sig_first_realigner_cmd)  or
                                             (sig_input_eof_reg         and
                                              not(sig_first_realigner_cmd)); 
             
             sig_realign_cmd_cmplt_reg   <=  (sig_skip_align2mbaa          and 
                                              sig_first_realigner_cmd)     or
                                              not(sig_first_realigner_cmd) or
                                              sig_calc_error_reg       ;
             sig_realign_calc_err_reg    <=  sig_calc_error_reg        ;
             
             sig_realign_strt_offset_reg <=  sig_realign_strt_offset;
   
             
             sig_realign_reg_empty       <=  '0';
             sig_realign_reg_full        <=  '1';
                        
           else
             null; -- Hold current State
           end if; 
         end if;       
       end process REG_REALIGNER_QUAL; 
   
     
     


 
 
  ----------------------------------------------------------------------
  -- Parent Calculation Error Logic




    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_CALC_ERROR_FLOP
    --
    -- Process Description:
    --   Implements the flop for the Calc Error flag, Once set,
    -- the flag cannot be cleared until a reset is issued.
    --
    -------------------------------------------------------------
    IMP_CALC_ERROR_FLOP : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
              sig_calc_error_reg <= '0';
            elsif (sig_push_input_reg = '1' and
                   sig_calc_error_reg = '0') then
              sig_calc_error_reg <= sig_btt_is_zero;
            else
              Null;  -- hold the current state
            end if; 
         end if;       
       end process IMP_CALC_ERROR_FLOP; 
    
    
    








   
    -----------------------------------------------------------------
    -- Child transfer command register design
   
    
    sig_push_child_cmd_reg  <=  sig_psm_ld_chcmd_reg;                                
     
    sig_pop_child_cmd_reg   <= sig_csm_pop_child_cmd;
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CHILD_CMD_REG
    --
    -- Process Description:
    --  Implements the Child command holding register
    --  loaded by the Parent State Machine. This is a
    --  1 deep fifo-like command queue.
    -------------------------------------------------------------
    CHILD_CMD_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg    = '1' or
                sig_pop_child_cmd_reg = '1') then
            
              sig_child_tag_reg                 <=  (others => '0');
              sig_child_addr_reg                <=  (others => '0');
              sig_child_burst_type_reg          <=  '0';
              sig_child_cache_type_reg          <=  (others => '0');
              sig_child_user_type_reg          <=  (others => '0');
              sig_needed_2_realign_cmds         <=  '0';
              sig_child_error_reg               <=  '0';
              
              sig_child_cmd_reg_empty           <=  '1';
              sig_child_cmd_reg_full            <=  '0';
            
            elsif (sig_push_child_cmd_reg = '1') then
              
              sig_child_tag_reg                 <=  sig_input_tag_reg ;
              sig_child_addr_reg                <=  sig_input_addr_reg;
              sig_child_burst_type_reg          <=  sig_input_burst_type_reg;
              sig_child_cache_type_reg          <=  sig_input_cache_type_reg;
              sig_child_user_type_reg          <=  sig_input_user_type_reg;
              sig_needed_2_realign_cmds         <=  not(sig_skip_align2mbaa_s_h);
              sig_child_error_reg               <=  sig_calc_error_reg;
              
              sig_child_cmd_reg_empty           <=  '0';
              sig_child_cmd_reg_full            <=  '1';
            
            else
              null; -- Hold current State
            end if; 
         end if;       
       end process CHILD_CMD_REG; 
   
    
    
 
 
 
    sig_ld_child_qual_reg  <= sig_pop_child_cmd_reg;
 
 
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CHILD_QUAL_REG
    --
    -- Process Description:
    --  Implements the child intermediate command qualifier holding 
    -- register. 
    --  
    -------------------------------------------------------------
    CHILD_QUAL_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
            
              sig_child_qual_tag_reg      <=  (others => '0');
              sig_child_qual_burst_type   <=  '0';
              sig_child_qual_cache_type   <=  (others => '0');
              sig_child_qual_user_type   <=  (others => '0');
              sig_child_qual_error_reg    <= '0';
              
            
            elsif (sig_ld_child_qual_reg = '1') then
              
              sig_child_qual_tag_reg      <=  sig_child_tag_reg        ;
              sig_child_qual_burst_type   <=  sig_child_burst_type_reg ;
              sig_child_qual_cache_type   <=  sig_child_cache_type_reg ;
              sig_child_qual_user_type   <=  sig_child_user_type_reg ;
              sig_child_qual_error_reg    <=  sig_child_error_reg;
              
            
            else
              null; -- Hold current State
            end if; 
         end if;       
       end process CHILD_QUAL_REG; 
   
    
    
    
    
    
    
    
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CHILD_QUAL_DBL_CMD_REG
    --
    -- Process Description:
    --  Implements the child intermediate command qualifier holding 
    -- register. 
    --  
    -------------------------------------------------------------
    CHILD_QUAL_DBL_CMD_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg   = '1' or
               (sig_csm_pop_sf_fifo  = '1' and
                sig_sf2pcc_cmd_cmplt = '1')) then
            
              sig_child_qual_first_of_2  <=  '0';
              
            
            elsif (sig_ld_child_qual_reg = '1') then
              
              sig_child_qual_first_of_2  <=  sig_needed_2_realign_cmds;
              
            
            else
              null; -- Hold current State
            end if; 
         end if;       
       end process CHILD_QUAL_DBL_CMD_REG; 
   
    
    
 
 
 
    ------------------------------------------------------------------
    -- Data and Address Controller Transfer Register Load Enable logic
   
    sig_last_s_f_xfer_ld  <= sig_push_xfer_reg and 
                             sig_sf2pcc_cmd_cmplt;
    
    
 
 
 
 
    -------------------------------------------------------------------------
    -- SFCC Child State machine Logic
    
   
   
   
   
   
    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: CHILD_STATE_MACHINE_COMB
    --
    -- Process Description:
    --  Implements the combinational portion of the Child Command 
    -- processing state machine.
    --
    -------------------------------------------------------------
    CHILD_STATE_MACHINE_COMB : process (sig_csm_state             ,
                                        sig_child_cmd_reg_full    ,
                                        sig_sf2pcc_xfer_valid     ,
                                        sig_child_error_reg       ,
                                        sig_cmd2data_valid        ,
                                        sig_cmd2addr_valid        ,
                                        sig_child_qual_first_of_2 ,
                                        sig_sf2pcc_cmd_cmplt      ,
                                        sig_sf2pcc_packet_eop)
       begin
    
         
         -- Set defaults
         sig_csm_state_ns          <= CH_INIT;
         sig_csm_ld_xfer_ns        <= '0';
         sig_csm_pop_sf_fifo_ns    <= '0';
         sig_csm_pop_child_cmd_ns  <= '0';
         
         

         case sig_csm_state is
           -----------------------------------------------------
           when CH_INIT =>
           
             sig_csm_state_ns <= WAIT_FOR_PCMD;
           
           
           -----------------------------------------------------
           when WAIT_FOR_PCMD =>
           
             If (sig_child_error_reg    = '1' and
                 sig_child_cmd_reg_full = '1') Then
    
               sig_csm_state_ns          <= CH_ERROR_TRAP1;
               sig_csm_pop_child_cmd_ns  <= '1';
             
             
             elsif (sig_child_cmd_reg_full = '1') Then
    
               sig_csm_state_ns          <= CH_WAIT_FOR_SF_CMD;
               sig_csm_pop_child_cmd_ns  <= '1';
             
             
             Else 
             
               sig_csm_state_ns <= WAIT_FOR_PCMD;
             
             End if;
           
                     
           -----------------------------------------------------
           when CH_WAIT_FOR_SF_CMD =>
           
             If (sig_sf2pcc_xfer_valid = '1') Then
    
               sig_csm_state_ns       <= CH_LD_CHILD_CMD;
             
             Else 
             
               sig_csm_state_ns <= CH_WAIT_FOR_SF_CMD;
             
             End if;
           
           
           
           -----------------------------------------------------
           when CH_LD_CHILD_CMD =>
           
             If (sig_cmd2data_valid    = '0' and
                 sig_cmd2addr_valid    = '0') Then
    
               sig_csm_state_ns       <= CH_CHK_IF_DONE;
               sig_csm_ld_xfer_ns     <= '1';
               sig_csm_pop_sf_fifo_ns <= '1';
             
             Else 
             
               sig_csm_state_ns <= CH_LD_CHILD_CMD;
             
             End if;
           
           
           
           -----------------------------------------------------
           when CH_CHK_IF_DONE =>
              
             If (sig_sf2pcc_cmd_cmplt      = '1' and
                (sig_child_qual_first_of_2 = '0' or
                 sig_sf2pcc_packet_eop     = '1')) Then  -- done
                
                sig_csm_state_ns          <= WAIT_FOR_PCMD;
                
              else  -- more SF child commands coming from the parent command
              
                sig_csm_state_ns <= CH_WAIT_FOR_SF_CMD;
              
              end if;
              
     
           
           -----------------------------------------------------
           when CH_ERROR_TRAP1 =>
           
             
             If (sig_cmd2data_valid    = '0' and
                 sig_cmd2addr_valid    = '0') Then
    
               sig_csm_state_ns          <= CH_ERROR_TRAP2;
               sig_csm_ld_xfer_ns        <= '1';
             
             Else 

               sig_csm_state_ns       <= CH_ERROR_TRAP1;
             
             
             End if;
              
   
     
           
           -----------------------------------------------------
           when CH_ERROR_TRAP2 =>
           
             sig_csm_state_ns       <= CH_ERROR_TRAP2;
              
     
           
           -----------------------------------------------------
           when others =>
           
             sig_csm_state_ns       <= CH_INIT;
           
           
         end case;
         


    
       end process CHILD_STATE_MACHINE_COMB; 
    
   
   
   
   
   
   
   
   
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CHILD_SM_REGISTERED
    --
    -- Process Description:
    -- Child State Machine registered implementation
    --
    -------------------------------------------------------------
    CHILD_SM_REGISTERED : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
            
              sig_csm_state              <= CH_INIT;
              sig_csm_ld_xfer            <= '0'    ;
              sig_csm_pop_sf_fifo        <= '0'    ;
              sig_csm_pop_child_cmd      <= '0'    ;
              
            else
            
              sig_csm_state              <=  sig_csm_state_ns          ;
              sig_csm_ld_xfer            <=  sig_csm_ld_xfer_ns        ;
              sig_csm_pop_sf_fifo        <=  sig_csm_pop_sf_fifo_ns    ;
              sig_csm_pop_child_cmd      <=  sig_csm_pop_child_cmd_ns  ;
            
            end if; 
         end if;       
       end process CHILD_SM_REGISTERED; 
        
     
     
     
 
 
 
 
 
 
 
 
 
 
 
 
 
    ----------------------------------------------------------------------------------------------------
    ----------------------------------------------------------------------------------------------------
    --
    -- General Address Counter Logic (applies to any address width of 32 or greater
    -- The address counter is divided into 2 16-bit segements for 32-bit address support. As the
    -- address gets wider, up to 2 more segements will be added via IfGens to provide for 64-bit 
    -- addressing.
    --
    ----------------------------------------------------------------------------------------------------
    


    --------------------------------------------------------------------------
    -- Address Counter logic
    
    sig_ld_child_addr_cntr   <= sig_ld_child_qual_reg;
    
    -- don't increment address cntr if type is '0' (non-incrementing)
    sig_incr_child_addr_cntr <= sig_push_xfer_reg and 
                                sig_child_qual_burst_type;  
    
    
    

    -- Unaligned address compensation
    -- Add the number of starting address offset byte positions to the
    -- final byte change value needed to calculate the AXI LEN field

    sig_start_addr_offset_slice <=  sig_child_addr_cntr_lsh(DBEAT_RESIDUE_WIDTH-1 downto 0);

    sig_adjusted_addr_incr      <=  RESIZE(UNSIGNED(sig_sf2pcc_xfer_bytes), ADDR_CNTR_WIDTH) +
                                    RESIZE(sig_start_addr_offset_slice, ADDR_CNTR_WIDTH);


    
    
    -- Select the address counter increment value to use
    sig_child_addr_cntr_incr <= RESIZE(UNSIGNED(sig_sf2pcc_xfer_bytes), ADDR_CNTR_WIDTH);  -- bytes received value plus the addr
                                                                                           -- offset.
                                                                                           

   
    -- adjust the address increment down by 1 byte to compensate
    -- for the LEN requirement of being N-1 data beats
    sig_byte_change_minus1 <=  sig_adjusted_addr_incr-ADDR_CNTR_ONE;


    

    -- Rip the new transfer length value
    sig_xfer_len <=  STD_LOGIC_VECTOR(
                         RESIZE(
                            sig_byte_change_minus1(BTT_RESIDUE_WIDTH-1 downto 
                                                   DBEAT_RESIDUE_WIDTH), 
                         LEN_WIDTH)
                     );
    


    
    -- calculate the next starting address after the current 
    -- xfer completes
    sig_predict_child_addr_lsh     <=  sig_child_addr_cntr_lsh + sig_child_addr_cntr_incr;
    sig_predict_child_addr_lsh_slv <= STD_LOGIC_VECTOR(sig_predict_child_addr_lsh);
    
    
    sig_child_addr_cntr_lsh_slv    <= STD_LOGIC_VECTOR(sig_child_addr_cntr_lsh);
    
    
    -- Determine if an address count lsh rollover is going to occur when 
    -- jumping to the next starting address by comparing the MS bit of the
    -- current address lsh to the MS bit of the predicted address lsh . 
    -- A transition of a '1' to a '0' is a rollover.
    sig_child_addr_lsh_rollover <= '1'
      when (
            (sig_child_addr_cntr_lsh_slv(ADDR_CNTR_WIDTH-1)    = '1') and
            (sig_predict_child_addr_lsh_slv(ADDR_CNTR_WIDTH-1) = '0')
           )
      Else '0';
    
    
    
   --  sig_child_addr_msh_eq_max <= '1'
   --     when (sig_child_addr_cntr_msh = ADDR_CNTR_MAX_VALUE)
   --     Else '0';
    
    
    -- sig_child_addr_msh_rollover <= sig_child_addr_msh_eq_max and 
    --                                sig_child_addr_lsh_rollover;
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_ADDR_STUFF
    --
    -- Process Description:
    --  Implements a general register for address counter related 
    -- things.
    --
    -------------------------------------------------------------
    REG_ADDR_STUFF : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
              
              sig_child_addr_lsh_rollover_reg  <= '0';
              --sig_child_addr_msh_rollover_reg  <= '0';
              --sig_child_addr_msh_eq_max_reg    <= '0';
              --sig_adjusted_child_addr_incr_reg <= (others => '0');
            
            else
              
              sig_child_addr_lsh_rollover_reg  <= sig_child_addr_lsh_rollover ;
              --sig_child_addr_msh_rollover_reg  <= sig_child_addr_msh_rollover ;
              --sig_child_addr_msh_eq_max_reg    <= sig_child_addr_msh_eq_max   ; 
              --sig_adjusted_child_addr_incr_reg <= sig_adjusted_addr_incr;
              
            end if; 
         end if;       
       end process REG_ADDR_STUFF; 
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_LSH_ADDR_CNTR
    --
    -- Process Description:
    -- Least Significant Half Address counter implementation. 
    --
    -------------------------------------------------------------
    IMP_LSH_ADDR_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
              
              sig_child_addr_cntr_lsh <= (others => '0');
            
            elsif (sig_ld_child_addr_cntr = '1') then
              
              sig_child_addr_cntr_lsh <= UNSIGNED(sig_child_addr_reg(ADDR_CNTR_WIDTH-1 downto 0));
            
            Elsif (sig_incr_child_addr_cntr = '1') Then
              
              sig_child_addr_cntr_lsh <= sig_predict_child_addr_lsh;
            
            else
              null;  -- hold current state
            end if; 
         end if;       
       end process IMP_LSH_ADDR_CNTR; 
   
   
 
  
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_MSH_ADDR_CNTR
    --
    -- Process Description:
    -- Least Significant Half Address counter implementation. 
    --
    -------------------------------------------------------------
    IMP_MSH_ADDR_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1') then
              
              sig_child_addr_cntr_msh <= (others => '0');
            
            elsif (sig_ld_child_addr_cntr = '1') then
              
              sig_child_addr_cntr_msh <= UNSIGNED(sig_child_addr_reg((2*ADDR_CNTR_WIDTH)-1 downto 
                                                                     ADDR_CNTR_WIDTH));
            
            Elsif (sig_incr_child_addr_cntr        = '1' and
                   sig_child_addr_lsh_rollover_reg = '1') Then
              
              sig_child_addr_cntr_msh <= sig_child_addr_cntr_msh+ADDR_CNTR_ONE;
            
            else
              null;  -- hold current state
            end if; 
         end if;       
       end process IMP_MSH_ADDR_CNTR; 
   
   
 
   
   
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_FIRST_XFER_FLOP
   --
   -- Process Description:
   --  Implements the register flop for the first transfer flag.
   --
   -------------------------------------------------------------
   IMP_FIRST_XFER_FLOP : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (sig_mmap_reset_reg       = '1' or
               sig_incr_child_addr_cntr = '1') then

             sig_first_child_xfer <= '0';
             
           elsif (sig_ld_child_addr_cntr = '1') then

             sig_first_child_xfer <= '1';
             
           else
             null;  -- hold current state
           end if; 
        end if;       
      end process IMP_FIRST_XFER_FLOP; 
  
  
  

  
     
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ADDR_32
    --
    -- If Generate Description:
    -- Implements the Address segment merge logic for the 32-bit
    -- address width case. The address counter segments are split 
    -- into two 16-bit sections to improve Fmax convergence.
    --
    --
    ------------------------------------------------------------
    GEN_ADDR_32 : if (C_ADDR_WIDTH = 32) generate
    
    
       begin
    
         
         -- Populate the transfer address value by concatonating the 
         -- address counter segments
         sig_xfer_address <= STD_LOGIC_VECTOR(sig_child_addr_cntr_msh) &
                             STD_LOGIC_VECTOR(sig_child_addr_cntr_lsh); 
         
         
         
       end generate GEN_ADDR_32;
    
    
    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ADDR_GT_32_LE_48
    --
    -- If Generate Description:
    -- Implements the additional Address Counter logic for the case 
    -- when the address width is greater than 32 bits and less than
    -- or equal to 48 bits. In this case, an additional counter segment
    -- is implemented (segment 3) that is variable width of 1
    -- to 16 bits.
    --
    ------------------------------------------------------------
    GEN_ADDR_GT_32_LE_48 : if (C_ADDR_WIDTH  > 32 and
                               C_ADDR_WIDTH <= 48) generate


      -- Local constants
      Constant ACNTR_SEG3_WIDTH    : integer  := C_ADDR_WIDTH-32;
      Constant ACNTR_SEG3_ONE      : unsigned := TO_UNSIGNED(1, ACNTR_SEG3_WIDTH);
      Constant ACNTR_MSH_MAX       : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '1');
      
      Constant SEG3_ADDR_RIP_MS_INDEX : integer := C_ADDR_WIDTH-1;
      Constant SEG3_ADDR_RIP_LS_INDEX : integer := 32;
      
      
      -- Local Signals
      signal lsig_seg3_addr_cntr       : unsigned(ACNTR_SEG3_WIDTH-1 downto 0) := (others => '0');
      signal lsig_acntr_msh_eq_max     : std_logic := '0';
      signal lsig_acntr_msh_eq_max_reg : std_logic := '0';
       
       
      begin

      
      
        -- Populate the transfer address value by concatonating the
        -- 3 address counter segments
        sig_xfer_address     <= STD_LOGIC_VECTOR(lsig_seg3_addr_cntr  ) &
                                STD_LOGIC_VECTOR(sig_child_addr_cntr_msh) &
                                STD_LOGIC_VECTOR(sig_child_addr_cntr_lsh);


       
        
        -- See if the MSH (Segment 2) of the Adress Counter is at a max value
        lsig_acntr_msh_eq_max <= '1'
          when (sig_child_addr_cntr_msh = ACNTR_MSH_MAX)
          Else '0';


  
        
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_SEG2_EQ_MAX_REG
        --
        -- Process Description:
        --  Implements a register for the flag indicating the address
        -- counter MSH (Segment 2) is at max value and will rollover
        -- at the next increment interval for the counter. Registering 
        -- this signal and using it for the Seg 3 increment logic only
        -- works because there is always at least a 1 clock time gap 
        -- between the increment causing the segment 2 counter to go to 
        -- max and the next increment operation that can bump segment 3. 
        --
        -------------------------------------------------------------
        IMP_SEG2_EQ_MAX_REG : process (primary_aclk)
          begin
            if (primary_aclk'event and primary_aclk = '1') then
               if (sig_mmap_reset_reg = '1') then
        
                 lsig_acntr_msh_eq_max_reg <= '0';
        
               else
        
                 lsig_acntr_msh_eq_max_reg <= lsig_acntr_msh_eq_max;
        
               end if; 
            end if;       
          end process IMP_SEG2_EQ_MAX_REG; 
  
        
        
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_SEG3_ADDR_CNTR
        --
        -- Process Description:
        -- Segment 3 of the Address counter implementation.
        --
        -------------------------------------------------------------
        IMP_SEG3_ADDR_CNTR : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (sig_mmap_reset_reg = '1') then

                  lsig_seg3_addr_cntr <= (others => '0');

                elsif (sig_ld_child_addr_cntr = '1') then

                  lsig_seg3_addr_cntr <= UNSIGNED(sig_child_addr_reg(SEG3_ADDR_RIP_MS_INDEX downto 
                                                                     SEG3_ADDR_RIP_LS_INDEX));

                Elsif (sig_incr_child_addr_cntr    = '1' and
                       sig_child_addr_lsh_rollover = '1' and
                       lsig_acntr_msh_eq_max_reg   = '1') then

                  lsig_seg3_addr_cntr <= lsig_seg3_addr_cntr+ACNTR_SEG3_ONE;

                else
                  null;  -- hold current state
                end if;
             end if;
           end process IMP_SEG3_ADDR_CNTR;



  
  
      end generate GEN_ADDR_GT_32_LE_48;



     
     
     
     
     
     
     
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ADDR_GT_48
    --
    -- If Generate Description:
    -- Implements the additional Address Counter logic for the case 
    -- when the address width is greater than 48 bits and less than
    -- or equal to 64. In this case, an additional 2 counter segments
    -- are implemented (segment 3 and 4). Segment 3 is a fixed 16-bits
    -- and segment 4 is variable width of 1 to 16 bits.
    --
    ------------------------------------------------------------
    GEN_ADDR_GT_48 : if (C_ADDR_WIDTH  > 48) generate


      -- Local constants
      Constant ACNTR_SEG3_WIDTH    : integer  := ADDR_CNTR_WIDTH;
      Constant ACNTR_SEG3_ONE      : unsigned := TO_UNSIGNED(1, ACNTR_SEG3_WIDTH);
      Constant ACNTR_SEG3_MAX      : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '1');
      
      Constant ACNTR_MSH_MAX       : unsigned(ADDR_CNTR_WIDTH-1 downto 0) := (others => '1');
      
      
      Constant ACNTR_SEG4_WIDTH    : integer  := C_ADDR_WIDTH-48;
      Constant ACNTR_SEG4_ONE      : unsigned := TO_UNSIGNED(1, ACNTR_SEG4_WIDTH);
      
      
      Constant SEG3_ADDR_RIP_MS_INDEX : integer := 47;
      Constant SEG3_ADDR_RIP_LS_INDEX : integer := 32;
      
      Constant SEG4_ADDR_RIP_MS_INDEX : integer := C_ADDR_WIDTH-1;
      Constant SEG4_ADDR_RIP_LS_INDEX : integer := 48;
      
      
      
      
      -- Local Signals
      signal lsig_seg3_addr_cntr        : unsigned(ACNTR_SEG3_WIDTH-1 downto 0) := (others => '0');
      signal lsig_acntr_msh_eq_max      : std_logic := '0';
      signal lsig_acntr_msh_eq_max_reg  : std_logic := '0';
 
      signal lsig_acntr_seg3_eq_max     : std_logic := '0';
      signal lsig_acntr_seg3_eq_max_reg : std_logic := '0';
      
      
      signal lsig_seg4_addr_cntr        : unsigned(ACNTR_SEG4_WIDTH-1 downto 0) := (others => '0');
 
       
       
      begin

      
      
        -- Populate the transfer address value by concatonating the
        -- 4 address counter segments
        sig_xfer_address     <= STD_LOGIC_VECTOR(lsig_seg4_addr_cntr  ) &
                                STD_LOGIC_VECTOR(lsig_seg3_addr_cntr  ) &
                                STD_LOGIC_VECTOR(sig_child_addr_cntr_msh) &
                                STD_LOGIC_VECTOR(sig_child_addr_cntr_lsh);


       
        
        -- See if the MSH (Segment 2) of the Address Counter is at a max value
        lsig_acntr_msh_eq_max <= '1'
          when (sig_child_addr_cntr_msh = ACNTR_MSH_MAX)
          Else '0';

        -- See if the Segment 3 of the Address Counter is at a max value
        lsig_acntr_seg3_eq_max <= '1'
          when (lsig_seg3_addr_cntr = ACNTR_SEG3_MAX)
          Else '0';


        
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_SEG2_3_EQ_MAX_REG
        --
        -- Process Description:
        --  Implements a register for the flag indicating the address
        -- counter segments 2 and 3 are at max value and will rollover
        -- at the next increment interval for the counter. Registering 
        -- these signals and using themt for the Seg 3/4 increment logic 
        -- only works because there is always at least a 1 clock time gap 
        -- between the increment causing the segment 2 or 3 counter to go  
        -- to max and the next increment operation. 
        --
        -------------------------------------------------------------
        IMP_SEG2_3_EQ_MAX_REG : process (primary_aclk)
          begin
            if (primary_aclk'event and primary_aclk = '1') then
               if (sig_mmap_reset_reg = '1') then
        
                 lsig_acntr_msh_eq_max_reg  <= '0';
                 lsig_acntr_seg3_eq_max_reg <= '0';
                 
               else
        
                 lsig_acntr_msh_eq_max_reg  <= lsig_acntr_msh_eq_max;
                 lsig_acntr_seg3_eq_max_reg <= lsig_acntr_seg3_eq_max;
        
               end if; 
            end if;       
          end process IMP_SEG2_3_EQ_MAX_REG; 
  
        
        
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_SEG3_ADDR_CNTR
        --
        -- Process Description:
        -- Segment 3 of the Address counter implementation.
        --
        -------------------------------------------------------------
        IMP_SEG3_ADDR_CNTR : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (sig_mmap_reset_reg = '1') then

                  lsig_seg3_addr_cntr <= (others => '0');

                elsif (sig_ld_child_addr_cntr = '1') then

                  lsig_seg3_addr_cntr <= UNSIGNED(sig_child_addr_reg(SEG3_ADDR_RIP_MS_INDEX downto 
                                                                     SEG3_ADDR_RIP_LS_INDEX));

                Elsif (sig_incr_child_addr_cntr    = '1' and
                       sig_child_addr_lsh_rollover = '1' and
                       lsig_acntr_msh_eq_max_reg   = '1') then

                  lsig_seg3_addr_cntr <= lsig_seg3_addr_cntr+ACNTR_SEG3_ONE;

                else
                  null;  -- hold current state
                end if;
             end if;
           end process IMP_SEG3_ADDR_CNTR;



        
  
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_SEG4_ADDR_CNTR
        --
        -- Process Description:
        -- Segment 4 of the Address counter implementation.
        --
        -------------------------------------------------------------
        IMP_SEG4_ADDR_CNTR : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (sig_mmap_reset_reg = '1') then

                  lsig_seg4_addr_cntr <= (others => '0');

                elsif (sig_ld_child_addr_cntr = '1') then

                  lsig_seg4_addr_cntr <= UNSIGNED(sig_child_addr_reg(SEG4_ADDR_RIP_MS_INDEX downto 
                                                                     SEG4_ADDR_RIP_LS_INDEX));

                Elsif (sig_incr_child_addr_cntr    = '1' and
                       sig_child_addr_lsh_rollover = '1' and
                       lsig_acntr_msh_eq_max_reg   = '1' and
                       lsig_acntr_seg3_eq_max_reg  = '1') then

                  lsig_seg4_addr_cntr <= lsig_seg4_addr_cntr+ACNTR_SEG4_ONE;

                else
                  null;  -- hold current state
                end if;
             end if;
           end process IMP_SEG4_ADDR_CNTR;



  
  
  
      end generate GEN_ADDR_GT_48;



     
     
     
     
     
     
     
     
    
    
    
    
    
    
    
    
     
      
    -- Child Addr and data Cntlr FIFO interface handshake logic ------------------------------
     
     sig_clr_cmd2data_valid    <= sig_cmd2data_valid and data2mstr_cmd_ready;
        
     sig_clr_cmd2addr_valid    <= sig_cmd2addr_valid and addr2mstr_cmd_ready;
        
     
      
     
     -------------------------------------------------------------
     -- Synchronous Process with Sync Reset
     --
     -- Label: CMD2DATA_VALID_FLOP
     --
     -- Process Description:
     --  Implements the set/reset flop for the Command Valid control
     -- to the Data Controller Module.
     --
     -------------------------------------------------------------
     CMD2DATA_VALID_FLOP : process (primary_aclk)
        begin
          if (primary_aclk'event and primary_aclk = '1') then
             if (sig_mmap_reset_reg     = '1' or
                 sig_clr_cmd2data_valid = '1') then
     
               sig_cmd2data_valid <= '0';
               
             elsif (sig_push_xfer_reg = '1') then
     
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
     --  Implements the set/reset flop for the Command Valid control
     -- to the Address Controller Module.
     --
     -------------------------------------------------------------
     CMD2ADDR_VALID_FLOP : process (primary_aclk)
        begin
          if (primary_aclk'event and primary_aclk = '1') then
             if (sig_mmap_reset_reg     = '1' or
                 sig_clr_cmd2addr_valid = '1') then
     
               sig_cmd2addr_valid <= '0';
               
             elsif (sig_push_xfer_reg = '1') then
     
               sig_cmd2addr_valid <= '1';
               
             else
               null; -- hold current state
             end if; 
          end if;       
        end process CMD2ADDR_VALID_FLOP; 
       
  
  
  
  
  
  
  
     
     
     
    ------------------------------------------------------------------
    -- Sequential transfer flag logic
 
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_SEQ_FLAG
    --
    -- Process Description:
    --  Sequential transfer flag flop 
    -- The sequential flag is an indication to downstream modules
    -- (such as Data Controllers) that the following command in the
    -- transfer queue is address sequential to the current transfer.
    -- This is used to minimize/eliminate transfer bubbles between
    -- child transfer boundaries.
    --
    -------------------------------------------------------------
    IMP_SEQ_FLAG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1' or
                sig_push_input_reg = '1') then

              sig_xfer_is_seq <= '0';
              
            elsif (sig_push_xfer_reg = '1') then

              sig_xfer_is_seq <= '1';
              
            else
              null; -- hold current state
            end if; 
         end if;       
       end process IMP_SEQ_FLAG; 
    
     
   
   
     
     
    
    
     -----------------------------------------------------------------
     -- Output xfer register design


     -- Pop the Store and Forward Xfer FIFO under command of the 
     -- Child State Machine
     sig_pcc2sf_xfer_ready <= sig_csm_pop_sf_fifo;
    
   
     
     sig_push_xfer_reg     <=  sig_csm_ld_xfer;
    
    
     sig_pop_xfer_reg      <= (sig_clr_cmd2data_valid and not(sig_cmd2addr_valid)) or  -- Data taking xfer after Addr
                              (sig_clr_cmd2addr_valid and not(sig_cmd2data_valid)) or  -- Addr taking xfer after Data
                              (sig_clr_cmd2data_valid and sig_clr_cmd2addr_valid);     -- Addr and Data both taking xfer
    
                                                     
     
     
     -- SFCC Simplifications
      
     --  sig_last_xfer_valid     <= sig_sf2pcc_cmd_cmplt;  
      
     sig_last_xfer_valid     <=  sig_sf2pcc_cmd_cmplt            and  -- from Store and forward
                                 (not(sig_child_qual_first_of_2) or
                                  sig_sf2pcc_packet_eop );
      
      
      
      
     -- DRE Stuff is sent via the Realigner command, 
     sig_xfer_drr_reg        <= '0';  -- not used here
      
     --  --------------------------------------------------------------------- 
     -- Strobe Generator Logic                                             
     -- Actual Strobes used are sent directly to the Data Controller from 
     -- Store and Forward module. Set these Strobe values to all ones in
     -- this module.
     sig_xfer_strt_strb_reg  <= (others => '1');
     sig_xfer_end_strb_reg   <= (others => '1');
                                         
    
    
    
                                                     
     -------------------------------------------------------------
     -- Synchronous Process with Sync Reset
     --
     -- Label: REG_CHILD_XFER_QUAL
     --
     -- Process Description:
     --  Implements the child command output xfer qualifier 
     -- holding register.
     --
     -------------------------------------------------------------
     REG_CHILD_XFER_QUAL : process (primary_aclk)
        begin
          if (primary_aclk'event and primary_aclk = '1') then
            if (sig_mmap_reset_reg = '1' or
               (sig_pop_xfer_reg   = '1' and
                sig_push_xfer_reg  = '0')) then
            
              sig_xfer_cache_reg      <=  (others => '0');
              sig_xfer_user_reg       <=  (others => '0');
              sig_xfer_tag_reg        <=  (others => '0');
              sig_xfer_addr_reg       <=  (others => '0');
              sig_xfer_len_reg        <=  (others => '0');
              sig_xfer_eof_reg        <=  '0';
              sig_xfer_is_seq_reg     <=  '0';
              sig_xfer_cmd_cmplt_reg  <=  '0';
              sig_xfer_calc_err_reg   <=  '0';
              sig_xfer_type_reg       <=  '0';                                        
              
              sig_xfer_reg_empty      <=  '1';
              sig_xfer_reg_full       <=  '0';
            
            elsif (sig_push_xfer_reg = '1') then
              
              sig_xfer_cache_reg      <=  sig_child_qual_cache_type     ;
              sig_xfer_user_reg       <=  sig_child_qual_user_type     ;
              sig_xfer_tag_reg        <=  sig_child_qual_tag_reg    ;
              sig_xfer_addr_reg       <=  sig_xfer_address          ;
              sig_xfer_len_reg        <=  sig_xfer_len              ;
              sig_xfer_eof_reg        <=  sf2pcc_packet_eop         ;
              sig_xfer_is_seq_reg     <=  not(sig_last_xfer_valid)  ;
              sig_xfer_cmd_cmplt_reg  <=  sig_last_xfer_valid or
                                          sig_child_qual_error_reg  ;
              sig_xfer_calc_err_reg   <=  sig_child_qual_error_reg  ;
              sig_xfer_type_reg       <=  sig_child_qual_burst_type ;
                                          
              sig_xfer_reg_empty      <=  '0';
              sig_xfer_reg_full       <=  '1';
                         
            else
              null; -- Hold current State
            end if; 
          end if;       
        end process REG_CHILD_XFER_QUAL; 
    
     
     

  
     
  
  end implementation;
