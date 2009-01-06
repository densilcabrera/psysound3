function funcH = filter_third_octaves_downsample(Pref, Fs, Fmin, ...
                                                 Fmax, N, factors)

% Calls the octave design function for each of the octave bands
% x is the file (Input length must be a multiple of 2^8)
% Pref is the reference level for calculating decibels
% Fmin is the minimum frequency
% Fmax is the maximum frequency (must be at least 2500 Hz)
% Fs is the sampling frequency
% N is the filter order

% original from the Salford http://www.acoustics.salford.ac.uk/research/
% Altered for the PsySound project by Matt Flax <flatmax@>
% Date : 20.03.07

% Altered for the PsySound project using nested functions and
% eliminating the dependence on filehandles by Farhan Rizwi
% Date: 07.07

% Returns the function handle on invokation

%
% PART 1
% Calculate the frequency midbands(ff), corresponding nominal
% frequecies(F) and indices(i)
%
[ff, F, j] = midbands(Fmin, Fmax, Fs);

%
% PART 2A
% Design and implement the filters, computing the RMS levels in
% each 1/3-oct. band
%
P = zeros(1, length(j));
k = find(j==7); % Determines where downsampling will commence (5000
                % Hz and below)

% Init the state vectors
Z = cell(1, length(j)+1);

% Initialise A & B
for i = length(j):-1:k+1;
  [B{length(j)-i+1}, A{length(j)-i+1}] = filter_design2(ff(i), Fs, N);

  if i == k+3; % Upper 1/3-oct. band in last octave.
    Bu = B{length(j)-i+1};
    Au = A{length(j)-i+1};
  end
  if i == k+2; % Center 1/3-oct. band in last octave.
    Bc = B{length(j)-i+1};
    Ac = A{length(j)-i+1};
  end
  if i == k+1; % Lower 1/3-oct. band in last octave.
    Bl = B{length(j)-i+1};
    Al = A{length(j)-i+1};
  end
end

% Initialise C & D
for i = k:-3:1;
  % Design anti-aliasing filter (IIR Filter)
  Wn = 0.4;
  [C, D] = cheby1(2, 0.1, Wn);
end

% Output data cell array
x       = [];
data    = cell(1, length(j));

% Return handle to the run function
funcH = @run;

  %
  % Nested Run function
  %
  function dataOut = run(dataIn)
  m = length(dataIn);
  
  % For frequencies of 6300 Hz or higher, direct implementation of filters.
  for i = length(j):-1:k+1;
    [y, Z{i}] = filter(B{length(j)-i+1}, A{length(j)-i+1}, dataIn, Z{i});
    y         = y * factors(i);
    data{i}   = y;
    P(i)      = 20*log10(sqrt(sum(y.^2)/m)); % Convert to decibels.
  end
  
  % 5000 Hz or lower, multirate filter implementation.
  % Filter
  x = dataIn;
  for i = k:-3:1
    [x, Z{length(j)+1}] = filter(C, D, x, Z{length(j)+1});

    % Downsample
    x  = downsample(x, 2, 1); % Offset by one to eliminate end effects
    Fs = Fs/2;
    m  = length(x);

    % Performs the filtering
    [y, Z{i}] = filter(Bu, Au, x, Z{i});
    y          = y*factors(i);
    data{i}    = y;
    P(i)       = 20*log10(sqrt(sum(y.^2)/m));

    [y, Z{i-1}] = filter(Bc, Ac, x, Z{i-1});
    y            = y*factors(i-1);
    data{i-1}    = y;
    P(i-1)       = 20*log10(sqrt(sum(y.^2)/m));

    [y, Z{i-2}] = filter(Bl, Al, x, Z{i-2});
    y            = y*factors(i-2);
    data{i-2}    = y;
    P(i-2)       = 20*log10(sqrt(sum(y.^2)/m));
  end

  %
  % PART 3
  % Calibrate the readings
  %
  P = P + Pref; % Reference level for dB scale, from calibration run
  
  %
  % PART 4
  % Generate plot of the powers within each frequency band
  %

  if 0
    figure(203)
    bar(P);
    %axis([0 (length(F)+1) (-10) (max(P)+1)])
    set(gca,'XTick',[1:3:length(P)]);
    set(gca,'XTickLabel',F(1:3:length(F))); % Labels frequency axis
                                            % on third octaves.x
    xlabel('Frequency band [Hz]'); ylabel('Powers [dB]');
    title('One-third-octave spectrum')
  end

  % These don't seem to be used except for the plot below
  % Plog = 10.^(fileHandle.thirdOctave.P./10);
  % Ptotal = sum(Plog);
  % Ptotal = 10*log10(Ptotal);
  
  if 0
    figure(203)
    text(1,-5,'Ptotal [dB] =')
    text(5,-5,num2str(Ptotal))
  end
  
  % Assign output argument
  dataOut = data;
  
  end % run
end % filter_third_octaves_downsample