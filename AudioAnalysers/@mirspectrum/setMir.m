function ss = set(s,varargin)
% SET Set properties for the MIRspectrum object
% and return the updated object

propertyArgIn = varargin;
ph = s.phase;
log = s.log;
pow = s.pow;
xs = s.xscale;
d = mirdata(s);
d = set(d,'Title',get(s,'Title'),'Abs',get(s,'Abs'),'Ord',get(s,'Ord'));
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Magnitude'
           d = set(d,'Data',val);
       case 'Frequency'
           d = set(d,'Pos',val);
       case 'Phase'
           ph = val;
       case 'log'
           log = val;
       case 'XScale'
           xs = val;
       case 'Power'
           pow = val;
       otherwise
           d = set(d,prop,val);
   end
end
ss.phase = ph;
ss.log = log;
ss.xscale = xs;
ss.pow = pow;
ss = class(ss,'mirspectrum',d);