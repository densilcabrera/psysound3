function out = getOverlap(obj)
% GETOVERLAP  The overlap is set as a structure in order to provide
%             flexibility in type.  This get method returns the
%             overlap in number of samples

% Get the overlap structure from the object
ov      = obj.overlap;
overlap = 0;

switch ov.type
 case 'samples'
  % The simplest case
  overlap = ov.size;
  
 case 'percent'
  % The overlap is specified as a percentage of the window length
  wl      = obj.windowLength;
  overlap = round((ov.size/100) * wl);
  
 case 'ms'
  % The overlap is specified in milliseconds
  fs      = obj.fs;
  overlap = round(ov.size * 1e-3 * fs);
  
 case 's'
  % The overlap is specified in seconds
  fs      = obj.fs;
  overlap = round(ov.size * fs);
  
 otherwise
  error('Invalid overlap type');
end

% Assign output
out = overlap;