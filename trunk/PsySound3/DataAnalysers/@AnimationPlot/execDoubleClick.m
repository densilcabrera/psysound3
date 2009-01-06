function execDoubleClick(obj, panel)
% EXECDOUBLECLICK  This is the double-click method
%

buttH = findobj(panel, 'Style', 'Pushbutton', 'Tag', 'MovieButton');

% Insta-plot!
Movie(obj, buttH);

% EOF
