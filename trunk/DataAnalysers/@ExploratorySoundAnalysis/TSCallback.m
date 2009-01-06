function TSCallback(obj, hObj)
% TSCALLBACK Callback for the TimeSeries pushbutton

% % Initial handle retrieval
p   = get(hObj,'Parent'); % The uipanel for univariate
uip = get(p,'Parent');    % The uipanel for the DataAnalyser

% Find axes
ax{1} = findobj(uip, 'Type','Axes','Tag','ESAAxesTop');
ax{2} = findobj(uip, 'Type','Axes','Tag','ESAAxesBottom');

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, uip);

% Get the Choice of Representation
reprChoiceH = findobj(p,'Tag','TimeseriesPopup');
reprChoice  = get(reprChoiceH,'String');
reprChoice  = reprChoice(get(reprChoiceH,'Value'),:);
reprChoice  = strrep(reprChoice,' ',''); % Strip out spaces


% Get the Choice of Representation
concatChoiceH = findobj(p,'Tag','tsConcatPopup');
concatChoice  = get(concatChoiceH,'String');
concatChoice  = concatChoice(get(concatChoiceH,'Value'),:);
concatChoice  = strrep(concatChoice,' ',''); % Strip out spaces

% Bail out if empty
if isempty(nodes)
  return;
end

% Clear up some things
axes(ax{1});
cla; legend off; colorbar off;
set(ax{1}, 'UserData', []);
set(ax{1}, 'XLimMode', 'auto');
set(ax{1}, 'YLimMode', 'auto');
set(ax{1}, 'ZLimMode', 'auto');

axes(ax{2});
cla; legend off; colorbar off;
set(ax{2}, 'UserData', []);
set(ax{2}, 'XLimMode', 'auto');
set(ax{2}, 'YLimMode', 'auto');
set(ax{2}, 'ZLimMode', 'auto');

% Switch on plot type

for i = 1:length(nodes)
  dataObjS(i) = getDataObjectFromTreeNode(obj, nodes(i));
  wavData =  getWaveDataFromTreeNode(obj,nodes(i)); % Little hack due to no support for () syntax
  AudioObj{i} = wavData;
end
if isempty(dataObjS)
  return
end

if length(dataObjS) == 1
  DAAFObj = DAAF(dataObjS, AudioObj{1},'simple');
  switch (reprChoice)
    case 'PeakAnalysis'
			DAAFObj = tsPeakAnalysis(DAAFObj,concatChoice,ax);
    	DAAFObj = xfade(DAAFObj);
      DAAFObj = concatenate(DAAFObj);
      sound(DAAFObj);
      export(DAAFObj,'peakanalysis');

    case 'FourierTransform'
      DAAFObj = tsFourier(DAAFObj,ax);
      DAAFObj = concatenate(DAAFObj);
      sound(DAAFObj);
      export(DAAFObj,'FourierAnalysis');


    case 'MedianFilter'
      DAAFObj = tsMedian(DAAFObj,17);
    	DAAFObj = xfade(DAAFObj);
      DAAFObj = concatenate(DAAFObj);
      sound(DAAFObj);
      export(DAAFObj,'MedianFilter');
      
  end
end




