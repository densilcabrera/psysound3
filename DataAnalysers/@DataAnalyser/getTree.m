function uit = getTree(obj, panel)
% GETTREE  Returns the uitree from the post-prop panel


% Group from panel
utg = get(panel, 'Parent');

% Popup from group
uipopup = get(get(utg, 'UserData'),'UserData');

uit  = uipopup.Tree;

% EOF
