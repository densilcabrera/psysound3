function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

fs          = get(obj, 'fs');
N           = get(obj, 'windowLength');
N2          = N/2;
frequencies = (0:N2-1) / fs; % row vect

% Create the Time Spectrum
PowSpec = power2dB(dataBuffer.PowSpec.get()) + getlevelOffset(obj);
tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, ...
                           TimePoints);

tSpec.Name     = 'Cepstrogram';
tSpec.DataName = 'Gamnitude';
tSpec.DataUnit = 'dB of dB';
tSpec.FreqName = 'Quefrency';
tSpec.FreqUnit = 's';

% Create the averaged Spectrum
avPowSpec = mean(PowSpec, 1);
avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);

avSpec.Name  = 'Average Gamnitude Cepstrum';
avSpec.DataName = 'Gamnitude';
avSpec.DataUnit = 'dB of dB';
avSpec.FreqName = 'Quefrency';
avSpec.FreqUnit = 's';

tstep   = diff(TimePoints(1:2));


% Create Time series for the higher-order statistics
moments   = dataBuffer.moments.get();
SD        = dataBuffer.SD.get();
kurtosis  = dataBuffer.kurtosis.get();
skewness  = dataBuffer.skewness.get();
bigMatrix = [moments, SD, skewness, kurtosis];
tags      = {'Cepstral Centroid (1st Moment)', 'Quefrency (s)' ;...
             'Cepstral 2nd Moment', 'Quefrency (s)' ;...
             'Cepstral 3rd Moment', 'Quefrency (s)' ;...
             'Cepstral 4th Moment', 'Quefrency (s)' ;...
             'Standard deviation',  'Quefrency (s)' ;...
             'Skewness',            'units'; ...
             'Kurtosis',            'units'};

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