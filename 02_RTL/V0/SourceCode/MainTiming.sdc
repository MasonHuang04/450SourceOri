create_clock -name board_clk -period 10.0 [get_ports iMAIN_CLK]
derive_pll_clocks
create_generated_clock -name fft_clk -source [get_ports iMAIN_CLK] -divide_by 2 [get_pins {cFFTClk|q}]
create_generated_clock -name adc_clk -source [get_pins {uPLL|mainpll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -edges {5 11 17} [get_pins {uRx|uAD|adc_clock|q}]
create_generated_clock -name adc_pin -source [get_pins {uRx|uAD|adc_clock|q}] -divide_by 1 [get_ports oAD_CLK]
create_generated_clock -name adc_spi -source [get_pins {uRx|uAD|adc_clock|q}] -divide_by 1 [get_ports oAD_SCLK]
create_generated_clock -name dac_capture -source [get_pins {uPLL|mainpll_inst|altera_pll_i|general[0].gpll~PLL_OUTPUT_COUNTER|divclk}] -invert [get_ports oDA_CLK]
derive_clock_uncertainty
set_input_delay -clock adc_spi -max 23.25 [get_ports iAD_SDO]
set_input_delay -clock adc_spi -min 2.75 [get_ports iAD_SDO]
set_output_delay -clock adc_spi -clock_fall -max 4.25 [get_ports oAD_SDI]
set_output_delay -clock adc_spi -clock_fall -min -6.25 [get_ports oAD_SDI]
set_output_delay -clock adc_spi -clock_fall -max -7.93 [get_ports oAD_CS]
set_output_delay -clock adc_spi -clock_fall -min -10.25 [get_ports oAD_CS]
set_output_delay -clock adc_pin -max 9.25 [get_ports oAD_START]
set_output_delay -clock adc_pin -min -9.25 [get_ports oAD_START]
set_output_delay -clock dac_capture -max 1.25 [get_ports {oDA_D[*]}]
set_output_delay -clock dac_capture -min -1.75 [get_ports {oDA_D[*]}]
# First stages only; all later synchronizer stages stay timed.
set_false_path -to [get_registers {cLockSync[0] cFFTRstSync[0] uRx|uAD|adc_reset_sync[0] uRx|uAD|word_sync[0] uRx|uAD|adc|drdy_sync[0] uFFT|done_sync[0] uFFT|result_sync[0]}]
set_false_path -from [get_ports iUART_RXD] -to [get_registers {*vRx_L1*}]
# ADC word is held for a complete conversion interval; captured one extra sys
# clock after its toggle crosses two synchronizers.
set_false_path -from [get_registers {uRx|uAD|held_sample[*]}] -to [get_registers {uRx|uAD|oFftValue[*] uRx|uAD|oValue[*] uRx|uAD|oClipped}]
# Immutable frame statistics and FFT results are sampled after 2FF + one edge.
set_false_path -from [get_registers {uFFT|cap_count[*] uFFT|cap_span[*] uFFT|cap_seq[*] uFFT|cap_min[*] uFFT|cap_max[*] uFFT|cap_flags[*] uFFT|cap_sum[*]}] -to [get_registers {uFFT|report_count[*] uFFT|report_span[*] uFFT|report_seq[*] uFFT|report_min[*] uFFT|report_max[*] uFFT|report_flags[*] uFFT|report_sum[*]}]
set_false_path -from [get_registers {uFFT|report_count[*] uFFT|report_span[*] uFFT|report_seq[*] uFFT|report_min[*] uFFT|report_max[*] uFFT|report_flags[*] uFFT|report_bin[*] uFFT|report_power[*] uFFT|report_delta[*] uFFT|report_interp_status[*]}] -to [get_registers {uFFT|o_count[*] uFFT|o_span[*] uFFT|o_seq[*] uFFT|o_min[*] uFFT|o_max[*] uFFT|o_flags[*] uFFT|o_bin[*] uFFT|o_power[*] uFFT|o_delta_q16[*] uFFT|o_interp_status[*]}]
# Status, asynchronous UART/I2C and static analog controls have no synchronous
# external receiver requirement. ADC and DAC signal timing remains constrained.
set_false_path -to [get_ports {oLED_* oUART_* oTMP_SCL ioTMP_SDA oDA_PD oTX_MUX_* oRX_MUX_* oAD_RST}]
set_false_path -from [get_ports {iUART_RTS ioTMP_SDA}]

# M4 mailbox: args/held are immutable until the request/ack round trip ends.
# Only synchronizer first stages and the explicitly held payload crossings are exempt.
set_false_path -to [get_registers {uPeakReport|g_range.request_sync[0] uPeakReport|result_sync[0]}]
set_false_path -from [get_registers {uPeakReport|bin[*] uPeakReport|flags[*] uPeakReport|delta_q16[*] uPeakReport|interp_status[*] uPeakReport|fft_length[*] uPeakReport|temp_raw[*] uPeakReport|temp_status[*] uPeakReport|bw_bits[*] uPeakReport|time_bits[*] uPeakReport|waveform_ok}] -to [get_registers {uPeakReport|g_range.args_cap[*]}]
set_false_path -from [get_registers {uPeakReport|g_range.held[*]}] -to [get_registers {uPeakReport|frequency_millihz[*] uPeakReport|distance_um[*] uPeakReport|range_status[*]}]
