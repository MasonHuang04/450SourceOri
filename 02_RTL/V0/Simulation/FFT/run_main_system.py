from pathlib import Path
import sys,subprocess,shutil,hashlib,json
A=Path(__file__).resolve().parent;V=A.parents[1];S=V/'SourceCode'
mode=sys.argv[1] if len(sys.argv)>1 else 'system';assert mode in ['short','system','io']
O=A/'results/main'/mode;O.mkdir(parents=True,exist_ok=True)
sys.path.insert(0,str(A.parent))
from source_units import SourceTree
tree=SourceTree(S,O)
macro=dict(short='MAIN_SHORT_TOP',system='MAIN_SYSTEM_TOP',io='MAIN_IO_TEST')[mode]
d='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
sv=['MainRangeCalculator.sv','MainPeakReport.sv'];vhd=['SysLib.vhd']
if mode=='io':sv+=['MainAdcBridge.sv','MainWaveFifo.sv'];vhd+=['UARTController.vhd','RxDepack.vhd','MainTxPack.vhd'];top='tb_main_io'
else:
 sv+=['MainReferenceDelay.sv','MainDigitalMixer.sv','MainTempSnapshot.sv','MainCicDecimator.sv','MainFrameRam.sv','MainFftProcessor.sv','MainWaveFifo.sv','fft_tdp_store.sv','kaiser4_rfft.sv','fft_power_peak.sv','main_peak_interpolator.sv']
 if mode=='short':sv+=['ScopeAdc27m5.sv','MainAdcBridge.sv']
 vhd+=['DSPLib.vhd','MainSettings.vhd','RxDepack.vhd','MainTxPack.vhd','MainRxController.vhd']
 t=tree.read('MainTxController.vhd');t=t[:t.lower().index('architecture')]+'''architecture model of MainTxController is
begin
 oDA_PD<='0';oDA_CLK<=iClk;oDA_D<=(others=>'0');oSineReference<=x"7FFF";oTX_MUX_EN<='1';oTX_MUX_A<=iMuxSel;
 process begin oBusy<='0';wait until rising_edge(iStart);
  assert iFc=x"471c4000" and iBW=x"457a0000" and iTc=x"3ca3d70a" and iA=x"3e800000"
   and iMuxSel="000" and iSQWaveEn='1' and iDownSampleRate=0 and iDataResolution=14
   report "Main TX defaults must match 38-42 kHz / 20 ms Chirp experiment" severity failure;
  report "PASS MAIN TOP SQUARE TX DEFAULTS: 40kHz center / 4kHz BW / 20ms / amplitude 0.25 / filter bypass";
  oBusy<='1';wait for 20 us;oBusy<='0';wait until iStart='0';end process;
end architecture;
''';(O/'TxModel.vhd').write_text(t)
 t=tree.read('MainTMP117Controller.vhd');t=t[:t.lower().index('architecture')]+'''architecture model of MainTMP117Controller is
begin oTempData<=x"0C80";oDataValid<='1';oUpdated<=not iRst;oTmp_SCL<='1';ioTmp_SDA<='Z';end architecture;
''';(O/'TempModel.vhd').write_text(t)
 top='tb_main_top'
for n in vhd:
 p=tree.file(n);d+='vcom -2008 {'+p.as_posix()+'}\n'
if mode!='io':
 t=(S/'UsMimoTestBench.vhd').read_text()
 if mode=='system':t=t.replace('SAMPLE_TICKS:integer:=4608','SAMPLE_TICKS:integer:=32')
 (O/'MainTest.vhd').write_text(t)
 for n in ['TxModel.vhd','TempModel.vhd','MainTest.vhd']:d+='vcom -2008 {'+(O/n).as_posix()+'}\n'
 for n in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:shutil.copy2(tree.resolve(n),O/n)
