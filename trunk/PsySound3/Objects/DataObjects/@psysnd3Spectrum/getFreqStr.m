function str = getFreqStr(obj)
% GETFREQSTR  Get frequenct string 

str = {};

freq = get(obj, 'Freq');
fMin = '';
fMax = '';


if isnumeric(freq(1))
if freq(1) == 0,
  fMin = 'DC';
else
  fMin = num2str(freq(1));
end

if freq(end) > 1000
  fMax = sprintf('%.3f k', freq(end)/1000);
else
  fMax = sprintf('%.0f', freq(end));
end
spc = sprintf('%.2f', freq(2)-freq(1));

else
    fMin = char(freq(1));
    fMax = char(freq(end));
    spc = 'not specified';
end




str{end+1} = sprintf('%s (%s):\n', obj.FreqName, obj.FreqUnit);
str{end+1} = sprintf([' Range : %s -> %s\n', ...
                    ' Spacing : %s\n'], ...
                     fMin, fMax, spc);

str = [str{:}];
% EOF
