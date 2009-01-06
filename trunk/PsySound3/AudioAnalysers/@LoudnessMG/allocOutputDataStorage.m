function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% The LoudnessMG Analyser has 2 outputs - Specific Loudness and Total Loudness

N = get(obj, 'outputSamples') + 5;

% A vector for each output for each window
dataBuffer.Loudness     = makeDataBuffer(N);
dataBuffer.SharpnessA   = makeDataBuffer(N);
dataBuffer.SharpnessZ   = makeDataBuffer(N);
dataBuffer.TimbralWidth = makeDataBuffer(N);
dataBuffer.Volume       = makeDataBuffer(N);
dataBuffer.DissonanceHK = makeDataBuffer(N);
dataBuffer.DissonanceS  = makeDataBuffer(N);
dataBuffer.SpectDissHK  = makeDataBuffer(N);
dataBuffer.SpectDissS   = makeDataBuffer(N);

% 1 N x 390 matrix for the complete DFT
dataBuffer.SpecLoudness = makeDataBuffer(N, 390);

% 1 numWindows x windowLength matrix for the complete ERB spectrum
dataBuffer.Esig = makeDataBuffer(N, 390);

% end allocOutputDataStorage
