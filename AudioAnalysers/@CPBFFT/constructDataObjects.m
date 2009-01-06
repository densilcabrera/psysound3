function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

% fs          = get(obj, 'fs');
% N           = get(obj, 'windowLength');
% N2          = N/2;
% frequencies = (0:N2-1) / fs; % row vect
frequencies = [12.5 16 20 25 31.5 40 50 63 80 100 125 160 200 250 320 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000]';
for i = 1:length(frequencies)
    frequenciesStr{i} = num2str(frequencies(i));
end
frequencies = frequenciesStr;

chan = get(obj,'channels');
if chan == 1
% Create the third oct band Time Spectrum
    RawPowSpec = dataBuffer.thirdoctspec.get();
    PowSpec = power2dB(RawPowSpec) + getlevelOffset(obj);
%PowSpec = power2dB(dataBuffer.thirdoctspec.get()) + getlevelOffset(obj);
tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, ...
                           TimePoints);

tSpec.Name     = 'One-third Octave Band Spectrogram';
tSpec.DataName = 'Magnitude';
tSpec.DataUnit = 'dB';
tSpec.FreqName = 'Frequency';
tSpec.FreqUnit = 'Hz';
% tSpec.FreqScale = 'log';

% Create the averaged Spectrum
avPowSpec = power2dB(mean(RawPowSpec, 1))+ getlevelOffset(obj);
avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);

avSpec.Name  = 'One-third Octave Band Spectrum';
avSpec.DataName = 'Magnitude';
avSpec.DataUnit = 'dB';
avSpec.FreqName = 'Frequency';
avSpec.FreqUnit = 'Hz';
avSpec.FreqScale = 'log';

% Create the octave band time spectrum
octfrequencies = [16 31.5 63 125 250 500 1000 2000 4000 8000 16000]';
for i = 1:length(octfrequencies)
    octfrequenciesStr{i} = num2str(octfrequencies(i));
end
octfrequencies = octfrequenciesStr;


%PowSpecOct = power2dB(dataBuffer.octspec.get()) + getlevelOffset(obj);
    RawPowSpecOct = dataBuffer.octspec.get();
    PowSpecOct = power2dB(RawPowSpecOct) + getlevelOffset(obj);
tSpec2   = createDataObject('tSpectrum', octfrequencies, PowSpecOct, ...
                           TimePoints);

tSpec2.Name     = 'Octave band spectrogram';
tSpec2.DataName = 'Magnitude';
tSpec2.DataUnit = 'dB';
tSpec2.FreqName = 'Frequency';
tSpec2.FreqUnit = 'Hz';
% tSpec2.FreqScale = 'log';


% Create the averaged octave band Spectrum
avPowSpecOct = power2dB(mean(RawPowSpecOct, 1))+ getlevelOffset(obj);
avSpec2    = createDataObject('Spectrum', octfrequencies, avPowSpecOct);

avSpec2.Name  = 'Octave Band Spectrum';
avSpec2.DataName = 'Magnitude';
avSpec2.DataUnit = 'dB';
avSpec2.FreqName = 'Frequency';
avSpec2.FreqUnit = 'Hz';
avSpec2.FreqScale = 'log';


% tstep   = diff(TimePoints(1:2));
% 
% 
% % Create Time series for the higher-order statistics
% moments   = dataBuffer.moments.get();
% SD        = dataBuffer.SD.get();
% kurtosis  = dataBuffer.kurtosis.get();
% skewness  = dataBuffer.skewness.get();
% level = power2dB(dataBuffer.level.get())+ getlevelOffset(obj);
% bigMatrix = [moments, SD, skewness, kurtosis, level];
% tags      = {'Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
%              'Spectral 2nd Moment', 'Frequency (Hz)' ;...
%              'Spectral 3rd Moment', 'Frequency (Hz)' ;...
%              'Spectral 4th Moment', 'Frequency (Hz)' ;...
%              'Standard deviation',  'Frequency (Hz)' ;...
%              'Skewness',            'units'; ...
%              'Kurtosis',            'units'; ...
%              'Level',            'dB'};
% 
% tsArray = {};
% tstep   = diff(TimePoints(1:2));
% for i=1:length(tags)
%   ts = createDataObject('tSeries', bigMatrix(:, i));
%   ts = set(ts, 'Name', tags{i, 1});
%   
%   % Set the increment
%   ts.TimeInfo.Increment = tstep;
% 
%   % Stick this tag in the data info so that we pick it up as ylabel
%   % in PlotResult
%   ts.DataInfo.Units = tags{i, 2};
%   
%   % Assign to cell array
%   tsArray{i} = ts;


% Assign outputs to the object
out = {tSpec, avSpec, tSpec2, avSpec2};
obj = set(obj, 'output', out);
end

