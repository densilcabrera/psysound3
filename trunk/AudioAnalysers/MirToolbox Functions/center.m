function c = center(x)
if isempty(x)
    c = [];
else
    c = x - repmat(mean(x),[size(x,1),1,1]);
end