function [filematL,filematR] = tsFourier(obj,ax)
% TSFOURIER ESA Fourier Analysis Create graphs and attach callbacks

data = obj.DataPoints;
timedata = obj.TimePoints;

data = data(find(~isnan(data)));
timedata = timedata(find(~isnan(data)));

axes(ax{1}); cla; set(ax{1},'Tag','ESAAxesTop'); hold on; 
set(ax{1},'Userdata',{obj});

fs = 100;
wl = length(data);

f1 = 0.01;    % in hertz
f2 = 1;     % in hertz

omega = exp(-j*2*pi*(f2-f1)/(wl*fs));
a     = exp(j*2*pi*f1/fs);

fftdata = czt(data, wl, omega, a)';
fBin = (f2-f1)/wl;
freqdata = (f1:fBin:f2);


for i = 1:(length(fftdata)/2)
  x    = 10 * log10(abs(fftdata(i)));
  y    = freqdata(i);
  h(i) = plot(y,x,'r.');
  set(h(i),'ButtonDownFcn',@pt_use);
  % Put fftdata in somewhere
  set(h(i),'UserData',[i fftdata(i) freqdata(i)]);
end

axes(ax{2}); cla; set(ax{2},'Tag','ESAAxesBottom'); hold on;

for i = 1:length(data)
  x    = data(i);
  y    = freqdata(i);
  h2(i) = plot(y,x,'.');
end

filematL = [];
filematR = [];




function pt_use(src,evnt)
% use the point in the fft for calculating the appropriate points
set(src,'Color','r');

% Get stored fftdata
UserData = get(src,'UserData');

% Find the axis
ax{1} = findobj(get(get(src,'Parent'),'Parent'),'Tag','ESAAxesTop');
ax{2} = findobj(get(get(src,'Parent'),'Parent'),'Tag','ESAAxesBottom');

% Retrieve DAAFObj
DAAFObj = get(ax{1},'UserData');
DAAFObj = DAAFObj{1};

% Use Frequency data to highlight the appropriate peaks.
fs = 100;
childrenAx2 = flipud(get(ax{2},'Children'));

stepsize = 1/(UserData(3)) * fs;

rads = angle(UserData(2)) - pi/4 +pi/20;
dec =  rads / (2*pi);
startphase = stepsize * dec;

thechosen = floor([(startphase):stepsize:(length(childrenAx2))]');
if startphase < 0
  thechosen = thechosen(2:end);
end

% change plot choice
set(childrenAx2,'Color','b');
set(childrenAx2,'Marker','.');
set(childrenAx2(thechosen),'Color','r');
set(childrenAx2(thechosen),'Marker','o');


DAAFObj = highlight(DAAFObj,thechosen);
sound(DAAFObj);


% DAAFObj = xfade(DAAFObj);
% DAAFObj = concatenate(DAAFObj);


