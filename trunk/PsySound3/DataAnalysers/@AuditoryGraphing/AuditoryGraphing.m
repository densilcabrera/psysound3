function obj = AuditoryGraphing(varargin)
% BASICPLOT Constructor. Implements basic plotting functionality
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'AuditoryGraphing', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'AuditoryGraphing')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for AuditoryGraphing : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Auditory Graphing');
obj = set(obj, 'Group', 'Sonification');

% EOF
