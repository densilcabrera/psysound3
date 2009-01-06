function obj = SpectralIndicators(varargin)
% AUTOCORR   Constructor. Implements AutoCorrelation
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'SpectralIndicators', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'SpectralIndicators')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for SpectralIndicators : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Spectral Indicators');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
