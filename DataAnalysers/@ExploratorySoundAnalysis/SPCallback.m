function SPCallback(obj, hObj)
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
reprChoiceH = findobj(p,'Tag','SpectralSonPopup');
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


for i = 1:length(nodes)
  dataObjS(i) = getDataObjectFromTreeNode(obj, nodes(i));
end
  
for i = 1:length(nodes)
 
%   if strcmp(class(dataObjS(i).DataObj),'Spectrum')
%   
%     axes(ax{1}); 
%     plot(dataObjS(i).DataObj);
%     axis([0 max(dataObjS(i).DataObj.Freq) 0 max(dataObjS(i).DataObj.Data)]);
%     set(ax{1},'Tag','ESAAxesTop');
%     
%     axes(ax{2}); 
%     tSpec = getDataObjectFromTreeNode(obj, nodes(i));
%     node = nodes(i);
%     while ~strcmp(class(tSpec.DataObj),'tSpectrum')
%       node = getNextSibling(node);
%       tSpec = getDataObjectFromTreeNode(obj,node);
%     end
%     plot(tSpec.DataObj);
%     set(ax{2},'Tag','ESAAxesBottom');
%    
%     drawnow;
%     
%   end
    
%   if ~strcmp(class(dataObjS(i).DataObj),'tSeries')
%     % get Sibling Time Series from Next Node
%     while ~strcmp(class(dataObjS(i).DataObj),'tSeries')
%       dataObjS(i) = getDataObjectFromTreeNode(obj,getNextSibling(nodes(i)));
%     end
%   end
  wavData =  getWaveDataFromTreeNode(obj,nodes(i)); % Little hack due to no support for () syntax
  AudioObj = wavData;
  try
    if strcmp(dataObjS(i).AnalyserObj.Name, 'Beatroot Beat Detection')
      beats = dataObjS(i);
    end
  end
	try
    if strcmp(dataObjS(i).AnalyserObj.Name, 'Pitch (Terhardt)')
      vpitch = dataObjS(i);
    end
  end

end

if isempty(dataObjS)
  return
end

[junk,index] = regexp(reprChoice,'(\w*-)');
if ~isempty(index)
  UVType =   reprChoice(index+1:end);
  reprChoice = reprChoice(1:index-1);
end
% Decimation
decFactor = 5;

