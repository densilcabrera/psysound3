function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

% fs          = get(obj, 'fs');
% N           = get(obj, 'windowLength');
% N2          = N/2;
% frequencies = (0:N2-1) / fs; % row vect
frequencies = [20	21.1	22.4	23.7	25.1	26.6	28.2	29.9	31.6	33.5	35.5	37.6	39.8	42.2	44.7	47.3	50.1	53.1	56.2	59.6	63.1	66.8	70.8	75	79.4	84.1	89.1	94.4	100	106	112	119	126	133	141	150	158	168	178	188	200	211	224	237	251	266	282	299	316	335	355	376	398	422	447	473	501	531	562	596	631	668	708	750	794	841	891	944	1000	1059	1122	1189	1259	1334	1413	1496	1585	1679	1778	1884	1995	2113	2239	2371	2512	2661	2818	2985	3162	3350	3548	3758	3981	4217	4467	4732	5012	5309	5623	5957	6310	6683	7079	7499	7943	8414	8913	9441	10000	10593	11220	11885	12589	13335	14125	14962	15849	16788	17783	18836	19953]';
chan = get(obj,'channels');
if chan == 1
    % Create the third oct band Time Spectrum
    RawPowSpec = dataBuffer.twelfthoctspec.get();
    PowSpec = power2dB(RawPowSpec) + getlevelOffset(obj);
    tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, ...
        TimePoints);

    tSpec.Name     = '1/12-Oct Spectrogram';
    tSpec.DataName = 'Magnitude';
    tSpec.DataUnit = 'dB';
    tSpec.FreqName = 'Frequency';
    tSpec.FreqUnit = 'Hz';
    % tSpec.FreqScale = 'log';

    % Create the averaged Spectrum
    avPowSpec = power2dB(mean(RawPowSpec, 1)) + getlevelOffset(obj);
    avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);

    avSpec.Name  = '1/12-Oct Spectrum';
    avSpec.DataName = 'Magnitude';
    avSpec.DataUnit = 'dB';
    avSpec.FreqName = 'Frequency';
    avSpec.FreqUnit = 'Hz';
    avSpec.FreqScale = 'log';


%     tstep   = diff(TimePoints(1:2));


%     % Create Time series for the higher-order statistics
%     moments   = dataBuffer.moments.get();
%     SD        = dataBuffer.SD.get();
%     kurtosis  = dataBuffer.kurtosis.get();
%     skewness  = dataBuffer.skewness.get();
%     level = power2dB(dataBuffer.level.get())+ getlevelOffset(obj);
%     bigMatrix = [moments, SD, skewness, kurtosis, level];
%     tags      = {'Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
%         'Spectral 2nd Moment', 'Frequency (Hz)' ;...
%         'Spectral 3rd Moment', 'Frequency (Hz)' ;...
%         'Spectral 4th Moment', 'Frequency (Hz)' ;...
%         'Standard deviation',  'Frequency (Hz)' ;...
%         'Skewness',            'units'; ...
%         'Kurtosis',            'units'; ...
%         'Level',            'dB'};
% 
%     tsArray = {};
%     tstep   = diff(TimePoints(1:2));
%     for i=1:length(tags)
%         ts = createDataObject('tSeries', bigMatrix(:, i));
%         ts = set(ts, 'Name', tags{i, 1});
% 
%         % Set the increment
%         ts.TimeInfo.Increment = tstep;
% 
%         % Stick this tag in the data info so that we pick it up as ylabel
%         % in PlotResult
%         ts.DataInfo.Units = tags{i, 2};
% 
%         % Assign to cell array
%         tsArray{i} = ts;
%     end

    % Assign outputs to the object
