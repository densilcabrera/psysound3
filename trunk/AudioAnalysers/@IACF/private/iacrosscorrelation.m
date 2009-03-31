function [acfl, acfr, ccf, phi0] = iacrosscorrelation(data, Fs)
% IACROSSCORRELATION  Finds the Inter-aural cross-correlation of two
%                     time signals' data
out = [];

if size(data,2) ~= 2
  error('iacrosscorrelation called with non-stereo audio!');
end

len      = size(data, 1);
lagCount = round(len/2);
nFFT     =  2^(nextpow2(len + 1));

% Calculate ffts
FFT = fft(data, nFFT);
FL  = FFT(:, 1); conjFL = conj(FL);
FR  = FFT(:, 1); conjFR = conj(FR);

% Calculate inverse fft. The first column will the ACF of the left
% channel, 2nd right and third CCF
CF = real(ifft([FL.*conjFL,  FR.*conjFR, FL.*conj(FR)]));
midW = nFFT/2;
CCF = CF(midW-lagCount:midW+lagCount, :);

LACF = CF(1:(lagCount+1),1);
RACF = CF(1:(lagCount+1),2);

% Farhan's code
% % Normalize
% IACF0 = sqrt(LACF(1) * RACF(1)); 
% IACF  = CCF(:,3) / IACF0;

% adapted from Sato
nrm = sqrt(LACF(1) * RACF(1));
lftplt = cat(2, (0:-1000/Fs:round((-1.0*0.01*Fs+1)*1000)/Fs)', real(IFFT(1:round(1.0*0.01*Fs),3))./nrm);
rgtplt = cat(2, (1000./Fs:1000./Fs:round(1.0*0.01*Fs-1)*1000./Fs)', real(IFFT(2:round(1.0*0.01*Fs),4))./nrm);
IACF = cat(1, flipud(lftplt), rgtplt);


% assign output
acfl = LACF;
acfr = RACF;
ccf  = IACF;
%phi0 = IACF0;
phi0 = nrm;


end % iacrosscorrelation
