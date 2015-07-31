  -------------------------------------------------------------------------------
  -- axi_datamover_s2mm_scatter.vhd
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
  -- Filename:        axi_datamover_s2mm_scatter.vhd
  --
  -- Description:     
  --    This file implements the S2MM Scatter support module. Scatter requires 
  --    the input Stream to be stopped and disected at command boundaries. The 
  --    Scatter module splits the input stream data at the command boundaries 
  --    and force feeds the S2MM DRE with data and source alignment.                   
  --                  
  --                  
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all;
  
  
  library axi_datamover_v5_1;
  use axi_datamover_v5_1.axi_datamover_strb_gen2;
  use axi_datamover_v5_1.axi_datamover_mssai_skid_buf;
  use axi_datamover_v5_1.axi_datamover_fifo;
  use axi_datamover_v5_1.axi_datamover_slice;
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_s2mm_scatter is
    generic (
      
      C_ENABLE_INDET_BTT     : Integer range  0 to   1 :=  0;
        -- Indicates if the IBTT Indeterminate BTT is enabled
        -- (external to this module)
      
      C_DRE_ALIGN_WIDTH      : Integer range  1 to   3 :=  2;
        -- Sets the width of the S2MM DRE alignment control ports
      
      C_BTT_USED             : Integer range  8 to  23 := 16;
        -- Sets the width of the BTT input port 
      
      C_STREAM_DWIDTH        : Integer range  8 to 1024 := 32;
        -- Sets the width of the input and output data streams
    C_ENABLE_S2MM_TKEEP             : integer range 0 to 1 := 1;       
      C_FAMILY               : String  := "virtex7"
        -- Specifies the target FPGA device family
      
      
      );
    port (
      
      -- Clock and Reset inputs --------------------------------------------------
                                                                                --
      primary_aclk          : in  std_logic;                                    --
         -- Primary synchronization clock for the Master side                   --
         -- interface and internal logic. It is also used                       --
         -- for the User interface synchronization when                         --
         -- C_STSCMD_IS_ASYNC = 0.                                              --
                                                                                --
      -- Reset input                                                            --
      mmap_reset            : in  std_logic;                                    --
         -- Reset used for the internal master logic                            --
      ----------------------------------------------------------------------------
      
     
      
     -- DRE Realign Controller I/O  ----------------------------------------------
                                                                                --
      scatter2drc_cmd_ready : Out std_logic;                                    --
        -- Indicates the Scatter Engine is ready to accept a new command        --
                                                                                --
      drc2scatter_push_cmd  : In  std_logic;                                    --
        -- Indicates a new command is being read from the command que           --
                                                                                --
      drc2scatter_btt       : In  std_logic_vector(C_BTT_USED-1 downto 0);      --
        -- Indicates the new command's BTT value                                --
                                                                                --
      drc2scatter_eof       : In  std_logic;                                    --
        -- Indicates that the input command is also the last of a packet        --
        -- This input is ignored when C_ENABLE_INDET_BTT = 1                    --
      ----------------------------------------------------------------------------
     
 
 
     -- DRE Source Alignment ---------------------------------------------------------
                                                                                    --
      scatter2drc_src_align : Out  std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0);  --
        -- Indicates the next source alignment to the DRE control                   --
      --------------------------------------------------------------------------------
     
     
 
      
     -- AXI Slave Stream In ----------------------------------------------------------
                                                                                    --
      s2mm_strm_tready      : Out  Std_logic;                                       --
        -- AXI Stream READY input                                                   --
                                                                                    --
      s2mm_strm_tvalid      : In  std_logic;                                        --
        -- AXI Stream VALID Output                                                  --
                                                                                    --
      s2mm_strm_tdata       : In  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);     --    
        -- AXI Stream data output                                                   --
                                                                                    --
      s2mm_strm_tstrb       : In std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0);  --       
        -- AXI Stream STRB output                                                   --
                                                                                    --
      s2mm_strm_tlast       : In std_logic;                                         --
        -- AXI Stream LAST output                                                   --
      --------------------------------------------------------------------------------
               
                
                
     -- Stream Out to S2MM DRE -------------------------------------------------------
                                                                                    --
      drc2scatter_tready    : In  Std_logic;                                        --
        -- S2MM DRE Stream READY input                                              --
                                                                                    --
      scatter2drc_tvalid    : Out  std_logic;                                       --
        -- S2MM DRE VALID Output                                                    --
                                                                                    --
      scatter2drc_tdata     : Out  std_logic_vector(C_STREAM_DWIDTH-1 downto 0);    --     
        -- S2MM DRE data output                                                     --
                                                                                    --
      scatter2drc_tstrb     : Out std_logic_vector((C_STREAM_DWIDTH/8)-1 downto 0); --        
        -- S2MM DRE STRB output                                                     --
                                                                                    --
      scatter2drc_tlast     : Out std_logic;                                        --
        -- S2MM DRE LAST output                                                     --
                                                                                    --
      scatter2drc_flush     : Out std_logic;                                        --
        -- S2MM DRE LAST output                                                     --
                                                                                    --
      scatter2drc_eop       : Out std_logic;                                        --
        -- S2MM DRE End of Packet marker                                            --
      --------------------------------------------------------------------------------
      
      
               
                
      -- Premature TLAST assertion error flag ---------------------------------------
                                                                                   --
      scatter2drc_tlast_error  : Out std_logic                                     --
         -- When asserted, this indicates the scatter Engine detected              --
         -- a Early/Late TLAST assertion on the incoming data stream               --
         -- relative to the commands given to the DataMover Cmd FIFO.              --
      -------------------------------------------------------------------------------      
      
      
      );
  
  end entity axi_datamover_s2mm_scatter;
  
  
  architecture implementation of axi_datamover_s2mm_scatter  is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    
    -- Function declaration   ----------------------------------------
    
     -------------------------------------------------------------------
     -- Function
     --
     -- Function Name: get_start_index
     --
     -- Function Description:
     --      This function calculates the bus bit index corresponding
     -- to the MSB of the Slice lane index input and the Slice width.
     --
     -------------------------------------------------------------------
     function get_start_index (lane_index : integer;
                               lane_width : integer)
                               return integer is

        Variable bit_index_start : Integer := 0;

     begin

        bit_index_start := lane_index*lane_width;

        return(bit_index_start);

     end function get_start_index;


     -------------------------------------------------------------------
     -- Function
     --
     -- Function Name: get_end_index
     --
     -- Function Description:
     --      This function calculates the bus bit index corresponding
     -- to the LSB of the Slice lane index input and the Slice width.
     --
     -------------------------------------------------------------------
     function get_end_index (lane_index : integer;
                             lane_width : integer)
                             return integer is

        Variable bit_index_end   : Integer := 0;

     begin

        bit_index_end   := (lane_index*lane_width) + (lane_width-1);

        return(bit_index_end);

     end function get_end_index;



    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_num_offset_bits
    --
    -- Function Description:
    --  This function calculates the number of bits needed for specifying 
    -- a byte lane offset for the input transfer data width. 
    --
    -------------------------------------------------------------------
    function func_num_offset_bits (stream_dwidth_value : integer) return integer is
    
      Variable num_offset_bits_needed : Integer range 1 to 7 := 1;
    
    begin
    
      case stream_dwidth_value is
        when 8 => -- 1 byte lanes
          num_offset_bits_needed := 1;
        when 16 => -- 2 byte lanes
          num_offset_bits_needed := 1;
        when 32 => -- 4 byte lanes
          num_offset_bits_needed := 2;
        when 64 => -- 8 byte lanes
          num_offset_bits_needed := 3;
        when 128 => -- 16 byte lanes
          num_offset_bits_needed := 4;
        when 256 => -- 32 byte lanes
          num_offset_bits_needed := 5;
        when 512 => -- 64 byte lanes
          num_offset_bits_needed := 6;
        
        when others => -- 1024 bits with 128 byte lanes
          num_offset_bits_needed := 7;
      end case;
      
      Return (num_offset_bits_needed);
       
    end function func_num_offset_bits;
    
   
    function func_fifo_prim (stream_dwidth_value : integer) return integer is
    
      Variable prim_needed : Integer range 0 to 2 := 1;
    
    begin
    
      case stream_dwidth_value is
        when 8 => -- 1 byte lanes
          prim_needed := 2;
        when 16 => -- 2 byte lanes
          prim_needed := 2;
        when 32 => -- 4 byte lanes
          prim_needed := 2;
        when 64 => -- 8 byte lanes
          prim_needed := 2;
        when 128 => -- 16 byte lanes
          prim_needed := 0;
        when others => -- 256 bits and above
          prim_needed := 0;
      end case;
      
      Return (prim_needed);
       
    end function func_fifo_prim;
     
    
    -- Constant Declarations  -------------------------------------------------
   
    Constant LOGIC_LOW           : std_logic := '0';
    Constant LOGIC_HIGH          : std_logic := '0';
    
    Constant BYTE_WIDTH          : integer := 8; -- bits
    Constant STRM_NUM_BYTE_LANES : integer := C_STREAM_DWIDTH/BYTE_WIDTH;
    Constant STRM_STRB_WIDTH     : integer := STRM_NUM_BYTE_LANES;
    Constant SLICE_WIDTH         : integer := BYTE_WIDTH+2; -- 8 data bits plus Strobe plus TLAST bit
    Constant SLICE_STROBE_INDEX  : integer := (BYTE_WIDTH-1)+1;
    Constant SLICE_TLAST_INDEX   : integer := SLICE_STROBE_INDEX+1;
    Constant ZEROED_SLICE        : std_logic_vector(SLICE_WIDTH-1 downto 0) := (others => '0');
    Constant CMD_BTT_WIDTH       : Integer := C_BTT_USED;
    Constant BTT_OF_ZERO         : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0'); 
    Constant MAX_BTT_INCR        : integer := C_STREAM_DWIDTH/8;
    Constant NUM_OFFSET_BITS     : integer := func_num_offset_bits(C_STREAM_DWIDTH);
      -- Minimum Number of bits needed to represent the byte lane position within the Stream Data
    Constant NUM_INCR_BITS       : integer := NUM_OFFSET_BITS+1;
      -- Minimum Number of bits needed to represent the maximum per dbeat increment value
    
    Constant OFFSET_ONE          : unsigned(NUM_OFFSET_BITS-1 downto 0) := TO_UNSIGNED(1 , NUM_OFFSET_BITS);
    Constant OFFSET_MAX          : unsigned(NUM_OFFSET_BITS-1 downto 0) := TO_UNSIGNED(STRM_STRB_WIDTH - 1 , NUM_OFFSET_BITS);
    Constant INCR_MAX            : unsigned(NUM_INCR_BITS-1 downto 0) := TO_UNSIGNED(MAX_BTT_INCR , NUM_INCR_BITS);

    
    
    
    Constant MSSAI_INDEX_WIDTH   : integer := NUM_OFFSET_BITS;
    
    Constant TSTRB_FIFO_DEPTH    : integer := 16;
    
    Constant TSTRB_FIFO_DWIDTH   : integer := 1                 +    -- TLAST Bit
                                              1                 +    -- EOF Bit
                                              1                 +    -- Freeze Bit
                                              MSSAI_INDEX_WIDTH +    -- MSSAI Value
                                              STRM_STRB_WIDTH*C_ENABLE_S2MM_TKEEP ;      -- Strobe Value
    
    
    
    
    
    Constant USE_SYNC_FIFO       : integer := 0;
    Constant REG_FIFO_PRIM       : integer := 0; 
    Constant BRAM_FIFO_PRIM      : integer := 1; 
    Constant SRL_FIFO_PRIM       : integer := 2; 
    Constant FIFO_PRIM           : integer := func_fifo_prim(C_STREAM_DWIDTH);   
   
    Constant FIFO_TLAST_INDEX    : integer := TSTRB_FIFO_DWIDTH-1;
    Constant FIFO_EOF_INDEX      : integer := FIFO_TLAST_INDEX-1;
    Constant FIFO_FREEZE_INDEX   : integer := FIFO_EOF_INDEX-1;
    Constant FIFO_MSSAI_MS_INDEX : integer := FIFO_FREEZE_INDEX-1;
    Constant FIFO_MSSAI_LS_INDEX : integer := FIFO_MSSAI_MS_INDEX - (MSSAI_INDEX_WIDTH-1);
    Constant FIFO_TSTRB_MS_INDEX : integer := FIFO_MSSAI_LS_INDEX-1;
    Constant FIFO_TSTRB_LS_INDEX : integer := 0;
    
    

    -- Types ------------------------------------------------------------------
    
    type byte_lane_type is array(STRM_NUM_BYTE_LANES-1 downto 0) of
                    std_logic_vector(SLICE_WIDTH-1 downto 0);

      
    
    
    -- Signal Declarations  ---------------------------------------------------

    signal sig_good_strm_dbeat         : std_logic := '0';
    signal sig_strm_tready             : std_logic := '0';
    signal sig_strm_tvalid             : std_logic := '0';
    signal sig_strm_tdata              : std_logic_vector(C_STREAM_DWIDTH-1 downto 0) := (others => '0');
    signal sig_strm_tstrb              : std_logic_vector(STRM_NUM_BYTE_LANES-1 downto 0) := (others => '0');
    signal sig_strm_tlast              : std_logic := '0';
    signal sig_drc2scatter_tready      : std_logic := '0';
    signal sig_scatter2drc_tvalid      : std_logic := '0';
    signal sig_scatter2drc_tdata       : std_logic_vector(C_STREAM_DWIDTH-1 downto 0) := (others => '0');
    signal sig_scatter2drc_tstrb       : std_logic_vector(STRM_NUM_BYTE_LANES-1 downto 0) := (others => '0');
    signal sig_scatter2drc_tlast       : std_logic := '0';
    signal sig_scatter2drc_flush       : std_logic := '0';
    signal sig_valid_dre_output_dbeat  : std_logic := '0';
    signal sig_ld_cmd                  : std_logic := '0';
    signal sig_cmd_full                : std_logic := '0';
    signal sig_cmd_empty               : std_logic := '0';
    signal sig_drc2scatter_push_cmd    : std_logic := '0';
    signal sig_drc2scatter_btt         : std_logic_vector(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_drc2scatter_eof         : std_logic := '0';
    signal sig_btt_offset_slice        : unsigned(NUM_OFFSET_BITS-1 downto 0) := (others => '0');
    signal sig_curr_strt_offset        : unsigned(NUM_OFFSET_BITS-1 downto 0) := (others => '0');
    signal sig_next_strt_offset        : unsigned(NUM_OFFSET_BITS-1 downto 0) := (others => '0');
    signal sig_next_dre_src_align      : std_logic_vector(C_DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
    signal sig_curr_dbeat_offset       : std_logic_vector(NUM_OFFSET_BITS-1 downto 0) := (others => '0');
    signal sig_cmd_sof                 : std_logic := '0';
    signal sig_curr_eof_reg            : std_logic := '0';
    signal sig_btt_cntr                : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_btt_cntr_dup                : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    Attribute KEEP : string; -- declaration
    Attribute EQUIVALENT_REGISTER_REMOVAL : string; -- declaration
    Attribute KEEP of sig_btt_cntr_dup : signal is "TRUE"; -- definition
    Attribute EQUIVALENT_REGISTER_REMOVAL of sig_btt_cntr_dup : signal is "no";
    signal sig_ld_btt_cntr             : std_logic := '0';
    signal sig_decr_btt_cntr           : std_logic := '0';
    signal sig_btt_cntr_decr_value     : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_btt_stb_gen_slice       : std_logic_vector(NUM_INCR_BITS-1 downto 0) := (others => '0');
    signal sig_btt_eq_0                : std_logic := '0';
    signal sig_btt_lteq_max_first_incr : std_logic := '0';
    signal sig_btt_gteq_max_incr       : std_logic := '0';
    signal sig_max_first_increment     : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_btt_cntr_prv            : unsigned(CMD_BTT_WIDTH-1 downto 0) := (others => '0');
    signal sig_btt_eq_0_pre_reg        : std_logic := '0';
    signal sig_set_tlast_error         : std_logic := '0';
    signal sig_tlast_error_over        : std_logic := '0';
    signal sig_tlast_error_under       : std_logic := '0';
    signal sig_tlast_error_exact       : std_logic := '0';
    signal sig_tlast_error_reg         : std_logic := '0';
    signal sig_stbgen_tstrb            : std_logic_vector(STRM_NUM_BYTE_LANES-1 downto 0) := (others => '0');
    signal sig_tlast_error_out         : std_logic := '0';
    signal sig_freeze_it               : std_logic := '0';
    signal sig_tstrb_fifo_data_in      : std_logic_vector(TSTRB_FIFO_DWIDTH-1 downto 0);
    signal sig_tstrb_fifo_data_out     : std_logic_vector(TSTRB_FIFO_DWIDTH-1 downto 0);
    signal slice_insert_data     : std_logic_vector(TSTRB_FIFO_DWIDTH-1 downto 0);
    signal slice_insert_ready          : std_logic := '0';
    signal slice_insert_valid        : std_logic := '0';
    signal sig_tstrb_fifo_rdy          : std_logic := '0';
    signal sig_tstrb_fifo_valid        : std_logic := '0';
    signal sig_valid_fifo_ld           : std_logic := '0';
    signal sig_fifo_tlast_out          : std_logic := '0';
    signal sig_fifo_eof_out            : std_logic := '0';
    signal sig_fifo_freeze_out         : std_logic := '0';
    signal sig_fifo_tstrb_out          : std_logic_vector(STRM_STRB_WIDTH-1 downto 0);
    signal sig_tstrb_valid             : std_logic := '0';
    signal sig_get_tstrb               : std_logic := '0';
    signal sig_tstrb_fifo_empty        : std_logic := '0';
    signal sig_clr_fifo_ld_regs        : std_logic := '0';
    signal ld_btt_cntr_reg1            : std_logic := '0';
    signal ld_btt_cntr_reg2            : std_logic := '0';
    signal ld_btt_cntr_reg3            : std_logic := '0';
    signal sig_btt_eq_0_reg            : std_logic := '0';
    signal sig_tlast_ld_beat           : std_logic := '0';
    signal sig_eof_ld_dbeat            : std_logic := '0';
    signal sig_strb_error              : std_logic := '0';
    signal sig_mssa_index              : std_logic_vector(MSSAI_INDEX_WIDTH-1 downto 0) := (others => '0');
    signal sig_tstrb_fifo_mssai_in     : std_logic_vector(MSSAI_INDEX_WIDTH-1 downto 0);
    signal sig_tstrb_fifo_mssai_out    : std_logic_vector(MSSAI_INDEX_WIDTH-1 downto 0);
    signal sig_fifo_mssai              : unsigned(NUM_OFFSET_BITS-1 downto 0) := (others => '0');
    signal sig_clr_tstrb_fifo          : std_logic := '0';
    signal sig_eop_sent                : std_logic := '0';
    signal sig_eop_sent_reg            : std_logic := '0';
    signal sig_scatter2drc_eop         : std_logic := '0';
    signal sig_set_packet_done         : std_logic := '0';
    signal sig_tlast_sent              : std_logic := '0';
    signal sig_gated_fifo_freeze_out   : std_logic := '0';
    signal sig_cmd_side_ready          : std_logic := '0';
    signal sig_eop_halt_xfer           : std_logic := '0';
    signal sig_err_underflow_reg       : std_logic := '0';
    signal sig_assert_valid_out        : std_logic := '0';
--   Attribute KEEP : string; -- declaration
--  Attribute EQUIVALENT_REGISTER_REMOVAL : string; -- declaration

--  Attribute KEEP of sig_btt_cntr_dup   : signal is "TRUE"; -- definition

--  Attribute EQUIVALENT_REGISTER_REMOVAL of sig_btt_cntr_dup   : signal is "no";
 
                                     
  begin --(architecture implementation)
  
    
    
    -- Output stream assignments (to DRE) -----------------
    sig_drc2scatter_tready   <= drc2scatter_tready     ;             
    scatter2drc_tvalid       <= sig_scatter2drc_tvalid ;
    scatter2drc_tdata        <= sig_scatter2drc_tdata  ;
    scatter2drc_tstrb        <= sig_scatter2drc_tstrb  ;
    scatter2drc_tlast        <= sig_scatter2drc_tlast  ;
    scatter2drc_flush        <= sig_scatter2drc_flush  ;
    scatter2drc_eop          <= sig_scatter2drc_eop    ;
    
    -- DRC Control ----------------------------------------
    
    scatter2drc_cmd_ready    <= sig_cmd_empty;
    
    sig_drc2scatter_push_cmd <= drc2scatter_push_cmd ;
    sig_drc2scatter_btt      <= drc2scatter_btt      ;
    sig_drc2scatter_eof      <= drc2scatter_eof      ;
    
    
    -- Next source alignment control to the S2Mm DRE ------
    scatter2drc_src_align    <= sig_next_dre_src_align; 
    
    
    -- TLAST error flag output ----------------------------
    scatter2drc_tlast_error  <= sig_tlast_error_out;
    
    
    
    -- Data to DRE output ---------------------------------
    sig_scatter2drc_tdata    <= sig_strm_tdata ;
    
    
    
    sig_scatter2drc_tvalid   <=  sig_assert_valid_out and -- Asserting the valid output       
                                 sig_cmd_side_ready;      -- and the tstrb fifo has an entry pending
    
    
    -- Create flag indicating a qualified output stream data beat to the DRE
    sig_valid_dre_output_dbeat <= sig_drc2scatter_tready and
                                  sig_scatter2drc_tvalid;
    
     
    
    
    
    -- Databeat DRE FLUSH output --------------------------
    sig_scatter2drc_flush    <= '0';
    
    
    
    
    sig_ld_cmd               <=  sig_drc2scatter_push_cmd and
                                 not(sig_cmd_full);
    
    
    sig_next_dre_src_align   <= STD_LOGIC_VECTOR(RESIZE(sig_next_strt_offset,
                                                      C_DRE_ALIGN_WIDTH));
    
    
    sig_good_strm_dbeat      <=  sig_strm_tready and
                                 sig_assert_valid_out ;
    
    

    -- Set the valid out flag
    sig_assert_valid_out     <= (sig_strm_tvalid        or  -- there is valid data in the Skid buffer output register
                                 sig_err_underflow_reg);    -- or an underflow error has been detected and needs to flush
    




                                                      
    --- Input Stream Skid Buffer with Special Functions ------------------------------
    
        
    ------------------------------------------------------------
    -- Instance: I_MSSAI_SKID_BUF 
    --
    -- Description:
    -- Instance for the MSSAI Skid Buffer needed for Fmax 
    -- closure when the Scatter Module is included in the DataMover
    -- S2MM.    
    --
    ------------------------------------------------------------
    I_MSSAI_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_mssai_skid_buf
    generic map (
  
      C_WDATA_WIDTH  =>  C_STREAM_DWIDTH   ,   
      C_INDEX_WIDTH  =>  MSSAI_INDEX_WIDTH   
  
      )
    port map (
  
      -- System Ports
      aclk          => primary_aclk     ,  
      arst          => mmap_reset       ,  
      
      -- Shutdown control (assert for 1 clk pulse)
      skid_stop     => LOGIC_LOW        ,  
      
      -- Slave Side (Stream Data Input) 
      s_valid       => s2mm_strm_tvalid ,  
      s_ready       => s2mm_strm_tready ,  
      s_data        => s2mm_strm_tdata  ,  
      s_strb        => s2mm_strm_tstrb  ,  
      s_last        => s2mm_strm_tlast  ,  

      -- Master Side (Stream Data Output 
      m_valid       => sig_strm_tvalid  ,  
      m_ready       => sig_strm_tready  ,  
      m_data        => sig_strm_tdata   ,  
      m_strb        => sig_strm_tstrb   ,  
      m_last        => sig_strm_tlast   ,  
      
      m_mssa_index  => sig_mssa_index   ,  
      m_strb_error  => sig_strb_error      
      
      );
  
                   
                     
                     
                     
                     
                     
    -------------------------------------------------------------
    -- packet Done Logic
    -------------------------------------------------------------
                     
                                                    
                              
    sig_set_packet_done    <= sig_eop_sent_reg;      
                              
                                                      
                                                      
                     
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_CMD_FLAG_REG
    --
    -- Process Description:
    --   Implement the Scatter transfer command full/empty tracking
    -- flops 
    --
    -------------------------------------------------------------
    IMP_CMD_FLAG_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset         = '1' or
                sig_tlast_sent     = '1') then
              
              sig_cmd_full   <= '0';
              sig_cmd_empty  <= '1';
              
              
            elsif (sig_ld_cmd = '1') then
              
              sig_cmd_full   <= '1';
              sig_cmd_empty  <= '0';
              
            else
              null; -- hold current state
            end if; 
         end if;       
       end process IMP_CMD_FLAG_REG; 
    
    
    
    


    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_CURR_OFFSET_REG
    --
    -- Process Description:
    --  Implements the register holding the current starting
    -- byte position offset of the first byte of the current
    -- command. This implementation assumes that only the first
    -- databeat can be unaligned from Byte position 0.
    --
    -------------------------------------------------------------
    IMP_CURR_OFFSET_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset          = '1' or
                sig_set_packet_done = '1' or
                sig_valid_fifo_ld   = '1') then
              
              sig_curr_strt_offset <= (others => '0');
            
            elsif (sig_ld_cmd = '1') then
              
              sig_curr_strt_offset <= sig_next_strt_offset;
              
            else
              null;  -- Hold current state
            end if; 
         end if;       
       end process IMP_CURR_OFFSET_REG; 
    
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_NEXT_OFFSET_REG
    --
    -- Process Description:
    --  Implements the register holding the predicted byte position
    -- offset of the first byte of the next command. If the current 
    -- command has EOF set, then the next command's first data input
    -- byte offset must be at byte lane 0 in the input stream.
    --
    -------------------------------------------------------------
    IMP_NEXT_OFFSET_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset           = '1' or
                sig_set_packet_done  = '1' or
                STRM_NUM_BYTE_LANES  = 1) then
              
              sig_next_strt_offset <= (others => '0');
            
            elsif (sig_ld_cmd = '1') then
              
              sig_next_strt_offset <= sig_next_strt_offset + sig_btt_offset_slice;
              
            else
              null;  -- Hold current state
            end if; 
         end if;       
       end process IMP_NEXT_OFFSET_REG; 
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_FIFO_MSSAI_REG
    --
    -- Process Description:
    --  Implements the register holding the predicted byte position
    -- offset of the last valid byte defined by the current command.
    --
    -------------------------------------------------------------
    IMP_FIFO_MSSAI_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset          = '1' or
                sig_set_packet_done = '1' or
                STRM_NUM_BYTE_LANES = 1 ) then
              
              sig_fifo_mssai <= (others => '0');
            
            elsif (ld_btt_cntr_reg1 = '1' and
                   ld_btt_cntr_reg2 = '0') then
              
              sig_fifo_mssai <= sig_next_strt_offset - OFFSET_ONE;
              
            else
              null;  -- Hold current state
            end if; 
         end if;       
       end process IMP_FIFO_MSSAI_REG; 
    
    
    
    
    
    
    
    
    
    
    -- Strobe Generation Logic ------------------------------------------------
    
    
    
    
    sig_curr_dbeat_offset  <= STD_LOGIC_VECTOR(sig_curr_strt_offset);
    
  
  
         
    ------------------------------------------------------------
    -- Instance: I_SCATTER_STROBE_GEN 
    --
    -- Description:
    --  Strobe generator instance. Generates strobe bits for
    -- a designated starting byte lane and the number of bytes
    -- to be transfered (for that data beat).    
    --
    ------------------------------------------------------------
     I_SCATTER_STROBE_GEN : entity axi_datamover_v5_1.axi_datamover_strb_gen2
     generic map (
                           
       C_OP_MODE            =>  0                     , -- 0 = Offset/Length mode
       C_STRB_WIDTH         =>  STRM_NUM_BYTE_LANES   ,   
       C_OFFSET_WIDTH       =>  NUM_OFFSET_BITS       ,   
       C_NUM_BYTES_WIDTH    =>  NUM_INCR_BITS           
   
       )
     port map (
       
       start_addr_offset    =>  sig_curr_dbeat_offset , 
       end_addr_offset      =>  sig_curr_dbeat_offset , -- not used in op mode 0
       num_valid_bytes      =>  sig_btt_stb_gen_slice , -- not used in op mode 1
       strb_out             =>  sig_stbgen_tstrb   
   
       );
                                
   


    
     
     
    
    
    
    
    -- BTT Counter stuff ------------------------------------------------------
    
    sig_btt_stb_gen_slice     <= STD_LOGIC_VECTOR(INCR_MAX) 
     when (sig_btt_gteq_max_incr = '1')
     else '0' & STD_LOGIC_VECTOR(sig_btt_cntr(NUM_OFFSET_BITS-1 downto 0));     
    
    
    sig_btt_offset_slice      <= UNSIGNED(sig_drc2scatter_btt(NUM_OFFSET_BITS-1 downto 0));
    
    
    sig_btt_lteq_max_first_incr <= '1'
      when (sig_btt_cntr_dup <= RESIZE(sig_max_first_increment, CMD_BTT_WIDTH))     -- more timing improv
      Else '0';                                                                 -- more timing improv
                                                                                -- more timing improv
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_MAX_FIRST_INCR_REG
    --
    -- Process Description:
    --   Implements the Max first increment register value. 
    --
    -------------------------------------------------------------
    IMP_MAX_FIRST_INCR_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset  = '1') then
              
              sig_max_first_increment <= (others => '0');
              
            Elsif (sig_ld_cmd = '1') Then
            
              sig_max_first_increment <= RESIZE(TO_UNSIGNED(MAX_BTT_INCR,NUM_INCR_BITS) - 
                                                     RESIZE(sig_next_strt_offset,NUM_INCR_BITS), 
                                                     CMD_BTT_WIDTH);
            
            Elsif (sig_valid_fifo_ld = '1') Then
              
              sig_max_first_increment <= RESIZE(TO_UNSIGNED(MAX_BTT_INCR,NUM_INCR_BITS), CMD_BTT_WIDTH);
              
            else

              null;  -- hold current value  
                
            end if; 
         end if;       
       end process IMP_MAX_FIRST_INCR_REG; 
    
    
    
    
    
    
    
    sig_btt_cntr_decr_value <= sig_btt_cntr
      When (sig_btt_lteq_max_first_incr = '1')
      Else sig_max_first_increment;
   
   
    sig_ld_btt_cntr   <= sig_ld_cmd ;
    
    sig_decr_btt_cntr <= not(sig_btt_eq_0) and 
                         sig_valid_fifo_ld;
   
    
    
    
    -- New intermediate value for reduced Timing path
    sig_btt_cntr_prv <= UNSIGNED(sig_drc2scatter_btt)
      when (sig_ld_btt_cntr = '1')
