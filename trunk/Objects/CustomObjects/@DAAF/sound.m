function obj = sound(obj,varargin)
% SOUND method for DAAF Object
if nargin == 1 
  sound(obj.OutputAudio ,obj.FS);
end

if nargin == 2 
  % if there's two then the second is a cell array to be concatenated.
  objArr =  varargin{1};
  audio = [];
  for i = 1:length(objArr)
    audio = [audio; zeros(obj.FS*0.5,1)]; 
    audio = [audio; objArr{i}.OutputAudio];
  end
  sound(audio./(max(abs(audio))*1.1) ,obj.FS);
end
% EOF
