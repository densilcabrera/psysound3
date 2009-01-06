function obj = assignOutputs(obj, dataIn, dataBuffer, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% dataIn is going to be a cell array, 1 for each integrator type
% (fast or slow) of matricies, each column of which is the
% weightings type

% xxx - draw picture of data structure

wChoices = getwChoices(obj);
iChoices = getiChoices(obj);

col = 1;
% Loop over each of the weighting choices
for w = 1:length(wChoices)
  wStr = wChoices(w);
  % Loop over each of the integration types
  for i = 1:length(iChoices)
    iStr = iChoices(i);
    
    dataBuffer.data.assign(dataIn{col}, col);
    
    % Go to the next column
    col = col + 1;
  end
end
