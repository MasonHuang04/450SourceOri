# Main：25–500 Hz 输入、8192 点 FFT 与峰值

本版用于先把**外部连续正弦信号**送入主板 RX，模拟前端混频后的低频信号。原始 ADC 仍约 1.145833 MS/s；新增的 main FFT 分支有效采样率约 35.807292 kS/s，8192 点，观察约 228.78 ms。主板系统时钟仍为 165 MHz。

## 为什么增加点数不一定增加测频精度

FFT 频率格间隔为 `Δf = Fs / N`。未补零时，记录时长 `T = N / Fs`，所以 `Δf = 1 / T`。

| 配置 | FFT有效采样率 | 有效点数 | 观察时间 | 频率格间隔 |
|---|---:|---:|---:|---:|
| 独立 FFT 实验（保持原样） | 8.951823 kS/s | 2048 | 228.78 ms | 4.371007 Hz |
| 新 main | 35.807292 kS/s | 8192 | 228.78 ms | 4.371007 Hz |

新 main 每周期有更多点，例如 500 Hz 每周期约 71.6 点。因为采样率和点数都增加 4 倍，频率格没有变细。若希望约 1 Hz 的格间隔，需要约 1 秒的**有效信号**。补零只加密频谱显示；峰值插值能改善单音估计，但不能保证任意噪声、多目标条件下的误差。本版输出离散最大功率频点，未增加峰值插值。

## 数据路径与默认值

```text
外部连续正弦波 -> 主板 P5 RX_IN -> 模拟滤波/ADC
  -> 27.5 MHz ADC接口 -> 约1.145833 MS/s原始16位数据
     ├─ 原始波形 /4 -> 131072字缓存 -> 原协议二进制波形包
     └─ 三级CIC低通 /32 -> 8192点缓存 -> 去直流
        -> Kaiser(beta=4) -> FFT -> Re²+Im² -> 25–500 Hz范围最大值
  -> 原始波形包完整结束 -> M1峰值记录 -> 同一个2 Mbaud UART
```

- main RX 默认 250 ms，延迟 1 ms；FFT使用接收窗开始处的8192个有效滤波输出，覆盖约229ms；剩余时间仍采样并回传原始数据。原始波形下采样参数 3 表示每4点保留1点，约71614点/帧。FFT分支使用原始全速数据，再低通抽取，独立于这个原始回传参数。
- main TX 默认改为与实验1相同的 **38–42 kHz / 20 ms**：中心40 kHz、带宽4 kHz、幅度系数0.25、正弦、14位DAC、不降采样、TX滤波旁路及1倍通路。main仍由串口触发，不采用实验1的200ms自动重复周期；RX 250ms和FFT设置不变。**单独 FFT 实验仍是50–100 Hz。**
- 低频支路假定输入是混频后信号；本版未在 FPGA 新增 TX×RX 混频器。
- 主板原有模拟 RX 低通保持使能。数字 CIC 是抗混叠抽取滤波，不能替代所有模拟抗混叠需求，也不能保证任意强带外干扰都被消除。
- 250 ms 接收窗不改变 TX 的 `B/T_TX`。实际超声混频信号只在 TX/RX 有效重叠期间有用；不能把20 ms信号后面的空白当成额外测频信息。实声实验需按有效重叠重新设置窗口、有效点数和必要的补零。

## 打开、编译、上板

1. 打开本目录唯一的 `UsMimoTestBench.qpf`。
2. `Project → Revisions`，选择 **UsMimoTestBench**，`Set Current`。
3. `Processing → Start Compilation`。检查编译和时序报告；main输出为 `output_files/UsMimoTestBench.sof`。
4. 用 Programmer 下载这个 `.sof`，确认100% Successful。不要选独立FFT或Chirp的文件。
5. 主板USB-C供电/串口连电脑，S1打开。发生器输出接主板 **P5 RX_IN**，外壳接地；先用100 Hz、小幅正弦输入，沿用已验证的输入量程，避免ADC削顶。主板TX不需要接RX。
6. 关闭原上位机，打开 `Tools/MainFftMonitor/MainFftMonitor.exe`，输入主板COM号和发生器频率。
7. 查看器发送原协议触发，先收波形，再显示FFT峰值；按回车再次测量。目标频率仅用于计算误差，不修改FPGA测量结果。原始数据和峰值日志保存在查看器旁的 `Main_日期时间` 文件夹。

2026-10-17更新：`03_SW/RunMain.cmd` 现可打开图形上位机，调整Chirp参数、显示RX波形和M1峰值；它固定保留本main的RX设置。见[新版上位机说明](../../03_SW/README_main_2026-10-17.md)。MainFftMonitor仍可作为仅触发的简易工具使用；不要让两个程序同时占用COM口。

## 修改 main 参数

Chirp默认值位于 `SourceCode/UsMimoTestBench.vhd` 的 `cTx_Fc/cTx_BW/cTx_Tc/cTx_A/cTx_MuxSel` 初始值。串口设置包仍可覆盖这些默认值；MainFftMonitor只发送触发命令。

