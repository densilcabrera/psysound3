function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

% get variables from base workspace
Fs_hz  = get(obj, 'fs');
Noct = get(obj,'NOct');
Noct_Start_Hz = get(obj,'NOctStartHz');

%Num_NoctBands = getNOctNumBands;
Num_NoctBands = get(obj, 'NOctNumBands');

%[frequencies, NoctBands_Fu_vector] = Gen_1_Noct_band_Fc_Fu(Fs_Hz, Noct, Noct_Start_Hz, Num_NoctBands);
frequencies = get(obj, 'NOctCentreFreq');

% Create the third oct band Time Spectrum
PowSpec = power2dB(dataBuffer.twelfthoctspec.get()) + getlevelOffset(obj);
tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, ...
                           TimePoints);

tSpec.Name     = '1/N-Octave Band Spectrogram';
tSpec.DataName = 'Magnitude';
tSpec.DataUnit = 'dB';
tSpec.FreqName = 'Frequency';
tSpec.FreqUnit = 'Hz';
% tSpec.FreqScale = 'log';

% Create the averaged Spectrum
avPowSpec = mean(PowSpec, 1);
avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);

avSpec.Name  = '1/N-Octave Band Spectrum';
avSpec.DataName = 'Magnitude';
avSpec.DataUnit = 'dB';
avSpec.FreqName = 'Frequency';
avSpec.FreqUnit = 'Hz';
avSpec.FreqScale = 'log';


tstep   = diff(TimePoints(1:2));


% Create Time series for the higher-order statistics
moments   = dataBuffer.moments.get();
SD        = dataBuffer.SD.get();
kurtosis  = dataBuffer.kurtosis.get();
skewness  = dataBuffer.skewness.get();
level = power2dB(dataBuffer.level.get())+ getlevelOffset(obj);
bigMatrix = [moments, SD, skewness, kurtosis, level];
tags      = {'Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
             'Spectral 2nd Moment', 'Frequency (Hz)' ;...
             'Spectral 3rd Moment', 'Frequency (Hz)' ;...
             'Spectral 4th Moment', 'Frequency (Hz)' ;...
             'Standard deviation',  'Frequency (Hz)' ;...
             'Skewness',            'units'; ...
             'Kurtosis',            'units'; ...
             'Level',            'dB'};

tsArray = {};
tstep   = diff(TimePoints(1:2));
for i=1:length(tags)
  ts = createDataObject('tSeries', bigMatrix(:, i));
  ts = set(ts, 'Name', tags{i, 1});
  
  % Set the increment
  ts.TimeInfo.Increment = tstep;

  % Stick this tag in the data info so that we pick it up as ylabel
  % in PlotResult
  ts.DataInfo.Units = tags{i, 2};
  
  % Assign to cell array
  tsArray{i} = ts;
end

% Assign outputs to the obect
out = {tSpec, avSpec, tsArray{:}};
obj = set(obj, 'output', out);

% end constructDataObjects