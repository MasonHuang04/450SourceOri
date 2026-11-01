"""Read measured CSVs without altering them; quantify ADC rails and log status."""
from pathlib import Path
from collections import Counter
import csv,io,json,hashlib
import numpy as np

out=Path(__file__).parent
root=Path('E:/Document_HH/Course/26FA/450code/15_UsMimoTestBench_multiFPGA')
source=root/'verification/Output_real/1029'
names=['rx_20261029_134125.csv','rx_20261029_134405.csv']
summary={'date':'2026-10-29','data_kind':'Measured UART ADC samples',
 'user_confirmed_route':'Front-end Amplifier / Rx_Amp, P4 2-3',
 'csv_sample_limit':'Exported UART waveform contains every fourth ADC sample, not all raw1.145833MS/s samples. CSV has no acquisition frame ID or TX settings.',
 'units':'16-bit signed ADC code after unsigned transport centering; no voltage calibration applied.',
 'files':[]}
for name,label in zip(names,['Approx.30-40cm, user estimate','Approx.50cm, user statement']):
    f=source/name;raw=f.read_bytes();rows=list(csv.DictReader(io.StringIO(raw.decode('utf-8-sig'))))
    t=np.array([float(r['time_s']) for r in rows]);y=np.array([int(r['adc_centered']) for r in rows]);u=np.array([int(r['adc_unsigned']) for r in rows]);idx=np.array([int(r['index']) for r in rows])
    assert len(y)==5442 and np.array_equal(idx,np.arange(len(y))) and np.array_equal(y,u-32768)
    assert set(r['source'] for r in rows)=={'UART'}
    dt=float(np.median(np.diff(t)));assert np.max(np.abs(np.diff(t)-dt))<1e-12
    pos=np.flatnonzero(y==32767);neg=np.flatnonzero(y==-32768)
    windows=[]
    for group in np.split(pos,np.where(np.diff(pos)*dt>.00015)[0]+1):
        if len(group):windows.append({'start_ms':float(t[group[0]]*1000),'end_ms':float(t[group[-1]]*1000),'positive_rail_points':len(group)})
    freqs=np.fft.rfftfreq(len(y),dt);power=np.abs(np.fft.rfft((y-y.mean())*np.hanning(len(y))))**2
    band=(freqs>=35000)&(freqs<=45000);carrier_idx=np.flatnonzero(band)[int(np.argmax(power[band]))]
    summary['files'].append({'file':name,'source_sha256':hashlib.sha256(raw).hexdigest(),'distance_label':label,
      'points':len(y),'sample_rate_hz':1/dt,'sample_interval_s':dt,'window_ms':len(y)*dt*1000,
      'min_code':int(y.min()),'max_code':int(y.max()),'mean_code':float(y.mean()),'median_code':float(np.median(y)),
      'first_1ms_median_code':float(np.median(y[t<.001])),'ac_rms_code':float(np.std(y)),
      'positive_rail_points':len(pos),'negative_rail_points':len(neg),'rail_percent':100*(len(pos)+len(neg))/len(y),
      'positive_rail_time_extent_ms':[float(t[pos[0]]*1000),float(t[pos[-1]]*1000)] if len(pos) else None,
      'rail_windows_grouped_by_150us_gap':windows,'near_positive_rail_ge32000':int(np.sum(y>=32000)),
      'carrier_peak_in_35_to_45kHz_hz':float(freqs[carrier_idx])})

log=root/'03_SW/UsMimoTestBench/bin/Release/DataSessions/20261029_133648_ec25e2/peaks.csv'
raw=log.read_bytes();reader=csv.DictReader(io.StringIO(raw.decode('utf-8-sig')));fields=reader.fieldnames
allrows=list(reader)
# The live session may append during analysis. Freeze the interval containing both exports.
cutoff='2026-10-29T13:44:32.4545300+08:00'
rows=[r for r in allrows if r['time']<=cutoff]
with (out/'session_peaks_snapshot.csv').open('w',newline='',encoding='utf-8-sig') as f:
    w=csv.DictWriter(f,fieldnames=fields);w.writeheader();w.writerows(rows)
counts=dict(Counter(r['status'] for r in rows))
def interval(a,b):
    selected=[r for r in rows if a<=r['time'].split('T')[1][:8]<=b]
    valid=[r for r in selected if r['status']=='OK']
    power=[float(r['power_code_squared']) for r in selected]
    return {'start_clock':a,'end_clock':b,'frames':len(selected),'statuses':dict(Counter(r['status'] for r in selected)),
      'tx_amplitudes':sorted(set(r['tx_amplitude'] for r in selected)),
      'power_display_min':min(power),'power_display_max':max(power),
      'valid_distance_mm_min':min(float(r['distance_mm']) for r in valid) if valid else None,
      'valid_distance_mm_max':max(float(r['distance_mm']) for r in valid) if valid else None}
summary['log_snapshot']={'source_file_relative':log.relative_to(root).as_posix(),'cutoff_inclusive':cutoff,'frames':len(rows),'statuses':counts,
 'percentages':{k:100*v/len(rows) for k,v in counts.items()},
 'export_neighborhoods':[interval('13:41:15','13:41:35'),interval('13:43:55','13:44:15')],
 'association_limit':'Neighborhood timestamps only. CSV names are export times and contain no frame ID, so an exact waveform-to-log-row match is not claimed.'}
summary['interpretation']={
 'confirmed':'First CSV hits positive ADC rail248times; second CSV has no rail hits. Receive-path digital samples are clipped in the first frame.',
 'not_confirmed':'Physical RX gain, TX output volts, ADC reference volts and exact stage creating DC/overload cannot be determined from these CSVs alone.',
 'dc_headroom':'Both records have about6000positive codes. This reduces positive headroom; subtracting mean after ADC does not recover clipped samples.',
 'limitation':'Clipping percentage applies to exported samples only; true full-rate rail count is not available. No valid distance is inferred from the clipped frame.'}
(out/'analysis.json').write_text(json.dumps(summary,ensure_ascii=False,indent=2),encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False,indent=2))
