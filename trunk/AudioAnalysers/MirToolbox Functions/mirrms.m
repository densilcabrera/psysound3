function varargout = mirrms(x,varargin)
%   e = mirrms(x) calculates the root mean square energy.
%   Optional arguments:
%       mirrms(...,'Frame') computes the temporal evolution of the energy.
%       mirrms(...,'Root',0) does not apply the root operation to the mean
%           square energy.

        normal.key = 'Normal';
        normal.type = 'Boolean';
        normal.default = 1;
    option.normal = normal;
    
        root.key = 'Root';
        root.type = 'Boolean';
        root.default = 1;
    option.root = root;
    
specif.option = option;

specif.defaultframelength = 0.05;
specif.defaultframehop = 0.5;

specif.eachchunk = @eachchunk;
specif.combinechunk = @combinechunk;
specif.afterchunk = @afterchunk;

varargout = mirfunction(@mirrms,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
type = 'mirscalar';


function e = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
d = get(x,'Data');
v = mircompute(@algo,d,option);
e = mirscalar(x,'Data',v,'Title','RMS energy');


function e = algo(d,option)
nl = size(d,1);
nc = size(d,2);
nch = size(d,3);
e = zeros(1,nc,nch);
for i = 1:nch
    for j = 1:nc
        if option.root
            e(1,j,i) = norm(d(:,j,i));
        else
            e(1,j,i) = d(:,j,i)'*d(:,j,i);
        end
    end
end
if option.normal
    e = e/sqrt(nl);
end


function [y orig] = eachchunk(orig,option,missing,postchunk)
option.normal = 0;
y = mirrms(orig,option);


function y = combinechunk(old,new)
do = get(old,'Data');
do = do{1}{1};
dn = get(new,'Data');
dn = dn{1}{1};
y = set(old,'ChunkData',sqrt(do^2+dn^2));


function y = afterchunk(orig,length,postoption)
d = get(orig,'Data');
v = mircompute(@afternorm,d,length);
y = set(orig,'Data',v);


function e = afternorm(d,length)
e = d/sqrt(length);