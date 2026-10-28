"""Test current digital-mixer RTL with raw-RF and already-mixed ADC inputs."""
from pathlib import Path
import json,sys,shutil,hashlib,subprocess
import numpy as np

R=Path('E:/Document_HH/Course/26FA/450code/15_UsMimoTestBench_multiFPGA')
A=R/'02_RTL/V0/Simulation/FFT';S=R/'02_RTL/V0/SourceCode';O=Path(__file__).parent/'run';O.mkdir(exist_ok=True)
sys.path.insert(0,str(A.parent));sys.path.insert(0,str(A))
from source_units import SourceTree
from fft_reference import fixed_reference
tree=SourceTree(S,O)
names=['MainDigitalMixer.sv','MainFftProcessor.sv','MainCicDecimator.sv','MainFrameRam.sv','kaiser4_rfft.sv','fft_tdp_store.sv','fft_power_peak.sv','main_peak_interpolator.sv']
for name in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:shutil.copy2(tree.resolve(name),O/name)
fs=165e6/144;lo=fs/32;nv=672;nfft=1024;distance_cm=17.5;t=.001+np.arange(21770)/fs;tau=2*(distance_cm/100)/343
phase=lambda u:2*np.pi*(38000*u+100000*u*u)
reference=(np.trunc(8192+8191*.25*np.cos(phase(t))).astype(np.int64)-8192)*4
rx=20000*np.cos(phase(t-tau))*(t>=tau)
q=np.where(np.cos(phase(t))>=0,1.,-1.)
inputs=[('Raw RX, correct bypass path',rx),
        ('Already low-pass IF, wrong input',10000*np.cos(phase(t)-phase(t-tau))),
        ('Balanced square analog product, no feedthrough',.5*q*rx),
        ('Analog product + 5% RX feedthrough',(.5*q+.05)*rx),
        ('Same feedthrough model, 5x weaker RX',(.5*q+.05)*(rx/5)),
        ('Unipolar square analog product',.25*(1+q)*rx)]
for i,(label,y) in enumerate(inputs):
    adc=np.trunc(y).astype(np.int64);assert adc.min()>-32768 and adc.max()<32767
    product=np.clip((adc*reference+16384)>>15,-32768,32767)
    for name,arr in [('rx',adc),('ref',reference),('product',product)]:np.savetxt(O/f'{name}_{i}.mem',arr&65535,fmt='%04x')
tb=(A/'tb_digital_mixer.sv').read_text(encoding='utf-8')
tb=tb[tb.index('module tb_mixer_frames;'):tb.index('module tb_adc_reference_pair;')]
tb='`timescale 1ns/1ps\n'+tb
tb=tb.replace('LAST_CASE=26','LAST_CASE=5')
tb=tb.replace('flags!=0||status!=0||mc','((flags!=0)&&(flags!=16))||((flags==0)&&(status!=0))||((flags==16)&&(status!=1))||mc')
tb=tb.replace('PASS DIGITAL MIXER FRAMES:','PASS ROUTE AUDIT:')
(O/'tb_route.sv').write_text(tb,encoding='utf-8')
files=[tree.file(n) for n in names]+[O/'tb_route.sv']
do='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
do+='vlog -sv +define+FFT_USE_INTEL_RAM '+' '.join('{'+p.as_posix()+'}' for p in files)+'\n'
do+='vsim -t 1ps -L altera_mf work.tb_mixer_frames\nrun -all\nquit -code 0 -force\n'
(O/'run.do').write_text(do,encoding='utf-8')
source_hash={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files)}
(O/'source_sha256.json').write_text(json.dumps(source_hash,indent=2))
with (O/'simulation.log').open('w') as log:
    subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=log,stderr=subprocess.STDOUT,check=True,timeout=600)
log=(O/'simulation.log').read_text(errors='replace');assert 'PASS ROUTE AUDIT:' in log and '** Error' not in log and '** Fatal' not in log
cap=np.genfromtxt(O/'capture.csv',delimiter=',',names=True,dtype=np.int64)
sp=np.genfromtxt(O/'spectrum.csv',delimiter=',',names=True,dtype=np.int64)
meta=np.atleast_1d(np.genfromtxt(O/'metadata.csv',delimiter=',',names=True,dtype=np.int64))
w=np.floor(np.kaiser(nv,4)*2**17+.5).astype(np.int64);cos=np.floor(np.cos(np.arange(257)*2*np.pi/nfft)*2**17+.5).astype(np.int64)
results=[]
for row in meta:
    case=int(row['case']);prod=np.loadtxt(O/f'product_{case}.mem',converters=lambda z:int(z,16),dtype=np.int64)
    y=np.where(prod>=32768,prod-65536,prod)
    for _ in range(3):cum=np.cumsum(y);y=cum.copy();y[32:]-=cum[:-32]
    expected=((y[31::32]+16384)>>15)[2:674];actual=cap[cap['case']==case]['code'];assert np.array_equal(actual,expected)
    mean=int(abs(actual.sum())//nv)*(1 if actual.sum()>=0 else -1)
    re,im,ov=fixed_reference(np.clip(actual-mean,-32768,32767),w,cos,10);pw=re*re+im*im;ss=sp[sp['case']==case]
    assert not ov and np.array_equal(ss['real'],re) and np.array_equal(ss['imag'],im) and np.array_equal(ss['power'],pw)
    k=1+int(np.argmax(pw[1:58]));assert row['bin']==k and row['power']==pw[k]
    found=bool(pw[k]>=6400);assert int(row['flags'])==(0 if found else 16)
    hz=(k+int(row['delta'])/65536)*lo/nfft if found else None
    if found:
        logs=np.log(pw[k-1:k+2].astype(float));df=.5*(logs[0]-logs[2])/(logs[0]-2*logs[1]+logs[2])
        assert abs(int(row['delta'])/65536-np.clip(df,-.5,.5))<.0001
    results.append({'case':case,'model':inputs[case][0],'distance_cm':distance_cm,'raw_bin':k,'raw_bin_hz':k*lo/nfft,
        'power_raw':int(pw[k]),'power_display':float(pw[k]/64),'status':'OK' if found else 'NO_STRONG_PEAK',
        'frequency_hz':hz,'inferred_distance_mm':hz*343/400000*1000 if found else None,'flags':int(row['flags'])})
checks={'pass':True,'hardware_measured':False,'production_rtl_changed':False,'actual_rtl_multiply_cic_fft_power_interpolator':True,
 'all_integer_products_verified':21770*len(inputs),'all_cic_capture_and_fft_powers_exact':True,
 'scope':'Frame-level current RTL with complete ADC input words and compressed idle cycles; inputs model alternate routing. Analog AD835 nonidealities are hypothetical, not a device-level model or physical measurement.',
 'hypothesis_parameters':'Nominal 17.5cm; Rx=20000code peak. Analog balanced multiplier reference=+/-0.5, feedthrough coefficient0.05; weakcase Rx/5; unipolar reference=0 or0.5. These are illustrative values, not measured board parameters.',
 'results':results}
(Path(__file__).parent/'checks.json').write_text(json.dumps(checks,indent=2),encoding='utf-8')
print(json.dumps(checks,indent=2))
