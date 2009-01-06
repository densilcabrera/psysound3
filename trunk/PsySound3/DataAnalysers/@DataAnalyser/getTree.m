function uit = getTree(obj, panel)
% GETTREE  Returns the uitree from the post-prop panel

% Tab from panel
utb = get(panel, 'Parent');

% Group from tab
utg = get(utb, 'Parent');

% Tree from group
uit = get(utg, 'UserData');

% EOF
