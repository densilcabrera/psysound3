function obj = psysnd3DataObject(varargin)
% PSYSND3DATAOBJECT  Base class constructor for all PsySound3 data
%                    objects

switch(nargin)
 case 0
  % Create an empty object - Default constructor
  obj = struct('Name',      '',       ...
               'FreqScale', 'linear', ...
               'DataScale', 'linear', ...
               'Stats',     []);
  
  obj = class(obj, 'psysnd3DataObject');
  
 case 1
  % Copy constructor/Constructor with a supplied name
  arg1 = varargin{1};
  
  if isa(arg1, 'DataObject')
    % Return objects of the same type
    obj = arg1;
  
  elseif isstr(arg1)
    % Call default constructor
    obj = psysnd3DataObject;
    
    % and set the name
    obj.Name = arg1;
    
  else
    error(['Unknown argument of type ', class(arg1)]);
  end

 otherwise
  error('Unknown number of inputs encountered');
end % switch

% [EOF]
