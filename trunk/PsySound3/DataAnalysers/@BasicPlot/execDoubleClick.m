function execDoubleClick(obj, panel)
% EXECDOUBLECLICK  This is the double-click method
%

graphButt = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'GraphButton');

% Insta-plot!
Graph(obj, graphButt);

% EOF
