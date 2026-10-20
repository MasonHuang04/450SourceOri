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
    CommonPackages.vhd              公共类型、函数、组件声明
    ChirpModules.vhd                Chirp核与发射控制
    MainControl.vhd                 主控制、命令解析、接收/打包/温度控制
    RxAcquisition.sv                ADC接口、CIC与采集缓存
    FftPipeline.sv                  Kaiser窗、FFT、功率谱与峰值
    UartBuffers.sv                  原始帧缓存、UART结果报告
    ChirpSettings.vhd                从Chirp/settings.json生成
    FftSettings.svh                  从FFT/settings.json生成
    MainSettings.vhd                 从FFT/main_settings.json生成
    *.sdc                           三个版本各自的时序约束
    ROM/                            MEM/MIF窗函数与旋转系数
    DSP/ MainPLL/                    当前使用的Intel IP目录
  Simulation/
    source_units.py                 从分组源码选取测试需要的逻辑单元
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

## Main 集成验证（当前默认20 ms Chirp短窗）

Main当前RX延迟1 ms后采集19 ms，672有效点补零到1024 FFT；两个独立实验不变。25 Hz不足半周期，低频精度不能沿用旧长窗结论。

在FFT目录运行：`python run_main.py`验证Intel内存模型，`--fast-memory`用等延迟行为内存验证全部有效数据/FFT/插值；`--interp`在既有tb_fft_plot.sv分支测试插值数值。`--system`检查完整19ms等效数据量与M3回传（压缩空闲拍），`--short`检查短ADC SPI，`--io`检查81字节真实UART，`--tx`核对Intel IP的19ms RX计数及原TX配置。系统/IO/TX分支的预期固定为本默认配置；自定义参数需同步调整。

配置入口为FFT/main_settings.json；`python configure_main.py`生成MainSettings、ROM与C#默认配置块。FFT点数和有效点数分别设置，必须配套重编译Main与03_SW。四个手写testbench和同一个QPF继续使用。

详情见[Main说明](../README_main_2026-10-17.md)和[短窗报告](../../../verification/FFT/Short20ms_20261020/report.html)。

## SourceCode 整理（2026-10-17）

已移除未被三个Revision或测试台引用的旧RxController/ADCController/TxPack/TMP117Controller、旧WaveFIFO、早期KaiserFFT包装入口及.bak；也移除了未使用的AlDec/Cadence/Synopsys启动模板和图形符号.bsf。

保留有效HDL、Intel IP源码、Questa源模型/启动脚本、QIP/SIP/SPD/F/CMP等IP描述、SDC时序约束及HEX/MIF/MEM系数。它们是源码配套输入，不是可随意删除的编译产物。共享FFT核心默认参数仍引用的通用系数也保留。

上述清理阶段未改变有效RTL、三个QSF和现有SOF的内容；后续文件合并见下一节。回退备份位于verification/Archive/sourcecode_before_cleanup_20261017.zip，逐文件清单位于sourcecode_cleanup_20261017.json。

## 按功能合并源文件（2026-10-17）

25份手写模块文件合并为6份，12份系数文件移入ROM。SourceCode根目录由46个文件减少为15个文件；子目录里的Intel IP保持厂商结构。三个顶层、三个参数文件和三个SDC分别保留，仍从同一个QPF选择Revision。

| 编辑的文件 | 内含的逻辑单元 |
|---|---|
| [CommonPackages.vhd](../SourceCode/CommonPackages.vhd) | `SysLib`、`DSPLib` |
| [ChirpModules.vhd](../SourceCode/ChirpModules.vhd) | `ChirpWaveGen`、`TxController`、`MainTxController`、`ScopeBurstControl` |
| [MainControl.vhd](../SourceCode/MainControl.vhd) | `UARTController`、`RxDepack`、`MainRxController`、`MainTxPack`、`MainTMP117Controller` |
| [RxAcquisition.sv](../SourceCode/RxAcquisition.sv) | `ScopeAdc27m5`、`MainAdcBridge`、`ScopeCic128`、`MainCicDecimator`、`ScopeFrameRam`、`MainFrameRam` |
| [FftPipeline.sv](../SourceCode/FftPipeline.sv) | `fft_tdp_store`、`kaiser4_rfft`、`fft_power_peak`、`MainFftProcessor`、`ScopeRxFft` |
| [UartBuffers.sv](../SourceCode/UartBuffers.sv) | `MainWaveFifo`、`ScopeUartReport`、`MainPeakReport`（含`MainWaveBank`） |

只移动代码的位置：模块名、端口、模块体、默认参数和时序约束均保留。修改功能时直接编辑表中对应文件，在文件内搜索模块名即可。`BEGIN_SOURCE` / `END_SOURCE`注释用于仿真脚本定位单元，编辑时保留它们。

Quartus直接编译六个分组文件。仿真脚本通过`source_units.py`抽取测试需要的单元到`results/.../units`，以便某些测试替换ADC/TX等模型而不重复定义模块；这些自动抽取的文件是可删除缓存，不是第二份需要维护的源码。原有run.py和run_main.py命令不变。

合并前备份和逐文件记录位于`verification/Archive/source_bundle_before_20261017.zip`与`source_bundle_20261017.json`。本轮完成三个Revision的Quartus Analysis & Elaboration，以及Chirp、FFT、短UART回归；没有重新布局布线或生成SOF，现有已验证的SOF保持原样。仅整理文件不要求重新烧录。

## Main FPGA峰值插值（2026-10-20）

新增逻辑单元`main_peak_interpolator`放在既有`SourceCode/FftPipeline.sv`中，根目录文件数不增加。Main现在按“FFT → 最大功率频点 → 三点对数插值”工作，当前M3回传FPGA计算的Q16偏移与FFT长度；两个独立实验保持原样。

`python run_main.py --interp`运行现有tb_fft_plot.sv的插值分支；其频率扫描由NumPy生成频谱，实际插值由RTL完成。`--fast-memory`验证完整Main数字处理分支，`--system`验证全数量原始数据与M2回传，`--short`/`--io`检查短ADC和逐位UART。峰值索引、功率、插值偏移均与独立参考比对。

上板需新Main SOF与支持M3的新版03_SW配套。[详细说明](../README_main_2026-10-17.md)和[验证报告](../../../verification/FFT/Interpolation_20261020/report.html)。
