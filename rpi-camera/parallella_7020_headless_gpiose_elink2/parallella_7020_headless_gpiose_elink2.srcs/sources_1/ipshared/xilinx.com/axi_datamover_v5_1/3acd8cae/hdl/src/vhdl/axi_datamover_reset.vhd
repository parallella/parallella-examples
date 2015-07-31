  -------------------------------------------------------------------------------
  -- axi_datamover_reset.vhd
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
  -- Filename:        axi_datamover_reset.vhd
  --
  -- Description:     
  --   This file implements the DataMover Reset module.               
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
  
  library lib_cdc_v1_0;  
  -------------------------------------------------------------------------------
  
  entity axi_datamover_reset is
    generic (
      
      C_STSCMD_IS_ASYNC    : Integer range  0 to  1 :=  0
        -- 0 = Use Synchronous Command/Statys User Interface
        -- 1 = Use Asynchronous Command/Statys User Interface
      );
    port (
      
      -- Primary Clock and Reset Inputs -----------------
                                                       --
      primary_aclk         : in  std_logic;            --
      primary_aresetn      : in  std_logic;            --
      ---------------------------------------------------
      
                                                       
      -- Async operation clock and reset from User ------
      -- Used for Command/Status User interface        --
      -- synchronization when C_STSCMD_IS_ASYNC = 1    --
                                                       --
      secondary_awclk      : in  std_logic;            --
      secondary_aresetn    : in  std_logic;            --
      ---------------------------------------------------
  
                                           
     
      -- Halt request input control -------------------------------
      halt_req             : in  std_logic;                      --
         -- Active high soft shutdown request (can be a pulse)   --
                                                                 --
      -- Halt Complete status flag                               --
      halt_cmplt           : Out std_logic;                      --
         -- Active high soft shutdown complete status            --
      -------------------------------------------------------------
      
       
                                                 
      -- Soft Shutdown internal interface ------------------------------------------------
                                                                                        --
      flush_stop_request   : Out std_logic;                                             --
         -- Active high soft stop request to modules                                    --
                                                                                        --
      data_cntlr_stopped   : in  std_logic;                                             --
         -- Active high flag indicating the data controller is flushed and stopped      --
                                                                                        --
      addr_cntlr_stopped   : in  std_logic;                                             --
         -- Active high flag indicating the address controller is flushed and stopped   --
                                                                                        --
      aux1_stopped         : in  std_logic;                                             --
         -- Active high flag flush complete for auxillary 1 module                      --
         -- Tie high if unused                                                          --
                                                                                        --
      aux2_stopped         : in  std_logic;                                             --
         -- Active high flag flush complete for auxillary 2 module                      --
         -- Tie high if unused                                                          --
      ------------------------------------------------------------------------------------
      
       
          
      -- HW Reset outputs to reset groups  -------------------------------------     
                                                                              --
      cmd_stat_rst_user    : Out std_logic;                                   --
         -- The reset to the Command/Status Module User interface side        --
                                                                              --
      cmd_stat_rst_int     : Out std_logic;                                   --
         -- The reset to the Command/Status Module internal interface side    --
                                                                              --
      mmap_rst             : Out std_logic;                                   --
         -- The reset to the Memory Map interface side                        --
                                                                              --
      stream_rst           : Out std_logic                                    --
         -- The reset to the Stream interface side                            --
      --------------------------------------------------------------------------
      
      );
  
  end entity axi_datamover_reset;
  
  
  architecture implementation of axi_datamover_reset is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";

    constant MTBF_STAGES : integer := 4;
  
      --  ATTRIBUTE async_reg                      : STRING;
    -- Signals
    
    signal sig_cmd_stat_rst_user_n     : std_logic := '0';
    signal sig_cmd_stat_rst_user_reg_n_cdc_from : std_logic := '0';
    signal sig_cmd_stat_rst_int_reg_n  : std_logic := '0';
    signal sig_mmap_rst_reg_n          : std_logic := '0';
    signal sig_stream_rst_reg_n        : std_logic := '0';
    signal sig_syncd_sec_rst           : std_logic := '0';
    
    -- soft shutdown support
    signal sig_internal_reset          : std_logic := '0';
    signal sig_s_h_halt_reg            : std_logic := '0';
    signal sig_halt_cmplt              : std_logic := '0';
                               
    -- additional CDC synchronization signals
    signal sig_sec_neg_edge_plus_delay : std_logic := '0';
    signal sig_secondary_aresetn_reg   : std_logic := '0';
    signal sig_prim2sec_rst_reg1_n_cdc_to     : std_logic := '0';
    signal sig_prim2sec_rst_reg2_n     : std_logic := '0';
    