--      Else sig_btt_cntr_dup-sig_btt_cntr_decr_value;
      Else sig_btt_cntr_dup-sig_btt_cntr_decr_value;
    
    
    sig_btt_eq_0_pre_reg <= '1'
      when (sig_btt_cntr_prv = BTT_OF_ZERO)
      Else '0';
    
--    sig_btt_eq_0 <= '1'
--      when (sig_btt_cntr = BTT_OF_ZERO)
--      Else '0';
    
    sig_btt_gteq_max_incr  <= '1'
      when (sig_btt_cntr >= TO_UNSIGNED(MAX_BTT_INCR, CMD_BTT_WIDTH))
      Else '0';
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_BTT_CNTR_REG
    --
    -- Process Description:
    --  Implements the registered portion of the BTT Counter. The
    -- BTT Counter has been recoded this way to minimize long
    -- timing paths in the btt -> strobgen-> EOP Demux path.
    --
    -------------------------------------------------------------
    IMP_BTT_CNTR_REG : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset   = '1' or
               sig_eop_sent = '1') then
  
             sig_btt_cntr                <= (others => '0');
             sig_btt_cntr_dup                <= (others => '0');
             sig_btt_eq_0                <= '1';
  
           elsif (sig_ld_btt_cntr   = '1' or
                  sig_decr_btt_cntr = '1') then
  
             sig_btt_cntr                <= sig_btt_cntr_prv;
             sig_btt_cntr_dup                <= sig_btt_cntr_prv;
             sig_btt_eq_0                <= sig_btt_eq_0_pre_reg;
           
           else
  
             Null;  -- Hold current state
  
           end if; 
        end if;       
      end process IMP_BTT_CNTR_REG; 
    
    
