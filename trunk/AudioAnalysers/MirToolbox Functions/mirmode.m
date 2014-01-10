function varargout = mirmode(x,varargin)
%   m = mirmode(a) estimates the mode. A value of 0 indicates a complete
%       incertainty, whereas a positive value indicates a dominance of
%       major mode and a negative value indicates a dominance of minor mode.
%   Optional arguments:
%   mirmode(a,s) specifies a strategy. 
%       Possible values for s: 'Sum', 'Best'(default)

        stra.type = 'String';
        stra.default = 'Best';
        stra.choice = {'Best','Sum'};
    option.stra = stra;
    
specif.option = option;
specif.defaultframelength = 1;
specif.defaultframehop = .5;

varargout = mirfunction(@mirmode,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirkeystrength'))
    x = mirkeystrength(x);
end
type = 'mirscalar';


function o = main(s,option,postoption)
if iscell(s)
    s = s{1};
end
m = get(s,'Data');
if strcmpi(option.stra,'sum')
    v = mircompute(@algosum,m);
elseif strcmpi(option.stra,'best')
    v = mircompute(@algobest,m);
end
b = mirscalar(s,'Data',v,'Title','Mode');
o = {b,s};


function v = algosum(m)
v = sum(abs(m(:,:,:,1) - m(:,:,:,2)));


function v = algobest(m)
v = max(m(:,:,:,1)) - max(m(:,:,:,2));