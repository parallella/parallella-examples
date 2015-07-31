
#include "xil_io.h"
#define PS7_MASK_POLL_TIME 100000000

char*
getPS7MessageInfo(unsigned key) {

  char* err_msg = "";
  switch (key) {
    case PS7_INIT_SUCCESS:                  err_msg = "PS7 initialization successful"; break;
    case PS7_INIT_CORRUPT:                  err_msg = "PS7 init Data Corrupted"; break;
    case PS7_INIT_TIMEOUT:                  err_msg = "PS7 init mask poll timeout"; break;
    case PS7_POLL_FAILED_DDR_INIT:          err_msg = "Mask Poll failed for DDR Init"; break;
    case PS7_POLL_FAILED_DMA:               err_msg = "Mask Poll failed for PLL Init"; break;
    case PS7_POLL_FAILED_PLL:               err_msg = "Mask Poll failed for DMA done bit"; break;
    default:                                err_msg = "Undefined error status"; break;
  }
  
  return err_msg;  
}

unsigned long
ps7GetSiliconVersion () {
  // Read PS version from MCTRL register [31:28]
  unsigned long mask = 0xF0000000;
  unsigned long *addr = (unsigned long*) 0XF8007080;    
  unsigned long ps_version = (*addr & mask) >> 28;
  return ps_version;
}

void mask_write (unsigned long add , unsigned long  mask, unsigned long val ) {
        unsigned long *addr = (unsigned long*) add;
        *addr = ( val & mask ) | ( *addr & ~mask);
        //xil_printf("MaskWrite : 0x%x--> 0x%x \n \r" ,add, *addr);
}


int mask_poll(unsigned long add , unsigned long mask ) {
        volatile unsigned long *addr = (volatile unsigned long*) add;
        int i = 0;
        while (!(*addr & mask)) {
          if (i == PS7_MASK_POLL_TIME) {
            return -1;
          }
          i++;
        }
     return 1;   
        //xil_printf("MaskPoll : 0x%x --> 0x%x \n \r" , add, *addr);
}

unsigned long mask_read(unsigned long add , unsigned long mask ) {
        unsigned long *addr = (unsigned long*) add;
        unsigned long val = (*addr & mask);
        //xil_printf("MaskRead : 0x%x --> 0x%x \n \r" , add, val);
        return val;
}

# TAG_START PCW_DDR_INTERNAL_HASECC
/* ECC Enabling */
/* Definitions for peripheral PS7_DDR_0 */
#define PS7_XPAR_PS7_DDR_0_S_AXI_BASEADDR 0x00100000
#define PS7_XPAR_PS7_DDR_0_S_AXI_HIGHADDR % pcw_ddr_ram_highaddr %
#define PS7_DDR_ADDR_END  PS7_XPAR_PS7_DDR_0_S_AXI_HIGHADDR + 1
#define PS7_DDR_ADDR_START  PS7_XPAR_PS7_DDR_0_S_AXI_BASEADDR
#define PS7_DDR_LENGTH  (PS7_DDR_ADDR_END - PS7_DDR_ADDR_START)
#define PS7_DEVCFG_TRANSFER_MAX_LEN   0x1FFFFFFF /* Up to 512MB data */
/* Clear the ECC ERROR CODE */
#define PS7_XPS_DDR_CTRL_BASEADDR 0XF8006000
#define PS7_DDR_CHE_ECC_CONTROL_REG_OFFSET  (PS7_XPS_DDR_CTRL_BASEADDR + 0xC4)
#define PS7_CLEAR_ERROR_ECC 0x3
#define PS7_PCAP_LAST_TRANSFER 1


