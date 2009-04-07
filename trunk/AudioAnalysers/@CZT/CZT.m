function obj = CZT(varargin)
% CZT Constructor
%

obj = struct('levelOffset', 0, 'complexAverage',0,'cztF',[]);

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();
  
  obj = class(obj, 'CZT', base);

 case 1
  % Copy Constructor
  % if single argument of class CZT, return it
  arg1 = varargin{1};
  if isa(arg1, 'CZT')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'CZT', base);
  
  else
    error('CZT: Invalid Argument type');
  end
  
 otherwise
  error('CZT: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'CZT Spectrum'); 

% Set default Overlap, Window size and Windowing function
ov.size = 75;
ov.type = 'percent';

obj = set(obj, 'overlap', ov);
obj = set(obj, 'windowLength', 2048);
obj = set(obj, 'windowFunc', 'Hanning');

% Specify analyser type
obj = set(obj, 'type', 'FrequencyDomain');
% Set stereo mode
obj = set(obj, 'multiChannelSupport', true);

% obj = setlevelOffset(obj, 104.11);
obj = setlevelOffset(obj, 97.01); % calculated from power sum of spectrum with window function correction

end % CZT Constructor
