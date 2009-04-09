function obj = constructDataObjects(obj, dataBuffer, timePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%
% Get the p data
ReverbTime = dataBuffer{1};

% Get the s data
Time = dataBuffer{2};











fs = get(obj,'fs');
oDataRate = get(obj,'outputDataRate');

% format for TimeSeries
tsRT = createDataObject('tSeries',ReverbTime,Time);
tsRT.Name = 'Schroeder Integration';
tsRT.DataInfo.Unit = 'dB';
tsRT.TimeInfo.Increment= 1/fs;
output{1} = tsRT;

%Assign outputs to the object
obj = set(obj, 'output', output);

% end constructDataObjects
