
/*
  Copyright (C) 2013 Adapteva, Inc.
  Contributed by Andreas Olofsson <andreas@adapteva.com>
 
   This program is free software: you can redistribute it and/or modify
  it under the terms of the GNU General Public License as published by
  the Free Software Foundation, either version 3 of the License, or
  (at your option) any later version.This program is distributed in the hope 
  that it will be useful,but WITHOUT ANY WARRANTY; without even the implied 
  warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
  GNU General Public License for more details. You should have received a copy 
  of the GNU General Public License along with this program (see the file 
  COPYING).  If not, see <http://www.gnu.org/licenses/>.
*/
/*
 ########################################################################
 EPIPHANY CONFIGURATION REGISTER
 ########################################################################
-------------------------------------------------------------
 ESYSRESET        ***Elink reset***
 [0]              0  - elink active 
                  1  - elink in reset
-------------------------------------------------------------
 ESYSCFGTX        ***Elink transmitter configuration***
 [0]              0  - link TX disable
                  1  - link TX enable
 [1]              0  - normal pass through transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - gpio mode
                  10 - reserved
                  11 - reserved
 [7:4]           Transmit control mode for eMesh
 [11:8]           0000 - No division, full speed
                  0001 - Divide by 2
                  Others - Reserved
  -------------------------------------------------------------
 ESYSCFGRX       ***Elink receiver configuration***
 [0]              0  - link RX disable
                  1  - link RX enable
 [1]              0  - normal transaction mode
                  1  - mmu mode
 [3:2]            00 - normal mode
                  01 - GPIO mode (drive rd wait pins from registers)
                  10 - loopback mode (loops TX-->RX)
                  11 - reserved
 [4]              0  - set monitor to count traffic
                  1  - set monitor to count congestion    
  -------------------------------------------------------------
 ESYSCFGCLK       ***Epiphany clock frequency setting*** 
 [3:0]            Output divider
<<<<<<< HEAD
                  0000 - Clock turned off
=======
                  000  - DC
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
                  0001 - CLKIN/64
                  0010 - CLKIN/32
                  0011 - CLKIN/16
                  0100 - CLKIN/8
                  0101 - CLKIN/4
                  0110 - CLKIN/2
                  0111 - CLKIN/1 (full speed)
                  1XXX - RESERVED
 [7:4]            PLL settings (TBD)
 -------------------------------------------------------------
 ESYSCOREID     ***CORE ID***
 [5:0]           Column ID-->default at powerup/reset             
 [11:6]          Row ID  
 -------------------------------------------------------------
 ESYSVERSION    ***Version number (read only)***
 [7:0]           Revision #, incremented in each change (match git?)
 [15:8]          Type (features included in FPGA load, same board)
 [23:16]         Board platform #
 [31:24]         Generation # (needed??)
 -------------------------------------------------------------
 ESYSDATAIN     ***Data on elink input pins
 [7:0]          rx_data[7:0]         
 [8]            tx_frame
 [9]            tx_wait_rd
 [10]           tx_wait_wr
   -------------------------------------------------------------
 ESYSDATAOUT    ***Data on eLink output pins
 [7:0]          tx_data[7:0]         
 [8]            tx_frame
 [9]            rx_wait_rd
 [10]           rx_wait_wr
 ########################################################################
 */

// These are WORD addresses
`define E_REG_SYSRESET    10'h010
`define E_REG_SYSCFGTX    10'h011
`define E_REG_SYSCFGRX    10'h012
`define E_REG_SYSCFGCLK   10'h013
`define E_REG_SYSCOREID   10'h014
`define E_REG_SYSVERSION  10'h015
`define E_REG_SYSDATAIN   10'h016
`define E_REG_SYSDATAOUT  10'h017

