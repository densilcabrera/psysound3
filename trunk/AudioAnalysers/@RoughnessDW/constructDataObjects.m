function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

% Convenience variables
R  = dataBuffer.R.get();
ri = dataBuffer.ri.get();

out   = {};
tstep = 1/get(obj, 'outputDataRate');

% format for TimeSeries
ts = createDataObject('tSeries', R);
ts.DataInfo.Unit = 'aspers';
ts.Name = 'Roughness'; 
ts.TimeInfo.Increment = tstep;
out{end+1} = ts;

% format for TimeSpectrum
TimeSpectrumOutput = createDataObject('tSpectrum', [1:47]'/2, ri, TimePoints);
TimeSpectrumOutput = set(TimeSpectrumOutput,'Name','Specific Roughness');
TimeSpectrumOutput = set(TimeSpectrumOutput,'DataName','Specific Roughness');
TimeSpectrumOutput = set(TimeSpectrumOutput,'DataUnit','Aspers/Bark');
TimeSpectrumOutput = set(TimeSpectrumOutput,'FreqName','Critical Band Rate');
TimeSpectrumOutput = set(TimeSpectrumOutput,'FreqUnit','Bark');
out{end+1} = TimeSpectrumOutput;

%  format for Spectrum
%  calculate the spectrum by taking the mean across the data, this could be
%  done many ways apart from this simple method.
outputSpectrumData = mean(ri, 1);
SpectrumOutput = createDataObject('Spectrum', [1:47]'/2, outputSpectrumData);
SpectrumOutput = set(SpectrumOutput,'Name','Average Roughness');
SpectrumOutput = set(SpectrumOutput,'DataName','Specific Roughness');
SpectrumOutput = set(SpectrumOutput,'DataUnit','Aspers/Bark');
SpectrumOutput = set(SpectrumOutput,'FreqName','Critical Band Rate');
SpectrumOutput = set(SpectrumOutput,'FreqUnit','Bark');
out{end+1} = SpectrumOutput;

% Set output on the object
obj = set(obj, 'output', out);

% end constructDataObjects
