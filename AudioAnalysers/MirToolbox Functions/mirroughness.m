function varargout = mirroughness(x,varargin)
%   r = mirroughness(x) calculates the roughness, or sensory dissonance,
%           due to beating phenomenon between close frequency peaks. 
%       The frequency components are supposed to remain sufficiently 
%           constant throughout each frame of each audio file.
%   r = mirroughness(...,'Contrast',c) specifies the contrast parameter
%       used for peak picking (cf. mirpeaks).
%       Default value: c = .01
%   [r,s] = mirroughness(x) also displays the spectrum and its peaks, used
%           for the computation of roughness.
%   Optional arguments:
%       Method used:
%           mirroughness(...,'Sethares') (default): based on the summation
%               of roughness between all pairs of sines (obtained through
%               spectral peak-picking).
%           mirroughness(...,'Vassilakis'): variant of 'Sethares' model
%               with a more complex weighting (Vassilakis, 2001, Eq. 6.23).

        meth.type = 'String';
        meth.choice = {'Sethares','Vassilakis'};
        meth.default = 'Sethares';
    option.meth = meth;
    
        cthr.key = 'Contrast';
        cthr.type = 'Integer';
        cthr.default = .01;
    option.cthr = cthr;
    
        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.default = [.05 .5];
    option.frame = frame;
    
specif.option = option;
specif.defaultframelength = .05;
specif.defaultframehop = .5;


varargout = mirfunction(@mirroughness,x,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if isamir(x,'miraudio') && not(isframed(x))
    x = mirframenow(x,option);
end
x = mirspectrum(x);
if not(haspeaks(x))
    x = mirpeaks(x,'Contrast',option.cthr);
end
type = 'mirscalar';


function r = main(p,option,postoption)
if iscell(p)
    p = p{1};
end
if strcmpi(option.meth,'Sethares') || strcmpi(option.meth,'Vassilakis')
    pf = get(p,'PeakPosUnit');
    pv = get(p,'PeakVal');
    rg = cell(1,length(pf));
    for h = 1:length(pf)
        rg{h} = cell(1,length(pf{h}));
        for i = 1:length(pf{h})
            pfi = pf{h}{i};
            pvi = pv{h}{i};
            rg{h}{i} = zeros(1,length(pfi));
            for k = 1:size(pfi,3)
                for j = 1:size(pfi,2)
                    pfj = pfi{1,j,k};
                    pvj = pvi{1,j,k};
                    f1 = repmat(pfj,[1 length(pfj)]);
                    f2 = repmat(pfj',[length(pfj) 1]);
                    v1 = repmat(pvj,[1 length(pvj)]);
                    v2 = repmat(pvj',[length(pvj) 1]);
                    rj = plomp(f1,f2);
                    if strcmpi(option.meth,'Sethares')
                        rj = v1.*v2.*rj;
                    elseif strcmpi(option.meth,'Vassilakis')
                        rj = (v1.*v2).^.1.*.5.*(2*v2./(v1+v2)).^3.11.*rj;
                    end
                    rg{h}{i}(1,j,k) = sum(sum(rj));
                end
            end
        end
    end
else
end    
r = mirscalar(p,'Data',rg,'Title','Roughness');
r = {r,p};


function pd = plomp(f1, f2)
% returns the dissonance of two pure tones at frequencies f1 & f2 Hz
% according to the Plomp-Levelt curve (see Sethares)
    b1 = 3.51;
    b2 = 5.75;
    xstar = .24;
    s1 = .0207;
    s2 = 18.96;
    s = tril(xstar ./ (s1 * min(f1,f2) + s2 ));
    pd = exp(-b1*s.*abs(f2-f1)) - exp(-b2*s.*abs(f2-f1));
return