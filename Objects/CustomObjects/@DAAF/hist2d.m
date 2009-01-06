function stemMatrix = stemLeafTwoD(filemat, data1, data2)
% Make stem and leaf sonification with 2 dimensions

% sort by main parameter 
[data1,indexs]     = sort(data1);
% sort second parameter based on main parameter - 
% they are now synchronised again
data2               = data2(indexs);

filemat             = filemat(:,indexs);

% NaNs will be thrown to the end
% Work out which has the largest number of NaNs and killemall
if length(find(~isnan(data1))) > length(find(~isnan(data2)))
  indexs    = find(~isnan(data1));
  data1      = data1(indexs);
  data2      = data2(indexs);
  filemat    = filemat(:,indexs);
else
  indexs    = find(~isnan(data2));
  data1      = data1(indexs);
  data2      = data2(indexs);
  filemat    = filemat(:,indexs);
end  

% get the min and max of the primary parameter
minData      = min(data1);
maxData      = max(data1);
% number of bins = 10
binsize      = (maxData - minData) / 10 ;

% Find slices
i=1;
for lowerlimit = [floor(minData):binsize:ceil(maxData)]
  Slice{i}   = find(lowerlimit < data1 & data1 < (lowerlimit+binsize));
  i          = i + 1;
end





[r,c]        = size(filemat);   %
stemMatrix   = zeros(r,1);      % initialise new matrix
for i = 1:length(Slice)
  if length(Slice{i}) > 1
    % Get the indexs we will work with
    indexs = Slice{i};
    % Get the corresponding indexs from data2 and sort them
    [junk,data2indexs] = sort(data2(indexs));
    % The resulting indexes are indexed from 1 due to the way sort works 
    % By sorting initial indexes we get the indexs related to the data. 
    indexs = indexs(data2indexs);
    % put a gap in between each set of bins and add the piece of filemat
    stemMatrix = [stemMatrix zeros(r,10) filemat(:,indexs)]; 
  else
    % Blank space
    stemMatrix = [stemMatrix zeros(r,10) zeros(r,10)]; 
  end
end

