//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
//Date        : Wed Jun 24 00:24:56 2015
//Host        : lain running 64-bit Gentoo Base System release 2.2
//Command     : generate_target elink2_top_wrapper.bd
//Design      : elink2_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module elink2_top_wrapper
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
    csi_intr,
    gpio_0_tri_io);
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
  inout [63:0]gpio_0_tri_io;

  wire CAM_I2C_SCL;
  wire CAM_I2C_SDA;
  wire CCLK_N;
  wire CCLK_P;
  wire [31:0]CSI_AXI_araddr;
  wire [2:0]CSI_AXI_arprot;
  wire [0:0]CSI_AXI_arready;
  wire [0:0]CSI_AXI_arvalid;
  wire [31:0]CSI_AXI_awaddr;
  wire [2:0]CSI_AXI_awprot;
  wire [0:0]CSI_AXI_awready;
  wire [0:0]CSI_AXI_awvalid;
  wire [0:0]CSI_AXI_bready;
  wire [1:0]CSI_AXI_bresp;
  wire [0:0]CSI_AXI_bvalid;
  wire [31:0]CSI_AXI_rdata;
  wire [0:0]CSI_AXI_rready;
  wire [1:0]CSI_AXI_rresp;
  wire [0:0]CSI_AXI_rvalid;
  wire [31:0]CSI_AXI_wdata;
  wire [0:0]CSI_AXI_wready;
  wire [3:0]CSI_AXI_wstrb;
  wire [0:0]CSI_AXI_wvalid;
  wire [31:0]CSI_VIDEO_tdata;
  wire [3:0]CSI_VIDEO_tkeep;
  wire CSI_VIDEO_tlast;
  wire CSI_VIDEO_tready;
  wire [0:0]CSI_VIDEO_tuser;
  wire CSI_VIDEO_tvalid;
  wire [14:0]DDR_addr;
  wire [2:0]DDR_ba;
  wire DDR_cas_n;
  wire DDR_ck_n;
  wire DDR_ck_p;
  wire DDR_cke;
  wire DDR_cs_n;
  wire [3:0]DDR_dm;
  wire [31:0]DDR_dq;
  wire [3:0]DDR_dqs_n;
  wire [3:0]DDR_dqs_p;
  wire DDR_odt;
  wire DDR_ras_n;
  wire DDR_reset_n;
  wire DDR_we_n;
  wire [0:0]DSP_RESET_N;
  wire FCLK_CLK0;
  wire FCLK_CLK1;
  wire FIXED_IO_ddr_vrn;
  wire FIXED_IO_ddr_vrp;
  wire [53:0]FIXED_IO_mio;
  wire FIXED_IO_ps_clk;
  wire FIXED_IO_ps_porb;
  wire FIXED_IO_ps_srstb;
  wire I2C_SCL;
  wire I2C_SDA;
  wire [7:0]RX_data_n;
  wire [7:0]RX_data_p;
  wire RX_frame_n;
  wire RX_frame_p;
  wire RX_lclk_n;
  wire RX_lclk_p;
  wire RX_rd_wait_n;
  wire RX_rd_wait_p;
  wire RX_wr_wait_n;
  wire RX_wr_wait_p;
  wire [7:0]TX_data_n;
  wire [7:0]TX_data_p;
  wire TX_frame_n;
  wire TX_frame_p;
  wire TX_lclk_n;
  wire TX_lclk_p;
  wire TX_rd_wait_n;
  wire TX_rd_wait_p;
  wire TX_wr_wait_n;
  wire TX_wr_wait_p;
  wire [0:0]aresetn;
  wire csi_intr;
  wire [0:0]gpio_0_tri_i_0;
  wire [1:1]gpio_0_tri_i_1;
  wire [10:10]gpio_0_tri_i_10;
  wire [11:11]gpio_0_tri_i_11;
  wire [12:12]gpio_0_tri_i_12;
  wire [13:13]gpio_0_tri_i_13;
  wire [14:14]gpio_0_tri_i_14;
  wire [15:15]gpio_0_tri_i_15;
  wire [16:16]gpio_0_tri_i_16;
  wire [17:17]gpio_0_tri_i_17;
  wire [18:18]gpio_0_tri_i_18;
  wire [19:19]gpio_0_tri_i_19;
  wire [2:2]gpio_0_tri_i_2;
  wire [20:20]gpio_0_tri_i_20;
  wire [21:21]gpio_0_tri_i_21;
  wire [22:22]gpio_0_tri_i_22;
  wire [23:23]gpio_0_tri_i_23;
  wire [24:24]gpio_0_tri_i_24;
  wire [25:25]gpio_0_tri_i_25;
  wire [26:26]gpio_0_tri_i_26;
  wire [27:27]gpio_0_tri_i_27;
  wire [28:28]gpio_0_tri_i_28;
  wire [29:29]gpio_0_tri_i_29;
  wire [3:3]gpio_0_tri_i_3;
  wire [30:30]gpio_0_tri_i_30;
  wire [31:31]gpio_0_tri_i_31;
  wire [32:32]gpio_0_tri_i_32;
  wire [33:33]gpio_0_tri_i_33;
  wire [34:34]gpio_0_tri_i_34;
  wire [35:35]gpio_0_tri_i_35;
  wire [36:36]gpio_0_tri_i_36;
  wire [37:37]gpio_0_tri_i_37;
  wire [38:38]gpio_0_tri_i_38;
  wire [39:39]gpio_0_tri_i_39;
  wire [4:4]gpio_0_tri_i_4;
  wire [40:40]gpio_0_tri_i_40;
  wire [41:41]gpio_0_tri_i_41;
  wire [42:42]gpio_0_tri_i_42;
  wire [43:43]gpio_0_tri_i_43;
  wire [44:44]gpio_0_tri_i_44;
  wire [45:45]gpio_0_tri_i_45;
  wire [46:46]gpio_0_tri_i_46;
  wire [47:47]gpio_0_tri_i_47;
  wire [48:48]gpio_0_tri_i_48;
  wire [49:49]gpio_0_tri_i_49;
  wire [5:5]gpio_0_tri_i_5;
  wire [50:50]gpio_0_tri_i_50;
  wire [51:51]gpio_0_tri_i_51;
  wire [52:52]gpio_0_tri_i_52;
  wire [53:53]gpio_0_tri_i_53;
  wire [54:54]gpio_0_tri_i_54;
  wire [55:55]gpio_0_tri_i_55;
  wire [56:56]gpio_0_tri_i_56;
  wire [57:57]gpio_0_tri_i_57;
  wire [58:58]gpio_0_tri_i_58;
  wire [59:59]gpio_0_tri_i_59;
  wire [6:6]gpio_0_tri_i_6;
  wire [60:60]gpio_0_tri_i_60;
  wire [61:61]gpio_0_tri_i_61;
  wire [62:62]gpio_0_tri_i_62;
  wire [63:63]gpio_0_tri_i_63;
  wire [7:7]gpio_0_tri_i_7;
  wire [8:8]gpio_0_tri_i_8;
  wire [9:9]gpio_0_tri_i_9;
  wire [0:0]gpio_0_tri_io_0;
  wire [1:1]gpio_0_tri_io_1;
  wire [10:10]gpio_0_tri_io_10;
  wire [11:11]gpio_0_tri_io_11;
  wire [12:12]gpio_0_tri_io_12;
  wire [13:13]gpio_0_tri_io_13;
  wire [14:14]gpio_0_tri_io_14;
  wire [15:15]gpio_0_tri_io_15;
  wire [16:16]gpio_0_tri_io_16;
  wire [17:17]gpio_0_tri_io_17;
  wire [18:18]gpio_0_tri_io_18;
  wire [19:19]gpio_0_tri_io_19;
  wire [2:2]gpio_0_tri_io_2;
  wire [20:20]gpio_0_tri_io_20;
  wire [21:21]gpio_0_tri_io_21;
  wire [22:22]gpio_0_tri_io_22;
  wire [23:23]gpio_0_tri_io_23;
  wire [24:24]gpio_0_tri_io_24;
  wire [25:25]gpio_0_tri_io_25;
  wire [26:26]gpio_0_tri_io_26;
  wire [27:27]gpio_0_tri_io_27;
  wire [28:28]gpio_0_tri_io_28;
  wire [29:29]gpio_0_tri_io_29;
  wire [3:3]gpio_0_tri_io_3;
  wire [30:30]gpio_0_tri_io_30;
  wire [31:31]gpio_0_tri_io_31;
  wire [32:32]gpio_0_tri_io_32;
  wire [33:33]gpio_0_tri_io_33;
  wire [34:34]gpio_0_tri_io_34;
  wire [35:35]gpio_0_tri_io_35;
  wire [36:36]gpio_0_tri_io_36;
  wire [37:37]gpio_0_tri_io_37;
  wire [38:38]gpio_0_tri_io_38;
  wire [39:39]gpio_0_tri_io_39;
  wire [4:4]gpio_0_tri_io_4;
  wire [40:40]gpio_0_tri_io_40;
  wire [41:41]gpio_0_tri_io_41;
  wire [42:42]gpio_0_tri_io_42;
  wire [43:43]gpio_0_tri_io_43;
  wire [44:44]gpio_0_tri_io_44;
  wire [45:45]gpio_0_tri_io_45;
  wire [46:46]gpio_0_tri_io_46;
  wire [47:47]gpio_0_tri_io_47;
  wire [48:48]gpio_0_tri_io_48;
  wire [49:49]gpio_0_tri_io_49;
  wire [5:5]gpio_0_tri_io_5;
  wire [50:50]gpio_0_tri_io_50;
  wire [51:51]gpio_0_tri_io_51;
  wire [52:52]gpio_0_tri_io_52;
  wire [53:53]gpio_0_tri_io_53;
  wire [54:54]gpio_0_tri_io_54;
  wire [55:55]gpio_0_tri_io_55;
  wire [56:56]gpio_0_tri_io_56;
  wire [57:57]gpio_0_tri_io_57;
  wire [58:58]gpio_0_tri_io_58;
  wire [59:59]gpio_0_tri_io_59;
  wire [6:6]gpio_0_tri_io_6;
  wire [60:60]gpio_0_tri_io_60;
  wire [61:61]gpio_0_tri_io_61;
  wire [62:62]gpio_0_tri_io_62;
  wire [63:63]gpio_0_tri_io_63;
  wire [7:7]gpio_0_tri_io_7;
  wire [8:8]gpio_0_tri_io_8;
  wire [9:9]gpio_0_tri_io_9;
  wire [0:0]gpio_0_tri_o_0;
  wire [1:1]gpio_0_tri_o_1;
  wire [10:10]gpio_0_tri_o_10;
  wire [11:11]gpio_0_tri_o_11;
  wire [12:12]gpio_0_tri_o_12;
  wire [13:13]gpio_0_tri_o_13;
  wire [14:14]gpio_0_tri_o_14;
  wire [15:15]gpio_0_tri_o_15;
  wire [16:16]gpio_0_tri_o_16;
  wire [17:17]gpio_0_tri_o_17;
  wire [18:18]gpio_0_tri_o_18;
  wire [19:19]gpio_0_tri_o_19;
  wire [2:2]gpio_0_tri_o_2;
  wire [20:20]gpio_0_tri_o_20;
  wire [21:21]gpio_0_tri_o_21;
  wire [22:22]gpio_0_tri_o_22;
  wire [23:23]gpio_0_tri_o_23;
  wire [24:24]gpio_0_tri_o_24;
  wire [25:25]gpio_0_tri_o_25;
  wire [26:26]gpio_0_tri_o_26;
  wire [27:27]gpio_0_tri_o_27;
  wire [28:28]gpio_0_tri_o_28;
  wire [29:29]gpio_0_tri_o_29;
  wire [3:3]gpio_0_tri_o_3;
  wire [30:30]gpio_0_tri_o_30;
  wire [31:31]gpio_0_tri_o_31;
  wire [32:32]gpio_0_tri_o_32;
  wire [33:33]gpio_0_tri_o_33;
  wire [34:34]gpio_0_tri_o_34;
  wire [35:35]gpio_0_tri_o_35;
  wire [36:36]gpio_0_tri_o_36;
  wire [37:37]gpio_0_tri_o_37;
  wire [38:38]gpio_0_tri_o_38;
  wire [39:39]gpio_0_tri_o_39;
  wire [4:4]gpio_0_tri_o_4;
  wire [40:40]gpio_0_tri_o_40;
  wire [41:41]gpio_0_tri_o_41;
  wire [42:42]gpio_0_tri_o_42;
  wire [43:43]gpio_0_tri_o_43;
  wire [44:44]gpio_0_tri_o_44;
  wire [45:45]gpio_0_tri_o_45;
  wire [46:46]gpio_0_tri_o_46;
  wire [47:47]gpio_0_tri_o_47;
  wire [48:48]gpio_0_tri_o_48;
  wire [49:49]gpio_0_tri_o_49;
  wire [5:5]gpio_0_tri_o_5;
  wire [50:50]gpio_0_tri_o_50;
  wire [51:51]gpio_0_tri_o_51;
  wire [52:52]gpio_0_tri_o_52;
  wire [53:53]gpio_0_tri_o_53;
  wire [54:54]gpio_0_tri_o_54;
  wire [55:55]gpio_0_tri_o_55;
  wire [56:56]gpio_0_tri_o_56;
  wire [57:57]gpio_0_tri_o_57;
  wire [58:58]gpio_0_tri_o_58;
  wire [59:59]gpio_0_tri_o_59;
  wire [6:6]gpio_0_tri_o_6;
  wire [60:60]gpio_0_tri_o_60;
  wire [61:61]gpio_0_tri_o_61;
  wire [62:62]gpio_0_tri_o_62;
  wire [63:63]gpio_0_tri_o_63;
  wire [7:7]gpio_0_tri_o_7;
  wire [8:8]gpio_0_tri_o_8;
  wire [9:9]gpio_0_tri_o_9;
  wire [0:0]gpio_0_tri_t_0;
  wire [1:1]gpio_0_tri_t_1;
  wire [10:10]gpio_0_tri_t_10;
  wire [11:11]gpio_0_tri_t_11;
  wire [12:12]gpio_0_tri_t_12;
  wire [13:13]gpio_0_tri_t_13;
  wire [14:14]gpio_0_tri_t_14;
  wire [15:15]gpio_0_tri_t_15;
  wire [16:16]gpio_0_tri_t_16;
  wire [17:17]gpio_0_tri_t_17;
  wire [18:18]gpio_0_tri_t_18;
  wire [19:19]gpio_0_tri_t_19;
  wire [2:2]gpio_0_tri_t_2;
  wire [20:20]gpio_0_tri_t_20;
  wire [21:21]gpio_0_tri_t_21;
  wire [22:22]gpio_0_tri_t_22;
  wire [23:23]gpio_0_tri_t_23;
  wire [24:24]gpio_0_tri_t_24;
  wire [25:25]gpio_0_tri_t_25;
  wire [26:26]gpio_0_tri_t_26;
  wire [27:27]gpio_0_tri_t_27;
  wire [28:28]gpio_0_tri_t_28;
  wire [29:29]gpio_0_tri_t_29;
  wire [3:3]gpio_0_tri_t_3;
  wire [30:30]gpio_0_tri_t_30;
  wire [31:31]gpio_0_tri_t_31;
  wire [32:32]gpio_0_tri_t_32;
  wire [33:33]gpio_0_tri_t_33;
  wire [34:34]gpio_0_tri_t_34;
  wire [35:35]gpio_0_tri_t_35;
  wire [36:36]gpio_0_tri_t_36;
  wire [37:37]gpio_0_tri_t_37;
  wire [38:38]gpio_0_tri_t_38;
  wire [39:39]gpio_0_tri_t_39;
  wire [4:4]gpio_0_tri_t_4;
  wire [40:40]gpio_0_tri_t_40;
  wire [41:41]gpio_0_tri_t_41;
  wire [42:42]gpio_0_tri_t_42;
  wire [43:43]gpio_0_tri_t_43;
  wire [44:44]gpio_0_tri_t_44;
  wire [45:45]gpio_0_tri_t_45;
  wire [46:46]gpio_0_tri_t_46;
  wire [47:47]gpio_0_tri_t_47;
  wire [48:48]gpio_0_tri_t_48;
  wire [49:49]gpio_0_tri_t_49;
  wire [5:5]gpio_0_tri_t_5;
  wire [50:50]gpio_0_tri_t_50;
  wire [51:51]gpio_0_tri_t_51;
  wire [52:52]gpio_0_tri_t_52;
  wire [53:53]gpio_0_tri_t_53;
  wire [54:54]gpio_0_tri_t_54;
  wire [55:55]gpio_0_tri_t_55;
  wire [56:56]gpio_0_tri_t_56;
  wire [57:57]gpio_0_tri_t_57;
  wire [58:58]gpio_0_tri_t_58;
  wire [59:59]gpio_0_tri_t_59;
  wire [6:6]gpio_0_tri_t_6;
  wire [60:60]gpio_0_tri_t_60;
  wire [61:61]gpio_0_tri_t_61;
  wire [62:62]gpio_0_tri_t_62;
  wire [63:63]gpio_0_tri_t_63;
  wire [7:7]gpio_0_tri_t_7;
  wire [8:8]gpio_0_tri_t_8;
  wire [9:9]gpio_0_tri_t_9;

