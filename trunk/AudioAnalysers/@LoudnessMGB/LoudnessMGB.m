function obj = LoudnessMGB(varargin)
% LoudnessMGB Constructor
%
obj = struct('filterMethod',1);

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  obj = class(obj, 'LoudnessMGB', base);

 case 1
  % Copy Constructor
  % if single argument of class LoudnessMGB, return it
  arg1 = varargin{1};
  if isa(arg1, 'LoudnessMGB')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'LoudnessMGB', base);
  
  else
    error('LoudnessMGB: Invalid Argument type');
  end
  
 otherwise
  error('LoudnessMGB: Invalid number of input arguments')
end

% Specify analyser type
obj = set(obj, 'type', 'Raw');

% Set default windowlength
numSamples = get(obj,'samples') + mod(get(obj,'samples'),2);
obj = set(obj, 'windowLength', numSamples);

% set output rate to 100 - if synchronise is used this will be changed
% This considerably decreases storage space necessary.
% obj = set(obj, 'outputDataRate', 100);

% Set stereo mode
obj = set(obj, 'multiChannelSupport', true);

% Set name
obj = set(obj, 'Name', 'Loudness (Moore, Glasberg and Baer)');

% end LoudnessMGB constructor
