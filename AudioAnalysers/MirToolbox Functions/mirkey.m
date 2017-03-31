function varargout = mirkey(orig,varargin)
%   k = mirkey(x) estimates the key.
%   Optional argument:
%       mirkey(...,'Total',m) selects not only the most probable key, but
%           the m most probable keys.
%       The other parameter 'Contrast' related to mirpeaks can be specified 
%           here (see help mirchromagram).
%       The optional parameters 'Weight' and 'Triangle' related to
%           mirchromagram can be specified here (see help mirchromagram).
%   [k,ks] = mirkey(...) also returns the key clarity, corresponding here 
%       to the key strength associated to the best candidate.
%   [k,ks,ksc] = mirkey(...) also displays the key strength curve used for
%       the key estimation and shows in particular the peaks corresponding 
%       to the selected key(s).

        tot.key = 'Total';
        tot.type = 'Integer';
        tot.default = 1;
    option.tot = tot;
    
        thr.key = 'Contrast';
        thr.type = 'Integer';
        thr.default = .1;
    option.thr = thr;
    
        wth.key = 'Weight';
        wth.type = 'Integer';
        wth.default = .5;
    option.wth = wth;
    
        tri.key = 'Triangle';
        tri.type = 'Boolean';
        tri.default = 0;
    option.tri = tri;

specif.option = option;
specif.defaultframelength = 1;
specif.defaultframehop = .5;

varargout = mirfunction(@mirkey,orig,varargin,nargout,specif,@init,@main);


function [p type] = init(x,option)
if not(isamir(x,'mirkeystrength'))
    x = mirkeystrength(x,'Weight',option.wth,'Triangle',option.tri);
end
p = mirpeaks(x,'Total',option.tot,'Contrast',option.thr);
type = {'mirscalar','mirscalar','mirkeystrength'};


function k = main(p,option,postoption)
if iscell(p)
    p = p{1};
end
pc = get(p,'PeakPos');
pv = get(p,'PeakMaxVal');
pm = get(p,'PeakMode');
k = mirscalar(p,'Data',pc,'Mode',pm,'Title','Key',...
    'Legend',{'C','C#','D','D#','E','F','F#','G','G#','A','A#','B'});
m = mirscalar(p,'Data',pv,'Title','Key clarity','MultiData',{});
k = {k m p};