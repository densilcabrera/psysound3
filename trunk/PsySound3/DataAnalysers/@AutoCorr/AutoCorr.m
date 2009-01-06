function obj = AutoCorr(varargin)
% AUTOCORR   Constructor. Implements AutoCorrelation
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'AutoCorr', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'AutoCorr')
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
obj = set(obj, 'Name',  'Auto-Correlation');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
