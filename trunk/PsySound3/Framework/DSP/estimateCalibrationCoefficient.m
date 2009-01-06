function [calCoeff, w] = estimateCalibrationCoefficient(calFileName, dBSPL)
% ESTIMATECALIBRATIONCOEFFICIENT Find the calibration coefficient
%                                of a 'dBSPL' dB SPL calibration
%                                signal
%
% w - returns the warning text, if asked otherwise it goes ahead
%     and issues the warning

w = '';

% Get some basic info
fh = readData(calFileName);

% Warn if data is less than a second
if (fh.samples < fh.sampleRate)
  message = sprintf(['Found only %d samples, representing %f secs ' ...
                     'worth of data in calibration file ''%s''. ' ...
                     'Psysound recommends data of atleast 1 sec ' ...
                     'duration.'], fh.samples, fh.samples/fh.sampleRate, ...
                    fh.name);
  if nargout > 1
    w = message;
  else
    warning(message);
  end
end

% Set the calibration coeffecient
fh.calCoeff = 1;

% Read data
fh = readData(fh);

% Extract the actual non-zero-padded data
data = fh.data(fh.winDataStart:fh.winDataEnd);

% Calculate coeff
RMS       = sqrt(mean(data.^2))/20e-6;
RMSLevel  = 20 * log10(RMS);
calOffset = dBSPL - RMSLevel;
calCoeff  = 10.^(calOffset/20);

% EOF
