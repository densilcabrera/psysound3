function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

% fs          = get(obj, 'fs');
% N           = get(obj, 'windowLength');
% N2          = N/2;
% frequencies = (0:N2-1) / fs; % row vect
frequencies = [27.5 29.1 30.9 32.7 34.6 36.7 38.9 41.2 43.7 46.2 49 51.9 55 58.3 61.7 65.4 69.3 73.4 77.8 82.4 87.3 92.5 98 103.8 110 116.5 123.5 130.8 138.6 146.8 155.6 164.8 174.6 185 196 207.7 220 233.1 246.9 261.6 277.2 293.7 311.1 329.6 349.2 370 392 415.3 440 466.2 493.9 523.3 554.4 587.3 622.3 659.3 698.5 740 784 830.6 880 932.3 987.8 1046.5 1108.7 1174.7 1244.5 1318.5 1396.9 1480 1568 1661.2 1760 1864.7 1975.5 2093 2217.5 2349.3 2489 2637 2793.8 2960 3136 3322.4 3520 3729.3 3951.1 4186 4434.9 4698.6 4978 5274 5587.7 5919.9 6271.9 6644.9 7040 7458.6 7902.1 8372 8869.8 9397.3 9956.1 10548.1 11175.3 11839.8 12543.9 13289.8]';
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