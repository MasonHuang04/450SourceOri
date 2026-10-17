create_clock -name board_clk -period 10.0 [get_ports iMAIN_CLK]
derive_pll_clocks
# This is the forwarded (inverted) system clock at the DAC CLK package pin.
create_generated_clock -name dac_capture -source [get_pins {pll|mainpll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -invert [get_ports oDA_CLK]
derive_clock_uncertainty
# DAC904 datasheet: setup 1.0 ns, hold 1.5 ns. Add 0.25 ns differential PCB skew
# allowance each way. This does not claim measured board trace delays.
set_output_delay -clock dac_capture -max 1.25 [get_ports {oDA_D[*]}]
set_output_delay -clock dac_capture -min -1.75 [get_ports {oDA_D[*]}]
# Static controls / LEDs have no synchronous external capture requirement.
set_false_path -to [get_ports {oLED_* oAD_* oTX_MUX_* oRX_MUX_* oUART_* oTMP_SCL ioTMP_SDA oDA_PD}]
# These input interfaces are not consumed by this TX-only test.
set_false_path -from [get_ports {iUART_RXD iUART_RTS iAD_SDO iAD_DRDY ioTMP_SDA}]
# PLL lock is asynchronous to the system clock; only the first synchronizer
# register is excepted. The second stage and all control logic remain timed.
set_false_path -to [get_registers {sequence_control|lock_sync[0]}]
