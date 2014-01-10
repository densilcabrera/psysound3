function c = mirtimes(a,b)

d = getMir(a,'Data');
e = getMir(b,'Data');
f = cell(1,length(d));
p = getMir(a,'Pos');
q = getMir(b,'Pos');
r = cell(1,length(d));
l = getMir(a,'Name');
m = getMir(b,'Name');
n = cell(1,length(l));
for i = 1:length(d)
    f{i} = cell(1,length(d{i}));
    for j = 1:length(d{i})
        pij = p{i}{j}(:,1,1);
        qij = q{i}{j}(:,1,1);
        pq = pij; %union(pij,qij);
            % The sampling of the product is the sampling of the first
            % operand.
        dij = d{i}{j}; %interp1(pij,d{i}{j},pq);
        eij = interp1(qij,e{i}{j},pq);
        dij = max(dij,0);
        eij = max(eij,0);
        eij = eij./repmat(max(eij)+1e-16,[size(eij,1),1,1,1]);
            % The second operand of mirtimes is scaled from 0 to 1.
            % In this way, the range of value of the first operand is kept.
        f{i}{j} = dij.*eij;
        [x y] = find(isnan(f{i}{j}));
        x = unique(x);
        pq(x) = [];
        f{i}{j}(x,:) = [];
        r{i}{j} = repmat(pq,[1 size(p{i}{j},2) size(p{i}{j},3)]);
    end
    if strcmpi(l(i),m(i))
        n{i} = l(i);
    else
        n{i} = [l(i) '*' m(i)];
    end
end
c = set(a,'Pos',r,'Data',f,'Name',n,...
          'Title',[get(a,'Title') ' * ' get(b,'Title')]);