function [obj, fH] = settings(obj, fH, varargin)
% SETTINGS  Generic method to retrieve the overlap and windowLength
%           from the GUI

if ~isempty(varargin)
  % This is to allow superclasses to call this base class method
  if isa(varargin{1}, 'Analyser')
    % Swap out to superclass
    obj = varargin{1};
  end
end

windowLength = [];
overlap      = [];

% We're executing some callback which means the GUI must exist
name = class(obj);

% Not all Analysers have this option
h = findobj('Tag', [name, 'WindowSize']);
if ishandle(h)
  MenuStrings  = get(h, 'String');
  MenuChoice   = get(h, 'Value');
  windowLength = str2double(MenuStrings(MenuChoice,:));
  
  if isnan(windowLength)
    % Try eval'ing it, eg. see FFT
    windowLength = eval(MenuStrings(MenuChoice,:));
  end
    
  % Set the property value
  obj = set(obj, 'windowLength', windowLength);
end

h = findobj('Tag', [name, 'OverlapType']);
if ishandle(h)
  MenuStrings  = get(h, 'String');
  MenuChoice   = get(h, 'Value');
  overlapType  = MenuStrings(MenuChoice,:);
  
  % Must also have the size
  h = findobj('Tag', [name, 'OverlapSize']);
  MenuStrings  = get(h, 'String');
  overlapSize  = str2double(MenuStrings);
  
  % Set the property value
  ov.type = deblank(overlapType);
  ov.size = overlapSize;
  
  obj = set(obj, 'overlap', ov);
end

h = findobj('Tag', [name, 'WindowFunc']);
if ishandle(h)
  MenuStrings = get(h, 'String');
  MenuChoice  = get(h, 'Value');
  wFunc       = MenuStrings(MenuChoice,:);
  
  % Set the property value
  obj = set(obj, 'windowFunc', deblank(wFunc));
end

% EOF
