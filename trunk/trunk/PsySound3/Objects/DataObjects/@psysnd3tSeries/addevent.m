function obj = addevent(obj,varargin)
% Wrapper for addevent command
if nargin < 2
disp('addevent for psysnd3tsereis needs 3 arguments');
else
  tsObj = addevent(obj.tsObj, varargin{1},varargin{2});
 end
obj.tsObj= tsObj;
% [EOF]

