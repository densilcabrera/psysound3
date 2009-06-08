function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%

N       = dataBuffer.N.get();
Fl      = dataBuffer.Fl.get();
main_N  = dataBuffer.main_N.get();
spec_N  = dataBuffer.spec_N.get();

output = {};

% Check for synchronisation
if get(obj, 'synch')
  % Sync
  tPeriod = 1/get(obj, 'outputDataRate');
  tstep   = 1/get(obj, 'outputDataRate');
else
  % Nominal
  tPeriod = 2e-3;
  tstep   = TimePoints(2)-TimePoints(1);
end
timePoints = (0:length(N)-1)' * tPeriod;

% format for TimeSeries
ts = createDataObject('tSeries', N);
ts.DataInfo.Unit = 'sones';
ts.Name          = 'Loudness'; 
ts.TimeInfo.Increment = tPeriod;
output{end+1} = ts;

% % format for TimeSeries
% ts = createDataObject('tSeries', Fl);
% ts.DataInfo.Unit = 'vacils';
% ts.Name = 'Fluctuation'; 
% ts.TimeInfo.Increment = tstep;
% output{end+1} = ts;

% format hires for TimeSpectrum
tSpec = createDataObject('tSpectrum', (1:24), main_N, timePoints);
tSpec = set(tSpec, 'Name',     'Main Loudness');
tSpec = set(tSpec, 'DataName', 'Loudness');
tSpec = set(tSpec, 'DataUnit', 'Sones/Bark');
tSpec = set(tSpec, 'FreqName', 'Critical Band Rate');
tSpec = set(tSpec, 'FreqUnit', 'Bark');
output{end+1} = tSpec;

% format hires for TimeSpectrum
tSpec = createDataObject('tSpectrum', (0.1:0.1:24), spec_N, timePoints);
tSpec = set(tSpec, 'Name','Specific Loudness');
tSpec = set(tSpec,'DataName','Loudness');
tSpec = set(tSpec,'DataUnit','Sones/Bark');
tSpec = set(tSpec,'FreqName','Critical Band Rate');
tSpec = set(tSpec,'FreqUnit','Bark');
output{end+1} = tSpec;

% format for Spectrum
% calculate the spectrum by taking the mean across the data, this could be
% done many ways apart from this simple method.
specData = mean(main_N, 1);
Spec = createDataObject('Spectrum', (1:24), specData);
Spec = set(Spec,'Name',     'Average Main Loudness');
Spec = set(Spec,'DataName', 'Loudness');
Spec = set(Spec,'DataUnit', 'Sones/Bark');
Spec = set(Spec,'FreqName', 'Critical Band Rate');
Spec = set(Spec,'FreqUnit', 'Bark');
output{end+1} = Spec;

% format for Spectrum
% calculate the spectrum by taking the mean across the data, this could be
% done many ways apart from this simple method.
specData = mean(spec_N, 1);
Spec = createDataObject('Spectrum', (0.1:0.1:24), specData);
Spec = set(Spec,'Name',     'Average Specific Loudness');
Spec = set(Spec,'DataName', 'Loudness');
Spec = set(Spec,'DataUnit', 'Sones/Bark');
Spec = set(Spec,'FreqName', 'Critical Band Rate');
Spec = set(Spec,'FreqUnit', 'Bark');
output{end+1} = Spec;

[r, c] = size(spec_N);
Sh = zeros(r, 1);
for i = 1:r
  Sh(i) = sharpness_Fastl(spec_N(i,:));
end

% format for TimeSeries
ts = createDataObject('tSeries', Sh);
ts.DataInfo.Unit = 'acums';
ts.Name = 'Sharpness'; 
ts.TimeInfo.Increment = tPeriod;
output{end+1} = ts;

% Set the output property on the object
obj = set(obj, 'output', output);

% end constructDataObjects