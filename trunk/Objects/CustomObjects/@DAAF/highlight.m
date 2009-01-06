function obj = highlight(obj, frames)
% HIGHLIGHT Create a gain function to highlight particular frames

% How long are the frames, overlap length
fLength     = obj.WindowLength / obj.FS ;
fLengthSmpl = obj.WindowLength;

% Create a surrounding grain made up of a 
% short ramp to start and lingering tail. 
wind = hanning(fLengthSmpl / 2);

% Ramp up is one quarter the frame length. 
% Plateau is two times frame length
% Ramp down is one quarter frame length
grain = [wind(1:end/2); ones(fLengthSmpl,1); ones(fLengthSmpl,1); wind(end/2+1:end)];
grLength = length(grain);

% start should therefore be one quarter frame length in front
% plus half a frame as times are at centre
tOffset = fLength / 4  * 3;
% Find centres of chosen frames
gTimes = obj.TimePoints(frames);
% grain start points 
gTimes = gTimes - tOffset;
% grain starts in samples
gTimesSmpl = floor(gTimes * obj.FS);

% Are any negative? 
posIndexs = find(gTimesSmpl > 0);
gTimesSmpl = gTimesSmpl(posIndexs);

% Are any beyond the end of the gain function
realIndexs = find(~(gTimesSmpl > (length(obj.AudioData) - grLength)));
gTimesSmpl = gTimesSmpl(realIndexs);

% Create empty gain function. 
gFunc = zeros(length(obj.AudioData),1);
% Place start of grain function at appropriate sample index
for i = 1:length(gTimesSmpl)
  gFunc(gTimesSmpl(i):gTimesSmpl(i)+grLength-1) = grain;
end

%%%%%%%%%%%%%%%%%%%%%%
% Apply to Input Audio
audio = gFunc .* obj.AudioData;
% Dump in output
obj.OutputAudio = audio;