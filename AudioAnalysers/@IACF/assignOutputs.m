function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Assign
% Left auto-correlation
dataBuf.correlogramL.assign(dataIn{1});
dataBuf.tau1L.assign(dataIn{2});
dataBuf.phi1L.assign(dataIn{3});
dataBuf.taueL.assign(dataIn{4});

% Right auto-correlation
dataBuf.correlogramR.assign(dataIn{5});
dataBuf.tau1R.assign(dataIn{6});
dataBuf.phi1R.assign(dataIn{7});
dataBuf.taueR.assign(dataIn{8});

% Cross-correlation
dataBuf.correlogramX.assign(dataIn{9});
dataBuf.phi0.assign(dataIn{10});
dataBuf.iacc.assign(dataIn{11});
dataBuf.tauIACC.assign(dataIn{12});
dataBuf.Wiacc.assign(dataIn{13});

% end assignOutputs
