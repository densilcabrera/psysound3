function mirsave(a,f,multichan)

ext = 0;    % Specified new extension
if nargin < 2
    f = '.mir';
elseif length(f)>3 && strcmpi(f(end-3:end),'.wav')
    ext = '.wav';
    if length(f)==4
        f = '.mir';
    end
elseif length(f)>2 && strcmpi(f(end-2:end),'.au')
    ext = '.au';
    if length(f)==3
        f = '.mir';
    end
end

if nargin < 3
    multichan = '';
end

d = get(a,'Data');
nf = length(d);
fs = get(a,'Sampling');
nb = get(a,'NBits');
nm = get(a,'Name');
ch = get(a,'Channels');
maxd = 0;
for i = 1:nf
    for j = 1:length(d{i})
        maxd = max(max(max(max(abs(d{i}{j}),[],1),[],2),[],3),maxd);
    end
end
for i = 1:nf
    nbi = nb{i};
    di = d{i};
    fsi = fs{i};
    nmi = nm{i};
    chi = ch{i};
    out = [];
    for j = 1:length(di)
        di{j} = di{j}./repmat(maxd,size(di{j}))*.9999;
        out = [out;reshape(di{j},[],size(di{j},3),1)];
        if length(di)>1
            out = [out;rand(100,size(di{j},3))*.9];
        end
    end
    
    %Let's remove the extension from the original files
    if length(nmi)>3 && strcmpi(nmi(end-3:end),'.wav')
        nmi(end-3:end) = [];
    elseif length(nmi)>2 && strcmpi(nmi(end-2:end),'.au')
        nmi(end-2:end) = [];
    end
    
    nchan = size(out,2);
    if isempty(multichan) || nchan < 2
        if nf>1 || strcmp(f(1),'.')
            %Let's add the new suffix
            n = [nmi f];
        else
            n = f;
        end
        if not(ischar(ext)) || strcmp(ext,'.wav')
            if length(n)<4 || not(strcmpi(n(end-3:end),'.wav'))
                n = [n '.wav'];
            end
            wavwrite(out,fsi,nbi,n)
        elseif strcmp(ext,'.au')
            if length(n)<3 || not(strcmpi(n(end-2:end),'.au'))
                n = [n '.au'];
            end
            auwrite(out,fsi,nbi,'linear',n)
        end
        disp([n,' saved.']);
    else
        for j = 1:nchan
            nb = num2str(chi(j));
            if nf>1 || strcmp(f(1),'.')
                %Let's add the new suffix
                n = [nmi nb f];
            else
                n = [f nb];
            end
            if not(ischar(ext)) || strcmp(ext,'.wav')
                if length(n)<4 || not(strcmpi(n(end-3:end),'.wav'))
                    n = [n '.wav'];
                end
                wavwrite(out(:,j),fsi,nbi,n)
            elseif strcmp(ext,'.au')
                if length(n)<3 || not(strcmpi(n(end-2:end),'.au'))
                    n = [n '.au'];
                end
                auwrite(out(:,j),fsi,nbi,'linear',n)
            end
            disp([n,' saved.']);
        end
    end
end