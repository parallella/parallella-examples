-------------------------------------------------------------------------------
-- axi_datamover_mm2s_dre.vhd
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
-- Filename:        axi_datamover_mm2s_dre.vhd
--
-- Description:
--     This VHDL design implements a 64 bit wide (8 byte lane) function that
-- realigns an arbitrarily aligned input data stream to an arbitrarily aligned
-- output data stream.
--
--
--
-- VHDL-Standard:   VHDL'93
-------------------------------------------------------------------------------
---------------------------------------------------------------------------------
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library axi_datamover_v5_1;
use axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n;
use axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n;
use axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n;


-------------------------------------------------------------------------------

entity axi_datamover_mm2s_dre is
  Generic (
    
    C_DWIDTH          : Integer := 64;
      -- Sets the native data width of the DRE
      
    C_ALIGN_WIDTH     : Integer :=  3
      -- Sets the alignment port widths. The value should be
      -- log2(C_DWIDTH)
     
    );
  port (
   
   -- Clock and Reset inputs ---------------
    dre_clk          : In  std_logic;     --
    dre_rst          : In  std_logic;     --
    ----------------------------------------
    
    
    -- Alignment Controls ------------------------------------------------ 
    dre_new_align    : In  std_logic;                                   --
    dre_use_autodest : In  std_logic;                                   --
    dre_src_align    : In  std_logic_vector(C_ALIGN_WIDTH-1 downto 0);  --
    dre_dest_align   : In  std_logic_vector(C_ALIGN_WIDTH-1 downto 0);  --
    dre_flush        : In  std_logic;                                   --
    ----------------------------------------------------------------------

                                                               
    -- Input Stream Interface --------------------------------------------
    dre_in_tstrb     : In  std_logic_vector((C_DWIDTH/8)-1 downto 0);   --
    dre_in_tdata     : In  std_logic_vector(C_DWIDTH-1 downto 0);       --
    dre_in_tlast     : In  std_logic;                                   --
    dre_in_tvalid    : In  std_logic;                                   --
    dre_in_tready    : Out std_logic;                                   --
    ----------------------------------------------------------------------

   
    -- Output Stream Interface -------------------------------------------
    dre_out_tstrb     : Out std_logic_vector((C_DWIDTH/8)-1 downto 0);  --
    dre_out_tdata     : Out std_logic_vector(C_DWIDTH-1 downto 0);      --
    dre_out_tlast     : Out std_logic;                                  --
    dre_out_tvalid    : Out std_logic;                                  --
    dre_out_tready    : In  std_logic                                   --
    ----------------------------------------------------------------------
    
    );

end entity axi_datamover_mm2s_dre;


architecture implementation of axi_datamover_mm2s_dre is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of implementation : architecture is "yes";


  
  -- Functions

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




  -- Constants

      Constant BYTE_WIDTH         : integer := 8; -- bits
      Constant DATA_WIDTH_BYTES   : integer := C_DWIDTH/BYTE_WIDTH;
      Constant SLICE_WIDTH        : integer := BYTE_WIDTH+2; -- 8 data bits plus Strobe plus TLAST bit
      Constant SLICE_STROBE_INDEX : integer := (BYTE_WIDTH-1)+1;
      Constant SLICE_TLAST_INDEX  : integer := SLICE_STROBE_INDEX+1;
      Constant ZEROED_SLICE       : std_logic_vector(SLICE_WIDTH-1 downto 0) := (others => '0');
      Constant NUM_BYTE_LANES     : integer := C_DWIDTH/BYTE_WIDTH;
      Constant ALIGN_VECT_WIDTH   : integer := C_ALIGN_WIDTH;
      Constant NO_STRB_SET_VALUE  : integer := 0;
  
      
  
  -- Types

      type sig_byte_lane_type is array(DATA_WIDTH_BYTES-1 downto 0) of
                    std_logic_vector(SLICE_WIDTH-1 downto 0);



  -- Signals

      signal sig_input_data_reg       : sig_byte_lane_type;
      signal sig_delay_data_reg       : sig_byte_lane_type;
      signal sig_output_data_reg      : sig_byte_lane_type;
      signal sig_pass_mux_bus         : sig_byte_lane_type;
      signal sig_delay_mux_bus        : sig_byte_lane_type;
      signal sig_final_mux_bus        : sig_byte_lane_type;
      Signal sig_dre_strb_out_i       : std_logic_vector(DATA_WIDTH_BYTES-1 downto 0) := (others => '0');
      Signal sig_dre_data_out_i       : std_logic_vector(C_DWIDTH-1 downto 0) := (others => '0');
      Signal sig_dest_align_i         : std_logic_vector(ALIGN_VECT_WIDTH-1 downto 0) := (others => '0');
      Signal sig_dre_flush_i          : std_logic := '0';
      Signal sig_pipeline_halt        : std_logic := '0';
      Signal sig_dre_tvalid_i         : std_logic := '0';
      Signal sig_input_accept         : std_logic := '0';
      Signal sig_tlast_enables        : std_logic_vector(NUM_BYTE_LANES-1 downto 0) := (others => '0');
      signal sig_final_mux_has_tlast  : std_logic := '0';
      signal sig_tlast_out            : std_logic := '0';
      Signal sig_tlast_strobes        : std_logic_vector(NUM_BYTE_LANES-1 downto 0) := (others => '0');
      Signal sig_next_auto_dest       : std_logic_vector(ALIGN_VECT_WIDTH-1 downto 0) := (others => '0');
      Signal sig_current_dest_align   : std_logic_vector(ALIGN_VECT_WIDTH-1 downto 0) := (others => '0');
      Signal sig_last_written_strb    : std_logic_vector(NUM_BYTE_LANES-1 downto 0) := (others => '0');
      Signal sig_auto_flush           : std_logic := '0';
      Signal sig_flush_db1            : std_logic := '0';
      Signal sig_flush_db2            : std_logic := '0';
      signal sig_flush_db1_complete   : std_logic := '0';
      signal sig_flush_db2_complete   : std_logic := '0';
      signal sig_output_xfer          : std_logic := '0';
      signal sig_advance_pipe_data    : std_logic := '0';
      Signal sig_flush_reg            : std_logic := '0';
      Signal sig_input_flush_stall    : std_logic := '0';
      signal sig_enable_input_rdy     : std_logic := '0';
      signal sig_input_ready          : std_logic := '0';

      
      
