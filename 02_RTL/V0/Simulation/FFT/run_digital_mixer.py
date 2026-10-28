"""Verify the multiFPGA digital mixer, ADC/reference pairing and RF FFT chain.

Run --arithmetic, --pair, --frames, or --real-cadence. Frame sweep retains all
ADC words but compresses idle clocks; --real-cadence uses actual 144-cycle cadence.
"""
from pathlib import Path
import argparse,json,subprocess,shutil,sys,hashlib
import numpy as np

def run_square_tx(A,V,S,O):
    """Actual Intel Chirp core: square/sine phase, amplitude and full sweep."""
    sys.path.insert(0,str(A.parent))
    from source_units import SourceTree
    tree=SourceTree(S,O)
    tb='''library ieee;
use ieee.std_logic_1164.all;use ieee.numeric_std.all;use std.textio.all;use std.env.all;
entity tb_square_chirp is end;
architecture test of tb_square_chirp is
 signal clk:std_logic:='0';signal rst:std_logic:='1';signal done:boolean:=false;
 signal idx:std_logic_vector(31 downto 0):=(others=>'0');
 signal amp:std_logic_vector(31 downto 0):=x"3e800000";
 signal square_wave,sine_wave:integer range 0 to 16383;
begin
 clk<=not clk after 3.030303 ns when not done else '0';
 dut:entity work.ChirpWaveGen(Beh) port map(iClk=>clk,iRst=>rst,iSQWaveEn=>'1',iDIdx=>idx,
 iF0=>x"47147000",iK=>x"48435000",iA=>amp,iDT=>x"31d03da8",
 oWaveform=>square_wave,oSineWaveform=>sine_wave);
 process
  file f:text open write_mode is "square_sine.csv";variable l:line;variable n,tick:integer;
 begin
  for c in 0 to 4 loop
   rst<='1';idx<=(others=>'0');
   case c is when 0=>amp<=x"3e800000";when 1=>amp<=x"3e000000";
    when 2=>amp<=x"3f000000";when 3=>amp<=x"3f800000";when others=>amp<=x"00000000";end case;
   for j in 1 to 30 loop wait until falling_edge(clk);end loop;rst<='0';
   for j in 1 to 300 loop wait until falling_edge(clk);end loop;
   if c=0 then n:=5001;else n:=501;end if;
   for j in 0 to n+140 loop
    if j<n then tick:=j*660;else tick:=(n-1)*660;end if;
    idx<=std_logic_vector(to_unsigned(tick,32));wait until rising_edge(clk);wait for 1 ps;
    write(l,c);write(l,string'(","));write(l,j);write(l,string'(","));write(l,tick);
    write(l,string'(","));write(l,square_wave);write(l,string'(","));write(l,sine_wave);writeline(f,l);
    wait until falling_edge(clk);
   end loop;
  end loop;
  report "PASS SQUARE AND SINE CHIRP EXPORT";done<=true;wait;
 end process;
end;
'''
    (O/'tb_square_chirp.vhd').write_text(tb)
    files=[tree.file(n) for n in ['SysLib.vhd','DSP/FPFAdd/FPFAdd/dspba_library_package.vhd','DSP/FPFAdd/FPFAdd/dspba_library.vhd']]
    for name in ['FPFAdd','FPFSub','FPFMult','FPFDiv','FPFCos','FPFFP32ToInt32','FPFInt32ToFP32']:
        files.extend([S/'DSP'/name/name/(name+'_0002.vhd'),S/'DSP'/name/(name+'.vhd')])
    files.extend([tree.file(n) for n in ['DSPLib.vhd','DSP/FIFO.vhd','ChirpWaveGen.vhd']]+[O/'tb_square_chirp.vhd'])
    for p in (S/'DSP').rglob('*.hex'):shutil.copy2(p,O/p.name)
    script='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
    script+=''.join('vcom -2008 {'+p.as_posix()+'}\n' for p in files)
    script+='vsim -t 1fs -L altera_mf -L altera_lnsim -L lpm work.tb_square_chirp\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0 -force\n'
    (O/'run.do').write_text(script)
    (O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files)},indent=2))
    with (O/'simulation.log').open('w') as out:
        subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=out,stderr=subprocess.STDOUT,check=True,timeout=600)
    log=(O/'simulation.log').read_text();assert 'PASS SQUARE AND SINE CHIRP EXPORT' in log and '** Error' not in log and '** Fatal' not in log
    data=np.loadtxt(O/'square_sine.csv',delimiter=',',dtype=np.int64);results=[]
    for case,amp in enumerate([.25,.125,.5,1.,0.]):
        n=5001 if case==0 else 501;rows=data[data[:,0]==case][105:105+n]
        assert len(rows)==n
        ts=np.arange(n)*4e-6;square=rows[:,3];sine=rows[:,4]
        ideal=np.rint(8192+8191*amp*np.cos(2*np.pi*(38000*ts+100000*ts*ts)))
        err=np.abs(sine-ideal);assert max(err)<=32
        levels=np.unique(square);peak=(max(levels)-min(levels))/2
        assert abs(peak-8191*amp)<=1 and min(levels)+max(levels)==16384
        assert len(levels)==(1 if amp==0 else 2)
        if amp:
            assert np.array_equal(square>=8192,sine>=8192)
            assert len(np.unique(sine))>100
        else:assert np.all(square==8192) and np.all(sine==8192)
        result={'amplitude':amp,'points':n,'square_levels':levels.tolist(),'sine_max_error_codes':int(max(err)),'phase_signs_match':True}
        if case==0:
            centered=sine-8192;cross=np.flatnonzero((centered[:-1]>=0)!=(centered[1:]>=0))
            assert len(cross)==1600
            tcross=(cross-centered[cross]/(centered[cross+1]-centered[cross]))*4e-6
            fit=np.polyfit(tcross,np.arange(len(cross))*.5+.25,2)
            start_hz=float(fit[1]);end_hz=float(fit[1]+2*fit[0]*.020)
            assert abs(start_hz-38000)<5 and abs(end_hz-42000)<5
            result.update({'transitions':int(len(cross)),'fitted_start_hz':start_hz,'fitted_end_hz':end_hz})
            np.savetxt(O/'square_sine_checkpoints.csv',np.column_stack([ts,square,sine]),delimiter=',',header='time_s,square_code,sine_code',comments='',fmt=['%.9f','%d','%d'])
        results.append(result)
    checks={'pass':True,'scope':'Actual Intel Chirp IP, 4-us sample-index checkpoints across20ms, simultaneous square TX and sine reference; amplitude0/.125/.25/.5/1. Main controller duration verified separately.','cases':results,'hardware_measured':False}
    (O/'checks.json').write_text(json.dumps(checks,indent=2));print(json.dumps(checks,indent=2))

