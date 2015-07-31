  -------------------------------------------------------------------------------
  -- axi_datamover_s2mm_realign.vhd
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
  -- Filename:        axi_datamover_s2mm_realign.vhd
  --
  -- Description:
  --    This file implements the S2MM Data Realignment module. THe S2MM direction is
  --  more complex than the MM2S direction since the DRE needs to be upstream from
  --  the Write Data Controller. This requires the S2MM DRE to be running 2 to
  --  3 clocks ahead of the Write Data controller to minimize/eliminate xfer
  --  bubble insertion.
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
  use axi_datamover_v5_1.axi_datamover_s2mm_dre;
  use axi_datamover_v5_1.axi_datamover_s2mm_scatter;

  -------------------------------------------------------------------------------

  entity axi_datamover_s2mm_realign is
    generic (

      C_ENABLE_INDET_BTT     : Integer range  0 to   1 :=  0;
        -- Specifies if the IBTT Indeterminate BTT Module is enabled
        -- for use (outside of this module)
      
      C_INCLUDE_DRE          : Integer range  0 to   1 :=  1;
        -- Includes/Omits the S2MM DRE
        -- 0 = Omit
        -- 1 = Include
      
      C_DRE_CNTL_FIFO_DEPTH  : Integer range  1 to  32 :=  1;
        -- Specifies the depth of the internal command queue fifo
      
      C_DRE_ALIGN_WIDTH      : Integer range  1 to   3 :=  2;
        -- Sets the width of the DRE alignment control ports
      
      C_SUPPORT_SCATTER      : Integer range  0 to   1 :=  1;
        -- Includes/Omits the Scatter functionality
        -- 0 = omit
        -- 1 = include
    C_ENABLE_S2MM_TKEEP             : integer range 0 to 1 := 1; 
      
      C_BTT_USED             : Integer range  8 to  23 := 16;
        -- Indicates the width of the input command BTT that is actually
        -- used
      
      C_STREAM_DWIDTH        : Integer range  8 to 1024 := 32;
        -- Sets the width of the Input and Output Stream Data ports
      
      C_TAG_WIDTH            : Integer range  1 to   8 :=  4;
        --  Sets the width of the input command Tag port
      
      C_STRT_SF_OFFSET_WIDTH : Integer range 1 to 7 := 1 ;
        -- Sets the width of the Store and Forward Start offset ports
      
      C_FAMILY               : String                  := "virtex7"
        -- specifies the target FPGA familiy
      

      );
    port (

      -- Clock and Reset Inputs -------------------------------------------
                                                                         --
      primary_aclk         : in  std_logic;                              --
         -- Primary synchronization clock for the Master side            --
         -- interface and internal logic. It is also used                --
         -- for the User interface synchronization when                  --
         -- C_STSCMD_IS_ASYNC = 0.                                       --
                                                                         --
      -- Reset input                                                     --
      mmap_reset           : in  std_logic;                              --
         -- Reset used for the internal master logic                     --
      ---------------------------------------------------------------------


       
     -- Write Data Controller or IBTT Indeterminate BTT I/O  -------------------------
                                                                                    --
      wdc2dre_wready      : In  std_logic;                                          --
        -- Write READY input from WDC or SF                                         --
                                                                                    --
      dre2wdc_wvalid      : Out  std_logic;                                         --
        -- Write VALID output to WDC or SF                                          --
                                                                                    --
      dre2wdc_wdata       : Out  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);      --
        -- Write DATA output to WDC or SF                                           --
                                                                                    --
      dre2wdc_wstrb       : Out  std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);  --
        -- Write DATA output to WDC or SF                                           --
                                                                                    --
      dre2wdc_wlast       : Out  std_logic;                                         --
        -- Write LAST output to WDC or SF                                           --
                                                                                    --
      dre2wdc_eop         : Out  std_logic;                                         --
        -- End of Packet indicator for the Stream input to WDC or SF                --
      --------------------------------------------------------------------------------



      -- Starting offset output for the Store and Forward Modules  -------------------
                                                                                    --
      dre2sf_strt_offset  : Out std_logic_vector(C_STRT_SF_OFFSET_WIDTH-1 downto 0);--
        -- Outputs the starting offset of a transfer. This is used with Store       --
        -- and Forward Packer/Unpacker logic                                        --
      --------------------------------------------------------------------------------

    

     -- AXI Slave Stream In ----------------------------------------------------------
                                                                                    --
      s2mm_strm_wready   : Out  Std_logic;                                          --
        -- AXI Stream READY input                                                   --
                                                                                    --
      s2mm_strm_wvalid   : In  std_logic;                                           --
        -- AXI Stream VALID Output                                                  --
                                                                                    --
      s2mm_strm_wdata    : In  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);        --
        -- AXI Stream data output                                                   --
                                                                                    --
      s2mm_strm_wstrb    : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);     --
        -- AXI Stream STRB output                                                   --
                                                                                    --
      s2mm_strm_wlast    : In std_logic;                                            --
        -- AXI Stream LAST output                                                   --
      --------------------------------------------------------------------------------



      -- Command Calculator Interface ---------------------------------------------------
                                                                                       --
      dre2mstr_cmd_ready      : Out std_logic ;                                        --
        -- Indication from the DRE that the command is being                           --
        -- accepted from the Command Calculator                                        --
                                                                                       --
      mstr2dre_cmd_valid      : In std_logic;                                          --
        -- The next command valid indication to the DRE                                --
        -- from the Command Calculator                                                 --
                                                                                       --
      mstr2dre_tag            : In std_logic_vector(C_TAG_WIDTH-1 downto 0);           --
        -- The next command tag                                                        --
                                                                                       --
      mstr2dre_dre_src_align  : In std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);     --
        -- The source (input) alignment for the DRE                                    --
                                                                                       --
      mstr2dre_dre_dest_align : In std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);     --
        -- The destinstion (output) alignment for the DRE                              --
                                                                                       --
      mstr2dre_btt            : In std_logic_vector(C_BTT_USED-1 downto 0);            --
        -- The bytes to transfer value for the input command                           --
                                                                                       --
      mstr2dre_drr            : In std_logic;                                          --
        -- The starting tranfer of a sequence of transfers                             --
                                                                                       --
      mstr2dre_eof            : In std_logic;                                          --
        -- The endiing tranfer of a sequence of transfers                              --
                                                                                       --
      mstr2dre_cmd_cmplt      : In std_logic;                                          --
        -- The last tranfer command of a sequence of transfers                         --
        -- spawned from a single parent command                                        --
                                                                                       --
      mstr2dre_calc_error     : In std_logic;                                          --
        -- Indication if the next command in the calculation pipe                      --
        -- has a calculation error                                                     --
                                                                                       --
      mstr2dre_strt_offset    : In std_logic_vector(C_STRT_SF_OFFSET_WIDTH-1 downto 0);--
        -- Outputs the starting offset of a transfer. This is used with Store          --
        -- and Forward Packer/Unpacker logic                                           --
      -----------------------------------------------------------------------------------



      -- Premature TLAST assertion error flag -----------------------------
                                                                         --
      dre2all_tlast_error     : Out std_logic;                           --
        -- When asserted, this indicates the DRE detected                --
        -- a Early/Late TLAST assertion on the incoming data stream.     --
      ---------------------------------------------------------------------



      -- DRE Halted Status ------------------------------------------------
                                                                         --
      dre2all_halted          : Out std_logic                            --
        -- When asserted, this indicates the DRE has satisfied           --
        -- all pending transfers queued by the command calculator        --
        -- and is halted.                                                --
      ---------------------------------------------------------------------



      );

  end entity axi_datamover_s2mm_realign;


  architecture implementation of axi_datamover_s2mm_realign  is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";



    -- Function Declarations  --------------------------------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_size_realign_fifo
    --
    -- Function Description:
    --  Assures that the Realigner cmd fifo depth is at least 4 deep else it
    -- is equal to the pipe depth.
    --
    -------------------------------------------------------------------
    function funct_size_realign_fifo (pipe_depth : integer) return integer is
    
      Variable temp_fifo_depth : Integer := 4;
    
    begin
    
      If (pipe_depth < 4) Then
    
        temp_fifo_depth := 4;
      
      Else 

        temp_fifo_depth := pipe_depth;
          
      End if;
      
      
      Return (temp_fifo_depth);
      
      
    end function funct_size_realign_fifo;
    


    -- Constant Declarations  --------------------------------------------


    Constant BYTE_WIDTH            : integer := 8; -- bits
    Constant STRM_NUM_BYTE_LANES   : integer := C_STREAM_DWIDTH/BYTE_WIDTH;
    Constant STRM_STRB_WIDTH       : integer := STRM_NUM_BYTE_LANES;
    Constant SLICE_WIDTH           : integer := BYTE_WIDTH+2; -- 8 data bits plus Strobe plus TLAST bit
    Constant SLICE_STROBE_INDEX    : integer := (BYTE_WIDTH-1)+1;
    Constant SLICE_TLAST_INDEX     : integer := SLICE_STROBE_INDEX+1;
    Constant ZEROED_SLICE          : std_logic_vector(SLICE_WIDTH-1 downto 0) := (others => '0');
    Constant USE_SYNC_FIFO         : integer := 0;
    Constant REG_FIFO_PRIM         : integer := 0;
    Constant BRAM_FIFO_PRIM        : integer := 1;
    Constant SRL_FIFO_PRIM         : integer := 2;
    Constant FIFO_PRIM_TYPE        : integer := SRL_FIFO_PRIM;
    Constant TAG_WIDTH             : integer := C_TAG_WIDTH;
    Constant SRC_ALIGN_WIDTH       : integer := C_DRE_ALIGN_WIDTH;
    Constant DEST_ALIGN_WIDTH      : integer := C_DRE_ALIGN_WIDTH;
    Constant BTT_WIDTH             : integer := C_BTT_USED;
    Constant DRR_WIDTH             : integer := 1;
    Constant EOF_WIDTH             : integer := 1;
    Constant SEQUENTIAL_WIDTH      : integer := 1;
    Constant CALC_ERR_WIDTH        : integer := 1;
    Constant SF_OFFSET_WIDTH       : integer := C_STRT_SF_OFFSET_WIDTH;
    
    
    Constant BTT_OF_ZERO           : std_logic_vector(BTT_WIDTH-1 downto 0)
                                     := (others => '0');

    
    
    Constant DRECTL_FIFO_DEPTH     : integer := funct_size_realign_fifo(C_DRE_CNTL_FIFO_DEPTH);
    
    
    Constant DRECTL_FIFO_WIDTH     : Integer := TAG_WIDTH        +  -- Tag field
                                                SRC_ALIGN_WIDTH  +  -- Source align field width
                                                DEST_ALIGN_WIDTH +  -- Dest align field width
                                                BTT_WIDTH        +  -- BTT field width
                                                DRR_WIDTH        +  -- DRE Re-alignment Request Flag Field
                                                EOF_WIDTH        +  -- EOF flag field
                                                SEQUENTIAL_WIDTH +  -- Sequential command flag
                                                CALC_ERR_WIDTH   +  -- Calc error flag
                                                SF_OFFSET_WIDTH;    -- Store and Forward Offset

    Constant TAG_STRT_INDEX        : integer := 0;
    Constant SRC_ALIGN_STRT_INDEX  : integer := TAG_STRT_INDEX + TAG_WIDTH;
    Constant DEST_ALIGN_STRT_INDEX : integer := SRC_ALIGN_STRT_INDEX + SRC_ALIGN_WIDTH;
    Constant BTT_STRT_INDEX        : integer := DEST_ALIGN_STRT_INDEX + DEST_ALIGN_WIDTH;
    Constant DRR_STRT_INDEX        : integer := BTT_STRT_INDEX + BTT_WIDTH;
    Constant EOF_STRT_INDEX        : integer := DRR_STRT_INDEX + DRR_WIDTH;
    Constant SEQUENTIAL_STRT_INDEX : integer := EOF_STRT_INDEX + EOF_WIDTH;
    Constant CALC_ERR_STRT_INDEX   : integer := SEQUENTIAL_STRT_INDEX+SEQUENTIAL_WIDTH;
    Constant SF_OFFSET_STRT_INDEX  : integer := CALC_ERR_STRT_INDEX+CALC_ERR_WIDTH;
    
    
    
    Constant INCLUDE_DRE           : boolean := (C_INCLUDE_DRE    = 1  and
                                                 C_STREAM_DWIDTH <= 64 and
                                                 C_STREAM_DWIDTH >= 16);
                                                 
    Constant OMIT_DRE              : boolean := not(INCLUDE_DRE);



   
    -- Type Declarations  --------------------------------------------
    
    type TYPE_CMD_CNTL_SM is (
                INIT,
                LD_DRE_SCATTER_FIRST,
                CHK_POP_FIRST       ,
                LD_DRE_SCATTER_SECOND,
                CHK_POP_SECOND,
                ERROR_TRAP
                );





    -- Signal Declarations  --------------------------------------------
    
    Signal sig_cmdcntl_sm_state        : TYPE_CMD_CNTL_SM := INIT;
    Signal sig_cmdcntl_sm_state_ns     : TYPE_CMD_CNTL_SM := INIT;
    signal sig_sm_ld_dre_cmd_ns        : std_logic := '0';
    signal sig_sm_ld_dre_cmd           : std_logic := '0';
    signal sig_sm_ld_scatter_cmd_ns    : std_logic := '0';
    signal sig_sm_ld_scatter_cmd       : std_logic := '0';
    signal sig_sm_pop_cmd_fifo_ns      : std_logic := '0';
    signal sig_sm_pop_cmd_fifo         : std_logic := '0';

    signal sig_cmd_fifo_data_in        : std_logic_vector(DRECTL_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_cmd_fifo_data_out       : std_logic_vector(DRECTL_FIFO_WIDTH-1 downto 0) := (others => '0');
    signal sig_fifo_wr_cmd_valid       : std_logic := '0';
    signal sig_fifo_wr_cmd_ready       : std_logic := '0';
    signal sig_curr_tag_reg            : std_logic_vector(TAG_WIDTH-1 downto 0)        := (others => '0');
    signal sig_curr_src_align_reg      : std_logic_vector(SRC_ALIGN_WIDTH-1 downto 0)  := (others => '0');
    signal sig_curr_dest_align_reg     : std_logic_vector(DEST_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_curr_btt_reg            : std_logic_vector(BTT_WIDTH-1 downto 0)        := (others => '0');
    signal sig_curr_drr_reg            : std_logic := '0';
    signal sig_curr_eof_reg            : std_logic := '0';
    signal sig_curr_cmd_cmplt_reg      : std_logic := '0';
    signal sig_curr_calc_error_reg     : std_logic := '0';
    signal sig_dre_align_ready         : std_logic := '0';
    signal sig_dre_use_autodest        : std_logic := '0';
    signal sig_dre_src_align           : std_logic_vector(SRC_ALIGN_WIDTH-1 downto 0)  := (others => '0');
    signal sig_dre_dest_align          : std_logic_vector(DEST_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_dre_flush               : std_logic := '0';
    signal sig_dre2wdc_tstrb           : std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0) := (others => '0');
    signal sig_dre2wdc_tdata           : std_logic_vector(C_STREAM_DWIDTH-1 downto 0)     := (others => '0');
    signal sig_dre2wdc_tlast           : std_logic := '0';
    signal sig_dre2wdc_tvalid          : std_logic := '0';
    signal sig_wdc2dre_tready          : std_logic := '0';
    signal sig_tlast_err0r             : std_logic := '0';
    signal sig_dre_halted              : std_logic := '0';
    signal sig_strm2scatter_tstrb      : std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0) := (others => '0');
    signal sig_strm2scatter_tdata      : std_logic_vector(C_STREAM_DWIDTH-1 downto 0)     := (others => '0');
    signal sig_strm2scatter_tlast      : std_logic := '0';
    signal sig_strm2scatter_tvalid     : std_logic := '0';
    signal sig_scatter2strm_tready     : std_logic := '0';
    signal sig_scatter2dre_tstrb       : std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0) := (others => '0');
    signal sig_scatter2dre_tdata       : std_logic_vector(C_STREAM_DWIDTH-1 downto 0)     := (others => '0');
    signal sig_scatter2dre_tlast       : std_logic := '0';
    signal sig_scatter2dre_tvalid      : std_logic := '0';
    signal sig_dre2scatter_tready      : std_logic := '0';
    signal sig_scatter2dre_flush       : std_logic := '0';
    signal sig_scatter2drc_eop         : std_logic := '0';
    signal sig_scatter2dre_src_align   : std_logic_vector(SRC_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_scatter2drc_cmd_ready   : std_logic := '0';
    signal sig_drc2scatter_push_cmd    : std_logic;
    signal sig_drc2scatter_btt         : std_logic_vector(BTT_WIDTH-1 downto 0);
    signal sig_drc2scatter_eof         : std_logic;
    signal sig_scatter2all_tlast_error : std_logic := '0';
    signal sig_need_cmd_flush          : std_logic := '0';
    signal sig_fifo_rd_cmd_valid       : std_logic := '0';
    signal sig_curr_strt_offset_reg    : std_logic_vector(SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
    signal sig_ld_strt_offset          : std_logic := '0';
    signal sig_output_strt_offset_reg  : std_logic_vector(SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
    signal sig_dre2sf_strt_offset      : std_logic_vector(SF_OFFSET_WIDTH-1 downto 0) := (others => '0');




  begin --(architecture implementation)


    -------------------------------------------------------------
    -- Port connections


    -- Input Stream Attachment
    s2mm_strm_wready        <= sig_scatter2strm_tready ;
    sig_strm2scatter_tvalid <= s2mm_strm_wvalid        ;
    sig_strm2scatter_tdata  <= s2mm_strm_wdata         ;
    sig_strm2scatter_tstrb  <= s2mm_strm_wstrb         ;
    sig_strm2scatter_tlast  <= s2mm_strm_wlast         ;



    -- Write Data Controller Stream Attachment
    sig_wdc2dre_tready   <= wdc2dre_wready     ;
    dre2wdc_wvalid       <= sig_dre2wdc_tvalid ;
    dre2wdc_wdata        <= sig_dre2wdc_tdata  ;
    dre2wdc_wstrb        <= sig_dre2wdc_tstrb  ;
    dre2wdc_wlast        <= sig_dre2wdc_tlast  ;
    

    -- Status/Error flags
    dre2all_tlast_error  <= sig_tlast_err0r   ;
    dre2all_halted       <= sig_dre_halted    ;


    -- Store and Forward Starting Offset Output
    dre2sf_strt_offset   <= sig_dre2sf_strt_offset ;





    -------------------------------------------------------------
    -- Internal logic


    sig_dre_halted    <= sig_dre_align_ready;



  
  
    -------------------------------------------------------------
    -- DRE Handshake signals

    sig_dre_src_align        <= sig_curr_src_align_reg ;
    sig_dre_dest_align       <= sig_curr_dest_align_reg;

    sig_dre_use_autodest     <= '0';  -- not used
    sig_dre_flush            <= '0';  -- not used



 
  -------------------------------------------------------------------------
  -------- Realigner Command FIFO and controls 
  -------------------------------------------------------------------------
 
    -- Command Calculator Handshake
    sig_fifo_wr_cmd_valid    <= mstr2dre_cmd_valid   ;
    dre2mstr_cmd_ready       <= sig_fifo_wr_cmd_ready;




    -- Format the input fifo data word
    sig_cmd_fifo_data_in     <= mstr2dre_strt_offset    &
                                mstr2dre_calc_error     &
                                mstr2dre_cmd_cmplt      &
                                mstr2dre_eof            &
                                mstr2dre_drr            &
                                mstr2dre_btt            &
                                mstr2dre_dre_dest_align &
                                mstr2dre_dre_src_align  &
                                mstr2dre_tag ;


    -- Rip the output fifo data word
    sig_curr_tag_reg         <= sig_cmd_fifo_data_out((TAG_STRT_INDEX+TAG_WIDTH)-1 downto TAG_STRT_INDEX);
    sig_curr_src_align_reg   <= sig_cmd_fifo_data_out((SRC_ALIGN_STRT_INDEX+SRC_ALIGN_WIDTH)-1 downto SRC_ALIGN_STRT_INDEX);
    sig_curr_dest_align_reg  <= sig_cmd_fifo_data_out((DEST_ALIGN_STRT_INDEX+DEST_ALIGN_WIDTH)-1 downto DEST_ALIGN_STRT_INDEX);
    sig_curr_btt_reg         <= sig_cmd_fifo_data_out((BTT_STRT_INDEX+BTT_WIDTH)-1 downto BTT_STRT_INDEX);
    sig_curr_drr_reg         <= sig_cmd_fifo_data_out(DRR_STRT_INDEX);
    sig_curr_eof_reg         <= sig_cmd_fifo_data_out(EOF_STRT_INDEX);
    sig_curr_cmd_cmplt_reg   <= sig_cmd_fifo_data_out(SEQUENTIAL_STRT_INDEX);
    sig_curr_calc_error_reg  <= sig_cmd_fifo_data_out(CALC_ERR_STRT_INDEX);
    sig_curr_strt_offset_reg <= sig_cmd_fifo_data_out((SF_OFFSET_STRT_INDEX+SF_OFFSET_WIDTH)-1 downto SF_OFFSET_STRT_INDEX);



    ------------------------------------------------------------
    -- Instance: I_DRE_CNTL_FIFO
    --
    -- Description:
    -- Instance for the DRE Control FIFO
    --
    ------------------------------------------------------------
     I_DRE_CNTL_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
     generic map (

       C_DWIDTH             =>  DRECTL_FIFO_WIDTH      , 
       C_DEPTH              =>  DRECTL_FIFO_DEPTH  , 
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
       fifo_rd_tready       =>   sig_sm_pop_cmd_fifo   , 
       fifo_rd_tdata        =>   sig_cmd_fifo_data_out , 
       fifo_rd_empty        =>   open                    

       );





 
 
  -------------------------------------------------------------------------
  -------- DRE and Scatter Command Loader State Machine 
  -------------------------------------------------------------------------
 

   
    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: CMDCNTL_SM_COMBINATIONAL
    --
    -- Process Description:
    -- Command Controller State Machine combinational implementation
    -- The design is based on the premise that for every parent 
    -- command loaded into the S2MM, the Realigner can be loaded with
    -- 1 or 2 commands spawned from it. The first command is used to 
    -- align ensuing transfers (in MMap space) to a max burst address 
    -- boundary. Then, if the parent command's BTT value is not satisfied
    -- after the first command completes, a second command is generated
    -- and loaded in the Realigner for the remaining BTT value. The 
    -- command complete bit in the Realigner command indicates if the
    -- first command the final command or the second command (if needed)
    -- is the final command,
    -------------------------------------------------------------
    CMDCNTL_SM_COMBINATIONAL : process (sig_cmdcntl_sm_state      ,
                                        sig_fifo_rd_cmd_valid     ,
                                        sig_dre_align_ready       ,
                                        sig_scatter2drc_cmd_ready ,
                                        sig_need_cmd_flush        ,
                                        sig_curr_cmd_cmplt_reg    ,
                                        sig_curr_calc_error_reg
                                       )
       
       begin

         -- SM Defaults
         sig_cmdcntl_sm_state_ns   <=  INIT;
         sig_sm_ld_dre_cmd_ns      <=  '0';
         sig_sm_ld_scatter_cmd_ns  <=  '0';
         sig_sm_pop_cmd_fifo_ns    <=  '0';
         


         case sig_cmdcntl_sm_state is

           --------------------------------------------
           when INIT =>

             sig_cmdcntl_sm_state_ns  <=  LD_DRE_SCATTER_FIRST;

           
           
           --------------------------------------------
           when LD_DRE_SCATTER_FIRST =>

             If  (sig_fifo_rd_cmd_valid   = '1' and
                  sig_curr_calc_error_reg = '1') Then   
            
               sig_cmdcntl_sm_state_ns  <=  ERROR_TRAP;
             
             
             elsif (sig_fifo_rd_cmd_valid     = '1' and
                    sig_dre_align_ready       = '1' and
                    sig_scatter2drc_cmd_ready = '1') Then

               sig_cmdcntl_sm_state_ns   <=  CHK_POP_FIRST ;
               sig_sm_ld_dre_cmd_ns      <=  '1';
               sig_sm_ld_scatter_cmd_ns  <=  '1';
               sig_sm_pop_cmd_fifo_ns    <=  '1';

             else

               sig_cmdcntl_sm_state_ns <=  LD_DRE_SCATTER_FIRST;

             End if;



           --------------------------------------------
           when CHK_POP_FIRST =>

             If (sig_curr_cmd_cmplt_reg = '1') Then
               
               sig_cmdcntl_sm_state_ns <=  LD_DRE_SCATTER_FIRST;
             
             Else 
             
               sig_cmdcntl_sm_state_ns <=  LD_DRE_SCATTER_SECOND;
             
             
             End if;
            
             

           --------------------------------------------
           when LD_DRE_SCATTER_SECOND =>

             If  (sig_fifo_rd_cmd_valid   = '1' and
                  sig_curr_calc_error_reg = '1') Then   
            
               sig_cmdcntl_sm_state_ns  <=  ERROR_TRAP;
             
             elsif (sig_fifo_rd_cmd_valid  = '1' and
                    sig_need_cmd_flush     = '1') Then
             
               sig_cmdcntl_sm_state_ns   <=  CHK_POP_SECOND ;
               sig_sm_pop_cmd_fifo_ns    <=  '1';
             
             
             elsif (sig_fifo_rd_cmd_valid     = '1' and
                    sig_dre_align_ready       = '1' and
                    sig_scatter2drc_cmd_ready = '1') Then

               sig_cmdcntl_sm_state_ns   <=  CHK_POP_FIRST ;
               sig_sm_ld_dre_cmd_ns      <=  '1';
               sig_sm_ld_scatter_cmd_ns  <=  '1';
               sig_sm_pop_cmd_fifo_ns    <=  '1';

             else

               sig_cmdcntl_sm_state_ns <=  LD_DRE_SCATTER_SECOND;

             End if;



           --------------------------------------------
           when CHK_POP_SECOND =>

             sig_cmdcntl_sm_state_ns   <=  LD_DRE_SCATTER_FIRST ;


           --------------------------------------------
           when ERROR_TRAP =>

             sig_cmdcntl_sm_state_ns   <=  ERROR_TRAP ;



           --------------------------------------------
           when others =>

             sig_cmdcntl_sm_state_ns <=  INIT;

         end case;



       end process CMDCNTL_SM_COMBINATIONAL;



     
     
     

    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: CMDCNTL_SM_REGISTERED
    --
    -- Process Description:
    -- Command Controller State Machine registered implementation
    --
    -------------------------------------------------------------
    CMDCNTL_SM_REGISTERED : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset = '1') then

              sig_cmdcntl_sm_state  <= INIT;
              sig_sm_ld_dre_cmd     <= '0' ;
              sig_sm_ld_scatter_cmd <= '0' ;
              sig_sm_pop_cmd_fifo   <= '0' ;

            else

              sig_cmdcntl_sm_state  <= sig_cmdcntl_sm_state_ns   ;
              sig_sm_ld_dre_cmd     <= sig_sm_ld_dre_cmd_ns      ;
              sig_sm_ld_scatter_cmd <= sig_sm_ld_scatter_cmd_ns  ;
              sig_sm_pop_cmd_fifo   <= sig_sm_pop_cmd_fifo_ns    ;
              
            end if;
         end if;
       end process CMDCNTL_SM_REGISTERED;








   
  
  
  

  -------------------------------------------------------------------------
  -------- DRE Instance and controls 
  -------------------------------------------------------------------------
 



    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_DRE
    --
    -- If Generate Description:
    --  Includes the instance for the DRE
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_DRE : if (INCLUDE_DRE) generate

      signal lsig_eop_reg                : std_logic := '0';
      signal lsig_dre_load_beat          : std_logic := '0';
      signal lsig_dre_tlast_output_beat  : std_logic := '0';
      signal lsig_set_eop                : std_logic := '0';
      signal lsig_tlast_err_reg1         : std_logic := '0';
      signal lsig_tlast_err_reg2         : std_logic := '0';
      
      signal lsig_push_strt_offset_reg   : std_logic_vector(SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
      signal lsig_pushreg_full           : std_logic := '0';
      signal lsig_pushreg_empty          : std_logic := '0';
      
      signal lsig_pull_strt_offset_reg   : std_logic_vector(SF_OFFSET_WIDTH-1 downto 0) := (others => '0');
      signal lsig_pullreg_full           : std_logic := '0';
      signal lsig_pullreg_empty          : std_logic := '0';
     
      signal lsig_pull_new_offset        : std_logic := '0';
      signal lsig_push_new_offset        : std_logic := '0';
     
     
     
     
      begin


        ------------------------------------------------------------
        -- Instance: I_S2MM_DRE_BLOCK
        --
        -- Description:
        --  Instance for the S2MM Data Realignment Engine (DRE)
        --
        ------------------------------------------------------------
        I_S2MM_DRE_BLOCK : entity axi_datamover_v5_1.axi_datamover_s2mm_dre
        generic map (

          C_DWIDTH          =>  C_STREAM_DWIDTH            , 
          C_ALIGN_WIDTH     =>  C_DRE_ALIGN_WIDTH            

          )
        port map (

         -- Clock and Reset
          dre_clk           =>  primary_aclk               , 
          dre_rst           =>  mmap_reset                 , 

         -- Alignment Control (Independent from Stream Input timing)
          dre_align_ready   =>  sig_dre_align_ready        , 
          dre_align_valid   =>  sig_sm_ld_dre_cmd          , 
          dre_use_autodest  =>  sig_dre_use_autodest       , 
          dre_src_align     =>  sig_scatter2dre_src_align  , 
          dre_dest_align    =>  sig_dre_dest_align         , 

         -- Flush Control (Aligned to input Stream timing)
          dre_flush         =>  sig_scatter2dre_flush      , 

         -- Stream Inputs
          dre_in_tstrb      =>  sig_scatter2dre_tstrb      , 
          dre_in_tdata      =>  sig_scatter2dre_tdata      , 
          dre_in_tlast      =>  sig_scatter2dre_tlast      , 
          dre_in_tvalid     =>  sig_scatter2dre_tvalid     , 
          dre_in_tready     =>  sig_dre2scatter_tready     , 


         -- Stream Outputs
          dre_out_tstrb     =>  sig_dre2wdc_tstrb          , 
          dre_out_tdata     =>  sig_dre2wdc_tdata          , 
          dre_out_tlast     =>  sig_dre2wdc_tlast          , 
          dre_out_tvalid    =>  sig_dre2wdc_tvalid         , 
          dre_out_tready    =>  sig_wdc2dre_tready           

          );






        lsig_dre_load_beat         <= sig_scatter2dre_tvalid and
                                      sig_dre2scatter_tready;
        
        
        lsig_set_eop               <=  sig_scatter2drc_eop and
                                       lsig_dre_load_beat ;
        
        
        lsig_dre_tlast_output_beat <=  sig_dre2wdc_tvalid and
                                       sig_wdc2dre_tready and
                                       sig_dre2wdc_tlast;
        
        
         dre2wdc_eop               <=  lsig_dre_tlast_output_beat and
                                       lsig_eop_reg;
        
        
        
         
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_EOP_REG
        --
        -- Process Description:
        --   Implements a flop for holding the EOP from the Scatter
        -- Engine until the corresponding packet clears out of the DRE.
        -- THis is used to transfer the EOP marker to the DRE output
        -- stream without the need for the DRE to pass it through.
        --
        -------------------------------------------------------------
        IMP_EOP_REG : process (primary_aclk)
          begin
            if (primary_aclk'event and primary_aclk = '1') then
               if (mmap_reset                 = '1' or
                  (lsig_dre_tlast_output_beat = '1' and
                   lsig_set_eop               = '0')) then
        
                 lsig_eop_reg  <= '0';
        
               elsif (lsig_set_eop = '1') then
        
                 lsig_eop_reg <= '1';
        
               else
                 
                 null;  -- Hold current state
        
               end if; 
            end if;       
          end process IMP_EOP_REG; 
         
         
         
        

       
       
          -- Delay TLAST Error by 2 clocks to compensate for DRE minimum
          -- delay of 2 clocks for the stream data.
          sig_tlast_err0r         <= lsig_tlast_err_reg2;
         
         
       
          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_TLAST_ERR_DELAY
          --
          -- Process Description:
          --   Implements a 2 clock delay to better align the TLAST
          -- error detection with the Stream output data to the WDC
          -- which has a minimum 2 clock delay through the DRE.
          --
          -------------------------------------------------------------
          IMP_TLAST_ERR_DELAY : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset = '1') then
          
                   lsig_tlast_err_reg1 <= '0';
                   lsig_tlast_err_reg2 <= '0';
          
                 else
          
                   lsig_tlast_err_reg1 <= sig_scatter2all_tlast_error;
                   lsig_tlast_err_reg2 <= lsig_tlast_err_reg1;
          
                 end if; 
              end if;       
            end process IMP_TLAST_ERR_DELAY; 
       
     
     
     
     
       
          -------------------------------------------------------------------------
          -- Store and Forward Start Address Offset Registers Logic 
          --       Push-pull register is used to to time align the starting address 
          --       offset (ripped from the Realigner command via parsing) to DRE 
          --       TLAST output timing. The offset output of the pull register must
          --       be valid on the first output databeat of the DRE to the Store and
          --       Forward module.
          -------------------------------------------------------------------------
          
          sig_dre2sf_strt_offset <= lsig_pull_strt_offset_reg;
        
          --    lsig_push_new_offset   <= sig_dre_align_ready and
          --                              sig_gated_dre_align_valid ;
          
          lsig_push_new_offset   <= sig_sm_ld_dre_cmd ;
        
        
        
        
        
          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_PUSH_STRT_OFFSET_REG
          --
          -- Process Description:
          --   Implements the input register for holding the starting address 
          -- offset sent to the external Store and Forward functions.
          --
          -------------------------------------------------------------
          IMP_PUSH_STRT_OFFSET_REG : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset = '1') then
          
                   lsig_push_strt_offset_reg <= (others => '0');
                   lsig_pushreg_full         <= '0';
                   lsig_pushreg_empty        <= '1';
          
                 elsif (lsig_push_new_offset = '1') then
          
                   lsig_push_strt_offset_reg <= sig_curr_strt_offset_reg;
                   lsig_pushreg_full         <= '1';
                   lsig_pushreg_empty        <= '0';
          
                 elsif (lsig_pull_new_offset = '1') then
          
                   lsig_push_strt_offset_reg <= (others => '0');
                   lsig_pushreg_full         <= '0';
                   lsig_pushreg_empty        <= '1';
          
                 else
          
                   null;  -- Hold Current State
          
                 end if; 
              end if;       
            end process IMP_PUSH_STRT_OFFSET_REG; 
        
        
           
           
          
          -- Pull the next offset (if one exists) into the pull register  
          -- when the DRE outputs a TLAST. If the pull register is empty 
          -- and the push register has an offset, then push the new value 
          -- into the pull register.   
          lsig_pull_new_offset <= (sig_dre2wdc_tlast   and  
                                   sig_dre2wdc_tvalid  and 
                                   sig_wdc2dre_tready) or
                                  (lsig_pushreg_full   and 
                                   lsig_pullreg_empty);
        
                                                          
                                                          
                                                          
          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_PULL_STRT_OFFSET_REG
          --
          -- Process Description:
          --   Implements the output register for holding the starting  
          -- address offset sent to the Store and Forward modul's upsizer
          -- logic.
          --
          -------------------------------------------------------------
          IMP_PULL_STRT_OFFSET_REG : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset = '1') then
          
                   lsig_pull_strt_offset_reg <= (others => '0');
                   lsig_pullreg_full         <= '0';
                   lsig_pullreg_empty        <= '1';
          
                 elsif (lsig_pull_new_offset = '1' and
                        lsig_pushreg_full    = '1') then
          
                   lsig_pull_strt_offset_reg <= lsig_push_strt_offset_reg;
                   lsig_pullreg_full         <= '1';
                   lsig_pullreg_empty        <= '0';
          
                 elsif (lsig_pull_new_offset = '1' and
                        lsig_pushreg_full    = '0') then
          
                   lsig_pull_strt_offset_reg <= (others => '0');
                   lsig_pullreg_full         <= '0';
                   lsig_pullreg_empty        <= '1';
          
                 else
          
                   null;  -- Hold Current State
          
                 end if; 
              end if;       
            end process IMP_PULL_STRT_OFFSET_REG; 
        
        
        
        
        
        


      end generate GEN_INCLUDE_DRE;






    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_OMIT_DRE
    --
    -- If Generate Description:
    --   Omits the DRE from the Re-aligner.
    --
    --
    ------------------------------------------------------------
    GEN_OMIT_DRE : if (OMIT_DRE) generate

       begin

          
          -- DRE always ready
          sig_dre_align_ready     <= '1';
          
          
          --    -- Let the Scatter engine control the Realigner command
          --    -- flow.
          --    sig_dre_align_ready     <= sig_scatter2drc_cmd_ready;


          -- Pass through signal connections
          sig_dre2wdc_tstrb       <= sig_scatter2dre_tstrb  ;
          sig_dre2wdc_tdata       <= sig_scatter2dre_tdata  ;
          sig_dre2wdc_tlast       <= sig_scatter2dre_tlast  ;
          sig_dre2wdc_tvalid      <= sig_scatter2dre_tvalid ;
          sig_dre2scatter_tready  <= sig_wdc2dre_tready     ;

          dre2wdc_eop             <=  sig_scatter2drc_eop   ;


          
          -- Just pass TLAST Error through when no DRE is present
          sig_tlast_err0r         <= sig_scatter2all_tlast_error;
         
      
      
         
          -------------------------------------------------------------------------
          -------- Store and Forward Start Address Offset Register Logic 
          -------------------------------------------------------------------------
         
          sig_dre2sf_strt_offset <=  sig_output_strt_offset_reg;
          
          
          sig_ld_strt_offset <= sig_sm_ld_dre_cmd;
        
        
            
          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_STRT_OFFSET_OUTPUT
          --
          -- Process Description:
          --   Implements the register for holding the starting address 
          -- offset sent to the S2MM Store and Forward module's upsizer
          -- logic.
          --
          -------------------------------------------------------------
          IMP_STRT_OFFSET_OUTPUT : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset = '1') then
          
                   sig_output_strt_offset_reg <= (others => '0');
          
                 elsif (sig_ld_strt_offset = '1') then
          
                   sig_output_strt_offset_reg <= sig_curr_strt_offset_reg;
          
                 else
          
                   null;  -- Hold Current State
          
                 end if; 
              end if;       
            end process IMP_STRT_OFFSET_OUTPUT; 
        
        
        
        
        
  
         
         
       end generate GEN_OMIT_DRE;








    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_SCATTER
    --
    -- If Generate Description:
    -- This IfGen implements the Scatter function which is a pre-
    -- processor for the S2MM DRE. The scatter function breaks up
    -- a continous input stream of data into constituant parts
    -- as described by a set of loaded commands that together
    -- describe an entire input packet.
    --
    ------------------------------------------------------------
    GEN_INCLUDE_SCATTER : if (C_SUPPORT_SCATTER = 1) generate


      begin


        -- Load the Scatter Engine command when the DRE command
        -- is loaded
        
        --    sig_drc2scatter_push_cmd <= sig_dre_align_ready and
        --                                sig_gated_dre_align_valid;

        
        sig_drc2scatter_push_cmd <= sig_sm_ld_scatter_cmd ;
        
        
        
        
        
        
        -- Assign the new Bytes to Transfer (BTT) qualifier for the
        -- Scatter Engine
        sig_drc2scatter_btt      <= sig_curr_btt_reg;

        -- Assign the new End of Frame (EOF) qualifier for the
        -- Scatter Engine
        sig_drc2scatter_eof      <= sig_curr_eof_reg;


       ------------------------------------------------------------
       -- Instance: I_S2MM_SCATTER
       --
       -- Description:
       --  Instance for the Scatter Engine. This block breaks up a
       --  input stream per commands loaded.
       --
       ------------------------------------------------------------
       I_S2MM_SCATTER : entity axi_datamover_v5_1.axi_datamover_s2mm_scatter
       generic map (

         C_ENABLE_INDET_BTT       =>  C_ENABLE_INDET_BTT        , 
         C_DRE_ALIGN_WIDTH        =>  C_DRE_ALIGN_WIDTH         ,
          C_ENABLE_S2MM_TKEEP       =>  C_ENABLE_S2MM_TKEEP        ,
         C_BTT_USED               =>  BTT_WIDTH                 ,
         C_STREAM_DWIDTH          =>  C_STREAM_DWIDTH           ,
         C_FAMILY                 =>  C_FAMILY

         )
       port map (

         -- Clock input & Reset input
         primary_aclk             => primary_aclk               ,  
         mmap_reset               => mmap_reset                 ,  

        -- DRE Realign Controller I/O  ----------------------------
         scatter2drc_cmd_ready    => sig_scatter2drc_cmd_ready  ,  
         drc2scatter_push_cmd     => sig_drc2scatter_push_cmd   ,  
         drc2scatter_btt          => sig_drc2scatter_btt        ,  
         drc2scatter_eof          => sig_drc2scatter_eof        ,  

        -- DRE Source Alignment -----------------------------------
         scatter2drc_src_align    => sig_scatter2dre_src_align ,  

        -- AXI Slave Stream In -----------------------------------
         s2mm_strm_tready         => sig_scatter2strm_tready   ,  
         s2mm_strm_tvalid         => sig_strm2scatter_tvalid   ,  
         s2mm_strm_tdata          => sig_strm2scatter_tdata    ,  
         s2mm_strm_tstrb          => sig_strm2scatter_tstrb    ,  
         s2mm_strm_tlast          => sig_strm2scatter_tlast    ,  

        -- Stream Out to S2MM DRE ---------------------------------
         drc2scatter_tready       => sig_dre2scatter_tready    ,  
         scatter2drc_tvalid       => sig_scatter2dre_tvalid    ,  
         scatter2drc_tdata        => sig_scatter2dre_tdata     ,  
         scatter2drc_tstrb        => sig_scatter2dre_tstrb     ,  
         scatter2drc_tlast        => sig_scatter2dre_tlast     ,  
         scatter2drc_flush        => sig_scatter2dre_flush     ,  
         scatter2drc_eop          => sig_scatter2drc_eop       ,  

         -- Premature TLAST assertion error flag
         scatter2drc_tlast_error  => sig_scatter2all_tlast_error  

         );




      end generate GEN_INCLUDE_SCATTER;









    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_OMIT_SCATTER
    --
    -- If Generate Description:
    --   This IfGen omits the Scatter pre-processor.
    --
    --
    ------------------------------------------------------------
    GEN_OMIT_SCATTER : if (C_SUPPORT_SCATTER = 0) generate


       begin

        -- Just housekeep the signaling
        
        sig_scatter2drc_cmd_ready   <= '1'                     ;
        sig_scatter2drc_eop         <= sig_strm2scatter_tlast  ;    
        sig_scatter2dre_src_align   <= sig_dre_src_align       ;
        sig_scatter2all_tlast_error <= '0'                     ;
        sig_scatter2dre_flush       <= sig_dre_flush           ;
        sig_scatter2dre_tstrb       <= sig_strm2scatter_tstrb  ;
        sig_scatter2dre_tdata       <= sig_strm2scatter_tdata  ;
        sig_scatter2dre_tlast       <= sig_strm2scatter_tlast  ;
        sig_scatter2dre_tvalid      <= sig_strm2scatter_tvalid ;
        sig_scatter2strm_tready     <= sig_dre2scatter_tready  ;

        
        
       end generate GEN_OMIT_SCATTER;




    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_OMIT_INDET_BTT
    --
    -- If Generate Description:
    --    Omit and special logic for Indeterminate BTT support.
    --
    --
    ------------------------------------------------------------
    GEN_OMIT_INDET_BTT : if (C_ENABLE_INDET_BTT = 0) generate
    
    
       begin
  
         sig_need_cmd_flush        <= '0'                 ; -- not needed without Indeterminate BTT
  
    
       end generate GEN_OMIT_INDET_BTT;





    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ENABLE_INDET_BTT
    --
    -- If Generate Description:
    --   Include logic for the case when Indeterminate BTT is
    -- included as part of the S2MM. In this mode, the actual 
    -- length of input stream packets is not known when the S2MM
    -- is loaded with a transfer command. 
    --
    ------------------------------------------------------------
    GEN_ENABLE_INDET_BTT : if (C_ENABLE_INDET_BTT = 1) generate
    
  
       signal lsig_clr_cmd_flush        : std_logic := '0';
       signal lsig_set_cmd_flush        : std_logic := '0';
       signal lsig_cmd_set_fetch_pause  : std_logic := '0';
       signal lsig_cmd_clr_fetch_pause  : std_logic := '0';
       signal lsig_cmd_fetch_pause      : std_logic := '0';
       
       
       begin
  
  
         
          lsig_cmd_set_fetch_pause <= sig_drc2scatter_push_cmd    and
                                      not(sig_curr_cmd_cmplt_reg) and
                                      not(sig_need_cmd_flush);
         
          lsig_cmd_clr_fetch_pause <= sig_scatter2dre_tvalid and
                                      sig_dre2scatter_tready and
                                      sig_scatter2dre_tlast;
         
         
          -------------------------------------------------------------
          -- Synchronous Process with Sync Reset
          --
          -- Label: IMP_CMD_FETCH_PAUSE
          --
          -- Process Description:
          --   Implements the flop for the flag that causes the command
          -- queue manager to pause fetching the next command if the 
          -- current command does not have the command complete bit set.
          -- The pause remains set until the associated TLAST for the 
          -- command is output from the Scatter Engine. If the Tlast is
          -- also accompanied by a EOP and the pause is set, then the 
          -- ensuing command (which will have the cmd cmplt bit set) must
          -- be flushed from the queue and not loaded into the Scatter
          -- Engine or DRE, This is normally associated with indeterminate
          -- packets that are actually shorter than the intial align to 
          -- max burst child command sent to the Realigner, The next loaded
          -- child command is to finish the remainder of the indeterminate 
          -- packet up to the full BTT value in the original parent command.
          -- This child command becomes stranded in the Realigner command fifo
          -- and has to be flushed.
          --
          -------------------------------------------------------------
          IMP_CMD_FETCH_PAUSE : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset               = '1' or
                     lsig_cmd_clr_fetch_pause = '1') then
          
                   lsig_cmd_fetch_pause <= '0';
          
                 elsif (lsig_cmd_set_fetch_pause = '1') then
          
                   lsig_cmd_fetch_pause <= '1';
          
                 else
          
                   null; -- Hold current state
          
                 end if; 
              end if;       
            end process IMP_CMD_FETCH_PAUSE; 
         
         
         
         
         
         
         
         
         -- Clear the flush needed flag when the command with the command
         -- complete marker is popped off of the command queue.
         lsig_clr_cmd_flush  <= sig_need_cmd_flush and 
                                sig_sm_pop_cmd_fifo;
         
         
         -- The command queue has to be flushed if the stream EOP marker
         -- is transfered out of the Scatter Engine when the corresponding
         -- command being executed does not have the command complete
         -- marker set.
         lsig_set_cmd_flush  <= lsig_cmd_fetch_pause    and
                                sig_scatter2dre_tvalid  and
                                sig_dre2scatter_tready  and
                                sig_scatter2drc_eop;
         
  
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_CMD_FLUSH_FLOP
         --
         -- Process Description:
         --   Implements the flop for holding the command flush flag.
         -- This is only needed in Indeterminate BTT mode.
         --
         -------------------------------------------------------------
         IMP_CMD_FLUSH_FLOP : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (mmap_reset         = '1' or
                    lsig_clr_cmd_flush = '1') then
         
                  sig_need_cmd_flush <= '0';
         
                elsif (lsig_set_cmd_flush = '1') then
         
                  sig_need_cmd_flush <= '1';
         
                else
         
                  null;  -- Hold current state
         
                end if; 
             end if;       
           end process IMP_CMD_FLUSH_FLOP; 
  
  
    
       end generate GEN_ENABLE_INDET_BTT;





  end implementation;
