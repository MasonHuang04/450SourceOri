# 一个工程：main 与两个独立实验

| 项目 | Chirp | FFT |
|---|---|---|
| 改参数 | [Chirp/settings.json](Chirp/settings.json) | [FFT/settings.json](FFT/settings.json) |
| 仿真和画图 | [Chirp/run.py](Chirp/run.py) | [FFT/run.py](FFT/run.py) |
| Questa 入口 | [Chirp/simulate.do](Chirp/simulate.do) | [FFT/simulate.do](FFT/simulate.do) |
| 唯一上板工程 | [UsMimoTestBench.qpf](../UsMimoTestBench.qpf) | [同一个 UsMimoTestBench.qpf](../UsMimoTestBench.qpf) |
| 选择 Revision | `ChirpTxScope40k20ms` | `RxFftLowFreq50to100Hz` |
| 可综合顶层 | [ChirpTxScope40k20ms.vhd](../SourceCode/ChirpTxScope40k20ms.vhd) | [RxFftLowFreq50to100Hz.sv](../SourceCode/RxFftLowFreq50to100Hz.sv) |

`UsMimoTestBench.vhd` 是原可综合主顶层，名字里虽然有 TestBench，但不是这里的仿真 testbench。main现已接入25–500Hz峰值检测；两个独立实验仍使用各自顶层。详见 [main说明](../README_main_2026-10-17.md)。

## 只开一个 .qpf 怎样生成两种 .sof

1. 关闭以前打开的独立实验工程，打开 [UsMimoTestBench.qpf](../UsMimoTestBench.qpf)。
2. 选择 **Project → Revisions**，选中需要的版本，点击 **Set Current**，再关闭对话框。
3. 点 **Processing → Start Compilation**。两种实验使用各自的顶层、约束和输出目录，生成不同名称的 `.sof`。
4. 在 Programmer 中选择该版本对应的 `.sof` 下载。切换 Revision 后不要继续选择上一次实验的下载文件。

| Revision | 用途 | 生成的下载文件 |
|---|---|---|
| `ChirpTxScope40k20ms`（默认） | 主板TX接示波器，38–42kHz / 20ms | [output_chirp_scope_40k20ms/ChirpTxScope40k20ms.sof](../output_chirp_scope_40k20ms/ChirpTxScope40k20ms.sof) |
| `RxFftLowFreq50to100Hz` | 外部50–100Hz输入，RX / FFT / 峰值 | [output_rx_fft_lowfreq/RxFftLowFreq50to100Hz.sof](../output_rx_fft_lowfreq/RxFftLowFreq50to100Hz.sof) |
| `UsMimoTestBench` | main：TX + RX + 25–500Hz FFT/峰值 | `output_files/UsMimoTestBench.sof` |

