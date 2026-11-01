# 450SourceOri — FPGA digital mixer / Square TX

本目录对应 **`fpga-mixer` 分支**。原始RX载波经ADC后，在FPGA内与同源数字正弦参考相乘，再做CIC低通、FFT、搜峰和插值。

## 两个目录、两个分支

| 本地目录 | GitHub分支 | Main输入 |
|---|---|---|
| `15_UsMimoTestBench` | [`main`](https://github.com/MasonHuang04/450SourceOri/tree/main) | 前端模拟混频后的低频 |
| `15_UsMimoTestBench_multiFPGA` | [`fpga-mixer`](https://github.com/MasonHuang04/450SourceOri/tree/fpga-mixer) | 原始约40kHz RX载波 |

两个目录各有独立Git工作区，提交和推送各自分支。不要通过覆盖整个文件夹同步两种硬件链路；共用修复可在审核后按提交同步。两分支以原有共同历史为基础分别保存当前工作状态，不自动互相合并。

## 本分支默认配置与入口

- TX：方波TX；内部保留同相位正弦参考，40kHz中心、4kHz带宽、20ms、幅度0.25。
- RX：延迟1ms后采19ms；ADC1.145833MS/s；回传波形每4点保留1点。
- FFT：CIC3 /32 → 35.807292kS/s；672有效点加Kaiser beta=4，补零到1024；25–2000Hz搜峰及FPGA三点对数插值。
- FPGA计算温度补偿声速和距离，使用M4报文；系统/DAC165MHz，FFT50MHz，UART2Mbaud / 8N1。
- **前端P4：2–3，Amplifier / Rx_Amp**；旁路AD835，主板模拟RX低通旁路。

[Quartus工程](02_RTL/V0/UsMimoTestBench.qpf) · [本分支Main SOF](02_RTL/V0/output_files/UsMimoTestBench.sof) · [配套上位机RunMain.cmd](03_SW/RunMain.cmd)

同一QPF中选择 `UsMimoTestBench` revision编译Main。独立Chirp、独立低频FFT实验有各自Revision，不要混用其SOF和上位机。SOF/EXE均取自本分支；代码改动后需重新编译和核对时序。主板供电、连接及实物改动还需参照[接线记录](HARDWARE_WIRING_NOTES.txt)。

## 结果与证据

- [数字混频、方波TX及完整Main验证](verification/SquareTx_20261026/report.html)
- [27个距离点及15cm FFT频谱](verification/SquareTx_20261026/figures_20261028/report.html)
- [前端Mixer误接对照](verification/MixerRouteAudit_20261028/report.html)
- [流程图](WORKFLOW_Demo_MULFPGA.drawio)

仿真通过说明对应模型下的数字处理和接口验证通过，不保证真实声学链路的测距精度。固定偏移、群延迟、过载、多径及最大峰切换均需结合实测检查。使用方波新版时须正确选择Rx_Amp；错误接入Rx_Mix可能偶尔给出看似正确的距离。

## 日常提交与同步

在本目录终端中操作，先确认当前分支：

```powershell
git branch --show-current
git status
git add <本次修改的文件或目录>
git commit -m "说明本次修改"
git push origin fpga-mixer
```

此目录的当前分支应为 `fpga-mixer`，上游为 `origin/fpga-mixer`。另一目录的未提交文件不会随本目录提交一起上传。需要拉取更新时，先保存自己的改动，再运行 `git pull --ff-only`；出现分叉时先检查差异。

新电脑可分别克隆：

```powershell
git clone --branch main --single-branch https://github.com/MasonHuang04/450SourceOri.git 15_UsMimoTestBench
git clone --branch fpga-mixer --single-branch https://github.com/MasonHuang04/450SourceOri.git 15_UsMimoTestBench_multiFPGA
```

## 文件保留策略

Git保留硬件设计、源码/IP/ROM、工程配置、仿真入口、必要自测样本、报告、图表和关键数值。沿用当前项目方式，保留三个最新SOF、配套Release EXE和构建摘要，使克隆后入口可直接使用；后续可按版本标签发布Release附件。

Quartus/Questa/MSBuild缓存、DataSessions原始会话目录及本地回退ZIP不进入新提交。关键实测资料按需整理到verification后提交。旧文档中的回退ZIP链接仅适用于保留这些本地备份的电脑。`original`备份及同级独立Simulation工程不属于此仓库。

当前Main SOF SHA256：`d83136b1530341af5195e5e8135eee4d34cfb9d772135106a8a81ba950cc96c1`

当前上位机EXE SHA256：`466aed0c3b1830df3bc3ce69c7f53996268aa99b7a1fa94760ad3bc5be129cc3`

2026-10-28整理：仅分支/仓库配置、说明和打包元数据调整；保留已经验证的RTL、SOF和EXE原始字节。


## 2026-11-01 workflow 复核

[新旧混频、ADC 参考配对、帧处理顺序及验证记录](verification/WorkflowAudit_20261101/README.md)。当前处理顺序审查通过；真实模拟/ADC 群延迟与绝对距离仍需标定。本次保留已验证的 RTL、SOF 和 EXE，更新说明与证据。

[2026-10-29 实测 RX 削顶记录](verification/Output_real/1029/analysis_20261029/report.html)已归档，不能将理想仿真误差当作这组实板数据的精度保证。
