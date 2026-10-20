# 历史归档索引

[history_20261017.zip](history_20261017.zip) 是整理前 verification 目录的完整快照，并附有整理前的关联文档。旧版本、失败重跑、测试向量、旧编译记录和此前的源码备份ZIP都在其中，未丢弃唯一数据。

需要查旧记录时，把压缩包解压到单独目录，再按下面的原目录名查找。压缩包内的 `HISTORY_MANIFEST.json` 记录每个文件的SHA-256。

其中 `archive_before_cleanup_20261016.zip` 是前一轮清理的源码备份；`unified_project_20261017/previous_project_entries.zip` 是统一QPF前的入口备份。它们作为历史文件包含在本压缩包内。

`original_backup_hashes.json` 保留 original 备份的校验基准，方便以后核对。历史JSON里的绝对路径/源文件布局是当时的证据，不代表当前执行入口。

| 整理前目录/文件 | 文件数 | 大小 |
|---|---:|---:|
| `archive_before_cleanup_20261016.zip` | 1 | 9.30 MiB |
| `cache_cleanup_20261017.json` | 1 | 0.00 MiB |
| `chirp_scope_firmware_20261016` | 34 | 1.16 MiB |
| `cleanup_manifest.json` | 1 | 0.00 MiB |
| `experiment_summary_20261016` | 11 | 5.35 MiB |
| `fft_reference_input` | 4 | 3.06 MiB |
| `full_80ms_interrupted_20261012` | 8 | 0.24 MiB |
| `FULL_80MS_RESTART_DIAGNOSIS.txt` | 1 | 0.00 MiB |
| `kaiser_fft_80ms_20261015` | 158 | 43.79 MiB |
| `kaiser_fft_peak_20261015` | 161 | 62.83 MiB |
| `mainboard_40k_20ms_20261016` | 28 | 5.68 MiB |
| `minimal_165m_20261014` | 38 | 23.96 MiB |
| `README.md` | 1 | 0.00 MiB |
| `report_figures` | 3 | 0.27 MiB |
| `residual_cleanup_20261017` | 2 | 0.02 MiB |
| `results` | 8 | 0.13 MiB |
| `rtl_200k_results` | 17 | 6.93 MiB |
| `rx_echo_results` | 10 | 3.30 MiB |
| `rx_fft_external_100hz20ms_20261016` | 17 | 2.53 MiB |
| `rx_fft_external_40k20ms_20261016` | 17 | 2.66 MiB |
| `rx_fft_lowfreq_20261016` | 27 | 0.97 MiB |
| `system_results` | 16 | 0.58 MiB |
| `TESTBENCH_200k.txt` | 1 | 0.01 MiB |
| `unified_project_20261017` | 3 | 0.02 MiB |
| `workflow_fft_20261015` | 2 | 0.19 MiB |
| `workflow_raw_input_20261015` | 2 | 0.46 MiB |


## 当前main与上位机的回退备份

| 文件 | 用途 |
|---|---|
| `before_main_fft_20261017.zip` | main接入FFT前的源文件 |
| `main_output_before_20261017.zip` | main集成前的输出文件 |
| `main_before_chirp40_20261017.zip` | main改成40kHz默认值前的源码、QSF和固件 |
| `sw_before_mainui_20261017.zip` | 03_SW改造前的源码与EXE |

这些备份对应不同阶段，不是同一版本的重复文件，本次保留。最新main/上位机的验证源码快照分别在FFT和SW结果目录的evidence.zip中。

## 2026-10-17 再次精简

见 [cleanup_20261017_duplicates.json](cleanup_20261017_duplicates.json)。23个删除项均有字节相同的恢复副本：大多数在本目录history ZIP或结果目录evidence ZIP中；重复界面图保留为ui_normal.png。清理清单记录原路径、大小、SHA-256及归档成员路径，不新增重复备份ZIP。


## 02_RTL / 03_SW 可重建缓存清理

[project_cache_cleanup_20261017.json](project_cache_cleanup_20261017.json)：删除388个Questa/MSBuild缓存及生成输入文件，约119.6 MiB。三个Revision引用检查、上位机离线自测通过，源码、配置、SOF、EXE未改。Quartus占用的db/incremental_db暂留。较大范围的旧代码/控件/JIC/DataRecording归档删除尚未执行，等待明确授权。


## SourceCode 专项清理

本轮明确授权的SourceCode清理已完成：246个文件精简为169个，移除77个未使用模块、备份和非当前仿真器模板。保留全部当前Quartus/Questa源输入。三个Revision引用检查、真实Intel IP参数/启动短回归通过；有效RTL、QSF和SOF内容未变。

- [完整清理前备份](sourcecode_before_cleanup_20261017.zip)
- [删除清单与验证](sourcecode_cleanup_20261017.json)

这不包括此前仍未处理的03_SW旧控件、JIC或DataRecording。

## SourceCode 文件合并

25份手写模块合并为6份，12份MEM/MIF移入ROM，根目录文件46→15。源模块逐字节保持，三个顶层、配置、时序约束及SOF不变；QSF与仿真入口同步引用新位置。三个Revision的Quartus Analysis & Elaboration通过，Chirp、FFT和短UART回归通过。未重新布局布线。

- [合并前源码与入口备份](source_bundle_before_20261017.zip)
- [文件映射、哈希与验证记录](source_bundle_20261017.json)
