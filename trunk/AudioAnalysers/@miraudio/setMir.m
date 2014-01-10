function aa = setMir(a,varargin)
% SET Set properties for the miraudio object
% and return the updated object

if nargin == 3 && ischar(varargin{1}) && strcmp(varargin{1},'Extracted')
    aa = a;
    aa.extracted = varargin{2};
    return
end

t = mirtemporal(a);
t = set(t,'Title',get(a,'Title'),'Abs',get(a,'Abs'),'Ord',get(a,'Ord'),...
        varargin{:});
aa.fresh = a.fresh;
aa.extracted = a.extracted;
aa = class(aa,'miraudio',t);