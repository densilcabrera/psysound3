function obj = tsMedian(obj,windowSize)
% TSMEDIAN Median filter data


data = obj.DataPoints;
time = obj.TimePoints;

if mod(windowSize,2) == 0
  windowSize = windowSize + 1;
  disp('windowSize should be odd.');
end

padding =floor(windowSize/2);
% zero pad data
paddata = [zeros(padding,1); data; zeros(padding,1)];

for i = (padding+1):(length(data)+padding)
  % create data window
  dw = paddata((i-padding):(i+padding));

  % find median and index of median
  [sortdata, ind] = sort(dw);
  
  ind2 = sort(ind);
  % median is the middle point
  switch ceil(rand*5)
    case 1
      choice = ceil(length(ind)/2);
    case 2
      choice = floor(length(ind)/2);
    case 3
      choice = ceil(length(ind)/2)+1;
    case 4
      choice = floor(length(ind)/2)-1;
    case 5
      choice = ceil(length(ind)/2)+2;
  end

  index = ind2(choice);
  % index from data stream
  dataIndex(i) = i - (padding+1) + ind(choice); 
  
  % place in output
  filtdata(i) = sortdata(index);

end
filtdata  = filtdata(padding+1:end)' ;
dataIndex = dataIndex(padding+1:end)' -padding-1 ;
dataIndex = [dataIndex(1:end-1); length(dataIndex)]; %last one is the last one.
dataIndex(find(dataIndex<1)) = 1;
figure;
subplot(1,2,1);
plot(time,data,'b');
hold on;
plot(time,filtdata,'r.');
xlabel('Time');
subplot(1,2,2);
plot(time,time(dataIndex));
obj.OutputFrames = obj.Frames(dataIndex);