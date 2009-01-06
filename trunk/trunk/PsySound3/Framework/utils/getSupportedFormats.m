function fmtStr = getSupportedFormats
% GETSUPPORTEDFORMATS  Get supported file types of SOX
%    FMTSTR = GETSUPPORTEDFORMATS
%
% Primarily used by READDATA for file import
%

soxPath = getFullPathToSox;

% Get the help text
[s, w] = system([soxPath ' -h']);

formatStr = 'Supported file formats: ';
startIndex = regexp(w, formatStr);
startIndex = startIndex + length(formatStr);
fmts = w(startIndex:end);

newLns = regexp(fmts,'\n');
fmts   = fmts(1:newLns(1));
spaces = regexp(fmts,' ');
spaces = [0 spaces];

for j=1:length(spaces)-1
    retFmts{j} = fmts(spaces(j)+1:spaces(j+1)-1);
    % MAC reports aiff with aif extension
    if strcmp(retFmts{j}, 'aiff')
      retFmts{j} = 'aif*';
    end
end

fmtStr = {};

for j=1:length(retFmts)
  %fmtStr = [fmtStr '*.' retFmts{j} ';'];
  fmtStr{j, 1} = ['*.', retFmts{j}];
  fmtStr{j, 2} = ['All ', retFmts{j}, ' files'];
end

% end getSupportedFormats
% EOF
