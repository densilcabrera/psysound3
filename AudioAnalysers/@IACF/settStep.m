function obj = settStep(obj, val)
% SETTSTEP  Sets the window time step

obj.tStep = val;

% Fix up the window overlap
ovT = getIntTime(obj) - val;
obj = set(obj, 'overlap', struct('size', ovT, 'type', 's'));

% end setTStep
