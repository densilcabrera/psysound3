function filemat = ESA2(varargin)
% Build Soundfile from grains. 2D version


% Unpack inputs - we will only use 2 inputs in this file. 
dataObj   = varargin{1};
analObj1  = dataObj(1).AnalyserObj;
analObj2  = dataObj(2).AnalyserObj;
dataObj1  = dataObj(1).DataObj; 
dataObj2  = dataObj(2).DataObj; 
ax = varargin{2};
ax1 = ax{1};
ax2 = ax{2};
axTag1 = get(ax{1},'Tag');
axTag2 = get(ax{2},'Tag');
plotType = varargin{3};

% Get Timesteps
timestep1     = diff(dataObj1.Time);             % Time Increment 
timestep1     = timestep1(1);                    % 
timestep2     = diff(dataObj2.Time);             % Time Increment 
timestep2     = timestep2(1);                    % 

% Errorcheck Timesteps
if timestep1 == timestep2
	windowLength = floor(timestep1 * analObj1.fs); % Get WindowLength
	if mod(windowLength,2)>0
	  windowLength = windowLength - 1;
	end
	timestep = timestep1;
else
	% timesteps are not identical
	errordlg('The timesteps for the two data objects are different.');
	return;
end	

% They should both be from the same file
if ~strcmp(analObj1.filename,analObj2.filename) 
	errordlg('These data objects aren''t from the same file.');
	return;
end
[file,fs,bits] = wavread(analObj1.filename);      % load in wavefile
file      = file(:,1);                            % mono - left side only

% make windowed matrix from sound file
filemat   = cut(file, windowLength, timestep, analObj1.fs); 
[r,c]     = size(filemat);
smallestColumns = min([c length(dataObj1.data)]); % get smallest length; data or number of windows
data1     = dataObj1.data(1:smallestColumns);     % Get data from object (chop to smallestColumns)
data2     = dataObj2.data(1:smallestColumns);     % Get data from object (chop to smallestColumns)
timeAxis  = dataObj1.Time(1:smallestColumns); 
TimeInfo  = dataObj1.TimeInfo;                    % Get TimeInfo

%  
switch plotType
  case '2DStemAndLeaf'
    filemat  = stemLeafTwoD(filemat(:,1:smallestColumns),data1,data2);
  case 'RegressLin'
    filemat  = RegressLin(filemat(:,1:smallestColumns),data1,data2);
end

filemat  = windowMix(filemat,windowLength,0.2);      % Overlap and add the sorted windows
sound(filemat./max(filemat),analObj1.fs);        % Play Sound
