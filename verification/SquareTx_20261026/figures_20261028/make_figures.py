"""Render archived RTL outputs; this script does not synthesize test signals."""
from pathlib import Path
import argparse,csv,hashlib,io,json,sys,zipfile
import numpy as np
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt

p=argparse.ArgumentParser()
p.add_argument('--evidence',type=Path,default=Path(__file__).parent.parent/'evidence.zip')
p.add_argument('--checks',type=Path,default=Path(__file__).parent.parent/'checks.json')
p.add_argument('--qa-tools',type=Path,required=True)
arg=p.parse_args()
sys.path.insert(0,str(arg.qa_tools))
from audit_panel_alignment import require_matplotlib_panel_alignment
out=Path(__file__).parent; (out/'qa').mkdir(exist_ok=True)
checks=json.loads(arg.checks.read_text(encoding='utf-8'))
frames=checks['frames']; assert frames['pass']
cases=frames['cases']; assert len(cases)==27
fs=165e6/144/32; nfft=1024; slope=4000/.020; sound_speed=343.
x=np.array([r['distance_cm'] for r in cases]);errors=np.array([r['error_mm'] for r in cases])
assert np.array_equal(x,np.arange(10,75.01,2.5))
for r in cases:
    f=(r['bin']+r['delta_q16']/65536)*fs/nfft
    assert abs(f-r['measured_hz'])<1e-9
    assert abs((f*sound_speed/(2*slope)-r['distance_cm']/100)*1000-r['error_mm'])<1e-9
selected=next(r for r in cases if r['distance_cm']==15)
with zipfile.ZipFile(arg.evidence) as archive:
    raw=archive.read('simulation/digital_mixer/frames/spectrum.csv')
    records=list(csv.DictReader(io.StringIO(raw.decode())))
    records=[{k:int(v) for k,v in r.items()} for r in records if int(r['case'])==selected['case']]
    assert len(records)==513 and [r['bin'] for r in records]==list(range(513))
    log=archive.read('simulation/digital_mixer/frames/simulation.log').decode(errors='replace')
    assert 'PASS DIGITAL MIXER FRAMES' in log and '# Errors: 0' in log
