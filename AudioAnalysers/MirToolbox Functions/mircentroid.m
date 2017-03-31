function varargout = mircentroid(x,varargin)
%   c = mircentroid(x) calculates the centroid (or center of gravity) of x.
%   x can be either:
%       - a spectrum (spectral centroid),
%       - an envelope (temporal centroid)
%       - a histogram,
%       - or any data. Only the positive ordinates of the data are taken
%           into consideration.
%   c = mircentroid(x,'Peaks') calculates the centroid of the peaks only.

% Beauchamp 1982 version?

        peaks.key = 'Peaks';
        peaks.type = 'String';
        peaks.choice = {0,'NoInterpol','Interpol'};
        peaks.default = 0;
        peaks.keydefault = 'NoInterpol';
    option.peaks = peaks;
    
specif.option = option;

varargout = mirfunction(@mircentroid,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirdata')) || isamir(x,'miraudio')
    x = mirspectrum(x);
end
type = 'mirscalar';


function c = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
if option.peaks
    if strcmpi(option.peaks,'Interpol')
        pt = get(x,'PeakPrecisePos');
        pv = get(x,'PeakPreciseVal');
    else
        pt = get(x,'PeakPos');
        pv = get(x,'PeakVal');
    end
    cx = cell(1,length(pt));
    for h = 1:length(pt)
        cx{h} = cell(1,length(pt{h}));
        for i = 1:length(pt{h})
            pti = pt{h}{i};
            pvi = pv{h}{i};
            %if isempty(pti)

            nfr = size(pti,2);
            nbd = size(pti,3);
            ci = zeros(1,nfr,nbd);
            for j = 1:nfr
                for k = 1:nbd
                    ptk = pti{1,j,k};
                    pvk = pvi{1,j,k};
                    sk = sum(pvk);
                    ci(1,j,k) = sum(ptk.*pvk) ./ sk;
                end
            end
            cx{h}{i} = ci;
        end
    end
else
    cx = peaksegments(@centroid,get(x,'Data'),get(x,'Pos'));
end
if isa(x,'mirspectrum')
    t = 'Spectral centroid';
elseif isa(x,'mirenvelope')
    t = 'Temporal centroid';
else
    t = ['centroid of ',get(x,'Title')];
end
c = mirscalar(x,'Data',cx,'Title',t);


function c = centroid(d,p)
c = (p'*d) ./ sum(d);