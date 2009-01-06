function exportData(obj, fid, delim, varargin)
% EXPORTDATA  Generic function to export data to the given
%             fid. This is just a simple loop around the exportData
%             methods of the underlying data objects

short = false;
if ~isempty(varargin)
  short = varargin{1};
end

% Generic header
exportGenericHeader(obj, fid);

% Get outputs
outputs = get(obj, 'output');

for i=1:length(outputs)
  exportData(outputs{i}, fid, delim, short);
  
  % Blank line in between each
  fprintf(fid, '\n');
end

% EOF