%     out = {tSpec, avSpec, tsArray{:}};
    out = {tSpec, avSpec};
    obj = set(obj, 'output', out);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if chan == 2
        % Create the third oct band Time Spectrum
    RawPowSpecL = (dataBuffer.twelfthoctspecL.get());
    RawPowSpecR = (dataBuffer.twelfthoctspecR.get());
    PowSpecLR = power2dB(0.5.*(RawPowSpecL+RawPowSpecR)) + getlevelOffset(obj);
    PowSpecL = power2dB(RawPowSpecL) + getlevelOffset(obj);
    PowSpecR = power2dB(RawPowSpecR) + getlevelOffset(obj);

     tSpecLR   = createDataObject('tSpectrum', frequencies, PowSpecLR, ...
        TimePoints);

    tSpecLR.Name     = '1/12-Oct Spectrogram LR Average';
    tSpecLR.DataName = 'Magnitude';
    tSpecLR.DataUnit = 'dB';
    tSpecLR.FreqName = 'Frequency';
    tSpecLR.FreqUnit = 'Hz';
    % tSpecLR.FreqScale = 'log';
    
    tSpecL   = createDataObject('tSpectrum', frequencies, PowSpecL, ...
        TimePoints);

    tSpecL.Name     = '1/12-Oct Spectrogram Left';
    tSpecL.DataName = 'Magnitude';
    tSpecL.DataUnit = 'dB';
    tSpecL.FreqName = 'Frequency';
    tSpecL.FreqUnit = 'Hz';
    % tSpecL.FreqScale = 'log';
    
    tSpecR   = createDataObject('tSpectrum', frequencies, PowSpecR, ...
        TimePoints);

    tSpecR.Name     = '1/12-Oct Spectrogram Right';
    tSpecR.DataName = 'Magnitude';
    tSpecR.DataUnit = 'dB';
    tSpecR.FreqName = 'Frequency';
    tSpecR.FreqUnit = 'Hz';
    % tSpecR.FreqScale = 'log';
    
    DiffSpec = PowSpecR - PowSpecL;
    tDiffSpec = createDataObject('tSpectrum', frequencies, DiffSpec, ...
        TimePoints);
    tDiffSpec.Name     = '1/12-Oct Spectrogram R-L Difference';
    tDiffSpec.DataName = 'Magnitude';
    tDiffSpec.DataUnit = 'dB';
    tDiffSpec.FreqName = 'Frequency';
    tDiffSpec.FreqUnit = 'Hz';
    % tDiffSpec.FreqScale = 'log';
    
    
    
    % Create the averaged Spectrum
    avPowSpecLR = 10*log10(mean(10.^(PowSpecLR.*0.1), 1));
    avSpecLR    = createDataObject('Spectrum', frequencies, avPowSpecLR);

    avSpecLR.Name  = '1/2-Oct Spectrum LR Average';
    avSpecLR.DataName = 'Magnitude';
    avSpecLR.DataUnit = 'dB';
    avSpecLR.FreqName = 'Frequency';
    avSpecLR.FreqUnit = 'Hz';
    avSpecLR.FreqScale = 'log';
    

        avPowSpecL = 10*log10(mean(10.^(PowSpecL.*0.1), 1));
    avSpecL    = createDataObject('Spectrum', frequencies, avPowSpecL);

    avSpecL.Name  = '1/12-Oct Band Spectrum Left';
    avSpecL.DataName = 'Magnitude';
    avSpecL.DataUnit = 'dB';
    avSpecL.FreqName = 'Frequency';
    avSpecL.FreqUnit = 'Hz';
    avSpecL.FreqScale = 'log';
    
    
        avPowSpecR = 10*log10(mean(10.^(PowSpecR.*0.1), 1));
    avSpecR    = createDataObject('Spectrum', frequencies, avPowSpecR);

    avSpecR.Name  = '1/12-Oct Spectrum Right';
    avSpecR.DataName = 'Magnitude';
    avSpecR.DataUnit = 'dB';
    avSpecR.FreqName = 'Frequency';
    avSpecR.FreqUnit = 'Hz';
    avSpecR.FreqScale = 'log';
    
    
        avDiffSpec = 10*log10(mean(10.^(DiffSpec.*0.1), 1));
    avSpecDiff    = createDataObject('Spectrum', frequencies, avDiffSpec);

    avSpecDiff.Name  = '1/12-Oct Spectrum LR Average';
    avSpecDiff.DataName = 'Magnitude';
    avSpecDiff.DataUnit = 'dB';
    avSpecDiff.FreqName = 'Frequency';
    avSpecDiff.FreqUnit = 'Hz';
    avSpecDiff.FreqScale = 'log';
    
    
    
%     tstep   = diff(TimePoints(1:2));


%     % Create Time series for the higher-order statistics
%     moments   = dataBuffer.moments.get();
%     SD        = dataBuffer.SD.get();
%     kurtosis  = dataBuffer.kurtosis.get();
%     skewness  = dataBuffer.skewness.get();
%     level = power2dB(dataBuffer.level.get())+ getlevelOffset(obj);
%     bigMatrix = [moments, SD, skewness, kurtosis, level];
%     tags      = {'Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
%         'Spectral 2nd Moment', 'Frequency (Hz)' ;...
%         'Spectral 3rd Moment', 'Frequency (Hz)' ;...
%         'Spectral 4th Moment', 'Frequency (Hz)' ;...
%         'Standard deviation',  'Frequency (Hz)' ;...
%         'Skewness',            'units'; ...
%         'Kurtosis',            'units'; ...
%         'Level',            'dB'};
% 
%     tsArray = {};
%     tstep   = diff(TimePoints(1:2));
%     for i=1:length(tags)
%         ts = createDataObject('tSeries', bigMatrix(:, i));
%         ts = set(ts, 'Name', tags{i, 1});
% 
%         % Set the increment
%         ts.TimeInfo.Increment = tstep;
% 
%         % Stick this tag in the data info so that we pick it up as ylabel
%         % in PlotResult
%         ts.DataInfo.Units = tags{i, 2};
% 
%         % Assign to cell array
%         tsArray{i} = ts;
%     end

    % Assign outputs to the obect
%    out = {tSpec, avSpec, tsArray{:}};
    out = {tSpecL, tSpecR, tSpecLR, tDiffSpec, avSpecLR, avSpecL, avSpecR, avSpecDiff};
    obj = set(obj, 'output', out);
end
% end constructDataObjects