function [Rseries, correction, data2fl, rlPivot] = regress(obj, obj2, varargin)
% Make regression sonification from 2 timeseries
%
% We will create a parameter R representing error for the regression.
% Therefore, by doing a density, or a CDF, using the R value as a threshold
% we get a 2D regression. 

%%%%%%%%%%%%%%%%%%
% Input Checking %
%%%%%%%%%%%%%%%%%%

% Are they the same length? If they are different lengths, 
% are they different by one then shorten.
if  (abs(length(obj.DataPoints) - length(obj2.DataPoints)) > 2)
		error('The objects are not the same length')
elseif (abs(length(obj.DataPoints) - length(obj2.DataPoints)) == 1)
	disp('The objects are out by one. We''ll shorten one.');
end

% Delete NaN results from data1, data2, and audio frames.
indexs1    = find(~isnan(obj.DataPoints));
indexs2    = find(~isnan(obj2.DataPoints));
indexs     = intersect(indexs1,indexs2);
data1      = obj.DataPoints(indexs);
data2      = obj2.DataPoints(indexs);
frames     = obj.Frames(indexs);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simple Linear Regression %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

V = [data1 ones(size(data1)) ];     
c = V\data2;         % Backslash operator for matrix division               

% Evaluate within data1 domain
regrValue = c(1) * data1 + c(2);    

% Find the errors
R         = data2 - regrValue;

figure; subplot(1,2,1);plot(data1,data2,'g.'); 
xlabel(obj.Name); ylabel(obj2.Name); hold on; plot(data1,regrValue,'k'); 

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Return various objects %
%%%%%%%%%%%%%%%%%%%%%%%%%%

Rseries           = NaN(length(obj.DataPoints),1);
Rseries(indexs)   = R; % Fill indexs with error data.
rlPivot           = median(data2);

if nargin > 2, rlPivot = varargin{1}; end;

correction        = rlPivot - (c(1) * data1 + c(2)); % calculate correction at each xaxis point
corSeries         = NaN(length(obj.DataPoints),1);
corSeries(indexs) = correction;

data2fl           = data2 + correction; % add correction to data2 to flatten
d2flSeries        = NaN(length(obj.DataPoints),1);
d2flSeries(indexs)= data2fl;

% Old code below.

% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Select frames based on regression %
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% % get the min and max of the primary parameter
% minData      = min(data1);
% maxData      = max(data1);
% numFrames = 500;  % How many frames to use
% binsize = (maxData - minData) / numFrames;
% 
% 
% i = 1;
% % Evaluate in steps
% for step = [minData:binsize:maxData]
%   % Get indexs of numbers in this chunk
%   Slice = find(step < data1 & data1 < (step + binsize));
%   
%   % Look for smallest R
%   [junk,SliceIndex] = min(R(Slice));
%  
%   % This is the index from the subscripted indexs - 
%   % to find the real index corresponding to data 1 do
%   if ~isempty(Slice(SliceIndex)) && R(SliceIndex) < 100
%     StepIndex(i) = Slice(SliceIndex);
%   end
%   % Increment
%   i = i + 1;
% end
% 
% 
% for i = 1:length(StepIndex)
%   if ~isempty(StepIndex(i)) 
%     if StepIndex(i) > 0
%       obj.OutputFrames(i) = frames(StepIndex(i));
%       plot(data1(StepIndex(i)),data2(StepIndex(i)),'r.')
%       drawnow;
%   else
%       obj.OutputFrames(i) = {zeros(obj.WindowLength,1)};
%     end
%   end
% end
% StepIndex = StepIndex(find(StepIndex>0));
% 
% 
% plot(data1(StepIndex),data2(StepIndex),'r.')
% 
% if nargin > 2
%   % Regression to be flattened. 
%   rlPivot = varargin{1}; %This is the numnber to pivot around
%   hold on; 
%   plot(data1, correction + regrValue,'k');
%   plot(data1(StepIndex),data2fl(StepIndex),'r.');
% end
% % figure; plot(data2flattened,data1);
