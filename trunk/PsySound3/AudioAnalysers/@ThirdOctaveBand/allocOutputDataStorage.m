function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%

numSamples = get(obj, 'samples');
numBands = 28;


% One big matrix with time in columns with frequency across
dataBuffer.data = makeDataBuffer(numSamples, numBands);

% end allocOutputDataStorage
