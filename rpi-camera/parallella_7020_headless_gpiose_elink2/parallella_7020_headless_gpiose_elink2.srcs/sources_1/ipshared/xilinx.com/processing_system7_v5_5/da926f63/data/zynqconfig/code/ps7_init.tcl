set PCW_SILICON_VER_1_0 "0x0"
set PCW_SILICON_VER_2_0 "0x1"
set PCW_SILICON_VER_3_0 "0x2"
set APU_FREQ  % MHzToHz pcw_apu_peripheral_freqmhz %

# TAG_START PCW_DDR_INTERNAL_HASECC
proc ps7_ddr_ecc_init {} {
		#/* ECC Enabling */
		#/* Definitions for peripheral PS7_DDR_0 */
		set PS7_XPAR_PS7_DDR_0_S_AXI_BASEADDR 0x00100000
		set PS7_XPAR_PS7_DDR_0_S_AXI_HIGHADDR 0x0FFFFFFF
		set PS7_DDR_ADDR_END  [ expr { $PS7_XPAR_PS7_DDR_0_S_AXI_HIGHADDR + 1 } ]
		set PS7_DDR_ADDR_START  $PS7_XPAR_PS7_DDR_0_S_AXI_BASEADDR
		set PS7_DDR_LENGTH  [ expr { $PS7_DDR_ADDR_END - $PS7_DDR_ADDR_START} ]
		set PS7_DEVCFG_TRANSFER_MAX_LEN   0x1FFFFFFF 
		#/* Clear the ECC ERROR CODE */
		set PS7_XPS_DDR_CTRL_BASEADDR 0XF8006000
		set PS7_DDR_CHE_ECC_CONTROL_REG_OFFSET  [ expr {$PS7_XPS_DDR_CTRL_BASEADDR + 0xC4} ]
		set PS7_CLEAR_ERROR_ECC 0x3
		set PS7_PCAP_LAST_TRANSFER 1

        set LengthBytes $PS7_DDR_LENGTH
        set SourceAddr 0
        set DestAddr $PS7_XPAR_PS7_DDR_0_S_AXI_BASEADDR
        set Length 0

        while { $LengthBytes > 0} {
                if {$LengthBytes > $PS7_DEVCFG_TRANSFER_MAX_LEN } {
                  set Length $PS7_DEVCFG_TRANSFER_MAX_LEN
                } else {
                  set Length $LengthBytes
                }

                #/*
                # * Disable source address increment
                # */
                mask_write 0XF8007008 0x00000020 0x00000020


                #/*
                # * Start the Transfer
                # */
                mask_write 0XF8007080 0x00000010 0x00000010                
                mask_write 0XF8007000 0x02000000 0x02000000                

                mask_write 0XF8007018 0xFFFFFFFF [expr {$SourceAddr | $PS7_PCAP_LAST_TRANSFER}]                
                mask_write 0XF800701C 0xFFFFFFFF $DestAddr                 
                mask_write 0XF8007020 0x7FFFFFFF [expr {$Length/4}]                 
                mask_write 0XF8007024 0x7FFFFFFF [expr {$Length/4}]                 

                #/*
                # * Poll for the DMA done
                # */
                mask_poll 0XF800700C 0x00002000

                #/*
                # * Clear the PCAP status register
                # */
                #//ClearPcap_Status();
                mask_write 0XF800700C 0xFFFFFFFF 0x00000000                 

                #/*
                # * Enable source address increment
                # */
                mask_write 0XF8007008 0x00000020 0x00000000

                #/*
                # * Update source address and Length information
                # */
                set LengthBytes [expr {$LengthBytes - $Length}] 
                set DestAddr [expr {$DestAddr + $Length}]
        }

        #/*
        # * Fix for CR#656095
        # */
        mask_write $PS7_DDR_CHE_ECC_CONTROL_REG_OFFSET 0x00000003 $PS7_CLEAR_ERROR_ECC

        return 1
}
#TAG_END

# TAG_START PCW_INTERNAL_DDR_USE_LPDDR2_WORKAROUND

proc minfunc {x y} {
    if { $x < $y} {
     return $x 
    } else {
     return $y 
    }
}

proc maxfunc {x y} {
    if { $x > $y} {
     return $x 
    } else {
     return $y 
    }
}

proc abs { var } {
       if { $var < 0 } {
       set $var [expr {-$var}]
       }
       return $var;
}

