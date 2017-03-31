function varargout = mirspread(orig,varargin)
%   S = mirspread(x) calculates the spread of x, which can be either:
%       - a spectrum (spectral spread),
%       - an envelope (temporal spread), or
%       - any histogram.


varargout = mirfunction(@mirspread,orig,varargin,nargout,struct,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirdata')) || isamir(x,'miraudio')
    x = mirspectrum(x);
end
type = 'mirscalar';


function S = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
y = peaksegments(@spread,get(x,'Data'),...
                         get(x,'Pos'),...
                         get(mircentroid(x),'Data'));
if isa(x,'mirspectrum')
    t = 'Spectral spread';
elseif isa(x,'mirenvelope')
    t = 'Temporal spread';
else
    t = ['Spread of ',get(x,'Title')];
end
S = mirscalar(x,'Data',y,'Title',t);


function s = spread(d,p,c)
s = sqrt( sum((p-c).^2.*d) ) ./ sum(d);