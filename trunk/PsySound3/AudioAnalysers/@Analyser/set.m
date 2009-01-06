function obj = set(obj, propName, propVal)
% SET Sets the value of the property

% Set field
switch(propName)
 case 'Name'
  obj.Name = propVal;
 case 'filename'
  obj.filename = propVal;
 case 'fs'
  obj.fs             = propVal;
  obj.outputDataRate = propVal;  % Will be overwritten later, if
                                 % neccassary
 case 'bits'
  obj.bits = propVal;
 case 'samples'
  obj.samples       = propVal;
  obj.outputSamples = propVal;  % Will be overwritten later, if
                                % neccassary
 case 'channels'
  obj.channels = propVal;
 case 'windowLength'
  obj.windowLength = propVal;
 case 'windowFunc'
  obj.windowFunc = propVal;
 case 'overlap'
  if ~isstruct(propVal)
    error(['Overlap must be a structure with ''type'' and ''size'' ' ...
           'as fields']);
  end
  obj.overlap = propVal;
 case 'type'
  obj.type = propVal;
 case 'synch'
  obj.synch = propVal;
 case 'windowOffset'
  obj.windowOffset = propVal;
 case 'outputDataRate'
  obj.outputDataRate = propVal;
 case 'outputSamples'
  obj.outputSamples = propVal;
 case 'multiChannelSupport'
  obj.multiChannelSupport = propVal;
 case 'output'
  obj.output = propVal;
 otherwise
  % See if a specialised set method for the property value exists
  m = ['set', propName];
  try
    obj = eval([m, '(obj, propVal)']);
  catch
    error(['Analyser: set: ', propName, ' is not a field of the Analyser', ...
           ' class.  Could not resolve ', m, ' for class ', class(obj)]);
  end
end
