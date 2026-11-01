"""Plot measured raw-RX samples using the established Python plotting backend."""
from pathlib import Path
import json,csv,sys,hashlib
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
from matplotlib.ticker import StrMethodFormatter

out=Path(__file__).parent
root=Path('E:/Document_HH/Course/26FA/450code/15_UsMimoTestBench_multiFPGA')
source=root/'verification/Output_real/1029'
sys.path.insert(0,'C:/Users/admin/.codex/skills/nature-figure/scripts')
from audit_panel_alignment import require_matplotlib_panel_alignment
s=json.loads((out/'analysis.json').read_text(encoding='utf-8'))
arrays=[]
for meta in s['files']:
    f=source/meta['file'];assert hashlib.sha256(f.read_bytes()).hexdigest()==meta['source_sha256']
    rows=list(csv.DictReader(f.open(encoding='utf-8-sig')))
    arrays.append((np.array([float(r['time_s'])*1000 for r in rows]),np.array([int(r['adc_centered']) for r in rows])))
    assert 18.9<meta['window_ms']<19.1
plt.rcParams.update({'font.family':'sans-serif','font.sans-serif':['Arial','DejaVu Sans'],'font.size':11,
 'axes.spines.top':False,'axes.spines.right':False,'svg.fonttype':'none','pdf.fonttype':42,'legend.frameon':False})
def save(fig,name):
    fig.canvas.draw()
    require_matplotlib_panel_alignment(fig,json_out=out/'qa'/f'{name}.alignment.json',strict=True)
    fig.savefig(out/f'{name}.png',dpi=300);fig.savefig(out/f'{name}.pdf');fig.savefig(out/f'{name}.svg');plt.close(fig)

fig,axes=plt.subplots(1,2,sharex=True,sharey=True,figsize=(12.4,4.9))
fig.subplots_adjust(left=.085,right=.98,bottom=.23,top=.74,wspace=.14)
fig.suptitle('Measured Raw RX: ADC Clipping Comparison',y=.98,fontsize=18)
for i,(ax,(t,y),meta) in enumerate(zip(axes,arrays,s['files'])):
    ax.plot(t,y,lw=.55,color='#176f9c',label='Measured samples',rasterized=True)
    ax.axhline(32767,color='#bb5544',ls='--',lw=1,label='ADC limits');ax.axhline(-32768,color='#bb5544',ls='--',lw=1)
    ax.axhline(meta['mean_code'],color='#6f7780',ls=':',lw=1.2,label='Frame mean')
    rail=(y==32767)|(y==-32768)
    ax.scatter(t[rail],y[rail],s=8,color='#bb3322',zorder=5,label='Clipped samples')
    ax.set_title(('Approx. 30-40 cm' if i==0 else 'Approx. 50 cm')+'\n'+f"{meta['positive_rail_points']+meta['negative_rail_points']} / {meta['points']} clipped ({meta['rail_percent']:.2f}%)",fontsize=13,pad=14)
    ax.set(xlim=(0,19),ylim=(-36000,36000),xlabel='Time from first exported sample (ms)')
    ax.set_xticks([0,5,10,15,19]);ax.set_yticks([-32768,-16384,0,16384,32767]);ax.yaxis.set_major_formatter(StrMethodFormatter('{x:,.0f}'))
    ax.grid(alpha=.15)
axes[0].set_ylabel('Signed ADC code')
fig.legend(*axes[0].get_legend_handles_labels(),ncol=4,loc='lower center',bbox_to_anchor=(.54,.015),fontsize=10)
save(fig,'measured_rx_clipping_EN')

fig,ax=plt.subplots(figsize=(9.2,4.8));fig.subplots_adjust(left=.12,right=.97,bottom=.24,top=.79)
fig.suptitle('Measured RX: Positive Peaks Clipped at +32,767',y=.97,fontsize=17)
t,y=arrays[0];take=(t>=10.2)&(t<=10.4)
ax.plot(t[take],y[take],'o-',ms=4,lw=1.5,color='#176f9c',label='Exported ADC samples')
ax.axhline(32767,color='#bb5544',ls='--',lw=1.2,label='Positive full-scale code')
rail=take&(y==32767);ax.scatter(t[rail],y[rail],s=38,color='#bb3322',zorder=5)
ax.set(xlim=(10.2,10.4),ylim=(-36000,38000),xlabel='Time from first exported sample (ms)',ylabel='Signed ADC code')
ax.set_xticks(np.linspace(10.2,10.4,5));ax.yaxis.set_major_formatter(StrMethodFormatter('{x:,.0f}'));ax.grid(alpha=.15)
fig.legend(*ax.get_legend_handles_labels(),ncol=2,loc='lower center',bbox_to_anchor=(.54,.025),fontsize=10)
save(fig,'clipped_cycles_zoom_EN')

