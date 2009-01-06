function obj = displayStats(obj,name,duration);
% get StatFrames and dump them into OutputFrames

% get the frame
frames = obj.StatFrames.(name);
frNeeded = duration / ( length(frames{1}) / obj.FS) ;
for l = 1:frNeeded
  obj.OutputFrames(l) = obj.Frames(frames(ceil(rand * length(frames))));
end 