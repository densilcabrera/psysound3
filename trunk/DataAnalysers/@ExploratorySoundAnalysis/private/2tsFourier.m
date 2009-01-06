function [filematL,filematR] = tsFourier(dataObj,filemat,ax,concatType)
% Create the graphs and attach callbacks

data = dataObj.DataObj.data;
timedata = dataObj.DataObj.time;

axes(ax{1});
cla;
set(ax{1},'Tag','ESAAxesTop');
hold on; 

fftdata   = fft(data);
freqdata  = 1:length(fftdata);  
for i = 1:(length(fftdata)/2)
  x    = 10 * log10(abs(fftdata(i)));
  y    = freqdata(i);
  h(i) = plot(y,x,'r.');
  set(h(i),'ButtonDownFcn',@pt_use);
  % Put fftdata in somewhere
  set(h(i),'UserData',[i fftdata(i)]);
end

axes(ax{2});
cla;
set(ax{2},'Tag','ESAAxesBottom');
hold on;
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

% Use Frequency data to highlight the appropriate peaks.

childrenAx2 = get(ax{2},'Children');
UserData(1)
set(childrenAx2([1 5 10 110]),'Color','r');

% Dump in handle. 