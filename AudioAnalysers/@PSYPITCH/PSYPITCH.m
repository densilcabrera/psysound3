function obj = PSYPITCH(varargin)
% SWIPEP Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = psyscalar();
  obj.amplitude = [];
  
  obj.Frame=[];
  obj.SpectrumType='';
  
  obj = class(obj, 'PSYPITCH', base);

 case 1
  % Copy Constructor
  % if single argument of class PSYPITCH return it
  arg1 = varargin{1};
  if isa(arg1, 'PSYPITCH')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = psyscalar(arg1);
    obj.amplitude = [];  
    
    obj.Frame=[];
    obj.SpectrumType='';
    
    obj = class(obj, 'PSYPITCH', base);
  
  else
    error('PSYPITCH: Invalid Argument type');
  end
  
 otherwise
  error('PSYPITCH: Invalid number of input arguments')
end

% Specify analyser type ??
% obj = set(obj, 'type', 'Raw');

% Set default windowlength ??
% numSamples = get(obj,'samples') + mod(get(obj,'samples'),2);
% obj = set(obj, 'windowLength', numSamples);

% set output rate to 100 - if synchronise is used this will be changed
% This considerably decreases storage space necessary.
% obj = set(obj, 'outputDataRate', 100);

% Set name
obj = set(obj, 'Name', 'MirToolbox (PSYPITCH)');

% end PSYPITCH constructor
