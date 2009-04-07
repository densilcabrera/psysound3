function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% The FFT Analyser has 3 outputs, Envelope, Phase and Frequency

numWindows   = getNumWindows(obj);

if ~isempty(obj.cztF)
    n = 1;
else
    n = 2;
end

windowLength = get(obj, 'windowLength')/n;
chan = get(obj,'channels');

if chan == 1
    % A 3-col vector for the 4 moements for each window
    dataBuffer.moments  = makeDataBuffer(numWindows, 4);
    dataBuffer.SD       = makeDataBuffer(numWindows);
    dataBuffer.skewness = makeDataBuffer(numWindows);
    dataBuffer.kurtosis = makeDataBuffer(numWindows);
    dataBuffer.level    = makeDataBuffer(numWindows);

    % 1 numWindows x windowLength matrix for the complete DFT
    dataBuffer.PowSpec = makeDataBuffer(numWindows, windowLength);

    % IF COMPLEX AVERAGE THEN DO THE FOLLOWING
    dataBuffer.MagnitudeSpec = makeDataBuffer(numWindows, windowLength);
    dataBuffer.PhaseSpec = makeDataBuffer(numWindows, windowLength);
    % END IF

end % if chan == 1
if chan == 2
    % A 3-col vector for the 4 moements for each window
    dataBuffer.momentsL  = makeDataBuffer(numWindows, 4);
    dataBuffer.SDL       = makeDataBuffer(numWindows);
    dataBuffer.skewnessL = makeDataBuffer(numWindows);
    dataBuffer.kurtosisL = makeDataBuffer(numWindows);
    dataBuffer.levelL = makeDataBuffer(numWindows);
    
    % A 3-col vector for the 4 moements for each window
    dataBuffer.momentsR  = makeDataBuffer(numWindows, 4);
    dataBuffer.SDR       = makeDataBuffer(numWindows);
    dataBuffer.skewnessR = makeDataBuffer(numWindows);
    dataBuffer.kurtosisR = makeDataBuffer(numWindows);
    dataBuffer.levelR = makeDataBuffer(numWindows);

    % 1 numWindows x windowLength matrix for the complete DFT
    dataBuffer.PowSpecL = makeDataBuffer(numWindows, windowLength);
    dataBuffer.PowSpecR = makeDataBuffer(numWindows, windowLength);


    % IF COMPLEX AVERAGE THEN DO THE FOLLOWING
    dataBuffer.MagnitudeSpecL = makeDataBuffer(numWindows, windowLength);
    dataBuffer.PhaseSpecL = makeDataBuffer(numWindows, windowLength);
    dataBuffer.MagnitudeSpecR = makeDataBuffer(numWindows, windowLength);
    dataBuffer.PhaseSpecR = makeDataBuffer(numWindows, windowLength);
    % END IF

end % if chan ==2
% end allocOutputDataStorage
