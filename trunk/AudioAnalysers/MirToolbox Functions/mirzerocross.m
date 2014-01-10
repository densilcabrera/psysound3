function varargout = mirzerocross(orig,varargin)
%   mirzeroscross(x) computes the sign-changes rate along the signal x,
%       i.e., how many time the waveform crosses the X-axis. When applied on
%       an audio waveform, gives a notion of noise.
%   Optional argument:
%       mirzerocross(...,'Per',p) precises the temporal reference for the
%           rate computation.
%           Possible values:
%               p = 'Second': number of sign-changes per second (Default).
%               p = 'Sample': number of sign-changes divided by the total 
%                   number of samples.
%           The 'Second' option returns a result equal to the one returned
%               by the 'Sample' option multiplied by the sampling rate.
%       mirzerocross(...,'Dir',d) precises the definition of sign change.
%           Possible values:
%               d = 'One': number of sign-changes from negative to positive 
%                   only (or, equivalently, from positive to negative only).
%                       (Default)
%               d = 'Both': number of sign-changes in both ways.
%           The 'Both' option returns a result equal to twice the one
%               returned by the 'One' option.


        per.key = 'Per';
        per.type = 'String';
        per.choice = {'Second','Sample'};
        per.default = 'Second';
    option.per = per;

        dir.key = 'Dir';
        dir.type = 'String';
        dir.choice = {'One','Both'};
        dir.default = 'One';
    option.dir = dir;
    
specif.option = option;
     
varargout = mirfunction(@mirzerocross,orig,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirdata'))
    x = miraudio(x);
end
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
        nc = size(di,2);
        nf = size(di,3);
        nl = size(di,1);
        zc = sum( di(2:end,:,:).*di(1:(end-1),:,:) < 0 ) /nl;
        if strcmp(option.per,'Second')
            zc = zc*f{h};
        end
        if strcmp(option.dir,'One')
            zc = zc/2;
        end
        v{h}{i} = zc;
    end
end
z = mirscalar(a,'Data',v,'Title','Zero-crossing rate');