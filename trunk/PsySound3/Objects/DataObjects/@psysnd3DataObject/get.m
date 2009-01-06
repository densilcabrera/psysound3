function val = get(obj, propName)
% GET method for psysnd3DataObject

% Note: isfield appears to be broken on MATLAB 7.4 so using a
% switch statement instead
switch(lower(propName))
 case 'name'
  val = obj.Name;
 
 case 'freqscale'
  val = obj.FreqScale;
 
 case 'datascale'
  val = obj.DataScale;
 
 case 'stats'
  val = obj.Stats;
 
 otherwise
  error(['Unknown field name ', propName]);
end

% [EOF]
