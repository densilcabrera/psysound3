function obj = hist(obj, decimation, varargin)
% Make density sonification
%
% 1. get frames and associated datapoints
% 2. window frames
% 3. Choose a duration
% 4. Make a data range from max to min (threshold elsewhere)
% 5. Place in appropriate place on duration. 

decimation = 10;

% Sort Data
% Window Frames
for i = 1:length(obj.Frames)
	obj.Frames{i} = windowFunc(obj.Frames{i});
end

 
prompt={'Minimum','Maximum'};
name='Input for Peaks function';
numlines=1;
defaultanswer={num2str(min(obj.DataPoints)),num2str(max(obj.DataPoints))};
answer=inputdlg(prompt,name,numlines,defaultanswer);
mindata = str2num(answer{1});
maxdata = str2num(answer{2});

% Boundaries
range = maxdata - mindata;
       
% Make audio 
smplLength = obj.FS * decimation;
audio = zeros(smplLength + obj.WindowLength,1);

for i = 1:length(obj.DataPoints)
	% find smpl to put it in 
  normData(i) = (obj.DataPoints(i) - mindata)/range;
	smpl =  floor(smplLength *  normData(i)) + 2;
  if ~(isnan(smpl) || (smpl < 1) || (smpl > smplLength-obj.WindowLength))
    audio(smpl:smpl+obj.WindowLength-1) = audio(smpl:smpl+obj.WindowLength-1) + obj.Frames{i};
  end
end
obj.OutputAudio = audio;

%%%%%% something to window a single frame
function audio = windowFunc(audio)

wl 											= length(audio);
rLength 								= floor(wl/8);
if mod(rLength,2) 			== 1, rLength = rLength+1; end
rLength2                = rLength/2;
wFunc   								= hanning(rLength*2);
audio(1:rLength2) 			  = audio(1:rLength2)       .* wFunc(1:rLength2);
audio(end-rLength2:end)  = audio(end-rLength2:end) .* wFunc(end-rLength2:end);