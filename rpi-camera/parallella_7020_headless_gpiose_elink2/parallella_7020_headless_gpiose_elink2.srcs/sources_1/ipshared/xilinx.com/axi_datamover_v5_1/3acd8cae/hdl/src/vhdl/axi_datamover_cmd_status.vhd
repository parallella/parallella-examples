  -------------------------------------------------------------------------------
  -- axi_datamover_cmd_status.vhd
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
  -- Filename:        axi_datamover_cmd_status.vhd
  --
  -- Description:     
  --    This file implements the DataMover Command and Status interfaces.                 
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
  Use axi_datamover_v5_1.axi_datamover_fifo;
  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_cmd_status is
    generic (
      
      C_ADDR_WIDTH         : Integer range 32 to 64 := 32;
        -- Indictes the width of the DataMover Address bus
       
      C_INCLUDE_STSFIFO    : Integer range  0 to  1 :=  1;
        -- Indicates if a Stus FIFO is to be included or omitted
        -- 0 = Omit
        -- 1 = Include
       
      C_STSCMD_FIFO_DEPTH  : Integer range  1 to 16 :=  4;
        -- Sets the depth of the Command and Status FIFOs
       
      C_STSCMD_IS_ASYNC    : Integer range  0 to  1 :=  0;
        -- Indicates if the Command and Status Stream Channels are clocked with
        -- a different clock than the Main dataMover Clock
        -- 0 = Same Clock
        -- 1 = Different clocks
       
      C_CMD_WIDTH          : Integer                := 68;
        -- Sets the width of the input command
       
      C_STS_WIDTH          : Integer                :=  8;
        -- Sets the width of the output status

      C_ENABLE_CACHE_USER  : Integer range 0 to 1   :=  0;
       
      C_FAMILY             : string                 := "virtex7"
        -- Sets the target FPGA family
      
      );
    port (
      
      -- Clock inputs ----------------------------------------------------
      primary_aclk           : in  std_logic;                           --
         -- Primary synchronization clock for the Master side           --
         -- interface and internal logic. It is also used               --
         -- for the User interface synchronization when                 --
         -- C_STSCMD_IS_ASYNC = 0.                                      --
                                                                        --
      secondary_awclk        : in  std_logic;                           --
         -- Clock used for the Command and Status User Interface        --
         --  when the User Command and Status interface is Async        --
         -- to the MMap interface. Async mode is set by the assigned    --
         -- value to C_STSCMD_IS_ASYNC = 1.                             --
      --------------------------------------------------------------------
     
     
      -- Reset inputs ----------------------------------------------------
      user_reset             : in  std_logic;                           --
        -- Reset used for the User Stream interface logic               --
                                                                        --
      internal_reset         : in  std_logic;                           --
        -- Reset used for the internal master interface logic           --
      --------------------------------------------------------------------
      
      
      -- User Command Stream Ports (AXI Stream) -------------------------------
      cmd_wvalid             : in  std_logic;                                --
      cmd_wready             : out std_logic;                                --
      cmd_wdata              : in  std_logic_vector(C_CMD_WIDTH-1 downto 0); --
      cache_data             : in  std_logic_vector(7 downto 0); --
      -------------------------------------------------------------------------
      
      -- User Status Stream Ports (AXI Stream) ------------------------------------
      sts_wvalid             : out std_logic;                                    --
      sts_wready             : in  std_logic;                                    --
      sts_wdata              : out std_logic_vector(C_STS_WIDTH-1 downto 0);     --
      sts_wstrb              : out std_logic_vector((C_STS_WIDTH/8)-1 downto 0); --
      sts_wlast              : out std_logic;                                    --
      -----------------------------------------------------------------------------
      
      
      -- Internal Command Out Interface -----------------------------------------------
      cmd2mstr_command       : Out std_logic_vector(C_CMD_WIDTH-1 downto 0);         --
         -- The next command value available from the Command FIFO/Register          --

      cache2mstr_command       : Out std_logic_vector(7 downto 0);         --
         -- The cache value available from the FIFO/Register          --

                                                                                     --
      mst2cmd_cmd_valid      : Out std_logic;                                        --
         -- Handshake bit indicating the Command FIFO/Register has at least 1 valid  --
         -- command entry                                                            --
                                                                                     --
      cmd2mstr_cmd_ready     : in  std_logic;                                        --
         -- Handshake bit indicating the Command Calculator is ready to accept       --
         -- another command                                                          --
      ---------------------------------------------------------------------------------
      
      
      -- Internal Status In Interface  -----------------------------------------------------
      mstr2stat_status       : in  std_logic_vector(C_STS_WIDTH-1 downto 0);              --
         -- The input for writing the status value to the Status FIFO/Register            --
                                                                                          --
      stat2mstr_status_ready : Out std_logic;                                             --
         -- Handshake bit indicating that the Status FIFO/Register is ready for transfer  --
                                                                                          --
      mst2stst_status_valid  : In  std_logic                                              --
         -- Handshake bit for writing the Status value into the Status FIFO/Register      --
      --------------------------------------------------------------------------------------
     
      );
  
  end entity axi_datamover_cmd_status;
  
  
  architecture implementation of axi_datamover_cmd_status is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

  
    
    -- Function
    
    -------------------------------------------------------------------
    -- Function
    --
    -- Function Name: get_fifo_prim_type
    --
    -- Function Description:
    --  Returns the fifo primitiver type to use for the given input
    -- conditions.
    --
    --  0 = Not used or allowed here
    --  1 = BRAM Primitives (Block Memory)
    --  2 = Distributed memory
    --
    -------------------------------------------------------------------
    function get_fifo_prim_type (is_async : integer;
                                 depth    : integer) return integer is
    
      Variable var_temp_prim_type : Integer := 1;
    
    begin
    
      if (is_async = 1) then   -- Async FIFOs always use Blk Mem (BRAM)
      
        var_temp_prim_type := 1;
      
      elsif (depth <= 64) then -- (use srls or distrubuted)
      
        var_temp_prim_type := 2; 
      
      else  -- depth is too big for SRLs so use Blk Memory (BRAM)
      
        var_temp_prim_type := 1;
      
      end if;
      
     Return (var_temp_prim_type);
      
    end function get_fifo_prim_type;
    
   
   
    
    
    -- Constants 
    
    Constant REGISTER_TYPE  : integer := 0; 
    Constant BRAM_TYPE      : integer := 1; 
    --Constant SRL_TYPE       : integer := 2; 
    --Constant FIFO_PRIM_TYPE : integer := SRL_TYPE;
    Constant FIFO_PRIM_TYPE : integer := get_fifo_prim_type(C_STSCMD_IS_ASYNC, 
                                                            C_STSCMD_FIFO_DEPTH);
    
    
    -- Signals
    
    signal sig_cmd_fifo_wr_clk  : std_logic := '0';
    signal sig_cmd_fifo_wr_rst  : std_logic := '0';
    signal sig_cmd_fifo_rd_clk  : std_logic := '0';
    signal sig_cmd_fifo_rd_rst  : std_logic := '0';
    signal sig_sts_fifo_wr_clk  : std_logic := '0';
    signal sig_sts_fifo_wr_rst  : std_logic := '0';
    signal sig_sts_fifo_rd_clk  : std_logic := '0';
    signal sig_sts_fifo_rd_rst  : std_logic := '0';
    signal sig_reset_mstr       : std_logic := '0';
    signal sig_reset_user       : std_logic := '0';
 
 
  
  
  begin --(architecture implementation)
  
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_SYNC_RESET
    --
    -- If Generate Description:
    --  This IfGen assigns the clock and reset signals for the 
    -- synchronous User interface case
    --
    ------------------------------------------------------------
    GEN_SYNC_RESET : if (C_STSCMD_IS_ASYNC = 0) generate
    
       begin
    
          sig_reset_mstr       <= internal_reset  ;
          sig_reset_user       <= internal_reset  ;
        
          sig_cmd_fifo_wr_clk   <=  primary_aclk  ;  
          sig_cmd_fifo_wr_rst   <=  sig_reset_user; 
          sig_cmd_fifo_rd_clk   <=  primary_aclk  ; 
          sig_cmd_fifo_rd_rst   <=  sig_reset_mstr; 
         
          sig_sts_fifo_wr_clk   <=  primary_aclk  ; 
          sig_sts_fifo_wr_rst   <=  sig_reset_mstr; 
          sig_sts_fifo_rd_clk   <=  primary_aclk  ; 
          sig_sts_fifo_rd_rst   <=  sig_reset_user; 
           
         
        
             
         
       end generate GEN_SYNC_RESET;
  
  
    
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ASYNC_RESET
    --
    -- If Generate Description:
    --  This IfGen assigns the clock and reset signals for the 
    -- Asynchronous User interface case
    --
    ------------------------------------------------------------
    GEN_ASYNC_RESET : if (C_STSCMD_IS_ASYNC = 1) generate
    
       begin
    
         sig_reset_mstr        <= internal_reset  ;
         sig_reset_user        <= user_reset      ;
       
         sig_cmd_fifo_wr_clk   <=  secondary_awclk;  
         sig_cmd_fifo_wr_rst   <=  sig_reset_user ; 
         sig_cmd_fifo_rd_clk   <=  primary_aclk   ; 
         sig_cmd_fifo_rd_rst   <=  sig_reset_mstr ; 
        
         sig_sts_fifo_wr_clk   <=  primary_aclk   ; 
         sig_sts_fifo_wr_rst   <=  sig_reset_mstr ; 
         sig_sts_fifo_rd_clk   <=  secondary_awclk; 
         sig_sts_fifo_rd_rst   <=  sig_reset_user ; 
          
        
            
         
       end generate GEN_ASYNC_RESET;
  
  
  
  
       
    ------------------------------------------------------------
    -- Instance: I_CMD_FIFO 
    --
    -- Description:
    -- Instance for the Command FIFO
    -- The User Interface is the Write Side
    -- The Internal Interface is the Read side    
    --
    ------------------------------------------------------------
     I_CMD_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
     generic map (
   
       C_DWIDTH            =>  C_CMD_WIDTH          ,  
       C_DEPTH             =>  C_STSCMD_FIFO_DEPTH  ,  
       C_IS_ASYNC          =>  C_STSCMD_IS_ASYNC    ,  
       C_PRIM_TYPE         =>  FIFO_PRIM_TYPE       ,  
       C_FAMILY            =>  C_FAMILY                
      
       )
     port map (
       
       -- Write Clock and reset
       fifo_wr_reset        =>  sig_cmd_fifo_wr_rst ,  
       fifo_wr_clk          =>  sig_cmd_fifo_wr_clk ,  
       
       -- Write Side
       fifo_wr_tvalid       =>  cmd_wvalid          ,  
       fifo_wr_tready       =>  cmd_wready          ,  
       fifo_wr_tdata        =>  cmd_wdata           ,  
       fifo_wr_full         =>  open                ,  
      
      
       -- Read Clock and reset
       fifo_async_rd_reset  =>  sig_cmd_fifo_rd_rst ,     
       fifo_async_rd_clk    =>  sig_cmd_fifo_rd_clk ,   
       
       -- Read Side
       fifo_rd_tvalid       =>  mst2cmd_cmd_valid   ,  
       fifo_rd_tready       =>  cmd2mstr_cmd_ready  ,  
       fifo_rd_tdata        =>  cmd2mstr_command    ,  
       fifo_rd_empty        =>  open                   
      
       );