bins=np.array([r['bin'] for r in records]);power=np.array([r['power'] for r in records],dtype=np.int64)
real=np.array([r['real'] for r in records],dtype=np.int64);imag=np.array([r['imag'] for r in records],dtype=np.int64)
assert np.array_equal(power,real*real+imag*imag)
peak_bin=1+int(np.argmax(power[1:58]));assert peak_bin==selected['bin']==5
frequency=bins*fs/nfft
positive=power>0
db=np.full(power.shape,np.nan,dtype=float)
db[positive]=10*np.log10(power[positive]/power[peak_bin])
# Preserve all 513 frequencies in source data. Plot zoom is explicitly 0-600 Hz.
with (out/'fft_15cm_source.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['bin','frequency_hz','real_raw','imag_raw','power_raw','relative_power_db','in_search_band'])
    for i in bins:w.writerow([int(i),frequency[i],int(real[i]),int(imag[i]),int(power[i]),db[i],1<=i<=57])
with (out/'distance_sweep_source.csv').open('w',newline='',encoding='utf-8') as f:
    w=csv.writer(f);w.writerow(['distance_cm','ideal_hz','rtl_hz','raw_bin','delta_q16','inferred_distance_mm','signed_error_mm'])
    for r in cases:w.writerow([r['distance_cm'],r['ideal_hz'],r['measured_hz'],r['bin'],r['delta_q16'],r['distance_cm']*10+r['error_mm'],r['error_mm']])

plt.rcParams.update({'font.family':'sans-serif','font.sans-serif':['Arial','DejaVu Sans'],
 'font.size':12,'axes.titlesize':16,'axes.labelsize':13,'legend.fontsize':10,
 'axes.spines.top':False,'axes.spines.right':False,'axes.linewidth':.8,
 'svg.fonttype':'none','pdf.fonttype':42,'legend.frameon':False})
def save(fig,name):
    fig.canvas.draw()
    require_matplotlib_panel_alignment(fig,json_out=out/'qa'/f'{name}.alignment.json',strict=True)
    fig.savefig(out/f'{name}.png',dpi=300)
    fig.savefig(out/f'{name}.svg')
    fig.savefig(out/f'{name}.pdf')
    plt.close(fig)

fig,ax=plt.subplots(figsize=(9.2,5.3))
fig.subplots_adjust(left=.12,right=.97,bottom=.15,top=.79)
fig.suptitle('Square-TX RTL: Distance Error',x=.54,y=.96,fontsize=17)
fig.text(.54,.875,f"27 distances | Max |error| = {max(abs(errors)):.3f} mm | RMSE = {np.sqrt(np.mean(errors**2)):.3f} mm",ha='center',fontsize=12)
ax.axhline(0,color='#8897a6',linewidth=1)
ax.plot(x,errors,'o-',color='#126f9b',linewidth=1.7,markersize=5)
ax.set(xlabel='Reflector distance (cm)',ylabel='Distance error (mm)',xlim=(9,76),ylim=(-.55,.55))
ax.set_xticks(np.arange(10,76,5));ax.set_yticks(np.arange(-.4,.41,.2))
ax.grid(alpha=.18)
save(fig,'rtl_distance_error_EN')

fig,ax=plt.subplots(figsize=(9.2,5.3))
fig.subplots_adjust(left=.12,right=.97,bottom=.24,top=.77)
fig.suptitle('Square-TX RTL: FFT Spectrum at 15 cm',x=.54,y=.96,fontsize=17)
fig.text(.54,.875,f"Expected: {selected['ideal_hz']:.3f} Hz | RTL: {selected['measured_hz']:.3f} Hz | Error: {selected['error_mm']:+.3f} mm",ha='center',fontsize=11.5)
ax.plot(frequency,db,'o-',color='#126f9b',markersize=4,linewidth=1.5,label='RTL FFT power')
ax.axvline(selected['ideal_hz'],color='#8b949d',linestyle='--',linewidth=1.2,label='Expected beat frequency')
ax.scatter([frequency[peak_bin]],[0],s=72,facecolor='#c67c00',edgecolor='white',zorder=5,label=f"Peak bin {peak_bin}: {frequency[peak_bin]:.3f} Hz")
ax.set(xlabel='Beat frequency (Hz)',ylabel='Relative power (dB)',xlim=(0,600),ylim=(-80,5))
ax.set_xticks(np.arange(0,601,100));ax.set_yticks(np.arange(-80,1,20))
ax.grid(alpha=.18)
fig.legend(*ax.get_legend_handles_labels(),loc='lower center',bbox_to_anchor=(.54,.015),ncol=3,fontsize=9)
save(fig,'rtl_fft_15cm_EN')

metadata={'figure_date':'2026-10-28','rtl_run_date':'2026-10-26','new_simulation_run':False,
 'data_kind':'Archived actual RTL simulator outputs, not illustrative floating-point signal models',
 'evidence_sha256':hashlib.sha256(arg.evidence.read_bytes()).hexdigest(),
 'full_spectrum_csv_sha256':hashlib.sha256(raw).hexdigest(),'sof_sha256':checks['sof_sha256'],
 'parameters':{'chirp_start_hz':38000,'chirp_end_hz':42000,'chirp_s':.020,'amplitude':.25,
 'adc_hz':165e6/144,'fft_input_hz':fs,'cic_decimation':32,'effective_samples':672,'fft_length':nfft,'window':'Kaiser beta=4','search_hz':[25,2000],'assumed_sound_speed_m_s':343},
 'scope':'Modeled delayed fundamental RX + same-phase sine reference; production signed mixer, CIC, Kaiser FFT, power, peak and fixed-point interpolation. Frame vectors retain all ADC samples but use compressed idle clocks. Distance is inferred offline from RTL frequency using R=c*f/(2*slope).',
 'limitations':['Ideal single echo only.','No measured transducer response, analog group delay, noise, multipath or clipping.','Not proof of interference robustness or hardware accuracy.','Full real-cadence Main integration was separately verified at 50 cm; this 27-case sweep is the frame-level RTL chain.'],
 'selected_case':selected,'selected_peak_power_raw':int(power[peak_bin]),
 'max_abs_error_mm':float(max(abs(errors))),'rmse_mm':float(np.sqrt(np.mean(errors**2))),
 'figure_contract':{'claim':'The tested ideal single-echo inputs yield small distance errors in the current RTL signal-processing chain.',
 'roles':['Distance sweep shows all 27 deterministic cases.','15 cm spectrum verifies raw frequency-bin selection and interpolated frequency.'],
 'archetype':'Two separate single-panel quantitative figures','backend':'Python Matplotlib, reused from this diagnostic workflow',
 'export':'Two 9.2x5.3 inch slide/report panels, PNG/SVG/PDF, editable vector text','uncertainty':'One deterministic RTL result per distance; no measured repeats or statistical intervals.'},
 'plot_range_notes':'FFT figure shows0-600Hz; source CSV preserves all513 bins; selected peak verified over bins1-57. Lines connect discrete RTL FFT bins; no spectrum smoothing or extra zero padding.'}
(out/'provenance.json').write_text(json.dumps(metadata,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps({'all_27_cases_verified':True,'all_513_fft_powers_verified':True,'selected_case':selected,'max_abs_error_mm':metadata['max_abs_error_mm']},indent=2))