if chan == 2
    
    % Create the third oct band Time Spectrum
    RawPowSpecL = (dataBuffer.thirdoctspecL.get());
    RawPowSpecR = (dataBuffer.thirdoctspecR.get());
    PowSpecLR = power2dB(0.5.*(RawPowSpecL+RawPowSpecR)) + getlevelOffset(obj);
    PowSpecL = power2dB(RawPowSpecL) + getlevelOffset(obj);
    PowSpecR = power2dB(RawPowSpecR) + getlevelOffset(obj);

     tSpecLR   = createDataObject('tSpectrum', frequencies, PowSpecLR, ...
        TimePoints);

    tSpecLR.Name     = '1/3-Oct Spectrogram LR Average';
    tSpecLR.DataName = 'Magnitude';
    tSpecLR.DataUnit = 'dB';
    tSpecLR.FreqName = 'Frequency';
    tSpecLR.FreqUnit = 'Hz';
    % tSpecLR.FreqScale = 'log';
    
    tSpecL   = createDataObject('tSpectrum', frequencies, PowSpecL, ...
        TimePoints);

    tSpecL.Name     = '1/3-Oct Spectrogram Left';
    tSpecL.DataName = 'Magnitude';
    tSpecL.DataUnit = 'dB';
    tSpecL.FreqName = 'Frequency';
    tSpecL.FreqUnit = 'Hz';
    % tSpecL.FreqScale = 'log';
    
    tSpecR   = createDataObject('tSpectrum', frequencies, PowSpecR, ...
        TimePoints);

    tSpecR.Name     = '1/3-Oct Spectrogram Right';
    tSpecR.DataName = 'Magnitude';
    tSpecR.DataUnit = 'dB';
    tSpecR.FreqName = 'Frequency';
    tSpecR.FreqUnit = 'Hz';
    % tSpecR.FreqScale = 'log';
    
    DiffSpec = PowSpecR - PowSpecL;
    tDiffSpec = createDataObject('tSpectrum', frequencies, DiffSpec, ...
        TimePoints);
    tDiffSpec.Name     = '1/3-Oct Spectrogram R-L Difference';
    tDiffSpec.DataName = 'Magnitude';
    tDiffSpec.DataUnit = 'dB';
    tDiffSpec.FreqName = 'Frequency';
    tDiffSpec.FreqUnit = 'Hz';
    % tDiffSpec.FreqScale = 'log';
    
    
    
    % Create the averaged Spectrum
    avPowSpecLR = 10*log10(mean(10.^(PowSpecLR.*0.1), 1));
    avSpecLR    = createDataObject('Spectrum', frequencies, avPowSpecLR);

    avSpecLR.Name  = '1/3-Oct Spectrum LR Average';
    avSpecLR.DataName = 'Magnitude';
    avSpecLR.DataUnit = 'dB';
    avSpecLR.FreqName = 'Frequency';
    avSpecLR.FreqUnit = 'Hz';
    avSpecLR.FreqScale = 'log';
    

        avPowSpecL = 10*log10(mean(10.^(PowSpecL.*0.1), 1));
    avSpecL    = createDataObject('Spectrum', frequencies, avPowSpecL);

    avSpecL.Name  = '1/3-Oct Band Spectrum Left';
    avSpecL.DataName = 'Magnitude';
    avSpecL.DataUnit = 'dB';
    avSpecL.FreqName = 'Frequency';
    avSpecL.FreqUnit = 'Hz';
    avSpecL.FreqScale = 'log';
    
    
        avPowSpecR = 10*log10(mean(10.^(PowSpecR.*0.1), 1));
    avSpecR    = createDataObject('Spectrum', frequencies, avPowSpecR);

    avSpecR.Name  = '1/3-Oct Spectrum Right';
    avSpecR.DataName = 'Magnitude';
    avSpecR.DataUnit = 'dB';
    avSpecR.FreqName = 'Frequency';
    avSpecR.FreqUnit = 'Hz';
    avSpecR.FreqScale = 'log';
    
    
        avDiffSpec = 10*log10(mean(10.^(DiffSpec.*0.1), 1));
    avSpecDiff    = createDataObject('Spectrum', frequencies, avDiffSpec);

    avSpecDiff.Name  = '1/3-Oct Spectrum R-L Difference';
    avSpecDiff.DataName = 'Magnitude';
    avSpecDiff.DataUnit = 'dB';
    avSpecDiff.FreqName = 'Frequency';
    avSpecDiff.FreqUnit = 'Hz';
    avSpecDiff.FreqScale = 'log';
    
    
    % Create the octave band time spectrum
    octfrequencies = [16 31.5 63 125 250 500 1000 2000 4000 8000 16000]';
    %PowSpecOct = power2dB(dataBuffer.octspec.get()) + getlevelOffset(obj);
    RawPowSpecOctL = dataBuffer.octspecL.get();
    RawPowSpecOctR = dataBuffer.octspecR.get();
    PowSpecOctLR = power2dB(0.5.*(RawPowSpecOctL+RawPowSpecOctR)) + getlevelOffset(obj);
    PowSpecOctL = power2dB(RawPowSpecOctL) + getlevelOffset(obj);
    PowSpecOctR = power2dB(RawPowSpecOctR) + getlevelOffset(obj);
    
         tSpecLR2   = createDataObject('tSpectrum', octfrequencies, PowSpecOctLR, ...
        TimePoints);

    tSpecLR2.Name     = '1/1-Oct Spectrogram LR Average';
    tSpecLR2.DataName = 'Magnitude';
    tSpecLR2.DataUnit = 'dB';
    tSpecLR2.FreqName = 'Frequency';
    tSpecLR2.FreqUnit = 'Hz';
    % tSpecLR2.FreqScale = 'log';
    
    tSpecL2   = createDataObject('tSpectrum', octfrequencies, PowSpecOctL, ...
        TimePoints);

    tSpecL2.Name     = '1/1-Oct Spectrogram Left';
    tSpecL2.DataName = 'Magnitude';
    tSpecL2.DataUnit = 'dB';
    tSpecL2.FreqName = 'Frequency';
    tSpecL2.FreqUnit = 'Hz';
    % tSpecL.FreqScale = 'log';
    
    tSpecR2   = createDataObject('tSpectrum', octfrequencies, PowSpecOctR, ...
        TimePoints);

    tSpecR2.Name     = '1/1-Oct Spectrogram Right';
    tSpecR2.DataName = 'Magnitude';
    tSpecR2.DataUnit = 'dB';
    tSpecR2.FreqName = 'Frequency';
    tSpecR2.FreqUnit = 'Hz';
    % tSpecR.FreqScale = 'log';
    
    DiffSpecOct = PowSpecOctR - PowSpecOctL;
    tDiffSpec2 = createDataObject('tSpectrum', octfrequencies, DiffSpecOct, ...
        TimePoints);
    tDiffSpec2.Name     = '1/1-Oct Spectrogram R-L Difference';
    tDiffSpec2.DataName = 'Magnitude';
    tDiffSpec2.DataUnit = 'dB';
    tDiffSpec2.FreqName = 'Frequency';
    tDiffSpec2.FreqUnit = 'Hz';
    % tDiffSpec.FreqScale = 'log';
    
    
    
    % Create the averaged Spectrum
    avPowSpecOctLR = 10*log10(mean(10.^(PowSpecOctLR.*0.1), 1));
    avSpecLR2    = createDataObject('Spectrum', octfrequencies, avPowSpecOctLR);

    avSpecLR2.Name  = '1/1-Oct Spectrum LR Average';
    avSpecLR2.DataName = 'Magnitude';
    avSpecLR2.DataUnit = 'dB';
    avSpecLR2.FreqName = 'Frequency';
    avSpecLR2.FreqUnit = 'Hz';
    avSpecLR2.FreqScale = 'log';
    

        avPowSpecOctL = 10*log10(mean(10.^(PowSpecOctL.*0.1), 1));
    avSpecL2    = createDataObject('Spectrum', octfrequencies, avPowSpecOctL);

    avSpecL2.Name  = '1/1-Oct Band Spectrum Left';
    avSpecL2.DataName = 'Magnitude';
    avSpecL2.DataUnit = 'dB';
    avSpecL2.FreqName = 'Frequency';
    avSpecL2.FreqUnit = 'Hz';
    avSpecL2.FreqScale = 'log';
    
    
        avPowSpecOctR = 10*log10(mean(10.^(PowSpecOctR.*0.1), 1));
    avSpecR2    = createDataObject('Spectrum', octfrequencies, avPowSpecOctR);

    avSpecR2.Name  = '1/1-Oct Spectrum Right';
    avSpecR2.DataName = 'Magnitude';
    avSpecR2.DataUnit = 'dB';
    avSpecR2.FreqName = 'Frequency';
    avSpecR2.FreqUnit = 'Hz';
    avSpecR2.FreqScale = 'log';
    
    
        avDiffSpecOct = 10*log10(mean(10.^(DiffSpecOct.*0.1), 1));
    avSpecDiff2    = createDataObject('Spectrum', octfrequencies, avDiffSpecOct);

    avSpecDiff2.Name  = '1/1-Oct Spectrum R-L Difference';
    avSpecDiff2.DataName = 'Magnitude';
    avSpecDiff2.DataUnit = 'dB';
    avSpecDiff2.FreqName = 'Frequency';
    avSpecDiff2.FreqUnit = 'Hz';
    avSpecDiff2.FreqScale = 'log';
    
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
    out = {tSpecL, tSpecR, tSpecLR, tDiffSpec, avSpecLR, avSpecL, avSpecR, avSpecDiff, ...
        tSpecL2, tSpecR2, tSpecLR2, tDiffSpec2, avSpecLR2, avSpecL2, avSpecR2, avSpecDiff2};
    obj = set(obj, 'output', out);

end    
% end constructDataObjects