"""Draw the saved Main RTL sweep; no simulation rerun or production edits."""
from pathlib import Path
import csv, json, html
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.font_manager import FontProperties, fontManager

D=Path(__file__).resolve().parent
rows=list(csv.DictReader((D/'distance_results.csv').open(encoding='utf-8')))
check=json.loads((D/'checks.json').read_text())
model=json.loads((D/'model.json').read_text())
assert len(rows)==27 and check['rtl_arithmetic_and_protocol_pass']
fontfile=Path('C:/Windows/Fonts/msyh.ttc')
if fontfile.exists():
    fontManager.addfont(str(fontfile))
    family=FontProperties(fname=str(fontfile)).get_name()
else: family='DejaVu Sans'
plt.rcParams.update({'font.family':family,'font.size':12,'axes.unicode_minus':False,
                     'axes.spines.top':False,'axes.spines.right':False,'savefig.dpi':180})
x=np.array([float(r['distance_cm']) for r in rows])
e=np.array([float(r['signed_error_mm']) for r in rows])
inside=np.array([r['nominal_search_contains_beat']=='True' for r in rows])
assert sum(inside)==14
limit=check['nominal_search_upper_distance_cm']
fig,axes=plt.subplots(1,2,figsize=(15,7.7))
fig.subplots_adjust(left=.07,right=.975,top=.71,bottom=.24,wspace=.23)
fig.text(.5,.955,'当前 Main RTL：10–75 cm 距离—误差仿真',ha='center',fontsize=24,weight='bold',color='#193a51')
fig.text(.5,.902,'40 kHz 中心 · 4 kHz 带宽 · 20 ms TX · 19 ms RX · 每 2.5 cm 一点，共 27 点',ha='center',fontsize=13)
fig.text(.5,.837,'Chirp / 延迟回波 / 混频模型 → ADC 数字输入 → 当前 FPGA RTL：CIC /32 → 去均值 → Kaiser4 → FFT → 找峰 → 插值',
         ha='center',fontsize=11,bbox=dict(boxstyle='round,pad=.7',facecolor='#eaf3fa',edgecolor='none'))
a,b=axes
a.axvspan(limit,76,color='#fff0dd',zorder=0)
a.axhline(0,color='#8796a1',lw=1)
a.plot(x[inside],e[inside],'o-',lw=1.8,ms=5,color='#126f9d',label='搜索范围内')
a.plot(x[~inside],e[~inside],'x--',lw=1.8,ms=7,mew=2,color='#c56623',label='超出搜索范围：错误输出')
a.axvline(limit,color='#b78045',linestyle=':',lw=1.4)
a.text(45,15,'500 Hz 边界 ≈ 42.9 cm',fontsize=10,color='#9a5728')
a.set(title='A  全部 27 点：保留当前 25–500 Hz 搜峰设置',xlabel='设置的反射面距离（cm）',ylabel='有符号距离误差（mm）',xlim=(8,77),ylim=(-390,42),xticks=np.arange(10,76,5))
a.annotate(f"75 cm → {float(rows[-1]['estimated_distance_cm']):.2f} cm\n误差 {e[-1]:.1f} mm",xy=(75,e[-1]),xytext=(47,-337),fontsize=11,color='#9a5728',arrowprops=dict(arrowstyle='->',color='#9a5728'))
a.legend(loc='lower left',fontsize=10,framealpha=.95)
b.axhspan(-.5,.5,color='#eef7fc',zorder=0)
b.axhline(0,color='#8796a1',lw=1)
b.plot(x[inside],e[inside],'o-',color='#126f9d',lw=1.8,ms=6)
b.set(title='B  放大 10–42.5 cm：理想单回波模型',xlabel='设置的反射面距离（cm）',ylabel='有符号距离误差（mm）',xlim=(9,43.5),ylim=(-.52,.58),xticks=x[inside])
b.tick_params(axis='x',labelrotation=45,labelsize=10)
imax=np.argmax(abs(e[inside]));xp=x[inside][imax];ep=e[inside][imax]
b.annotate(f'{ep:+.3f} mm',xy=(xp,ep),xytext=(xp+2,ep+.1),fontsize=11,color='#126f9d',arrowprops=dict(arrowstyle='->',color='#126f9d'))
for ax in axes: ax.grid(alpha=.2)
fig.text(.5,.105,f"搜索范围内：最大绝对误差 {check['inband_max_abs_error_mm']:.3f} mm；RMSE {check['inband_rmse_mm']:.3f} mm。连线仅用于观察趋势，未拟合或校准误差。",ha='center',fontsize=12)
fig.text(.5,.052,'声速 343 m/s；理想共点往返反射、无噪声/多径/换能器频响；距离换算在离线脚本完成。此图不代表实板测距精度。',ha='center',fontsize=10,color='#536574')
fig.savefig(D/'distance_error_10_75cm.png')
fig.savefig(D/'distance_error_10_75cm.svg')
plt.close(fig)

