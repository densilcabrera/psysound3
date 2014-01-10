function obj = constructDataObjects(obj, dataBuffer, timePoints)
%  CONSTRUCTDATAOBJECTS Constructs the appropriate data objects
%
% Analogous to assignoutputs
%
% Get the p data
p = dataBuffer{1};

% Get the s data
s = dataBuffer{2};

% Get the t data
t = dataBuffer{3};

oDataRate = get(obj,'outputDataRate');

% format for TimeSeries
tsPitch = createDataObject('tSeries',p,t);
tsPitch.Name = 'SWIPEP Pitch';
tsPitch.DataInfo.Unit = 'Hz';
% tsPitch.TimeInfo.Increment= 1/oDataRate;
tsPitch1=setuniformtime(tsPitch.tsObj,'Interval',1/oDataRate);
tsPitch=set(tsPitch,'time',get(tsPitch1,'time'));
output{1} = tsPitch;

tsPitchStrength = createDataObject('tSeries',s,t);
tsPitchStrength.Name = 'SWIPEP Pitch Strength';
tsPitchStrength1=setuniformtime(tsPitchStrength.tsObj,'Interval', 1/oDataRate);
tsPitchStrength=set(tsPitchStrength,'time',get(tsPitchStrength1,'time'));
output{2} = tsPitchStrength;

%Assign outputs to the obect
obj = set(obj, 'output', output);

% end constructDataObjects