elink2_top elink2_top_i
       (.CAM_I2C_SCL(CAM_I2C_SCL),
        .CAM_I2C_SDA(CAM_I2C_SDA),
        .CCLK_N(CCLK_N),
        .CCLK_P(CCLK_P),
        .CSI_AXI_araddr(CSI_AXI_araddr),
        .CSI_AXI_arprot(CSI_AXI_arprot),
        .CSI_AXI_arready(CSI_AXI_arready),
        .CSI_AXI_arvalid(CSI_AXI_arvalid),
        .CSI_AXI_awaddr(CSI_AXI_awaddr),
        .CSI_AXI_awprot(CSI_AXI_awprot),
        .CSI_AXI_awready(CSI_AXI_awready),
        .CSI_AXI_awvalid(CSI_AXI_awvalid),
        .CSI_AXI_bready(CSI_AXI_bready),
        .CSI_AXI_bresp(CSI_AXI_bresp),
        .CSI_AXI_bvalid(CSI_AXI_bvalid),
        .CSI_AXI_rdata(CSI_AXI_rdata),
        .CSI_AXI_rready(CSI_AXI_rready),
        .CSI_AXI_rresp(CSI_AXI_rresp),
        .CSI_AXI_rvalid(CSI_AXI_rvalid),
        .CSI_AXI_wdata(CSI_AXI_wdata),
        .CSI_AXI_wready(CSI_AXI_wready),
        .CSI_AXI_wstrb(CSI_AXI_wstrb),
        .CSI_AXI_wvalid(CSI_AXI_wvalid),
        .CSI_VIDEO_tdata(CSI_VIDEO_tdata),
        .CSI_VIDEO_tkeep(CSI_VIDEO_tkeep),
        .CSI_VIDEO_tlast(CSI_VIDEO_tlast),
        .CSI_VIDEO_tready(CSI_VIDEO_tready),
        .CSI_VIDEO_tuser(CSI_VIDEO_tuser),
        .CSI_VIDEO_tvalid(CSI_VIDEO_tvalid),
        .DDR_addr(DDR_addr),
        .DDR_ba(DDR_ba),
        .DDR_cas_n(DDR_cas_n),
        .DDR_ck_n(DDR_ck_n),
        .DDR_ck_p(DDR_ck_p),
        .DDR_cke(DDR_cke),
        .DDR_cs_n(DDR_cs_n),
        .DDR_dm(DDR_dm),
        .DDR_dq(DDR_dq),
        .DDR_dqs_n(DDR_dqs_n),
        .DDR_dqs_p(DDR_dqs_p),
        .DDR_odt(DDR_odt),
        .DDR_ras_n(DDR_ras_n),
        .DDR_reset_n(DDR_reset_n),
        .DDR_we_n(DDR_we_n),
        .DSP_RESET_N(DSP_RESET_N),
        .FCLK_CLK0(FCLK_CLK0),
        .FCLK_CLK1(FCLK_CLK1),
        .FIXED_IO_ddr_vrn(FIXED_IO_ddr_vrn),
        .FIXED_IO_ddr_vrp(FIXED_IO_ddr_vrp),
        .FIXED_IO_mio(FIXED_IO_mio),
        .FIXED_IO_ps_clk(FIXED_IO_ps_clk),
        .FIXED_IO_ps_porb(FIXED_IO_ps_porb),
        .FIXED_IO_ps_srstb(FIXED_IO_ps_srstb),
        .GPIO_0_tri_i({gpio_0_tri_i_63,gpio_0_tri_i_62,gpio_0_tri_i_61,gpio_0_tri_i_60,gpio_0_tri_i_59,gpio_0_tri_i_58,gpio_0_tri_i_57,gpio_0_tri_i_56,gpio_0_tri_i_55,gpio_0_tri_i_54,gpio_0_tri_i_53,gpio_0_tri_i_52,gpio_0_tri_i_51,gpio_0_tri_i_50,gpio_0_tri_i_49,gpio_0_tri_i_48,gpio_0_tri_i_47,gpio_0_tri_i_46,gpio_0_tri_i_45,gpio_0_tri_i_44,gpio_0_tri_i_43,gpio_0_tri_i_42,gpio_0_tri_i_41,gpio_0_tri_i_40,gpio_0_tri_i_39,gpio_0_tri_i_38,gpio_0_tri_i_37,gpio_0_tri_i_36,gpio_0_tri_i_35,gpio_0_tri_i_34,gpio_0_tri_i_33,gpio_0_tri_i_32,gpio_0_tri_i_31,gpio_0_tri_i_30,gpio_0_tri_i_29,gpio_0_tri_i_28,gpio_0_tri_i_27,gpio_0_tri_i_26,gpio_0_tri_i_25,gpio_0_tri_i_24,gpio_0_tri_i_23,gpio_0_tri_i_22,gpio_0_tri_i_21,gpio_0_tri_i_20,gpio_0_tri_i_19,gpio_0_tri_i_18,gpio_0_tri_i_17,gpio_0_tri_i_16,gpio_0_tri_i_15,gpio_0_tri_i_14,gpio_0_tri_i_13,gpio_0_tri_i_12,gpio_0_tri_i_11,gpio_0_tri_i_10,gpio_0_tri_i_9,gpio_0_tri_i_8,gpio_0_tri_i_7,gpio_0_tri_i_6,gpio_0_tri_i_5,gpio_0_tri_i_4,gpio_0_tri_i_3,gpio_0_tri_i_2,gpio_0_tri_i_1,gpio_0_tri_i_0}),
        .GPIO_0_tri_o({gpio_0_tri_o_63,gpio_0_tri_o_62,gpio_0_tri_o_61,gpio_0_tri_o_60,gpio_0_tri_o_59,gpio_0_tri_o_58,gpio_0_tri_o_57,gpio_0_tri_o_56,gpio_0_tri_o_55,gpio_0_tri_o_54,gpio_0_tri_o_53,gpio_0_tri_o_52,gpio_0_tri_o_51,gpio_0_tri_o_50,gpio_0_tri_o_49,gpio_0_tri_o_48,gpio_0_tri_o_47,gpio_0_tri_o_46,gpio_0_tri_o_45,gpio_0_tri_o_44,gpio_0_tri_o_43,gpio_0_tri_o_42,gpio_0_tri_o_41,gpio_0_tri_o_40,gpio_0_tri_o_39,gpio_0_tri_o_38,gpio_0_tri_o_37,gpio_0_tri_o_36,gpio_0_tri_o_35,gpio_0_tri_o_34,gpio_0_tri_o_33,gpio_0_tri_o_32,gpio_0_tri_o_31,gpio_0_tri_o_30,gpio_0_tri_o_29,gpio_0_tri_o_28,gpio_0_tri_o_27,gpio_0_tri_o_26,gpio_0_tri_o_25,gpio_0_tri_o_24,gpio_0_tri_o_23,gpio_0_tri_o_22,gpio_0_tri_o_21,gpio_0_tri_o_20,gpio_0_tri_o_19,gpio_0_tri_o_18,gpio_0_tri_o_17,gpio_0_tri_o_16,gpio_0_tri_o_15,gpio_0_tri_o_14,gpio_0_tri_o_13,gpio_0_tri_o_12,gpio_0_tri_o_11,gpio_0_tri_o_10,gpio_0_tri_o_9,gpio_0_tri_o_8,gpio_0_tri_o_7,gpio_0_tri_o_6,gpio_0_tri_o_5,gpio_0_tri_o_4,gpio_0_tri_o_3,gpio_0_tri_o_2,gpio_0_tri_o_1,gpio_0_tri_o_0}),
        .GPIO_0_tri_t({gpio_0_tri_t_63,gpio_0_tri_t_62,gpio_0_tri_t_61,gpio_0_tri_t_60,gpio_0_tri_t_59,gpio_0_tri_t_58,gpio_0_tri_t_57,gpio_0_tri_t_56,gpio_0_tri_t_55,gpio_0_tri_t_54,gpio_0_tri_t_53,gpio_0_tri_t_52,gpio_0_tri_t_51,gpio_0_tri_t_50,gpio_0_tri_t_49,gpio_0_tri_t_48,gpio_0_tri_t_47,gpio_0_tri_t_46,gpio_0_tri_t_45,gpio_0_tri_t_44,gpio_0_tri_t_43,gpio_0_tri_t_42,gpio_0_tri_t_41,gpio_0_tri_t_40,gpio_0_tri_t_39,gpio_0_tri_t_38,gpio_0_tri_t_37,gpio_0_tri_t_36,gpio_0_tri_t_35,gpio_0_tri_t_34,gpio_0_tri_t_33,gpio_0_tri_t_32,gpio_0_tri_t_31,gpio_0_tri_t_30,gpio_0_tri_t_29,gpio_0_tri_t_28,gpio_0_tri_t_27,gpio_0_tri_t_26,gpio_0_tri_t_25,gpio_0_tri_t_24,gpio_0_tri_t_23,gpio_0_tri_t_22,gpio_0_tri_t_21,gpio_0_tri_t_20,gpio_0_tri_t_19,gpio_0_tri_t_18,gpio_0_tri_t_17,gpio_0_tri_t_16,gpio_0_tri_t_15,gpio_0_tri_t_14,gpio_0_tri_t_13,gpio_0_tri_t_12,gpio_0_tri_t_11,gpio_0_tri_t_10,gpio_0_tri_t_9,gpio_0_tri_t_8,gpio_0_tri_t_7,gpio_0_tri_t_6,gpio_0_tri_t_5,gpio_0_tri_t_4,gpio_0_tri_t_3,gpio_0_tri_t_2,gpio_0_tri_t_1,gpio_0_tri_t_0}),
        .I2C_SCL(I2C_SCL),
        .I2C_SDA(I2C_SDA),
        .RX_data_n(RX_data_n),
        .RX_data_p(RX_data_p),
        .RX_frame_n(RX_frame_n),
        .RX_frame_p(RX_frame_p),
        .RX_lclk_n(RX_lclk_n),
        .RX_lclk_p(RX_lclk_p),
        .RX_rd_wait_n(RX_rd_wait_n),
        .RX_rd_wait_p(RX_rd_wait_p),
        .RX_wr_wait_n(RX_wr_wait_n),
        .RX_wr_wait_p(RX_wr_wait_p),
        .TX_data_n(TX_data_n),
        .TX_data_p(TX_data_p),
        .TX_frame_n(TX_frame_n),
        .TX_frame_p(TX_frame_p),
        .TX_lclk_n(TX_lclk_n),
        .TX_lclk_p(TX_lclk_p),
        .TX_rd_wait_n(TX_rd_wait_n),
        .TX_rd_wait_p(TX_rd_wait_p),
        .TX_wr_wait_n(TX_wr_wait_n),
        .TX_wr_wait_p(TX_wr_wait_p),
        .aresetn(aresetn),
        .csi_intr(csi_intr));
