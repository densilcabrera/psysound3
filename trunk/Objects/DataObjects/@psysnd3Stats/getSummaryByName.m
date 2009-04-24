function [propVal,propUnit] = getSummaryByName(obj, propName)
% getSummaryByName method for Stats
%
% pass the object and the Summary Name and the Summary Value and Unit will be returned 
SummariesWithName = 0;
len = length(obj.Summaries);
for i = 1:len
  if strcmp(obj.Summaries{i}.Name, propName)
    SummariesWithName = SummariesWithName + 1; % Increment
  	propVal = obj.Summaries{i}.Value;
  	propUnit = obj.Summaries{i}.Unit;
	end
end
   
if SummariesWithName > 1
	% If there is are multiple summaries with this name 
	% then return the problem but don't error.
  propVal = 'Multiple Summaries with this Name.';
	return;
elseif SummariesWithName < 1
	% If there is no summary with this name then error.
	error('No Summary with This Name');
end

% [EOF]
