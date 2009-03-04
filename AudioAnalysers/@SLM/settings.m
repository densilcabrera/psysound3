function [obj, fH] = settings(obj, fH)
% SETTINGS  SLM specific stuff

% Build list of weighting filters
wH = findobj('-regexp', 'Tag', 'SLMWeighting', 'Value', 1);
ud = get(wH, 'UserData');

% Set the weighints prop
if iscell(ud)
  obj = setwChoices(obj, [ud{:}]);
else
  obj = setwChoices(obj, ud);
end

% Build list of integration types
iH = findobj('-regexp', 'Tag', 'SLMIntegration', 'Value', 1);
ud = get(iH, 'UserData');

% Set the integration prop
if iscell(ud)
  obj = setiChoices(obj, ud);
else
  obj = setiChoices(obj, ud);
end

h   = findobj('Style', 'checkbox', 'Tag', 'SLMIgnoreDelay');
val = get(h, 'Value');
obj = setIgnoreDelay(obj, val);

% end settings

