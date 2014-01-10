function varargout = mirbeatspectrum(orig,varargin)
%   n = mirbeatspectrum(m) evaluates the beat spectrum.
%   [n,m] = mirbeatspectrum(m) also return the similarity matrix on which
%       the estimation is made.
%   Optional argument: 
%       mirbeatspectrum(...,s) specifies the estimation method.
%           Possible values:
%           s = 'Diag', summing simply along the diagonals of the matrix.
%           s = 'Autocor', based on the autocorrelation of the matrix.
%       mirbeatspectrum(...,'Distance',f) specifies the name of a dissimilarity
%           distance function, from those proposed in the Statistics Toolbox
%               (help pdist).
%           default value: f = 'cosine'
%   J. Foote, M. Cooper, U. Nam, "Audio Retrieval by Rhythmic Similarity",
%   ISMIR 2002.


        dist.key = 'Distance';
        dist.type = 'String';
        dist.default = 'cosine';
    option.dist = dist;

        meth.type = 'String';
        meth.choice = {'Diag','Autocor'};
        meth.default = 'Autocor';
    option.meth = meth;

specif.option = option;
varargout = mirfunction(@mirbeatspectrum,orig,varargin,nargout,specif,@init,@main);
    

function [x type] = init(x,option)
if not(isamir(x,'mirscalar'))
    if isamir(x,'miraudio')
        x = mirspectrum(x,'frame',.025,'s',.01,'s'); % should be mirmfcc (not available in Matlab Central Version)
    end
    x = mirsimatrix(x,'Distance',option.dist,'Similarity');
end
type = 'mirscalar';


function y = main(orig,option,postoption)
if iscell(orig)
    orig = orig{1};
end
fp = get(orig,'FramePos');
if not(isa(orig,'mirscalar'))
    s = get(orig,'Data');
    total = cell(1,length(s));
    for k = 1:length(s)
        for h = 1:length(s{k})
            maxfp = find(fp{k}{h}(2,:)>4,1);
            if isempty(maxfp)
                maxfp = Inf;
            else
                fp{k}{h}(:,maxfp+1:end) = [];
            end
            l = min(length(s{k}{h}),maxfp);
            total{k}{h} = zeros(1,l);
            if strcmpi(option.meth,'Diag')
                for i = 1:l
                    total{k}{h}(i) = mean(diag(s{k}{h},i-1));
                end
            else
                for i = 1:l
                    total{k}{h}(i) = mean(mean(s{k}{h}(:,1:l-i+1).*s{k}{h}(:,i:l)));
                end
            end
        end
    end
else
    total = get(orig,'Data');
end
n = mirscalar(orig,'Data',total,'FramePos',fp,'Title','Beat Spectrum'); 
y = {n orig};