
%%%%%%% Sonify
function Sonify_Callback(hObject, eventdata, handles)

hWait = waitbar(0, 'Sonification in progress. Please wait ...');

p = get(hObject, 'Parent');

% We have a valid time series name, lets figure out which file we
% came from
dataObjS = getDataObjectFromTreeNode(hObject, nodes(1));  
% This is the filename to load
fName = strs{val};

% Find all the timeseries objects, the 1st sampling rate and all
% the min/max values specified in the GUI
[tsArray, fs, minMax] = findAllTsObjs(p, handles, fName);

% Assign real-audio frequency if no timeseries objects were found
if isempty(fs)
  fs = 44100;
end

hWait = waitbar(0.5, hWait);

% Get scaling factor from the GUI
h       = findobj(p, 'Tag', 'outScFactor');
durFact = str2num(get(h, 'String'));

% Get the scaling type
h       = findobj(p, 'Tag', 'outScFactorPopup');
durType = get(h, 'Value');
durStrs = {'', 'total', 'upsample', 'downsample'};

tVect = [];
T     = 1/fs;
sEndT = Inf;
for i=1:length(tsArray)
  ts = tsArray{i};
  if ~isempty(ts)
    endT = ts.TimeInfo.End;
    if (endT < sEndT)
      sEndT = endT;
    end
  end
end

% Construct the time vector as per request
switch(durStrs{durType})
 case 'total'
  % The total time duration is specified so figure out what
  % scaling factor this translates into
  sc = durFact/sEndT;
  
 case 'upsample'
  % Increase the time length
  sc = durFact;
  
 case 'downsample'
  % Decrease the time length
  sc = 1/durFact;
  
 otherwise
  % Else no change
  sc = 1;
end

% 
tVect = (0:T/sc:sEndT)';

% Find the usePinkNoise flag
h            = findobj(p, 'Tag', 'SonifyUsePinkNoise');
usePinkNoise = get(h, 'Value');

hWait = waitbar(0.75, hWait);

% Do the sonification
sig = [];
try
  sig = sonify(tsArray, tVect,  minMax, fs, usePinkNoise);
catch
  errordlg(lasterr);
end

hWait = waitbar(1, hWait);

% Stick the signal in the UserData
set(hObject, 'UserData', {sig, fs});

try
  delete(hWait);
end