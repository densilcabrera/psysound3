function signal = sonifyData(tsArray, tVect, minMaxVals, fs, usePinkNoise)
% SONIFY : Sonification workhorse
%    tsArray : A cell array of timeseries objects
%    tVect   : time vector to resample on
%    minMaxVals : Structure of min/max value arrays, one for each
%                 'freq', 'level', and 'pan'
%  
%    fs : sampling rate
% 
%    usePinkNoise : 0 or 1
%   
% usage: signal = sonify(tsArray)
% A cell array of timeseries objects is taken, and fields in the
% timeseries objects are used to build signals. Each of these
% signals are then mixed together. If the signal does not have a
% pitch field it is used to multiply the signal. If none of the
% timeseries objects have a pitch field the a pink noise source is
% created so that it can be multiplied.
%
% Fields :
% F0
% - max 
% - min
% Pitch is in Hz. Semitone transformation is assumed. No
% quantisation is applied.
%
% Intensity
% - max
% - min
% 0 is defined as full scale, and min must be below max. if either
% max or min is not defined,
% they are taken as being equal to the other - 1 of them must be defined. 
%
% Pan
% - max 
% - min
% 1 is right and 0 is left. if either max or min is not defined,
% they are taken as being equal to the other - 1 of them must be defined.

% Note: When we go to true uniformally sampled time vectors
%       (i.e. the time vector is not stored) then we can do away
%       with the following resampling as in the new paradigm we
%       need only change the TimeInfo.Increment

% xxx - do the 50ms advance
% tVect = tVect(round(50e-3*fs):end);

% First resample all the timeseries objects
for i=1:length(tsArray)
  ts = tsArray{i};
  if ~isempty(ts)
    TInfo = get(ts,'TimeInfo');
    tsArray{i} = resample(get(ts,'tsObj'), [TInfo.Start:(1/fs):TInfo.End]');
  end
end

% Divvy them out
[tsFreq, tsLevel, tsPan] = tsArray{:};

% Ok, now for the real sonification part


% freq
signal = sonifyF0(tsFreq, minMaxVals, tVect, fs, usePinkNoise);

% level
signal = signal .* sonifySPL(tsLevel, minMaxVals);

% Add stereo and pan
sigPan = sonifyPan(tsPan, minMaxVals);
signal = [signal.*sigPan(:,1) signal.*sigPan(:,2)];

% end sonify

%
% Frequency
%
function signal = sonifyF0(tsInput, minMax, tVect, fs, usePinkNoise)

if usePinkNoise
  % Generate pink noise
  signal = pinkNoise(tVect)';

  return;
end

if ~isa(tsInput, 'timeseries')
  % Make up a data vector
  data = zeros(size(tVect));
  fc   = minMax.freq(2);

  % Generate a single tone
  signal = vco(data, fc, fs);
  
else
  % Scale data -- vco takes [-1 1]
  data = scaleData(tsInput.data, 1);
  
  fmin = minMax.freq(1);
  fmax = minMax.freq(2);
  
  signal = vco(data, [fmin fmax], fs); % generate signal
end
% end sonifyF0

%
% Level
%
function signal = sonifySPL(tsInput, minMax)
% create signal to multiply with the f0 stream

if isa(tsInput, 'timeseries')
  % Use the data to modulate
  data = scaleData(tsInput.data, 0);
  
  % Max min values
  SPLmin = minMax.level(1);
  SPLmax = minMax.level(2);
  
  % scale to range for db
  SPLrange = SPLmax - SPLmin;

  data = data .*SPLrange;
  data = data - max(data);

  % turn db into scaling factors 
  signal = 10.^(data/10);
else
  % Nothing to do really, leave the signal level as is
  signal = 1;
end
% end sonifySPL

%
% Pan
%
function signal = sonifyPan(tsInput, minMax)
% create signal to multiply with the f0 stream

% Max min values
Panmin = minMax.pan(1);
Panmax = minMax.pan(2);

PanRange = Panmax - Panmin;

if isa(tsInput, 'timeseries')
  % Use the data to modulate
  data = scaleData(tsInput.data, 0);
  data = (data * PanRange) + Panmin;
  
  signal = [1-data data];
else
  % Interpret as levels
  signal = minMax.pan;
end
% end sonifyPan

%
% Generate pink noise
%
function s = pinkNoise(t)

% % Title: Noise
% % Subtitle: Pink noise
% % The power spectrum of pink noise is
% % proportional to f^(-1) (f is frequency), which
% % means that it decreases 3 dB per octave.
% % This means that frequency bands with the same
% % bandwidth on a logarithmic frequency scale
% % contain the same power.
% %
% % This pink noise was calculated according to
% % an algorithm I found on the internet
% % The original author was Mr. Tom Bruhns from HP
% % who proposed the following values for a
% % white-to-pink noise filter for audio signals:
% % poles=[.9986823 .9914651 .9580812 .8090598 .2896591]';
% % zeros=[.9963594 .9808756 .9097290 .6128445 -.0324723]';
% %

poles=[.9986823 .9914651 .9580812 .8090598 .2896591]';
zeros=[.9963594 .9808756 .9097290 .6128445 -.0324723]';

% Find forward and backward coefficients of the filter
[b, a] = zp2tf(zeros, poles, 1);
x = rand(length(t),1)*2-1;
% Filter the white noise to get pink noise.
s(1,:) = filter(b, a, x);
    
% end pinkNoise

% SCALEDATA to -1:1
function dataOut = scaleData(dataIn, flag)
%
% flag = 0 for ( 0:1)
% flag = 1 for (-1:1)
dataOut = [];

data 	  = dataIn;
dataMax   = max(data);
dataMin   = min(data);
dataRange = dataMax - dataMin;
data 	  = (data - dataMin) /dataRange; % scales between 0 and 1

if (flag)
  data = data * 2 - 1; % scales between -1 and 1
end

dataOut = data;
% end scaleData

% EOF
