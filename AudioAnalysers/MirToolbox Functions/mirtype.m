function type = mirtype(x)

if iscell(x)
    for i = 1:length(x)
        type{i} = mirtype(x{i});
    end
    return
end
    
if isa(x,'psydesign')
    type = get(x,'Type');
else
    type = class(x);
end