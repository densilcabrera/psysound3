function val = get(obj, propName)
% GET  method for the psysnd3tSeries object. Basically this
%      is just a wrapper for the timeseries object

switch(lower(propName))
  % Special handling for base class fields
 case 'timescale'
  val = get(obj.psysnd3DataObject, 'TimeScale');
  
 case 'datascale'
  val = get(obj.psysnd3DataObject, 'DataScale');
 
 case 'stats'
  val = get(obj.psysnd3DataObject, 'stats');
 
 case 'tsobj'
   val = obj.tsObj;
  
 otherwise
  % Ask the timeseries object
  val = get(obj.tsObj, propName);
end

% [EOF]
