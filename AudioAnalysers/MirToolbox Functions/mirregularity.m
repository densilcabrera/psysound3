function varargout = mirregularity(orig,varargin)
%   i = mirregularity(x) calculates the irregularity of a spectrum, i.e.,
%       the degree of variation of the successive peaks of the spectrum.
%   Specification of the definition of irregularity:
%       mirregularity(...,'Jensen') is based on (Jensen, 1999),
%           where the irregularity is the sum of the square of the 
%           difference in amplitude between adjoining partials.
%           (Default approach)
%       mirregularity(...,'Krimphoff') is based on (Krimphoff et al., 1994),
%           where the irregularity is the sum of the amplitude minus the 
%           mean of the preceding, same and next amplitude.
%   If the input x is not already a spectrum with peak extracted, the peak
%       picking is performed prior to the calculation of the irregularity.
%       In this case the 'Contrast' parameter used in mirpeaks can be
%       modified, and is set by default to .1.
%
%   [Krimphoff et al. 1994] J. Krimphoff, S. McAdams, S. Winsberg, 
%       Caracterisation du timbre des sons complexes. II Analyses
%       acoustiques et quantification psychophysique. Journal de Physique 
%       IV, Colloque C5, Vol. 4. 1994. 
%   [Jensen, 1999] K. Jensen, Timbre Models of Musical Sounds, Ph.D.
%       dissertation, University of Copenhagen, Rapport Nr. 99/7.


        meth.type = 'String';
        meth.default = 'Jensen';
        meth.choice = {'Jensen','Krimphoff'};
    option.meth = meth;
    
        cthr.key = 'Contrast';
        cthr.type = 'Integer';
        cthr.default = .01;
    option.cthr = cthr;

specif.option = option;

varargout = mirfunction(@mirregularity,orig,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
if not(isamir(x,'mirdata')) || isamir(x,'miraudio')
    x = mirspectrum(x);
end
if not(haspeaks(x))
    x = mirpeaks(x,'Reso','SemiTone','Contrast',option.cthr);  %% FIND BETTER
end
type = 'mirscalar';


function o = main(x,option,postoption)
if iscell(x)
    x = x{1};
end
m = get(x,'PeakVal');
p = get(x,'PeakPos');
y = cell(1,length(m));
for h = 1:length(m)
    y{h} = cell(1,length(m{h}));
    for k = 1:length(m{h})
        y{h}{k} = zeros(size(m{h}{k}));
        for j = 1:size(m{h}{k},3)
            for l = 1:size(m{h}{k},2)
                state = warning('query','MATLAB:divideByZero');
                warning('off','MATLAB:divideByZero');
                mm = m{h}{k}{1,l,j};
                pp = p{h}{k}{1,l,j};
                [pp oo] = sort(pp); % Sort peaks in ascending order of x abscissae. 
                mm = mm(oo);
                if strcmpi(option.meth,'Jensen')
                    y{h}{k}(1,l,j) = sum((mm(2:end,:)-mm(1:end-1,:)).^2)...
                                    ./sum(mm.^2);
                elseif strcmpi(option.meth,'Krimphoff')
                    avrg = filter(ones(3,1),1,mm)/3;
                    y{h}{k}(1,l,j) = log10(sum(abs(mm(2:end-1,:)-avrg(3:end))));
                end
                warning(state.state,'MATLAB:divideByZero');
                if isnan(y{h}{k}(1,l,j))
                    y{h}{k}(1,l,j) = 0;
                end
            end
        end
    end
end
if isa(x,'mirspectrum')
    t = 'Spectral irregularity';
else
    t = ['Irregularity of ',get(x,'Title')];;
end
i = mirscalar(x,'Data',y,'Title',t);
o = {i,x};