function obj = SLM(varargin)
% SLM Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();
  
  initObj();
  obj = class(obj, 'SLM', base);

 case 1
  % Copy Constructor
  % if single argument of class SLM, return it
  arg1 = varargin{1};
  if isa(arg1, 'SLM')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    initObj();
    obj = class(obj, 'SLM', base);

  else
    error('SLM: Invalid Argument type');
  end
  
 otherwise
  error('SLM: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'Sound level meter');

% Specify analyser type
obj = set(obj, 'type', 'TimeDomain');

  % Initialising function
  % SLM has the following additional fields
  function initObj
  
  obj.wChoices = 'AZ';
  obj.iChoices = {'f','s'};

  obj.ignoreDelay = true;
  
  end % initObj
end % SLM Constructor