IOBUF gpio_0_tri_iobuf_0
       (.I(gpio_0_tri_o_0),
        .IO(gpio_0_tri_io[0]),
        .O(gpio_0_tri_i_0),
        .T(gpio_0_tri_t_0));
IOBUF gpio_0_tri_iobuf_1
       (.I(gpio_0_tri_o_1),
        .IO(gpio_0_tri_io[1]),
        .O(gpio_0_tri_i_1),
        .T(gpio_0_tri_t_1));
IOBUF gpio_0_tri_iobuf_10
       (.I(gpio_0_tri_o_10),
        .IO(gpio_0_tri_io[10]),
        .O(gpio_0_tri_i_10),
        .T(gpio_0_tri_t_10));
IOBUF gpio_0_tri_iobuf_11
       (.I(gpio_0_tri_o_11),
        .IO(gpio_0_tri_io[11]),
        .O(gpio_0_tri_i_11),
        .T(gpio_0_tri_t_11));
IOBUF gpio_0_tri_iobuf_12
       (.I(gpio_0_tri_o_12),
        .IO(gpio_0_tri_io[12]),
        .O(gpio_0_tri_i_12),
        .T(gpio_0_tri_t_12));
IOBUF gpio_0_tri_iobuf_13
       (.I(gpio_0_tri_o_13),
        .IO(gpio_0_tri_io[13]),
        .O(gpio_0_tri_i_13),
        .T(gpio_0_tri_t_13));
