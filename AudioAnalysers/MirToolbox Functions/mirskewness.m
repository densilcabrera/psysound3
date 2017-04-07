function varargout = mirskewness(orig,varargin)
%   s = skewness(x) calculates the skewness of x, showing the (lack of)
%       symmetry of the curve.
%   x can be either:
%       - a spectrum (spectral skewness),
%       - an envelope (temporal skewness), or
%       - any histogram.


varargout = mirfunction(@mirskewness,orig,varargin,nargout,struct,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'psydata')) || isamir(x,'psyaudio')
    x = psyspectrum(x);
end
type = 'psyscalar';


function s = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
y = peaksegments(@skewness,get(x,'Data'),...
                           get(x,'Pos'),...
                           get(mircentroid(x),'Data'),...
                           get(mirspread(x),'Data'));
if isa(x,'psyspectrum')
    t = 'Spectral skewness';
elseif isa(x,'mirenvelope')
    t = 'Temporal skewness';
else
    t = ['Skewness of ',get(x,'Title')];
end
s = psyscalar(x,'Data',y,'Title',t,'Unit','');


function s = skewness(d,p,c,sp)
s = sum((p-c).^3.*d) ./ sum(d) ./ sp.^3;