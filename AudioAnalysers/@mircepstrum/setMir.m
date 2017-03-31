function ss = set(s,varargin)
% SET Set properties for the MIRcepstrum object
% and return the updated object

propertyArgIn = varargin;
p = s.phase;
f = s.freq;
d = mirdata(s);
d = set(d,'Title',get(s,'Title'),'Abs',get(s,'Abs'),'Ord',get(s,'Ord'));
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Magnitude'
           d = set(d,'Data',val);
       case 'Phase'
           p = val;
       case 'Quefrency'
           d = set(d,'Pos',val);
       case 'FreqDomain'
           f = val;
       otherwise
           d = set(d,prop,val);
   end
end
ss.phase = p;
ss.freq = f;
ss = class(ss,'mircepstrum',d);