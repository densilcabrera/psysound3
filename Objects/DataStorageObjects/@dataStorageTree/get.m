function val = get(obj, varargin)
% GET  Method for the dataStorageTree object

val = [];
ind = 1;

if nargin ==1
  val = obj;

elseif nargin == 2

  switch lower(varargin{1})
    case 'tree'
      val = obj.tree;
    otherwise
      error(['Unknown property specified : ', prop]);
  end

elseif nargin > 2
  % make comparisons
  numComparisons = (nargin - 1) / 2;
  for i = 1:numComparisons
    prop = varargin{1 + (i - 1) * 2};
    propVal = varargin{2 + (i - 1) * 2};
    trueArr(:,i) = compareTree(obj.tree,prop,propVal);
  end
  subsetTree = find(sum(trueArr,2) == numComparisons);
  obj.tree = obj.tree(subsetTree);
  val = obj;
end

function trueArr = compareTree(tree, prop, propVal)
% Compare through the array

  for i = 1:length(tree)
    if ~strcmp(tree(i),'No Data')
      switch prop
        case 'nodeType'
          trueArr(i) = strcmp(tree(i).nodeType, propVal);
        case 'audiofile'
          trueArr(i) = strcmp(tree(i).audiofile,propVal);
        case 'Name'
          trueArr(i) = strcmp(tree(i).name, propVal);
        case 'analyserName'
          trueArr(i) = strcmp(tree(i).analyserName, strrep(propVal, ' ',''));
      end
    else
      trueArr(i) = 0;
    end
  end
  trueArr = trueArr';

% EOF
