from pathlib import Path
import numpy as np
import sys,subprocess,shutil,json,hashlib
A=Path(__file__).resolve().parent;R=A.parents[1];S=R/'SourceCode';O=A/'results/main/fft';O.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,str(A.parent))
from source_units import SourceTree
tree=SourceTree(S,O)
cfg=json.loads((A/'main_settings.json').read_text())
fs=165e6/144;low=fs/32;nfft=int(cfg['fft_length']);logn=nfft.bit_length()-1;nv=int(cfg['fft_valid_samples'])
df=low/nfft;lo=int(np.ceil(cfg['search_min_hz']/df));hi=int(np.floor(cfg['search_max_hz']/df));raw_words=int(fs*cfg['rx_capture_ms']/1000)
dw=int(max(np.diff(np.floor(np.kaiser(nv,4)*2**17+.5).astype(np.int64)[:nv//2],prepend=11597))).bit_length()
defines=f'+define+MF_LOGN={logn} +define+MF_VALID={nv} +define+MF_DW={dw} +define+MF_MIN={lo} +define+MF_MAX={hi} +define+MF_RAW={raw_words} '
if '--interp' in sys.argv:
 import math
 O=A/'results/main/interpolation';O.mkdir(parents=True,exist_ok=True);tree=SourceTree(S,O)
 t=np.arange(nv)/low;w=np.kaiser(nv,4)
 vectors=[];reference=[]
 def add(l,c,r,k=lo+2,enable=1,mode=0,status=None,hz=None,kind='arithmetic'):
  if status is None:status=3 if min(l,c,r)==0 else 4 if c<l or c<r else 5 if l==c==r else 0
  if status==0:
   v=np.log([float(l),float(c),float(r)]);d=float(np.clip(.5*(v[0]-v[2])/(v[0]-2*v[1]+v[2]),-.5,.5))
  else:d=0.
  index=len(vectors);vectors.append(f'{index} {int(l)} {int(c)} {int(r)} {k} {enable} {mode}\n')
  reference.append(dict(id=index,delta=d,status=status,bin=k,input_hz=hz,kind=kind))
 for args in [(1,2**40,1),(1,2**40,2**39),(2**39,2**40,1),(64,256,256),(256,256,64)]:add(*args,k=lo)
 add(0,100,40,status=3);add(100,100,100,k=lo,status=5)
 add(200,100,40,k=lo,status=4);add(40,100,60,mode=1,status=2)
 add(40,100,60,mode=2,status=2);add(40,100,60,enable=0,status=1)
 add(2**40-3,2**40-2,2**40-3,k=lo,status=5)
 rng=np.random.default_rng(45020261020)
 for _ in range(300):
  c=int(2**rng.uniform(10,40));add(max(1,int(c*rng.uniform(.001,.9))),c,max(1,int(c*rng.uniform(.001,.9))))
 for hz in np.linspace(25,500,191):
  for phase in [0,.7,1.9,3.1]:
   x=np.rint(7000*np.sin(2*np.pi*hz*t+phase));x-=np.trunc(x.mean())
   y=np.fft.rfft(x*w,nfft)/nfft*8;re=np.rint(y.real).astype(np.int64);im=np.rint(y.imag).astype(np.int64);pw=re*re+im*im
   k=lo+int(np.argmax(pw[lo:hi+1]));add(*pw[k-1:k+2],k=k,hz=float(hz),kind='single_tone_numpy_spectrum')
 for hz in [25,50,99.6,100,250,500]:
  for trial in range(10):
   x=7000*np.sin(2*np.pi*hz*t+rng.uniform(0,2*np.pi))+rng.normal(0,7000/np.sqrt(2)*10**(-25/20),len(t));x=np.rint(x);x-=np.trunc(x.mean())
   y=np.fft.rfft(x*w,nfft)/nfft*8;re=np.rint(y.real).astype(np.int64);im=np.rint(y.imag).astype(np.int64);pw=re*re+im*im;k=lo+int(np.argmax(pw[lo:hi+1]))
   add(*pw[k-1:k+2],k=k,hz=float(hz),kind='single_tone_25dB_numpy_spectrum')
 (O/'vectors.txt').write_text(''.join(vectors));(O/'reference.json').write_text(json.dumps(reference,indent=2))
 files=[tree.file('main_peak_interpolator.sv'),A/'tb_fft_plot.sv']
 (O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files)},indent=2))
 (O/'run.do').write_text('onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\nvlog -sv +define+INTERP_TEST '+defines+' '.join('{'+p.as_posix()+'}' for p in files)+'\nvsim work.tb_interpolation\nrun -all\nquit -code 0 -force\n')
 with (O/'simulation.log').open('w') as log:subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=300)
 log=(O/'simulation.log').read_text();assert 'PASS FPGA INTERPOLATION' in log and '** Error' not in log and '** Fatal' not in log,log[-3000:]
 rows=np.genfromtxt(O/'interpolated.csv',delimiter=',',names=True,dtype=np.int64);assert len(rows)==len(reference)
 output=[];fixed_errors=[]
 for row,ref in zip(rows,reference):
  assert int(row['id'])==ref['id'] and int(row['status'])==ref['status'],(row,ref)
  delta=int(row['delta_q16'])/65536;error=abs(delta-ref['delta']);fixed_errors.append(error);assert error<.00015,(row,ref,error)
  if ref['status']!=0:assert int(row['delta_q16'])==0
  if ref['input_hz'] is not None:
   coarse=ref['bin']*df;fine=(ref['bin']+delta)*df;output.append(dict(input_hz=ref['input_hz'],coarse_hz=coarse,fine_hz=fine,coarse_error_hz=coarse-ref['input_hz'],fine_error_hz=fine-ref['input_hz'],kind=ref['kind']))
 checks=dict(pass_all=True,vectors=len(rows),maximum_latency_cycles=int(max(rows['latency'])),maximum_fixed_point_error_bins=max(fixed_errors),bin_hz=df,cases=output,
  observation_ms=nv/low*1000,effective_samples=nv,nfft=nfft,low_frequency_accuracy_guaranteed=False,scope='Actual RTL interpolator. Frequency sweeps use NumPy-derived quantized spectra; separate Main FFT regression tests the complete RTL CIC/window/FFT/power/interpolation chain.')
 for kind in ['single_tone_numpy_spectrum','single_tone_25dB_numpy_spectrum']:
  group=[r for r in output if r['kind']==kind];co=np.array([r['coarse_error_hz'] for r in group]);fi=np.array([r['fine_error_hz'] for r in group])
  checks[kind]=dict(cases=len(group),coarse_max_error_hz=float(max(abs(co))),fine_max_error_hz=float(max(abs(fi))),coarse_rmse_hz=float(np.sqrt(np.mean(co**2))),fine_rmse_hz=float(np.sqrt(np.mean(fi**2))))
 (O/'checks.json').write_text(json.dumps(checks,indent=2));print(json.dumps({k:v for k,v in checks.items() if k!='cases'},indent=2));raise SystemExit
