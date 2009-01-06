function obj = DataAnalyser(varargin)
% DATANALYSER Base class constructor
%
% Fields:
%
%   Name    : Name of data analyser. May include any character
%   Group   : The exact tab group this belongs to 

switch(nargin)
 case 0
  obj.Name  = 'Base Data Analyser';
  obj.Group = '';
  
  obj = class(obj, 'DataAnalyser');
  
 case 1
  arg = varargin{1};
  
  if isa(arg, 'dataAnalyser')
    % Copy constructor
    obj = arg;
  else
    error('Unknown argument');
  end
  
 otherwise
  error(['Invalid number of arguments for dataAnalyser : ', ...
         num2str(nargin)]);
end

% EOF
