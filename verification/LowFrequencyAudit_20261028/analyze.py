from pathlib import Path
import json
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

out=Path(__file__).parent
fs=165e6/144/32
n=672; nfft=1024; slope=4000/.020; c=343.
t=np.arange(n)/fs; window=np.kaiser(n,4)
true_hz=2*slope*.1/c
freq=np.fft.rfftfreq(nfft,1/fs)
def spectrum(x):
    power=np.abs(np.fft.rfft((x-x.mean())*window,nfft))**2
    k=1+int(np.argmax(power[1:58]))
    a,b,d=np.log(np.maximum(power[k-1:k+2],1e-100))
    delta=float(np.clip(.5*(a-d)/(a-2*b+d),-.5,.5))
    estimate=(k+delta)*fs/nfft
    return power,{'bin':k,'delta':delta,'estimated_hz':estimate,
                  'estimated_mm':estimate*c/(2*slope)*1000}

base=np.cos(2*np.pi*true_hz*t)
cases=[('Ideal 10 cm',base),
       ('Frequency shift: +84 Hz',np.cos(2*np.pi*(true_hz+84)*t)),
       ('Competing peak: 380 Hz',base+1.2*np.cos(2*np.pi*380*t))]
reference=spectrum(base)[0].max()
fig,axes=plt.subplots(1,3,figsize=(14.5,4.3),sharex=True,sharey=True,layout='constrained')
results=[]
for ax,(name,signal) in zip(axes,cases):
    p,result=spectrum(signal);results.append({'model':name,**result})
    ax.plot(freq,10*np.log10(np.maximum(p/reference,1e-10)),'o-',ms=3,lw=1.6,color='#176f9c',label='1024-point FFT')
    ax.axvline(true_hz,color='#64748b',ls='--',lw=1,label='Ideal beat: 116.62 Hz')
    ax.axvline(result['estimated_hz'],color='#de8500',ls=':',lw=1.8,label=f"Selected: {result['estimated_hz']:.2f} Hz")
    ax.set_title(name+'\n'+f"Estimated distance: {result['estimated_mm']:.2f} mm",fontsize=12)
    ax.set_xlim(0,500);ax.set_ylim(-65,7);ax.set_xlabel('Beat frequency (Hz)')
    ax.grid(alpha=.2);ax.legend(fontsize=8,loc='lower right')
axes[0].set_ylabel('Power relative to ideal peak (dB)')
fig.suptitle('Frequency Offset vs. Peak Switching — Illustrative Models, Not Measurements',fontsize=15)
fig.savefig(out/'spectrum_hypotheses_EN.png',dpi=180)
plt.close(fig)

x=np.arange(10,50.01,2.5)
y=np.array([171.862,300.795,366.32,245.312,268.46,292.558,317.109,340.549,368.341,392.001,416.42,439.76,465.443,479.952,515.935,539.267,567.111])
mask=x>=17.5;m,b=np.polyfit(x[mask]*10,y[mask],1)
res=y[mask]-(m*x[mask]*10+b)
summary={'date':'2026-10-28','scope':'Read-only audit of original project; new floating-point diagnostic models only, not a new RTL or hardware test.',
         'original_project':'15_UsMimoTestBench','sampling_hz':fs,'effective_samples':n,'fft_length':nfft,'window':'Kaiser beta=4',
         'search_bins':[1,57],'assumed_sound_speed_m_s':c,'chirp_slope_hz_s':slope,
         'model_notes':['Input is synthesized after decimation; full ADC/CIC is not simulated.','Floating point, frame mean removal and existing peak/interpolation rule.','+84 Hz chosen to illustrate measured trend offset; it does not establish its physical cause.','380 Hz interference is an illustrative competing component, not measured spectrum.'],
         'models':results,'fit_17p5_to_50cm':{'slope_mm_per_mm':m,'offset_mm':b,'r_squared':1-float(res@res)/float(np.sum((y[mask]-y[mask].mean())**2)),
                                         'equivalent_offset_hz':2*slope*b*.001/c},
         'measured_spectrum_available':False,
         'transcribed_measurements':[{'actual_cm':float(a),'measured_mm':float(v),'inferred_hz_at_343m_s':float(v*.001*2*slope/c)} for a,v in zip(x,y)]}