proc mask_read { addr mask } {
    set curval "0x[string range [mrd $addr] end-8 end]"
    set maskedval [expr {$curval & $mask}]
    return $maskedval
}

proc bugfix3644 {r0 r3 bd0 bd3 freq} {
        # Bug fix for virage ticket 3644 12/2/11
        #   calc new ratio3 (r3) based on ratio0 (r0) and the board delays (bd)
        # We only have the r3 7lsbs, so figure out the 4 msbs.
        # rx in ratio units, bd (float) in nsec. freq in mhz.
        # will work up to 0.7inch delta between lane 0 and 3.
        #xil_printf("Bugfix STARTS r0 %d : r3 %d : bd0 %0.6f : bd3 %0.6f : freq %0.6f,  \n \r", r0,r3,bd0,bd3,freq );

        set period_ns [ expr { 1000.0 / $freq} ]
        #xil_printf(" Period %0.6f \n \r", period_ns );
        # calc boad delay delta in nsec
        set bd_delta_ns [ expr { 2.0*($bd3-$bd0) } ]
        #xil_printf(" bd_delta_ns %0.6f \n \r", bd_delta_ns);
        # convert to ratio units
        set bd_delta [ expr { int(256.0 * $bd_delta_ns / $period_ns)} ]
        #xil_printf(" bd_delta %0.6f \n \r", bd_delta);
        # compute an expected value
        set expected_r3 [ expr {$r0 + $bd_delta}]
        # limit to 7 bits
        set er3 [ expr { $expected_r3 & 0x07f} ];
        set msb [ expr {($expected_r3 >> 7) & 0x0f} ]
        # if er3 is close to r3, use the same msbs
        #xil_printf(" msb %d \n \r", msb);
        set new_r3 0
        if { [expr { [abs [ expr {$er3 - $r3} ] ] }] < 33  } {
                set new_r3 [ expr { $r3 + ($msb << 7) } ]
                #xil_printf(" new_r3 %d \n \r",new_r3);
        } else {
                # An msb bit wrap occured
                if { $r3 < $er3} {
                        # e.g. expected is 252, r3 is 4 (260), and er3 is 124 ==> need to add 128
                        set new_r3 [ expr { $r3 + ($msb << 7) + 128} ]
                        #xil_printf(" new_r3 (1)  %d \n \r",new_r3);
                } else {
                        # e.g. expected is 260, r3 is 124 (252), and er3 is 4 ==> need to sub 128
                        set new_r3 [ expr { $r3 + ($msb << 7) - 128}]
                        #xil_printf(" new_r3 (2)  %d \n \r",new_r3);
                }
        }
        set val [ maxfunc [ minfunc $new_r3 2047]  0  ]
        return $val;
}