--    IMP_BTT_CNTR_REG : process (primary_aclk)
--      begin
--        if (primary_aclk'event and primary_aclk = '1') then
--           if (mmap_reset   = '1' or
--               sig_eop_sent = '1') then
    
--             sig_btt_cntr                <= (others => '0');
----             sig_btt_eq_0                <= '1';
    
--           elsif (sig_ld_btt_cntr   = '1') then
                  
    
--             sig_btt_cntr                <= UNSIGNED(sig_drc2scatter_btt); --sig_btt_cntr_prv;
----             sig_btt_eq_0                <= sig_btt_eq_0_pre_reg;

--           elsif (sig_decr_btt_cntr = '1') then
--             sig_btt_cntr                <= sig_btt_cntr-sig_btt_cntr_decr_value; --sig_btt_cntr_prv;
----             sig_btt_eq_0                <= sig_btt_eq_0_pre_reg;
             
--           else
    
--             Null;  -- Hold current state
    
--           end if; 
--        end if;       
--      end process IMP_BTT_CNTR_REG; 
    
     
    
    
    
     
     
    
    ------------------------------------------------------------------------
    -- DRE TVALID Gating logic
    ------------------------------------------------------------------------
    
    
    
    sig_cmd_side_ready     <= not(sig_tstrb_fifo_empty) and
                              not(sig_eop_halt_xfer); 
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_EOP_HALT_FLOP
    --
    -- Process Description:
    -- Implements a flag that is set when an end of packet is sent
    -- to the DRE and cleared after the TSTRB FIFO has been reset.
    -- This flag inhibits the TVALID sent to the DRE.
    -------------------------------------------------------------
    IMP_EOP_HALT_FLOP : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset   = '1' or
                sig_eop_sent = '1') then
              
              sig_eop_halt_xfer <= '1';
            
            Elsif (sig_valid_fifo_ld = '1') Then
              
              sig_eop_halt_xfer <= '0';
              
            else
              null; -- hold current state
            end if; 
         end if;       
       end process IMP_EOP_HALT_FLOP; 
                                                      
                                                      
                                                      
                                                      
                                                      
                                                      
     
    
    ------------------------------------------------------------------------
    -- TSTRB FIFO Logic
    ------------------------------------------------------------------------
    
     
    sig_tlast_ld_beat        <= sig_btt_lteq_max_first_incr;
    
    
    sig_eof_ld_dbeat         <= sig_curr_eof_reg and sig_tlast_ld_beat;
    
    
    -- Set the MSSAI offset value to the maximum for non-tlast dbeat
    -- case, otherwise use the calculated value for the TLSAT case. 
    sig_tstrb_fifo_mssai_in  <= STD_LOGIC_VECTOR(sig_fifo_mssai)
      when (sig_tlast_ld_beat = '1')
      else STD_LOGIC_VECTOR(OFFSET_MAX);
    


 
