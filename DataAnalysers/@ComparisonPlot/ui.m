function obj = ui(obj, panel)
% UI metod for basic stats
% 

bgColor = [0.9 0.9 0.9];

% Create uicontrols
posGraph = [0.8 0.64 0.17 0.07];
posPopup = [0.8 0.74 0.17 0.07];

set(panel,'Visible','off');

h = uicontrol('Parent', panel, ...
              'units', 'normalized', ...
              'Position', posGraph, ...
              'String',  'Graph', ...
              'Callback', @(src, ev)Graph(obj, src), ...
              'ToolTip', 'Displays Bar Chart of Selected Objects', ...
              'Tag', 'ComparisonPlotGraph', ...
							'Style',   'Pushbutton');

uicontrol('Parent', panel, ...
              'units', 'normalized', ...
              'Position', posPopup, ...
              'String',  'bar', ...
              'Callback', @(src, ev)Graph(obj, src), ...
              'ToolTip', 'Choose Graph Type', ...
              'Tag', 'ComparisonPlotPopup', ...
							'Style',   'popupmenu');
							
% Add axis
ax = axes('Parent', panel, ...
          'Units', 'normalized', ...
          'Tag',   'ComparisonAxes', ...
          'OuterPosition',      [0 0 0.78 0.93]);
							

% Add context menu
AddVisContextMenu(ax);

function AddVisContextMenu(ax)
  
  % Create a default menu
  uih = uicontextmenu;

  % Add items
  uimenu(uih, ...
         'Label',    'Grid',...  
         'Enable',   'off', ...
         'Tag',      'grid', ...
         'Callback', @gridCallback);
  
  uimenu(uih, ...
         'Label',    'Legend', ...
         'Enable',   'off', ...
         'Tag',      'legend', ...
         'Callback', @legendCallback);

  uimenu(uih, ...
         'Label',     'Open new figure', ...
         'Enable',    'off', ...
         'Callback',   @newFigCallback, ...
         'Tag',       'newFig', ...
         'Separator', 'on');
	
  set(ax, 'UIContextMenu', uih);
  
% end AddVisContextMenu

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Context menu callbacks %
%%%%%%%%%%%%%%%%%%%%%%%%%%
function gridCallback(varargin)
  
  h = varargin{1};
  
  % Find the axes
  f  = get(get(h, 'Parent'), 'Parent');
  ax = findobj(f, 'Type', 'Axes', 'Tag', 'ComparisonAxes');
  
  str = get(ax, 'XGrid');
  if strcmp(str, 'on')
    % Turn it off
    grid(ax, 'off');
    set(h, 'Checked', 'off');
  else
    % Turn it on
    grid(ax, 'on');
    set(h, 'Checked', 'on');
  end    
% end gridCallback

%
% legendCallback
%
function legendCallback(varargin)
  
  h = varargin{1};

  % Find the axes
  f  = get(get(h, 'Parent'), 'Parent');
  lg = findobj(f, 'Type', 'Axes', 'Tag', 'legend');
  ax = findobj(f, 'Type', 'Axes', 'Tag', 'ComparisonAxes');
  
  if ~isempty(lg)
    % Turn it off
    legend off;
    set(h, 'Checked', 'off');
  else
    % Turn it on
    strs = get(ax, 'UserData');
    legend(ax, strs);
    set(h, 'Checked', 'on');
  end    
% end legendCallback

%
% newFigCallback
%
function newFigCallback(varargin)
  h = varargin{1};

  % Find the axes
  f  = get(get(h, 'Parent'), 'Parent');
  ax = findobj(f, 'Type', 'Axes', 'Tag', 'ComparisonAxes');
  
  % Clone into a new figure
  newFig = figure;
  newAx = copyobj(ax, newFig);
  
  % Fix dimensions
  set(newAx, 'Position', [0.1 0.1 0.8 0.8]);
  
% end newFigCallback

% EOF