tr=[]
for r in rows:
    inband=r['nominal_search_contains_beat']=='True'
    tag='范围内' if inband else '超出搜峰范围'
    tr.append('<tr'+(' class="outside"' if not inband else '')+'>'+''.join('<td>'+v+'</td>' for v in [
        f"{float(r['distance_cm']):g}",f"{float(r['ideal_beat_hz']):.3f}",f"{float(r['interpolated_hz']):.3f}",
        f"{float(r['estimated_distance_cm']):.4f}",f"{float(r['signed_error_mm']):+.3f}",r['raw_bin'],r['interp_status'],tag])+'</tr>')
report=f'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>Main 距离扫描 · 2026-10-21</title>
<style>body{{font:16px/1.8 system-ui,"Microsoft YaHei",sans-serif;background:#edf3f7;color:#193347;margin:0}}main{{max-width:1200px;margin:24px auto;padding:32px;background:white;border-radius:12px}}h1{{font-size:29px}}h2{{font-size:22px;margin-top:30px;color:#176a91}}a{{color:#1679b0}}img{{width:100%}}.note{{background:#fff3e1;border-left:5px solid #cb8535;padding:15px 20px}}.ok{{background:#edf8f4;padding:15px 20px}}table{{border-collapse:collapse;width:100%;font-size:14px}}td,th{{padding:8px;border-bottom:1px solid #d7e2ea;text-align:right}}th{{background:#edf5fa}}.outside{{background:#fff7ec}}code{{background:#edf2f5;padding:2px 5px}}li{{margin:7px 0}}</style><main>
<h1>当前 Main：10–75 cm 距离—误差扫描</h1><p>2026-10-21 · 27 点，间隔 2.5 cm · 沿用当前已上板版本的生产 RTL 与参数。</p>
<div class="note"><b>当前配置不能正确覆盖全部 75 cm。</b> 25–500 Hz 搜峰范围对应理想反射距离约 2.14–42.88 cm。
本次保留限制：10–42.5 cm 的 14 点在范围内；45–75 cm 的 13 点在范围外。范围外的读数仍画出，但不能解释为有效测距。</div>
<img src="distance_error_10_75cm.png" alt="当前Main RTL距离误差点图与正常范围放大图">
<p><a href="distance_error_10_75cm.png">PNG 图片</a> · <a href="distance_error_10_75cm.svg">SVG 矢量图</a> ·
<a href="distance_results.csv">27 点原始结果 CSV</a> · <a href="evidence.zip">测试证据与源码快照</a></p>
<h2>这次模拟了哪些部分？</h2>
<p>与当前主板测试相同的默认设置：40 kHz 中心、4 kHz 带宽、20 ms 发射、幅度 0.25；RX 延迟 1 ms、接收 19 ms；
ADC 原始采样率 165 MHz /144，FFT 前 CIC3 /32 后约 35.807 kS/s，672 个有效点补零到 1024 点；Kaiser β=4，搜索第 1–14 格，FPGA 三点对数功率插值。</p>
<p><b>真正运行生产 RTL 的部分：</b>ADC 数字样本进入 MainCicDecimator → MainFftProcessor → 帧缓存/整帧去均值 →
Kaiser4 / FFT → 功率 → 最大峰 → FPGA 插值 → MainPeakReport 的 M3 字节报告。使用真实 Intel altsyncram 仿真模型；
仅在 testbench 压缩了采样间空闲时钟，物理采样率仍按当前 Main 的数值换算。
生产 HDL、ROM、上位机、SOF 和原有 testbench 文件未修改，源文件 SHA-256 可核对。</p>
<p><b>由数学模型提供的部分：</b>Chirp 及其延迟回波、模拟乘法器和理想低通。
设 <code>τ=2R/343</code>，<code>S=4000/0.020=200000 Hz/s</code>，理想拍频 <code>f_b=Sτ</code>。
不是直接给 FPGA 填入期望峰值：逐点生成两条 chirp 相乘后的差频波形，量化成 16 位 ADC 输入，再交给实际 RTL 运算。</p>
<p>采用差频相位 <code>2π(f_start τ + Sτt − Sτ²/2)</code>，反射附加相位取 0；考虑回波到达前输入为空、
20 ms TX 参考结束后的截断。到较远目标时，回波会在 RX 窗口开始后才到达。
混频后幅度固定为 7000 ADC codes、直流偏置 111 codes，仅用于隔离算法误差，未套用未知的距离衰减或接收增益。</p>
<p>未模拟本次 TX 生成器 RTL/DAC、ADC SPI 引脚时序、完整 Main 顶层、UART 逐位传输、换能器频响、
模拟低通起止瞬态、噪声、多径、串扰和系统距离零点。不能把理想模型误差当成实板精度。
当前 FPGA/上位机报告频率；本报告用 <code>R_est=c·f_est/(2S)</code> 离线换算距离，未给产品新增距离显示。</p>
<h2>结果与检查</h2>
<div class="ok">27 帧的 CIC 数据、整帧均值、窗输入、全部 FFT 实虚部和功率逐点通过参考检查；峰值索引、插值公式、
M3 校验与连续帧通过。通过的是计算与协议检查，<b>不是全部 27 个距离均能正确测量</b>。</div>
<ul><li>10–42.5 cm：最大绝对误差 <b>{check['inband_max_abs_error_mm']:.3f} mm</b>，RMSE <b>{check['inband_rmse_mm']:.3f} mm</b>。
同组数据只使用整数 FFT 格时，最大误差约 {check['inband_raw_bin_max_abs_error_mm']:.3f} mm；当前插值改善了这组理想单峰的频率估计。</li>
<li>12.5 cm 理想拍频约 145.773 Hz，本次 RTL 为 {float(rows[1]['interpolated_hz']):.3f} Hz，没有出现 380 Hz 突跃。
这与理想单回波条件一致；不能排除真实环境中的多峰竞争。</li>
<li>75 cm 理想拍频约 874.636 Hz，超出当前 500 Hz 搜索上限。RTL 选择到范围内的谱泄漏/旁瓣，显示约
{float(rows[-1]['interpolated_hz']):.3f} Hz，离线换算为 {float(rows[-1]['estimated_distance_cm']):.3f} cm，误差 {float(rows[-1]['signed_error_mm']):.3f} mm。</li>
<li>范围外帧也可能具有 flags=0，部分还能成功插值；这不代表物理目标正确。当前状态位并未判断真实主峰是否在搜索区外。</li>
<li>未做距离拟合、固定偏移校准或误差平滑。图中相邻点连线只用于观察趋势。</li></ul>
<p>Questa 日志记录 0 errors、62 warnings，涉及 Intel 库未用端口和复位前未知值；有效帧无未知结果，数值检查全部通过。
完整日志保存在 evidence.zip。</p>
<h2>每个距离点的结果</h2><table><tr><th>真实距离 cm</th><th>理想拍频 Hz</th><th>当前流程输出 Hz</th><th>换算距离 cm</th><th>误差 mm</th><th>峰格</th><th>插值状态</th><th>范围判断</th></tr>{''.join(tr)}</table>
<p>插值状态 0：插值算术有效；4：当前搜索区最大值不是包含左右邻点时的局部最大值，采用整数格回退。
范围判断使用已知仿真真值，因此只用于本报告诊断；当前硬件不会直接知道目标真值。</p>
<h2>复现</h2><ol><li>保留当前项目代码，运行 <code>python run_sweep.py --project 工作工程目录 --output 本地输出目录</code>。
可用 <code>--vsim</code> 指定 Questa；默认使用当前安装路径。</li>
<li>也可解压 evidence.zip，使用其中的 source_snapshot 作为 --project，可固定到本次测试源码。</li>
<li>run_sweep.py 重新生成 27 组 ADC 输入并执行生产模块仿真；<code>--analyze-only</code> 只复核已完成的输出。</li>
<li>在本报告目录执行 <code>python build_figure.py</code> 可从 CSV 重绘图片。依赖 numpy、matplotlib；未安装微软雅黑时需指定可用中文字体。</li></ol>
<p><a href="checks.json">检查摘要</a> · <a href="model.json">完整模型与参数</a> · <a href="run_sweep.py">仿真脚本</a> · <a href="build_figure.py">绘图脚本</a></p>
<p>若下一步需要正确覆盖 75 cm，应先把峰值搜索范围覆盖约 875 Hz 并留余量，再复测。
875 Hz 已在当前采样率和 1024 点 FFT 的计算频带内，当前首要限制是搜峰范围，不是缺少采样点。
本次按要求保留已上板流程，没有扩大搜索上限。</p></main></html>'''
(D/'report.html').write_text(report,encoding='utf-8')
print(D/'distance_error_10_75cm.png')
