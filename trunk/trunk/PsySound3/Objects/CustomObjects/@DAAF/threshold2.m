function obj = threshold2(obj,objThresh)
% THRESHOLD Restrict to only particular values of data
% objThresh is the thresholding second variable
% it is assumed synchronised to the first

% Find the indexs
indexs = find(objThresh.DataPoints  < objThresh.DataThreshold(1) | objThresh.DataPoints  > objThresh.DataThreshold(2));
% thresh 1 is minimum
% thresh 2 is maximum

% Select these frames and turn them into NaN - they will then be thrown
% away at CDF time
obj.DataPoints(indexs) = NaN;

% Find stats and recalculate


% do stat frames again