GEN_S2MM_TKEEP_ENABLE3 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin
   
    -- Merge the various pieces to go through the TSTRB FIFO into a single vector
    sig_tstrb_fifo_data_in   <= sig_tlast_ld_beat       & -- the last beat of this sub-packet
                                sig_eof_ld_dbeat        & -- the end of the whole packet
                                sig_freeze_it           & -- A sub-packet boundary
                                sig_tstrb_fifo_mssai_in & -- the index of EOF byte position
                                sig_stbgen_tstrb;         -- The calculated strobes



  
end generate GEN_S2MM_TKEEP_ENABLE3;

GEN_S2MM_TKEEP_DISABLE3 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin

   
    -- Merge the various pieces to go through the TSTRB FIFO into a single vector
    sig_tstrb_fifo_data_in   <= sig_tlast_ld_beat       & -- the last beat of this sub-packet
                                sig_eof_ld_dbeat        & -- the end of the whole packet
                                sig_freeze_it           & -- A sub-packet boundary
                                sig_tstrb_fifo_mssai_in; --& -- the index of EOF byte position
                                --sig_stbgen_tstrb;         -- The calculated strobes



end generate GEN_S2MM_TKEEP_DISABLE3;





    
    -- FIFO Load control
    sig_valid_fifo_ld        <= sig_tstrb_fifo_valid and
                                sig_tstrb_fifo_rdy;
    
    
     
