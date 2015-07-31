//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
//Date        : Wed Jun 24 00:24:56 2015
//Host        : lain running 64-bit Gentoo Base System release 2.2
//Command     : generate_target elink2_top.bd
//Design      : elink2_top
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module elink2_imp_1JQ28BR
   (CCLK_N,
    CCLK_P,
    DSP_RESET_N,
    EMM_TOMMU_access,
    EMM_TOMMU_ctrlmode,
    EMM_TOMMU_data,
    EMM_TOMMU_datamode,
    EMM_TOMMU_dstaddr,
    EMM_TOMMU_srcaddr,
    EMM_TOMMU_write,
    EMS_FROMMMU_access,
    EMS_FROMMMU_ctrlmode,
    EMS_FROMMMU_data,
    EMS_FROMMMU_datamode,
    EMS_FROMMMU_dstaddr,
    EMS_FROMMMU_srcaddr,
    EMS_FROMMMU_write,
    M00_AXI_araddr,
    M00_AXI_arburst,
    M00_AXI_arcache,
    M00_AXI_arid,
    M00_AXI_arlen,
    M00_AXI_arlock,
    M00_AXI_arprot,
    M00_AXI_arqos,
    M00_AXI_arready,
    M00_AXI_arsize,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awburst,
    M00_AXI_awcache,
    M00_AXI_awid,
    M00_AXI_awlen,
    M00_AXI_awlock,
    M00_AXI_awprot,
    M00_AXI_awqos,
    M00_AXI_awready,
    M00_AXI_awsize,
    M00_AXI_awvalid,
    M00_AXI_bid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rid,
    M00_AXI_rlast,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wlast,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    RX_data_n,
    RX_data_p,
    RX_frame_n,
    RX_frame_p,
    RX_lclk_n,
    RX_lclk_p,
    RX_rd_wait_n,
    RX_rd_wait_p,
    RX_wr_wait_n,
    RX_wr_wait_p,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arregion,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awregion,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid,
    S_AXI_CFG_araddr,
    S_AXI_CFG_arprot,
    S_AXI_CFG_arready,
    S_AXI_CFG_arvalid,
    S_AXI_CFG_awaddr,
    S_AXI_CFG_awprot,
    S_AXI_CFG_awready,
    S_AXI_CFG_awvalid,
    S_AXI_CFG_bready,
    S_AXI_CFG_bresp,
    S_AXI_CFG_bvalid,
    S_AXI_CFG_rdata,
    S_AXI_CFG_rready,
    S_AXI_CFG_rresp,
    S_AXI_CFG_rvalid,
    S_AXI_CFG_wdata,
    S_AXI_CFG_wready,
    S_AXI_CFG_wstrb,
    S_AXI_CFG_wvalid,
    TX_data_n,
    TX_data_p,
    TX_frame_n,
    TX_frame_p,
    TX_lclk_n,
    TX_lclk_p,
    TX_rd_wait_n,
    TX_rd_wait_p,
    TX_wr_wait_n,
    TX_wr_wait_p,
    clkin,
    m00_axi_aclk,
    m00_axi_aresetn,
    reset,
    s00_axi_aclk,
    s00_axi_aresetn,
    s_axi_aclk,
    s_axi_aresetn);
  output CCLK_N;
  output CCLK_P;
  output [0:0]DSP_RESET_N;
  output EMM_TOMMU_access;
  output [3:0]EMM_TOMMU_ctrlmode;
  output [31:0]EMM_TOMMU_data;
  output [1:0]EMM_TOMMU_datamode;
  output [31:0]EMM_TOMMU_dstaddr;
  output [31:0]EMM_TOMMU_srcaddr;
  output EMM_TOMMU_write;
  input EMS_FROMMMU_access;
  input [3:0]EMS_FROMMMU_ctrlmode;
  input [31:0]EMS_FROMMMU_data;
  input [1:0]EMS_FROMMMU_datamode;
  input [31:0]EMS_FROMMMU_dstaddr;
  input [31:0]EMS_FROMMMU_srcaddr;
  input EMS_FROMMMU_write;
  output [31:0]M00_AXI_araddr;
  output [1:0]M00_AXI_arburst;
  output [3:0]M00_AXI_arcache;
  output [0:0]M00_AXI_arid;
  output [7:0]M00_AXI_arlen;
  output [0:0]M00_AXI_arlock;
  output [2:0]M00_AXI_arprot;
  output [3:0]M00_AXI_arqos;
  input M00_AXI_arready;
  output [2:0]M00_AXI_arsize;
  output M00_AXI_arvalid;
  output [31:0]M00_AXI_awaddr;
  output [1:0]M00_AXI_awburst;
  output [3:0]M00_AXI_awcache;
  output [0:0]M00_AXI_awid;
  output [7:0]M00_AXI_awlen;
  output [0:0]M00_AXI_awlock;
  output [2:0]M00_AXI_awprot;
  output [3:0]M00_AXI_awqos;
  input M00_AXI_awready;
  output [2:0]M00_AXI_awsize;
  output M00_AXI_awvalid;
  input [0:0]M00_AXI_bid;
  output M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input M00_AXI_bvalid;
  input [63:0]M00_AXI_rdata;
  input [0:0]M00_AXI_rid;
  input M00_AXI_rlast;
  output M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input M00_AXI_rvalid;
  output [63:0]M00_AXI_wdata;
  output M00_AXI_wlast;
  input M00_AXI_wready;
  output [7:0]M00_AXI_wstrb;
  output M00_AXI_wvalid;
  input [7:0]RX_data_n;
  input [7:0]RX_data_p;
  input RX_frame_n;
  input RX_frame_p;
  input RX_lclk_n;
  input RX_lclk_p;
  output RX_rd_wait_n;
  output RX_rd_wait_p;
  output RX_wr_wait_n;
  output RX_wr_wait_p;
  input [29:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [11:0]S00_AXI_arid;
  input [7:0]S00_AXI_arlen;
  input [0:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [3:0]S00_AXI_arregion;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [29:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [11:0]S00_AXI_awid;
  input [7:0]S00_AXI_awlen;
  input [0:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [3:0]S00_AXI_awregion;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [11:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [11:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;
  input [12:0]S_AXI_CFG_araddr;
  input [2:0]S_AXI_CFG_arprot;
  output [0:0]S_AXI_CFG_arready;
  input [0:0]S_AXI_CFG_arvalid;
  input [12:0]S_AXI_CFG_awaddr;
  input [2:0]S_AXI_CFG_awprot;
  output [0:0]S_AXI_CFG_awready;
  input [0:0]S_AXI_CFG_awvalid;
  input [0:0]S_AXI_CFG_bready;
  output [1:0]S_AXI_CFG_bresp;
  output [0:0]S_AXI_CFG_bvalid;
  output [31:0]S_AXI_CFG_rdata;
  input [0:0]S_AXI_CFG_rready;
  output [1:0]S_AXI_CFG_rresp;
  output [0:0]S_AXI_CFG_rvalid;
  input [31:0]S_AXI_CFG_wdata;
  output [0:0]S_AXI_CFG_wready;
  input [3:0]S_AXI_CFG_wstrb;
  input [0:0]S_AXI_CFG_wvalid;
  output [7:0]TX_data_n;
  output [7:0]TX_data_p;
  output TX_frame_n;
  output TX_frame_p;
  output TX_lclk_n;
  output TX_lclk_p;
  input TX_rd_wait_n;
  input TX_rd_wait_p;
  input TX_wr_wait_n;
  input TX_wr_wait_p;
  input clkin;
  input m00_axi_aclk;
  input [0:0]m00_axi_aresetn;
  input [0:0]reset;
  input s00_axi_aclk;
  input [0:0]s00_axi_aresetn;
  input s_axi_aclk;
  input [0:0]s_axi_aresetn;

  wire Conn1_access;
  wire [3:0]Conn1_ctrlmode;
  wire [31:0]Conn1_data;
  wire [1:0]Conn1_datamode;
  wire [31:0]Conn1_dstaddr;
  wire [31:0]Conn1_srcaddr;
  wire Conn1_write;
  wire Conn2_access;
  wire [3:0]Conn2_ctrlmode;
  wire [31:0]Conn2_data;
  wire [1:0]Conn2_datamode;
  wire [31:0]Conn2_dstaddr;
  wire [31:0]Conn2_srcaddr;
  wire Conn2_write;
  wire [31:0]Conn3_ARADDR;
  wire [1:0]Conn3_ARBURST;
  wire [3:0]Conn3_ARCACHE;
  wire [0:0]Conn3_ARID;
  wire [7:0]Conn3_ARLEN;
  wire Conn3_ARLOCK;
  wire [2:0]Conn3_ARPROT;
  wire [3:0]Conn3_ARQOS;
  wire Conn3_ARREADY;
  wire [2:0]Conn3_ARSIZE;
  wire Conn3_ARVALID;
  wire [31:0]Conn3_AWADDR;
  wire [1:0]Conn3_AWBURST;
  wire [3:0]Conn3_AWCACHE;
  wire [0:0]Conn3_AWID;
  wire [7:0]Conn3_AWLEN;
  wire Conn3_AWLOCK;
  wire [2:0]Conn3_AWPROT;
  wire [3:0]Conn3_AWQOS;
  wire Conn3_AWREADY;
  wire [2:0]Conn3_AWSIZE;
  wire Conn3_AWVALID;
  wire [0:0]Conn3_BID;
  wire Conn3_BREADY;
  wire [1:0]Conn3_BRESP;
  wire Conn3_BVALID;
  wire [63:0]Conn3_RDATA;
  wire [0:0]Conn3_RID;
  wire Conn3_RLAST;
  wire Conn3_RREADY;
  wire [1:0]Conn3_RRESP;
  wire Conn3_RVALID;
  wire [63:0]Conn3_WDATA;
  wire Conn3_WLAST;
  wire Conn3_WREADY;
  wire [7:0]Conn3_WSTRB;
  wire Conn3_WVALID;
  wire GND_1;
  wire [7:0]RX_1_data_n;
  wire [7:0]RX_1_data_p;
  wire RX_1_frame_n;
  wire RX_1_frame_p;
  wire RX_1_lclk_n;
  wire RX_1_lclk_p;
  wire RX_1_rd_wait_n;
  wire RX_1_rd_wait_p;
  wire RX_1_wr_wait_n;
  wire RX_1_wr_wait_p;
  wire [29:0]S00_AXI_1_ARADDR;
  wire [1:0]S00_AXI_1_ARBURST;
  wire [3:0]S00_AXI_1_ARCACHE;
  wire [11:0]S00_AXI_1_ARID;
  wire [7:0]S00_AXI_1_ARLEN;
  wire [0:0]S00_AXI_1_ARLOCK;
  wire [2:0]S00_AXI_1_ARPROT;
  wire [3:0]S00_AXI_1_ARQOS;
  wire S00_AXI_1_ARREADY;
  wire [3:0]S00_AXI_1_ARREGION;
  wire [2:0]S00_AXI_1_ARSIZE;
  wire S00_AXI_1_ARVALID;
  wire [29:0]S00_AXI_1_AWADDR;
  wire [1:0]S00_AXI_1_AWBURST;
  wire [3:0]S00_AXI_1_AWCACHE;
  wire [11:0]S00_AXI_1_AWID;
  wire [7:0]S00_AXI_1_AWLEN;
  wire [0:0]S00_AXI_1_AWLOCK;
  wire [2:0]S00_AXI_1_AWPROT;
  wire [3:0]S00_AXI_1_AWQOS;
  wire S00_AXI_1_AWREADY;
  wire [3:0]S00_AXI_1_AWREGION;
  wire [2:0]S00_AXI_1_AWSIZE;
  wire S00_AXI_1_AWVALID;
  wire [11:0]S00_AXI_1_BID;
  wire S00_AXI_1_BREADY;
  wire [1:0]S00_AXI_1_BRESP;
  wire S00_AXI_1_BVALID;
  wire [31:0]S00_AXI_1_RDATA;
  wire [11:0]S00_AXI_1_RID;
  wire S00_AXI_1_RLAST;
  wire S00_AXI_1_RREADY;
  wire [1:0]S00_AXI_1_RRESP;
  wire S00_AXI_1_RVALID;
  wire [31:0]S00_AXI_1_WDATA;
  wire S00_AXI_1_WLAST;
  wire S00_AXI_1_WREADY;
  wire [3:0]S00_AXI_1_WSTRB;
  wire S00_AXI_1_WVALID;
  wire [12:0]S_AXI_REGS_1_ARADDR;
  wire [2:0]S_AXI_REGS_1_ARPROT;
  wire S_AXI_REGS_1_ARREADY;
  wire [0:0]S_AXI_REGS_1_ARVALID;
  wire [12:0]S_AXI_REGS_1_AWADDR;
  wire [2:0]S_AXI_REGS_1_AWPROT;
  wire S_AXI_REGS_1_AWREADY;
  wire [0:0]S_AXI_REGS_1_AWVALID;
  wire [0:0]S_AXI_REGS_1_BREADY;
  wire [1:0]S_AXI_REGS_1_BRESP;
  wire S_AXI_REGS_1_BVALID;
  wire [31:0]S_AXI_REGS_1_RDATA;
  wire [0:0]S_AXI_REGS_1_RREADY;
  wire [1:0]S_AXI_REGS_1_RRESP;
  wire S_AXI_REGS_1_RVALID;
  wire [31:0]S_AXI_REGS_1_WDATA;
  wire S_AXI_REGS_1_WREADY;
  wire [3:0]S_AXI_REGS_1_WSTRB;
  wire [0:0]S_AXI_REGS_1_WVALID;
  wire [0:0]aresetn_1;
  wire [12:0]axi_bram_ctrl_2_BRAM_PORTA_ADDR;
  wire axi_bram_ctrl_2_BRAM_PORTA_CLK;
  wire [31:0]axi_bram_ctrl_2_BRAM_PORTA_DIN;
  wire [31:0]axi_bram_ctrl_2_BRAM_PORTA_DOUT;
  wire axi_bram_ctrl_2_BRAM_PORTA_EN;
  wire axi_bram_ctrl_2_BRAM_PORTA_RST;
  wire [3:0]axi_bram_ctrl_2_BRAM_PORTA_WE;
  wire clkin_1;
  wire [3:0]eCfg_0_ecfg_cclk_div;
  wire eCfg_0_ecfg_cclk_en;
  wire [3:0]eCfg_0_ecfg_cclk_pllcfg;
  wire [11:0]eCfg_0_ecfg_coreid;
  wire [10:0]eCfg_0_ecfg_datain;
  wire [10:0]eCfg_0_ecfg_dataout;
  wire eCfg_0_ecfg_rx_enable;
  wire eCfg_0_ecfg_rx_gpio_mode;
  wire eCfg_0_ecfg_rx_loopback_mode;
  wire eCfg_0_ecfg_rx_mmu_mode;
  wire eCfg_0_ecfg_sw_reset;
  wire [3:0]eCfg_0_ecfg_tx_clkdiv;
  wire [3:0]eCfg_0_ecfg_tx_ctrl_mode;
  wire eCfg_0_ecfg_tx_enable;
  wire eCfg_0_ecfg_tx_gpio_mode;
  wire eCfg_0_ecfg_tx_mmu_mode;
  wire earb_0_emm_tx_access;
  wire [3:0]earb_0_emm_tx_ctrlmode;
  wire [31:0]earb_0_emm_tx_data;
  wire [1:0]earb_0_emm_tx_datamode;
  wire [31:0]earb_0_emm_tx_dstaddr;
  wire earb_0_emm_tx_rd_wait;
  wire [31:0]earb_0_emm_tx_srcaddr;
  wire earb_0_emm_tx_wr_wait;
  wire earb_0_emm_tx_write;
  wire earb_0_emrq_EMPTY;
  wire [102:0]earb_0_emrq_RD_DATA;
  wire earb_0_emrq_RD_EN;
  wire earb_0_emrr_EMPTY;
  wire [102:0]earb_0_emrr_RD_DATA;
  wire earb_0_emrr_RD_EN;
  wire earb_0_emwr_EMPTY;
  wire [102:0]earb_0_emwr_RD_DATA;
  wire earb_0_emwr_RD_EN;
  wire [10:0]ecfg_split_0_mcfg0_datain;
  wire [10:0]ecfg_split_0_mcfg0_dataout;
  wire ecfg_split_0_mcfg0_rx_enable;
  wire ecfg_split_0_mcfg0_rx_gpio_mode;
  wire ecfg_split_0_mcfg0_rx_loopback_mode;
  wire [10:0]ecfg_split_0_mcfg1_dataout;
  wire [3:0]ecfg_split_0_mcfg1_tx_clkdiv;
  wire ecfg_split_0_mcfg1_tx_enable;
  wire ecfg_split_0_mcfg1_tx_gpio_mode;
  wire ecfg_split_0_mcfg2_rx_enable;
  wire ecfg_split_0_mcfg2_rx_mmu_mode;
  wire [11:0]ecfg_split_0_mcfg3_coreid;
  wire [3:0]ecfg_split_0_mcfg3_tx_ctrl_mode;
  wire ecfg_split_0_mcfg4_sw_reset;
  wire eclock_0_CCLK_N;
  wire eclock_0_CCLK_P;
  wire eclock_0_lclk_out;
  wire eclock_0_lclk_p;
  wire eclock_0_lclk_s;
  wire edistrib_0_emrq_FULL;
  wire [102:0]edistrib_0_emrq_WR_DATA;
  wire edistrib_0_emrq_WR_EN;
  wire edistrib_0_emrr_FULL;
  wire [102:0]edistrib_0_emrr_WR_DATA;
  wire edistrib_0_emrr_WR_EN;
  wire edistrib_0_emwr_FULL;
  wire [102:0]edistrib_0_emwr_WR_DATA;
  wire edistrib_0_emwr_WR_EN;
  wire [63:0]eio_rx_0_rxdata_p;
  wire [7:0]eio_rx_0_rxframe_p;
  wire eio_rx_0_rxlclk_p;
  wire [7:0]eio_tx_0_TX_data_n;
  wire [7:0]eio_tx_0_TX_data_p;
  wire eio_tx_0_TX_frame_n;
  wire eio_tx_0_TX_frame_p;
  wire eio_tx_0_TX_lclk_n;
  wire eio_tx_0_TX_lclk_p;
  wire eio_tx_0_TX_rd_wait_n;
  wire eio_tx_0_TX_rd_wait_p;
  wire eio_tx_0_TX_wr_wait_n;
  wire eio_tx_0_TX_wr_wait_p;
  wire eio_tx_0_tx_rd_wait;
  wire eio_tx_0_tx_wr_wait;
  wire emaxi_0_emrq_EMPTY;
  wire [102:0]emaxi_0_emrq_RD_DATA;
  wire emaxi_0_emrq_RD_EN;
  wire emaxi_0_emrr_FULL;
  wire [102:0]emaxi_0_emrr_WR_DATA;
  wire emaxi_0_emrr_WR_EN;
  wire emaxi_0_emwr_EMPTY;
  wire [102:0]emaxi_0_emwr_RD_DATA;
  wire emaxi_0_emwr_RD_EN;
  wire emesh_split_0_emm0_access;
  wire [3:0]emesh_split_0_emm0_ctrlmode;
  wire [31:0]emesh_split_0_emm0_data;
  wire [1:0]emesh_split_0_emm0_datamode;
  wire [31:0]emesh_split_0_emm0_dstaddr;
  wire emesh_split_0_emm0_rd_wait;
  wire [31:0]emesh_split_0_emm0_srcaddr;
  wire emesh_split_0_emm0_wr_wait;
  wire emesh_split_0_emm0_write;
  wire eproto_rx_0_emrx_access;
  wire [3:0]eproto_rx_0_emrx_ctrlmode;
  wire [31:0]eproto_rx_0_emrx_data;
  wire [1:0]eproto_rx_0_emrx_datamode;
  wire [31:0]eproto_rx_0_emrx_dstaddr;
  wire eproto_rx_0_emrx_rd_wait;
  wire [31:0]eproto_rx_0_emrx_srcaddr;
  wire eproto_rx_0_emrx_wr_wait;
  wire eproto_rx_0_emrx_write;
  wire eproto_rx_0_rx_rd_wait;
  wire eproto_rx_0_rx_wr_wait;
  wire eproto_tx_0_emtx_ack;
  wire [63:0]eproto_tx_0_txdata_p;
  wire [7:0]eproto_tx_0_txframe_p;
  wire esaxi_0_emrq_FULL;
  wire [102:0]esaxi_0_emrq_WR_DATA;
  wire esaxi_0_emrq_WR_EN;
  wire esaxi_0_emrr_EMPTY;
  wire [102:0]esaxi_0_emrr_RD_DATA;
  wire esaxi_0_emrr_RD_EN;
  wire esaxi_0_emwr_FULL;
  wire [102:0]esaxi_0_emwr_WR_DATA;
  wire esaxi_0_emwr_WR_EN;
  wire fifo_103x16_rdreq_prog_full;
  wire fifo_103x16_rresp_prog_full;
  wire fifo_103x16_write_prog_full;
  wire fifo_103x32_0_prog_full;
  wire fifo_103x32_1_prog_full;
  wire fifo_103x32_2_prog_full;
  wire m00_axi_aclk_1;
  wire [0:0]m00_axi_aresetn_1;
  wire [0:0]reset_1;
  wire s00_axi_aclk_1;
  wire [0:0]s00_axi_aresetn_1;
  wire s_axi_aclk_1;
  wire [0:0]util_vector_logic_0_Res;

  assign CCLK_N = eclock_0_CCLK_N;
  assign CCLK_P = eclock_0_CCLK_P;
  assign Conn2_access = EMS_FROMMMU_access;
  assign Conn2_ctrlmode = EMS_FROMMMU_ctrlmode[3:0];
  assign Conn2_data = EMS_FROMMMU_data[31:0];
  assign Conn2_datamode = EMS_FROMMMU_datamode[1:0];
  assign Conn2_dstaddr = EMS_FROMMMU_dstaddr[31:0];
  assign Conn2_srcaddr = EMS_FROMMMU_srcaddr[31:0];
  assign Conn2_write = EMS_FROMMMU_write;
  assign Conn3_ARREADY = M00_AXI_arready;
  assign Conn3_AWREADY = M00_AXI_awready;
  assign Conn3_BID = M00_AXI_bid[0];
  assign Conn3_BRESP = M00_AXI_bresp[1:0];
  assign Conn3_BVALID = M00_AXI_bvalid;
  assign Conn3_RDATA = M00_AXI_rdata[63:0];
  assign Conn3_RID = M00_AXI_rid[0];
  assign Conn3_RLAST = M00_AXI_rlast;
  assign Conn3_RRESP = M00_AXI_rresp[1:0];
  assign Conn3_RVALID = M00_AXI_rvalid;
  assign Conn3_WREADY = M00_AXI_wready;
  assign DSP_RESET_N[0] = util_vector_logic_0_Res;
  assign EMM_TOMMU_access = Conn1_access;
  assign EMM_TOMMU_ctrlmode[3:0] = Conn1_ctrlmode;
  assign EMM_TOMMU_data[31:0] = Conn1_data;
  assign EMM_TOMMU_datamode[1:0] = Conn1_datamode;
  assign EMM_TOMMU_dstaddr[31:0] = Conn1_dstaddr;
  assign EMM_TOMMU_srcaddr[31:0] = Conn1_srcaddr;
  assign EMM_TOMMU_write = Conn1_write;
  assign M00_AXI_araddr[31:0] = Conn3_ARADDR;
  assign M00_AXI_arburst[1:0] = Conn3_ARBURST;
  assign M00_AXI_arcache[3:0] = Conn3_ARCACHE;
  assign M00_AXI_arid[0] = Conn3_ARID;
  assign M00_AXI_arlen[7:0] = Conn3_ARLEN;
  assign M00_AXI_arlock[0] = Conn3_ARLOCK;
  assign M00_AXI_arprot[2:0] = Conn3_ARPROT;
  assign M00_AXI_arqos[3:0] = Conn3_ARQOS;
  assign M00_AXI_arsize[2:0] = Conn3_ARSIZE;
  assign M00_AXI_arvalid = Conn3_ARVALID;
  assign M00_AXI_awaddr[31:0] = Conn3_AWADDR;
  assign M00_AXI_awburst[1:0] = Conn3_AWBURST;
  assign M00_AXI_awcache[3:0] = Conn3_AWCACHE;
  assign M00_AXI_awid[0] = Conn3_AWID;
  assign M00_AXI_awlen[7:0] = Conn3_AWLEN;
  assign M00_AXI_awlock[0] = Conn3_AWLOCK;
  assign M00_AXI_awprot[2:0] = Conn3_AWPROT;
  assign M00_AXI_awqos[3:0] = Conn3_AWQOS;
  assign M00_AXI_awsize[2:0] = Conn3_AWSIZE;
  assign M00_AXI_awvalid = Conn3_AWVALID;
  assign M00_AXI_bready = Conn3_BREADY;
  assign M00_AXI_rready = Conn3_RREADY;
  assign M00_AXI_wdata[63:0] = Conn3_WDATA;
  assign M00_AXI_wlast = Conn3_WLAST;
  assign M00_AXI_wstrb[7:0] = Conn3_WSTRB;
  assign M00_AXI_wvalid = Conn3_WVALID;
  assign RX_1_data_n = RX_data_n[7:0];
  assign RX_1_data_p = RX_data_p[7:0];
  assign RX_1_frame_n = RX_frame_n;
  assign RX_1_frame_p = RX_frame_p;
  assign RX_1_lclk_n = RX_lclk_n;
  assign RX_1_lclk_p = RX_lclk_p;
  assign RX_rd_wait_n = RX_1_rd_wait_n;
  assign RX_rd_wait_p = RX_1_rd_wait_p;
  assign RX_wr_wait_n = RX_1_wr_wait_n;
  assign RX_wr_wait_p = RX_1_wr_wait_p;
  assign S00_AXI_1_ARADDR = S00_AXI_araddr[29:0];
  assign S00_AXI_1_ARBURST = S00_AXI_arburst[1:0];
  assign S00_AXI_1_ARCACHE = S00_AXI_arcache[3:0];
  assign S00_AXI_1_ARID = S00_AXI_arid[11:0];
  assign S00_AXI_1_ARLEN = S00_AXI_arlen[7:0];
  assign S00_AXI_1_ARLOCK = S00_AXI_arlock[0];
  assign S00_AXI_1_ARPROT = S00_AXI_arprot[2:0];
  assign S00_AXI_1_ARQOS = S00_AXI_arqos[3:0];
  assign S00_AXI_1_ARREGION = S00_AXI_arregion[3:0];
  assign S00_AXI_1_ARSIZE = S00_AXI_arsize[2:0];
  assign S00_AXI_1_ARVALID = S00_AXI_arvalid;
  assign S00_AXI_1_AWADDR = S00_AXI_awaddr[29:0];
  assign S00_AXI_1_AWBURST = S00_AXI_awburst[1:0];
  assign S00_AXI_1_AWCACHE = S00_AXI_awcache[3:0];
  assign S00_AXI_1_AWID = S00_AXI_awid[11:0];
  assign S00_AXI_1_AWLEN = S00_AXI_awlen[7:0];
  assign S00_AXI_1_AWLOCK = S00_AXI_awlock[0];
  assign S00_AXI_1_AWPROT = S00_AXI_awprot[2:0];
  assign S00_AXI_1_AWQOS = S00_AXI_awqos[3:0];
  assign S00_AXI_1_AWREGION = S00_AXI_awregion[3:0];
  assign S00_AXI_1_AWSIZE = S00_AXI_awsize[2:0];
  assign S00_AXI_1_AWVALID = S00_AXI_awvalid;
  assign S00_AXI_1_BREADY = S00_AXI_bready;
  assign S00_AXI_1_RREADY = S00_AXI_rready;
  assign S00_AXI_1_WDATA = S00_AXI_wdata[31:0];
  assign S00_AXI_1_WLAST = S00_AXI_wlast;
  assign S00_AXI_1_WSTRB = S00_AXI_wstrb[3:0];
  assign S00_AXI_1_WVALID = S00_AXI_wvalid;
  assign S00_AXI_arready = S00_AXI_1_ARREADY;
  assign S00_AXI_awready = S00_AXI_1_AWREADY;
  assign S00_AXI_bid[11:0] = S00_AXI_1_BID;
  assign S00_AXI_bresp[1:0] = S00_AXI_1_BRESP;
  assign S00_AXI_bvalid = S00_AXI_1_BVALID;
  assign S00_AXI_rdata[31:0] = S00_AXI_1_RDATA;
  assign S00_AXI_rid[11:0] = S00_AXI_1_RID;
  assign S00_AXI_rlast = S00_AXI_1_RLAST;
  assign S00_AXI_rresp[1:0] = S00_AXI_1_RRESP;
  assign S00_AXI_rvalid = S00_AXI_1_RVALID;
  assign S00_AXI_wready = S00_AXI_1_WREADY;
  assign S_AXI_CFG_arready[0] = S_AXI_REGS_1_ARREADY;
  assign S_AXI_CFG_awready[0] = S_AXI_REGS_1_AWREADY;
  assign S_AXI_CFG_bresp[1:0] = S_AXI_REGS_1_BRESP;
  assign S_AXI_CFG_bvalid[0] = S_AXI_REGS_1_BVALID;
  assign S_AXI_CFG_rdata[31:0] = S_AXI_REGS_1_RDATA;
  assign S_AXI_CFG_rresp[1:0] = S_AXI_REGS_1_RRESP;
  assign S_AXI_CFG_rvalid[0] = S_AXI_REGS_1_RVALID;
  assign S_AXI_CFG_wready[0] = S_AXI_REGS_1_WREADY;
  assign S_AXI_REGS_1_ARADDR = S_AXI_CFG_araddr[12:0];
  assign S_AXI_REGS_1_ARPROT = S_AXI_CFG_arprot[2:0];
  assign S_AXI_REGS_1_ARVALID = S_AXI_CFG_arvalid[0];
  assign S_AXI_REGS_1_AWADDR = S_AXI_CFG_awaddr[12:0];
  assign S_AXI_REGS_1_AWPROT = S_AXI_CFG_awprot[2:0];
  assign S_AXI_REGS_1_AWVALID = S_AXI_CFG_awvalid[0];
  assign S_AXI_REGS_1_BREADY = S_AXI_CFG_bready[0];
  assign S_AXI_REGS_1_RREADY = S_AXI_CFG_rready[0];
  assign S_AXI_REGS_1_WDATA = S_AXI_CFG_wdata[31:0];
  assign S_AXI_REGS_1_WSTRB = S_AXI_CFG_wstrb[3:0];
  assign S_AXI_REGS_1_WVALID = S_AXI_CFG_wvalid[0];
  assign TX_data_n[7:0] = eio_tx_0_TX_data_n;
  assign TX_data_p[7:0] = eio_tx_0_TX_data_p;
  assign TX_frame_n = eio_tx_0_TX_frame_n;
  assign TX_frame_p = eio_tx_0_TX_frame_p;
  assign TX_lclk_n = eio_tx_0_TX_lclk_n;
  assign TX_lclk_p = eio_tx_0_TX_lclk_p;
  assign aresetn_1 = s_axi_aresetn[0];
  assign clkin_1 = clkin;
  assign eio_tx_0_TX_rd_wait_n = TX_rd_wait_n;
  assign eio_tx_0_TX_rd_wait_p = TX_rd_wait_p;
  assign eio_tx_0_TX_wr_wait_n = TX_wr_wait_n;
  assign eio_tx_0_TX_wr_wait_p = TX_wr_wait_p;
  assign m00_axi_aclk_1 = m00_axi_aclk;
  assign m00_axi_aresetn_1 = m00_axi_aresetn[0];
  assign reset_1 = reset[0];
  assign s00_axi_aclk_1 = s00_axi_aclk;
  assign s00_axi_aresetn_1 = s00_axi_aresetn[0];
  assign s_axi_aclk_1 = s_axi_aclk;
GND GND
       (.G(GND_1));
(* BMM_INFO_ADDRESS_SPACE = "byte  0x70000000 32 >  elink2_top elink2/eCfg_0" *) 
   (* KEEP_HIERARCHY = "yes" *) 
   elink2_top_axi_bram_ctrl_2_0 axi_bram_ctrl_2
       (.bram_addr_a(axi_bram_ctrl_2_BRAM_PORTA_ADDR),
        .bram_clk_a(axi_bram_ctrl_2_BRAM_PORTA_CLK),
        .bram_en_a(axi_bram_ctrl_2_BRAM_PORTA_EN),
        .bram_rddata_a(axi_bram_ctrl_2_BRAM_PORTA_DOUT),
        .bram_rst_a(axi_bram_ctrl_2_BRAM_PORTA_RST),
        .bram_we_a(axi_bram_ctrl_2_BRAM_PORTA_WE),
        .bram_wrdata_a(axi_bram_ctrl_2_BRAM_PORTA_DIN),
        .s_axi_aclk(s_axi_aclk_1),
        .s_axi_araddr(S_AXI_REGS_1_ARADDR),
        .s_axi_aresetn(aresetn_1),
        .s_axi_arprot(S_AXI_REGS_1_ARPROT),
        .s_axi_arready(S_AXI_REGS_1_ARREADY),
        .s_axi_arvalid(S_AXI_REGS_1_ARVALID),
        .s_axi_awaddr(S_AXI_REGS_1_AWADDR),
        .s_axi_awprot(S_AXI_REGS_1_AWPROT),
        .s_axi_awready(S_AXI_REGS_1_AWREADY),
        .s_axi_awvalid(S_AXI_REGS_1_AWVALID),
        .s_axi_bready(S_AXI_REGS_1_BREADY),
        .s_axi_bresp(S_AXI_REGS_1_BRESP),
        .s_axi_bvalid(S_AXI_REGS_1_BVALID),
        .s_axi_rdata(S_AXI_REGS_1_RDATA),
        .s_axi_rready(S_AXI_REGS_1_RREADY),
        .s_axi_rresp(S_AXI_REGS_1_RRESP),
        .s_axi_rvalid(S_AXI_REGS_1_RVALID),
        .s_axi_wdata(S_AXI_REGS_1_WDATA),
        .s_axi_wready(S_AXI_REGS_1_WREADY),
        .s_axi_wstrb(S_AXI_REGS_1_WSTRB),
        .s_axi_wvalid(S_AXI_REGS_1_WVALID));
elink2_top_eCfg_0_0 eCfg_0
       (.ecfg_cclk_div(eCfg_0_ecfg_cclk_div),
        .ecfg_cclk_en(eCfg_0_ecfg_cclk_en),
        .ecfg_cclk_pllcfg(eCfg_0_ecfg_cclk_pllcfg),
        .ecfg_coreid(eCfg_0_ecfg_coreid),
        .ecfg_datain(eCfg_0_ecfg_datain),
        .ecfg_dataout(eCfg_0_ecfg_dataout),
        .ecfg_rx_enable(eCfg_0_ecfg_rx_enable),
        .ecfg_rx_gpio_mode(eCfg_0_ecfg_rx_gpio_mode),
        .ecfg_rx_loopback_mode(eCfg_0_ecfg_rx_loopback_mode),
        .ecfg_rx_mmu_mode(eCfg_0_ecfg_rx_mmu_mode),
        .ecfg_sw_reset(eCfg_0_ecfg_sw_reset),
        .ecfg_tx_clkdiv(eCfg_0_ecfg_tx_clkdiv),
        .ecfg_tx_ctrl_mode(eCfg_0_ecfg_tx_ctrl_mode),
        .ecfg_tx_enable(eCfg_0_ecfg_tx_enable),
        .ecfg_tx_gpio_mode(eCfg_0_ecfg_tx_gpio_mode),
        .ecfg_tx_mmu_mode(eCfg_0_ecfg_tx_mmu_mode),
        .hw_reset(reset_1),
        .mi_addr(axi_bram_ctrl_2_BRAM_PORTA_ADDR[11:0]),
        .mi_clk(axi_bram_ctrl_2_BRAM_PORTA_CLK),
        .mi_din(axi_bram_ctrl_2_BRAM_PORTA_DIN),
        .mi_dout(axi_bram_ctrl_2_BRAM_PORTA_DOUT),
        .mi_en(axi_bram_ctrl_2_BRAM_PORTA_EN),
        .mi_rst(axi_bram_ctrl_2_BRAM_PORTA_RST),
        .mi_we(axi_bram_ctrl_2_BRAM_PORTA_WE[0]));
elink2_top_earb_0_0 earb_0
       (.clock(eclock_0_lclk_p),
        .emm_tx_access(earb_0_emm_tx_access),
        .emm_tx_ctrlmode(earb_0_emm_tx_ctrlmode),
        .emm_tx_data(earb_0_emm_tx_data),
        .emm_tx_datamode(earb_0_emm_tx_datamode),
        .emm_tx_dstaddr(earb_0_emm_tx_dstaddr),
        .emm_tx_rd_wait(earb_0_emm_tx_rd_wait),
        .emm_tx_srcaddr(earb_0_emm_tx_srcaddr),
        .emm_tx_wr_wait(earb_0_emm_tx_wr_wait),
        .emm_tx_write(earb_0_emm_tx_write),
        .emrq_empty(earb_0_emrq_EMPTY),
        .emrq_rd_data(earb_0_emrq_RD_DATA),
        .emrq_rd_en(earb_0_emrq_RD_EN),
        .emrr_empty(earb_0_emrr_EMPTY),
        .emrr_rd_data(earb_0_emrr_RD_DATA),
        .emrr_rd_en(earb_0_emrr_RD_EN),
        .emtx_ack(eproto_tx_0_emtx_ack),
        .emwr_empty(earb_0_emwr_EMPTY),
        .emwr_rd_data(earb_0_emwr_RD_DATA),
        .emwr_rd_en(earb_0_emwr_RD_EN),
        .reset(reset_1));
elink2_top_ecfg_split_0_0 ecfg_split_0
       (.mcfg0_datain(ecfg_split_0_mcfg0_datain),
        .mcfg0_dataout(ecfg_split_0_mcfg0_dataout),
        .mcfg0_rx_enable(ecfg_split_0_mcfg0_rx_enable),
        .mcfg0_rx_gpio_mode(ecfg_split_0_mcfg0_rx_gpio_mode),
        .mcfg0_rx_loopback_mode(ecfg_split_0_mcfg0_rx_loopback_mode),
        .mcfg1_datain({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .mcfg1_dataout(ecfg_split_0_mcfg1_dataout),
        .mcfg1_tx_clkdiv(ecfg_split_0_mcfg1_tx_clkdiv),
        .mcfg1_tx_enable(ecfg_split_0_mcfg1_tx_enable),
        .mcfg1_tx_gpio_mode(ecfg_split_0_mcfg1_tx_gpio_mode),
        .mcfg2_datain({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .mcfg2_rx_enable(ecfg_split_0_mcfg2_rx_enable),
        .mcfg2_rx_mmu_mode(ecfg_split_0_mcfg2_rx_mmu_mode),
        .mcfg3_coreid(ecfg_split_0_mcfg3_coreid),
        .mcfg3_datain({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .mcfg3_tx_ctrl_mode(ecfg_split_0_mcfg3_tx_ctrl_mode),
        .mcfg4_datain({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .mcfg4_sw_reset(ecfg_split_0_mcfg4_sw_reset),
        .slvcfg_coreid(eCfg_0_ecfg_coreid),
        .slvcfg_datain(eCfg_0_ecfg_datain),
        .slvcfg_dataout(eCfg_0_ecfg_dataout),
        .slvcfg_rx_enable(eCfg_0_ecfg_rx_enable),
        .slvcfg_rx_gpio_mode(eCfg_0_ecfg_rx_gpio_mode),
        .slvcfg_rx_loopback_mode(eCfg_0_ecfg_rx_loopback_mode),
        .slvcfg_rx_mmu_mode(eCfg_0_ecfg_rx_mmu_mode),
        .slvcfg_sw_reset(eCfg_0_ecfg_sw_reset),
        .slvcfg_tx_clkdiv(eCfg_0_ecfg_tx_clkdiv),
        .slvcfg_tx_ctrl_mode(eCfg_0_ecfg_tx_ctrl_mode),
        .slvcfg_tx_enable(eCfg_0_ecfg_tx_enable),
        .slvcfg_tx_gpio_mode(eCfg_0_ecfg_tx_gpio_mode),
        .slvcfg_tx_mmu_mode(eCfg_0_ecfg_tx_mmu_mode));
elink2_top_eclock_0_0 eclock_0
       (.CCLK_N(eclock_0_CCLK_N),
        .CCLK_P(eclock_0_CCLK_P),
        .clkin(clkin_1),
        .ecfg_cclk_div(eCfg_0_ecfg_cclk_div),
        .ecfg_cclk_en(eCfg_0_ecfg_cclk_en),
        .ecfg_cclk_pllcfg(eCfg_0_ecfg_cclk_pllcfg),
        .lclk_out(eclock_0_lclk_out),
        .lclk_p(eclock_0_lclk_p),
        .lclk_s(eclock_0_lclk_s),
        .reset(reset_1));
elink2_top_edistrib_0_0 edistrib_0
       (.ecfg_rx_enable(ecfg_split_0_mcfg2_rx_enable),
        .ecfg_rx_mmu_mode(ecfg_split_0_mcfg2_rx_mmu_mode),
        .emrq_full(edistrib_0_emrq_FULL),
        .emrq_prog_full(fifo_103x32_2_prog_full),
        .emrq_wr_data(edistrib_0_emrq_WR_DATA),
        .emrq_wr_en(edistrib_0_emrq_WR_EN),
        .emrr_full(edistrib_0_emrr_FULL),
        .emrr_prog_full(fifo_103x32_1_prog_full),
        .emrr_wr_data(edistrib_0_emrr_WR_DATA),
        .emrr_wr_en(edistrib_0_emrr_WR_EN),
        .ems_dir_access(emesh_split_0_emm0_access),
        .ems_dir_ctrlmode(emesh_split_0_emm0_ctrlmode),
        .ems_dir_data(emesh_split_0_emm0_data),
        .ems_dir_datamode(emesh_split_0_emm0_datamode),
        .ems_dir_dstaddr(emesh_split_0_emm0_dstaddr),
        .ems_dir_rd_wait(emesh_split_0_emm0_rd_wait),
        .ems_dir_srcaddr(emesh_split_0_emm0_srcaddr),
        .ems_dir_wr_wait(emesh_split_0_emm0_wr_wait),
        .ems_dir_write(emesh_split_0_emm0_write),
        .ems_mmu_access(Conn2_access),
        .ems_mmu_ctrlmode(Conn2_ctrlmode),
        .ems_mmu_data(Conn2_data),
        .ems_mmu_datamode(Conn2_datamode),
        .ems_mmu_dstaddr(Conn2_dstaddr),
        .ems_mmu_srcaddr(Conn2_srcaddr),
        .ems_mmu_write(Conn2_write),
        .emwr_full(edistrib_0_emwr_FULL),
        .emwr_prog_full(fifo_103x32_0_prog_full),
        .emwr_wr_data(edistrib_0_emwr_WR_DATA),
        .emwr_wr_en(edistrib_0_emwr_WR_EN),
        .rxlclk(eio_rx_0_rxlclk_p));
elink2_top_eio_rx_0_0 eio_rx_0
       (.RX_DATA_N(RX_1_data_n),
        .RX_DATA_P(RX_1_data_p),
        .RX_FRAME_N(RX_1_frame_n),
        .RX_FRAME_P(RX_1_frame_p),
        .RX_LCLK_N(RX_1_lclk_n),
        .RX_LCLK_P(RX_1_lclk_p),
        .RX_RD_WAIT_N(RX_1_rd_wait_n),
        .RX_RD_WAIT_P(RX_1_rd_wait_p),
        .RX_WR_WAIT_N(RX_1_wr_wait_n),
        .RX_WR_WAIT_P(RX_1_wr_wait_p),
        .ecfg_datain(ecfg_split_0_mcfg0_datain),
        .ecfg_dataout(ecfg_split_0_mcfg0_dataout),
        .ecfg_rx_enable(ecfg_split_0_mcfg0_rx_enable),
        .ecfg_rx_gpio_mode(ecfg_split_0_mcfg0_rx_gpio_mode),
        .ecfg_rx_loopback_mode(ecfg_split_0_mcfg0_rx_loopback_mode),
        .ioreset(reset_1),
        .loopback_data(eproto_tx_0_txdata_p),
        .loopback_frame(eproto_tx_0_txframe_p),
        .reset(reset_1),
        .rx_rd_wait(eproto_rx_0_rx_rd_wait),
        .rx_wr_wait(eproto_rx_0_rx_wr_wait),
        .rxdata_p(eio_rx_0_rxdata_p),
        .rxframe_p(eio_rx_0_rxframe_p),
        .rxlclk_p(eio_rx_0_rxlclk_p),
        .tx_rd_wait(eio_tx_0_tx_rd_wait),
        .tx_wr_wait(eio_tx_0_tx_wr_wait),
        .txlclk_p(eclock_0_lclk_p));
elink2_top_eio_tx_0_0 eio_tx_0
       (.TX_DATA_N(eio_tx_0_TX_data_n),
        .TX_DATA_P(eio_tx_0_TX_data_p),
        .TX_FRAME_N(eio_tx_0_TX_frame_n),
        .TX_FRAME_P(eio_tx_0_TX_frame_p),
        .TX_LCLK_N(eio_tx_0_TX_lclk_n),
        .TX_LCLK_P(eio_tx_0_TX_lclk_p),
        .TX_RD_WAIT_N(eio_tx_0_TX_rd_wait_n),
        .TX_RD_WAIT_P(eio_tx_0_TX_rd_wait_p),
        .TX_WR_WAIT_N(eio_tx_0_TX_wr_wait_n),
        .TX_WR_WAIT_P(eio_tx_0_TX_wr_wait_p),
        .ecfg_dataout(ecfg_split_0_mcfg1_dataout),
        .ecfg_tx_clkdiv(ecfg_split_0_mcfg1_tx_clkdiv),
        .ecfg_tx_enable(ecfg_split_0_mcfg1_tx_enable),
        .ecfg_tx_gpio_mode(ecfg_split_0_mcfg1_tx_gpio_mode),
        .ioreset(reset_1),
        .reset(reset_1),
        .tx_rd_wait(eio_tx_0_tx_rd_wait),
        .tx_wr_wait(eio_tx_0_tx_wr_wait),
        .txdata_p(eproto_tx_0_txdata_p),
        .txframe_p(eproto_tx_0_txframe_p),
        .txlclk_out(eclock_0_lclk_out),
        .txlclk_p(eclock_0_lclk_p),
        .txlclk_s(eclock_0_lclk_s));
elink2_top_emaxi_0_0 emaxi_0
       (.emrq_empty(emaxi_0_emrq_EMPTY),
        .emrq_rd_data(emaxi_0_emrq_RD_DATA),
        .emrq_rd_en(emaxi_0_emrq_RD_EN),
        .emrr_full(emaxi_0_emrr_FULL),
        .emrr_prog_full(fifo_103x16_rresp_prog_full),
        .emrr_wr_data(emaxi_0_emrr_WR_DATA),
        .emrr_wr_en(emaxi_0_emrr_WR_EN),
        .emwr_empty(emaxi_0_emwr_EMPTY),
        .emwr_rd_data(emaxi_0_emwr_RD_DATA),
        .emwr_rd_en(emaxi_0_emwr_RD_EN),
        .m00_axi_aclk(m00_axi_aclk_1),
        .m00_axi_araddr(Conn3_ARADDR),
        .m00_axi_arburst(Conn3_ARBURST),
        .m00_axi_arcache(Conn3_ARCACHE),
        .m00_axi_aresetn(m00_axi_aresetn_1),
        .m00_axi_arid(Conn3_ARID),
        .m00_axi_arlen(Conn3_ARLEN),
        .m00_axi_arlock(Conn3_ARLOCK),
        .m00_axi_arprot(Conn3_ARPROT),
        .m00_axi_arqos(Conn3_ARQOS),
        .m00_axi_arready(Conn3_ARREADY),
        .m00_axi_arsize(Conn3_ARSIZE),
        .m00_axi_arvalid(Conn3_ARVALID),
        .m00_axi_awaddr(Conn3_AWADDR),
        .m00_axi_awburst(Conn3_AWBURST),
        .m00_axi_awcache(Conn3_AWCACHE),
        .m00_axi_awid(Conn3_AWID),
        .m00_axi_awlen(Conn3_AWLEN),
        .m00_axi_awlock(Conn3_AWLOCK),
        .m00_axi_awprot(Conn3_AWPROT),
        .m00_axi_awqos(Conn3_AWQOS),
        .m00_axi_awready(Conn3_AWREADY),
        .m00_axi_awsize(Conn3_AWSIZE),
        .m00_axi_awvalid(Conn3_AWVALID),
        .m00_axi_bid(Conn3_BID),
        .m00_axi_bready(Conn3_BREADY),
        .m00_axi_bresp(Conn3_BRESP),
        .m00_axi_bvalid(Conn3_BVALID),
        .m00_axi_rdata(Conn3_RDATA),
        .m00_axi_rid(Conn3_RID),
        .m00_axi_rlast(Conn3_RLAST),
        .m00_axi_rready(Conn3_RREADY),
        .m00_axi_rresp(Conn3_RRESP),
        .m00_axi_rvalid(Conn3_RVALID),
        .m00_axi_wdata(Conn3_WDATA),
        .m00_axi_wlast(Conn3_WLAST),
        .m00_axi_wready(Conn3_WREADY),
        .m00_axi_wstrb(Conn3_WSTRB),
        .m00_axi_wvalid(Conn3_WVALID));
elink2_top_emesh_split_0_0 emesh_split_0
       (.emm0_access(emesh_split_0_emm0_access),
        .emm0_ctrlmode(emesh_split_0_emm0_ctrlmode),
        .emm0_data(emesh_split_0_emm0_data),
        .emm0_datamode(emesh_split_0_emm0_datamode),
        .emm0_dstaddr(emesh_split_0_emm0_dstaddr),
        .emm0_rd_wait(emesh_split_0_emm0_rd_wait),
        .emm0_srcaddr(emesh_split_0_emm0_srcaddr),
        .emm0_wr_wait(emesh_split_0_emm0_wr_wait),
        .emm0_write(emesh_split_0_emm0_write),
        .emm1_access(Conn1_access),
        .emm1_ctrlmode(Conn1_ctrlmode),
        .emm1_data(Conn1_data),
        .emm1_datamode(Conn1_datamode),
        .emm1_dstaddr(Conn1_dstaddr),
        .emm1_srcaddr(Conn1_srcaddr),
        .emm1_write(Conn1_write),
        .ems_access(eproto_rx_0_emrx_access),
        .ems_ctrlmode(eproto_rx_0_emrx_ctrlmode),
        .ems_data(eproto_rx_0_emrx_data),
        .ems_datamode(eproto_rx_0_emrx_datamode),
        .ems_dstaddr(eproto_rx_0_emrx_dstaddr),
        .ems_rd_wait(eproto_rx_0_emrx_rd_wait),
        .ems_srcaddr(eproto_rx_0_emrx_srcaddr),
        .ems_wr_wait(eproto_rx_0_emrx_wr_wait),
        .ems_write(eproto_rx_0_emrx_write));
elink2_top_eproto_rx_0_0 eproto_rx_0
       (.emrx_access(eproto_rx_0_emrx_access),
        .emrx_ctrlmode(eproto_rx_0_emrx_ctrlmode),
        .emrx_data(eproto_rx_0_emrx_data),
        .emrx_datamode(eproto_rx_0_emrx_datamode),
        .emrx_dstaddr(eproto_rx_0_emrx_dstaddr),
        .emrx_rd_wait(eproto_rx_0_emrx_rd_wait),
        .emrx_srcaddr(eproto_rx_0_emrx_srcaddr),
        .emrx_wr_wait(eproto_rx_0_emrx_wr_wait),
        .emrx_write(eproto_rx_0_emrx_write),
        .reset(reset_1),
        .rx_rd_wait(eproto_rx_0_rx_rd_wait),
        .rx_wr_wait(eproto_rx_0_rx_wr_wait),
        .rxdata_p(eio_rx_0_rxdata_p),
        .rxframe_p(eio_rx_0_rxframe_p),
        .rxlclk_p(eio_rx_0_rxlclk_p));
elink2_top_eproto_tx_0_0 eproto_tx_0
       (.emtx_access(earb_0_emm_tx_access),
        .emtx_ack(eproto_tx_0_emtx_ack),
        .emtx_ctrlmode(earb_0_emm_tx_ctrlmode),
        .emtx_data(earb_0_emm_tx_data),
        .emtx_datamode(earb_0_emm_tx_datamode),
        .emtx_dstaddr(earb_0_emm_tx_dstaddr),
        .emtx_rd_wait(earb_0_emm_tx_rd_wait),
        .emtx_srcaddr(earb_0_emm_tx_srcaddr),
        .emtx_wr_wait(earb_0_emm_tx_wr_wait),
        .emtx_write(earb_0_emm_tx_write),
        .reset(reset_1),
        .tx_rd_wait(eio_tx_0_tx_rd_wait),
        .tx_wr_wait(eio_tx_0_tx_wr_wait),
        .txdata_p(eproto_tx_0_txdata_p),
        .txframe_p(eproto_tx_0_txframe_p),
        .txlclk_p(eclock_0_lclk_p));
elink2_top_esaxi_0_0 esaxi_0
       (.ecfg_coreid(ecfg_split_0_mcfg3_coreid),
        .ecfg_tx_ctrl_mode(ecfg_split_0_mcfg3_tx_ctrl_mode),
        .emrq_full(esaxi_0_emrq_FULL),
        .emrq_prog_full(fifo_103x16_rdreq_prog_full),
        .emrq_wr_data(esaxi_0_emrq_WR_DATA),
        .emrq_wr_en(esaxi_0_emrq_WR_EN),
        .emrr_empty(esaxi_0_emrr_EMPTY),
        .emrr_rd_data(esaxi_0_emrr_RD_DATA),
        .emrr_rd_en(esaxi_0_emrr_RD_EN),
        .emwr_full(esaxi_0_emwr_FULL),
        .emwr_prog_full(fifo_103x16_write_prog_full),
        .emwr_wr_data(esaxi_0_emwr_WR_DATA),
        .emwr_wr_en(esaxi_0_emwr_WR_EN),
        .s00_axi_aclk(s00_axi_aclk_1),
        .s00_axi_araddr(S00_AXI_1_ARADDR),
        .s00_axi_arburst(S00_AXI_1_ARBURST),
        .s00_axi_arcache(S00_AXI_1_ARCACHE),
        .s00_axi_aresetn(s00_axi_aresetn_1),
        .s00_axi_arid(S00_AXI_1_ARID),
        .s00_axi_arlen(S00_AXI_1_ARLEN),
        .s00_axi_arlock(S00_AXI_1_ARLOCK),
        .s00_axi_arprot(S00_AXI_1_ARPROT),
        .s00_axi_arqos(S00_AXI_1_ARQOS),
        .s00_axi_arready(S00_AXI_1_ARREADY),
        .s00_axi_arregion(S00_AXI_1_ARREGION),
        .s00_axi_arsize(S00_AXI_1_ARSIZE),
        .s00_axi_arvalid(S00_AXI_1_ARVALID),
        .s00_axi_awaddr(S00_AXI_1_AWADDR),
        .s00_axi_awburst(S00_AXI_1_AWBURST),
        .s00_axi_awcache(S00_AXI_1_AWCACHE),
        .s00_axi_awid(S00_AXI_1_AWID),
        .s00_axi_awlen(S00_AXI_1_AWLEN),
        .s00_axi_awlock(S00_AXI_1_AWLOCK),
        .s00_axi_awprot(S00_AXI_1_AWPROT),
        .s00_axi_awqos(S00_AXI_1_AWQOS),
        .s00_axi_awready(S00_AXI_1_AWREADY),
        .s00_axi_awregion(S00_AXI_1_AWREGION),
        .s00_axi_awsize(S00_AXI_1_AWSIZE),
        .s00_axi_awvalid(S00_AXI_1_AWVALID),
        .s00_axi_bid(S00_AXI_1_BID),
        .s00_axi_bready(S00_AXI_1_BREADY),
        .s00_axi_bresp(S00_AXI_1_BRESP),
        .s00_axi_bvalid(S00_AXI_1_BVALID),
        .s00_axi_rdata(S00_AXI_1_RDATA),
        .s00_axi_rid(S00_AXI_1_RID),
        .s00_axi_rlast(S00_AXI_1_RLAST),
        .s00_axi_rready(S00_AXI_1_RREADY),
        .s00_axi_rresp(S00_AXI_1_RRESP),
        .s00_axi_rvalid(S00_AXI_1_RVALID),
        .s00_axi_wdata(S00_AXI_1_WDATA),
        .s00_axi_wlast(S00_AXI_1_WLAST),
        .s00_axi_wready(S00_AXI_1_WREADY),
        .s00_axi_wstrb(S00_AXI_1_WSTRB),
        .s00_axi_wvalid(S00_AXI_1_WVALID));
elink2_top_fifo_103x16_rdreq_0 fifo_103x16_rdreq
       (.din(esaxi_0_emrq_WR_DATA),
        .dout(earb_0_emrq_RD_DATA),
        .empty(earb_0_emrq_EMPTY),
        .full(esaxi_0_emrq_FULL),
        .prog_full(fifo_103x16_rdreq_prog_full),
        .rd_clk(eclock_0_lclk_p),
        .rd_en(earb_0_emrq_RD_EN),
        .rst(reset_1),
        .wr_clk(s00_axi_aclk_1),
        .wr_en(esaxi_0_emrq_WR_EN));
elink2_top_fifo_103x16_rresp_0 fifo_103x16_rresp
       (.din(emaxi_0_emrr_WR_DATA),
        .dout(earb_0_emrr_RD_DATA),
        .empty(earb_0_emrr_EMPTY),
        .full(emaxi_0_emrr_FULL),
        .prog_full(fifo_103x16_rresp_prog_full),
        .rd_clk(eclock_0_lclk_p),
        .rd_en(earb_0_emrr_RD_EN),
        .rst(reset_1),
        .wr_clk(m00_axi_aclk_1),
        .wr_en(emaxi_0_emrr_WR_EN));
elink2_top_fifo_103x16_write_0 fifo_103x16_write
       (.din(esaxi_0_emwr_WR_DATA),
        .dout(earb_0_emwr_RD_DATA),
        .empty(earb_0_emwr_EMPTY),
        .full(esaxi_0_emwr_FULL),
        .prog_full(fifo_103x16_write_prog_full),
        .rd_clk(eclock_0_lclk_p),
        .rd_en(earb_0_emwr_RD_EN),
        .rst(reset_1),
        .wr_clk(s00_axi_aclk_1),
        .wr_en(esaxi_0_emwr_WR_EN));
elink2_top_fifo_103x32_rdreq_0 fifo_103x32_rdreq
       (.din(edistrib_0_emrq_WR_DATA),
        .dout(emaxi_0_emrq_RD_DATA),
        .empty(emaxi_0_emrq_EMPTY),
        .full(edistrib_0_emrq_FULL),
        .prog_full(fifo_103x32_2_prog_full),
        .rd_clk(m00_axi_aclk_1),
        .rd_en(emaxi_0_emrq_RD_EN),
        .rst(reset_1),
        .wr_clk(eio_rx_0_rxlclk_p),
        .wr_en(edistrib_0_emrq_WR_EN));
elink2_top_fifo_103x32_rresp_0 fifo_103x32_rresp
       (.din(edistrib_0_emrr_WR_DATA),
        .dout(esaxi_0_emrr_RD_DATA),
        .empty(esaxi_0_emrr_EMPTY),
        .full(edistrib_0_emrr_FULL),
        .prog_full(fifo_103x32_1_prog_full),
        .rd_clk(s00_axi_aclk_1),
        .rd_en(esaxi_0_emrr_RD_EN),
        .rst(reset_1),
        .wr_clk(eio_rx_0_rxlclk_p),
        .wr_en(edistrib_0_emrr_WR_EN));
elink2_top_fifo_103x32_write_0 fifo_103x32_write
       (.din(edistrib_0_emwr_WR_DATA),
        .dout(emaxi_0_emwr_RD_DATA),
        .empty(emaxi_0_emwr_EMPTY),
        .full(edistrib_0_emwr_FULL),
        .prog_full(fifo_103x32_0_prog_full),
        .rd_clk(m00_axi_aclk_1),
        .rd_en(emaxi_0_emwr_RD_EN),
        .rst(reset_1),
        .wr_clk(eio_rx_0_rxlclk_p),
        .wr_en(edistrib_0_emwr_WR_EN));
elink2_top_util_vector_logic_0_0 util_vector_logic_0
       (.Op1(ecfg_split_0_mcfg4_sw_reset),
        .Res(util_vector_logic_0_Res));
endmodule

module elink2_top
   (CAM_I2C_SCL,
    CAM_I2C_SDA,
    CCLK_N,
    CCLK_P,
    CSI_AXI_araddr,
    CSI_AXI_arprot,
    CSI_AXI_arready,
    CSI_AXI_arvalid,
    CSI_AXI_awaddr,
    CSI_AXI_awprot,
    CSI_AXI_awready,
    CSI_AXI_awvalid,
    CSI_AXI_bready,
    CSI_AXI_bresp,
    CSI_AXI_bvalid,
    CSI_AXI_rdata,
    CSI_AXI_rready,
    CSI_AXI_rresp,
    CSI_AXI_rvalid,
    CSI_AXI_wdata,
    CSI_AXI_wready,
    CSI_AXI_wstrb,
    CSI_AXI_wvalid,
    CSI_VIDEO_tdata,
    CSI_VIDEO_tkeep,
    CSI_VIDEO_tlast,
    CSI_VIDEO_tready,
    CSI_VIDEO_tuser,
    CSI_VIDEO_tvalid,
    DDR_addr,
    DDR_ba,
    DDR_cas_n,
    DDR_ck_n,
    DDR_ck_p,
    DDR_cke,
    DDR_cs_n,
    DDR_dm,
    DDR_dq,
    DDR_dqs_n,
    DDR_dqs_p,
    DDR_odt,
    DDR_ras_n,
    DDR_reset_n,
    DDR_we_n,
    DSP_RESET_N,
    FCLK_CLK0,
    FCLK_CLK1,
    FIXED_IO_ddr_vrn,
    FIXED_IO_ddr_vrp,
    FIXED_IO_mio,
    FIXED_IO_ps_clk,
    FIXED_IO_ps_porb,
    FIXED_IO_ps_srstb,
    GPIO_0_tri_i,
    GPIO_0_tri_o,
    GPIO_0_tri_t,
    I2C_SCL,
    I2C_SDA,
    RX_data_n,
    RX_data_p,
    RX_frame_n,
    RX_frame_p,
    RX_lclk_n,
    RX_lclk_p,
    RX_rd_wait_n,
    RX_rd_wait_p,
    RX_wr_wait_n,
    RX_wr_wait_p,
    TX_data_n,
    TX_data_p,
    TX_frame_n,
    TX_frame_p,
    TX_lclk_n,
    TX_lclk_p,
    TX_rd_wait_n,
    TX_rd_wait_p,
    TX_wr_wait_n,
    TX_wr_wait_p,
    aresetn,
    csi_intr);
  inout CAM_I2C_SCL;
  inout CAM_I2C_SDA;
  output CCLK_N;
  output CCLK_P;
  output [31:0]CSI_AXI_araddr;
  output [2:0]CSI_AXI_arprot;
  input [0:0]CSI_AXI_arready;
  output [0:0]CSI_AXI_arvalid;
  output [31:0]CSI_AXI_awaddr;
  output [2:0]CSI_AXI_awprot;
  input [0:0]CSI_AXI_awready;
  output [0:0]CSI_AXI_awvalid;
  output [0:0]CSI_AXI_bready;
  input [1:0]CSI_AXI_bresp;
  input [0:0]CSI_AXI_bvalid;
  input [31:0]CSI_AXI_rdata;
  output [0:0]CSI_AXI_rready;
  input [1:0]CSI_AXI_rresp;
  input [0:0]CSI_AXI_rvalid;
  output [31:0]CSI_AXI_wdata;
  input [0:0]CSI_AXI_wready;
  output [3:0]CSI_AXI_wstrb;
  output [0:0]CSI_AXI_wvalid;
  input [31:0]CSI_VIDEO_tdata;
  input [3:0]CSI_VIDEO_tkeep;
  input CSI_VIDEO_tlast;
  output CSI_VIDEO_tready;
  input [0:0]CSI_VIDEO_tuser;
  input CSI_VIDEO_tvalid;
  inout [14:0]DDR_addr;
  inout [2:0]DDR_ba;
  inout DDR_cas_n;
  inout DDR_ck_n;
  inout DDR_ck_p;
  inout DDR_cke;
  inout DDR_cs_n;
  inout [3:0]DDR_dm;
  inout [31:0]DDR_dq;
  inout [3:0]DDR_dqs_n;
  inout [3:0]DDR_dqs_p;
  inout DDR_odt;
  inout DDR_ras_n;
  inout DDR_reset_n;
  inout DDR_we_n;
  output [0:0]DSP_RESET_N;
  output FCLK_CLK0;
  output FCLK_CLK1;
  inout FIXED_IO_ddr_vrn;
  inout FIXED_IO_ddr_vrp;
  inout [53:0]FIXED_IO_mio;
  inout FIXED_IO_ps_clk;
  inout FIXED_IO_ps_porb;
  inout FIXED_IO_ps_srstb;
  input [63:0]GPIO_0_tri_i;
  output [63:0]GPIO_0_tri_o;
  output [63:0]GPIO_0_tri_t;
  inout I2C_SCL;
  inout I2C_SDA;
  input [7:0]RX_data_n;
  input [7:0]RX_data_p;
  input RX_frame_n;
  input RX_frame_p;
  input RX_lclk_n;
  input RX_lclk_p;
  output RX_rd_wait_n;
  output RX_rd_wait_p;
  output RX_wr_wait_n;
  output RX_wr_wait_p;
  output [7:0]TX_data_n;
  output [7:0]TX_data_p;
  output TX_frame_n;
  output TX_frame_p;
  output TX_lclk_n;
  output TX_lclk_p;
  input TX_rd_wait_n;
  input TX_rd_wait_p;
  input TX_wr_wait_n;
  input TX_wr_wait_p;
  output [0:0]aresetn;
  input csi_intr;

  wire [31:0]CSI_VIDEO_1_TDATA;
  wire [3:0]CSI_VIDEO_1_TKEEP;
  wire CSI_VIDEO_1_TLAST;
  wire CSI_VIDEO_1_TREADY;
  wire [0:0]CSI_VIDEO_1_TUSER;
  wire CSI_VIDEO_1_TVALID;
  wire EMS_FROMMMU_1_access;
  wire [3:0]EMS_FROMMMU_1_ctrlmode;
  wire [31:0]EMS_FROMMMU_1_data;
  wire [1:0]EMS_FROMMMU_1_datamode;
  wire [31:0]EMS_FROMMMU_1_dstaddr;
  wire [31:0]EMS_FROMMMU_1_srcaddr;
  wire EMS_FROMMMU_1_write;
  wire GND_1;
  wire Net2;
  wire Net3;
  wire Net4;
  wire Net5;
  wire [7:0]RX_1_data_n;
  wire [7:0]RX_1_data_p;
  wire RX_1_frame_n;
  wire RX_1_frame_p;
  wire RX_1_lclk_n;
  wire RX_1_lclk_p;
  wire RX_1_rd_wait_n;
  wire RX_1_rd_wait_p;
  wire RX_1_wr_wait_n;
  wire RX_1_wr_wait_p;
  wire VCC_1;
  wire [12:0]axi_lite_0_M00_AXI_ARADDR;
  wire [2:0]axi_lite_0_M00_AXI_ARPROT;
  wire [0:0]axi_lite_0_M00_AXI_ARREADY;
  wire [0:0]axi_lite_0_M00_AXI_ARVALID;
  wire [12:0]axi_lite_0_M00_AXI_AWADDR;
  wire [2:0]axi_lite_0_M00_AXI_AWPROT;
  wire [0:0]axi_lite_0_M00_AXI_AWREADY;
  wire [0:0]axi_lite_0_M00_AXI_AWVALID;
  wire [0:0]axi_lite_0_M00_AXI_BREADY;
  wire [1:0]axi_lite_0_M00_AXI_BRESP;
  wire [0:0]axi_lite_0_M00_AXI_BVALID;
  wire [31:0]axi_lite_0_M00_AXI_RDATA;
  wire [0:0]axi_lite_0_M00_AXI_RREADY;
  wire [1:0]axi_lite_0_M00_AXI_RRESP;
  wire [0:0]axi_lite_0_M00_AXI_RVALID;
  wire [31:0]axi_lite_0_M00_AXI_WDATA;
  wire [0:0]axi_lite_0_M00_AXI_WREADY;
  wire [3:0]axi_lite_0_M00_AXI_WSTRB;
  wire [0:0]axi_lite_0_M00_AXI_WVALID;
  wire [8:0]axi_lite_0_M01_AXI_ARADDR;
  wire axi_lite_0_M01_AXI_ARREADY;
  wire axi_lite_0_M01_AXI_ARVALID;
  wire [8:0]axi_lite_0_M01_AXI_AWADDR;
  wire axi_lite_0_M01_AXI_AWREADY;
  wire axi_lite_0_M01_AXI_AWVALID;
  wire axi_lite_0_M01_AXI_BREADY;
  wire [1:0]axi_lite_0_M01_AXI_BRESP;
  wire axi_lite_0_M01_AXI_BVALID;
  wire [31:0]axi_lite_0_M01_AXI_RDATA;
  wire axi_lite_0_M01_AXI_RREADY;
  wire [1:0]axi_lite_0_M01_AXI_RRESP;
  wire axi_lite_0_M01_AXI_RVALID;
  wire [31:0]axi_lite_0_M01_AXI_WDATA;
  wire axi_lite_0_M01_AXI_WREADY;
  wire axi_lite_0_M01_AXI_WVALID;
  wire [31:0]axi_lite_0_M02_AXI_ARADDR;
  wire [2:0]axi_lite_0_M02_AXI_ARPROT;
  wire [0:0]axi_lite_0_M02_AXI_ARREADY;
  wire [0:0]axi_lite_0_M02_AXI_ARVALID;
  wire [31:0]axi_lite_0_M02_AXI_AWADDR;
  wire [2:0]axi_lite_0_M02_AXI_AWPROT;
  wire [0:0]axi_lite_0_M02_AXI_AWREADY;
  wire [0:0]axi_lite_0_M02_AXI_AWVALID;
  wire [0:0]axi_lite_0_M02_AXI_BREADY;
  wire [1:0]axi_lite_0_M02_AXI_BRESP;
  wire [0:0]axi_lite_0_M02_AXI_BVALID;
  wire [31:0]axi_lite_0_M02_AXI_RDATA;
  wire [0:0]axi_lite_0_M02_AXI_RREADY;
  wire [1:0]axi_lite_0_M02_AXI_RRESP;
  wire [0:0]axi_lite_0_M02_AXI_RVALID;
  wire [31:0]axi_lite_0_M02_AXI_WDATA;
  wire [0:0]axi_lite_0_M02_AXI_WREADY;
  wire [3:0]axi_lite_0_M02_AXI_WSTRB;
  wire [0:0]axi_lite_0_M02_AXI_WVALID;
  wire [31:0]axi_protocol_converter_0_M_AXI_ARADDR;
  wire [1:0]axi_protocol_converter_0_M_AXI_ARBURST;
  wire [3:0]axi_protocol_converter_0_M_AXI_ARCACHE;
  wire [0:0]axi_protocol_converter_0_M_AXI_ARID;
  wire [3:0]axi_protocol_converter_0_M_AXI_ARLEN;
  wire [1:0]axi_protocol_converter_0_M_AXI_ARLOCK;
  wire [2:0]axi_protocol_converter_0_M_AXI_ARPROT;
  wire [3:0]axi_protocol_converter_0_M_AXI_ARQOS;
  wire axi_protocol_converter_0_M_AXI_ARREADY;
  wire [2:0]axi_protocol_converter_0_M_AXI_ARSIZE;
  wire axi_protocol_converter_0_M_AXI_ARVALID;
  wire [31:0]axi_protocol_converter_0_M_AXI_AWADDR;
  wire [1:0]axi_protocol_converter_0_M_AXI_AWBURST;
  wire [3:0]axi_protocol_converter_0_M_AXI_AWCACHE;
  wire [0:0]axi_protocol_converter_0_M_AXI_AWID;
  wire [3:0]axi_protocol_converter_0_M_AXI_AWLEN;
  wire [1:0]axi_protocol_converter_0_M_AXI_AWLOCK;
  wire [2:0]axi_protocol_converter_0_M_AXI_AWPROT;
  wire [3:0]axi_protocol_converter_0_M_AXI_AWQOS;
  wire axi_protocol_converter_0_M_AXI_AWREADY;
  wire [2:0]axi_protocol_converter_0_M_AXI_AWSIZE;
  wire axi_protocol_converter_0_M_AXI_AWVALID;
  wire [5:0]axi_protocol_converter_0_M_AXI_BID;
  wire axi_protocol_converter_0_M_AXI_BREADY;
  wire [1:0]axi_protocol_converter_0_M_AXI_BRESP;
  wire axi_protocol_converter_0_M_AXI_BVALID;
  wire [63:0]axi_protocol_converter_0_M_AXI_RDATA;
  wire [5:0]axi_protocol_converter_0_M_AXI_RID;
  wire axi_protocol_converter_0_M_AXI_RLAST;
  wire axi_protocol_converter_0_M_AXI_RREADY;
  wire [1:0]axi_protocol_converter_0_M_AXI_RRESP;
  wire axi_protocol_converter_0_M_AXI_RVALID;
  wire [63:0]axi_protocol_converter_0_M_AXI_WDATA;
  wire [0:0]axi_protocol_converter_0_M_AXI_WID;
  wire axi_protocol_converter_0_M_AXI_WLAST;
  wire axi_protocol_converter_0_M_AXI_WREADY;
  wire [7:0]axi_protocol_converter_0_M_AXI_WSTRB;
  wire axi_protocol_converter_0_M_AXI_WVALID;
  wire [31:0]axi_protocol_converter_1_M_AXI_AWADDR;
  wire [1:0]axi_protocol_converter_1_M_AXI_AWBURST;
  wire [3:0]axi_protocol_converter_1_M_AXI_AWCACHE;
  wire [3:0]axi_protocol_converter_1_M_AXI_AWLEN;
  wire [1:0]axi_protocol_converter_1_M_AXI_AWLOCK;
  wire [2:0]axi_protocol_converter_1_M_AXI_AWPROT;
  wire [3:0]axi_protocol_converter_1_M_AXI_AWQOS;
  wire axi_protocol_converter_1_M_AXI_AWREADY;
  wire [2:0]axi_protocol_converter_1_M_AXI_AWSIZE;
  wire axi_protocol_converter_1_M_AXI_AWVALID;
  wire axi_protocol_converter_1_M_AXI_BREADY;
  wire [1:0]axi_protocol_converter_1_M_AXI_BRESP;
  wire axi_protocol_converter_1_M_AXI_BVALID;
  wire [63:0]axi_protocol_converter_1_M_AXI_WDATA;
  wire axi_protocol_converter_1_M_AXI_WLAST;
  wire axi_protocol_converter_1_M_AXI_WREADY;
  wire [7:0]axi_protocol_converter_1_M_AXI_WSTRB;
  wire axi_protocol_converter_1_M_AXI_WVALID;
  wire [31:0]axi_protocol_converter_2_M_AXI_ARADDR;
  wire [1:0]axi_protocol_converter_2_M_AXI_ARBURST;
  wire [3:0]axi_protocol_converter_2_M_AXI_ARCACHE;
  wire [11:0]axi_protocol_converter_2_M_AXI_ARID;
  wire [7:0]axi_protocol_converter_2_M_AXI_ARLEN;
  wire [0:0]axi_protocol_converter_2_M_AXI_ARLOCK;
  wire [2:0]axi_protocol_converter_2_M_AXI_ARPROT;
  wire [3:0]axi_protocol_converter_2_M_AXI_ARQOS;
  wire axi_protocol_converter_2_M_AXI_ARREADY;
  wire [3:0]axi_protocol_converter_2_M_AXI_ARREGION;
  wire [2:0]axi_protocol_converter_2_M_AXI_ARSIZE;
  wire axi_protocol_converter_2_M_AXI_ARVALID;
  wire [31:0]axi_protocol_converter_2_M_AXI_AWADDR;
  wire [1:0]axi_protocol_converter_2_M_AXI_AWBURST;
  wire [3:0]axi_protocol_converter_2_M_AXI_AWCACHE;
  wire [11:0]axi_protocol_converter_2_M_AXI_AWID;
  wire [7:0]axi_protocol_converter_2_M_AXI_AWLEN;
  wire [0:0]axi_protocol_converter_2_M_AXI_AWLOCK;
  wire [2:0]axi_protocol_converter_2_M_AXI_AWPROT;
  wire [3:0]axi_protocol_converter_2_M_AXI_AWQOS;
  wire axi_protocol_converter_2_M_AXI_AWREADY;
  wire [3:0]axi_protocol_converter_2_M_AXI_AWREGION;
  wire [2:0]axi_protocol_converter_2_M_AXI_AWSIZE;
  wire axi_protocol_converter_2_M_AXI_AWVALID;
  wire [11:0]axi_protocol_converter_2_M_AXI_BID;
  wire axi_protocol_converter_2_M_AXI_BREADY;
  wire [1:0]axi_protocol_converter_2_M_AXI_BRESP;
  wire axi_protocol_converter_2_M_AXI_BVALID;
  wire [31:0]axi_protocol_converter_2_M_AXI_RDATA;
  wire [11:0]axi_protocol_converter_2_M_AXI_RID;
  wire axi_protocol_converter_2_M_AXI_RLAST;
  wire axi_protocol_converter_2_M_AXI_RREADY;
  wire [1:0]axi_protocol_converter_2_M_AXI_RRESP;
  wire axi_protocol_converter_2_M_AXI_RVALID;
  wire [31:0]axi_protocol_converter_2_M_AXI_WDATA;
  wire axi_protocol_converter_2_M_AXI_WLAST;
  wire axi_protocol_converter_2_M_AXI_WREADY;
  wire [3:0]axi_protocol_converter_2_M_AXI_WSTRB;
  wire axi_protocol_converter_2_M_AXI_WVALID;
  wire [31:0]axi_vdma_0_M_AXI_S2MM_AWADDR;
  wire [1:0]axi_vdma_0_M_AXI_S2MM_AWBURST;
  wire [3:0]axi_vdma_0_M_AXI_S2MM_AWCACHE;
  wire [7:0]axi_vdma_0_M_AXI_S2MM_AWLEN;
  wire [2:0]axi_vdma_0_M_AXI_S2MM_AWPROT;
  wire axi_vdma_0_M_AXI_S2MM_AWREADY;
  wire [2:0]axi_vdma_0_M_AXI_S2MM_AWSIZE;
  wire axi_vdma_0_M_AXI_S2MM_AWVALID;
  wire axi_vdma_0_M_AXI_S2MM_BREADY;
  wire [1:0]axi_vdma_0_M_AXI_S2MM_BRESP;
  wire axi_vdma_0_M_AXI_S2MM_BVALID;
  wire [63:0]axi_vdma_0_M_AXI_S2MM_WDATA;
  wire axi_vdma_0_M_AXI_S2MM_WLAST;
  wire axi_vdma_0_M_AXI_S2MM_WREADY;
  wire [7:0]axi_vdma_0_M_AXI_S2MM_WSTRB;
  wire axi_vdma_0_M_AXI_S2MM_WVALID;
  wire axi_vdma_0_s2mm_introut;
  wire csi_intr_1;
  wire elink2_CCLK_N;
  wire elink2_CCLK_P;
  wire [31:0]elink2_M00_AXI_ARADDR;
  wire [1:0]elink2_M00_AXI_ARBURST;
  wire [3:0]elink2_M00_AXI_ARCACHE;
  wire [0:0]elink2_M00_AXI_ARID;
  wire [7:0]elink2_M00_AXI_ARLEN;
  wire [0:0]elink2_M00_AXI_ARLOCK;
  wire [2:0]elink2_M00_AXI_ARPROT;
  wire [3:0]elink2_M00_AXI_ARQOS;
  wire elink2_M00_AXI_ARREADY;
  wire [2:0]elink2_M00_AXI_ARSIZE;
  wire elink2_M00_AXI_ARVALID;
  wire [31:0]elink2_M00_AXI_AWADDR;
  wire [1:0]elink2_M00_AXI_AWBURST;
  wire [3:0]elink2_M00_AXI_AWCACHE;
  wire [0:0]elink2_M00_AXI_AWID;
  wire [7:0]elink2_M00_AXI_AWLEN;
  wire [0:0]elink2_M00_AXI_AWLOCK;
  wire [2:0]elink2_M00_AXI_AWPROT;
  wire [3:0]elink2_M00_AXI_AWQOS;
  wire elink2_M00_AXI_AWREADY;
  wire [2:0]elink2_M00_AXI_AWSIZE;
  wire elink2_M00_AXI_AWVALID;
  wire [0:0]elink2_M00_AXI_BID;
  wire elink2_M00_AXI_BREADY;
  wire [1:0]elink2_M00_AXI_BRESP;
  wire elink2_M00_AXI_BVALID;
  wire [63:0]elink2_M00_AXI_RDATA;
  wire [0:0]elink2_M00_AXI_RID;
  wire elink2_M00_AXI_RLAST;
  wire elink2_M00_AXI_RREADY;
  wire [1:0]elink2_M00_AXI_RRESP;
  wire elink2_M00_AXI_RVALID;
  wire [63:0]elink2_M00_AXI_WDATA;
  wire elink2_M00_AXI_WLAST;
  wire elink2_M00_AXI_WREADY;
  wire [7:0]elink2_M00_AXI_WSTRB;
  wire elink2_M00_AXI_WVALID;
  wire [7:0]elink2_TX_data_n;
  wire [7:0]elink2_TX_data_p;
  wire elink2_TX_frame_n;
  wire elink2_TX_frame_p;
  wire elink2_TX_lclk_n;
  wire elink2_TX_lclk_p;
  wire elink2_TX_rd_wait_n;
  wire elink2_TX_rd_wait_p;
  wire elink2_TX_wr_wait_n;
  wire elink2_TX_wr_wait_p;
  wire [0:0]elink2_mcfg4_sw_reset;
  wire [0:0]proc_sys_reset_0_peripheral_aresetn;
  wire [0:0]proc_sys_reset_0_peripheral_reset;
  wire [14:0]processing_system7_0_DDR_ADDR;
  wire [2:0]processing_system7_0_DDR_BA;
  wire processing_system7_0_DDR_CAS_N;
  wire processing_system7_0_DDR_CKE;
  wire processing_system7_0_DDR_CK_N;
  wire processing_system7_0_DDR_CK_P;
  wire processing_system7_0_DDR_CS_N;
  wire [3:0]processing_system7_0_DDR_DM;
  wire [31:0]processing_system7_0_DDR_DQ;
  wire [3:0]processing_system7_0_DDR_DQS_N;
  wire [3:0]processing_system7_0_DDR_DQS_P;
  wire processing_system7_0_DDR_ODT;
  wire processing_system7_0_DDR_RAS_N;
  wire processing_system7_0_DDR_RESET_N;
  wire processing_system7_0_DDR_WE_N;
  wire processing_system7_0_FCLK_CLK0;
  wire processing_system7_0_FCLK_CLK1;
  wire processing_system7_0_FCLK_RESET0_N;
  wire processing_system7_0_FIXED_IO_DDR_VRN;
  wire processing_system7_0_FIXED_IO_DDR_VRP;
  wire [53:0]processing_system7_0_FIXED_IO_MIO;
  wire processing_system7_0_FIXED_IO_PS_CLK;
  wire processing_system7_0_FIXED_IO_PS_PORB;
  wire processing_system7_0_FIXED_IO_PS_SRSTB;
  wire [63:0]processing_system7_0_GPIO_0_TRI_I;
  wire [63:0]processing_system7_0_GPIO_0_TRI_O;
  wire [63:0]processing_system7_0_GPIO_0_TRI_T;
  wire processing_system7_0_IIC_0_SCL_I;
  wire processing_system7_0_IIC_0_SCL_O;
  wire processing_system7_0_IIC_0_SCL_T;
  wire processing_system7_0_IIC_0_SDA_I;
  wire processing_system7_0_IIC_0_SDA_O;
  wire processing_system7_0_IIC_0_SDA_T;
  wire processing_system7_0_IIC_1_SCL_I;
  wire processing_system7_0_IIC_1_SCL_O;
  wire processing_system7_0_IIC_1_SCL_T;
  wire processing_system7_0_IIC_1_SDA_I;
  wire processing_system7_0_IIC_1_SDA_O;
  wire processing_system7_0_IIC_1_SDA_T;
  wire [31:0]processing_system7_0_M_AXI_GP0_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_ARQOS;
  wire processing_system7_0_M_AXI_GP0_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_ARSIZE;
  wire processing_system7_0_M_AXI_GP0_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP0_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP0_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP0_AWQOS;
  wire processing_system7_0_M_AXI_GP0_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP0_AWSIZE;
  wire processing_system7_0_M_AXI_GP0_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP0_BID;
  wire processing_system7_0_M_AXI_GP0_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_BRESP;
  wire processing_system7_0_M_AXI_GP0_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_RID;
  wire processing_system7_0_M_AXI_GP0_RLAST;
  wire processing_system7_0_M_AXI_GP0_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP0_RRESP;
  wire processing_system7_0_M_AXI_GP0_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP0_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP0_WID;
  wire processing_system7_0_M_AXI_GP0_WLAST;
  wire processing_system7_0_M_AXI_GP0_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP0_WSTRB;
  wire processing_system7_0_M_AXI_GP0_WVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_ARADDR;
  wire [1:0]processing_system7_0_M_AXI_GP1_ARBURST;
  wire [3:0]processing_system7_0_M_AXI_GP1_ARCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP1_ARID;
  wire [3:0]processing_system7_0_M_AXI_GP1_ARLEN;
  wire [1:0]processing_system7_0_M_AXI_GP1_ARLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP1_ARPROT;
  wire [3:0]processing_system7_0_M_AXI_GP1_ARQOS;
  wire processing_system7_0_M_AXI_GP1_ARREADY;
  wire [2:0]processing_system7_0_M_AXI_GP1_ARSIZE;
  wire processing_system7_0_M_AXI_GP1_ARVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_AWADDR;
  wire [1:0]processing_system7_0_M_AXI_GP1_AWBURST;
  wire [3:0]processing_system7_0_M_AXI_GP1_AWCACHE;
  wire [11:0]processing_system7_0_M_AXI_GP1_AWID;
  wire [3:0]processing_system7_0_M_AXI_GP1_AWLEN;
  wire [1:0]processing_system7_0_M_AXI_GP1_AWLOCK;
  wire [2:0]processing_system7_0_M_AXI_GP1_AWPROT;
  wire [3:0]processing_system7_0_M_AXI_GP1_AWQOS;
  wire processing_system7_0_M_AXI_GP1_AWREADY;
  wire [2:0]processing_system7_0_M_AXI_GP1_AWSIZE;
  wire processing_system7_0_M_AXI_GP1_AWVALID;
  wire [11:0]processing_system7_0_M_AXI_GP1_BID;
  wire processing_system7_0_M_AXI_GP1_BREADY;
  wire [1:0]processing_system7_0_M_AXI_GP1_BRESP;
  wire processing_system7_0_M_AXI_GP1_BVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_RDATA;
  wire [11:0]processing_system7_0_M_AXI_GP1_RID;
  wire processing_system7_0_M_AXI_GP1_RLAST;
  wire processing_system7_0_M_AXI_GP1_RREADY;
  wire [1:0]processing_system7_0_M_AXI_GP1_RRESP;
  wire processing_system7_0_M_AXI_GP1_RVALID;
  wire [31:0]processing_system7_0_M_AXI_GP1_WDATA;
  wire [11:0]processing_system7_0_M_AXI_GP1_WID;
  wire processing_system7_0_M_AXI_GP1_WLAST;
  wire processing_system7_0_M_AXI_GP1_WREADY;
  wire [3:0]processing_system7_0_M_AXI_GP1_WSTRB;
  wire processing_system7_0_M_AXI_GP1_WVALID;
  wire [1:0]xlconcat_0_dout;

  assign CCLK_N = elink2_CCLK_N;
  assign CCLK_P = elink2_CCLK_P;
  assign CSI_AXI_araddr[31:0] = axi_lite_0_M02_AXI_ARADDR;
  assign CSI_AXI_arprot[2:0] = axi_lite_0_M02_AXI_ARPROT;
  assign CSI_AXI_arvalid[0] = axi_lite_0_M02_AXI_ARVALID;
  assign CSI_AXI_awaddr[31:0] = axi_lite_0_M02_AXI_AWADDR;
  assign CSI_AXI_awprot[2:0] = axi_lite_0_M02_AXI_AWPROT;
  assign CSI_AXI_awvalid[0] = axi_lite_0_M02_AXI_AWVALID;
  assign CSI_AXI_bready[0] = axi_lite_0_M02_AXI_BREADY;
  assign CSI_AXI_rready[0] = axi_lite_0_M02_AXI_RREADY;
  assign CSI_AXI_wdata[31:0] = axi_lite_0_M02_AXI_WDATA;
  assign CSI_AXI_wstrb[3:0] = axi_lite_0_M02_AXI_WSTRB;
  assign CSI_AXI_wvalid[0] = axi_lite_0_M02_AXI_WVALID;
  assign CSI_VIDEO_1_TDATA = CSI_VIDEO_tdata[31:0];
  assign CSI_VIDEO_1_TKEEP = CSI_VIDEO_tkeep[3:0];
  assign CSI_VIDEO_1_TLAST = CSI_VIDEO_tlast;
  assign CSI_VIDEO_1_TUSER = CSI_VIDEO_tuser[0];
  assign CSI_VIDEO_1_TVALID = CSI_VIDEO_tvalid;
  assign CSI_VIDEO_tready = CSI_VIDEO_1_TREADY;
  assign DSP_RESET_N[0] = elink2_mcfg4_sw_reset;
  assign FCLK_CLK0 = processing_system7_0_FCLK_CLK0;
  assign FCLK_CLK1 = processing_system7_0_FCLK_CLK1;
  assign GPIO_0_tri_o[63:0] = processing_system7_0_GPIO_0_TRI_O;
  assign GPIO_0_tri_t[63:0] = processing_system7_0_GPIO_0_TRI_T;
  assign RX_1_data_n = RX_data_n[7:0];
  assign RX_1_data_p = RX_data_p[7:0];
  assign RX_1_frame_n = RX_frame_n;
  assign RX_1_frame_p = RX_frame_p;
  assign RX_1_lclk_n = RX_lclk_n;
  assign RX_1_lclk_p = RX_lclk_p;
  assign RX_rd_wait_n = RX_1_rd_wait_n;
  assign RX_rd_wait_p = RX_1_rd_wait_p;
  assign RX_wr_wait_n = RX_1_wr_wait_n;
  assign RX_wr_wait_p = RX_1_wr_wait_p;
  assign TX_data_n[7:0] = elink2_TX_data_n;
  assign TX_data_p[7:0] = elink2_TX_data_p;
  assign TX_frame_n = elink2_TX_frame_n;
  assign TX_frame_p = elink2_TX_frame_p;
  assign TX_lclk_n = elink2_TX_lclk_n;
  assign TX_lclk_p = elink2_TX_lclk_p;
  assign aresetn[0] = proc_sys_reset_0_peripheral_aresetn;
  assign axi_lite_0_M02_AXI_ARREADY = CSI_AXI_arready[0];
  assign axi_lite_0_M02_AXI_AWREADY = CSI_AXI_awready[0];
  assign axi_lite_0_M02_AXI_BRESP = CSI_AXI_bresp[1:0];
  assign axi_lite_0_M02_AXI_BVALID = CSI_AXI_bvalid[0];
  assign axi_lite_0_M02_AXI_RDATA = CSI_AXI_rdata[31:0];
  assign axi_lite_0_M02_AXI_RRESP = CSI_AXI_rresp[1:0];
  assign axi_lite_0_M02_AXI_RVALID = CSI_AXI_rvalid[0];
  assign axi_lite_0_M02_AXI_WREADY = CSI_AXI_wready[0];
  assign csi_intr_1 = csi_intr;
  assign elink2_TX_rd_wait_n = TX_rd_wait_n;
  assign elink2_TX_rd_wait_p = TX_rd_wait_p;
  assign elink2_TX_wr_wait_n = TX_wr_wait_n;
  assign elink2_TX_wr_wait_p = TX_wr_wait_p;
  assign processing_system7_0_GPIO_0_TRI_I = GPIO_0_tri_i[63:0];
GND GND
       (.G(GND_1));
VCC VCC
       (.P(VCC_1));
elink2_top_axi_interconnect_0_0 axi_lite_0
       (.ACLK(processing_system7_0_FCLK_CLK0),
        .ARESETN(proc_sys_reset_0_peripheral_aresetn),
        .M00_ACLK(processing_system7_0_FCLK_CLK0),
        .M00_ARESETN(proc_sys_reset_0_peripheral_aresetn),
        .M00_AXI_araddr(axi_lite_0_M00_AXI_ARADDR),
        .M00_AXI_arprot(axi_lite_0_M00_AXI_ARPROT),
        .M00_AXI_arready(axi_lite_0_M00_AXI_ARREADY),
        .M00_AXI_arvalid(axi_lite_0_M00_AXI_ARVALID),
        .M00_AXI_awaddr(axi_lite_0_M00_AXI_AWADDR),
        .M00_AXI_awprot(axi_lite_0_M00_AXI_AWPROT),
        .M00_AXI_awready(axi_lite_0_M00_AXI_AWREADY),
        .M00_AXI_awvalid(axi_lite_0_M00_AXI_AWVALID),
        .M00_AXI_bready(axi_lite_0_M00_AXI_BREADY),
        .M00_AXI_bresp(axi_lite_0_M00_AXI_BRESP),
        .M00_AXI_bvalid(axi_lite_0_M00_AXI_BVALID),
        .M00_AXI_rdata(axi_lite_0_M00_AXI_RDATA),
        .M00_AXI_rready(axi_lite_0_M00_AXI_RREADY),
        .M00_AXI_rresp(axi_lite_0_M00_AXI_RRESP),
        .M00_AXI_rvalid(axi_lite_0_M00_AXI_RVALID),
        .M00_AXI_wdata(axi_lite_0_M00_AXI_WDATA),
        .M00_AXI_wready(axi_lite_0_M00_AXI_WREADY),
        .M00_AXI_wstrb(axi_lite_0_M00_AXI_WSTRB),
        .M00_AXI_wvalid(axi_lite_0_M00_AXI_WVALID),
        .M01_ACLK(processing_system7_0_FCLK_CLK0),
        .M01_ARESETN(proc_sys_reset_0_peripheral_aresetn),
        .M01_AXI_araddr(axi_lite_0_M01_AXI_ARADDR),
        .M01_AXI_arready(axi_lite_0_M01_AXI_ARREADY),
        .M01_AXI_arvalid(axi_lite_0_M01_AXI_ARVALID),
        .M01_AXI_awaddr(axi_lite_0_M01_AXI_AWADDR),
        .M01_AXI_awready(axi_lite_0_M01_AXI_AWREADY),
        .M01_AXI_awvalid(axi_lite_0_M01_AXI_AWVALID),
        .M01_AXI_bready(axi_lite_0_M01_AXI_BREADY),
        .M01_AXI_bresp(axi_lite_0_M01_AXI_BRESP),
        .M01_AXI_bvalid(axi_lite_0_M01_AXI_BVALID),
        .M01_AXI_rdata(axi_lite_0_M01_AXI_RDATA),
        .M01_AXI_rready(axi_lite_0_M01_AXI_RREADY),
        .M01_AXI_rresp(axi_lite_0_M01_AXI_RRESP),
        .M01_AXI_rvalid(axi_lite_0_M01_AXI_RVALID),
        .M01_AXI_wdata(axi_lite_0_M01_AXI_WDATA),
        .M01_AXI_wready(axi_lite_0_M01_AXI_WREADY),
        .M01_AXI_wvalid(axi_lite_0_M01_AXI_WVALID),
        .M02_ACLK(processing_system7_0_FCLK_CLK0),
        .M02_ARESETN(proc_sys_reset_0_peripheral_aresetn),
        .M02_AXI_araddr(axi_lite_0_M02_AXI_ARADDR),
        .M02_AXI_arprot(axi_lite_0_M02_AXI_ARPROT),
        .M02_AXI_arready(axi_lite_0_M02_AXI_ARREADY),
        .M02_AXI_arvalid(axi_lite_0_M02_AXI_ARVALID),
        .M02_AXI_awaddr(axi_lite_0_M02_AXI_AWADDR),
        .M02_AXI_awprot(axi_lite_0_M02_AXI_AWPROT),
        .M02_AXI_awready(axi_lite_0_M02_AXI_AWREADY),
        .M02_AXI_awvalid(axi_lite_0_M02_AXI_AWVALID),
        .M02_AXI_bready(axi_lite_0_M02_AXI_BREADY),
        .M02_AXI_bresp(axi_lite_0_M02_AXI_BRESP),
        .M02_AXI_bvalid(axi_lite_0_M02_AXI_BVALID),
        .M02_AXI_rdata(axi_lite_0_M02_AXI_RDATA),
        .M02_AXI_rready(axi_lite_0_M02_AXI_RREADY),
        .M02_AXI_rresp(axi_lite_0_M02_AXI_RRESP),
        .M02_AXI_rvalid(axi_lite_0_M02_AXI_RVALID),
        .M02_AXI_wdata(axi_lite_0_M02_AXI_WDATA),
        .M02_AXI_wready(axi_lite_0_M02_AXI_WREADY),
        .M02_AXI_wstrb(axi_lite_0_M02_AXI_WSTRB),
        .M02_AXI_wvalid(axi_lite_0_M02_AXI_WVALID),
        .S00_ACLK(processing_system7_0_FCLK_CLK0),
        .S00_ARESETN(proc_sys_reset_0_peripheral_aresetn),
        .S00_AXI_araddr(processing_system7_0_M_AXI_GP0_ARADDR),
        .S00_AXI_arburst(processing_system7_0_M_AXI_GP0_ARBURST),
        .S00_AXI_arcache(processing_system7_0_M_AXI_GP0_ARCACHE),
        .S00_AXI_arid(processing_system7_0_M_AXI_GP0_ARID),
        .S00_AXI_arlen(processing_system7_0_M_AXI_GP0_ARLEN),
        .S00_AXI_arlock(processing_system7_0_M_AXI_GP0_ARLOCK),
        .S00_AXI_arprot(processing_system7_0_M_AXI_GP0_ARPROT),
        .S00_AXI_arqos(processing_system7_0_M_AXI_GP0_ARQOS),
        .S00_AXI_arready(processing_system7_0_M_AXI_GP0_ARREADY),
        .S00_AXI_arsize(processing_system7_0_M_AXI_GP0_ARSIZE),
        .S00_AXI_arvalid(processing_system7_0_M_AXI_GP0_ARVALID),
        .S00_AXI_awaddr(processing_system7_0_M_AXI_GP0_AWADDR),
        .S00_AXI_awburst(processing_system7_0_M_AXI_GP0_AWBURST),
        .S00_AXI_awcache(processing_system7_0_M_AXI_GP0_AWCACHE),
        .S00_AXI_awid(processing_system7_0_M_AXI_GP0_AWID),
        .S00_AXI_awlen(processing_system7_0_M_AXI_GP0_AWLEN),
        .S00_AXI_awlock(processing_system7_0_M_AXI_GP0_AWLOCK),
        .S00_AXI_awprot(processing_system7_0_M_AXI_GP0_AWPROT),
        .S00_AXI_awqos(processing_system7_0_M_AXI_GP0_AWQOS),
        .S00_AXI_awready(processing_system7_0_M_AXI_GP0_AWREADY),
        .S00_AXI_awsize(processing_system7_0_M_AXI_GP0_AWSIZE),
        .S00_AXI_awvalid(processing_system7_0_M_AXI_GP0_AWVALID),
        .S00_AXI_bid(processing_system7_0_M_AXI_GP0_BID),
        .S00_AXI_bready(processing_system7_0_M_AXI_GP0_BREADY),
        .S00_AXI_bresp(processing_system7_0_M_AXI_GP0_BRESP),
        .S00_AXI_bvalid(processing_system7_0_M_AXI_GP0_BVALID),
        .S00_AXI_rdata(processing_system7_0_M_AXI_GP0_RDATA),
        .S00_AXI_rid(processing_system7_0_M_AXI_GP0_RID),
        .S00_AXI_rlast(processing_system7_0_M_AXI_GP0_RLAST),
        .S00_AXI_rready(processing_system7_0_M_AXI_GP0_RREADY),
        .S00_AXI_rresp(processing_system7_0_M_AXI_GP0_RRESP),
        .S00_AXI_rvalid(processing_system7_0_M_AXI_GP0_RVALID),
        .S00_AXI_wdata(processing_system7_0_M_AXI_GP0_WDATA),
        .S00_AXI_wid(processing_system7_0_M_AXI_GP0_WID),
        .S00_AXI_wlast(processing_system7_0_M_AXI_GP0_WLAST),
        .S00_AXI_wready(processing_system7_0_M_AXI_GP0_WREADY),
        .S00_AXI_wstrb(processing_system7_0_M_AXI_GP0_WSTRB),
        .S00_AXI_wvalid(processing_system7_0_M_AXI_GP0_WVALID));
elink2_top_axi_protocol_converter_0_0 axi_protocol_converter_0
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_araddr(axi_protocol_converter_0_M_AXI_ARADDR),
        .m_axi_arburst(axi_protocol_converter_0_M_AXI_ARBURST),
        .m_axi_arcache(axi_protocol_converter_0_M_AXI_ARCACHE),
        .m_axi_arid(axi_protocol_converter_0_M_AXI_ARID),
        .m_axi_arlen(axi_protocol_converter_0_M_AXI_ARLEN),
        .m_axi_arlock(axi_protocol_converter_0_M_AXI_ARLOCK),
        .m_axi_arprot(axi_protocol_converter_0_M_AXI_ARPROT),
        .m_axi_arqos(axi_protocol_converter_0_M_AXI_ARQOS),
        .m_axi_arready(axi_protocol_converter_0_M_AXI_ARREADY),
        .m_axi_arsize(axi_protocol_converter_0_M_AXI_ARSIZE),
        .m_axi_arvalid(axi_protocol_converter_0_M_AXI_ARVALID),
        .m_axi_awaddr(axi_protocol_converter_0_M_AXI_AWADDR),
        .m_axi_awburst(axi_protocol_converter_0_M_AXI_AWBURST),
        .m_axi_awcache(axi_protocol_converter_0_M_AXI_AWCACHE),
        .m_axi_awid(axi_protocol_converter_0_M_AXI_AWID),
        .m_axi_awlen(axi_protocol_converter_0_M_AXI_AWLEN),
        .m_axi_awlock(axi_protocol_converter_0_M_AXI_AWLOCK),
        .m_axi_awprot(axi_protocol_converter_0_M_AXI_AWPROT),
        .m_axi_awqos(axi_protocol_converter_0_M_AXI_AWQOS),
        .m_axi_awready(axi_protocol_converter_0_M_AXI_AWREADY),
        .m_axi_awsize(axi_protocol_converter_0_M_AXI_AWSIZE),
        .m_axi_awvalid(axi_protocol_converter_0_M_AXI_AWVALID),
        .m_axi_bid(axi_protocol_converter_0_M_AXI_BID[0]),
        .m_axi_bready(axi_protocol_converter_0_M_AXI_BREADY),
        .m_axi_bresp(axi_protocol_converter_0_M_AXI_BRESP),
        .m_axi_bvalid(axi_protocol_converter_0_M_AXI_BVALID),
        .m_axi_rdata(axi_protocol_converter_0_M_AXI_RDATA),
        .m_axi_rid(axi_protocol_converter_0_M_AXI_RID[0]),
        .m_axi_rlast(axi_protocol_converter_0_M_AXI_RLAST),
        .m_axi_rready(axi_protocol_converter_0_M_AXI_RREADY),
        .m_axi_rresp(axi_protocol_converter_0_M_AXI_RRESP),
        .m_axi_rvalid(axi_protocol_converter_0_M_AXI_RVALID),
        .m_axi_wdata(axi_protocol_converter_0_M_AXI_WDATA),
        .m_axi_wid(axi_protocol_converter_0_M_AXI_WID),
        .m_axi_wlast(axi_protocol_converter_0_M_AXI_WLAST),
        .m_axi_wready(axi_protocol_converter_0_M_AXI_WREADY),
        .m_axi_wstrb(axi_protocol_converter_0_M_AXI_WSTRB),
        .m_axi_wvalid(axi_protocol_converter_0_M_AXI_WVALID),
        .s_axi_araddr(elink2_M00_AXI_ARADDR),
        .s_axi_arburst(elink2_M00_AXI_ARBURST),
        .s_axi_arcache(elink2_M00_AXI_ARCACHE),
        .s_axi_arid(elink2_M00_AXI_ARID),
        .s_axi_arlen(elink2_M00_AXI_ARLEN),
        .s_axi_arlock(elink2_M00_AXI_ARLOCK),
        .s_axi_arprot(elink2_M00_AXI_ARPROT),
        .s_axi_arqos(elink2_M00_AXI_ARQOS),
        .s_axi_arready(elink2_M00_AXI_ARREADY),
        .s_axi_arregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_arsize(elink2_M00_AXI_ARSIZE),
        .s_axi_arvalid(elink2_M00_AXI_ARVALID),
        .s_axi_awaddr(elink2_M00_AXI_AWADDR),
        .s_axi_awburst(elink2_M00_AXI_AWBURST),
        .s_axi_awcache(elink2_M00_AXI_AWCACHE),
        .s_axi_awid(elink2_M00_AXI_AWID),
        .s_axi_awlen(elink2_M00_AXI_AWLEN),
        .s_axi_awlock(elink2_M00_AXI_AWLOCK),
        .s_axi_awprot(elink2_M00_AXI_AWPROT),
        .s_axi_awqos(elink2_M00_AXI_AWQOS),
        .s_axi_awready(elink2_M00_AXI_AWREADY),
        .s_axi_awregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awsize(elink2_M00_AXI_AWSIZE),
        .s_axi_awvalid(elink2_M00_AXI_AWVALID),
        .s_axi_bid(elink2_M00_AXI_BID),
        .s_axi_bready(elink2_M00_AXI_BREADY),
        .s_axi_bresp(elink2_M00_AXI_BRESP),
        .s_axi_bvalid(elink2_M00_AXI_BVALID),
        .s_axi_rdata(elink2_M00_AXI_RDATA),
        .s_axi_rid(elink2_M00_AXI_RID),
        .s_axi_rlast(elink2_M00_AXI_RLAST),
        .s_axi_rready(elink2_M00_AXI_RREADY),
        .s_axi_rresp(elink2_M00_AXI_RRESP),
        .s_axi_rvalid(elink2_M00_AXI_RVALID),
        .s_axi_wdata(elink2_M00_AXI_WDATA),
        .s_axi_wlast(elink2_M00_AXI_WLAST),
        .s_axi_wready(elink2_M00_AXI_WREADY),
        .s_axi_wstrb(elink2_M00_AXI_WSTRB),
        .s_axi_wvalid(elink2_M00_AXI_WVALID));
elink2_top_axi_protocol_converter_0_3 axi_protocol_converter_1
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_awaddr(axi_protocol_converter_1_M_AXI_AWADDR),
        .m_axi_awburst(axi_protocol_converter_1_M_AXI_AWBURST),
        .m_axi_awcache(axi_protocol_converter_1_M_AXI_AWCACHE),
        .m_axi_awlen(axi_protocol_converter_1_M_AXI_AWLEN),
        .m_axi_awlock(axi_protocol_converter_1_M_AXI_AWLOCK),
        .m_axi_awprot(axi_protocol_converter_1_M_AXI_AWPROT),
        .m_axi_awqos(axi_protocol_converter_1_M_AXI_AWQOS),
        .m_axi_awready(axi_protocol_converter_1_M_AXI_AWREADY),
        .m_axi_awsize(axi_protocol_converter_1_M_AXI_AWSIZE),
        .m_axi_awvalid(axi_protocol_converter_1_M_AXI_AWVALID),
        .m_axi_bready(axi_protocol_converter_1_M_AXI_BREADY),
        .m_axi_bresp(axi_protocol_converter_1_M_AXI_BRESP),
        .m_axi_bvalid(axi_protocol_converter_1_M_AXI_BVALID),
        .m_axi_wdata(axi_protocol_converter_1_M_AXI_WDATA),
        .m_axi_wlast(axi_protocol_converter_1_M_AXI_WLAST),
        .m_axi_wready(axi_protocol_converter_1_M_AXI_WREADY),
        .m_axi_wstrb(axi_protocol_converter_1_M_AXI_WSTRB),
        .m_axi_wvalid(axi_protocol_converter_1_M_AXI_WVALID),
        .s_axi_awaddr(axi_vdma_0_M_AXI_S2MM_AWADDR),
        .s_axi_awburst(axi_vdma_0_M_AXI_S2MM_AWBURST),
        .s_axi_awcache(axi_vdma_0_M_AXI_S2MM_AWCACHE),
        .s_axi_awlen(axi_vdma_0_M_AXI_S2MM_AWLEN),
        .s_axi_awlock(GND_1),
        .s_axi_awprot(axi_vdma_0_M_AXI_S2MM_AWPROT),
        .s_axi_awqos({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awready(axi_vdma_0_M_AXI_S2MM_AWREADY),
        .s_axi_awregion({GND_1,GND_1,GND_1,GND_1}),
        .s_axi_awsize(axi_vdma_0_M_AXI_S2MM_AWSIZE),
        .s_axi_awvalid(axi_vdma_0_M_AXI_S2MM_AWVALID),
        .s_axi_bready(axi_vdma_0_M_AXI_S2MM_BREADY),
        .s_axi_bresp(axi_vdma_0_M_AXI_S2MM_BRESP),
        .s_axi_bvalid(axi_vdma_0_M_AXI_S2MM_BVALID),
        .s_axi_wdata(axi_vdma_0_M_AXI_S2MM_WDATA),
        .s_axi_wlast(axi_vdma_0_M_AXI_S2MM_WLAST),
        .s_axi_wready(axi_vdma_0_M_AXI_S2MM_WREADY),
        .s_axi_wstrb(axi_vdma_0_M_AXI_S2MM_WSTRB),
        .s_axi_wvalid(axi_vdma_0_M_AXI_S2MM_WVALID));
elink2_top_axi_protocol_converter_0_2 axi_protocol_converter_2
       (.aclk(processing_system7_0_FCLK_CLK0),
        .aresetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_araddr(axi_protocol_converter_2_M_AXI_ARADDR),
        .m_axi_arburst(axi_protocol_converter_2_M_AXI_ARBURST),
        .m_axi_arcache(axi_protocol_converter_2_M_AXI_ARCACHE),
        .m_axi_arid(axi_protocol_converter_2_M_AXI_ARID),
        .m_axi_arlen(axi_protocol_converter_2_M_AXI_ARLEN),
        .m_axi_arlock(axi_protocol_converter_2_M_AXI_ARLOCK),
        .m_axi_arprot(axi_protocol_converter_2_M_AXI_ARPROT),
        .m_axi_arqos(axi_protocol_converter_2_M_AXI_ARQOS),
        .m_axi_arready(axi_protocol_converter_2_M_AXI_ARREADY),
        .m_axi_arregion(axi_protocol_converter_2_M_AXI_ARREGION),
        .m_axi_arsize(axi_protocol_converter_2_M_AXI_ARSIZE),
        .m_axi_arvalid(axi_protocol_converter_2_M_AXI_ARVALID),
        .m_axi_awaddr(axi_protocol_converter_2_M_AXI_AWADDR),
        .m_axi_awburst(axi_protocol_converter_2_M_AXI_AWBURST),
        .m_axi_awcache(axi_protocol_converter_2_M_AXI_AWCACHE),
        .m_axi_awid(axi_protocol_converter_2_M_AXI_AWID),
        .m_axi_awlen(axi_protocol_converter_2_M_AXI_AWLEN),
        .m_axi_awlock(axi_protocol_converter_2_M_AXI_AWLOCK),
        .m_axi_awprot(axi_protocol_converter_2_M_AXI_AWPROT),
        .m_axi_awqos(axi_protocol_converter_2_M_AXI_AWQOS),
        .m_axi_awready(axi_protocol_converter_2_M_AXI_AWREADY),
        .m_axi_awregion(axi_protocol_converter_2_M_AXI_AWREGION),
        .m_axi_awsize(axi_protocol_converter_2_M_AXI_AWSIZE),
        .m_axi_awvalid(axi_protocol_converter_2_M_AXI_AWVALID),
        .m_axi_bid(axi_protocol_converter_2_M_AXI_BID),
        .m_axi_bready(axi_protocol_converter_2_M_AXI_BREADY),
        .m_axi_bresp(axi_protocol_converter_2_M_AXI_BRESP),
        .m_axi_bvalid(axi_protocol_converter_2_M_AXI_BVALID),
        .m_axi_rdata(axi_protocol_converter_2_M_AXI_RDATA),
        .m_axi_rid(axi_protocol_converter_2_M_AXI_RID),
        .m_axi_rlast(axi_protocol_converter_2_M_AXI_RLAST),
        .m_axi_rready(axi_protocol_converter_2_M_AXI_RREADY),
        .m_axi_rresp(axi_protocol_converter_2_M_AXI_RRESP),
        .m_axi_rvalid(axi_protocol_converter_2_M_AXI_RVALID),
        .m_axi_wdata(axi_protocol_converter_2_M_AXI_WDATA),
        .m_axi_wlast(axi_protocol_converter_2_M_AXI_WLAST),
        .m_axi_wready(axi_protocol_converter_2_M_AXI_WREADY),
        .m_axi_wstrb(axi_protocol_converter_2_M_AXI_WSTRB),
        .m_axi_wvalid(axi_protocol_converter_2_M_AXI_WVALID),
        .s_axi_araddr(processing_system7_0_M_AXI_GP1_ARADDR),
        .s_axi_arburst(processing_system7_0_M_AXI_GP1_ARBURST),
        .s_axi_arcache(processing_system7_0_M_AXI_GP1_ARCACHE),
        .s_axi_arid(processing_system7_0_M_AXI_GP1_ARID),
        .s_axi_arlen(processing_system7_0_M_AXI_GP1_ARLEN),
        .s_axi_arlock(processing_system7_0_M_AXI_GP1_ARLOCK),
        .s_axi_arprot(processing_system7_0_M_AXI_GP1_ARPROT),
        .s_axi_arqos(processing_system7_0_M_AXI_GP1_ARQOS),
        .s_axi_arready(processing_system7_0_M_AXI_GP1_ARREADY),
        .s_axi_arsize(processing_system7_0_M_AXI_GP1_ARSIZE),
        .s_axi_arvalid(processing_system7_0_M_AXI_GP1_ARVALID),
        .s_axi_awaddr(processing_system7_0_M_AXI_GP1_AWADDR),
        .s_axi_awburst(processing_system7_0_M_AXI_GP1_AWBURST),
        .s_axi_awcache(processing_system7_0_M_AXI_GP1_AWCACHE),
        .s_axi_awid(processing_system7_0_M_AXI_GP1_AWID),
        .s_axi_awlen(processing_system7_0_M_AXI_GP1_AWLEN),
        .s_axi_awlock(processing_system7_0_M_AXI_GP1_AWLOCK),
        .s_axi_awprot(processing_system7_0_M_AXI_GP1_AWPROT),
        .s_axi_awqos(processing_system7_0_M_AXI_GP1_AWQOS),
        .s_axi_awready(processing_system7_0_M_AXI_GP1_AWREADY),
        .s_axi_awsize(processing_system7_0_M_AXI_GP1_AWSIZE),
        .s_axi_awvalid(processing_system7_0_M_AXI_GP1_AWVALID),
        .s_axi_bid(processing_system7_0_M_AXI_GP1_BID),
        .s_axi_bready(processing_system7_0_M_AXI_GP1_BREADY),
        .s_axi_bresp(processing_system7_0_M_AXI_GP1_BRESP),
        .s_axi_bvalid(processing_system7_0_M_AXI_GP1_BVALID),
        .s_axi_rdata(processing_system7_0_M_AXI_GP1_RDATA),
        .s_axi_rid(processing_system7_0_M_AXI_GP1_RID),
        .s_axi_rlast(processing_system7_0_M_AXI_GP1_RLAST),
        .s_axi_rready(processing_system7_0_M_AXI_GP1_RREADY),
        .s_axi_rresp(processing_system7_0_M_AXI_GP1_RRESP),
        .s_axi_rvalid(processing_system7_0_M_AXI_GP1_RVALID),
        .s_axi_wdata(processing_system7_0_M_AXI_GP1_WDATA),
        .s_axi_wid(processing_system7_0_M_AXI_GP1_WID),
        .s_axi_wlast(processing_system7_0_M_AXI_GP1_WLAST),
        .s_axi_wready(processing_system7_0_M_AXI_GP1_WREADY),
        .s_axi_wstrb(processing_system7_0_M_AXI_GP1_WSTRB),
        .s_axi_wvalid(processing_system7_0_M_AXI_GP1_WVALID));
elink2_top_axi_vdma_0_0 axi_vdma_0
       (.axi_resetn(proc_sys_reset_0_peripheral_aresetn),
        .m_axi_s2mm_aclk(processing_system7_0_FCLK_CLK0),
        .m_axi_s2mm_awaddr(axi_vdma_0_M_AXI_S2MM_AWADDR),
        .m_axi_s2mm_awburst(axi_vdma_0_M_AXI_S2MM_AWBURST),
        .m_axi_s2mm_awcache(axi_vdma_0_M_AXI_S2MM_AWCACHE),
        .m_axi_s2mm_awlen(axi_vdma_0_M_AXI_S2MM_AWLEN),
        .m_axi_s2mm_awprot(axi_vdma_0_M_AXI_S2MM_AWPROT),
        .m_axi_s2mm_awready(axi_vdma_0_M_AXI_S2MM_AWREADY),
        .m_axi_s2mm_awsize(axi_vdma_0_M_AXI_S2MM_AWSIZE),
        .m_axi_s2mm_awvalid(axi_vdma_0_M_AXI_S2MM_AWVALID),
        .m_axi_s2mm_bready(axi_vdma_0_M_AXI_S2MM_BREADY),
        .m_axi_s2mm_bresp(axi_vdma_0_M_AXI_S2MM_BRESP),
        .m_axi_s2mm_bvalid(axi_vdma_0_M_AXI_S2MM_BVALID),
        .m_axi_s2mm_wdata(axi_vdma_0_M_AXI_S2MM_WDATA),
        .m_axi_s2mm_wlast(axi_vdma_0_M_AXI_S2MM_WLAST),
        .m_axi_s2mm_wready(axi_vdma_0_M_AXI_S2MM_WREADY),
        .m_axi_s2mm_wstrb(axi_vdma_0_M_AXI_S2MM_WSTRB),
        .m_axi_s2mm_wvalid(axi_vdma_0_M_AXI_S2MM_WVALID),
        .s2mm_frame_ptr_in({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .s2mm_introut(axi_vdma_0_s2mm_introut),
        .s_axi_lite_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_lite_araddr(axi_lite_0_M01_AXI_ARADDR),
        .s_axi_lite_arready(axi_lite_0_M01_AXI_ARREADY),
        .s_axi_lite_arvalid(axi_lite_0_M01_AXI_ARVALID),
        .s_axi_lite_awaddr(axi_lite_0_M01_AXI_AWADDR),
        .s_axi_lite_awready(axi_lite_0_M01_AXI_AWREADY),
        .s_axi_lite_awvalid(axi_lite_0_M01_AXI_AWVALID),
        .s_axi_lite_bready(axi_lite_0_M01_AXI_BREADY),
        .s_axi_lite_bresp(axi_lite_0_M01_AXI_BRESP),
        .s_axi_lite_bvalid(axi_lite_0_M01_AXI_BVALID),
        .s_axi_lite_rdata(axi_lite_0_M01_AXI_RDATA),
        .s_axi_lite_rready(axi_lite_0_M01_AXI_RREADY),
        .s_axi_lite_rresp(axi_lite_0_M01_AXI_RRESP),
        .s_axi_lite_rvalid(axi_lite_0_M01_AXI_RVALID),
        .s_axi_lite_wdata(axi_lite_0_M01_AXI_WDATA),
        .s_axi_lite_wready(axi_lite_0_M01_AXI_WREADY),
        .s_axi_lite_wvalid(axi_lite_0_M01_AXI_WVALID),
        .s_axis_s2mm_aclk(processing_system7_0_FCLK_CLK0),
        .s_axis_s2mm_tdata(CSI_VIDEO_1_TDATA),
        .s_axis_s2mm_tkeep(CSI_VIDEO_1_TKEEP),
        .s_axis_s2mm_tlast(CSI_VIDEO_1_TLAST),
        .s_axis_s2mm_tready(CSI_VIDEO_1_TREADY),
        .s_axis_s2mm_tuser(CSI_VIDEO_1_TUSER),
        .s_axis_s2mm_tvalid(CSI_VIDEO_1_TVALID));
elink2_imp_1JQ28BR elink2
       (.CCLK_N(elink2_CCLK_N),
        .CCLK_P(elink2_CCLK_P),
        .DSP_RESET_N(elink2_mcfg4_sw_reset),
        .EMM_TOMMU_access(EMS_FROMMMU_1_access),
        .EMM_TOMMU_ctrlmode(EMS_FROMMMU_1_ctrlmode),
        .EMM_TOMMU_data(EMS_FROMMMU_1_data),
        .EMM_TOMMU_datamode(EMS_FROMMMU_1_datamode),
        .EMM_TOMMU_dstaddr(EMS_FROMMMU_1_dstaddr),
        .EMM_TOMMU_srcaddr(EMS_FROMMMU_1_srcaddr),
        .EMM_TOMMU_write(EMS_FROMMMU_1_write),
        .EMS_FROMMMU_access(EMS_FROMMMU_1_access),
        .EMS_FROMMMU_ctrlmode(EMS_FROMMMU_1_ctrlmode),
        .EMS_FROMMMU_data(EMS_FROMMMU_1_data),
        .EMS_FROMMMU_datamode(EMS_FROMMMU_1_datamode),
        .EMS_FROMMMU_dstaddr(EMS_FROMMMU_1_dstaddr),
        .EMS_FROMMMU_srcaddr(EMS_FROMMMU_1_srcaddr),
        .EMS_FROMMMU_write(EMS_FROMMMU_1_write),
        .M00_AXI_araddr(elink2_M00_AXI_ARADDR),
        .M00_AXI_arburst(elink2_M00_AXI_ARBURST),
        .M00_AXI_arcache(elink2_M00_AXI_ARCACHE),
        .M00_AXI_arid(elink2_M00_AXI_ARID),
        .M00_AXI_arlen(elink2_M00_AXI_ARLEN),
        .M00_AXI_arlock(elink2_M00_AXI_ARLOCK),
        .M00_AXI_arprot(elink2_M00_AXI_ARPROT),
        .M00_AXI_arqos(elink2_M00_AXI_ARQOS),
        .M00_AXI_arready(elink2_M00_AXI_ARREADY),
        .M00_AXI_arsize(elink2_M00_AXI_ARSIZE),
        .M00_AXI_arvalid(elink2_M00_AXI_ARVALID),
        .M00_AXI_awaddr(elink2_M00_AXI_AWADDR),
        .M00_AXI_awburst(elink2_M00_AXI_AWBURST),
        .M00_AXI_awcache(elink2_M00_AXI_AWCACHE),
        .M00_AXI_awid(elink2_M00_AXI_AWID),
        .M00_AXI_awlen(elink2_M00_AXI_AWLEN),
        .M00_AXI_awlock(elink2_M00_AXI_AWLOCK),
        .M00_AXI_awprot(elink2_M00_AXI_AWPROT),
        .M00_AXI_awqos(elink2_M00_AXI_AWQOS),
        .M00_AXI_awready(elink2_M00_AXI_AWREADY),
        .M00_AXI_awsize(elink2_M00_AXI_AWSIZE),
        .M00_AXI_awvalid(elink2_M00_AXI_AWVALID),
        .M00_AXI_bid(elink2_M00_AXI_BID),
        .M00_AXI_bready(elink2_M00_AXI_BREADY),
        .M00_AXI_bresp(elink2_M00_AXI_BRESP),
        .M00_AXI_bvalid(elink2_M00_AXI_BVALID),
        .M00_AXI_rdata(elink2_M00_AXI_RDATA),
        .M00_AXI_rid(elink2_M00_AXI_RID),
        .M00_AXI_rlast(elink2_M00_AXI_RLAST),
        .M00_AXI_rready(elink2_M00_AXI_RREADY),
        .M00_AXI_rresp(elink2_M00_AXI_RRESP),
        .M00_AXI_rvalid(elink2_M00_AXI_RVALID),
        .M00_AXI_wdata(elink2_M00_AXI_WDATA),
        .M00_AXI_wlast(elink2_M00_AXI_WLAST),
        .M00_AXI_wready(elink2_M00_AXI_WREADY),
        .M00_AXI_wstrb(elink2_M00_AXI_WSTRB),
        .M00_AXI_wvalid(elink2_M00_AXI_WVALID),
        .RX_data_n(RX_1_data_n),
        .RX_data_p(RX_1_data_p),
        .RX_frame_n(RX_1_frame_n),
        .RX_frame_p(RX_1_frame_p),
        .RX_lclk_n(RX_1_lclk_n),
        .RX_lclk_p(RX_1_lclk_p),
        .RX_rd_wait_n(RX_1_rd_wait_n),
        .RX_rd_wait_p(RX_1_rd_wait_p),
        .RX_wr_wait_n(RX_1_wr_wait_n),
        .RX_wr_wait_p(RX_1_wr_wait_p),
        .S00_AXI_araddr(axi_protocol_converter_2_M_AXI_ARADDR[29:0]),
        .S00_AXI_arburst(axi_protocol_converter_2_M_AXI_ARBURST),
        .S00_AXI_arcache(axi_protocol_converter_2_M_AXI_ARCACHE),
        .S00_AXI_arid(axi_protocol_converter_2_M_AXI_ARID),
        .S00_AXI_arlen(axi_protocol_converter_2_M_AXI_ARLEN),
        .S00_AXI_arlock(axi_protocol_converter_2_M_AXI_ARLOCK),
        .S00_AXI_arprot(axi_protocol_converter_2_M_AXI_ARPROT),
        .S00_AXI_arqos(axi_protocol_converter_2_M_AXI_ARQOS),
        .S00_AXI_arready(axi_protocol_converter_2_M_AXI_ARREADY),
        .S00_AXI_arregion(axi_protocol_converter_2_M_AXI_ARREGION),
        .S00_AXI_arsize(axi_protocol_converter_2_M_AXI_ARSIZE),
        .S00_AXI_arvalid(axi_protocol_converter_2_M_AXI_ARVALID),
        .S00_AXI_awaddr(axi_protocol_converter_2_M_AXI_AWADDR[29:0]),
        .S00_AXI_awburst(axi_protocol_converter_2_M_AXI_AWBURST),
        .S00_AXI_awcache(axi_protocol_converter_2_M_AXI_AWCACHE),
        .S00_AXI_awid(axi_protocol_converter_2_M_AXI_AWID),
        .S00_AXI_awlen(axi_protocol_converter_2_M_AXI_AWLEN),
        .S00_AXI_awlock(axi_protocol_converter_2_M_AXI_AWLOCK),
        .S00_AXI_awprot(axi_protocol_converter_2_M_AXI_AWPROT),
        .S00_AXI_awqos(axi_protocol_converter_2_M_AXI_AWQOS),
        .S00_AXI_awready(axi_protocol_converter_2_M_AXI_AWREADY),
        .S00_AXI_awregion(axi_protocol_converter_2_M_AXI_AWREGION),
        .S00_AXI_awsize(axi_protocol_converter_2_M_AXI_AWSIZE),
        .S00_AXI_awvalid(axi_protocol_converter_2_M_AXI_AWVALID),
        .S00_AXI_bid(axi_protocol_converter_2_M_AXI_BID),
        .S00_AXI_bready(axi_protocol_converter_2_M_AXI_BREADY),
        .S00_AXI_bresp(axi_protocol_converter_2_M_AXI_BRESP),
        .S00_AXI_bvalid(axi_protocol_converter_2_M_AXI_BVALID),
        .S00_AXI_rdata(axi_protocol_converter_2_M_AXI_RDATA),
        .S00_AXI_rid(axi_protocol_converter_2_M_AXI_RID),
        .S00_AXI_rlast(axi_protocol_converter_2_M_AXI_RLAST),
        .S00_AXI_rready(axi_protocol_converter_2_M_AXI_RREADY),
        .S00_AXI_rresp(axi_protocol_converter_2_M_AXI_RRESP),
        .S00_AXI_rvalid(axi_protocol_converter_2_M_AXI_RVALID),
        .S00_AXI_wdata(axi_protocol_converter_2_M_AXI_WDATA),
        .S00_AXI_wlast(axi_protocol_converter_2_M_AXI_WLAST),
        .S00_AXI_wready(axi_protocol_converter_2_M_AXI_WREADY),
        .S00_AXI_wstrb(axi_protocol_converter_2_M_AXI_WSTRB),
        .S00_AXI_wvalid(axi_protocol_converter_2_M_AXI_WVALID),
        .S_AXI_CFG_araddr(axi_lite_0_M00_AXI_ARADDR),
        .S_AXI_CFG_arprot(axi_lite_0_M00_AXI_ARPROT),
        .S_AXI_CFG_arready(axi_lite_0_M00_AXI_ARREADY),
        .S_AXI_CFG_arvalid(axi_lite_0_M00_AXI_ARVALID),
        .S_AXI_CFG_awaddr(axi_lite_0_M00_AXI_AWADDR),
        .S_AXI_CFG_awprot(axi_lite_0_M00_AXI_AWPROT),
        .S_AXI_CFG_awready(axi_lite_0_M00_AXI_AWREADY),
        .S_AXI_CFG_awvalid(axi_lite_0_M00_AXI_AWVALID),
        .S_AXI_CFG_bready(axi_lite_0_M00_AXI_BREADY),
        .S_AXI_CFG_bresp(axi_lite_0_M00_AXI_BRESP),
        .S_AXI_CFG_bvalid(axi_lite_0_M00_AXI_BVALID),
        .S_AXI_CFG_rdata(axi_lite_0_M00_AXI_RDATA),
        .S_AXI_CFG_rready(axi_lite_0_M00_AXI_RREADY),
        .S_AXI_CFG_rresp(axi_lite_0_M00_AXI_RRESP),
        .S_AXI_CFG_rvalid(axi_lite_0_M00_AXI_RVALID),
        .S_AXI_CFG_wdata(axi_lite_0_M00_AXI_WDATA),
        .S_AXI_CFG_wready(axi_lite_0_M00_AXI_WREADY),
        .S_AXI_CFG_wstrb(axi_lite_0_M00_AXI_WSTRB),
        .S_AXI_CFG_wvalid(axi_lite_0_M00_AXI_WVALID),
        .TX_data_n(elink2_TX_data_n),
        .TX_data_p(elink2_TX_data_p),
        .TX_frame_n(elink2_TX_frame_n),
        .TX_frame_p(elink2_TX_frame_p),
        .TX_lclk_n(elink2_TX_lclk_n),
        .TX_lclk_p(elink2_TX_lclk_p),
        .TX_rd_wait_n(elink2_TX_rd_wait_n),
        .TX_rd_wait_p(elink2_TX_rd_wait_p),
        .TX_wr_wait_n(elink2_TX_wr_wait_n),
        .TX_wr_wait_p(elink2_TX_wr_wait_p),
        .clkin(processing_system7_0_FCLK_CLK0),
        .m00_axi_aclk(processing_system7_0_FCLK_CLK0),
        .m00_axi_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .reset(proc_sys_reset_0_peripheral_reset),
        .s00_axi_aclk(processing_system7_0_FCLK_CLK0),
        .s00_axi_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .s_axi_aclk(processing_system7_0_FCLK_CLK0),
        .s_axi_aresetn(proc_sys_reset_0_peripheral_aresetn));
elink2_top_parallella_i2c_0_0 parallella_i2c_0
       (.I2C_SCL(I2C_SCL),
        .I2C_SCL_I(processing_system7_0_IIC_0_SCL_I),
        .I2C_SCL_O(processing_system7_0_IIC_0_SCL_O),
        .I2C_SCL_T(processing_system7_0_IIC_0_SCL_T),
        .I2C_SDA(I2C_SDA),
        .I2C_SDA_I(processing_system7_0_IIC_0_SDA_I),
        .I2C_SDA_O(processing_system7_0_IIC_0_SDA_O),
        .I2C_SDA_T(processing_system7_0_IIC_0_SDA_T));
elink2_top_parallella_i2c_0_1 parallella_i2c_1
       (.I2C_SCL(CAM_I2C_SCL),
        .I2C_SCL_I(processing_system7_0_IIC_1_SCL_I),
        .I2C_SCL_O(processing_system7_0_IIC_1_SCL_O),
        .I2C_SCL_T(processing_system7_0_IIC_1_SCL_T),
        .I2C_SDA(CAM_I2C_SDA),
        .I2C_SDA_I(processing_system7_0_IIC_1_SDA_I),
        .I2C_SDA_O(processing_system7_0_IIC_1_SDA_O),
        .I2C_SDA_T(processing_system7_0_IIC_1_SDA_T));
elink2_top_proc_sys_reset_0_0 proc_sys_reset_0
       (.aux_reset_in(VCC_1),
        .dcm_locked(VCC_1),
        .ext_reset_in(processing_system7_0_FCLK_RESET0_N),
        .mb_debug_sys_rst(GND_1),
        .peripheral_aresetn(proc_sys_reset_0_peripheral_aresetn),
        .peripheral_reset(proc_sys_reset_0_peripheral_reset),
        .slowest_sync_clk(processing_system7_0_FCLK_CLK0));
(* BMM_INFO_PROCESSOR = "ARM > elink2_top elink2/axi_bram_ctrl_2" *) 
   (* KEEP_HIERARCHY = "yes" *) 
   elink2_top_processing_system7_0_0 processing_system7_0
       (.DDR_Addr(DDR_addr[14:0]),
        .DDR_BankAddr(DDR_ba[2:0]),
        .DDR_CAS_n(DDR_cas_n),
        .DDR_CKE(DDR_cke),
        .DDR_CS_n(DDR_cs_n),
        .DDR_Clk(DDR_ck_p),
        .DDR_Clk_n(DDR_ck_n),
        .DDR_DM(DDR_dm[3:0]),
        .DDR_DQ(DDR_dq[31:0]),
        .DDR_DQS(DDR_dqs_p[3:0]),
        .DDR_DQS_n(DDR_dqs_n[3:0]),
        .DDR_DRSTB(DDR_reset_n),
        .DDR_ODT(DDR_odt),
        .DDR_RAS_n(DDR_ras_n),
        .DDR_VRN(FIXED_IO_ddr_vrn),
        .DDR_VRP(FIXED_IO_ddr_vrp),
        .DDR_WEB(DDR_we_n),
        .FCLK_CLK0(processing_system7_0_FCLK_CLK0),
        .FCLK_CLK1(processing_system7_0_FCLK_CLK1),
        .FCLK_RESET0_N(processing_system7_0_FCLK_RESET0_N),
        .GPIO_I(processing_system7_0_GPIO_0_TRI_I),
        .GPIO_O(processing_system7_0_GPIO_0_TRI_O),
        .GPIO_T(processing_system7_0_GPIO_0_TRI_T),
        .I2C0_SCL_I(processing_system7_0_IIC_0_SCL_I),
        .I2C0_SCL_O(processing_system7_0_IIC_0_SCL_O),
        .I2C0_SCL_T(processing_system7_0_IIC_0_SCL_T),
        .I2C0_SDA_I(processing_system7_0_IIC_0_SDA_I),
        .I2C0_SDA_O(processing_system7_0_IIC_0_SDA_O),
        .I2C0_SDA_T(processing_system7_0_IIC_0_SDA_T),
        .I2C1_SCL_I(processing_system7_0_IIC_1_SCL_I),
        .I2C1_SCL_O(processing_system7_0_IIC_1_SCL_O),
        .I2C1_SCL_T(processing_system7_0_IIC_1_SCL_T),
        .I2C1_SDA_I(processing_system7_0_IIC_1_SDA_I),
        .I2C1_SDA_O(processing_system7_0_IIC_1_SDA_O),
        .I2C1_SDA_T(processing_system7_0_IIC_1_SDA_T),
        .IRQ_F2P(xlconcat_0_dout),
        .MIO(FIXED_IO_mio[53:0]),
        .M_AXI_GP0_ACLK(processing_system7_0_FCLK_CLK0),
        .M_AXI_GP0_ARADDR(processing_system7_0_M_AXI_GP0_ARADDR),
        .M_AXI_GP0_ARBURST(processing_system7_0_M_AXI_GP0_ARBURST),
        .M_AXI_GP0_ARCACHE(processing_system7_0_M_AXI_GP0_ARCACHE),
        .M_AXI_GP0_ARID(processing_system7_0_M_AXI_GP0_ARID),
        .M_AXI_GP0_ARLEN(processing_system7_0_M_AXI_GP0_ARLEN),
        .M_AXI_GP0_ARLOCK(processing_system7_0_M_AXI_GP0_ARLOCK),
        .M_AXI_GP0_ARPROT(processing_system7_0_M_AXI_GP0_ARPROT),
        .M_AXI_GP0_ARQOS(processing_system7_0_M_AXI_GP0_ARQOS),
        .M_AXI_GP0_ARREADY(processing_system7_0_M_AXI_GP0_ARREADY),
        .M_AXI_GP0_ARSIZE(processing_system7_0_M_AXI_GP0_ARSIZE),
        .M_AXI_GP0_ARVALID(processing_system7_0_M_AXI_GP0_ARVALID),
        .M_AXI_GP0_AWADDR(processing_system7_0_M_AXI_GP0_AWADDR),
        .M_AXI_GP0_AWBURST(processing_system7_0_M_AXI_GP0_AWBURST),
        .M_AXI_GP0_AWCACHE(processing_system7_0_M_AXI_GP0_AWCACHE),
        .M_AXI_GP0_AWID(processing_system7_0_M_AXI_GP0_AWID),
        .M_AXI_GP0_AWLEN(processing_system7_0_M_AXI_GP0_AWLEN),
        .M_AXI_GP0_AWLOCK(processing_system7_0_M_AXI_GP0_AWLOCK),
        .M_AXI_GP0_AWPROT(processing_system7_0_M_AXI_GP0_AWPROT),
        .M_AXI_GP0_AWQOS(processing_system7_0_M_AXI_GP0_AWQOS),
        .M_AXI_GP0_AWREADY(processing_system7_0_M_AXI_GP0_AWREADY),
        .M_AXI_GP0_AWSIZE(processing_system7_0_M_AXI_GP0_AWSIZE),
        .M_AXI_GP0_AWVALID(processing_system7_0_M_AXI_GP0_AWVALID),
        .M_AXI_GP0_BID(processing_system7_0_M_AXI_GP0_BID),
        .M_AXI_GP0_BREADY(processing_system7_0_M_AXI_GP0_BREADY),
        .M_AXI_GP0_BRESP(processing_system7_0_M_AXI_GP0_BRESP),
        .M_AXI_GP0_BVALID(processing_system7_0_M_AXI_GP0_BVALID),
        .M_AXI_GP0_RDATA(processing_system7_0_M_AXI_GP0_RDATA),
        .M_AXI_GP0_RID(processing_system7_0_M_AXI_GP0_RID),
        .M_AXI_GP0_RLAST(processing_system7_0_M_AXI_GP0_RLAST),
        .M_AXI_GP0_RREADY(processing_system7_0_M_AXI_GP0_RREADY),
        .M_AXI_GP0_RRESP(processing_system7_0_M_AXI_GP0_RRESP),
        .M_AXI_GP0_RVALID(processing_system7_0_M_AXI_GP0_RVALID),
        .M_AXI_GP0_WDATA(processing_system7_0_M_AXI_GP0_WDATA),
        .M_AXI_GP0_WID(processing_system7_0_M_AXI_GP0_WID),
        .M_AXI_GP0_WLAST(processing_system7_0_M_AXI_GP0_WLAST),
        .M_AXI_GP0_WREADY(processing_system7_0_M_AXI_GP0_WREADY),
        .M_AXI_GP0_WSTRB(processing_system7_0_M_AXI_GP0_WSTRB),
        .M_AXI_GP0_WVALID(processing_system7_0_M_AXI_GP0_WVALID),
        .M_AXI_GP1_ACLK(processing_system7_0_FCLK_CLK0),
        .M_AXI_GP1_ARADDR(processing_system7_0_M_AXI_GP1_ARADDR),
        .M_AXI_GP1_ARBURST(processing_system7_0_M_AXI_GP1_ARBURST),
        .M_AXI_GP1_ARCACHE(processing_system7_0_M_AXI_GP1_ARCACHE),
        .M_AXI_GP1_ARID(processing_system7_0_M_AXI_GP1_ARID),
        .M_AXI_GP1_ARLEN(processing_system7_0_M_AXI_GP1_ARLEN),
        .M_AXI_GP1_ARLOCK(processing_system7_0_M_AXI_GP1_ARLOCK),
        .M_AXI_GP1_ARPROT(processing_system7_0_M_AXI_GP1_ARPROT),
        .M_AXI_GP1_ARQOS(processing_system7_0_M_AXI_GP1_ARQOS),
        .M_AXI_GP1_ARREADY(processing_system7_0_M_AXI_GP1_ARREADY),
        .M_AXI_GP1_ARSIZE(processing_system7_0_M_AXI_GP1_ARSIZE),
        .M_AXI_GP1_ARVALID(processing_system7_0_M_AXI_GP1_ARVALID),
        .M_AXI_GP1_AWADDR(processing_system7_0_M_AXI_GP1_AWADDR),
        .M_AXI_GP1_AWBURST(processing_system7_0_M_AXI_GP1_AWBURST),
        .M_AXI_GP1_AWCACHE(processing_system7_0_M_AXI_GP1_AWCACHE),
        .M_AXI_GP1_AWID(processing_system7_0_M_AXI_GP1_AWID),
        .M_AXI_GP1_AWLEN(processing_system7_0_M_AXI_GP1_AWLEN),
        .M_AXI_GP1_AWLOCK(processing_system7_0_M_AXI_GP1_AWLOCK),
        .M_AXI_GP1_AWPROT(processing_system7_0_M_AXI_GP1_AWPROT),
        .M_AXI_GP1_AWQOS(processing_system7_0_M_AXI_GP1_AWQOS),
        .M_AXI_GP1_AWREADY(processing_system7_0_M_AXI_GP1_AWREADY),
        .M_AXI_GP1_AWSIZE(processing_system7_0_M_AXI_GP1_AWSIZE),
        .M_AXI_GP1_AWVALID(processing_system7_0_M_AXI_GP1_AWVALID),
        .M_AXI_GP1_BID(processing_system7_0_M_AXI_GP1_BID),
        .M_AXI_GP1_BREADY(processing_system7_0_M_AXI_GP1_BREADY),
        .M_AXI_GP1_BRESP(processing_system7_0_M_AXI_GP1_BRESP),
        .M_AXI_GP1_BVALID(processing_system7_0_M_AXI_GP1_BVALID),
        .M_AXI_GP1_RDATA(processing_system7_0_M_AXI_GP1_RDATA),
        .M_AXI_GP1_RID(processing_system7_0_M_AXI_GP1_RID),
        .M_AXI_GP1_RLAST(processing_system7_0_M_AXI_GP1_RLAST),
        .M_AXI_GP1_RREADY(processing_system7_0_M_AXI_GP1_RREADY),
        .M_AXI_GP1_RRESP(processing_system7_0_M_AXI_GP1_RRESP),
        .M_AXI_GP1_RVALID(processing_system7_0_M_AXI_GP1_RVALID),
        .M_AXI_GP1_WDATA(processing_system7_0_M_AXI_GP1_WDATA),
        .M_AXI_GP1_WID(processing_system7_0_M_AXI_GP1_WID),
        .M_AXI_GP1_WLAST(processing_system7_0_M_AXI_GP1_WLAST),
        .M_AXI_GP1_WREADY(processing_system7_0_M_AXI_GP1_WREADY),
        .M_AXI_GP1_WSTRB(processing_system7_0_M_AXI_GP1_WSTRB),
        .M_AXI_GP1_WVALID(processing_system7_0_M_AXI_GP1_WVALID),
        .PS_CLK(FIXED_IO_ps_clk),
        .PS_PORB(FIXED_IO_ps_porb),
        .PS_SRSTB(FIXED_IO_ps_srstb),
        .S_AXI_HP0_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP0_ARADDR({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARBURST({GND_1,GND_1}),
        .S_AXI_HP0_ARCACHE({GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARID({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARLEN({GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARLOCK({GND_1,GND_1}),
        .S_AXI_HP0_ARPROT({GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARQOS({GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARSIZE({GND_1,GND_1,GND_1}),
        .S_AXI_HP0_ARVALID(GND_1),
        .S_AXI_HP0_AWADDR(axi_protocol_converter_1_M_AXI_AWADDR),
        .S_AXI_HP0_AWBURST(axi_protocol_converter_1_M_AXI_AWBURST),
        .S_AXI_HP0_AWCACHE(axi_protocol_converter_1_M_AXI_AWCACHE),
        .S_AXI_HP0_AWID({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_AWLEN(axi_protocol_converter_1_M_AXI_AWLEN),
        .S_AXI_HP0_AWLOCK(axi_protocol_converter_1_M_AXI_AWLOCK),
        .S_AXI_HP0_AWPROT(axi_protocol_converter_1_M_AXI_AWPROT),
        .S_AXI_HP0_AWQOS(axi_protocol_converter_1_M_AXI_AWQOS),
        .S_AXI_HP0_AWREADY(axi_protocol_converter_1_M_AXI_AWREADY),
        .S_AXI_HP0_AWSIZE(axi_protocol_converter_1_M_AXI_AWSIZE),
        .S_AXI_HP0_AWVALID(axi_protocol_converter_1_M_AXI_AWVALID),
        .S_AXI_HP0_BREADY(axi_protocol_converter_1_M_AXI_BREADY),
        .S_AXI_HP0_BRESP(axi_protocol_converter_1_M_AXI_BRESP),
        .S_AXI_HP0_BVALID(axi_protocol_converter_1_M_AXI_BVALID),
        .S_AXI_HP0_RDISSUECAP1_EN(GND_1),
        .S_AXI_HP0_RREADY(GND_1),
        .S_AXI_HP0_WDATA(axi_protocol_converter_1_M_AXI_WDATA),
        .S_AXI_HP0_WID({GND_1,GND_1,GND_1,GND_1,GND_1,GND_1}),
        .S_AXI_HP0_WLAST(axi_protocol_converter_1_M_AXI_WLAST),
        .S_AXI_HP0_WREADY(axi_protocol_converter_1_M_AXI_WREADY),
        .S_AXI_HP0_WRISSUECAP1_EN(GND_1),
        .S_AXI_HP0_WSTRB(axi_protocol_converter_1_M_AXI_WSTRB),
        .S_AXI_HP0_WVALID(axi_protocol_converter_1_M_AXI_WVALID),
        .S_AXI_HP1_ACLK(processing_system7_0_FCLK_CLK0),
        .S_AXI_HP1_ARADDR(axi_protocol_converter_0_M_AXI_ARADDR),
        .S_AXI_HP1_ARBURST(axi_protocol_converter_0_M_AXI_ARBURST),
        .S_AXI_HP1_ARCACHE(axi_protocol_converter_0_M_AXI_ARCACHE),
        .S_AXI_HP1_ARID(axi_protocol_converter_0_M_AXI_ARID),
        .S_AXI_HP1_ARLEN(axi_protocol_converter_0_M_AXI_ARLEN),
        .S_AXI_HP1_ARLOCK(axi_protocol_converter_0_M_AXI_ARLOCK),
        .S_AXI_HP1_ARPROT(axi_protocol_converter_0_M_AXI_ARPROT),
        .S_AXI_HP1_ARQOS(axi_protocol_converter_0_M_AXI_ARQOS),
        .S_AXI_HP1_ARREADY(axi_protocol_converter_0_M_AXI_ARREADY),
        .S_AXI_HP1_ARSIZE(axi_protocol_converter_0_M_AXI_ARSIZE),
        .S_AXI_HP1_ARVALID(axi_protocol_converter_0_M_AXI_ARVALID),
        .S_AXI_HP1_AWADDR(axi_protocol_converter_0_M_AXI_AWADDR),
        .S_AXI_HP1_AWBURST(axi_protocol_converter_0_M_AXI_AWBURST),
        .S_AXI_HP1_AWCACHE(axi_protocol_converter_0_M_AXI_AWCACHE),
        .S_AXI_HP1_AWID(axi_protocol_converter_0_M_AXI_AWID),
        .S_AXI_HP1_AWLEN(axi_protocol_converter_0_M_AXI_AWLEN),
        .S_AXI_HP1_AWLOCK(axi_protocol_converter_0_M_AXI_AWLOCK),
        .S_AXI_HP1_AWPROT(axi_protocol_converter_0_M_AXI_AWPROT),
        .S_AXI_HP1_AWQOS(axi_protocol_converter_0_M_AXI_AWQOS),
        .S_AXI_HP1_AWREADY(axi_protocol_converter_0_M_AXI_AWREADY),
        .S_AXI_HP1_AWSIZE(axi_protocol_converter_0_M_AXI_AWSIZE),
        .S_AXI_HP1_AWVALID(axi_protocol_converter_0_M_AXI_AWVALID),
        .S_AXI_HP1_BID(axi_protocol_converter_0_M_AXI_BID),
        .S_AXI_HP1_BREADY(axi_protocol_converter_0_M_AXI_BREADY),
        .S_AXI_HP1_BRESP(axi_protocol_converter_0_M_AXI_BRESP),
        .S_AXI_HP1_BVALID(axi_protocol_converter_0_M_AXI_BVALID),
        .S_AXI_HP1_RDATA(axi_protocol_converter_0_M_AXI_RDATA),
        .S_AXI_HP1_RDISSUECAP1_EN(GND_1),
        .S_AXI_HP1_RID(axi_protocol_converter_0_M_AXI_RID),
        .S_AXI_HP1_RLAST(axi_protocol_converter_0_M_AXI_RLAST),
        .S_AXI_HP1_RREADY(axi_protocol_converter_0_M_AXI_RREADY),
        .S_AXI_HP1_RRESP(axi_protocol_converter_0_M_AXI_RRESP),
        .S_AXI_HP1_RVALID(axi_protocol_converter_0_M_AXI_RVALID),
        .S_AXI_HP1_WDATA(axi_protocol_converter_0_M_AXI_WDATA),
        .S_AXI_HP1_WID(axi_protocol_converter_0_M_AXI_WID),
        .S_AXI_HP1_WLAST(axi_protocol_converter_0_M_AXI_WLAST),
        .S_AXI_HP1_WREADY(axi_protocol_converter_0_M_AXI_WREADY),
        .S_AXI_HP1_WRISSUECAP1_EN(GND_1),
        .S_AXI_HP1_WSTRB(axi_protocol_converter_0_M_AXI_WSTRB),
        .S_AXI_HP1_WVALID(axi_protocol_converter_0_M_AXI_WVALID),
        .USB0_VBUS_PWRFAULT(GND_1),
        .USB1_VBUS_PWRFAULT(GND_1));
elink2_top_xlconcat_0_0 xlconcat_0
       (.In0(axi_vdma_0_s2mm_introut),
        .In1(csi_intr_1),
        .dout(xlconcat_0_dout));
endmodule

module elink2_top_axi_interconnect_0_0
   (ACLK,
    ARESETN,
    M00_ACLK,
    M00_ARESETN,
    M00_AXI_araddr,
    M00_AXI_arprot,
    M00_AXI_arready,
    M00_AXI_arvalid,
    M00_AXI_awaddr,
    M00_AXI_awprot,
    M00_AXI_awready,
    M00_AXI_awvalid,
    M00_AXI_bready,
    M00_AXI_bresp,
    M00_AXI_bvalid,
    M00_AXI_rdata,
    M00_AXI_rready,
    M00_AXI_rresp,
    M00_AXI_rvalid,
    M00_AXI_wdata,
    M00_AXI_wready,
    M00_AXI_wstrb,
    M00_AXI_wvalid,
    M01_ACLK,
    M01_ARESETN,
    M01_AXI_araddr,
    M01_AXI_arready,
    M01_AXI_arvalid,
    M01_AXI_awaddr,
    M01_AXI_awready,
    M01_AXI_awvalid,
    M01_AXI_bready,
    M01_AXI_bresp,
    M01_AXI_bvalid,
    M01_AXI_rdata,
    M01_AXI_rready,
    M01_AXI_rresp,
    M01_AXI_rvalid,
    M01_AXI_wdata,
    M01_AXI_wready,
    M01_AXI_wvalid,
    M02_ACLK,
    M02_ARESETN,
    M02_AXI_araddr,
    M02_AXI_arprot,
    M02_AXI_arready,
    M02_AXI_arvalid,
    M02_AXI_awaddr,
    M02_AXI_awprot,
    M02_AXI_awready,
    M02_AXI_awvalid,
    M02_AXI_bready,
    M02_AXI_bresp,
    M02_AXI_bvalid,
    M02_AXI_rdata,
    M02_AXI_rready,
    M02_AXI_rresp,
    M02_AXI_rvalid,
    M02_AXI_wdata,
    M02_AXI_wready,
    M02_AXI_wstrb,
    M02_AXI_wvalid,
    S00_ACLK,
    S00_ARESETN,
    S00_AXI_araddr,
    S00_AXI_arburst,
    S00_AXI_arcache,
    S00_AXI_arid,
    S00_AXI_arlen,
    S00_AXI_arlock,
    S00_AXI_arprot,
    S00_AXI_arqos,
    S00_AXI_arready,
    S00_AXI_arsize,
    S00_AXI_arvalid,
    S00_AXI_awaddr,
    S00_AXI_awburst,
    S00_AXI_awcache,
    S00_AXI_awid,
    S00_AXI_awlen,
    S00_AXI_awlock,
    S00_AXI_awprot,
    S00_AXI_awqos,
    S00_AXI_awready,
    S00_AXI_awsize,
    S00_AXI_awvalid,
    S00_AXI_bid,
    S00_AXI_bready,
    S00_AXI_bresp,
    S00_AXI_bvalid,
    S00_AXI_rdata,
    S00_AXI_rid,
    S00_AXI_rlast,
    S00_AXI_rready,
    S00_AXI_rresp,
    S00_AXI_rvalid,
    S00_AXI_wdata,
    S00_AXI_wid,
    S00_AXI_wlast,
    S00_AXI_wready,
    S00_AXI_wstrb,
    S00_AXI_wvalid);
  input ACLK;
  input [0:0]ARESETN;
  input M00_ACLK;
  input [0:0]M00_ARESETN;
  output [12:0]M00_AXI_araddr;
  output [2:0]M00_AXI_arprot;
  input [0:0]M00_AXI_arready;
  output [0:0]M00_AXI_arvalid;
  output [12:0]M00_AXI_awaddr;
  output [2:0]M00_AXI_awprot;
  input [0:0]M00_AXI_awready;
  output [0:0]M00_AXI_awvalid;
  output [0:0]M00_AXI_bready;
  input [1:0]M00_AXI_bresp;
  input [0:0]M00_AXI_bvalid;
  input [31:0]M00_AXI_rdata;
  output [0:0]M00_AXI_rready;
  input [1:0]M00_AXI_rresp;
  input [0:0]M00_AXI_rvalid;
  output [31:0]M00_AXI_wdata;
  input [0:0]M00_AXI_wready;
  output [3:0]M00_AXI_wstrb;
  output [0:0]M00_AXI_wvalid;
  input M01_ACLK;
  input [0:0]M01_ARESETN;
  output [8:0]M01_AXI_araddr;
  input M01_AXI_arready;
  output M01_AXI_arvalid;
  output [8:0]M01_AXI_awaddr;
  input M01_AXI_awready;
  output M01_AXI_awvalid;
  output M01_AXI_bready;
  input [1:0]M01_AXI_bresp;
  input M01_AXI_bvalid;
  input [31:0]M01_AXI_rdata;
  output M01_AXI_rready;
  input [1:0]M01_AXI_rresp;
  input M01_AXI_rvalid;
  output [31:0]M01_AXI_wdata;
  input M01_AXI_wready;
  output M01_AXI_wvalid;
  input M02_ACLK;
  input [0:0]M02_ARESETN;
  output [31:0]M02_AXI_araddr;
  output [2:0]M02_AXI_arprot;
  input [0:0]M02_AXI_arready;
  output [0:0]M02_AXI_arvalid;
  output [31:0]M02_AXI_awaddr;
  output [2:0]M02_AXI_awprot;
  input [0:0]M02_AXI_awready;
  output [0:0]M02_AXI_awvalid;
  output [0:0]M02_AXI_bready;
  input [1:0]M02_AXI_bresp;
  input [0:0]M02_AXI_bvalid;
  input [31:0]M02_AXI_rdata;
  output [0:0]M02_AXI_rready;
  input [1:0]M02_AXI_rresp;
  input [0:0]M02_AXI_rvalid;
  output [31:0]M02_AXI_wdata;
  input [0:0]M02_AXI_wready;
  output [3:0]M02_AXI_wstrb;
  output [0:0]M02_AXI_wvalid;
  input S00_ACLK;
  input [0:0]S00_ARESETN;
  input [31:0]S00_AXI_araddr;
  input [1:0]S00_AXI_arburst;
  input [3:0]S00_AXI_arcache;
  input [11:0]S00_AXI_arid;
  input [3:0]S00_AXI_arlen;
  input [1:0]S00_AXI_arlock;
  input [2:0]S00_AXI_arprot;
  input [3:0]S00_AXI_arqos;
  output S00_AXI_arready;
  input [2:0]S00_AXI_arsize;
  input S00_AXI_arvalid;
  input [31:0]S00_AXI_awaddr;
  input [1:0]S00_AXI_awburst;
  input [3:0]S00_AXI_awcache;
  input [11:0]S00_AXI_awid;
  input [3:0]S00_AXI_awlen;
  input [1:0]S00_AXI_awlock;
  input [2:0]S00_AXI_awprot;
  input [3:0]S00_AXI_awqos;
  output S00_AXI_awready;
  input [2:0]S00_AXI_awsize;
  input S00_AXI_awvalid;
  output [11:0]S00_AXI_bid;
  input S00_AXI_bready;
  output [1:0]S00_AXI_bresp;
  output S00_AXI_bvalid;
  output [31:0]S00_AXI_rdata;
  output [11:0]S00_AXI_rid;
  output S00_AXI_rlast;
  input S00_AXI_rready;
  output [1:0]S00_AXI_rresp;
  output S00_AXI_rvalid;
  input [31:0]S00_AXI_wdata;
  input [11:0]S00_AXI_wid;
  input S00_AXI_wlast;
  output S00_AXI_wready;
  input [3:0]S00_AXI_wstrb;
  input S00_AXI_wvalid;

  wire axi_lite_0_ACLK_net;
  wire [0:0]axi_lite_0_ARESETN_net;
  wire [31:0]axi_lite_0_to_s00_couplers_ARADDR;
  wire [1:0]axi_lite_0_to_s00_couplers_ARBURST;
  wire [3:0]axi_lite_0_to_s00_couplers_ARCACHE;
  wire [11:0]axi_lite_0_to_s00_couplers_ARID;
  wire [3:0]axi_lite_0_to_s00_couplers_ARLEN;
  wire [1:0]axi_lite_0_to_s00_couplers_ARLOCK;
  wire [2:0]axi_lite_0_to_s00_couplers_ARPROT;
  wire [3:0]axi_lite_0_to_s00_couplers_ARQOS;
  wire axi_lite_0_to_s00_couplers_ARREADY;
  wire [2:0]axi_lite_0_to_s00_couplers_ARSIZE;
  wire axi_lite_0_to_s00_couplers_ARVALID;
  wire [31:0]axi_lite_0_to_s00_couplers_AWADDR;
  wire [1:0]axi_lite_0_to_s00_couplers_AWBURST;
  wire [3:0]axi_lite_0_to_s00_couplers_AWCACHE;
  wire [11:0]axi_lite_0_to_s00_couplers_AWID;
  wire [3:0]axi_lite_0_to_s00_couplers_AWLEN;
  wire [1:0]axi_lite_0_to_s00_couplers_AWLOCK;
  wire [2:0]axi_lite_0_to_s00_couplers_AWPROT;
  wire [3:0]axi_lite_0_to_s00_couplers_AWQOS;
  wire axi_lite_0_to_s00_couplers_AWREADY;
  wire [2:0]axi_lite_0_to_s00_couplers_AWSIZE;
  wire axi_lite_0_to_s00_couplers_AWVALID;
  wire [11:0]axi_lite_0_to_s00_couplers_BID;
  wire axi_lite_0_to_s00_couplers_BREADY;
  wire [1:0]axi_lite_0_to_s00_couplers_BRESP;
  wire axi_lite_0_to_s00_couplers_BVALID;
  wire [31:0]axi_lite_0_to_s00_couplers_RDATA;
  wire [11:0]axi_lite_0_to_s00_couplers_RID;
  wire axi_lite_0_to_s00_couplers_RLAST;
  wire axi_lite_0_to_s00_couplers_RREADY;
  wire [1:0]axi_lite_0_to_s00_couplers_RRESP;
  wire axi_lite_0_to_s00_couplers_RVALID;
  wire [31:0]axi_lite_0_to_s00_couplers_WDATA;
  wire [11:0]axi_lite_0_to_s00_couplers_WID;
  wire axi_lite_0_to_s00_couplers_WLAST;
  wire axi_lite_0_to_s00_couplers_WREADY;
  wire [3:0]axi_lite_0_to_s00_couplers_WSTRB;
  wire axi_lite_0_to_s00_couplers_WVALID;
  wire [12:0]m00_couplers_to_axi_lite_0_ARADDR;
  wire [2:0]m00_couplers_to_axi_lite_0_ARPROT;
  wire [0:0]m00_couplers_to_axi_lite_0_ARREADY;
  wire [0:0]m00_couplers_to_axi_lite_0_ARVALID;
  wire [12:0]m00_couplers_to_axi_lite_0_AWADDR;
  wire [2:0]m00_couplers_to_axi_lite_0_AWPROT;
  wire [0:0]m00_couplers_to_axi_lite_0_AWREADY;
  wire [0:0]m00_couplers_to_axi_lite_0_AWVALID;
  wire [0:0]m00_couplers_to_axi_lite_0_BREADY;
  wire [1:0]m00_couplers_to_axi_lite_0_BRESP;
  wire [0:0]m00_couplers_to_axi_lite_0_BVALID;
  wire [31:0]m00_couplers_to_axi_lite_0_RDATA;
  wire [0:0]m00_couplers_to_axi_lite_0_RREADY;
  wire [1:0]m00_couplers_to_axi_lite_0_RRESP;
  wire [0:0]m00_couplers_to_axi_lite_0_RVALID;
  wire [31:0]m00_couplers_to_axi_lite_0_WDATA;
  wire [0:0]m00_couplers_to_axi_lite_0_WREADY;
  wire [3:0]m00_couplers_to_axi_lite_0_WSTRB;
  wire [0:0]m00_couplers_to_axi_lite_0_WVALID;
  wire [8:0]m01_couplers_to_axi_lite_0_ARADDR;
  wire m01_couplers_to_axi_lite_0_ARREADY;
  wire m01_couplers_to_axi_lite_0_ARVALID;
  wire [8:0]m01_couplers_to_axi_lite_0_AWADDR;
  wire m01_couplers_to_axi_lite_0_AWREADY;
  wire m01_couplers_to_axi_lite_0_AWVALID;
  wire m01_couplers_to_axi_lite_0_BREADY;
  wire [1:0]m01_couplers_to_axi_lite_0_BRESP;
  wire m01_couplers_to_axi_lite_0_BVALID;
  wire [31:0]m01_couplers_to_axi_lite_0_RDATA;
  wire m01_couplers_to_axi_lite_0_RREADY;
  wire [1:0]m01_couplers_to_axi_lite_0_RRESP;
  wire m01_couplers_to_axi_lite_0_RVALID;
  wire [31:0]m01_couplers_to_axi_lite_0_WDATA;
  wire m01_couplers_to_axi_lite_0_WREADY;
  wire m01_couplers_to_axi_lite_0_WVALID;
  wire [31:0]m02_couplers_to_axi_lite_0_ARADDR;
  wire [2:0]m02_couplers_to_axi_lite_0_ARPROT;
  wire [0:0]m02_couplers_to_axi_lite_0_ARREADY;
  wire [0:0]m02_couplers_to_axi_lite_0_ARVALID;
  wire [31:0]m02_couplers_to_axi_lite_0_AWADDR;
  wire [2:0]m02_couplers_to_axi_lite_0_AWPROT;
  wire [0:0]m02_couplers_to_axi_lite_0_AWREADY;
  wire [0:0]m02_couplers_to_axi_lite_0_AWVALID;
  wire [0:0]m02_couplers_to_axi_lite_0_BREADY;
  wire [1:0]m02_couplers_to_axi_lite_0_BRESP;
  wire [0:0]m02_couplers_to_axi_lite_0_BVALID;
  wire [31:0]m02_couplers_to_axi_lite_0_RDATA;
  wire [0:0]m02_couplers_to_axi_lite_0_RREADY;
  wire [1:0]m02_couplers_to_axi_lite_0_RRESP;
  wire [0:0]m02_couplers_to_axi_lite_0_RVALID;
  wire [31:0]m02_couplers_to_axi_lite_0_WDATA;
  wire [0:0]m02_couplers_to_axi_lite_0_WREADY;
  wire [3:0]m02_couplers_to_axi_lite_0_WSTRB;
  wire [0:0]m02_couplers_to_axi_lite_0_WVALID;
  wire [31:0]s00_couplers_to_xbar_ARADDR;
  wire [2:0]s00_couplers_to_xbar_ARPROT;
  wire [0:0]s00_couplers_to_xbar_ARREADY;
  wire s00_couplers_to_xbar_ARVALID;
  wire [31:0]s00_couplers_to_xbar_AWADDR;
  wire [2:0]s00_couplers_to_xbar_AWPROT;
  wire [0:0]s00_couplers_to_xbar_AWREADY;
  wire s00_couplers_to_xbar_AWVALID;
  wire s00_couplers_to_xbar_BREADY;
  wire [1:0]s00_couplers_to_xbar_BRESP;
  wire [0:0]s00_couplers_to_xbar_BVALID;
  wire [31:0]s00_couplers_to_xbar_RDATA;
  wire s00_couplers_to_xbar_RREADY;
  wire [1:0]s00_couplers_to_xbar_RRESP;
  wire [0:0]s00_couplers_to_xbar_RVALID;
  wire [31:0]s00_couplers_to_xbar_WDATA;
  wire [0:0]s00_couplers_to_xbar_WREADY;
  wire [3:0]s00_couplers_to_xbar_WSTRB;
  wire s00_couplers_to_xbar_WVALID;
  wire [31:0]xbar_to_m00_couplers_ARADDR;
  wire [2:0]xbar_to_m00_couplers_ARPROT;
  wire [0:0]xbar_to_m00_couplers_ARREADY;
  wire [0:0]xbar_to_m00_couplers_ARVALID;
  wire [31:0]xbar_to_m00_couplers_AWADDR;
  wire [2:0]xbar_to_m00_couplers_AWPROT;
  wire [0:0]xbar_to_m00_couplers_AWREADY;
  wire [0:0]xbar_to_m00_couplers_AWVALID;
  wire [0:0]xbar_to_m00_couplers_BREADY;
  wire [1:0]xbar_to_m00_couplers_BRESP;
  wire [0:0]xbar_to_m00_couplers_BVALID;
  wire [31:0]xbar_to_m00_couplers_RDATA;
  wire [0:0]xbar_to_m00_couplers_RREADY;
  wire [1:0]xbar_to_m00_couplers_RRESP;
  wire [0:0]xbar_to_m00_couplers_RVALID;
  wire [31:0]xbar_to_m00_couplers_WDATA;
  wire [0:0]xbar_to_m00_couplers_WREADY;
  wire [3:0]xbar_to_m00_couplers_WSTRB;
  wire [0:0]xbar_to_m00_couplers_WVALID;
  wire [63:32]xbar_to_m01_couplers_ARADDR;
  wire xbar_to_m01_couplers_ARREADY;
  wire [1:1]xbar_to_m01_couplers_ARVALID;
  wire [63:32]xbar_to_m01_couplers_AWADDR;
  wire xbar_to_m01_couplers_AWREADY;
  wire [1:1]xbar_to_m01_couplers_AWVALID;
  wire [1:1]xbar_to_m01_couplers_BREADY;
  wire [1:0]xbar_to_m01_couplers_BRESP;
  wire xbar_to_m01_couplers_BVALID;
  wire [31:0]xbar_to_m01_couplers_RDATA;
  wire [1:1]xbar_to_m01_couplers_RREADY;
  wire [1:0]xbar_to_m01_couplers_RRESP;
  wire xbar_to_m01_couplers_RVALID;
  wire [63:32]xbar_to_m01_couplers_WDATA;
  wire xbar_to_m01_couplers_WREADY;
  wire [1:1]xbar_to_m01_couplers_WVALID;
  wire [95:64]xbar_to_m02_couplers_ARADDR;
  wire [8:6]xbar_to_m02_couplers_ARPROT;
  wire [0:0]xbar_to_m02_couplers_ARREADY;
  wire [2:2]xbar_to_m02_couplers_ARVALID;
  wire [95:64]xbar_to_m02_couplers_AWADDR;
  wire [8:6]xbar_to_m02_couplers_AWPROT;
  wire [0:0]xbar_to_m02_couplers_AWREADY;
  wire [2:2]xbar_to_m02_couplers_AWVALID;
  wire [2:2]xbar_to_m02_couplers_BREADY;
  wire [1:0]xbar_to_m02_couplers_BRESP;
  wire [0:0]xbar_to_m02_couplers_BVALID;
  wire [31:0]xbar_to_m02_couplers_RDATA;
  wire [2:2]xbar_to_m02_couplers_RREADY;
  wire [1:0]xbar_to_m02_couplers_RRESP;
  wire [0:0]xbar_to_m02_couplers_RVALID;
  wire [95:64]xbar_to_m02_couplers_WDATA;
  wire [0:0]xbar_to_m02_couplers_WREADY;
  wire [11:8]xbar_to_m02_couplers_WSTRB;
  wire [2:2]xbar_to_m02_couplers_WVALID;
  wire [8:0]NLW_xbar_m_axi_arprot_UNCONNECTED;
  wire [8:0]NLW_xbar_m_axi_awprot_UNCONNECTED;
  wire [11:0]NLW_xbar_m_axi_wstrb_UNCONNECTED;

  assign M00_AXI_araddr[12:0] = m00_couplers_to_axi_lite_0_ARADDR;
  assign M00_AXI_arprot[2:0] = m00_couplers_to_axi_lite_0_ARPROT;
  assign M00_AXI_arvalid[0] = m00_couplers_to_axi_lite_0_ARVALID;
  assign M00_AXI_awaddr[12:0] = m00_couplers_to_axi_lite_0_AWADDR;
  assign M00_AXI_awprot[2:0] = m00_couplers_to_axi_lite_0_AWPROT;
  assign M00_AXI_awvalid[0] = m00_couplers_to_axi_lite_0_AWVALID;
  assign M00_AXI_bready[0] = m00_couplers_to_axi_lite_0_BREADY;
  assign M00_AXI_rready[0] = m00_couplers_to_axi_lite_0_RREADY;
  assign M00_AXI_wdata[31:0] = m00_couplers_to_axi_lite_0_WDATA;
  assign M00_AXI_wstrb[3:0] = m00_couplers_to_axi_lite_0_WSTRB;
  assign M00_AXI_wvalid[0] = m00_couplers_to_axi_lite_0_WVALID;
  assign M01_AXI_araddr[8:0] = m01_couplers_to_axi_lite_0_ARADDR;
  assign M01_AXI_arvalid = m01_couplers_to_axi_lite_0_ARVALID;
  assign M01_AXI_awaddr[8:0] = m01_couplers_to_axi_lite_0_AWADDR;
  assign M01_AXI_awvalid = m01_couplers_to_axi_lite_0_AWVALID;
  assign M01_AXI_bready = m01_couplers_to_axi_lite_0_BREADY;
  assign M01_AXI_rready = m01_couplers_to_axi_lite_0_RREADY;
  assign M01_AXI_wdata[31:0] = m01_couplers_to_axi_lite_0_WDATA;
  assign M01_AXI_wvalid = m01_couplers_to_axi_lite_0_WVALID;
  assign M02_AXI_araddr[31:0] = m02_couplers_to_axi_lite_0_ARADDR;
  assign M02_AXI_arprot[2:0] = m02_couplers_to_axi_lite_0_ARPROT;
  assign M02_AXI_arvalid[0] = m02_couplers_to_axi_lite_0_ARVALID;
  assign M02_AXI_awaddr[31:0] = m02_couplers_to_axi_lite_0_AWADDR;
  assign M02_AXI_awprot[2:0] = m02_couplers_to_axi_lite_0_AWPROT;
  assign M02_AXI_awvalid[0] = m02_couplers_to_axi_lite_0_AWVALID;
  assign M02_AXI_bready[0] = m02_couplers_to_axi_lite_0_BREADY;
  assign M02_AXI_rready[0] = m02_couplers_to_axi_lite_0_RREADY;
  assign M02_AXI_wdata[31:0] = m02_couplers_to_axi_lite_0_WDATA;
  assign M02_AXI_wstrb[3:0] = m02_couplers_to_axi_lite_0_WSTRB;
  assign M02_AXI_wvalid[0] = m02_couplers_to_axi_lite_0_WVALID;
  assign S00_AXI_arready = axi_lite_0_to_s00_couplers_ARREADY;
  assign S00_AXI_awready = axi_lite_0_to_s00_couplers_AWREADY;
  assign S00_AXI_bid[11:0] = axi_lite_0_to_s00_couplers_BID;
  assign S00_AXI_bresp[1:0] = axi_lite_0_to_s00_couplers_BRESP;
  assign S00_AXI_bvalid = axi_lite_0_to_s00_couplers_BVALID;
  assign S00_AXI_rdata[31:0] = axi_lite_0_to_s00_couplers_RDATA;
  assign S00_AXI_rid[11:0] = axi_lite_0_to_s00_couplers_RID;
  assign S00_AXI_rlast = axi_lite_0_to_s00_couplers_RLAST;
  assign S00_AXI_rresp[1:0] = axi_lite_0_to_s00_couplers_RRESP;
  assign S00_AXI_rvalid = axi_lite_0_to_s00_couplers_RVALID;
  assign S00_AXI_wready = axi_lite_0_to_s00_couplers_WREADY;
  assign axi_lite_0_ACLK_net = ACLK;
  assign axi_lite_0_ARESETN_net = ARESETN[0];
  assign axi_lite_0_to_s00_couplers_ARADDR = S00_AXI_araddr[31:0];
  assign axi_lite_0_to_s00_couplers_ARBURST = S00_AXI_arburst[1:0];
  assign axi_lite_0_to_s00_couplers_ARCACHE = S00_AXI_arcache[3:0];
  assign axi_lite_0_to_s00_couplers_ARID = S00_AXI_arid[11:0];
  assign axi_lite_0_to_s00_couplers_ARLEN = S00_AXI_arlen[3:0];
  assign axi_lite_0_to_s00_couplers_ARLOCK = S00_AXI_arlock[1:0];
  assign axi_lite_0_to_s00_couplers_ARPROT = S00_AXI_arprot[2:0];
  assign axi_lite_0_to_s00_couplers_ARQOS = S00_AXI_arqos[3:0];
  assign axi_lite_0_to_s00_couplers_ARSIZE = S00_AXI_arsize[2:0];
  assign axi_lite_0_to_s00_couplers_ARVALID = S00_AXI_arvalid;
  assign axi_lite_0_to_s00_couplers_AWADDR = S00_AXI_awaddr[31:0];
  assign axi_lite_0_to_s00_couplers_AWBURST = S00_AXI_awburst[1:0];
  assign axi_lite_0_to_s00_couplers_AWCACHE = S00_AXI_awcache[3:0];
  assign axi_lite_0_to_s00_couplers_AWID = S00_AXI_awid[11:0];
  assign axi_lite_0_to_s00_couplers_AWLEN = S00_AXI_awlen[3:0];
  assign axi_lite_0_to_s00_couplers_AWLOCK = S00_AXI_awlock[1:0];
  assign axi_lite_0_to_s00_couplers_AWPROT = S00_AXI_awprot[2:0];
  assign axi_lite_0_to_s00_couplers_AWQOS = S00_AXI_awqos[3:0];
  assign axi_lite_0_to_s00_couplers_AWSIZE = S00_AXI_awsize[2:0];
  assign axi_lite_0_to_s00_couplers_AWVALID = S00_AXI_awvalid;
  assign axi_lite_0_to_s00_couplers_BREADY = S00_AXI_bready;
  assign axi_lite_0_to_s00_couplers_RREADY = S00_AXI_rready;
  assign axi_lite_0_to_s00_couplers_WDATA = S00_AXI_wdata[31:0];
  assign axi_lite_0_to_s00_couplers_WID = S00_AXI_wid[11:0];
  assign axi_lite_0_to_s00_couplers_WLAST = S00_AXI_wlast;
  assign axi_lite_0_to_s00_couplers_WSTRB = S00_AXI_wstrb[3:0];
  assign axi_lite_0_to_s00_couplers_WVALID = S00_AXI_wvalid;
  assign m00_couplers_to_axi_lite_0_ARREADY = M00_AXI_arready[0];
  assign m00_couplers_to_axi_lite_0_AWREADY = M00_AXI_awready[0];
  assign m00_couplers_to_axi_lite_0_BRESP = M00_AXI_bresp[1:0];
  assign m00_couplers_to_axi_lite_0_BVALID = M00_AXI_bvalid[0];
  assign m00_couplers_to_axi_lite_0_RDATA = M00_AXI_rdata[31:0];
  assign m00_couplers_to_axi_lite_0_RRESP = M00_AXI_rresp[1:0];
  assign m00_couplers_to_axi_lite_0_RVALID = M00_AXI_rvalid[0];
  assign m00_couplers_to_axi_lite_0_WREADY = M00_AXI_wready[0];
  assign m01_couplers_to_axi_lite_0_ARREADY = M01_AXI_arready;
  assign m01_couplers_to_axi_lite_0_AWREADY = M01_AXI_awready;
  assign m01_couplers_to_axi_lite_0_BRESP = M01_AXI_bresp[1:0];
  assign m01_couplers_to_axi_lite_0_BVALID = M01_AXI_bvalid;
  assign m01_couplers_to_axi_lite_0_RDATA = M01_AXI_rdata[31:0];
  assign m01_couplers_to_axi_lite_0_RRESP = M01_AXI_rresp[1:0];
  assign m01_couplers_to_axi_lite_0_RVALID = M01_AXI_rvalid;
  assign m01_couplers_to_axi_lite_0_WREADY = M01_AXI_wready;
  assign m02_couplers_to_axi_lite_0_ARREADY = M02_AXI_arready[0];
  assign m02_couplers_to_axi_lite_0_AWREADY = M02_AXI_awready[0];
  assign m02_couplers_to_axi_lite_0_BRESP = M02_AXI_bresp[1:0];
  assign m02_couplers_to_axi_lite_0_BVALID = M02_AXI_bvalid[0];
  assign m02_couplers_to_axi_lite_0_RDATA = M02_AXI_rdata[31:0];
  assign m02_couplers_to_axi_lite_0_RRESP = M02_AXI_rresp[1:0];
  assign m02_couplers_to_axi_lite_0_RVALID = M02_AXI_rvalid[0];
  assign m02_couplers_to_axi_lite_0_WREADY = M02_AXI_wready[0];
m00_couplers_imp_ABSHXI m00_couplers
       (.M_ACLK(axi_lite_0_ACLK_net),
        .M_ARESETN(axi_lite_0_ARESETN_net),
        .M_AXI_araddr(m00_couplers_to_axi_lite_0_ARADDR),
        .M_AXI_arprot(m00_couplers_to_axi_lite_0_ARPROT),
        .M_AXI_arready(m00_couplers_to_axi_lite_0_ARREADY),
        .M_AXI_arvalid(m00_couplers_to_axi_lite_0_ARVALID),
        .M_AXI_awaddr(m00_couplers_to_axi_lite_0_AWADDR),
        .M_AXI_awprot(m00_couplers_to_axi_lite_0_AWPROT),
        .M_AXI_awready(m00_couplers_to_axi_lite_0_AWREADY),
        .M_AXI_awvalid(m00_couplers_to_axi_lite_0_AWVALID),
        .M_AXI_bready(m00_couplers_to_axi_lite_0_BREADY),
        .M_AXI_bresp(m00_couplers_to_axi_lite_0_BRESP),
        .M_AXI_bvalid(m00_couplers_to_axi_lite_0_BVALID),
        .M_AXI_rdata(m00_couplers_to_axi_lite_0_RDATA),
        .M_AXI_rready(m00_couplers_to_axi_lite_0_RREADY),
        .M_AXI_rresp(m00_couplers_to_axi_lite_0_RRESP),
        .M_AXI_rvalid(m00_couplers_to_axi_lite_0_RVALID),
        .M_AXI_wdata(m00_couplers_to_axi_lite_0_WDATA),
        .M_AXI_wready(m00_couplers_to_axi_lite_0_WREADY),
        .M_AXI_wstrb(m00_couplers_to_axi_lite_0_WSTRB),
        .M_AXI_wvalid(m00_couplers_to_axi_lite_0_WVALID),
        .S_ACLK(axi_lite_0_ACLK_net),
        .S_ARESETN(axi_lite_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m00_couplers_ARADDR[12:0]),
        .S_AXI_arprot(xbar_to_m00_couplers_ARPROT),
        .S_AXI_arready(xbar_to_m00_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m00_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m00_couplers_AWADDR[12:0]),
        .S_AXI_awprot(xbar_to_m00_couplers_AWPROT),
        .S_AXI_awready(xbar_to_m00_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m00_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m00_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m00_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m00_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m00_couplers_RDATA),
        .S_AXI_rready(xbar_to_m00_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m00_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m00_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m00_couplers_WDATA),
        .S_AXI_wready(xbar_to_m00_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m00_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m00_couplers_WVALID));
m01_couplers_imp_HV0DJ4 m01_couplers
       (.M_ACLK(axi_lite_0_ACLK_net),
        .M_ARESETN(axi_lite_0_ARESETN_net),
        .M_AXI_araddr(m01_couplers_to_axi_lite_0_ARADDR),
        .M_AXI_arready(m01_couplers_to_axi_lite_0_ARREADY),
        .M_AXI_arvalid(m01_couplers_to_axi_lite_0_ARVALID),
        .M_AXI_awaddr(m01_couplers_to_axi_lite_0_AWADDR),
        .M_AXI_awready(m01_couplers_to_axi_lite_0_AWREADY),
        .M_AXI_awvalid(m01_couplers_to_axi_lite_0_AWVALID),
        .M_AXI_bready(m01_couplers_to_axi_lite_0_BREADY),
        .M_AXI_bresp(m01_couplers_to_axi_lite_0_BRESP),
        .M_AXI_bvalid(m01_couplers_to_axi_lite_0_BVALID),
        .M_AXI_rdata(m01_couplers_to_axi_lite_0_RDATA),
        .M_AXI_rready(m01_couplers_to_axi_lite_0_RREADY),
        .M_AXI_rresp(m01_couplers_to_axi_lite_0_RRESP),
        .M_AXI_rvalid(m01_couplers_to_axi_lite_0_RVALID),
        .M_AXI_wdata(m01_couplers_to_axi_lite_0_WDATA),
        .M_AXI_wready(m01_couplers_to_axi_lite_0_WREADY),
        .M_AXI_wvalid(m01_couplers_to_axi_lite_0_WVALID),
        .S_ACLK(axi_lite_0_ACLK_net),
        .S_ARESETN(axi_lite_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m01_couplers_ARADDR[40:32]),
        .S_AXI_arready(xbar_to_m01_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m01_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m01_couplers_AWADDR[40:32]),
        .S_AXI_awready(xbar_to_m01_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m01_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m01_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m01_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m01_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m01_couplers_RDATA),
        .S_AXI_rready(xbar_to_m01_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m01_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m01_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m01_couplers_WDATA),
        .S_AXI_wready(xbar_to_m01_couplers_WREADY),
        .S_AXI_wvalid(xbar_to_m01_couplers_WVALID));
m02_couplers_imp_1UKXSGA m02_couplers
       (.M_ACLK(axi_lite_0_ACLK_net),
        .M_ARESETN(axi_lite_0_ARESETN_net),
        .M_AXI_araddr(m02_couplers_to_axi_lite_0_ARADDR),
        .M_AXI_arprot(m02_couplers_to_axi_lite_0_ARPROT),
        .M_AXI_arready(m02_couplers_to_axi_lite_0_ARREADY),
        .M_AXI_arvalid(m02_couplers_to_axi_lite_0_ARVALID),
        .M_AXI_awaddr(m02_couplers_to_axi_lite_0_AWADDR),
        .M_AXI_awprot(m02_couplers_to_axi_lite_0_AWPROT),
        .M_AXI_awready(m02_couplers_to_axi_lite_0_AWREADY),
        .M_AXI_awvalid(m02_couplers_to_axi_lite_0_AWVALID),
        .M_AXI_bready(m02_couplers_to_axi_lite_0_BREADY),
        .M_AXI_bresp(m02_couplers_to_axi_lite_0_BRESP),
        .M_AXI_bvalid(m02_couplers_to_axi_lite_0_BVALID),
        .M_AXI_rdata(m02_couplers_to_axi_lite_0_RDATA),
        .M_AXI_rready(m02_couplers_to_axi_lite_0_RREADY),
        .M_AXI_rresp(m02_couplers_to_axi_lite_0_RRESP),
        .M_AXI_rvalid(m02_couplers_to_axi_lite_0_RVALID),
        .M_AXI_wdata(m02_couplers_to_axi_lite_0_WDATA),
        .M_AXI_wready(m02_couplers_to_axi_lite_0_WREADY),
        .M_AXI_wstrb(m02_couplers_to_axi_lite_0_WSTRB),
        .M_AXI_wvalid(m02_couplers_to_axi_lite_0_WVALID),
        .S_ACLK(axi_lite_0_ACLK_net),
        .S_ARESETN(axi_lite_0_ARESETN_net),
        .S_AXI_araddr(xbar_to_m02_couplers_ARADDR),
        .S_AXI_arprot(xbar_to_m02_couplers_ARPROT),
        .S_AXI_arready(xbar_to_m02_couplers_ARREADY),
        .S_AXI_arvalid(xbar_to_m02_couplers_ARVALID),
        .S_AXI_awaddr(xbar_to_m02_couplers_AWADDR),
        .S_AXI_awprot(xbar_to_m02_couplers_AWPROT),
        .S_AXI_awready(xbar_to_m02_couplers_AWREADY),
        .S_AXI_awvalid(xbar_to_m02_couplers_AWVALID),
        .S_AXI_bready(xbar_to_m02_couplers_BREADY),
        .S_AXI_bresp(xbar_to_m02_couplers_BRESP),
        .S_AXI_bvalid(xbar_to_m02_couplers_BVALID),
        .S_AXI_rdata(xbar_to_m02_couplers_RDATA),
        .S_AXI_rready(xbar_to_m02_couplers_RREADY),
        .S_AXI_rresp(xbar_to_m02_couplers_RRESP),
        .S_AXI_rvalid(xbar_to_m02_couplers_RVALID),
        .S_AXI_wdata(xbar_to_m02_couplers_WDATA),
        .S_AXI_wready(xbar_to_m02_couplers_WREADY),
        .S_AXI_wstrb(xbar_to_m02_couplers_WSTRB),
        .S_AXI_wvalid(xbar_to_m02_couplers_WVALID));
s00_couplers_imp_JU3OQV s00_couplers
       (.M_ACLK(axi_lite_0_ACLK_net),
        .M_ARESETN(axi_lite_0_ARESETN_net),
        .M_AXI_araddr(s00_couplers_to_xbar_ARADDR),
        .M_AXI_arprot(s00_couplers_to_xbar_ARPROT),
        .M_AXI_arready(s00_couplers_to_xbar_ARREADY),
        .M_AXI_arvalid(s00_couplers_to_xbar_ARVALID),
        .M_AXI_awaddr(s00_couplers_to_xbar_AWADDR),
        .M_AXI_awprot(s00_couplers_to_xbar_AWPROT),
        .M_AXI_awready(s00_couplers_to_xbar_AWREADY),
        .M_AXI_awvalid(s00_couplers_to_xbar_AWVALID),
        .M_AXI_bready(s00_couplers_to_xbar_BREADY),
        .M_AXI_bresp(s00_couplers_to_xbar_BRESP),
        .M_AXI_bvalid(s00_couplers_to_xbar_BVALID),
        .M_AXI_rdata(s00_couplers_to_xbar_RDATA),
        .M_AXI_rready(s00_couplers_to_xbar_RREADY),
        .M_AXI_rresp(s00_couplers_to_xbar_RRESP),
        .M_AXI_rvalid(s00_couplers_to_xbar_RVALID),
        .M_AXI_wdata(s00_couplers_to_xbar_WDATA),
        .M_AXI_wready(s00_couplers_to_xbar_WREADY),
        .M_AXI_wstrb(s00_couplers_to_xbar_WSTRB),
        .M_AXI_wvalid(s00_couplers_to_xbar_WVALID),
        .S_ACLK(axi_lite_0_ACLK_net),
        .S_ARESETN(axi_lite_0_ARESETN_net),
        .S_AXI_araddr(axi_lite_0_to_s00_couplers_ARADDR),
        .S_AXI_arburst(axi_lite_0_to_s00_couplers_ARBURST),
        .S_AXI_arcache(axi_lite_0_to_s00_couplers_ARCACHE),
        .S_AXI_arid(axi_lite_0_to_s00_couplers_ARID),
        .S_AXI_arlen(axi_lite_0_to_s00_couplers_ARLEN),
        .S_AXI_arlock(axi_lite_0_to_s00_couplers_ARLOCK),
        .S_AXI_arprot(axi_lite_0_to_s00_couplers_ARPROT),
        .S_AXI_arqos(axi_lite_0_to_s00_couplers_ARQOS),
        .S_AXI_arready(axi_lite_0_to_s00_couplers_ARREADY),
        .S_AXI_arsize(axi_lite_0_to_s00_couplers_ARSIZE),
        .S_AXI_arvalid(axi_lite_0_to_s00_couplers_ARVALID),
        .S_AXI_awaddr(axi_lite_0_to_s00_couplers_AWADDR),
        .S_AXI_awburst(axi_lite_0_to_s00_couplers_AWBURST),
        .S_AXI_awcache(axi_lite_0_to_s00_couplers_AWCACHE),
        .S_AXI_awid(axi_lite_0_to_s00_couplers_AWID),
        .S_AXI_awlen(axi_lite_0_to_s00_couplers_AWLEN),
        .S_AXI_awlock(axi_lite_0_to_s00_couplers_AWLOCK),
        .S_AXI_awprot(axi_lite_0_to_s00_couplers_AWPROT),
        .S_AXI_awqos(axi_lite_0_to_s00_couplers_AWQOS),
        .S_AXI_awready(axi_lite_0_to_s00_couplers_AWREADY),
        .S_AXI_awsize(axi_lite_0_to_s00_couplers_AWSIZE),
        .S_AXI_awvalid(axi_lite_0_to_s00_couplers_AWVALID),
        .S_AXI_bid(axi_lite_0_to_s00_couplers_BID),
        .S_AXI_bready(axi_lite_0_to_s00_couplers_BREADY),
        .S_AXI_bresp(axi_lite_0_to_s00_couplers_BRESP),
        .S_AXI_bvalid(axi_lite_0_to_s00_couplers_BVALID),
        .S_AXI_rdata(axi_lite_0_to_s00_couplers_RDATA),
        .S_AXI_rid(axi_lite_0_to_s00_couplers_RID),
        .S_AXI_rlast(axi_lite_0_to_s00_couplers_RLAST),
        .S_AXI_rready(axi_lite_0_to_s00_couplers_RREADY),
        .S_AXI_rresp(axi_lite_0_to_s00_couplers_RRESP),
        .S_AXI_rvalid(axi_lite_0_to_s00_couplers_RVALID),
        .S_AXI_wdata(axi_lite_0_to_s00_couplers_WDATA),
        .S_AXI_wid(axi_lite_0_to_s00_couplers_WID),
        .S_AXI_wlast(axi_lite_0_to_s00_couplers_WLAST),
        .S_AXI_wready(axi_lite_0_to_s00_couplers_WREADY),
        .S_AXI_wstrb(axi_lite_0_to_s00_couplers_WSTRB),
        .S_AXI_wvalid(axi_lite_0_to_s00_couplers_WVALID));
elink2_top_xbar_0 xbar
       (.aclk(axi_lite_0_ACLK_net),
        .aresetn(axi_lite_0_ARESETN_net),
        .m_axi_araddr({xbar_to_m02_couplers_ARADDR,xbar_to_m01_couplers_ARADDR,xbar_to_m00_couplers_ARADDR}),
        .m_axi_arprot({xbar_to_m02_couplers_ARPROT,NLW_xbar_m_axi_arprot_UNCONNECTED[5:3],xbar_to_m00_couplers_ARPROT}),
        .m_axi_arready({xbar_to_m02_couplers_ARREADY,xbar_to_m01_couplers_ARREADY,xbar_to_m00_couplers_ARREADY}),
        .m_axi_arvalid({xbar_to_m02_couplers_ARVALID,xbar_to_m01_couplers_ARVALID,xbar_to_m00_couplers_ARVALID}),
        .m_axi_awaddr({xbar_to_m02_couplers_AWADDR,xbar_to_m01_couplers_AWADDR,xbar_to_m00_couplers_AWADDR}),
        .m_axi_awprot({xbar_to_m02_couplers_AWPROT,NLW_xbar_m_axi_awprot_UNCONNECTED[5:3],xbar_to_m00_couplers_AWPROT}),
        .m_axi_awready({xbar_to_m02_couplers_AWREADY,xbar_to_m01_couplers_AWREADY,xbar_to_m00_couplers_AWREADY}),
        .m_axi_awvalid({xbar_to_m02_couplers_AWVALID,xbar_to_m01_couplers_AWVALID,xbar_to_m00_couplers_AWVALID}),
        .m_axi_bready({xbar_to_m02_couplers_BREADY,xbar_to_m01_couplers_BREADY,xbar_to_m00_couplers_BREADY}),
        .m_axi_bresp({xbar_to_m02_couplers_BRESP,xbar_to_m01_couplers_BRESP,xbar_to_m00_couplers_BRESP}),
        .m_axi_bvalid({xbar_to_m02_couplers_BVALID,xbar_to_m01_couplers_BVALID,xbar_to_m00_couplers_BVALID}),
        .m_axi_rdata({xbar_to_m02_couplers_RDATA,xbar_to_m01_couplers_RDATA,xbar_to_m00_couplers_RDATA}),
        .m_axi_rready({xbar_to_m02_couplers_RREADY,xbar_to_m01_couplers_RREADY,xbar_to_m00_couplers_RREADY}),
        .m_axi_rresp({xbar_to_m02_couplers_RRESP,xbar_to_m01_couplers_RRESP,xbar_to_m00_couplers_RRESP}),
        .m_axi_rvalid({xbar_to_m02_couplers_RVALID,xbar_to_m01_couplers_RVALID,xbar_to_m00_couplers_RVALID}),
        .m_axi_wdata({xbar_to_m02_couplers_WDATA,xbar_to_m01_couplers_WDATA,xbar_to_m00_couplers_WDATA}),
        .m_axi_wready({xbar_to_m02_couplers_WREADY,xbar_to_m01_couplers_WREADY,xbar_to_m00_couplers_WREADY}),
        .m_axi_wstrb({xbar_to_m02_couplers_WSTRB,NLW_xbar_m_axi_wstrb_UNCONNECTED[7:4],xbar_to_m00_couplers_WSTRB}),
        .m_axi_wvalid({xbar_to_m02_couplers_WVALID,xbar_to_m01_couplers_WVALID,xbar_to_m00_couplers_WVALID}),
        .s_axi_araddr(s00_couplers_to_xbar_ARADDR),
        .s_axi_arprot(s00_couplers_to_xbar_ARPROT),
        .s_axi_arready(s00_couplers_to_xbar_ARREADY),
        .s_axi_arvalid(s00_couplers_to_xbar_ARVALID),
        .s_axi_awaddr(s00_couplers_to_xbar_AWADDR),
        .s_axi_awprot(s00_couplers_to_xbar_AWPROT),
        .s_axi_awready(s00_couplers_to_xbar_AWREADY),
        .s_axi_awvalid(s00_couplers_to_xbar_AWVALID),
        .s_axi_bready(s00_couplers_to_xbar_BREADY),
        .s_axi_bresp(s00_couplers_to_xbar_BRESP),
        .s_axi_bvalid(s00_couplers_to_xbar_BVALID),
        .s_axi_rdata(s00_couplers_to_xbar_RDATA),
        .s_axi_rready(s00_couplers_to_xbar_RREADY),
        .s_axi_rresp(s00_couplers_to_xbar_RRESP),
        .s_axi_rvalid(s00_couplers_to_xbar_RVALID),
        .s_axi_wdata(s00_couplers_to_xbar_WDATA),
        .s_axi_wready(s00_couplers_to_xbar_WREADY),
        .s_axi_wstrb(s00_couplers_to_xbar_WSTRB),
        .s_axi_wvalid(s00_couplers_to_xbar_WVALID));
endmodule

module m00_couplers_imp_ABSHXI
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [12:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [12:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [12:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [12:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [12:0]m00_couplers_to_m00_couplers_ARADDR;
  wire [2:0]m00_couplers_to_m00_couplers_ARPROT;
  wire [0:0]m00_couplers_to_m00_couplers_ARREADY;
  wire [0:0]m00_couplers_to_m00_couplers_ARVALID;
  wire [12:0]m00_couplers_to_m00_couplers_AWADDR;
  wire [2:0]m00_couplers_to_m00_couplers_AWPROT;
  wire [0:0]m00_couplers_to_m00_couplers_AWREADY;
  wire [0:0]m00_couplers_to_m00_couplers_AWVALID;
  wire [0:0]m00_couplers_to_m00_couplers_BREADY;
  wire [1:0]m00_couplers_to_m00_couplers_BRESP;
  wire [0:0]m00_couplers_to_m00_couplers_BVALID;
  wire [31:0]m00_couplers_to_m00_couplers_RDATA;
  wire [0:0]m00_couplers_to_m00_couplers_RREADY;
  wire [1:0]m00_couplers_to_m00_couplers_RRESP;
  wire [0:0]m00_couplers_to_m00_couplers_RVALID;
  wire [31:0]m00_couplers_to_m00_couplers_WDATA;
  wire [0:0]m00_couplers_to_m00_couplers_WREADY;
  wire [3:0]m00_couplers_to_m00_couplers_WSTRB;
  wire [0:0]m00_couplers_to_m00_couplers_WVALID;

  assign M_AXI_araddr[12:0] = m00_couplers_to_m00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m00_couplers_to_m00_couplers_ARPROT;
  assign M_AXI_arvalid[0] = m00_couplers_to_m00_couplers_ARVALID;
  assign M_AXI_awaddr[12:0] = m00_couplers_to_m00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m00_couplers_to_m00_couplers_AWPROT;
  assign M_AXI_awvalid[0] = m00_couplers_to_m00_couplers_AWVALID;
  assign M_AXI_bready[0] = m00_couplers_to_m00_couplers_BREADY;
  assign M_AXI_rready[0] = m00_couplers_to_m00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m00_couplers_to_m00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m00_couplers_to_m00_couplers_WSTRB;
  assign M_AXI_wvalid[0] = m00_couplers_to_m00_couplers_WVALID;
  assign S_AXI_arready[0] = m00_couplers_to_m00_couplers_ARREADY;
  assign S_AXI_awready[0] = m00_couplers_to_m00_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m00_couplers_to_m00_couplers_BRESP;
  assign S_AXI_bvalid[0] = m00_couplers_to_m00_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m00_couplers_to_m00_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m00_couplers_to_m00_couplers_RRESP;
  assign S_AXI_rvalid[0] = m00_couplers_to_m00_couplers_RVALID;
  assign S_AXI_wready[0] = m00_couplers_to_m00_couplers_WREADY;
  assign m00_couplers_to_m00_couplers_ARADDR = S_AXI_araddr[12:0];
  assign m00_couplers_to_m00_couplers_ARPROT = S_AXI_arprot[2:0];
  assign m00_couplers_to_m00_couplers_ARREADY = M_AXI_arready[0];
  assign m00_couplers_to_m00_couplers_ARVALID = S_AXI_arvalid[0];
  assign m00_couplers_to_m00_couplers_AWADDR = S_AXI_awaddr[12:0];
  assign m00_couplers_to_m00_couplers_AWPROT = S_AXI_awprot[2:0];
  assign m00_couplers_to_m00_couplers_AWREADY = M_AXI_awready[0];
  assign m00_couplers_to_m00_couplers_AWVALID = S_AXI_awvalid[0];
  assign m00_couplers_to_m00_couplers_BREADY = S_AXI_bready[0];
  assign m00_couplers_to_m00_couplers_BRESP = M_AXI_bresp[1:0];
  assign m00_couplers_to_m00_couplers_BVALID = M_AXI_bvalid[0];
  assign m00_couplers_to_m00_couplers_RDATA = M_AXI_rdata[31:0];
  assign m00_couplers_to_m00_couplers_RREADY = S_AXI_rready[0];
  assign m00_couplers_to_m00_couplers_RRESP = M_AXI_rresp[1:0];
  assign m00_couplers_to_m00_couplers_RVALID = M_AXI_rvalid[0];
  assign m00_couplers_to_m00_couplers_WDATA = S_AXI_wdata[31:0];
  assign m00_couplers_to_m00_couplers_WREADY = M_AXI_wready[0];
  assign m00_couplers_to_m00_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m00_couplers_to_m00_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module m01_couplers_imp_HV0DJ4
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [8:0]M_AXI_araddr;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [8:0]M_AXI_awaddr;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [8:0]S_AXI_araddr;
  output S_AXI_arready;
  input S_AXI_arvalid;
  input [8:0]S_AXI_awaddr;
  output S_AXI_awready;
  input S_AXI_awvalid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output S_AXI_wready;
  input S_AXI_wvalid;

  wire [8:0]m01_couplers_to_m01_couplers_ARADDR;
  wire m01_couplers_to_m01_couplers_ARREADY;
  wire m01_couplers_to_m01_couplers_ARVALID;
  wire [8:0]m01_couplers_to_m01_couplers_AWADDR;
  wire m01_couplers_to_m01_couplers_AWREADY;
  wire m01_couplers_to_m01_couplers_AWVALID;
  wire m01_couplers_to_m01_couplers_BREADY;
  wire [1:0]m01_couplers_to_m01_couplers_BRESP;
  wire m01_couplers_to_m01_couplers_BVALID;
  wire [31:0]m01_couplers_to_m01_couplers_RDATA;
  wire m01_couplers_to_m01_couplers_RREADY;
  wire [1:0]m01_couplers_to_m01_couplers_RRESP;
  wire m01_couplers_to_m01_couplers_RVALID;
  wire [31:0]m01_couplers_to_m01_couplers_WDATA;
  wire m01_couplers_to_m01_couplers_WREADY;
  wire m01_couplers_to_m01_couplers_WVALID;

  assign M_AXI_araddr[8:0] = m01_couplers_to_m01_couplers_ARADDR;
  assign M_AXI_arvalid = m01_couplers_to_m01_couplers_ARVALID;
  assign M_AXI_awaddr[8:0] = m01_couplers_to_m01_couplers_AWADDR;
  assign M_AXI_awvalid = m01_couplers_to_m01_couplers_AWVALID;
  assign M_AXI_bready = m01_couplers_to_m01_couplers_BREADY;
  assign M_AXI_rready = m01_couplers_to_m01_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m01_couplers_to_m01_couplers_WDATA;
  assign M_AXI_wvalid = m01_couplers_to_m01_couplers_WVALID;
  assign S_AXI_arready = m01_couplers_to_m01_couplers_ARREADY;
  assign S_AXI_awready = m01_couplers_to_m01_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m01_couplers_to_m01_couplers_BRESP;
  assign S_AXI_bvalid = m01_couplers_to_m01_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m01_couplers_to_m01_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m01_couplers_to_m01_couplers_RRESP;
  assign S_AXI_rvalid = m01_couplers_to_m01_couplers_RVALID;
  assign S_AXI_wready = m01_couplers_to_m01_couplers_WREADY;
  assign m01_couplers_to_m01_couplers_ARADDR = S_AXI_araddr[8:0];
  assign m01_couplers_to_m01_couplers_ARREADY = M_AXI_arready;
  assign m01_couplers_to_m01_couplers_ARVALID = S_AXI_arvalid;
  assign m01_couplers_to_m01_couplers_AWADDR = S_AXI_awaddr[8:0];
  assign m01_couplers_to_m01_couplers_AWREADY = M_AXI_awready;
  assign m01_couplers_to_m01_couplers_AWVALID = S_AXI_awvalid;
  assign m01_couplers_to_m01_couplers_BREADY = S_AXI_bready;
  assign m01_couplers_to_m01_couplers_BRESP = M_AXI_bresp[1:0];
  assign m01_couplers_to_m01_couplers_BVALID = M_AXI_bvalid;
  assign m01_couplers_to_m01_couplers_RDATA = M_AXI_rdata[31:0];
  assign m01_couplers_to_m01_couplers_RREADY = S_AXI_rready;
  assign m01_couplers_to_m01_couplers_RRESP = M_AXI_rresp[1:0];
  assign m01_couplers_to_m01_couplers_RVALID = M_AXI_rvalid;
  assign m01_couplers_to_m01_couplers_WDATA = S_AXI_wdata[31:0];
  assign m01_couplers_to_m01_couplers_WREADY = M_AXI_wready;
  assign m01_couplers_to_m01_couplers_WVALID = S_AXI_wvalid;
endmodule

module m02_couplers_imp_1UKXSGA
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arprot,
    S_AXI_arready,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awprot,
    S_AXI_awready,
    S_AXI_awvalid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input [0:0]M_AXI_arready;
  output [0:0]M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input [0:0]M_AXI_awready;
  output [0:0]M_AXI_awvalid;
  output [0:0]M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input [0:0]M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output [0:0]M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input [0:0]M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input [0:0]M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output [0:0]M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [2:0]S_AXI_arprot;
  output [0:0]S_AXI_arready;
  input [0:0]S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [2:0]S_AXI_awprot;
  output [0:0]S_AXI_awready;
  input [0:0]S_AXI_awvalid;
  input [0:0]S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output [0:0]S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  input [0:0]S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output [0:0]S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  output [0:0]S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input [0:0]S_AXI_wvalid;

  wire [31:0]m02_couplers_to_m02_couplers_ARADDR;
  wire [2:0]m02_couplers_to_m02_couplers_ARPROT;
  wire [0:0]m02_couplers_to_m02_couplers_ARREADY;
  wire [0:0]m02_couplers_to_m02_couplers_ARVALID;
  wire [31:0]m02_couplers_to_m02_couplers_AWADDR;
  wire [2:0]m02_couplers_to_m02_couplers_AWPROT;
  wire [0:0]m02_couplers_to_m02_couplers_AWREADY;
  wire [0:0]m02_couplers_to_m02_couplers_AWVALID;
  wire [0:0]m02_couplers_to_m02_couplers_BREADY;
  wire [1:0]m02_couplers_to_m02_couplers_BRESP;
  wire [0:0]m02_couplers_to_m02_couplers_BVALID;
  wire [31:0]m02_couplers_to_m02_couplers_RDATA;
  wire [0:0]m02_couplers_to_m02_couplers_RREADY;
  wire [1:0]m02_couplers_to_m02_couplers_RRESP;
  wire [0:0]m02_couplers_to_m02_couplers_RVALID;
  wire [31:0]m02_couplers_to_m02_couplers_WDATA;
  wire [0:0]m02_couplers_to_m02_couplers_WREADY;
  wire [3:0]m02_couplers_to_m02_couplers_WSTRB;
  wire [0:0]m02_couplers_to_m02_couplers_WVALID;

  assign M_AXI_araddr[31:0] = m02_couplers_to_m02_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = m02_couplers_to_m02_couplers_ARPROT;
  assign M_AXI_arvalid[0] = m02_couplers_to_m02_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = m02_couplers_to_m02_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = m02_couplers_to_m02_couplers_AWPROT;
  assign M_AXI_awvalid[0] = m02_couplers_to_m02_couplers_AWVALID;
  assign M_AXI_bready[0] = m02_couplers_to_m02_couplers_BREADY;
  assign M_AXI_rready[0] = m02_couplers_to_m02_couplers_RREADY;
  assign M_AXI_wdata[31:0] = m02_couplers_to_m02_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = m02_couplers_to_m02_couplers_WSTRB;
  assign M_AXI_wvalid[0] = m02_couplers_to_m02_couplers_WVALID;
  assign S_AXI_arready[0] = m02_couplers_to_m02_couplers_ARREADY;
  assign S_AXI_awready[0] = m02_couplers_to_m02_couplers_AWREADY;
  assign S_AXI_bresp[1:0] = m02_couplers_to_m02_couplers_BRESP;
  assign S_AXI_bvalid[0] = m02_couplers_to_m02_couplers_BVALID;
  assign S_AXI_rdata[31:0] = m02_couplers_to_m02_couplers_RDATA;
  assign S_AXI_rresp[1:0] = m02_couplers_to_m02_couplers_RRESP;
  assign S_AXI_rvalid[0] = m02_couplers_to_m02_couplers_RVALID;
  assign S_AXI_wready[0] = m02_couplers_to_m02_couplers_WREADY;
  assign m02_couplers_to_m02_couplers_ARADDR = S_AXI_araddr[31:0];
  assign m02_couplers_to_m02_couplers_ARPROT = S_AXI_arprot[2:0];
  assign m02_couplers_to_m02_couplers_ARREADY = M_AXI_arready[0];
  assign m02_couplers_to_m02_couplers_ARVALID = S_AXI_arvalid[0];
  assign m02_couplers_to_m02_couplers_AWADDR = S_AXI_awaddr[31:0];
  assign m02_couplers_to_m02_couplers_AWPROT = S_AXI_awprot[2:0];
  assign m02_couplers_to_m02_couplers_AWREADY = M_AXI_awready[0];
  assign m02_couplers_to_m02_couplers_AWVALID = S_AXI_awvalid[0];
  assign m02_couplers_to_m02_couplers_BREADY = S_AXI_bready[0];
  assign m02_couplers_to_m02_couplers_BRESP = M_AXI_bresp[1:0];
  assign m02_couplers_to_m02_couplers_BVALID = M_AXI_bvalid[0];
  assign m02_couplers_to_m02_couplers_RDATA = M_AXI_rdata[31:0];
  assign m02_couplers_to_m02_couplers_RREADY = S_AXI_rready[0];
  assign m02_couplers_to_m02_couplers_RRESP = M_AXI_rresp[1:0];
  assign m02_couplers_to_m02_couplers_RVALID = M_AXI_rvalid[0];
  assign m02_couplers_to_m02_couplers_WDATA = S_AXI_wdata[31:0];
  assign m02_couplers_to_m02_couplers_WREADY = M_AXI_wready[0];
  assign m02_couplers_to_m02_couplers_WSTRB = S_AXI_wstrb[3:0];
  assign m02_couplers_to_m02_couplers_WVALID = S_AXI_wvalid[0];
endmodule

module s00_couplers_imp_JU3OQV
   (M_ACLK,
    M_ARESETN,
    M_AXI_araddr,
    M_AXI_arprot,
    M_AXI_arready,
    M_AXI_arvalid,
    M_AXI_awaddr,
    M_AXI_awprot,
    M_AXI_awready,
    M_AXI_awvalid,
    M_AXI_bready,
    M_AXI_bresp,
    M_AXI_bvalid,
    M_AXI_rdata,
    M_AXI_rready,
    M_AXI_rresp,
    M_AXI_rvalid,
    M_AXI_wdata,
    M_AXI_wready,
    M_AXI_wstrb,
    M_AXI_wvalid,
    S_ACLK,
    S_ARESETN,
    S_AXI_araddr,
    S_AXI_arburst,
    S_AXI_arcache,
    S_AXI_arid,
    S_AXI_arlen,
    S_AXI_arlock,
    S_AXI_arprot,
    S_AXI_arqos,
    S_AXI_arready,
    S_AXI_arsize,
    S_AXI_arvalid,
    S_AXI_awaddr,
    S_AXI_awburst,
    S_AXI_awcache,
    S_AXI_awid,
    S_AXI_awlen,
    S_AXI_awlock,
    S_AXI_awprot,
    S_AXI_awqos,
    S_AXI_awready,
    S_AXI_awsize,
    S_AXI_awvalid,
    S_AXI_bid,
    S_AXI_bready,
    S_AXI_bresp,
    S_AXI_bvalid,
    S_AXI_rdata,
    S_AXI_rid,
    S_AXI_rlast,
    S_AXI_rready,
    S_AXI_rresp,
    S_AXI_rvalid,
    S_AXI_wdata,
    S_AXI_wid,
    S_AXI_wlast,
    S_AXI_wready,
    S_AXI_wstrb,
    S_AXI_wvalid);
  input M_ACLK;
  input [0:0]M_ARESETN;
  output [31:0]M_AXI_araddr;
  output [2:0]M_AXI_arprot;
  input M_AXI_arready;
  output M_AXI_arvalid;
  output [31:0]M_AXI_awaddr;
  output [2:0]M_AXI_awprot;
  input M_AXI_awready;
  output M_AXI_awvalid;
  output M_AXI_bready;
  input [1:0]M_AXI_bresp;
  input M_AXI_bvalid;
  input [31:0]M_AXI_rdata;
  output M_AXI_rready;
  input [1:0]M_AXI_rresp;
  input M_AXI_rvalid;
  output [31:0]M_AXI_wdata;
  input M_AXI_wready;
  output [3:0]M_AXI_wstrb;
  output M_AXI_wvalid;
  input S_ACLK;
  input [0:0]S_ARESETN;
  input [31:0]S_AXI_araddr;
  input [1:0]S_AXI_arburst;
  input [3:0]S_AXI_arcache;
  input [11:0]S_AXI_arid;
  input [3:0]S_AXI_arlen;
  input [1:0]S_AXI_arlock;
  input [2:0]S_AXI_arprot;
  input [3:0]S_AXI_arqos;
  output S_AXI_arready;
  input [2:0]S_AXI_arsize;
  input S_AXI_arvalid;
  input [31:0]S_AXI_awaddr;
  input [1:0]S_AXI_awburst;
  input [3:0]S_AXI_awcache;
  input [11:0]S_AXI_awid;
  input [3:0]S_AXI_awlen;
  input [1:0]S_AXI_awlock;
  input [2:0]S_AXI_awprot;
  input [3:0]S_AXI_awqos;
  output S_AXI_awready;
  input [2:0]S_AXI_awsize;
  input S_AXI_awvalid;
  output [11:0]S_AXI_bid;
  input S_AXI_bready;
  output [1:0]S_AXI_bresp;
  output S_AXI_bvalid;
  output [31:0]S_AXI_rdata;
  output [11:0]S_AXI_rid;
  output S_AXI_rlast;
  input S_AXI_rready;
  output [1:0]S_AXI_rresp;
  output S_AXI_rvalid;
  input [31:0]S_AXI_wdata;
  input [11:0]S_AXI_wid;
  input S_AXI_wlast;
  output S_AXI_wready;
  input [3:0]S_AXI_wstrb;
  input S_AXI_wvalid;

  wire S_ACLK_1;
  wire [0:0]S_ARESETN_1;
  wire [31:0]auto_pc_to_s00_couplers_ARADDR;
  wire [2:0]auto_pc_to_s00_couplers_ARPROT;
  wire auto_pc_to_s00_couplers_ARREADY;
  wire auto_pc_to_s00_couplers_ARVALID;
  wire [31:0]auto_pc_to_s00_couplers_AWADDR;
  wire [2:0]auto_pc_to_s00_couplers_AWPROT;
  wire auto_pc_to_s00_couplers_AWREADY;
  wire auto_pc_to_s00_couplers_AWVALID;
  wire auto_pc_to_s00_couplers_BREADY;
  wire [1:0]auto_pc_to_s00_couplers_BRESP;
  wire auto_pc_to_s00_couplers_BVALID;
  wire [31:0]auto_pc_to_s00_couplers_RDATA;
  wire auto_pc_to_s00_couplers_RREADY;
  wire [1:0]auto_pc_to_s00_couplers_RRESP;
  wire auto_pc_to_s00_couplers_RVALID;
  wire [31:0]auto_pc_to_s00_couplers_WDATA;
  wire auto_pc_to_s00_couplers_WREADY;
  wire [3:0]auto_pc_to_s00_couplers_WSTRB;
  wire auto_pc_to_s00_couplers_WVALID;
  wire [31:0]s00_couplers_to_auto_pc_ARADDR;
  wire [1:0]s00_couplers_to_auto_pc_ARBURST;
  wire [3:0]s00_couplers_to_auto_pc_ARCACHE;
  wire [11:0]s00_couplers_to_auto_pc_ARID;
  wire [3:0]s00_couplers_to_auto_pc_ARLEN;
  wire [1:0]s00_couplers_to_auto_pc_ARLOCK;
  wire [2:0]s00_couplers_to_auto_pc_ARPROT;
  wire [3:0]s00_couplers_to_auto_pc_ARQOS;
  wire s00_couplers_to_auto_pc_ARREADY;
  wire [2:0]s00_couplers_to_auto_pc_ARSIZE;
  wire s00_couplers_to_auto_pc_ARVALID;
  wire [31:0]s00_couplers_to_auto_pc_AWADDR;
  wire [1:0]s00_couplers_to_auto_pc_AWBURST;
  wire [3:0]s00_couplers_to_auto_pc_AWCACHE;
  wire [11:0]s00_couplers_to_auto_pc_AWID;
  wire [3:0]s00_couplers_to_auto_pc_AWLEN;
  wire [1:0]s00_couplers_to_auto_pc_AWLOCK;
  wire [2:0]s00_couplers_to_auto_pc_AWPROT;
  wire [3:0]s00_couplers_to_auto_pc_AWQOS;
  wire s00_couplers_to_auto_pc_AWREADY;
  wire [2:0]s00_couplers_to_auto_pc_AWSIZE;
  wire s00_couplers_to_auto_pc_AWVALID;
  wire [11:0]s00_couplers_to_auto_pc_BID;
  wire s00_couplers_to_auto_pc_BREADY;
  wire [1:0]s00_couplers_to_auto_pc_BRESP;
  wire s00_couplers_to_auto_pc_BVALID;
  wire [31:0]s00_couplers_to_auto_pc_RDATA;
  wire [11:0]s00_couplers_to_auto_pc_RID;
  wire s00_couplers_to_auto_pc_RLAST;
  wire s00_couplers_to_auto_pc_RREADY;
  wire [1:0]s00_couplers_to_auto_pc_RRESP;
  wire s00_couplers_to_auto_pc_RVALID;
  wire [31:0]s00_couplers_to_auto_pc_WDATA;
  wire [11:0]s00_couplers_to_auto_pc_WID;
  wire s00_couplers_to_auto_pc_WLAST;
  wire s00_couplers_to_auto_pc_WREADY;
  wire [3:0]s00_couplers_to_auto_pc_WSTRB;
  wire s00_couplers_to_auto_pc_WVALID;

  assign M_AXI_araddr[31:0] = auto_pc_to_s00_couplers_ARADDR;
  assign M_AXI_arprot[2:0] = auto_pc_to_s00_couplers_ARPROT;
  assign M_AXI_arvalid = auto_pc_to_s00_couplers_ARVALID;
  assign M_AXI_awaddr[31:0] = auto_pc_to_s00_couplers_AWADDR;
  assign M_AXI_awprot[2:0] = auto_pc_to_s00_couplers_AWPROT;
  assign M_AXI_awvalid = auto_pc_to_s00_couplers_AWVALID;
  assign M_AXI_bready = auto_pc_to_s00_couplers_BREADY;
  assign M_AXI_rready = auto_pc_to_s00_couplers_RREADY;
  assign M_AXI_wdata[31:0] = auto_pc_to_s00_couplers_WDATA;
  assign M_AXI_wstrb[3:0] = auto_pc_to_s00_couplers_WSTRB;
  assign M_AXI_wvalid = auto_pc_to_s00_couplers_WVALID;
  assign S_ACLK_1 = S_ACLK;
  assign S_ARESETN_1 = S_ARESETN[0];
  assign S_AXI_arready = s00_couplers_to_auto_pc_ARREADY;
  assign S_AXI_awready = s00_couplers_to_auto_pc_AWREADY;
  assign S_AXI_bid[11:0] = s00_couplers_to_auto_pc_BID;
  assign S_AXI_bresp[1:0] = s00_couplers_to_auto_pc_BRESP;
  assign S_AXI_bvalid = s00_couplers_to_auto_pc_BVALID;
  assign S_AXI_rdata[31:0] = s00_couplers_to_auto_pc_RDATA;
  assign S_AXI_rid[11:0] = s00_couplers_to_auto_pc_RID;
  assign S_AXI_rlast = s00_couplers_to_auto_pc_RLAST;
  assign S_AXI_rresp[1:0] = s00_couplers_to_auto_pc_RRESP;
  assign S_AXI_rvalid = s00_couplers_to_auto_pc_RVALID;
  assign S_AXI_wready = s00_couplers_to_auto_pc_WREADY;
  assign auto_pc_to_s00_couplers_ARREADY = M_AXI_arready;
  assign auto_pc_to_s00_couplers_AWREADY = M_AXI_awready;
  assign auto_pc_to_s00_couplers_BRESP = M_AXI_bresp[1:0];
  assign auto_pc_to_s00_couplers_BVALID = M_AXI_bvalid;
  assign auto_pc_to_s00_couplers_RDATA = M_AXI_rdata[31:0];
  assign auto_pc_to_s00_couplers_RRESP = M_AXI_rresp[1:0];
  assign auto_pc_to_s00_couplers_RVALID = M_AXI_rvalid;
  assign auto_pc_to_s00_couplers_WREADY = M_AXI_wready;
  assign s00_couplers_to_auto_pc_ARADDR = S_AXI_araddr[31:0];
  assign s00_couplers_to_auto_pc_ARBURST = S_AXI_arburst[1:0];
  assign s00_couplers_to_auto_pc_ARCACHE = S_AXI_arcache[3:0];
  assign s00_couplers_to_auto_pc_ARID = S_AXI_arid[11:0];
  assign s00_couplers_to_auto_pc_ARLEN = S_AXI_arlen[3:0];
  assign s00_couplers_to_auto_pc_ARLOCK = S_AXI_arlock[1:0];
  assign s00_couplers_to_auto_pc_ARPROT = S_AXI_arprot[2:0];
  assign s00_couplers_to_auto_pc_ARQOS = S_AXI_arqos[3:0];
  assign s00_couplers_to_auto_pc_ARSIZE = S_AXI_arsize[2:0];
  assign s00_couplers_to_auto_pc_ARVALID = S_AXI_arvalid;
  assign s00_couplers_to_auto_pc_AWADDR = S_AXI_awaddr[31:0];
  assign s00_couplers_to_auto_pc_AWBURST = S_AXI_awburst[1:0];
  assign s00_couplers_to_auto_pc_AWCACHE = S_AXI_awcache[3:0];
  assign s00_couplers_to_auto_pc_AWID = S_AXI_awid[11:0];
  assign s00_couplers_to_auto_pc_AWLEN = S_AXI_awlen[3:0];
  assign s00_couplers_to_auto_pc_AWLOCK = S_AXI_awlock[1:0];
  assign s00_couplers_to_auto_pc_AWPROT = S_AXI_awprot[2:0];
  assign s00_couplers_to_auto_pc_AWQOS = S_AXI_awqos[3:0];
  assign s00_couplers_to_auto_pc_AWSIZE = S_AXI_awsize[2:0];
  assign s00_couplers_to_auto_pc_AWVALID = S_AXI_awvalid;
  assign s00_couplers_to_auto_pc_BREADY = S_AXI_bready;
  assign s00_couplers_to_auto_pc_RREADY = S_AXI_rready;
  assign s00_couplers_to_auto_pc_WDATA = S_AXI_wdata[31:0];
  assign s00_couplers_to_auto_pc_WID = S_AXI_wid[11:0];
  assign s00_couplers_to_auto_pc_WLAST = S_AXI_wlast;
  assign s00_couplers_to_auto_pc_WSTRB = S_AXI_wstrb[3:0];
  assign s00_couplers_to_auto_pc_WVALID = S_AXI_wvalid;
elink2_top_auto_pc_0 auto_pc
       (.aclk(S_ACLK_1),
        .aresetn(S_ARESETN_1),
        .m_axi_araddr(auto_pc_to_s00_couplers_ARADDR),
        .m_axi_arprot(auto_pc_to_s00_couplers_ARPROT),
        .m_axi_arready(auto_pc_to_s00_couplers_ARREADY),
        .m_axi_arvalid(auto_pc_to_s00_couplers_ARVALID),
        .m_axi_awaddr(auto_pc_to_s00_couplers_AWADDR),
        .m_axi_awprot(auto_pc_to_s00_couplers_AWPROT),
        .m_axi_awready(auto_pc_to_s00_couplers_AWREADY),
        .m_axi_awvalid(auto_pc_to_s00_couplers_AWVALID),
        .m_axi_bready(auto_pc_to_s00_couplers_BREADY),
        .m_axi_bresp(auto_pc_to_s00_couplers_BRESP),
        .m_axi_bvalid(auto_pc_to_s00_couplers_BVALID),
        .m_axi_rdata(auto_pc_to_s00_couplers_RDATA),
        .m_axi_rready(auto_pc_to_s00_couplers_RREADY),
        .m_axi_rresp(auto_pc_to_s00_couplers_RRESP),
        .m_axi_rvalid(auto_pc_to_s00_couplers_RVALID),
        .m_axi_wdata(auto_pc_to_s00_couplers_WDATA),
        .m_axi_wready(auto_pc_to_s00_couplers_WREADY),
        .m_axi_wstrb(auto_pc_to_s00_couplers_WSTRB),
        .m_axi_wvalid(auto_pc_to_s00_couplers_WVALID),
        .s_axi_araddr(s00_couplers_to_auto_pc_ARADDR),
        .s_axi_arburst(s00_couplers_to_auto_pc_ARBURST),
        .s_axi_arcache(s00_couplers_to_auto_pc_ARCACHE),
        .s_axi_arid(s00_couplers_to_auto_pc_ARID),
        .s_axi_arlen(s00_couplers_to_auto_pc_ARLEN),
        .s_axi_arlock(s00_couplers_to_auto_pc_ARLOCK),
        .s_axi_arprot(s00_couplers_to_auto_pc_ARPROT),
        .s_axi_arqos(s00_couplers_to_auto_pc_ARQOS),
        .s_axi_arready(s00_couplers_to_auto_pc_ARREADY),
        .s_axi_arsize(s00_couplers_to_auto_pc_ARSIZE),
        .s_axi_arvalid(s00_couplers_to_auto_pc_ARVALID),
        .s_axi_awaddr(s00_couplers_to_auto_pc_AWADDR),
        .s_axi_awburst(s00_couplers_to_auto_pc_AWBURST),
        .s_axi_awcache(s00_couplers_to_auto_pc_AWCACHE),
        .s_axi_awid(s00_couplers_to_auto_pc_AWID),
        .s_axi_awlen(s00_couplers_to_auto_pc_AWLEN),
        .s_axi_awlock(s00_couplers_to_auto_pc_AWLOCK),
        .s_axi_awprot(s00_couplers_to_auto_pc_AWPROT),
        .s_axi_awqos(s00_couplers_to_auto_pc_AWQOS),
        .s_axi_awready(s00_couplers_to_auto_pc_AWREADY),
        .s_axi_awsize(s00_couplers_to_auto_pc_AWSIZE),
        .s_axi_awvalid(s00_couplers_to_auto_pc_AWVALID),
        .s_axi_bid(s00_couplers_to_auto_pc_BID),
        .s_axi_bready(s00_couplers_to_auto_pc_BREADY),
        .s_axi_bresp(s00_couplers_to_auto_pc_BRESP),
        .s_axi_bvalid(s00_couplers_to_auto_pc_BVALID),
        .s_axi_rdata(s00_couplers_to_auto_pc_RDATA),
        .s_axi_rid(s00_couplers_to_auto_pc_RID),
        .s_axi_rlast(s00_couplers_to_auto_pc_RLAST),
        .s_axi_rready(s00_couplers_to_auto_pc_RREADY),
        .s_axi_rresp(s00_couplers_to_auto_pc_RRESP),
        .s_axi_rvalid(s00_couplers_to_auto_pc_RVALID),
        .s_axi_wdata(s00_couplers_to_auto_pc_WDATA),
        .s_axi_wid(s00_couplers_to_auto_pc_WID),
        .s_axi_wlast(s00_couplers_to_auto_pc_WLAST),
        .s_axi_wready(s00_couplers_to_auto_pc_WREADY),
        .s_axi_wstrb(s00_couplers_to_auto_pc_WSTRB),
        .s_axi_wvalid(s00_couplers_to_auto_pc_WVALID));
endmodule