IOBUF gpio_0_tri_iobuf_14
       (.I(gpio_0_tri_o_14),
        .IO(gpio_0_tri_io[14]),
        .O(gpio_0_tri_i_14),
        .T(gpio_0_tri_t_14));
IOBUF gpio_0_tri_iobuf_15
       (.I(gpio_0_tri_o_15),
        .IO(gpio_0_tri_io[15]),
        .O(gpio_0_tri_i_15),
        .T(gpio_0_tri_t_15));
IOBUF gpio_0_tri_iobuf_16
       (.I(gpio_0_tri_o_16),
        .IO(gpio_0_tri_io[16]),
        .O(gpio_0_tri_i_16),
        .T(gpio_0_tri_t_16));
IOBUF gpio_0_tri_iobuf_17
       (.I(gpio_0_tri_o_17),
        .IO(gpio_0_tri_io[17]),
        .O(gpio_0_tri_i_17),
        .T(gpio_0_tri_t_17));
IOBUF gpio_0_tri_iobuf_18
       (.I(gpio_0_tri_o_18),
        .IO(gpio_0_tri_io[18]),
        .O(gpio_0_tri_i_18),
        .T(gpio_0_tri_t_18));
IOBUF gpio_0_tri_iobuf_19
       (.I(gpio_0_tri_o_19),
        .IO(gpio_0_tri_io[19]),
        .O(gpio_0_tri_i_19),
        .T(gpio_0_tri_t_19));
