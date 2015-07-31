  -------------------------------------------------------------------------------
  -- axi_datamover_wrdata_cntl.vhd
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
  -- Filename:        axi_datamover_wrdata_cntl.vhd
  --
  -- Description:     
  --    This file implements the DataMover Master Write Data Controller.                 
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
  
  library axi_datamover_v5_1;
  use axi_datamover_v5_1.axi_datamover_fifo;
  use axi_datamover_v5_1.axi_datamover_strb_gen2;
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_wrdata_cntl is
    generic (
      
      C_REALIGNER_INCLUDED   : Integer range  0 to   1 :=  0;
        -- Indicates the Data Realignment function is included (external
        -- to this module)
      
      C_ENABLE_INDET_BTT     : Integer range  0 to   1 :=  0;
        -- Indicates the INDET BTT function is included (external
        -- to this module)
            
      C_SF_BYTES_RCVD_WIDTH  : Integer range  1 to  23 :=  1;
        -- Sets the width of the data2wsc_bytes_rcvd port used for 
        -- relaying the actual number of bytes received when Idet BTT is 
        -- enabled (C_ENABLE_INDET_BTT = 1)
      
      C_SEL_ADDR_WIDTH       : Integer range  1 to   8 :=  5;
        -- Sets the width of the LS bits of the transfer address that
        -- are being used to Demux write data to a wider AXI4 Write
        -- Data Bus
        
      C_DATA_CNTL_FIFO_DEPTH : Integer range  1 to  32 :=  4;
        -- Sets the depth of the internal command fifo used for the
        -- command queue
        
      C_MMAP_DWIDTH          : Integer range 32 to 1024 := 32;
        -- Indicates the native data width of the Read Data port
        
      C_STREAM_DWIDTH        : Integer range  8 to 1024 := 32;
        -- Sets the width of the Stream output data port
        
      C_TAG_WIDTH            : Integer range  1 to   8 :=  4;
        -- Indicates the width of the Tag field of the input command
        
      C_FAMILY               : String                  := "virtex7"
        -- Indicates the device family of the target FPGA
        
      
      );
    port (
      
      -- Clock and Reset inputs ----------------------------------------------
                                                                            --
      primary_aclk         : in  std_logic;                                 --
         -- Primary synchronization clock for the Master side               --
         -- interface and internal logic. It is also used                   --
         -- for the User interface synchronization when                     --
         -- C_STSCMD_IS_ASYNC = 0.                                          --
                                                                            --
      -- Reset input                                                        --
      mmap_reset           : in  std_logic;                                 --
         -- Reset used for the internal master logic                        --
      ------------------------------------------------------------------------
      

     
      
      -- Soft Shutdown internal interface ------------------------------------
                                                                            --
      rst2data_stop_request : in  std_logic;                                --
         -- Active high soft stop request to modules                        --
                                                                            --
      data2addr_stop_req    : Out std_logic;                                --
        -- Active high signal requesting the Address Controller             --
        -- to stop posting commands to the AXI Read Address Channel         --
                                                                            --
      data2rst_stop_cmplt   : Out std_logic;                                --
        -- Active high indication that the Data Controller has completed    --
        -- any pending transfers committed by the Address Controller        --
        -- after a stop has been requested by the Reset module.             --
      ------------------------------------------------------------------------
      
      
        
  
      -- Store and Forward support signals for external User logic ------------
                                                                             --
      wr_xfer_cmplt         : Out std_logic;                                 --
        -- Active high indication that the Data Controller has completed     --
        -- a single write data transfer on the AXI4 Write Data Channel.      --
        -- This signal is escentially echos the assertion of wlast sent      --
        -- to the AXI4.                                                      --
                                                                             --
      s2mm_ld_nxt_len        : out std_logic;                                --
        -- Active high pulse indicating a new xfer length has been queued    --
        -- to the WDC Cmd FIFO                                               --
                                                                             --
      s2mm_wr_len            : out std_logic_vector(7 downto 0);             --
        -- Bus indicating the AXI LEN value associated with the xfer command --
        -- loaded into the WDC Command FIFO.                                 --
      -------------------------------------------------------------------------
     
     
     
      -- AXI Write Data Channel Skid buffer I/O  ---------------------------------------
                                                                                      --
      data2skid_saddr_lsb   : out std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0);      --
        -- Write DATA output to skid buffer                                           --
                                                                                      --
      data2skid_wdata       : Out  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);      --
        -- Write DATA output to skid buffer                                           --
                                                                                      --
      data2skid_wstrb       : Out  std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);  --
        -- Write DATA output to skid buffer                                           --
                                                                                      --
      data2skid_wlast       : Out  std_logic;                                         --
        -- Write LAST output to skid buffer                                           --
                                                                                      --
      data2skid_wvalid      : Out  std_logic;                                         --
        -- Write VALID output to skid buffer                                          --
                                                                                      --
      skid2data_wready      : In  std_logic;                                          --
        -- Write READY input from skid buffer                                         --
      ----------------------------------------------------------------------------------
     
 
 
      -- AXI Slave Stream In -----------------------------------------------------------
                                                                                      --
      s2mm_strm_wvalid   : In  std_logic;                                             --
        -- AXI Stream VALID input                                                     --
                                                                                      --
      s2mm_strm_wready   : Out  Std_logic;                                            --
        -- AXI Stream READY Output                                                    --
                                                                                      --
      s2mm_strm_wdata    : In  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);          --
        -- AXI Stream data input                                                      --
                                                                                      --
      s2mm_strm_wstrb    : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);       --  
        -- AXI Stream STRB input                                                      --
                                                                                      --
      s2mm_strm_wlast    : In std_logic;                                              --
        -- AXI Stream LAST input                                                      --
      ----------------------------------------------------------------------------------
               
      
      
      -- Stream input sideband signal from Indeterminate BTT and/or DRE ----------------
                                                                                      --
      s2mm_strm_eop      : In std_logic;                                              --
        -- Stream End of Packet marker input. This is only used when Indeterminate    --
        -- BTT mode is enable. Otherwise it is ignored                                --
                                                                                      --
                                                                                      --
      s2mm_stbs_asserted : in  std_logic_vector(7 downto 0);                          --
        -- Indicates the number of asserted WSTRB bits for the                        --
        -- associated input stream data beat                                          --
                                                                                      --
                                                                                      --
      -- Realigner Underrun/overrun error flag used in non Indeterminate BTT          --
      -- Mode                                                                         --
      realign2wdc_eop_error  : In  std_logic ;                                        --
        -- Asserted active high and will only clear with reset. It is only used       --
        -- when Indeterminate BTT is not enabled and the Realigner Module is          --
        -- instantiated upstream from the WDC. The Realigner will detect overrun      --
        -- underrun conditions and will will relay these conditions via this signal.  --
      ----------------------------------------------------------------------------------        
      
      
                
                
                
      -- Command Calculator Interface --------------------------------------------------
                                                                                      --
      mstr2data_tag        : In std_logic_vector(C_TAG_WIDTH-1 downto 0);             --
         -- The next command tag                                                      --
                                                                                      --
      mstr2data_saddr_lsb  : In std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0);        --
         -- The next command start address LSbs to use for the write strb             --
         -- demux (only used if Stream data width is less than the MMap Dwidth).      --
                                                                                      --
      mstr2data_len        : In std_logic_vector(7 downto 0);                         --
         -- The LEN value output to the Address Channel                               --
                                                                                      --
      mstr2data_strt_strb  : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);     --
         -- The starting strobe value to use for the first stream data beat           --
                                                                                      --
      mstr2data_last_strb  : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);     --
         -- The endiing (LAST) strobe value to use for the last stream                --
         -- data beat                                                                 --
                                                                                      --
      mstr2data_drr        : In std_logic;                                            --
         -- The starting tranfer of a sequence of transfers                           --
                                                                                      --
      mstr2data_eof        : In std_logic;                                            --
         -- The endiing tranfer of a sequence of transfers                            --
                                                                                      --
      mstr2data_sequential : In std_logic;                                            --
         -- The next sequential tranfer of a sequence of transfers                    --
         -- spawned from a single parent command                                      --
                                                                                      --
      mstr2data_calc_error : In std_logic;                                            --
         -- Indication if the next command in the calculation pipe                    --
         -- has a calculation error                                                   --
                                                                                      --
      mstr2data_cmd_cmplt  : In std_logic;                                            --
         -- The final child tranfer of a parent command fetched from                  --
         -- the Command FIFO (not necessarily an EOF command)                         --
                                                                                      --
      mstr2data_cmd_valid  : In std_logic;                                            --
         -- The next command valid indication to the Data Channel                     --
         -- Controller for the AXI MMap                                               --
                                                                                      --
      data2mstr_cmd_ready  : Out std_logic ;                                          --
         -- Indication from the Data Channel Controller that the                      --
         -- command is being accepted on the AXI Address                              --
         -- Channel                                                                   --
      ----------------------------------------------------------------------------------
      
      
      
        
      -- Address Controller Interface --------------------------------------------------
                                                                                      --
      addr2data_addr_posted    : In std_logic ;                                       --
         -- Indication from the Address Channel Controller to the                     --
         -- Data Controller that an address has been posted to the                    --
         -- AXI Address Channel                                                       --
                                                                                      --
                                                                                      --
      data2addr_data_rdy       : out std_logic;                                       --
         -- Indication that the Data Channel is ready to send the first               --
         -- databeat of the next command on the write data channel.                   --
         -- This is used for the "wait for data" feature which keeps the              --
         -- address controller from issuing a transfer request until the              --
         -- corresponding data valid is asserted on the stream input. The             --
         -- WDC will continue to assert the output until an assertion on              --
         -- the addr2data_addr_posted is received.                                    --
       ---------------------------------------------------------------------------------
  
  
      
      -- Premature TLAST assertion error flag ------------------------------------------
                                                                                      --
      data2all_tlast_error : Out std_logic;                                           --
         -- When asserted, this indicates the data controller detected                --
         -- a premature TLAST assertion on the incoming data stream.                  --
       ---------------------------------------------------------------------------------     
      
      
      -- Data Controller Halted Status -------------------------------------------------
                                                                                      --
      data2all_dcntlr_halted : Out std_logic;                                         --
         -- When asserted, this indicates the data controller has satisfied           --
         -- all pending transfers queued by the Address Controller and is halted.     --
      ----------------------------------------------------------------------------------
      
       
 
      -- Input Stream Skid Buffer Halt control -----------------------------------------
                                                                                      --
      data2skid_halt       : Out std_logic;                                           --
         -- The data controller asserts this output for 1 primary clock period        --
         -- The pulse commands the MM2S Stream skid buffer to tun off outputs         --
         -- at the next tlast transmission.                                           --
      ----------------------------------------------------------------------------------
      
       
 
       
      -- Write Status Controller Interface ---------------------------------------------
                                                                                      --
      data2wsc_tag         : Out std_logic_vector(C_TAG_WIDTH-1 downto 0);            --
         -- The command tag                                                           --
                                                                                      --
      data2wsc_calc_err    : Out std_logic ;                                          --
         -- Indication that the current command out from the Cntl FIFO                --
         -- has a calculation error                                                   --
                                                                                      --
      data2wsc_last_err    : Out std_logic ;                                          --
        -- Indication that the current write transfer encountered a premature         --
        -- TLAST assertion on the incoming Stream Channel                             --
                                                                                      --
      data2wsc_cmd_cmplt   : Out std_logic ;                                          --
         -- Indication by the Data Channel Controller that the                        --
         -- corresponding status is the last status for a command                     --
         -- pulled from the command FIFO                                              --
                                                                                      --
      wsc2data_ready       : in  std_logic;                                           --
         -- Input from the Write Status Module indicating that the                    --
         -- Status Reg/FIFO is ready to accept data                                   --
                                                                                      --
      data2wsc_valid       : Out  std_logic;                                          --
         -- Output to the Command/Status Module indicating that the                   --
         -- Data Controller has valid tag and err indicators to write                 --
         -- to the Status module                                                      --
                                                                                      --
      data2wsc_eop         : Out  std_logic;                                          --
         -- Output to the Write Status Controller indicating that the                 --
         -- associated command status also corresponds to a End of Packet             --
         -- marker for the input Stream. This is only used when Inderminate           --
         -- BTT is enabled in the S2MM.                                               --
                                                                                      --
      data2wsc_bytes_rcvd  : Out std_logic_vector(C_SF_BYTES_RCVD_WIDTH-1 downto 0);  --
         -- Output to the Write Status Controller indicating the actual               --
         -- number of bytes received from the Stream input for the                    --
         -- corresponding command status. This is only used when Inderminate          --
         -- BTT is enabled in the S2MM.                                               --
                                                                                      --
      wsc2mstr_halt_pipe   : In  std_logic                                            --
         -- Indication to Halt the Data and Address Command pipeline due              --
         -- to the Status FIFO going full or an internal error being logged           --
      ----------------------------------------------------------------------------------

    
      
      );
  
  end entity axi_datamover_wrdata_cntl;
  
  
  architecture implementation of axi_datamover_wrdata_cntl  is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Function declaration   ----------------------------------------
    
    
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
        
        when 128 =>  -- 1024 bits          -- Added per Per CR616409
            temp_dbeat_residue_width := 7; -- Added per Per CR616409
        when 64 =>   -- 512 bits           -- Added per Per CR616409
            temp_dbeat_residue_width := 6; -- Added per Per CR616409
        when 32 =>   -- 256 bits           
            temp_dbeat_residue_width := 5;
        when 16 =>   -- 128 bits
            temp_dbeat_residue_width := 4;
        when 8 =>    -- 64 bits
            temp_dbeat_residue_width := 3;
        when 4 =>    -- 32 bits
            temp_dbeat_residue_width := 2;
        when 2 =>    -- 16 bits
            temp_dbeat_residue_width := 1;
        when others =>  -- assume 1-byte transfers
            temp_dbeat_residue_width := 0;
      end case;

      Return (temp_dbeat_residue_width);

    end function funct_get_dbeat_residue_width;




    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_set_cnt_width
    --
    -- Function Description:
    --    Sets a count width based on a fifo depth. A depth of 4 or less
    -- is a special case which requires a minimum count width of 3 bits.
    --
    -------------------------------------------------------------------
    function funct_set_cnt_width (fifo_depth : integer) return integer is
    
      Variable temp_cnt_width : Integer := 4;
    
    begin
    
      
      if (fifo_depth <= 4) then
      
         temp_cnt_width := 3;
      
      elsif (fifo_depth <= 8) then
      
         temp_cnt_width := 4;
      
      elsif (fifo_depth <= 16) then
      
         temp_cnt_width := 5;
      
      elsif (fifo_depth <= 32) then
      
         temp_cnt_width := 6;
      
      else  -- fifo depth <= 64
      
         temp_cnt_width := 7;
      
      end if;
      
      Return (temp_cnt_width);
       
       
    end function funct_set_cnt_width;
    
 
 
 
  
    -- Constant Declarations  --------------------------------------------
    
    Constant STRM_STRB_WIDTH        : integer := C_STREAM_DWIDTH/8;
    Constant LEN_OF_ZERO            : std_logic_vector(7 downto 0) := (others => '0');
    Constant USE_SYNC_FIFO          : integer := 0;
    Constant REG_FIFO_PRIM          : integer := 0; 
    Constant BRAM_FIFO_PRIM         : integer := 1; 
    Constant SRL_FIFO_PRIM          : integer := 2; 
    Constant FIFO_PRIM_TYPE         : integer := SRL_FIFO_PRIM; 
    Constant TAG_WIDTH              : integer := C_TAG_WIDTH;
    Constant SADDR_LSB_WIDTH        : integer := C_SEL_ADDR_WIDTH;
    Constant LEN_WIDTH              : integer := 8;
    Constant STRB_WIDTH             : integer := C_STREAM_DWIDTH/8;
    Constant DRR_WIDTH              : integer := 1;
    Constant EOF_WIDTH              : integer := 1;
    Constant CALC_ERR_WIDTH         : integer := 1;
    Constant CMD_CMPLT_WIDTH        : integer := 1;
    Constant SEQUENTIAL_WIDTH       : integer := 1;
    Constant DCTL_FIFO_WIDTH        : Integer := TAG_WIDTH        +  -- Tag field
                                                 SADDR_LSB_WIDTH  +  -- LS Address field width
                                                 LEN_WIDTH        +  -- LEN field
                                                 STRB_WIDTH       +  -- Starting Strobe field
                                                 STRB_WIDTH       +  -- Ending Strobe field
                                                 DRR_WIDTH        +  -- DRE Re-alignment Request Flag Field
                                                 EOF_WIDTH        +  -- EOF flag field
                                                 SEQUENTIAL_WIDTH +  -- Sequential command flag
                                                 CMD_CMPLT_WIDTH  +  -- Command Complete Flag
                                                 CALC_ERR_WIDTH;     -- Calc error flag
    
    Constant TAG_STRT_INDEX         : integer := 0;
    Constant SADDR_LSB_STRT_INDEX   : integer := TAG_STRT_INDEX + TAG_WIDTH;
    Constant LEN_STRT_INDEX         : integer := SADDR_LSB_STRT_INDEX + SADDR_LSB_WIDTH;
    Constant STRT_STRB_STRT_INDEX   : integer := LEN_STRT_INDEX + LEN_WIDTH;
    Constant LAST_STRB_STRT_INDEX   : integer := STRT_STRB_STRT_INDEX + STRB_WIDTH;
    Constant DRR_STRT_INDEX         : integer := LAST_STRB_STRT_INDEX + STRB_WIDTH;
    Constant EOF_STRT_INDEX         : integer := DRR_STRT_INDEX + DRR_WIDTH;
    Constant SEQUENTIAL_STRT_INDEX  : integer := EOF_STRT_INDEX + EOF_WIDTH;
    Constant CMD_CMPLT_STRT_INDEX   : integer := SEQUENTIAL_STRT_INDEX+SEQUENTIAL_WIDTH;
    Constant CALC_ERR_STRT_INDEX    : integer := CMD_CMPLT_STRT_INDEX+CMD_CMPLT_WIDTH;        
    Constant ADDR_INCR_VALUE        : integer := C_STREAM_DWIDTH/8;
    
    Constant ADDR_POSTED_CNTR_WIDTH : integer := funct_set_cnt_width(C_DATA_CNTL_FIFO_DEPTH); 
    
    
    
    Constant ADDR_POSTED_ZERO       : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) 
                                      := (others => '0');
    Constant ADDR_POSTED_ONE        : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) 
                                      := TO_UNSIGNED(1, ADDR_POSTED_CNTR_WIDTH);
    Constant ADDR_POSTED_MAX        : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) 
                                      := (others => '1');
                    
    
    
    
    
    -- Signal Declarations  --------------------------------------------
    
    signal sig_get_next_dqual        : std_logic := '0';
    signal sig_last_mmap_dbeat       : std_logic := '0';
    signal sig_last_mmap_dbeat_reg   : std_logic := '0';
    signal sig_mmap2data_ready       : std_logic := '0';
    signal sig_data2mmap_valid       : std_logic := '0';
    signal sig_data2mmap_last        : std_logic := '0';
    signal sig_data2mmap_data        : std_logic_vector(C_STREAM_DWIDTH-1 downto 0) := (others => '0');
    signal sig_ld_new_cmd            : std_logic := '0';
    signal sig_ld_new_cmd_reg        : std_logic := '0';
    signal sig_cmd_cmplt_reg         : std_logic := '0';
    signal sig_calc_error_reg        : std_logic := '0';
    signal sig_tag_reg               : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_addr_lsb_reg          : std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_strt_strb_reg         : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_last_strb_reg         : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_addr_posted           : std_logic := '0';
    signal sig_dqual_rdy             : std_logic := '0';
    signal sig_good_mmap_dbeat       : std_logic := '0';
    signal sig_first_dbeat           : std_logic := '0';
    signal sig_last_dbeat            : std_logic := '0';
    signal sig_single_dbeat          : std_logic := '0';
    signal sig_new_len_eq_0          : std_logic := '0';
    signal sig_dbeat_cntr            : unsigned(7 downto 0) := (others => '0');
    Signal sig_dbeat_cntr_int        : Integer range 0 to 255 := 0;
    signal sig_dbeat_cntr_eq_0       : std_logic := '0';
    signal sig_dbeat_cntr_eq_1       : std_logic := '0';
    signal sig_wsc_ready             : std_logic := '0';
    signal sig_push_to_wsc           : std_logic := '0';
    signal sig_push_to_wsc_cmplt     : std_logic := '0';
    signal sig_set_push2wsc          : std_logic := '0';
    signal sig_data2wsc_tag          : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_data2wsc_calc_err     : std_logic := '0';
    signal sig_data2wsc_last_err     : std_logic := '0';
    signal sig_data2wsc_cmd_cmplt    : std_logic := '0';
    signal sig_tlast_error           : std_logic := '0';
    signal sig_tlast_error_strbs     : std_logic := '0';
    signal sig_end_stbs_match_err    : std_logic := '0';
    signal sig_tlast_error_reg       : std_logic := '0';
    signal sig_cmd_is_eof            : std_logic := '0';
    signal sig_push_err2wsc          : std_logic := '0';
    signal sig_tlast_error_ovrrun    : std_logic := '0';
    signal sig_tlast_error_undrrun   : std_logic := '0';
    signal sig_next_tag_reg          : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_next_strt_strb_reg    : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_next_last_strb_reg    : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_next_eof_reg          : std_logic := '0';
    signal sig_next_sequential_reg   : std_logic := '0';
    signal sig_next_cmd_cmplt_reg    : std_logic := '0';
    signal sig_next_calc_error_reg   : std_logic := '0';
    signal sig_pop_dqual_reg         : std_logic := '0';
    signal sig_push_dqual_reg        : std_logic := '0';
    signal sig_dqual_reg_empty       : std_logic := '0';
    signal sig_dqual_reg_full        : std_logic := '0';
    signal sig_addr_posted_cntr      : unsigned(ADDR_POSTED_CNTR_WIDTH-1 downto 0) := (others => '0');
    signal sig_addr_posted_cntr_eq_0 : std_logic := '0';
    signal sig_addr_posted_cntr_max  : std_logic := '0';
    signal sig_decr_addr_posted_cntr : std_logic := '0';
    signal sig_incr_addr_posted_cntr : std_logic := '0';
    signal sig_addr_posted_cntr_eq_1 : std_logic := '0';
    signal sig_apc_going2zero        : std_logic := '0';
    signal sig_aposted_cntr_ready    : std_logic := '0';
    signal sig_addr_chan_rdy         : std_logic := '0';
    Signal sig_no_posted_cmds        : std_logic := '0';
    signal sig_ls_addr_cntr          : unsigned(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_incr_ls_addr_cntr     : std_logic := '0';
    signal sig_addr_incr_unsgnd      : unsigned(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    Signal sig_cmd_fifo_data_in      : std_logic_vector(DCTL_FIFO_WIDTH-1 downto 0) := (others => '0');
    Signal sig_cmd_fifo_data_out     : std_logic_vector(DCTL_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_next_tag         : std_logic_vector(TAG_WIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_next_sadddr_lsb  : std_logic_vector(C_SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_next_len         : std_logic_vector(7 downto 0) := (others => '0');
    signal sig_fifo_next_strt_strb   : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_fifo_next_last_strb   : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_fifo_next_drr         : std_logic := '0';
    signal sig_fifo_next_eof         : std_logic := '0';
    signal sig_fifo_next_cmd_cmplt   : std_logic := '0';
    signal sig_fifo_next_sequential  : std_logic := '0';
    signal sig_fifo_next_calc_error  : std_logic := '0';
    signal sig_cmd_fifo_empty        : std_logic := '0';
    signal sig_fifo_wr_cmd_valid     : std_logic := '0';
    signal sig_fifo_wr_cmd_ready     : std_logic := '0';
    signal sig_fifo_rd_cmd_valid     : std_logic := '0';
    signal sig_fifo_rd_cmd_ready     : std_logic := '0';
    signal sig_sequential_push       : std_logic := '0';
    signal sig_clr_dqual_reg         : std_logic := '0';
    signal sig_tlast_err_stop        : std_logic := '0';
    signal sig_halt_reg              : std_logic := '0';
    signal sig_halt_reg_dly1         : std_logic := '0';
    signal sig_halt_reg_dly2         : std_logic := '0';
    signal sig_halt_reg_dly3         : std_logic := '0';
    signal sig_data2skid_halt        : std_logic := '0';
    signal sig_stop_wvalid           : std_logic := '0';
    signal sig_data2rst_stop_cmplt   : std_logic := '0';
    signal sig_s2mm_strm_wready      : std_logic := '0';
    signal sig_good_strm_dbeat       : std_logic := '0';
    signal sig_halt_strb             : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_sfhalt_next_strt_strb : std_logic_vector(STRM_STRB_WIDTH-1 downto 0) := (others => '0');             
    signal sig_wfd_simult_clr_set    : std_logic := '0';
    signal sig_wr_xfer_cmplt         : std_logic := '0';
    signal sig_s2mm_ld_nxt_len       : std_logic := '0';
    signal sig_s2mm_wr_len           : std_logic_vector(7 downto 0) := (others => '0');
    signal sig_data2mstr_cmd_ready   : std_logic := '0';
    signal sig_spcl_push_err2wsc     : std_logic := '0';
    
    
                               
  begin --(architecture implementation)
  
    -- Command calculator handshake
    data2mstr_cmd_ready <= sig_data2mstr_cmd_ready;
    
    
    -- Write Data Channel Skid Buffer Port assignments
    sig_mmap2data_ready  <= skid2data_wready     ;
    data2skid_wvalid     <= sig_data2mmap_valid  ;
    data2skid_wlast      <= sig_data2mmap_last   ;
    data2skid_wdata      <= sig_data2mmap_data   ;
    data2skid_saddr_lsb  <= sig_addr_lsb_reg     ;
    
    -- AXI MM2S Stream Channel Port assignments           
    sig_data2mmap_data   <= s2mm_strm_wdata      ;

    
    -- Premature TLAST assertion indication
    data2all_tlast_error <= sig_tlast_error_reg  ;
    
    
    
    
   
    -- Stream Input Ready Handshake
    s2mm_strm_wready     <= sig_s2mm_strm_wready ;                                           
    
    
    
    sig_good_strm_dbeat  <= s2mm_strm_wvalid and
                            sig_s2mm_strm_wready;
    
    
    sig_data2mmap_last   <= sig_dbeat_cntr_eq_0 and
                            sig_dqual_rdy;

                      

    -- Write Status Block interface signals
    data2wsc_valid       <= sig_push_to_wsc and
                            not(sig_tlast_err_stop) ; -- only allow 1 status write on TLAST errror
    sig_wsc_ready        <= wsc2data_ready          ;
    data2wsc_tag         <= sig_data2wsc_tag        ;   
    data2wsc_calc_err    <= sig_data2wsc_calc_err   ; 
    data2wsc_last_err    <= sig_data2wsc_last_err   ; 
    data2wsc_cmd_cmplt   <= sig_data2wsc_cmd_cmplt  ;   
    
                                      
    -- Address Channel Controller synchro pulse input                  
    sig_addr_posted      <= addr2data_addr_posted;
                                                        
    
    
    -- Request to halt the Address Channel Controller                  
    data2addr_stop_req   <= sig_halt_reg or
                            sig_tlast_error_reg;
 
    
    -- Halted flag to the reset module                  
    data2rst_stop_cmplt  <= sig_data2rst_stop_cmplt;
    
    
    -- Indicate the Write Data Controller is always ready
    data2addr_data_rdy   <= '1'; 
    
    
    
    -- Write Transfer Completed Status output 
    wr_xfer_cmplt        <= sig_wr_xfer_cmplt ;
    
    -- New LEN value is being loaded 
    s2mm_ld_nxt_len      <= sig_s2mm_ld_nxt_len;
    
    -- The new LEN value
    s2mm_wr_len          <= sig_s2mm_wr_len;
    
    
     
     
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_WR_CMPLT_FLAG
    --
    -- Process Description:
    --   Implements the status flag indicating that a write data 
    -- transfer has completed. This is an echo of a wlast assertion
    -- and a qualified data beat on the AXI4 Write Data Channel.
    --
    -------------------------------------------------------------
    IMP_WR_CMPLT_FLAG : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset = '1') then
    
             sig_wr_xfer_cmplt <= '0';
    
           else
    
             sig_wr_xfer_cmplt <= sig_data2mmap_last and 
                                  sig_good_strm_dbeat;
                                  
           end if; 
        end if;       
      end process IMP_WR_CMPLT_FLAG; 
     
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_OMIT_INDET_BTT
    --
    -- If Generate Description:
    --   Omits any Indeterminate BTT Support logic and includes
    -- any error detection needed in Non Indeterminate BTT mode.
    --
    ------------------------------------------------------------
    GEN_OMIT_INDET_BTT : if (C_ENABLE_INDET_BTT = 0) generate
    
      begin
   
       
        
        
        sig_sfhalt_next_strt_strb <= sig_fifo_next_strt_strb;
        
        
        
        
        -- Just housekeep the output port signals
        
        data2wsc_eop         <= '0';
   
        data2wsc_bytes_rcvd  <= (others => '0');
   
       
        
        
        
        -- WRSTRB logic ------------------------------
                  

        -- Generate the Write Strobes for the MMap Write Data Channel
        -- for the non Indeterminate BTT Case
        data2skid_wstrb  <= sig_strt_strb_reg 
          When (sig_first_dbeat  = '1')
          Else  sig_last_strb_reg
          When  (sig_last_dbeat  = '1')
          Else (others => '1');

        
                 
        -- Generate the Stream Ready for the Stream input side
        sig_s2mm_strm_wready <= sig_halt_reg            or  -- force tready if a halt requested
                                (sig_mmap2data_ready    and
                                sig_addr_chan_rdy       and -- This puts combinational logic in the stream WREADY path
                                sig_dqual_rdy           and
                                not(sig_calc_error_reg) and
                                not(sig_tlast_error_reg));   -- Stop the stream channel at a overrun/underrun detection
        
         
        
        -- MMap Write Data Channel Valid Handshaking
        sig_data2mmap_valid <= (s2mm_strm_wvalid       or
                               sig_tlast_error_reg     or  -- force valid if TLAST error 
                               sig_halt_reg       )    and -- force valid if halt requested       
                               sig_addr_chan_rdy       and -- xfers are commited on the address channel and       
                               sig_dqual_rdy           and -- there are commands in the command fifo        
                               not(sig_calc_error_reg) and
                               not(sig_stop_wvalid);       -- gate off wvalid immediately after a wlast for 1 clk
                                                           -- or when the soft shutdown has completed
              
      
        
        
        
        
        
        ------------------------------------------------------------
        -- If Generate
        --
        -- Label: GEN_LOCAL_ERR_DETECT
        --
        -- If Generate Description:
        --  Implements the local overrun and underrun detection when
        -- the S2MM Realigner is not included.
        --
        --
        ------------------------------------------------------------
        GEN_LOCAL_ERR_DETECT : if (C_REALIGNER_INCLUDED = 0) generate
        
        
           begin
        
             -------  Input Stream TLAST assertion error ------------------------------- 
             
             
             sig_tlast_error_ovrrun <= sig_cmd_is_eof       and
                                       sig_dbeat_cntr_eq_0  and
                                       sig_good_mmap_dbeat  and
                                       not(s2mm_strm_wlast);
             
             
             
             sig_tlast_error_undrrun <= s2mm_strm_wlast     and
                                        sig_good_mmap_dbeat and
                                        (not(sig_dbeat_cntr_eq_0) or
                                         not(sig_cmd_is_eof));
             
                    
                    
             sig_end_stbs_match_err  <=  '1'                            -- Set flag if the calculated end strobe value
               When ((s2mm_strm_wstrb    /= sig_next_last_strb_reg) and -- does not match the received strobe value 
                    (s2mm_strm_wlast     = '1') and                     -- at TLAST assertion
                    (sig_good_mmap_dbeat = '1'))                        -- Qualified databeat
               Else '0';
                    
                                 
             sig_tlast_error <=  (sig_tlast_error_ovrrun  or
                                  sig_tlast_error_undrrun or
                                  sig_end_stbs_match_err) and
                                  not(sig_halt_reg);          -- Suppress TLAST error when in soft shutdown 
                                 
                                 
             
             -- Just housekeep this when local TLAST error detection is used
             sig_spcl_push_err2wsc <= '0';
            
            
            
           
           end generate GEN_LOCAL_ERR_DETECT;
        
        
 
 
 
        ------------------------------------------------------------
        -- If Generate
        --
        -- Label: GEN_EXTERN_ERR_DETECT
        --
        -- If Generate Description:
        --  Omits the local overrun and underrun detection and relies
        -- on the S2MM Realigner for the detection.
        --
        ------------------------------------------------------------
        GEN_EXTERN_ERR_DETECT : if (C_REALIGNER_INCLUDED = 1) generate
        
        
           begin
        
 
              sig_tlast_error_undrrun <= '0';  -- not used here
 
              sig_tlast_error_ovrrun  <= '0';  -- not used here
 
              sig_end_stbs_match_err  <= '0';  -- not used here
 
 
           
              sig_tlast_error <= realign2wdc_eop_error and  -- External error detection asserted
                                 not(sig_halt_reg);         -- Suppress TLAST error when in soft shutdown
               
             
             
              -- Special case for pushing error status when timing is such that no 
              -- addresses have been posted to AXI and a TLAST error has been detected  
              -- by the Realigner module and propagated in from the Stream input side.
              sig_spcl_push_err2wsc <= sig_tlast_error_reg     and
                                       not(sig_tlast_err_stop) and
                                       not(sig_addr_chan_rdy );
             
             
             
             
             
             
               
               
           
           end generate GEN_EXTERN_ERR_DETECT;
 
 
 
 
 
 
 
        
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_TLAST_ERR_REG
        --
        -- Process Description:
        --  Implements a sample and hold flop for the flag indicating
        -- that the input Stream TLAST assertion was not at the expected
        -- data beat relative to the commanded number of databeats
        -- from the associated command from the SCC or PCC.
        -------------------------------------------------------------
        IMP_TLAST_ERR_REG : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (mmap_reset = '1') then
                  sig_tlast_error_reg <= '0';
                elsif (sig_tlast_error = '1') then
                  sig_tlast_error_reg <= '1';
                else
                  null;  -- hold current state
                end if; 
             end if;       
           end process IMP_TLAST_ERR_REG; 
           
           
           
           
           
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_TLAST_ERROR_STOP
        --
        -- Process Description:
        --  Implements the flop to generate a stop flag once the TLAST
        -- error condition has been relayed to the Write Status 
        -- Controller. This stop flag is used to prevent any more 
        -- pushes to the Write Status Controller.
        --
        -------------------------------------------------------------
        IMP_TLAST_ERROR_STOP : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (mmap_reset = '1') then
                  sig_tlast_err_stop <= '0';
                elsif (sig_tlast_error_reg   = '1' and
                       sig_push_to_wsc_cmplt = '1') then
                  sig_tlast_err_stop <= '1';
                else
                  null; -- Hold State
                end if; 
             end if;       
           end process IMP_TLAST_ERROR_STOP; 
           
           
           
      
      
      
      end generate GEN_OMIT_INDET_BTT;
   
   













    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INDET_BTT
    --
    -- If Generate Description:
    --   Includes any Indeterminate BTT Support logic. Primarily
    -- this is a counter for the input stream bytes received. The
    -- received byte count is relayed to the Write Status Controller
    -- for each parent command completed.
    -- When a packet completion is indicated via the EOP marker
    -- assertion, the status to the Write Status Controller also
    -- indicates the EOP condition.
    -- Note that underrun and overrun detection/error flagging
    -- is disabled in Indeterminate BTT Mode.
    --
    ------------------------------------------------------------
    GEN_INDET_BTT : if (C_ENABLE_INDET_BTT = 1) generate
    
      -- local constants
      Constant BYTE_CNTR_WIDTH          : integer := C_SF_BYTES_RCVD_WIDTH;
      Constant NUM_ZEROS_WIDTH          : integer := 8;
      Constant BYTES_PER_DBEAT          : integer := C_STREAM_DWIDTH/8;
      Constant STRBGEN_ADDR_SLICE_WIDTH : integer := 
                                          funct_get_dbeat_residue_width(BYTES_PER_DBEAT);
      
      Constant STRBGEN_ADDR_0            : std_logic_vector(STRBGEN_ADDR_SLICE_WIDTH-1 downto 0) := (others => '0');
      
      
      
      -- local signals
      signal lsig_byte_cntr             : unsigned(BYTE_CNTR_WIDTH-1 downto 0) := (others => '0');
      signal lsig_byte_cntr_incr_value  : unsigned(BYTE_CNTR_WIDTH-1 downto 0) := (others => '0');
      signal lsig_ld_byte_cntr          : std_logic := '0';
      signal lsig_incr_byte_cntr        : std_logic := '0';
      signal lsig_clr_byte_cntr         : std_logic := '0';
      signal lsig_end_of_cmd_reg        : std_logic := '0';
      signal lsig_eop_s_h_reg           : std_logic := '0';
      signal lsig_eop_reg               : std_logic := '0';
      signal sig_strbgen_addr           : std_logic_vector(STRBGEN_ADDR_SLICE_WIDTH-1 downto 0) := (others => '0');
      signal sig_strbgen_bytes          : std_logic_vector(STRBGEN_ADDR_SLICE_WIDTH   downto 0) := (others => '0');
      
      
      
      
      begin
   
       
        -- Assign the outputs to the Write Status Controller
        data2wsc_eop         <= lsig_eop_reg and 
                                not(sig_next_calc_error_reg);
         
        data2wsc_bytes_rcvd  <= STD_LOGIC_VECTOR(lsig_byte_cntr);
        
 
 
        -- WRSTRB logic ------------------------------
      
      
      
        --sig_strbgen_bytes <= (others => '1'); -- set to the max value
      
        
        -- set the length to the max number of bytes per databeat
        sig_strbgen_bytes <=  STD_LOGIC_VECTOR(TO_UNSIGNED(BYTES_PER_DBEAT, STRBGEN_ADDR_SLICE_WIDTH+1));
        
        
        
        
        
        
        sig_strbgen_addr  <= STD_LOGIC_VECTOR(RESIZE(UNSIGNED(sig_fifo_next_sadddr_lsb), 
                                                     STRBGEN_ADDR_SLICE_WIDTH)) ;
 
 
 
      
      ------------------------------------------------------------
      -- Instance: I_STRT_STRB_GEN 
      --
      -- Description:
      --  Strobe generator used to generate the starting databeat
      -- strobe value for soft shutdown case where the S2MM has to 
      -- flush out all of the transfers that have been committed
      -- to the AXI Write address channel. Starting Strobes must
      -- match the committed address offest for each transfer. 
      -- 
      ------------------------------------------------------------
      I_STRT_STRB_GEN : entity axi_datamover_v5_1.axi_datamover_strb_gen2
      generic map (
                            
        C_OP_MODE            =>  0                         , -- 0 = Offset/Length mode
        C_STRB_WIDTH         =>  BYTES_PER_DBEAT           ,   
        C_OFFSET_WIDTH       =>  STRBGEN_ADDR_SLICE_WIDTH  ,   
        C_NUM_BYTES_WIDTH    =>  STRBGEN_ADDR_SLICE_WIDTH+1           
    
        )
      port map (
        
        start_addr_offset    =>  sig_strbgen_addr         , 
        end_addr_offset      =>  STRBGEN_ADDR_0           , -- not used in op mode 0
        num_valid_bytes      =>  sig_strbgen_bytes        , 
        strb_out             =>  sig_sfhalt_next_strt_strb   
    
        );
                                  
     


   
   

        -- Generate the WSTRB to use during soft shutdown 
        sig_halt_strb  <= sig_strt_strb_reg 
          When (sig_first_dbeat   = '1' or
                sig_single_dbeat  = '1')
          Else  (others => '1');

           
                  
        -- Generate the Write Strobes for the MMap Write Data Channel
        -- for the Indeterminate BTT case. Strobes come from the Stream
        -- input from the Indeterminate BTT module during normal operation.
        -- However, during soft shutdown, those strobes become unpredictable
        -- so generated strobes have to be used.
        data2skid_wstrb <=  sig_halt_strb
          When (sig_halt_reg = '1')
        
          Else s2mm_strm_wstrb;
          
          
          
        -- Generate the Stream Ready for the Stream input side
        sig_s2mm_strm_wready <=  sig_halt_reg             or -- force tready if a halt requested
                                 (sig_mmap2data_ready    and -- MMap is accepting the xfers
                                 sig_addr_chan_rdy       and -- xfers are commited on the address channel and 
                                 sig_dqual_rdy           and -- there are commands in the command fifo        
                                 not(sig_calc_error_reg) and -- No internal error                             
                                 not(sig_stop_wvalid));      -- Gate off stream ready immediately after a wlast for 1 clk
                                                             -- or when the soft shutdown has completed
         
        
        -- MMap Write Data Channel Valid Handshaking
        sig_data2mmap_valid <= (s2mm_strm_wvalid        or -- Normal Stream input valid       
                               sig_halt_reg       )    and -- force valid if halt requested       
                               sig_addr_chan_rdy       and -- xfers are commited on the address channel and       
                               sig_dqual_rdy           and -- there are commands in the command fifo        
                               not(sig_calc_error_reg) and -- No internal error
                               not(sig_stop_wvalid);       -- Gate off wvalid immediately after a wlast for 1 clk
                                                           -- or when the soft shutdown has completed
              
      
         
        -- TLAST Error housekeeping for Indeterminate BTT Mode
        -- There is no Underrun/overrun in Stroe and Forward mode 
         
        sig_tlast_error_ovrrun  <= '0'; -- Not used with Indeterminate BTT
        sig_tlast_error_undrrun <= '0'; -- Not used with Indeterminate BTT
        sig_end_stbs_match_err  <= '0'; -- Not used with Indeterminate BTT
        sig_tlast_error         <= '0'; -- Not used with Indeterminate BTT
        sig_tlast_error_reg     <= '0'; -- Not used with Indeterminate BTT
        sig_tlast_err_stop      <= '0'; -- Not used with Indeterminate BTT
        
        
        
        
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_EOP_REG_FLOP
        --
        -- Process Description:
        --  Register the End of Packet marker.
        --
        -------------------------------------------------------------
        IMP_EOP_REG_FLOP : process (primary_aclk)
          begin
            if (primary_aclk'event and primary_aclk = '1') then
               if (mmap_reset = '1') then
        
                 lsig_end_of_cmd_reg <= '0';
                 lsig_eop_reg        <= '0';
               
               
               Elsif (sig_good_strm_dbeat = '1') Then
               
        
                 lsig_end_of_cmd_reg <= sig_next_cmd_cmplt_reg and
                                        s2mm_strm_wlast;
                 
                 lsig_eop_reg        <= s2mm_strm_eop;
               
               else

                 null; -- hold current state  
                   
               end if; 
            end if;       
          end process IMP_EOP_REG_FLOP; 
        
        
        
        
 
        -----  Byte Counter Logic -----------------------------------------------
        -- The Byte counter reflects the actual byte count received on the 
        -- Stream input for each parent command loaded into the S2MM command
        -- FIFO. Thus it counts input bytes until the command complete qualifier
        -- is set and the TLAST input from the Stream input.
      
      
        lsig_clr_byte_cntr        <= lsig_end_of_cmd_reg and   -- Clear if a new stream packet does not start 
                                     not(sig_good_strm_dbeat); -- immediately after the previous one finished.    
        
     
        lsig_ld_byte_cntr         <= lsig_end_of_cmd_reg and -- Only load if a new stream packet starts       
                                     sig_good_strm_dbeat;    -- immediately after the previous one finished.       
        
        lsig_incr_byte_cntr       <= sig_good_strm_dbeat; 
        
        
        lsig_byte_cntr_incr_value <=  RESIZE(UNSIGNED(s2mm_stbs_asserted), 
                                                       BYTE_CNTR_WIDTH);
     
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_BYTE_CMTR
        --
        -- Process Description:
        -- Keeps a running byte count per burst packet loaded into the 
        -- xfer FIFO. It is based on the strobes set on the incoming
        -- Stream dbeat.
        --
        -------------------------------------------------------------
        IMP_BYTE_CMTR : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
               if (mmap_reset         = '1' or
                   lsig_clr_byte_cntr = '1') then 

                 lsig_byte_cntr <= (others => '0');
                 
               elsif (lsig_ld_byte_cntr = '1') then

                 lsig_byte_cntr <= lsig_byte_cntr_incr_value;
                 
               elsif (lsig_incr_byte_cntr = '1') then

                 lsig_byte_cntr <= lsig_byte_cntr + lsig_byte_cntr_incr_value;
                 
               else
                 null;  -- hold current value
               end if; 
             end if;       
           end process IMP_BYTE_CMTR; 
     
     
        
 
   
      end generate GEN_INDET_BTT;
   
   
    
    
    
    
    
    
              
    
    -- Internal logic ------------------------------
    
    sig_good_mmap_dbeat  <= sig_mmap2data_ready and 
                            sig_data2mmap_valid;
    
    
    sig_last_mmap_dbeat  <= sig_good_mmap_dbeat and 
                            sig_data2mmap_last;
     
     
    sig_get_next_dqual   <= sig_last_mmap_dbeat; 
    
    
    
    
    
    
         
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_LAST_DBEAT
    --
    -- Process Description:
    --   This implements a FLOP that creates a pulse
    -- indicating the LAST signal for an outgoing write data channel
    -- has been sent. Note that it is possible to have back to 
    -- back LAST databeats.
    --
    -------------------------------------------------------------
    REG_LAST_DBEAT : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset = '1') then

             sig_last_mmap_dbeat_reg <= '0';
             
           else
             
             sig_last_mmap_dbeat_reg <= sig_last_mmap_dbeat;
             
           end if; 
         end if;       
       end process REG_LAST_DBEAT; 
  
 
 
 
 
    
    
    -----  Write Status Interface Stuff --------------------------
    
    sig_push_to_wsc_cmplt <= sig_push_to_wsc and sig_wsc_ready;
    
    
    sig_set_push2wsc      <= (sig_good_mmap_dbeat and
                             sig_dbeat_cntr_eq_0) or
                             sig_push_err2wsc     or
                             sig_spcl_push_err2wsc;   -- Special case from CR616212
                             
    
    
    
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_INTERR_PUSH_FLOP
    --
    -- Process Description:
    -- Generate a 1 clock wide pulse when a calc error has propagated
    -- from the Command Calculator. This pulse is used to force a 
    -- push of the error status to the Write Status Controller
    -- without a AXI transfer completion.
    --
    -------------------------------------------------------------
    IMP_INTERR_PUSH_FLOP : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset       = '1' or
                sig_push_err2wsc = '1') then
              sig_push_err2wsc <= '0';
            elsif (sig_ld_new_cmd_reg = '1' and
                   sig_calc_error_reg = '1') then
              sig_push_err2wsc <= '1';
            else
              null; -- hold state
            end if; 
         end if;       
       end process IMP_INTERR_PUSH_FLOP; 
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_PUSH2WSC_FLOP
    --
    -- Process Description:
    -- Implements a Sample and hold register for the outbound status
    -- signals to the Write Status Controller (WSC). This register
    -- has to support back to back transfer completions.
    --
    -------------------------------------------------------------
    IMP_PUSH2WSC_FLOP : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset             = '1'  or
               (sig_push_to_wsc_cmplt = '1'  and
                sig_set_push2wsc      = '0')) then
              
              sig_push_to_wsc        <= '0';
              sig_data2wsc_tag       <=  (others => '0');
              sig_data2wsc_calc_err  <=  '0';
              sig_data2wsc_last_err  <=  '0';
              sig_data2wsc_cmd_cmplt <=  '0';
              
            elsif (sig_set_push2wsc   = '1' and 
                   sig_tlast_err_stop = '0') then
              
              sig_push_to_wsc        <= '1';
              sig_data2wsc_tag       <= sig_tag_reg          ;
              sig_data2wsc_calc_err  <= sig_calc_error_reg   ;
              sig_data2wsc_last_err  <= sig_tlast_error_reg or 
                                        sig_tlast_error      ;
              sig_data2wsc_cmd_cmplt <= sig_cmd_cmplt_reg   or 
                                        sig_tlast_error_reg or
                                        sig_tlast_error      ;
              
            else
              null;  -- hold current state
            end if; 
         end if;       
       end process IMP_PUSH2WSC_FLOP; 
     
  
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_LD_NEW_CMD_REG
    --
    -- Process Description:
    -- Registers the flag indicating a new command has been 
    -- loaded. Needs to be a 1 clk wide pulse.
    --
    -------------------------------------------------------------
    IMP_LD_NEW_CMD_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset         = '1' or
                sig_ld_new_cmd_reg = '1') then
              sig_ld_new_cmd_reg <= '0';
            else
              sig_ld_new_cmd_reg <= sig_ld_new_cmd;
            end if; 
         end if;       
       end process IMP_LD_NEW_CMD_REG; 
    
    
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_NXT_LEN_REG
    --
    -- Process Description:
    -- Registers the load control and length value for a command 
    -- passed to the WDC input command interface. The registered
    -- signals are used for the external Indeterminate BTT support
    -- ports.
    --
    -------------------------------------------------------------
    IMP_NXT_LEN_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset         = '1') then

              sig_s2mm_ld_nxt_len <= '0';
              sig_s2mm_wr_len     <= (others => '0');
              
            else
              sig_s2mm_ld_nxt_len <= mstr2data_cmd_valid and
                                     sig_data2mstr_cmd_ready;
              sig_s2mm_wr_len     <= mstr2data_len;
                                     
                                     
            end if; 
         end if;       
       end process IMP_NXT_LEN_REG; 
    
    
    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_DATA_CNTL_FIFO
    --
    -- If Generate Description:
     --   Omits the input data control FIFO if the requested FIFO
     -- depth is 1. The Data Qualifier Register serves as a 
     -- 1 deep FIFO by itself.
    --
    ------------------------------------------------------------
    GEN_NO_DATA_CNTL_FIFO : if (C_DATA_CNTL_FIFO_DEPTH = 1) generate
    
       
      begin

        -- Command Calculator Handshake output
        sig_data2mstr_cmd_ready <= sig_fifo_wr_cmd_ready;           
       
        sig_fifo_rd_cmd_valid   <= mstr2data_cmd_valid ;
        
        
        
        -- pre 13.1 sig_fifo_wr_cmd_ready  <= sig_dqual_reg_empty     and                                         
        -- pre 13.1                           sig_aposted_cntr_ready  and                                         
        -- pre 13.1                           not(wsc2mstr_halt_pipe) and -- The Wr Status Controller is not stalling
        -- pre 13.1                           not(sig_calc_error_reg);    -- the command execution pipe and there is  
        -- pre 13.1                                                       -- no calculation error being propagated    
        
        sig_fifo_wr_cmd_ready  <= sig_push_dqual_reg;
        
                                                              
        
        sig_fifo_next_tag         <= mstr2data_tag        ;    
        sig_fifo_next_sadddr_lsb  <= mstr2data_saddr_lsb  ;    
        sig_fifo_next_len         <= mstr2data_len        ;    
        sig_fifo_next_strt_strb   <= mstr2data_strt_strb  ;    
        sig_fifo_next_last_strb   <= mstr2data_last_strb  ;    
        sig_fifo_next_drr         <= mstr2data_drr        ;    
        sig_fifo_next_eof         <= mstr2data_eof        ;    
        sig_fifo_next_sequential  <= mstr2data_sequential ;    
        sig_fifo_next_cmd_cmplt   <= mstr2data_cmd_cmplt  ;    
        sig_fifo_next_calc_error  <= mstr2data_calc_error ;    
                                                             
             
   
      end generate GEN_NO_DATA_CNTL_FIFO;
  
  
 
    
    
    
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_DATA_CNTL_FIFO
     --
     -- If Generate Description:
     --   Includes the input data control FIFO if the requested 
     -- FIFO depth is more than 1.
     --
     ------------------------------------------------------------
     GEN_DATA_CNTL_FIFO : if (C_DATA_CNTL_FIFO_DEPTH > 1) generate

       begin

       
         -- Command Calculator Handshake output
         sig_data2mstr_cmd_ready  <= sig_fifo_wr_cmd_ready;           
         
         sig_fifo_wr_cmd_valid    <= mstr2data_cmd_valid  ;
         
         
         -- pop the fifo when dqual reg is pushed
         sig_fifo_rd_cmd_ready    <= sig_push_dqual_reg;     
                                                               

         
         
                              
         -- Format the input fifo data word
         sig_cmd_fifo_data_in  <=   mstr2data_calc_error &
                                    mstr2data_cmd_cmplt  &
                                    mstr2data_sequential &
                                    mstr2data_eof        &
                                    mstr2data_drr        &
                                    mstr2data_last_strb  &
                                    mstr2data_strt_strb  &
                                    mstr2data_len        &
                                    mstr2data_saddr_lsb  &
                                    mstr2data_tag ;
         
          
         -- Rip the output fifo data word
         sig_fifo_next_tag        <= sig_cmd_fifo_data_out((TAG_STRT_INDEX+TAG_WIDTH)-1 downto 
                                                            TAG_STRT_INDEX);                   
         sig_fifo_next_sadddr_lsb <= sig_cmd_fifo_data_out((SADDR_LSB_STRT_INDEX+SADDR_LSB_WIDTH)-1 downto 
                                                            SADDR_LSB_STRT_INDEX);
         sig_fifo_next_len        <= sig_cmd_fifo_data_out((LEN_STRT_INDEX+LEN_WIDTH)-1 downto 
                                                            LEN_STRT_INDEX);
         sig_fifo_next_strt_strb  <= sig_cmd_fifo_data_out((STRT_STRB_STRT_INDEX+STRB_WIDTH)-1 downto 
                                                            STRT_STRB_STRT_INDEX);
         sig_fifo_next_last_strb  <= sig_cmd_fifo_data_out((LAST_STRB_STRT_INDEX+STRB_WIDTH)-1 downto 
                                                            LAST_STRB_STRT_INDEX);
         sig_fifo_next_drr        <= sig_cmd_fifo_data_out(DRR_STRT_INDEX);
         sig_fifo_next_eof        <= sig_cmd_fifo_data_out(EOF_STRT_INDEX);
         sig_fifo_next_sequential <= sig_cmd_fifo_data_out(SEQUENTIAL_STRT_INDEX);
         sig_fifo_next_cmd_cmplt  <= sig_cmd_fifo_data_out(CMD_CMPLT_STRT_INDEX);
         sig_fifo_next_calc_error <= sig_cmd_fifo_data_out(CALC_ERR_STRT_INDEX);

         
         
         
         ------------------------------------------------------------
         -- Instance: I_DATA_CNTL_FIFO 
         --
         -- Description:
         -- Instance for the Command Qualifier FIFO
         --
         ------------------------------------------------------------
          I_DATA_CNTL_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
          generic map (
        
            C_DWIDTH             =>  DCTL_FIFO_WIDTH        , 
            C_DEPTH              =>  C_DATA_CNTL_FIFO_DEPTH , 
            C_IS_ASYNC           =>  USE_SYNC_FIFO          , 
            C_PRIM_TYPE          =>  FIFO_PRIM_TYPE         , 
            C_FAMILY             =>  C_FAMILY                 
           
            )
          port map (
            
            -- Write Clock and reset
            fifo_wr_reset        =>   mmap_reset            , 
            fifo_wr_clk          =>   primary_aclk          , 
            
            -- Write Side
            fifo_wr_tvalid       =>   sig_fifo_wr_cmd_valid , 
            fifo_wr_tready       =>   sig_fifo_wr_cmd_ready , 
            fifo_wr_tdata        =>   sig_cmd_fifo_data_in  , 
            fifo_wr_full         =>   open                  , 
           
           
            -- Read Clock and reset
            fifo_async_rd_reset  =>   mmap_reset            ,   
            fifo_async_rd_clk    =>   primary_aclk          , 
            
            -- Read Side
            fifo_rd_tvalid       =>   sig_fifo_rd_cmd_valid , 
            fifo_rd_tready       =>   sig_fifo_rd_cmd_ready , 
            fifo_rd_tdata        =>   sig_cmd_fifo_data_out , 
            fifo_rd_empty        =>   sig_cmd_fifo_empty      
           
            );
        

       end generate GEN_DATA_CNTL_FIFO;
         
          
    
   
  
  
  
  
  
    -- Data Qualifier Register ------------------------------------
    
    
    sig_ld_new_cmd           <= sig_push_dqual_reg              ;
    sig_dqual_rdy            <= sig_dqual_reg_full              ;
    sig_strt_strb_reg        <= sig_next_strt_strb_reg          ;
    sig_last_strb_reg        <= sig_next_last_strb_reg          ;
    sig_tag_reg              <= sig_next_tag_reg                ;
    sig_cmd_cmplt_reg        <= sig_next_cmd_cmplt_reg          ;
    sig_calc_error_reg       <= sig_next_calc_error_reg         ;
    
    sig_cmd_is_eof           <= sig_next_eof_reg                ;
    
    
    
    -- new for no bubbles between child requests
    sig_sequential_push      <= sig_good_mmap_dbeat and -- MMap handshake qualified
                                sig_last_dbeat      and -- last data beat of transfer
                                sig_next_sequential_reg;-- next queued command is sequential 
                                                        -- to the current command
    
    
    -- pre 13.1 sig_push_dqual_reg        <= (sig_sequential_push   or
    -- pre 13.1                               sig_dqual_reg_empty)  and 
    -- pre 13.1                              sig_fifo_rd_cmd_valid  and
    -- pre 13.1                              sig_aposted_cntr_ready and 
    -- pre 13.1                              not(wsc2mstr_halt_pipe);  -- The Wr Status Controller is not     
    -- pre 13.1                                                        -- stalling the command execution pipe 

    
    sig_push_dqual_reg       <= (sig_sequential_push    or
                                 sig_dqual_reg_empty)   and 
                                sig_fifo_rd_cmd_valid   and
                                sig_aposted_cntr_ready  and 
                                not(sig_calc_error_reg) and -- 13.1 addition => An error has not been propagated
                                not(wsc2mstr_halt_pipe);    -- The Wr Status Controller is not  
                                                            -- stalling the command execution pipe
                                                        







                                                         
    sig_pop_dqual_reg         <= not(sig_next_calc_error_reg) and 
                                 sig_get_next_dqual and 
                                 sig_dqual_reg_full  ; 
    
  
    -- new for no bubbles between child requests
    sig_clr_dqual_reg        <=  mmap_reset         or
                                 (sig_pop_dqual_reg and
                                 not(sig_push_dqual_reg));
  
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_DQUAL_REG
    --
    -- Process Description:
    --    This process implements a register for the Data 
    -- Control and qualifiers. It operates like a 1 deep Sync FIFO.
    --
    -------------------------------------------------------------
    IMP_DQUAL_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_clr_dqual_reg = '1') then
              
              sig_next_tag_reg         <= (others => '0');
              sig_next_strt_strb_reg   <= (others => '0');
              sig_next_last_strb_reg   <= (others => '0');
              sig_next_eof_reg         <= '0'            ;
              sig_next_sequential_reg  <= '0'            ;
              sig_next_cmd_cmplt_reg   <= '0'            ;
              sig_next_calc_error_reg  <= '0'            ;
                                                        
              sig_dqual_reg_empty      <= '1'            ;
              sig_dqual_reg_full       <= '0'            ;
                                                        
            elsif (sig_push_dqual_reg = '1') then
              
              sig_next_tag_reg        <= sig_fifo_next_tag         ;
              sig_next_strt_strb_reg  <= sig_sfhalt_next_strt_strb ;
              sig_next_last_strb_reg  <= sig_fifo_next_last_strb   ;
              sig_next_eof_reg        <= sig_fifo_next_eof         ;
              sig_next_sequential_reg <= sig_fifo_next_sequential  ;
              sig_next_cmd_cmplt_reg  <= sig_fifo_next_cmd_cmplt   ;
              sig_next_calc_error_reg <= sig_fifo_next_calc_error  ;
              
              sig_dqual_reg_empty     <= '0';
              sig_dqual_reg_full      <= '1';
              
            else
              null;  -- don't change state
            end if; 
         end if;       
       end process IMP_DQUAL_REG; 
     

  
  
  
    
    
    -- Address LS Cntr logic  --------------------------
   
    sig_addr_lsb_reg         <= STD_LOGIC_VECTOR(sig_ls_addr_cntr);
    sig_addr_incr_unsgnd     <= TO_UNSIGNED(ADDR_INCR_VALUE, C_SEL_ADDR_WIDTH);
    sig_incr_ls_addr_cntr    <= sig_good_mmap_dbeat;
    
   
   
   
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: DO_ADDR_LSB_CNTR
    --
    -- Process Description:
    --  Implements the LS Address Counter used for controlling
    -- the Write STRB  DeMux during Burst transfers
    --
    -------------------------------------------------------------
    DO_ADDR_LSB_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset         = '1' or
               (sig_pop_dqual_reg  = '1'and
                sig_push_dqual_reg = '0')) then                 -- Clear the Counter
              
              sig_ls_addr_cntr <= (others => '0');
            
            elsif (sig_push_dqual_reg = '1') then               -- Load the Counter
              
              sig_ls_addr_cntr <= unsigned(sig_fifo_next_sadddr_lsb);
            
            elsif (sig_incr_ls_addr_cntr = '1') then            -- Increment the Counter
              
              sig_ls_addr_cntr <= sig_ls_addr_cntr + sig_addr_incr_unsgnd;
            
            else
              null;  -- Hold Current value
            end if; 
         end if;       
       end process DO_ADDR_LSB_CNTR; 
    
    
    
    
    
    
    
    
    
    
    
    
   -- Address Posted Counter Logic --------------------------------------
   
    sig_addr_chan_rdy         <= not(sig_addr_posted_cntr_eq_0 or 
                                     sig_apc_going2zero)         ; -- Gates data channel xfer handshake
    
    sig_aposted_cntr_ready    <= not(sig_addr_posted_cntr_max)   ; -- Gates new command fetching
    
    sig_no_posted_cmds        <= sig_addr_posted_cntr_eq_0       ; -- Used for flushing cmds that are posted
    
 
 
 
    
    sig_incr_addr_posted_cntr <= sig_addr_posted         ;
    
    sig_decr_addr_posted_cntr <= sig_last_mmap_dbeat_reg ;
    
    sig_addr_posted_cntr_eq_0 <= '1'
      when (sig_addr_posted_cntr = ADDR_POSTED_ZERO)
      Else '0';
    
    sig_addr_posted_cntr_max <= '1'
      when (sig_addr_posted_cntr = ADDR_POSTED_MAX)
      Else '0';
    
    
    sig_addr_posted_cntr_eq_1 <= '1'
      when (sig_addr_posted_cntr = ADDR_POSTED_ONE)
      Else '0';
    
    sig_apc_going2zero  <= sig_addr_posted_cntr_eq_1 and
                           sig_decr_addr_posted_cntr and
                           not(sig_incr_addr_posted_cntr);
    
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_ADDR_POSTED_FIFO_CNTR
    --
    -- Process Description:
    --    This process implements a counter for the tracking  
    -- if an Address has been posted on the AXI address channel.
    -- The Data Controller must wait for an address to be posted
    -- before proceeding with the corresponding data transfer on
    -- the Data Channel. The counter is also used to track flushing
    -- operations where all transfers commited on the  AXI Address
    -- Channel have to be completed before a halt can occur.
    -------------------------------------------------------------
    IMP_ADDR_POSTED_FIFO_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sig_addr_posted_cntr <= ADDR_POSTED_ZERO;
              
            elsif (sig_incr_addr_posted_cntr = '1' and
                   sig_decr_addr_posted_cntr = '0' and
                   sig_addr_posted_cntr_max  = '0') then
              
              sig_addr_posted_cntr <= sig_addr_posted_cntr + ADDR_POSTED_ONE ;
              
            elsif (sig_incr_addr_posted_cntr = '0' and
                   sig_decr_addr_posted_cntr = '1' and
                   sig_addr_posted_cntr_eq_0 = '0') then
              
              sig_addr_posted_cntr <= sig_addr_posted_cntr - ADDR_POSTED_ONE ;
              
            else
              null;  -- don't change state
            end if; 
         end if;       
       end process IMP_ADDR_POSTED_FIFO_CNTR; 
 
 
      
      
      
    ------- First/Middle/Last Dbeat detimination -------------------
     
     sig_new_len_eq_0 <= '1'
       When  (sig_fifo_next_len = LEN_OF_ZERO)
       else '0';
     
     
      
      
     -------------------------------------------------------------
     -- Synchronous Process with Sync Reset
     --
     -- Label: DO_FIRST_MID_LAST
     --
     -- Process Description:
     --  Implements the detection of the First/Mid/Last databeat of
     -- a transfer.
     --
     -------------------------------------------------------------
     DO_FIRST_MID_LAST : process (primary_aclk)
        begin
          if (primary_aclk'event and primary_aclk = '1') then
             if (mmap_reset = '1') then
               
               sig_first_dbeat   <= '0';
               sig_last_dbeat    <= '0';
               sig_single_dbeat  <= '0';
             
             elsif (sig_ld_new_cmd = '1') then
               
               sig_first_dbeat   <= not(sig_new_len_eq_0);
               sig_last_dbeat    <= sig_new_len_eq_0;
               sig_single_dbeat  <= sig_new_len_eq_0;
             
             Elsif (sig_dbeat_cntr_eq_1 = '1' and
                    sig_good_mmap_dbeat = '1') Then
             
               sig_first_dbeat   <= '0';
               sig_last_dbeat    <= '1';
               sig_single_dbeat  <= '0';
             
             Elsif (sig_dbeat_cntr_eq_0 = '0' and
                    sig_dbeat_cntr_eq_1 = '0' and
                    sig_good_mmap_dbeat = '1') Then
             
               sig_first_dbeat   <= '0';
               sig_last_dbeat    <= '0';
               sig_single_dbeat  <= '0';
             
             else
               null; -- hold current state
             end if; 
          end if;       
        end process DO_FIRST_MID_LAST; 
    
    
   
   
   
   -------  Data Controller Halted Indication ------------------------------- 
    
 
    data2all_dcntlr_halted <= sig_no_posted_cmds or
                              sig_calc_error_reg;
 
 
    
    
       
       
       
       
       
       
    
    
   -------  Data Beat counter logic ------------------------------- 
    
    
    
    
    
    sig_dbeat_cntr_int  <= TO_INTEGER(sig_dbeat_cntr);
    
    sig_dbeat_cntr_eq_0 <= '1'
      when (sig_dbeat_cntr_int = 0)
      Else '0';
    
    sig_dbeat_cntr_eq_1 <= '1'
      when (sig_dbeat_cntr_int = 1)
      Else '0';
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: DO_DBEAT_CNTR
    --
    -- Process Description:
    -- Implements the transfer data beat counter used to track 
    -- progress of the transfer.
    --
    -------------------------------------------------------------
    DO_DBEAT_CNTR : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              sig_dbeat_cntr <= (others => '0');
            elsif (sig_ld_new_cmd = '1') then
              sig_dbeat_cntr <= unsigned(sig_fifo_next_len);
            Elsif (sig_good_mmap_dbeat = '1' and
                   sig_dbeat_cntr_eq_0 = '0') Then
              sig_dbeat_cntr <= sig_dbeat_cntr-1;
            else
              null; -- Hold current state
            end if; 
         end if;       
       end process DO_DBEAT_CNTR; 
  
  
  
  
  
  
  
  
  
  
  
  
   -------  Soft Shutdown Logic ------------------------------- 
    
    
    
    
    
    -- Formulate the soft shutdown complete flag
    sig_data2rst_stop_cmplt  <= (sig_halt_reg_dly3        and   -- Normal Mode shutdown
                                 sig_no_posted_cmds       and 
                                 not(sig_calc_error_reg)) or
                                (sig_halt_reg_dly3  and         -- Shutdown after error trap
                                 sig_calc_error_reg);
    
    
              
    
    -- Generate a gate signal to deassert the WVALID output
    -- for 1 clock cycle after a WLAST is issued. This only 
    -- occurs when in soft shutdown mode. 
    sig_stop_wvalid  <= (sig_last_mmap_dbeat_reg and
                        sig_halt_reg) or
                        sig_data2rst_stop_cmplt;
  
  
    
    
    
    -- Assign the output port skid buf control for the
    -- input Stream skid buffer
    data2skid_halt      <= sig_data2skid_halt;
    
    -- Create a 1 clock wide pulse to tell the input
    -- stream skid buffer to shut down.
    sig_data2skid_halt  <=  sig_halt_reg_dly2 and 
                            not(sig_halt_reg_dly3);
    
    
  
  
     
     
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_HALT_REQ_REG
    --
    -- Process Description:
    --   Implements the flop for capturing the Halt request from 
    -- the Reset module.
    --
    -------------------------------------------------------------
    IMP_HALT_REQ_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sig_halt_reg      <= '0';
            
            elsif (rst2data_stop_request = '1') then
              
              sig_halt_reg <= '1';
            
            else
              null;  -- Hold current State
            end if; 
         end if;       
       end process IMP_HALT_REQ_REG; 
  
  
   
   
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_HALT_REQ_REG_DLY
    --
    -- Process Description:
    --   Implements the flops for delaying the halt request by 3
    -- clocks to allow the Address Controller to halt before the
    -- Data Contoller can safely indicate it has exhausted all
    -- transfers committed to the AXI Address Channel by the Address
    -- Controller.
    --
    -------------------------------------------------------------
    IMP_HALT_REQ_REG_DLY : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then
              
              sig_halt_reg_dly1 <= '0';
              sig_halt_reg_dly2 <= '0';
              sig_halt_reg_dly3 <= '0';
            
            else
              
              sig_halt_reg_dly1 <= sig_halt_reg;
              sig_halt_reg_dly2 <= sig_halt_reg_dly1;
              sig_halt_reg_dly3 <= sig_halt_reg_dly2;
            
            end if; 
         end if;       
       end process IMP_HALT_REQ_REG_DLY; 
  
  
   
    
    
    
    
    
    
 
  end implementation;
