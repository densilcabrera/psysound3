function obj = ChordalAnalysis(varargin)
% AUTOCORR   Constructor. Implements AutoCorrelation
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'ChordalAnalysis', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'ChordalAnalysis')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for ChordalAnalysis : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Chordal Analysis');
obj = set(obj, 'Group', 'Data Analysis');

% EOF
