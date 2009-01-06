function val = get(obj, propName)
% GET  method for the psysnd3AudioTSeries object

switch(lower(propName))
  % Special handling for base class fields
 case 'origfilename'
  val = obj.origFileName;
  
 case 'fs'
  val = obj.Fs;
  
 case 'bits'
  val = obj.bits;
  
 otherwise
  % Ask the tSeries object
  val = get(obj.psysnd3tSeries, propName);
end

% [EOF]
