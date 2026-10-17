from pathlib import Path
import sys,subprocess,shutil,hashlib,json
A=Path(__file__).resolve().parent;V=A.parents[1];S=V/'SourceCode'
mode=sys.argv[1] if len(sys.argv)>1 else 'system';assert mode in ['short','system','io']
O=A/'results/main'/mode;O.mkdir(parents=True,exist_ok=True)
macro=dict(short='MAIN_SHORT_TOP',system='MAIN_SYSTEM_TOP',io='MAIN_IO_TEST')[mode]
d='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
sv=['MainPeakReport.sv'];vhd=['SysLib.vhd']
if mode=='io':sv+=['MainAdcBridge.sv','MainWaveFifo.sv'];vhd+=['UARTController.vhd','RxDepack.vhd','MainTxPack.vhd'];top='tb_main_io'
else:
 sv+=['MainCicDecimator.sv','MainFrameRam.sv','MainFftProcessor.sv','MainWaveFifo.sv','fft_tdp_store.sv','kaiser4_rfft.sv','fft_power_peak.sv']
 if mode=='short':sv+=['ScopeAdc27m5.sv','MainAdcBridge.sv']
 vhd+=['DSPLib.vhd','MainSettings.vhd','RxDepack.vhd','MainTxPack.vhd','MainRxController.vhd']
 t=(S/'MainTxController.vhd').read_text();t=t[:t.lower().index('architecture')]+'''architecture model of MainTxController is
begin
 oDA_PD<='0';oDA_CLK<=iClk;oDA_D<=(others=>'0');oTX_MUX_EN<='1';oTX_MUX_A<=iMuxSel;
 process begin oBusy<='0';wait until rising_edge(iStart);
  assert iFc=x"471c4000" and iBW=x"457a0000" and iTc=x"3ca3d70a" and iA=x"3e800000"
   and iMuxSel="000" and iSQWaveEn='0' and iDownSampleRate=0 and iDataResolution=14
   report "Main TX defaults must match 38-42 kHz / 20 ms Chirp experiment" severity failure;
  report "PASS MAIN TOP TX DEFAULTS: 40kHz center / 4kHz BW / 20ms / amplitude 0.25 / filter bypass";
  oBusy<='1';wait for 20 us;oBusy<='0';wait until iStart='0';end process;
end architecture;
''';(O/'TxModel.vhd').write_text(t)
 t=(S/'MainTMP117Controller.vhd').read_text();t=t[:t.lower().index('architecture')]+'''architecture model of MainTMP117Controller is
begin oTempData<=x"0C80";oDataValid<='1';oTmp_SCL<='1';ioTmp_SDA<='Z';end architecture;
''';(O/'TempModel.vhd').write_text(t)
 top='tb_main_top'
for n in vhd:
 p=next(S.rglob(n)) if n=='DSPLib.vhd' else S/n;d+='vcom -2008 {'+p.as_posix()+'}\n'
if mode!='io':
 t=(S/'UsMimoTestBench.vhd').read_text()
 if mode=='system':t=t.replace('SAMPLE_TICKS:integer:=4608','SAMPLE_TICKS:integer:=32')
 (O/'MainTest.vhd').write_text(t)
 for n in ['TxModel.vhd','TempModel.vhd','MainTest.vhd']:d+='vcom -2008 {'+(O/n).as_posix()+'}\n'
 for n in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:shutil.copy2(S/n,O/n)
files=[S/n for n in sv]+[A/'tb_fft_board.sv']
if mode=='system':
 p=O/'MainWaveFifo_model.sv';p.write_text((S/'MainWaveFifo.sv').read_text().replace('`ifdef FFT_USE_INTEL_RAM','`ifdef MAIN_RAW_MEMORY_INTEL_TEST'));files=[p if f==S/'MainWaveFifo.sv' else f for f in files]
(O/'memory_models.json').write_text(json.dumps(dict(raw_ram='behavioral' if mode in ['system','io'] else 'Intel altsyncram',fft_ram='Intel altsyncram' if mode=='system' else 'not exercised numerically')))
d+='vlog -sv '+('' if mode=='io' else '+define+FFT_USE_INTEL_RAM ')+'+define+'+macro+' '+' '.join('{'+p.as_posix()+'}' for p in files)+'\n'
d+='vsim -t 1ps -L altera_mf work.'+top+'\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0 -force\n'
if mode=='short':
 d=d.replace('run -all','force -deposit /tb_main_top/dut/uRx/cTick 16#'+format(2**28-300000,'07x')+' 0\nrun -all')
(O/'run.do').write_text(d)
(O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in files+[S/'UsMimoTestBench.vhd',S/'MainSettings.vhd']},indent=2))
with (O/'simulation.log').open('w') as f:
 subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=1200)
marker=dict(short='PASS MAIN SHORT TOP',system='PASS MAIN LONG FRAME',io='PASS MAIN IO')[mode]
assert '** Error' not in (O/'simulation.log').read_text() and '** Fatal' not in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-4000:]
assert marker in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-3000:]
if mode!='io':
 import struct,numpy as np
 b=bytes(int(s,16) for s in (O/'stream.hex').read_text().split());n=struct.unpack_from('<I',b,8)[0];assert len(b)==n*2+128
 raw=np.genfromtxt(O/'raw_words.csv',delimiter=',',names=True,dtype=np.int64)['code'];assert np.array_equal(raw,np.frombuffer(b[32:32+2*n],dtype='<u2'))
 tail=bytearray(b[:32]);tail[6]=tail[25]=165;assert b[32+2*n:64+2*n]==bytes(tail)
 line=b[-64:];ck=0
 for c in line[:60]:ck^=c
 assert ck==int(line[60:62],16)
 print('PASS complete packet contents / trailer / M1 checksum:',n,'raw samples')
print(marker+'; see '+str(O))
