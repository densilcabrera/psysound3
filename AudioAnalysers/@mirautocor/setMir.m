function aa = setMir(a,varargin)
% SET Set properties for the MIRautocor object
% and return the updated object

propertyArgIn = varargin;
f = a.freq;
s = a.ofspectrum;
w = a.window;
nw = a.normalwindow;
d = mirdata(a);
d = set(d,'Title',get(a,'Title'),'Abs',get(a,'Abs'),'Ord',get(a,'Ord'));
while length(propertyArgIn) >= 2,
   prop = propertyArgIn{1};
   val = propertyArgIn{2};
   propertyArgIn = propertyArgIn(3:end);
   switch prop
       case 'Coeff'
           d = set(d,'Data',val);
       case 'Delay'
           d = set(d,'Pos',val);
       case 'FreqDomain'
           f = val;
       case 'OfSpectrum'
           s = val;
       case 'Window'
           w = val;
       case 'LowRemoved'
           lr = val;
       otherwise
           d = set(d,prop,val);
   end
end
aa.freq = f;
aa.ofspectrum = s;
aa.window = w;
aa.normalwindow = nw;
aa = class(aa,'mirautocor',d);