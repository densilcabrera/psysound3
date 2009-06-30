function obj = psysnd3Stats(varargin)
% PSYSND3STATS  Object to hold data statistics
%

switch(nargin)
 case 0
   emptyStr = struct('Name','','Unit','','Value',[]);
   
  % Create an empty object - Default constructor
  obj = struct('Name',   '', ...
               'min',    [], ...
               'max',    [], ...
               'mean',   [], ...
               'median', [], ...
               'stdev',  [], ...
               'skewness',    [], ...
               'kurtosis',    [], ...
               'percentiles', [1:99]', ...
               'Summaries',  [],...
               'SpecSummaries', []);
  
             
  obj = class(obj, 'psysnd3Stats');
  
 case {1, 2, 3}
  % Copy constructor/Constructor with a supplied name
  arg1 = varargin{1};
  
  if isa(arg1, 'DataObject')
    % Return objects of the same type
    obj = arg1;
  
  elseif isnumeric(arg1)
    % Call default constructor
    obj  = psysnd3Stats;
    data = arg1;
    
    if nargin == 2
      dbOffset = varargin{2};
      obj = calcStats(obj, data, dbOffset);
    else
      % No offset
      obj = calcStats(obj, data, 0);
    end
  else
    error(['Unknown argument of type ', class(arg1)]);
  end

 otherwise
  error('Unknown number of inputs encountered');
end % switch

% end main function

% Calculate and store the stats
function obj = calcStats(obj, data, dBOffset)
  
  % Assume non-decibel data if dBoffset is zero
    
  % Remove any nan's
  data(find(isnan(data))) = [];
  
  if dBOffset
    % Convert back to power values before computing the average
    powData   = 10.^((data-dBOffset)/10);
    muPowData = mean(powData);
    
    % Back to decibels
    obj.mean = power2dB(muPowData) + dBOffset;
  else
    mu = NaN;
    obj.mean = mu;
  end

  % Works out the percentiles
  pc  = [1:99]';
  len = length(pc);
  for i=1:len
    obj.percentiles(pc(i)) = percentile(data, pc(i));
  end
  obj.min    = min(data);
  obj.max    = max(data);
  obj.median = median(data);

  %% Higher-order stats %%
  
  % Standard deviation is the square root of the variance, where
  %
  % Variance is E(x-mu)^2
  % 
  if dBOffset
    stdev = sqrt(mean((powData - muPowData).^2));
  else
    stdev = sqrt(mean((data - mu).^2));
  end
  obj.stdev = stdev;
  
  %              E(x-mu)^3
  % Skewness is  ---------
  %                std^3
  if dBOffset
    obj.skewness = (mean((powData - muPowData).^3))/stdev^3;
  else
    obj.skewness = (mean((data    - mu).^3))/stdev^3;
  end
  
  %              E(x-mu)^4
  % Kurtosis is  ---------
  %                std^4
  if dBOffset
    obj.kurtosis = (mean((powData - muPowData).^4))/stdev^4;
  else
    obj.kurtosis = (mean((data    - mu).^4))/stdev^4;
  end
  % end calcStats
% [EOF]
