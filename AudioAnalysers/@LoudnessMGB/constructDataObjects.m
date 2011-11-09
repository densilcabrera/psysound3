function obj = constructDataObjects(obj, dataBuffer, timePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%
% Get the InstantaneousLoudness data
InstantaneousLoudness= dataBuffer{1};

% Get the ShortTermLoudness data
ShortTermLoudness = dataBuffer{2};

% Get the LongTermLoudness data
LongTermLoudness = dataBuffer{3};

% Get the t data
t = dataBuffer{4};
synch = get(obj,'synch');

if synch
  oDataRate = get(obj,'outputDataRate'); 
  tResampled = [0:1/oDataRate:t(end)]';
  tsI =  timeseries(InstantaneousLoudness,t);
  tsI =  resample(tsI,tResampled);
  tsL =  timeseries(LongTermLoudness,t);
  tsL =  resample(tsL,tResampled);
  tsS =  timeseries(ShortTermLoudness,t);
  tsS =  resample(tsS,tResampled);
  oDataRatet = diff(t);
  oDataRatet = oDataRatet(1);
  fprintf('Downsampling from %.1f Hz to %.1f Hz using Matlab timeseries resample command',...
    1 / oDataRatet, 1 / oDataRate);
else  
  oDataRate = diff(t);
  oDataRate = oDataRate(1);
end


% format for TimeSeries
tsInst = createDataObject('tSeries',tsI.Data,tsI.Time);
tsInst.Name = 'Instantaneous Loudness';
tsInst.DataInfo.Unit = 'Sones';
tsInst.TimeInfo.Increment = oDataRate;
output{1} = tsInst;

tsShort = createDataObject('tSeries',tsS.Data,tsS.Time);
tsShort.Name = 'Short-term Loudness';
tsShort.DataInfo.Unit = 'Sones';
tsShort.TimeInfo.Increment  = oDataRate;
output{2} = tsShort;

tsLong = createDataObject('tSeries',tsL.Data,tsL.Time);
tsLong.Name = 'Long-term Loudness';
tsLong.DataInfo.Unit = 'Sones';
tsLong.TimeInfo.Increment  = oDataRate;
output{3} = tsLong;




%Assign outputs to the object
obj = set(obj, 'output', output);

% end constructDataObjects