GEN_S2MM_TKEEP_ENABLE4 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin

    -- Rip the various pieces from the FIFO output
    sig_fifo_tlast_out       <= sig_tstrb_fifo_data_out(FIFO_TLAST_INDEX) ;
    
    sig_fifo_eof_out         <= sig_tstrb_fifo_data_out(FIFO_EOF_INDEX)   ;
    
    sig_fifo_freeze_out      <= sig_tstrb_fifo_data_out(FIFO_FREEZE_INDEX);
    
    sig_tstrb_fifo_mssai_out <= sig_tstrb_fifo_data_out(FIFO_MSSAI_MS_INDEX downto FIFO_MSSAI_LS_INDEX);
    
    sig_fifo_tstrb_out       <= sig_tstrb_fifo_data_out(FIFO_TSTRB_MS_INDEX downto FIFO_TSTRB_LS_INDEX);
    
    

 
end generate GEN_S2MM_TKEEP_ENABLE4;

GEN_S2MM_TKEEP_DISABLE4 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin

   -- Rip the various pieces from the FIFO output
    sig_fifo_tlast_out       <= sig_tstrb_fifo_data_out(FIFO_TLAST_INDEX) ;
    
    sig_fifo_eof_out         <= sig_tstrb_fifo_data_out(FIFO_EOF_INDEX)   ;
    
    sig_fifo_freeze_out      <= sig_tstrb_fifo_data_out(FIFO_FREEZE_INDEX);
    
    sig_tstrb_fifo_mssai_out <= sig_tstrb_fifo_data_out(FIFO_MSSAI_MS_INDEX downto FIFO_MSSAI_LS_INDEX);
    
    sig_fifo_tstrb_out       <= (others => '1');
    
    

 