module ecfg (/*AUTOARG*/
   // Outputs
<<<<<<< HEAD
   mi_dout, ecfg_sw_reset, ecfg_tx_enable, ecfg_tx_mmu_mode,
   ecfg_tx_gpio_mode, ecfg_tx_ctrl_mode, ecfg_tx_clkdiv,
   ecfg_rx_enable, ecfg_rx_mmu_mode, ecfg_rx_gpio_mode,
   ecfg_rx_loopback_mode, ecfg_cclk_en, ecfg_cclk_div,
   ecfg_cclk_pllcfg, ecfg_coreid, ecfg_dataout,
   // Inputs
   param_coreid, mi_clk, mi_rst, mi_en, mi_we, mi_addr, mi_din, reset,
   ecfg_datain
=======
   mi_data_out, mi_data_sel, ecfg_sw_reset, ecfg_reset,
   ecfg_tx_enable, ecfg_tx_mmu_mode, ecfg_tx_gpio_mode,
   ecfg_tx_ctrl_mode, ecfg_tx_clkdiv, ecfg_rx_enable,
   ecfg_rx_mmu_mode, ecfg_rx_gpio_mode, ecfg_rx_loopback_mode,
   ecfg_cclk_en, ecfg_cclk_div, ecfg_cclk_pllcfg, ecfg_coreid,
   ecfg_gpio_dataout,
   // Inputs
   param_coreid, clk, hw_reset, mi_access, mi_write, mi_addr,
   mi_data_in
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
   );
   //Register file parameters

/*
 #####################################################################
 COMPILE TIME PARAMETERS 
 ######################################################################
 */
   
parameter E_VERSION = 32'h00_00_00_00;  // FPGA gen:plat:type:rev
parameter IDW    = 12;  // Elink ID (row,column coordinate)
parameter RFAW   = 12;  // Register file address width
   // NB: The BRAM interface seems to provide BYTE addresses!

   /*****************************/
   /*STATIC CONFIG SIGNALS      */
   /*****************************/
   input [IDW-1:0] param_coreid;
   
   /*****************************/
   /*SIMPLE MEMORY INTERFACE    */
   /*****************************/
<<<<<<< HEAD
   input              mi_clk;
   input              mi_rst;  // Not used
   input              mi_en;
   input              mi_we;  // Single WE, must write full words!
   input [RFAW-1:0]   mi_addr;
   input  [31:0]      mi_din;
   output [31:0]      mi_dout;
   
   input              reset;
   
=======
   input              clk;   
   input              hw_reset;
   input              mi_access;
   input              mi_write;
   input  [19:0]      mi_addr;
   input  [31:0]      mi_data_in;
   output [31:0]      mi_data_out;
   output 	      mi_data_sel;
  
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
   /*****************************/
   /*ELINK CONTROL SIGNALS      */
   /*****************************/
   //RESET
   output 	      ecfg_sw_reset;
   output 	      ecfg_reset;

   //tx
   output 	     ecfg_tx_enable;         //enable signal for TX  
   output 	     ecfg_tx_mmu_mode;       //enables MMU on transnmit path  
   output 	     ecfg_tx_gpio_mode;      //forces TX output pins to constants
   output [3:0]	     ecfg_tx_ctrl_mode;      //value for emesh ctrlmode tag
   output [3:0]      ecfg_tx_clkdiv;         //transmit clock divider

   //rx
   output 	     ecfg_rx_enable;         //enable signal for rx  
   output 	     ecfg_rx_mmu_mode;       //enables MMU on rx path  
   output 	     ecfg_rx_gpio_mode;      //forces rx wait pins to constants
   output 	     ecfg_rx_loopback_mode;  //loops back tx to rx receiver (after serdes)

   //cclk
   output 	     ecfg_cclk_en;           //cclk enable   
   output [3:0]      ecfg_cclk_div;          //cclk divider setting
   output [3:0]      ecfg_cclk_pllcfg;       //pll configuration

   //coreid
   output [11:0]     ecfg_coreid;            //core-id of fpga elink

   //gpio