begin --(architecture implementation)

   
   
   
   
   
   -- Misc assignments

    --dre_in_tready            <= sig_input_accept   ;
    dre_in_tready            <= sig_input_ready    ;

    dre_out_tstrb            <= sig_dre_strb_out_i ;

    dre_out_tdata            <= sig_dre_data_out_i ;

    dre_out_tvalid           <= sig_dre_tvalid_i   ;
    
    dre_out_tlast            <= sig_tlast_out      ;

    sig_pipeline_halt        <= sig_dre_tvalid_i and not(dre_out_tready);


    sig_output_xfer          <= sig_dre_tvalid_i and dre_out_tready;
    
    
    sig_advance_pipe_data    <= (dre_in_tvalid or 
                                 sig_dre_flush_i) and
                                 not(sig_pipeline_halt) and
                                 sig_enable_input_rdy;
    
    sig_dre_flush_i          <= sig_auto_flush        ;
                                                                   

    sig_input_accept         <= dre_in_tvalid and
                                sig_input_ready;



    sig_flush_db1_complete   <= sig_flush_db1 and
                                not(sig_pipeline_halt);
    
                                                       
    sig_flush_db2_complete   <= sig_flush_db2 and
                                not(sig_pipeline_halt);

    sig_auto_flush           <= sig_flush_db1 or sig_flush_db2;
                            
                               
    sig_input_flush_stall    <= sig_auto_flush;     -- commanded flush needed for concatonation
    
    
    sig_last_written_strb    <= sig_dre_strb_out_i;
   
   
 
    sig_input_ready          <= sig_enable_input_rdy   and
                                not(sig_pipeline_halt) and
                                not(sig_input_flush_stall) ;
 
    
   
   
   
   
   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: IMP_RESET_FLOP
   --
   -- Process Description:
   --   Just a flop for generating an input disable while reset
   -- is in progress.
   --
   -------------------------------------------------------------
   IMP_RESET_FLOP : process (dre_clk)
      begin
        if (dre_clk'event and dre_clk = '1') then
           
           if (dre_rst = '1') then
             
             sig_enable_input_rdy <= '0';
           
           else
             
             sig_enable_input_rdy <= '1';
           
           end if; 
        end if;       
      end process IMP_RESET_FLOP; 
   
   


   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: REG_FLUSH_IN
   --
   -- Process Description:
   --  Register for the flush signal
   --
   -------------------------------------------------------------
   REG_FLUSH_IN : process (dre_clk)
      begin
        if (dre_clk'event and dre_clk = '1') then
           
           if (dre_rst       = '1' or
               sig_flush_db2 = '1') then
             
             sig_flush_reg <= '0';
           
           elsif (sig_input_accept = '1') then
             
             sig_flush_reg <= dre_flush;
           
           else
             null;  -- hold current state
           end if; 
        end if;       
      end process REG_FLUSH_IN; 
   
   


   -------------------------------------------------------------
   -- Combinational Process
   --
   -- Label: DO_FINAL_MUX_TLAST_OR
   --
   -- Process Description:
   -- Look at all associated tlast bits in the Final Mux output
   -- and detirmine if any are set.
   --  
   --
   -------------------------------------------------------------
   DO_FINAL_MUX_TLAST_OR : process (sig_final_mux_bus)
       
     Variable lvar_finalmux_or : std_logic_vector(NUM_BYTE_LANES-1 downto 0);
       
     begin
       
       lvar_finalmux_or(0) := sig_final_mux_bus(0)(SLICE_TLAST_INDEX);
       
       for tlast_index in 1 to NUM_BYTE_LANES-1 loop
       
          lvar_finalmux_or(tlast_index) := 
                       lvar_finalmux_or(tlast_index-1)   or
                       sig_final_mux_bus(tlast_index)(SLICE_TLAST_INDEX);
       
       end loop;
       
       
       sig_final_mux_has_tlast <= lvar_finalmux_or(NUM_BYTE_LANES-1);  
       
     
     end process DO_FINAL_MUX_TLAST_OR; 
  
    ------------------------------------------------------------------------
  
   
 
   
    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: GEN_FLUSH_DB1
    --
    -- Process Description:
    --  Creates the first sequential flag indicating that the DRE needs to flush out
    -- current contents before allowing any new inputs. This is 
    -- triggered by the receipt of the TLAST.
    --
    -------------------------------------------------------------
    GEN_FLUSH_DB1 : process (dre_clk)
       begin

         if (dre_clk'event and dre_clk = '1') then

            If (dre_rst                = '1' or
                sig_flush_db2_complete = '1') Then
    
       
              sig_flush_db1   <= '0';

            Elsif (sig_input_accept = '1') Then
               
               sig_flush_db1  <= dre_flush or dre_in_tlast;

            else
              null;  -- hold state
            end if;
--         else
--           null;
         end if;
       end process GEN_FLUSH_DB1;


    -------------------------------------------------------------
    -- Synchronous Process with Sync Reset
    --
    -- Label: GEN_FLUSH_DB2
    --
    -- Process Description:
    --  Creates a second sequential flag indicating that the DRE
    -- is flushing out current contents. This is 
    -- triggered by the assertion of the first sequential flush 
    -- flag.
    --
    -------------------------------------------------------------
    GEN_FLUSH_DB2 : process (dre_clk)
       begin

         if (dre_clk'event and dre_clk = '1') then

            If (dre_rst                = '1' or
                sig_flush_db2_complete = '1') Then
    
       
              sig_flush_db2   <= '0';

            elsif (sig_pipeline_halt = '0') then              

               sig_flush_db2  <= sig_flush_db1;

            else
              null;  -- hold state
            end if;
--         else
--           null;
         end if;
       end process GEN_FLUSH_DB2;



    -------------------------------------------------------------
    -- Combinational Process
    --
    -- Label: CALC_DEST_STRB_ALIGN
    --
    -- Process Description:
    --    This process calculates the byte lane position of the
    -- left-most STRB that is unasserted on the DRE output STRB bus.
    -- The resulting value is used as the Destination Alignment
    -- Vector for the DRE.
    --
    -------------------------------------------------------------
    CALC_DEST_STRB_ALIGN : process (sig_last_written_strb)

      Variable lvar_last_strb_hole_position : Integer range 0 to NUM_BYTE_LANES;
      Variable lvar_strb_hole_detected      : Boolean;
      Variable lvar_first_strb_assert_found : Boolean;
      Variable lvar_loop_count              : integer range 0 to NUM_BYTE_LANES;

      Begin

          lvar_loop_count               := NUM_BYTE_LANES;
          lvar_last_strb_hole_position  := 0;
          lvar_strb_hole_detected       := FALSE;
          lvar_first_strb_assert_found  := FALSE;

          -- Search through the output STRB bus starting with the MSByte
          while (lvar_loop_count > 0) loop

             If (sig_last_written_strb(lvar_loop_count-1) = '0' and
                 lvar_first_strb_assert_found  = FALSE) Then

                lvar_strb_hole_detected      := TRUE;
                lvar_last_strb_hole_position := lvar_loop_count-1;

             Elsif (sig_last_written_strb(lvar_loop_count-1) = '1') Then

                lvar_first_strb_assert_found  := true;

             else
                null; -- do nothing
             End if;

             lvar_loop_count := lvar_loop_count - 1;

          End loop;

          -- now assign the encoder output value to the bit position of the last Strobe encountered
          If (lvar_strb_hole_detected) Then
             
             sig_current_dest_align <= STD_LOGIC_VECTOR(TO_UNSIGNED(lvar_last_strb_hole_position, ALIGN_VECT_WIDTH));
             
          else
             
             sig_current_dest_align <= STD_LOGIC_VECTOR(TO_UNSIGNED(NO_STRB_SET_VALUE, ALIGN_VECT_WIDTH));
          
          End if;

       end process CALC_DEST_STRB_ALIGN;



   ------------------------------------------------------------
   ------------------------------------------------------------
   ------------------------------------------------------------
   -- For Generate
   --
   -- Label: FORMAT_OUTPUT_DATA_STRB
   --
   -- For Generate Description:
   --   Connect the output Data and Strobe ports to the appropriate
   -- bits in the sig_output_data_reg.
   --
   ------------------------------------------------------------
   FORMAT_OUTPUT_DATA_STRB : for byte_lane_index in 0 to NUM_BYTE_LANES-1 generate

   begin

      sig_dre_data_out_i(get_end_index(byte_lane_index, BYTE_WIDTH) downto
               get_start_index(byte_lane_index, BYTE_WIDTH)) <=
               
           sig_output_data_reg(byte_lane_index)(BYTE_WIDTH-1 downto 0);

   
   
   
      sig_dre_strb_out_i(byte_lane_index)   <=
           sig_output_data_reg(byte_lane_index)(SLICE_WIDTH-2);


   end generate FORMAT_OUTPUT_DATA_STRB;
   ------------------------------------------------------------
   ------------------------------------------------------------
   ------------------------------------------------------------

   
   ---------------------------------------------------------------------------------
   -- Registers
   


   ------------------------------------------------------------
   -- For Generate
   --
   -- Label: GEN_INPUT_REG
   --
   -- For Generate Description:
   --
   --   Implements a programble number of input register slices.
   -- 
   --
   ------------------------------------------------------------
   GEN_INPUT_REG : for slice_index in 0 to NUM_BYTE_LANES-1 generate
   
   begin
   
      
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: DO_INPUTREG_SLICE
       --
       -- Process Description:
       --  Implement a single register slice for the Input Register. 
       --
       -------------------------------------------------------------
       DO_INPUTREG_SLICE : process (dre_clk)
          begin
            if (dre_clk'event and dre_clk    = '1') then
               if (dre_rst                   = '1' or 
                   sig_flush_db1_complete    = '1' or      -- clear on reset or if
                  (dre_in_tvalid             = '1' and
                   sig_pipeline_halt         = '0' and     -- the pipe is being advanced and
                   dre_in_tstrb(slice_index) = '0')) then  -- no new valid data id being loaded
                 
                 sig_input_data_reg(slice_index) <= ZEROED_SLICE; 
               
               elsif (dre_in_tstrb(slice_index) = '1' and
                      sig_input_accept          = '1') then
                 
                 sig_input_data_reg(slice_index) <= sig_tlast_enables(slice_index) &
                                                    dre_in_tstrb(slice_index)      & 
                                                    dre_in_tdata((slice_index*8)+7 downto slice_index*8);
                 
               else
                 null; -- don't change state
               end if; 
            end if;       
          end process DO_INPUTREG_SLICE; 
      
      
      
      
   end generate GEN_INPUT_REG;
  
  

   ------------------------------------------------------------
   -- For Generate
   --
   -- Label: GEN_DELAY_REG
   --
   -- For Generate Description:
   --
   --   Implements a programble number of output register slices
   --
   --
   ------------------------------------------------------------
   GEN_DELAY_REG : for slice_index in 0 to NUM_BYTE_LANES-1 generate
   
   begin
   
      
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: DO_DELAYREG_SLICE
       --
       -- Process Description:
       --  Implement a single register slice 
       --
       -------------------------------------------------------------
       DO_DELAYREG_SLICE : process (dre_clk)
          begin
            if (dre_clk'event and dre_clk = '1') then
               if (dre_rst = '1'    or                                              -- clear on reset or if
                  (sig_advance_pipe_data   = '1' and                                -- the pipe is being advanced and
                   sig_delay_mux_bus(slice_index)(SLICE_STROBE_INDEX) = '0')) then  -- no new valid data id being loaded
                 
                 sig_delay_data_reg(slice_index) <= ZEROED_SLICE; 
               
               elsif (sig_delay_mux_bus(slice_index)(SLICE_STROBE_INDEX) = '1' and
                      sig_advance_pipe_data   = '1') then
                 
                 sig_delay_data_reg(slice_index) <= sig_delay_mux_bus(slice_index);
                 
               else
                 null; -- don't change state
               end if; 
            end if;       
          end process DO_DELAYREG_SLICE; 
      
      
      
      
   end generate GEN_DELAY_REG;
  
  

   ------------------------------------------------------------
   -- For Generate
   --
   -- Label: GEN_OUTPUT_REG
   --
   -- For Generate Description:
   --
   --   Implements a programble number of output register slices
   --
   --
   ------------------------------------------------------------
   GEN_OUTPUT_REG : for slice_index in 0 to NUM_BYTE_LANES-1 generate
   
   begin
   
      
       -------------------------------------------------------------
       -- Synchronous Process with Sync Reset
       --
       -- Label: DO_OUTREG_SLICE
       --
       -- Process Description:
       --  Implement a single register slice 
       --
       -------------------------------------------------------------
       DO_OUTREG_SLICE : process (dre_clk)
          begin
            if (dre_clk'event and dre_clk = '1') then
               if (dre_rst = '1'    or                                              -- clear on reset or if
                  (sig_output_xfer         = '1' and                                -- the output is being transfered and
                   sig_final_mux_bus(slice_index)(SLICE_STROBE_INDEX) = '0')) then  -- no new valid data id being loaded
                 
                 sig_output_data_reg(slice_index) <= ZEROED_SLICE; 
               
               elsif (sig_final_mux_bus(slice_index)(SLICE_STROBE_INDEX) = '1' and
                      sig_advance_pipe_data   = '1') then
                 
                 sig_output_data_reg(slice_index) <= sig_final_mux_bus(slice_index);
                 
               else
                 null; -- don't change state
               end if; 
            end if;       
          end process DO_OUTREG_SLICE; 
      
      
      
      
   end generate GEN_OUTPUT_REG;
  
  

   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: GEN_TVALID
   --
   -- Process Description:
   --   This sync process generates the Write request for the
   -- destination interface.
   --
   -------------------------------------------------------------
   GEN_TVALID : process (dre_clk)
      begin
        if (dre_clk'event and dre_clk = '1') then
           if (dre_rst        = '1') then

             sig_dre_tvalid_i <= '0';

           elsif (sig_advance_pipe_data = '1') then

              
              sig_dre_tvalid_i <= sig_final_mux_bus(NUM_BYTE_LANES-1)(SLICE_STROBE_INDEX) or -- MS Strobe is set or
                                  sig_final_mux_has_tlast;   -- the Last data beat of a packet
          
           Elsif (dre_out_tready   = '1' and    -- a completed write but no
                  sig_dre_tvalid_i = '1') Then  -- new input data so clear
                                                -- until more input data shows up
              sig_dre_tvalid_i <= '0';
          
           else
             null; -- hold state
           end if;
--        else
--          null;
        end if;
      end process GEN_TVALID;


   -------------------------------------------------------------
   -- Synchronous Process with Sync Reset
   --
   -- Label: GEN_TLAST_OUT
   --
   -- Process Description:
   --   This sync process generates the TLAST output for the
   -- destination interface.
   --
   -------------------------------------------------------------
   GEN_TLAST_OUT : process (dre_clk)
      begin
        if (dre_clk'event and dre_clk = '1') then
           if (dre_rst        = '1') then

             sig_tlast_out <= '0';

           elsif (sig_advance_pipe_data = '1') then
              
              sig_tlast_out <= sig_final_mux_has_tlast;
          
           Elsif (dre_out_tready   = '1' and    -- a completed transfer 
                  sig_dre_tvalid_i = '1') Then  -- so clear tlast
                                               
              sig_tlast_out <= '0';
          
           else
             null; -- hold state
           end if;
--        else
--          null;
        end if;
      end process GEN_TLAST_OUT;


     
     -------------------------------------------------------------------------------
     -------------------------------------------------------------------------------
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_MUXFARM_64
     --
     -- If Generate Description:
     -- Support Logic and Mux Farm for 64-bit data path case 
     --
     --
     ------------------------------------------------------------
     GEN_MUXFARM_64 : if (C_DWIDTH = 64) generate
   
         signal sig_cntl_state_64    : std_logic_vector(5 downto 0) := (others => '0');
         Signal s_case_i_64          : Integer range 0 to 7 := 0;
         Signal sig_shift_case_i     : std_logic_vector(2 downto 0) := (others => '0');
         Signal sig_shift_case_reg   : std_logic_vector(2 downto 0) := (others => '0');
         Signal sig_final_mux_sel    : std_logic_vector(7 downto 0) := (others => '0');
           
       begin
     
     
     
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: FIND_MS_STRB_SET_8
         --
         -- Process Description:
         --    This process finds the most significant asserted strobe  
         -- position. This position is used to enable the input flop    
         -- for TLAST that is associated with that byte position. The   
         -- TLAST can then flow through the DRE pipe with the last      
         -- valid byte of data.                                         
         --
         -------------------------------------------------------------
         FIND_MS_STRB_SET_8 : process (dre_in_tlast, 
                                       dre_in_tstrb,
                                       sig_tlast_strobes)
            begin
       
              sig_tlast_strobes  <= dre_in_tstrb(7 downto 0); -- makes case choice locally static
              
              
              if (dre_in_tlast = '0') then
              
                sig_tlast_enables <= "00000000";
              
              elsif (sig_tlast_strobes(7) = '1') then
              
                sig_tlast_enables <= "10000000";
              
              elsif (sig_tlast_strobes(6) = '1') then
              
                sig_tlast_enables <= "01000000";
              
              elsif (sig_tlast_strobes(5) = '1') then
              
                sig_tlast_enables <= "00100000";
              
              elsif (sig_tlast_strobes(4) = '1') then
              
                sig_tlast_enables <= "00010000";
              
              elsif (sig_tlast_strobes(3) = '1') then
              
                sig_tlast_enables <= "00001000";
              
              elsif (sig_tlast_strobes(2) = '1') then
              
                sig_tlast_enables <= "00000100";
              
              elsif (sig_tlast_strobes(1) = '1') then
              
                sig_tlast_enables <= "00000010";
              
              else
              
                sig_tlast_enables <= "00000001";
              
              end if;
              
              
            end process FIND_MS_STRB_SET_8; 
         
   
        ---------------------------------------------------------------------------------
        -- Shift Case logic
        
                               
                               
         -- The new auto-destination alignment is based on the last
         -- strobe alignment written into the output register.
         sig_next_auto_dest <= sig_current_dest_align;                      
                               
         
         -- Select the destination alignment to use                      
         sig_dest_align_i <= sig_next_auto_dest
           When (dre_use_autodest = '1')
           Else dre_dest_align;
                               
                               
                               
                               

         -- Convert shift case to sld_logic_vector
         --sig_shift_case_i <= CONV_STD_LOGIC_VECTOR(s_case_i_64, 3);
         
         sig_shift_case_i <= STD_LOGIC_VECTOR(TO_UNSIGNED(s_case_i_64, 3));
         
         

          
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_SHIFT_CASE_64
         --
         -- Process Description:
         -- Implements the DRE Control State Calculator
         --
         -------------------------------------------------------------
         DO_SHIFT_CASE_64 : process (dre_src_align   ,
                                     sig_dest_align_i,
                                     sig_cntl_state_64)
           
           -- signal sig_cntl_state_64 : std_logic_vector(5 downto 0);
           -- Signal s_case_i_64   : Integer range 0 to 7;
           
           
           begin
             
             
             sig_cntl_state_64 <= dre_src_align & sig_dest_align_i; 
               
             case sig_cntl_state_64 is
               when "000000" =>
                  s_case_i_64 <= 0;
               when "000001" => 
                  s_case_i_64 <= 7;
               when "000010" =>
                  s_case_i_64 <= 6;
               when "000011" => 
                  s_case_i_64 <= 5;
               when "000100" => 
                  s_case_i_64 <= 4;
               when "000101" => 
                  s_case_i_64 <= 3;
               when "000110" => 
                  s_case_i_64 <= 2;
               when "000111" => 
                  s_case_i_64 <= 1;
               
               when "001000" =>
                  s_case_i_64 <= 1;
               when "001001" => 
                  s_case_i_64 <= 0;
               when "001010" =>
                  s_case_i_64 <= 7;
               when "001011" => 
                  s_case_i_64 <= 6;
               when "001100" => 
                  s_case_i_64 <= 5;
               when "001101" => 
                  s_case_i_64 <= 4;
               when "001110" => 
                  s_case_i_64 <= 3;
               when "001111" => 
                  s_case_i_64 <= 2;
               
               when "010000" =>
                  s_case_i_64 <= 2;
               when "010001" => 
                  s_case_i_64 <= 1;
               when "010010" =>
                  s_case_i_64 <= 0;
               when "010011" => 
                  s_case_i_64 <= 7;
               when "010100" => 
                  s_case_i_64 <= 6;
               when "010101" => 
                  s_case_i_64 <= 5;
               when "010110" => 
                  s_case_i_64 <= 4;
               when "010111" => 
                  s_case_i_64 <= 3;
               
               when "011000" =>
                  s_case_i_64 <= 3;
               when "011001" => 
                  s_case_i_64 <= 2;
               when "011010" =>
                  s_case_i_64 <= 1;
               when "011011" => 
                  s_case_i_64 <= 0;
               when "011100" => 
                  s_case_i_64 <= 7;
               when "011101" => 
                  s_case_i_64 <= 6;
               when "011110" => 
                  s_case_i_64 <= 5;
               when "011111" => 
                  s_case_i_64 <= 4;
               
               when "100000" =>
                  s_case_i_64 <= 4;
               when "100001" => 
                  s_case_i_64 <= 3;
               when "100010" =>
                  s_case_i_64 <= 2;
               when "100011" => 
                  s_case_i_64 <= 1;
               when "100100" => 
                  s_case_i_64 <= 0;
               when "100101" => 
                  s_case_i_64 <= 7;
               when "100110" => 
                  s_case_i_64 <= 6;
               when "100111" => 
                  s_case_i_64 <= 5;
               
               when "101000" =>
                  s_case_i_64 <= 5;
               when "101001" => 
                  s_case_i_64 <= 4;
               when "101010" =>
                  s_case_i_64 <= 3;
               when "101011" => 
                  s_case_i_64 <= 2;
               when "101100" => 
                  s_case_i_64 <= 1;
               when "101101" => 
                  s_case_i_64 <= 0;
               when "101110" => 
                  s_case_i_64 <= 7;
               when "101111" => 
                  s_case_i_64 <= 6;
               
               when "110000" =>
                  s_case_i_64 <= 6;
               when "110001" => 
                  s_case_i_64 <= 5;
               when "110010" =>
                  s_case_i_64 <= 4;
               when "110011" => 
                  s_case_i_64 <= 3;
               when "110100" => 
                  s_case_i_64 <= 2;
               when "110101" => 
                  s_case_i_64 <= 1;
               when "110110" => 
                  s_case_i_64 <= 0;
               when "110111" => 
                  s_case_i_64 <= 7;
               
               when "111000" =>
                  s_case_i_64 <= 7;
               when "111001" => 
                  s_case_i_64 <= 6;
               when "111010" => 
                  s_case_i_64 <= 5;
               when "111011" => 
                  s_case_i_64 <= 4;
               when "111100" => 
                  s_case_i_64 <= 3;
               when "111101" => 
                  s_case_i_64 <= 2;
               when "111110" => 
                  s_case_i_64 <= 1;
               when "111111" => 
                  s_case_i_64 <= 0;
               
               when others => 
                  NULL;
             end case;   
         
        
           end process DO_SHIFT_CASE_64; 
         
          
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: REG_SHIFT_CASE
         --
         -- Process Description:
         --     This process registers the Shift Case output from the
         -- Shift Case Generator. This will be used to control the
         -- select inputs of the Shift Muxes for the duration of the
         -- data transfer session. If Pass Through is requested, then
         -- Shift Case 0 is forced regardless of source and destination
         -- alignment values.
         --
         -------------------------------------------------------------
         REG_SHIFT_CASE : process (dre_clk)
           begin
             if (dre_clk'event and dre_clk = '1') then

               if (dre_rst = '1') then

                 sig_shift_case_reg <= (others => '0');

               elsif (dre_new_align    = '1' and
                      sig_input_accept = '1') then
                  
                 sig_shift_case_reg <= sig_shift_case_i;
                  
               else
                 null;  -- hold state
               end if;
--             else
--               null;
             end if;
           end process REG_SHIFT_CASE;

 
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start PASS Mux Farm Design-------------------------------------------------


        -- Pass Mux Byte 0 (wire)

        -- This is a wire so.....

        sig_pass_mux_bus(0) <= sig_input_data_reg(0);


        -- Pass Mux Byte 1 (2-1 x8 Mux)

        I_MUX2_1_PASS_B1 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(                                   
              Sel    =>  sig_shift_case_reg(0)         ,  
              I0     =>  sig_input_data_reg(1)         ,  
              I1     =>  sig_input_data_reg(0)         ,  
              Y      =>  sig_pass_mux_bus(1)              
             );                                       


        -- Pass Mux Byte 2 (4-1 x8 Mux)

        I_MUX4_1_PASS_B2 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  sig_input_data_reg(2)         ,  
              I1     =>  ZEROED_SLICE                  ,  
              I2     =>  sig_input_data_reg(0)         ,  
              I3     =>  sig_input_data_reg(1)         ,  
              Y      =>  sig_pass_mux_bus(2)              
             );


        -- Pass Mux Byte 3 (4-1 x8 Mux)

        I_MUX4_1_PASS_B3 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  sig_input_data_reg(3)         ,  
              I1     =>  sig_input_data_reg(0)         ,  
              I2     =>  sig_input_data_reg(1)         ,  
              I3     =>  sig_input_data_reg(2)         ,  
              Y      =>  sig_pass_mux_bus(3)              
             );


        -- Pass Mux Byte 4 (8-1 x8 Mux)

        I_MUX8_1_PASS_B4 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0),  
              I0     =>  sig_input_data_reg(4)         ,  
              I1     =>  ZEROED_SLICE                  ,  
              I2     =>  ZEROED_SLICE                  ,  
              I3     =>  ZEROED_SLICE                  ,  
              I4     =>  sig_input_data_reg(0)         ,  
              I5     =>  sig_input_data_reg(1)         ,  
              I6     =>  sig_input_data_reg(2)         ,  
              I7     =>  sig_input_data_reg(3)         ,  
              Y      =>  sig_pass_mux_bus(4)              
             );


        -- Pass Mux Byte 5 (8-1 x8 Mux)

        I_MUX8_1_PASS_B5 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0),  
              I0     =>  sig_input_data_reg(5)         ,  
              I1     =>  ZEROED_SLICE                  ,  
              I2     =>  ZEROED_SLICE                  ,  
              I3     =>  sig_input_data_reg(0)         ,  
              I4     =>  sig_input_data_reg(1)         ,  
              I5     =>  sig_input_data_reg(2)         ,  
              I6     =>  sig_input_data_reg(3)         ,  
              I7     =>  sig_input_data_reg(4)         ,  
              Y      =>  sig_pass_mux_bus(5)              
             );


        -- Pass Mux Byte 6 (8-1 x8 Mux)

        I_MUX8_1_PASS_B6 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0),  
              I0     =>  sig_input_data_reg(6)         ,  
              I1     =>  ZEROED_SLICE                  ,  
              I2     =>  sig_input_data_reg(0)         ,  
              I3     =>  sig_input_data_reg(1)         ,  
              I4     =>  sig_input_data_reg(2)         ,  
              I5     =>  sig_input_data_reg(3)         ,  
              I6     =>  sig_input_data_reg(4)         ,  
              I7     =>  sig_input_data_reg(5)         ,  
              Y      =>  sig_pass_mux_bus(6)              
             );


        -- Pass Mux Byte 7 (8-1 x8 Mux)

        I_MUX8_1_PASS_B7 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0),  
              I0     =>  sig_input_data_reg(7)         ,  
              I1     =>  sig_input_data_reg(0)         ,  
              I2     =>  sig_input_data_reg(1)         ,  
              I3     =>  sig_input_data_reg(2)         ,  
              I4     =>  sig_input_data_reg(3)         ,  
              I5     =>  sig_input_data_reg(4)         ,  
              I6     =>  sig_input_data_reg(5)         ,  
              I7     =>  sig_input_data_reg(6)         ,  
              Y      =>  sig_pass_mux_bus(7)              
             );



        -- End PASS Mux Farm Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------


        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start Delay Mux Farm Design-------------------------------------------------


        -- Delay Mux Byte 0 (8-1 x8 Mux)

        I_MUX8_1_DLY_B0 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0) ,  
              I0     =>  ZEROED_SLICE                   ,  
              I1     =>  sig_input_data_reg(1)          ,  
              I2     =>  sig_input_data_reg(2)          ,  
              I3     =>  sig_input_data_reg(3)          ,  
              I4     =>  sig_input_data_reg(4)          ,  
              I5     =>  sig_input_data_reg(5)          ,  
              I6     =>  sig_input_data_reg(6)          ,  
              I7     =>  sig_input_data_reg(7)          ,  
              Y      =>  sig_delay_mux_bus(0)              
             );


        -- Delay Mux Byte 1 (8-1 x8 Mux)

        I_MUX8_1_DLY_B1 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0),  
              I0     =>  ZEROED_SLICE                  ,  
              I1     =>  sig_input_data_reg(2)         ,  
              I2     =>  sig_input_data_reg(3)         ,  
              I3     =>  sig_input_data_reg(4)         ,  
              I4     =>  sig_input_data_reg(5)         ,  
              I5     =>  sig_input_data_reg(6)         ,  
              I6     =>  sig_input_data_reg(7)         ,  
              I7     =>  ZEROED_SLICE                  ,  
              Y      =>  sig_delay_mux_bus(1)             
             );


        -- Delay Mux Byte 2 (8-1 x8 Mux)

        I_MUX8_1_DLY_B2 : entity axi_datamover_v5_1.axi_datamover_dre_mux8_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(2 downto 0),  
              I0     =>  ZEROED_SLICE                  ,  
              I1     =>  sig_input_data_reg(3)         ,  
              I2     =>  sig_input_data_reg(4)         ,  
              I3     =>  sig_input_data_reg(5)         ,  
              I4     =>  sig_input_data_reg(6)         ,  
              I5     =>  sig_input_data_reg(7)         ,  
              I6     =>  ZEROED_SLICE                  ,  
              I7     =>  ZEROED_SLICE                  ,  
              Y      =>  sig_delay_mux_bus(2)             
             );


        -- Delay Mux Byte 3 (4-1 x8 Mux)

        I_MUX4_1_DLY_B3 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  sig_input_data_reg(7)         ,  
              I1     =>  sig_input_data_reg(4)         ,  
              I2     =>  sig_input_data_reg(5)         ,  
              I3     =>  sig_input_data_reg(6)         ,  
              Y      =>  sig_delay_mux_bus(3)             
             );


        -- Delay Mux Byte 4 (4-1 x8 Mux)

        I_MUX4_1_DLY_B4 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  ZEROED_SLICE                  ,  
              I1     =>  sig_input_data_reg(5)         ,  
              I2     =>  sig_input_data_reg(6)         ,  
              I3     =>  sig_input_data_reg(7)         ,  
              Y      =>  sig_delay_mux_bus(4)             
             );


        -- Delay Mux Byte 5 (2-1 x8 Mux)

        I_MUX2_1_DLY_B5 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  --  : Integer := 8
             )
          port map(
              Sel    =>  sig_shift_case_reg(0), 
              I0     =>  sig_input_data_reg(7), 
              I1     =>  sig_input_data_reg(6), 
              Y      =>  sig_delay_mux_bus(5)   
             );



        -- Delay Mux Byte 6 (Wire)

        sig_delay_mux_bus(6) <= sig_input_data_reg(7);



        -- Delay Mux Byte 7 (Zeroed)

        sig_delay_mux_bus(7) <= ZEROED_SLICE;





        -- End Delay Mux Farm  Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------

        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start Final Mux Farm Design-------------------------------------------------
        



        -- Final Mux Byte 0 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B0_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 0 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B0_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(0) <= '0';
                when "001" =>
                    sig_final_mux_sel(0) <= '1';
                when "010" =>
                    sig_final_mux_sel(0) <= '1';
                when "011" =>
                    sig_final_mux_sel(0) <= '1';
                when "100" =>
                    sig_final_mux_sel(0) <= '1';
                when "101" =>
                    sig_final_mux_sel(0) <= '1';
                when "110" =>
                    sig_final_mux_sel(0) <= '1';
                when "111" =>
                    sig_final_mux_sel(0) <= '1';
                when others =>
                    sig_final_mux_sel(0) <= '0';
              end case;

           end process MUX2_1_FINAL_B0_CNTL;



        I_MUX2_1_FINAL_B0 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(0) ,  
              I0     =>  sig_input_data_reg(0),  
              I1     =>  sig_delay_data_reg(0),  
              Y      =>  sig_final_mux_bus(0)    
             );



        -- Final Mux Byte 1 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B1_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 1 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B1_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(1) <= '0';
                when "001" =>
                    sig_final_mux_sel(1) <= '1';
                when "010" =>
                    sig_final_mux_sel(1) <= '1';
                when "011" =>
                    sig_final_mux_sel(1) <= '1';
                when "100" =>
                    sig_final_mux_sel(1) <= '1';
                when "101" =>
                    sig_final_mux_sel(1) <= '1';
                when "110" =>
                    sig_final_mux_sel(1) <= '1';
                when "111" =>
                    sig_final_mux_sel(1) <= '0';
                when others =>
                    sig_final_mux_sel(1) <= '0';
              end case;

           end process MUX2_1_FINAL_B1_CNTL;



        I_MUX2_1_FINAL_B1 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(1) , 
              I0     =>  sig_pass_mux_bus(1)  , 
              I1     =>  sig_delay_data_reg(1), 
              Y      =>  sig_final_mux_bus(1)   
             );




        -- Final Mux Byte 2 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B2_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 2 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B2_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(2) <= '0';
                when "001" =>
                    sig_final_mux_sel(2) <= '1';
                when "010" =>
                    sig_final_mux_sel(2) <= '1';
                when "011" =>
                    sig_final_mux_sel(2) <= '1';
                when "100" =>
                    sig_final_mux_sel(2) <= '1';
                when "101" =>
                    sig_final_mux_sel(2) <= '1';
                when "110" =>
                    sig_final_mux_sel(2) <= '0';
                when "111" =>
                    sig_final_mux_sel(2) <= '0';
                when others =>
                    sig_final_mux_sel(2) <= '0';
              end case;

           end process MUX2_1_FINAL_B2_CNTL;



        I_MUX2_1_FINAL_B2 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(2) , 
              I0     =>  sig_pass_mux_bus(2)  , 
              I1     =>  sig_delay_data_reg(2), 
              Y      =>  sig_final_mux_bus(2)   
             );




        -- Final Mux Byte 3 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B3_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 3 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B3_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(3) <= '0';
                when "001" =>
                    sig_final_mux_sel(3) <= '1';
                when "010" =>
                    sig_final_mux_sel(3) <= '1';
                when "011" =>
                    sig_final_mux_sel(3) <= '1';
                when "100" =>
                    sig_final_mux_sel(3) <= '1';
                when "101" =>
                    sig_final_mux_sel(3) <= '0';
                when "110" =>
                    sig_final_mux_sel(3) <= '0';
                when "111" =>
                    sig_final_mux_sel(3) <= '0';
                when others =>
                    sig_final_mux_sel(3) <= '0';
              end case;

           end process MUX2_1_FINAL_B3_CNTL;



        I_MUX2_1_FINAL_B3 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(3) ,
              I0     =>  sig_pass_mux_bus(3)  ,
              I1     =>  sig_delay_data_reg(3),
              Y      =>  sig_final_mux_bus(3)  
             );




        -- Final Mux Byte 4 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B4_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 4 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B4_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(4) <= '0';
                when "001" =>
                    sig_final_mux_sel(4) <= '1';
                when "010" =>
                    sig_final_mux_sel(4) <= '1';
                when "011" =>
                    sig_final_mux_sel(4) <= '1';
                when "100" =>
                    sig_final_mux_sel(4) <= '0';
                when "101" =>
                    sig_final_mux_sel(4) <= '0';
                when "110" =>
                    sig_final_mux_sel(4) <= '0';
                when "111" =>
                    sig_final_mux_sel(4) <= '0';
                when others =>
                    sig_final_mux_sel(4) <= '0';
              end case;

           end process MUX2_1_FINAL_B4_CNTL;



        I_MUX2_1_FINAL_B4 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(4) ,
              I0     =>  sig_pass_mux_bus(4)  ,
              I1     =>  sig_delay_data_reg(4),
              Y      =>  sig_final_mux_bus(4)  
             );




        -- Final Mux Byte 5 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B5_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 5 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B5_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(5) <= '0';
                when "001" =>
                    sig_final_mux_sel(5) <= '1';
                when "010" =>
                    sig_final_mux_sel(5) <= '1';
                when "011" =>
                    sig_final_mux_sel(5) <= '0';
                when "100" =>
                    sig_final_mux_sel(5) <= '0';
                when "101" =>
                    sig_final_mux_sel(5) <= '0';
                when "110" =>
                    sig_final_mux_sel(5) <= '0';
                when "111" =>
                    sig_final_mux_sel(5) <= '0';
                when others =>
                    sig_final_mux_sel(5) <= '0';
              end case;

           end process MUX2_1_FINAL_B5_CNTL;



        I_MUX2_1_FINAL_B5 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(5) , 
              I0     =>  sig_pass_mux_bus(5)  , 
              I1     =>  sig_delay_data_reg(5), 
              Y      =>  sig_final_mux_bus(5)   
             );




        -- Final Mux Byte 6 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B6_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Byte 6 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B6_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "000" =>
                    sig_final_mux_sel(6) <= '0';
                when "001" =>
                    sig_final_mux_sel(6) <= '1';
                when "010" =>
                    sig_final_mux_sel(6) <= '0';
                when "011" =>
                    sig_final_mux_sel(6) <= '0';
                when "100" =>
                    sig_final_mux_sel(6) <= '0';
                when "101" =>
                    sig_final_mux_sel(6) <= '0';
                when "110" =>
                    sig_final_mux_sel(6) <= '0';
                when "111" =>
                    sig_final_mux_sel(6) <= '0';
                when others =>
                    sig_final_mux_sel(6) <= '0';
              end case;

           end process MUX2_1_FINAL_B6_CNTL;



        I_MUX2_1_FINAL_B6 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(6) , 
              I0     =>  sig_pass_mux_bus(6)  , 
              I1     =>  sig_delay_data_reg(6), 
              Y      =>  sig_final_mux_bus(6)   
             );



        -- Final Mux Byte 7 (wire)

        sig_final_mux_sel(7) <= '0';
        sig_final_mux_bus(7) <= sig_pass_mux_bus(7);




        -- End Final Mux Farm Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
 
 
    end generate GEN_MUXFARM_64;
 
 
 
     -------------------------------------------------------------------------------
     -------------------------------------------------------------------------------
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_MUXFARM_32
     --
     -- If Generate Description:
     -- Support Logic and Mux Farm for 32-bit data path case 
     --
     --
     ------------------------------------------------------------
     GEN_MUXFARM_32 : if (C_DWIDTH = 32) generate
         
         signal sig_cntl_state_32    : std_logic_vector(3 downto 0);
         Signal s_case_i_32          : Integer range 0 to 3;
         Signal sig_shift_case_i     : std_logic_vector(1 downto 0);
         Signal sig_shift_case_reg   : std_logic_vector(1 downto 0);
         Signal sig_final_mux_sel    : std_logic_vector(3 downto 0);
           
       begin
     
     
     
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: FIND_MS_STRB_SET_4
         --
         -- Process Description:
         --    This process finds the most significant asserted strobe  
         -- position. This position is used to enable the input flop    
         -- for TLAST that is associated with that byte position. The   
         -- TLAST can then flow through the DRE pipe with the last      
         -- valid byte of data.                                         
         --
         -------------------------------------------------------------
         FIND_MS_STRB_SET_4 : process (dre_in_tlast, 
                                       dre_in_tstrb,
                                       sig_tlast_strobes)
            begin
       
              sig_tlast_strobes  <= dre_in_tstrb(3 downto 0); -- makes case choice locally static
              
              
              if (dre_in_tlast = '0') then
              
                sig_tlast_enables <= "0000";
              
              elsif (sig_tlast_strobes(3) = '1') then
              
                sig_tlast_enables <= "1000";
              
              elsif (sig_tlast_strobes(2) = '1') then
              
                sig_tlast_enables <= "0100";
              
              elsif (sig_tlast_strobes(1) = '1') then
              
                sig_tlast_enables <= "0010";
              
              else
              
                sig_tlast_enables <= "0001";
              
              end if;
              
              
            end process FIND_MS_STRB_SET_4; 
         
 
 
        ---------------------------------------------------------------------------------
        -- Shift Case logic
        
                               
                               
         -- The new auto-destination alignment is based on the last
         -- strobe alignment written into the output register.
         sig_next_auto_dest <= sig_current_dest_align;                      
                               
         
         -- Select the destination alignment to use                      
         sig_dest_align_i <= sig_next_auto_dest
           When (dre_use_autodest = '1')
           Else dre_dest_align;
                               
                               
                               
         -- Convert shift case to sld_logic_vector
         --sig_shift_case_i <= CONV_STD_LOGIC_VECTOR(s_case_i_32, 2);
         
         sig_shift_case_i <= STD_LOGIC_VECTOR(TO_UNSIGNED(s_case_i_32, 2));
         
             
             
                               

         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_SHIFT_CASE_32
         --
         -- Process Description:
         -- Implements the DRE Control State Calculator
         --
         -------------------------------------------------------------
         DO_SHIFT_CASE_32 : process (dre_src_align   ,
                                     sig_dest_align_i,
                                     sig_cntl_state_32)
           
           begin
        
             
             
             
             sig_cntl_state_32 <= dre_src_align(1 downto 0) & sig_dest_align_i(1 downto 0); 
               
             case sig_cntl_state_32 is
               when "0000" =>
                  s_case_i_32 <= 0;
               when "0001" => 
                  s_case_i_32 <= 3;
               when "0010" =>
                  s_case_i_32 <= 2;
               when "0011" => 
                  s_case_i_32 <= 1;
               
               when "0100" =>
                  s_case_i_32 <= 1;
               when "0101" => 
                  s_case_i_32 <= 0;
               when "0110" =>
                  s_case_i_32 <= 3;
               when "0111" => 
                  s_case_i_32 <= 2;
               
               when "1000" =>
                  s_case_i_32 <= 2;
               when "1001" => 
                  s_case_i_32 <= 1;
               when "1010" =>
                  s_case_i_32 <= 0;
               when "1011" => 
                  s_case_i_32 <= 3;
               
               when "1100" =>
                  s_case_i_32 <= 3;
               when "1101" => 
                  s_case_i_32 <= 2;
               when "1110" =>
                  s_case_i_32 <= 1;
               when "1111" => 
                  s_case_i_32 <= 0;
               
               
               when others => 
                  NULL;
             end case;   
         
        
           end process DO_SHIFT_CASE_32; 
         
          
          
          
          
          
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: REG_SHIFT_CASE
         --
         -- Process Description:
         --     This process registers the Shift Case output from the
         -- Shift Case Generator. This will be used to control the
         -- select inputs of the Shift Muxes for the duration of the
         -- data transfer session. If Pass Through is requested, then
         -- Shift Case 0 is forced regardless of source and destination
         -- alignment values.
         --
         -------------------------------------------------------------
         REG_SHIFT_CASE : process (dre_clk)
           begin
             if (dre_clk'event and dre_clk = '1') then

               if (dre_rst = '1') then

                 sig_shift_case_reg <= (others => '0');

               elsif (dre_new_align    = '1' and
                      sig_input_accept = '1') then
                  
                 sig_shift_case_reg <= sig_shift_case_i;
                  
               else
                 null;  -- hold state
               end if;
--             else
--               null;
             end if;
           end process REG_SHIFT_CASE;


 
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start PASS Mux Farm Design-------------------------------------------------


        -- Pass Mux Byte 0 (wire)

        -- This is a wire so.....
        sig_pass_mux_bus(0) <= sig_input_data_reg(0);


        -- Pass Mux Byte 1 (2-1 x8 Mux)

        I_MUX2_1_PASS_B1 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(0),  
              I0     =>  sig_input_data_reg(1),  
              I1     =>  sig_input_data_reg(0),  
              Y      =>  sig_pass_mux_bus(1)     
             );


        -- Pass Mux Byte 2 (4-1 x8 Mux)

        I_MUX4_1_PASS_B2 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  sig_input_data_reg(2)         ,  
              I1     =>  ZEROED_SLICE                  ,  
              I2     =>  sig_input_data_reg(0)         ,  
              I3     =>  sig_input_data_reg(1)         ,  
              Y      =>  sig_pass_mux_bus(2)              
             );


        -- Pass Mux Byte 3 (4-1 x8 Mux)

        I_MUX4_1_PASS_B3 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  sig_input_data_reg(3)         ,  
              I1     =>  sig_input_data_reg(0)         ,  
              I2     =>  sig_input_data_reg(1)         ,  
              I3     =>  sig_input_data_reg(2)         ,  
              Y      =>  sig_pass_mux_bus(3)              
             );



        -- End PASS Mux Farm Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------


        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start Delay Mux Farm Design-------------------------------------------------



        -- Delay Mux Byte 0 (4-1 x8 Mux)

        I_MUX4_1_DLY_B4 : entity axi_datamover_v5_1.axi_datamover_dre_mux4_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(1 downto 0),  
              I0     =>  ZEROED_SLICE                  ,  
              I1     =>  sig_input_data_reg(1)         ,  
              I2     =>  sig_input_data_reg(2)         ,  
              I3     =>  sig_input_data_reg(3)         ,  
              Y      =>  sig_delay_mux_bus(0)             
             );


        -- Delay Mux Byte 1 (2-1 x8 Mux)

        I_MUX2_1_DLY_B5 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg(0),       
              I0     =>  sig_input_data_reg(3),       
              I1     =>  sig_input_data_reg(2),       
              Y      =>  sig_delay_mux_bus(1)         
             );



        -- Delay Mux Byte 2 (Wire)

        sig_delay_mux_bus(2) <= sig_input_data_reg(3);



        -- Delay Mux Byte 3 (Zeroed)

        sig_delay_mux_bus(3) <= ZEROED_SLICE;





        -- End Delay Mux Farm  Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------


        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start Final Mux Farm Design-------------------------------------------------
        



        -- Final Mux Slice 0 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B0_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Slice 0 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B0_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "00" =>
                    sig_final_mux_sel(0) <= '0';
                when "01" =>
                    sig_final_mux_sel(0) <= '1';
                when "10" =>
                    sig_final_mux_sel(0) <= '1';
                when "11" =>
                    sig_final_mux_sel(0) <= '1';
                when others =>
                    sig_final_mux_sel(0) <= '0';
              end case;

           end process MUX2_1_FINAL_B0_CNTL;



        I_MUX2_1_FINAL_B0 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(0) , 
              I0     =>  sig_pass_mux_bus(0)  , 
              I1     =>  sig_delay_data_reg(0), 
              Y      =>  sig_final_mux_bus(0)   
             );




        -- Final Mux Slice 1 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B1_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for slice 1 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B1_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "00" =>
                    sig_final_mux_sel(1) <= '0';
                when "01" =>
                    sig_final_mux_sel(1) <= '1';
                when "10" =>
                    sig_final_mux_sel(1) <= '1';
                when "11" =>
                    sig_final_mux_sel(1) <= '0';
                when others =>
                    sig_final_mux_sel(1) <= '0';
              end case;

           end process MUX2_1_FINAL_B1_CNTL;



        I_MUX2_1_FINAL_B1 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(1) ,
              I0     =>  sig_pass_mux_bus(1)  ,
              I1     =>  sig_delay_data_reg(1),
              Y      =>  sig_final_mux_bus(1)  
             );




        -- Final Mux Slice 2 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B2_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Slice 2 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B2_CNTL : process (sig_shift_case_reg)
           begin

              case sig_shift_case_reg is
                when "00" =>
                    sig_final_mux_sel(2) <= '0';
                when "01" =>
                    sig_final_mux_sel(2) <= '1';
                when "10" =>
                    sig_final_mux_sel(2) <= '0';
                when "11" =>
                    sig_final_mux_sel(2) <= '0';
                when others =>
                    sig_final_mux_sel(2) <= '0';
              end case;

           end process MUX2_1_FINAL_B2_CNTL;



        I_MUX2_1_FINAL_B2 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(2) , 
              I0     =>  sig_pass_mux_bus(2)  , 
              I1     =>  sig_delay_data_reg(2), 
              Y      =>  sig_final_mux_bus(2)   
             );



        -- Final Mux Slice 3 (wire)

        sig_final_mux_sel(3) <= '0';
        sig_final_mux_bus(3) <= sig_pass_mux_bus(3);




        -- End Final Mux Farm Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
 
 
    end generate GEN_MUXFARM_32;
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
 
     -------------------------------------------------------------------------------
     -------------------------------------------------------------------------------
     ------------------------------------------------------------
     -- If Generate
     --
     -- Label: GEN_MUXFARM_16
     --
     -- If Generate Description:
     -- Support Logic and Mux Farm for 16-bit data path case 
     --
     --
     ------------------------------------------------------------
     GEN_MUXFARM_16 : if (C_DWIDTH = 16) generate
         
         signal sig_cntl_state_16    : std_logic_vector(1 downto 0);
         Signal s_case_i_16          : Integer range 0 to 1;
         Signal sig_shift_case_i     : std_logic;
         Signal sig_shift_case_reg   : std_logic;
         Signal sig_final_mux_sel    : std_logic_vector(1 downto 0);
           
       begin
     
     
     
         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: FIND_MS_STRB_SET_2
         --
         -- Process Description:
         --    This process finds the most significant asserted strobe  
         -- position. This position is used to enable the input flop    
         -- for TLAST that is associated with that byte position. The   
         -- TLAST can then flow through the DRE pipe with the last      
         -- valid byte of data.                                         
         --
         -------------------------------------------------------------
         FIND_MS_STRB_SET_2 : process (dre_in_tlast, 
                                       dre_in_tstrb,
                                       sig_tlast_strobes)
            begin
       
              sig_tlast_strobes  <= dre_in_tstrb(1 downto 0); -- makes case choice locally static
              
              
              if (dre_in_tlast = '0') then
              
                sig_tlast_enables <= "00";
              
              elsif (sig_tlast_strobes(1) = '1') then
              
                sig_tlast_enables <= "10";
              
              else
              
                sig_tlast_enables <= "01";
              
              end if;
              
              
            end process FIND_MS_STRB_SET_2; 
         




   
   
   
   
 
 
 
 
        ---------------------------------------------------------------------------------
        -- Shift Case logic
        
                               
                               
         -- The new auto-destination alignment is based on the last
         -- strobe alignment written into the output register.
         sig_next_auto_dest <= sig_current_dest_align;                      
                               
         
         -- Select the destination alignment to use                      
         sig_dest_align_i <= sig_next_auto_dest
           When (dre_use_autodest = '1')
           Else dre_dest_align;
                               
                               
                           
         -- Convert shift case to std_logic
         sig_shift_case_i <= '1'
           When s_case_i_16 = 1
           Else '0';
         
         
                           

         -------------------------------------------------------------
         -- Combinational Process
         --
         -- Label: DO_SHIFT_CASE_16
         --
         -- Process Description:
         -- Implements the DRE Control State Calculator
         --
         -------------------------------------------------------------
         DO_SHIFT_CASE_16 : process (dre_src_align   ,
                                     sig_dest_align_i,
                                     sig_cntl_state_16)
           
           begin
        
             
             
             sig_cntl_state_16 <= dre_src_align(0) & sig_dest_align_i(0); 
               
             case sig_cntl_state_16 is
               when "00" =>
                  s_case_i_16 <= 0;
               when "01" => 
                  s_case_i_16 <= 1;
               when "10" =>
                  s_case_i_16 <= 1;
               when "11" => 
                  s_case_i_16 <= 0;
               
               when others => 
                  NULL;
             end case;   
         
        
           end process DO_SHIFT_CASE_16; 
         
          
          
          
          
          
         -------------------------------------------------------------
         -- Synchronous Process with Sync Reset
         --
         -- Label: REG_SHIFT_CASE
         --
         -- Process Description:
         --     This process registers the Shift Case output from the
         -- Shift Case Generator. This will be used to control the
         -- select inputs of the Shift Muxes for the duration of the
         -- data transfer session. If Pass Through is requested, then
         -- Shift Case 0 is forced regardless of source and destination
         -- alignment values.
         --
         -------------------------------------------------------------
         REG_SHIFT_CASE : process (dre_clk)
           begin
             if (dre_clk'event and dre_clk = '1') then

               if (dre_rst = '1') then

                 sig_shift_case_reg <= '0';

               elsif (dre_new_align    = '1' and
                      sig_input_accept = '1') then
                  
                 sig_shift_case_reg <= sig_shift_case_i;
                  
               else
                 null;  -- hold state
               end if;
--             else
--               null;
             end if;
           end process REG_SHIFT_CASE;





        
        
        
        
        
        
        
        
   
   
 
 
 
 
 
 
 
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start PASS Mux Farm Design-------------------------------------------------


        -- Pass Mux Byte 0 (wire)

        -- This is a wire so.....
        sig_pass_mux_bus(0) <= sig_input_data_reg(0);


        -- Pass Mux Byte 1 (2-1 x8 Mux)

        I_MUX2_1_PASS_B1 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_shift_case_reg,  
              I0     =>  sig_input_data_reg(1),  
              I1     =>  sig_input_data_reg(0),  
              Y      =>  sig_pass_mux_bus(1)     
             );




        -- End PASS Mux Farm Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------






        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start Delay Mux Farm Design-------------------------------------------------




        -- Delay Mux Slice 0 (Wire)

        sig_delay_mux_bus(0) <= sig_input_data_reg(1);



        -- Delay Mux Slice 1 (Zeroed)

        sig_delay_mux_bus(1) <= ZEROED_SLICE;





        -- End Delay Mux Farm  Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------








        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
        -- Start Final Mux Farm Design-------------------------------------------------
        


        -- Final Mux Slice 0 (2-1 x8 Mux)


        -------------------------------------------------------------
        -- Combinational Process
        --
        -- Label: MUX2_1_FINAL_B0_CNTL
        --
        -- Process Description:
        --  This process generates the Select Control for Slice 0 of
        -- the Final 2-1 Mux of the DRE.
        --
        -------------------------------------------------------------
        MUX2_1_FINAL_B0_CNTL : process (sig_shift_case_reg)
           begin

             case sig_shift_case_reg is
               when '0' =>
                   sig_final_mux_sel(0) <= '0';
               when others =>
                   sig_final_mux_sel(0) <= '1';
             end case;

           end process MUX2_1_FINAL_B0_CNTL;



        I_MUX2_1_FINAL_B0 : entity axi_datamover_v5_1.axi_datamover_dre_mux2_1_x_n
          generic map(
             C_WIDTH =>  SLICE_WIDTH  
             )
          port map(
              Sel    =>  sig_final_mux_sel(0) , 
              I0     =>  sig_pass_mux_bus(0)  , 
              I1     =>  sig_delay_data_reg(0), 
              Y      =>  sig_final_mux_bus(0)   
             );



        -- Final Mux Slice 1 (wire)

        sig_final_mux_sel(1) <= '0';
        sig_final_mux_bus(1) <= sig_pass_mux_bus(1);




        -- End Final Mux Farm Design---------------------------------------------------
        -------------------------------------------------------------------------------
        -------------------------------------------------------------------------------
 
 
    end generate GEN_MUXFARM_16;
 
 
 
 
 
 



end implementation;
