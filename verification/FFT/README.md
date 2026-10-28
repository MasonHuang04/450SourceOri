# FFT 验证索引

## 当前Main：25–2000 Hz（2026-10-21）

- [更新报告与英文误差图](Search2k_20261021/report.html)：其他参数不变，10–75 cm、每2.5 cm一点，共27点。
- 理想模型最大绝对距离误差0.467 mm、RMSE 0.226 mm；生产RTL、软件范围检查和生成配置已同步。尚未新增实板精度验证。
- [原始CSV](Search2k_20261021/distance_results.csv) · [旧500 Hz与新2000 Hz对照](Search2k_20261021/comparison.csv)。

## main：10–75 cm 距离扫描（2026-10-21）

- [当前 Main RTL 距离—误差图与报告](DistanceSweep_20261021/report.html)：27 点，间隔 2.5 cm；保留 25–500 Hz 搜峰设置。
- 理想单回波条件下，10–42.5 cm 范围内最大绝对误差 0.383 mm；45–75 cm 超出当前搜索范围，不能作为有效测距。非实板精度验证，生产 RTL、上位机和 SOF 未改。
- [原始数据](DistanceSweep_20261021/distance_results.csv) · [仿真与绘图脚本](DistanceSweep_20261021/run_sweep.py)。

## main：当前短窗版本（2026-10-20）

- [短窗报告](Short20ms_20261020/report.html)：19 ms RX、672有效点/1024 FFT、FPGA插值、M3协议。
- [用户反馈与版本校验](Short20ms_20261020/user_confirmation.json)：用户确认当前运行正常；未新增定量精度数据。
- [长窗插值对照](Interpolation_20261020/report.html)：保留旧8192点条件下的对比结果。
- [本次保存说明](../../readme_2026-10-20.md)。

## 初版main：2026-10-17集成记录

- [main报告](Main_20261017/report.html)：8192点、35.807kS/s、25–500Hz搜索。
- [40kHz Chirp默认值更新](Main_20261017/chirp40_update.json)及[最新时序结果](Main_20261017/chirp40_timing.json)。
- [100Hz波形数据](Main_20261017/waveform_100hz.csv)、[频谱数据](Main_20261017/spectrum_100hz.csv)、[完整长帧回传数据](Main_20261017/system_raw_words.csv)。
- [初始集成证据包](Main_20261017/evidence.zip)、[Chirp默认值更新证据包](Main_20261017/chirp40_update_evidence.zip)。详细仿真日志和编译摘要已包含在这些ZIP中，不再重复展开。

报告中区分初始main验证和后续40kHz默认值更新；旧 `timing.json` / `manifest.json` 属于初始集成版本，当前更新见 `chirp40_*` 文件。仿真通过不等于实板测试通过。

## 独立50–100Hz实验

- [报告与误差图](results/report.html)
- [数字检查](results/checks.json)
- [完整ADC引脚级仿真日志](full_top/simulation.log)
- [完整采集数据](full_top/capture.csv)
- [当前仿真入口](../../02_RTL/V0/Simulation/FFT/run.py)
- [当前示例图](../../02_RTL/V0/Simulation/FFT/results/fft.png)
- [编译检查基线](results/build_checks.json)

这里保留验证当时的参数与数据，再次运行会写入Simulation/FFT/results。删除的重复日志/状态文件可按 [清理索引](../Archive/cleanup_20261017_duplicates.json) 从历史或证据ZIP恢复。

## Main 温度补偿距离（2026-10-21）

[报告与界面](TemperatureRange_20261021/report.html)：FPGA 计算温度补偿距离、M4 回传；383 组数值、I²C模型、实际 UART、Main整帧、上位机与全部时序通过。未新增实板传感器或声学精度验证。
