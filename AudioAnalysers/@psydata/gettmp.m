function [tmp y] = gettmp(x,y)

idx = get(x,'TmpIdx')+1;
tmps = get(x,'InterChunk');
if idx > length(tmps)
    tmp = [];
else
    tmp = tmps{idx};
end
if nargin<2
    y = x;
end
y = set(y,'InterChunk',tmps,'TmpIdx',idx);