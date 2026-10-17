create_clock -name board_clk -period 10.0 [get_ports iMAIN_CLK]
derive_pll_clocks
create_generated_clock -name fft_clk -source [get_ports iMAIN_CLK] -divide_by 2 [get_pins {fft_clock|q}]
# ADC divider rises on the third 165 MHz edge, falls three edges later.
create_generated_clock -name adc_clk -source [get_pins {pll|mainpll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -edges {5 11 17} [get_pins {adc_clock|q}]
create_generated_clock -name adc_pin -source [get_pins {adc_clock|q}] -divide_by 1 [get_ports oAD_CLK]
create_generated_clock -name adc_spi -source [get_pins {adc_clock|q}] -divide_by 1 [get_ports oAD_SCLK]
derive_clock_uncertainty
# ADS127L21 1.8 V timing, with 0.25 ns relative board-delay allowance.
set_input_delay -clock adc_spi -max 23.25 [get_ports iAD_SDO]
set_input_delay -clock adc_spi -min 2.75 [get_ports iAD_SDO]
set_output_delay -clock adc_spi -clock_fall -max 4.25 [get_ports oAD_SDI]
set_output_delay -clock adc_spi -clock_fall -min -6.25 [get_ports oAD_SDI]
# Use one falling-edge reference for both CS constraints. The first SCLK rise
# is half a period later: max = 10.25 - (36.36/2) = -7.93 ns.
# CS is asserted while SCLK is gated low, a full period before its first rise.
set_output_delay -clock adc_spi -clock_fall -max -7.93 [get_ports oAD_CS]
set_output_delay -clock adc_spi -clock_fall -min -10.25 [get_ports oAD_CS]
set_output_delay -clock adc_pin -max 9.25 [get_ports oAD_START]
set_output_delay -clock adc_pin -min -9.25 [get_ports oAD_START]
# CDC control: two-register synchronizers. Data RAM is dual-clock and the
# capture frame stays immutable until FFT and report transmission complete.
set_false_path -to [get_registers {adc_lock_sync[0] fft_lock_sync[0] engine|request_sync[0] engine|done_sync[0] engine|adc_ready_sync[0] adc|drdy_sync[0]}]
# Bundled statistics are sampled one additional 50 MHz edge after the done
# toggle crosses two synchronizers, and held until the next capture request.
set_false_path -from [get_registers {engine|cap_count[*] engine|cap_span[*] engine|cap_min[*] engine|cap_max[*] engine|cap_flags[*] engine|cap_sum[*]}] -to [get_registers {engine|report_count[*] engine|report_span[*] engine|report_min[*] engine|report_max[*] engine|report_flags[*] engine|report_sum[*]}]
# Status/static pins and asynchronous UART have no synchronous receiver clock.
# ADC RESET release-to-communication is checked as >=10000 ADC clocks in TB.
set_false_path -to [get_ports {oLED_* oUART_* oTMP_SCL ioTMP_SDA oDA_* oTX_MUX_* oRX_MUX_* oAD_RST}]
set_false_path -from [get_ports {iUART_RXD iUART_RTS ioTMP_SDA}]
