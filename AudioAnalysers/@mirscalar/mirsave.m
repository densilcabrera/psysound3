function mirsave(a)

d = get(a,'Data');
n = get(a,'Name');
t = get(a,'Title');
c = get(a,'Channels');
fp = get(a,'FramePos');
out = cell(1,length(d));

for k = 1:length(d)
    dk = d{k};
    if not(iscell(dk))
        dk = {dk};
    end
    out = [];
    for l = 1:size(dk{1},3)
        for i = 1:length(dk)
            di = dk{i};
            synth = zeros(1,ceil((fp{k}{i}(end)-fp{k}{i}(1))*44100)+1);
            for j = 1:size(di,2)
                if iscell(di)
                    dj = di{j};
                else
                    dj = di(j);
                end
                if not(isempty(dj))
                    k1 = floor((fp{k}{i}(1,j)-fp{k}{i}(1))*44100)+1;
                    k2 = floor((fp{k}{i}(2,j)-fp{k}{i}(1))*44100)+1;
                    synth(k1:k2) = synth(k1:k2) ...
                        + sum(sin(2*pi*dj*(0:k2-k1)/44100),1).*hann(k2-k1+1)';
                end
            end
            out = [out synth];
            if size(dk{1},3)>1
                out = [out rand(1,10)];
            end
        end
    end
    fout = miraudio(out,44100);
    mirsave(fout,[n{k},'.',t]);
end


function oldmirsave % not used anymore
d = get(a,'Data');
nf = length(d);
fp = get(a,'FramePos');
nm = get(a,'Name');
t = get(a,'Title');
for i = 1:nf
    nmi = nm{i};
    di = d{i}{1};
    fpi = fp{i}{1};
    
    %Let's remove the extension from the original files
    if length(nmi)>3 && strcmpi(nmi(end-3:end),'.wav')
        nmi(end-3:end) = [];
    elseif length(nmi)>2 && strcmpi(nmi(end-2:end),'.au')
        nmi(end-2:end) = [];
    end    
    n = [nmi,'.',lower(t),'.txt'];
    
    fid = fopen(n, 'wt');
    fprintf(fid,'Frame_start Frame_end Data \n');

    for j = 1:length(di)
        fprintf(fid,'%g %g %g \n',fpi(1,j),fpi(2,j),di(j));
    end
    fclose(fid);
    disp([n,' saved.']);
end