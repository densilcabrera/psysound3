function dataBuffer = allocOutputDataStorage(obj, varargin)
%  ALLOCOUTPUTDATASTORAGE Allocates raw array memory for all output
%                         vectors.  These will get transferred to
%                         appropriate timeseries objects later.
%
%
% The SLM Analyser needs a vector for each one of its weighted
% outputs

numSamples = get(obj, 'outputSamples');

wChoices = getwChoices(obj);
iChoices = getiChoices(obj);

% This is the number of SLM outputs as chosen by the user
len = length(wChoices) * length(iChoices);

% Each column is an output
dataBuffer.data = makeDataBuffer(numSamples, len);

% end allocOutputDataStorage
