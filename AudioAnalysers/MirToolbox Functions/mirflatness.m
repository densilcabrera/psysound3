function varargout = mirflatness(orig,varargin)
%   f = mirflatness(x) calculates the flatness of x, which can be either:
%       - a spectrum (spectral flatness),
%       - an envelope (temporal flatness), or
%       - any histogram.


varargout = mirfunction(@mirflatness,orig,varargin,nargout,struct,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirenvelope') || isamir(x,'mirhisto'))
    x = mirspectrum(x);
end
type = 'mirscalar';


function f = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
m = get(x,'Data');
y = cell(1,length(m));
for h = 1:length(m)
    if not(iscell(m{h})) % for histograms
        m{h} = {m{h}'};
    end
    y{h} = cell(1,length(m{h}));
    for i = 1:length(m{h})
        mm = m{h}{i};
        nl = size(mm,1);
        ari = mean(mm);
        geo = (prod(mm.^(1/nl)));
        divideByZero = warning('query','MATLAB:divideByZero');
        logZero = warning('query','MATLAB:log:logOfZero');
        warning('off','MATLAB:divideByZero');
        warning('off','MATLAB:log:logOfZero');
        y{h}{i} = ...10*log10(
            geo./ari;%);
        warning(divideByZero.state,'MATLAB:divideByZero');
        warning(logZero.state,'MATLAB:log:logOfZero');
        nany = find(isinf(y{h}{i}));
        y{h}{i}(nany) = zeros(size(nany));
    end
end
if isa(x,'mirenvelope')
    t = 'Temporal flatness';
elseif isa(x,'mirspectrum')
    t = 'Spectral flatness';
else
    t = ['Flatness of ',get(x,'Title')];
end
f = mirscalar(x,'Data',y,'Title',t,'Unit','');