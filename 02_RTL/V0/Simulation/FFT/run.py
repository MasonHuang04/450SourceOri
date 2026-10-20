from pathlib import Path
import numpy as np
import subprocess,json,hashlib,shutil,sys,time
A=Path(__file__).resolve().parent;S=A.parents[1]/'SourceCode';O=A/'results/run';O.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,str(A.parent))
from source_units import SourceTree
tree=SourceTree(S,O)
R=S
if '--analyze' in sys.argv:sys.argv.append('--analyze-only')
fs=165e6/144;lowfs=fs/128;df=lowfs/2048
cfg=json.loads((A/'settings.json').read_text())
assert cfg['profile']=='CIC128_FFT2048'
assert 50<=cfg['search_min_hz']<cfg['search_max_hz']<=100
assert 50<=cfg['input_hz']<=100
assert len(cfg['additional_test_frequencies_hz'])==8 and all(cfg['search_min_hz']<=f<=cfg['search_max_hz'] for f in cfg['additional_test_frequencies_hz'])
assert cfg['search_min_hz']<=cfg['input_hz']<=cfg['search_max_hz']
lo=max(1,int(np.floor(cfg['search_min_hz']/df))-1);hi=int(np.ceil(cfg['search_max_hz']/df))+2
header='// Generated from Simulation/FFT/settings.json.\n`define FFT_SEARCH_MIN_BIN 15\'d%d\n`define FFT_SEARCH_MAX_BIN 15\'d%d\n`define FFT_TEST_HZ %.9f\n'%(lo,hi,cfg['input_hz'])
if '--analyze-only' not in sys.argv:(S/'FftSettings.svh').write_text(header)
if '--settings-only' in sys.argv:print('Updated shared FFT search settings');raise SystemExit
if '--board' in sys.argv:
 subprocess.run([sys.executable,str(A/'run_board.py')],check=True);raise SystemExit
