# Main：20 ms Chirp短窗FFT，25–2000 Hz搜峰（2026-10-21）

当前Main采用用户选择的短窗方案：默认TX仍为38–42 kHz、20 ms、幅度0.25；RX延迟1 ms后采集19 ms。ADC速率、CIC /32、Kaiser4和FPGA峰值插值保持原样。两个独立Chirp/FFT实验不变。

**这是速度与低频精度的取舍。峰值插值不能补回短窗缺失的信息。25 Hz在有效窗口中不足半个周期，不能可靠测频；不要沿用旧约229 ms窗口的精度结论。**

## 当前配置

| 参数 | 原长窗Main | 当前短窗Main |
|---|---:|---:|
| 主时钟 / FFT时钟 | 165 / 50 MHz | 不变 |
| TX | 38–42 kHz、20 ms、0.25 | 不变 |
| RX延迟 | 1 ms | 1 ms |
| RX窗口 | 250 ms | 19 ms |
| 原始ADC / FFT输入率 | 1.145833 MS/s / 35.807292 kS/s | 不变 |
| FFT有效点 | 8192 | 672 |
| 有效数据时长 | 228.780 ms | 18.767 ms |
| FFT长度 | 8192 | 1024（补352个零） |
| 频率格间隔 | 4.371007 Hz | 34.968058 Hz |
| 每帧原始波形回传 | 约71614点 | 约5442点 |
| 峰值搜索 | 25–500 Hz | 25–2000 Hz，第1–57格；低频精度仍受限 |

Main的采集控制、FFT缓存和ROM都已按新尺寸匹配，并非只把上位机显示的时间改短。672点给19 ms接收窗口留出少量转换/流水线余量；真实有效回波仍取决于传播延迟、混频和滤波建立时间，本版尚未做声路有效区间自适应选择。

## 数据流与插值

`RX_IN → ADC → CIC /32 → 672点缓存/去直流 → Kaiser4 → 补零到1024 → FFT → 功率谱/最大频点 → 三点对数插值 → UART`

在最大频点k两侧读取功率，令L=log2(P)：

`delta=0.5*(L[k-1]-L[k+1])/(L[k-1]-2*L[k]+L[k+1])`，限幅±0.5；`f=(k+delta)*Fs_FFT/NFFT`。

log功率与log幅度只相差常数倍，该比值与Simulation的对数幅度抛物线公式等价。对数与除法均在FPGA内完成；上位机只换算Hz。FFT后插值不减少这次FFT运算，真正的提速来自采样窗口及FFT长度缩小。

输入削顶、短/空帧、错误节拍、无强峰、FFT溢出等仍会标错。插值缺邻点、零功率、非局部峰或平坦曲率时退回原频点。短窗中即使数据/算法状态正常，频率估计也可能有较大偏差；上位机对估计不足3周期的结果显示橙色“短窗低频，仅供参考”。这只是提示，不是保证其他频点一定准确。

## 上板

1. Programmer重新选择本目录`output_files/UsMimoTestBench.sof`，下载至100% Successful；不是独立实验的SOF。
2. 运行工程根目录`03_SW/RunMain.cmd`，选择主板COM口。新固件与新上位机配套使用。
3. 先用发生器连续100 Hz正弦接主板P5 RX_IN，共地，沿用已验证的小幅输入；点击“应用并采集一次”。主板P4 TX_OUT可同时接示波器观察20 ms Chirp。
4. 应收到约5442个原始点，以及672有效点/1024 FFT的峰值和插值结果。逐次改变输入频率无需重新编译；参考频率只用于算误差。
5. 25 Hz不再作为可靠测频验收点。当前只测最强频率，不提供多峰/距离结果，也没有新增FPGA混频器。

单次UART数据约11029字节，2 Mbaud/8N1理论线路时间约55.15 ms；连同19 ms采集约为75 ms量级（不含电脑/操作系统额外延迟）。上位机连续模式仍在完整结果后等待约1秒，不等于持续每75 ms自动发一帧。

## 参数与代码

