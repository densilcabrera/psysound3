function obj = hist(obj, decimation, varargin)
% Make histogram sonification


% Sort Data
[sortedData, orders] = sort(obj.DataPoints);

% Deduce Boundaries
range = max(sortedData) - min(sortedData);
boundaries = [min(sortedData):(range/10):max(sortedData)]';
boundaries = [boundaries(1:end-1) boundaries(2:end) ];

if nargin > 2
  if isnumeric(varargin{1})
		boundaries = varargin{1};
	else
		ax = varargin{1};
	end
end

if nargin > 3
  boundaries = varargin{2};
end

% Let's not count the silence in the decimation total length
frNum = decimation * obj.FS / obj.WindowLength;
decFac = length(sortedData) / frNum;
decInd = floor([1:decFac:length(sortedData)]');

sortedData   = sortedData(decInd);
orders       = orders(decInd);
frames       = obj.Frames(decInd);
frLength     = length(obj.Frames{1});         
silence      = zeros(frLength,1); 

% Which DataPoints fall into each bin
for i = 1:(length(boundaries))
	bin{i} = find(sortedData > boundaries(i,1) & sortedData < boundaries(i,2) );

  frame = orders(bin{i});
  offset = length(frame);
  obj.OutputFrames((end+1):(end+offset)) = obj.Frames(frame);
  for j = 1:25
    obj.OutputFrames(end+1) = {silence};
  end
end

% Graphing
if nargin>2
	for i = 1:length(bin) 
    eachBin(i) = length(bin{i});
  end
  binTime = obj.Increment * decFac;
  eachBin = eachBin * binTime;
  axes(ax{1});
  tag = get(ax{1},'Tag');
  plot(obj.DataObject.DataObj)
  set(ax{1},'Tag',tag);

  axes(ax{2});
  tag = get(ax{2},'Tag');
  bar(eachBin);
  set(ax{2},'Tag',tag);
  set(ax{2},'XTickLabel',round(boundaries(1:10,2)*100)/100);
  set(ax{2},'XLim',[0 11]);
  ylabel('Time (seconds)');
  xlabel(['Top of Bin - ' obj.Name ' (' obj.Units.Unit ')']);

end

