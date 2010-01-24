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
oDataRate = diff(t);
oDataRate = oDataRate(1);


% format for TimeSeries
tsInst = createDataObject('tSeries',InstantaneousLoudness,t);
tsInst.Name = 'Instantaneous Loudness';
tsInst.DataInfo.Unit = 'Sones';
tsInst.TimeInfo.Increment = oDataRate;
output{1} = tsInst;

tsShort = createDataObject('tSeries',ShortTermLoudness,t);
tsShort.Name = 'Short-term Loudness';
tsShort.DataInfo.Unit = 'Sones';
tsShort.TimeInfo.Increment  = oDataRate;
output{2} = tsShort;

tsLong = createDataObject('tSeries',LongTermLoudness,t);
tsLong.Name = 'Long-term Loudness';
tsLong.DataInfo.Unit = 'Sones';
tsLong.TimeInfo.Increment  = oDataRate;
output{3} = tsLong;

%Assign outputs to the object
obj = set(obj, 'output', output);

% end constructDataObjects