--  ATTRIBUTE async_reg OF sig_prim2sec_rst_reg1_n_cdc_to  : SIGNAL IS "true";
--  ATTRIBUTE async_reg OF sig_prim2sec_rst_reg2_n  : SIGNAL IS "true";
                               
                               
  begin --(architecture implementation)
  
  
    -- Assign outputs
   
    cmd_stat_rst_user <=   not(sig_cmd_stat_rst_user_n);
    
    cmd_stat_rst_int  <=   not(sig_cmd_stat_rst_int_reg_n) or
                           sig_syncd_sec_rst;
    
    mmap_rst          <=   not(sig_mmap_rst_reg_n) or
                           sig_syncd_sec_rst;
    
    stream_rst        <=   not(sig_stream_rst_reg_n) or
                           sig_syncd_sec_rst;
    
    
    
    
    
    
    
    -- Internal logic Implmentation
    
    
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_SYNC_CMDSTAT_RESET
    --
    -- If Generate Description:
    --  This IfGen assigns the reset for the 
    -- Synchronous Command/Status User interface case
    --
    ------------------------------------------------------------
    GEN_SYNC_CMDSTAT_RESET : if (C_STSCMD_IS_ASYNC = 0) generate
       
       begin
    
          sig_syncd_sec_rst       <= '0';
          
          sig_cmd_stat_rst_user_n <=  not(sig_cmd_stat_rst_user_reg_n_cdc_from);
                    
       end generate GEN_SYNC_CMDSTAT_RESET;
  
  
  
    ------------------------------------------------------------
    -- If Generate
    --
    -- Label: GEN_ASYNC_CMDSTAT_RESET
    --
    -- If Generate Description:
    --  This IfGen assigns the reset for the 
    -- Asynchronous Command/Status User interface case
    --
    ------------------------------------------------------------
    GEN_ASYNC_CMDSTAT_RESET : if (C_STSCMD_IS_ASYNC = 1) generate
     --   ATTRIBUTE async_reg                      : STRING;
 
      signal sig_sec_reset_in_reg_n      : std_logic := '0';
      signal sig_secondary_aresetn_reg_tmp : std_logic := '0';
      
      -- Secondary reset pulse stretcher
      signal sig_secondary_dly1          : std_logic := '0';
      signal sig_secondary_dly2          : std_logic := '0';
      signal sig_neg_edge_detect         : std_logic := '0';
      signal sig_sec2prim_reset          : std_logic := '0';
      signal sig_sec2prim_reset_reg_cdc_tig      : std_logic := '0';
      signal sig_sec2prim_reset_reg2     : std_logic := '0';
      signal sig_sec2prim_rst_syncro1_cdc_tig    : std_logic := '0';
      signal sig_sec2prim_rst_syncro2    : std_logic := '0';
--  ATTRIBUTE async_reg OF sig_sec2prim_reset_reg_cdc_tig  : SIGNAL IS "true";
--  ATTRIBUTE async_reg OF sig_sec2prim_reset_reg2  : SIGNAL IS "true";
      
