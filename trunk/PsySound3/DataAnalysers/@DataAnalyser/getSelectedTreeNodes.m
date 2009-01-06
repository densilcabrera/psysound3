function [nodes, uit] = getSelectedTreeNodes(obj, panel)
% GETSELECTEDTREENODES  Returns the selected nodes in the tree

uit   = getTree(obj, panel);
nodes = get(uit, 'SelectedNodes');

% EOF
