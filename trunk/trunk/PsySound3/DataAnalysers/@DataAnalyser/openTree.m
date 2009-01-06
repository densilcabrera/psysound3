function openTree(obj, panel, path)
% OPENTREE Opens the postprocessing tree to the given path
%

uit = getTree(obj, panel);

% Collapse tree
uit.Tree.collapseRow(0);
setLoaded(uit, uit.getRoot, false);

p = getPsysound3Prefs;

% Prune off the prefdir 
ind   = regexp(path, p.dataDir, 'end');
fPath = path(ind+2:end);  % Advance by 2

% Start with the root node expanded
root = uit.getRoot;
uit.Tree.expandRow(0);
nextNode = root;
row = 0;

% Loop through and expand
[token, rest] = strtok(fPath, filesep);

while ~isempty(rest)
  row = row+1;
  
  nextNode     = nextNode.getNextNode;
  [junk, name] = fileparts(getValue(nextNode));

  if strcmp(token, name)
    uit.Tree.expandRow(row);
    
    [token, rest] = strtok(rest, filesep);
  end
end

% EOF