<<<<<<< HEAD
   input [10:0]      ecfg_datain;           // data from elink inputs
   output [10:0]     ecfg_dataout;          //data for elink outputs {rd_wait,wr_wait,frame,data[7:0]}


   /*------------------------BODY CODE---------------------------------------*/
=======
   output [11:0]     ecfg_gpio_dataout;      //data for elink outputs {rd_wait,wr_wait,frame,data[7:0}
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
   
   //registers
   reg [11:0] 	ecfg_cfgtx_reg;
   reg [4:0] 	ecfg_cfgrx_reg;
   reg [7:0] 	ecfg_cfgclk_reg;
   reg [11:0] 	ecfg_coreid_reg;
<<<<<<< HEAD
   reg 		ecfg_reset_reg;
   reg [11:0] 	ecfg_datain_reg;
   reg [11:0] 	ecfg_dataout_reg;
   reg [31:0] 	mi_dout;
   
=======
   wire [31:0] 	ecfg_version_reg;
   reg 		ecfg_reset_reg;
   reg [11:0] 	ecfg_gpio_datain_reg;
   reg [11:0] 	ecfg_gpio_dataout_reg;
   reg [31:0] 	mi_data_out;
   reg 		mi_data_sel;

>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
   //wires
   wire 	ecfg_read;
   wire 	ecfg_write;
   wire 	ecfg_reset_match;
   wire 	ecfg_cfgtx_match;
   wire 	ecfg_cfgrx_match;
   wire 	ecfg_cfgclk_match;
   wire 	ecfg_coreid_match;
   wire 	ecfg_datain_match;
   wire 	ecfg_dataout_match;
   wire         ecfg_match;
   wire 	ecfg_regmux;
   wire [31:0] 	ecfg_reg_mux;
   wire 	ecfg_cfgtx_write;
   wire 	ecfg_cfgrx_write;
   wire 	ecfg_cfgclk_write;
   wire 	ecfg_coreid_write;
   wire 	ecfg_dataout_write;
   wire 	ecfg_rx_monitor_mode;
   wire 	ecfg_reset_write;
   
   /*****************************/
   /*ADDRESS DECODE LOGIC       */
   /*****************************/

   //read/write decode
   assign ecfg_write      = mi_en & mi_we;
   assign ecfg_read       = mi_en & ~mi_we;   

   //address match signals
   assign ecfg_reset_match     = mi_addr[RFAW-1:2]==`E_REG_SYSRESET;
   assign ecfg_cfgtx_match     = mi_addr[RFAW-1:2]==`E_REG_SYSCFGTX;
   assign ecfg_cfgrx_match     = mi_addr[RFAW-1:2]==`E_REG_SYSCFGRX;
   assign ecfg_cfgclk_match    = mi_addr[RFAW-1:2]==`E_REG_SYSCFGCLK;
   assign ecfg_coreid_match    = mi_addr[RFAW-1:2]==`E_REG_SYSCOREID;
   assign ecfg_version_match   = mi_addr[RFAW-1:2]==`E_REG_SYSVERSION;
   assign ecfg_datain_match    = mi_addr[RFAW-1:2]==`E_REG_SYSDATAIN;
   assign ecfg_dataout_match   = mi_addr[RFAW-1:2]==`E_REG_SYSDATAOUT;

   assign ecfg_match           = ecfg_reset_match   |
				 ecfg_cfgtx_match   |
				 ecfg_cfgrx_match   |
				 ecfg_cfgclk_match  |
				 ecfg_coreid_match  |
				 ecfg_version_match |
				 ecfg_datain_match  |
				 ecfg_dataout_match;
   
				
   //Write enables
   assign ecfg_reset_write     = ecfg_reset_match   & ecfg_write;
   assign ecfg_cfgtx_write     = ecfg_cfgtx_match   & ecfg_write;
   assign ecfg_cfgrx_write     = ecfg_cfgrx_match   & ecfg_write;
   assign ecfg_cfgclk_write    = ecfg_cfgclk_match  & ecfg_write;
   assign ecfg_coreid_write    = ecfg_coreid_match  & ecfg_write;
   assign ecfg_dataout_write   = ecfg_dataout_match & ecfg_write;

   
   //###########################
   //# ESYSCFGTX
   //###########################
