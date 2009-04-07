function [obj, fH] = settings(obj, fH)
% SETTINGS  FFT specific method

% First call the base class's settings method for any defaults
[obj, fH] = settings(obj.Analyser, fH, obj);



%%%%%%%
% Complex Averaging Checkbox

% h   = findobj('Tag', 'FFTDoComplexAverage', 'Style', 'checkbox');
% DoComplex = get(h, 'Value');
% 
% obj.complexAverage = DoComplex;


% Get min/max
h   = findobj('Tag', 'CZTChirpF1', 'Style', 'edit');
str = get(h, 'String');

if isempty(str)
  return;
end

% We're using czt
f1 = str2double(str);

h   = findobj('Tag', 'CZTChirpF2', 'Style', 'edit');
str = get(h, 'String');

if isempty(str)
  return;
end

% We're using czt
f2 = str2double(str);

h   = findobj('Tag', 'CZTRadius1', 'Style', 'edit');
str = get(h, 'String');

if isempty(str)
  R1 = 1;
else
R1 = str2double(str);
end

h   = findobj('Tag', 'CZTRadius2', 'Style', 'edit');
str = get(h, 'String');

if isempty(str)
  R2 = 1;
else
R2 = str2double(str);
end

if f2 < f1
%   warndlg(['Upper frequency must be greater than lower frequency ',...
%     'for Chirp Z-transform setting in FFT Spectrum. Values swapped']);
  % swap f1 and f2
%   obj.cztF = [f2 f1];
  % return;
  x = f2;
  f2 = f1;
  f1 = x;
  x = R2;
  R2 = R1;
  R1 = x;
end

if f2 == f1
  warndlg(['Upper frequency must not be equal to the lower frequency ',...
    'for Chirp Z-transform setting in FFT Spectrum. Values ignored']);
  % bail out
  obj.cztF = [];
   return;
end

% All good, set field
obj.cztF = [f1 f2 R1 R2];



% EOF
