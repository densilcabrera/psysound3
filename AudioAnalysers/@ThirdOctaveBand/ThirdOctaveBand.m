function obj = ThirdOctaveBand(varargin)
% THIRDOCTAVEBAND Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  obj = class(obj, 'ThirdOctaveBand', base);

 case 1
  % Copy Constructor
  % if single argument of class ThirdOctaveBand, return it
  arg1 = varargin{1};
  if isa(arg1, 'ThirdOctaveBand')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'ThirdOctaveBand', base);
  
  else
    error('ThirdOctaveBand: Invalid Argument type');
  end
  
 otherwise
  error('ThirdOctaveBand: Invalid number of input arguments')
end

% Specify analyser type
obj = set(obj, 'type', 'Raw');

% Set default windowlength
numSamples = get(obj,'samples') + mod(get(obj,'samples'),2);
obj = set(obj, 'windowLength', numSamples);


% set output rate to 100 - if synchronise is used this will be changed
% This considerably decreases storage space necessary.
obj = set(obj, 'outputDataRate', 100);

% Set name
obj = set(obj, 'Name', '1/3-Octave Band Spectrum');

% end ThirdOctaveBand constructor