# Workaround function to be called for lpddr2 for manual training
proc ps7_lpddr2_manual_traing_workaround {} {
        variable PCW_SILICON_VER_1_0
        variable PCW_SILICON_VER_2_0
        variable PCW_SILICON_VER_3_0

        # STEP 1:
        # As before, use zddr_driver unchanged, to provide the 95 or so address-data pairs of the register values required to initialize the DDRC, but modify
        # the very last register load to not take the DDRC out of reset by clearing bit[0] (reg_ddrc_soft_rstb) of the ddrc_ctrl register.
        # For example, the last address-data pair provided by zddr is:
        # 0xf8006000 0x81
        # And it is modified before register load to:
        # 0xf8006000 0x80
        #if (ps7_config (ps7_ddr_init_data) == -1) return -1;

        # STEP 2:
        # In preparation for even lane automatic training, disable the odd lanes by clearing the reg_phy_data_slice_in_use bit
        # in DDRC registers PHY_Config1 and PHY_Config3.

        mask_write 0XF8006118 0x7FFFFFFF 0x40000001
        mask_write 0XF800611C 0x7FFFFFFF 0x40000000
        mask_write 0XF8006120 0x7FFFFFFF 0x40000001
        mask_write 0XF8006124 0x7FFFFFFF 0x40000000
        #xil_printf("STEP 2 completes\n \r" );

        # STEP 3:
        # Run even lane automatic training by setting reg_ddrc_soft_rstb, and polling ddrc_reg_operating_mode till training is complete
        mask_write 0XF8006000 0x00000001 0x00000001
        mask_poll 0XF8006054 0x00000007
        #xil_printf("STEP 3 completes\n \r" );

        # STEP 4:
        # Read the training results for the even lanes and store them for later use.
        # The results include 2 sets of values:
        # -	Read DQS ratios
        # -	Read gate ratios
        # Get the read DQS ratios for lanes 0 and 2 from:
        # 	ddrc.reg6e_710. phy_reg_rdlvl_dqs_ratio
        # 	ddrc.reg6e_712. phy_reg_rdlvl_dqs_ratio
        # Getting the read gate ratios is a bit more complex.
        # In 2.0 silicon, the read gate ratios are read from the following fields:
        # ddrc.reg69_6a0.phy_reg_rdlvl_fifowein_ratio
        # ddrc.reg69_6a1.phy_reg_rdlvl_fifowein_ratio
        # ddrc.reg6c_6d2.phy_reg_rdlvl_fifowein_ratio
        # ddrc.reg6c_6d3.phy_reg_rdlvl_fifowein_ratio

        # fifo_we_ratio_slice_0[10:0] = {Reg_6A[9]    ,Reg_69[18:9]}
        # fifo_we_ratio_slice_1[10:0] = {Reg_6B[10:9] ,Reg_6A[18:10]}
        # fifo_we_ratio_slice_2[10:0] = {Reg_6C[11:9] ,Reg_6B[18:11]}
        # fifo_we_ratio_slice_3[10:0] = {4'b0 ,Reg_6C[18:12]}

        # Read DQS
        array set r {} 
        # Read gate ratio
        array set  d {}
        # Read raw  gate ratio
        array set  gate_ratio {}
        set r(0) [mask_read 0XF80061B8 0x3FF00000 ]
        set r(0) [expr { $r(0) >> 20 } ]
        set r(2) [mask_read 0XF80061C0 0x3FF00000 ]
        set r(2) [expr { $r(2) >> 20}]

        # Do the remapping of 11 bits because of bug 637927
        # [28:0]
        set gate_ratio(0) [ mask_read 0XF80061A4 0x1FFFFFFF ]
        set gate_ratio(1) [ mask_read 0XF80061A8 0x1FFFFFFF ]

        set sil_ver [ps_version]

        if { $sil_ver == $PCW_SILICON_VER_1_0 } {
          set gate_ratio(2) [ mask_read 0XF80061AC 0x1FFFFFFF ]
          set gate_ratio(3) [ mask_read 0XF80061B0 0x1FFFFFFF ]
        } else {
          set gate_ratio(2) [ mask_read 0XF80061B0 0x1FFFFFFF ]
          set gate_ratio(3) [ mask_read 0XF80061B4 0x1FFFFFFF ]
        }
        set gate_ratio(0) [ expr {($gate_ratio(0) & 0x0007FE00) >> 9 } ]
        set gate_ratio(1) [ expr {($gate_ratio(1) & 0x00000200) << 1 } ]
        set gate_ratio(2) [ expr {($gate_ratio(2) & 0x0007F800) >> 11 }]
        set gate_ratio(3) [ expr {($gate_ratio(3) & 0x00000E00)} ]
        #xil_printf("gate_ratio0:3  0x%x 0x%x 0x%x 0x%x \n \r", gate_ratio[0], gate_ratio[1], gate_ratio[2], gate_ratio[3]);

        set d(0) [ expr { $gate_ratio(1) + $gate_ratio(0)} ]
        set d(2) [ expr { $gate_ratio(3) + $gate_ratio(2)} ]
        #xil_printf("STEP 4 completes rd_data[0] : %d  rd_data[2] : %d   rd_dqs[0] : %d  rd_dqs[2] %d \n \r", d[0], d[2], r[0], r[2] );

        # STEP 5:
        # In preparation for odd lane automatic training, first clear reg_ddrc_soft_rstb to disable DDRC, and then disable the even lanes by clearing the
        # reg_phy_data_slice_in_use bit in DDRC registers PHY_Config0 and PHY_Config0, and re-enable the odd lanes by setting the same bit in PHY_Config1 and PHY_Config3
        mask_write 0XF8006000 0x00000001 0x00000000;
        # PHY_Config0/2
        mask_write 0XF8006118 0x00000001 0x00000000
        mask_write 0XF8006120 0x00000001 0x00000000
        mask_write 0XF800611c 0x00000001 0x00000001
        mask_write 0XF8006124 0x00000001 0x00000001
        #xil_printf("STEP 5 completes\n \r" );



        # STEP 6:
        # Run odd lane automatic training by setting reg_ddrc_soft_rstb, and polling ddrc_reg_operating_mode till training is complete
        mask_write 0XF8006000 0x00000001 0x00000001
        mask_poll 0XF8006054 0x00000007
        #xil_printf("STEP 6 completes\n \r" );

        # STEP 7:
        # Read the training results for the odd lanes and store them for later use.
        # The results include 2 sets of values:
        # -	Read DQS ratios
        # -	Read gate ratios
        # Get the read DQS ratios for lanes 1 and 3 from:
        # 	ddrc.reg6e_711. phy_reg_rdlvl_dqs_ratio
        # 	ddrc.reg6e_713. phy_reg_rdlvl_dqs_ratio
        # To get the read gate ratios for lanes 1 and 3 do:
        # 1.	Read the ?raw? read gate ratios for all lanes
        # 2.	Use the remapping procedure above to rearrange the bits and get the correct 11-bit values for lane 1, and the 7 lsb for lane 3
        # 3.	Use the ?bugfix3644? procedure documented below to recover the 4 missing msb for lane 3.
        # 4.	Store the results for later use.
        #[29:20]
        set r(1) [ mask_read 0XF80061BC 0x3FF00000]
        set r(1) [ expr { $r(1) >> 20} ] 
        set r(3) [ mask_read 0XF80061C4 0x3FF00000 ]
        set r(3) [ expr { $r(3) >> 20} ] 

        # Do the remapping of 11 bits because of bug 637927
        set gate_ratio(0) [ mask_read 0XF80061A4 0x1FFFFFFF ]
        set gate_ratio(1) [ mask_read 0XF80061A8 0x1FFFFFFF ]

        if { $sil_ver == $PCW_SILICON_VER_1_0 } {
          set gate_ratio(2) [ mask_read 0XF80061AC 0x1FFFFFFF ]
          set gate_ratio(3) [ mask_read 0XF80061B0 0x1FFFFFFF ]
        } else {
          set gate_ratio(2) [ mask_read 0XF80061B0 0x1FFFFFFF ]
          set gate_ratio(3) [ mask_read 0XF80061B4 0x1FFFFFFF ]
        }

        set gate_ratio(1) [ expr { ($gate_ratio(1) & 0x0007FC00) >> 10 } ]
        set gate_ratio(2) [ expr { ($gate_ratio(2) & 0x00000600) } ]
        set gate_ratio(3) [ expr { ($gate_ratio(3) & 0x0007F000) >> 12 } ]
        #xil_printf("gate_ratio0:3  0x%x 0x%x 0x%x 0x%x \n \r", gate_ratio[0], gate_ratio[1], gate_ratio[2], gate_ratio[3]);
        set d(1) [ expr {  $gate_ratio(2) + $gate_ratio(1) } ]
        set d(3) $gate_ratio(3)
        ##xil_printf("d[1] d[3] 0x%x 0x%x \n \r", d[1] ,d[3] );

        set freq  % pcw_uiparam_ddr_freq_mhz %
        set bd0  % pcw_uiparam_ddr_board_delay0 %
        set bd3  % pcw_uiparam_ddr_board_delay3 %
        #xil_printf("STEP 7 completes rd_data[1] : %d  rd_data[3] : %d   rd_dqs[1] : %d  rd_dqs[3] %d \n \r", d[1], d[3], r[1], r[3] );

        set d(3) [ bugfix3644 $d(0) $d(3) $bd0 $bd3 $freq ]
        #xil_printf("Bugfix completes 0x%x \n \r", d[3] );

        # STEP 8:
        # In preparation for the final manual setting, first clear reg_ddrc_soft_rstb to disable DDRC, and then re-enable all the slices by
        # setting the reg_phy_data_slice_in_use bit in DDRC registers PHY_Config0/1/2/3
        mask_write 0XF8006000 0x00000001 0x00000000
        mask_write 0XF8006118 0x00000001 0x00000001
        mask_write 0XF800611c 0x00000001 0x00000001
        mask_write 0XF8006120 0x00000001 0x00000001
        mask_write 0XF8006124 0x00000001 0x00000001
        #xil_printf("STEP 8 completes\n \r" );

        # STEP 9:
        # Modify 6 bits in 2 registers to switch from automatic training to manual setting. The fields to be modified are:
        # reg_2c.reg_ddrc_dfi_rd_data_eye_train
        # reg_2c.reg_ddrc_dfi_rd_dqs_gate_level
        # reg_2c.reg_ddrc_dfi_wr_level_en
        # reg_65.reg_phy_use_rd_data_eye_level
        # reg_65.reg_phy_use_rd_dqs_gate_level
        # reg_65.reg_phy_use_wr_level
        # All 6 bits should be set to 0 (the write leveling bits should already be 0 since LPDDR2 does not support write leveling)
        mask_write 0XF80060B0 0x1C000000 0x00000000
        mask_write 0XF8006194 0x0001C000 0x00000000
        #xil_printf("STEP 9 completes\n \r" );

        # STEP 10:
        # Load the automatic training results into the manual setting slave_ratio registers as detailed below.
        # Load the read DQS values for all lanes into these registers
        # ddrc.phy_rd_dqs_cfg0.reg_phy_rd_dqs_slave_ratio
        # ddrc.phy_rd_dqs_cfg1.reg_phy_rd_dqs_slave_ratio
        # ddrc.phy_rd_dqs_cfg2.reg_phy_rd_dqs_slave_ratio
        # ddrc.phy_rd_dqs_cfg3.reg_phy_rd_dqs_slave_ratio
        # Load the sum of read gate value and read DQS value for all lanes into these registers
        # 	ddrc.phy_we_cfg0.reg_phy_fifo_we_slave_ratio
        # 	ddrc.phy_we_cfg1.reg_phy_fifo_we_slave_ratio
        # 	ddrc.phy_we_cfg2.reg_phy_fifo_we_slave_ratio
        # 	ddrc.phy_we_cfg3.reg_phy_fifo_we_slave_ratio
        # Note that the value loaded into each of the above 4 registers is the sum of the read DQS and read gate values (per lane) that were captured in previous steps
        # Name Relative Address
        #phy_rd_dqs_cfg0 0xf8006140
        #phy_rd_dqs_cfg1 0xf8006144
        #phy_rd_dqs_cfg2 0xf8006148
        #phy_rd_dqs_cfg3 0xf800614c
        mask_write 0XF8006140 0x000003FF $r(0)
        mask_write 0XF8006144 0x000003FF $r(1)
        mask_write 0XF8006148 0x000003FF $r(2)
        mask_write 0XF800614C 0x000003FF $r(3)

        #phy_we_cfg0 0xf8006168
        #phy_we_cfg1 0xf800616c
        #phy_we_cfg2 0xf8006170
        #phy_we_cfg3 0xf8006174
        mask_write 0XF8006168 0x000007FF [expr { $r(0) + $d(0)} ]
        mask_write 0XF800616C 0x000007FF [expr { $r(1) + $d(1)} ]
        mask_write 0XF8006170 0x000007FF [expr { $r(2) + $d(2)} ]
        mask_write 0XF8006174 0x000007FF [expr { $r(3) + $d(3)} ]
        #xil_printf("STEP 10 completes\n \r" );

        # STEP 11:
        # Enable the DDRC by setting the reg_ddrc_soft_rstb bit, and poll ddrc_reg_operating_mode till initialization is complete. This completes the workaround procedure.
        # The indication of a successful completion is an error-free memory test. Also, comparing the resulting slave ratios to those computed by a pure manual setting using
        # zddr alone, should show only minor value differences
        mask_write 0XF8006000 0x00000001 0x00000001
        mask_poll 0XF8006054 0x00000007
        #xil_printf("STEP 11 completes\n \r" );
        #Lock

        return 1;
}

