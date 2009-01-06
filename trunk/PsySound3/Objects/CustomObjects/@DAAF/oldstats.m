function obj = stats(obj,varargin)
% STATS Finds the frames corresponding to the stats in the stats objects. 
% Gets them and then sticks them in the statsFrames fields.

% Indexes in order
[sortedData,orders] = sort(obj.DataPoints);            

% Get names from stats object 
names = fields(obj.Stats);
 wl = floor(obj.WindowLength / 2);
if nargin > 2
method = varargin{1};
 else
method = 'multipleFrames';
end

switch method
 case 'multipleFrames'

for i = 2:length(names)-1
  % What is the index of the frame
  index = find(sortedData >= obj.Stats.(char(names(i))),1,'first');
	try
		origIndex = orders((index-5):(index+5));
	catch
		try
			origIndex = orders((index-10):index);
		catch
			origIndex = orders(index:(index+10));
		end
	end
  % find sample boundaries and double
  frames = obj.Frames(origIndex);
  obj.StatFrames.(char(names(i))) = frames;
end


	
	
case 'singleFrame'
% Get each field and place in appropriate field
for i = 2:length(names)-1
  % What is the index of the frame
  index = find(sortedData >= obj.Stats.(char(names(i))),1,'first');
  origIndex = orders(index);
  % find sample boundaries and double
  samples = obj.FrameSamples(origIndex,:);
  samples = [(samples(1) - wl):(samples(2) + wl)];
  sampleIndexes = find(samples > 0 & samples < length(obj.AudioData));
  samples = samples(sampleIndexes);
  newframe = obj.AudioData(samples);
  obj.StatFrames.(char(names(i))) = newframe;
end

% Percentiles are stored in an array, the index of which represents the
% number. 
for i = 1:99
  index = find(sortedData >= obj.Stats.percentiles(i),1,'first');
  % find sample boundaries and double
  origIndex = orders(index);
  samples = obj.FrameSamples(origIndex,:);
  samples = [(samples(1) - wl):(samples(2) + wl)];
  sampleIndexes = find(samples > 0 & samples < length(obj.AudioData));
  samples = samples(sampleIndexes);
  newframe = obj.AudioData(samples);
  obj.StatFrames.percentiles(i) = {newframe};
end
end