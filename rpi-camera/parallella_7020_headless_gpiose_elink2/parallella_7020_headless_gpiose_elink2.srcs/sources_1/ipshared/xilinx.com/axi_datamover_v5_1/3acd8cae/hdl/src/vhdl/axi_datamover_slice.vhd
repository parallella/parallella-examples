--  (c) Copyright 2012 Xilinx, Inc. All rights reserved.
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
------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_misc.all;

library unisim;
use unisim.vcomponents.all;



   entity axi_datamover_slice is
   generic (
           C_DATA_WIDTH : Integer range 1 to 200 := 64
           );
   port (

   ACLK : in std_logic;
   ARESET : in std_logic;

   -- Slave side
   S_PAYLOAD_DATA : in std_logic_vector (C_DATA_WIDTH-1 downto 0);
   S_VALID : in std_logic;
   S_READY : out std_logic;

   -- Master side
   M_PAYLOAD_DATA : out std_logic_vector (C_DATA_WIDTH-1 downto 0);
   M_VALID : out std_logic;
   M_READY : in std_logic
   );
   end entity axi_datamover_slice;

   architecture working of axi_datamover_slice is
  attribute DowngradeIPIdentifiedWarnings: string;
  attribute DowngradeIPIdentifiedWarnings of working : architecture is "yes";

      signal storage_data : std_logic_vector (C_DATA_WIDTH-1 downto 0);
      signal s_ready_i : std_logic;
      signal m_valid_i : std_logic;
      signal areset_d  : std_logic_vector (1 downto 0);
   begin
      -- assign local signal to its output signal
      S_READY <= s_ready_i; 
      M_VALID <= m_valid_i;

      process (ACLK) begin
        if (ACLK'event and ACLK = '1') then
          areset_d(0) <= ARESET;
          areset_d(1) <= areset_d(0);
        end if;
      end process;

      -- Save payload data whenever we have a transaction on the slave side
      process (ACLK) begin
        if (ACLK'event and ACLK = '1') then
           if (S_VALID = '1' and s_ready_i = '1') then
              storage_data <= S_PAYLOAD_DATA;
           else
              storage_data <= storage_data;
           end if;
        end if;
      end process;

      M_PAYLOAD_DATA <= storage_data;

      -- M_Valid set to high when we have a completed transfer on slave side
      -- Is removed on a M_READY except if we have a new transfer on the slave side
      process (ACLK) begin
        if (ACLK'event and ACLK = '1') then
          if (areset_d (1) = '1') then
             m_valid_i <= '0';
          elsif (S_VALID = '1') then
             m_valid_i <= '1';
          elsif (M_READY = '1') then
             m_valid_i <= '0';
          else
             m_valid_i <= m_valid_i;
          end if; 
        end if;
      end process;

      -- Slave Ready is either when Master side drives M_Ready or we have space in our storage data
      s_ready_i <= (M_READY or (not m_valid_i)) and not (areset_d(1) or areset_d(0));
     end working;