只打开`UsMimoTestBench.qpf`，在Project → Revisions选择`UsMimoTestBench`。默认设置位于`Simulation/FFT/main_settings.json`，运行`python configure_main.py`会生成MainSettings、ROM，并更新现有MainProtocol.cs中的软件RX/FFT/搜索范围默认配置块，以及MainFftMonitor中的搜索范围常量。GUI范围检查、说明文字和参考频率输入读取生成常量。以后调整搜峰上限只改JSON里的search_max_hz，然后运行生成器、重新编译Main与03_SW并下载SOF。串口不能运行时修改此上限。

- `SourceCode/FftPipeline.sv`：MainFftProcessor现在可配置LOGN/有效点数，复用原FFT和插值核。
- `SourceCode/RxAcquisition.sv`：MainFrameRam地址与深度匹配FFT长度。
- `SourceCode/UartBuffers.sv`：MainPeakReport改发M3，带实际FFT长度。
- `SourceCode/UsMimoTestBench.vhd`：连接新参数与报文字段，TX默认值不变。
- `03_SW/UsMimoTestBench/MainProtocol.cs`：按报文FFT长度换算频率，支持M1/M2/M3解析；短窗RX设置与原始帧长度验证。

默认只把RX改成19 ms；修改GUI里的TX时长不会自动改变这个RX窗口。自定义FFT/窗口后应更新对应系统测试的固定预期；当前系统/IO/TX测试覆盖本页默认配置。

## M3协议

`M3,seq8,count8,bin4,power11,min4,max4,flags2,span8,delta8,istatus2,nfft4,checksum2\r\n`

共81字节。字段为定宽十六进制，delta为32位二补码Q16频点偏移；checksum是前77字节异或。count是实际有效点，nfft是变换长度，二者不同。插值状态0有效、1错误帧、2缺邻点/峰不匹配、3零功率、4非局部峰、5平坦曲率。功率仍为原最大频点功率，`power/64`的单位是归一化ADC code²。

M1/M2解析保留用于历史数据，但旧固件没有本次短窗FFT配置，不能只升级软件后就用于短窗测试。旧查看器不能解析新M3。

## 本次搜索范围更新

2026-10-21仅把Main搜索上限从500 Hz改为2000 Hz；下限25 Hz、TX/RX、采样、窗、FFT长度、插值和时钟都不变。10–75 cm、每2.5 cm一个点，共27点的理想单回波RTL扫描，最大绝对距离误差0.467 mm，RMSE 0.226 mm。未新增实板精度测试。

[25–2000 Hz更新报告和英文误差图](../../verification/FFT/Search2k_20261021/report.html)。回退包：verification/Archive/before_search2k_20261021.zip。

## 验证与回退

在Simulation/FFT运行`python run_main.py`（Intel内存）或`--fast-memory`，验证完整CIC/去直流/加窗/补零/FFT/功率/插值，与独立定点参考逐点对比；`--interp`测试插值数值与频率扫描。`--system`保留19 ms等效全部输入点但压缩空闲节拍，`--short`检查短ADC SPI，`--io`检查真实2Mbaud逐位串口，`--tx`检查实际Intel IP的19 ms计数和TX默认值。

[本次短窗报告](../../verification/FFT/Short20ms_20261020/report.html)包含所有低频偏差，没有把实现正确当作低频精度保证。2026-10-20用户随后反馈当前运行正常；未新增定量精度实测数据，见[本次保存说明](../../readme_2026-10-20.md)。

旧长窗版：[插值报告](../../verification/FFT/Interpolation_20261020/report.html)。修改前文件与SOF备份在`verification/Archive/before_short20ms_20261020.zip`。恢复时应同时恢复Main固件、参数/ROM与配套软件。

## 温度补偿距离（2026-10-21）

Main 在原有 FFT/插值后增加温度有效性判断、声速和距离运算，随 M4 报文回传。TMP117 温度以 Q7、有符号形式，频率以 milliHz、距离以微米发送。M4 共 110 字节，新上位机兼容旧 M1–M3。保留当前 25–2000 Hz 搜峰和其他采样参数。

温度无应答、过期、越界，或 FFT/插值/Chirp 参数无效时，不提供有效距离；0 带宽单频模式不能测距。使用本次锁存的 B/T，R=(331.3+0.606θ)·f_b·T/(2B)，未标定系统零点或双探头几何。

完整 RTL/I²C/UART/上位机验证和 84 项时序检查见 [温度补偿报告](../../verification/FFT/TemperatureRange_20261021/report.html)。实际温度传感器与声学精度仍需上板验证。
