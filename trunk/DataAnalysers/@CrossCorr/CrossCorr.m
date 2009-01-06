function obj = CrossCorr(varargin)
% CROSSCORR   Constructor. Implements CrossCorrelation
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'CrossCorr', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'CrossCorr')
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
obj = set(obj, 'Name',  'Cross-Correlation');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