# TAG_END 

proc mask_poll { addr mask } {
    set count 1
    set curval "0x[string range [mrd $addr] end-8 end]"
    set maskedval [expr {$curval & $mask}]
    while { $maskedval == 0 } {
        set curval "0x[string range [mrd $addr] end-8 end]"
        set maskedval [expr {$curval & $mask}]
        set count [ expr { $count + 1 } ]
        if { $count == 100000000 } {
          puts "Timeout Reached. Mask poll failed at ADDRESS: $addr MASK: $mask"
          break
        }
    }
}



proc mask_delay { addr val } {
    set delay  [ get_number_of_cycles_for_delay $val ]
    perf_reset_and_start_timer
    set curval "0x[string range [mrd $addr] end-8 end]"
    set maskedval [expr {$curval < $delay}]
    while { $maskedval == 1 } {
        set curval "0x[string range [mrd $addr] end-8 end]"
        set maskedval [expr {$curval < $delay}]
    }
    perf_reset_clock 
}

proc ps_version { } {
    set si_ver "0x[string range [mrd 0xF8007080] end-8 end]"
    set mask_sil_ver "0x[expr {$si_ver >> 28}]"
    return $mask_sil_ver;
}

proc ps7_post_config {} {
    variable PCW_SILICON_VER_1_0
    variable PCW_SILICON_VER_2_0
    variable PCW_SILICON_VER_3_0
    set sil_ver [ps_version]

    if { $sil_ver == $PCW_SILICON_VER_1_0} {
        ps7_post_config_1_0   
    } elseif { $sil_ver == $PCW_SILICON_VER_2_0 } {
        ps7_post_config_2_0   
    } else {
        ps7_post_config_3_0   
    }
}

