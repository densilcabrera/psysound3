function obj = displayStats(obj,name,duration,plotflag,ax)
% get StatFrames and dump them into OutputFrames

if strcmp(class(name),'double') % this is a number because its a reference to percentiles.
  frames = obj.StatFrames.percentiles{name};
  frNeeded = duration / ( length(obj.Frames{frames(1)}) / obj.FS) ;
  for l = 1:frNeeded
    obj.OutputFrames = [obj.OutputFrames; obj.Frames(frames(ceil(rand * length(frames))))];
  end
  return;
end
  
% get the frame
frames = obj.StatFrames.(name);
frNeeded = duration / ( length(obj.Frames{frames(1)}) / obj.FS) ;
for l = 1:frNeeded
  obj.OutputFrames = [obj.OutputFrames; obj.Frames(frames(ceil(rand * length(frames))))];
end 
if exist('plotflag')
  %plot(obj,ax,frames,name);
  %set(gcf,'Renderer','OpenGL');
end
