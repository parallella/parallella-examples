//Copyright 1986-2014 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2014.3 (lin64) Build 1034051 Fri Oct  3 16:31:15 MDT 2014
//Date        : Sat Dec  6 13:00:58 2014
//Host        : FredsLaptop running 64-bit Ubuntu 14.04.1 LTS
//Command     : generate_target elink_testbench_wrapper.bd
//Design      : elink_testbench_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module elink_testbench_wrapper
   (aclk,
    aresetn,
    csysreq,
    done0,
    done1,
    done2,
    error0,
    error1,
    error2,
    param_coreid,
    reset,
    rx_cclk_n,
    rx_cclk_p,
    start);
  input aclk;
  input aresetn;
  input csysreq;
  output done0;
  output done1;
  output done2;
  output error0;
  output error1;
  output error2;
  input [11:0]param_coreid;
  input reset;
  output rx_cclk_n;
  output rx_cclk_p;
  input start;

  wire aclk;
  wire aresetn;
  wire csysreq;
  wire done0;
  wire done1;
  wire done2;
  wire error0;
  wire error1;
  wire error2;
  wire [11:0]param_coreid;
  wire reset;
  wire rx_cclk_n;
  wire rx_cclk_p;
  wire start;

elink_testbench elink_testbench_i
       (.aclk(aclk),
        .aresetn(aresetn),
        .csysreq(csysreq),
        .done0(done0),
        .done1(done1),
        .done2(done2),
        .error0(error0),
        .error1(error1),
        .error2(error2),
        .param_coreid(param_coreid),
        .reset(reset),
        .rx_cclk_n(rx_cclk_n),
        .rx_cclk_p(rx_cclk_p),
        .start(start));
endmodule
