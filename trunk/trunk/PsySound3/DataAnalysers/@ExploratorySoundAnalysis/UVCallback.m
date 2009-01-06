function UVCallback(obj, hObj, DAAFObj)
% UVCALLBACK Callback for the Univariate pushbutton

% % Initial handle retrieval
p   = get(hObj,'Parent'); % The uipanel for univariate
uip = get(p,'Parent');    % The uipanel for the DataAnalyser

% Find axes
ax{1} = findobj(uip, 'Type','Axes','Tag','ESAAxesTop');
ax{2} = findobj(uip, 'Type','Axes','Tag','ESAAxesBottom');

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, uip);

% Decimation Choices
decimateHandle = findobj(p, 'Style','checkbox','Tag','decimateCheckbox');
decimateValue = get(decimateHandle,'Value');
decChoice =[];
if decimateValue == 1
% Get the Choice of Decimation Length
decChoiceH = findobj(p,'Tag','decimatePopup');
decChoice  = get(decChoiceH,'String');
decChoice  = str2num(decChoice(get(decChoiceH,'Value'),:));
else
  decChoice = 3; 
end

% Get the Choice of Representation
reprChoiceH = findobj(p,'Tag','UnivariatePopup');
reprChoice  = get(reprChoiceH,'String');
reprChoice  = reprChoice(get(reprChoiceH,'Value'),:);
reprChoice  = strrep(reprChoice,' ',''); % Strip out spaces

% Get the Choice of Percentile (in case we need it)
pctlChoiceH = findobj(p,'Tag','UnivariatePctlPopup');
pctlChoice  = get(pctlChoiceH,'String');
pctlChoice  = pctlChoice(get(pctlChoiceH,'Value'),:);
pctlChoice  = strrep(pctlChoice,' ',''); % Strip out spaces
pctlChoice  = str2num(pctlChoice);

% Bail out if empty
if isempty(nodes)
  return;
end

% Clear up some things
axes(ax{1});
cla; legend off; colorbar off; title('');
set(ax{1}, 'UserData', []);
set(ax{1}, 'XLimMode', 'auto');
set(ax{1}, 'YLimMode', 'auto');
set(ax{1}, 'ZLimMode', 'auto');
set(ax{1}, 'YTickLabelMode', 'auto');
set(ax{1}, 'XTickLabelMode', 'auto');
set(ax{1}, 'XTickMode', 'auto');
cla;

axes(ax{2});
cla; legend off; colorbar off; title('');
set(ax{2}, 'UserData', []);
set(ax{2}, 'XLimMode', 'auto');
set(ax{2}, 'YLimMode', 'auto');
set(ax{2}, 'ZLimMode', 'auto');
set(ax{2}, 'XTickLabelMode', 'auto');
set(ax{2}, 'YTickLabelMode', 'auto');
set(ax{1}, 'XTickMode', 'auto');
cla;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if the thresholded DAAF has been passed in DAAFObj %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if ~isempty(get(hObj,'UserData'))
  DAAFObj = get(hObj,'UserData'); DAAFObj = DAAFObj{1};
  set(hObj,'UserData',[]);
  switch (reprChoice)
    case 'Boxplot'
      DAAFObj = boxplot(DAAFObj);
      DAAFObj = set(DAAFObj,'Overlap',0.05);
      if decimateValue
        DAAFObj = decimate(DAAFObj,decChoice);
      end
    case 'CumulativeDistribution'      
      DAAFObj = CDF(DAAFObj,'Graph',ax);
      if decimateValue
      	DAAFObj = decimate(DAAFObj,decChoice);
      end
    case 'Density'
      if decimateValue
      	DAAFObj = density(DAAFObj,'Graph',decChoice);
      else
				DAAFObj = density(DAAFObj,'Graph',10);
			end
    case 'Histogram'
      DAAFObj = hist(DAAFObj,decChoice);
    case {'Mean','Median','Min','Max'}
      DAAFObj = displayStats(DAAFObj,lower(reprChoice),decChoice,1,ax);
    case 'Percentile'
      DAAFObj = displayStats(DAAFObj,pctlChoice,decChoice,1,ax);
  end
  
  if ~strcmp(reprChoice,'Density')
    DAAFObj = xfade(DAAFObj);
    DAAFObj = concatenate(DAAFObj);
  end

  %%%%%%%%%%%%
  % Graphing %
  %%%%%%%%%%%%

    switch (reprChoice)
      case 'Boxplot'
        DAAFObj = boxplot(DAAFObj,ax);
      case 'CumulativeDistribution'
        DAAFObj = CDF(DAAFObj,ax);
			case 'Density'
      case 'Histogram'
        DAAFObj =hist(DAAFObj,decChoice,ax);
      case {'Mean','Median','Min','Max'}
    end
   drawnow;
  sound(DAAFObj);
  if strcmp(reprChoice,'Percentile')
    export(DAAFObj,pctlChoice);
  else
    export(DAAFObj,reprChoice);
  end
  return;
end


%%%%%%%%%%%%%
% Otherwise %
%%%%%%%%%%%%%
for i = 1:length(nodes)
  dataObjS(i) = getDataObjectFromTreeNode(obj, nodes(i));
  wavData =  getWaveDataFromTreeNode(obj,nodes(i)); % Little hack
  AudioObj{i} = wavData;
end
if isempty(dataObjS)
  return
end

