function obj = set(obj,varargin)
% SET Sets the value of the property

%modified for MirToolbox
propName=varargin{1};
propVal=varargin{2};



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
 case 'SummaryOutput'
  obj.SummaryOutput = propVal;
 case 'OptionStr'
  obj.OptionStr = propVal;
     
        
 otherwise
  % See if a specialised set method for the property value exists
 
 
  
     try
        m = ['set', propName];
        obj = eval([m, '(obj, propVal)']);
     catch ME1
            
            if regexp(class(obj),'mir','ignorecase','start')==1
    
                try
                    obj=setMir(obj,varargin{:});
                catch ME2
                    error(['Problem with the name (regexp()), or with setMir for class ',class(obj),...
                    ' or ',propName, ' might be an unknown field of this class'])
                    
                end
            
            else
        error(['Analyser: set: ', propName, ' is not a field of the Analyser', ...
           ' class.  Could not resolve ', m, ' for class ', class(obj)]);
            end
     end
  end


end