int ps7_ddr_ecc_init(void)
{

        unsigned long LengthBytes = PS7_DDR_LENGTH;
        unsigned long SourceAddr = 0;
        unsigned long DestAddr = PS7_XPAR_PS7_DDR_0_S_AXI_BASEADDR;
        unsigned long Length = 0;

        while(LengthBytes > 0) {
                if(LengthBytes > PS7_DEVCFG_TRANSFER_MAX_LEN) {
                        Length = PS7_DEVCFG_TRANSFER_MAX_LEN;
                } else {
                        Length = LengthBytes;
                }

                /*
                 * Disable source address increment
                 */
                 mask_write (0XF8007008, 0x00000020U, 0x00000020);

                /*
                 * Start the Transfer
                 */
               /* Status = XDcfg_Transfer(DcfgInstPtr,
                                (u8 *)(SourceAddr | PCAP_LAST_TRANSFER),
                                Length/4,
                                (u8 *)(SourceAddr),
                                Length/4, XDCFG_CONCURRENT_NONSEC_READ_WRITE);*/
                mask_write (0XF8007080, 0x00000010U, 0x00000010U);                
                mask_write (0XF8007000, 0x02000000U, 0x02000000U);                

                mask_write (0XF8007018, 0xFFFFFFFFU, (SourceAddr | PS7_PCAP_LAST_TRANSFER) );                
                mask_write (0XF800701C, 0xFFFFFFFFU, DestAddr );                
                mask_write (0XF8007020, 0x7FFFFFFFU, Length/4 );                
                mask_write (0XF8007024, 0x7FFFFFFFU, Length/4 );                

                /*
                 * Check the status of the transfer
                 */

                /*
                 * Poll for the DMA done
                 */
                 if (mask_poll(0XF800700C, 0x00002000U) == -1)
                  return PS7_POLL_FAILED_DMA;

                /*
                 * Clear the PCAP status register
                 */
                //ClearPcap_Status();
                mask_write (0XF800700C, 0xFFFFFFFFU, 0x00000000 );                

                /*
                 * Enable source address increment
                 */
                 mask_write (0XF8007008, 0x00000020U, 0x00000000);

                /*
                 * Update source address and Length information
                 */
                LengthBytes -= Length;
                DestAddr += Length;
        }

        /*
         * Fix for CR#656095
         */
        mask_write (PS7_DDR_CHE_ECC_CONTROL_REG_OFFSET, 0x00000003U, PS7_CLEAR_ERROR_ECC);

        return PS7_INIT_SUCCESS;
}

# TAG_END 

# TAG_START PCW_INTERNAL_DDR_USE_LPDDR2_WORKAROUND
#define min(x,y) ((x) < (y) ? (x) : (y))
#define max(x,y) ((x) > (y) ? (x) : (y))
#define LPDDR2_FREQ_MHZ % pcw_uiparam_ddr_freq_mhz %
#define BOARD_DELAY_0 % pcw_uiparam_ddr_board_delay0 %
#define BOARD_DELAY_3 % pcw_uiparam_ddr_board_delay3 %
int abs(int var)
{
       if ( var < 0)
       var = -var;
       return var;
}

int bugfix3644 (int r0, int r3, float bd0, float bd3, float freq) {
        // Bug fix for virage ticket 3644 12/2/11
        //   calc new ratio3 (r3) based on ratio0 (r0) and the board delays (bd)
        // We only have the r3 7lsbs, so figure out the 4 msbs.
        // rx in ratio units, bd (float) in nsec. freq in mhz.
        // will work up to 0.7inch delta between lane 0 and 3.
        //xil_printf("Bugfix STARTS r0 %d : r3 %d : bd0 %0.6f : bd3 %0.6f : freq %0.6f,  \n \r", r0,r3,bd0,bd3,freq );
		int bd_delta = 0;
		int expected_r3 = 0;
		int er3 = 0;
		int new_r3 = 0, msb = 0 , val = 0;
		float bd_delta_ns = 0 , period_ns = 0;
        period_ns = 1000.0 / freq;
        //xil_printf(" Period %0.6f \n \r", period_ns );
        // calc boad delay delta in nsec
        bd_delta_ns = 2.0*(bd3-bd0);
        //xil_printf(" bd_delta_ns %0.6f \n \r", bd_delta_ns);
        // convert to ratio units
        bd_delta = (int)(256.0 * bd_delta_ns / period_ns);
        //xil_printf(" bd_delta %0.6f \n \r", bd_delta);
        // compute an expected value
        expected_r3 = r0 + bd_delta;
        // limit to 7 bits
        er3 = expected_r3 & 0x07f;
        msb = (expected_r3 >> 7) & 0x0f;
        // if er3 is close to r3, use the same msbs
        //xil_printf(" msb %d \n \r", msb);
        if (abs(er3 - r3) < 33) {
                new_r3 = r3 + (msb << 7);
                //xil_printf(" new_r3 %d \n \r",new_r3);
        } else {
                // An msb bit wrap occured
                if (r3 < er3){
                        // e.g. expected is 252, r3 is 4 (260), and er3 is 124 ==> need to add 128
                        new_r3 = r3 + (msb << 7) + 128;
                        //xil_printf(" new_r3 (1)  %d \n \r",new_r3);
                } else {
                        // e.g. expected is 260, r3 is 124 (252), and er3 is 4 ==> need to sub 128
                        new_r3 = r3 + (msb << 7) - 128;
                        //xil_printf(" new_r3 (2)  %d \n \r",new_r3);
                }
        }
        val = max( min(new_r3, 2047) , 0 );
        return val;
}

