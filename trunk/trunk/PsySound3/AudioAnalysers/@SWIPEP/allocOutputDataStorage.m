function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% 

numSamples = get(obj, 'outputSamples');

% 3 single column vectors
dataBuffer.p = makeDataBuffer(numSamples);
dataBuffer.s = makeDataBuffer(numSamples);
dataBuffer.t = makeDataBuffer(numSamples);