<<<<<<< HEAD
   always @ (posedge mi_clk)
     if(reset)
=======
   always @ (posedge clk)
     if(hw_reset)
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
       ecfg_cfgtx_reg[11:0] <= 12'b0;
     else if (ecfg_cfgtx_write)
       ecfg_cfgtx_reg[11:0] <= mi_din[11:0];

   assign ecfg_tx_enable         = ecfg_cfgtx_reg[0];
   assign ecfg_tx_mmu_mode       = ecfg_cfgtx_reg[1];   
   assign ecfg_tx_gpio_mode      = ecfg_cfgtx_reg[3:2]==2'b01;
   assign ecfg_tx_ctrl_mode[3:0] = ecfg_cfgtx_reg[7:4];
   assign ecfg_tx_clkdiv[3:0]    = ecfg_cfgtx_reg[11:8];

   //###########################
   //# ESYSCFGRX
   //###########################
<<<<<<< HEAD
   always @ (posedge mi_clk)
     if(reset)
=======
   always @ (posedge clk)
     if(hw_reset)
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
       ecfg_cfgrx_reg[4:0] <= 5'b0;
     else if (ecfg_cfgrx_write)
       ecfg_cfgrx_reg[4:0] <= mi_din[4:0];

   assign ecfg_rx_enable        = ecfg_cfgrx_reg[0];
   assign ecfg_rx_mmu_mode      = ecfg_cfgrx_reg[1];   
   assign ecfg_rx_gpio_mode     = ecfg_cfgrx_reg[3:2]==2'b01;
   assign ecfg_rx_loopback_mode = ecfg_cfgrx_reg[3:2]==2'b10;
   assign ecfg_rx_monitor_mode  = ecfg_cfgrx_reg[4];

   //###########################
   //# ESYSCFGCLK
   //###########################
<<<<<<< HEAD
    always @ (posedge mi_clk)
     if(reset)
