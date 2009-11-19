function obj = RLB(varargin)
% RLB Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();
  
  initObj();
  obj = class(obj, 'RLB', base);

 case 1
  % Copy Constructor
  % if single argument of class RLB, return it
  arg1 = varargin{1};
  if isa(arg1, 'RLB')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    initObj();
    obj = class(obj, 'RLB', base);

  else
    error('RLB: Invalid Argument type');
  end
  
 otherwise
  error('RLB: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'Revised LF B-curve (Soulodre)');

% Choose a large enough window to accomodate a 10s window@48K
obj = set(obj, 'windowLength', 2^19);

% Specify analyser type
obj = set(obj, 'type', 'TimeDomain');

  % Initialising function
  % RLB has the following additional fields
  function initObj
  
  obj.rmsChoices = 1;

  obj.ignoreDelay = true;

  end % initObj
end % RLB Constructor
