function ss = setMir(s,varargin)
% SET Set properties for the MIRscalar object
% and return the updated object.
propertyArgIn = varargin;
m = s.mode;
l = s.legend;
p = s.parameter;
d = mirdata(s);
d = setMir(d,'Title',get(s,'Title'),'Abs',get(s,'Abs'),'Ord',get(s,'Ord'));
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Mode'
           m = val;
       case 'Legend'
           l = val;
       case 'Parameter'
           p = val;
       otherwise
           d = setMir(d,prop,val);
   end
end
ss.mode = m;
ss.legend = l;
ss.parameter = p;
ss = class(ss,'mirscalar',d);

end