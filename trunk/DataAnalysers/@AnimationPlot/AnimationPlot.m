function obj = AnimationPlot(varargin)
% BASICPLOT Constructor. Implements basic plotting functionality
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'AnimationPlot', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'AnimationPlot')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for AnimationPlot : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Animation Plot');
obj = set(obj, 'Group', 'Visualisation');

% EOF
