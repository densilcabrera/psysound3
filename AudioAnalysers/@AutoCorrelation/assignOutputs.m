function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Assign ACF
dataBuf.specData.assign(dataIn');

% end assignOutputs