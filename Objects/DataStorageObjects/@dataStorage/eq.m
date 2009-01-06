function bool = eq(obj1, obj2)
% EQ  == function

if ~strcmp(obj1.name, obj2.name)
  bool = false;
elseif ~strcmp(obj1.filename, obj2.filename) % don't really need to
                                             % check this prop
  bool = false;
elseif ~strcmp(obj1.nodeType, obj2.nodeType)
  bool = false;
elseif ~(obj1.isLeaf == obj2.isLeaf)
  bool = false;
else
  % All match!
  bool = true;
end

% EOF