=======
    always @ (posedge clk)
     if(hw_reset)
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
       ecfg_cfgclk_reg[7:0] <= 8'b0;
     else if (ecfg_cfgclk_write)
       ecfg_cfgclk_reg[7:0] <= mi_din[7:0];

   assign ecfg_cclk_en             = ~(ecfg_cfgclk_reg[3:0]==4'b0000);   
   assign ecfg_cclk_div[3:0]       = ecfg_cfgclk_reg[3:0];
   assign ecfg_cclk_pllcfg[3:0]    = ecfg_cfgclk_reg[7:4];

   //###########################
   //# ESYSCOREID
   //###########################
<<<<<<< HEAD
   always @ (posedge mi_clk)
     if(reset)
=======
   always @ (posedge clk)
     if(hw_reset)
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
       ecfg_coreid_reg[IDW-1:0] <= param_coreid[IDW-1:0];
     else if (ecfg_coreid_write)
       ecfg_coreid_reg[IDW-1:0] <= mi_din[IDW-1:0];   
   
   assign ecfg_coreid[IDW-1:0] = ecfg_coreid_reg[IDW-1:0];

   //###########################
   //# ESYSDATAIN
   //###########################
<<<<<<< HEAD
   always @ (posedge mi_clk)
     ecfg_datain_reg <= ecfg_datain;
   
   //###########################
   //# ESYSDATAOUT
   //###########################
   always @ (posedge mi_clk)
     if(reset)
       ecfg_dataout_reg <= 'd0;   
     else if (ecfg_dataout_write)
       ecfg_dataout_reg <= mi_din[10:0];

   assign ecfg_dataout[10:0] = ecfg_dataout_reg[10:0];
=======
   always @ (posedge clk)
     if(hw_reset)
       ecfg_gpio_datain_reg[11:0] <= 12'b0;   
     else if (ecfg_datain_write)
       ecfg_gpio_datain_reg[11:0] <= mi_data_in[11:0];  

   //###########################
   //# ESYSDATAOUT
   //###########################
   always @ (posedge clk)
     if(hw_reset)
       ecfg_gpio_dataout_reg[11:0] <= 12'b0;   
     else if (ecfg_dataout_write)
       ecfg_gpio_dataout_reg[11:0] <= mi_data_in[11:0];  

   assign ecfg_gpio_dataout[11:0] = ecfg_gpio_dataout_reg[11:0];
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
   
   //###########################
   //# ESYSRESET
   //###########################
<<<<<<< HEAD
    always @ (posedge mi_clk)
      if(reset)
=======
    always @ (posedge clk)
      if(hw_reset)
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
	ecfg_reset_reg <= 1'b0;   
      else if (ecfg_reset_write)
	ecfg_reset_reg <= mi_din[0];  

   assign ecfg_sw_reset = ecfg_reset_reg;
   assign ecfg_reset    = ecfg_sw_reset | hw_reset;
   
   //###############################
   //# DATA READBACK MUX
   //###############################

<<<<<<< HEAD
=======
   assign ecfg_reg_mux[31:0] =   ({(32){ecfg_reset_match}}   & {20'b0,ecfg_cfgtx_reg[11:0]})        |
				 ({(32){ecfg_cfgtx_match}}   & {20'b0,ecfg_cfgtx_reg[11:0]})        |
				 ({(32){ecfg_cfgrx_match}}   & {27'b0,ecfg_cfgrx_reg[4:0]})         |
				 ({(32){ecfg_cfgclk_match}}  & {24'b0,ecfg_cfgclk_reg[7:0]})        |
				 ({(32){ecfg_coreid_match}}  & {20'b0,ecfg_coreid_reg[11:0]})       |
				 ({(32){ecfg_version_match}} & ecfg_version_reg[31:0])              |
				 ({(32){ecfg_datain_match}}  & {20'b0,ecfg_gpio_datain_reg[11:0]})  |
				 ({(32){ecfg_dataout_match}} & {20'b0,ecfg_gpio_dataout_reg[11:0]}) ;
      
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
   //Pipelineing readback
   always @ (posedge mi_clk)
     if(ecfg_read)
<<<<<<< HEAD
       case(mi_addr[RFAW-1:2])
         `E_REG_SYSRESET:    mi_dout <= {31'b0, ecfg_reset_reg};
         `E_REG_SYSCFGTX:    mi_dout <= {20'b0, ecfg_cfgtx_reg[11:0]};
         `E_REG_SYSCFGRX:    mi_dout <= {27'b0, ecfg_cfgrx_reg[4:0]};
         `E_REG_SYSCFGCLK:   mi_dout <= {24'b0, ecfg_cfgclk_reg[7:0]};
         `E_REG_SYSCOREID:   mi_dout <= {{(32-IDW){1'b0}}, ecfg_coreid_reg[IDW-1:0]};
         `E_REG_SYSVERSION:  mi_dout <= E_VERSION;
         `E_REG_SYSDATAIN:   mi_dout <= {20'b0, ecfg_datain_reg[11:0]};
         `E_REG_SYSDATAOUT:  mi_dout <= {20'b0, ecfg_dataout_reg[11:0]};
         default:            mi_dout <= 32'd0;
       endcase

=======
       begin
	  mi_data_out[31:0] <= ecfg_reg_mux[31:0];
	  mi_data_sel       <= ecfg_match;
       end
>>>>>>> da805cf66f92dcec518d6b91dd87cf0bfed3c168
endmodule // para_config

