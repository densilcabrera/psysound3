function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%

numWindows   = getNumWindows(obj);
windowLength = get(obj, 'windowLength');
nFFT         = 2^(nextpow2(windowLength + 1));

% Left auto-correlation
dataBuffer.correlogramL = makeDataBuffer(numWindows, nFFT);
dataBuffer.tau1L = makeDataBuffer(numWindows);
dataBuffer.phi1L = makeDataBuffer(numWindows);
dataBuffer.taueL = makeDataBuffer(numWindows);

% Right auto-correlation
dataBuffer.correlogramR = makeDataBuffer(numWindows, nFFT);
dataBuffer.tau1R = makeDataBuffer(numWindows);
dataBuffer.phi1R = makeDataBuffer(numWindows);
dataBuffer.taueR = makeDataBuffer(numWindows);

% Cross-correlation
Fs  = get(obj, 'fs');
len = 2*0.01*Fs-1;
dataBuffer.correlogramX = makeDataBuffer(numWindows, len);
dataBuffer.phi0 = makeDataBuffer(numWindows);
dataBuffer.iacc = makeDataBuffer(numWindows);
dataBuffer.tauIACC = makeDataBuffer(numWindows);
dataBuffer.Wiacc = makeDataBuffer(numWindows);


% end allocOutputDataStorage
