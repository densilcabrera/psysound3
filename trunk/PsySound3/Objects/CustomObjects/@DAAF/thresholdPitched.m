function obj = thresholdPitched(obj,varargin)
% THRESHOLD Restrict to only particular values of data

dataObjS = varargin{1};
% Find the pitched indexs
indexs = find(isfinite(dataObjS.DataObj.data));

% Select these frames and ignore all else
obj.Frames     = obj.Frames(indexs);
obj.DataPoints = obj.DataPoints(indexs);
obj.TimePoints = obj.TimePoints(indexs);

