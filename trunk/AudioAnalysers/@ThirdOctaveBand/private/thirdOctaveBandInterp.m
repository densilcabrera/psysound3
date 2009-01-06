function dataOut = thirdOctaveBandInterp(dataIn, factors)
% author : Matt Flax <flatmax @ http://www.flatmax.org> : Matt Flax is flatmax
% Feb. 2007 : For the psySound project

% The input data fileHandle.data is processed in the frequency domain to
% the power spectrum (intensity, not dB domain)

% Generate and run the 1/3 octave band filters
% This will NOT generate them if they exist and are valid.

% The low frequency filters suffer scaling artifacts which are a process of
% the filter generation. Attempts to scale these filters in amplitude were
% successful, however only for the non-interpolated results. The process of
% filter output interpolation (to preserve equal sample counts) destroys
% the scaling paradigm. For this reason scaling correction is turned off.
% It may be enabled in the file 'filter_third_octaves_downsample.m'

% % use this loop to find the required scaling parameters
% % ... run-offline - otherwise it recreates the file every
% % time!
% if 0
%   figure(1);
%   for j=1:length(fileHandle.thirdOctave.data)
%     DATA=abs(fft(fileHandle.thirdOctave.data{j}));
%     factors(j)=1/max(abs(DATA(1:end/2)));
%   end
%   save thirdOctaveScaleFactors.mat factors
% end

dataOut = {};

maxLength = 0;
% Figure out the max length
for j = 1:length(dataIn)
  ln = length(dataIn{j});
  if ln > maxLength
    maxLength = ln;
  end
end

desiredIndexes = (0:maxLength-1);
% interpolate the data to be of the same dimension ...
for j = 1:length(dataIn)
  ln = length(dataIn{j});
  if ln ~= maxLength
    newIndexes = (0:ln/(ln-1):ln)*(maxLength-1)/(ln);
    mewIndexes = newIndexes+1;
    dataOut{j} = interp1(newIndexes', dataIn{j}/factors(j), ...
                         desiredIndexes','cubic');
    dataOut{j} = dataOut{j}*factors(j);
  else
    dataOut{j} = dataIn{j};
  end
end

% end thirdOctaveBand
