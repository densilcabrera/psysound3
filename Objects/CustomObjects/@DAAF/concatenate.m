function obj = concatenate(obj,varargin)
% CONCATENATE Frames of DAAF Object and place in OutputAudio
%

[r,c] = size(obj.OutputFrames);
isstereo = min([r c]) - 1;
if r<c
  obj.OutputFrames = obj.OutputFrames';
end  

if isempty(obj.OutputFrames)
  obj.OutputFrames(r,1:c) = {};
end


try
  if isstereo
    % Stereo
    obj.OutputAudio(:,1:2) = [obj.OutputFrames{1,1} obj.OutputFrames{1,2}];
    for i = 2:r
      obj.OutputAudio = [obj.OutputAudio; [obj.OutputFrames{i,1} obj.OutputFrames{i,2}]];
    end
  else
    % Mono
    % Create Matrix (faster)
    frames = cell2mat(obj.OutputFrames);
    obj.OutputAudio = reshape(frames,[],1);
  end

catch

  isstereo = min([r c]) - 1;
  if isstereo
    % Stereo
    obj.OutputAudio(:,1:2) = [obj.OutputFrames{1,1} obj.OutputFrames{1,2}];
    for i = 2:c
      obj.OutputAudio = [obj.OutputAudio; [obj.OutputFrames{i,1} obj.OutputFrames{i,2}]];
    end
  else
    % Mono
    obj.OutputAudio = obj.OutputFrames{1};
    for i = 2:c
      obj.OutputAudio = [obj.OutputAudio; obj.OutputFrames{i}];
    end
  end
end



  