CACHE_ENABLE : if C_ENABLE_CACHE_USER = 1 generate
begin
   
     I_CACHE_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
     generic map (
   
       C_DWIDTH            =>  8          ,  
       C_DEPTH             =>  C_STSCMD_FIFO_DEPTH  ,  
       C_IS_ASYNC          =>  C_STSCMD_IS_ASYNC    ,  
       C_PRIM_TYPE         =>  FIFO_PRIM_TYPE       ,  
       C_FAMILY            =>  C_FAMILY                
      
       )
     port map (
       
       -- Write Clock and reset
       fifo_wr_reset        =>  sig_cmd_fifo_wr_rst ,  
       fifo_wr_clk          =>  sig_cmd_fifo_wr_clk ,  
       
       -- Write Side
       fifo_wr_tvalid       =>  cmd_wvalid          ,  
       fifo_wr_tready       =>  open ,--cmd_wready          ,  
       fifo_wr_tdata        =>  cache_data           ,  
       fifo_wr_full         =>  open                ,  
      
      
       -- Read Clock and reset
       fifo_async_rd_reset  =>  sig_cmd_fifo_rd_rst ,     
       fifo_async_rd_clk    =>  sig_cmd_fifo_rd_clk ,   
       
       -- Read Side
       fifo_rd_tvalid       =>  open ,--mst2cmd_cmd_valid   ,  
       fifo_rd_tready       =>  cmd2mstr_cmd_ready  ,  
       fifo_rd_tdata        =>  cache2mstr_command  ,  
       fifo_rd_empty        =>  open                   
      
       );
   
