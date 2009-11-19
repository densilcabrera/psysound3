function [obj, fH] = settings(obj, fH)
% SETTINGS  RLB specific stuff

c = [];

% 1 s
h = findobj('Tag', 'RLB1s');
if get(h, 'Value')
  c = [c 1];
end

% 3s
h = findobj('Tag', 'RLB3s');
if get(h, 'Value')
  c = [c 3];
end

% 10 s
h = findobj('Tag', 'RLB10s');
if get(h, 'Value')
  c = [c 10];
end

% Set property
obj.rmsChoices = c;

% Filter delay padding
h   = findobj('Style', 'checkbox', 'Tag', 'RLBIgnoreDelay');
val = get(h, 'Value');
obj = setIgnoreDelay(obj, val);

% end settings

