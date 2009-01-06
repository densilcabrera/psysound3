function obj = BasicPlot(varargin)
% BASICPLOT Constructor. Implements basic plotting functionality
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'BasicPlot', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'BasicPlot')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for BasicPlot : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Single Axis');
obj = set(obj, 'Group', 'Visualisation');

% EOF
