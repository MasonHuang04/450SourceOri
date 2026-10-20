from pathlib import Path
import subprocess,shutil,hashlib,json,sys
import numpy as np
from fft_reference import fixed_reference
A=Path(__file__).resolve().parent;S=A.parents[1]/'SourceCode';O=A/'results/full_board';O.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,str(A.parent))
from source_units import SourceTree
tree=SourceTree(S,O)
R=S
for p in list((S/'ROM').glob('*.mem'))+list((S/'ROM').glob('*.mif')):shutil.copy2(p,O/p.name)
files=[tree.file(n) for n in ['fft_tdp_store.sv','kaiser4_rfft.sv','fft_power_peak.sv']]+[tree.file(n) for n in ['ScopeCic128.sv','ScopeAdc27m5.sv','ScopeFrameRam.sv','ScopeUartReport.sv','ScopeRxFft.sv','RxFftLowFreq50to100Hz.sv']]+[A/'tb_fft_board.sv']
(O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files+[S/'FftSettings.svh'])},indent=2))
do=O/'run.do';do.write_text('onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\nvlog -sv +define+FFT_USE_INTEL_RAM {+incdir+'+S.as_posix()+'} '+' '.join('{'+p.as_posix()+'}' for p in files)+'\nvsim -t 1ps -L altera_mf work.tb_rx_fft_board\nrun -all\nquit -code 0 -force\n')
with (O/'simulation.log').open('w') as log:
 p=subprocess.Popen(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do',str(do)],cwd=O,stdout=log,stderr=subprocess.STDOUT)
 (O/'status.json').write_text(json.dumps(dict(stage='running',pid=p.pid)))
 code=p.wait(timeout=1200)
text=(O/'simulation.log').read_text();assert code==0 and 'PASS FULL LOWFREQ TOP:' in text,text[-4000:]
cfg=json.loads((A/'settings.json').read_text());x=np.genfromtxt(O/'capture.csv',delimiter=',',names=True,dtype=np.int64)['code']
sp=np.genfromtxt(O/'spectrum.csv',delimiter=',',names=True,dtype=np.int64);m=np.genfromtxt(O/'metadata.csv',delimiter=',',names=True,dtype=np.int64)
assert len(x)==2048 and len(sp)==1025 and int(m['span'])==6288384 and int(m['flags'])==0
dc=int(abs(x.sum())//len(x))*(1 if x.sum()>=0 else -1);assert dc==int(m['dc_mean'])
w=np.floor(np.kaiser(2048,4)*(1<<17)+.5).astype(np.int64);c=np.floor(np.cos(np.arange(513)*2*np.pi/2048)*(1<<17)+.5).astype(np.int64)
re,im,overflow=fixed_reference(x-dc,w,c,11)
assert not overflow and np.array_equal(re,sp['real']) and np.array_equal(im,sp['imag']) and np.array_equal(re*re+im*im,sp['power'])
df=(165e6/144/128)/2048;lo=max(1,int(np.floor(cfg['search_min_hz']/df))-1);hi=int(np.ceil(cfg['search_max_hz']/df))+2
k=int(m['bin']);assert k==lo+int(np.argmax(sp['power'][lo:hi+1])) and abs(k*df-cfg['input_hz'])<=cfg['maximum_error_hz']
lines=[l for l in (O/'uart.txt').read_text().splitlines() if l];assert len(lines)==1 and len(lines[0])==62 and lines[0].startswith('L1,')
ck=0
for ch in lines[0][:60].encode():ck^=ch
assert ck==int(lines[0][60:],16)
fields=[int(v,16) for v in lines[0].split(',')[1:9]]
assert fields[1]==2048 and fields[2]==k and fields[3]==int(m['power']) and fields[6]==0 and fields[7]==6288384
checks=dict(pass_all=True,input_hz=cfg['input_hz'],peak_bin=k,peak_hz=k*df,error_hz=k*df-cfg['input_hz'],samples=2048,span=6288384,scope='Complete board digital top including ADC SPI model; independent FFT, power, frequency and UART verification.')
(O/'checks.json').write_text(json.dumps(checks,indent=2));(O/'status.json').write_text('{"stage":"passed"}');print(json.dumps(checks,indent=2))
