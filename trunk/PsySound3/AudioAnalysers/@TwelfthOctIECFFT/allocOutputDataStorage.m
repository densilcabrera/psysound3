function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%

numWindows   = getNumWindows(obj);

% if ~isempty(obj.cztF)
%   n = 1;
% else
%   n = 2;
% end
% 
% windowLength = get(obj, 'windowLength')/n;

% A 3-col vector for the 4 moements for each window
% dataBuffer.moments  = makeDataBuffer(numWindows, 4);
% dataBuffer.SD       = makeDataBuffer(numWindows);
% dataBuffer.skewness = makeDataBuffer(numWindows);
% dataBuffer.kurtosis = makeDataBuffer(numWindows);
% dataBuffer.level = makeDataBuffer(numWindows);

numberofbands = 121; % number of bands in the 1/12-oct band spectrum
chan = get(obj,'channels');
if chan == 1
% 1 numWindows x windowLength matrix for the complete DFT
dataBuffer.twelfthoctspec = makeDataBuffer(numWindows, numberofbands);
end
if chan == 2
    dataBuffer.twelfthoctspecL = makeDataBuffer(numWindows, numberofbands);
    dataBuffer.twelfthoctspecR = makeDataBuffer(numWindows, numberofbands);
end
% end allocOutputDataStorage