编辑 `Simulation/FFT/main_settings.json`，然后在该目录运行：

```powershell
python configure_main.py
```

脚本生成 `SourceCode/MainSettings.vhd` 与 main 专用窗/旋转系数文件。然后重新编译 **UsMimoTestBench**。这些设置不会修改两个独立实验。

可改：RX时长、原始波形抽取、峰值搜索区间、有效窗点数。ADC速率、main CIC /32 和8192 FFT长度是当前配套实现，不能只改一个数字。减小有效点数时会补零到8192，实际分辨能力仍由有效时长决定。

## 代码变化

| 文件 | 用途 |
|---|---|
| `SourceCode/UsMimoTestBench.vhd` | main顶层接入FFT分支、等待结果、波形包后发送M1；增加PLL锁定/输出时序处理 |
| `MainTxController.vhd` | main专用TX控制封装：保持Chirp数值核，为时长计算增加寄存级 |
| `MainRxController.vhd`、`MainAdcBridge.sv` | main专用采集控制、ADC SPI、稳定数据跨时钟域、全速FFT分支、原始数据限长和削顶标记 |
| `MainCicDecimator.sv` | /32低通抽取，运算流水线满足高速主时钟需求 |
| `MainFrameRam.sv`、`MainFftProcessor.sv` | 8192点缓存、跨时钟域、去直流、共享Kaiser/FFT/功率峰值核 |
| `MainTxPack.vhd`、`MainWaveFifo.sv` | 保持原始包格式，使用同一时钟下的16组帧缓存；每帧结束自动清空 |
| `MainPeakReport.sv` | 波形包后追加64字节M1 ASCII记录 |
| `MainTMP117Controller.vhd` | main温度控制改用同一上升沿；I²C状态逻辑沿用原版 |
| `MainTiming.sdc`、`MainSettings.vhd` | main时序约束和生成的默认参数 |

原 `TxController` 文件及 `ChirpWaveGen` 数值核、两个独立实验以及同级 `original` 备份保留。修改前的main文件备份在 `verification/Archive/before_main_fft_20261017.zip`。

## 结果如何解释

M1包含帧号、实际FFT点数、峰值bin、功率、滤波后最小/最大值、状态和采样跨度；频率由bin与已知采样率换算。`power/64`为归一化FFT幅度平方，单位ADC code²，未校准成电功率或声功率。

空输入/采集不足、间隔错误、ADC削顶、FFT溢出、无明显峰值、去直流后削顶、原始缓存满会单独标记；带错误标记的结果不能作为正常测量通过。

验证采用分层方式：完整输入样本的CIC/FFT逐点比对、主系统短ADC引脚测试、完整长帧数据与打包测试、短真实UART逐位测试、两帧复用和全容量边界测试、Quartus全编译及时序。长帧测试压缩了ADC空闲节拍和UART逐位等待，**不是完整250ms实际时钟节拍的端到端仿真，也不是实板测试**。详细实测值和报告见 `verification/FFT/Main_20261017/`。

满容量边界和多频点FFT数值回归使用行为内存模型；短ADC引脚测试使用Intel内存模型；主系统长帧测试使用Intel FFT内存与等延迟的行为波形帧缓存。温度传感器在系统测试中固定模拟为25°C，不验证温度/I²C。

快速数值回归：`python run_main.py --fast-memory`。`python run_main.py --tx` 使用真实Intel浮点IP同时检查TX参数/启动，以及RX的250ms窗口、1ms延迟和采样周期。

## 原 main 集成验证记录（Chirp 默认值更新前）

- Quartus全编译通过，84项时序检查无负余量，最差余量 0.009 ns。
- 8192点FFT/功率/峰值逐点参考比对通过；25/100/500Hz分别为26.226/100.533/498.295Hz。
- 完整数据量回归：286458原始输入，71614原始回传点，8192 FFT点，143356回传字节，打包错位0。
- 131072字缓存容量、262144字节顺序、两帧自动清空、短ADC和真实UART测试通过。
- 尚未在实际主板运行本main版本。
- [图表与详细证据](../../verification/FFT/Main_20261017/report.html)。

## 2026-10-17：main Chirp 默认值与实验1对齐

中心40 kHz，扫频38–42 kHz，20 ms，幅度系数0.25，TX滤波旁路；其余TX采样配置与实验1一致。RTL只修改主顶层5个初始值，RX/FFT硬件源文件全部保持一致。main的串口触发流程保持原样。首次编译时序余量-0.257ns，未发布；main布局种子由3改为4，时钟和时序要求不变。

实际Intel IP参数/启动与幅度检查、短ADC顶层及286点回传检查通过；重新全编译，84项时序检查通过，最小余量 +0.013 ns。新的 `output_files/UsMimoTestBench.sof` 已生成；下载后才会生效，尚未实板验证。未重复完整20ms波形或长帧FFT仿真。

[本次修改与验证记录](../../verification/FFT/Main_20261017/chirp40_update.json)。旧SOF及修改前文件保存在 `verification/Archive/main_before_chirp40_20261017.zip`。