if '--settings-only' in sys.argv:
 subprocess.run([sys.executable,str(A/'configure_main.py')],check=True);raise SystemExit
if '--tx' in sys.argv:
 subprocess.run([sys.executable,str(A/'run_main_tx.py')],check=True);raise SystemExit
for mode in ['short','system','io']:
 if '--'+mode in sys.argv:
  subprocess.run([sys.executable,str(A/'run_main_system.py'),mode],check=True);raise SystemExit
freqs=[25,100,500,250,99.6,75,25,100]
if '--analyze' not in sys.argv:
 (O/'run_profile.json').write_text(json.dumps(dict(ram_model='behavioral' if '--fast-memory' in sys.argv else 'Intel altsyncram')))
 t=np.arange(raw_words+1024)/fs
 for case,f in enumerate(freqs):
  x=7000*np.sin(2*np.pi*f*t+case*.37)+(6000 if case%2 else -5000)
  if case==3:x+=2000*np.sin(2*np.pi*700*t)
  if case==4:x+=7000*np.sin(2*np.pi*(low+250)*t)
  if case==5:x=40000*np.sin(2*np.pi*f*t)
  x=np.clip(np.trunc(x),-32768,32767).astype(np.int64);y=x.copy()
  for _ in range(3):c=np.cumsum(y);y=c.copy();y[32:]-=c[:-32]
  y=(y[31::32]+(1<<14))>>15
  np.savetxt(O/f'input_{case}.mem',x&65535,fmt='%04x');np.savetxt(O/f'expected_{case}.mem',y&65535,fmt='%04x')
 for n in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:shutil.copy2(tree.resolve(n),O/n)
 if '--fast-memory' in sys.argv:
  p=O/'main_cos_quarter.mem';vals=[int(x,2) for x in p.read_text().split()];assert max(vals)<2**18;p.write_text(''.join(f'{x:018b}\n' for x in vals))
 names=['MainFftProcessor.sv','MainPeakReport.sv','MainCicDecimator.sv','MainFrameRam.sv','kaiser4_rfft.sv','fft_tdp_store.sv','fft_power_peak.sv','main_peak_interpolator.sv'];files=[tree.file(n) for n in names]+[A/'tb_fft_plot.sv']
 (O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files)},indent=2))
 d=O/'run.do';d.write_text('onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\nvlog -sv '+('' if '--fast-memory' in sys.argv else '+define+FFT_USE_INTEL_RAM ')+'+define+MAIN_FFT_TEST '+defines+' '.join('{'+p.as_posix()+'}' for p in files)+'\nvsim -t 1ps -L altera_mf work.tb_main_fft\nrun -all\nquit -code 0 -force\n')
 with (O/'simulation.log').open('w') as log:
  p=subprocess.Popen(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do',str(d)],cwd=O,stdout=log,stderr=subprocess.STDOUT)
  (O/'status.json').write_text(json.dumps(dict(stage='running',pid=p.pid)));rc=p.wait(timeout=1200)
 if rc:print((O/'simulation.log').read_text()[-5000:]);raise SystemExit(rc)
assert '** Error' not in (O/'simulation.log').read_text() and '** Fatal' not in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-4000:]
assert 'PASS MAIN FFT PIPELINE' in (O/'simulation.log').read_text()
sys.path.insert(0,str(R/'Simulation/FFT'));from fft_reference import fixed_reference
cap=np.genfromtxt(O/'capture.csv',delimiter=',',names=True,dtype=np.int64);spec=np.genfromtxt(O/'spectrum.csv',delimiter=',',names=True,dtype=np.int64);meta=np.genfromtxt(O/'metadata.csv',delimiter=',',names=True,dtype=np.int64)
w=np.floor(np.kaiser(nv,4)*(1<<17)+.5).astype(np.int64);cos=np.floor(np.cos(np.arange(nfft//4+1)*2*np.pi/nfft)*(1<<17)+.5).astype(np.int64)
lines=[l for l in (O/'telemetry.txt').read_text().splitlines() if l];assert len(lines)==8
(O/'telemetry.txt').write_bytes(('\r\n'.join(lines)+'\r\n').encode())
results=[]
for case,line in enumerate(lines):
 assert len(line)==79 and line.startswith('M3,');ck=0
 for ch in line[:77].encode():ck^=ch
 assert ck==int(line[77:],16)
 seq,n,k,power,mn,mx,flags,span=[int(s,16) for s in line.split(',')[1:9]];m=meta[case]
 assert (seq,n,k,power,flags,span)==tuple(int(m[f]) for f in ['seq','count','bin','power','flags','span'])
 delta=int(line.split(',')[9],16);delta=delta-2**32 if delta>=2**31 else delta
 status=int(line.split(',')[10],16);assert int(line.split(',')[11],16)==nfft
 assert (delta,status)==(int(m['delta_q16']),int(m['interp_status']))
 if case>=6:assert flags&1 and n<nv and power==0 and status!=0 and delta==0;continue
 x=cap[cap['case']==case]['code'];s=spec[spec['case']==case];assert len(x)==nv and len(s)==nfft//2+1
 dc=int(abs(x.sum())//nv)*(1 if x.sum()>=0 else -1);assert int(m['mean'])==dc
 centered=np.clip(x-dc,-32768,32767);re,im,ov=fixed_reference(centered,w,cos,logn)
 assert not ov and np.array_equal(re,s['real']) and np.array_equal(im,s['imag']) and np.array_equal(re*re+im*im,s['power'])
 assert k==lo+int(np.argmax(s['power'][lo:hi+1])) and power==s['power'][k]
 err=float(np.max(abs((re+1j*im)/8-np.fft.rfft(centered*np.kaiser(nv,4),nfft)/nfft)));assert err<2
 if case<5:assert flags==0
 else:assert flags&4
 if flags==0:
  neighbors=s['power'][k-1:k+2];want=3 if min(neighbors)==0 else 4 if neighbors[1]<max(neighbors) else 5 if neighbors[0]==neighbors[1]==neighbors[2] else 0
  assert status==want
  if status==0:
   lp=np.log(neighbors.astype(float));d=float(np.clip(.5*(lp[0]-lp[2])/(lp[0]-2*lp[1]+lp[2]),-.5,.5));assert abs(delta/65536-d)<.0001
  else:assert delta==0
 else:assert status!=0 and delta==0
 results.append(dict(process_cycles=int(m['process_cycles']),process_ms=int(m['process_cycles'])/50000,interpolated_hz=(k+delta/65536)*df,interpolated_error_hz=(k+delta/65536)*df-freqs[case],delta_q16=delta,interp_status=status,case=case,input_hz=freqs[case],peak_hz=k*df,peak_bin=k,error_hz=k*df-freqs[case],flags=flags,max_fft_error=err))
out=dict(pass_all=True,profile=cfg,effective_samples=nv,nfft=nfft,observation_ms=nv/low*1000,bin_hz=df,low_frequency_accuracy_guaranteed=False,ram_model=json.loads((O/'run_profile.json').read_text())['ram_model'],cases=results,short_window_rejected=True,empty_window_rejected=True,consecutive_frames=True,telemetry_checksum=True,scope='Production main FFT branch and byte-handshake report; complete input words, compressed idle clocks; not full main top.')
(O/'checks.json').write_text(json.dumps(out,indent=2));(O/'status.json').write_text('{"stage":"passed"}');print(json.dumps(out,indent=2))
