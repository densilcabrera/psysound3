function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment



% get variables from base workspace
Fs_Hz  = get(obj, 'fs');
Noct = get(obj,'NOct');
Noct_Start_Hz = get(obj,'NOctStartHz');

%Num_NoctBands = Calc_Num_NoctBands(Fs_Hz, Noct, Noct_Start_Hz);
Num_NoctBands = get(obj, 'NOctNumBands');
%[frequencies, NoctBands_Fu_vector] = Gen_1_Noct_band_Fc_Fu(Fs_Hz, Noct, Noct_Start_Hz, Num_NoctBands);
frequencies = get(obj, 'NOctCentreFreq');

% scaling factor?
N2           = (get(obj, 'windowLength')/65536)^2;
PowSpec     = dataIn / N2;
 
% Assign the power spectrum
dataBuf.twelfthoctspec.assign(PowSpec);

% Assign the level
Power = sum(PowSpec);
dataBuf.level.assign(Power);

% Normalize the PowSpectrum
PowSpec = PowSpec/Power;

% Mean, which is also the 1st Moment
meanPowSpec = frequencies * PowSpec';

moments = meanPowSpec;
% Calculate higher-order moments
n = 4;  % Change to get higher ones
for i=2:n
  moments(1,i) = ((frequencies - meanPowSpec) .^ i) * PowSpec';
end

% Assign moments
dataBuf.moments.assign(moments);

% SD - this is the square root of the 2nd moment which is the
%      variance
SD = sqrt(moments(2));
dataBuf.SD.assign(SD);

% Skewness and Kurtosis
% This are the 3rd and 4th standardised moments, respectively
dataBuf.skewness.assign(moments(3)/ (SD^3));
dataBuf.kurtosis.assign(moments(4)/ (SD^4));

% end assignOutputs