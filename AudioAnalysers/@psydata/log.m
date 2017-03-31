function y = log(x)

d = get(x,'Data');
e = cell(1,length(d));
l = get(x,'Name');
m = cell(1,length(l));
    
for i = 1:length(d)
    e{i} = cell(1,length(d{i}));
    for j = 1:length(d{i})
        e{i}{j} = log(d{i}{j});
    end
    m{i} = ['log_' l{i}];
end
y = set(x,'Data',e,'Name',m);