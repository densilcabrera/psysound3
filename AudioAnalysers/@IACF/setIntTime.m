function obj = setIntTime(obj, val)
% SETINTTIME  Sets the integration time (in seconds) for this
%             Analyser

obj.IntTime = val;

% Fix up the window size
fs = get(obj, 'fs');
wl = round(fs*val);

% Make even
if mod(wl, 2)
  wl = wl+1;
end

obj = set(obj, 'windowLength', wl);
