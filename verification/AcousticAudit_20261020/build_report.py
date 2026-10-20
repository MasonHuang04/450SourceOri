"""Rebuild this audit's figures and derived tables. No production files are changed.
Requires Python, numpy, matplotlib. Inputs are frozen under data/.
The envelope model is illustrative, not a fit to the user's transducers.
"""
from pathlib import Path
import csv, json, hashlib, html
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import xml.etree.ElementTree as ET

D = Path(__file__).resolve().parent
DATA = D / "data"
checks = json.loads((DATA / "rtl_checks.json").read_text())
assert checks["pass_all"] and checks["ram_model"] == "behavioral"
spec = np.genfromtxt(DATA / "rtl_spectrum.csv", delimiter=",", names=True)
fs = 165e6 / 144 / 32
df = fs / 1024
obs = 672 / fs
distances = [5, 7.5, 12.5]
physics = []
for cm, row in zip(distances, checks["cases"][:3]):
    f = 2 * 200000 * cm / 100 / 343
    physics.append(dict(distance_cm=cm, ideal_beat_hz=f,
                        observed_cycles=f*obs, synthetic_rtl_hz=row["interpolated_hz"],
                        error_hz=row["interpolated_error_hz"]))
with (D / "ideal_beats.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(physics[0]))
    w.writeheader(); w.writerows(physics)

logs = list(csv.DictReader((DATA / "20261020_170453_7fee98_peaks.csv").open(encoding="utf-8-sig")))
assert len(logs) == 1576
jumps = []
for a, b in zip(logs, logs[1:]):
    if abs(float(b["peak_hz"])-float(a["peak_hz"])) > 150:
        jumps.append({f"{prefix}_{key}": row[key] for prefix, row in [("before", a), ("after", b)]
                      for key in ["time", "sequence", "status", "peak_hz", "bin", "raw_bin_hz", "delta_q16"]})
assert len(jumps) == 20
assert all(int(j["before_bin"]) != int(j["after_bin"]) for j in jumps)
with (D / "measured_jumps.csv").open("w", newline="", encoding="utf-8") as f:
    w = csv.DictWriter(f, fieldnames=list(jumps[0]))
    w.writeheader(); w.writerows(jumps)

plt.rcParams.update({"font.size": 11, "axes.spines.top": False, "axes.spines.right": False,
                     "axes.grid": True, "grid.alpha": .22, "savefig.dpi": 170})
fig, ax = plt.subplots(1, 2, figsize=(12.7, 4.7), layout="constrained")
colors = ["#1675a5", "#d46522"]
for case, label, color in [(3, "100 Hz stronger: peak 99.80 Hz", colors[0]),
                            (4, "380 Hz stronger: peak 379.78 Hz", colors[1])]:
    rows = spec[(spec["case"] == case) & (spec["bin"] <= 16)]
    p = rows["power"]
    ax[0].plot(rows["bin"]*df, 10*np.log10(np.maximum(p, 1)/max(p)), "o-", lw=1.8, ms=4,
               label=label, color=color)
ax[0].set(title="Unchanged production RTL: two-tone input",
          xlabel="Frequency (Hz)", ylabel="Power relative to each frame peak (dB)",
          xlim=(0, 550), ylim=(-45, 2))
ax[0].legend(fontsize=9, loc="lower center")
sub = [r for r in logs if 46 <= int(r["sequence"]) <= 55]
x = [int(r["sequence"]) for r in sub]
ax[1].plot(x, [float(r["raw_bin_hz"]) for r in sub], "s--", label="FFT bin before interpolation", color="#8995a4")
ax[1].plot(x, [float(r["peak_hz"]) for r in sub], "o-", label="FPGA interpolated result", color="#1675a5")
ax[1].set(title="Actual UART log: distance was not recorded",
          xlabel="Frame sequence", ylabel="Reported frequency (Hz)", xticks=x)
ax[1].legend(fontsize=9)
fig.suptitle("Peak selection can jump; interpolation only refines the selected peak", fontsize=14)
fig.savefig(D / "peak_switch.png")
plt.close(fig)

# Quasi-static total RF amplitude response. This is not a causal transducer model.
# Same shaped TX is assumed to feed both the acoustic emitter and mixer reference.
# A(t)=sqrt(g_min/g(t)) reduces the resonant center, never boosts the drive above 1.
t = .001 + np.arange(672)/fs
tau = 2*.125/343
def gain_at_time(u):
    freq = 38000 + 200000*u
    return .2 + .8*np.exp(-.5*((freq-40000)/850)**2)
u = np.linspace(0, .02, 2001)
floor = float(np.min(gain_at_time(u)))
def drive(u):
    return np.sqrt(floor/gain_at_time(u))
g = gain_at_time(t-tau)
comp = g*drive(t-tau)*drive(t)
carrier = np.cos(2*np.pi*(200000*tau)*t + .4)
assert np.max(drive(u)) <= 1.0000000001
env_stats = dict(
    model="Illustrative quasi-static RF Gaussian gain with 0.2 floor; unknown actual transducer model",
    assumptions="No noise, ringing, phase dispersion, clipping, multi-path or time-varying offset; common shaped TX reference",
    before_envelope_max_min_ratio=float(g.max()/g.min()),
    after_envelope_max_min_ratio=float(comp.max()/comp.min()),
    maximum_normalized_drive=float(drive(u).max()),
    minimum_normalized_drive=float(drive(u).min()),
    real_hardware_improvement_verified=False,
)
(D / "envelope_model.json").write_text(json.dumps(env_stats, indent=2), encoding="utf-8")
np.savetxt(D / "envelope_model.csv",
           np.c_[t, g, comp, g*carrier, comp*carrier],
           delimiter=",", header="receive_time_s,uncompensated_envelope,shaped_envelope,uncompensated_if,shaped_if",
           comments="")
fig, ax = plt.subplots(2, 2, figsize=(12, 7), layout="constrained")
ax[0,0].plot(u*1000, np.ones(len(u)), label="Current constant TX amplitude", color=colors[0])
ax[0,0].plot(u*1000, drive(u), label="Candidate: reduce resonant center", color=colors[1])
ax[0,0].set(title="TX drive envelope (not the 40 kHz carrier)", ylabel="Normalized drive", ylim=(0, 1.15))
ax[0,0].legend(fontsize=9)
ax[0,1].plot(u*1000, gain_at_time(u), color=colors[0])
ax[0,1].set(title="Assumed TX + RX amplitude response", ylabel="Relative RF gain")
ax[1,0].plot(t*1000, g*carrier, color=colors[0], lw=1.5)
ax[1,0].plot(t*1000, g, "--", color="#a6b1bb", lw=1)
ax[1,0].plot(t*1000, -g, "--", color="#a6b1bb", lw=1)
ax[1,0].set(title="Uncompensated mixer / LPF output", ylabel="Relative IF amplitude", ylim=(-1.1, 1.1))
ax[1,1].plot(t*1000, comp*carrier, color=colors[1], lw=1.5)
ax[1,1].plot(t*1000, comp, "--", color="#a6b1bb", lw=1)
ax[1,1].plot(t*1000, -comp, "--", color="#a6b1bb", lw=1)
ax[1,1].set(title="Candidate IF with shared shaped reference", ylabel="Relative IF amplitude", ylim=(-1.1, 1.1))
for a in ax.flat:
    a.set(xlabel="Time within chirp (ms)", xlim=(0, 20))
fig.suptitle("Illustrative envelope compensation only — not measured hardware data", fontsize=14)
fig.savefig(D / "envelope_model.png")
plt.close(fig)

workflow_steps = [
    ("TX 38–42 kHz / 20 ms", "Electrical amplitude and timing verified"),
    ("TX transducer → reflector → RX", "Unknown H(f), geometry, leakage and multipath"),
    ("Analog mixer × TX reference → LPF", "Preserves amplitude envelope; check offsets / clipping"),
    ("ADC → CIC /32 → mean removal", "672 effective samples; 18.77 ms"),
    ("Kaiser4 → FFT → power → global maximum", "1024 FFT; strongest peak may change identity"),
    ("FPGA peak interpolation → UART", "±0.5 bin only; no automatic distance conversion"),
]
mx = ET.Element("mxfile", host="app.diagrams.net")
diagram = ET.SubElement(mx, "diagram", name="Acoustic diagnosis 2026-10-20", id="acoustic-audit")
model = ET.SubElement(diagram, "mxGraphModel", dx="1400", dy="950", grid="1", gridSize="10",
                      page="1", pageScale="1", pageWidth="1400", pageHeight="950")
root = ET.SubElement(model, "root")
ET.SubElement(root, "mxCell", id="0")
ET.SubElement(root, "mxCell", id="1", parent="0")
def box(id, text, x, y, w, h, color="#e9f4fb", font=16):
    c = ET.SubElement(root, "mxCell", id=id, value=text, parent="1", vertex="1",
                      style=f"rounded=1;whiteSpace=wrap;html=0;fillColor={color};strokeColor=#728797;fontSize={font};")
    ET.SubElement(c, "mxGeometry", x=str(x), y=str(y), width=str(w), height=str(h),
                  attrib={"as":"geometry"})
def edge(a, b, id):
    e = ET.SubElement(root, "mxCell", id=id, source=a, target=b, parent="1", edge="1",
                      style="edgeStyle=orthogonalEdgeStyle;endArrow=block;strokeColor=#526b7c;")
    ET.SubElement(e, "mxGeometry", relative="1", attrib={"as":"geometry"})
box("title", "Current Main + acoustic diagnostic workflow\n40 kHz center | 4 kHz bandwidth | 20 ms TX | distances in cm", 60, 30, 1240, 80, "#ffffff", 23)
positions = [(60,150),(490,150),(920,150),(920,330),(490,330),(60,330)]
for i, ((title, body),(x,y)) in enumerate(zip(workflow_steps,positions)):
    box(f"w{i}", title+"\n\n"+body, x,y,380,125, "#fff1dd" if i in (1,2) else "#e9f4fb")
    if i: edge(f"w{i-1}",f"w{i}",f"e{i}")
box("measure", "1. Capture fixed distances\n5 / 7.5 / 10 / 12.5 / 15 cm\nTX reference + raw RX + IF\nSave waveform, gain and distance labels",60,540,280,160)
box("compare", "2. Identify the selected peak\nFull spectrum / top 3 local peaks\nRaw bin vs interpolation\nHarmonic / leakage / clipping checks",380,540,280,160)
box("calibrate", "3. Calibrate one stable branch\nFit f = aR + b, validate other positions\nMeasure amplitude + phase vs frequency\nNo arbitrary correction of jump frames",700,540,280,160)
box("improve", "4. Validate improvement offline\nConfidence / harmonic checks\nBounded response compensation\nThen consider FPGA integration",1020,540,280,160,"#e6f3e9")
for i,(a,b) in enumerate([("measure","compare"),("compare","calibrate"),("calibrate","improve")]):
    edge(a,b,f"d{i}")
box("limit", "Evidence: production RTL passes controlled tests; actual logs show bin jumps.\nNot established: which acoustic mechanism caused the 12.5 cm observation.\nNo production FPGA, GUI, SOF or original backup was changed by this audit.",60,770,1240,100,"#fff1dd",18)
ET.ElementTree(mx).write(D / "DIAGNOSTIC_WORKFLOW.drawio", encoding="utf-8", xml_declaration=True)

rows = "".join(f"<tr><td>{r['distance_cm']:g} cm</td><td>{r['ideal_beat_hz']:.3f}</td>"
               f"<td>{r['synthetic_rtl_hz']:.3f}</td><td>{r['error_hz']:+.3f}</td>"
               f"<td>{r['observed_cycles']:.2f}</td></tr>" for r in physics)
backup = json.loads((DATA / "backup_location.json").read_text())
report = f"""<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>声学链路与跳峰核查 · 2026-10-20</title>
<style>
body{{font:16px/1.8 system-ui,"Microsoft YaHei",sans-serif;margin:0;background:#eef3f6;color:#193044}}
main{{max-width:1100px;margin:30px auto;padding:36px;background:white;border-radius:14px}}
h1{{font-size:30px;line-height:1.4}}h2{{margin-top:36px;color:#17668b;font-size:23px}}
p{{margin:12px 0}}a{{color:#076eaa}}table{{border-collapse:collapse;width:100%;margin:18px 0}}
th,td{{padding:10px;border-bottom:1px solid #d4dfe5;text-align:left}}th{{background:#edf5fa}}
.note{{border-left:5px solid #e3a044;background:#fff7e8;padding:14px 20px}}
.ok{{border-left:5px solid #369776;background:#eaf7f1;padding:14px 20px}}
img{{width:100%;margin:16px 0}}code{{background:#f0f3f6;padding:2px 5px}}
.small{{color:#516777;font-size:14px}}li{{margin:7px 0}}.flow{{background:#eaf4fa;padding:20px;font-size:18px}}
</style><main>
<h1>声学链路与频率突跃核查</h1>
<p>2026-10-20 · 当前 Main 短窗版 · 40 kHz 中心 / 4 kHz 带宽 / 20 ms TX / 幅度 0.25</p>
<div class="note"><b>距离已更正为 5、7.5、12.5 cm，指探头到反射面的距离。</b>
此前按毫米得出的“理想拍频低于搜索范围”不适用于这次情况。探头型号和 TX/RX 中心间距仍未知。</div>
<h2>1. 备份与 Git 核查</h2>
<p>已建立 <code>{html.escape(backup['destination'])}</code>，包含 {backup['file_count']} 个文件、
{backup['total_bytes']/1024**2:.1f} MiB，逐文件 SHA-256 校验。保存当前源码、板卡设计、配置、文档、验证结果、
当前 SOF/EXE 和两份运行时峰值日志；排除 Git 数据库、可重建编译缓存和大型历史归档。original 目录未修改。</p>
<p>核查时，本地 HEAD 与 GitHub 私有仓库 <a href="https://github.com/MasonHuang04/450SourceOri">450SourceOri</a>
的 main 均为 <code>3ee6a8282ae6aaa0b73db41b842865f610f0cf4d</code>。关键 RTL、上位机源码、短窗与插值报告及
WORKFLOW_Demo.drawio 均逐文件匹配远端；只有 readme_2026-10-20.md 的最后一次 workflow 核对追加尚未提交。
本报告保存的是核查时基线；本次交付后的提交可在
<a href="https://github.com/MasonHuang04/450SourceOri/commits/main/">仓库提交记录</a>查看。</p>
<p class="small">备份并非整个目录的磁盘镜像；排除项见 <a href="data/backup_location.json">备份清单摘要</a>。
完整逐文件清单在备份目录 BACKUP_MANIFEST.json。<a href="data/git_audit.json">Git 逐项核查</a>。</p>
<h2>2. 厘米距离对应什么拍频？</h2>
<p>在共点收发、正对平面反射、无额外系统延迟的近似下：<code>S = B/T = 200000 Hz/s</code>，
<code>f_b = S × 2R/c</code>，取 <code>c = 343 m/s</code>。分置 TX/RX 时应使用真实总声程
<code>L_TX + L_RX</code>；例如对称平面反射时总路程为 <code>2√(R²+(d/2)²)</code>，d 为中心间距。</p>
<table><tr><th>反射面距离</th><th>理想拍频 / Hz</th><th>纯正弦输入 RTL / Hz</th><th>误差 / Hz</th><th>当前窗内周期数</th></tr>{rows}</table>
<p>表中 RTL 列使用理想拍频的纯正弦作为 ADC 数字输入，没有模拟声学传播或真实换能器。
三点都在当前名义 25–500 Hz 搜索范围内；窗长只有 18.767 ms，仍只有约 1–3 个低频周期，
因此这三次结果不能推广为任意相位、噪声、包络下的误差保证。</p>
<h2>3. 跳变发生在插值之前</h2>
<div class="ok">当前 FFT 算术、功率、峰值与插值的受控 RTL 测试通过；已有实板日志的跳变同时伴随原始 FFT 峰值格改变。
证据更支持“选到不同的峰”作为直接机制，尚不足以确定造成竞争峰的具体声学/模拟电路原因。</div>
<p>当前链路：CIC /32 → 整帧均值移除 → Kaiser β=4 → 1024 点 FFT（672 有效点+补零）→
<code>Re²+Im²</code> → 第 1–14 格中取最大功率 → 三点对数功率抛物线插值 → UART。
它没有多峰身份识别、谐波排除、跨帧追踪或自动距离换算。频域的 Re²+Im² 不等于把时域信号平方，本身不会把输入频率翻倍。</p>
<p>频点间隔 <b>{df:.6f} Hz</b>；插值限幅 ±0.5 格，即最多 <b>±{df/2:.6f} Hz</b>。
上位机使用 FPGA 返回的格号、Q16 偏移与 FFT 长度计算显示值，并校验偏移范围。
因此同一格的插值不能独自造成 100 → 380 Hz 的跳变。</p>
<table><tr><th>实际 UART 帧</th><th>原始格号</th><th>插值前 / Hz</th><th>插值后 / Hz</th><th>状态</th></tr>
<tr><td>17:05:58，seq 50</td><td>6</td><td>209.808</td><td>196.254</td><td>OK</td></tr>
<tr><td>17:05:59，seq 51</td><td>12</td><td>419.617</td><td>404.998</td><td>OK</td></tr></table>
<p>第二份日志有 1576 帧，其中 20 次相邻输出变化超过 150 Hz，全部伴随格号变化；
1543 帧 OK、32 帧 ADC_CLIPPED、1 帧 CENTERING_CLIPPED。第一份日志有 249 帧，
210 帧 OK、39 帧 NO_STRONG_PEAK。日志没有距离标签、原始 ADC 波形和完整功率谱，
不能把上述 seq 50/51 指认为 12.5 cm 的那次现象。OK 也不表示选中的峰就是目标回波。</p>
<img src="peak_switch.png" alt="不改RTL的双音跳峰测试与真实串口跳变">
<p>左图是新对照：100 Hz 与 380 Hz 同时输入，幅度从 7000:6300 交换为 6300:7000、相位固定，
输出便从 <b>99.802 Hz</b> 变为 <b>379.782 Hz</b>。这是正确执行“最大峰”规则，
不是已复现用户实板根因。右图是真实 UART 日志。</p>
<p class="small">测试覆盖实际 Main FFT 分支的 CIC、均值、窗、FFT、功率、峰值、插值和 M3 字节握手；
全量输入采样，压缩采样间空闲周期，使用行为 RAM。逐点 FFT/功率与定点参考一致，M3 校验、连续帧、
削顶标记、短帧/空帧拒绝通过。不是本次重新执行完整 Main 顶层、逐位 UART、Intel RAM、时序或实板声学测试。
<a href="data/rtl_checks.json">检查结果</a> · <a href="rtl_reproduction.zip">可复现测试源码包（无编译库）</a>。</p>
<h2>4. “斜率一样、存在偏移”怎样判断？</h2>
<p>若测量一直跟踪同一个物理峰，<code>f_meas ≈ aR+b</code> 很合理。
混频前的换能器/模拟链路群延迟、参考同步偏差以及距离零点可能形成偏移。
混频后的 IF 低通/CIC 固定延迟只改变稳态正弦的相位与时间位置，不能直接按 <code>Sτ</code> 当作拍频偏移。
固定偏移可以解释整条曲线平移，不能单独解释某一点跳到另一条分支。</p>
<p><b>只作诊断假设：</b>假如 5 cm 测得约 100 Hz、7.5 cm 测得约 130 Hz，同斜率分支到
12.5 cm 会接近 190 Hz；380 Hz 恰好接近其二倍。这使二次谐波成为候选，
但用户未提供这组精确配对数据，不能以此认定谐波。
双探头声程、直达串扰与回波相消、多径以及随时间变化的偏置也都可能改变最大峰。</p>
<table><tr><th>候选原因</th><th>怎样区分</th></tr>
<tr><td>稳定系统偏移</td><td>同一个峰随距离连续变化；多距离拟合 a、b，再用未参与拟合的位置验证。</td></tr>
<tr><td>谐波或非线性</td><td>同帧同时有 f 和约 2f；降低驱动或增益后，高次分量相对下降。未到 ADC 削顶不代表前级绝无线性失真。</td></tr>
<tr><td>串扰/多径与相消</td><td>改变目标角度、周边反射物或隔离直达路径后，候选峰强弱改变；检查固定峰与随距离移动峰。</td></tr>
<tr><td>短窗、包络、时变偏置</td><td>看 IF 波形的有效周期、均值漂移和起止瞬态；用同一波形离线比较处理结果。</td></tr></table>
<p>工程历史调试记录 <code>调试时的电路更改.txt</code> 曾注明乘法器偏置和若干放大级振荡修正。
这只是排查线索，不意味着这些问题现在仍然存在。当前 FPGA 只移除整帧均值，无法自动消除所有时变基线。</p>
<h2>5. 为什么会形成中间高、两边低的包络？</h2>
<p>电信号等幅，经过换能器以后不一定等幅。作为典型例子，
<a href="https://www.murata.com/-/media/webrenewal/products/sensor/ultrasonic/open/applinote_maopn.ashx?la=en">Murata MA40S4S/R 应用说明第 8 页</a>
给出了发射声压与接收灵敏度随频率的变化，40 kHz 附近响应更强。用户换能器型号未确认，不能把此曲线当作本板实测。</p>
<p>扫频把频率响应映射到时间上：38 kHz 时较弱 → 40 kHz 附近较强 → 42 kHz 时又变弱，
因此 RX 可能带一个包络。TX 与 RX 两端、反射路径和模拟前端的响应共同作用。
<a href="https://www.ti.com/lit/an/slaa907d/slaa907d.pdf">TI SLAA907D 第 2 节</a>
也讨论了谐振、增益饱和以及分置收发探头的几何校准。</p>
<p>简化模型：<code>RX = A(t) cos φ_RX(t)</code>。乘参考并低通后得到
<code>IF ≈ ½ A(t) A_ref(t) cos(2π f_b t + φ_H(t)) + d(t)</code>。
低通去掉和频，并不会自动去掉 A(t) 的包络；相位频响/群延迟变化也可能使拍频不再完全恒定。
对称的正包络本身不必然引起跳峰，但会增加频谱展宽和短窗估计偏差。</p>
<h2>6. 已做的补偿尝试：离线模型，不改当前固件</h2>
<img src="envelope_model.png" alt="仅示意的频响与限幅补偿模型">
<p>构造中心较强的总射频幅度响应 g(f)，不模拟实际换能器的因果振铃、相位色散、噪声、多径或非线性。
先尝试只压低中心、不提高两端峰值的幅度整形。
若同一条整形后的 TX 也作为混频参考，IF 幅度近似正比于 <code>A_TX²·g</code>，
因此采用 <code>A_TX≈√(g_min/g)</code>；固定等幅独立参考则应另按 <code>g_min/g</code> 设计。
延迟非零时，实际乘积为 <code>A_TX(t−τ)A_TX(t)</code>，不会完全等于平方。</p>
<p>该假设模型中包络最大/最小比从 {env_stats['before_envelope_max_min_ratio']:.2f} 降至
{env_stats['after_envelope_max_min_ratio']:.2f}，最大相对驱动不超过 1。
这是说明方法有可行性，不是实际硬件性能提升；中心衰减也牺牲信噪比。
必须先测实际复频响并确认 AD835 参考从哪里取得，再决定补偿位置与公式。</p>
<p><a href="https://eprints.whiterose.ac.uk/id/eprint/76005/">Smith 等 2012 年 PDAM 研究摘要</a>
报告了通过逆滤波预整形补偿换能器造成的 chirp 幅度削弱，也表明波形补偿成功不保证后续成像指标同步改善。
它支持尝试“实测后补偿”的方向，不给当前设备提供现成系数。</p>
<h2>7. 建议下一步 workflow</h2>
<div class="flow">固定距离并留原始波形 → 同帧看多个候选峰 → 排除削顶/谐波/串扰 → 校准稳定分支 →
实测频响并离线验证补偿 → 再决定 FPGA 修改</div>
<ol>
<li><b>固定现有 TX 参数</b>，在 5 / 7.5 / 10 / 12.5 / 15 cm 各采集多帧；
记录距离定义、探头间距、角度、增益、温度和时间。先不要用一个偏移量强行修正所有跳变。</li>
<li><b>示波器分段保存同次 chirp</b>：TX 参考、混频前 RX、混频后 IF。
两通道仪器可在目标固定时分两次采；不同次记录不能冒充同步。观察包络、削顶、起止振铃、IF 周期和基线。
差分 TX 的负端不是地，需正确差分测量。</li>
<li><b>导出完整 IF 波形/频谱</b>，并看前三个局部峰、原始格号、插值、峰间功率差和状态。
当前 M3 仅报告一个峰；可先用现有上位机波形导出做离线分析。该波形是原始 ADC /4，
并非 FFT 实际使用的 CIC /32 的 672 点，不能直接宣称两者逐点等同。</li>
<li><b>控制变量排查</b>：保持距离，适度降低现有驱动/接收增益检查谐波；改变目标角度/邻近反射物检查多径；
留无发射基线。跨帧追踪只能作为未来候选功能，不能用平滑把真实错误隐藏掉。</li>
<li><b>校准稳定分支</b>，拟合频率对距离的斜率与截距，并在独立位置验证。
“最大频率峰”不是“最近目标”，最大功率峰也不天然等于目标回波。</li>
<li><b>频响标定</b>：在允许的驱动范围内，分次发等幅窄带/固定频率 burst（例如带宽 0，中心从 38 到 42 kHz），
在稳态片段测 RX 幅度及相对相位；这一步看射频 RX，不用 Main 的 25–500 Hz 峰值当频响。
避免对深陷波做无界放大；优先离线比较限幅补偿与保留包络的模型拟合。</li>
</ol>
<p>也不要简单把 20 ms 改长并指望 FMCW 周期数必然增加：在固定带宽和距离、同步延长 chirp 时，
<code>f_b T = Bτ</code> 近似不变。这与连续固定频率信号发生器的长时间采样不同。
<a href="https://pmc.ncbi.nlm.nih.gov/articles/PMC9785695/">Laureti 等 2022 §3.4</a>
讨论了低拍频有限周期的限制与移位参考方案；移位参考属于另一个需要重新标定、验证的架构，不是当前 Main 已有功能。</p>
<p><a href="DIAGNOSTIC_WORKFLOW.drawio">打开可编辑 workflow</a> · <a href="ideal_beats.csv">厘米理论值 / RTL 表</a> ·
<a href="measured_jumps.csv">真实跳变明细</a> · <a href="envelope_model.csv">包络示意原始数据</a> ·
<a href="build_report.py">复算和绘图脚本</a></p>
<div class="note">本次没有修改生产 RTL、上位机、SOF、原有 draw.io 或 original 备份。
确认了测试条件下的算术正确性，识别了单峰选择的局限；12.5 cm 突跃的实际声学根因仍需带距离标签的同帧波形/频谱证实。</div>
</main></html>"""
(D / "report.html").write_text(report, encoding="utf-8")
(D / "analysis_summary.json").write_text(json.dumps(dict(
    corrected_distances_cm=distances, pure_tone_cases=physics, production_rtl_changed=False,
    actual_log_rows=len(logs), jumps_over_150_hz=len(jumps), all_jumps_change_raw_bin=True,
    interpolation_limit_hz=df/2, physical_root_cause_confirmed=False,
    diagnostic_ram_model="behavioral", diagnostic_full_top=False,
    competing_tone_outputs_hz=[r["interpolated_hz"] for r in checks["cases"][3:5]],
    envelope_model=env_stats), indent=2), encoding="utf-8")
print(json.dumps({"report":str(D/"report.html"),"rtl_pass":checks["pass_all"],
                  "jump_count":len(jumps),"envelope":env_stats},indent=2))
