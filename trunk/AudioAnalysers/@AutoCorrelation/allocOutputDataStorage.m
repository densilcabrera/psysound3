function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% 

numWindows   = getNumWindows(obj);
windowLength = get(obj, 'windowLength')/2 + 1; % xxx - check!!

% 1 numWindows x windowLength matrix for the complete DFT
dataBuffer.specData = makeDataBuffer(numWindows, windowLength);

% end allocOutputDataStorage
