function obj = tsPeakAnalysis(obj,concatType,ax)
% Find peaks and choose frames

% Strip out NaN data
nanData = isnan(obj.DataPoints);

% Difference
Ddata = diff(obj.DataPoints) + eps; % No zeroes

% Keep same length as original
Ddata(end+1) = Ddata(end);

% Get peaks, troughs and neither
peaks    = [0; (Ddata(1:end-1) > 0 & Ddata(2:end) < 0)];
troughs = [0; (Ddata(1:end-1) < 0 & Ddata(2:end) > 0) ]; 
neither  = [(peaks+troughs) == 0];

switch concatType
  
  case 'Stereo'
	  for i = 1:length(peaks)
    	obj.OutputFrames{i,1} = peaks(i)   * obj.Frames{i};
     	obj.OutputFrames{i,2} = troughs(i) * obj.Frames{i};
    end

  case 'Peaks'
		for i = 1:length(peaks)
    	obj.OutputFrames{i}= peaks(i)   * obj.Frames{i};
    end
  case 'Troughs'
    for i = 1:length(troughs)
    	obj.OutputFrames{i}= troughs(i)   * obj.Frames{i};
    end
  case 'PeaksOnly'
   	obj.OutputFrames = obj.Frames(find(peaks));
  case 'TroughsOnly'
   	obj.OutputFrames = obj.Frames(find(troughs));
  case 'StereoOnly'
   	p = obj.Frames(find(peaks));
   	t = obj.Frames(find(troughs));
    if length(p) > length(t)
      p = p(1:end-1);
    elseif length(p) < length(t)
      t = t(1:end-1);
    end
    obj.OutputFrames = [p' t'];

  otherwise
    disp('Unknown Concatenation Type');
end


% Top Axes
axes(ax{1});

plot(obj.TimePoints,obj.DataPoints);
hold on; 
% Draw data
for i = 1:length(obj.DataPoints)
  if peaks(i)
    ptColour = 'r';
    % Points
  x    = obj.DataPoints(i);
  y    = obj.TimePoints(i);
  h(i) = plot(y,x,[ptColour '.']);
  elseif	troughs(i)
    ptColour = 'g';
  % Points
  x    = obj.DataPoints(i);
  y    = obj.TimePoints(i);
  h(i) = plot(y,x,[ptColour '.']);
  else
    ptColour = 'k';
  end  


  % Callbacks and data
  %set(h(i),'ButtonDownFcn',@pt_use);  
  %set(h(i),'UserData',[i data(i)]);
end

set(ax{1},'Tag','ESAAxesTop');
 
% axes(ax{2});
% cla;
% set(ax{2},'Tag','ESAAxesBottom');
% hold on;
% 
% left = [];
% % make a square with top left at peak, and bottom right at trough
% for i = 1:length(data)
%   if 1 == peaks(i)
%    top = data(i);
%    left = timedata(i);
%   end
%   
%   if 1 == troughs(i) && ~isempty(left)
%     bottom = data(i);
%     right = timedata(i);
%     
%     % render 
%     patch([left left right right],[bottom top top bottom],[0.9 0.9 0.9]);
%     % put grey box around each.
%    
%     % get the median
%     %medianPt = median(data(top:bottom));
%   end
% end

