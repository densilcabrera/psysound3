function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Convenience variables
Loudness     = dataIn{1};
SpecL        = dataIn{2};
SharpnessA   = dataIn{3};
SharpnessZ   = dataIn{4};
TimbralWidth = dataIn{5};
Volume       = dataIn{6};
DissonanceHK = dataIn{7};
DissonanceS  = dataIn{8};
SpectDissHK  = dataIn{9};
SpectDissS   = dataIn{10};
Esig         = dataIn{11};

% Assign 
dataBuf.SpecLoudness.assign(SpecL);
dataBuf.Loudness.assign(Loudness);
dataBuf.SharpnessA.assign(SharpnessA);
dataBuf.SharpnessZ.assign(SharpnessZ);
dataBuf.TimbralWidth.assign(TimbralWidth);
dataBuf.Volume.assign(Volume);
dataBuf.DissonanceHK.assign(DissonanceHK);
dataBuf.DissonanceS.assign(DissonanceS);
dataBuf.SpectDissHK.assign(SpectDissHK);
dataBuf.SpectDissS.assign(SpectDissS);
dataBuf.Esig.assign(Esig);
% end assignOutputs