function displayStatsObject(obj, hObj)
% DISPLAYSTATSOBJECT Callback for the Display pushbutton

% Initial handle retrieval
p   = get(hObj,'Parent');
utb = get(p,   'Parent');
utg = get(utb, 'Parent');
fig = get(utg, 'Parent');

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, p);

% Bail out if empty
if isempty(nodes)
  return;
end

% Build 
for i = 1:length(nodes)
	s = getDataObjectFromTreeNode(obj,nodes(i));
  col(:,i+1) = struct2cell(get(s.DataObj,'Stats'));
	col(1,i+1) = {s.AnalyserObj.filename};
  names = fieldnames(get(s.DataObj,'Stats'));
end
col = col(1:end-1,:);
names{1} = 'Filename';
names = names(1:end-1,:);
col(:,1) = names;

% Delete Percentiles and Summaries 
col = col(1:end-2,:);

% Re-Add Summaries
for i = 1:length(nodes)
  s = getDataObjectFromTreeNode(obj,nodes(i));
  statsObj(i) = {get(s.DataObj,'Stats')};
end
Names = getSummaryNames(statsObj);


for i = 1:length(Names)
  % Look at the first summary name  
  sOb = statsObj{1};
  col(end+1,1) = Names(i);  
  
  % Add all summaries
  for j = 1:length(statsObj)
    sObj = statsObj{j};
    col(end,j+1) = {getSummaryByName(sObj, Names{i})};
  end
end
hedrow =[];
for j =1:length(col(:,1))
  hedrow = [hedrow sprintf('%s\t',col{j,1})];
end


for i = 1:length(col(2,:))-1
  rowdata = [];
  for j =1:length(col(:,1))
    rowdata = [rowdata sprintf('%s\t',col{j,i+1})];
  end
    rows(i,1) = {rowdata};
end
tablerows(1) = {hedrow};
tablerows(2:length(rows)+1) = rows;
% Set the table data
set(obj.Table,'String',tablerows');



function CommonNames = getSummaryNames(statsObj)
CommonNames = {};
if length(statsObj) == 1
    for j = 1:length(statsObj{1}.Summaries)
      CommonNames(j) = {statsObj{1}.Summaries{j}.Name};
    end
  return
end

Names = {};
for i = 1:length(statsObj)
  for j = 1:length(statsObj{i}.Summaries)
    Names(i,j) = {statsObj{i}.Summaries{j}.Name};
  end
end

% Check names in the first line exist in all rows
% If a name is not common to all rows then it is ignored
[r,c] = size(Names);
Common = [];
for i = 2:r
 for j = 1:c
   Common(i,j) = sum(strcmp(Names(1,j),Names(i,:)),2);
 end
end

if ~isempty(Common)
  % Find columns in Common that do not have all values false
  NameIndexes = find(sum(Common(2:end,:),1) >= r-1);
  % Get CommonNames.
  CommonNames = Names(1,NameIndexes);
else
  CommonNames = [];
end
