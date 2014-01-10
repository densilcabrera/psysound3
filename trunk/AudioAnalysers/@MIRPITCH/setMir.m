function pp = setMir(p,varargin)
% SET Set properties for the MIRpitch object
% and return the updated object
% Modified for the needs of parallell computing features in Psysound3

propertyArgIn = varargin;
a = p.amplitude;
c = p.Frame;
d = p.SpectrumType;

s = mirscalar(p);
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Amplitude'
           a = val;
       case 'Frame'
           c = val;
       case 'SpectrumType'
           d = val;
           
       otherwise
           s = setMir(s,prop,val);
   end
end
pp.amplitude = a;
pp.Frame = c;
pp.SpectrumType = d;
pp = class(pp,'MIRPITCH',s);
pp = set(pp,'Name','MirToolbox (MIRPITCH)');