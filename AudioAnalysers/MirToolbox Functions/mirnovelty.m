function varargout = mirnovelty(orig,varargin)
%   n = mirnovelty(m) evaluates the novelty score from a similarity matrix.
%   [n,m] = mirnovelty(m) also return the similarity matrix.
%   Optional argument: 
%       mirnovelty(...,'Distance',f) specifies the name of a dissimilarity
%           distance function, from those proposed in the Statistics Toolbox
%               (help pdist).
%           default value: f = 'cosine'
%       mirnovelty(...,'Similarity',f) specifies the name of a similarity
%           measure function. This function is applied to the result of the
%           distance function. cf. mirsimatrix 
%           default value: f = 'exponential'
%               corresponding to f(x) = exp(-x)
%       mirnovelty(...,'KernelSize',s) or more simply mirnovelty(...,s) 
%           specifies the length of the gaussian kernel, in samples.
%           default value: s = 64.
%       mirnovelty(...,'Normal',0) does not normalize the novelty curve
%           between the values 0 and 1.
%       mirnovelty(...,'Horizontal') uses the 'Horizontal' option in
%           mirsimatrix instead of 'TimeLag' used here by default.
%
%   Foote, J. & Cooper, M. (2003). Media Segmentation using Self-Similarity
% Decomposition,. In Proc. SPIE Storage and Retrieval for Multimedia
% Databases, Vol. 5021, pp. 167-75.

        dist.key = 'Distance';
        dist.type = 'String';
        dist.default = 'cosine';
    option.dist = dist;

        sm.key = {'Measure','Similarity'};
        sm.type = 'String';
        sm.default = 'exponential';
    option.sm = sm;

        K.key = {'KernelSize','Width'};
        K.type = 'Integer';
        K.default = 64;
    option.K = K;
    
        transf.type = 'String';
        transf.default = 'TimeLag';
        transf.choice = {'Horizontal','TimeLag'};
    option.transf = transf;

        normal.key = 'Normal';
        normal.type = 'Boolean';
        normal.default = 1;
        normal.when = 'After';
    option.normal = normal;
    
specif.option = option;
specif.nochunk = 1;
varargout = mirfunction(@mirnovelty,orig,varargin,nargout,specif,@init,@main);
    

function [x type] = init(x,option)
type = 'mirscalar';
if not(isamir(x,'mirscalar') && strcmp(get(x,'Title'),'Novelty'))
    x = mirsimatrix(x,'Distance',option.dist,'Similarity',option.sm,...
                      'Width',option.K,option.transf);
end
if isa(x,'mirdesign')
    x = set(x,'Overlap',ceil(option.K));
end


function y = main(orig,option,postoption)
if iscell(orig)
    orig = orig{1};
end
if not(isa(orig,'mirscalar'))
    s = get(orig,'Data');
    dw = get(orig,'DiagWidth');
    for k = 1:length(s)
        if isnumeric(dw)
            dwk = dw;
        else
            dwk = dw{k};
        end
        if option.K
            cgs = min(option.K,dwk);
        else
            cgs = dwk;
        end
        cg = checkergauss(cgs,option.transf);
        disp('Computing convolution, please wait...')
        for z = 1:length(s{k})
            sz = s{k}{z};
            szma = max(max(sz));
            szmi = min(min(sz));
            sz = (sz-szmi)/(szma-szmi);
            sz = 2*sz-1;
            sz(isnan(sz)) = 0;
            cv = convolve2(sz,cg,'same');
            nl = size(cv,1);
            nc = size(cv,2);
            if nl == 0
                warning('WARNING IN NOVELTY: No frame decomposition. The novelty score cannot be computed.');
                score{k}{z} = [];
            else
                sco = cv(floor(size(cv,1)/2),:);
                incr = find(diff(sco)>=0);
                if not(isempty(incr))
                    decr = find(diff(sco)<=0);
                    sco(1:incr(1)-1) = NaN(1,incr(1)-1);
                    if not(isempty(decr))
                        sco(decr(end)+1:end) = NaN(1,length(sco)-decr(end));
                    end
                    incr = find(diff(sco)>=0);
                    sco2 = sco;
                    if not(isempty(incr))
                        sco2 = sco2(1:incr(end)+1);
                    end
                    decr = find(diff(sco)<=0);
                    if not(isempty(decr)) && decr(1)>2
                        sco2 = sco2(decr(1)-1:end);
                    end
                    mins = min(sco2);
                    rang = find(sco>= mins);
                    if not(isempty(rang))
                        sco(1:rang(1)-1) = NaN(1,rang(1)-1);
                        sco(rang(end)+1:end) = NaN(1,length(sco)-rang(end));
                    end
                end
                score{k}{z} = sco;
            end
        end
    end
else
    score = get(orig,'Data');
end
if not(isempty(postoption)) && postoption.normal
    for k = 1:length(score)
        for l = 1:length(score{k})
            sco = score{k}{l};
            sco = (sco-min(sco))/(max(sco)-min(sco));
            score{k}{l} = sco;
        end
    end
end
n = mirscalar(orig,'Data',score,'Title','Novelty'); 
y = {n orig};


function y = checkergauss(N,transf)
hN = ceil(N/2);
if strcmpi(transf,'TimeLag')
    y = zeros(2*N,N);
    for j = 1:N
        for i = 1:2*N+1
            g = exp(-((((i-N)-(j-hN))/hN)^2 + (((j-hN)/hN)^2))*4);
            if xor(j>hN,j-hN>i-N)
                y(i,j) = -g;
            elseif j>hN+i || j-hN<i-2*N
                y(i,j) = 0;
            else
                y(i,j) = g;
            end
        end
    end
else
    y = zeros(N);
    for i = 1:N
        for j = 1:N
            g = exp(-(((i-hN)/hN)^2 + (((j-hN)/hN)^2))*4);
            if xor(j-hN>floor((i-hN)/2),j-hN>floor((hN-i)/2))
                y(i,j) = -g;
            else
                y(i,j) = g;
            end
        end
    end
end