IOBUF gpio_0_tri_iobuf_2
       (.I(gpio_0_tri_o_2),
        .IO(gpio_0_tri_io[2]),
        .O(gpio_0_tri_i_2),
        .T(gpio_0_tri_t_2));
IOBUF gpio_0_tri_iobuf_20
       (.I(gpio_0_tri_o_20),
        .IO(gpio_0_tri_io[20]),
        .O(gpio_0_tri_i_20),
        .T(gpio_0_tri_t_20));
IOBUF gpio_0_tri_iobuf_21
       (.I(gpio_0_tri_o_21),
        .IO(gpio_0_tri_io[21]),
        .O(gpio_0_tri_i_21),
        .T(gpio_0_tri_t_21));
IOBUF gpio_0_tri_iobuf_22
       (.I(gpio_0_tri_o_22),
        .IO(gpio_0_tri_io[22]),
        .O(gpio_0_tri_i_22),
        .T(gpio_0_tri_t_22));
IOBUF gpio_0_tri_iobuf_23
       (.I(gpio_0_tri_o_23),
        .IO(gpio_0_tri_io[23]),
        .O(gpio_0_tri_i_23),
        .T(gpio_0_tri_t_23));
IOBUF gpio_0_tri_iobuf_24
       (.I(gpio_0_tri_o_24),
        .IO(gpio_0_tri_io[24]),
        .O(gpio_0_tri_i_24),
        .T(gpio_0_tri_t_24));
