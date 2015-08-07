# RPi I2C interface
set_property IOSTANDARD LVCMOS25 [get_ports {GPIO_N[11]}]
set_property IOSTANDARD LVCMOS25 [get_ports {GPIO_P[11]}]

# MIPI Clock
create_clock -period 4.000 -name csi_clk [get_ports {GPIO_P[6]}]
set_input_jitter csi_clk 0.150
set_clock_groups -asynchronous -group {csi_clk}
