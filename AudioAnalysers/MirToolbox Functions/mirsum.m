function varargout = mirsum(orig,varargin)
%   s = mirsum(f) sums the envelope of the multi-channel object f.
%
%   Optional arguments:
%       mirsum(f,'Centered') centers the resulting envelope.
%       mirsum(f,'Mean') divides the summation by the number of channels.

%       mirsum(f,'Weights')...

        c.key = 'Centered';
        c.type = 'Boolean';
        c.default = 0;
        c.when = 'After';
    option.c = c;

        m.key = 'Mean';
        m.type = 'Boolean';
        m.default = 0;
        m.when = 'After';
    option.m = m;

        adj.key = 'Adjacent';
        adj.type = 'Integer';
        adj.default = 1;
    option.adj = adj;

        weights.key = 'Weights';
        weights.type = 'Integer';
        weights.default = [];
    option.weights = weights;    
    
specif.option = option;

if isamir(orig,'mirtemporal')
    specif.eachchunk = @eachtemporalchunk;
    specif.combinechunk = 'Concat'; %@combinetemporalchunk;
else
    specif.combinechunk = @combinechunk;
end
varargout = mirfunction(@mirsum,orig,varargin,nargout,specif,@init,@main);


function [x type] = init(x,option)
type = mirtype(x);


function s = main(x,option,postoption)
x = purgedata(x);
if iscell(x)
    x = x{1};
end
d = get(x,'Data');
pp = get(x,'PeakPos');
pv = get(x,'PeakVal');
pm = get(x,'PeakMode');
p = get(x,'Pos');
sc = cell(1,length(d));
spp = cell(1,length(d));
spv = cell(1,length(d));
spm = cell(1,length(d));
for h = 1:length(d)
    dh = d{h};
    sch = cell(1,length(dh));
    spph = cell(1,length(dh));
    spvh = cell(1,length(dh));
    spmh = cell(1,length(dh));
    for i = 1:length(dh)
        % Summation of signal
        s3 = size(dh{i},3);
        if not(isempty(option.weights))
            weights = reshape(option.weights,1,1,length(option.weights));
            if length(weights)~=s3
                %warning('WARNING in MIRSUM..');
                weights = weights(1,1,1:s3);
            end
            dh{i} = dh{i}.*repmat(weights,[size(dh{i},1),size(dh{i},2),1]);
        end
        if option.adj < 2
            sch{i} = sum(dh{i},3);
        else
            m0 = option.adj;
            nc1 = size(dh{i},3);
            nc2 = ceil(nc1/m0);
            sch{i} = zeros(size(dh{i},1),size(dh{i},2),nc2);
            for j = 1:nc2
                sch{i}(:,:,j) = sum(dh{i}(:,:,(j-1)*m0+1:min(j*m0,nc1))...
                                        ,3);
            end
        end
        % Summation of peaks
        if not(isempty(pp)) && not(isempty(pp{1}))
            ppi = pp{h}{i};
            pvi = pv{h}{i};
            pmi = pm{h}{i};
            nfr = size(ppi,2);
            nbd = size(ppi,3);
            sppi = cell(1,nfr,1);
            spvi = cell(1,nfr,1);
            spmi = cell(1,nfr,1);
            for j = 1:nfr
                sppj = [];
                spvj = [];
                spmj = [];
                for k = 1:nbd
                    ppk = ppi{1,j,k};
                    pvk = pvi{1,j,k};
                    pmk = pmi{1,j,k};
                    for l = 1:length(ppk)
                        fp = find(ppk(l) == sppj);
                        if fp
                            spvj(fp) = spvj(fp) + pvk(l);
                        else
                            sppj(end+1) = ppk(l);
                            spvj(end+1) = pvk(l);
                            spmj(end+1) = pmk(l);
                        end
                    end
                end
                sppi{1,j,1} = sppj;
                spvi{1,j,1} = spvj;
                spmi{1,j,1} = spmj;
            end
            spph{i} = sppi;
            spvh{i} = spvi;
            spmh{i} = spmi;
        else
            spph{i} = [];
            spvh{i} = [];
            spmh{i} = [];
        end
        if not(isempty(p)) && not(isempty(p{h}))
            p{h}{i} = p{h}{i}(:,:,1);
        end
    end
    sc{h} = sch;
    spp{h} = spph;
    spv{h} = spvh;
    spm{h} = spmh;
end
s = set(x,'Data',sc,'Pos',p,'PeakPos',spp,'PeakVal',spv,'PeakMode',spm);
if not(isempty(postoption))
    s = post(s,postoption);
end


function s = post(s,option)
if option.c
    d = get(s,'Data');
    for k = 1:length(d)
        for i = 1:length(d{k})
            d{k}{i} = center(d{k}{i});
        end
    end
    s = set(s,'Data',d);
end
if option.m
    d = get(s,'Data');
    ch = get(s,'Channels');
    if not(isempty(ch))
        for k = 1:length(d)
            for i = 1:length(d{k})
                d{k}{i} = d{k}{i}/length(ch{k});
            end
            ch{k} = [1];
        end
        s = set(s,'Data',d,'Channels',ch);
    end
end


function [y orig] = eachtemporalchunk(orig,option,missing)
[y orig] = mirsum(orig,option);


%function y = combinetemporalchunk(old,new)
%do = get(old,'Data');
%to = get(old,'Time');
%dn = get(new,'Data');
%tn = get(new,'Time');
%y = set(old,'Data',{{[do{1}{1};dn{1}{1}]}},...
%            'Time',{{[to{1}{1};tn{1}{1}]}});
%        
        
function y = combinechunk(old,new)
if isa(old,'mirspectrum')
    warning('WARNING IN MIRSUM: not yet fully generalized to mirspectrum')
end
do = get(old,'Data');
do = do{1}{1};
dn = get(new,'Data');
dn = dn{1}{1};
if length(dn) < length(do)
    dn(length(do),:,:) = 0; % Zero-padding
end
y = set(old,'ChunkData',do+dn);