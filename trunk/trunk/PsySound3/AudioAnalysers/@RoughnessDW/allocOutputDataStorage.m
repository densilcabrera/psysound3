function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% The FFT Analyser has 3 outputs, Envelope, Phase and Frequency

N = get(obj, 'outputSamples');

dataBuffer.R  = makeDataBuffer(N);
dataBuffer.ri = makeDataBuffer(N, 47); % hard-coded


% end allocOutputDataStorage
