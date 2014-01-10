function varargout = mirinharmonicity(orig,varargin)
%   ih = mirinharmonicity(x) estimates the inharmonicity of x, i.e., the
%       amount of partials that are not multiples of the fundamental
%       frequency.
%       x can be either an audio file, a miraudio or a mirspectrum object.
%   WARNING: This function presupposes that there is only one fundamental
%       frequency.
%   Optional argument:
%       mirinharmonicity(...,'f0',f) bases the computation of the
%           inharmonicity on the fundamental frequency indicated by f.
%           Default value: f = mirpitch(...,'Mono')
%   [ih,s] = mirinharmonicity(x) also displays the spectrum used for the
%       computation of the inharmonicity.
%   [ih,s,p] = mirinharmonicity(x) also displays the result of the
%       estimation of the fundamental frequency.

        f0.key = 'f0';
        f0.default = [];
    option.f0 = f0;
    
        frame.key = 'Frame';
        frame.type = 'Integer';
        frame.number = 2;
        frame.default = [0 0];
        frame.keydefault = [.1 .125];
    option.frame = frame;
        
specif.option = option;
     
varargout = mirfunction(@mirinharmonicity,orig,varargin,nargout,specif,@init,@main);


function [i type] = init(x,option)
if isamir(x,'miraudio')
    if option.frame.length.val
        s = mirspectrum(x,'Frame',option.frame.length.val,...
                                  option.frame.length.unit,...
                                  option.frame.hop.val,...
                                  option.frame.hop.unit);
    else
        s = mirspectrum(x);
    end
else
    s = x;
end
if isempty(option.f0)
    if option.frame.length.val
        p = mirpitch(x,'Mono','Frame',option.frame.length.val,...
                                      option.frame.length.unit,...
                                      option.frame.hop.val,...
                                      option.frame.hop.unit);
    else
        p = mirpitch(x,'Mono');
    end
else
    p = option.f0;
end
i = {s,p};
type = {'mirscalar','mirspectrum','mirscalar'};


function ih = main(x,option,postoption)
if isa(x{2},'mirdesign')
    x = x{1};
end
s = x{1};
p = x{2};
if iscell(p)
    p = p{1};
end
m = get(s,'Magnitude');
f = get(s,'Frequency');
fp1 = get(s,'FramePos');
if isnumeric(p)
    pf = {{{p}}};
else
    pf = get(p,'Data');
    fp2 = get(p,'FramePos');
end
v = cell(1,length(m));
for h = 1:length(m)
    v{h} = cell(1,length(m{h}));
    for i = 1:length(m{h})
        mi = m{h}{i};
        fi = f{h}{i};
        pfi = pf{h}{i};
        v{h}{i} = zeros(1,size(mi,2),size(mi,3));
        if not(size(mi,2) == size(pfi,2))
            beg = find(fp2{h}{i}(1,:) == fp1{h}{i}(1,1));
            if isempty(beg) || (beg + size(mi,2)-1 > size(pfi,2))
                error('ERROR IN MIRINHARMONICITY: The ''f0'' argument should have the same frame decomposition than the main input.');
            end
            pfi = pfi(:,beg:beg+size(mi,2)-1);
        end
        for j = 1:size(mi,3)
            for k = 1:size(mi,2)
                mk = mi(:,k,j);
                fk = fi(:,k,j);
                pfk = pfi(:,k);
                if isempty(pfk{1})
                    v{h}{i}(1,k,j) = NaN;
                else
                    r = fk/pfk{1}(1);
                    rr = 2*abs(r-round(r));
                    if isempty(rr)
                        v{h}{i}(1,k,j) = NaN;
                    else
                        v{h}{i}(1,k,j) = sum(rr.*mk) / sum(mk);
                    end
                end
            end
        end
    end
end
ih = mirscalar(s,'Data',v,'Title','Inharmonicity');
if isa(p,'mirdata')
    ih = {ih s p};
else
    ih = {ih s};
end