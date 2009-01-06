function obj = set(obj, propName, propVal)
% SET method for Spectrum

% Note: isfield appears to be broken on MATLAB 7.4 so using a
% switch statement instead
switch(lower(propName))
 case 'data'
  obj.Data = propVal;
  
 case 'freq'
  obj.Freq = propVal;
  
 case 'dataname'
  obj.DataName = propVal;
 
 case 'freqname'
  obj.FreqName = propVal;
 
 case 'dataunit'
  obj.DataUnit = propVal;
 
 case 'frequnit'
  obj.FreqUnit = propVal;
  
 otherwise
  % Try the base class
  try
    obj.psysnd3DataObject = set(obj.psysnd3DataObject, propName, propVal);
  catch
    error([propName ' is not a valid field of class Spectrum']);
  end
end % switch

% [EOF]
