function obj = intersect(obj,obj2)
% INTERSECT Intersect Frames of DAAF Object Frame by Frame


% Errorcheck Timesteps
if obj.Increment - obj2.Increment  < 0.00001
	% Timesteps from each dataObject are identical
  windowLength = floor(timestep(1) * nodeObj{1}.AnalyserObj.fs); % Get WindowLength
	if mod(windowLength,2)>0
	  windowLength = windowLength - 1;
	end
	timestep = timestep(1);
else
	% timesteps are not identical
	errordlg('The timesteps for the two data objects are different.');
	return;
end	

% They should both be from the same file
if ~strcmp(obj.AudioFilename,obj2.AudioFilename) 
	errordlg('These data objects aren''t from the same file.');
	return;
end

% Are the lengths the same? 
if length(obj.DataPoints) == length(obj2.DataPoints)
	lengthsSame = 1;
	return
else
	lengthsSame = 0;
end

if obj.TimePoints(1) == obj2.TimePoints(1)
	startSame = 1;
else
	startSame = 0;
end

if ~lengthSame & startSame 
	% find a starting Time
	startTime = obj.TimePoints(1);
elseif ~lengthSame & ~startSame 
	if obj.TimePoints(1)<obj2.TimePoints(1)
		startTime = obj.TimePoints(1);
	elseif obj.TimePoints(1) > obj2.TimePoints(1)
		startTime = obj2.TimePoints(1);
	end
end

if ~lengthSame  
	if obj.TimePoints(end) < obj2.TimePoints(end)
		endTime = obj.TimePoints(end);
	elseif obj.TimePoints(end) > obj2.TimePoints(end)
		endTime = obj2.TimePoints(end);
	end
end

time = startTime;
i = 1;
while time < endTime
	if obj.TimePoints(i) < (time + obj.Increment/2)  && obj.TimePoints(i) > (time - obj.Increment/2) 
	
	
	time = time + Increment;
end