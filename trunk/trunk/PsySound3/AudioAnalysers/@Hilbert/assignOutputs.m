function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Envelope
dataBuf.env.assign(dataIn{1});

% Phase
dataBuf.phs.assign(dataIn{2});

% frequency
dataBuf.frq.assign(dataIn{3});

% EOF
