function Graph(obj, hObj)
% GRAPH Callabck for the Graph pushbutton

% Initial handle retrieval
p   = get(hObj,'Parent');
utb = get(p,   'Parent');
utg = get(utb, 'Parent');
fig = get(utg, 'Parent');

% Figure out the value of the popup
plotPopup = findobj(p, 'Style', 'Popup', 'Tag', 'PlotTypePopup');
plotStrs  = get(plotPopup, 'String');
plotType  = '';
if ~isempty(deblank(plotStrs{1})),
  plotType  = deblank(plotStrs{get(plotPopup, 'Value'),:});
end

% Find axes
ax = findobj(p, 'Type','Axes');
if length(ax) == 2
  ax =ax(2);
end

% if isempty(ax)
%   ax = findobj(p, 'Type','Axes');
% end

% Get the tree nodes
nodes = getSelectedTreeNodes(obj, p);

% Bail out if empty
if isempty(nodes)
  return;
end

% Clear up some things
axes(ax);
cla; legend off; colorbar off;
axis auto;
set(ax, 'UserData', []);
set(ax, 'XLimMode', 'auto');
set(ax, 'YLimMode', 'auto');
set(ax, 'ZLimMode', 'auto');

% Find contextmenu stuff
uih = get(ax, 'UIContextMenu');
lg  = findobj(uih, 'Type', 'uimenu', 'Tag', 'legend');
gr  = findobj(uih, 'Type', 'uimenu', 'Tag', 'grid');
nf  = findobj(uih, 'Type', 'uimenu', 'Tag', 'newFig');

set([lg gr nf], 'Enable', 'off');
set(lg, 'Checked', 'off');

waitTextH = [];

