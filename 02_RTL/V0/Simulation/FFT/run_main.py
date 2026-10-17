from pathlib import Path
import numpy as np
import sys,subprocess,shutil,json,hashlib
A=Path(__file__).resolve().parent;R=A.parents[1];S=R/'SourceCode';O=A/'results/main/fft';O.mkdir(parents=True,exist_ok=True)
if '--settings-only' in sys.argv:
 subprocess.run([sys.executable,str(A/'configure_main.py')],check=True);raise SystemExit
cfg=json.loads((A/'main_settings.json').read_text())
assert cfg==dict(rx_capture_ms=250,rx_raw_downsample=3,fft_valid_samples=8192,search_min_hz=25,search_max_hz=500),'This regression covers the default main profile; update test inputs and expected values for custom settings.'
if '--tx' in sys.argv:
 subprocess.run([sys.executable,str(A/'run_main_tx.py')],check=True);raise SystemExit
for mode in ['short','system','io']:
 if '--'+mode in sys.argv:
  subprocess.run([sys.executable,str(A/'run_main_system.py'),mode],check=True);raise SystemExit
fs=165e6/144;low=fs/32;df=low/8192;freqs=[25,100,500,250,99.6,75,25,100]
if '--analyze' not in sys.argv:
 (O/'run_profile.json').write_text(json.dumps(dict(ram_model='behavioral' if '--fast-memory' in sys.argv else 'Intel altsyncram')))
 t=np.arange(300000)/fs
 for case,f in enumerate(freqs):
  x=7000*np.sin(2*np.pi*f*t+case*.37)+(6000 if case%2 else -5000)
  if case==3:x+=2000*np.sin(2*np.pi*700*t)
  if case==4:x+=7000*np.sin(2*np.pi*(low+250)*t)
  if case==5:x=40000*np.sin(2*np.pi*f*t)
  x=np.clip(np.trunc(x),-32768,32767).astype(np.int64);y=x.copy()
  for _ in range(3):c=np.cumsum(y);y=c.copy();y[32:]-=c[:-32]
  y=(y[31::32]+(1<<14))>>15
  np.savetxt(O/f'input_{case}.mem',x&65535,fmt='%04x');np.savetxt(O/f'expected_{case}.mem',y&65535,fmt='%04x')
 for n in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:shutil.copy2(S/n,O/n)
 if '--fast-memory' in sys.argv:
  p=O/'main_cos_quarter.mem';vals=[int(x,2) for x in p.read_text().split()];assert max(vals)<2**18;p.write_text(''.join(f'{x:018b}\n' for x in vals))
 names=['MainFftProcessor.sv','MainPeakReport.sv','MainCicDecimator.sv','MainFrameRam.sv','kaiser4_rfft.sv','fft_tdp_store.sv','fft_power_peak.sv'];files=[S/n for n in names]+[A/'tb_fft_plot.sv']
 (O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in files},indent=2))
 d=O/'run.do';d.write_text('onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\nvlog -sv '+('' if '--fast-memory' in sys.argv else '+define+FFT_USE_INTEL_RAM ')+'+define+MAIN_FFT_TEST '+' '.join('{'+p.as_posix()+'}' for p in files)+'\nvsim -t 1ps -L altera_mf work.tb_main_fft\nrun -all\nquit -code 0 -force\n')
 with (O/'simulation.log').open('w') as log:
  p=subprocess.Popen(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do',str(d)],cwd=O,stdout=log,stderr=subprocess.STDOUT)
  (O/'status.json').write_text(json.dumps(dict(stage='running',pid=p.pid)));rc=p.wait(timeout=1200)
 if rc:print((O/'simulation.log').read_text()[-5000:]);raise SystemExit(rc)
assert '** Error' not in (O/'simulation.log').read_text() and '** Fatal' not in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-4000:]
assert 'PASS MAIN FFT PIPELINE' in (O/'simulation.log').read_text()
sys.path.insert(0,str(R/'Simulation/FFT'));from fft_reference import fixed_reference
cap=np.genfromtxt(O/'capture.csv',delimiter=',',names=True,dtype=np.int64);spec=np.genfromtxt(O/'spectrum.csv',delimiter=',',names=True,dtype=np.int64);meta=np.genfromtxt(O/'metadata.csv',delimiter=',',names=True,dtype=np.int64)
w=np.floor(np.kaiser(8192,4)*(1<<17)+.5).astype(np.int64);cos=np.floor(np.cos(np.arange(2049)*2*np.pi/8192)*(1<<17)+.5).astype(np.int64)
lines=[l for l in (O/'telemetry.txt').read_text().splitlines() if l];assert len(lines)==8
(O/'telemetry.txt').write_bytes(('\r\n'.join(lines)+'\r\n').encode())
results=[]
for case,line in enumerate(lines):
 assert len(line)==62 and line.startswith('M1,');ck=0
 for ch in line[:60].encode():ck^=ch
 assert ck==int(line[60:],16)
 seq,n,k,power,mn,mx,flags,span=[int(s,16) for s in line.split(',')[1:9]];m=meta[case]
 assert (seq,n,k,power,flags,span)==tuple(int(m[f]) for f in ['seq','count','bin','power','flags','span'])
 if case>=6:assert flags&1 and n<8192 and power==0;continue
 x=cap[cap['case']==case]['code'];s=spec[spec['case']==case];assert len(x)==8192 and len(s)==4097
 dc=int(abs(x.sum())//8192)*(1 if x.sum()>=0 else -1);assert int(m['mean'])==dc
 centered=np.clip(x-dc,-32768,32767);re,im,ov=fixed_reference(centered,w,cos,13)
 assert not ov and np.array_equal(re,s['real']) and np.array_equal(im,s['imag']) and np.array_equal(re*re+im*im,s['power'])
 assert k==6+int(np.argmax(s['power'][6:115])) and power==s['power'][k]
 err=float(np.max(abs((re+1j*im)/8-np.fft.rfft(centered*np.kaiser(8192,4))/8192)));assert err<2
 if case<5:assert flags==0 and abs(k*df-freqs[case])<3
 else:assert flags&4
 results.append(dict(case=case,input_hz=freqs[case],peak_hz=k*df,peak_bin=k,error_hz=k*df-freqs[case],flags=flags,max_fft_error=err))
out=dict(pass_all=True,ram_model=json.loads((O/'run_profile.json').read_text())['ram_model'],cases=results,short_window_rejected=True,empty_window_rejected=True,consecutive_frames=True,telemetry_checksum=True,scope='Production main FFT branch and byte-handshake report; complete input words, compressed idle clocks; not full main top.')
(O/'checks.json').write_text(json.dumps(out,indent=2));(O/'status.json').write_text('{"stage":"passed"}');print(json.dumps(out,indent=2))
