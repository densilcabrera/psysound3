function r = mirgetrange(x)

if isempty(x)
    r = {};
    return
end

if isstruct(x)
    fields = fieldnames(x);
    for f = 1:length(fields)
        d.(fields{f}) = mirgetrange(x.(fields{f}));
    end
    return
end

if iscell(x)
    x = x{1};
end
v = get(x,'Data');
if isa(x,'mirscalar')
    m = get(x,'Mode');
end

if isa(x,'mirclassify')
    d = get(x,'Data');
    return
end

if isa(x,'miremotion')
    return
end

if isa(x,'mirsimatrix')
    return
end

pv = get(x,'PeakVal');
if not(isempty(pv)) && not(isempty(pv{1})) && not(isempty(pv{1}{1}))
    d = uncell(pv);
else
    d = uncell(v,isa(x,'mirscalar'));
end

if not(iscell(d))
    d = {d};
end
r = [];
for i = 1:length(d)
    r = [r;d{i}(:)];
end
r = sort(r);