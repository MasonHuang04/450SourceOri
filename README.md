# 450SourceOri

超声 MIMO 测试平台的当前工作工程：主板/前端电路、FPGA RTL、仿真入口和桌面上位机。

## 当前入口

| 内容 | 位置 |
|---|---|
| 硬件设计 | `01_Elec/01_MainBoard`、`01_Elec/02_FrontEnd`（Altium） |
| 唯一 Quartus 工程 | [UsMimoTestBench.qpf](02_RTL/V0/UsMimoTestBench.qpf) |
| 三个 Revision / 仿真说明 | [Simulation/README.md](02_RTL/V0/Simulation/README.md) |
| main 使用说明 | [README_main_2026-10-17.md](02_RTL/V0/README_main_2026-10-17.md) |
| 图形上位机 | [03_SW/RunMain.cmd](03_SW/RunMain.cmd) |
| 上位机说明 | [03_SW/README_main_2026-10-17.md](03_SW/README_main_2026-10-17.md) |
| 验证结果索引 | [verification/README.md](verification/README.md) |

## main 默认配置

- TX：中心40 kHz、带宽4 kHz（38–42 kHz）、20 ms、幅度0.25，TX滤波旁路。
- RX：250 ms，延迟1 ms；原始ADC约1.146 MS/s，波形每4点保留1点。
- FFT：CIC/32后约35.807 kS/s，8192点，Kaiser β=4，25–500 Hz功率峰值搜索。
- FPGA系统时钟165 MHz；UART 2 Mbaud / 8N1。
- 03_SW可在运行时发送TX参数，显示RX波形和FPGA峰值，无需为改这些参数重新编译FPGA。

板上应使用 main revision `UsMimoTestBench`。独立Chirp与独立FFT实验分别使用自己的Revision，不能混用上位机协议。main低频测试先用持续的外部信号发生器模拟混频信号；当前没有新增FPGA TX×RX混频器。

## 打开和构建

FPGA：用Quartus Prime Lite打开唯一QPF，Project → Revisions选择目标，再编译。三个当前SOF和时序摘要随仓库保存；源码改变后需重新编译和核对时序。

软件：Windows下双击 `03_SW/RunMain.cmd`。重新编译可运行 `03_SW/Build.ps1`，或用Visual Studio打开原解决方案；需要.NET Framework 4.8开发工具。连接主板COM后点击「应用并采集一次」。

仿真：Python、NumPy、Matplotlib和Questa。运行两个Simulation目录内的脚本，具体见对应README。脚本中Questa路径按原电脑配置，换电脑时调整路径。当前软件自测使用仓库内保留的两个UART/波形测试数据文件。

## 验证范围与版本保存

仓库记录RTL分层测试、UART协议测试和时序结果；它们不等同于完整声学链路或最新main的实板验证。上位机界面预览是明确标识的离线合成演示。

`.gitignore`排除Quartus/Questa/MSBuild缓存、旧原始录波、重复编译产物和大型本地历史备份。最新报告、必要采样数据、验证证据ZIP、三个SOF和上位机Release保留。被忽略的文件仍在原电脑，不会因Git初始化被删除。

本仓库对应当前 `15_UsMimoTestBench` 工作工程，不包含同级 `15_UsMimoTestBench_original` 备份或独立的 `Simulation` 目录。历史文档中指向 `verification/Archive` ZIP的链接仅适用于保留了这些本地归档的电脑；该目录的大型回退包不随Git上传。
