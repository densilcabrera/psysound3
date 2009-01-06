function BVCallback(obj, hObj)
% BVCALLBACK Callback for the Bivariate pushbutton

% % Initial handle retrieval
p   = get(hObj,'Parent'); % The uipanel for univariate
uip = get(p,'Parent');    % The uipanel for the DataAnalyser

% Find axes
ax{1} = findobj(uip, 'Type','Axes','Tag','ESAAxesTop');
ax{2} = findobj(uip, 'Type','Axes','Tag','ESAAxesBottom');

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, uip);

% Find the UVCAllback so we can call it once we've thresholded.
ESAChildren = get(uip,'Children');
UVButton    = findobj(ESAChildren(6),'Tag','1DButton');
UVCallback  = get(UVButton,'Callback');


% Decimation Choices
decimateHandle = findobj(p, 'Style','checkbox','Tag','decimateCheckbox');
decimateValue = get(decimateHandle,'Value');
decChoice =[];
if decimateValue == 1
  % Get the Choice of Representation
  decChoiceH = findobj(p,'Tag','decimatePopup');
  decChoice  = get(reprChoiceH,'String');
  decChoice  = str2num(reprChoice(get(reprChoiceH,'Value'),:));
end

% Get the Choice of Representation
reprChoiceH = findobj(p,'Tag','BivariatePopup');
reprChoice  = get(reprChoiceH,'String');
reprChoice  = reprChoice(get(reprChoiceH,'Value'),:);
reprChoice  = strrep(reprChoice,' ',''); % Strip out spaces

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

% Unpack inputs - we will only use 2 inputs in this file. 
nodeObj{1} = getDataObjectFromTreeNode(obj, nodes(1));
nodeObj{2} = getDataObjectFromTreeNode(obj, nodes(2));
waveObj{1} = getWaveDataFromTreeNode(obj, nodes(1)); 
waveObj{2} = getWaveDataFromTreeNode(obj, nodes(2));
s1 = DAAF(nodeObj{1},waveObj{1},'simple');
s2 = DAAF(nodeObj{2},waveObj{2},'simple');

axTag1 = get(ax{1},'Tag');
axTag2 = get(ax{2},'Tag');

% Get Timesteps
timestep1     = diff(nodeObj{1}.DataObj.Time);             % Time Increment 
timestep(1)     = timestep1(1);                    % 
timestep2     = diff(nodeObj{2}.DataObj.Time);             % Time Increment 
timestep(2)     = timestep2(1);                    % 
 
% Errorcheck Timesteps
if (timestep(1) - timestep(2) < 0.00001) && ...
   ~(length(nodeObj{1}.DataObj.Data) == length(nodeObj{2}.DataObj.Data)) || ...
   ~(abs(length(nodeObj{1}.DataObj.Data) - length(nodeObj{2}.DataObj.Data)) == 1)
	% Timesteps from each dataObject are identical
  windowLength = floor(timestep(1) * nodeObj{1}.AnalyserObj.fs); % Get WindowLength
	if mod(windowLength,2)>0
	  windowLength = windowLength - 1;
	end
	timestep = timestep(1);
elseif abs(length(nodeObj{1}.DataObj.Data) - length(nodeObj{2}.DataObj.Data)) == 1
  nodeObj{2}.DataObj.Data
  disp('Lost in limbo');
else
	% timesteps are not identical
	errordlg('The timesteps for the two data objects are different.');
	return;
end	

% They should both be from the same file
if ~strcmp(nodeObj{1}.AnalyserObj.filename,nodeObj{1}.AnalyserObj.filename) 
	errordlg('These data objects aren''t from the same file.');
	return;
end

% And have the sample length
% if ~(length(nodeObj{1}.DataObj.Data) == length(nodeObj{2}.DataObj.Data))
%   if length(nodeObj{1}.DataObj.Data) > length(nodeObj{2}.DataObj.Data)
%    nodeObj{1}.DataObj = nodeObj{1}.DataObj.addsample('Time',nodeObj{2}.DataObj.Time(end),'Data',nodeObj{1}.DataObj.Data(end));
%   end
%   if length(nodeObj{2}.DataObj.Data) > length(nodeObj{1}.DataObj.Data)
%    nodeObj{1}.DataObj = nodeObj{1}.DataObj.addsample('Time',nodeObj{2}.DataObj.Time(end),'Data',nodeObj{1}.DataObj.Data(end));
%   end
%   errordlg('These data objects should be the same lengths');
% 	return;
% end