IOBUF gpio_0_tri_iobuf_25
       (.I(gpio_0_tri_o_25),
        .IO(gpio_0_tri_io[25]),
        .O(gpio_0_tri_i_25),
        .T(gpio_0_tri_t_25));
IOBUF gpio_0_tri_iobuf_26
       (.I(gpio_0_tri_o_26),
        .IO(gpio_0_tri_io[26]),
        .O(gpio_0_tri_i_26),
        .T(gpio_0_tri_t_26));
IOBUF gpio_0_tri_iobuf_27
       (.I(gpio_0_tri_o_27),
        .IO(gpio_0_tri_io[27]),
        .O(gpio_0_tri_i_27),
        .T(gpio_0_tri_t_27));
IOBUF gpio_0_tri_iobuf_28
       (.I(gpio_0_tri_o_28),
        .IO(gpio_0_tri_io[28]),
        .O(gpio_0_tri_i_28),
        .T(gpio_0_tri_t_28));
IOBUF gpio_0_tri_iobuf_29
       (.I(gpio_0_tri_o_29),
        .IO(gpio_0_tri_io[29]),
        .O(gpio_0_tri_i_29),
        .T(gpio_0_tri_t_29));
IOBUF gpio_0_tri_iobuf_3
       (.I(gpio_0_tri_o_3),
        .IO(gpio_0_tri_io[3]),
        .O(gpio_0_tri_i_3),
        .T(gpio_0_tri_t_3));
