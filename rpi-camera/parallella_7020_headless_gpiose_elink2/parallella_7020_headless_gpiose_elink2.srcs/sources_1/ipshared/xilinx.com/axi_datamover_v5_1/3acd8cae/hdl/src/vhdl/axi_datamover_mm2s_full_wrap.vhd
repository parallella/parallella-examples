  -------------------------------------------------------------------------------
  -- axi_datamover_mm2s_full_wrap.vhd
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
  -- Filename:        axi_datamover_mm2s_full_wrap.vhd
  --
  -- Description:     
  --    This file implements the DataMover MM2S Full Wrapper.                 
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
  
  
  
  -- axi_datamover Library Modules
  library axi_datamover_v5_1; 
  use axi_datamover_v5_1.axi_datamover_reset;  
  use axi_datamover_v5_1.axi_datamover_cmd_status;
  use axi_datamover_v5_1.axi_datamover_pcc;
  use axi_datamover_v5_1.axi_datamover_addr_cntl;
  use axi_datamover_v5_1.axi_datamover_rddata_cntl;
  use axi_datamover_v5_1.axi_datamover_rd_status_cntl;
  use axi_datamover_v5_1.axi_datamover_mm2s_dre;
  Use axi_datamover_v5_1.axi_datamover_rd_sf;
  use axi_datamover_v5_1.axi_datamover_skid_buf;
  
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_mm2s_full_wrap is
    generic (
      
      C_INCLUDE_MM2S            : Integer range 0 to  2 :=  1;
         -- Specifies the type of MM2S function to include
         -- 0 = Omit MM2S functionality
         -- 1 = Full MM2S Functionality
         -- 2 = Lite MM2S functionality
         
      C_MM2S_ARID               : Integer range 0 to  255 :=  8;
         -- Specifies the constant value to output on 
         -- the ARID output port
         
      C_MM2S_ID_WIDTH           : Integer range 1 to  8 :=  4;
         -- Specifies the width of the MM2S ID port 
         
      C_MM2S_ADDR_WIDTH         : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Address Channel 
         -- Address bus
         
      C_MM2S_MDATA_WIDTH        : Integer range 32 to 1024 :=  32;
         -- Specifies the width of the MMap Read Data Channel
         -- data bus
      
      C_MM2S_SDATA_WIDTH        : Integer range 8 to 1024 :=  32;
         -- Specifies the width of the MM2S Master Stream Data 
         -- Channel data bus
      
      C_INCLUDE_MM2S_STSFIFO    : Integer range 0 to  1 :=  1;
         -- Specifies if a Status FIFO is to be implemented
         -- 0 = Omit MM2S Status FIFO
         -- 1 = Include MM2S Status FIFO
         
      C_MM2S_STSCMD_FIFO_DEPTH  : Integer range 1 to 16 :=  4;
         -- Specifies the depth of the MM2S Command FIFO and the 
         -- optional Status FIFO
         -- Valid values are 1,4,8,16
         
      C_MM2S_STSCMD_IS_ASYNC    : Integer range 0 to  1 :=  0;
         -- Specifies if the Status and Command interfaces need to
         -- be asynchronous to the primary data path clocking
         -- 0 = Use same clocking as data path
         -- 1 = Use special Status/Command clock for the interfaces
         
      C_INCLUDE_MM2S_DRE        : Integer range 0 to  1 :=  0;
         -- Specifies if DRE is to be included in the MM2S function 
         -- 0 = Omit DRE
         -- 1 = Include DRE
      
      C_MM2S_BURST_SIZE         : Integer range 2 to  256 :=  16;
         -- Specifies the max number of databeats to use for MMap
         -- burst transfers by the MM2S function 
    
      C_MM2S_BTT_USED           : Integer range 8 to  23 :=  16;
        -- Specifies the number of bits used from the BTT field
        -- of the input Command Word of the MM2S Command Interface 
    
      C_MM2S_ADDR_PIPE_DEPTH     : Integer range 1 to 30 := 3;
        -- This parameter specifies the depth of the MM2S internal 
        -- child command queues in the Read Address Controller and 
        -- the Read Data Controller. Increasing this value will 
        -- allow more Read Addresses to be issued to the AXI4 Read 
        -- Address Channel before receipt of the associated read 
        -- data on the Read Data Channel.

      C_TAG_WIDTH               : Integer range 1 to 8 :=  4 ;
         -- Width of the TAG field
         
      C_INCLUDE_MM2S_GP_SF      : Integer range 0 to 1 := 1 ;
        -- This parameter specifies the incllusion/omission of the
        -- MM2S (Read) Store and Forward function
        -- 0 = Omit Store and Forward
        -- 1 = Include Store and Forward
      C_ENABLE_CACHE_USER           : Integer range 0 to 1 := 1; 

    C_ENABLE_MM2S_TKEEP             : integer range 0 to 1 := 1; 


      C_ENABLE_SKID_BUF         : string := "11111";

      C_FAMILY                  : String := "virtex7"
         -- Specifies the target FPGA family type
      
      );
    port (
      
      
      -- MM2S Primary Clock input ---------------------------------
      mm2s_aclk         : in  std_logic;                         --
         -- Primary synchronization clock for the Master side    --
         -- interface and internal logic. It is also used        --
         -- for the User interface synchronization when          --
         -- C_STSCMD_IS_ASYNC = 0.                               --
                                                                 --
      -- MM2S Primary Reset input                                --
      mm2s_aresetn      : in  std_logic;                         --
         -- Reset used for the internal master logic             --
      -------------------------------------------------------------
 
     
      -- MM2S Halt request input control --------------------------
      mm2s_halt               : in  std_logic;                   --
         -- Active high soft shutdown request                    --
                                                                 --
      -- MM2S Halt Complete status flag                          --
      mm2s_halt_cmplt         : Out  std_logic;                  --
         -- Active high soft shutdown complete status            --
      -------------------------------------------------------------
      
      
      -- Error discrete output ------------------------------------
      mm2s_err          : Out std_logic;                         --
         -- Composite Error indication                           --
      -------------------------------------------------------------
     
     
     
      -- Optional MM2S Command and Status Clock and Reset ---------
      -- Used when C_MM2S_STSCMD_IS_ASYNC = 1                    --
      mm2s_cmdsts_awclk       : in  std_logic;                   --
      -- Secondary Clock input for async CMD/Status interface    --
                                                                 --
      mm2s_cmdsts_aresetn     : in  std_logic;                   --
        -- Secondary Reset input for async CMD/Status interface  --
      -------------------------------------------------------------
      
      
      -- User Command Interface Ports (AXI Stream) ----------------------------------------------------
      mm2s_cmd_wvalid         : in  std_logic;                                                       --
      mm2s_cmd_wready         : out std_logic;                                                       --
      mm2s_cmd_wdata          : in  std_logic_vector((C_TAG_WIDTH+(8*C_ENABLE_CACHE_USER)+C_MM2S_ADDR_WIDTH+36)-1 downto 0); --
      -------------------------------------------------------------------------------------------------
      
      
      -- User Status Interface Ports (AXI Stream) -------------------
      mm2s_sts_wvalid         : out std_logic;                     --
      mm2s_sts_wready         : in  std_logic;                     --
      mm2s_sts_wdata          : out std_logic_vector(7 downto 0);  --
      mm2s_sts_wstrb          : out std_logic_vector(0 downto 0);  --
      mm2s_sts_wlast          : out std_logic;                     --
      ---------------------------------------------------------------
      
      
      -- Address Posting contols ------------------------------------
      mm2s_allow_addr_req     : in  std_logic;                     --
      mm2s_addr_req_posted    : out std_logic;                     --
      mm2s_rd_xfer_cmplt      : out std_logic;                     --
      ---------------------------------------------------------------
      
      
      -- MM2S AXI Address Channel I/O  ---------------------------------------
      mm2s_arid     : out std_logic_vector(C_MM2S_ID_WIDTH-1 downto 0);     --
         -- AXI Address Channel ID output                                   --
                                                                            --
      mm2s_araddr   : out std_logic_vector(C_MM2S_ADDR_WIDTH-1 downto 0);   --
         -- AXI Address Channel Address output                              --
                                                                            --
      mm2s_arlen    : out std_logic_vector(7 downto 0);                     --
         -- AXI Address Channel LEN output                                  --
         -- Sized to support 256 data beat bursts                           --
                                                                            --
      mm2s_arsize   : out std_logic_vector(2 downto 0);                     --
         -- AXI Address Channel SIZE output                                 --
                                                                            --
      mm2s_arburst  : out std_logic_vector(1 downto 0);                     --
         -- AXI Address Channel BURST output                                --
                                                                            --
      mm2s_arprot   : out std_logic_vector(2 downto 0);                     --
         -- AXI Address Channel PROT output                                 --
                                                                            --
      mm2s_arcache  : out std_logic_vector(3 downto 0);                     --
         -- AXI Address Channel CACHE output                                --

      mm2s_aruser  : out std_logic_vector(3 downto 0);                     --
         -- AXI Address Channel CACHE output                                --
                                                                            --
      mm2s_arvalid  : out std_logic;                                        --
         -- AXI Address Channel VALID output                                --
                                                                            --
      mm2s_arready  : in  std_logic;                                        --
         -- AXI Address Channel READY input                                 --
      ------------------------------------------------------------------------
         
        
      -- Currently unsupported AXI Address Channel output signals ------------
        -- addr2axi_alock   : out std_logic_vector(2 downto 0);             --
        -- addr2axi_acache  : out std_logic_vector(4 downto 0);             --
        -- addr2axi_aqos    : out std_logic_vector(3 downto 0);             --
        -- addr2axi_aregion : out std_logic_vector(3 downto 0);             --
      ------------------------------------------------------------------------
  
  
  
  
      
      -- MM2S AXI MMap Read Data Channel I/O  -----------------------------------------
      mm2s_rdata              : In  std_logic_vector(C_MM2S_MDATA_WIDTH-1 downto 0); --
      mm2s_rresp              : In  std_logic_vector(1 downto 0);                    --
      mm2s_rlast              : In  std_logic;                                       --
      mm2s_rvalid             : In  std_logic;                                       --
      mm2s_rready             : Out std_logic;                                       --
      ---------------------------------------------------------------------------------
      
      
      
      -- MM2S AXI Master Stream Channel I/O  -------------------------------------------------
      mm2s_strm_wdata         : Out  std_logic_vector(C_MM2S_SDATA_WIDTH-1 downto 0);       --
      mm2s_strm_wstrb         : Out  std_logic_vector((C_MM2S_SDATA_WIDTH/8)-1 downto 0);   --
      mm2s_strm_wlast         : Out  std_logic;                                             --
      mm2s_strm_wvalid        : Out  std_logic;                                             --
      mm2s_strm_wready        : In   std_logic;                                             --
      ----------------------------------------------------------------------------------------
      
      -- Testing Support I/O -------------------------------------------
      mm2s_dbg_sel            : in  std_logic_vector( 3 downto 0);    --
      mm2s_dbg_data           : out std_logic_vector(31 downto 0)     --
      ------------------------------------------------------------------
      
      
      );
  
  end entity axi_datamover_mm2s_full_wrap;
  
  
  architecture implementation of axi_datamover_mm2s_full_wrap is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    -- Function Declarations   ----------------------------------------
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_calc_rdmux_sel_bits
    --
    -- Function Description:
    --  This function calculates the number of address bits needed for  
    -- the Read data mux select control. 
    --
    -------------------------------------------------------------------
    function func_calc_rdmux_sel_bits (mmap_dwidth_value : integer) return integer is
    
      Variable num_addr_bits_needed : Integer range 1 to 7 := 1;
    
    begin
    
      case mmap_dwidth_value is
        when 32 =>
          num_addr_bits_needed := 2;
        when 64 =>
          num_addr_bits_needed := 3;
        when 128 =>
          num_addr_bits_needed := 4;
        when 256 => 
          num_addr_bits_needed := 5;
        when 512 => 
          num_addr_bits_needed := 6;
        
        when others => -- 1024 bits
          num_addr_bits_needed := 7;
      end case;
      
      Return (num_addr_bits_needed);
       
    end function func_calc_rdmux_sel_bits;
    
     
     
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_include_dre
    --
    -- Function Description:
    -- This function desides if conditions are right for allowing DRE 
    -- inclusion.
    --
    -------------------------------------------------------------------
    function func_include_dre (need_dre          : integer;
                               needed_data_width : integer) return integer is
    
      Variable include_dre : Integer := 0;
    
    begin
    
      If (need_dre = 1 and 
          needed_data_width < 128 and
          needed_data_width >   8) Then
    
         include_dre := 1;
      
      Else 

        include_dre := 0;
      
      End if;
      
      Return (include_dre);
      
    end function func_include_dre;
    
 
 
    
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_get_align_width
    --
    -- Function Description:
    -- This function calculates the needed DRE alignment port width\
    -- based upon the inclusion of DRE and the needed bit width of the
    -- DRE.
    --
    -------------------------------------------------------------------
    function func_get_align_width (dre_included   : integer;
                                   dre_data_width : integer) return integer is
    
       Variable align_port_width : Integer := 1;
    
    begin
    
      if (dre_included = 1) then
      
        If (dre_data_width = 64) Then
    
          align_port_width := 3;
        
        Elsif (dre_data_width = 32) Then
    
          align_port_width := 2;
        
        else  -- 16 bit data width
    
          align_port_width := 1;
        
        End if;
      
      else -- no DRE
    
        align_port_width := 1;
        
      end if;
      
      Return (align_port_width);
       
    end function func_get_align_width;
    




    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_rnd2pwr_of_2
    --
    -- Function Description:
    --  Rounds the input value up to the nearest power of 2 between
    --  128 and 8192.
    --
    -------------------------------------------------------------------
    function funct_rnd2pwr_of_2 (input_value : integer) return integer is

      Variable temp_pwr2 : Integer := 128;

    begin

      if (input_value <= 128) then

         temp_pwr2 := 128;

      elsif (input_value <= 256) then

         temp_pwr2 := 256;

      elsif (input_value <= 512) then

         temp_pwr2 := 512;

      elsif (input_value <= 1024) then

         temp_pwr2 := 1024;

      elsif (input_value <= 2048) then

         temp_pwr2 := 2048;

      elsif (input_value <= 4096) then

         temp_pwr2 := 4096;

      else

         temp_pwr2 := 8192;

      end if;


      Return (temp_pwr2);

    end function funct_rnd2pwr_of_2;
    -------------------------------------------------------------------
    
   
   
   
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_sf_offset_width
    --
    -- Function Description:
    --  This function calculates the address offset width needed by
    -- the GP Store and Forward module with data packing.
    --
    -------------------------------------------------------------------
    function funct_get_sf_offset_width (mmap_dwidth   : integer;
                                        stream_dwidth : integer) return integer is
    
      Constant FCONST_WIDTH_RATIO     : integer := mmap_dwidth/stream_dwidth;
      
      Variable fvar_temp_offset_width : Integer := 1;
    
    begin
    
      case FCONST_WIDTH_RATIO is
        when 1 =>
          fvar_temp_offset_width := 1;
        when 2 =>
          fvar_temp_offset_width := 1;
        when 4 =>
          fvar_temp_offset_width := 2;
        when 8 =>
          fvar_temp_offset_width := 3;
        when 16 =>
          fvar_temp_offset_width := 4;
        when 32 =>
          fvar_temp_offset_width := 5;
        when 64 =>
          fvar_temp_offset_width := 6;
        when others => -- 128 ratio
          fvar_temp_offset_width := 7;
      end case;
      
      Return (fvar_temp_offset_width);
    
    
    end function funct_get_sf_offset_width;
    
   
     
     
     
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_stream_width2use
    --
    -- Function Description:
    --  This function calculates the Stream width to use for MM2S 
    -- modules upstream from the downsizing Store and Forward. If 
    -- Store and Forward is present, then the effective native width 
    -- is the MMAP data width. If no Store and Forward then the Stream
    -- width is the input Native Data width from the User. 
    --
    -------------------------------------------------------------------
    function funct_get_stream_width2use (mmap_data_width   : integer;
                                         stream_data_width : integer;
                                         sf_enabled        : integer) return integer is
    
      Variable fvar_temp_width : Integer := 32;
    
    begin
    
      If (sf_enabled = 1) Then
    
        fvar_temp_width := mmap_data_width;
      
      Else 

        fvar_temp_width := stream_data_width;
      
      End if;
     
      Return (fvar_temp_width);
     
    end function funct_get_stream_width2use;
    
   
    
    
    
    
    -- Constant Declarations   ----------------------------------------

     Constant SF_UPSIZED_SDATA_WIDTH  : integer := funct_get_stream_width2use(C_MM2S_MDATA_WIDTH,
                                                                              C_MM2S_SDATA_WIDTH,
                                                                              C_INCLUDE_MM2S_GP_SF);
     
     Constant LOGIC_LOW               : std_logic := '0';
     Constant LOGIC_HIGH              : std_logic := '1';     
     Constant INCLUDE_MM2S            : integer range  0 to    2 := C_INCLUDE_MM2S;
     Constant IS_MM2S                 : integer range  0 to    1 := 1;
     Constant MM2S_ARID_VALUE         : integer range  0 to  255 := C_MM2S_ARID;
     Constant MM2S_ARID_WIDTH         : integer range  1 to    8  := C_MM2S_ID_WIDTH;
     Constant MM2S_ADDR_WIDTH         : integer range 32 to   64 := C_MM2S_ADDR_WIDTH;
     Constant MM2S_MDATA_WIDTH        : integer range 32 to 1024 := C_MM2S_MDATA_WIDTH;
     Constant MM2S_SDATA_WIDTH        : integer range  8 to 1024 := C_MM2S_SDATA_WIDTH;
     Constant MM2S_TAG_WIDTH          : integer range  1 to    8 := C_TAG_WIDTH;
     Constant MM2S_CMD_WIDTH          : integer                  := (MM2S_TAG_WIDTH+C_MM2S_ADDR_WIDTH+32);
     Constant MM2S_STS_WIDTH          : integer                  := 8; -- always 8 for MM2S
     Constant INCLUDE_MM2S_STSFIFO    : integer range  0 to    1 := C_INCLUDE_MM2S_STSFIFO;
     Constant MM2S_STSCMD_FIFO_DEPTH  : integer range  1 to   16 := C_MM2S_STSCMD_FIFO_DEPTH;
     Constant MM2S_STSCMD_IS_ASYNC    : integer range  0 to    1 := C_MM2S_STSCMD_IS_ASYNC;
     Constant INCLUDE_MM2S_DRE        : integer range  0 to    1 := C_INCLUDE_MM2S_DRE;
     Constant MM2S_BURST_SIZE         : integer range 2 to  256 := C_MM2S_BURST_SIZE;
     Constant ADDR_CNTL_FIFO_DEPTH    : integer range  1 to   30 := C_MM2S_ADDR_PIPE_DEPTH;  
     Constant RD_DATA_CNTL_FIFO_DEPTH : integer range  1 to   30 := ADDR_CNTL_FIFO_DEPTH;
     Constant SEL_ADDR_WIDTH          : integer range  2 to    7 := func_calc_rdmux_sel_bits(MM2S_MDATA_WIDTH);
     Constant MM2S_BTT_USED           : integer range  8 to   23 := C_MM2S_BTT_USED;
     Constant NO_INDET_BTT            : integer range  0 to    1 := 0;
     Constant INCLUDE_DRE             : integer range  0 to    1 := func_include_dre(C_INCLUDE_MM2S_DRE,
                                                                                     C_MM2S_SDATA_WIDTH);
     Constant DRE_ALIGN_WIDTH         : integer range  1 to    3 := func_get_align_width(INCLUDE_DRE,
                                                                                        C_MM2S_SDATA_WIDTH);
     

     -- Calculates the minimum needed depth of the Store and Forward FIFO
     -- based on the MM2S pipeline depth and the max allowed Burst length
     Constant PIPEDEPTH_BURST_LEN_PROD : integer :=
                    (ADDR_CNTL_FIFO_DEPTH+2) * MM2S_BURST_SIZE;
              
              
     -- Assigns the depth of the optional Store and Forward FIFO to the nearest
     -- power of 2
     Constant SF_FIFO_DEPTH       : integer range 128 to 8192 :=
                                    funct_rnd2pwr_of_2(PIPEDEPTH_BURST_LEN_PROD);


     -- Calculate the width of the Store and Forward Starting Address Offset bus
     Constant SF_STRT_OFFSET_WIDTH : integer := funct_get_sf_offset_width(MM2S_MDATA_WIDTH,
                                                                          MM2S_SDATA_WIDTH);
     
     
     


     
    
    -- Signal Declarations  ------------------------------------------
    
     signal sig_cmd_stat_rst_user        : std_logic := '0';
     signal sig_cmd_stat_rst_int         : std_logic := '0';
     signal sig_mmap_rst                 : std_logic := '0';
     signal sig_stream_rst               : std_logic := '0';
     signal sig_mm2s_cmd_wdata           : std_logic_vector(MM2S_CMD_WIDTH-1 downto 0) := (others => '0');        
     signal sig_cache_data               : std_logic_vector(7 downto 0) := (others => '0');        
     signal sig_cmd2mstr_command         : std_logic_vector(MM2S_CMD_WIDTH-1 downto 0) := (others => '0');        
     signal sig_cmd2mstr_cmd_valid       : std_logic := '0';                                             
     signal sig_mst2cmd_cmd_ready        : std_logic := '0';                                             
     signal sig_mstr2addr_addr           : std_logic_vector(MM2S_ADDR_WIDTH-1 downto 0) := (others => '0');             
     signal first_addr           : std_logic_vector(MM2S_ADDR_WIDTH-1 downto 0) := (others => '0');             
     signal last_addr           : std_logic_vector(MM2S_ADDR_WIDTH-1 downto 0) := (others => '0');             
     signal sig_mstr2addr_len            : std_logic_vector(7 downto 0) := (others => '0');                          
     signal sig_mstr2addr_size           : std_logic_vector(2 downto 0) := (others => '0');                          
     signal sig_mstr2addr_burst          : std_logic_vector(1 downto 0) := (others => '0'); 
     signal sig_mstr2addr_cache          : std_logic_vector(3 downto 0) := (others => '0'); 
     signal sig_mstr2addr_user           : std_logic_vector(3 downto 0) := (others => '0'); 
     signal sig_mstr2addr_cmd_cmplt      : std_logic := '0';
     signal sig_mstr2addr_calc_error     : std_logic := '0';
     signal sig_mstr2addr_cmd_valid      : std_logic := '0';                                             
     signal sig_addr2mstr_cmd_ready      : std_logic := '0';                                              
     signal sig_mstr2data_saddr_lsb      : std_logic_vector(SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2data_len            : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_mstr2data_strt_strb      : std_logic_vector((SF_UPSIZED_SDATA_WIDTH/8)-1 downto 0) := (others => '0');      
     signal sig_mstr2data_last_strb      : std_logic_vector((SF_UPSIZED_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_mstr2data_drr            : std_logic := '0';
     signal sig_mstr2data_eof            : std_logic := '0';
     signal sig_mstr2data_sequential     : std_logic := '0';
     signal sig_mstr2data_calc_error     : std_logic := '0';
     signal sig_mstr2data_cmd_cmplt      : std_logic := '0';
     signal sig_mstr2data_cmd_valid      : std_logic := '0';                                             
     signal sig_data2mstr_cmd_ready      : std_logic := '0';
     signal sig_mstr2data_dre_src_align  : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');      
     signal sig_mstr2data_dre_dest_align : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');      
     signal sig_addr2data_addr_posted    : std_logic := '0';
     signal sig_data2all_dcntlr_halted   : std_logic := '0';
     signal sig_addr2rsc_calc_error      : std_logic := '0';
     signal sig_addr2rsc_cmd_fifo_empty  : std_logic := '0';
     signal sig_data2rsc_tag             : std_logic_vector(MM2S_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2rsc_calc_err        : std_logic := '0';                     
     signal sig_data2rsc_okay            : std_logic := '0';
     signal sig_data2rsc_decerr          : std_logic := '0';
     signal sig_data2rsc_slverr          : std_logic := '0';
     signal sig_data2rsc_cmd_cmplt       : std_logic := '0';
     signal sig_rsc2data_ready           : std_logic := '0';
     signal sig_data2rsc_valid           : std_logic := '0';
     signal sig_calc2dm_calc_err         : std_logic := '0';
     signal sig_rsc2stat_status          : std_logic_vector(MM2S_STS_WIDTH-1 downto 0) := (others => '0');
     signal sig_stat2rsc_status_ready    : std_logic := '0';   
     signal sig_rsc2stat_status_valid    : std_logic := '0';  
     signal sig_rsc2mstr_halt_pipe       : std_logic := '0';  
     signal sig_mstr2data_tag            : std_logic_vector(MM2S_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2addr_tag            : std_logic_vector(MM2S_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_dbg_data_mux_out         : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_0               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_1               : std_logic_vector(31 downto 0) := (others => '0');
     
     signal sig_sf2rdc_wready            : std_logic := '0';
     signal sig_rdc2sf_wvalid            : std_logic := '0';
     signal sig_rdc2sf_wdata             : std_logic_vector(SF_UPSIZED_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_rdc2sf_wstrb             : std_logic_vector((SF_UPSIZED_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_rdc2sf_wlast             : std_logic := '0';
     
     signal sig_skid2dre_wready          : std_logic := '0';
     signal sig_dre2skid_wvalid          : std_logic := '0';
     signal sig_dre2skid_wdata           : std_logic_vector(MM2S_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_dre2skid_wstrb           : std_logic_vector((MM2S_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_dre2skid_wlast           : std_logic := '0';
     
     signal sig_dre2sf_wready            : std_logic := '0';
     signal sig_sf2dre_wvalid            : std_logic := '0';
     signal sig_sf2dre_wdata             : std_logic_vector(MM2S_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_sf2dre_wstrb             : std_logic_vector((MM2S_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_sf2dre_wlast             : std_logic := '0';
   
     
     signal sig_rdc2dre_new_align        : std_logic := '0';
     signal sig_rdc2dre_use_autodest     : std_logic := '0';
     signal sig_rdc2dre_src_align        : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_rdc2dre_dest_align       : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_rdc2dre_flush            : std_logic := '0';
     
     signal sig_sf2dre_new_align         : std_logic := '0';
     signal sig_sf2dre_use_autodest      : std_logic := '0';
     signal sig_sf2dre_src_align         : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_sf2dre_dest_align        : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_sf2dre_flush             : std_logic := '0';
     
     signal sig_dre_new_align            : std_logic := '0';
     signal sig_dre_use_autodest         : std_logic := '0';
     signal sig_dre_src_align            : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_dre_dest_align           : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_dre_flush                : std_logic := '0';
     
     signal sig_rst2all_stop_request     : std_logic := '0';
     signal sig_data2rst_stop_cmplt      : std_logic := '0';
     signal sig_addr2rst_stop_cmplt      : std_logic := '0';
     signal sig_data2addr_stop_req       : std_logic := '0';
     signal sig_data2skid_halt           : std_logic := '0';
     
     signal sig_sf_allow_addr_req        : std_logic := '0';
     signal sig_mm2s_allow_addr_req      : std_logic := '0';
     signal sig_addr_req_posted          : std_logic := '0';
     signal sig_rd_xfer_cmplt            : std_logic := '0';
   
     signal sig_sf2mstr_cmd_ready        : std_logic := '0';
     signal sig_mstr2sf_cmd_valid        : std_logic := '0';
     signal sig_mstr2sf_tag              : std_logic_vector(MM2S_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2sf_dre_src_align    : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2sf_dre_dest_align   : std_logic_vector(DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2sf_btt              : std_logic_vector(MM2S_BTT_USED-1 downto 0) := (others => '0');
     signal sig_mstr2sf_drr              : std_logic := '0';
     signal sig_mstr2sf_eof              : std_logic := '0';
     signal sig_mstr2sf_calc_error       : std_logic := '0';
                                        
     signal sig_mstr2sf_strt_offset      : std_logic_vector(SF_STRT_OFFSET_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2sf_cmd_cmplt        : std_logic := '0';
     signal sig_cache2mstr_command       : std_logic_vector (7 downto 0);
     signal mm2s_arcache_int             : std_logic_vector (3 downto 0);
     signal mm2s_aruser_int             : std_logic_vector (3 downto 0);
 
     
     
    
  begin --(architecture implementation)
  
  
    
    -- Debug vector output
    mm2s_dbg_data  <= sig_dbg_data_mux_out;
    
    
    -- Note that only the mm2s_dbg_sel(0) is used at this time
    sig_dbg_data_mux_out <= sig_dbg_data_1
      When (mm2s_dbg_sel(0) = '1')
      else sig_dbg_data_0 ;
    
    
    sig_dbg_data_0              <=  X"BEEF1111"             ; -- 32 bit Constant indicating MM2S Full type
    
    sig_dbg_data_1(0)           <= sig_cmd_stat_rst_user    ;
    sig_dbg_data_1(1)           <= sig_cmd_stat_rst_int     ;
    sig_dbg_data_1(2)           <= sig_mmap_rst             ;
    sig_dbg_data_1(3)           <= sig_stream_rst           ;
    sig_dbg_data_1(4)           <= sig_cmd2mstr_cmd_valid   ;
    sig_dbg_data_1(5)           <= sig_mst2cmd_cmd_ready    ;
    sig_dbg_data_1(6)           <= sig_stat2rsc_status_ready;
    sig_dbg_data_1(7)           <= sig_rsc2stat_status_valid;
    sig_dbg_data_1(11 downto 8) <= sig_data2rsc_tag         ; -- Current TAG of active data transfer


    sig_dbg_data_1(15 downto 12) <= sig_rsc2stat_status(3 downto 0); -- Internal status tag field
    sig_dbg_data_1(16)           <= sig_rsc2stat_status(4)         ; -- Internal error
    sig_dbg_data_1(17)           <= sig_rsc2stat_status(5)         ; -- Decode Error
    sig_dbg_data_1(18)           <= sig_rsc2stat_status(6)         ; -- Slave Error
    sig_dbg_data_1(19)           <= sig_rsc2stat_status(7)         ; -- OKAY
    sig_dbg_data_1(20)           <= sig_stat2rsc_status_ready      ; -- Status Ready Handshake
    sig_dbg_data_1(21)           <= sig_rsc2stat_status_valid      ; -- Status Valid Handshake
                        
    
    -- Spare bits in debug1
    sig_dbg_data_1(31 downto 22) <= (others => '0')                ; -- spare bits
                        
                        
                        
     
     
    GEN_CACHE : if (C_ENABLE_CACHE_USER = 0) generate

       begin
 
    -- Cache signal tie-off
    mm2s_arcache       <= "0011";  -- Per Interface-X guidelines for Masters
    mm2s_aruser       <= "0000";  -- Per Interface-X guidelines for Masters
    sig_cache_data <= (others => '0'); --mm2s_cmd_wdata(103 downto 96);   -- This is the xUser and xCache values
     
       end generate GEN_CACHE;                 


    GEN_CACHE2 : if (C_ENABLE_CACHE_USER = 1) generate

       begin
 
    -- Cache signal tie-off
    mm2s_arcache       <= mm2s_arcache_int;  -- Cache from Desc
    mm2s_aruser       <= mm2s_aruser_int;  -- Cache from Desc
  --  sig_cache_data <= mm2s_cmd_wdata(103 downto 96);   -- This is the xUser and xCache values
    sig_cache_data <= mm2s_cmd_wdata(79 downto 72);   -- This is the xUser and xCache values
     
       end generate GEN_CACHE2;                 
                       
    -- Internal error output discrete ------------------------------
    mm2s_err           <=  sig_calc2dm_calc_err;
    
    
    -- Rip the used portion of the Command Interface Command Data
    -- and throw away the padding
    sig_mm2s_cmd_wdata <= mm2s_cmd_wdata(MM2S_CMD_WIDTH-1 downto 0);
    
         
    ------------------------------------------------------------
    -- Instance: I_RESET 
    --
    -- Description:
    --   Reset Block  
    --
    ------------------------------------------------------------
    I_RESET : entity axi_datamover_v5_1.axi_datamover_reset
    generic map (
  
      C_STSCMD_IS_ASYNC    =>  MM2S_STSCMD_IS_ASYNC      
  
      )
    port map (
  
      primary_aclk         =>  mm2s_aclk                ,
      primary_aresetn      =>  mm2s_aresetn             ,
      secondary_awclk      =>  mm2s_cmdsts_awclk        ,
      secondary_aresetn    =>  mm2s_cmdsts_aresetn      ,
      
      halt_req             =>  mm2s_halt                ,
      halt_cmplt           =>  mm2s_halt_cmplt          ,
      flush_stop_request   =>  sig_rst2all_stop_request ,
      data_cntlr_stopped   =>  sig_data2rst_stop_cmplt  ,
      addr_cntlr_stopped   =>  sig_addr2rst_stop_cmplt  ,
      aux1_stopped         =>  LOGIC_HIGH               ,
      aux2_stopped         =>  LOGIC_HIGH               ,
      
      cmd_stat_rst_user    =>  sig_cmd_stat_rst_user    ,
      cmd_stat_rst_int     =>  sig_cmd_stat_rst_int     ,
      mmap_rst             =>  sig_mmap_rst             ,
      stream_rst           =>  sig_stream_rst            
  
      );
  
   
   
 
 
         
    ------------------------------------------------------------
    -- Instance: I_CMD_STATUS 
    --
    -- Description:
    --   Command and Status Interface Block  
    --
    ------------------------------------------------------------
     I_CMD_STATUS : entity axi_datamover_v5_1.axi_datamover_cmd_status
     generic map (
   
       C_ADDR_WIDTH           =>  MM2S_ADDR_WIDTH           , 
       C_INCLUDE_STSFIFO      =>  INCLUDE_MM2S_STSFIFO      , 
       C_STSCMD_FIFO_DEPTH    =>  MM2S_STSCMD_FIFO_DEPTH    , 
       C_STSCMD_IS_ASYNC      =>  MM2S_STSCMD_IS_ASYNC      , 
       C_CMD_WIDTH            =>  MM2S_CMD_WIDTH            , 
       C_STS_WIDTH            =>  MM2S_STS_WIDTH            , 
       C_ENABLE_CACHE_USER    =>  C_ENABLE_CACHE_USER       ,
       C_FAMILY               =>  C_FAMILY                    

       )
     port map (
   
       primary_aclk           =>  mm2s_aclk                 , 
       secondary_awclk        =>  mm2s_cmdsts_awclk         , 
       user_reset             =>  sig_cmd_stat_rst_user     , 
       internal_reset         =>  sig_cmd_stat_rst_int      , 
       cmd_wvalid             =>  mm2s_cmd_wvalid           , 
       cmd_wready             =>  mm2s_cmd_wready           , 
       cmd_wdata              =>  sig_mm2s_cmd_wdata        , 
       cache_data             =>  sig_cache_data            ,
       sts_wvalid             =>  mm2s_sts_wvalid           , 
       sts_wready             =>  mm2s_sts_wready           , 
       sts_wdata              =>  mm2s_sts_wdata            , 
       sts_wstrb              =>  mm2s_sts_wstrb            , 
       sts_wlast              =>  mm2s_sts_wlast            , 
       cmd2mstr_command       =>  sig_cmd2mstr_command      , 
       cache2mstr_command     =>  sig_cache2mstr_command      , 
       mst2cmd_cmd_valid      =>  sig_cmd2mstr_cmd_valid    ,    
       cmd2mstr_cmd_ready     =>  sig_mst2cmd_cmd_ready     , 
       mstr2stat_status       =>  sig_rsc2stat_status       , 
       stat2mstr_status_ready =>  sig_stat2rsc_status_ready , 
       mst2stst_status_valid  =>  sig_rsc2stat_status_valid   
   
       );
   
   
   
 
 
         
    ------------------------------------------------------------
    -- Instance: I_RD_STATUS_CNTLR 
    --
    -- Description:
    -- Read Status Controller Block    
    --
    ------------------------------------------------------------
     I_RD_STATUS_CNTLR : entity axi_datamover_v5_1.axi_datamover_rd_status_cntl
     generic map (
   
       C_STS_WIDTH            =>  MM2S_STS_WIDTH ,      
       C_TAG_WIDTH            =>  MM2S_TAG_WIDTH        

       )
     port map (
   
       primary_aclk           =>  mm2s_aclk                   ,  
       mmap_reset             =>  sig_mmap_rst                ,  
       calc2rsc_calc_error    =>  sig_calc2dm_calc_err        ,  
       addr2rsc_calc_error    =>  sig_addr2rsc_calc_error     ,  
       addr2rsc_fifo_empty    =>  sig_addr2rsc_cmd_fifo_empty ,  
       data2rsc_tag           =>  sig_data2rsc_tag            ,  
       data2rsc_calc_error    =>  sig_data2rsc_calc_err       ,  
       data2rsc_okay          =>  sig_data2rsc_okay           ,  
       data2rsc_decerr        =>  sig_data2rsc_decerr         ,  
       data2rsc_slverr        =>  sig_data2rsc_slverr         ,  
       data2rsc_cmd_cmplt     =>  sig_data2rsc_cmd_cmplt      ,  
       rsc2data_ready         =>  sig_rsc2data_ready          ,  
       data2rsc_valid         =>  sig_data2rsc_valid          ,  
       rsc2stat_status        =>  sig_rsc2stat_status         ,  
       stat2rsc_status_ready  =>  sig_stat2rsc_status_ready   ,  
       rsc2stat_status_valid  =>  sig_rsc2stat_status_valid   ,  
       rsc2mstr_halt_pipe     =>  sig_rsc2mstr_halt_pipe         
     
       );
   
   
   
 
 
         
   ------------------------------------------------------------
   -- Instance: I_MSTR_PCC 
   --
   -- Description:
   -- Predictive Command Calculator Block   
   --
   ------------------------------------------------------------
    I_MSTR_PCC : entity axi_datamover_v5_1.axi_datamover_pcc
    generic map (
  
      C_IS_MM2S                 =>  IS_MM2S                      ,
      C_DRE_ALIGN_WIDTH         =>  DRE_ALIGN_WIDTH              , 
      C_SEL_ADDR_WIDTH          =>  SEL_ADDR_WIDTH               , 
      C_ADDR_WIDTH              =>  MM2S_ADDR_WIDTH              , 
      C_STREAM_DWIDTH           =>  MM2S_SDATA_WIDTH             , 
      C_MAX_BURST_LEN           =>  MM2S_BURST_SIZE              , 
      C_CMD_WIDTH               =>  MM2S_CMD_WIDTH               , 
      C_TAG_WIDTH               =>  MM2S_TAG_WIDTH               , 
      C_BTT_USED                =>  MM2S_BTT_USED                , 
      C_SUPPORT_INDET_BTT       =>  NO_INDET_BTT                 ,  
      C_NATIVE_XFER_WIDTH       =>  SF_UPSIZED_SDATA_WIDTH       ,
      C_STRT_SF_OFFSET_WIDTH    =>  SF_STRT_OFFSET_WIDTH
  
      )
    port map (
  
      -- Clock input
      primary_aclk              =>  mm2s_aclk                    , 
      mmap_reset                =>  sig_mmap_rst                 , 
      cmd2mstr_command          =>  sig_cmd2mstr_command         , 
      cache2mstr_command        =>  sig_cache2mstr_command       ,
      cmd2mstr_cmd_valid        =>  sig_cmd2mstr_cmd_valid       , 
      mst2cmd_cmd_ready         =>  sig_mst2cmd_cmd_ready        , 
      
      mstr2addr_tag             =>  sig_mstr2addr_tag            , 
      mstr2addr_addr            =>  sig_mstr2addr_addr           , 
      mstr2addr_len             =>  sig_mstr2addr_len            , 
      mstr2addr_size            =>  sig_mstr2addr_size           , 
      mstr2addr_burst           =>  sig_mstr2addr_burst          , 
      mstr2addr_cache           =>  sig_mstr2addr_cache          , 
      mstr2addr_user            =>  sig_mstr2addr_user           , 
      mstr2addr_cmd_cmplt       =>  sig_mstr2addr_cmd_cmplt      ,
      mstr2addr_calc_error      =>  sig_mstr2addr_calc_error     , 
      mstr2addr_cmd_valid       =>  sig_mstr2addr_cmd_valid      ,
      addr2mstr_cmd_ready       =>  sig_addr2mstr_cmd_ready      , 
      
      mstr2data_tag             =>  sig_mstr2data_tag            , 
      mstr2data_saddr_lsb       =>  sig_mstr2data_saddr_lsb      , 
      mstr2data_len             =>  sig_mstr2data_len            , 
      mstr2data_strt_strb       =>  sig_mstr2data_strt_strb      , 
      mstr2data_last_strb       =>  sig_mstr2data_last_strb      , 
      mstr2data_drr             =>  sig_mstr2data_drr            , 
      mstr2data_eof             =>  sig_mstr2data_eof            , 
      mstr2data_sequential      =>  sig_mstr2data_sequential     , 
      mstr2data_calc_error      =>  sig_mstr2data_calc_error     , 
      mstr2data_cmd_cmplt       =>  sig_mstr2data_cmd_cmplt      , 
      mstr2data_cmd_valid       =>  sig_mstr2data_cmd_valid      , 
      data2mstr_cmd_ready       =>  sig_data2mstr_cmd_ready      , 
      mstr2data_dre_src_align   =>  sig_mstr2data_dre_src_align  , 
      mstr2data_dre_dest_align  =>  sig_mstr2data_dre_dest_align , 
      
      calc_error                =>  sig_calc2dm_calc_err         , 
      
      dre2mstr_cmd_ready        =>  sig_sf2mstr_cmd_ready        , 
      mstr2dre_cmd_valid        =>  sig_mstr2sf_cmd_valid        , 
      mstr2dre_tag              =>  sig_mstr2sf_tag              , 
      mstr2dre_dre_src_align    =>  sig_mstr2sf_dre_src_align    , 
      mstr2dre_dre_dest_align   =>  sig_mstr2sf_dre_dest_align   , 
      mstr2dre_btt              =>  sig_mstr2sf_btt              , 
      mstr2dre_drr              =>  sig_mstr2sf_drr              , 
      mstr2dre_eof              =>  sig_mstr2sf_eof              , 
      mstr2dre_cmd_cmplt        =>  open                         ,
      mstr2dre_calc_error       =>  sig_mstr2sf_calc_error       ,  
    
      mstr2dre_strt_offset      =>  sig_mstr2sf_strt_offset 
      
      );
   
   
   
 
 
         
    ------------------------------------------------------------
    -- Instance: I_ADDR_CNTL 
    --
    -- Description:
    --   Address Controller Block  
    --
    ------------------------------------------------------------
     I_ADDR_CNTL : entity axi_datamover_v5_1.axi_datamover_addr_cntl
     generic map (
   
       C_ADDR_FIFO_DEPTH            =>  ADDR_CNTL_FIFO_DEPTH        , 
       C_ADDR_WIDTH                 =>  MM2S_ADDR_WIDTH             , 
       C_ADDR_ID                    =>  MM2S_ARID_VALUE             , 
       C_ADDR_ID_WIDTH              =>  MM2S_ARID_WIDTH             , 
       C_TAG_WIDTH                  =>  MM2S_TAG_WIDTH              ,
       C_FAMILY               =>  C_FAMILY  
   
       )
     port map (
   
       primary_aclk                 =>  mm2s_aclk                   ,
       mmap_reset                   =>  sig_mmap_rst                ,
       
       addr2axi_aid                 =>  mm2s_arid                   ,
       addr2axi_aaddr               =>  mm2s_araddr                 ,
       addr2axi_alen                =>  mm2s_arlen                  ,
       addr2axi_asize               =>  mm2s_arsize                 ,
       addr2axi_aburst              =>  mm2s_arburst                ,
       addr2axi_aprot               =>  mm2s_arprot                 ,
       addr2axi_avalid              =>  mm2s_arvalid                ,
       addr2axi_acache               =>  mm2s_arcache_int            ,
       addr2axi_auser                =>  mm2s_aruser_int             ,
       axi2addr_aready              =>  mm2s_arready                ,
       
       mstr2addr_tag                =>  sig_mstr2addr_tag           ,
       mstr2addr_addr               =>  sig_mstr2addr_addr          ,
       mstr2addr_len                =>  sig_mstr2addr_len           ,
       mstr2addr_size               =>  sig_mstr2addr_size          ,
       mstr2addr_burst              =>  sig_mstr2addr_burst         ,
       mstr2addr_cache              =>  sig_mstr2addr_cache         ,
       mstr2addr_user               =>  sig_mstr2addr_user          ,
       mstr2addr_cmd_cmplt          =>  sig_mstr2addr_cmd_cmplt     ,
       mstr2addr_calc_error         =>  sig_mstr2addr_calc_error    ,
       mstr2addr_cmd_valid          =>  sig_mstr2addr_cmd_valid     ,
       addr2mstr_cmd_ready          =>  sig_addr2mstr_cmd_ready     ,
       
       addr2rst_stop_cmplt          =>  sig_addr2rst_stop_cmplt     ,
       
       allow_addr_req               =>  sig_mm2s_allow_addr_req     ,
       addr_req_posted              =>  sig_addr_req_posted         ,
       
       addr2data_addr_posted        =>  sig_addr2data_addr_posted   ,
       data2addr_data_rdy           =>  LOGIC_LOW                   ,
       data2addr_stop_req           =>  sig_data2addr_stop_req      ,
       
       addr2stat_calc_error         =>  sig_addr2rsc_calc_error     ,
       addr2stat_cmd_fifo_empty     =>  sig_addr2rsc_cmd_fifo_empty  
       );
   
   
   
 
 
         
     ------------------------------------------------------------
     -- Instance: I_RD_DATA_CNTL 
     --
     -- Description:
     --     Read Data Controller Block
     --
     ------------------------------------------------------------
      I_RD_DATA_CNTL : entity axi_datamover_v5_1.axi_datamover_rddata_cntl
      generic map (
        
        C_INCLUDE_DRE             =>  INCLUDE_DRE                  , 
        C_ALIGN_WIDTH             =>  DRE_ALIGN_WIDTH              , 
        C_SEL_ADDR_WIDTH          =>  SEL_ADDR_WIDTH               , 
        C_DATA_CNTL_FIFO_DEPTH    =>  RD_DATA_CNTL_FIFO_DEPTH      , 
        C_MMAP_DWIDTH             =>  MM2S_MDATA_WIDTH             , 
        C_STREAM_DWIDTH           =>  SF_UPSIZED_SDATA_WIDTH       , 
          C_ENABLE_MM2S_TKEEP       =>  C_ENABLE_MM2S_TKEEP        ,
        C_TAG_WIDTH               =>  MM2S_TAG_WIDTH               , 
        C_FAMILY                  =>  C_FAMILY                       
    
        )
      port map (
    
        -- Clock and Reset  -----------------------------------
        primary_aclk              =>  mm2s_aclk                    , 
        mmap_reset                =>  sig_mmap_rst                 , 
     
        -- Soft Shutdown Interface -----------------------------
        rst2data_stop_request     =>  sig_rst2all_stop_request     , 
        data2addr_stop_req        =>  sig_data2addr_stop_req       , 
        data2rst_stop_cmplt       =>  sig_data2rst_stop_cmplt      , 
        
        -- External Address Pipelining Contol support
        mm2s_rd_xfer_cmplt        =>  sig_rd_xfer_cmplt            ,
        
        
        -- AXI Read Data Channel I/O  -------------------------------
        mm2s_rdata                =>  mm2s_rdata                   , 
        mm2s_rresp                =>  mm2s_rresp                   , 
        mm2s_rlast                =>  mm2s_rlast                   , 
        mm2s_rvalid               =>  mm2s_rvalid                  , 
        mm2s_rready               =>  mm2s_rready                  , 
        
        -- MM2S DRE Control  -----------------------------------
        mm2s_dre_new_align        =>  sig_rdc2dre_new_align        , 
        mm2s_dre_use_autodest     =>  sig_rdc2dre_use_autodest     , 
        mm2s_dre_src_align        =>  sig_rdc2dre_src_align        , 
        mm2s_dre_dest_align       =>  sig_rdc2dre_dest_align       , 
        mm2s_dre_flush            =>  sig_rdc2dre_flush            , 
        
        -- AXI Master Stream  -----------------------------------
        mm2s_strm_wvalid          =>  sig_rdc2sf_wvalid           , 
        mm2s_strm_wready          =>  sig_sf2rdc_wready           , 
        mm2s_strm_wdata           =>  sig_rdc2sf_wdata            ,     
        mm2s_strm_wstrb           =>  sig_rdc2sf_wstrb            ,         
        mm2s_strm_wlast           =>  sig_rdc2sf_wlast            , 
       
      -- MM2S Store and Forward Supplimental Control   ----------
        mm2s_data2sf_cmd_cmplt    =>  sig_data2sf_cmd_cmplt       ,
       
       
        
        -- Command Calculator Interface --------------------------
        mstr2data_tag             =>  sig_mstr2data_tag            , 
        mstr2data_saddr_lsb       =>  sig_mstr2data_saddr_lsb      , 
        mstr2data_len             =>  sig_mstr2data_len            , 
        mstr2data_strt_strb       =>  sig_mstr2data_strt_strb      , 
        mstr2data_last_strb       =>  sig_mstr2data_last_strb      , 
        mstr2data_drr             =>  sig_mstr2data_drr            , 
        mstr2data_eof             =>  sig_mstr2data_eof            , 
        mstr2data_sequential      =>  sig_mstr2data_sequential     , 
        mstr2data_calc_error      =>  sig_mstr2data_calc_error     , 
        mstr2data_cmd_cmplt       =>  sig_mstr2data_cmd_cmplt      , 
        mstr2data_cmd_valid       =>  sig_mstr2data_cmd_valid      , 
        data2mstr_cmd_ready       =>  sig_data2mstr_cmd_ready      , 
        mstr2data_dre_src_align   =>  sig_mstr2data_dre_src_align  , 
        mstr2data_dre_dest_align  =>  sig_mstr2data_dre_dest_align , 

        
        -- Address Controller Interface --------------------------
        addr2data_addr_posted     =>  sig_addr2data_addr_posted    , 
        
        -- Data Controller Halted Status
        data2all_dcntlr_halted    =>  sig_data2all_dcntlr_halted   , 
        
        -- Output Stream Skid Buffer Halt control
        data2skid_halt            =>  sig_data2skid_halt           , 
        
        
        -- Read Status Controller Interface --------------------------
        data2rsc_tag              =>  sig_data2rsc_tag             ,   
        data2rsc_calc_err         =>  sig_data2rsc_calc_err        ,   
        data2rsc_okay             =>  sig_data2rsc_okay            ,   
        data2rsc_decerr           =>  sig_data2rsc_decerr          ,   
        data2rsc_slverr           =>  sig_data2rsc_slverr          ,   
        data2rsc_cmd_cmplt        =>  sig_data2rsc_cmd_cmplt       ,   
        rsc2data_ready            =>  sig_rsc2data_ready           ,   
        data2rsc_valid            =>  sig_data2rsc_valid           ,   
        rsc2mstr_halt_pipe        =>  sig_rsc2mstr_halt_pipe           
         
        );
   
   
   
 
    
 
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_MM2S_SF
    --
    -- If Generate Description:
    --   Include the MM2S Store and Forward function
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_MM2S_SF : if (C_INCLUDE_MM2S_GP_SF = 1) generate
    
       begin

         -- Merge external address posting control with the
         -- Store and Forward address posting control
         sig_mm2s_allow_addr_req <= sig_sf_allow_addr_req and
                                    mm2s_allow_addr_req;
       
         -- Address Posting support outputs
         mm2s_addr_req_posted    <= sig_addr_req_posted   ;
         mm2s_rd_xfer_cmplt      <= sig_rd_xfer_cmplt     ;
         
                                  
         sig_dre_new_align       <=  sig_sf2dre_new_align    ;
         sig_dre_use_autodest    <=  sig_sf2dre_use_autodest ;
         sig_dre_src_align       <=  sig_sf2dre_src_align    ;
         sig_dre_dest_align      <=  sig_sf2dre_dest_align   ;
         sig_dre_flush           <=  sig_sf2dre_flush        ;
                                                             
         
         
         
         
       
        
             
         ------------------------------------------------------------
         -- Instance: I_RD_SF 
         --
         -- Description:
         --   Instance for the MM2S Store and Forward module with
         -- downsizer support.  
         --
         ------------------------------------------------------------
         I_RD_SF : entity axi_datamover_v5_1.axi_datamover_rd_sf
         generic map (
              
           C_SF_FIFO_DEPTH        => SF_FIFO_DEPTH           ,
           C_MAX_BURST_LEN        => MM2S_BURST_SIZE         ,   
           C_DRE_IS_USED          => INCLUDE_DRE             , 
           C_DRE_CNTL_FIFO_DEPTH  => RD_DATA_CNTL_FIFO_DEPTH ,
           C_DRE_ALIGN_WIDTH      => DRE_ALIGN_WIDTH         ,
           C_MMAP_DWIDTH          => MM2S_MDATA_WIDTH        ,
           C_STREAM_DWIDTH        => MM2S_SDATA_WIDTH        ,   
           C_STRT_SF_OFFSET_WIDTH => SF_STRT_OFFSET_WIDTH    ,
           C_TAG_WIDTH            => MM2S_TAG_WIDTH          ,
          C_ENABLE_MM2S_TKEEP       =>  C_ENABLE_MM2S_TKEEP        ,
           C_FAMILY               => C_FAMILY                    
           )
         port map (
       
           -- Clock and Reset inputs -------------------------------
           aclk                     => mm2s_aclk             ,                     
           reset                    => sig_mmap_rst          ,                     
           
           
           -- DataMover Read Side Address Pipelining Control Interface 
           ok_to_post_rd_addr       => sig_sf_allow_addr_req ,                    
           rd_addr_posted           => sig_addr_req_posted   ,                              
           rd_xfer_cmplt            => sig_rd_xfer_cmplt     ,                              
           
            
             
           -- Read Side Stream In from DataMover MM2S Read Data Controller -----
           sf2sin_tready            => sig_sf2rdc_wready     ,         
           sin2sf_tvalid            => sig_rdc2sf_wvalid     ,         
           sin2sf_tdata             => sig_rdc2sf_wdata      ,         
           sin2sf_tkeep             => sig_rdc2sf_wstrb      ,            
           sin2sf_tlast             => sig_rdc2sf_wlast      ,         

           -- RDC Store and Forward Supplimental Controls ----------
           data2sf_cmd_cmplt        => sig_data2sf_cmd_cmplt ,
           data2sf_dre_flush        => sig_rdc2dre_flush     ,
          
                    
           -- DRE Control Interface from the Command Calculator -----------------------------
           dre2mstr_cmd_ready       => sig_sf2mstr_cmd_ready       ,
           mstr2dre_cmd_valid       => sig_mstr2sf_cmd_valid       ,
           mstr2dre_tag             => sig_mstr2sf_tag             ,
           mstr2dre_dre_src_align   => sig_mstr2sf_dre_src_align   , 
           mstr2dre_dre_dest_align  => sig_mstr2sf_dre_dest_align  , 
           mstr2dre_drr             => sig_mstr2sf_drr             ,
           mstr2dre_eof             => sig_mstr2sf_eof             ,
           mstr2dre_calc_error      => sig_mstr2sf_calc_error      ,
           mstr2dre_strt_offset     => sig_mstr2sf_strt_offset     ,
                                         
           
                     
     
           -- MM2S DRE Control  -------------------------------------------------------------
           sf2dre_new_align         => sig_sf2dre_new_align    ,
           sf2dre_use_autodest      => sig_sf2dre_use_autodest ,
           sf2dre_src_align         => sig_sf2dre_src_align    ,
           sf2dre_dest_align        => sig_sf2dre_dest_align   ,
           sf2dre_flush             => sig_sf2dre_flush        ,
           
            
           
           -- Stream Out  ----------------------------------
           sout2sf_tready           => sig_dre2sf_wready    ,   
           sf2sout_tvalid           => sig_sf2dre_wvalid    ,   
           sf2sout_tdata            => sig_sf2dre_wdata     ,   
           sf2sout_tkeep            => sig_sf2dre_wstrb     ,   
           sf2sout_tlast            => sig_sf2dre_wlast         
              
           );
        
        
        --  ------------------------------------------------------------
        --  -- Instance: I_RD_SF 
        --  --
        --  -- Description:
        --  --   Instance for the MM2S Store and Forward module.  
        --  --
        --  ------------------------------------------------------------
        --  I_RD_SF : entity axi_datamover_v5_1.axi_datamover_rd_sf
        --  generic map (
        --       
        --    C_SF_FIFO_DEPTH        => SF_FIFO_DEPTH    ,
        --    C_MAX_BURST_LEN        => MM2S_BURST_SIZE  ,   
        --    C_DRE_IS_USED          => INCLUDE_DRE      ,   
        --    C_STREAM_DWIDTH        => MM2S_SDATA_WIDTH ,   
        --    C_FAMILY               => C_FAMILY             
        --    )
        --  port map (
        -- 
        --    -- Clock and Reset inputs -------------------------------
        --    aclk                   => mm2s_aclk             ,                     
        --    reset                  => sig_mmap_rst          ,                     
        --    
        --    
        --    -- DataMover Read Side Address Pipelining Control Interface 
        --    ok_to_post_rd_addr     => sig_sf_allow_addr_req ,                    
        --    rd_addr_posted         => sig_addr_req_posted   ,                              
        --    rd_xfer_cmplt          => sig_rd_xfer_cmplt     ,                              
        --    
        --     
        --      
        --    -- Read Side Stream In from DataMover MM2S -----
        --    sf2sin_tready          => sig_sf2dre_wready     ,         
        --    sin2sf_tvalid          => sig_dre2sf_wvalid     ,         
        --    sin2sf_tdata           => sig_dre2sf_wdata      ,         
        --    sin2sf_tkeep           => sig_dre2sf_wstrb      ,            
        --    sin2sf_tlast           => sig_dre2sf_wlast      ,         
        -- 
        --             
        --              
        --    -- Stream Out  ----------------------------------
        --    sout2sf_tready         => sig_skid2sf_wready    ,   
        --    sf2sout_tvalid         => sig_sf2skid_wvalid    ,   
        --    sf2sout_tdata          => sig_sf2skid_wdata     ,   
        --    sf2sout_tkeep          => sig_sf2skid_wstrb     ,   
        --    sf2sout_tlast          => sig_sf2skid_wlast         
        --       
        --    );
        
        
        
        
         
       end generate GEN_INCLUDE_MM2S_SF;
       
       






    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_MM2S_SF
    --
    -- If Generate Description:
    --   Omit the MM2S Store and Forward function
    --
    --
    ------------------------------------------------------------
    GEN_NO_MM2S_SF : if (C_INCLUDE_MM2S_GP_SF = 0) generate
    
       begin

         -- Allow external address posting control
         -- Ignore Store and Forward Control
         sig_mm2s_allow_addr_req <= mm2s_allow_addr_req ;
         sig_sf_allow_addr_req   <= '0'                 ;
  
         -- Address Posting support outputs
         mm2s_addr_req_posted <= sig_addr_req_posted    ;
         mm2s_rd_xfer_cmplt   <= sig_rd_xfer_cmplt      ;
         
  
  
         -- DRE Control Bus (Connect to the Read data Controller)                         
         sig_dre_new_align       <= sig_rdc2dre_new_align     ;
         sig_dre_use_autodest    <= sig_rdc2dre_use_autodest  ;
         sig_dre_src_align       <= sig_rdc2dre_src_align     ;
         sig_dre_dest_align      <= sig_rdc2dre_dest_align    ;
         sig_dre_flush           <= sig_rdc2dre_flush         ;
                                                             
  
         -- Just pass stream signals through
         sig_sf2rdc_wready       <= sig_dre2sf_wready   ; 
         
         sig_sf2dre_wvalid       <= sig_rdc2sf_wvalid   ;   
         sig_sf2dre_wdata        <= sig_rdc2sf_wdata    ;   
         sig_sf2dre_wstrb        <= sig_rdc2sf_wstrb    ;   
         sig_sf2dre_wlast        <= sig_rdc2sf_wlast    ;   
          
                                                           
         -- Always enable the DRE Cmd bus for loading to keep from
         -- stalling the PCC module
         sig_sf2mstr_cmd_ready  <= LOGIC_HIGH;
         
                                                           
       end generate GEN_NO_MM2S_SF;
       
       





    
         
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_MM2S_DRE
    --
    -- If Generate Description:
    --   Include the MM2S DRE
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_MM2S_DRE : if (INCLUDE_DRE = 1) generate
    
       begin

       
       
         ------------------------------------------------------------
         -- Instance: I_DRE64 
         --
         -- Description:
         -- Instance for the MM2S DRE whach can support widths of 
         -- 16 bits to 64 bits.     
         --
         ------------------------------------------------------------
          I_DRE_16_to_64 : entity axi_datamover_v5_1.axi_datamover_mm2s_dre
          generic map (
        
            C_DWIDTH         =>  MM2S_SDATA_WIDTH      , 
            C_ALIGN_WIDTH    =>  DRE_ALIGN_WIDTH           
        
            )
          port map (
        
           -- Control inputs
            dre_clk          =>  mm2s_aclk              , 
            dre_rst          =>  sig_stream_rst         , 
          
            dre_new_align    => sig_dre_new_align       , 
            dre_use_autodest => sig_dre_use_autodest    , 
            dre_src_align    => sig_dre_src_align       , 
            dre_dest_align   => sig_dre_dest_align      , 
            dre_flush        => sig_dre_flush           , 

           -- Stream Inputs
            dre_in_tstrb     => sig_sf2dre_wstrb        , 
            dre_in_tdata     => sig_sf2dre_wdata        , 
            dre_in_tlast     => sig_sf2dre_wlast        , 
            dre_in_tvalid    => sig_sf2dre_wvalid       , 
            dre_in_tready    => sig_dre2sf_wready       , 

         
           -- Stream Outputs
            dre_out_tstrb    => sig_dre2skid_wstrb      , 
            dre_out_tdata    => sig_dre2skid_wdata      , 
            dre_out_tlast    => sig_dre2skid_wlast      , 
            dre_out_tvalid   => sig_dre2skid_wvalid     , 
            dre_out_tready   => sig_skid2dre_wready       
        
            );
        
       
 
 
          
       end generate GEN_INCLUDE_MM2S_DRE;
     
     
     
     
     
       
       
    
         
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_MM2S_DRE
    --
    -- If Generate Description:
    --   Omit the MM2S DRE and housekeep the signals that it 
    -- needs to output.
    --
    ------------------------------------------------------------
    GEN_NO_MM2S_DRE : if (INCLUDE_DRE = 0) generate
    
       begin

         -- Just pass stream signals through from the Store 
         -- and Forward module
     
         sig_dre2sf_wready   <= sig_skid2dre_wready ;
         
         sig_dre2skid_wvalid <= sig_sf2dre_wvalid   ;
         sig_dre2skid_wdata  <= sig_sf2dre_wdata    ;
         sig_dre2skid_wstrb  <= sig_sf2dre_wstrb    ;
         sig_dre2skid_wlast  <= sig_sf2dre_wlast    ;
     
          
       end generate GEN_NO_MM2S_DRE;
       
       




ENABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(5) = '1' generate
begin 

     ------------------------------------------------------------
     -- Instance: I_MM2S_SKID_BUF 
     --
     -- Description:
     --   Instance for the MM2S Skid Buffer which provides for
     -- registerd Master Stream outputs and supports bi-dir
     -- throttling.  
     --
     ------------------------------------------------------------
      I_MM2S_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid_buf
      generic map (
         
        C_WDATA_WIDTH  =>  MM2S_SDATA_WIDTH        
    
        )
      port map (
    
        -- System Ports
        aclk           =>  mm2s_aclk           ,  
        arst           =>  sig_stream_rst      ,  
     
        -- Shutdown control (assert for 1 clk pulse)
        skid_stop      =>  sig_data2skid_halt  ,  
     
        -- Slave Side (Stream Data Input) 
        s_valid        =>  sig_dre2skid_wvalid ,  
        s_ready        =>  sig_skid2dre_wready ,  
        s_data         =>  sig_dre2skid_wdata  ,  
        s_strb         =>  sig_dre2skid_wstrb  ,  
        s_last         =>  sig_dre2skid_wlast  ,  

        -- Master Side (Stream Data Output 
        m_valid        =>  mm2s_strm_wvalid    ,  
        m_ready        =>  mm2s_strm_wready    ,  
        m_data         =>  mm2s_strm_wdata     ,  
        m_strb         =>  mm2s_strm_wstrb     ,  
        m_last         =>  mm2s_strm_wlast        
    
        );
    
end generate ENABLE_AXIS_SKID;
  
    
DISABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(5) = '0' generate
begin 

   mm2s_strm_wvalid <= sig_dre2skid_wvalid;
   sig_skid2dre_wready <= mm2s_strm_wready;
   mm2s_strm_wdata <= sig_dre2skid_wdata;
   mm2s_strm_wstrb <= sig_dre2skid_wstrb; 
   mm2s_strm_wlast <= sig_dre2skid_wlast;
   

end generate DISABLE_AXIS_SKID; 

    
    
    
  end implementation;
