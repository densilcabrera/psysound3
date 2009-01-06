function out = class(obj, varargin)
% CLASS Overloaded class method

if nargin == 1
  str = builtin('class', obj);
  
  % Strip off the leading 'psysnd3' string
  out = str(length('psysnd3')+1:end);
  
else
  % Dispatch it off to MATLAB
  out = builtin('class', obj, varargin{:});
end

% [EOF]
