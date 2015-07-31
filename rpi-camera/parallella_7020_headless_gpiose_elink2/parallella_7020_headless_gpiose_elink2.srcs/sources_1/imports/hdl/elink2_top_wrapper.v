//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.4 (lin64) Build 1071353 Tue Nov 18 16:47:07 MST 2014
//Date        : Tue Jun 23 22:18:35 2015
//Host        : lain running 64-bit Gentoo Base System release 2.2
//Command     : generate_target elink2_top_wrapper.bd
//Design      : elink2_top_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module elink2_top_wrapper (
  // DDR
  inout [14:0] DDR_addr,
  inout [ 2:0] DDR_ba,
  inout        DDR_cas_n,
  inout        DDR_ck_n,
  inout        DDR_ck_p,
  inout        DDR_cke,
  inout        DDR_cs_n,
  inout [ 3:0] DDR_dm,
  inout [31:0] DDR_dq,
  inout [ 3:0] DDR_dqs_n,
  inout [ 3:0] DDR_dqs_p,
  inout        DDR_odt,
  inout        DDR_ras_n,
  inout        DDR_reset_n,
  inout        DDR_we_n,

  // Fixed IO
  inout        FIXED_IO_ddr_vrn,
  inout        FIXED_IO_ddr_vrp,
  inout [53:0] FIXED_IO_mio,
  inout        FIXED_IO_ps_clk,
  inout        FIXED_IO_ps_porb,
  inout        FIXED_IO_ps_srstb,

  // I2C
  inout I2C_SCL,
  inout I2C_SDA,

  // Epiphany e-link
  output CCLK_N,
  output CCLK_P,
  output [0:0] DSP_RESET_N,

  input  [7:0] RX_data_n,
  input  [7:0] RX_data_p,
  input        RX_frame_n,
  input        RX_frame_p,
  input        RX_lclk_n,
  input        RX_lclk_p,
  output       RX_rd_wait_n,
  output       RX_rd_wait_p,
  output       RX_wr_wait_n,
  output       RX_wr_wait_p,

  output [7:0] TX_data_n,
  output [7:0] TX_data_p,
  output       TX_frame_n,
  output       TX_frame_p,
  output       TX_lclk_n,
  output       TX_lclk_p,
  input        TX_rd_wait_n,
  input        TX_rd_wait_p,
  input        TX_wr_wait_n,
  input        TX_wr_wait_p,

  // GPIO
  inout [23:0] GPIO_P,
  inout [23:0] GPIO_N
);

  // CSI AXI-lite config bus
  wire [31:0] CSI_AXI_araddr;
  wire  [2:0] CSI_AXI_arprot;
  wire        CSI_AXI_arready;
  wire        CSI_AXI_arvalid;
  wire [31:0] CSI_AXI_awaddr;
  wire  [2:0] CSI_AXI_awprot;
  wire        CSI_AXI_awready;
  wire        CSI_AXI_awvalid;
  wire        CSI_AXI_bready;
  wire  [1:0] CSI_AXI_bresp;
  wire        CSI_AXI_bvalid;
  wire [31:0] CSI_AXI_rdata;
  wire        CSI_AXI_rready;
  wire  [1:0] CSI_AXI_rresp;
  wire        CSI_AXI_rvalid;
  wire [31:0] CSI_AXI_wdata;
  wire        CSI_AXI_wready;
  wire  [3:0] CSI_AXI_wstrb;
  wire        CSI_AXI_wvalid;

  // CSI AXI-stream video interface
  wire [31:0] CSI_VIDEO_tdata;
  wire  [3:0] CSI_VIDEO_tkeep;
  wire        CSI_VIDEO_tlast;
  wire        CSI_VIDEO_tready;
  wire        CSI_VIDEO_tsof;
  wire        CSI_VIDEO_tvalid;

  // CSI interrupt line
  wire csi_intr;

  // CSI debug
  wire  [7:0] csi_debug;

  // Clocks from PS
  wire FCLK_CLK0;
  wire FCLK_CLK1;

  // Reset
  wire aresetn;
  wire rst;

  // GPIO IO buffer control
  wire [63:0] GPIO0_I;
  wire [63:0] GPIO0_O;
  wire [63:0] GPIO0_T;

	
  // Block design instance
  elink2_top elink2_top_i (
    .CAM_I2C_SCL(GPIO_N[11]),
    .CAM_I2C_SDA(GPIO_P[11]),
    .CCLK_N(CCLK_N),
    .CCLK_P(CCLK_P),
    .CSI_AXI_araddr(CSI_AXI_araddr),
    .CSI_AXI_arprot(CSI_AXI_arprot),
    .CSI_AXI_arready({CSI_AXI_arready}),
    .CSI_AXI_arvalid({CSI_AXI_arvalid}),
    .CSI_AXI_awaddr(CSI_AXI_awaddr),
    .CSI_AXI_awprot(CSI_AXI_awprot),
    .CSI_AXI_awready({CSI_AXI_awready}),
    .CSI_AXI_awvalid({CSI_AXI_awvalid}),
    .CSI_AXI_bready({CSI_AXI_bready}),
    .CSI_AXI_bresp(CSI_AXI_bresp),
    .CSI_AXI_bvalid({CSI_AXI_bvalid}),
    .CSI_AXI_rdata(CSI_AXI_rdata),
    .CSI_AXI_rready({CSI_AXI_rready}),
    .CSI_AXI_rresp(CSI_AXI_rresp),
    .CSI_AXI_rvalid({CSI_AXI_rvalid}),
    .CSI_AXI_wdata(CSI_AXI_wdata),
    .CSI_AXI_wready({CSI_AXI_wready}),
    .CSI_AXI_wstrb(CSI_AXI_wstrb),
    .CSI_AXI_wvalid({CSI_AXI_wvalid}),
    .CSI_VIDEO_tdata(CSI_VIDEO_tdata),
    .CSI_VIDEO_tkeep(CSI_VIDEO_tkeep),
    .CSI_VIDEO_tlast(CSI_VIDEO_tlast),
    .CSI_VIDEO_tready(CSI_VIDEO_tready),
    .CSI_VIDEO_tuser({CSI_VIDEO_tsof}),
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
    .GPIO_0_tri_i(GPIO0_I),
    .GPIO_0_tri_o(GPIO0_O),
    .GPIO_0_tri_t(GPIO0_T),
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
    .csi_intr(csi_intr)
  );

  // CSI
  mipi_csi_top #(
    .N_LANES(2),
    .PHY_INV_CLK(1'b0),
    .PHY_INV_DATA(1'b0)
  ) mipi_csi_top_I (
    .pad_data_p   ({GPIO_P[9], GPIO_P[8]}),
    .pad_data_n   ({GPIO_N[9], GPIO_N[8]}),
    .pad_clk_p    (GPIO_P[6]),
    .pad_clk_n    (GPIO_N[6]),
    .pad_lpdet_p  (GPIO_P[7]),
    .pad_lpdet_n  (GPIO_N[7]),
    .vaxi_data    (CSI_VIDEO_tdata),
    .vaxi_last    (CSI_VIDEO_tlast),
    .vaxi_sof     (CSI_VIDEO_tsof),
    .vaxi_valid   (CSI_VIDEO_tvalid),
    .vaxi_ready   (CSI_VIDEO_tready),
    .saxi_awvalid (CSI_AXI_awvalid),
    .saxi_awready (CSI_AXI_awready),
    .saxi_awaddr  (CSI_AXI_awaddr),
    .saxi_wvalid  (CSI_AXI_wvalid),
    .saxi_wready  (CSI_AXI_wready),
    .saxi_wdata   (CSI_AXI_wdata),
    .saxi_wstrb   (CSI_AXI_wstrb),
    .saxi_bvalid  (CSI_AXI_bvalid),
    .saxi_bready  (CSI_AXI_bready),
    .saxi_bresp   (CSI_AXI_bresp),
    .saxi_arvalid (CSI_AXI_arvalid),
    .saxi_arready (CSI_AXI_arready),
    .saxi_araddr  (CSI_AXI_araddr),
    .saxi_rvalid  (CSI_AXI_rvalid),
    .saxi_rready  (CSI_AXI_rready),
    .saxi_rdata   (CSI_AXI_rdata),
    .saxi_rresp   (CSI_AXI_rresp),
	.intr         (csi_intr),
    .debug        (csi_debug),
    .refclk       (FCLK_CLK1),
    .clk          (FCLK_CLK0),
    .rst          (rst)
  );

  assign CSI_VIDEO_tkeep = 4'b1111;

  assign rst = ~aresetn;

  // Generate IO buffers for GPIOs not used by CSI
  genvar i, j;

  generate
    for (i=0; i<24; i=i+1)
      if ((i < 6) || (i > 11) || (i == 10))
      begin : iobuf_se
        localparam j = ((i >> 1) << 2) | (i & 1);

        IOBUF #(
          .DRIVE(8),
          .IBUF_LOW_PWR("TRUE"),
          .IOSTANDARD("LVCMOS25"),
          .SLEW("SLOW")
        ) GPIOBUF_SE_N (
          .O(GPIO0_I[j]),
          .IO(GPIO_N[i]),
          .I(GPIO0_O[j]),
          .T(GPIO0_T[j])
        );

        IOBUF #(
          .DRIVE(8),
          .IBUF_LOW_PWR("TRUE"),
          .IOSTANDARD("LVCMOS25"),
          .SLEW("SLOW")
        ) GPIOBUF_SE_P (
          .O(GPIO0_I[j+2]),
          .IO(GPIO_P[i]),
          .I(GPIO0_O[j+2]),
          .T(GPIO0_T[j+2])
        );
      end
  endgenerate
  
  // Unused GPIOs
  assign GPIO0_I[19:12] = 8'h00;
  assign GPIO0_I[21] = 1'b0;
  assign GPIO0_I[23] = 1'b0;
  assign GPIO0_I[63:48] = 16'h0000;

endmodule