def run_full_top(A,V,S,O):
    """Actual Main/ADC SPI/mixer/FFT/report, behavioral RF source and TX math."""
    import struct
    sys.path.insert(0,str(A.parent))
    from source_units import SourceTree
    from fft_reference import fixed_reference
    tree=SourceTree(S,O)
    tx=tree.read('MainTxController.vhd')
    tx=tx[:tx.lower().index('architecture')]+'''architecture rf_model of MainTxController is
    begin
     oDA_PD<='0';oDA_CLK<=iClk;oTX_MUX_EN<='1';oTX_MUX_A<=iMuxSel;
     process(iClk)
      variable active:boolean:=false;variable last_start:std_logic:='0';
      variable n:integer:=0;variable ph,t:real;variable value:integer;
     begin if rising_edge(iClk)then
      assert iSQWaveEn='1' report "Square TX required" severity failure;
      if iRst='1'then active:=false;n:=0;oBusy<='0';oDA_D<=conv_std_logic_vector(8192,14);oSineReference<=(others=>'0');
      elsif iStart='1' and last_start='0'then active:=true;n:=0;oBusy<='1';
      elsif active then
       t:=real(n)/165000000.0;ph:=2.0*math_pi*(38000.0*t+100000.0*t*t);
       value:=integer(8191.0*0.25*cos(ph));
       if value>=0 then oDA_D<=conv_std_logic_vector(10240,14);else oDA_D<=conv_std_logic_vector(6144,14);end if;
       oSineReference<=conv_std_logic_vector(value*4,16);
       if n=3299999 then active:=false;oBusy<='0';else n:=n+1;end if;
      else oDA_D<=conv_std_logic_vector(8192,14);oSineReference<=(others=>'0');end if;
      last_start:=iStart;
     end if;end process;
    end architecture;
    '''
    tx=tx.replace('use work.SysLib.ALL;','use work.SysLib.ALL;\nuse ieee.math_real.all;')
    (O/'TxModel.vhd').write_text(tx)
    temp=tree.read('MainTMP117Controller.vhd');temp=temp[:temp.lower().index('architecture')]+'''architecture model of MainTMP117Controller is
    begin oTempData<=x"0C80";oDataValid<='1';oUpdated<=not iRst;oTmp_SCL<='1';ioTmp_SDA<='Z';end architecture;'''
    (O/'TempModel.vhd').write_text(temp)
    tb=(A/'tb_fft_board.sv').read_text().split('`elsif MAIN_SHORT_TOP',1)[1].split('`elsif MAIN_SYSTEM_TOP',1)[0]
    tb=tb.replace("(($rtoi($bitstoshortreal(a))==3135000)?165000:$rtoi($bitstoshortreal(a)))","$rtoi($bitstoshortreal(a))")
    tb=tb.replace('real f,phase,value_real;',
      'real f,phase,value_real,rf_time,u;\n integer sys_ticks=0,tx_epoch_tick=0;\n always @(posedge dut.cclkh)sys_ticks++;\n always @(posedge dut.ctx_busy)tx_epoch_tick=sys_ticks;')
    a0=tb.index('    case(case_no)0:f=100;');a1=tb.index('    ready_code=$rtoi(value_real);',a0)
    tb=tb[:a0]+'''    // Same master-clock timebase as TX: avoid 1 ps simulator rounding
    // turning #3.030303 ns into a 100 ppm TX/RX oscillator mismatch.
    rf_time=real'(sys_ticks-tx_epoch_tick)/165000000.0;u=rf_time-1.0/346.45;
    value_real=111;
    if(u>=0&&u<0.020)value_real=(24000*4.0/3.141592653589793)*$cos(6.283185307179586*(38000*u+100000*u*u))+111;
'''+tb[a1:]
    tb=tb.replace('cap_end-cap_begin!=165001','cap_end-cap_begin!=3135001')
    tb=tb.replace('RX1ms duration incorrect','RX19ms duration incorrect')
    tb=tb.replace('if(dut.cfftcount!=fft_count||!dut.creportflags[0]||dut.cfftbin!=0||dut.cfftpower!=0)$fatal(1,"Short window must reject FFT");',
      'if(dut.cfftcount!=672||fft_count!=672||dut.creportflags!=0||dut.cfftbin!=17||dut.cfftspan!=3091968)$fatal(1,"RF top FFT count/peak/span/flags");\n   if(dut.crx_muxsel[2]!==0)$fatal(1,"Raw RF must bypass analog IF LPF");')
    tb=tb.replace('PASS MAIN SHORT TOP: ADC SPI/raw FIFO/full short packet/short-FFT rejection/M4;',
      'PASS DIGITAL MAIN RF TOP: 19ms real cadence, raw RF ADC SPI/reference pairing/mixer/CIC/FFT/full raw packet/M4;')
    (O/'tb_rf_top.sv').write_text(tb)
    vhd=['SysLib.vhd','DSPLib.vhd','MainSettings.vhd','RxDepack.vhd','MainTxPack.vhd','MainRxController.vhd']
    sv=['ScopeAdc27m5.sv','MainAdcBridge.sv','MainReferenceDelay.sv','MainDigitalMixer.sv',
        'MainTempSnapshot.sv','MainRangeCalculator.sv','MainPeakReport.sv','MainCicDecimator.sv',
        'MainFrameRam.sv','MainFftProcessor.sv','MainWaveFifo.sv','fft_tdp_store.sv','kaiser4_rfft.sv',
        'fft_power_peak.sv','main_peak_interpolator.sv']
    for name in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:
        shutil.copy2(tree.resolve(name),O/name)
    files=[tree.file(n) for n in vhd]+[O/'TxModel.vhd',O/'TempModel.vhd',S/'UsMimoTestBench.vhd']
    script='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
    for p in files:script+='vcom -2008 {'+p.as_posix()+'}\n'
    # Keep the production raw-buffer control/address logic, using its provided
    # behavioral storage branch to avoid simulating 256 M10K models per tick.
    # FFT memories retain Intel altsyncram models in this integration test.
    raw_model=O/'MainWaveFifo_model.sv'
    raw_model.write_text(tree.read('MainWaveFifo.sv').replace('`ifdef FFT_USE_INTEL_RAM','`ifdef MAIN_RAW_MEMORY_INTEL_TEST'))
    svfiles=[raw_model if n=='MainWaveFifo.sv' else tree.file(n) for n in sv]+[O/'tb_rf_top.sv']
    script+='vlog -sv +define+FFT_USE_INTEL_RAM '+' '.join('{'+p.as_posix()+'}' for p in svfiles)+'\n'
    script+='vsim -t 1ps -L altera_mf work.tb_main_top\nset NumericStdNoWarnings 1\nset StdArithNoWarnings 1\nrun -all\nquit -code 0 -force\n'
    (O/'run.do').write_text(script)
    (O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files+svfiles+[Path(__file__)])},indent=2))
    with (O/'simulation.log').open('w') as out:
        subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=out,stderr=subprocess.STDOUT,check=True,timeout=1200)
    log=(O/'simulation.log').read_text();assert 'PASS DIGITAL MAIN RF TOP' in log and '** Error' not in log and '** Fatal' not in log,log[-5000:]
    b=bytes(int(x,16) for x in (O/'stream.hex').read_text().split());n=struct.unpack_from('<I',b,8)[0]
    raw=np.genfromtxt(O/'raw_words.csv',delimiter=',',names=True,dtype=np.int64)['code']
    assert n==5442 and len(b)==2*n+174 and np.array_equal(raw,np.frombuffer(b[32:32+2*n],dtype='<u2'))
    trailer=bytearray(b[:32]);trailer[6]=trailer[25]=165;assert b[32+2*n:64+2*n]==bytes(trailer)
    report=b[-110:];ck=0
    for ch in report[:106]:ck^=ch
    assert report.startswith(b'M4,') and ck==int(report[106:108],16)
    fields=report.decode().strip().split(',');delta=int(fields[9],16);delta=delta-2**32 if delta>=2**31 else delta
    x=np.genfromtxt(O/'fft_capture.csv',delimiter=',',names=True,dtype=np.int64)['code'];assert len(x)==672
    mean=int(abs(x.sum())//672)*(1 if x.sum()>=0 else -1)
    w=np.floor(np.kaiser(672,4)*2**17+.5).astype(np.int64);cos=np.floor(np.cos(np.arange(257)*2*np.pi/1024)*2**17+.5).astype(np.int64)
    re,im,overflow=fixed_reference(np.clip(x-mean,-32768,32767),w,cos,10);pw=re*re+im*im
    k=1+int(np.argmax(pw[1:58]));lp=np.log(pw[k-1:k+2].astype(float));d=.5*(lp[0]-lp[2])/(lp[0]-2*lp[1]+lp[2])
    assert not overflow and k==int(fields[3],16) and pw[k]==int(fields[4],16) and abs(delta/65536-d)<.0001
    assert int(fields[7],16)==0 and int(fields[10],16)==0 and int(fields[16],16)==0
    hz=(k+delta/65536)*(165e6/144/32/1024);reported_hz=int(fields[14],16)/1000;distance_mm=int(fields[15],16)/1000
    assert abs(hz-reported_hz)<.000501 and abs(distance_mm-500)<1
    checks={'pass':True,'raw_samples':n,'effective_samples':672,'fft_length':1024,'packet_bytes':len(b),
        'frequency_hz':hz,'expected_beat_hz':200000/346.45,'distance_mm':distance_mm,'expected_distance_mm':500,
        'model_temperature_c':25,'sound_speed_m_s':346.45,'raw_cadence_sys_cycles':144,
        'raw_waveform_spi_and_complete_m4_verified':True,'independent_fft_power_interpolation_match':True,
        'scope':'Actual Main top/ADC SPI/reference pairing/mixer/CIC/FFT/interpolation/range/frame reporting. TX waveform math, PLL, temperature and ADC analog behavior modeled; UART byte handshake accelerated; raw buffer behavioral storage with production control, FFT Intel altsyncram. Separate tests cover real Intel TX IP and UART bits.',
        'tx_shape':'square','reference_shape':'sine from same phase','rx_model':'delayed square-wave fundamental only, amplitude factor4/pi','adc_analog_group_delay_modeled':False,'hardware_measured':False}
    (O/'checks.json').write_text(json.dumps(checks,indent=2));print(json.dumps(checks,indent=2))

a=argparse.ArgumentParser();g=a.add_mutually_exclusive_group(required=True)
for name in ['arithmetic','pair','frames','real-cadence','top','square-tx']:g.add_argument('--'+name,action='store_true')
opt=a.parse_args();mode=next(k for k,v in vars(opt).items() if v)
A=Path(__file__).resolve().parent;V=A.parents[1];S=V/'SourceCode';O=A/'results/main/digital_mixer'/mode
O.mkdir(parents=True,exist_ok=True);sys.path.insert(0,str(A.parent))
if mode=='top':
    run_full_top(A,V,S,O)
    raise SystemExit
if mode=='square_tx':
    run_square_tx(A,V,S,O)
    raise SystemExit
from source_units import SourceTree
tree=SourceTree(S,O)
names=['ScopeAdc27m5.sv','MainAdcBridge.sv','MainReferenceDelay.sv','MainDigitalMixer.sv']
defines='';top={'arithmetic':'tb_mixer_arithmetic','pair':'tb_adc_reference_pair','frames':'tb_mixer_frames','real_cadence':'tb_mixer_frames'}[mode]
if mode in ['frames','real_cadence']:
    names+=['MainFftProcessor.sv','MainCicDecimator.sv','MainFrameRam.sv','kaiser4_rfft.sv','fft_tdp_store.sv','fft_power_peak.sv','main_peak_interpolator.sv']
    defines='+define+FFT_USE_INTEL_RAM '+('+define+MIX_REAL_CADENCE ' if mode=='real_cadence' else '')
    for name in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:
        shutil.copy2(tree.resolve(name),O/name)
    fs=165e6/144;low=fs/32;nfft=1024;nv=672;t=.001+np.arange(21770)/fs
    phase=lambda u:2*np.pi*(38000*u+.5*200000*u*u)
    ref=(np.trunc(8192+8191*.25*np.cos(phase(t))).astype(np.int64)-8192)*4
    for case,distance in enumerate(np.arange(10,75.1,2.5)):
        tau=2*distance/100/343
        rx=np.trunc((24000*4/np.pi)*np.cos(phase(t-tau))*(t>=tau)+111).astype(np.int64)
        product=np.clip((rx*ref+16384)>>15,-32768,32767)
        for label,x in [('rx',rx),('ref',ref),('product',product)]:np.savetxt(O/f'{label}_{case}.mem',x&65535,fmt='%04x')
files=[tree.file(n) for n in names]+[A/'tb_digital_mixer.sv']
script='onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\n'
script+='vlog -sv '+defines+' '.join('{'+p.as_posix()+'}' for p in files)+'\n'
script+='vsim -t 1ps -L altera_mf work.'+top+'\nrun -all\nquit -code 0 -force\n'
(O/'run.do').write_text(script)
(O/'source_sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in tree.ledger(files)},indent=2))
with (O/'simulation.log').open('w') as out:
    subprocess.run(['E:/Downloads/Questa/questa_fse/win64/vsim.exe','-c','-do','run.do'],cwd=O,stdout=out,stderr=subprocess.STDOUT,check=True,timeout=1200)
log=(O/'simulation.log').read_text()
assert '** Error' not in log and '** Fatal' not in log,log[-5000:]
marker={'arithmetic':'PASS DIGITAL MIXER ARITHMETIC','pair':'PASS ADC REFERENCE PAIRS','frames':'PASS DIGITAL MIXER FRAMES','real_cadence':'PASS DIGITAL MIXER FRAMES'}[mode]
assert marker in log,log[-4000:]
checks={'pass':True,'mode':mode,'scope':marker,'hardware_measured':False}
if mode in ['frames','real_cadence']:
    from fft_reference import fixed_reference
    cap=np.genfromtxt(O/'capture.csv',delimiter=',',names=True,dtype=np.int64)
    spec=np.genfromtxt(O/'spectrum.csv',delimiter=',',names=True,dtype=np.int64)
    metas=np.atleast_1d(np.genfromtxt(O/'metadata.csv',delimiter=',',names=True,dtype=np.int64))
    w=np.floor(np.kaiser(nv,4)*2**17+.5).astype(np.int64)
    cosine=np.floor(np.cos(np.arange(257)*2*np.pi/nfft)*2**17+.5).astype(np.int64)
    rows=[]
    for meta in metas:
        case=int(meta['case']);distance=10+case*2.5
        prod=np.loadtxt(O/f'product_{case}.mem',converters=lambda z:int(z,16),dtype=np.int64)
        prod=np.where(prod>=32768,prod-65536,prod);y=prod.copy()
        for _ in range(3):cumulative=np.cumsum(y);y=cumulative.copy();y[32:]-=cumulative[:-32]
        expected=((y[31::32]+16384)>>15)[2:674]
        actual=cap[cap['case']==case]['code'];assert np.array_equal(actual,expected)
        mean=int(abs(actual.sum())//nv)*(1 if actual.sum()>=0 else -1)
        re,im,overflow=fixed_reference(np.clip(actual-mean,-32768,32767),w,cosine,10)
        spectrum=spec[spec['case']==case];pw=re*re+im*im
        assert not overflow and np.array_equal(spectrum['real'],re) and np.array_equal(spectrum['imag'],im) and np.array_equal(spectrum['power'],pw)
        k=1+int(np.argmax(pw[1:58]));assert k==meta['bin'] and pw[k]==meta['power']
        lp=np.log(pw[k-1:k+2].astype(float));delta=.5*(lp[0]-lp[2])/(lp[0]-2*lp[1]+lp[2])
        assert abs(meta['delta']/65536-delta)<.0001
        hz=(k+meta['delta']/65536)*low/nfft;ideal=200000*2*distance/100/343
        rows.append({'case':case,'distance_cm':distance,'ideal_hz':ideal,'measured_hz':float(hz),'error_mm':float((hz-ideal)*343/(2*200000)*1000),'bin':k,'delta_q16':int(meta['delta'])})
    assert len(rows)==(1 if mode=='real_cadence' else 27)
    checks.update({'cases':rows,'max_error_mm':max(abs(r['error_mm']) for r in rows),
        'rmse_mm':float(np.sqrt(np.mean([r['error_mm']**2 for r in rows]))),
        'raw_words_per_frame':21770,'effective_samples':672,'fft_length':1024,
        'sample_clock_ticks':144 if mode=='real_cadence' else 8,
        'rtl_cic_capture_and_all_fft_powers_exact':True,
        'electronic_delay_model':'Frame input vectors are already paired by sample epoch. Separate SPI test verifies transport pairing.'})
(O/'checks.json').write_text(json.dumps(checks,indent=2))
print(json.dumps(checks,indent=2))
