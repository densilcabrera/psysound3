function obj = stats(obj,varargin)
% STATS Finds the frames corresponding to the stats in the stats objects. 
% Gets them and then sticks them in the statsFrames fields.

% Indexes in order
[sortedData,orders] = sort(obj.DataPoints);            

% Get names from stats object 
names = fields(obj.Stats);
names = {'median','mean','min','max'};

notNaNs = find(~isnan(sortedData)); % Dump NaNs 
sortedData = sortedData(notNaNs);
orders = orders(notNaNs);

for i = 1:length(names)
  index = find(sortedData >= obj.Stats.(names{i}),1,'first');
  switch (names{i})
    case 'mean'
      origIndex = orders((index-5):(index+5));
      obj.StatFrames.(char(names(i))) = origIndex;
    case 'median'
      origIndex = orders((index-5):(index+5));
      obj.StatFrames.(char(names(i))) = origIndex;
    case 'max'
      origIndex = orders((index-10):index);
      obj.StatFrames.(char(names(i))) = origIndex;
    case 'min'
      origIndex = orders(index:(index+10));
      obj.StatFrames.(char(names(i))) = origIndex;
    end
end

for i = 1:99
  index = find(sortedData >= obj.Stats.percentiles(i),1,'first');
  try
    obj.StatFrames.percentiles{i} = orders((index-5):(index+5));
  catch
    try
      obj.StatFrames.percentiles{i} = orders((index-2):(index+2));
      disp('chose 2');
    catch
      obj.StatFrames.percentiles{i} = orders(index);
      disp('only 1');
    end
  end
end