IOBUF gpio_0_tri_iobuf_30
       (.I(gpio_0_tri_o_30),
        .IO(gpio_0_tri_io[30]),
        .O(gpio_0_tri_i_30),
        .T(gpio_0_tri_t_30));
IOBUF gpio_0_tri_iobuf_31
       (.I(gpio_0_tri_o_31),
        .IO(gpio_0_tri_io[31]),
        .O(gpio_0_tri_i_31),
        .T(gpio_0_tri_t_31));
IOBUF gpio_0_tri_iobuf_32
       (.I(gpio_0_tri_o_32),
        .IO(gpio_0_tri_io[32]),
        .O(gpio_0_tri_i_32),
        .T(gpio_0_tri_t_32));
IOBUF gpio_0_tri_iobuf_33
       (.I(gpio_0_tri_o_33),
        .IO(gpio_0_tri_io[33]),
        .O(gpio_0_tri_i_33),
        .T(gpio_0_tri_t_33));
IOBUF gpio_0_tri_iobuf_34
       (.I(gpio_0_tri_o_34),
        .IO(gpio_0_tri_io[34]),
        .O(gpio_0_tri_i_34),
        .T(gpio_0_tri_t_34));
IOBUF gpio_0_tri_iobuf_35
       (.I(gpio_0_tri_o_35),
        .IO(gpio_0_tri_io[35]),
        .O(gpio_0_tri_i_35),
        .T(gpio_0_tri_t_35));
IOBUF gpio_0_tri_iobuf_36
       (.I(gpio_0_tri_o_36),
        .IO(gpio_0_tri_io[36]),
        .O(gpio_0_tri_i_36),
        .T(gpio_0_tri_t_36));
IOBUF gpio_0_tri_iobuf_37
       (.I(gpio_0_tri_o_37),
        .IO(gpio_0_tri_io[37]),
        .O(gpio_0_tri_i_37),
        .T(gpio_0_tri_t_37));
IOBUF gpio_0_tri_iobuf_38
       (.I(gpio_0_tri_o_38),
        .IO(gpio_0_tri_io[38]),
        .O(gpio_0_tri_i_38),
        .T(gpio_0_tri_t_38));
IOBUF gpio_0_tri_iobuf_39
       (.I(gpio_0_tri_o_39),
        .IO(gpio_0_tri_io[39]),
        .O(gpio_0_tri_i_39),
        .T(gpio_0_tri_t_39));
IOBUF gpio_0_tri_iobuf_4
       (.I(gpio_0_tri_o_4),
        .IO(gpio_0_tri_io[4]),
        .O(gpio_0_tri_i_4),
        .T(gpio_0_tri_t_4));
IOBUF gpio_0_tri_iobuf_40
       (.I(gpio_0_tri_o_40),
        .IO(gpio_0_tri_io[40]),
        .O(gpio_0_tri_i_40),
        .T(gpio_0_tri_t_40));
IOBUF gpio_0_tri_iobuf_41
       (.I(gpio_0_tri_o_41),
        .IO(gpio_0_tri_io[41]),
        .O(gpio_0_tri_i_41),
        .T(gpio_0_tri_t_41));
IOBUF gpio_0_tri_iobuf_42
       (.I(gpio_0_tri_o_42),
        .IO(gpio_0_tri_io[42]),
        .O(gpio_0_tri_i_42),
        .T(gpio_0_tri_t_42));
IOBUF gpio_0_tri_iobuf_43
       (.I(gpio_0_tri_o_43),
        .IO(gpio_0_tri_io[43]),
        .O(gpio_0_tri_i_43),
        .T(gpio_0_tri_t_43));
IOBUF gpio_0_tri_iobuf_44
       (.I(gpio_0_tri_o_44),
        .IO(gpio_0_tri_io[44]),
        .O(gpio_0_tri_i_44),
        .T(gpio_0_tri_t_44));
IOBUF gpio_0_tri_iobuf_45
       (.I(gpio_0_tri_o_45),
        .IO(gpio_0_tri_io[45]),
        .O(gpio_0_tri_i_45),
        .T(gpio_0_tri_t_45));
