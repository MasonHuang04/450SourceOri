# FFT 验证索引

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