这里切换的是 **Revision（可综合设计配置）**；`Simulation/Chirp` 和 `Simulation/FFT` 仍是仿真/画图目录。仿真testbench不作为烧录顶层。一个 `.qpf` 管理多个 `.qsf` 是Quartus原生支持的方式，`.qsf`需要保留，不能为了只剩一个文件把它们删掉。[官方说明](https://docs.altera.com/r/docs/683475/19.4/quartus-prime-standard-edition-user-guide-getting-started/optimize-settings-with-project-revisions?contentId=JjKtzmhVXufy~kLhFihUag)

参数修改方式保持不变：编辑对应 `settings.json` 后，先运行该目录 `python run.py --settings-only` 或完整仿真，再编译对应Revision。

## 文件怎么分

```text
02_RTL/V0/
  UsMimoTestBench.qpf                唯一工程入口，包含下面三个Revision
  ChirpTxScope40k20ms.qsf             实验1：Chirp Revision
  RxFftLowFreq50to100Hz.qsf           实验2：FFT Revision
  UsMimoTestBench.qsf                原系统Revision，保留
  SourceCode/
    UsMimoTestBench.vhd              原顶层
    ChirpTxScope40k20ms.vhd          实验1顶层，与原顶层平级
    RxFftLowFreq50to100Hz.sv          实验2顶层，与原顶层平级
    Scope*.sv / ScopeBurstControl.vhd
    kaiser4_*.sv / fft_*.sv           共用功能模块，各保留一份
    ChirpSettings.vhd                从Chirp/settings.json生成
    FftSettings.svh                  从FFT/settings.json生成
    *.sdc / *.mem / *.mif            约束与系数
    DSP/ MainPLL/ WaveFIFO/          原Intel IP目录，保持依赖结构
  Simulation/
    Chirp/                          参数、2个小testbench、运行/画图入口
    FFT/                            参数、2个testbench、运行/画图/参考脚本
  Tools/RxFftLowFreqMonitor/         当前实板FFT查看器
```

这里只保留四个手写测试台：

1. `Chirp/tb_chirp_plot.vhd`：真实 Intel Chirp 数值核的采样索引检查，输出波形数据。
2. `Chirp/tb_chirp_board_control.vhd`：自动触发、忙状态抑制、失锁重启的控制检查；加速了启动与重复计数，不是整块主板模拟电路仿真。
3. `FFT/tb_fft_plot.sv`：CIC、缓存、FFT、功率/峰值和UART回归，生成画图数据；省去原始转换之间的空闲拍，输入样本一个不少。
4. `FFT/tb_fft_board.sv`：完整主板数字顶层与 ADC SPI 引脚模型，保留真实时钟节拍，约229ms窗口；运行较慢，按需使用。

## 修改和运行

在相应的 `Chirp` 或 `FFT` 目录打开 PowerShell，运行：

```powershell
python run.py
```

脚本会读取本目录 `settings.json`、同步相应的共享参数、仿真、核对参考值并画图。需要 Python、NumPy、Matplotlib 和 Questa；脚本中的 Questa 路径按本机安装配置，换电脑时修改 `vsim` 路径。Questa 免费许可证一次只运行一个会话；不要同时运行两个实验。

Chirp 默认：38–42kHz、20ms、25%数字幅度、每200ms发射。修改 `start_hz/end_hz/duration_ms/amplitude/repeat_ms` 后重新运行，生成的 `SourceCode/ChirpSettings.vhd` 同时供测试台和板级顶层使用。

FFT 默认：50–100Hz范围，CIC /128、2048点。`input_hz` 是画图用主测试输入，也是可选主板接口仿真的模拟发生器输入；`additional_test_frequencies_hz` 是另外八个回归输入。`search_min_hz/search_max_hz` 同步到板级峰值搜索配置，当前限定在50–100Hz预设内。FFT长度、抽取倍率和ROM是一组匹配的低频设计，不是任意改一个数字就能扩展到40kHz/200kHz。

`input_hz` 不会让实板自动产生该输入，也不会把测量结果改成该值；实际输入频率由外部信号发生器决定。实板查看器仍需输入发生器目标频率来比较误差。

只同步烧录参数、暂不仿真：

```powershell
python run.py --settings-only
```

FFT 完整 ADC 引脚级仿真（在 FFT 目录）：

```powershell
python run.py --board
```

如果使用 Questa 图形界面，在 Transcript 中执行 `do {本目录simulate.do的完整路径}`。`.do` 是实际的仿真脚本格式；不用新建没有工具支持的 `.sim` 文件。

## 结果和烧录

- Chirp 图：`Chirp/results/chirp.png`；数据：`Chirp/results/chirp_samples.csv`。
- FFT 图：`FFT/results/fft.png`；数据和检查：`FFT/results/run/`。
- `results/run/work` 等是工具自动生成的仿真库，不是额外的源代码或实验入口。
- 改参数后，先同步/仿真，打开唯一的 `UsMimoTestBench.qpf`，选择对应 Revision，再 Start Compilation，检查时序通过后才使用新 `.sof`。
- 实验1 `.sof` 在 `../output_chirp_scope_40k20ms/`；实验2在 `../output_rx_fft_lowfreq/`。
- `.qpf` 打开工程，`.sof` 下载到FPGA；不是 `.soc`。两个顶层在同一工程中通过 Revision 切换，不要把测试台作为综合顶层，也不要一次把整个SourceCode目录所有文件加入原工程。

硬件连线和实测记录见工程根目录 `readme_2026-10-16.md`。历史报告/数据仍在 `verification`；移除的旧入口及重复源码在 `verification/Archive/history_20261017.zip`（内含此前的源码归档），不再作为当前执行入口。

## Main 集成验证（不改变独立实验参数）

在FFT目录运行 `python run_main.py` 检查完整8192点CIC/FFT/功率/峰值。
`python run_main.py --short` 检查main短ADC SPI窗口和空/短FFT状态；
`python run_main.py --system` 检查完整250ms等效输入数据量、原始缓存/打包和FFT回传（压缩等待节拍）；
`python run_main.py --io` 检查真实2Mbaud UART逐位传输和ADC桥缓存限长。
三个模式是同一个 `tb_fft_board.sv` 的条件编译分支；不需要新建更多testbench文件。
这组回归使用固定的默认配置。改参数后应相应调整测试输入、预期搜索区间和窗长断言，不能用旧结果代替新验证。

main的默认配置入口为 `FFT/main_settings.json`，运行 `python configure_main.py` 后重新编译main。
独立FFT继续使用 `FFT/settings.json` 与 `run.py`，不受main设置影响。

`python run_main.py --tx` 用真实Intel浮点IP检查main时长参数、扫频起点/斜率及DAC启动；这是短启动测试，不重复完整80ms波形仿真。仍在现有tb_fft_board.sv内选择模式。

Main快速回归可用 `python run_main.py --fast-memory`（完整数据、行为内存，结果逐点比较）；主系统长帧保留Intel FFT内存模型，波形帧缓存使用等延迟模型。短ADC测试核对Intel波形内存接口。
