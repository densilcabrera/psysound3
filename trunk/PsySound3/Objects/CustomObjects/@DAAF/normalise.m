function obj = normalise(obj, varargin)
% NORMALISE Frames of DAAF Object Frame by Frame
%

for i = 1:length(obj.Frames)
	obj.Frames{i} = obj.Frames{i} ./ max(abs(obj.Frames{i}));
end