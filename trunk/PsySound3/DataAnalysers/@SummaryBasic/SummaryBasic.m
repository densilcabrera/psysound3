function obj = SummaryBasic(varargin)
% SUMMARYBASIC  Basic summary 
%

switch(nargin)
 case 0
  % Hold onto text handles
  obj  = struct('dataDir',            0, ...
                'fileInfo',           0, ...
                'AudioAnalyserInfo',  0, ...
                'AudioDataOutput',    0, ...
                'DataAnalyserOutput', 0, ...
                'PlayButton', 0);
  base = DataAnalyser;

  obj = class(obj, 'SummaryBasic', base);
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'SummaryBasic')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for SummaryBasic : ', ...
         num2str(nargin)]);
end

% Set defaults
obj = set(obj, 'Name',  'Basic');
obj = set(obj, 'Group', 'Summary');

% EOF