a,b=s['files'];context=s['log_snapshot']['export_neighborhoods'];counts=s['log_snapshot']['statuses']
rows=''.join(f'<tr><td><a href="../{m["file"]}">{m["file"]}</a></td><td>{m["min_code"]:,}</td><td>{m["max_code"]:,}</td><td>{m["positive_rail_points"]}</td><td>{m["negative_rail_points"]}</td><td>{m["mean_code"]:.1f}</td></tr>' for m in s['files'])
report=f'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>2026-10-29 实测RX削顶分析</title>
<style>body{{font:16px/1.8 system-ui,'Microsoft YaHei',sans-serif;max-width:1120px;margin:32px auto;padding:0 24px;color:#193a51}}img{{max-width:100%}}table{{border-collapse:collapse;width:100%}}td,th{{padding:8px;border-bottom:1px solid #ccd5df;text-align:left}}.note{{background:#fff1cf;padding:15px}}a{{color:#176f9c}}</style>
<h1>实测确认：接收通路发生ADC正向削顶</h1>
<p>2026-10-29。用户确认前端已选择Amplifier / Rx_Amp。第一份距离约30–40cm，第二份约50cm；没有精确距离或逐帧位置标签。本页读取真实UART CSV与同一会话日志，没有使用理想仿真数据替代实测。</p>
<p><b>第一份导出样本中248/5442点（4.557%）等于+32767，第二份0点触顶。</b>这支持ADC输入通路超出正量程的判断。仅凭这些数值不能确定是哪一级增益/偏置造成，也不能换算实际输入伏特数。</p>
<table><tr><th>原始CSV</th><th>最小码</th><th>最大码</th><th>正触顶点</th><th>负触顶点</th><th>帧均值</th></tr>{rows}</table>
<p>两份均5442点、286.458325kS/s、18.9975ms。ADC-code是数字码，TX幅度0.100是数字比例，二者均不是输入电压读数。主载波谱峰在约39.8kHz与40.0kHz，符合原始RX载波通路。</p>
<img src="measured_rx_clipping_EN.png" alt="Measured raw RX clipping comparison">
<h2>触顶位置与直流偏置</h2>
<p>第一份的触顶集中在8.993–11.199ms和12.487–14.634ms（按相邻触顶点间隔不大于150us分组）。这里不是连续几毫秒都等于上限，而是多个载波周期的正峰被截平。放大图保留导出的真实采样点。</p>
<img src="clipped_cycles_zoom_EN.png" alt="Measured positive peak clipping">
<p>两份波形都偏向正方向，均值约5865与6320码；第一毫秒中位数约5964与6366码。按约6000码偏置估算，正半周可用余量由32767缩至约26767码。第一份均值已受削顶影响，不能据此精确反推未削顶峰值。软件减均值发生在采样后，不能恢复已经截掉的峰顶，也不能增加ADC采样前的量程。</p>
<h2>同一时段的峰值日志</h2>
<p>冻结读取13:36:48–13:44:32的310帧：ADC_CLIPPED {counts['ADC_CLIPPED']}帧（76.77%），OK {counts['OK']}帧，NO_STRONG_PEAK {counts['NO_STRONG_PEAK']}帧。本次主要问题是削顶。</p>
<p>13:41:15–13:41:35附近17帧均为ADC_CLIPPED，TX幅度0.1，峰功率约24888–25532，明显高于100的弱峰门限。13:43:55–13:44:15附近17帧均为OK，同样TX幅度0.1，功率约1841–1882，显示距离508.233–508.734mm。</p>
<p>CSV文件名是导出时间，内部没有采集帧号，连续采样期间不能据文件名精确匹配某一日志帧。以上为相邻时段对照，未宣称CSV与某行日志一一对应。会话后续可能继续追加；本报告使用的冻结区间见<a href="session_peaks_snapshot.csv">日志快照</a>。</p>
<h2>为什么有峰也拒绝测距</h2>
<p>当前RTL在整段RX采集期间，只要读到一个32767或-32768原始样本，就把削顶标志保持到帧结束。上位机收到这个标志会拒绝距离结果，即使FFT仍有很强的峰。当前CSV本身已出现大量正满量程点；原始1.145833MS/s流的触顶点数可能更多。UART只保留每4点中的1点，因此4.557%仅是导出序列比例。</p>
<h2>建议的下一步</h2>
<ol><li>保持TX幅度0.100及现有Chirp参数，优先把ADC前的RX模拟增益降低约一半（约6dB），然后固定位置单次采集、导出。实际电位器旋转方向和电阻装配需按实物确认。</li><li>重新采30–40cm和50cm两处，先确认所有帧的ADC_CLIPPED消失，并给峰值留余量，例如尽量保持ADC码在±25000以内。这是调试目标，不是ADC额定电压。</li><li>保持接收增益时，单纯继续降低TX幅度会同时减小新版内部参考幅度，可能更快触发弱峰。日志中0.02幅度出现过弱峰；位置并未固定标记，不能用该记录直接量化幅度因果关系。</li><li>若降低RX增益后仍只有正半周触顶，检查直流偏置来源；用DC耦合示波器逐级观察前端Rx_Amp、主板RX_IN及ADC差分驱动。此前调试记录提到RX电位器连线和THS4551相关改动，需对照实物，不把它们直接认定为故障。</li></ol>
<p>理想线性情况下，RX增益减半会使混频峰功率约变为1/4：50cm附近当前1840左右可能降至460左右，仍高于100门限。这仅是下一步设置的估算，需要重新采集验证；不能从已削顶的第一份CSV精确恢复真实输入幅度。</p>
<div class="note">本次不修改RTL、SOF、上位机或搜峰门限，也不绕过削顶保护。CSV证实超量程现象，但不提供ADC参考电压、模拟增益或精确反射距离，因而无法单凭这些记录确定输入是多少伏或系统绝对测距误差。</div>
<p><a href="https://www.ti.com/lit/ds/symlink/ads127l21.pdf">TI ADS127L21官方数据手册</a>说明ADC超量程会输出满量程码；本工程使用16位输出模式。图中代码单位未标定为伏特。</p>
<p><a href="analysis.json">完整数值与数据来源</a> · <a href="measured_rx_clipping_EN.png">对比图PNG</a> · <a href="clipped_cycles_zoom_EN.png">周期放大图PNG</a></p></html>'''
(out/'report.html').write_text(report,encoding='utf-8')
print('Measured clipping figures and report created.')
