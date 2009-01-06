function dataOut = processWindow(obj, dataIn)
% PROCESSWINDOW This is the core workhorse of this analyser
%
% We are using raw mode - the whole file to be analysed is stored 
% in dataIn.

if dataIn == 1
  dataOut = 1;
  return;
end

fs = get(obj, 'fs');

lab_freq = [100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 ...
  2500 3150 4000 5000];

% Data size reduction
Q = fs;
P = get(obj,'outputDataRate');

% Call Couvreur Code (below)
[y,f] = oct3bank(dataIn,fs,Q,P);

% The direct filtering phase and the downsampled filtering 
% phase have different length outputs. Truncate to fit.
leny = [];
for i = 1:length(y); leny = min([length(y{i}) leny]); end
for i = 1:length(y); ymat(:,i) = y{i}(1:leny);     end

dataOut = ymat;





function [y,F] = oct3bank(x,Fs,Q,P) 
% OCT3BANK Simple one-third-octave filter bank. 
%    OCT3BANK(X) plots one-third-octave power spectra of signal vector X. 
%    Implementation based on ANSI S1.11-1986 Order-3 filters. 
%    Sampling frequency Fs = 44100 Hz. Restricted one-third-octave-band 
%    range (from 100 Hz to 5000 Hz). RMS power is computed in each band 
%    and expressed in dB with 1 as reference level. 
%
%    [P,F] = OCT3BANK(X) returns two length-18 row-vectors with 
%    the RMS power (in dB) in P and the corresponding preferred labeling 
%    frequencies (ANSI S1.6-1984) in F. 
% 					
%    See also OCT3DSGN, OCT3SPEC, OCTDSGN, OCTSPEC.

% Author: Christophe Couvreur, Faculte Polytechnique de Mons (Belgium)
%         couvreur@thor.fpms.ac.be
% Last modification: Aug. 23, 1997, 10:30pm.

% References: 
%    [1] ANSI S1.1-1986 (ASA 65-1986): Specifications for
%        Octave-Band and Fractional-Octave-Band Analog and
%        Digital Filters, 1993.
%    [2] S. J. Orfanidis, Introduction to Signal Processing, 
%        Prentice Hall, Englewood Cliffs, 1996.


pi = 3.14159265358979; 
N = 4; 					% Order of analysis filters. 
F = [25 32 40 50 63 80 100 125 160, 200 250 315, 400 500 630, 800 1000 1250, ... 
	1600 2000 2500, 3150 4000 5000 6300 8000 10000 12500 ]; % Preferred labeling freq. 
ff = (1000).*((2^(1/3)).^[-16:11]); 	% Exact center freq.
%ff = ff+14;
m = length(x); 
filtIndex = length(F);

% Design filters and compute RMS powers in 1/3-oct. bands
% 5000 Hz band to 1600 Hz band, direct implementation of filters. 
for i = 28:-1:13
   [B,A] = Oct3dsgn(ff(i),Fs,N); % Design filter
   intHand = integrator(Fs,'f'); % Setup integrator fileHandle.
   filtOutput = filter(B,A,x); % Filter
   filtOutput = intHand(filtOutput); % Integrate
   filtOutput   = power2dB(filtOutput .^ 2);
   y{filtIndex} = resample(filtOutput,P,Q); % Data Reduction 
   %   P(i) = sum(y.^2)/m; 
   filtIndex = filtIndex-1;
end


% 1250 Hz to 100 Hz, multirate filter implementation (see [2]).
[Bu,Au] = Oct3dsgn(ff(15),Fs,N); 	% Upper 1/3-oct. band in last octave. 
[Bc,Ac] = Oct3dsgn(ff(14),Fs,N); 	% Center 1/3-oct. band in last octave. 
[Bl,Al] = Oct3dsgn(ff(13),Fs,N); 	% Lower 1/3-oct. band in last octave. 
for j = 3:-1:0
   x = decimate(x,2); 
   m = length(x); 

   intHand = integrator(Fs,'f'); % Setup integrator fileHandle.
   filtOutput   = filter(Bu,Au,x); 
   filtOutput = resample(filtOutput,2^(4-j),1); % Resample to fs
   filtOutput = intHand(filtOutput); % Integrate
   filtOutput   = power2dB(filtOutput .^ 2);
   y{filtIndex} = resample(filtOutput,P,Q); % Data Reduction 
   filtIndex    = filtIndex-1;

   intHand = integrator(Fs,'f'); % Setup integrator fileHandle.
   filtOutput   = filter(Bc,Ac,x); 
   filtOutput   = resample(filtOutput,2^(4-j),1); % Resample to fs
   filtOutput   = intHand(filtOutput); % Integrate
   filtOutput   = power2dB(filtOutput .^ 2);
   y{filtIndex} = resample(filtOutput,P,Q); % Data Reduction
   filtIndex    = filtIndex-1;
   
   intHand = integrator(Fs,'f'); % Setup integrator fileHandle.
   filtOutput   = filter(Bl,Al,x); 
   filtOutput   = resample(filtOutput,2^(4-j),1); % Resample to fs
   filtOutput   = intHand(filtOutput); % Integrate
   filtOutput   = power2dB(filtOutput .^ 2);
   y{filtIndex} = resample(filtOutput,P,Q); % Data Reduction
   filtIndex    = filtIndex-1;
end
