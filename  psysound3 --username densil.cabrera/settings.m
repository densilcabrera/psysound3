function [obj, fH] = settings(obj, fH)

% First call the base class's settings method for any defaults
[obj, fH] = settings(obj.Analyser, fH, obj);



h   = findobj('Tag', 'LoudnessMGBFilterType', 'Style', 'popupmenu');
FilterMethodMenu = get(h, 'Value');

switch FilterMethodMenu
    case 1
        FilterMethod = 1;
    case 2
        FilterMethod = 2;
    case 3
        FilterMethod = 3;
    case 4
        FilterMethod = 4;
end


obj.filterMethod = FilterMethod;

% EOF
