function obj = ui(obj, panel)
% UI metod for basic stats
% 

bgColor = [0.9 0.9 0.9];

% Create buttons
pos = [0.05 0.7 0.12 0.05];


obj.Table = uitable('Parent', panel);
set(obj.Table, 'Visible', false);
set(panel,'Visible','off');

h = uicontrol('Parent', panel, ...
              'units', 'normalized', ...
              'Position', pos, ...
              'String',  'Display', ...
              'Callback', @(src, ev)displayStatsObject(obj, src), ...
              'ToolTip', 'Adds data object to table', ...
              'Tag', 'BasicStatisticsDisplay', ...
							'Style',   'Pushbutton');

% obj.add = h;
% 
% pos(2) = pos(2) - pos(4) - 0.01;
% h = uicontrol('Parent', panel, ...
%               'units', 'normalized', ...
%               'Position', pos, ...
%               'String',  'Remove', ...
%               'Callback', @removeObject, ...
%               'ToolTip', 'Remove data object from table', ...
%               'Style',   'Pushbutton');
% obj.remove = h;
% 
% pos(2) = pos(2) - pos(4) - 0.01;
% h = uicontrol('Parent', panel, ...
%               'units', 'normalized', ...
%               'Position', pos, ...
%               'String',  'Clear', ...
%               'Callback', @clearAll, ...
%               'ToolTip', 'Clears table', ...
%               'Style',   'Pushbutton');
% obj.clear = h;

% xxx
%return;

% Set position
set(obj.Table, 'Units', 'normalized');

 set(obj.Table, 'Position', [0.47 0.18 0.48 0.65]);
%set(hTable, 'Position', [0 0.02 0.7 0.8]);
assignin('base', 'gg', obj.Table);

% Set the callback as userdata on the panel
set(panel, 'UserData', @statsTableCallback);

  % Set the function handle on the panel
  function statsTableCallback

  % Key off the tab as the panel is always visible!
    vis = get(get(panel, 'Parent'), 'Visible');
    if strcmp(vis, 'on')
      set(obj.Table, 'Visible', true);
    else
      set(obj.Table, 'Visible', false);
    end
  end
end

% EOF
