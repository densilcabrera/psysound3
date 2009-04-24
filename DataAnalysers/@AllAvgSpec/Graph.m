function Graph(obj, hObj)
% GRAPH Callabck for the Graph pushbutton

% Initial handle retrieval
panel = get(hObj,'Parent');

% Find axes
legend off; colorbar off;
ax = findobj(panel, 'Type','Axes'); % there is only one!

% Get the Objects
dObjS = findAllInDataSet('name', 'Average Power Spectrum');

% Bail out if empty
if isempty(dObjS)
  return;
end

% Clear up some things
axes(ax);
cla;

nameStrs = {};
% Plots all selected
for i=1:length(dObjS)
  dataObjS = dObjS{i};
  if ~isempty(dataObjS)    
    plot(dataObjS.DataObj, 'line');
    fName = dataObjS.AnalyserObj.filename(1:end-3);
    nameStrs{i} = fName;
    hold on;
  end
end
  
% Fix up the colors
co = get(ax, 'ColorOrder');
ch = get(ax, 'Children');
coLen = length(co);
for l=1:length(ch)
  ind = mod(l, coLen);
  if ind == 0
    ind = coLen;
  end
  set(ch(l), 'Color', co(ind,:));
end

% Add legend
legend(nameStrs);
legend show;
grid on;

% EOF
