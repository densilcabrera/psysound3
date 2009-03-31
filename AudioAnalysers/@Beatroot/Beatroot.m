function obj = Beatroot(varargin)
% Beatroot Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  obj = class(obj, 'Beatroot', base);

 case 1
  % Copy Constructor
  % if single argument of class Beatroot, return it
  arg1 = varargin{1};
  if isa(arg1, 'Beatroot')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    obj = class(obj, 'Beatroot', base);
  
    % Set window length
    fs = get(obj, 'fs');
    obj = set(obj, 'windowLength', 0.01);
  
    
  else
    error('Beatroot: Invalid Argument type');
  end
  
 otherwise
  error('Beatroot: Invalid number of input arguments')
end

% Set name
obj = set(obj, 'Name', 'Beatroot Beat Detection');

% end Beatroot constructor
