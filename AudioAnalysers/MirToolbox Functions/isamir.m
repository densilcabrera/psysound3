function b = isamir(x,class)

if isempty(x) || isnumeric(x)
    b = 0;
    return
end

if iscell(x)
    x = x{1};
end

if isa(x,class)
    b = 1;
    return
elseif ischar(x) && strcmpi(class,'psyaudio')
    b = 1;
    return
elseif not(isa(x,'psydesign'))
    b = 0;
    return
end

type = get(x,'Type');
if iscell(type)
    type = type{1};
end
types = lineage(type);
b = 0;
i = 0;
while not(b) && i<length(types)
    i = i+1;
    if strcmpi(types(i),class)
        b = 1;
    end
end


function types = lineage(class)
switch class
    case {'psyaudio','mirenvelope'}
        parent = 'psytemporal';
    case {'psyautocor','psycepstrum','mirchromagram','mirhisto',...
          'mirkeysom','mirkeystrength','mirmatrix','mirmfcc',...
          'psyscalar','mirsimatrix','psyspectrum',...
          'psytemporal','mirtonalcentroid'}
        parent = 'psydata';
    otherwise
        parent = '';
end

if isempty(parent)
    types = {class};
else
    parents = lineage(parent);
    types = {class parents{:}};
end