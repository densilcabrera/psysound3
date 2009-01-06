function val = get(obj, propName)
% GET method for Spectrum

% Note: isfield appears to be broken on MATLAB 7.4 so using a
% switch statement instead
switch(lower(propName))
 case 'freq'
  val = obj.Freq;
 
 case 'data'
  val = obj.Data;
 
 case 'dataname'
  val = obj.DataName;
 
 case 'freqname'
  val = obj.FreqName;
 
 case 'dataunit'
  val = obj.DataUnit;
 
 case 'frequnit'
  val = obj.FreqUnit;
  
 otherwise
  % Try the base class
  try
    val = get(obj.psysnd3DataObject, propName);
  catch
    error([propName ' is not a valid field of class Spectrum']);
  end
end % switch

% [EOF]