proc ps7_debug {} {
    variable PCW_SILICON_VER_1_0
    variable PCW_SILICON_VER_2_0
    variable PCW_SILICON_VER_3_0
    set sil_ver [ps_version]

    if { $sil_ver == $PCW_SILICON_VER_1_0} {
        ps7_debug_1_0   
    } elseif { $sil_ver == $PCW_SILICON_VER_2_0 } {
        ps7_debug_2_0   
    } else {
        ps7_debug_3_0   
    }
}

proc ps7_init {} {
    variable PCW_SILICON_VER_1_0
    variable PCW_SILICON_VER_2_0
    variable PCW_SILICON_VER_3_0
    set sil_ver [ps_version]

    if { $sil_ver == $PCW_SILICON_VER_1_0} {
            ps7_mio_init_data_1_0
            ps7_pll_init_data_1_0
            ps7_clock_init_data_1_0
            ps7_ddr_init_data_1_0
# TAG_START PCW_INTERNAL_DDR_USE_LPDDR2_WORKAROUND
            ps7_lpddr2_manual_traing_workaround   
# TAG_END  
# TAG_START PCW_DDR_INTERNAL_HASECC
            ps7_ddr_ecc_init
# TAG_END  
            ps7_peripherals_init_data_1_0
            #puts "PCW Silicon Version : 1.0"
    } elseif { $sil_ver == $PCW_SILICON_VER_2_0 } {
            ps7_mio_init_data_2_0
            ps7_pll_init_data_2_0
            ps7_clock_init_data_2_0
            ps7_ddr_init_data_2_0
# TAG_START PCW_INTERNAL_DDR_USE_LPDDR2_WORKAROUND
            ps7_lpddr2_manual_traing_workaround   
# TAG_END  
# TAG_START PCW_DDR_INTERNAL_HASECC
            ps7_ddr_ecc_init
# TAG_END  
            ps7_peripherals_init_data_2_0
            #puts "PCW Silicon Version : 2.0"
    } else {
            ps7_mio_init_data_3_0
            ps7_pll_init_data_3_0
            ps7_clock_init_data_3_0
            ps7_ddr_init_data_3_0
# TAG_START PCW_INTERNAL_DDR_USE_LPDDR2_WORKAROUND
            ps7_lpddr2_manual_traing_workaround   
# TAG_END 
# TAG_START PCW_DDR_INTERNAL_HASECC
            ps7_ddr_ecc_init
# TAG_END  
            ps7_peripherals_init_data_3_0
            #puts "PCW Silicon Version : 3.0"
    }
}


# For delay calculation using global timer 

# start timer 
 proc perf_start_clock { } {

    #writing SCU_GLOBAL_TIMER_CONTROL register

    mask_write 0xF8F00208 0x00000109 0x00000009
}

# stop timer and reset timer count regs 
 proc perf_reset_clock { } {
	perf_disable_clock
    mask_write 0xF8F00200 0xFFFFFFFF 0x00000000
    mask_write 0xF8F00204 0xFFFFFFFF 0x00000000
}

# Compute mask for given delay in miliseconds
proc get_number_of_cycles_for_delay { delay } {

  # GTC is always clocked at 1/2 of the CPU frequency (CPU_3x2x)
  variable APU_FREQ
  return [ expr ($delay * $APU_FREQ /(2 * 1000))]
}


# stop timer 
proc perf_disable_clock {} {
    mask_write 0xF8F00208 0xFFFFFFFF 0x00000000 
}

proc perf_reset_and_start_timer {} {
  	    perf_reset_clock 
	    perf_start_clock 
}


