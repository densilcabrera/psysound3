function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

fs          = get(obj, 'fs');
N           = get(obj, 'windowLength');
N2          = N/2;



if ~isempty(obj.LifterF) 
    frequencies = (fs/N) * (0:N2-1); % row vect
    % Create the Time Spectrum
    PowSpec = power2dB(dataBuffer.PowSpec.get()) + getlevelOffset(obj);
    tSpec   = createDataObject('tSpectrum', frequencies, PowSpec, ...
                               TimePoints);

    tSpec.Name     = 'Liftered Spectrogram';
    tSpec.DataName = 'Magnitude';
    tSpec.DataUnit = 'dB';
    tSpec.FreqName = 'Frequency';
    tSpec.FreqUnit = 'Hz';

    % Create the averaged Spectrum
    avPowSpec = mean(PowSpec, 1);
    avSpec    = createDataObject('Spectrum', frequencies, avPowSpec);

    avSpec.Name  = 'Average Magnitude Liftered Spectrum';
    avSpec.DataName = 'Magnitude';
    avSpec.DataUnit = 'dB';
    avSpec.FreqName = 'Frequency';
    avSpec.FreqUnit = 'Hz';

    tstep   = diff(TimePoints(1:2));


    % Create Time series for the higher-order statistics
    moments   = dataBuffer.moments.get();
    SD        = dataBuffer.SD.get();
    kurtosis  = dataBuffer.kurtosis.get();
    skewness  = dataBuffer.skewness.get();
    level     = power2dB(dataBuffer.level.get()) + getlevelOffset(obj); % only output this for liftered spectrum
    bigMatrix = [moments, SD, skewness, kurtosis, level];
    tags      = {'Spectral Centroid (1st Moment)', 'Frequency (Hz)' ;...
                 'Spectral 2nd Moment', 'Frequency (Hz)' ;...
                 'Spectral 3rd Moment', 'Frequency (Hz)' ;...
                 'Spectral 4th Moment', 'Frequency (Hz)' ;...
                 'Standard deviation',  'Frequency (Hz)' ;...
                 'Spectral Skewness',            'units'; ...
                 'Spectral Kurtosis',            'units'; ...
                 'Spectral Level',            'dB'};

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
else
    frequencies = (0:N2-1) / fs; % row vect - currenlty only first half the cepstrum
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
                 'Cepstral Skewness',            'units'; ...
                 'Cepstral Kurtosis',            'units'};

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
end %if    
% Assign outputs to the obect
out = {tSpec, avSpec, tsArray{:}};
obj = set(obj, 'output', out);

% end constructDataObjects