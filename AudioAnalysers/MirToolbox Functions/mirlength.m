function varargout = mirlength(orig,varargin)
%   mirlength(x) indicates the temporal length of x.
%   If x is decomposed into frames,
%       mirlength(x) indicates the frame length, whereas 
%       mirlength(x,'Global') indicates the total temporal spanning of the
%           frame decomposition. 
%   Optional argument:
%       mirlength(...,'Unit',u) indicates the length unit.
%           Possible values:
%               u = 'Second': duration in seconds (Default).
%               u = 'Sample': length in number of samples.

        unit.key = 'Unit';
        unit.type = 'String';
        unit.choice = {'Second','Sample'};
        unit.default = 'Second';
    option.unit = unit;   
    
specif.option = option;
     
varargout = mirfunction(@mirlength,orig,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
type = 'mirscalar';


function z = main(a,option,postoption)
if iscell(a)
    a = a{1};
end
d = get(a,'Data');
f = get(a,'Sampling');
v = cell(1,length(d));
for h = 1:length(d)
    v{h} = cell(1,length(d{h}));
    for i = 1:length(d{h})
        di = d{h}{i};
        v{h}{i} = size(d{h}{i},1);
        if strcmp(option.unit,'Second')
            v{h}{i} = v{h}{i}/f{h};
        end
    end
end
z = mirscalar(a,'Data',v,'Title','Temporal length');
if strcmp(option.unit,'Second')
    z = set(z,'Unit','s.');
else
    z = set(z,'Unit','samples.');
end