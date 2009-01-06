function process(obj, hObj)
% PROCESS  This method is called when the Process button is pressed
%
% Get the tree nodes
p     = get(hObj,'Parent');
nodes = getSelectedTreeNodes(obj, p);

% Bail out if only one node is not selected
if length(nodes) ~= 2
  errordlg('Please select a chroma salience node and a beats node.');
  return;
end

for i = 1:length(nodes)
	dataObjS = getDataObjectFromTreeNode(obj, nodes(i));
	if strcmp(dataObjS.DataObj.Name,'Beats')
	  beats = dataObjS.DataObj;
	end
	if strcmp(dataObjS.DataObj.Name,'Chroma Salience ')
	  salience = dataObjS.DataObj;
    AnalyserObj = dataObjS.AnalyserObj;
    salienceNode = i;
	end
end

beatEvents = beats.Events(1:4:length(beats.Events));

% step through beats
for i = 1:length(beatEvents)-1  % calculate data for the particular bar.

  % find time between first beat and second beat 
  salRows = find(salience.Time > beatEvents(i).Time & salience.Time < beatEvents(i+1).Time);

  % find data that corresponds
  salData = salience.Data(salRows,:);

  % send the data to FindChord
  barSalience(i,:) = mean(salData.^2);
  [chordname, R2(i), root(i), intervalNum{i}] = FindChord(barSalience(i,:));
  % Put the resulting chord in appropriate EventData spot
  beatEvents(i).Name = chordname;

end

% Calculate Chord Distance
[r,c] = size(barSalience);
for i = 1:r
  chordDistance(i) = sum(barSalience(1,:).*barSalience(i,:));
end

clear('dataObjS','ts');
ts = createDataObject('tSeries', R2');
% Get Times
for i = 1:length(ts.Time)
  times(i)      = beatEvents(i).Time;
end
ts.Name = 'Chord Estimation R2';
ts.Events    = beatEvents; ts.Time = times;
dataObjS.DataObj = ts; dataObjS.AnalyserObj = AnalyserObj;   % Repackage
% Add to salience node in tree
out = addToDataAnalysisFolder(obj, getValue(nodes(salienceNode)), dataObjS);

clear('dataObjS','ts');
ts = createDataObject('tSeries', root');
ts.Name = 'Root Index';
ts.Events    = beatEvents; ts.Time = times;
dataObjS.DataObj = ts; dataObjS.AnalyserObj = AnalyserObj;   % Repackage
% Add to salience node in tree
out = addToDataAnalysisFolder(obj, getValue(nodes(salienceNode)), dataObjS);

clear('dataObjS','ts');
ts = createDataObject('tSeries', chordDistance');
ts.Name = 'Chord Distance';
ts.Events    = beatEvents; ts.Time = times;
dataObjS.DataObj = ts; dataObjS.AnalyserObj = AnalyserObj;   % Repackage
% Add to salience node in tree
out = addToDataAnalysisFolder(obj, getValue(nodes(salienceNode)), dataObjS);

collapseAndUnLoadTree(obj, p); % Reset Tree

% EOF