if length(dataObjS) == 1 

  DAAFObj = DAAF(dataObjS, AudioObj{1},'simple');
  switch (reprChoice)
    case 'Boxplot'
      DAAFObj = boxplot(DAAFObj);
      DAAFObj = set(DAAFObj,'Overlap',0.05);
      if decimateValue
        DAAFObj = decimate(DAAFObj,decChoice);
      end
    case 'CumulativeDistribution'      
      DAAFObj = CDF(DAAFObj,'Graph',ax);
      if decimateValue
      	DAAFObj = decimate(DAAFObj,decChoice);
      end
    case 'Density'
      if decimateValue
      	DAAFObj = density(DAAFObj,'Graph',decChoice);
      else
				DAAFObj = density(DAAFObj,'Graph',10);
			end
    case 'Histogram'
      DAAFObj = hist(DAAFObj,decChoice);
    case {'Mean','Median','Min','Max'}
      DAAFObj = displayStats(DAAFObj,lower(reprChoice),decChoice,1,ax);
    case 'Percentile'
      DAAFObj = displayStats(DAAFObj,pctlChoice,decChoice,1,ax);
  end
  
  if ~strcmp(reprChoice,'Density')
    DAAFObj = xfade(DAAFObj);
    DAAFObj = concatenate(DAAFObj);
  end

  %%%%%%%%%%%%
  % Graphing %
  %%%%%%%%%%%%

  if length(dataObjS) == 1
    switch (reprChoice)
      case 'Boxplot'
        DAAFObj = boxplot(DAAFObj,ax);
      case 'CumulativeDistribution'
        DAAFObj = CDF(DAAFObj,ax);
			case 'Density'
      case 'Histogram'
        DAAFObj =hist(DAAFObj,decChoice,ax);
      case {'Mean','Median','Min','Max'}
    end
  end

  drawnow;
  sound(DAAFObj);
  if strcmp(reprChoice,'Percentile')
    export(DAAFObj,pctlChoice);
  else
    export(DAAFObj,reprChoice);
  end

elseif length(dataObjS) > 1
  for i = 1:length(dataObjS)
    s = DAAF(dataObjS(i), AudioObj{i},'simple');
    DAAFObj{i} = s;
    switch (reprChoice)
      case 'Boxplot'
        s = boxplot(DAAFObj{i});
      case 'CumulativeDistribution'
        s = CDF(DAAFObj{i});
      case 'Histogram'
        s = hist(DAAFObj{i});
      case 'Median'
        s = displayStats(DAAFObj{i},'median',3,0);
      case 'Density'
      	if decimateValue
      		s = density(DAAFObj{i},'Graph',decChoice);
        else
					s = density(DAAFObj{i},'Graph',10);
				end
			case 'Max'
        s = displayStats(DAAFObj{i},'max',3,0);
      case 'Percentile'
        s = displayStats(DAAFObj{i},pctlChoice,3,0);
    end

    if ~strcmp(reprChoice,'Density')
      s = xfade(s);
      s = concatenate(s);
    end

    DAAFObj{i} = s; %Hack
  end

  %%%%%%%%%%%%% Graphing %%%%%%%%%%%%%%%
  switch (reprChoice)
    case 'Boxplot'
   %   DAAFObj = boxplot(DAAFObj,ax);
   [matrixData,names] = formatBoxplotData(DAAFObj);
   figure; 
   boxplot(matrixData,0,'r.',0);
   set(gca,'YTickLabel',names);
   set(gca,'xTickMode','auto')
   xlabel([DAAFObj{1}.Name ' (' DAAFObj{1}.Units.Unit ')']);
    case 'CumulativeDistribution'
   %   DAAFObj = CDF(DAAFObj,ax);
    case 'Histogram'
   %   DAAFObj =hist(DAAFObj,decChoice,ax);
    case {'Mean','Median','Min','Max'}
      for i = 1:length(DAAFObj)
        dat(i) = DAAFObj{i}.Stats.(lower(reprChoice));
        names{i} = strrep(DAAFObj{i}.AudioFilename,'.wav','');
      end
      [values,indexs] = sort(dat);
      names = names(indexs);
      DAAFObj = DAAFObj(indexs);
      figure; bar(1:length(values), values);
			ylabel([DAAFObj{1}.Name, ' (', DAAFObj{1}.Units.Units,')']);
      set(gca,'XTick', 1:length(values)); set(gca,'XTickLabel',names);
  end
  %%%%%%%%%%%%% Sound %%%%%%%%%%%%%%%
  sound(DAAFObj{1},DAAFObj);
  sound(DAAFObj{1},pctlChoice,DAAFObj);
  if strcmp(reprChoice,'Percentile')
    export(DAAFObj{1},pctlChoice),DAAFObj;
  else
    export(DAAFObj{1},reprChoice,DAAFObj);
  end
end



function [matrixData,names] = formatBoxplotData(DAAFObjArray)

matrixData = [DAAFObjArray{1}.DataPoints];
lengthData = max([0 length(DAAFObjArray{1}.DataPoints)]);

for i = 2: length(DAAFObjArray)
  
  if length(DAAFObjArray{i}.DataPoints) > lengthData
    lengthCorrection =  length(DAAFObjArray{i}.DataPoints) - lengthData;
    matrixData(lengthData+1:lengthData+lengthCorrection,1:i-1) = NaN(lengthCorrection, 1:i);
    matrixData(:,i) = DAAFObjArray{i}.DataPoints;
    lengthData = length(DAAFObjArray{i}.DataPoints);
  else
    lengthCorrection = length(DAAFObjArray{i}.DataPoints) - lengthData;
    matrixData(:,i) = [DAAFObjArray{i}.DataPoints; NaN(abs(lengthCorrection),1)];
  end
  
end
for i = 1:length(DAAFObjArray)
  names{i} = strrep(DAAFObjArray{i}.AudioFilename,'.wav','');
end
