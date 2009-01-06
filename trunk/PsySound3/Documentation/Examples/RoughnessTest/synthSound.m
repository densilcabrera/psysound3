function [s]= synthSound(F0, Fs, g,  d, am, fm, ami, fmi)
%usage [signal] = synthSound(F0, g, Fs, d, am, ami, fm, fmi)

if nargin < 8
  fmi = 0;
end
if nargin< 7
  ami = 0;
end
if nargin < 6
  fm = 10;
end
if nargin < 5
  am = 10;
end


n      = Fs * d;                            % count from 0 to d at the fs
c      = (1:n)/Fs;                
amod   = (1:n)/Fs;                
fmod   = (1:n)/Fs;                 

amod   = 2 * pi * am * amod;                % into radians
c      = 2 * pi * F0 * c;  
fmod   = 2 * pi * fm * fmod;
 
amod   = sin(amod);                         % setup amplitude mod
amod   = (amod + 1)/2;
amod   = 1 - (amod .* ami);

fmod   = fmi * cos(fmod);                   % frequency modulator
s      = sin(c + fmod);                     % signal
s      = s .* amod;                         % amplitude modulation

rms    = sqrt(mean(s.^2));                  % get rms
rmsdB  = 20 * log10(rms);                   % decibels
gFac   = 10 ^ ((g - rmsdB) / 20);   
s      = s * gFac;                          % gain   

return;
