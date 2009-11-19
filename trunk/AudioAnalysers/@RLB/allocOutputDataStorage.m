function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% The RLB Analyser needs a vector for each one of its rms
% integration outputs

numSamples = get(obj, 'outputSamples');

len = length(getrmsChoices(obj));

% Each column is an output
dataBuffer.data = makeDataBuffer(numSamples, len);

% end allocOutputDataStorage
