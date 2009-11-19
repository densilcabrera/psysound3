function obj = assignOutputs(obj, dataIn, dataBuffer, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

rmsChoices = getrmsChoices(obj);

% Loop over each of the integration choices
for i = 1:length(rmsChoices)
  dataBuffer.data.assign(dataIn{i}, i);
end

% EOF
