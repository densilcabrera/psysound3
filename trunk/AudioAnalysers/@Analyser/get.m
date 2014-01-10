function propVal = get(obj, propName)
% GET Returns the value of the property



% Get field
switch(propName)
 case 'Name'
  propVal = obj.Name;
 case 'filename'
  propVal = obj.filename;
 case 'fs'
  propVal = obj.fs;
 case 'bits'
  propVal = obj.bits;
 case 'samples'
  propVal = obj.samples;
 case 'channels'
  propVal = obj.channels;
 case 'windowLength'
  propVal = obj.windowLength;
 case 'windowFunc'
  propVal = obj.windowFunc;
 case 'overlap'
  propVal = obj.overlap;
 case 'type'
  propVal = obj.type;
 case 'synch'
  propVal = obj.synch;
 case 'windowOffset'
  propVal = obj.windowOffset;
 case 'outputDataRate'
  propVal = obj.outputDataRate;
 case 'outputSamples'
  propVal = obj.outputSamples;
 case 'multiChannelSupport'
  propVal = obj.multiChannelSupport;
 case 'output'
  propVal = obj.output;
 case 'SummaryOutput'
  propVal = obj.SummaryOutput;
 case 'OptionStr'
  propVal = obj.OptionStr;
 otherwise
  % See if a specialised get method for the property value exists

     
  try      
    m = ['get', propName];
    propVal = eval([m, '(obj)']);
    catch
        
        if regexp(class(obj),'mir','ignorecase','start')==1
    
            try
                
                propVal=getMir(obj,propName);
            catch ME
                 error(['Problem with the name (regexp()), or with getMir for class',class(obj),...
                        ' \n or propName might be an unknown field of this class'])             
            end
            
        else
    error(['Analyser: get: ', propName, ' is not a field of the Analyser', ...
            ' class.  Could not resolve ', m, ' for class ', class(obj)]);
        end
    end
 end
 
end




