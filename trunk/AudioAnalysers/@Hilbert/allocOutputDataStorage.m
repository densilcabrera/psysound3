function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% The Hilbert Analyser has 3 outputs, Envelope, Phase and Frequency
%
% Note: This could easily be a matrix.  See SLM for an example

numSamples = get(obj, 'outputSamples');

% 3 single column vectors
dataBuffer.env = makeDataBuffer(numSamples);
dataBuffer.phs = makeDataBuffer(numSamples);
dataBuffer.frq = makeDataBuffer(numSamples);

% end allocOutputDataStorage