files=[tree.file(n) for n in sv]+[A/'tb_fft_board.sv']
if mode=='system':
 p=O/'MainWaveFifo_model.sv';p.write_text(tree.read('MainWaveFifo.sv').replace('`ifdef FFT_USE_INTEL_RAM','`ifdef MAIN_RAW_MEMORY_INTEL_TEST'));files=[p if f==tree.file('MainWaveFifo.sv') else f for f in files]
(O/'memory_models.json').write_text(json.dumps(dict(raw_ram='behavioral' if mode in ['system','io'] else 'Intel altsyncram',fft_ram='Intel altsyncram' if mode=='system' else 'not exercised numerically')))
d+='vlog -sv '+('' if mode=='io' else '+define+FFT_USE_INTEL_RAM ')+'+define+'+macro+' '+' '.join('{'+p.as_posix()+'}' for p in files)+'\n'
d+='vsim -t 1ps -L altera_mf work.'+top+'\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0 -force\n'
if mode=='short':
 d=d.replace('run -all','force -deposit /tb_main_top/dut/uRx/cTick 16#'+format(2**28-300000,'07x')+' 0\nrun -all')
(O/'run.do').write_text(d)
(O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files+[S/'UsMimoTestBench.vhd',S/'MainSettings.vhd'])},indent=2))
with (O/'simulation.log').open('w') as f:
 subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=1200)
marker=dict(short='PASS MAIN SHORT TOP',system='PASS MAIN LONG FRAME',io='PASS MAIN IO')[mode]
assert '** Error' not in (O/'simulation.log').read_text() and '** Fatal' not in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-4000:]
assert marker in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-3000:]
if mode!='io':
 import struct,numpy as np
 b=bytes(int(s,16) for s in (O/'stream.hex').read_text().split());n=struct.unpack_from('<I',b,8)[0];assert len(b)==n*2+174
 raw=np.genfromtxt(O/'raw_words.csv',delimiter=',',names=True,dtype=np.int64)['code'];assert np.array_equal(raw,np.frombuffer(b[32:32+2*n],dtype='<u2'))
 tail=bytearray(b[:32]);tail[6]=tail[25]=165;assert b[32+2*n:64+2*n]==bytes(tail)
 line=b[-110:];ck=0
 for c in line[:106]:ck^=c
 assert ck==int(line[106:108],16)
 assert line.startswith(b'M4,')
 fields=line.decode().strip().split(',');assert int(fields[11],16)==1024;offset=int(fields[9],16);offset=offset-2**32 if offset>=2**31 else offset;istatus=int(fields[10],16)
 if mode=='short':assert offset==0 and istatus==1 and int(fields[16],16)==1 and int(fields[15],16)==0
 else:
  from fft_reference import fixed_reference
  x=np.genfromtxt(O/'fft_capture.csv',delimiter=',',names=True,dtype=np.int64)['code'];assert len(x)==672
  mean=int(abs(x.sum())//672)*(1 if x.sum()>=0 else -1);centered=np.clip(x-mean,-32768,32767)
  w=np.floor(np.kaiser(672,4)*2**17+.5).astype(np.int64);c=np.floor(np.cos(np.arange(257)*2*np.pi/1024)*2**17+.5).astype(np.int64)
  re,im,overflow=fixed_reference(centered,w,c,10);pw=re*re+im*im;cfg=json.loads((A/'main_settings.json').read_text());df=165e6/144/32/1024;lo=int(np.ceil(cfg['search_min_hz']/df));hi=int(np.floor(cfg['search_max_hz']/df));k=lo+int(np.argmax(pw[lo:hi+1]));v=np.log(pw[k-1:k+2].astype(float));delta=.5*(v[0]-v[2])/(v[0]-2*v[1]+v[2])
  assert not overflow and istatus==0 and int(fields[3],16)==k and int(fields[4],16)==pw[k] and abs(offset/65536-delta)<.0001
  print('PASS independent FFT/power/interpolation reference:',(k+offset/65536)*(165e6/144/32/1024),'Hz')
 print('PASS complete packet contents / trailer / M4 checksum:',n,'raw samples')
print(marker+'; see '+str(O))
