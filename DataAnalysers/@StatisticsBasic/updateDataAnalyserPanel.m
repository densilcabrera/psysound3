function updateDataAnalyserPanel(obj, panel)
% UPDATEDATAANALYSERPANEL This method is called everytime a tree
%                         node is clicked.
%
%
% Update Enable/Disable state of plot buttons depending on 
% the type of objects in listbox4

displayButton 			= findobj(panel,'Tag','BasicStatisticsDisplay');
sNodes 							= getSelectedTreeNodes(obj, panel); 
len    							= length(sNodes);
wrongObjectSelected = 0;
set(displayButton,'Enable','on');
try
s1 = getDataObjectFromTreeNode(obj,sNodes(1));
if isempty(s1)
  wrongObjectSelected = 1;
end
if strcmp(class(s1.DataObj),'AudioTSeries')
	set(displayButton,'Enable','off');
  return;
end

end

     
for i = 1:len
	s = getDataObjectFromTreeNode(obj,sNodes(i));
  if isempty(s)
    wrongObjectSelected = 1;
    break;
  elseif ~strcmp(s1.DataObj.Name,s.DataObj.Name)
    wrongObjectSelected = 1;
    break;
  end
    
	if ~strcmp(class(s.DataObj),'tSeries')
		wrongObjectSelected = 1;
	end
end

if wrongObjectSelected
	set(displayButton,'Enable','off');
end

function s = makeColumn(panel, status)
% Get children of panel and set to status.

children = get(panel,'Children');
for i = 1:length(children)
  set(children(i),'Enable',status);
end

 
% EOF
