function obj = assignOutputs(obj, dataIn, dataBuf, s)
% ASSIGNOUTPUTS This method updates the output structure with each
%               new block of analysed data.  The output structures
%               (and any underlying data objects, eg. timeseries)
%               should already be allocated and all that should be
%               needed is assignment

% Convenience variables
% N   = get(obj, 'windowLength') - 1;
% N2  = N/2;
% fs  = get(obj, 'fs');

% Moment calculations
% if ~isempty(obj.cztF)
%   % We already have the frequency range
%   f1 = obj.cztF(1); f2 = obj.cztF(2);
%   fBin = (f2-f1)/N;
%   frequencies = (f1:fBin:f2);
%   DFT = dataIn / N;
% else
%   DFT = dataIn(1:end/2) / N;
%   frequencies = (fs/N) * (0:N2); % row vect
% end

N2           = (get(obj, 'windowLength')/65536)^2;
%frequencies = [12.5 16 20 25 31.5 40 50 63 80 100 125 160 200 250 320 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];
PowSpec     = dataIn / N2;

chan = get(obj,'channels');

if chan == 1
    % octave band spectrum
    % octfrequencies = [16 31.5 63 125 250 500 1000 2000 4000 8000 16000]';
    OctSpec(1:11) = zeros;
    for n = 1:11
        OctSpec(n) = PowSpec(3*n-2) + PowSpec(3*n-1) + PowSpec(3*n);
    end
    dataBuf.octspec.assign(OctSpec);


    % Assign the power spectrum
    dataBuf.thirdoctspec.assign(PowSpec);
end
if chan == 2
    OctSpecL(1:11) = zeros;
    for n = 1:11
        OctSpecL(n) = PowSpec(3*n-2,1) + PowSpec(3*n-1,1) + PowSpec(3*n,1);
    end
    dataBuf.octspecL.assign(OctSpecL);
    
    OctSpecR(1:11) = zeros;
    for n = 1:11
        OctSpecR(n) = PowSpec(3*n-2,2) + PowSpec(3*n-1,2) + PowSpec(3*n,2);
    end
    dataBuf.octspecR.assign(OctSpecR);
    dataBuf.thirdoctspecL.assign(PowSpec(:,1)');
    dataBuf.thirdoctspecR.assign(PowSpec(:,2)');
end
end
% % Assign the level
% Power = sum(PowSpec);
% dataBuf.level.assign(Power);
%
% % Normalize the PowSpectrum
% PowSpec = PowSpec/Power;
%
% % Mean, which is also the 1st Moment
% meanPowSpec = frequencies * PowSpec';
%
% moments = meanPowSpec;
% % Calculate higher-order moments
% n = 4;  % Change to get higher ones
% for i=2:n
%   moments(1,i) = ((frequencies - meanPowSpec) .^ i) * PowSpec';
% end
%
% % Assign moments
% dataBuf.moments.assign(moments);
%
% % SD - this is the square root of the 2nd moment which is the
% %      variance
% SD = sqrt(moments(2));
% dataBuf.SD.assign(SD);
%
% % Skewness and Kurtosis
% % This are the 3rd and 4th standardised moments, respectively
% dataBuf.skewness.assign(moments(3)/ (SD^3));
% dataBuf.kurtosis.assign(moments(4)/ (SD^4));

% end assignOutputs