freqs=[cfg['input_hz']]+cfg['additional_test_frequencies_hz']+[75]
if '--analyze-only' not in sys.argv:
 (O/'settings_used.json').write_text(json.dumps(cfg,indent=2))
 rng=np.random.default_rng(45100);t=np.arange(500000)/fs
 for case,f in enumerate(freqs):
  x=7000*np.sin(2*np.pi*f*t+case*.47)+(6000 if case%2 else -5000)
  if case==7:x+=rng.normal(0,50,len(t))+1000*np.sin(2*np.pi*300*t)
  if case==8:x+=7000*np.sin(2*np.pi*(lowfs+85)*t) # alias rejection at low-band image
  if case==9:x=40000*np.sin(2*np.pi*f*t)
  x=np.clip(np.trunc(x),-32768,32767).astype(np.int64)
  z=x.copy()
  for _ in range(3):
   cs=np.cumsum(z);z=cs.copy();z[128:]-=cs[:-128]
  expected=((z[127::128]+(1<<20))>>21)
  np.savetxt(O/f'input_{case}.mem',x&65535,fmt='%04x')
  np.savetxt(O/f'expected_{case}.mem',expected&65535,fmt='%04x')
 for p in list((S/'ROM').glob('*.mif'))+list((S/'ROM').glob('*.mem')):shutil.copy2(p,O/p.name)
 files=[tree.file(n) for n in ['fft_tdp_store.sv','kaiser4_rfft.sv','fft_power_peak.sv']]+[tree.file(n) for n in ['ScopeCic128.sv','ScopeFrameRam.sv','ScopeUartReport.sv','ScopeRxFft.sv']]+[A/'tb_fft_plot.sv']
 (O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files+[S/'FftSettings.svh']+list((S/'ROM').glob('*.mif'))+list((S/'ROM').glob('*.mem')))},indent=2))
 do=O/'run.do';do.write_text('onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\nvlog -sv +define+FFT_USE_INTEL_RAM {+incdir+'+S.as_posix()+'} '+' '.join('{'+p.as_posix()+'}' for p in files)+'\nvsim -t 1ps -L altera_mf work.tb_lowfreq\nrun -all\nquit -code 0 -force\n')
 if '--prepare' in sys.argv:print('Prepared FFT simulation and shared settings');raise SystemExit
 with (O/'simulation.log').open('w') as log:
  p=subprocess.Popen(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do',str(do)],cwd=O,stdout=log,stderr=subprocess.STDOUT)
  (O/'status.json').write_text(json.dumps(dict(stage='running',pid=p.pid,started=time.time())))
  code=p.wait(timeout=1200)
 if code:print((O/'simulation.log').read_text()[-4000:]);raise SystemExit(code)
assert 'PASS LOWFREQ:' in (O/'simulation.log').read_text()
assert json.loads((O/'settings_used.json').read_text())==cfg,'Settings changed since simulation'
from fft_reference import fixed_reference
cap=np.genfromtxt(O/'capture.csv',delimiter=',',names=True,dtype=np.int64);spec=np.genfromtxt(O/'spectrum.csv',delimiter=',',names=True,dtype=np.int64);meta=np.genfromtxt(O/'metadata.csv',delimiter=',',names=True,dtype=np.int64)
w=np.floor(np.kaiser(2048,4)*(1<<17)+.5).astype(np.int64);cos=np.floor(np.cos(np.arange(513)*2*np.pi/2048)*(1<<17)+.5).astype(np.int64)
lines=[l for l in (O/'uart.txt').read_text().splitlines() if l];assert len(lines)==11
(O/'uart.txt').write_bytes(('\r\n'.join(lines)+'\r\n').encode())
cases=[]
for case,line in enumerate(lines):
 assert len(line)==62 and line.startswith('L1,');ck=0
 for c in line[:60].encode():ck^=c
 assert ck==int(line[60:],16)
 vals=[int(s,16) for s in line.split(',')[1:9]];seq,count,k,power,vmin,vmax,flags,span=vals
 m=meta[case];assert (count,k,power,flags,span)==tuple(int(m[n]) for n in ['count','bin','power','flags','span'])
 if case==10:assert count==0 and flags&1;continue
 x=cap[cap['case']==case]['code'];s=spec[spec['case']==case];assert len(x)==2048 and len(s)==1025
 dc=int(abs(x.sum())//len(x))*(1 if x.sum()>=0 else -1);assert int(m['dc_mean'])==dc
 centered=np.clip(x-dc,-32768,32767);re,im,over=fixed_reference(centered,w,cos,11)
 assert not over and np.array_equal(re,s['real']) and np.array_equal(im,s['imag'])
 pw=re*re+im*im;assert np.array_equal(pw,s['power']);assert k==lo+int(np.argmax(pw[lo:hi+1])) and power==pw[k]
 floating=np.fft.rfft(centered*np.kaiser(2048,4))/2048;err=float(np.max(abs((re+1j*im)/8-floating)));assert err<2
 assert span==2047*128
 if case<9:assert flags==0 and abs(k*df-freqs[case])<=cfg['maximum_error_hz']
 else:assert flags&4
 cases.append(dict(case=case,input_hz=freqs[case],peak_bin=k,peak_hz=k*df,error_hz=k*df-freqs[case],power_q6=power,max_fft_error_codes=err,flags=flags))
# A denser numerical sweep (distinct from RTL) checks boundary/phase effects.
sweep=[];t=np.arange(2048)/lowfs
for f in np.arange(cfg['search_min_hz'],cfg['search_max_hz']+.001,.1):
 for ph in np.arange(8)*np.pi/4:
  x=7000*np.sin(2*np.pi*f*t+ph);x-=np.mean(x)
  y=np.fft.rfft(x*np.kaiser(2048,4));k=lo+int(np.argmax(abs(y[lo:hi+1])**2))
  sweep.append(abs(k*df-f))
assert max(sweep)<=cfg['maximum_error_hz']
checks=dict(pass_all=True,cic_exact_fir_equivalence=True,raw_clipping_detected=True,adc_timeout_pass=True,uart_pass=True,
 adc_sample_rate=fs,fft_sample_rate=lowfs,decimation=128,effective_samples=2048,nfft=2048,window_ms=2048/lowfs*1000,bin_hz=df,
 cases=cases,numerical_sweep_cases=len(sweep),numerical_sweep_max_error_hz=max(sweep),
 scope='CIC/CDC/window/FFT/power/peak/UART RTL with all raw ADC samples; idle ADC clocks compressed in this test. Optional --board checks physical cadence. No analog front-end model.')
(O/'checks.json').write_text(json.dumps(checks,indent=2));(O/'status.json').write_text('{"stage":"passed"}');print(json.dumps(checks,indent=2))

import matplotlib
matplotlib.use('Agg');import matplotlib.pyplot as plt
case=0;x=cap[cap['case']==case]['code'];s=spec[spec['case']==case]
fig,ax=plt.subplots(1,2,figsize=(11,4),layout='constrained')
ax[0].plot(np.arange(len(x))/lowfs*1000,x);ax[0].set(xlabel='Time (ms)',ylabel='Filtered ADC code',title='RTL input frame: %.2f Hz'%freqs[0]);ax[0].grid(alpha=.2)
ff=s['bin']*df;db=10*np.log10(np.maximum(s['power'],1)/max(s['power']))
ax[1].plot(ff,db);ax[1].scatter([cases[0]['peak_hz']],[db[cases[0]['peak_bin']]],color='red');ax[1].set(xlim=(0,180),ylim=(-80,3),xlabel='Frequency (Hz)',ylabel='Relative power (dB)',title='Kaiser4 / FFT / peak');ax[1].grid(alpha=.2)
fig.savefig(A/'results/fft.png',dpi=150);plt.close(fig)
(A/'results/checks.json').write_text(json.dumps(checks,indent=2))