end generate;    
    
    
CACHE_DISABLE : if C_ENABLE_CACHE_USER = 0 generate
begin
   
 cache2mstr_command <= (others => '0'); 
    
end generate CACHE_DISABLE;    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_INCLUDE_STATUS_FIFO
    --
    -- If Generate Description:
    --  Instantiates a Status FIFO
    --
    --
    ------------------------------------------------------------
    GEN_INCLUDE_STATUS_FIFO : if (C_INCLUDE_STSFIFO = 1) generate
    
       begin
 
  
         -- Set constant outputs for Status Interface
         sts_wstrb             <=  (others => '1');    
         sts_wlast             <=  '1';                
         
         
       
         ------------------------------------------------------------
         -- Instance: I_STS_FIFO 
         --
         -- Description:
         -- Instance for the Status FIFO
         -- The Internal Interface is the Write Side
         -- The User Interface is the Read side    
         --
         ------------------------------------------------------------
         I_STS_FIFO : entity axi_datamover_v5_1.axi_datamover_fifo
         generic map (
       
           C_DWIDTH            =>  C_STS_WIDTH            ,  
           C_DEPTH             =>  C_STSCMD_FIFO_DEPTH    ,  
           C_IS_ASYNC          =>  C_STSCMD_IS_ASYNC      ,  
           C_PRIM_TYPE         =>  FIFO_PRIM_TYPE         ,  
           C_FAMILY            =>  C_FAMILY                  
          
           )
         port map (
           
           -- Write Clock and reset
           fifo_wr_reset        =>  sig_sts_fifo_wr_rst   ,  
           fifo_wr_clk          =>  sig_sts_fifo_wr_clk   ,  
           
           -- Write Side
           fifo_wr_tvalid       =>  mst2stst_status_valid ,  
           fifo_wr_tready       =>  stat2mstr_status_ready,  
           fifo_wr_tdata        =>  mstr2stat_status      ,  
           fifo_wr_full         =>  open                  ,  
          
          
           -- Read Clock and reset
           fifo_async_rd_reset  =>  sig_sts_fifo_rd_rst   ,     
           fifo_async_rd_clk    =>  sig_sts_fifo_rd_clk   ,   
           
           -- Read Side
           fifo_rd_tvalid       =>  sts_wvalid            ,  
           fifo_rd_tready       =>  sts_wready            ,  
           fifo_rd_tdata        =>  sts_wdata             ,  
           fifo_rd_empty        =>  open                     
          
           );
        
    
       end generate GEN_INCLUDE_STATUS_FIFO;
    
    
    
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_OMIT_STATUS_FIFO
    --
    -- If Generate Description:
    --  Omits the Status FIFO
    --
    --
    ------------------------------------------------------------
    GEN_OMIT_STATUS_FIFO : if (C_INCLUDE_STSFIFO = 0) generate
    
       begin
  
         -- Status FIFO User interface housekeeping
         sts_wvalid            <=  '0';
         -- sts_wready         -- ignored
         sts_wdata             <=  (others => '0');
         sts_wstrb             <=  (others => '0');    
         sts_wlast             <=  '0';                
 
         
         
         -- Status FIFO Internal interface housekeeping
         stat2mstr_status_ready <= '1';
         -- mstr2stat_status       -- ignored
         -- mst2stst_status_valid  -- ignored
 
    
       end generate GEN_OMIT_STATUS_FIFO;
    
    
 
  
  end implementation;
