function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%

N   = get(obj, 'outputSamples') + 1; % We seem to need +1 for synchronisation
pts = N * 26; % This is the most we'll need

dataBuffer.N      = makeDataBuffer(pts);
dataBuffer.main_N = makeDataBuffer(pts, 24);
dataBuffer.spec_N = makeDataBuffer(pts, 240);
dataBuffer.Fl     = makeDataBuffer(N);

% end allocOutputDataStorage