% Switch on plot type
switch(get(hObj, 'String'))
  case 'Graph'
    % Get the FIRST object and plot
    dataObjS = getDataObjectFromTreeNode(obj, nodes(1));
    if ~isempty(dataObjS)

      % Only add the text for TimeSpectrum objects, otherwise it
      % could get annoying
      if isa(dataObjS.DataObj, 'tSpectrum');
        % Add wait text
        waitTextH = text(0.5, 0.5, sprintf(['Please wait ...\n(This may take ' ...
          'a while)']));
        set(waitTextH, 'HorizontalAlignment', 'center');
        drawnow;
      end

      plot(dataObjS.DataObj, plotType);

      titleStr = '';
      if ~isempty(dataObjS.AnalyserObj)
        if iscell(dataObjS.AnalyserObj)
          titleStr = sprintf('%s\n%s, %s', dataObjS.DataObj.Name, ...
            dataObjS.AnalyserObj{1}.filename(1:end-3), ...
            dataObjS.AnalyserObj{2}.filename(1:end-3));
        else
          titleStr = sprintf('%s - %s', dataObjS.DataObj.Name, ...
            dataObjS.AnalyserObj.filename(1:end-3));
        end
      else
        titleStr = dataObjS.DataObj.Name;
      end
      title(titleStr);
    end

  case 'Multi-Graph'
    nameStrs = {};
    % Plots all selected
    for l=1:length(nodes)
      dataObjS = getDataObjectFromTreeNode(obj, nodes(l));
      if ~isempty(dataObjS)
        plot(dataObjS.DataObj, plotType);
        nameStrs{l} = get(dataObjS.DataObj, 'Name');
        hold on;
      end
    end

    % Fix up the colors
    co = get(ax, 'ColorOrder');
    ch = get(ax, 'Children');
    for l=1:length(ch)
      set(ch(l), 'Color', co(l,:));
    end

    % Add legend
    legend(nameStrs);
    legend show;

    % Stick name Strs in UserData for the future
    set(ax, 'UserData', nameStrs);

    % Find and turn on legends
    set(lg, 'Enable',  'on');
    set(lg, 'Checked', 'on');

  case 'X-Y'
    % Load first
    data1    = [];
    dataObjS = getDataObjectFromTreeNode(obj, nodes(1));
    if ~isempty(dataObjS)
      dataObj1 = dataObjS.DataObj;
      data1    = dataObj1.Data;
    end

    % Load second
    data2    = [];
    dataObjS = getDataObjectFromTreeNode(obj, nodes(2));
    if ~isempty(dataObjS)
      dataObj2 = dataObjS.DataObj;
      data2    = dataObj2.Data;
    end

    if ~isempty(data1) && ~isempty(data2) && (length(data1) == length(data2))
      plot(data1, data2,'ro');
      xlabel(dataObj1.DataInfo.Units);
      ylabel(dataObj2.DataInfo.Units);
      title([dataObj2.Name, ' vs ', sprintf('\n'), dataObj1.Name]);
    else
      text(0.2, 0.5, 'Incompatible data encountered');
    end

  case 'Two-Axis'
    % Load first
    data1    = [];
    dataObjS = getDataObjectFromTreeNode(obj, nodes(1));
    if ~isempty(dataObjS)
      dataObj1 = dataObjS.DataObj;
      data1    = dataObj1.Data;
      time1    = dataObj1.Time;
    end

    % Load second
    data2    = [];
    dataObjS = getDataObjectFromTreeNode(obj, nodes(2));
    if ~isempty(dataObjS)
      dataObj2 = dataObjS.DataObj;
      data2    = dataObj2.Data;
      time2    = dataObj2.Time;
    end
    if ~isempty(data1) && ~isempty(data2)
      axes(ax);
      % Plot
      [h,ax1,ax2] = plotyy(time1, data1, time2, data2);
      xlabel('Time(s)');
			if ~isempty(dataObj1.DataInfo.Units)
      	set(get(h(1),'YLabel'),'String',[dataObj1.Name ' (' dataObj1.DataInfo.Units ')'])
			else
					set(get(h(1),'YLabel'),'String',dataObj1.Name)
			end
			if ~isempty(dataObj2.DataInfo.Units)
	      set(get(h(2),'YLabel'),'String',[dataObj2.Name ' (' dataObj2.DataInfo.Units ')'])
  		else
		  	set(get(h(2),'YLabel'),'String',dataObj2.Name)
			end
    %title([dataObj1.Name, ' and ', sprintf('\n'), dataObj2.Name]);
    else
      text(0.2, 0.5, 'Incompatible data encountered');
    end

  case 'Sub-Figure'
    % Plots all selected
    try
      figure

      % What is the name and class of the selected nodes
      for l=1:length(nodes)
        dataObjS = getDataObjectFromTreeNode(obj, nodes(l));
        ObjNames{l} = dataObjS.DataObj.Name;
        ObjClass{l} = class(dataObjS.DataObj);
      end

      % Is there anything common about the selected nodes
      if sum(strcmp(char(ObjNames{1}), ObjNames)) == l
        allSameName = 1;
      else
        allSameName = 0;
      end
      tSpecs  = strcmp('tSpectrum', ObjClass);
      tSeries = strcmp('tSeries', ObjClass);
      AtSeries = strcmp('AudioTSeries', ObjClass);
      if all(tSpecs + tSeries + AtSeries) || all(strcmp(char(ObjClass{1}), ObjClass))
        allSameClass = 1;
        if all(tSpecs + tSeries)
          alltSeries = 1;
        else
          alltSeries = 0;
        end
      else
        alltSeries = 0;
        allSameClass = 0;
      end

      % If they're all the same then get common axis limits.

      answer1 = [];
      answer2 = [];
      if allSameClass
        maxY = []; minY = []; maxX = []; minX = [];
        for l=1:length(nodes)
          dataObjS = getDataObjectFromTreeNode(obj, nodes(l));
          if   ~strcmp(ObjClass{l},'tSpectrum')
            maxY = max([max(max(dataObjS.DataObj.data)); maxY]);
            minY = min([min(min(dataObjS.DataObj.data)); minY]);
          elseif  strcmp(ObjClass{l},'tSpectrum')
            if isempty(answer1)
              prompt={'Enter the minimum y-axis value:','Enter the maximum y-axis value:'};
              name='Y Axis Limits';
              numlines=1;
              defaultanswer={'0','8000'};
              answer1=inputdlg(prompt,name,numlines,defaultanswer);
              minY = str2num(answer1{1});    maxY = str2num(answer1{2});
            end
          end
          if alltSeries
            maxX = max([max(dataObjS.DataObj.time); maxX]);
            minX = min([min(dataObjS.DataObj.time); minY]);
          else
            if isempty(answer2)
              prompt={'Enter the minimum x-axis value:','Enter the maximum x-axis value:'};
              name='X-Axis Limits';
              numlines=1;
              defaultanswer={'0','100'};
              answer2=inputdlg(prompt,name,numlines,defaultanswer);
              minX = str2num(answer2{1});    maxX = str2num(answer2{2});
            end
          end
        end
      end

      % Got the parameters  - now do some plots
      for l=1:length(nodes)
        dataObjS = getDataObjectFromTreeNode(obj, nodes(l));

        if ~isempty(dataObjS)
          h(l) = subplot(length(nodes),1,l);
          plot(dataObjS.DataObj);

          if allSameClass && allSameName
            limits = axis;
            if strcmp(ObjClass{l},'tSpectrum')
              colorbar off
              axis([minX maxX minY maxY])
            else
              axis([minX maxX minY maxY]);
            end
          end

          if allSameClass && ~allSameName
            limits = axis;
            if strcmp(ObjClass{l},'tSpectrum')
              colorbar off
              axis([minX maxX limits(3) limits(4)]);
            elseif strcmp(ObjClass{l},'tSeries')
              axis([minX maxX limits(3) limits(4)]);
            end
          end
          dot = strfind(dataObjS.AnalyserObj.filename,'.');
          title(dataObjS.AnalyserObj.filename(1:dot-1));
          limits = axis;
          pos = get(get(gca,'Title'),'Position');
          set(get(gca,'Title'),'Position',[limits(2) pos(2) pos(3) ],'HorizontalAlignment','Right')
          if l ~= length(nodes)
            xlabel([]);
          end
        end
      end
    catch
      errordlg('Error: At least 1 of these objects cannot be plotted with subfigure. Sorry.');
    end    
    % link axes for zooming
    linkaxes(h, 'x');
    zoom xon;

end % switch(buttonType)

% Just in case there was an error
if ishandle(waitTextH)
  delete(waitTextH);
end

% Add the context menu to lines & images, too
set(get(ax, 'Children'), 'UIContextmenu', uih);

% Enable context menu items
set(gr, 'Enable', 'on');
set(nf, 'Enable', 'on');

% Restore grid settings
if strcmp(get(gr, 'checked'), 'on')
  grid(ax, 'on');
end

% Reset some stuff
set(ax, 'Tag', 'SingleAxes');

% EOF
