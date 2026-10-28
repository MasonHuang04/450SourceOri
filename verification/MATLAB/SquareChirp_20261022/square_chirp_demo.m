function summary = square_chirp_demo(projectRoot, outputDir)
% SQUARE_CHIRP_DEMO Sample RF above Nyquist, mix, filter, and analyze.
% Main: RF sampling /4 -> multiply -> CIC3 /8 -> original 1024-point FFT.
% Previous direct /32 undersampling is retained only as a comparison.
% Existing mix-then-CIC path is retained as a reproducibility control.
% All signal generation, filtering, fixed-point emulation, analysis and plots
% run in MATLAB. Production FPGA and MCU firmware are not edited or executed.
% The main square case assumes ideal fundamental selection by the transducers.
% A separate causal Q=8 model is illustrative, not fitted to this hardware.
if nargin < 1
    projectRoot = 'E:/Document_HH/Course/26FA/450code/15_UsMimoTestBench';
end
if nargin < 2
    outputDir = fullfile(fileparts(mfilename('fullpath')), 'results');
end
if ~isfolder(outputDir), mkdir(outputDir); end
src = fullfile(projectRoot, '02_RTL/V0');
cfg = jsondecode(fileread(fullfile(src, 'Simulation/FFT/main_settings.json')));
assert(cfg.search_min_hz == 25 && cfg.search_max_hz == 2000);
assert(cfg.fft_length == 1024 && cfg.fft_valid_samples == 672);
assert(cfg.rx_capture_ms == 19 && cfg.rx_raw_downsample == 3);
refFolder = fullfile(projectRoot, 'verification/FFT/Search2k_20261021');
reference = readtable(fullfile(refFolder, 'distance_results.csv'),'VariableNamingRule','preserve');
model = jsondecode(fileread(fullfile(refFolder, 'model.json')));
fs = model.raw_fs_hz; fsIF = fs/32; nfft = 1024; nv = 672;
amplitude = 0.25; duration = 0.020; rxStart = 0.001;
fc = 40000; bandwidth = 4000; slope = bandwidth/duration; c = 343;
rawCount = floor(fs*0.019); sampleCount = rawCount+1024;
% Explicit RF and IF rates prevent reusing a low IF rate for a 40 kHz carrier.
rfDecimation = 4;
ifDecimation = 8;
rfFs = fs/rfDecimation;
assert(rfDecimation*ifDecimation == 32);
assert(rfFs/2 > 2*(fc+bandwidth/2), ...
    'RF Nyquist must exceed the highest product sum frequency.');
