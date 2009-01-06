function [fhOut, mLevels, adjs] = calibrate(fhIn, type, varargin)
% CALIBRATE Adds calibration coeffecients to the the filehandles
%
% Input arguments
%     fhIn     - array of filehandle structs
%     type     - can be either 'WithFiles' or 'WithOutFiles'
%
%     Rest as follows:
%    ( ...'WithFiles', name_of_calib_file, calibLevel)
%    ( ...'WithOutFiles', weightingType,  choice,    level)
%                              A           SPL        22
%                              B         Constant     40
%                              C          Median
%                              D           Max
%                              Z           Min
%
%  Examples:
%  --------
%
%  fh = calibrate(fh, 'Cal-40dB.wav', 94);
%
%  fh = calibrate(fh, 'A', 'Median');
%
%  fh = calibrate(fh, 'C', 'SPL', 40)

% Initialise output argument, in case of an error
fhOut   = fhIn;
mLevels = [];
adjs    = [];

switch(type)
 case 'WithFiles'
  if length(varargin) ~= 2
    error('calibrate: invalid number of arguments');
  end

  fh = estimWithFiles(fhIn, varargin{:});
  
 case 'WithOutFiles'
  [fh, mLevels, adjs] = estimWithOutFiles(fhIn, varargin{:});
 
 otherwise
  error(['calibrate: Unknown type ''', type, ''' specified']);
end

% Assign input argument
fhOut = fh;

%
% Local subfunctions
%
function fh = estimWithFiles(fh, calFileName, calLevel)

% Get the coeff
calCoeff = estimateCalibrationCoefficient(calFileName, calLevel);
  
for i = 1:length(fh)
  fh(i).calCoeff = calCoeff;
end

% end estimWithFiles

%
% Estimation without files
%
function [fh, meanLevels, adjs] = estimWithOutFiles(fh, wType, choice, ...
                                                                  varargin)

len   = length(fh);
level = 0;
wbh   = -1;

if ~isempty(varargin)
  level = varargin{1};

  if length(varargin) > 1
    % Use the supplied waitbar
    wbh = varargin{2};
  end
end

meanLevels = zeros(len, 1);
adjs       = zeros(len, 1);
% Run the SLM analyser and cache the mean levels
for i=1:len
  % Create new object
  S = SLM(fh(i));
  
  % Set the weighting and integrator types
  if strcmp(choice, 'NoChange')
    S.wChoices = 'Z';
  else
    S.wChoices = wType;
  end
  S.iChoices = 'f';
    
  % Update wait bar, if supplied
  if ishandle(wbh)
    wbStr = sprintf('Calculating adjustments for\n%s (%i/%i)', ...
                    fh(i).name, i, len);
    wbh = waitbar(i/len, wbh, wbStr);
  end
  
  % Run
  S = process(S, fh(i), [], 'calibrate');
  
  % Average the timeseries output
  meanLevels(i) = S.output{1}.Stats.mean;
end

% Now loop over, figure out the adjustments and set the calibration
% coeffecient on the filehandles
for i = 1:len
  switch(choice)
   case 'SPL'
    adj = level - meanLevels(i);
   case 'Constant'
    adj = level;
   case 'Median'
    adj = median(meanLevels) - meanLevels(i);
   case 'Max'
    adj = max(meanLevels) - meanLevels(i);
   case 'Min'
    adj = min(meanLevels) - meanLevels(i);
   case 'NoChange'
    adj = 0;
   otherwise
    error(['calibrate: unknown choice ''', choice, '''']);
  end

  % Set the coeff
  fh(i).calCoeff = 10^(adj/20);
  adjs(i) = adj;
end

% end estimWithFiles

% [EOF]