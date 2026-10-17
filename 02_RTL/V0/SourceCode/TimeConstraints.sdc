set_time_format -unit ns -decimal_places 3
derive_pll_clocks -create_base_clocks
create_clock -name CLKIN -period 10 [get_ports {iMAIN_CLK}]