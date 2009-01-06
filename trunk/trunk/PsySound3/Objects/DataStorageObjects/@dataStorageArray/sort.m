function dsArr = sort(dsArr)
% SORTS on name

% Build up a cell array of names
N = getNumChildren(dsArr);
Z = cell(1, N);
for i=1:N
  Z{i} = dsArr.children(i).name;
end

% Call cell sort
[Y, I] = sort(Z);

% Reorder the children
dsArr.children = dsArr.children(I);

% EOF
