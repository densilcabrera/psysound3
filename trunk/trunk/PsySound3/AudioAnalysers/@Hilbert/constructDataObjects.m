function obj = constructDataObjects(obj, dataBuffer, TimePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% The Hilbert Analyser has 3 outputs, Envelope, Phase and Frequency

% Analogous to assignoutputs

% Data in column vector
envData = dataBuffer.env.get();
phsData = dataBuffer.phs.get();
frqData = dataBuffer.frq.get();

caloffset = 90.97; % used to match calibration

ts      = createDataObject('tSeries', power2dB(abs(envData))+ caloffset, 'dB');
ts.Name = 'Instantaneous Level';
out{1}  = ts;

ts      = createDataObject('tSeries', phsData);
ts.Name = 'Instantaneous Phase';
out{2}  = ts;

ts      = createDataObject('tSeries', frqData);
ts.Name = 'Instantaneous Frequency';
out{3}  = ts;

% Set the units
out{1}.DataInfo.Units = 'dB';
out{2}.DataInfo.Units = 'radians';
out{3}.DataInfo.Units = 'Hz';

% Set the proper sampling rate
for i=1:length(out)
  out{i}.TimeInfo.Increment = 1/get(obj, 'outputDataRate');
end

% Set the output property
obj = set(obj, 'output', out);

% end constructDataObjects