% Switch on plot type
  switch (deblank(reprChoice))
    
    case 'AverageSpectrum'
      
		  % Find the right data object to plot
      if strcmp(class(dataObjS(i).DataObj),'Spectrum')

        tSpec = getDataObjectFromTreeNode(obj, nodes(i));
        node = nodes(i);
        while ~strcmp(class(tSpec.DataObj),'tSpectrum')
          node = getNextSibling(node);
          tSpec = getDataObjectFromTreeNode(obj,node);
        end

				% Plotting
        axes(ax{1}); plot(dataObjS(i).DataObj);
        axis([0 max(dataObjS(i).DataObj.Freq) 0 max(dataObjS(i).DataObj.Data)]);
        set(ax{1},'Tag','ESAAxesTop');

        axes(ax{2}); plot(tSpec.DataObj);
        set(ax{2},'Tag','ESAAxesBottom');
        drawnow;
			
				% Now get a tseries object for sound
      	tSer = getDataObjectFromTreeNode(obj, nodes(i));
      	node = nodes(i);
      	while ~strcmp(class(tSer.DataObj),'tSeries')
        	node = getNextSibling(node);
        	tSer = getDataObjectFromTreeNode(obj,node);
      	end
      end
			% make spectral sonification from tseries object through averaging
      DAAFObj = DAAF(tSer, AudioObj,'simple');
      DAAFObj = set(DAAFObj,'Overlap',0.25);
			% Averaging call
      DAAFObj = summSpec(DAAFObj,tSer.AnalyserObj.windowLength,'randomwind');
      DAAFObj = xfade(DAAFObj);
      DAAFObj = concatenate(DAAFObj);
			% play sound, export sound
      sound(DAAFObj);
      export(DAAFObj,reprChoice);    
          
      
    case 'BeatSpectrum'
		  if exist('vpitch')
      	DAAFObj = DAAF(dataObjS(1), AudioObj,'beatSpectrum',beats,vpitch);
      else
      	DAAFObj = DAAF(dataObjS(1), AudioObj,'beatSpectrum',beats);
			end
			DAAFObj = set(DAAFObj,'Overlap',0.01);
      
      switch deblank(UVType)
        case {'Original'}
          DAAFObj = recreate(DAAFObj);
        case {'CDF'}
          DAAFObj = CDF(DAAFObj);
        case {'Histogram'}
          DAAFObj = hist(DAAFObj,DAAFObj.Duration);
        case {'Median','Max','Min'}
          DAAFObj = displayStats(DAAFObj,lower(UVType),10);
      end      
      DAAFObj = xfade(DAAFObj);
      DAAFObj = concatenate(DAAFObj);
      sound(DAAFObj);
      export(DAAFObj,reprChoice);    
      
      
    case 'BeatSegmentation'
		  if exist('vpitch')
      	DAAFObj = DAAF(dataObjS(1), AudioObj,'beatSpectrum',beats,vpitch);
      else
      	DAAFObj = DAAF(dataObjS(1), AudioObj,'beatSpectrum',beats);
			end
			DAAFObj = set(DAAFObj,'Overlap',0.01);
      DAAFObj = recreate(DAAFObj);
      DAAFObj = xfade(DAAFObj);
      DAAFObj = concatenate(DAAFObj);
      sound(DAAFObj);
      %export(DAAFObj,reprChoice);    

    case 'ChromaSonification'
      if strcmp(class(dataObjS(1).DataObj),'AudioTSeries')
         playchroma('spectrumBeats',dataObjS(1).DataObj,dataObjS(2).DataObj.Events,3);
      elseif strcmp(class(dataObjS(1).DataObj),'tSpectrum')
        if length(dataObjS) > 1
          playchroma('chromaBeats',dataObjS(1).DataObj,dataObjS(2).DataObj.Events);
        else
          playchroma('chromaPattern',dataObjS(1).DataObj);
        end
      end

		case 'GainFunction'
      
			% Cut up into beats
			if exist('vpitch')
      	DAAFObj = DAAF(dataObjS(1), AudioObj,'beatSpectrum',beats,vpitch);
      else
      	DAAFObj = DAAF(dataObjS(1), AudioObj,'beatSpectrum',beats);
			end
			DAAFObj = set(DAAFObj,'Overlap',0.01);
			DAAFObj = recreate(DAAFObj);
			%DAAFObj = xfade(DAAFObj);
			DAAFObj = concatenate(DAAFObj);

			% Make raw sampling rate gain function
			gFuncTime = [0:(1/DAAFObj.FS*decFactor):DAAFObj.Duration]';
			gFuncData = NaN(length(gFuncTime), 1);

			% Find boundaries and timeseries values for audio between beats 
			for i = 2:length(DAAFObj.TimePoints)-1
				indexs = find(gFuncTime >= DAAFObj.TimePoints(i-1) & gFuncTime < DAAFObj.TimePoints(i));
				gFuncData(indexs) = DAAFObj.DataPoints(i-1);
			end

			% Map to gain function using maths
			maxExtent = max(DAAFObj.DataPoints);     % max data
			minExtent = min(DAAFObj.DataPoints);     % min data
			gFuncData(isnan(gFuncData)) = minExtent; % set NaN to lowest value of data

			% gain extents -5 to -35
			rangeData = maxExtent - minExtent; % find range
			gFuncData = gFuncData - minExtent; % make data start on 0
			gFuncData = gFuncData / rangeData; % make data between 0 and 1
			gFuncData = gFuncData * 30;        % make data between 0 and 30
			gFuncData = gFuncData - 35;        % make data between -35 and -5

			% Apply gain function
      OutputAudio = DAAFObj.OutputAudio;
      try 
        gFuncData   = gFuncData(1:length(OutputAudio));
      catch
        OutputAudio = OutputAudio(1:length(gFuncData));
      end
      OutputAudio = OutputAudio .* (10.^(gFuncData/20)); % Apply
      DAAFObj = set(DAAFObj, 'OutputAudio', OutputAudio);
      
			% Out
			sound(DAAFObj); 
			export(DAAFObj,reprChoice);

end