end generate GEN_S2MM_TKEEP_DISABLE4;

    
    
    -- FIFO Read Control
    sig_get_tstrb            <= sig_valid_dre_output_dbeat ;
    
    
    
    sig_tstrb_fifo_valid     <= ld_btt_cntr_reg2 or
                                (ld_btt_cntr_reg3 and 
                                 not(sig_btt_eq_0));
    
    
    sig_clr_fifo_ld_regs     <= (sig_tlast_ld_beat and
                                 sig_valid_fifo_ld) or
                                 sig_eop_sent;
    
     
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_FIFO_LD_1
    --
    -- Process Description:
    --   Implements the fifo loading control flop stage 1 
    --
    -------------------------------------------------------------
    IMP_FIFO_LD_1 : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset           = '1' or
                sig_clr_fifo_ld_regs = '1') then
              
              ld_btt_cntr_reg1  <= '0';
              
            
            Elsif (sig_ld_btt_cntr = '1') Then
            
              ld_btt_cntr_reg1  <= '1';
            
            else
              
              null; -- hold current state
              
            end if; 
         end if;       
       end process IMP_FIFO_LD_1; 
    
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_FIFO_LD_2
    --
    -- Process Description:
    --   Implements special fifo loading control flops 
    --
    -------------------------------------------------------------
    IMP_FIFO_LD_2 : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset           = '1' or
                sig_clr_fifo_ld_regs = '1') then
              
              ld_btt_cntr_reg2  <= '0';
              ld_btt_cntr_reg3  <= '0';
              
            Elsif (sig_tstrb_fifo_rdy = '1') Then
              
              ld_btt_cntr_reg2  <= ld_btt_cntr_reg1;
              ld_btt_cntr_reg3  <= ld_btt_cntr_reg2 or 
                                   ld_btt_cntr_reg3; -- once set, keep it set until cleared
              
            else

              null;  -- Hold current state
            
            end if; 
         end if;       
       end process IMP_FIFO_LD_2; 

--HIGHER_DATAWIDTH : if TSTRB_FIFO_DWIDTH > 40 generate
--begin    
    
    SLICE_INSERTION : entity axi_datamover_v5_1.axi_datamover_slice
         generic map (
             C_DATA_WIDTH => TSTRB_FIFO_DWIDTH
         )

         port map (
              ACLK => primary_aclk,
              ARESET => mmap_reset,

   -- Slave side
              S_PAYLOAD_DATA => sig_tstrb_fifo_data_in,
              S_VALID => sig_tstrb_fifo_valid,
              S_READY => sig_tstrb_fifo_rdy,

   -- Master side
              M_PAYLOAD_DATA => slice_insert_data,
              M_VALID => slice_insert_valid,
              M_READY => slice_insert_ready
         );
    

    ------------------------------------------------------------
    -- Instance: I_TSTRB_FIFO 
    --
    -- Description:
    -- Instance for the TSTRB FIFO
    --
    ------------------------------------------------------------
    I_TSTRB_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
    generic map (
  
      C_DWIDTH             =>  TSTRB_FIFO_DWIDTH      , 
      C_DEPTH              =>  TSTRB_FIFO_DEPTH       , 
      C_IS_ASYNC           =>  USE_SYNC_FIFO          , 
      C_PRIM_TYPE          =>  FIFO_PRIM          , 
      C_FAMILY             =>  C_FAMILY                 
     
      )
    port map (
      
      -- Write Clock and reset
      fifo_wr_reset        =>   sig_clr_tstrb_fifo    , 
      fifo_wr_clk          =>   primary_aclk          , 
      
      -- Write Side
      fifo_wr_tvalid       =>   slice_insert_valid, --sig_tstrb_fifo_valid  , 
      fifo_wr_tready       =>   slice_insert_ready, --sig_tstrb_fifo_rdy    , 
      fifo_wr_tdata        =>   slice_insert_data, --sig_tstrb_fifo_data_in, 
      fifo_wr_full         =>   open                  , 
     
     
      -- Read Clock and reset
      fifo_async_rd_reset  =>   mmap_reset            ,   
      fifo_async_rd_clk    =>   primary_aclk          , 
      
      -- Read Side
      fifo_rd_tvalid       =>   sig_tstrb_valid         , 
      fifo_rd_tready       =>   sig_get_tstrb           , 
      fifo_rd_tdata        =>   sig_tstrb_fifo_data_out , 
      fifo_rd_empty        =>   sig_tstrb_fifo_empty   
     
      );
  
--end generate HIGHER_DATAWIDTH;
    
    
--LOWER_DATAWIDTH : if TSTRB_FIFO_DWIDTH <= 40 generate
--begin   

    ------------------------------------------------------------
    -- Instance: I_TSTRB_FIFO 
    --
    -- Description:
    -- Instance for the TSTRB FIFO
    --
    ------------------------------------------------------------
