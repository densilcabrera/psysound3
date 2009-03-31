function obj = IACF(varargin)
% IACF Constructor
%

switch nargin
 case 0
  % Default Constructor
  % Inherit from the Analyser base class
  base = Analyser();

  initObj();
  obj = class(obj, 'IACF', base);
  
 case 1
  % Copy Constructor
  % if single argument of class IACF, return it
  arg1 = varargin{1};
  if isa(arg1, 'IACF')
    obj = arg1;
  elseif isstruct(arg1)
    % This should be a file handle
    base = Analyser(arg1);
    
    initObj();
    obj = class(obj, 'IACF', base);
  
  else
    error('IACF: Invalid Argument type');
  end
  
 otherwise
  error('IACF: Invalid number of input arguments')
end

  function initObj()
   % Default struct
   obj = struct('IntTime', [], ...
                'tStep',   []);
   
   end % initObj
 
% Set name
obj = set(obj, 'Name', 'Auto & Cross-Correlation (Ando)');

% Set stereo mode
obj = set(obj, 'multiChannelSupport', true);

% Set default Integration time
obj = setIntTime(obj, 1);

% Set default window time step
obj = settStep(obj, 0.5);

% Specify analyser type
obj = set(obj, 'type', 'FrequencyDomain');

end % IACF Constructor
