function tt = setMir(t,varargin)
% SET Set properties for the MIRtemporal object
% and return the updated object

propertyArgIn = varargin;
c = t.centered;
b = t.nbits;
d = mirdata(t);
d = set(d,'Title',get(t,'Title'),'Abs',get(t,'Abs'),'Ord',get(t,'Ord'));
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Time'
           d = set(d,'Pos',val);
       case 'Centered'
           c = val;
       case 'NBits'
           b = val;
       otherwise
           d = set(d,prop,val);
   end
end
tt.centered = c;
tt.nbits = b;
tt = class(tt,'mirtemporal',d);