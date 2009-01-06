function obj = StatisticsBasic(varargin)
% STATISTICS  Basic statistics 
%

switch(nargin)
 case 0
  % Hold onto text and Table handles
  obj  = struct('Display', 0, ...
                'Table', 0);
  base = DataAnalyser;

  obj = class(obj, 'StatisticsBasic', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'StatisticsBasic')
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
obj = set(obj, 'Name',  'Basic Statistics');
obj = set(obj, 'Group', 'Statistics');

% EOF
