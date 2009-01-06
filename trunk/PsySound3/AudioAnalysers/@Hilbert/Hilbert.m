function obj = Hilbert(varargin)
% HILBERT Constructor
%
obj = struct;

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  % Initialise Hilbert specific fields
  initObj();

  obj = class(obj, 'Hilbert', base);

 case 1
  % Copy Constructor
  % if single argument of class Hilbert, return it
  arg1 = varargin{1};
  if isa(arg1, 'Hilbert')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    % Initialise Hilbert specific fields
    initObj();
    
    obj = class(obj, 'Hilbert', base);
  
  else
    error('Hilbert: Invalid Argument type');
  end
  
 otherwise
  error('Hilbert: Invalid number of input arguments')
end

% Set Name
obj = set(obj, 'Name', 'Hilbert');

% Set default Overlap
ov.size = 100;
ov.type = 'ms';

obj = set(obj, 'overlap', ov);

% Designate this as a time domaing analyser
obj = set(obj, 'type', 'TimeDomain');

% Set the window offset
obj = set(obj, 'windowOffset', round(getOverlap(obj)/2));

% end Hilbert constructor

  % Initialisation subfunction
  function initObj
   % These are Hilbert specific fields
   obj.PreFilterWeighting = 'none';
   
   end % initObj
end % Hilbert Constructor
