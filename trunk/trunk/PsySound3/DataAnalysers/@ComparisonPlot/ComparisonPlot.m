function obj = ComparisonPlot(varargin)
% COMPARISONPLOT  Basic plotting for comparisons 
%

switch(nargin)
 case 0
  % Hold onto text and Table handles
  obj  = struct('Display', 0, ...
                'Table', 0);
  base = DataAnalyser;

  obj = class(obj, 'ComparisonPlot', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'ComparisonPlot')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for Stats : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Comparison Plotting');
obj = set(obj, 'Group', 'Visualisation');

% EOF
