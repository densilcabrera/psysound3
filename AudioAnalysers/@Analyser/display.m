function display(obj)
% DISPLAY  Lists the fields of this object

% Print the name
fprintf('\n%s Object\n\n', class(obj));

% Name
fprintf('  Name\t\t : %s\n', obj.Name);

% filename
fprintf('  filename\t : ''%s''\n', obj.filename);

% fs
fprintf('  fs\t\t : %d samples/sec\n', obj.fs);

% bits
fprintf('  bits\t\t : %d\n', obj.bits);

% samples 
fprintf('  samples\t : %d\n', obj.samples);

% duration
if obj.fs > 0
  fprintf('  duration\t : %.2f sec(s)\n', obj.samples/obj.fs);
else
  fprintf('  duration\t : -\n');
end

% channels
fprintf('  channels\t : %d\n', obj.channels);

% windowLength
fprintf('  windowLength\t : %d\n', obj.windowLength);

% overlap
fprintf('  overlap\t : %d %s\n', obj.overlap.size, obj.overlap.type);

% Windowing functions
fprintf('  windowFunc\t : ''%s''\n', obj.windowFunc);

% data rate
fprintf('  outputDataRate : %2.2f Hz\n', obj.outputDataRate);

% data num samples
fprintf('  outputSamples  : %d\n', obj.outputSamples);

% output
out = obj.output;
if ~isempty(out)
  for i = 1:length(out)
    if i == 1
      str = 'output';
    else
      str = '';
    end
    
    o = out{i};
    sz = getSize(o);
    cl = class(o);
    nm = get(o, 'Name');
    
    if length(sz) == 2
      fprintf('  %-11s\t : [%dx%d] %s (%s)\n', str, sz(1), sz(2), ...
              cl, nm);
    else
      fprintf('  %-11s\t : [%dx%dx%d] %s (%s)\n', str, sz(1), sz(2), ...
              sz(3), cl, nm);
    end
  end
else
  fprintf('  %-11s\t : not available\n', 'output');
end
 
% Additional subclass specific fields
if ~strcmp(class(obj), 'Analyser')
  % There are additional fields so display them as well
  fprintf('\n Subclass fields\n\n');
  displaySubclassFields(obj);
end 
fprintf('\n');

%
% Subfunction to display additional subclass fields
% Recurses over class hierarchy
%
function displaySubclassFields(obj)
fnames = fieldnames(obj);
for i=1:length(fnames);
  fname = fnames{i};    % Even though it shows up obj.(fname)
                        % does not work ???
  
  % Skip Analyser
  if strcmp(fname, 'Analyser')
    continue;
  end
  
  % Get the value
  str = ['get', fname, '(obj)'];

  if ismethod(obj, str(1:end-5))
    val = eval(str);
  else
    continue;
  end
  
  if isnumeric(val)
    if isscalar(val)
      fprintf('  %s\t: %d\n', fname, val);
    else
      % Assume vector
      fmtstr = repmat('%d ', 1, length(val));
      fmtstr(end) = ']';
      fprintf(['  %s\t: [', fmtstr, '\n'], fname, val);
    end
  elseif isa(val, 'function_handle')
    fprintf('  %s\t: %s\n', fname, func2str(val));
  elseif iscell(val)
    for i = 1:length(val)
      fprintf('  %s (%i) \t: %s\n', fname, i, val{i});
    end
  elseif isobject(val)
    % Recurse if object
    displaySubclassFields(val);
  else
    fprintf('  %s\t: %s\n', fname, val);
  end
end