--    I_TSTRB_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
--    generic map (
--  
--      C_DWIDTH             =>  TSTRB_FIFO_DWIDTH      , 
--      C_DEPTH              =>  TSTRB_FIFO_DEPTH       , 
--      C_IS_ASYNC           =>  USE_SYNC_FIFO          , 
--      C_PRIM_TYPE          =>  FIFO_PRIM          , 
--      C_FAMILY             =>  C_FAMILY                 
--     
--      )
--    port map (
--      
--      -- Write Clock and reset
--      fifo_wr_reset        =>   sig_clr_tstrb_fifo    , 
--      fifo_wr_clk          =>   primary_aclk          , 
--      
--     -- Write Side
--     fifo_wr_tvalid       =>   sig_tstrb_fifo_valid  , 
--     fifo_wr_tready       =>   sig_tstrb_fifo_rdy    , 
--     fifo_wr_tdata        =>   sig_tstrb_fifo_data_in, 
--     fifo_wr_full         =>   open                  , 
--    
--    
--     -- Read Clock and reset
--     fifo_async_rd_reset  =>   mmap_reset            ,   
--     fifo_async_rd_clk    =>   primary_aclk          , 
--     
--     -- Read Side
--     fifo_rd_tvalid       =>   sig_tstrb_valid         , 
--     fifo_rd_tready       =>   sig_get_tstrb           , 
--     fifo_rd_tdata        =>   sig_tstrb_fifo_data_out , 
--      fifo_rd_empty        =>   sig_tstrb_fifo_empty   
--     
--      );
--
--
--end generate LOWER_DATAWIDTH;
 
    ------------------------------------------------------------
    -- TSTRB FIFO Clear Logic
    ------------------------------------------------------------

    -- Special TSTRB FIFO Clear Logic to clean out any residue  
    -- once EOP has been sent out to DRE. This is primarily 
    -- needed in Indeterminate BTT mode but is also included in  
    -- the non-Indeterminate BTT mode for a more robust design. 
    sig_clr_tstrb_fifo   <=  mmap_reset or 
                             sig_set_packet_done;

  
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_EOP_SENT_REG
    --
    -- Process Description:
    --   Register the EOP being sent out to the DRE stage. This
    -- is used to clear the TSTRB FIFO of any residue.
    --
    -------------------------------------------------------------
    IMP_EOP_SENT_REG : process (primary_aclk)
      begin
        if (primary_aclk'event and primary_aclk = '1') then
           if (mmap_reset       = '1' or
               sig_eop_sent_reg = '1') then
    
             sig_eop_sent_reg <= '0';
    
           else
    
             sig_eop_sent_reg <= sig_eop_sent;
    
           end if; 
        end if;       
      end process IMP_EOP_SENT_REG; 

     
           
           


      
      
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_EOF_REG
    --
    -- Process Description:
    --   Implement a sample and hold flop for the command EOF 
    --   The Commanded EOF is used when C_ENABLE_INDET_BTT = 0.
    -------------------------------------------------------------
    IMP_EOF_REG : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (mmap_reset          = '1' or
                sig_set_packet_done = '1') then
              
              sig_curr_eof_reg <= '0';
              
            elsif (sig_ld_cmd = '1') then
              
              sig_curr_eof_reg <= sig_drc2scatter_eof;
              
            else
              null; -- hold current state
            end if; 
         end if;       
       end process IMP_EOF_REG; 
    
    

    


   
   
   
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_OMIT_INDET_BTT
    --
    -- If Generate Description:
    --  Implements the Scatter Freeze Register Controls plus 
    -- other logic needed when Indeterminate BTT Mode is not enabled.
    -- 
    --
    --
    ------------------------------------------------------------
    GEN_OMIT_INDET_BTT : if (C_ENABLE_INDET_BTT = 0) generate
    

       signal lsig_eop_matches_ms_strb     : std_logic := '0';

    
       begin

 
         sig_eop_sent    <=  sig_scatter2drc_eop and
                             sig_valid_dre_output_dbeat;
         
         
         sig_tlast_sent  <=  sig_scatter2drc_tlast and
                             sig_valid_dre_output_dbeat;
         
         
         sig_freeze_it   <= not(sig_stbgen_tstrb(STRM_NUM_BYTE_LANES-1)) and -- ms strobe not set
                            sig_valid_fifo_ld and                            -- tstrb fifo being loaded
                            not(sig_curr_eof_reg);                           -- Current input cmd does not have eof set
          
              
              
         -- Assign the TREADY out to the Stream In 
         sig_strm_tready  <= '0'
           when (sig_gated_fifo_freeze_out  = '1' or
                 sig_cmd_side_ready         = '0')
           Else sig_drc2scatter_tready;
         
         
         
 
         
         -- Without Indeterminate BTT, FIFO Freeze does not
         -- need to be gated.
         sig_gated_fifo_freeze_out <= sig_fifo_freeze_out;
         
         
         
         -- Strobe outputs are always generated from the input command
         -- with Indeterminate BTT omitted. Stream input Strobes are not
         -- sent to output.
         sig_scatter2drc_tstrb <= sig_fifo_tstrb_out;      
                               
                               
         -- The EOF marker is generated from the input command 
         -- with Indeterminate BTT omitted. Stream input TLAST is monitored
         -- but not sent to output to DRE.
         sig_scatter2drc_eop   <= sig_fifo_eof_out and 
                                  sig_scatter2drc_tvalid;
                                  
                                  
 
         -- TLast output marker always generated from the input command
         sig_scatter2drc_tlast     <= sig_fifo_tlast_out and 
                                      sig_scatter2drc_tvalid;
         
 

   
   
         
         --- TLAST Error Detection -------------------------------------------------
    
         sig_tlast_error_out  <=  sig_set_tlast_error or
                                  sig_tlast_error_reg;
                                   
          
         
        -- Compare the Most significant Asserted TSTRB from the TSTRB FIFO
        -- with that from the Input Skid Buffer
        lsig_eop_matches_ms_strb <= '1'
          when (sig_tstrb_fifo_mssai_out = sig_mssa_index)
          Else '0';
   
         
         
         
         -- Detect the case when the calculated end of packet
         -- marker preceeds the received end of packet marker
         -- and a freeze condition is not enabled
         sig_tlast_error_over <= '1'
          when (sig_valid_dre_output_dbeat  = '1' and           
                sig_fifo_freeze_out         = '0' and
                sig_fifo_eof_out            = '1' and
                sig_strm_tlast              = '0')
          Else '0';
         
         
         
         
         -- Detect the case when the received end of packet marker preceeds
         -- the calculated end of packet
         -- and a freeze condition is not enabled
         sig_tlast_error_under <= '1'
          when (sig_valid_dre_output_dbeat  = '1' and                    
                sig_fifo_freeze_out         = '0' and
                sig_fifo_eof_out            = '0' and
                sig_strm_tlast              = '1')
          Else '0';
         
         
         
         
         -- Detect the case when the received end of packet marker occurs
         -- in the same beat as the calculated end of packet but the most 
         -- significant received strobe that is asserted does not match
         -- the most significant calcualted strobe that is asserted.
         -- Also, a freeze condition is not enabled
         sig_tlast_error_exact <= '1'
           When (sig_valid_dre_output_dbeat  = '1' and                    
                 sig_fifo_freeze_out         = '0' and
                 sig_fifo_eof_out            = '1' and
                 sig_strm_tlast              = '1' and
                 lsig_eop_matches_ms_strb    = '0')
           
           Else '0';
         
         
         
         
         
         
         -- Combine all of the possible error conditions
         sig_set_tlast_error  <=  sig_tlast_error_over  or
                                  sig_tlast_error_under or
                                  sig_tlast_error_exact;
          
          
          
          
         
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_TLAST_ERROR_REG
         --
         -- Process Description:
         --
         --
         -------------------------------------------------------------
         IMP_TLAST_ERROR_REG : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset = '1') then
                   
                   sig_tlast_error_reg <= '0';
                 
                 elsif (sig_set_tlast_error = '1') then
                   
                   sig_tlast_error_reg <= '1';
                 
                 else
                   Null;  -- Hold current State
                 end if; 
              end if;       
            end process IMP_TLAST_ERROR_REG; 
         
         
         
         
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_TLAST_ERROR_UNDER_REG
         --
         -- Process Description:
         --  Sample and Hold flop for the case when an underrun is 
         --  detected. This flag is used to force a a tvalid output.
         --
         -------------------------------------------------------------
         IMP_TLAST_ERROR_UNDER_REG : process (primary_aclk)
            begin
              if (primary_aclk'event and primary_aclk = '1') then
                 if (mmap_reset = '1') then
                   
                   sig_err_underflow_reg <= '0';
                 
                 elsif (sig_tlast_error_under = '1') then
                   
                   sig_err_underflow_reg <= '1';
                 
                 else
                   Null;  -- Hold current State
                 end if; 
              end if;       
            end process IMP_TLAST_ERROR_UNDER_REG; 
         
         
         





    
       end generate GEN_OMIT_INDET_BTT;
    
    
 
 
 
 
 
 
 
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INDET_BTT
    --
    -- If Generate Description:
    --  Implements the Scatter Freeze Register and Controls plus
    -- other logic needed to support the Indeterminate BTT Mode
    -- of Operation.
    --
    --
    ------------------------------------------------------------
    GEN_INDET_BTT : if (C_ENABLE_INDET_BTT = 1) generate
    
       -- local signals
       
       -- signal lsig_valid_eop_dbeat   : std_logic := '0';
       signal lsig_strm_eop_asserted : std_logic := '0';
       signal lsig_absorb2tlast      : std_logic := '0';
       signal lsig_set_absorb2tlast  : std_logic := '0';
       signal lsig_clr_absorb2tlast  : std_logic := '0';
       
     
       begin

         -- Detect an end of packet condition. This is an EOP sent to the DRE or
         -- an overflow data absorption condition
         sig_eop_sent    <=  (sig_scatter2drc_eop and
                             sig_valid_dre_output_dbeat) or
                             (lsig_set_absorb2tlast and
                              not(lsig_absorb2tlast));
         
         sig_tlast_sent  <=  (sig_scatter2drc_tlast      and  --
                              sig_valid_dre_output_dbeat and  -- Normal Tlast Sent condition
                              not(lsig_set_absorb2tlast)) or  --
                              (lsig_absorb2tlast and
                              lsig_clr_absorb2tlast);         -- Overflow absorbion condition
         
         
         
         -- TStrb FIFO Input Stream Freeze control
         sig_freeze_it   <= not(sig_stbgen_tstrb(STRM_NUM_BYTE_LANES-1)) and -- ms strobe not set             
                           -- not(sig_curr_eof_reg) and                      -- tstrb fifo being loaded       
                            sig_valid_fifo_ld ;                              -- Current input cmd has eof set 
          

  
         -- Stream EOP assertion is caused when the stream input TLAST
         -- is asserted and the most significant strobe bit asserted in 
         -- the input stream data beat is less than or equal to the most
         -- significant calculated asserted strobe bit for the data beat.
         lsig_strm_eop_asserted <=  '1'
           when (sig_mssa_index <= sig_tstrb_fifo_mssai_out) and
                (sig_strm_tlast  = '1' and
                 sig_strm_tvalid = '1')
           else '0';
          
         
          
          
         -- Must not freeze the Stream input skid buffer if an EOF
         -- condition exists on the Stream input (skid buf output)
         sig_gated_fifo_freeze_out <= sig_fifo_freeze_out         and
                                      not(lsig_strm_eop_asserted) and
                                      sig_strm_tvalid;             -- CR617164
         
  
         -- Databeat DRE EOP output ---------------------------
         sig_scatter2drc_eop     <= (--sig_fifo_eof_out        or 
                                    lsig_strm_eop_asserted) and 
                                    sig_scatter2drc_tvalid;

         
         -- Databeat DRE Last output ---------------------------
         sig_scatter2drc_tlast  <= (sig_fifo_tlast_out      or
                                    lsig_strm_eop_asserted) and 
                                    sig_scatter2drc_tvalid;
         
         
         
         -- Formulate the output TSTRB vector. It is an AND of the command 
         -- generated TSTRB and the actual TSTRB received from the Stream input.
         sig_scatter2drc_tstrb  <= sig_fifo_tstrb_out and
                                   sig_strm_tstrb;


         
         sig_tlast_error_over     <= '0'; -- no tlast error in Indeterminate BTT
         sig_tlast_error_under    <= '0'; -- no tlast error in Indeterminate BTT
         sig_tlast_error_exact    <= '0'; -- no tlast error in Indeterminate BTT
         sig_set_tlast_error      <= '0'; -- no tlast error in Indeterminate BTT
         sig_tlast_error_reg      <= '0'; -- no tlast error in Indeterminate BTT
         
         sig_tlast_error_out      <= '0'; -- no tlast error in Indeterminate BTT 
         
         

         
         
         ------------------------------------------------
         -- Data absorption to TLAST logic
         -- This is used for the Stream Input overflow case. In this case, the
         -- input stream data is absorbed (thrown away) until the TLAST databeat 
         -- is received (also thrown away). However, data is only absorbed if
         -- the EOP bit from the TSTRB FIFO is encountered before the TLST from
         -- the Stream input.
         -- In addition, the scatter2drc_eop assertion is suppressed from the output
         -- to the DRE.
         
     
           
          
         -- Assign the TREADY out to the Stream In with Overflow data absorption
         -- case added.
         sig_strm_tready  <= '0'
           when  (lsig_absorb2tlast          = '0' and
                 (sig_gated_fifo_freeze_out  = '1' or -- Normal case
                  sig_cmd_side_ready         = '0'))
           Else '1'
           When (lsig_absorb2tlast = '1')  -- Absorb overflow case
           Else sig_drc2scatter_tready;
         
    
         
         -- Check for the condition for absorbing overflow data. The start of new input
         -- packet cannot reside in the same databeat as the end of the previous
         -- packet. Thus anytime an EOF is encountered from the TSTRB FIFO output, the
         -- entire databeat needs to be discarded after transfer to the DRE of the 
         -- appropriate data.
         lsig_set_absorb2tlast <=  '1'
           when (sig_fifo_eof_out     = '1'  and
                 sig_tstrb_fifo_empty = '0'  and  -- CR617164
                 (sig_strm_tlast      = '0'  and
                  sig_strm_tvalid     = '1'))
           Else '1'
           When  (sig_gated_fifo_freeze_out = '1' and
                  sig_fifo_eof_out          = '1' and
                  sig_tstrb_fifo_empty      = '0') -- CR617164
           else '0';
          
         
 
         lsig_clr_absorb2tlast <=  '1'
           when lsig_absorb2tlast = '1' and
                (sig_strm_tlast   = '1' and
                 sig_strm_tvalid  = '1')
           else '0';
          
         

        
        
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: IMP_ABSORB_FLOP
         --
         -- Process Description:
         --   Implements the flag for indicating a overflow absorption
         -- case is active.
         --
         -------------------------------------------------------------
         IMP_ABSORB_FLOP : process (primary_aclk)
           begin
             if (primary_aclk'event and primary_aclk = '1') then
                if (mmap_reset            = '1' or
                    lsig_clr_absorb2tlast = '1') then
         
                  lsig_absorb2tlast <= '0';
         
                elsif (lsig_set_absorb2tlast = '1') then
         
                  lsig_absorb2tlast <= '1';
         
                else
         
                  null;  -- Hold Current State
         
                end if; 
             end if;       
           end process IMP_ABSORB_FLOP; 
        
        
         
         
         
         
        
    
       end generate GEN_INDET_BTT;
    
    
    
    
    
      
  
  end implementation;
