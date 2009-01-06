function obj = boxplot(obj,varargin)

decChoice = 1;
obj = displayStats(obj,1,decChoice);
obj = displayStats(obj,25,decChoice);
obj = displayStats(obj,'median',decChoice);
obj = displayStats(obj,75,decChoice);
obj = displayStats(obj,99,decChoice);



% if length(obj.Frames) < 1000
%   disp(['Number of Frames: ' num2str(length(obj.Frames))]);
% end
% 
% % Organise data
% [dataSorted,indexs]     = sort(obj.DataPoints);
% nanIndex = find(isnan(dataSorted),1,'first');
% if ~isempty(nanIndex)
%  indexs =   indexs(1:nanIndex-1); 
%  dataSorted = obj.DataPoints(indexs);
% end
% 
% frames = obj.Frames(indexs);
% % The getting of the numbers
% numbers         = [min(dataSorted); percentile(dataSorted,25); median(dataSorted);  percentile(dataSorted,75); max(dataSorted)]'; % Calculate various numbers
% fiveNum(1:10)   = find(dataSorted >= numbers(1),10,'first');                         % Find windows
% fiveNum(11:20)  = find(dataSorted > numbers(2) & dataSorted < numbers(3),10,'first');                         % Find windows
% fiveNum(21:30)  = find(dataSorted > numbers(3) & dataSorted < numbers(4),10,'first');                         % Find windows
% fiveNum(31:40)  = find(dataSorted > numbers(4) & dataSorted < numbers(5),10,'first');                         % Find windows
% fiveNum(41:50)  = find(dataSorted <= numbers(5),10,'last');                         % Find windows
% 
% % Randomise
% minGrains       = frames(fiveNum(1:10));
% minGrains       = minGrains(ceil(rand(50,1)*10));
% 
% p25Grains       = frames(fiveNum(11:20));
% p25Grains       = p25Grains(ceil(rand(50,1)*10));
% 
% medianGrains    = frames(fiveNum(21:30));
% medianGrains    = medianGrains(ceil(rand(50,1)*10));
% 
% p75Grains       = frames(fiveNum(31:40));
% p75Grains       = p75Grains(ceil(rand(50,1)*10));
% 
% maxGrains       = frames(fiveNum(41:50));
% maxGrains       = maxGrains(ceil(rand(50,1)*10));
% 
% % Reshape frames
% obj.OutputFrames= [minGrains'; p25Grains'; medianGrains'; p75Grains'; maxGrains'];

% 
% if nargin > 1
%   ax = varargin{1};
%   if nargin > 2
%     reprType = varargin{2};
%   else
%     reprType = 'Graph';
%   end
%   switch reprType
%     case 'Graph'
%       axes(ax{1});
%       tag = get(ax{1},'Tag');
%       h = plot(obj.TimePoints,obj.DataPoints);
%       title('Original Timeseries Data');
%       xlabel('Time (s)');
%       ylabel([obj.Name ' (' obj.Units.Unit ')']);
%       set(get(h,'Parent'),'Tag',tag);
% 
% 
%      axes(ax{2});
%      tag = get(ax{2},'Tag');
%      boxplot(obj.DataPoints);
%      set(ax{2},'XTickLabel',{'Minimum','75th Percentile','Median','25th Percentile','Maximum'});
%      ylabel([obj.Name ' (' obj.Units.Unit ')']);
%      set(ax{2},'Tag',tag);
%   end
% end
% 
% 
% 




