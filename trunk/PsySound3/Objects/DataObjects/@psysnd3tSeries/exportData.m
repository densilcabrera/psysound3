function exportData(obj, fid, delim, varargin)
% EXPORTDATA  Writes to file id

short = false;
if ~isempty(varargin)
  short = varargin{1};
end

% Write Header
% Name
fprintf(fid, '%s\n', obj.tsObj.Name);
fprintf(fid, '\n');

% Some info
len = length(obj.tsObj.data);
fprintf(fid, 'Samples : %d\n', len);
fprintf(fid, '\n');

% Write Time and Data header
fprintf(fid, ['Time', delim, 'Data (', getDataUnit(obj), ')\n']);

% Write Time and Data Values
% NOTE: fprintf runs columnwise, hence the need for transpose
str = ['%f', delim, '%f\n'];
if short
  dlen = len;
  if dlen > 10
    dlen = 10;
  end
  fprintf(fid, str, [obj.tsObj.time(1:dlen), obj.tsObj.data(1:dlen)]');
  fprintf(fid, '...\n');
else
  fprintf(fid, str, [obj.tsObj.time, obj.tsObj.data]');
end


% end exportData
