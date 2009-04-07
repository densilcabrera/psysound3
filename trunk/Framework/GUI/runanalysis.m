function out = runanalysis(fileHandles, analysers, syncPeriod, wH, varargin)
% RUNANALYSIS  Run the specified Analysers for each of the file
%              handles given
%
% This is the loop for Estimating how long these files will take to analyse.
%
% Output : TSTR - Structure with times for each file, analyser
% Input  : FH   - Array of filehandle structures (they don't need
%                                                 to be calibrated)
%        : ANALYSERS - Cell array of Analyser names
%
%
% Retreive PsySound settings
prefs        = getPsysound3Prefs;
dataSaveDir  = prefs.dataDir;
dataSaveName = 'dataInfo.mat';

fLen = length(fileHandles);
aLen = length(analysers);

% default states
verb        = 0;
estimate    = 0;
summaryBoxH = [];
if ~isempty(varargin)
  str = varargin{1};
  
  if length(varargin) > 1
    summaryBoxH = varargin{2};
    summaryStr = get(summaryBoxH, 'String');
    
    % Check if TimeEstimate has been done
    if iscell(summaryStr) && length(summaryStr) > 1
      val = 1;
      for k=1:length(summaryStr)
        if ~isempty(findstr('Times for each', summaryStr{k}))
          val = k+1;
          break;
        end
      end
      set(summaryBoxH, 'Value', val);
    else
      set(summaryBoxH, 'String', {});
      set(summaryBoxH, 'Value', 1);
    end
  end
  
  if ~isstr(str)
    error('runanalysis: Unknown option specified');
  elseif strcmp(str, 'estimate')
    estimate = 1;
    verb     = 1;

    % If an output argument is supplied, don't display anything to
    % screen
    if nargout
      verb = 0;
    end
  elseif strcmp(str, 'verbose')
    verb = 1;
  else
    % do nothing, I guess
  end
end

wBars = [];
wText = [];
if ~isempty(wH)
  wBars = wH{1};
  wText = wH{2};
end

cr = sprintf('\n');

% 
% {'file1', {'FFT', 5},  {'SLM', 33}, .... 123}
% {'file2', {'FFT', 10}, {'SLM', 35}, .... 223}
% ...
% ...
% {'fileN', {'FFT', 10}, {'SLM', 35}, .... 223}
timStr = cell(fLen, aLen+2);

fprintf('\n');

% Starting ..
if verb
  fprintf('Please wait ....\n\n');
end

% xxx do file existence checking here.  issue warning for command
% line

% Reset the wait bars
resetWaitBars(wBars, wText);

if ~estimate
  % Create the dataStorage object files
  dsArrAudio = getDataStorageArrObj(dataSaveDir);
  
  % Set properties
  dsArrAudio = set(dsArrAudio, 'type', 'root');
end

