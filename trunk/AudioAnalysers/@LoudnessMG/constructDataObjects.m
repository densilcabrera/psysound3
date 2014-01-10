function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%

frequencies = [21:390]./10; % row vect

% Check for synchronisation
if get(obj, 'synch')
  % Sync
  tstep = 1/get(obj, 'outputDataRate');
else
  % Nominal
  tstep = TimePoints(2)-TimePoints(1);
end

out = {};

% Create the Time Spectrum
SpecL = dataBuffer.SpecLoudness.get();
% Resample timepoints
SpecL = SpecL(:,21:390);
TimePoints = (0:size(SpecL)-1)' * tstep;

tSpec = createDataObject('tSpectrum', frequencies, SpecL, TimePoints);
tSpec.Name  = 'Specific Loudness Pattern';
tSpec.DataName = 'Specific Loudness';
tSpec.DataUnit = 'sone';
tSpec.FreqName = 'ERB Number';
tSpec.FreqUnit = 'ERB';
out{end+1}  = tSpec;

% Create the averaged Spectrum
avSpecL = mean(SpecL, 1);
avSpec  = createDataObject('Spectrum', frequencies, avSpecL);
avSpec.Name  = 'Average Specific Loudness Pattern';
avSpec.DataName = 'Av. Specific Loudness';
avSpec.DataUnit = 'sone';
avSpec.FreqName = 'ERB Number';
avSpec.FreqUnit = 'ERB';
out{end+1} = avSpec;

% Create the Time Spectrum
Esig = dataBuffer.Esig.get();
Esig = Esig(:,21:390);
tSpec = createDataObject('tSpectrum', frequencies, power2dB(abs(Esig)), TimePoints);
tSpec.Name  = 'Excitation Pattern';
tSpec.DataName = 'Excitation Level';
tSpec.DataUnit = 'dB';
tSpec.FreqName = 'ERB Number';
tSpec.FreqUnit = 'ERB';
out{end+1}  = tSpec;

% Create the averaged Spectrum
avEsig = power2dB(mean(abs(Esig), 1));
avSpec  = createDataObject('Spectrum', frequencies, avEsig);
avSpec.Name  = 'Average Excitation Pattern';
avSpec.DataName = 'Excitation Level';
avSpec.DataUnit = 'dB';
avSpec.FreqName = 'ERB Number';
avSpec.FreqUnit = 'ERB';
out{end+1} = avSpec;

% Create Time series
Loudness = dataBuffer.Loudness.get();
ts = createDataObject('tSeries', Loudness);
% Set props
ts.Name               = 'Loudness';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = 'sone';
out{end+1} = ts;

% Create Time series
SharpnessZ = dataBuffer.SharpnessZ.get();
ts = createDataObject('tSeries', SharpnessZ);
% Set props
ts.Name               = 'SharpnessZ';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = 'acum';
out{end+1} = ts;

% Create Time series
SharpnessA = dataBuffer.SharpnessA.get();
ts = createDataObject('tSeries', SharpnessA);
% Set props
ts.Name               = 'SharpnessA';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = 'acum';
out{end+1} = ts;

% Create Time series
TimbralWidth = dataBuffer.TimbralWidth.get();
ts = createDataObject('tSeries', TimbralWidth);
% Set props
ts.Name               = 'Timbral Width';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = '';
out{end+1} = ts;

% Create Time series
Volume = dataBuffer.Volume.get();
ts = createDataObject('tSeries', Volume);
% Set props
ts.Name               = 'Volume';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = 'vol';
out{end+1} = ts;

% Create Time series
DissonanceHK = dataBuffer.DissonanceHK.get();
ts = createDataObject('tSeries', DissonanceHK);
% Set props
ts.Name               = 'Tonal Dissonance (HK)';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = '';
out{end+1} = ts;

% Create Time series
DissonanceS = dataBuffer.DissonanceS.get();
ts = createDataObject('tSeries', DissonanceS);
% Set props
ts.Name               = 'Tonal Dissonance (S)';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = '';
out{end+1} = ts;

% Create Time series
SpectDissHK = dataBuffer.SpectDissHK.get();
ts = createDataObject('tSeries', SpectDissHK);
% Set props
ts.Name               = 'Spectral Dissonance (HK)';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = '';
out{end+1} = ts;

% Create Time series
SpectDissS = dataBuffer.SpectDissS.get();
ts = createDataObject('tSeries', SpectDissS);
% Set props
ts.Name               = 'Spectral Dissonance (S)';
ts1=setuniformtime(ts.tsObj,'Interval',tstep);
ts=set(ts,'time',get(ts1,'time'));
ts.DataInfo.Units     = '';
out{end+1} = ts;

% Assign outputs to the object
obj = set(obj, 'output', out);

% end constructDataObjects