[junk,index] = regexp(reprChoice,'(\w*-)');
if ~isempty(index)
  UVType =   reprChoice(index+1:end);
  reprChoice = reprChoice(1:index-1);
end


% Switch on reprChoice
switch (reprChoice)
	case 'Regression'
		[Rseries, corSeries, d2flSeries, rlPivot] = regress(s1,s2);
		% add all as objects   

		% Create a new timeseries object
		ts = createDataObject('tSeries', Rseries);
		% Copy over some attributes
		ts.Name = sprintf('%s, Residual', nodeObj{1}.DataObj.tsObj.Name);
    if isnan(nodeObj{1}.DataObj.tsObj.TimeInfo.Increment)
      ts.Time = nodeObj{1}.DataObj.tsObj.Time;
    else
      ts.TimeInfo.Increment = nodeObj{1}.DataObj.tsObj.TimeInfo.Increment;
    end
    ts.DataInfo = nodeObj{1}.DataObj.tsObj.DataInfo;
		nObjCopy = nodeObj{1};
    nObjCopy.DataObj = ts; % Repackage and deposit
   	out = addToDataAnalysisFolder(obj, getValue(nodes(1)), nObjCopy);
		clear('nObjCopy');
    
		ts = createDataObject('tSeries', corSeries);
		% Copy over some attributes
		ts.Name = sprintf('%s, Flattening Correction', nodeObj{1}.DataObj.tsObj.Name);
    if isnan(nodeObj{1}.DataObj.tsObj.TimeInfo.Increment)
      ts.Time = nodeObj{1}.DataObj.tsObj.Time;
    else
      ts.TimeInfo.Increment = nodeObj{1}.DataObj.tsObj.TimeInfo.Increment;
    end
		ts.DataInfo = nodeObj{1}.DataObj.tsObj.DataInfo;
    nObjCopy = nodeObj{1};
		nObjCopy .DataObj = ts; % Repackage and deposit
   	out = addToDataAnalysisFolder(obj, getValue(nodes(1)), nObjCopy);

		ts = createDataObject('tSeries', d2flSeries);
		% Copy over some attributes
		ts.Name = sprintf('%s, Flattened at %.2f', nodeObj{2}.DataObj.tsObj.Name, rlPivot);
	  if isnan(nodeObj{2}.DataObj.tsObj.TimeInfo.Increment)
      ts.Time = nodeObj{2}.DataObj.tsObj.Time;
    else
      ts.TimeInfo.Increment = nodeObj{2}.DataObj.tsObj.TimeInfo.Increment;
     end
    ts.DataInfo = nodeObj{2}.DataObj.tsObj.DataInfo;
		nodeObj{2}.DataObj = ts; % Repackage and deposit
		out = addToDataAnalysisFolder(obj, getValue(nodes(1)), nodeObj{2});

		% Reload tree
	  collapseAndUnLoadTree(obj, uip);
    
  case 'FlattenedReg'
    % Get the Choice of Number to flatten at

    numbChoiceH = findobj(p,'Tag','flattenEditText');
    numbChoice  = str2num(get(numbChoiceH,'String'));
    [Rseries, corSeries, d2flSeries, rlPivot] = regress(s1,s2,numbChoice);
  case 'Compressor'
  case 'Threshold'	
		[thresholds] = thresholdDlg(s2);
    s2 = set(s2,'DataThreshold',thresholds);
		s1 = threshold2(s1, s2);
    set(UVButton, 'UserData',{s1});
    UVCallback(UVButton, s1);
    % So I have fired off the UVCallback, with the DAAF deposited in the
    % button - don't forget to delete afterwards. 
    return;
end % switch(buttonType)

if ~strcmp(reprChoice,'Regression')
  s1 = xfade(s1);
  s1 = concatenate(s1);
  export(s1,reprChoice);
  saveas(gcf, [reprChoice '-'  strrep(waveObj{1}.origFileName,'.wav','.eps')],'epsc');
  sound(s1);
end

function thresholds = thresholdDlg(s1)

prompt         = {'Minimum','Maximum'};
name           = 'Threshold the Data';
numlines       = 1;
defaultanswer  = {num2str(min(s1.DataPoints)),num2str(max(s1.DataPoints))};
answer         = inputdlg(prompt,name,numlines,defaultanswer);
if isempty(answer)
  return;
end

thresholds     = [str2num(answer{1}) str2num(answer{2})];

% EOF