% for each file
for i = 1:fLen
  fh = fileHandles(i);

  % Just cache the name, paths may get annoying
  [jink, fName] = fileparts(fh.realName);
  timStr{i, 1}  = fName;

  % some useful information to save with the outputs of the
  % algorithms
  % Note: It may be worth saving the calibration info
  % fileinfo.Filename = fh.realName;
  % fileinfo.calFilename = Files{file,2};
  % fileinfo.calLevel    = calLevel;
  % TODO Add IV
  
  % Update summary box string
  if ~isempty(summaryBoxH)
    updateSummaryBox(summaryBoxH, [' ', fName]);
  end

  if ~estimate
    % Create and cache the path
    pathTofName = fullfile(dataSaveDir, fName);
    if ~(exist(pathTofName, 'dir') == 7)
      % Create the directory
      [suc, mess] = mkdir(pathTofName);
      if ~suc
        error(mess);
      end
    end
  end
  
  % This is the total time for this file
  ttime = 0;

  if verb
    fprintf('  %-20s  \n', fName);
  end
  
  % Set the wait text string
  if ~isempty(wText)
    wStr = sprintf('File %i of %i', i, fLen);
    set(wText(3), 'String', wStr);

    % Update bar
    updateWaitBar(wBars(3), i/fLen);
  end
  
  if ~estimate
    % Create the dataStorageArray object for Analysers
    dsArrAnal = getDataStorageArrObj(pathTofName);
    
    % Set properties
    dsArrAnal = set(dsArrAnal, 'type', 'AudioFileFolder');
    dsArrAnal = set(dsArrAnal, 'data', fh);
    dsArrAnal = set(dsArrAnal, 'date', datestr(now));
  end
  
  % For each analyser
  for j = 1:aLen
		try % so that the system doesn't fail at the first error. 
		 
    % This is the analyser as a string
    analyserStr = analysers{j};
  
    % Instantiate it with the file handle
    obj = eval([analyserStr, '(fh)']);

    if ~estimate
      % Create and cache the path
      pathToAnal = fullfile(pathTofName, analyserStr);
      if ~(exist(pathToAnal, 'dir') == 7)
        % Create the directory
        [suc, mess] = mkdir(pathToAnal);
        if ~suc
          error(mess);
        end
      end
    end
    
    % Set the wait text string
    if ~isempty(wText)
      wStr = sprintf('Analyser %i of %i', j, aLen);
      set(wText(2), 'String', wStr);

      % Update bar
      updateWaitBar(wBars(2), j/aLen);
    end
    
    if estimate
      if verb
        fprintf('.');
      end

      % Pass the optional argument to process
      wFuncH = [];
      if ~isempty(wBars)
        updateWaitBar(wBars(1), 0);
        wFuncH = @(xx)updateWaitBar(wBars(1), xx);
      end
      tims = process(obj, fh, wFuncH, 'estimate');
      
      % Cache the actual name of the analyser
      timStr{i, j+1} = {obj.Name, tims(2), tims(3)};
      ttime = ttime + tims(2); % update total time
    else
      %%%%%%%%%%%%%%%%%%%%%
      % Run the analysers %
      %%%%%%%%%%%%%%%%%%%%%
      if verb
        fprintf('    %-20s    ', analyserStr);
        % Create progress function handle
        pChar    = '-';
        progress = @progressFunc;
        
        % Run the analyser, giving it the function handle for
        % progress
        if ~isempty(syncPeriod)
          obj = process(obj, fh, progress, 'synchronise', ...
                        syncPeriod);
        else
          obj = process(obj, fh, progress);
        end
        fprintf('\bdone\n');
      else
        % Reset buffer wait bar
        if ~isempty(wBars)
          %
          % Run the analyser with no display
          %
          updateWaitBar(wBars(1), 0);
          if ~isempty(syncPeriod)
            obj = process(obj, fh, @(xx)updateWaitBar(wBars(1),xx), ...
                          'synchronise', syncPeriod);
          else
            obj = process(obj, fh, @(xx)updateWaitBar(wBars(1),xx));
          end
        else
          % Run the analyser with no display
          if ~isempty(syncPeriod)
            obj = process(obj, fh, [], 'synchronise', syncPeriod);
          else
            obj = process(obj, fh, []);
          end
        end
      end % verb
      
      % Create the dataStorage object for the data
      objtmp = obj; objtmp.output = [];
      dsArrDataObj = getDataStorageArrObj(pathToAnal);
      dsArrDataObj = set(dsArrDataObj, 'type', 'AudioAnalyserFolder');
      dsArrDataObj = set(dsArrDataObj, 'data', objtmp);
      dsArrDataObj = set(dsArrDataObj, 'date', datestr(now));
      
      % Create files for each of the outputs
      createAndSaveOutputs(obj, pathToAnal, dsArrDataObj);
      
      % Create and add this analyser
      dsObjAnal = dataStorage(obj.Name, class(obj), ...
                              'AudioAnalyserFolder', 0);
      dsArrAnal = addNode(dsArrAnal, dsObjAnal);
      
    end % estimate
  
    % Update summary box string
    if ~isempty(summaryBoxH)
      updateSummaryBox(summaryBoxH, ...
                  sprintf('  %-20s %+10s', obj.Name, 'done'));
    end
		catch
		% Update summary box string
    if ~isempty(summaryBoxH)
      updateSummaryBox(summaryBoxH, ...
                  sprintf('  %-20s %+10s', obj.Name, 'Failed: See Error'));
        errStr = getErrStringWithStack(lasterror);
      for i =  1:length(errStr)
        disp(errStr{i});
      end
    end
		end
  end % foreach analyser
  
  if ~isempty(wBars)
    % reset bar
    updateWaitBar(wBars(2), 0);
  end

  if verb
    fprintf(' \n');
  end
  
  % Cache total time
  timStr{i, end} = ttime;
  
  if ~estimate
    % Save the list of analysers for this file
    saveArrDataInfo(dsArrAnal, pathTofName);
    
    % Create and add this AudioFile node
    dsObjAudio = dataStorage(fName, fName, 'AudioFileFolder', 0);
    dsArrAudio = addNode(dsArrAudio, dsObjAudio);
  
    % Save dataInfo for the list of files for this set of data
    % Note: This next line is in the loop in case of a crash
    saveArrDataInfo(dsArrAudio, dataSaveDir);

    % Create and save the timeseries object for the audio file
    audioSaveName = fullfile(pathTofName, [fName, '.mat']);
    if ~exist(audioSaveName, 'file')
      audioTSObj = createDataObject('AudioTSeries', fh.name);
      
      % Make struct
      dataObjS.DataObj     = audioTSObj;
      dataObjS.AnalyserObj = [];
      
      % and Save
      save(audioSaveName, 'dataObjS');
    end
  end
  
  % Update summary box string
  if ~isempty(summaryBoxH)
    updateSummaryBox(summaryBoxH, ' ');
  end  
end % foreach filehandle

if verb
  fprintf('\n');
end

