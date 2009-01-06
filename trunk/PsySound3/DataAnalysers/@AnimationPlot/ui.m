function obj = ui(obj, panel)
% UI method for Animation Plot
%
% Inputs:
%  panel : is the handle to the left panel of the data analyser

bgColor = [0.9 0.9 0.9];

% Add the Movie push-button
uicontrol('Parent',   panel, ...
          'units',    'normalized', ...
          'Position', [0.8 0.64 0.17 0.07], ...
          'String',  'Movie', ...
          'Enable',  'off', ...
          'ToolTip', 'Plots graph', ...
          'BackGroundColor', bgColor, ...              
          'Callback', @(src, ev)Movie(obj, src), ...
          'Tag',      'MovieButton', ...
          'Style',   'Pushbutton');

% Add the Multi-Graph push-button
uicontrol('Parent',   panel, ...
          'units',    'normalized', ...
          'Position', [0.8 0.54 0.17 0.07], ...
          'String',  'X-Y', ...
          'ToolTip', 'Plots graph', ...
          'BackGroundColor', bgColor, ...              
          'Enable',  'off', ...
          'Callback', @(src, ev)Comet(obj, src), ...
          'Tag',      'XYButton', ...
          'Style',   'Pushbutton', ...
					'Visible',  'off');

% Add axis
ax = axes('Parent', panel, ...
          'Units', 'normalized', ...
          'Tag',   'AnimAxes', ...
          'OuterPosition',      [0 0 0.8 0.95]);

% Add context menu
AddVisContextMenu(ax);

% Add plot type popup
uicontrol('Parent', panel, ...
          'units', 'normalized', ...
          'FontSize', 9, ...
          'Position', [0.8 0.74 0.17 0.07], ...
          'String', ' ', ...
          'ToolTip', 'Select the plot type', ...
          'BackGroundColor', bgColor, ...              
          'Enable', 'off', ...
          'Tag',    'PlotTypePopup', ...
          'Style' , 'Popup');

%
% Axis context menu
%
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
  ax = findobj(f, 'Type', 'Axes', 'Tag', 'SingleAxes');
  
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
  ax = findobj(f, 'Type', 'Axes', 'Tag', 'SingleAxes');
  
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
  ax = findobj(f, 'Type', 'Axes', 'Tag', 'SingleAxes');
  
  % Clone into a new figure
  newFig = figure;
  newAx = copyobj(ax, newFig);
  
  % Fix dimensions
  set(newAx, 'Position', [0.1 0.1 0.8 0.8]);
  
% end newFigCallback
  

% EOF
