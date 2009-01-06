function obj = threshold(obj)
% THRESHOLD Restrict to only particular values of data

% Find the indexs
indexs = find(obj.DataPoints  > obj.DataThreshold(1) & obj.DataPoints  < obj.DataThreshold(2));
% thresh 1 is minimum
% thresh 2 is maximum

% Select these frames and ignore all else
obj.Frames     = obj.Frames(indexs);
obj.DataPoints = obj.DataPoints(indexs);
obj.TimePoints = obj.TimePoints(indexs);

