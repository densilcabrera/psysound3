function [obj, fH] = settings(obj, fH)
% SETTINGS  CepstrumComplex specific method

% Get min/max
h   = findobj('Tag', 'LifterF1', 'Style', 'edit');
str = get(h, 'String');

if isempty(str)
  return;
end

% We're using liftering
f1 = str2double(str);

h   = findobj('Tag', 'LifterF2', 'Style', 'edit');
str = get(h, 'String');

if isempty(str)
  return;
end

% We're using czt
f2 = str2double(str);

% All good, set field
obj.LifterF = [f1 f2];

% EOF
