# 验证结果与历史归档

这里保存报告、图表、采样数据和证据，不是当前编译使用的源代码。FPGA源码在 `../02_RTL/V0/SourceCode`，仿真入口在 `../02_RTL/V0/Simulation`，上位机源码在 `../03_SW/UsMimoTestBench`。

## 当前优先查看

| 内容 | 入口 |
|---|---|
| main：8192点FFT、25–500Hz峰值 | [报告](FFT/Main_20261017/report.html) |
| main：40kHz / 4kHz / 20ms / 幅度0.25默认值更新 | [修改和版本记录](FFT/Main_20261017/chirp40_update.json) · [最新时序](FFT/Main_20261017/chirp40_timing.json) |
| 新上位机：参数设置、波形和峰值 | [报告与界面](SW/MainUI_20261017/report.html) · [使用说明](../03_SW/README_main_2026-10-17.md) |
| 独立Chirp实验 | [Chirp索引](Chirp/README.md) |
| 独立50–100Hz FFT实验 | [FFT索引](FFT/README.md) |

## 目录用途

| 目录 | 保留内容 |
|---|---|
| [Chirp](Chirp/README.md) | 初次Chirp控制/数值验证及原始检查点 |
| [FFT](FFT/README.md) | 独立FFT与main集成报告、数据和版本证据 |
| [SW](SW/README.md) | 新上位机验证、界面预览及协议证据 |
| [Measurements](Measurements/README.md) | 实板示波器照片、真实串口日志 |
| [Figures](Figures/README.md) | draw.io/汇报引用的图片和原始数据 |
| [Archive](Archive/README.md) | 历史归档、旧源码/固件备份和清理索引 |

Quartus编译不会自动更新本目录。编译只更新当前revision对应的 `output_*` 目录；当前仿真会在 `Simulation/Chirp/results` 或 `Simulation/FFT/results` 生成新结果。本目录中的基线报告保留当时的配置，不应当作每次编译自动刷新的结果。

## 本次精简（2026-10-17）

删除了23份重复展开文件：旧编译日志、状态/源文件清单、已入证据包的仿真日志、自测命令/CSV及一张重复预览图。全部按SHA-256确认仍有相同副本，恢复位置逐项记录在 [清理清单](Archive/cleanup_20261017_duplicates.json)。没有删除任何唯一的测量记录或源代码。

保留报告直接链接的文件、波形/频谱CSV、实板照片/日志以及 `evidence.zip`。各证据ZIP中的源码只用于记录验证时的版本，不参与当前编译；无需再解压成多份源码目录。

`Archive/history_20261017.zip` 约97 MiB，占用最多，保存早期200kHz、旧FFT、失败重跑及旧入口快照。它不影响当前运行，但删除后会失去这些历史记录，本次保留。`original_backup_hashes.json` 是original备份的校验基准，也保留。

软件自测重新运行后可能再次生成命令hex、导出示例CSV及构建日志；它们是测试输出，不是应用运行依赖。
