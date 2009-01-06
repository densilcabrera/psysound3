
%%%%%%%%%%%%%%%%%%%
% Local functions %
%%%%%%%%%%%%%%%%%%%
% Retrieves all the timeseries objects for Sonification and
% packages them up in a cell array
function [tsArray, fs, minMax] = findAllTsObjs(p, handles, fName);

% Outputs
fs      = [];
tsArray = {};
minMax  = struct;

% Results list
resList = get(handles.OutputResultsList, 'String');

% The three input signale
inputSignals = {'freq', 'level', 'pan'};

for i=1:length(inputSignals)
  sig = inputSignals{i};
  
  % first find the tsObj string from the panel
  h   = findobj(p, 'Tag', [sig, 'TsObj']);
  str = get(h, 'String');

  % These are the indicies into the Results and Data lists,
  % respectively
  ind = get(h, 'UserData');
  
  if ~isempty(ind) & strcmp(get(h, 'Enable'), 'on')
    % This is the Analyser result
    res = resList{ind(1)};
    
    % If the data object doesn't already exist, load it
    if ~exist(res, 'var')
      load(fName, res);
    end
    
    % Set the sampling rate, if not already done so
    if isempty(fs)
      fs = get(eval(res), 'fs');
    end
    
    % Get the output cell array
    outputCell = get(eval(res), 'output');
    
    % The timeseries object is the one indexed by the data choice
    % list
    tsObj = outputCell{ind(2)};
    
    % Check a couple of things
    if ~isa(tsObj, 'timeseries')
      errordlg('Sonify: timeseries cache is wrong');
    else
      if ~strcmp(tsObj.name, str)
        errordlg('Sonify: timeseries name does not match');
      end
    end
    
    % Alls good, assign the timeseries object
    tsArray{i} = tsObj;
    
  else
    tsArray{i} = [];
  end
  
  % Find the min/max values from the GUI
  h = findobj(p, '-regexp', 'Tag', [sig, '(Min|Max)']);
  
  % Extract the actual values
  vals = get(h, 'String');
  
  % Add to the minMax struct
  minMax.(sig) = [str2num(vals{2}), str2num(vals{1})];

end