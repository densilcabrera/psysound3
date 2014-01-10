function varargout = mirkurtosis(orig,varargin)
%   k = mirkurtosis(x) calculates the kurtosis of x, indicating whether
%       the curve is peaked or flat relative to a normal distribution.
%   x can be either:
%       - a spectrum (spectral kurtosis),
%       - an envelope (temporal kurtosis), or
%       - any histogram.


varargout = mirfunction(@mirkurtosis,orig,varargin,nargout,struct,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirdata')) || isamir(x,'miraudio')
    x = mirspectrum(x);
end
type = 'mirscalar';


function k = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
y = peaksegments(@kurtosis,get(x,'Data'),...
                           get(x,'Pos'),...
                           get(mircentroid(x),'Data'),...
                           get(mirspread(x),'Data'));
if isa(x,'mirspectrum')
    t = 'Spectral kurtosis';
elseif isa(x,'mirenvelope')
    t = 'Temporal kurtosis';
else
    t = ['Kurtosis of ',get(x,'Title')];
end
k = mirscalar(x,'Data',y,'Title',t,'Unit','');


function k = kurtosis(d,p,c,s)
k = sum((p-c).^4.*d) ./ sum(d) ./ s.^4;