IOBUF gpio_0_tri_iobuf_46
       (.I(gpio_0_tri_o_46),
        .IO(gpio_0_tri_io[46]),
        .O(gpio_0_tri_i_46),
        .T(gpio_0_tri_t_46));
IOBUF gpio_0_tri_iobuf_47
       (.I(gpio_0_tri_o_47),
        .IO(gpio_0_tri_io[47]),
        .O(gpio_0_tri_i_47),
        .T(gpio_0_tri_t_47));
IOBUF gpio_0_tri_iobuf_48
       (.I(gpio_0_tri_o_48),
        .IO(gpio_0_tri_io[48]),
        .O(gpio_0_tri_i_48),
        .T(gpio_0_tri_t_48));
IOBUF gpio_0_tri_iobuf_49
       (.I(gpio_0_tri_o_49),
        .IO(gpio_0_tri_io[49]),
        .O(gpio_0_tri_i_49),
        .T(gpio_0_tri_t_49));
IOBUF gpio_0_tri_iobuf_5
       (.I(gpio_0_tri_o_5),
        .IO(gpio_0_tri_io[5]),
        .O(gpio_0_tri_i_5),
        .T(gpio_0_tri_t_5));
IOBUF gpio_0_tri_iobuf_50
       (.I(gpio_0_tri_o_50),
        .IO(gpio_0_tri_io[50]),
        .O(gpio_0_tri_i_50),
        .T(gpio_0_tri_t_50));
IOBUF gpio_0_tri_iobuf_51
       (.I(gpio_0_tri_o_51),
        .IO(gpio_0_tri_io[51]),
        .O(gpio_0_tri_i_51),
        .T(gpio_0_tri_t_51));
IOBUF gpio_0_tri_iobuf_52
       (.I(gpio_0_tri_o_52),
        .IO(gpio_0_tri_io[52]),
        .O(gpio_0_tri_i_52),
        .T(gpio_0_tri_t_52));
IOBUF gpio_0_tri_iobuf_53
       (.I(gpio_0_tri_o_53),
        .IO(gpio_0_tri_io[53]),
        .O(gpio_0_tri_i_53),
        .T(gpio_0_tri_t_53));
IOBUF gpio_0_tri_iobuf_54
       (.I(gpio_0_tri_o_54),
        .IO(gpio_0_tri_io[54]),
        .O(gpio_0_tri_i_54),
        .T(gpio_0_tri_t_54));
IOBUF gpio_0_tri_iobuf_55
       (.I(gpio_0_tri_o_55),
        .IO(gpio_0_tri_io[55]),
        .O(gpio_0_tri_i_55),
        .T(gpio_0_tri_t_55));
IOBUF gpio_0_tri_iobuf_56
       (.I(gpio_0_tri_o_56),
        .IO(gpio_0_tri_io[56]),
        .O(gpio_0_tri_i_56),
        .T(gpio_0_tri_t_56));
IOBUF gpio_0_tri_iobuf_57
       (.I(gpio_0_tri_o_57),
        .IO(gpio_0_tri_io[57]),
        .O(gpio_0_tri_i_57),
        .T(gpio_0_tri_t_57));
IOBUF gpio_0_tri_iobuf_58
       (.I(gpio_0_tri_o_58),
        .IO(gpio_0_tri_io[58]),
        .O(gpio_0_tri_i_58),
        .T(gpio_0_tri_t_58));
IOBUF gpio_0_tri_iobuf_59
       (.I(gpio_0_tri_o_59),
        .IO(gpio_0_tri_io[59]),
        .O(gpio_0_tri_i_59),
        .T(gpio_0_tri_t_59));
IOBUF gpio_0_tri_iobuf_6
       (.I(gpio_0_tri_o_6),
        .IO(gpio_0_tri_io[6]),
        .O(gpio_0_tri_i_6),
        .T(gpio_0_tri_t_6));
IOBUF gpio_0_tri_iobuf_60
       (.I(gpio_0_tri_o_60),
        .IO(gpio_0_tri_io[60]),
        .O(gpio_0_tri_i_60),
        .T(gpio_0_tri_t_60));
IOBUF gpio_0_tri_iobuf_61
       (.I(gpio_0_tri_o_61),
        .IO(gpio_0_tri_io[61]),
        .O(gpio_0_tri_i_61),
        .T(gpio_0_tri_t_61));
IOBUF gpio_0_tri_iobuf_62
       (.I(gpio_0_tri_o_62),
        .IO(gpio_0_tri_io[62]),
        .O(gpio_0_tri_i_62),
        .T(gpio_0_tri_t_62));
IOBUF gpio_0_tri_iobuf_63
       (.I(gpio_0_tri_o_63),
        .IO(gpio_0_tri_io[63]),
        .O(gpio_0_tri_i_63),
        .T(gpio_0_tri_t_63));
IOBUF gpio_0_tri_iobuf_7
       (.I(gpio_0_tri_o_7),
        .IO(gpio_0_tri_io[7]),
        .O(gpio_0_tri_i_7),
        .T(gpio_0_tri_t_7));
IOBUF gpio_0_tri_iobuf_8
       (.I(gpio_0_tri_o_8),
        .IO(gpio_0_tri_io[8]),
        .O(gpio_0_tri_i_8),
        .T(gpio_0_tri_t_8));
IOBUF gpio_0_tri_iobuf_9
       (.I(gpio_0_tri_o_9),
        .IO(gpio_0_tri_io[9]),
        .O(gpio_0_tri_i_9),
        .T(gpio_0_tri_t_9));
endmodule
