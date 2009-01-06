function obj = process(obj, fH, wH, varargin)
% PROCESS method, overrides the ANALYSER process method.
%
%


% See if we're estimating
estimate  = 0;
calibrate = 0;
if ~isempty(varargin)
  var = varargin{1};
  if isstr(var)
    str = var;
    switch(str)
     case 'estimate'
      % We want time estimates
      estimate    = 1;
      fH.calCoeff = 1;
     case 'calibrate'
      % We are in the process of calibration, set the coeffecient to
      % one
      fH.calCoeff = 1;
      calibrate   = 1;
     case 'synchronise'
      % Synchronise output
      synch     = 1;
      oDataRate = varargin{2};
     otherwise
      error(['Analyser: process. Unknown string argument ''', str, '''']);
    end
  else
    error(['Analyser: process. Unknown argument ''', var, '''']);
  end
end

if ~ exist('oDataRate') 
oDataRate = 100;
end
filename = get(obj,'filename');
[x,Fs] = wavread(filename);
x = x * fH.calCoeff;
[p,t,s] = swipep(x,Fs,[],1/oDataRate);


% format for TimeSeries
tsPitch = createDataObject('tSeries',p,t);
tsPitch.Name = 'SWIPEP Pitch';
tsPitch.DataInfo.Unit = 'Hz';
tsPitch.TimeInfo.Increment= 1/oDataRate;
output{1} = tsPitch;

tsPitchStrength = createDataObject('tSeries',s,t);
tsPitchStrength.Name = 'SWIPEP Pitch Strength';
tsPitchStrength.TimeInfo.Increment= 1/oDataRate;
output{2} = tsPitchStrength;

clear('p','t','s');

[p,t,s] = swipe(x,Fs,[],1/oDataRate);

% format for TimeSeries
tsPitch = createDataObject('tSeries',p,t);
tsPitch.Name = 'SWIPE Pitch';
tsPitch.DataInfo.Unit = 'Hz';
tsPitch.TimeInfo.Increment= 1/oDataRate;
output{3} = tsPitch;

tsPitchStrength = createDataObject('tSeries',s,t);
tsPitchStrength.Name = 'SWIPE Pitch Strength';
tsPitchStrength.TimeInfo.Increment= 1/oDataRate;
output{4} = tsPitchStrength;


ov.size = get(obj,'windowLength') - floor(get(obj,'fs')/oDataRate);
ov.type = 'samples';
obj = set(obj,'overlap',ov);

obj = set(obj,'samples',length(p));
obj = set(obj,'outputDataRate',oDataRate);
obj = set(obj,'output', output);
out = obj;
