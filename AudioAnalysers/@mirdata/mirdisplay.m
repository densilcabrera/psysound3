function mirdisplay(d,varargin)

% DISPLAY  Lists the fields of this object
% Section 1 : related to the class Analyser 
% (Mir adapted for Psysound3)

% Print the name


fprintf('\n%s Object\n\n', class(d));

% Name
n=get(d,'Name');
fprintf('  Name\t\t : %s\n', n);

% filename
f=get(d,'filename');
fprintf('  filename\t : ''%s''\n', f);

% fs
fs=get(d,'fs');
fprintf('  fs\t\t : %d samples/sec\n', fs);

% bits
b=get(d,'bits');
fprintf('  bits\t\t : %d\n', b);

% samples 
sm=get(d,'samples');
fprintf('  samples\t : %d\n', sm);

% duration
if fs > 0
  fprintf('  duration\t : %.2f sec(s)\n', sm/fs);
else
  fprintf('  duration\t : -\n');
end

% channels
c=get(d,'channels');
fprintf('  channels\t : %d\n', c);

% windowLength
w=get(d,'windowLength');
fprintf('  windowLength\t : %d\n', w);

% overlap
o=get(d,'overlap');
fprintf('  overlap\t : %d %s\n', o.size, o.type);

% Windowing functions
wf=get(d,'windowFunc');
fprintf('  windowFunc\t : ''%s''\n', wf);

% data rate
od=get(d,'outputDataRate');
fprintf('  outputDataRate : %2.2f Hz\n', od);

% data num samples
os=get(d,'outputSamples');
fprintf('  outputSamples  : %d\n', os);

% output
out = get(d,'output');
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



% MIRDATA/DISPLAY display of a MIR data
% Section 2 : related to the class mirdata 

disp(' ');

v=get(d,'Data');
%  fprintf('  Data\t\t : ''%s''\n', v); cell
f=get(d,'Sampling');
%  fprintf('  sr\t\t : ''%s''\n', f); cell
n=get(d,'Name');
%  fprintf('  name\t\t : ''%s''\n', n); cell
l=get(d,'Label');
%  fprintf('  label\t : ''%s''\n', l); cell
p=get(d,'Pos');
%  fprintf('  Pos\t\t : ''%s''\n', p); cell
fp=get(d,'FramePos');
%  fprintf('  FramePos\t\t : ''%s''\n', fp); cell
% pp = d.peak.pos;
pp=get(d,'PeakPos');
%  fprintf('  Peak Pos\t\t : ''%s''\n', pp); cell
% pm = d.peak.mode;
pm=get(d,'PeakMode');
% fprintf('  PeakMode\t\t : ''%s''\n', pm); cell

ml=get(d,'MultiData');
fprintf('  MultiData\t : ''%s''\n', ml);

ld = length(v);

 
if isempty(d.attack)
    ap = cell(ld);
else
    ap = d.attack.pos;
end
if isempty(d.release)
    rp = cell(ld);
else
    rp = d.release.pos;
end
if isempty(d.track)
    tp = cell(ld);
    tv = cell(ld);
else
    tp = d.track.pos;
    tv = d.track.val;
end
if ld == 0
    disp('No data.');
else
    for i = 1:length(v)
        if nargin < 2
            va = inputname(1);
        else
            va = varargin{1};
        end
        if isempty(va)
            va = 'ans';
        end
        if length(v)>1
            va = [va,'(',num2str(i),')'];
        end
        if not(isempty(l)) && iscell(l) && not(isempty(l{i}))
            lab = ' with label ';
            if isnumeric(l{i})
                lab = [lab,num2str(l{i})];
            else
                lab = [lab,l{i}];
            end
        else
            lab = '';
        end
        disp([va,' is the ',d.title,' related to ',n{i},lab,...
            ', of sampling rate ',num2str(f{i}),' Hz.'])
        if size(v{i},2) == 0
            if isempty(d.init)
                disp('It does not contain any data.');
            else
                disp('It has not been loaded yet.');
            end
        else
            if iscell(d.channels)
                cha = d.channels{i};
            else
                cha = [];
            end
            if nargin<3
                flag = displot(p{i},v{i},d.abs,d.ord,d.title,fp{i},pp{i},tp{i},tv{i},...
                    cha,d.multidata,pm{i},ap{i},rp{i},d.clusters{i});
                if flag
                    fig = get(0,'CurrentFigure');
                    disp(['Its content is displayed in Figure ',num2str(fig),'.']);
                else
                    disp('It does not contain any data.');
                end
            else
                disp('To display its content in a figure, evaluate this variable directly in the Command Window.');
            end
        end
    end
end

 
% Additional subclass specific fields
% if ~strcmp(class(d), 'Analyser')
%   % There are additional fields so display them as well
%   fprintf('\n Subclass fields\n\n');
%   displaySubclassFields(d);
% end 
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
%                       ->  utiliser get(obj,'...')
  
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

