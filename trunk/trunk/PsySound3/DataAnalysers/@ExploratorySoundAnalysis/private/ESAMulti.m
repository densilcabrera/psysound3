function filemat = ESAMulti(varargin)
% Build Soundfile from grains. 2D version

% Unpack inputs - we will only use 2 inputs in this file. 
DataObj   = varargin{1};
for i = 1:length(DataObj)
  analObj{i}  = DataObj(i).AnalyserObj;
  dataObj{i}  = DataObj(i).DataObj;
  temp   = diff(dataObj{i}.Time);             % Time Increment 
  timestep(i) = temp(1);
end

ax = varargin{2};
for i = 1:length(ax)
  ax1{i} = ax{i};
  axTag{i} = get(ax{i},'Tag');
  
end
plotType = varargin{3};

% Errorcheck Timesteps

% if timestep1 == timestep2
% 	windowLength = floor(timestep1 * analObj1.fs); % Get WindowLength
% 	if mod(windowLength,2)>0
% 	  windowLength = windowLength - 1;
% 	end
% 	timestep = timestep1;
% else
% 	% timesteps are not identical
% 	errordlg('The timesteps for the two data objects are different.');
% 	return;
% end	
 
% % They should both be from the same file
% if ~strcmp(analObj1.filename,analObj2.filename) 
% 	errordlg('These data objects aren''t from the same file.');
% 	return;
% end

for i = 1:length(dataObj)

  [file,fs,bits] = wavread(analObj{i}.filename);      % load in wavefile
  file      = file(:,1);                            % mono - left side only
  windowLength = floor(timestep(i) * analObj{i}.fs);
  % make windowed matrix from sound file
  filemat   = cut(file, windowLength, timestep, analObj{i}.fs);
  [r,c]     = size(filemat);
  smallestColumns = min([c length(dataObj{i}.data)]); % get smallest length; data or number of windows
  data     = dataObj{i}.data(1:smallestColumns);     % Get data from object (chop to smallestColumns)
  timeAxis  = dataObj{i}.Time(1:smallestColumns);
 
  
  [sData,sIndexs] = sort(data);
  medianIndex =  floor(length(data)/2);
  aroundMedian = sIndexs(medianIndex-5:medianIndex+5);
  aroundMedian = repmat(aroundMedian,1,10);
  filemat  = filemat(:,aroundMedian(ceil(rand(100,1)*100)));
  
  % end
  filemat  = windowMix(filemat,windowLength,0.2);      % Overlap and add the sorted windows
  pieces{i} = filemat;
end
filemat = [];


% Concatenate each with gaps of 200ms between each chunk.
for i = 1: length(pieces) 
  filemat = [filemat; zeros(floor(analObj{1}.fs/5),1); pieces{i}];
end

  
sound(filemat./max(filemat),analObj{1}.fs);        % Play Sound
