function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes

% Get the tree nodes
panel = get(hObj,'Parent');
nodes = getSelectedTreeNodes(obj, panel);

% Bail out if two nodes are not selected
if length(nodes) ~= 2
  errordlg('Please select two nodes. The first to be thresholded, and the second to threshold with.');
  return;
end

dataObjS1 = getDataObjectFromTreeNode(obj, nodes(1));
dataObjS2 = getDataObjectFromTreeNode(obj, nodes(2));
if isempty(dataObjS1) || isempty(dataObjS2)
  errordlg('Please select a valid node');
  return;
end

TSObj1 = dataObjS1.DataObj; % Get the data objects.
TSObj2 = dataObjS2.DataObj;
if ~isa(TSObj1, 'tSeries') ||  ~isa(TSObj2, 'tSeries')
  errordlg('Please select timeseries nodes.');
  return;
end


[thresholds] = thresholdDlg(TSObj2); % Ask user for threshold range 
% Find the indexs
indexs = find(TSObj2.Data  < thresholds(1) | TSObj2.Data  > thresholds(2));


TSObj1.data(indexs) = NaN; % Dump data

% Change the name of the data.
NewName = sprintf('%s, Thresholded by %s', TSObj1.Name, TSObj2.Name);
TSObj1.Name = NewName;

% Repackage
dataObjS1.DataObj = TSObj1;

% Add to node in tree
out = addToDataAnalysisFolder(obj, getValue(nodes(1)), dataObjS1);

collapseAndUnLoadTree(obj, panel);
% Try this instead of the above collapse
% openTree(obj, panel, out);


% Just a function for the dialog box.
function thresholds = thresholdDlg(s1)

prompt         = {'Minimum','Maximum'};
name           = 'Threshold the Data';
numlines       = 1;
defaultanswer  = {num2str(min(s1.Data)),num2str(max(s1.Data))};
answer         = inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
  thresholds     = [min(s1.Data) max(s1.Data)];
	return;
end
thresholds     = [str2num(answer{1}) str2num(answer{2})];

% EOF