// Workaround function to be called for lpddr2 for manual training
int ps7_lpddr2_manual_traing_workaround() {

        int r[4]; // Read DQS
        int d[4]; // Read gate ratio
        int gate_ratio[4]; // Read gate ratio
		float freq = 0;
        float bd0 = 0;
        float bd3 = 0;
		unsigned long si_ver = 0 ;
		// STEP 1:
        // As before, use zddr_driver unchanged, to provide the 95 or so address-data pairs of the register values required to initialize the DDRC, but modify
        // the very last register load to not take the DDRC out of reset by clearing bit[0] (reg_ddrc_soft_rstb) of the ddrc_ctrl register.
        // For example, the last address-data pair provided by zddr is:
        // 0xf8006000 0x81
        // And it is modified before register load to:
        // 0xf8006000 0x80
        //if (ps7_config (ps7_ddr_init_data) == -1) return -1;

        // STEP 2:
        // In preparation for even lane automatic training, disable the odd lanes by clearing the reg_phy_data_slice_in_use bit
        // in DDRC registers PHY_Config1 and PHY_Config3.

        mask_write(0XF8006118, 0x7FFFFFFFU ,0x40000001U);
        mask_write(0XF800611C, 0x7FFFFFFFU ,0x40000000U);
        mask_write(0XF8006120, 0x7FFFFFFFU ,0x40000001U);
        mask_write(0XF8006124, 0x7FFFFFFFU ,0x40000000U);
        //xil_printf("STEP 2 completes\n \r" );

        // STEP 3:
        // Run even lane automatic training by setting reg_ddrc_soft_rstb, and polling ddrc_reg_operating_mode till training is complete
        mask_write(0XF8006000, 0x00000001U ,0x00000001U);
        if (mask_poll(0XF8006054, 0x00000007U) == -1)
          return PS7_POLL_FAILED_DDR_INIT;
        //xil_printf("STEP 3 completes\n \r" );

        // STEP 4:
        // Read the training results for the even lanes and store them for later use.
        // The results include 2 sets of values:
        // -	Read DQS ratios
        // -	Read gate ratios
        // Get the read DQS ratios for lanes 0 and 2 from:
        // 	ddrc.reg6e_710. phy_reg_rdlvl_dqs_ratio
        // 	ddrc.reg6e_712. phy_reg_rdlvl_dqs_ratio
        // Getting the read gate ratios is a bit more complex.
        // In 2.0 silicon, the read gate ratios are read from the following fields:
        // ddrc.reg69_6a0.phy_reg_rdlvl_fifowein_ratio
        // ddrc.reg69_6a1.phy_reg_rdlvl_fifowein_ratio
        // ddrc.reg6c_6d2.phy_reg_rdlvl_fifowein_ratio
        // ddrc.reg6c_6d3.phy_reg_rdlvl_fifowein_ratio

        // fifo_we_ratio_slice_0[10:0] = {Reg_6A[9]    ,Reg_69[18:9]}
        // fifo_we_ratio_slice_1[10:0] = {Reg_6B[10:9] ,Reg_6A[18:10]}
        // fifo_we_ratio_slice_2[10:0] = {Reg_6C[11:9] ,Reg_6B[18:11]}
        // fifo_we_ratio_slice_3[10:0] = {4'b0 ,Reg_6C[18:12]}

        
        r[0] = mask_read (0XF80061B8, 0x3FF00000U); // [29:20]
        r[0] = r[0] >> 20;
        r[2] = mask_read (0XF80061C0, 0x3FF00000U); // [29:20]
        r[2] = r[2] >> 20;

        //d[0] = mask_read (0XF80061A4, 0x0007FF00U); // [19:9]
        //d[2] = mask_read (0XF80061AC, 0x0007FF00U); // [19:9]
        // Do the remapping of 11 bits because of bug 637927
        gate_ratio[0] = mask_read (0XF80061A4, 0x1FFFFFFFU); // [28:0]
        gate_ratio[1] = mask_read (0XF80061A8, 0x1FFFFFFFU); // [28:0]

        si_ver = ps7GetSiliconVersion ();
        if (si_ver == PCW_SILICON_VERSION_1) {
          gate_ratio[2] = mask_read (0XF80061AC, 0x1FFFFFFFU); // [28:0]
          gate_ratio[3] = mask_read (0XF80061B0, 0x1FFFFFFFU); // [28:0]
        } else {
          gate_ratio[2] = mask_read (0XF80061B0, 0x1FFFFFFFU); // [28:0]
          gate_ratio[3] = mask_read (0XF80061B4, 0x1FFFFFFFU); // [28:0]
        }

        gate_ratio[0] = (gate_ratio[0] & 0x0007FE00U) >> 9;
        gate_ratio[1] = (gate_ratio[1] & 0x00000200U) << 1;
        //xil_printf("Gate_ratio3  0x%x \n \r", gate_ratio[3]);
        gate_ratio[2] = (gate_ratio[2] & 0x0007F800U) >> 11;
        gate_ratio[3] = (gate_ratio[3] & 0x00000E00U) ;
        //xil_printf("gate_ratio0:3  0x%x 0x%x 0x%x 0x%x \n \r", gate_ratio[0], gate_ratio[1], gate_ratio[2], gate_ratio[3]);

        d[0] = gate_ratio[1] + gate_ratio[0] ;
        d[2] = gate_ratio[3] + gate_ratio[2];
        //d[0] = (gate_ratio[1] & 0x00000200U) + (gate_ratio[0] & 0x0007FE00U);
        //d[2] = (gate_ratio[3] & 0x00000E00U) + (gate_ratio[2] & 0x0007F800U);
        //d[0] = d[0] >> 9;
        //d[2] = d[2] >> 9;
        //xil_printf("STEP 4 completes rd_data[0] : %d  rd_data[2] : %d   rd_dqs[0] : %d  rd_dqs[2] %d \n \r", d[0], d[2], r[0], r[2] );

        // STEP 5:
        // In preparation for odd lane automatic training, first clear reg_ddrc_soft_rstb to disable DDRC, and then disable the even lanes by clearing the
        // reg_phy_data_slice_in_use bit in DDRC registers PHY_Config0 and PHY_Config0, and re-enable the odd lanes by setting the same bit in PHY_Config1 and PHY_Config3
        mask_write(0XF8006000, 0x00000001U ,0x00000000U);
        // PHY_Config0/2
        mask_write(0XF8006118, 0x00000001U ,0x00000000U);
        mask_write(0XF8006120, 0x00000001U ,0x00000000U);
        mask_write(0XF800611c, 0x00000001U ,0x00000001U);
        mask_write(0XF8006124, 0x00000001U ,0x00000001U);
        //xil_printf("STEP 5 completes\n \r" );



        // STEP 6:
        // Run odd lane automatic training by setting reg_ddrc_soft_rstb, and polling ddrc_reg_operating_mode till training is complete
        mask_write(0XF8006000, 0x00000001U ,0x00000001U);
        if (mask_poll(0XF8006054, 0x00000007U) == -1)
          return PS7_POLL_FAILED_DDR_INIT;
        //xil_printf("STEP 6 completes\n \r" );

        // STEP 7:
        // Read the training results for the odd lanes and store them for later use.
        // The results include 2 sets of values:
        // -	Read DQS ratios
        // -	Read gate ratios
        // Get the read DQS ratios for lanes 1 and 3 from:
        // 	ddrc.reg6e_711. phy_reg_rdlvl_dqs_ratio
        // 	ddrc.reg6e_713. phy_reg_rdlvl_dqs_ratio
        // To get the read gate ratios for lanes 1 and 3 do:
        // 1.	Read the ?raw? read gate ratios for all lanes
        // 2.	Use the remapping procedure above to rearrange the bits and get the correct 11-bit values for lane 1, and the 7 lsb for lane 3
        // 3.	Use the ?bugfix3644? procedure documented below to recover the 4 missing msb for lane 3.
        // 4.	Store the results for later use.
        r[1] = mask_read (0XF80061BC, 0x3FF00000U); // [29:20]
        r[1] = r[1] >> 20; 
        r[3] = mask_read (0XF80061C4, 0x3FF00000U); // [29:20]
        r[3] = r[3] >> 20; 

        //d[0] = mask_read (0XF80061A4, 0x0007FF00U); // [19:9]
        //d[2] = mask_read (0XF80061AC, 0x0007FF00U); // [19:9]
        // Do the remapping of 11 bits because of bug 637927
        gate_ratio[0] = mask_read (0XF80061A4, 0x1FFFFFFFU); // [28:0]
        gate_ratio[1] = mask_read (0XF80061A8, 0x1FFFFFFFU); // [28:0]
        
        if (si_ver == PCW_SILICON_VERSION_1) {
          gate_ratio[2] = mask_read (0XF80061AC, 0x1FFFFFFFU); // [28:0]
          gate_ratio[3] = mask_read (0XF80061B0, 0x1FFFFFFFU); // [28:0]
        } else {
          gate_ratio[2] = mask_read (0XF80061B0, 0x1FFFFFFFU); // [28:0]
          gate_ratio[3] = mask_read (0XF80061B4, 0x1FFFFFFFU); // [28:0]
        }

        gate_ratio[1] = (gate_ratio[1] & 0x0007FC00U) >> 10;
        gate_ratio[2] = (gate_ratio[2] & 0x00000600U) ;
        gate_ratio[3] = (gate_ratio[3] & 0x0007F000U) >> 12 ;
        //xil_printf("gate_ratio0:3  0x%x 0x%x 0x%x 0x%x \n \r", gate_ratio[0], gate_ratio[1], gate_ratio[2], gate_ratio[3]);
        d[1] = gate_ratio[2] + gate_ratio[1];
        d[3] = gate_ratio[3];
        //d[1] = (gate_ratio[2] & 0x00000600U) + (gate_ratio[1] & 0x0007FC00U);
        //d[1] = d[1] >> 9; 
        //d[3] = (4'b0) + (gate_ratio[3] & 0x0007F000U);
        //  d[3] = (gate_ratio[3] & 0x0007F000U);
        //d[3] = d[3] >> 9; 
        ////xil_printf("d[1] d[3] 0x%x 0x%x \n \r", d[1] ,d[3] );

        freq = LPDDR2_FREQ_MHZ;
        bd0 = BOARD_DELAY_0;
        bd3 = BOARD_DELAY_3;
        //xil_printf("STEP 7 completes rd_data[1] : %d  rd_data[3] : %d   rd_dqs[1] : %d  rd_dqs[3] %d \n \r", d[1], d[3], r[1], r[3] );

        d[3] = bugfix3644 (d[0], d[3], bd0, bd3, freq);
        //xil_printf("Bugfix completes 0x%x \n \r", d[3] );

        // STEP 8:
        // In preparation for the final manual setting, first clear reg_ddrc_soft_rstb to disable DDRC, and then re-enable all the slices by
        // setting the reg_phy_data_slice_in_use bit in DDRC registers PHY_Config0/1/2/3
        mask_write(0XF8006000, 0x00000001U ,0x00000000U);
        mask_write(0XF8006118, 0x00000001U ,0x00000001U);
        mask_write(0XF800611c, 0x00000001U ,0x00000001U);
        mask_write(0XF8006120, 0x00000001U ,0x00000001U);
        mask_write(0XF8006124, 0x00000001U ,0x00000001U);
        //xil_printf("STEP 8 completes\n \r" );

        // STEP 9:
        // Modify 6 bits in 2 registers to switch from automatic training to manual setting. The fields to be modified are:
        // reg_2c.reg_ddrc_dfi_rd_data_eye_train
        // reg_2c.reg_ddrc_dfi_rd_dqs_gate_level
        // reg_2c.reg_ddrc_dfi_wr_level_en
        // reg_65.reg_phy_use_rd_data_eye_level
        // reg_65.reg_phy_use_rd_dqs_gate_level
        // reg_65.reg_phy_use_wr_level
        // All 6 bits should be set to 0 (the write leveling bits should already be 0 since LPDDR2 does not support write leveling)
        mask_write(0XF80060B0, 0x1C000000U ,0x00000000U);
        mask_write(0XF8006194, 0x0001C000U ,0x00000000U);
        //xil_printf("STEP 9 completes\n \r" );

        // STEP 10:
        // Load the automatic training results into the manual setting slave_ratio registers as detailed below.
        // Load the read DQS values for all lanes into these registers
        // ddrc.phy_rd_dqs_cfg0.reg_phy_rd_dqs_slave_ratio
        // ddrc.phy_rd_dqs_cfg1.reg_phy_rd_dqs_slave_ratio
        // ddrc.phy_rd_dqs_cfg2.reg_phy_rd_dqs_slave_ratio
        // ddrc.phy_rd_dqs_cfg3.reg_phy_rd_dqs_slave_ratio
        // Load the sum of read gate value and read DQS value for all lanes into these registers
        // 	ddrc.phy_we_cfg0.reg_phy_fifo_we_slave_ratio
        // 	ddrc.phy_we_cfg1.reg_phy_fifo_we_slave_ratio
        // 	ddrc.phy_we_cfg2.reg_phy_fifo_we_slave_ratio
        // 	ddrc.phy_we_cfg3.reg_phy_fifo_we_slave_ratio
        // Note that the value loaded into each of the above 4 registers is the sum of the read DQS and read gate values (per lane) that were captured in previous steps
        // Name Relative Address
        //phy_rd_dqs_cfg0 0xf8006140
        //phy_rd_dqs_cfg1 0xf8006144
        //phy_rd_dqs_cfg2 0xf8006148
        //phy_rd_dqs_cfg3 0xf800614c
        mask_write(0XF8006140, 0x000003FF ,r[0]);
        mask_write(0XF8006144, 0x000003FF ,r[1]);
        mask_write(0XF8006148, 0x000003FF ,r[2]);
        mask_write(0XF800614C, 0x000003FF ,r[3]);

        //phy_we_cfg0 0xf8006168
        //phy_we_cfg1 0xf800616c
        //phy_we_cfg2 0xf8006170
        //phy_we_cfg3 0xf8006174
        mask_write(0XF8006168, 0x000007FF ,r[0] + d[0]);
        mask_write(0XF800616C, 0x000007FF ,r[1] + d[1]);
        mask_write(0XF8006170, 0x000007FF ,r[2] + d[2]);
        mask_write(0XF8006174, 0x000007FF ,r[3] + d[3]);
        //xil_printf("STEP 10 completes\n \r" );

        // STEP 11:
        // Enable the DDRC by setting the reg_ddrc_soft_rstb bit, and poll ddrc_reg_operating_mode till initialization is complete. This completes the workaround procedure.
        // The indication of a successful completion is an error-free memory test. Also, comparing the resulting slave ratios to those computed by a pure manual setting using
        // zddr alone, should show only minor value differences
        mask_write(0XF8006000, 0x00000001U ,0x00000001U);
        if (mask_poll(0XF8006054, 0x00000007U) == -1)
          return PS7_POLL_FAILED_DDR_INIT;
        //xil_printf("STEP 11 completes\n \r" );
        //Lock

        return PS7_INIT_SUCCESS;


}
# TAG_END 

