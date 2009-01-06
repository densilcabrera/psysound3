function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

R  = dataIn{1};
ri = dataIn{2};
% SPL = dataIn{3};

% Assign R
dataBuf.R.assign(R);

% Assign ri
dataBuf.ri.assign(ri);

% end assignOutputs