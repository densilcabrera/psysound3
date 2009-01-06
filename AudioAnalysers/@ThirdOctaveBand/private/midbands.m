function [ff, F, j] = midbands(Fmin, Fmax, Fs)
  
% divides the frequency range into third octave bands
% Fmin is the minimum third octave band
% Fmax is the maximum third octave band
  
% original from the Salford http://www.acoustics.salford.ac.uk/research/
  
%%%%%%%%
% PART 1
% Decides whether range is within limits of programme
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
% This section of the programme defines the upper and lower third
% octave bands which this programme will work for.
  
  lowest_band = 25;
  highest_band = 20000;
  Nyquist_frequency = Fs/2;
  FUpper = 2^(1/6)*Fmax;
  
  if (Fmin < lowest_band)
    Fmin = input('Please re-enter Fmin (min value 25Hz)\n');
  end
  
  if (Fmax > Nyquist_frequency) | ...
        (Fmax > highest_band)   | ...
        (FUpper > Nyquist_frequency)
    Nyquist_frequency
    FUpper
    disp(['FUpper must be smaller then Nyquist. Try maximum of ' ...
          num2str(Nyquist_frequency/2^(1/6))]);
    Fmax = input(['Please select a lower Fmax (max value 20kHz but ' ...
                  'also FUpper < Nyquist_frequency)\n']);
  end

  %%%%%%
  % PART 2
  % Determines the indices(j), midband frequencies(ff) and the
  % preferred labeling frequencies(F)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
fr = 1000; % reference frequency is 1000Hz
i = -16:1:13;
lab_freq = [25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 ...
        2500 3150 4000 5000 6300 8000 10000 12500 16000 20000];

A = find(lab_freq == Fmin);
B = find(lab_freq == Fmax);

while (length(A) == 0)
    Fmin
    fprintf('Fmin is not a nominal midband frequency\n')
    Fmin = input('Please re-enter Fmin (min value 25Hz)\n');
    A = find(lab_freq == Fmin);
end
while (length(B) == 0)
    Fmax
    fprintf('Fmax is not a nominal midband frequency\n')
    Fmax = input('Please re-enter Fmax (max value 20kHz but also Fmax < Nyquist_frequency)\n');
    FUpper = 2^(1/6)*Fmax;
    if (Fmax > Nyquist_frequency)|(Fmax > highest_band)|(FUpper > Nyquist_frequency)
        Nyquist_frequency
        FUpper
        Fmax = input('Please select a lower Fmax (max value 20kHz but also FUpper < Nyquist_frequency)\n');
    end
    B = find(lab_freq == Fmax);
end

j = i([A:B]); % indices to find exact midband frequencies
ff = (2.^(j./3)).*fr; % Exact midband frequencies (Calculated as base two exact)
F = lab_freq([A:B]);
end