int
ps7_config(unsigned long * ps7_config_init) 
{
    unsigned long *ptr = ps7_config_init;

    unsigned long  opcode;            // current instruction ..
    unsigned long  args[16];           // no opcode has so many args ...
    int  numargs;           // number of arguments of this instruction
    int  j;                 // general purpose index

    volatile unsigned long *addr;         // some variable to make code readable
    unsigned long  val,mask;              // some variable to make code readable

    int finish = -1 ;           // loop while this is negative !
    int i = 0;                  // Timeout variable
    
    while( finish < 0 ) {
        numargs = ptr[0] & 0xF;
        opcode = ptr[0] >> 4;

        for( j = 0 ; j < numargs ; j ++ ) 
            args[j] = ptr[j+1];
        ptr += numargs + 1;
        
        
        switch ( opcode ) {
            
        case OPCODE_EXIT:
            finish = PS7_INIT_SUCCESS;
            break;
            
        case OPCODE_CLEAR:
            addr = (unsigned long*) args[0];
            *addr = 0;
            break;

        case OPCODE_WRITE:
            addr = (unsigned long*) args[0];
            val = args[1];
            *addr = val;
            break;

        case OPCODE_MASKWRITE:
            addr = (unsigned long*) args[0];
            mask = args[1];
            val = args[2];
            *addr = ( val & mask ) | ( *addr & ~mask);
            break;

        case OPCODE_MASKPOLL:
            addr = (unsigned long*) args[0];
            mask = args[1];
            i = 0;
            while (!(*addr & mask)) {
                if (i == PS7_MASK_POLL_TIME) {
                    finish = PS7_INIT_TIMEOUT;
                    break;
                }
                i++;
            }
            break;
        case OPCODE_MASKDELAY:
            addr = (unsigned long*) args[0];
            mask = args[1];
            int delay = get_number_of_cycles_for_delay(mask);
            perf_reset_and_start_timer(); 
            while ((*addr < delay)) {
            }
            break;
        default:
            finish = PS7_INIT_CORRUPT;
            break;
        }
    }
    return finish;
}