estStr = {};
if estimate
  % Figure out the totat time
  tTime = sum([timStr{:, end}]);
  estStr{end+1} = sprintf('Total estimated time : %s', prettyTime(tTime));
  estStr{end+1} = '';
  estStr{end+1} = 'Summary';
  estStr{end+1} = '--------';
  % per file breakdown
  for i=1:fLen
    estStr{end+1} = sprintf(' %-25s %s', timStr{i, 1}, ...
                                            prettyTime(timStr{i, end}));
  end
  estStr{end+1} = '';
  estStr{end+1} = 'Times for each Analyser';
  estStr{end+1} = '-----------------------';
  for i=1:fLen
    estStr{end+1} = sprintf(' %-25s', timStr{i, 1});
    for j=1:aLen
      estStr{end+1} = sprintf('  %-20s %+10s', timStr{i,j+1}{1}, ...
                              prettyTime(timStr{i,j+1}{2}));
    end
    estStr{end+1} = '';
  end
end

if verb
  fprintf('\n');
end

% Assign output argumnets
if nargout
  if estimate
    % Return timings
    out = estStr;
  else
    % Return a cell array of analysed objects
    out = objs;
  end
else
  % No ouput argument, so display stats on screen
  if estimate
    for i=1:length(estStr)
      fprintf('%s\n', estStr{i})
    end
  end
end

% Reset the wait bars
resetWaitBars(wBars, wText);

  %
  % Nested local function for progress reporting
  %
  function pfh = progressFunc(arg)
    switch(pChar)
     case '-'
      pChar = '\';
     case '\'
      pChar = '|';
     case '|'
      pChar = '/';
     otherwise
      pChar = '-';
    end
    fprintf('\b%s', pChar);
  end

end % runanalysis

%
% Local subfunction to put times in pretty format
%
function outStr = prettyTime(value)

outStr = '';

mins = value/60;
secs = value - floor(mins)*60;

if mins > 1
  outStr = sprintf('%dm %2.0fs', floor(mins), secs);
else
  outStr = sprintf('%0.2f secs', secs);
end

end % prettyTime

%
% Save a dataStorage object in the dataInfo file in the given dir
%
function saveArrDataInfo(dsArr, path2Dir)

% Build up the full path - the dir should already exist
saveDir = fullfile(path2Dir, 'dataInfo.mat');

% Sort
dsArr = sort(dsArr);

% ... and save
save(saveDir, 'dsArr');

end % saveArrDataInfo

%
% Save function for output objects
%
function createAndSaveOutputs(obj, path2Anal, dsArrObj)

% Steal outputs
outputs    = obj.output;
obj.output = [];  % Null out to prevent saving of data objects
                  % within the analyser object

% For each output object
for i=1:length(outputs)
  % Keep only the desired output
  dataObj = outputs{i};

  % Create a valid name
  dataName     = dataObj.Name;
  dataSaveName = genvarname(dataName);

  % Build the full path
  dataFileName = fullfile(path2Anal, dataSaveName);

  % Create struct ...
  dataObjS.DataObj     = dataObj;
  dataObjS.AnalyserObj = obj;
  
  % and Save
  save(dataFileName, 'dataObjS');
  
  % Create and Add node
  if exist(dataFileName, 'dir')
    % If a dir of the same name already exists then hook it up
    % there instead.  This only happens when a dataAnalyser has
    % been operated on
    dsArrObjDA = getDataStorageArrObj(dataFileName);
    
    % add .. suffix
    dsObjData = dataStorage(dataName,                     ...
                            fullfile('..', dataSaveName), ... 
                            class(dataObj),               ...
                            1);

    % Add and save this sub-node
    dsArrObjDA = addNode(dsArrObjDA, dsObjData);
    saveArrDataInfo(dsArrObjDA, dataFileName);
    
    % Make original entry not a leaf
    dsObjData = dataStorage(dataName,             ...
                            dataSaveName,         ... 
                            'DataAnalyserFolder', ...
                            0);
    dsArrObj = addNode(dsArrObj, dsObjData);    
  else
    % Regular case
    dsObjData = dataStorage(dataName, dataSaveName, class(dataObj), 1);
    dsArrObj  = addNode(dsArrObj, dsObjData);
  end
end

% Save the dataStorage object
saveArrDataInfo(dsArrObj, path2Anal);

end % createAndSaveOutputs

%
% Update the summary box with the specified string
%
function updateSummaryBox(h, str)
strs = get(h, 'String');
val  = get(h, 'Value') + 1;

strs{val} = str;

set(h, 'String', strs);
set(h, 'Value',  val);
drawnow;

end % updateSummaryBox


function errStr = getErrStringWithStack(lerr)

psyDir = fileparts(which('psysound3'));
str = {lerr.message, ''};
stk = lerr.stack;
for i=1:length(stk)
  fname = strrep(stk(i).file, psyDir, '');  % psysound path
  fname = fname(2:end-2); % remove leading slash and extension
  str{end+1} = ['In ', fname, ' -> ',...
    stk(i).name, ' at ', num2str(stk(i).line)];
end

errStr = str;
end
% [EOF]
