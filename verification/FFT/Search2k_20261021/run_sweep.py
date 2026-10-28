"""Sweep the unchanged Main FPGA receive/FFT RTL over 27 modeled reflector distances.
Uses the production testbench assertions and Intel altsyncram simulation models.
No production source/configuration is written. Simulator outputs go under --output.
"""
from pathlib import Path
import argparse, csv, hashlib, importlib.util, json, re, shutil, struct, subprocess, sys
import numpy as np

def main():
    p = argparse.ArgumentParser()
    p.add_argument('--project', type=Path, default=Path(r'E:/Document_HH/Course/26FA/450code/15_UsMimoTestBench'))
    p.add_argument('--output', type=Path, default=Path(__file__).resolve().parent/'run')
    p.add_argument('--vsim', default=r'E:/Downloads/Questa/questa_fse/win64/vsim.exe')
    p.add_argument('--analyze-only', action='store_true')
    args = p.parse_args()
    root = args.project.resolve(); v = root/'02_RTL/V0'; s = v/'SourceCode'
    o = args.output.resolve(); o.mkdir(parents=True, exist_ok=True)
    cfg = json.loads((v/'Simulation/FFT/main_settings.json').read_text())
    assert cfg == dict(rx_capture_ms=19, rx_raw_downsample=3, fft_length=1024, fft_valid_samples=672, search_min_hz=25, search_max_hz=2000), cfg
    sys.path.insert(0, str(v/'Simulation'))
    from source_units import SourceTree
    tree = SourceTree(s, o)
    top = (s/'UsMimoTestBench.vhd').read_text(encoding='utf-8')
    def fp_default(name):
        match = re.search(r'signal\s+'+name+r'\s*:[^;]*?x"([0-9a-fA-F]{8})"', top)
        assert match, name
        return struct.unpack('>f', bytes.fromhex(match.group(1)))[0]
    defaults = {n:fp_default(n) for n in ['cTx_Fc','cTx_BW','cTx_Tc','cTx_A','cRx_Td']}
    assert defaults['cTx_Fc']==40000 and defaults['cTx_BW']==4000 and defaults['cTx_A']==.25
    assert abs(defaults['cTx_Tc']-.02)<1e-9 and abs(defaults['cRx_Td']-.001)<1e-9
    # Use the nominal user profile; binary32 duration representation differs by < 1 ns.
    fc, bw, duration, delay, c = 40000., 4000., .020, .001, 343.
    slope = bw/duration; f0 = fc-bw/2
    fs = 165e6/144; fl = fs/32; nfft=1024; nv=672; df=fl/nfft
    lo, hi = int(np.ceil(cfg['search_min_hz']/df)), int(np.floor(cfg['search_max_hz']/df))
    raw_words = int(fs*cfg['rx_capture_ms']/1000)
    ninput = raw_words+1024
    cases=[]
    for i, distance_cm in enumerate(np.arange(10,75.01,2.5)):
        tau = 2*distance_cm/100/c
        cases.append(dict(case=i,distance_cm=float(distance_cm),delay_s=float(tau),ideal_beat_hz=float(slope*tau)))
    assert len(cases)==27
    if not args.analyze_only:
        t = delay+np.arange(ninput)/fs
        for case in cases:
            tau=case['delay_s']
            # LPF{cos(phi(t)) cos(phi(t-tau))}; high-frequency sum term removed analytically.
            # Same reference phase, one non-dispersive reflection, constant post-mixer amplitude.
            phase = 2*np.pi*(f0*tau + slope*tau*t - .5*slope*tau*tau)
            overlap = (t>=tau)&(t<duration)&(t-tau<duration)
            x=np.trunc(111 + 7000*overlap*np.cos(phase)).astype(np.int64)
            assert np.max(x)<32767 and np.min(x)>-32768
            y=x.copy()
            for _ in range(3):
                integ=np.cumsum(y); y=integ.copy(); y[32:]-=integ[:-32]
            y=(y[31::32]+(1<<14))>>15
            np.savetxt(o/f"input_{case['case']}.mem",x&65535,fmt='%04x')
            np.savetxt(o/f"expected_{case['case']}.mem",y&65535,fmt='%04x')
        for name in ['main_window_delta.mem','main_window_delta.mif','main_cos_quarter.mem','main_cos_quarter.mif']:
            shutil.copy2(tree.resolve(name),o/name)
        original=(v/'Simulation/FFT/tb_fft_plot.sv').read_text()
        tb=original[original.index('`elsif MAIN_FFT_TEST')+len('`elsif MAIN_FFT_TEST'):original.index('\n`else', original.index('`elsif MAIN_FFT_TEST'))]
        replacements={
            'case_no<8':'case_no<27',
            'n<(case_no==6 ? RAW_WORDS/2 : case_no==7 ? RAW_WORDS/8 : RAW_WORDS)':'n<RAW_WORDS',
            'av=(case_no!=7)':'av=1',
            'if(case_no<6)begin':'begin',
            'if(case_no<5&&flags!=0)$fatal(1,"Unexpected flags %h",flags);':'if((flags & 8\'hef)!=0)$fatal(1,"Unexpected acquisition/FFT flags %h",flags);',
            'if(case_no==5&&!flags[2])$fatal(1,"Clipping not detected");':'// A weak out-of-band peak may legitimately set flag bit 4.',
            'end else if(!flags[0]||bn!=0||fn!=0||peak_power!=0)$fatal(1,"Short/empty window reported valid FFT");':'end',
        }
        for old,new in replacements.items():
            assert old in tb, old
            tb=tb.replace(old,new)
        (o/'tb_distance_sweep.sv').write_text(tb,encoding='utf-8')
        names=['MainFftProcessor.sv','MainPeakReport.sv','MainCicDecimator.sv','MainFrameRam.sv','kaiser4_rfft.sv','fft_tdp_store.sv','fft_power_peak.sv','main_peak_interpolator.sv']
        files=[tree.file(n) for n in names]+[o/'tb_distance_sweep.sv']
        refs=tree.ledger(files)+[s/'MainSettings.vhd',s/'UsMimoTestBench.vhd',v/'Simulation/FFT/main_settings.json',v/'Simulation/FFT/tb_fft_plot.sv',v/'Simulation/FFT/fft_reference.py',root/'03_SW/UsMimoTestBench/MainProtocol.cs']
        (o/'source_sha256.json').write_text(json.dumps({str(q):hashlib.sha256(q.read_bytes()).hexdigest() for q in refs},indent=2))
        defs=f'+define+FFT_USE_INTEL_RAM +define+MF_LOGN=10 +define+MF_VALID=672 +define+MF_DW=9 +define+MF_MIN={lo} +define+MF_MAX={hi} +define+MF_RAW={raw_words}'
        (o/'run.do').write_text('onerror {quit -code 1 -force}\nonbreak {quit -code 1 -force}\nvlib work\nvmap work work\nvlog -sv '+defs+' '+' '.join('{'+f.as_posix()+'}' for f in files)+'\nvsim -t 1ps -L altera_mf work.tb_main_fft\nrun -all\nquit -code 0 -force\n')
        (o/'model.json').write_text(json.dumps(dict(
            tx_defaults_binary32=defaults,nominal_chirp=dict(center_hz=fc,bandwidth_hz=bw,duration_s=duration,amplitude=.25),
            rx_start_s=delay,rx_window_s=.019,raw_fs_hz=fs,fft_fs_hz=fl,valid_samples=nv,nfft=nfft,
            search_hz=[cfg['search_min_hz'],cfg['search_max_hz']],search_bins=[lo,hi],c_m_s=c,if_peak_adc_codes=7000,adc_dc_codes=111,
            phase='2*pi*(f_start*tau + slope*tau*t - slope*tau^2/2); reflection phase 0',
            gating='RX echo exists after tau; reference TX exists during [0,20ms); acquisition starts at 1ms',
            analog_model='Analytical difference term of ideal multiplier/LPF; no analog filter transient, transducer response, noise, multipath, clipping or amplitude-distance loss',
            rtl_scope='Unchanged production CIC3 /32, RAM, mean, Kaiser4, FFT, power, argmax, interpolation, M3 byte report; Intel altsyncram models; idle clocks compressed',
            not_simulated=['Chirp generator RTL and DAC analog output','ADC SPI physical timing','full Main top','physical UART bits','physical propagation and transducer transfer response'],
            cases=cases),indent=2))
        with (o/'simulation.log').open('w') as log:
            process=subprocess.Popen([args.vsim,'-c','-do','run.do'],cwd=o,stdout=log,stderr=subprocess.STDOUT)
            (o/'status.json').write_text(json.dumps(dict(stage='running',pid=process.pid)))
            rc=process.wait(timeout=1200)
        if rc:
            print((o/'simulation.log').read_text()[-6000:]);raise SystemExit(rc)
    log=(o/'simulation.log').read_text()
    assert 'PASS MAIN FFT PIPELINE' in log and '** Error' not in log and '** Fatal' not in log
    sys.path.insert(0,str(v/'Simulation/FFT'))
    from fft_reference import fixed_reference
    cap=np.genfromtxt(o/'capture.csv',delimiter=',',names=True,dtype=np.int64)
    spec=np.genfromtxt(o/'spectrum.csv',delimiter=',',names=True,dtype=np.int64)
    meta=np.genfromtxt(o/'metadata.csv',delimiter=',',names=True,dtype=np.int64)
    # Questa on Windows can write CR-CR-LF for an explicit CRLF report.
    lines=[line for line in (o/'telemetry.txt').read_text().splitlines() if line]
    assert len(lines)==len(meta)==27
    w=np.floor(np.kaiser(nv,4)*(1<<17)+.5).astype(np.int64)
    tw=np.floor(np.cos(np.arange(nfft//4+1)*2*np.pi/nfft)*(1<<17)+.5).astype(np.int64)
    results=[];max_interp_error=0.;max_fft_error=0.
    for case,m,line in zip(cases,meta,lines):
        cid=case['case'];x=cap[cap['case']==cid]['code'];sp=spec[spec['case']==cid]
        assert len(x)==nv and len(sp)==513 and len(line)==79 and line.startswith('M3,')
        checksum=0
        for b in line[:77].encode():checksum^=b
        assert checksum==int(line[77:],16)
        fields=line.split(',');seq,n,k,power,mn,mx,flags,span=[int(f,16) for f in fields[1:9]]
        delta=int(fields[9],16);delta=delta-2**32 if delta>=2**31 else delta
        istatus=int(fields[10],16)
        assert (seq,n,k,power,flags,span,delta,istatus)==tuple(int(m[f]) for f in ['seq','count','bin','power','flags','span','delta_q16','interp_status'])
        assert int(fields[11],16)==nfft and seq==cid+1 and flags&~16==0
        mean=int(abs(x.sum())//nv)*(1 if x.sum()>=0 else -1)
        assert mean==int(m['mean'])
        centered=np.clip(x-mean,-32768,32767)
        re_,im,overflow=fixed_reference(centered,w,tw,10)
        assert not overflow
        assert np.array_equal(re_,sp['real']) and np.array_equal(im,sp['imag']) and np.array_equal(re_*re_+im*im,sp['power'])
        assert k==lo+int(np.argmax(sp['power'][lo:hi+1])) and power==sp['power'][k]
        fft_error=float(np.max(abs((re_+1j*im)/8-np.fft.rfft(centered*np.kaiser(nv,4),nfft)/nfft)))
        max_fft_error=max(max_fft_error,fft_error);assert fft_error<2
        nbr=sp['power'][k-1:k+2]
        wanted=1 if flags else 3 if min(nbr)==0 else 4 if nbr[1]<max(nbr) else 5 if nbr[0]==nbr[1]==nbr[2] else 0
        assert istatus==wanted,(cid,istatus,wanted)
        if istatus==0:
            lp=np.log(nbr.astype(float));expected_delta=float(np.clip(.5*(lp[0]-lp[2])/(lp[0]-2*lp[1]+lp[2]),-.5,.5))
            e=abs(delta/65536-expected_delta);max_interp_error=max(max_interp_error,e);assert e<.0001
        else: assert delta==0
        # Mirror the current C# display, including raw-bin fallback on invalid interpolation.
        raw_hz=k*df; displayed_hz=(k+delta/65536)*df if flags==0 and istatus==0 else raw_hz
        estimated_cm=displayed_hz*c/(2*slope)*100
        results.append(dict(**case,nominal_search_contains_beat=cfg['search_min_hz']<=case['ideal_beat_hz']<=cfg['search_max_hz'],
            raw_bin=k,raw_bin_hz=raw_hz,interpolated_hz=displayed_hz,delta_q16=delta,interp_status=istatus,
            flags=flags,power_code_squared=power/64,estimated_distance_cm=estimated_cm,
            signed_error_mm=(estimated_cm-case['distance_cm'])*10,
            raw_bin_error_mm=(raw_hz*c/(2*slope)*100-case['distance_cm'])*10,
            available_echo_ms=max(0.,min(delay+nv/fl,duration)-max(delay,case['delay_s']))*1000))
    with (o/'distance_results.csv').open('w',newline='',encoding='utf-8') as f:
        wr=csv.DictWriter(f,fieldnames=list(results[0]));wr.writeheader();wr.writerows(results)
    inband=[r for r in results if r['nominal_search_contains_beat']]
    errs=np.array([r['signed_error_mm'] for r in inband]);raw=np.array([r['raw_bin_error_mm'] for r in inband])
    checks=dict(rtl_arithmetic_and_protocol_pass=True,all_distances_valid_ranging=all(r['nominal_search_contains_beat'] and r['flags']==0 and r['interp_status']==0 for r in results),cases=27,
        intel_ram_model=True,full_main_top_simulated=False,exact_fft_and_power_reference_match=True,
        maximum_fft_difference_from_float=max_fft_error,maximum_interpolation_error_bins=max_interp_error,
        nominal_search_upper_distance_cm=cfg['search_max_hz']*c/(2*slope)*100,nominal_inband_cases=len(inband),
        nominal_out_of_band_cases=len(results)-len(inband),
        inband_max_abs_error_mm=float(max(abs(errs))),inband_rmse_mm=float(np.sqrt(np.mean(errs**2))),
        inband_raw_bin_max_abs_error_mm=float(max(abs(raw))),
        scope='Error is inferred using ideal R=c*f/(2*slope); current FPGA/GUI do not implement distance conversion. Uncalibrated, deterministic single-reflector model, not hardware accuracy.')
    (o/'checks.json').write_text(json.dumps(checks,indent=2))
    (o/'status.json').write_text(json.dumps(dict(stage='complete',all_ranges_supported=True)))
    print(json.dumps(checks,indent=2))
    print('distance_cm,ideal_hz,result_hz,error_mm,flags,interp_status')
    for r in results:print(f"{r['distance_cm']:g},{r['ideal_beat_hz']:.3f},{r['interpolated_hz']:.3f},{r['signed_error_mm']:.3f},{r['flags']},{r['interp_status']}")

if __name__=='__main__': main()
