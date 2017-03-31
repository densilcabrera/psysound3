function c = plus(a,b)

d = get(a,'Data');
e = get(b,'Data');
f = cell(1,length(d));
p = get(a,'Time');
q = get(b,'Time');
r = cell(1,length(d));
l = get(a,'Name');
m = get(b,'Name');
n = cell(1,length(l));
for i = 1:length(d)
    f{i} = cell(1,length(d{i}));
    for j = 1:length(d{i})
        ld = size(d{i}{j},1);
        le = size(e{i}{j},1);
        if ld > le
            r{i}{j} = p{i}{j};
            f{i}{j} = d{i}{j} + [e{i}{j};zeros(ld-le,size(e,2),size(e,3))];
        else
            r{i}{j} = q{i}{j};
            f{i}{j} = [d{i}{j};zeros(le-ld,size(d,2),size(d,3))] + e{i}{j};
        end
    end
    n{i} = [l{i} '+' m{i}];
end
c = set(a,'Pos',r,'Data',f,'Name',n);