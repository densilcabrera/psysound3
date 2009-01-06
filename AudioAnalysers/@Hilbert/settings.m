function [obj, fH] = settings(obj, fH)
% SETTINGS  method for Hilbert.

h = findobj('Style', 'popup', 'Tag', 'HilbertWeightingType');

wStr = get(h, 'String');
val  = get(h, 'Value');
obj  = setPreFilterWeighting(obj, wStr{val});

% EOF
