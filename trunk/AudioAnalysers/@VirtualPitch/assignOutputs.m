function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

dataBuf.VP.assign(dataIn{1});
dataBuf.SP.assign(dataIn{2});
dataBuf.PT.assign(dataIn{3});
dataBuf.CT.assign(dataIn{4});
dataBuf.M.assign (dataIn{5});
dataBuf.S.assign (dataIn{6});
dataBuf.CP.assign(dataIn{7});