assert(fsIF/2 > cfg.search_max_hz);
rfIndex = (rfDecimation:rfDecimation:rawCount)';
assert(numel(rfIndex) >= (nv+2)*ifDecimation);
t = rxStart+(0:sampleCount-1)'/fs;
phase = @(u) 2*pi*((fc-bandwidth/2)*u+0.5*slope*u.^2);
txGate = double(t >= 0 & t < duration);
sineReference = amplitude*cos(phase(t)).*txGate;
sampledReference = adc16(sineReference);
% Match the existing retained output timestamps: indices 96, 128, ..., 21568.
% The first two decimated samples remain excluded to keep the frame layout.
sampleIndex = (96:32:96+(nv-1)*32)';
assert(sampleIndex(end) <= rawCount);
selectedReference = sampledReference(sampleIndex);
rfReference = sampledReference(rfIndex);
% CIC output timestamps still match the existing first/last retained points.
assert(isequal(rfIndex((3:2+nv)'*ifDecimation),sampleIndex));
filteredReference = cicCapture(round(sampledReference*32767),nv)/32767;
mixScale = 14000/amplitude^2;
halfDelta = readBinary(fullfile(src, 'SourceCode/ROM/main_window_delta.mem'));
halfWindow = 11597+cumsum(halfDelta);
window = [halfWindow; flipud(halfWindow)];
cosine = readBinary(fullfile(src, 'SourceCode/ROM/main_cos_quarter.mem'));
assert(numel(window) == nv && numel(cosine) == nfft/4+1);
assert(max(abs(window-floor(kaiser(nv,4)*2^17+0.5))) == 0);
lo = ceil(cfg.search_min_hz/(fsIF/nfft));
hi = floor(cfg.search_max_hz/(fsIF/nfft));
distances = (10:2.5:75)';
names = ["Previous IF baseline", "Sine TX, sampled reference", ...
    "Square TX, fundamental RX", "Square TX, digital reference", ...
    "Downsample first, then mix", "CIC on both RF channels, then mix", ...
    "RF /4, mix, CIC /8"];
estimates = zeros(numel(distances),numel(names));
bins = estimates; deltas = estimates;
peakStatus = strings(size(estimates));
peakPower = zeros(size(estimates));
sumAliasRange = zeros(numel(distances),2);
powerAll = zeros(nfft/2+1,numel(distances),numel(names));
captureAll = zeros(nv,numel(distances),numel(names));
quantizedMixerClips = zeros(numel(distances),numel(names));
qExample = 8; oversample = 32;
nonidealEstimates = zeros(numel(distances),2);
nonidealConvergence = zeros(numel(distances),1);
fixtureDir = fullfile(outputDir, 'baseline_fixture');
if ~isfolder(fixtureDir)
    unzip(fullfile(refFolder,'evidence.zip'),fixtureDir);
end
savedCapture = readtable(fullfile(fixtureDir,'distance_run/capture.csv'),'VariableNamingRule','preserve');
savedSpectrum = readtable(fullfile(fixtureDir,'distance_run/spectrum.csv'),'VariableNamingRule','preserve');
baselineExact = true;
for j = 1:numel(distances)
    tau = 2*(distances(j)/100)/c;
    echoGate = double(t >= tau & t-tau < duration);
    rxSine = amplitude*cos(phase(t-tau)).*echoGate;
    % Fundamental of a bipolar 50% square wave is (4/pi)*cos(phase).
    % This idealized transducer removes higher harmonics with no added delay.
    rxSquareFundamental = (4/pi)*rxSine;
    rxSineAdc = adc16(rxSine);
    rxSquareAdc = adc16(rxSquareFundamental);
    phaseDifference = 2*pi*((fc-bandwidth/2)*tau+slope*tau*t-0.5*slope*tau^2);
    baseline = fix(111+7000*echoGate.*txGate.*cos(phaseDifference));
    products = [baseline, ...
        fix(111+mixScale*rxSineAdc.*sampledReference), ...
        fix(111+mixScale*rxSquareAdc.*sampledReference), ...
        fix(111+mixScale*rxSquareAdc.*sineReference)];
    for k = 1:4
        quantizedMixerClips(j,k) = nnz(products(:,k)>32767 | products(:,k)<-32768);
        assert(quantizedMixerClips(j,k) == 0,'Mixer overflow: adjust explicit scaling.');
        [estimates(j,k),bins(j,k),deltas(j,k),pwr,cap,status] = ...
            backend(products(:,k),window,cosine,nfft,nv,fsIF,lo,hi);
        powerAll(:,j,k) = pwr;
        captureAll(:,j,k) = cap;
        peakStatus(j,k) = status;
        peakPower(j,k) = max(pwr(lo+1:hi+1));
        if k == 1
            baselineExact = baselineExact && isequal(cap,savedCapture.code(savedCapture.('case') == j-1));
            baselineExact = baselineExact && isequal(pwr,savedSpectrum.power(savedSpectrum.('case') == j-1));
            assert(bins(j,1) == reference.raw_bin(j));
            assert(deltas(j,1) == reference.delta_q16(j));
            assert(abs(estimates(j,1)-reference.interpolated_hz(j)) < 1e-9);
        end
    end
    % Requested order: BOTH RF inputs use identical /32 sample indices.
    % Do not use decimate(): its default anti-alias low-pass removes the RF.
    selectedRx = rxSquareAdc(sampleIndex);
    directProduct = fix(111+mixScale*selectedRx.*selectedReference);
    % Separate diagnostic: moving the existing CIC to both RF paths is NOT
    % equivalent to sample selection. Keep its absolute gain and ADC scaling.
    filteredRx = cicCapture(round(rxSquareAdc*32767),nv)/32767;
    filteredProduct = fix(111+mixScale*filteredRx.*filteredReference);
    newCaptures = [directProduct, filteredProduct];
    for branch = 1:2
        k = branch+4;
        cap = newCaptures(:,branch);
        quantizedMixerClips(j,k) = nnz(cap>32767 | cap<-32768);
        assert(quantizedMixerClips(j,k) == 0);
        [estimates(j,k),bins(j,k),deltas(j,k),pwr,cap,status] = ...
            analyzeCapture(cap,window,cosine,nfft,nv,fsIF,lo,hi);
        captureAll(:,j,k) = cap;
        powerAll(:,j,k) = pwr;
        peakStatus(j,k) = status;
        peakPower(j,k) = max(pwr(lo+1:hi+1));
    end
    % Revised main branch: input carrier and sum term are below RF Nyquist.
    rfRx = rxSquareAdc(rfIndex);
    rfProduct = fix(111+mixScale*rfRx.*rfReference);
    quantizedMixerClips(j,7) = nnz(rfProduct>32767 | rfProduct<-32768);
    assert(quantizedMixerClips(j,7) == 0);
    filteredCapture = cicCapture(rfProduct,nv,ifDecimation);
    [estimates(j,7),bins(j,7),deltas(j,7),pwr,cap,status] = ...
        analyzeCapture(filteredCapture,window,cosine,nfft,nv,fsIF,lo,hi);
    captureAll(:,j,7) = cap;
    powerAll(:,j,7) = pwr;
    peakStatus(j,7) = status;
    peakPower(j,7) = max(pwr(lo+1:hi+1));
    validTimes = t(sampleIndex);
    validTimes = validTimes(validTimes>=tau & validTimes<duration);
    sumAlias = 2*(fc-bandwidth/2)+slope*(2*validTimes-tau)-2*fsIF;
    sumAliasRange(j,:) = [min(sumAlias),max(sumAlias)];
    % Same-rate point selection and multiplication commute exactly. The
    % difference from the old path is omission of its post-mix CIC filter.
    assert(isequal(directProduct,products(sampleIndex,3)));
    % Separate sensitivity study: two causal resonators, one for each probe.
    % They operate BEFORE ADC sampling at an oversampled analog-model rate.
    [rxNonidealSine,rxNonidealSquare] = resonatorPair(tau,fs,sampleCount, ...
        rxStart,duration,fc,slope,amplitude,qExample,oversample);
    [~,rxSquareCoarse] = resonatorPair(tau,fs,sampleCount, ...
        rxStart,duration,fc,slope,amplitude,qExample,oversample/2);
    temp = [rxNonidealSine,rxNonidealSquare,rxSquareCoarse];
    tempEst = zeros(1,3);
    for k = 1:3
        v = fix(111+mixScale*adc16(temp(:,k)).*sampledReference);
        assert(all(v<32767 & v>-32768));
        tempEst(k) = backend(v,window,cosine,nfft,nv,fsIF,lo,hi);
    end
    nonidealEstimates(j,:) = tempEst(1:2);
    nonidealConvergence(j) = (tempEst(2)-tempEst(3))*c/(2*slope)*1000;
    if j == numel(distances)
        example = struct('time_s',t,'reference_analog',sineReference, ...
            'reference_sampled',sampledReference, ...
            'tx_square',amplitude*(2*(cos(phase(t))>=0)-1).*txGate, ...
            'rx_ideal_fundamental',rxSquareFundamental, ...
            'rx_ideal_sampled',rxSquareAdc,'digital_product',products(:,3), ...
            'rx_assumed_resonator_square',rxNonidealSquare, ...
            'fft_input',captureAll(:,j,3),'power',powerAll(:,j,3), ...
            'selected_time_s',t(sampleIndex), ...
            'selected_reference',selectedReference,'selected_rx',selectedRx, ...
            'downsample_first_product',directProduct, ...
            'downsample_first_fft_input',captureAll(:,j,5), ...
            'downsample_first_power',powerAll(:,j,5), ...
            'premix_cic_product',filteredProduct, ...
            'rf_time_s',t(rfIndex),'rf_reference',rfReference,'rf_rx',rfRx, ...
            'rf_product',rfProduct,'nyquist_main_capture',captureAll(:,j,7), ...
            'nyquist_main_power',powerAll(:,j,7));
    end
end
assert(baselineExact,'MATLAB baseline must reproduce saved RTL samples and powers exactly.');
assert(all(peakStatus(:,[1:5 7])=="valid",'all'), ...
    'The baseline or requested sample-selection path did not produce valid peaks.');
distanceEst = estimates*c/(2*slope)*100;
errors = (distanceEst-distances)*10;
nonidealError = (nonidealEstimates*c/(2*slope)*100-distances)*10;
metrics = table(names',max(abs(errors),[],1)',sqrt(mean(errors.^2,1))', ...
    'VariableNames',{'Case','MaxAbsError_mm','RMSE_mm'});
metrics.ValidPeaks = sum(peakStatus=="valid",1)';
results = table(distances,2*slope*(distances/100)/c, ...
    estimates(:,1),estimates(:,2),estimates(:,3),estimates(:,4), ...
    errors(:,1),errors(:,2),errors(:,3),errors(:,4), ...
    'VariableNames',{'Distance_cm','IdealBeat_Hz','Baseline_Hz','SineSampled_Hz', ...
    'SquareSampled_Hz','SquareDigitalReference_Hz','BaselineError_mm', ...
    'SineSampledError_mm','SquareSampledError_mm','SquareDigitalReferenceError_mm'});
nonideal = table(distances,nonidealError(:,1),nonidealError(:,2),nonidealConvergence, ...
    'VariableNames',{'Distance_cm','AssumedSineError_mm','AssumedSquareError_mm','Oversampling32vs16_mm'});
results.DownsampleFirst_Hz = estimates(:,5);
results.DownsampleFirstError_mm = errors(:,5);
results.DownsampleFirstBin = bins(:,5);
results.DownsampleFirstDeltaQ16 = deltas(:,5);
results.DownsampleFirstStatus = peakStatus(:,5);
results.PremixCic_Hz = estimates(:,6);
results.PremixCicError_mm = errors(:,6);
results.PremixCicStatus = peakStatus(:,6);
results.PremixCicPeakPower = peakPower(:,6);
results.SumAliasMin_Hz = sumAliasRange(:,1);
results.SumAliasMax_Hz = sumAliasRange(:,2);
results.NyquistMain_Hz = estimates(:,7);
results.NyquistMainError_mm = errors(:,7);
results.NyquistMainBin = bins(:,7);
results.NyquistMainDeltaQ16 = deltas(:,7);
results.NyquistMainStatus = peakStatus(:,7);
writetable(results,fullfile(outputDir,'distance_results.csv'));
writetable(metrics,fullfile(outputDir,'metrics.csv'));
writetable(nonideal,fullfile(outputDir,'assumed_resonator_results.csv'));
sumFrequencies = linspace(76000,84000,10001)';
Hcic = abs(sin(pi*32*sumFrequencies/fs)./(32*sin(pi*sumFrequencies/fs))).^3;
fStart = fc-bandwidth/2;
newCicSumGain = abs(sin(pi*ifDecimation*sumFrequencies/rfFs)./ ...
    (ifDecimation*sin(pi*sumFrequencies/rfFs))).^3;
passFrequencies = linspace(0.001,cfg.search_max_hz,10001)';
passGain = abs(sin(pi*ifDecimation*passFrequencies/rfFs)./ ...
    (ifDecimation*sin(pi*passFrequencies/rfFs))).^3;
% Independently verify /8 CIC against direct FIR convolution, with exact
% integer-valued coefficients, startup state, rounding and sample positions.
firCoefficients = conv(conv(ones(8,1),ones(8,1)),ones(8,1));
firProduct = filter(firCoefficients,1,example.rf_product);
firDecimated = floor((firProduct(8:8:end)+256)/512);
assert(isequal(firDecimated(3:2+nv),example.nyquist_main_capture));
nyquistStages = table(["Reference grid";"Previous RF /32";"New RF /4"; ...
    "New product before LPF";"Filtered beat /8"], ...
    [fs;fsIF;rfFs;rfFs;fsIF], [fs;fsIF;rfFs;rfFs;fsIF]/2, ...
    [42000;42000;42000;84000;cfg.search_max_hz], ...
    'VariableNames',{'Stage','SampleRate_Sps','Nyquist_Hz','WantedBandMax_Hz'});
nyquistStages.MainBandBelowNyquist = nyquistStages.Nyquist_Hz>nyquistStages.WantedBandMax_Hz;
writetable(nyquistStages,fullfile(outputDir,'sampling_rates.csv'));
summary = struct('parameters',cfg,'tx_center_hz',fc,'bandwidth_hz',bandwidth, ...
    'tx_duration_s',duration,'tx_amplitude',amplitude,'rx_delay_s',rxStart, ...
    'raw_fs_hz',fs,'fft_fs_hz',fsIF,'sound_speed_m_s',c,'adc_bits',16, ...
    'reference_skew_s',0,'additional_reference_delay_s',0, ...
    'distances_cm',distances','baseline_bit_exact_all_27',baselineExact, ...
    'max_reference_sampling_difference_mm',max(abs(errors(:,3)-errors(:,4))), ...
    'CIC_sum_band_worst_amplitude_dB',20*log10(max(Hcic)), ...
    'CIC_sum_band_best_amplitude_dB',20*log10(min(Hcic)), ...
    'sum_band_alias_hz',[76000-2*fsIF,84000-2*fsIF], ...
    'max_mixer_clipped_samples',max(quantizedMixerClips,[],'all'), ...
    'primary_model','Ideal square-wave fundamental RX and sine reference are sampled synchronously at raw_fs/4, multiplied, low-pass filtered by CIC3 and decimated /8, then processed by the unchanged 672-point Kaiser4 / 1024 FFT / log interpolation. No carrier or sum-term folding at the mixer input rate.', ...
    'version_date','2026-10-23', ...
    'main_case_index',7,'comparison_case_index',5, ...
    'nyquist_main',struct('rf_decimation',rfDecimation,'rf_fs_hz',rfFs, ...
       'rf_nyquist_hz',rfFs/2,'rf_band_hz',[38000,42000], ...
       'product_sum_band_upper_hz',84000,'if_decimation',ifDecimation, ...
       'if_fs_hz',fsIF,'if_nyquist_hz',fsIF/2, ...
       'fft_length',nfft,'effective_samples',nv,'zero_padding',nfft-nv, ...
       'rf_pairs_in_19ms',numel(rfIndex), ...
       'rf_pairs_needed_for_fft',(nv+2)*ifDecimation, ...
       'valid_peaks',sum(peakStatus(:,7)=="valid"), ...
       'cic_dc_gain',ifDecimation^3,'cic_sum_gain_db', ...
       [min(20*log10(newCicSumGain)),max(20*log10(newCicSumGain))], ...
       'cic_passband_0_to_2000Hz_max_droop_db',-min(20*log10(passGain)), ...
       'cic_group_delay_s',3*(ifDecimation-1)/(2*rfFs), ...
       'cic_direct_convolution_exact',true, ...
       'analog_model','Ideal fundamental only. Hardware input must be band-limited before low-rate ADC or decimation; no real analog anti-alias circuit is modeled.'), ...
    'previous_sample_selection',struct('factor',32,'first_raw_index_one_based',sampleIndex(1), ...
       'last_raw_index_one_based',sampleIndex(end),'retained_pairs',nv, ...
       'first_time_s',t(sampleIndex(1)),'last_time_s',t(sampleIndex(end)), ...
       'multiplications_per_frame',nv,'old_raw_multiplications_per_frame',rawCount), ...
    'rf_alias_band_hz',[fc-bandwidth/2,fc+bandwidth/2]-fsIF, ...
    'observed_sum_alias_range_hz',[min(sumAliasRange(:,1)),max(sumAliasRange(:,2))], ...
    'previous_direct32_valid_peaks',sum(peakStatus(:,5)=="valid"), ...
    'premix_cic_valid_peaks',sum(peakStatus(:,6)=="valid"), ...
    'premix_cic_max_peak_power',max(peakPower(:,6)), ...
    'premix_cic_single_channel_gain_db',20*log10(abs(sin(pi*32*[38000,40000,42000]/fs)./(32*sin(pi*[38000,40000,42000]/fs))).^3), ...
    'point_selection_mixing_commutes_exactly',true, ...
    'fpga_firmware_modified',false, ...
    'old_mcu_budget_superseded_for_this_main_branch',true, ...
    'backend','Main: RF /4 -> multiply -> CIC3 /8 -> mean removal -> 672 Kaiser4 -> 352 zeros -> original 1024 FFT and Q16 log-parabolic interpolation. FPGA production settings are not changed.', ...
    'extra_filter','Main now has an explicitly restored post-mix CIC3 low-pass /8. It suppresses the sum band before IF decimation. It is not a brick-wall filter; finite residual sum aliasing is retained in the result.', ...
    'assumed_resonator_model',struct('Q_per_probe',qExample,'resonance_hz',fc, ...
       'stages',2,'analog_oversampling',oversample,'measured_hardware_model',false, ...
       'sine_error_range_mm',[min(nonidealError(:,1)),max(nonidealError(:,1))], ...
       'square_error_range_mm',[min(nonidealError(:,2)),max(nonidealError(:,2))], ...
       'maximum_oversampling_change_mm',max(abs(nonidealConvergence))), ...
    'mcu',struct('part','STM32G431RBT6','max_cpu_hz',170e6,'sram_bytes',32*1024, ...
       'native_adc_bits',12,'max_native_adc_rate_sps',4e6, ...
       'raw_frame_samples',rawCount,'one_channel_frame_bytes',2*rawCount, ...
       'two_channel_frame_bytes',4*rawCount,'cpu_cycles_per_sample_pair',170e6/fs, ...
       'rfft_input_output_float32_bytes',2*nfft*4,'benchmark_measured',false), ...
    'source_urls',{{'https://www.st.com/resource/en/datasheet/stm32g431rb.pdf', ...
       'https://www.st.com/content/ccc/resource/technical/document/application_note/group0/c1/ee/18/7a/f9/45/45/3b/DM00273990/files/DM00273990.pdf/jcr:content/translations/en.DM00273990.pdf', ...
       'https://www.murata.com/~/media/webrenewal/products/sensor/ultrasonic/open/ma40s4s-e.ashx?la=en-us'}});
summary.metrics = table2struct(metrics);
writeText(fullfile(outputDir,'checks.json'),jsonencode(summary,PrettyPrint=true));
save(fullfile(outputDir,'simulation_data.mat'),'summary','results','metrics','nonideal', ...
    'example','captureAll','powerAll','window','cosine','fStart', ...
    'sampleIndex','rfIndex','nyquistStages','peakStatus','peakPower','sumAliasRange','-v7');
selectedSamples = table(example.selected_time_s,example.selected_reference, ...
    example.selected_rx,example.downsample_first_product, ...
    'VariableNames',{'Time_s','Reference_sample','RX_sample','Mixer_code'});
writetable(selectedSamples,fullfile(outputDir,'example_75cm_selected_samples.csv'));
rfSamples = table(example.rf_time_s,example.rf_reference,example.rf_rx,example.rf_product, ...
    'VariableNames',{'Time_s','Reference_sample','RX_sample','Mixer_code'});
writetable(rfSamples,fullfile(outputDir,'example_75cm_rf_samples.csv'));
fig = figure('Color','w','Position',[100 100 1300 730],'Name','Square Chirp MATLAB Comparison');
ax = axes(fig); hold(ax,'on');
plot(ax,distances,errors(:,5),'-o','Color',[.5 .56 .61],'LineWidth',1.4,'MarkerSize',5);
plot(ax,distances,errors(:,7),'-d','Color',[.07 .43 .63],'LineWidth',1.8,'MarkerSize',5);
yline(ax,0,'Color',[.55 .62 .67]); grid(ax,'on');
title(ax,'Distance Error: Higher-Rate RF Sampling','FontSize',24,'FontWeight','bold');
xlabel(ax,'Reflector distance (cm)'); ylabel(ax,'Distance error (mm)');
set(ax,'FontName','Arial','FontSize',13,'XTick',distances,'XLim',[9 76],'Box','off');
legend(ax,["Previous: RF 35.8 kS/s","New: RF 286.5 kS/s + LPF"],'Location','southoutside','Orientation','horizontal','FontSize',12);
exportgraphics(fig,fullfile(outputDir,'distance_error_EN.png'),'Resolution',220,'Padding',12);
writeReport(outputDir,summary,metrics);
disp(metrics);
disp(summary.assumed_resonator_model);
disp("Baseline matched all saved RTL captures, FFT powers, bins and Q16 offsets.");
disp("Results: "+string(outputDir));
end

function q = adc16(v)
q = min(max(fix(v*32767),-32768),32767)/32767;
end

function values = readBinary(filename)
lines = strip(readlines(filename));lines(lines == "") = [];
values = bin2dec(char(lines));
end

function [f,k,deltaQ,power,capture,status] = backend(raw,window,cosine,nfft,nv,fsIF,lo,hi)
capture = cicCapture(raw,nv);
[f,k,deltaQ,power,capture,status] = analyzeCapture(capture,window,cosine,nfft,nv,fsIF,lo,hi);
end

function capture = cicCapture(raw,nv,factor)
% FIR-equivalent CIC3, zero initial state, integer rounding before truncation.
if nargin < 3, factor = 32; end
y = raw;
for stage = 1:3
    a = cumsum(y);
    y = a;
    y(factor+1:end) = a(factor+1:end)-a(1:end-factor);
end
gain = factor^3;
y = floor((y(factor:factor:end)+gain/2)/gain);
capture = y(3:2+nv); % Two warm-up outputs are discarded by production RTL.
end

function [f,k,deltaQ,power,capture,status] = analyzeCapture(capture,window,cosine,nfft,nv,fsIF,lo,hi)
% Invalid cases remain explicit; never normalize a weak branch into a pass.
f = NaN;
deltaQ = 0;
status = "below_threshold";
centered = min(max(capture-fix(sum(capture)/nv),-32768),32767);
[re,im] = fixedFFT(centered,window,cosine,nfft);
power = re.^2+im.^2;
[best,index] = max(power(lo+1:hi+1));k = lo+index-1;
if best < 6400, return; end
neighbors = power(k:k+2);
if any(neighbors<=0) || neighbors(2)<max(neighbors)
    status = "invalid_neighbors";
    return;
end
logs = arrayfun(@fixedLog2,neighbors);
denominator = logs(1)-2*logs(2)+logs(3);
if denominator >= 0
    status = "invalid_curvature";
    return;
end
num = logs(1)-logs(3);
deltaQ = sign(num/denominator)*min(32768,floor(abs(num)*32768/abs(denominator)));
f = (k+deltaQ/65536)*fsIF/nfft;
status = "valid";
end

function out = fixedLog2(p)
exponent = floor(log2(p));x = floor(p*2^(24-exponent));fraction = 0;
for step = 1:16
    sq = x*x;bit = double(sq>=2^49);
    if bit, x=floor(sq/2^25);else, x=floor(sq/2^24);end
    fraction = 2*fraction+bit;
end
out = exponent*65536+fraction;
end

function [outR,outI] = fixedFFT(x,w,cosine,n)
% Integer-valued doubles represent every intermediate exactly below 2^53.
% Matches the existing fft_reference.py and production packed real FFT.
m = n/2;q = n/4;
v = shiftRound(x.*w,14);
pr=zeros(m,1);pi_=zeros(m,1);
pr(1:numel(v)/2)=v(1:2:end);pi_(1:numel(v)/2)=v(2:2:end);
indices=uint32((0:m-1)');rev=zeros(m,1);
for b=0:log2(m)-1, rev=rev+double(bitget(indices,b+1))*2^(log2(m)-1-b);end
re=pr(rev+1);im=pi_(rev+1);
span=2;
while span<=m
    half=span/2;[wr,wi]=twiddle((0:half-1)'*(n/span),cosine,n);
    for base=1:span:m
        ia=base:base+half-1;ib=ia+half;
        ar=re(ia);ai=im(ia);br=re(ib);bi=im(ib);
        tr=shiftRound(br.*wr-bi.*wi,17);ti=shiftRound(br.*wi+bi.*wr,17);
        re(ia)=clip20(shiftRound(ar+tr,1));im(ia)=clip20(shiftRound(ai+ti,1));
        re(ib)=clip20(shiftRound(ar-tr,1));im(ib)=clip20(shiftRound(ai-ti,1));
    end
    span=span*2;
end
outR=zeros(m+1,1);outI=zeros(m+1,1);
outR(1)=clip20(shiftRound(re(1)+im(1),1));outR(m+1)=clip20(shiftRound(re(1)-im(1),1));
k=(1:q-1)';a=re(k+1);b=im(k+1);cc=re(m-k+1);d=im(m-k+1);
sr=a+cc;si=b-d;dr=a-cc;di=b+d;[wr,wi]=twiddle(k,cosine,n);
tr=shiftRound(dr.*wr-di.*wi,17);ti=shiftRound(dr.*wi+di.*wr,17);
outR(k+1)=clip20(shiftRound(sr+ti,2));outI(k+1)=clip20(shiftRound(si-tr,2));
outR(m-k+1)=clip20(shiftRound(sr-ti,2));outI(m-k+1)=clip20(shiftRound(-si-tr,2));
outR(q+1)=clip20(shiftRound(re(q+1),1));outI(q+1)=clip20(shiftRound(-im(q+1),1));
end

function [wr,wi] = twiddle(phase,cosine,n)
q=n/4;m=n/2;
wr=cosine(min(phase,m-phase)+1);wr(phase>q)=-wr(phase>q);
wi=-cosine(abs(q-phase)+1);
end

function y = shiftRound(x,bits)
y=floor((x+2^(bits-1))/2^bits);
end

function y = clip20(x)
assert(all(x>=-2^19 & x<=2^19-1),'20-bit FFT overflow.');y=x;
end

function [sineRx,squareRx] = resonatorPair(tau,fs,count,rxStart,duration,fc,slope,A,Q,L)
analogFs=fs*L;pre=ceil(rxStart*analogFs);
time=rxStart+(-pre:(count-1)*L)'/analogFs;
u=time-tau;gate=double(u>=0 & u<duration);
p=2*pi*((fc-2000)*u+.5*slope*u.^2);
sineIn=A*cos(p).*gate;squareIn=A*(2*(cos(p)>=0)-1).*gate;
w0=2*pi*fc;[b,a]=bilinear([w0/Q 0],[1 w0/Q w0^2],analogFs,fc);
sineOut=filter(b,a,filter(b,a,sineIn));squareOut=filter(b,a,filter(b,a,squareIn));
idx=pre+1+(0:count-1)*L;sineRx=sineOut(idx);squareRx=squareOut(idx);
end

function writeText(filename,text)
f=fopen(filename,'w','n','UTF-8');assert(f>=0);cleaner=onCleanup(@() fclose(f));
fprintf(f,'%s',text);
end

function writeReport(folder,s,metrics)
metricRows = "";
for j = [3 5 7]
    metricRows = metricRows+sprintf( ...
        '<tr><td>%s</td><td>%.6f</td><td>%.6f</td><td>%d / 27</td></tr>', ...
        metrics.Case(j),metrics.MaxAbsError_mm(j),metrics.RMSE_mm(j),metrics.ValidPeaks(j));
end
html = "<!doctype html><html lang='zh-CN'><meta charset='utf-8'><title>Higher-Rate RF Sampling</title>"+ ...
    "<style>body{font:16px/1.8 system-ui,'Microsoft YaHei',sans-serif;max-width:1100px;margin:32px auto;padding:0 24px;color:#193a51}img{width:100%}table{border-collapse:collapse;width:100%}td,th{padding:10px;border-bottom:1px solid #d5e1e9;text-align:left}code{background:#edf3f6}a{color:#126f9d}</style>"+ ...
    "<h1>提高混频前采样率，保持原 FFT 窗口</h1><p>2026-10-23。修改并运行 MATLAB 模型；生产 FPGA、SOF、上位机均未修改。上一版完整脚本和结果备份为 <a href='../before_nyquist_sampling_20261023.zip'>before_nyquist_sampling_20261023.zip</a>。</p>"+ ...
    "<h2>奈奎斯特检查</h2><p>奈奎斯特频率 fN=fs/2；常规无载波混叠采样要求 fN 大于输入最高有效频率。当前近似正弦 RX 与参考的扫频范围为38–42 kHz，因此采样率应高于84 kS/s并留余量。上一版35.807 kS/s的奈奎斯特频率仅17.904 kHz，属于利用频带折叠的欠采样对照，不是普通无载波混叠采样。</p>"+ ...
    "<p>本版选择原时间网格的 /4：286.458 kS/s，奈奎斯特频率143.229 kHz，既高于42 kHz输入，也高于两路相乘后最高84 kHz和频。相乘后再CIC3低通 /8，FFT输入回到35.807 kS/s；此时目标已经是25–2000 Hz拍频，不再是40 kHz载波。</p>"+ ...
    "<table><tr><th>位置</th><th>采样率</th><th>奈奎斯特频率</th><th>处理信号</th></tr><tr><td>旧版混频前</td><td>35.807 kS/s</td><td>17.904 kHz</td><td>38–42 kHz：载波折叠</td></tr><tr><td>新版混频前及乘法</td><td>286.458 kS/s</td><td>143.229 kHz</td><td>输入≤42 kHz；乘积和频≤84 kHz</td></tr><tr><td>低通 /8 后的 FFT</td><td>35.807 kS/s</td><td>17.904 kHz</td><td>目标25–2000 Hz拍频</td></tr></table>"+ ...
    "<p><b>新版流程：</b>同源方波TX与正弦参考 → 理想换能器基波RX → 两路同步按286.458 kS/s取样（原网格 /4）→ 相乘 → CIC3低通 /8 → 672点去均值 → Kaiser4 → 补352零 → 1024 FFT → 25–2000 Hz搜峰 → 同款Q16对数插值 → 距离。</p>"+ ...
    "<p>保持40 kHz中心、4 kHz带宽、20 ms发射、1 ms接收延迟、19 ms接收窗口、幅度0.25、343 m/s声速、理想16位ADC、672点Kaiser4、1024 FFT及原插值公式。两级降采样总比仍为32；有效输出时间仍为1.082909–19.822109 ms，未因提高RF采样率而缩短观测窗口。</p>"+ ...
    sprintf("<p>19 ms内约%d对RF采样；本帧672个FFT有效点及启动丢弃实际需要%d对。可以分块相乘和滤波，无需把整段双路RF数组同时放进MCU RAM。混频运算多于上一版672次，但仍低于最初高速约21770次；FFT工作区仍按1024点预算。</p>",s.nyquist_main.rf_pairs_in_19ms,s.nyquist_main.rf_pairs_needed_for_fft)+ ...
    "<img src='distance_error_EN.png'><table><tr><th>Case</th><th>Max |error| / mm</th><th>RMSE / mm</th><th>Valid peaks</th></tr>"+metricRows+"</table>"+ ...
    "<h2>低通滤波与误差边界</h2>"+ ...
    sprintf("<p>恢复的是混频后的CIC3，抽取比改为8，DC增益512并归一化。76–84 kHz和频的幅度衰减为 %.2f 至 %.2f dB；0–2000 Hz最大幅度下降约%.4f dB，群延迟%.3f微秒。计算包含真实因果启动、整数舍入和有限阻带残留，没有用理想砖墙滤波器或已知距离修正结果。</p>",s.nyquist_main.cic_sum_gain_db,s.nyquist_main.cic_passband_0_to_2000Hz_max_droop_db,1e6*s.nyquist_main.cic_group_delay_s)+ ...
    "<p>高RF采样率使两路基波与相乘和频不在混频阶段折叠；后续低通再降采样仍有有限阻带残留，不能称为所有频率绝对无混叠。该残留已保留在数值仿真中。新增 /8 CIC在75 cm完整帧与直接FIR卷积逐点一致。</p>"+ ...
    "<p>主图仍是单回波、理想基波换能器模型，无噪声、多径、额外群延迟或ADC时钟误差。原始理想方波含无限多谐波，不能把42 kHz当成其完整带宽；这里采样的是换能器后的近似正弦RX和正弦参考。实物仍需在ADC前限制有效模拟带宽，残余谐波和干扰需另测。</p>"+ ...
    "<p>此次只增加MATLAB仿真分支，原来的27组RTL基线、全部FFT功率和Q16插值结果继续逐点通过复现。没有重新烧录FPGA，没有MCU运行时间或实物抗混叠滤波器验证。原资源预算需要按新的286.458 kS/s混频与CIC /8重新核算。</p>"+ ...
    "<p><a href='https://www.mathworks.com/help/daq/making-quality-measurements.html'>MathWorks：奈奎斯特频率</a> · <a href='https://www.mathworks.com/help/dsp/ug/design-of-decimatorsinterpolators.html'>滤波后降采样</a></p>"+ ...
    "<p><a href='distance_results.csv'>27点结果</a> · <a href='sampling_rates.csv'>逐级采样率</a> · <a href='checks.json'>检查与参数</a> · <a href='example_75cm_rf_samples.csv'>75 cm高采样率两路样本与乘积</a> · <a href='simulation_data.mat'>MATLAB完整数据</a></p></html>";
writeText(fullfile(folder,'report.html'),html);
end
