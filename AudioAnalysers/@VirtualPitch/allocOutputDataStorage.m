function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%

N = get(obj, 'outputSamples');

% make frequencies from 440 - midi notes
i = -68:47;
notes = log2(440*2 .^ (i / 12));
len = length(notes);

dataBuffer.VP = makeDataBuffer(N, len);  % Virtual pitch
dataBuffer.SP = makeDataBuffer(N, len);  % Spectral pitch
dataBuffer.PT = makeDataBuffer(N,   1);  % Pure Tonalness
dataBuffer.CT = makeDataBuffer(N,   1);  % Complex Tonalness
dataBuffer.M  = makeDataBuffer(N,   1);  % Multiplicity
dataBuffer.S  = makeDataBuffer(N, len);  % Salience
dataBuffer.CP  = makeDataBuffer(N, 12);  % Chroma pattern

% end allocOutputDataStorage
