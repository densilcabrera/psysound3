function obj = set(obj, propName, propVal)
% SET  method for the psysnd3tSeries object. Basically this
%      is just a wrapper for the timeseries object

switch(lower(propName))
  % Special handling for base class fields
 case 'timescale'
  bObj = set(obj.psysnd3DataObject, 'TimeScale', propVal);
  obj.psysnd3DataObject = bObj;
  
 case 'datascale'
  bObj = set(obj.psysnd3DataObject, 'DataScale', propVal);
  obj.psysnd3DataObject = bObj;
  
 case 'stats'
  bObj = set(obj.psysnd3DataObject, 'Stats', propVal);
  obj.psysnd3DataObject = bObj;
  
 otherwise
  % Call set on the underlying timeseries object
  tsObj = set(obj.tsObj, propName, propVal);
  obj.tsObj = tsObj;
  
end

% [EOF]

