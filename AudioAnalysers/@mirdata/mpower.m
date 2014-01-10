function c = mpower(a,b)

d = get(a,'Data');
f = cell(1,length(d));
n = get(a,'Name');
t = get(a,'Title');
if not(isa(a,'miraudio'))
    if isa(b,'mirdata')
        t = [t,' ^ ',get(b,'Title')];
    else
        t = [t,' ^ ',num2str(b)];
    end
end
    
if isa(b,'mirdata')
    e = get(b,'Data');
    m = get(b,'Name');
else
    e = {{b}};
    m = {num2str(b)};
end
    
for i = 1:length(d)
    f{i} = cell(1,length(d{i}));
    for j = 1:length(d{i})
        ld = size(d{i}{j},1);
        le = size(e{i}{j},1);
        if ld > le
            f{i}{j} = d{i}{j} .^ [e{i}{j};zeros(ld-le,size(e,2),size(e,3))];
        else
            f{i}{j} = [d{i}{j};zeros(le-ld,size(d,2),size(d,3))] .^ e{i}{j};
        end
    end
    if isa(a,'miraudio')
        n{i} = [n{i} '^' m{i}];
    end
end
c = set(a,'Data',f,'Name',n,'Title',t);