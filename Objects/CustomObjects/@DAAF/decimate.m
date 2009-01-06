function obj = decimate(obj, targetTime)
% DECIMATE Get time information and decimate to targetTime

% Size of the Frames
len              = length(obj.OutputFrames);
% Ratio of Decimation
decRatio         =  (max(obj.TimePoints) - min(obj.TimePoints)) / targetTime;
% The new set of indexes
indexes          = floor([1:decRatio:len]');
% Selecting the indexes from the cell array of frames
obj.OutputFrames = obj.OutputFrames(indexes);