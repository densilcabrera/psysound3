function dataObjS = findAllInDataSet(varargin)
% FINDALLINDATASET  Finds all dataStorage objects that match the P/V pairs
%                   starting at the root node

p = getPsysound3Prefs;

% Load root object
load(fullfile(p.dataDir, filesep, 'dataInfo.mat'));

if mod(nargin, 2)
  error('Even number of property/value pairs must be given');
end

% Support for only a single prop/val pair
prop = varargin{1};
val  = varargin{2};

% Let it rip
dataObjS = getAllInDataSet(dsArr, {}, prop, val, p.dataDir);

% end findAllInDataSet

%
% local recursive function
% 
function objs = getAllInDataSet(dsArr, objs, prop, val, dirPath)

ch = dsArr.children;
for i=1:length(ch)
  node = ch(i);
  
  if node.isLeaf
    % This is a data object
    if strcmp(node.(prop), val)
      load(fullfile(dirPath, node.filename));
      objs{end+1} = dataObjS;
    end
  else
    % Load its node object and recurse
    try
      load(fullfile(dirPath, node.filename, filesep, 'dataInfo.mat'));
    catch
      continue
    end
    objs = getAllInDataSet(dsArr, objs, prop, val, fullfile(dirPath, node.filename));
  end
  
end

% end getAllInDataSet

% EOF
