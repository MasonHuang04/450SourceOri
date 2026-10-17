Original input for the 725.587 Hz FFT demonstration
==================================================
这是 testbench case 8 (tone_bin83) 实际使用的、加 Kaiser 窗之前的输入。
不是实测 ADC 回波，也不是 190–210 kHz Chirp；它是验证 FFT 峰值位置的已知单频。

完整数据：91,667 点；Fs = 165 MHz / 144 = 1,145,833.333333 Hz。
频率：83 * Fs / 131072 = 725.587209065755 Hz；峰值幅度约 12000 数字码。
生成定义：x[n] = round(12000*cos(2*pi*f*n/Fs + 0.31))，signed 16-bit。
此次导出直接来自原测试输入，已逐点与 input_8.txt / input_8.hex / reference_8.npz 核对。
第一点 n=0；最后一点时间 (91667-1)/Fs = 79.999418181818 ms。

FFT_Input_725p587Hz.csv：sample_index（编号）, time_s（秒）, sample_signed16（原始码值）。
FFT_Input_725p587Hz.hex：逐行 16-bit 二进制补码十六进制，与原 testbench 文件逐字节一致。
FFT_Input_725p587Hz.png：只画前 6 ms，让正弦周期清楚；CSV/HEX 都包含完整约80ms。

对应输出：第83格，P_raw=410759604，P_norm=P_raw/64=6418118.8125 ADC-code²。
原始参考位置：verification/kaiser_fft_peak_20261015/vectors_full/input_8.hex。
