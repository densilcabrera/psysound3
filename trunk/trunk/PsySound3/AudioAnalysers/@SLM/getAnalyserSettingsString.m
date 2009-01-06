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

switch obj.iChoices
 case 'f'
  str{3} = 'fast';
 case 's'
  str{3} = 'slow';
 case {'fs' 'sf'}
  str{3} = 'fast & slow';
 otherwise
  % do nothing
  str{3} = '';
end

% assign output
out = [str{:}];
