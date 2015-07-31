  -------------------------------------------------------------------------------
  -- axi_datamover_s2mm_full_wrap.vhd
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
  -- Filename:        axi_datamover_s2mm_full_wrap.vhd
  --
  -- Description:
  --    This file implements the DataMover S2MM FULL Wrapper.
  --
  --
  --
  --
  -- VHDL-Standard:   VHDL'93
  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  library IEEE;
  use IEEE.std_logic_1164.all;
  use IEEE.numeric_std.all   ;

  -- axi_datamover Library Modules
  library axi_datamover_v5_1;
  use axi_datamover_v5_1.axi_datamover_reset         ;
  use axi_datamover_v5_1.axi_datamover_cmd_status    ;
  use axi_datamover_v5_1.axi_datamover_pcc           ;
  use axi_datamover_v5_1.axi_datamover_ibttcc        ;
  use axi_datamover_v5_1.axi_datamover_indet_btt     ;
  use axi_datamover_v5_1.axi_datamover_s2mm_realign  ;
  use axi_datamover_v5_1.axi_datamover_addr_cntl     ;
  use axi_datamover_v5_1.axi_datamover_wrdata_cntl   ;
  use axi_datamover_v5_1.axi_datamover_wr_status_cntl;
  Use axi_datamover_v5_1.axi_datamover_skid2mm_buf   ;
  Use axi_datamover_v5_1.axi_datamover_skid_buf      ;
  Use axi_datamover_v5_1.axi_datamover_wr_sf         ;


  -------------------------------------------------------------------------------

  entity axi_datamover_s2mm_full_wrap is
    generic (

      C_INCLUDE_S2MM            : Integer range 0 to  2 :=  1;
         -- Specifies the type of S2MM function to include
         -- 0 = Omit S2MM functionality
         -- 1 = Full S2MM Functionality
         -- 2 = Lite S2MM functionality

      C_S2MM_AWID               : Integer range 0 to 255 :=  9;
         -- Specifies the constant value to output on
         -- the ARID output port

      C_S2MM_ID_WIDTH           : Integer range 1 to  8 :=  4;
         -- Specifies the width of the S2MM ID port

      C_S2MM_ADDR_WIDTH         : Integer range 32 to  64 :=  32;
         -- Specifies the width of the MMap Read Address Channel
         -- Address bus

      C_S2MM_MDATA_WIDTH        : Integer range 32 to 1024 :=  32;
         -- Specifies the width of the MMap Read Data Channel
         -- data bus

      C_S2MM_SDATA_WIDTH        : Integer range 8 to 1024 :=  32;
         -- Specifies the width of the S2MM Master Stream Data
         -- Channel data bus

      C_INCLUDE_S2MM_STSFIFO    : Integer range 0 to  1 :=  1;
         -- Specifies if a Status FIFO is to be implemented
         -- 0 = Omit S2MM Status FIFO
         -- 1 = Include S2MM Status FIFO

      C_S2MM_STSCMD_FIFO_DEPTH  : Integer range 1 to 16 :=  4;
         -- Specifies the depth of the S2MM Command FIFO and the
         -- optional Status FIFO
         -- Valid values are 1,4,8,16

      C_S2MM_STSCMD_IS_ASYNC    : Integer range 0 to  1 :=  0;
         -- Specifies if the Status and Command interfaces need to
         -- be asynchronous to the primary data path clocking
         -- 0 = Use same clocking as data path
         -- 1 = Use special Status/Command clock for the interfaces

      C_INCLUDE_S2MM_DRE        : Integer range 0 to  1 :=  0;
         -- Specifies if DRE is to be included in the S2MM function
         -- 0 = Omit DRE
         -- 1 = Include DRE

      C_S2MM_BURST_SIZE         : Integer range 2 to  256 :=  16;
         -- Specifies the max number of databeats to use for MMap
         -- burst transfers by the S2MM function

      C_S2MM_BTT_USED           : Integer range 8 to  23 :=  16;
        -- Specifies the number of bits used from the BTT field
        -- of the input Command Word of the S2MM Command Interface

      C_S2MM_SUPPORT_INDET_BTT  : Integer range 0 to  1 :=  0;
         -- Specifies if support for indeterminate packet lengths
         -- are to be received on the input Stream interface
         -- 0 = Omit support (User MUST transfer the exact number of
         --     bytes on the Stream interface as specified in the BTT
         --     field of the Corresponding DataMover Command)
         -- 1 = Include support for indeterminate packet lengths
         --     This causes FIFOs to be added and "Store and Forward"
         --     behavior of the S2MM function

      C_S2MM_ADDR_PIPE_DEPTH    : Integer range 1 to 30 := 3;
          -- This parameter specifies the depth of the S2MM internal 
          -- address pipeline queues in the Write Address Controller 
          -- and the Write Data Controller. Increasing this value will 
          -- allow more Write Addresses to be issued to the AXI4 Write 
          -- Address Channel before transmission of the associated  
          -- write data on the Write Data Channel.

      C_TAG_WIDTH               : Integer range 1 to 8 :=  4 ;
         -- Width of the TAG field

      C_INCLUDE_S2MM_GP_SF      : Integer range 0 to 1 := 1 ;
        -- This parameter specifies the inclusion/omission of the
        -- S2MM (Write) General Purpose Store and Forward function
        -- 0 = Omit GP Store and Forward
        -- 1 = Include GP Store and Forward
      
      C_ENABLE_CACHE_USER           : Integer range 0 to 1 := 1; 

    C_ENABLE_S2MM_TKEEP             : integer range 0 to 1 := 1; 

      C_ENABLE_SKID_BUF         : string := "11111";

      C_FAMILY                  : String := "virtex7"
         -- Specifies the target FPGA family type

      );
    port (


      -- S2MM Primary Clock and Reset inputs ----------------------------
      s2mm_aclk         : in  std_logic;                               --
         -- Primary synchronization clock for the Master side          --
         -- interface and internal logic. It is also used              --
         -- for the User interface synchronization when                --
         -- C_STSCMD_IS_ASYNC = 0.                                     --
      -------------------------------------------------------------------
      

      -- S2MM Primary Reset input ---------------------------------------
      s2mm_aresetn      : in  std_logic;                               --
         -- Reset used for the internal master logic                   --
      -------------------------------------------------------------------



      -- S2MM Halt request input control --------------------------------
      s2mm_halt               : in  std_logic;                         --
         -- Active high soft shutdown request                          --
                                                                       --
      -- S2MM Halt Complete status flag                                --
      s2mm_halt_cmplt         : Out  std_logic;                        --
         -- Active high soft shutdown complete status                  --
      -------------------------------------------------------------------



      -- S2MM Error discrete output -------------------------------------
      s2mm_err          : Out std_logic;                               --
         -- Composite Error indication                                 --
      -------------------------------------------------------------------



      -- Optional Command and Status Clock and Reset -------------------
      -- Only used when C_S2MM_STSCMD_IS_ASYNC = 1                    --
                                                                      --
      s2mm_cmdsts_awclk       : in  std_logic;                        --
      -- Secondary Clock input for async CMD/Status interface         --
                                                                      --
      s2mm_cmdsts_aresetn     : in  std_logic;                        --
        -- Secondary Reset input for async CMD/Status interface       --
      ------------------------------------------------------------------
      

      -- User Command Interface Ports (AXI Stream) -----------------------------------------------------
      s2mm_cmd_wvalid         : in  std_logic;                                                        --
      s2mm_cmd_wready         : out std_logic;                                                        --
      s2mm_cmd_wdata          : in  std_logic_vector((C_TAG_WIDTH+(8*C_ENABLE_CACHE_USER)+C_S2MM_ADDR_WIDTH+36)-1 downto 0);  --
      --------------------------------------------------------------------------------------------------

      -- User Status Interface Ports (AXI Stream) --------------------------------------------------------
      s2mm_sts_wvalid         : out std_logic;                                                          --
      s2mm_sts_wready         : in  std_logic;                                                          --
      s2mm_sts_wdata          : out std_logic_vector(((C_S2MM_SUPPORT_INDET_BTT*24)+8)-1 downto 0);     --
      s2mm_sts_wstrb          : out std_logic_vector((((C_S2MM_SUPPORT_INDET_BTT*24)+8)/8)-1 downto 0); --
      s2mm_sts_wlast          : out std_logic;                                                          --
      ----------------------------------------------------------------------------------------------------
      
      
      -- Address posting controls ---------------------------------------
      s2mm_allow_addr_req     : in  std_logic;                         --
      s2mm_addr_req_posted    : out std_logic;                         --
      s2mm_wr_xfer_cmplt      : out std_logic;                         --
      s2mm_ld_nxt_len         : out std_logic;                         --
      s2mm_wr_len             : out std_logic_vector(7 downto 0);      --
      -------------------------------------------------------------------
     
      
      -- S2MM AXI Address Channel I/O  --------------------------------------
      s2mm_awid     : out std_logic_vector(C_S2MM_ID_WIDTH-1 downto 0);    --
         -- AXI Address Channel ID output                                  --
                                                                           --
      s2mm_awaddr   : out std_logic_vector(C_S2MM_ADDR_WIDTH-1 downto 0);  --
         -- AXI Address Channel Address output                             --
                                                                           --
      s2mm_awlen    : out std_logic_vector(7 downto 0);                    --
         -- AXI Address Channel LEN output                                 --
         -- Sized to support 256 data beat bursts                          --
                                                                           --
      s2mm_awsize   : out std_logic_vector(2 downto 0);                    --
         -- AXI Address Channel SIZE output                                --
                                                                           --
      s2mm_awburst  : out std_logic_vector(1 downto 0);                    --
         -- AXI Address Channel BURST output                               --
                                                                           --
      s2mm_awprot   : out std_logic_vector(2 downto 0);                    --
         -- AXI Address Channel PROT output                                --
                                                                           --
      s2mm_awcache  : out std_logic_vector(3 downto 0);                    --
         -- AXI Address Channel PROT output                                --

      s2mm_awuser  : out std_logic_vector(3 downto 0);                    --
         -- AXI Address Channel PROT output                                --
                                                                           --
      s2mm_awvalid  : out std_logic;                                       --
         -- AXI Address Channel VALID output                               --
                                                                           --
      s2mm_awready  : in  std_logic;                                       --
         -- AXI Address Channel READY input                                --
      -----------------------------------------------------------------------
      

      -- Currently unsupported AXI Address Channel output signals -----------
        -- s2mm__awlock   : out std_logic_vector(2 downto 0);              --
        -- s2mm__awcache  : out std_logic_vector(4 downto 0);              --
        -- s2mm__awqos    : out std_logic_vector(3 downto 0);              --
        -- s2mm__awregion : out std_logic_vector(3 downto 0);              --
      -----------------------------------------------------------------------





      -- S2MM AXI MMap Write Data Channel I/O  ---------------------------------------------
      s2mm_wdata              : Out  std_logic_vector(C_S2MM_MDATA_WIDTH-1 downto 0);     --
      s2mm_wstrb              : Out  std_logic_vector((C_S2MM_MDATA_WIDTH/8)-1 downto 0); --
      s2mm_wlast              : Out  std_logic;                                           --
      s2mm_wvalid             : Out  std_logic;                                           --
      s2mm_wready             : In   std_logic;                                           --
      --------------------------------------------------------------------------------------
      

      -- S2MM AXI MMap Write response Channel I/O  ----------------------------------------- 
      s2mm_bresp              : In   std_logic_vector(1 downto 0);                        --
      s2mm_bvalid             : In   std_logic;                                           --
      s2mm_bready             : Out  std_logic;                                           --
      --------------------------------------------------------------------------------------


      -- S2MM AXI Master Stream Channel I/O  -----------------------------------------------
      s2mm_strm_wdata         : In  std_logic_vector(C_S2MM_SDATA_WIDTH-1 downto 0);      --
      s2mm_strm_wstrb         : In  std_logic_vector((C_S2MM_SDATA_WIDTH/8)-1 downto 0);  --
      s2mm_strm_wlast         : In  std_logic;                                            --
      s2mm_strm_wvalid        : In  std_logic;                                            --
      s2mm_strm_wready        : Out std_logic;                                            --
      --------------------------------------------------------------------------------------

      -- Testing Support I/O ------------------------------------------
      s2mm_dbg_sel            : in  std_logic_vector( 3 downto 0);   --
      s2mm_dbg_data           : out std_logic_vector(31 downto 0)    --
      -----------------------------------------------------------------


      );

  end entity axi_datamover_s2mm_full_wrap;


  architecture implementation of axi_datamover_s2mm_full_wrap is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";




    -- Function Declarations   ----------------------------------------

    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: func_calc_wdemux_sel_bits
    --
    -- Function Description:
    --  This function calculates the number of address bits needed for
    -- the Write Strobe demux select control.
    --
    -------------------------------------------------------------------
    function func_calc_wdemux_sel_bits (mmap_dwidth_value : integer) return integer is

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

    end function func_calc_wdemux_sel_bits;






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

      if (need_dre = 1 and
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

      else

        align_port_width := 1;

      end if;

      Return (align_port_width);

    end function func_get_align_width;





    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_set_status_width
    --
    -- Function Description:
    -- This function sets the width of the Status pipe depending on the
    -- Store and Forward inclusion or ommision.
    --
    -------------------------------------------------------------------
    function funct_set_status_width (store_forward_enabled : integer)
             return integer is


      Variable temp_status_bit_width : Integer := 8;


    begin


      If (store_forward_enabled = 1) Then

        temp_status_bit_width := 32;

      Else

        temp_status_bit_width := 8;

      End if;


      Return (temp_status_bit_width);


    end function funct_set_status_width;




    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: get_bits_needed
    --
    -- Function Description:
    --
    --
    -------------------------------------------------------------------
    function get_bits_needed (max_bytes : integer) return integer is
    
      Variable fvar_temp_bit_width : Integer := 1;
    
    begin
    
      
      if (max_bytes <= 1) then
      
         fvar_temp_bit_width := 1;
      
      elsif (max_bytes <= 3) then
      
         fvar_temp_bit_width := 2;
      
      elsif (max_bytes <= 7) then
      
         fvar_temp_bit_width := 3;
      
      elsif (max_bytes <= 15) then
      
         fvar_temp_bit_width := 4;
      
      elsif (max_bytes <= 31) then
      
         fvar_temp_bit_width := 5;
      
      elsif (max_bytes <= 63) then
      
         fvar_temp_bit_width := 6;
      
      elsif (max_bytes <= 127) then
      
         fvar_temp_bit_width := 7;
      
      elsif (max_bytes <= 255) then
      
         fvar_temp_bit_width := 8;
      
      elsif (max_bytes <= 511) then
      
         fvar_temp_bit_width := 9;
      
      elsif (max_bytes <= 1023) then
      
         fvar_temp_bit_width := 10;
      
      elsif (max_bytes <= 2047) then
      
         fvar_temp_bit_width := 11;
      
      elsif (max_bytes <= 4095) then
      
         fvar_temp_bit_width := 12;
      
      elsif (max_bytes <= 8191) then
      
         fvar_temp_bit_width := 13;
      
      else  -- 8k - 16K
      
         fvar_temp_bit_width := 14;
      
      end if;
       
       
      Return (fvar_temp_bit_width);
       
       
    end function get_bits_needed;
    

   

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
    -- Function Name: funct_need_realigner
    --
    -- Function Description:
    --  Determines if the Realigner module needs to be included.
    --
    -------------------------------------------------------------------
    function funct_need_realigner (indet_btt_enabled : integer;
                                   dre_included      : integer;
                                   gp_sf_included    : integer) return integer is
    
      Variable temp_val : Integer := 0;
    
    begin
    
      If ((indet_btt_enabled = 1) or
          (dre_included      = 1) or
          (gp_sf_included    = 1)) Then
    
         temp_val := 1;
      
      else

         temp_val := 0;
      
      End if;
      
    
      Return (temp_val);

    
    end function funct_need_realigner;
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
        when others =>
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
    --  This function calculates the Stream width to use for S2MM 
    -- modules downstream from the upsizing Store and Forward. If 
    -- Store and forward is present, then the effective Stream width 
    -- is the MMAP data width. If no Store and Forward then the Stream
    -- width is the input Stream width from the User. 
    --
    -------------------------------------------------------------------
    function funct_get_stream_width2use (mmap_data_width   : integer;
                                         stream_data_width : integer;
                                         sf_enabled        : integer) return integer is
    
      Variable fvar_temp_width : Integer := 32;
    
    begin
    
      If (sf_enabled > 0) Then
    
        fvar_temp_width := mmap_data_width;
      
      Else 

        fvar_temp_width := stream_data_width;
      
      End if;
     
      Return (fvar_temp_width);
     
    end function funct_get_stream_width2use;
    
   
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: funct_get_bytes_per_dbeat
    --
    -- Function Description:
    --  This function calculates the number of bytes transfered per
    -- databeat on the MMap AXI4 Write Data Channel by the S2MM. The
    -- value is based on input parameterization of included functions
    -- in the S2MM block.
    --
    -------------------------------------------------------------------
    function funct_get_bytes_per_dbeat (ibtt_enabled  : integer ;
                                        gpsf_enabled  : integer ;
                                        stream_dwidth : integer ;
                                        mmap_dwidth   : integer ) return integer is
    
      Variable fvar_temp_bytes_per_xfer : Integer := 4;
    
    begin
    
      If (ibtt_enabled > 0 or
          gpsf_enabled > 0) Then -- transfers will be upsized to mmap data width
    
        fvar_temp_bytes_per_xfer := mmap_dwidth/8;      
      
      Else -- transfers will be in stream data widths (may be narrow transfers on mmap)
      
        fvar_temp_bytes_per_xfer := stream_dwidth/8;      
      
      End if;
    
    
      Return (fvar_temp_bytes_per_xfer);
    
    
    end function funct_get_bytes_per_dbeat;
    
    
    
    
    -- Constant Declarations   ----------------------------------------

     
     Constant SF_ENABLED                : integer := C_INCLUDE_S2MM_GP_SF + C_S2MM_SUPPORT_INDET_BTT;
     Constant SF_UPSIZED_SDATA_WIDTH    : integer := funct_get_stream_width2use(C_S2MM_MDATA_WIDTH,
                                                                                C_S2MM_SDATA_WIDTH,
                                                                                SF_ENABLED);
     
     Constant LOGIC_LOW                 : std_logic := '0';
     Constant LOGIC_HIGH                : std_logic := '1';
     Constant IS_NOT_MM2S               : integer range  0 to    1 := 0;
     Constant S2MM_AWID_VALUE           : integer range  0 to  255 := C_S2MM_AWID;
     Constant S2MM_AWID_WIDTH           : integer range  1 to    8 := C_S2MM_ID_WIDTH;
     Constant S2MM_ADDR_WIDTH           : integer range 32 to   64 := C_S2MM_ADDR_WIDTH;
     Constant S2MM_MDATA_WIDTH          : integer range 32 to 1024 := C_S2MM_MDATA_WIDTH;
     Constant S2MM_SDATA_WIDTH          : integer range  8 to 1024 := C_S2MM_SDATA_WIDTH;
     Constant S2MM_TAG_WIDTH            : integer range  1 to    8 := C_TAG_WIDTH;
     Constant S2MM_CMD_WIDTH            : integer                  := (S2MM_TAG_WIDTH+S2MM_ADDR_WIDTH+32);
     Constant INCLUDE_S2MM_STSFIFO      : integer range  0 to    1 := C_INCLUDE_S2MM_STSFIFO;
     Constant S2MM_STSCMD_FIFO_DEPTH    : integer range  1 to   16 := C_S2MM_STSCMD_FIFO_DEPTH;
     Constant S2MM_STSCMD_IS_ASYNC      : integer range  0 to    1 := C_S2MM_STSCMD_IS_ASYNC;
     Constant S2MM_BURST_SIZE           : integer range 2 to  256 := C_S2MM_BURST_SIZE;
     Constant ADDR_CNTL_FIFO_DEPTH      : integer range  1 to   30 := C_S2MM_ADDR_PIPE_DEPTH;
     Constant WR_DATA_CNTL_FIFO_DEPTH   : integer range  1 to   30 := C_S2MM_ADDR_PIPE_DEPTH;
     
     
     Constant SEL_ADDR_WIDTH            : integer range  2 to   7 := func_calc_wdemux_sel_bits(S2MM_MDATA_WIDTH);
     Constant S2MM_BTT_USED             : integer range  8 to  23 := C_S2MM_BTT_USED;
     Constant BITS_PER_BYTE             : integer := 8;
     
     Constant INCLUDE_S2MM_DRE          : integer range  0 to   1 := func_include_dre(C_INCLUDE_S2MM_DRE,
                                                                                      S2MM_SDATA_WIDTH);
     
     Constant DRE_CNTL_FIFO_DEPTH       : integer range  1 to  30 := C_S2MM_ADDR_PIPE_DEPTH;
     
     Constant S2MM_DRE_ALIGN_WIDTH      : integer range  1 to   3 := func_get_align_width(INCLUDE_S2MM_DRE,
                                                                                          S2MM_SDATA_WIDTH);
     Constant DRE_SUPPORT_SCATTER       : integer range  0 to   1 := 1;
     
     Constant ENABLE_INDET_BTT_SF       : integer range  0 to   1 := C_S2MM_SUPPORT_INDET_BTT;
     
     Constant ENABLE_GP_SF              : integer range  0 to   1 := C_INCLUDE_S2MM_GP_SF ;
    
     Constant BYTES_PER_MMAP_DBEAT      : integer := funct_get_bytes_per_dbeat(ENABLE_INDET_BTT_SF ,
                                                                               ENABLE_GP_SF        ,
                                                                               S2MM_SDATA_WIDTH    ,
                                                                               S2MM_MDATA_WIDTH);
     
     
     Constant MAX_BYTES_PER_BURST       : integer := BYTES_PER_MMAP_DBEAT*S2MM_BURST_SIZE;
     Constant IBTT_XFER_BYTES_WIDTH     : integer := get_bits_needed(MAX_BYTES_PER_BURST);
     
     
     
     Constant WR_STATUS_CNTL_FIFO_DEPTH : integer range  1 to  32 := WR_DATA_CNTL_FIFO_DEPTH+2; -- 2 added for going 
                                                                                                -- full thresholding
                                                                                                -- in WSC
     Constant WSC_STATUS_WIDTH          : integer range  8 to 32 := 
                                          funct_set_status_width(ENABLE_INDET_BTT_SF);
     Constant WSC_BYTES_RCVD_WIDTH      : integer range  8 to 32 :=  S2MM_BTT_USED;
     
     Constant ADD_REALIGNER             : integer := funct_need_realigner(ENABLE_INDET_BTT_SF ,
                                                                          INCLUDE_S2MM_DRE    ,
                                                                          ENABLE_GP_SF);
     
     
     
     
     -- Calculates the minimum needed depth of the GP Store and Forward FIFO
     -- based on the S2MM pipeline depth and the max allowed Burst length
     Constant PIPEDEPTH_BURST_LEN_PROD : integer :=
                    (ADDR_CNTL_FIFO_DEPTH+2) * S2MM_BURST_SIZE;
              
              
     -- Assigns the depth of the optional GP Store and Forward FIFO to the nearest
     -- power of 2
     Constant SF_FIFO_DEPTH        : integer range 128 to 8192 :=
                                     funct_rnd2pwr_of_2(PIPEDEPTH_BURST_LEN_PROD);


     -- Calculate the width of the Store and Forward Starting Address Offset bus
     Constant SF_STRT_OFFSET_WIDTH : integer := funct_get_sf_offset_width(S2MM_MDATA_WIDTH,
                                                                          S2MM_SDATA_WIDTH);
     
     
     
     
     
    
    
    -- Signal Declarations  ------------------------------------------

     signal sig_cmd_stat_rst_user        : std_logic := '0';
     signal sig_cmd_stat_rst_int         : std_logic := '0';
     signal sig_mmap_rst                 : std_logic := '0';
     signal sig_stream_rst               : std_logic := '0';
     signal sig_s2mm_cmd_wdata           : std_logic_vector(S2MM_CMD_WIDTH-1 downto 0) := (others => '0');
     signal sig_s2mm_cache_data           : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_cmd2mstr_command         : std_logic_vector(S2MM_CMD_WIDTH-1 downto 0) := (others => '0');
     signal sig_cmd2mstr_cmd_valid       : std_logic := '0';
     signal sig_mst2cmd_cmd_ready        : std_logic := '0';
     signal sig_mstr2addr_addr           : std_logic_vector(S2MM_ADDR_WIDTH-1 downto 0) := (others => '0');
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
     signal sig_mstr2data_cmd_last       : std_logic := '0';
     signal sig_mstr2data_cmd_valid      : std_logic := '0';
     signal sig_data2mstr_cmd_ready      : std_logic := '0';
     signal sig_addr2data_addr_posted    : std_logic := '0';
     signal sig_data2addr_data_rdy       : std_logic := '0';
     signal sig_data2all_tlast_error     : std_logic := '0';
     signal sig_data2all_dcntlr_halted   : std_logic := '0';
     signal sig_addr2wsc_calc_error      : std_logic := '0';
     signal sig_addr2wsc_cmd_fifo_empty  : std_logic := '0';
     signal sig_data2wsc_rresp           : std_logic_vector(1 downto 0) := (others => '0');
     signal sig_data2wsc_cmd_empty       : std_logic := '0';
     signal sig_data2wsc_calc_err        : std_logic := '0';
     signal sig_data2wsc_cmd_cmplt       : std_logic := '0';
     signal sig_data2wsc_last_err        : std_logic := '0';
     signal sig_calc2dm_calc_err         : std_logic := '0';
     signal sig_wsc2stat_status          : std_logic_vector(WSC_STATUS_WIDTH-1 downto 0) := (others => '0');
     signal sig_stat2wsc_status_ready    : std_logic := '0';
     signal sig_wsc2stat_status_valid    : std_logic := '0';
     signal sig_wsc2mstr_halt_pipe       : std_logic := '0';
     signal sig_data2wsc_tag             : std_logic_vector(S2MM_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2data_tag            : std_logic_vector(S2MM_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2addr_tag            : std_logic_vector(S2MM_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2skid_addr_lsb       : std_logic_vector(SEL_ADDR_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2skid_wvalid         : std_logic := '0';
     signal sig_skid2data_wready         : std_logic := '0';
     signal sig_data2skid_wdata          : std_logic_vector(SF_UPSIZED_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_data2skid_wstrb          : std_logic_vector((SF_UPSIZED_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_data2skid_wlast          : std_logic := '0';
     signal sig_skid2axi_wvalid          : std_logic := '0';
     signal sig_axi2skid_wready          : std_logic := '0';
     signal sig_skid2axi_wdata           : std_logic_vector(S2MM_MDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_skid2axi_wstrb           : std_logic_vector((S2MM_MDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_skid2axi_wlast           : std_logic := '0';
     signal sig_data2wsc_sof             : std_logic := '0';
     signal sig_data2wsc_eof             : std_logic := '0';
     signal sig_data2wsc_valid           : std_logic := '0';
     signal sig_wsc2data_ready           : std_logic := '0';
     signal sig_data2wsc_eop             : std_logic := '0';
     signal sig_data2wsc_bytes_rcvd      : std_logic_vector(WSC_BYTES_RCVD_WIDTH-1 downto 0) := (others => '0');
     signal sig_dbg_data_mux_out         : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_0               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_dbg_data_1               : std_logic_vector(31 downto 0) := (others => '0');
     signal sig_sf2pcc_xfer_valid        : std_logic := '0';
     signal sig_pcc2sf_xfer_ready        : std_logic := '0';
     signal sig_sf2pcc_cmd_cmplt         : std_logic := '0';
     signal sig_sf2pcc_packet_eop        : std_logic := '0';
     signal sig_sf2pcc_xfer_bytes        : std_logic_vector(IBTT_XFER_BYTES_WIDTH-1 downto 0) := (others => '0');
     signal sig_ibtt2wdc_tvalid          : std_logic := '0';
     signal sig_wdc2ibtt_tready          : std_logic := '0';
     signal sig_ibtt2wdc_tdata           : std_logic_vector(SF_UPSIZED_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_ibtt2wdc_tstrb           : std_logic_vector((SF_UPSIZED_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_ibtt2wdc_tlast           : std_logic := '0';
     signal sig_ibtt2wdc_eop             : std_logic := '0';
     signal sig_ibtt2wdc_stbs_asserted   : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_dre2ibtt_tvalid          : std_logic := '0';
     signal sig_ibtt2dre_tready          : std_logic := '0';
     signal sig_dre2ibtt_tdata           : std_logic_vector(S2MM_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal sig_dre2ibtt_tstrb           : std_logic_vector((S2MM_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal sig_dre2ibtt_tlast           : std_logic := '0';
     signal sig_dre2ibtt_eop             : std_logic := '0';
     signal sig_dre2mstr_cmd_ready       : std_logic := '0';
     signal sig_mstr2dre_cmd_valid       : std_logic := '0';
     signal sig_mstr2dre_tag             : std_logic_vector(S2MM_TAG_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2dre_dre_src_align   : std_logic_vector(S2MM_DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2dre_dre_dest_align  : std_logic_vector(S2MM_DRE_ALIGN_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2dre_btt             : std_logic_vector(S2MM_BTT_USED-1 downto 0) := (others => '0');
     signal sig_mstr2dre_drr             : std_logic := '0';
     signal sig_mstr2dre_eof             : std_logic := '0';
     signal sig_mstr2dre_cmd_cmplt       : std_logic := '0';
     signal sig_mstr2dre_calc_error      : std_logic := '0';
     signal sig_realign2wdc_eop_error    : std_logic := '0';
     signal sig_dre2all_halted           : std_logic := '0';
     signal sig_rst2all_stop_request     : std_logic := '0';
     signal sig_data2rst_stop_cmplt      : std_logic := '0';
     signal sig_addr2rst_stop_cmplt      : std_logic := '0';
     signal sig_data2addr_stop_req       : std_logic := '0';
     signal sig_wsc2rst_stop_cmplt       : std_logic := '0';
     signal sig_data2skid_halt           : std_logic := '0';
     signal skid2dre_wvalid              : std_logic := '0';
     signal dre2skid_wready              : std_logic := '0';
     signal skid2dre_wdata               : std_logic_vector(S2MM_SDATA_WIDTH-1 downto 0) := (others => '0');
     signal skid2dre_wstrb               : std_logic_vector((S2MM_SDATA_WIDTH/8)-1 downto 0) := (others => '0');
     signal skid2dre_wlast               : std_logic := '0';
     signal sig_s2mm_allow_addr_req      : std_logic := '0';
     signal sig_ok_to_post_wr_addr       : std_logic := '0';
     signal sig_s2mm_addr_req_posted     : std_logic := '0';
     signal sig_s2mm_wr_xfer_cmplt       : std_logic := '0';
     signal sig_s2mm_ld_nxt_len          : std_logic := '0';
     signal sig_s2mm_wr_len              : std_logic_vector(7 downto 0) := (others => '0');
     signal sig_ibtt2wdc_error           : std_logic := '0';
     signal sig_sf_strt_addr_offset      : std_logic_vector(SF_STRT_OFFSET_WIDTH-1 downto 0) := (others => '0');
     signal sig_mstr2dre_sf_strt_offset  : std_logic_vector(SF_STRT_OFFSET_WIDTH-1 downto 0) := (others => '0');
     signal sig_cache2mstr_command       : std_logic_vector (7 downto 0);
     signal s2mm_awcache_int             : std_logic_vector (3 downto 0);
     signal s2mm_awuser_int             : std_logic_vector (3 downto 0);
    
    
  begin --(architecture implementation)



    -- Debug/Test Port Assignments

    s2mm_dbg_data        <= sig_dbg_data_mux_out;

    -- Note that only the s2mm_dbg_sel(0) is used at this time
    sig_dbg_data_mux_out <= sig_dbg_data_1
      When (s2mm_dbg_sel(0) = '1')
      else sig_dbg_data_0 ;


    sig_dbg_data_0               <=  X"CAFE1111"             ;    -- 32 bit Constant indicating S2MM FULL type

    sig_dbg_data_1(0)            <= sig_cmd_stat_rst_user    ;
    sig_dbg_data_1(1)            <= sig_cmd_stat_rst_int     ;
    sig_dbg_data_1(2)            <= sig_mmap_rst             ;
    sig_dbg_data_1(3)            <= sig_stream_rst           ;
    sig_dbg_data_1(4)            <= sig_cmd2mstr_cmd_valid   ;
    sig_dbg_data_1(5)            <= sig_mst2cmd_cmd_ready    ;
    sig_dbg_data_1(6)            <= sig_stat2wsc_status_ready;
    sig_dbg_data_1(7)            <= sig_wsc2stat_status_valid;
    sig_dbg_data_1(11 downto 8)  <= sig_data2wsc_tag         ; -- Current TAG of active data transfer


    sig_dbg_data_1(15 downto 12) <= sig_wsc2stat_status(3 downto 0); -- Internal status tag field
    sig_dbg_data_1(16)           <= sig_wsc2stat_status(4)         ; -- Internal error
    sig_dbg_data_1(17)           <= sig_wsc2stat_status(5)         ; -- Decode Error
    sig_dbg_data_1(18)           <= sig_wsc2stat_status(6)         ; -- Slave Error
    --sig_dbg_data_1(19)           <= sig_wsc2stat_status(7)         ; -- OKAY
    sig_dbg_data_1(20)           <= sig_stat2wsc_status_ready      ; -- Status Ready Handshake
    sig_dbg_data_1(21)           <= sig_wsc2stat_status_valid      ; -- Status Valid Handshake
                        
    
    sig_dbg_data_1(29 downto 22) <= sig_mstr2data_len              ; -- WDC Cmd FIFO LEN input
    sig_dbg_data_1(30)           <= sig_mstr2data_cmd_valid        ; -- WDC Cmd FIFO Valid Inpute
    sig_dbg_data_1(31)           <= sig_data2mstr_cmd_ready        ; -- WDC Cmd FIFO Ready Output
    
    


    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ADD_DEBUG_EOP
    --
    -- If Generate Description:
    --
    --   This IfGen adds in the EOP status marker to the debug
    -- vector data when Indet BTT Store and Forward is enabled.
    --
    ------------------------------------------------------------
    GEN_ADD_DEBUG_EOP : if (ENABLE_INDET_BTT_SF = 1) generate
    
       begin
  
         sig_dbg_data_1(19)  <= sig_wsc2stat_status(31) ; -- EOP Marker
  
    
       end generate GEN_ADD_DEBUG_EOP;
   
   
   
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_DEBUG_EOP
    --
    -- If Generate Description:
    --
    --   This IfGen zeros the debug vector bit used for the  EOP 
    -- status marker when Indet BTT Store and Forward is not 
    -- enabled.
    --
    ------------------------------------------------------------
    GEN_NO_DEBUG_EOP : if (ENABLE_INDET_BTT_SF = 0) generate
    
       begin
  
         sig_dbg_data_1(19)   <= '0' ; -- EOP Marker
  
    
       end generate GEN_NO_DEBUG_EOP;
   
   
   
   
    ---- End of Debug/Test Support --------------------------------
   
   
   


     -- Assign the Address posting control outputs
     s2mm_addr_req_posted     <= sig_s2mm_addr_req_posted ;
     s2mm_wr_xfer_cmplt       <= sig_s2mm_wr_xfer_cmplt   ;
     s2mm_ld_nxt_len          <= sig_s2mm_ld_nxt_len      ;
     s2mm_wr_len              <= sig_s2mm_wr_len          ;
     
     
     
   
   
   
   
   


    -- Write Data Channel I/O
     s2mm_wvalid         <= sig_skid2axi_wvalid;
     sig_axi2skid_wready <= s2mm_wready        ;
     s2mm_wdata          <= sig_skid2axi_wdata ;
     s2mm_wlast          <= sig_skid2axi_wlast ;

GEN_S2MM_TKEEP_ENABLE2 : if C_ENABLE_S2MM_TKEEP = 1 generate
begin

     s2mm_wstrb          <= sig_skid2axi_wstrb ;


end generate GEN_S2MM_TKEEP_ENABLE2;

GEN_S2MM_TKEEP_DISABLE2 : if C_ENABLE_S2MM_TKEEP = 0 generate
begin

  s2mm_wstrb        <= (others => '1');

end generate GEN_S2MM_TKEEP_DISABLE2;




    GEN_CACHE : if (C_ENABLE_CACHE_USER = 0) generate
      begin
     -- Cache signal tie-off
     s2mm_awcache <= "0011";  -- pre Interface-X guidelines for Masters
     s2mm_awuser <= "0000";  -- pre Interface-X guidelines for Masters
     sig_s2mm_cache_data <= (others => '0'); --s2mm_cmd_wdata(103 downto 96);
    end generate GEN_CACHE;

    GEN_CACHE2 : if (C_ENABLE_CACHE_USER = 1) generate
      begin
     -- Cache signal tie-off
     s2mm_awcache <= s2mm_awcache_int;  -- pre Interface-X guidelines for Masters
     s2mm_awuser <= s2mm_awuser_int;  -- pre Interface-X guidelines for Masters
     sig_s2mm_cache_data <= s2mm_cmd_wdata(79 downto 72);
  --   sig_s2mm_cache_data <= s2mm_cmd_wdata(103 downto 96);
    end generate GEN_CACHE2;

     -- Internal error output discrete
     s2mm_err            <=  sig_calc2dm_calc_err or sig_data2all_tlast_error;


     -- Rip the used portion of the Command Interface Command Data
     -- and throw away the padding
     sig_s2mm_cmd_wdata <= s2mm_cmd_wdata(S2MM_CMD_WIDTH-1 downto 0);




     ------------------------------------------------------------
     -- Instance: I_RESET
     --
     -- Description:
     --   Reset Block
     --
     ------------------------------------------------------------
      I_RESET : entity axi_datamover_v5_1.axi_datamover_reset
      generic map (

        C_STSCMD_IS_ASYNC    =>  S2MM_STSCMD_IS_ASYNC       

        )
      port map (

        primary_aclk         =>  s2mm_aclk                , 
        primary_aresetn      =>  s2mm_aresetn             , 
        secondary_awclk      =>  s2mm_cmdsts_awclk        , 
        secondary_aresetn    =>  s2mm_cmdsts_aresetn      , 
        halt_req             =>  s2mm_halt                , 
        halt_cmplt           =>  s2mm_halt_cmplt          , 
        flush_stop_request   =>  sig_rst2all_stop_request , 
        data_cntlr_stopped   =>  sig_data2rst_stop_cmplt  , 
        addr_cntlr_stopped   =>  sig_addr2rst_stop_cmplt  , 
        aux1_stopped         =>  sig_wsc2rst_stop_cmplt   , 
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

        C_ADDR_WIDTH           =>  S2MM_ADDR_WIDTH           , 
        C_INCLUDE_STSFIFO      =>  INCLUDE_S2MM_STSFIFO      , 
        C_STSCMD_FIFO_DEPTH    =>  S2MM_STSCMD_FIFO_DEPTH    , 
        C_STSCMD_IS_ASYNC      =>  S2MM_STSCMD_IS_ASYNC      , 
        C_CMD_WIDTH            =>  S2MM_CMD_WIDTH            , 
        C_STS_WIDTH            =>  WSC_STATUS_WIDTH          , 
        C_ENABLE_CACHE_USER    =>  C_ENABLE_CACHE_USER       ,
        C_FAMILY               =>  C_FAMILY

        )
      port map (

        primary_aclk           =>  s2mm_aclk                 , 
        secondary_awclk        =>  s2mm_cmdsts_awclk         , 
        user_reset             =>  sig_cmd_stat_rst_user     , 
        internal_reset         =>  sig_cmd_stat_rst_int      , 
        cmd_wvalid             =>  s2mm_cmd_wvalid           , 
        cmd_wready             =>  s2mm_cmd_wready           , 
        cmd_wdata              =>  sig_s2mm_cmd_wdata        , 
        cache_data             =>  sig_s2mm_cache_data        , 
        sts_wvalid             =>  s2mm_sts_wvalid           , 
        sts_wready             =>  s2mm_sts_wready           , 
        sts_wdata              =>  s2mm_sts_wdata            , 
        sts_wstrb              =>  s2mm_sts_wstrb            , 
        sts_wlast              =>  s2mm_sts_wlast            , 
        cmd2mstr_command       =>  sig_cmd2mstr_command      , 
        cache2mstr_command     =>  sig_cache2mstr_command      , 
        mst2cmd_cmd_valid      =>  sig_cmd2mstr_cmd_valid    , 
        cmd2mstr_cmd_ready     =>  sig_mst2cmd_cmd_ready     , 
        mstr2stat_status       =>  sig_wsc2stat_status       , 
        stat2mstr_status_ready =>  sig_stat2wsc_status_ready , 
        mst2stst_status_valid  =>  sig_wsc2stat_status_valid   

        );






     ------------------------------------------------------------
     -- Instance: I_WR_STATUS_CNTLR
     --
     -- Description:
     -- Write Status Controller Block
     --
     ------------------------------------------------------------
      I_WR_STATUS_CNTLR : entity axi_datamover_v5_1.axi_datamover_wr_status_cntl
      generic map (

        C_ENABLE_INDET_BTT     =>  ENABLE_INDET_BTT_SF         ,  
        C_SF_BYTES_RCVD_WIDTH  =>  WSC_BYTES_RCVD_WIDTH        ,  
        C_STS_FIFO_DEPTH       =>  WR_STATUS_CNTL_FIFO_DEPTH   ,
        C_STS_WIDTH            =>  WSC_STATUS_WIDTH            ,  
        C_TAG_WIDTH            =>  S2MM_TAG_WIDTH              ,  
        C_FAMILY               =>  C_FAMILY                       

        )
      port map (

        primary_aclk           =>  s2mm_aclk                   ,  
        mmap_reset             =>  sig_mmap_rst                ,  
        rst2wsc_stop_request   =>  sig_rst2all_stop_request    ,  
        wsc2rst_stop_cmplt     =>  sig_wsc2rst_stop_cmplt      ,  
        addr2wsc_addr_posted   =>  sig_addr2data_addr_posted   ,  
        s2mm_bresp             =>  s2mm_bresp                  ,  
        s2mm_bvalid            =>  s2mm_bvalid                 ,  
        s2mm_bready            =>  s2mm_bready                 ,  
        calc2wsc_calc_error    =>  sig_calc2dm_calc_err        ,  
        addr2wsc_calc_error    =>  sig_addr2wsc_calc_error     ,  
        addr2wsc_fifo_empty    =>  sig_addr2wsc_cmd_fifo_empty ,  
        data2wsc_tag           =>  sig_data2wsc_tag            ,  
        data2wsc_calc_error    =>  sig_data2wsc_calc_err       ,  
        data2wsc_last_error    =>  sig_data2wsc_last_err       ,  
        data2wsc_cmd_cmplt     =>  sig_data2wsc_cmd_cmplt      ,  
        data2wsc_valid         =>  sig_data2wsc_valid          ,  
        wsc2data_ready         =>  sig_wsc2data_ready          ,  
        data2wsc_eop           =>  sig_data2wsc_eop            ,  
        data2wsc_bytes_rcvd    =>  sig_data2wsc_bytes_rcvd     ,  
        wsc2stat_status        =>  sig_wsc2stat_status         ,  
        stat2wsc_status_ready  =>  sig_stat2wsc_status_ready   ,  
        wsc2stat_status_valid  =>  sig_wsc2stat_status_valid   ,  
        wsc2mstr_halt_pipe     =>  sig_wsc2mstr_halt_pipe         

        );





    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_PCC
    --
    -- If Generate Description:
    --   Include the normal Predictive Command Calculator function, 
    -- Store and Forward is not an included feature.
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_PCC : if (ENABLE_INDET_BTT_SF = 0) generate


       begin


         ------------------------------------------------------------
         -- Instance: I_MSTR_PCC
         --
         -- Description:
         -- Predictive Command Calculator Block
         --
         ------------------------------------------------------------
         I_MSTR_PCC : entity axi_datamover_v5_1.axi_datamover_pcc
         generic map (

           C_IS_MM2S                 =>  IS_NOT_MM2S                  ,
           C_DRE_ALIGN_WIDTH         =>  S2MM_DRE_ALIGN_WIDTH         , 
           C_SEL_ADDR_WIDTH          =>  SEL_ADDR_WIDTH               , 
           C_ADDR_WIDTH              =>  S2MM_ADDR_WIDTH              , 
           C_STREAM_DWIDTH           =>  S2MM_SDATA_WIDTH             , 
           C_MAX_BURST_LEN           =>  S2MM_BURST_SIZE              , 
           C_CMD_WIDTH               =>  S2MM_CMD_WIDTH               , 
           C_TAG_WIDTH               =>  S2MM_TAG_WIDTH               , 
           C_BTT_USED                =>  S2MM_BTT_USED                , 
           C_SUPPORT_INDET_BTT       =>  ENABLE_INDET_BTT_SF          ,
           C_NATIVE_XFER_WIDTH       =>  SF_UPSIZED_SDATA_WIDTH       ,
           C_STRT_SF_OFFSET_WIDTH    =>  SF_STRT_OFFSET_WIDTH

           )
         port map (

           -- Clock input
           primary_aclk              =>  s2mm_aclk                    , 
           mmap_reset                =>  sig_mmap_rst                 , 
           
           cmd2mstr_command          =>  sig_cmd2mstr_command         , 
           cache2mstr_command        =>  sig_cache2mstr_command         , 
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
           mstr2data_cmd_cmplt       =>  sig_mstr2data_cmd_last       , 
           mstr2data_cmd_valid       =>  sig_mstr2data_cmd_valid      , 
           data2mstr_cmd_ready       =>  sig_data2mstr_cmd_ready      , 
           mstr2data_dre_src_align   =>  open                         ,
           mstr2data_dre_dest_align  =>  open                         ,
           

           calc_error                =>  sig_calc2dm_calc_err         , 

           dre2mstr_cmd_ready        =>  sig_dre2mstr_cmd_ready       , 
           mstr2dre_cmd_valid        =>  sig_mstr2dre_cmd_valid       , 
           mstr2dre_tag              =>  sig_mstr2dre_tag             , 
           mstr2dre_dre_src_align    =>  sig_mstr2dre_dre_src_align   , 
           mstr2dre_dre_dest_align   =>  sig_mstr2dre_dre_dest_align  , 
           mstr2dre_btt              =>  sig_mstr2dre_btt             , 
           mstr2dre_drr              =>  sig_mstr2dre_drr             , 
           mstr2dre_eof              =>  sig_mstr2dre_eof             , 
           mstr2dre_cmd_cmplt        =>  sig_mstr2dre_cmd_cmplt       , 
           mstr2dre_calc_error       =>  sig_mstr2dre_calc_error      ,
           
           mstr2dre_strt_offset      =>  sig_mstr2dre_sf_strt_offset

           );


       end generate GEN_INCLUDE_PCC;



    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_IBTTCC
    --
    -- If Generate Description:
    --   Include the Indeterminate BTT Command Calculator function, 
    -- Store and Forward is enabled in the S2MM.
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_IBTTCC : if (ENABLE_INDET_BTT_SF = 1) generate


       begin


         

         ------------------------------------------------------------
         -- Instance: I_S2MM_MSTR_SFCC
         --
         -- Description:
         --   Instantiates the Store and Forward Command Calculator 
         -- Block.
         --
         ------------------------------------------------------------
         I_S2MM_MSTR_IBTTCC : entity axi_datamover_v5_1.axi_datamover_ibttcc
         generic map (

           C_SF_XFER_BYTES_WIDTH     =>  IBTT_XFER_BYTES_WIDTH        , 
           C_DRE_ALIGN_WIDTH         =>  S2MM_DRE_ALIGN_WIDTH         , 
           C_SEL_ADDR_WIDTH          =>  SEL_ADDR_WIDTH               , 
           C_ADDR_WIDTH              =>  S2MM_ADDR_WIDTH              , 
           C_STREAM_DWIDTH           =>  S2MM_SDATA_WIDTH             , 
           C_MAX_BURST_LEN           =>  S2MM_BURST_SIZE              , 
           C_CMD_WIDTH               =>  S2MM_CMD_WIDTH               , 
           C_TAG_WIDTH               =>  S2MM_TAG_WIDTH               , 
           C_BTT_USED                =>  S2MM_BTT_USED                ,
           C_NATIVE_XFER_WIDTH       =>  SF_UPSIZED_SDATA_WIDTH       ,
           C_STRT_SF_OFFSET_WIDTH    =>  SF_STRT_OFFSET_WIDTH 
           
           )
           
         port map (

           -- Clock input
           primary_aclk              =>  s2mm_aclk                    , 
           mmap_reset                =>  sig_mmap_rst                 , 
           
           cmd2mstr_command          =>  sig_cmd2mstr_command         , 
           cache2mstr_command        =>  sig_cache2mstr_command         , 
           cmd2mstr_cmd_valid        =>  sig_cmd2mstr_cmd_valid       , 
           mst2cmd_cmd_ready         =>  sig_mst2cmd_cmd_ready        , 

           sf2pcc_xfer_valid         =>  sig_sf2pcc_xfer_valid        , 
           pcc2sf_xfer_ready         =>  sig_pcc2sf_xfer_ready        , 
           sf2pcc_cmd_cmplt          =>  sig_sf2pcc_cmd_cmplt         , 
           sf2pcc_packet_eop         =>  sig_sf2pcc_packet_eop        , 
           sf2pcc_xfer_bytes         =>  sig_sf2pcc_xfer_bytes        , 
                
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
           mstr2data_cmd_cmplt       =>  sig_mstr2data_cmd_last       , 
           mstr2data_cmd_valid       =>  sig_mstr2data_cmd_valid      , 
           data2mstr_cmd_ready       =>  sig_data2mstr_cmd_ready      , 

           calc_error                =>  sig_calc2dm_calc_err         , 

           dre2mstr_cmd_ready        =>  sig_dre2mstr_cmd_ready       , 
           mstr2dre_cmd_valid        =>  sig_mstr2dre_cmd_valid       , 
           mstr2dre_tag              =>  sig_mstr2dre_tag             , 
           mstr2dre_dre_src_align    =>  sig_mstr2dre_dre_src_align   , 
           mstr2dre_dre_dest_align   =>  sig_mstr2dre_dre_dest_align  , 
           mstr2dre_btt              =>  sig_mstr2dre_btt             , 
           mstr2dre_drr              =>  sig_mstr2dre_drr             , 
           mstr2dre_eof              =>  sig_mstr2dre_eof             , 
           mstr2dre_cmd_cmplt        =>  sig_mstr2dre_cmd_cmplt       , 
           mstr2dre_calc_error       =>  sig_mstr2dre_calc_error      ,
           
           mstr2dre_strt_offset      =>  sig_mstr2dre_sf_strt_offset        

           );


       end generate GEN_INCLUDE_IBTTCC;



    
    
    
    
    
ENABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(4) = '1' generate
begin 
    
    
    ------------------------------------------------------------
    -- Instance: I_S2MM_STRM_SKID_BUF
    --
    -- Description:
    --   Instance for the S2MM Skid Buffer which provides for
    -- registerd Slave Stream inputs and supports bi-dir
    -- throttling.
    --
    ------------------------------------------------------------
    I_S2MM_STRM_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid_buf
    generic map (

      C_WDATA_WIDTH =>  S2MM_SDATA_WIDTH      

      )
    port map (

      -- System Ports
      aclk          =>  s2mm_aclk             ,  
      arst          =>  sig_mmap_rst          ,  

      -- Shutdown control (assert for 1 clk pulse)
      skid_stop     =>  sig_data2skid_halt    ,  

      -- Slave Side (Stream Data Input)
      s_valid       =>  s2mm_strm_wvalid      ,  
      s_ready       =>  s2mm_strm_wready      ,  
      s_data        =>  s2mm_strm_wdata       ,  
      s_strb        =>  s2mm_strm_wstrb       ,  
      s_last        =>  s2mm_strm_wlast       ,  

      -- Master Side (Stream Data Output
      m_valid       =>  skid2dre_wvalid       , 
      m_ready       =>  dre2skid_wready       , 
      m_data        =>  skid2dre_wdata        , 
      m_strb        =>  skid2dre_wstrb        , 
      m_last        =>  skid2dre_wlast          

      );


end generate ENABLE_AXIS_SKID;
  
    
DISABLE_AXIS_SKID : if C_ENABLE_SKID_BUF(4) = '0' generate
begin 

   skid2dre_wvalid <= s2mm_strm_wvalid;
   s2mm_strm_wready <= dre2skid_wready;
   skid2dre_wdata <= s2mm_strm_wdata;
   skid2dre_wstrb <= s2mm_strm_wstrb;
   skid2dre_wlast <= s2mm_strm_wlast;
   

end generate DISABLE_AXIS_SKID; 

    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_REALIGNER
    --
    -- If Generate Description:
    --   Omit the S2MM Realignment Engine
    --
    --
    ------------------------------------------------------------
    GEN_NO_REALIGNER : if (ADD_REALIGNER = 0) generate

       begin


         -- Set to Always ready for DRE to PCC Command Interface
         sig_dre2mstr_cmd_ready <= LOGIC_HIGH;
         
         
         
         -- Without DRE and Scatter, the end of packet is the TLAST
         --sig_dre2ibtt_eop     <= skid2dre_wlast  ;
         sig_dre2ibtt_eop     <= sig_dre2ibtt_tlast  ; -- use skid buffered version
         
         -- Cant't detect undrrun/overrun here
         sig_realign2wdc_eop_error <= '0';

       
       
ENABLE_NOREALIGNER_SKID : if C_ENABLE_SKID_BUF(3) = '1' generate
begin 
        
        
         ------------------------------------------------------------
         -- Instance: I_NO_REALIGN_SKID_BUF
         --
         -- Description:
         --   Instance for a Skid Buffer which provides for
         -- Fmax timing improvement between the Null Absorber and
         -- the Write Data controller when the Realigner is not
         -- present (no DRE and no Store and Forward case).
         --
         ------------------------------------------------------------
         I_NO_REALIGN_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid_buf
         generic map (

           C_WDATA_WIDTH =>  S2MM_SDATA_WIDTH      

           )
         port map (

           -- System Ports
           aclk          =>  s2mm_aclk            ,  
           arst          =>  sig_mmap_rst         ,  

           -- Shutdown control (assert for 1 clk pulse)
           skid_stop     =>  LOGIC_LOW            ,  

           -- Slave Side (Null Absorber Input)
           s_valid       =>  skid2dre_wvalid      ,  
           s_ready       =>  dre2skid_wready      ,  
           s_data        =>  skid2dre_wdata       ,  
           s_strb        =>  skid2dre_wstrb       ,  
           s_last        =>  skid2dre_wlast       ,  

           -- Master Side (Stream Data Output to WData Cntlr)
           m_valid       =>  sig_dre2ibtt_tvalid  , 
           m_ready       =>  sig_ibtt2dre_tready  , 
           m_data        =>  sig_dre2ibtt_tdata   , 
           m_strb        =>  sig_dre2ibtt_tstrb   , 
           m_last        =>  sig_dre2ibtt_tlast     

           );

end generate ENABLE_NOREALIGNER_SKID;
  
    
DISABLE_NOREALIGNER_SKID : if C_ENABLE_SKID_BUF(3) = '0' generate
begin 

   sig_dre2ibtt_tvalid <= skid2dre_wvalid;
   dre2skid_wready <= sig_ibtt2dre_tready;
   sig_dre2ibtt_tdata <= skid2dre_wdata;
   sig_dre2ibtt_tstrb <= skid2dre_wstrb;
   sig_dre2ibtt_tlast <= skid2dre_wlast;
   

end generate DISABLE_NOREALIGNER_SKID; 


        
       end generate GEN_NO_REALIGNER;



    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_REALIGNER
    --
    -- If Generate Description:
    --   Include the S2MM realigner Module. It hosts the S2MM DRE
    -- and the Scatter Block.
    --
    -- Note that the General Purpose Store and Forward Module
    -- needs the Scatter function to detect input overrun and
    -- underrun events on the AXI Stream input. Thus the Realigner
    -- is included whenever the GP Store and Forward is enabled.
    --
    ------------------------------------------------------------
    GEN_INCLUDE_REALIGNER : if (ADD_REALIGNER = 1) generate

      begin



       ------------------------------------------------------------
       -- Instance: I_S2MM_REALIGNER
       --
       -- Description:
       --  Instance for the S2MM Data Realignment Module.
       --
       ------------------------------------------------------------
        I_S2MM_REALIGNER : entity axi_datamover_v5_1.axi_datamover_s2mm_realign
        generic map (

          C_ENABLE_INDET_BTT      =>  ENABLE_INDET_BTT_SF         ,  
          C_INCLUDE_DRE           =>  INCLUDE_S2MM_DRE            ,  
          C_DRE_CNTL_FIFO_DEPTH   =>  DRE_CNTL_FIFO_DEPTH         ,  
          C_DRE_ALIGN_WIDTH       =>  S2MM_DRE_ALIGN_WIDTH        ,  
          C_SUPPORT_SCATTER       =>  DRE_SUPPORT_SCATTER         ,  
          C_BTT_USED              =>  S2MM_BTT_USED               ,  
          C_STREAM_DWIDTH         =>  S2MM_SDATA_WIDTH            , 
          C_ENABLE_S2MM_TKEEP       =>  C_ENABLE_S2MM_TKEEP        ,
          C_TAG_WIDTH             =>  S2MM_TAG_WIDTH              ,  
          C_STRT_SF_OFFSET_WIDTH  =>  SF_STRT_OFFSET_WIDTH        ,
          C_FAMILY                =>  C_FAMILY                       

          )
        port map (

         -- Clock and Reset
          primary_aclk            =>  s2mm_aclk                   ,  
          mmap_reset              =>  sig_mmap_rst                ,  

         -- Write Data Controller or Store and Forward I/O  -------
          wdc2dre_wready          =>  sig_ibtt2dre_tready         ,  
          dre2wdc_wvalid          =>  sig_dre2ibtt_tvalid         ,  
          dre2wdc_wdata           =>  sig_dre2ibtt_tdata          ,  
          dre2wdc_wstrb           =>  sig_dre2ibtt_tstrb          ,  
          dre2wdc_wlast           =>  sig_dre2ibtt_tlast          ,  
          dre2wdc_eop             =>  sig_dre2ibtt_eop            ,  
          
         
         -- Starting offset output  -------------------------------
          dre2sf_strt_offset      => sig_sf_strt_addr_offset      ,                                                    
                                                                    
                                                                    
         -- AXI Slave Stream In -----------------------------------
          s2mm_strm_wready        =>  dre2skid_wready             ,  
          s2mm_strm_wvalid        =>  skid2dre_wvalid             ,  
          s2mm_strm_wdata         =>  skid2dre_wdata              ,  
          s2mm_strm_wstrb         =>  skid2dre_wstrb              ,  
          s2mm_strm_wlast         =>  skid2dre_wlast              ,  

          -- Command Calculator Interface --------------------------
          dre2mstr_cmd_ready      =>  sig_dre2mstr_cmd_ready      ,  
          mstr2dre_cmd_valid      =>  sig_mstr2dre_cmd_valid      ,  
          mstr2dre_tag            =>  sig_mstr2dre_tag            ,  
          mstr2dre_dre_src_align  =>  sig_mstr2dre_dre_src_align  ,  
          mstr2dre_dre_dest_align =>  sig_mstr2dre_dre_dest_align ,  
          mstr2dre_btt            =>  sig_mstr2dre_btt            ,  
          mstr2dre_drr            =>  sig_mstr2dre_drr            ,  
          mstr2dre_eof            =>  sig_mstr2dre_eof            ,  
          mstr2dre_cmd_cmplt      =>  sig_mstr2dre_cmd_cmplt      ,  
          mstr2dre_calc_error     =>  sig_mstr2dre_calc_error     ,
          mstr2dre_strt_offset    =>  sig_mstr2dre_sf_strt_offset ,
          
            

          -- Premature TLAST assertion error flag
          dre2all_tlast_error     =>  sig_realign2wdc_eop_error   ,  

          -- DRE Halted Status
          dre2all_halted          =>  sig_dre2all_halted             


          );


      end generate GEN_INCLUDE_REALIGNER;



    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ENABLE_INDET_BTT_SF
    --
    -- If Generate Description:
    --   Include the Indeterminate BTT Logic with specialized 
    -- Store and Forward function, This also requires the 
    -- Scatter Engine in the Realigner module.
    --
    --
    ------------------------------------------------------------
    GEN_ENABLE_INDET_BTT_SF : if (ENABLE_INDET_BTT_SF = 1) generate


      begin


        -- Pass the Realigner EOP error through
        sig_ibtt2wdc_error   <=  sig_realign2wdc_eop_error;
        
        -- Use only external address posting enable      
        sig_s2mm_allow_addr_req <= s2mm_allow_addr_req ; 
        
        

        ------------------------------------------------------------
        -- Instance: I_INDET_BTT
        --
        -- Description:
        --  Instance for the Indeterminate BTT with Store and Forward
        -- module.
        --
        ------------------------------------------------------------
        I_INDET_BTT : entity axi_datamover_v5_1.axi_datamover_indet_btt
        generic map (

          C_SF_FIFO_DEPTH         =>  SF_FIFO_DEPTH             , 
          C_IBTT_XFER_BYTES_WIDTH =>  IBTT_XFER_BYTES_WIDTH     , 
          C_STRT_OFFSET_WIDTH     =>  SF_STRT_OFFSET_WIDTH      ,
          C_MAX_BURST_LEN         =>  S2MM_BURST_SIZE           , 
          C_MMAP_DWIDTH           =>  S2MM_MDATA_WIDTH          ,
          C_STREAM_DWIDTH         =>  S2MM_SDATA_WIDTH          , 
          C_ENABLE_SKID_BUF       =>  C_ENABLE_SKID_BUF         ,
          C_ENABLE_S2MM_TKEEP       =>  C_ENABLE_S2MM_TKEEP        ,
          C_ENABLE_DRE            =>  INCLUDE_S2MM_DRE          ,
          C_FAMILY                =>  C_FAMILY       
          )
        port map (

          primary_aclk              =>  s2mm_aclk                 , 
          mmap_reset                =>  sig_mmap_rst              , 

          ibtt2wdc_stbs_asserted    =>  sig_ibtt2wdc_stbs_asserted, 
          ibtt2wdc_eop              =>  sig_ibtt2wdc_eop          , 
          ibtt2wdc_tdata            =>  sig_ibtt2wdc_tdata        , 
          ibtt2wdc_tstrb            =>  sig_ibtt2wdc_tstrb        , 
          ibtt2wdc_tlast            =>  sig_ibtt2wdc_tlast        , 
          ibtt2wdc_tvalid           =>  sig_ibtt2wdc_tvalid       , 
          wdc2ibtt_tready           =>  sig_wdc2ibtt_tready       , 

          dre2ibtt_tvalid           =>  sig_dre2ibtt_tvalid       , 
          ibtt2dre_tready           =>  sig_ibtt2dre_tready       , 
          dre2ibtt_tdata            =>  sig_dre2ibtt_tdata        , 
          dre2ibtt_tstrb            =>  sig_dre2ibtt_tstrb        , 
          dre2ibtt_tlast            =>  sig_dre2ibtt_tlast        , 
          dre2ibtt_eop              =>  sig_dre2ibtt_eop          , 
        
          dre2ibtt_strt_addr_offset => sig_sf_strt_addr_offset    ,
          
          sf2pcc_xfer_valid         =>  sig_sf2pcc_xfer_valid     , 
          pcc2sf_xfer_ready         =>  sig_pcc2sf_xfer_ready     , 
          sf2pcc_cmd_cmplt          =>  sig_sf2pcc_cmd_cmplt      , 
          sf2pcc_packet_eop         =>  sig_sf2pcc_packet_eop     , 
          sf2pcc_xfer_bytes         =>  sig_sf2pcc_xfer_bytes       

          );


      end generate GEN_ENABLE_INDET_BTT_SF;



    
    
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_NO_SF
    --
    -- If Generate Description:
    --   Bypasses any store and Forward functions.
    --
    --
    ------------------------------------------------------------
    GEN_NO_SF : if (ENABLE_INDET_BTT_SF = 0 and
                    ENABLE_GP_SF        = 0) generate

       begin

         -- Use only external address posting enable     
         sig_s2mm_allow_addr_req    <= s2mm_allow_addr_req ;
         
         -- Housekeep unused signal in this case
         sig_ok_to_post_wr_addr     <= '0'                 ; 

         -- SFCC Interface Signals that are not used
         sig_pcc2sf_xfer_ready      <= '0'                 ;
         sig_sf2pcc_xfer_valid      <= '0'                 ;
         sig_sf2pcc_cmd_cmplt       <= '0'                 ;
         sig_sf2pcc_packet_eop      <= '0'                 ;
         sig_sf2pcc_xfer_bytes      <= (others => '0')     ;

         -- Just pass DRE signals through
         sig_ibtt2dre_tready        <= sig_wdc2ibtt_tready ;
         sig_ibtt2wdc_tvalid        <= sig_dre2ibtt_tvalid ;
         sig_ibtt2wdc_tdata         <= sig_dre2ibtt_tdata  ;
         sig_ibtt2wdc_tstrb         <= sig_dre2ibtt_tstrb  ;
         sig_ibtt2wdc_tlast         <= sig_dre2ibtt_tlast  ;
         sig_ibtt2wdc_eop           <= sig_dre2ibtt_eop    ;
         sig_ibtt2wdc_stbs_asserted <= (others => '0')     ;
        
         -- Pass the Realigner EOP error through
         sig_ibtt2wdc_error         <=  sig_realign2wdc_eop_error;
        
                                                  
                                                  
       end generate GEN_NO_SF;



 
 
 
 
 
 
 
 
 
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_GP_SF
    --
    -- If Generate Description:
    --   Include the General Purpose Store and Forward module.
    -- This If Generate can only be enabled when
    -- Indeterminate BTT mode is not enabled. The General Purpose
    -- Store and Forward is instantiated in place of the Indet
    -- BTT Store and Forward.
    -- 
    ------------------------------------------------------------
    GEN_INCLUDE_GP_SF : if (ENABLE_INDET_BTT_SF = 0 and
                            ENABLE_GP_SF        = 1) generate

       begin

         
         -- Merge the external address posting control with the
         -- SF address posting control.
         sig_s2mm_allow_addr_req <= s2mm_allow_addr_req and
                                    sig_ok_to_post_wr_addr    ; 
         
         -- Zero these out since Indet BTT is not enabled, they
         -- are only used by the WDC in that mode
         sig_ibtt2wdc_stbs_asserted <= (others => '0')        ;
         sig_ibtt2wdc_eop           <= '0'                    ;
        
         -- SFCC Interface Signals that are not used
         sig_pcc2sf_xfer_ready      <=  '0'                   ;
         sig_sf2pcc_xfer_valid      <=  '0'                   ;
         sig_sf2pcc_cmd_cmplt       <=  '0'                   ;
         sig_sf2pcc_packet_eop      <=  '0'                   ;
         sig_sf2pcc_xfer_bytes      <=  (others => '0')       ;

         
             
         ------------------------------------------------------------
         -- Instance: I_S2MM_GP_SF 
         --
         -- Description:
         --   Instance for the S2MM (Write) General Purpose Store and
         -- Forward Module. This module can only be enabled when
         -- Indeterminate BTT mode is not enabled. It is connected
         -- in place of the IBTT Module when GP SF is enabled. 
         --
         ------------------------------------------------------------
         I_S2MM_GP_SF : entity axi_datamover_v5_1.axi_datamover_wr_sf
         generic map (
       
           C_WR_ADDR_PIPE_DEPTH    => ADDR_CNTL_FIFO_DEPTH ,
           C_SF_FIFO_DEPTH         => SF_FIFO_DEPTH        ,
           C_MMAP_DWIDTH           => S2MM_MDATA_WIDTH     ,
           C_STREAM_DWIDTH         => S2MM_SDATA_WIDTH     ,
           C_STRT_OFFSET_WIDTH     => SF_STRT_OFFSET_WIDTH ,
           C_FAMILY                => C_FAMILY              
            
            )
          port map (
        
            -- Clock and Reset inputs -----------------------------
            aclk                   => s2mm_aclk                 ,  
            reset                  => sig_mmap_rst              ,  
          
            -- Slave Stream Input  --------------------------------
            sf2sin_tready          => sig_ibtt2dre_tready       ,   
            sin2sf_tvalid          => sig_dre2ibtt_tvalid       ,   
            sin2sf_tdata           => sig_dre2ibtt_tdata        ,      
            sin2sf_tkeep           => sig_dre2ibtt_tstrb        ,         
            sin2sf_tlast           => sig_dre2ibtt_tlast        ,   
            sin2sf_error           => sig_realign2wdc_eop_error ,  
            
            
            -- Starting Address Offset Input  ---------------------
            sin2sf_strt_addr_offset => sig_sf_strt_addr_offset  ,  
                  
            
            
            -- DataMover Write Side Address Pipelining Control Interface -------- 
            ok_to_post_wr_addr     => sig_ok_to_post_wr_addr    ,    
            wr_addr_posted         => sig_s2mm_addr_req_posted  ,    
            wr_xfer_cmplt          => sig_s2mm_wr_xfer_cmplt    ,    
            wr_ld_nxt_len          => sig_s2mm_ld_nxt_len       ,    
            wr_len                 => sig_s2mm_wr_len           ,    
               
            
            -- Write Side Stream Out to DataMover S2MM -------------
            sout2sf_tready         => sig_wdc2ibtt_tready       ,    
            sf2sout_tvalid         => sig_ibtt2wdc_tvalid       ,    
            sf2sout_tdata          => sig_ibtt2wdc_tdata        ,    
            sf2sout_tkeep          => sig_ibtt2wdc_tstrb        ,    
            sf2sout_tlast          => sig_ibtt2wdc_tlast        ,    
            sf2sout_error          => sig_ibtt2wdc_error
              
            );
        
                                                  
       end generate GEN_INCLUDE_GP_SF;


 
 
 
 
 
 
 
 
 
 
 
 
    
    
    
     ------------------------------------------------------------
     -- Instance: I_ADDR_CNTL
     --
     -- Description:
     --   Address Controller Block
     --
     ------------------------------------------------------------
      I_ADDR_CNTL : entity axi_datamover_v5_1.axi_datamover_addr_cntl
      generic map (

        C_ADDR_FIFO_DEPTH        =>  ADDR_CNTL_FIFO_DEPTH        , 
        C_ADDR_WIDTH             =>  S2MM_ADDR_WIDTH             , 
        C_ADDR_ID                =>  S2MM_AWID_VALUE             , 
        C_ADDR_ID_WIDTH          =>  S2MM_AWID_WIDTH             , 
        C_TAG_WIDTH              =>  S2MM_TAG_WIDTH              ,
        C_FAMILY               =>  C_FAMILY  

        )
      port map (

        primary_aclk             =>  s2mm_aclk                   , 
        mmap_reset               =>  sig_mmap_rst                , 
        
        addr2axi_aid             =>  s2mm_awid                   , 
        addr2axi_aaddr           =>  s2mm_awaddr                 , 
        addr2axi_alen            =>  s2mm_awlen                  , 
        addr2axi_asize           =>  s2mm_awsize                 , 
        addr2axi_aburst          =>  s2mm_awburst                , 
        addr2axi_aprot           =>  s2mm_awprot                 , 
        addr2axi_avalid          =>  s2mm_awvalid                , 
        addr2axi_acache           =>  s2mm_awcache_int            ,
        addr2axi_auser            =>  s2mm_awuser_int             ,

        axi2addr_aready          =>  s2mm_awready                , 
        
        mstr2addr_tag            =>  sig_mstr2addr_tag           , 
        mstr2addr_addr           =>  sig_mstr2addr_addr          , 
      --  mstr2addr_cache_info     =>  sig_cache2mstr_command      ,
        mstr2addr_len            =>  sig_mstr2addr_len           , 
        mstr2addr_size           =>  sig_mstr2addr_size          , 
        mstr2addr_burst          =>  sig_mstr2addr_burst         , 
        mstr2addr_cache          =>  sig_mstr2addr_cache         , 
        mstr2addr_user           =>  sig_mstr2addr_user          , 
        mstr2addr_cmd_cmplt      =>  sig_mstr2addr_cmd_cmplt     , 
        mstr2addr_calc_error     =>  sig_mstr2addr_calc_error    , 
        mstr2addr_cmd_valid      =>  sig_mstr2addr_cmd_valid     , 
        addr2mstr_cmd_ready      =>  sig_addr2mstr_cmd_ready     , 
        
        addr2rst_stop_cmplt      =>  sig_addr2rst_stop_cmplt     , 
 
        allow_addr_req           =>  sig_s2mm_allow_addr_req     ,
        addr_req_posted          =>  sig_s2mm_addr_req_posted    ,
        
        addr2data_addr_posted    =>  sig_addr2data_addr_posted   , 
        data2addr_data_rdy       =>  sig_data2addr_data_rdy      , 
        data2addr_stop_req       =>  sig_data2addr_stop_req      , 
        
        addr2stat_calc_error     =>  sig_addr2wsc_calc_error     , 
        addr2stat_cmd_fifo_empty =>  sig_addr2wsc_cmd_fifo_empty   
        );



    
    
    
    
    
    
    
      ------------------------------------------------------------
      -- Instance: I_WR_DATA_CNTL
      --
      -- Description:
      --     Write Data Controller Block
      --
      ------------------------------------------------------------
       I_WR_DATA_CNTL : entity axi_datamover_v5_1.axi_datamover_wrdata_cntl
       generic map (

         C_REALIGNER_INCLUDED   =>  ADD_REALIGNER             , 
         C_ENABLE_INDET_BTT     =>  ENABLE_INDET_BTT_SF       , 
         C_SF_BYTES_RCVD_WIDTH  =>  WSC_BYTES_RCVD_WIDTH      , 
         C_SEL_ADDR_WIDTH       =>  SEL_ADDR_WIDTH            , 
         C_DATA_CNTL_FIFO_DEPTH =>  WR_DATA_CNTL_FIFO_DEPTH   , 
         C_MMAP_DWIDTH          =>  S2MM_MDATA_WIDTH          , 
         C_STREAM_DWIDTH        =>  SF_UPSIZED_SDATA_WIDTH    , 
         C_TAG_WIDTH            =>  S2MM_TAG_WIDTH            , 
         C_FAMILY               =>  C_FAMILY                    

         )
       port map (

         primary_aclk           =>  s2mm_aclk                 , 
         mmap_reset             =>  sig_mmap_rst              , 
         rst2data_stop_request  =>  sig_rst2all_stop_request  , 
         data2addr_stop_req     =>  sig_data2addr_stop_req    , 
         data2rst_stop_cmplt    =>  sig_data2rst_stop_cmplt   , 
         wr_xfer_cmplt          =>  sig_s2mm_wr_xfer_cmplt    ,
         s2mm_ld_nxt_len        =>  sig_s2mm_ld_nxt_len       ,
         s2mm_wr_len            =>  sig_s2mm_wr_len           ,
         data2skid_saddr_lsb    =>  sig_data2skid_addr_lsb    , 
         data2skid_wdata        =>  sig_data2skid_wdata       , 
         data2skid_wstrb        =>  sig_data2skid_wstrb       , 
         data2skid_wlast        =>  sig_data2skid_wlast       , 
         data2skid_wvalid       =>  sig_data2skid_wvalid      , 
         skid2data_wready       =>  sig_skid2data_wready      , 
         s2mm_strm_wvalid       =>  sig_ibtt2wdc_tvalid       , 
         s2mm_strm_wready       =>  sig_wdc2ibtt_tready       , 
         s2mm_strm_wdata        =>  sig_ibtt2wdc_tdata        , 
         s2mm_strm_wstrb        =>  sig_ibtt2wdc_tstrb        , 
         s2mm_strm_wlast        =>  sig_ibtt2wdc_tlast        , 
         s2mm_strm_eop          =>  sig_ibtt2wdc_eop          , 
         s2mm_stbs_asserted     =>  sig_ibtt2wdc_stbs_asserted, 
         realign2wdc_eop_error  =>  sig_ibtt2wdc_error        , 
         mstr2data_tag          =>  sig_mstr2data_tag         , 
         mstr2data_saddr_lsb    =>  sig_mstr2data_saddr_lsb   , 
         mstr2data_len          =>  sig_mstr2data_len         , 
         mstr2data_strt_strb    =>  sig_mstr2data_strt_strb   , 
         mstr2data_last_strb    =>  sig_mstr2data_last_strb   , 
         mstr2data_drr          =>  sig_mstr2data_drr         , 
         mstr2data_eof          =>  sig_mstr2data_eof         , 
         mstr2data_sequential   =>  sig_mstr2data_sequential  , 
         mstr2data_calc_error   =>  sig_mstr2data_calc_error  , 
         mstr2data_cmd_cmplt    =>  sig_mstr2data_cmd_last    , 
         mstr2data_cmd_valid    =>  sig_mstr2data_cmd_valid   , 
         data2mstr_cmd_ready    =>  sig_data2mstr_cmd_ready   , 
         addr2data_addr_posted  =>  sig_addr2data_addr_posted , 
         data2addr_data_rdy     =>  sig_data2addr_data_rdy    , 
         data2all_tlast_error   =>  sig_data2all_tlast_error  , 
         data2all_dcntlr_halted =>  sig_data2all_dcntlr_halted, 
         data2skid_halt         =>  sig_data2skid_halt        , 
         data2wsc_tag           =>  sig_data2wsc_tag          , 
         data2wsc_calc_err      =>  sig_data2wsc_calc_err     , 
         data2wsc_last_err      =>  sig_data2wsc_last_err     , 
         data2wsc_cmd_cmplt     =>  sig_data2wsc_cmd_cmplt    , 
         wsc2data_ready         =>  sig_wsc2data_ready        , 
         data2wsc_valid         =>  sig_data2wsc_valid        , 
         data2wsc_eop           =>  sig_data2wsc_eop          , 
         data2wsc_bytes_rcvd    =>  sig_data2wsc_bytes_rcvd   , 
         wsc2mstr_halt_pipe     =>  sig_wsc2mstr_halt_pipe      

         );



    
    
    
    
--ENABLE_AXIMMAP_SKID : if C_ENABLE_SKID_BUF(4) = '1' generate
--begin 
    
    
    
      ------------------------------------------------------------
      -- Instance: I_S2MM_MMAP_SKID_BUF
      --
      -- Description:
      --   Instance for the S2MM Skid Buffer which provides for
      -- registered outputs and supports bi-dir throttling.
      --
      -- This Module also provides Write Data Bus Mirroring and WSTRB
      -- Demuxing to match a narrow Stream to a wider MMap Write
      -- Channel. By doing this in the skid buffer, the resource
      -- utilization of the skid buffer can be minimized by only
      -- having to buffer/mux the Stream data width, not the MMap
      -- Data width.
      --
      ------------------------------------------------------------
       I_S2MM_MMAP_SKID_BUF : entity axi_datamover_v5_1.axi_datamover_skid2mm_buf
       generic map (

         C_MDATA_WIDTH    =>  S2MM_MDATA_WIDTH       , 
         C_SDATA_WIDTH    =>  SF_UPSIZED_SDATA_WIDTH , 
         C_ADDR_LSB_WIDTH =>  SEL_ADDR_WIDTH           

         )
       port map (

         -- System Ports
         ACLK             =>   s2mm_aclk             , 
         ARST             =>   sig_stream_rst        , 

         -- Slave Side (Wr Data Controller Input Side )
         S_ADDR_LSB       =>   sig_data2skid_addr_lsb, 
         S_VALID          =>   sig_data2skid_wvalid  , 
         S_READY          =>   sig_skid2data_wready  , 
         S_Data           =>   sig_data2skid_wdata   , 
         S_STRB           =>   sig_data2skid_wstrb   , 
         S_Last           =>   sig_data2skid_wlast   , 

         -- Master Side (MMap Write Data Output Side)
         M_VALID          =>   sig_skid2axi_wvalid   , 
         M_READY          =>   sig_axi2skid_wready   , 
         M_Data           =>   sig_skid2axi_wdata    , 
         M_STRB           =>   sig_skid2axi_wstrb    , 
         M_Last           =>   sig_skid2axi_wlast      

         );

--end generate ENABLE_AXIMMAP_SKID;



  end implementation;