unsigned long *ps7_mio_init_data = ps7_mio_init_data_3_0;
unsigned long *ps7_pll_init_data = ps7_pll_init_data_3_0;
unsigned long *ps7_clock_init_data = ps7_clock_init_data_3_0;
unsigned long *ps7_ddr_init_data = ps7_ddr_init_data_3_0;
unsigned long *ps7_peripherals_init_data = ps7_peripherals_init_data_3_0;

int
ps7_post_config() 
{
  // Get the PS_VERSION on run time
  unsigned long si_ver = ps7GetSiliconVersion ();
  int ret = -1;
  if (si_ver == PCW_SILICON_VERSION_1) {
      ret = ps7_config (ps7_post_config_1_0);   
      if (ret != PS7_INIT_SUCCESS) return ret;
  } else if (si_ver == PCW_SILICON_VERSION_2) {
      ret = ps7_config (ps7_post_config_2_0);   
      if (ret != PS7_INIT_SUCCESS) return ret;
  } else {
      ret = ps7_config (ps7_post_config_3_0);
      if (ret != PS7_INIT_SUCCESS) return ret;
  }
  return PS7_INIT_SUCCESS;
}

int
ps7_debug() 
{
  // Get the PS_VERSION on run time
  unsigned long si_ver = ps7GetSiliconVersion ();
  int ret = -1;
  if (si_ver == PCW_SILICON_VERSION_1) {
      ret = ps7_config (ps7_debug_1_0);   
      if (ret != PS7_INIT_SUCCESS) return ret;
  } else if (si_ver == PCW_SILICON_VERSION_2) {
      ret = ps7_config (ps7_debug_2_0);   
      if (ret != PS7_INIT_SUCCESS) return ret;
  } else {
      ret = ps7_config (ps7_debug_3_0);
      if (ret != PS7_INIT_SUCCESS) return ret;
  }
  return PS7_INIT_SUCCESS;
}

