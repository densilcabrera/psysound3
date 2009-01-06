function obj = ExploratorySoundAnalysis(varargin)
% ExploratorySoundAnalysis Constructor. Implements basic ESa functionality
%

switch(nargin)
 case 0
  obj  = struct([]); % no fields
  base = DataAnalyser;

  obj = class(obj, 'ExploratorySoundAnalysis', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'ExploratorySoundAnalysis')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for Exploratory Sound Analysis : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Exploratory Sound Analysis');
obj = set(obj, 'Group', 'Sonification');

% EOF
