function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% the previous returns a string when post-processing hasn't occurred
if ~isempty(dataIn{1}) && ~isstr(dataIn{1})
  N      = dataIn{1}; % remember the post-processing outputs
  main_N = dataIn{2};
  spec_N = dataIn{3};
  Fl     = dataIn{4};
  
  dataBuf.N.assign(N);
  dataBuf.main_N.assign(main_N);
  dataBuf.spec_N.assign(spec_N);
  
  if ~isempty(Fl)
    dataBuf.Fl.assign(Fl);
  end

elseif isstr(dataIn{1})
  % insert zero for fluctuation to keep in time
  dataBuf.Fl.assign(0);  
end
