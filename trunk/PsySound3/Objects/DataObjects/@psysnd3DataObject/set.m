function obj = set(obj, propName, propVal)
% SET method for psysnd3DataObject

% Note: isfield appears to be broken on MATLAB 7.4 so using a
% switch statement instead
switch(lower(propName))
 case 'name'
  obj.Name = propVal;
 
 case 'freqscale'
  obj.FreqScale = propVal;
 
 case 'datascale'
  obj.DataScale = propVal;
 
 case 'stats'
  if ~isa(propVal, 'psysnd3Stats')
    error([class(propVal),' is not a Stats object!']);
  else
    obj.Stats = propVal;
  end
 
 otherwise
  error(['Unknown field name ', propName]);
end

% [EOF]
