from pathlib import Path
import subprocess,shutil,json,hashlib
A=Path(__file__).resolve().parent;S=A.parents[1]/'SourceCode';O=A/'results/main/tx';O.mkdir(parents=True,exist_ok=True)
files=[S/n for n in ['SysLib.vhd','DSP/FPFAdd/FPFAdd/dspba_library_package.vhd','DSP/FPFAdd/FPFAdd/dspba_library.vhd']]
for n in ['FPFAdd','FPFSub','FPFMult','FPFDiv','FPFCos','FPFFP32ToInt32','FPFInt32ToFP32']:files.extend([S/'DSP'/n/n/(n+'_0002.vhd'),S/'DSP'/n/(n+'.vhd')])
files.extend([S/n for n in ['DSPLib.vhd','DSP/FIFO.vhd','ChirpWaveGen.vhd','MainTxController.vhd','MainRxController.vhd']])
d='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
for p in files:d+='vcom -2008 {'+p.as_posix()+'}\n'
for p in (S/'DSP').rglob('*.hex'):shutil.copy2(p,O/p.name)
d+='vlog -sv {'+(S/'MainAdcBridge.sv').as_posix()+'} {'+(S/'ScopeAdc27m5.sv').as_posix()+'}\n'
d+='vlog -sv +define+MAIN_TX_PARAMETERS {'+(A/'tb_fft_board.sv').as_posix()+'}\nvsim -t 1ps -L altera_mf -L altera_lnsim -L lpm work.tb_main_tx_parameters\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0 -force\n'
(O/'run.do').write_text(d);(O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in files+[S/'MainAdcBridge.sv',S/'ScopeAdc27m5.sv',A/'tb_fft_board.sv']},indent=2))
with (O/'simulation.log').open('w') as f:subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=f,stderr=subprocess.STDOUT,check=True,timeout=300)
assert '** Error' not in (O/'simulation.log').read_text() and '** Fatal' not in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-4000:]
assert 'PASS MAIN TX PARAMETERS AND STARTUP' in (O/'simulation.log').read_text(),(O/'simulation.log').read_text()[-3000:]
print('PASS main TX real Intel IP parameter pipeline and startup; full-duration waveform not repeated.')
