function exportData(obj, fid, delim, varargin)
% EXPORTDATA  RLB exportData method that all the data columns next
%             to each other

short = false;
if ~isempty(varargin)
  short = varargin{1};
end

% Generic header
exportGenericHeader(obj, fid);

% Get outputs
outputs = get(obj, 'output');

fmtHeadStr = ['%s', delim];
fmtDataStr = ['%f', delim];

if short
  data = {outputs{1}.time(1:10)};
else
  data = {outputs{1}.time};
end
head = {'Time'};
for i=1:length(outputs)
  % Build the format strings
  fmtDataStr = strcat(fmtDataStr, ['%f', delim]);
  if short
    data{end+1} = outputs{i}.data(1:10);
  else
    data{end+1} = outputs{i}.data;
  end
  
  fmtHeadStr = strcat(fmtHeadStr, ['%s', delim]);
  head{end+1} = outputs{i}.name;
end

% Add new lines
fmtDataStr = strcat(fmtDataStr, '\n');
fmtHeadStr = strcat(fmtHeadStr, '\n');

% Convert to a matrix
data = cell2mat(data)'; % transpose

% Write data name/units
fprintf(fid, [delim, 'Level (%s)\n'], outputs{1}.DataInfo.Unit);

% Write header
fprintf(fid, fmtHeadStr, head{:});

% Write data
fprintf(fid, fmtDataStr, data);

if short
  fprintf(fid, '...');
end

% blank line
fprintf(fid, '\n');

% EOF

