function obj = plot(obj, ax, varargin)
% PLOT plot the data and the audio with frame boundaries.

if nargin>1
	if length(varargin{1})==2
		tstart = varargin{1}(1);
		tend = varargin{1}(2);
	elseif length(varargin{1})>2
  	tstart = 0;
  	tend = length(obj.AudioData)/obj.FS;
		chosenFr = varargin{1};
		reprChoice = varargin{2};

	end	
end

axes(ax{1});
timeaxis = [tstart:(1/obj.FS):tend]';
timeaxis = timeaxis(1:end-1);
plot(timeaxis,obj.AudioData,'g');
hold on
for i = 1:length(obj.FrameSamples)
	if sum(i == chosenFr) > 0
		st = (obj.FrameSamples(i,1) - obj.WindowLength/2) / obj.FS ; 
		ed = (obj.FrameSamples(i,2) - obj.WindowLength/2) / obj.FS ;
		x = [st; st; ed; ed];
		y = [1; -1; -1; 1]; 
    patch(x,y,'r');
		alpha(.5);
    set(gcf,'Renderer','painters');
	end
	%plot([obj.FrameSamples(i,1)/obj.FS obj.FrameSamples(i,1)/obj.FS], [1 -1],'k');
end 
axis([tstart tend -1 1]);
ylabel('Amplitude');
title('Audio Waveform');


axes(ax{2});
plot(obj.TimePoints,obj.DataPoints,'.g');
hold on;
plot(obj.TimePoints(chosenFr),obj.DataPoints(chosenFr),'or');
plot(obj.TimePoints,repmat(obj.Stats.(reprChoice),length(obj.TimePoints),1));
reprChoice(1) = upper(reprChoice(1));
title({[reprChoice ': '  num2str(obj.Stats.(lower(reprChoice)))]});
limits = axis; axis([0 max(obj.TimePoints) limits(3) limits(4)]);
xlabel('Time (s)')
ylabel([obj.Name ' (' obj.Units.Units ')'])

ax2(1) = ax{1};
ax2(2) = ax{2};
set(ax{1},'Tag','ESAAxesTop');
set(ax{2},'Tag','ESAAxesBottom');

%linkaxes(ax2,'x');
%zoom xon;