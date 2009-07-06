function out = getAnalyserSettingsString(obj)
% GETANALYSERSETTINGSSTRING  Returns a string for display purposes
%                            of the analyser settings

out = {};

str{1} = ['Weighting(s) : ', obj.wChoices(1)];
for i=2:length(obj.wChoices)
  if i < length(obj.wChoices)
    str{1} = [str{1}, ', ', obj.wChoices(i)]; 
  else
    str{1} = [str{1}, ' & ', obj.wChoices(i)]; 
  end
end

% line feed
str{2} = sprintf('\nIntegration time(s): ');

if ischar(obj.iChoices)
	for i = 1:length(obj.iChoices)
	 iChoices(i) = {obj.iChoices(i)};
	end
end


strInt = [];
for i = 1:length(iChoices)
  if i > 1  
    strInt = [strInt ', '];
  end
  
  switch char(iChoices{i})
    case 'f'
      strInt = [strInt  'Fast'];
    case 's'
      strInt = [strInt  'Slow'];
    case 'i'
      strInt = [strInt 'Imp'];
    case 'p'
      strInt = [strInt 'Peak'];
    otherwise
      strInt = [strInt str2num(iChoices{i})]; % This has not been tested
  end
end
str{3} = strInt;
% assign output
out = [str{:}];