(out/'analysis.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
rows=''.join(f'<tr><td>{a:g}</td><td>{v:.3f}</td><td>{2*slope*a*.01/c:.2f}</td><td>{2*slope*v*.001/c:.2f}</td></tr>' for a,v in zip(x[:5],y[:5]))
report=f'''<!doctype html><html lang="zh-CN"><meta charset="utf-8"><title>Low-frequency offset audit — 2026-10-28</title>
<style>body{{font:16px/1.8 system-ui,'Microsoft YaHei',sans-serif;max-width:1120px;margin:32px auto;padding:0 24px;color:#193a51}}img{{max-width:100%}}table{{border-collapse:collapse;width:100%}}td,th{{padding:8px;border-bottom:1px solid #ccd5df}}.note{{background:#fff2d9;padding:14px}}</style>
<h1>原工程：低频频移与换峰排查</h1><p>检查对象为15_UsMimoTestBench，未修改RTL、SOF或上位机。实际距离单位cm，测量结果单位mm。原工程使用模拟混频后低频输入；本页不是multiFPGA方波固件验证报告。</p>
<p><b>可能有固定频率偏移，但单一固定偏移不能解释全部异常点。</b>17.5–50cm拟合：测量mm = {m:.6f} × 实际mm + {b:.3f}；R²={summary['fit_17p5_to_50cm']['r_squared']:.6f}。截距等效约{summary['fit_17p5_to_50cm']['equivalent_offset_hz']:.2f}Hz，但不证明真实电路产生了恒定频偏。</p>
<table><tr><th>实际/cm</th><th>测量/mm</th><th>理想拍频/Hz</th><th>由测量距离反推/Hz</th></tr>{rows}</table>
<p>以上使用c=343m/s、B=4kHz、T=20ms。实际温度与当次TX参数需用测量日志确认；反推值不是保存下来的实测频谱。</p>
<h2>同参数浮点排查模型</h2><img src="spectrum_hypotheses_EN.png" alt="Illustrative frequency offset and peak-switching models">
<div class="note">这张图是人为构造的三种输入，不是实测证据，也不是重新运行的RTL。使用当前FFT输入采样率35.807292kS/s、672点、去均值、Kaiser4、1024点FFT、bin1–57搜峰和三点对数插值。未重跑ADC/CIC、定点量化或声学模型。84Hz按观察到的整体偏移选取，380Hz用于展示另一个峰胜出的情况。</div>
<p>添加一个低频分量与把目标拍频整体加上频偏是不同模型：前者产生额外峰或峰重叠，后者移动目标峰。单独选中100–120Hz干扰一般会报约86–103mm，不能直接解释300–366mm读数；这些读数对应约351–427Hz，必须检查更高的峰、谐波/旁瓣或其他畸变。</p>
<h2>为什么10cm理想RTL仿真通过</h2><p><a href="../FFT/Search2k_20261021/distance_results.csv">原工程RTL扫描数据</a>中，10cm理想拍频116.618Hz，输出116.720Hz，误差+0.087mm；12.5cm输出146.131Hz，误差+0.307mm。它验证理想输入时的数字处理，不排除实际干扰、非线性、群延迟和多径。原代码去帧均值只能移除常量DC，不能移除100Hz等非零频率干扰。</p>
<h2>下一次实测需要的证据</h2><ol><li>保存无反射目标及10、12.5、15、17.5cm的混频后波形，保持TX参数、增益和摆放不变；无目标仍有环境反射，不能把所有剩余峰直接定为电串扰。</li><li>用同一采样率/有效时间窗处理，显示完整0–2kHz功率谱、前三个局部峰、原始bin、插值频率与削顶状态。</li><li>目标移动时一直固定的峰是干扰候选；随距离平滑移动的是目标候选；两个峰高低交换支持换峰。固定的目标频偏需另做固定路径/频响标定。</li></ol>
<p>原上位机UART波形为ADC每4点保留1点的IF支路，重算应先按实际波形采样间隔解释，不能直接当作35.807kS/s FFT输入。要精确对齐FPGA，应取得CIC后的672点或回传FFT频谱；PC重算近似谱需标明差异。</p>
<p><a href="analysis.json">计算结果与模型假设</a> · <a href="analyze.py">复现脚本</a></p></html>'''
(out/'report.html').write_text(report,encoding='utf-8')
print(json.dumps({'models':results,'fit':summary['fit_17p5_to_50cm']},indent=2))