--  ATTRIBUTE async_reg OF sig_sec2prim_rst_syncro1_cdc_tig  : SIGNAL IS "true";
--  ATTRIBUTE async_reg OF sig_sec2prim_rst_syncro2  : SIGNAL IS "true";
                                 
      begin
         
        -- Generate the reset in the primary clock domain. Use the longer
        -- of the pulse stretched reset or the actual reset.
        sig_syncd_sec_rst <= sig_sec2prim_reset_reg2 or
                             sig_sec2prim_rst_syncro2;
  
        
        -- Check for falling edge of secondary_aresetn input
        sig_neg_edge_detect <=  '1'
          when (sig_sec_reset_in_reg_n = '1' and 
                secondary_aresetn      = '0')
          else '0';
          

        
         
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: IMP_PUSE_STRETCH_FLOPS
        --
        -- Process Description:
        -- This process implements a 3 clock wide pulse whenever the 
        -- secondary reset is asserted
        --
        -------------------------------------------------------------
        IMP_PUSE_STRETCH_FLOPS : process (secondary_awclk)
          begin
            if (secondary_awclk'event and secondary_awclk = '1') then
            
              If (sig_secondary_dly2 = '1') Then
                
                sig_secondary_dly1 <= '0' ;
                sig_secondary_dly2 <= '0' ;
            
              Elsif (sig_neg_edge_detect = '1') Then
                
                sig_secondary_dly1 <= '1';
            
              else

                sig_secondary_dly2 <= sig_secondary_dly1 ;
              
              End if;
            
            
            
            
            end if;       
          end process IMP_PUSE_STRETCH_FLOPS; 
        
        
        
   --  CDC add     
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: SYNC_NEG_EDGE
        --
        -- Process Description:
        --  First (source clock) stage synchronizer for CDC of 
        -- negative edge detection,
        --
        -------------------------------------------------------------
        SYNC_NEG_EDGE : process (secondary_awclk)
          begin
            if (secondary_awclk'event and secondary_awclk = '1') then
            
              sig_sec_neg_edge_plus_delay <= sig_neg_edge_detect or
                                             sig_secondary_dly1  or
                                             sig_secondary_dly2;
            
            end if;       
          end process SYNC_NEG_EDGE; 
        
  --      
         
         
         
          
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: SEC2PRIM_RST_SYNCRO
        --
        -- Process Description:
        --    This process registers the secondary reset input to 
        -- the primary clock domain.
        --
        -------------------------------------------------------------
SEC2PRIM_RST_SYNCRO : entity  lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => '0',
        prmry_resetn               => '0',
        prmry_in                   => sig_sec_neg_edge_plus_delay,
        prmry_vect_in              => (others => '0'),

        scndry_aclk                => primary_aclk,
        scndry_resetn              => '0',
        scndry_out                 => sig_sec2prim_reset_reg2,
        scndry_vect_out            => open
    );


--        SEC2PRIM_RST_SYNCRO : process (primary_aclk)
--           begin
--             if (primary_aclk'event and primary_aclk = '1') then
--             
--               
--               sig_sec2prim_reset_reg_cdc_tig   <=  sig_sec_neg_edge_plus_delay ;
--               
--               sig_sec2prim_reset_reg2  <=  sig_sec2prim_reset_reg_cdc_tig;
--                            
--             end if;       
--           end process SEC2PRIM_RST_SYNCRO; 
        
       
       
 
 
 
 
 
 
   --  CDC add     
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: REG_SEC_RST
        --
        -- Process Description:
        --  First (source clock) stage synchronizer for CDC of 
        -- secondary reset input,
        --
        -------------------------------------------------------------
        REG_SEC_RST : process (secondary_awclk)
          begin
            if (secondary_awclk'event and secondary_awclk = '1') then
            
              sig_secondary_aresetn_reg <= secondary_aresetn;
            
            end if;       
          end process REG_SEC_RST; 
        
  --      
         
         
         
         
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: SEC2PRIM_RST_SYNCRO_2
        --
        -- Process Description:
        --    Second stage (destination) synchronizers for the secondary
        -- reset CDC to the primary clock.
        --
        -------------------------------------------------------------

         sig_secondary_aresetn_reg_tmp <= not(sig_secondary_aresetn_reg);

SEC2PRIM_RST_SYNCRO_2 : entity  lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => '0',
        prmry_resetn               => '0',
        prmry_in                   => sig_secondary_aresetn_reg_tmp,
        prmry_vect_in              => (others => '0'),

        scndry_aclk                => primary_aclk,
        scndry_resetn              => '0',
        scndry_out                 => sig_sec2prim_rst_syncro2,
        scndry_vect_out            => open
    );


--        SEC2PRIM_RST_SYNCRO_2 : process (primary_aclk)
--           begin
--             if (primary_aclk'event and primary_aclk = '1') then
--             
--               
--      -- CDC   sig_sec2prim_rst_syncro1_cdc_tig  <= not(secondary_aresetn);
--               sig_sec2prim_rst_syncro1_cdc_tig  <= not(sig_secondary_aresetn_reg);
--               sig_sec2prim_rst_syncro2  <= sig_sec2prim_rst_syncro1_cdc_tig;
-- 
-- 
--             end if;       
--           end process SEC2PRIM_RST_SYNCRO_2; 
        
       
         
         
         -- Generate the Command and Status side reset
         sig_cmd_stat_rst_user_n <= sig_sec_reset_in_reg_n and
                                    sig_prim2sec_rst_reg2_n;
    -- CDC                          sig_cmd_stat_rst_user_reg_n_cdc_from;
   
   
    
    
         
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: REG_RESET_ASYNC
         --
         -- Process Description:
         --    This process registers the secondary reset input to 
         -- generate the Command/Status User interface reset.
         --
         -------------------------------------------------------------
         REG_RESET_ASYNC : process (secondary_awclk)
            begin
              if (secondary_awclk'event and secondary_awclk = '1') then
              
                 sig_sec_reset_in_reg_n <= secondary_aresetn;
              
              end if;       
            end process REG_RESET_ASYNC; 
         
   
   
   
   
   --  CDC add     
        
        -------------------------------------------------------------
        -- Synchronous Process with Sync Reset
        --
        -- Label: SYNC_PRIM2SEC_RST
        --
        -- Process Description:
        --  Second (destination clock) stage synchronizers for CDC of 
        -- primary reset input,
        --
        -------------------------------------------------------------

SYNC_PRIM2SEC_RST : entity  lib_cdc_v1_0.cdc_sync
    generic map (
        C_CDC_TYPE                 => 1,
        C_RESET_STATE              => 0,
        C_SINGLE_BIT               => 1,
        C_VECTOR_WIDTH             => 32,
        C_MTBF_STAGES              => MTBF_STAGES
    )
    port map (
        prmry_aclk                 => '0',
        prmry_resetn               => '0',
        prmry_in                   => sig_cmd_stat_rst_user_reg_n_cdc_from,
        prmry_vect_in              => (others => '0'),

        scndry_aclk                => secondary_awclk,
        scndry_resetn              => '0',
        scndry_out                 => sig_prim2sec_rst_reg2_n,
        scndry_vect_out            => open
    );


--        SYNC_PRIM2SEC_RST : process (secondary_awclk)
--          begin
--            if (secondary_awclk'event and secondary_awclk = '1') then
--            
--              sig_prim2sec_rst_reg1_n_cdc_to <= sig_cmd_stat_rst_user_reg_n_cdc_from;
--              sig_prim2sec_rst_reg2_n <= sig_prim2sec_rst_reg1_n_cdc_to;
--            
--            end if;       
--          end process SYNC_PRIM2SEC_RST; 
        
  --      
         
         
        
        
      end generate GEN_ASYNC_CMDSTAT_RESET;
 
 
 
  
  
  
  
  
  
  
  
 
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_CMDSTAT_PRIM_RESET
    --
    -- Process Description:
    --    This process registers the primary reset input to 
    -- generate the Command/Status User interface reset.
    --
    -------------------------------------------------------------
    REG_CMDSTAT_PRIM_RESET : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
         
            sig_cmd_stat_rst_user_reg_n_cdc_from <= primary_aresetn;
         
         end if;       
       end process REG_CMDSTAT_PRIM_RESET; 
    
   
   
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_CMDSTAT_INT_RESET
    --
    -- Process Description:
    --    This process registers the primary reset input to 
    -- generate the Command/Status internal interface reset.
    --
    -------------------------------------------------------------
    REG_CMDSTAT_INT_RESET : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
         
            sig_cmd_stat_rst_int_reg_n <= primary_aresetn;
         
         end if;       
       end process REG_CMDSTAT_INT_RESET; 
    
   
   
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_MMAP_RESET
    --
    -- Process Description:
    --    This process registers the primary reset input to 
    -- generate the Memory Map interface reset.
    --
    -------------------------------------------------------------
    REG_MMAP_RESET : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
         
            sig_mmap_rst_reg_n <= primary_aresetn;
         
         end if;       
       end process REG_MMAP_RESET; 
    
   
   
 
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_STREAM_RESET
    --
    -- Process Description:
    --    This process registers the primary reset input to 
    -- generate the Stream interface reset.
    --
    -------------------------------------------------------------
    REG_STREAM_RESET : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
         
            sig_stream_rst_reg_n <= primary_aresetn;
         
         end if;       
       end process REG_STREAM_RESET; 
    
  
  
  
  
  
  
  
  
  -- Soft Shutdown logic ------------------------------------------------------
  
    
    
    sig_internal_reset  <= not(sig_cmd_stat_rst_int_reg_n) or
                           sig_syncd_sec_rst;
    
    
    flush_stop_request  <= sig_s_h_halt_reg;
    
    
    halt_cmplt          <= sig_halt_cmplt;
    
    
    
    
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: REG_HALT_REQ
    --
    -- Process Description:
    --  Implements a sample and hold flop for the halt request 
    -- input. Can only be cleared on a HW reset.
    --
    -------------------------------------------------------------
    REG_HALT_REQ : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_internal_reset = '1') then
              
              sig_s_h_halt_reg <= '0';
            
            elsif (halt_req = '1') then
              
              sig_s_h_halt_reg <= '1';
            
            else
              null;  -- hold current state
            end if; 
         end if;       
       end process REG_HALT_REQ; 
     
     
  
  
  
  
  
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: IMP_HALT_CMPLT
    --
    -- Process Description:
    --  Implements a the flop for the halt complete status 
    -- output. Can only be cleared on a HW reset.
    --
    -------------------------------------------------------------
    IMP_HALT_CMPLT : process (primary_aclk)
       begin
         if (primary_aclk'event and primary_aclk = '1') then
            if (sig_internal_reset = '1') then
              
              sig_halt_cmplt <= '0';
            
            elsif (data_cntlr_stopped = '1' and
                   addr_cntlr_stopped = '1' and
                   aux1_stopped       = '1' and
                   aux2_stopped       = '1') then
              
              sig_halt_cmplt <= '1';
            
            else
              null;  -- hold current state
            end if; 
         end if;       
       end process IMP_HALT_CMPLT; 
     
     
  
          
          
  
    
  end implementation;