int
ps7_init() 
{
  // Get the PS_VERSION on run time
  unsigned long si_ver = ps7GetSiliconVersion ();
  int ret;
  //int pcw_ver = 0;

  if (si_ver == PCW_SILICON_VERSION_1) {
    ps7_mio_init_data = ps7_mio_init_data_1_0;
    ps7_pll_init_data = ps7_pll_init_data_1_0;
    ps7_clock_init_data = ps7_clock_init_data_1_0;
    ps7_ddr_init_data = ps7_ddr_init_data_1_0;
    ps7_peripherals_init_data = ps7_peripherals_init_data_1_0;
    //pcw_ver = 1;

  } else if (si_ver == PCW_SILICON_VERSION_2) {
    ps7_mio_init_data = ps7_mio_init_data_2_0;
    ps7_pll_init_data = ps7_pll_init_data_2_0;
    ps7_clock_init_data = ps7_clock_init_data_2_0;
    ps7_ddr_init_data = ps7_ddr_init_data_2_0;
    ps7_peripherals_init_data = ps7_peripherals_init_data_2_0;
    //pcw_ver = 2;

  } else {
    ps7_mio_init_data = ps7_mio_init_data_3_0;
    ps7_pll_init_data = ps7_pll_init_data_3_0;
    ps7_clock_init_data = ps7_clock_init_data_3_0;
    ps7_ddr_init_data = ps7_ddr_init_data_3_0;
    ps7_peripherals_init_data = ps7_peripherals_init_data_3_0;
    //pcw_ver = 3;
  }

  // MIO init
  ret = ps7_config (ps7_mio_init_data);  
  if (ret != PS7_INIT_SUCCESS) return ret;

  // PLL init
  ret = ps7_config (ps7_pll_init_data); 
  if (ret != PS7_INIT_SUCCESS) return ret;

  // Clock init
  ret = ps7_config (ps7_clock_init_data);
  if (ret != PS7_INIT_SUCCESS) return ret;

  // DDR init
  ret = ps7_config (ps7_ddr_init_data);
  if (ret != PS7_INIT_SUCCESS) return ret;

# TAG_START PCW_INTERNAL_DDR_USE_LPDDR2_WORKAROUND
  // LPDDR2 manual workaround 
  ret = ps7_lpddr2_manual_traing_workaround();
  if (ret != PS7_INIT_SUCCESS) return ret;
# TAG_END  

# TAG_START PCW_DDR_INTERNAL_HASECC
  // DDR ECC init
  ret = ps7_ddr_ecc_init();
  if (ret != PS7_INIT_SUCCESS) return ret;
# TAG_END  

  // Peripherals init
  ret = ps7_config (ps7_peripherals_init_data);
  if (ret != PS7_INIT_SUCCESS) return ret;
  //xil_printf ("\n PCW Silicon Version : %d.0", pcw_ver);
  return PS7_INIT_SUCCESS;
}




/* For delay calculation using global timer */

/* start timer */
 void perf_start_clock(void)
{
	*(volatile unsigned int*)SCU_GLOBAL_TIMER_CONTROL = ((1 << 0) | // Timer Enable
						      (1 << 3) | // Auto-increment
						      (0 << 8) // Pre-scale
	); 
}

/* stop timer and reset timer count regs */
 void perf_reset_clock(void)
{
	perf_disable_clock();
	*(volatile unsigned int*)SCU_GLOBAL_TIMER_COUNT_L32 = 0;
	*(volatile unsigned int*)SCU_GLOBAL_TIMER_COUNT_U32 = 0;
}

/* Compute mask for given delay in miliseconds*/
int get_number_of_cycles_for_delay(unsigned int delay) 
{
  // GTC is always clocked at 1/2 of the CPU frequency (CPU_3x2x)
  return (APU_FREQ*delay/(2*1000));
   
}

/* stop timer */
 void perf_disable_clock(void)
{
	*(volatile unsigned int*)SCU_GLOBAL_TIMER_CONTROL = 0;
}

void perf_reset_and_start_timer() 
{
  	    perf_reset_clock();
	    perf_start_clock();
}




