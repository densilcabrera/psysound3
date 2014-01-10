function c = purgedata(c)

d = get(c,'Data');
l = length(d);
empty = cell(1,l);
for i = 1:l
    empty{i} = cell(1,length(d{i}));
end
c = set(c,'PeakPos',empty,'PeakVal',empty,...
          'PeakPrecisePos',{},'PeakPreciseVal',{},'PeakMode',empty);
          %,...'Tmp',[]);