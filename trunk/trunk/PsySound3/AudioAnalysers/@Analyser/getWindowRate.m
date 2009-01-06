function out = getWindowRate(obj, varargin)
% GETWINDOWRATE  Gives the rate at which the window moves forward
%                Follows the same logic as readData

% For raw analysers we set outputDataRate explicitly 
if strcmp(obj.type, 'Raw')
  try
    out = obj.outputDataRate;
    return;
  catch
    error('outputDataRate not specified. Specify this in the AudioAnalyser Constructor');
  end
end

if nargin > 1
  wl = varargin{1};
  ov = varargin{2};
else
  wl = get(obj, 'windowLength');
  ov = getOverlap(obj);
end

offset = wl - ov;
period = offset ./ get(obj, 'fs');
out    = 1 ./ period;


% EOF
