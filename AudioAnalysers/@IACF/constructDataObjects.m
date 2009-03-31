function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

out = {};

% Convenience variables
N  = get(obj, 'windowLength');
fs = get(obj, 'fs');

lagsListing = [0:(1/fs):(N/fs)]';
lagsListing = lagsListing(1:ceil(end/2));

% Get the Data
clgrmL = dataBuffer.correlogramL.get();
tau1L  = dataBuffer.tau1L.get();
phi1L  = dataBuffer.phi1L.get();
taueL  = dataBuffer.taueL.get();

clgrmR = dataBuffer.correlogramR.get();
tau1R  = dataBuffer.tau1R.get();
phi1R  = dataBuffer.phi1R.get();
taueR  = dataBuffer.taueR.get();

clgrmX = dataBuffer.correlogramX.get();
phi0  = dataBuffer.phi0.get();
iacc  = dataBuffer.iacc.get();
tauIACC  = dataBuffer.tauIACC.get();
Wiacc  = dataBuffer.Wiacc.get();

% Create the Time Spectrum
tSpec    = createDataObject('tSpectrum', lagsListing, clgrmL, TimePoints);
tSpec.Name  = 'Left Autocorrelogram';
tSpec.DataName = 'auto-correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 's';
tSpec.TimeName = 'Time';
tSpec.TimeUnit = 's';
out{end+1} = tSpec;

% Timeseries data
ts = createDataObject('tSeries', tau1L);
ts.Time = TimePoints;
ts.Name = 'tau1L';
ts.DataInfo.Unit = 'ms';
out{end+1} = ts;

ts = createDataObject('tSeries', phi1L);
ts.Time = TimePoints;
ts.Name = 'phi1L';
ts.DataInfo.Unit = 'units';
out{end+1} = ts;

ts = createDataObject('tSeries', taueL);
ts.Time = TimePoints;
ts.Name = 'taueL';
ts.DataInfo.Unit = 'ms';
out{end+1} = ts;

% Create the Time Spectrum
tSpec    = createDataObject('tSpectrum',lagsListing, clgrmR, TimePoints);
tSpec.Name  = 'Right Autocorrelogram';
tSpec.DataName = 'auto-correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 's';
tSpec.TimeName = 'Time';
tSpec.TimeUnit = 's';
out{end+1} = tSpec;

% Timeseries data
ts = createDataObject('tSeries', tau1R);
ts.Time = TimePoints;
ts.Name = 'tau1R';
ts.DataInfo.Unit = 'ms';
out{end+1} = ts;

ts = createDataObject('tSeries', phi1R);
ts.Time = TimePoints;
ts.Name = 'phi1R';
ts.DataInfo.Unit = 'units';
out{end+1} = ts;

ts = createDataObject('tSeries', taueR);
ts.Time = TimePoints;
ts.Name = 'taueR';
ts.DataInfo.Unit = 'ms';
out{end+1} = ts;

% Create the Time Spectrum
clgrmF = [(-10:1000/fs:0) (1000/fs:1000/fs:10)]';
tSpec  = createDataObject('tSpectrum', clgrmF, clgrmX, TimePoints);
tSpec.Name  = 'Cross-correlogram +/-10 ms';
tSpec.DataName = 'cross-correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 'ms';
tSpec.TimeName = 'Time';
tSpec.TimeUnit = 's';
out{end+1} = tSpec;

% Create the Spectrum
meanIACF = mean(clgrmX);
SpectrumOutput = createDataObject('Spectrum', clgrmF(2:end-1), meanIACF); 
SpectrumOutput = set(SpectrumOutput, 'Name','Time-averaged IACF');
SpectrumOutput = set(SpectrumOutput, 'DataName',  'cross-correlation');
SpectrumOutput = set(SpectrumOutput, 'DataUnit',  'Coefficient');
SpectrumOutput = set(SpectrumOutput, 'FreqName',  'Lag');
SpectrumOutput = set(SpectrumOutput, 'FreqUnit',  'ms');
SpectrumOutput = set(SpectrumOutput, 'FreqScale', 'linear');
out{end+1} = SpectrumOutput;

% Create the Time Spectrum
tau_center = ceil(length(clgrmX)/2);
t1_lim = ceil(tau_center - 0.0005*fs);
t2_lim = floor(tau_center + 0.0005*fs);
clgrmXsmall = clgrmX(:,t1_lim:t2_lim);
clgrmF = [(-1:1000/fs:0) (1000/fs:1000/fs:1)]';
tSpec  = createDataObject('tSpectrum', clgrmF, clgrmXsmall, TimePoints);
tSpec.Name  = 'Cross-correlogram +/-1 ms';
tSpec.DataName = 'cross-correlation';
tSpec.DataUnit = 'Coefficient';
tSpec.FreqName = 'Lag';
tSpec.FreqUnit = 'ms';
tSpec.TimeName = 'Time';
tSpec.TimeUnit = 's';
out{end+1} = tSpec;

% Timeseries data
ts = createDataObject('tSeries', phi0);
ts.Time = TimePoints;
ts.Name = 'phi(0)';
ts.DataInfo.Unit = 'units';
out{end+1} = ts;

ts = createDataObject('tSeries', iacc);
ts.Time = TimePoints;
ts.Name = 'iacc';
ts.DataInfo.Unit = 'units';
out{end+1} = ts;

ts = createDataObject('tSeries', tauIACC);
ts.Time = TimePoints;
ts.Name = 'tau(iacc)';
ts.DataInfo.Unit = 'units';
out{end+1} = ts;

ts = createDataObject('tSeries', Wiacc);
ts.Time = TimePoints;
ts.Name = 'W(iacc)';
ts.DataInfo.Unit = 'ms';
out{end+1} = ts;


% Assign outputs to the object
obj = set(obj, 'output', out);

% end constructDataObjects
