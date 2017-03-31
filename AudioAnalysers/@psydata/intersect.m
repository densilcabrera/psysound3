function i = intersect(a,b,thr)

if nargin<3
    thr = .01;
end

va = get(a,'PeakVal');
pa = get(a,'PeakPos');
ma = get(a,'PeakMode');
if isa(a,'mirscalar')
    xa = get(a,'FramePos');
else
    xa = get(a,'Pos');
end
vb = get(b,'PeakVal');
pb = get(b,'PeakPos');
mb = get(b,'PeakMode');
if isa(b,'mirscalar')
    xb = get(b,'FramePos');
else
    xb = get(b,'Pos');
end

for j = 1:length(va)
    for k = 1:length(va{j})
        [nl nc np] = size(va{j}{k});
        for c = 1:nc
            for p = 1:np
                [pacp,ix] = sort(pa{j}{k}{1,c,p});
                vacp = va{j}{k}{1,c,p}(ix);
                macp = ma{j}{k}{1,c,p}(ix);
                [pbcp,ix] = sort(pb{j}{k}{1,c,p});
                xajk = xa{j}{k};
                xbjk = xb{j}{k};
                if isa(a,'mirscalar')
                    xajk = mean(xajk);
                end
                if isa(b,'mirscalar')
                    xbjk = mean(xbjk);
                end
                ia = 1;
                ib = 1;
                ii = 1;
                while ia <= length(pacp) && ib <= length(pbcp)
                    if abs(xajk(pacp(ia))-xbjk(pbcp(ib)))<thr
                        picp(ii) = pacp(ia);
                        vicp(ii) = vacp(ia);
                        micp(ii) = macp(ia);
                        ia = ia+1;
                        ib = ib+1;
                        ii = ii+1;
                    elseif xajk(pacp(ia))<xbjk(pbcp(ib))
                        ia = ia+1;
                    else
                        ib = ib+1;
                    end
                end
            pa{j}{k}{1,c,p} = picp;
            va{j}{k}{1,c,p} = vicp;
            ma{j}{k}{1,c,p} = micp;
            end
        end
    end
end

i = set(a,'PeakPos',pa,'PeakVal',va,'PeakMode',ma);