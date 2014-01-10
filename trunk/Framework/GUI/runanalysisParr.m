function out = runanalysisParr(fileHandles, analysers, syncPeriod, wH,parOnFiles,varargin)
% RUNANALYSIS  Run the specified Analysers for each of the file
%              handles given
%
% This is the special runanalysis file for parallell computing feature.
% The value of ParrOnFiles determines whether to do the parfor loop on the
% analysers or on the filehandles (nested parfor loops are forbidden)
% It is also forbidden to call nested function from a parfor loop, as well
% as using save(), eval() and many others.

% The way that the time estimate, SummaryBox and Waitbars features were written and implemented couldn't
% allow the use of parfor loops, that is why I removed them, in order not
% to have to rewrite the entire file (and certainly modify the Summary and
% waitbars functions as well) Verbose is also not available.

% However, a special progress bar ("Matlab ParforProgress") is included in this version of Psysound3: 
% Copyright (c) 2013, Andreas Kotowicz
% All rights reserved.
% (Trust the ETA displayed in the bar only if you use parallell computing on the
% filehandles (ParOnFiles=1) and if the files have approximately the same size.)

fLen = length(fileHandles);
aLen = length(analysers);
dsArrAudioTemp = cell(1,fLen);

analyserList=cell(fLen,aLen);
objList=cell(fLen,aLen);
for i=1:fLen
    fh = fileHandles(i);  
    for j=1:aLen
       analyserList{i,j}=analysers{j}; %in order to have a 'sliced' variable in the parfor loop
       objList{i,j} = eval([analysers{j},'(fh)']);
       if ~isempty(gcbo)
       objList{i,j} = settings(objList{i,j},fh);
       end
    end
    
end

switch parOnFiles
    
    case 1 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
      prefs        = getPsysound3Prefs;
dataSaveDir  = prefs.dataDir;
dataSaveName = 'dataInfo.mat';



% default states
verb        = 0;
estimate    = 0;


  % Create the dataStorage object files
  dsArrAudio = getDataStorageArrObj(dataSaveDir);
  
  % Set properties
  dsArrAudio = set(dsArrAudio, 'type', 'root');


do_debug = 1;
    
    %  initialize ParforProgress monitor
    
    try % Initialization
        ppm = ParforProgressStarter2('Analysing the files...', fLen*aLen, 0.1, do_debug);
    catch me % make sure "ParforProgressStarter2" didn't get moved to a different directory
        if strcmp(me.message, 'Undefined function or method ''ParforProgressStarter2'' for input arguments of type ''char''.')
            error('ParforProgressStarter2 not in path.');
        else
            % this should NEVER EVER happen.
            msg{1} = 'Unknown error while initializing "ParforProgressStarter2":';
            msg{2} = me.message;
            print_error_red(msg);
            % backup solution so that we can still continue.
            ppm.increment = nan(1, fLen*aLen);
        end
    end

t0 = tic();


% for each file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
parfor i = 1:fLen 

    pathTofName=''; %WARNING?
   
    
  fh = fileHandles(i);
  % Just cache the name, paths may get annoying
  [jink, fName] = fileparts(fh.realName);
  
    % Create and cache the path
    pathTofName = fullfile(dataSaveDir, fName);
    if ~(exist(pathTofName, 'dir') == 7)
      % Create the directory
      [suc, mess] = mkdir(pathTofName);
      if ~suc
        error(mess);
      end
    end
  
   
    % Create the dataStorageArray object for Analysers
    dsArrAnal = getDataStorageArrObj(pathTofName);
    
    % Set properties
    dsArrAnal = set(dsArrAnal, 'type', 'AudioFileFolder');
    dsArrAnal = set(dsArrAnal, 'data', fh);
    dsArrAnal = set(dsArrAnal, 'date', datestr(now));
  
  
  % For each analyser%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  for j = 1:aLen
   
    pathToAnal='';

		try % so that the system doesn't fail at the first error. 
		 
    % This is the analyser as a string
    analyserStr = analyserList{i,j};
  
    % Instantiate it with the file handle
      obj=objList{i,j};

fprintf(' \n The Analyser "%s" (%d/%d) is processing the file (%d/%d): \n ',get(obj,'Name'),j,aLen,i,fLen)
    
      % Create and cache the path
      pathToAnal = fullfile(pathTofName, analyserStr);
      if ~(exist(pathToAnal, 'dir') == 7)
        % Create the directory
        [suc, mess] = mkdir(pathToAnal);
        if ~suc
          error(mess);
        end
      end
    
    
    fprintf('-------- %s \n',fh.realName)

      %%%%%%%%%%%%%%%%%%%%%
      % Run the analysers %
      %%%%%%%%%%%%%%%%%%%%%
          
       
          % Run the analyser with no display
           if ~isempty(syncPeriod)
             obj = processParr(obj, fh, [], 'synchronise', syncPeriod);

           else
            obj = processParr(obj, fh, []);
           end           
      
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
         dsArrAnal = addNodeparr(dsObjAnal,pathTofName);
         
         % Save it now (because of AddnodeParr)
         saveArrDataInfo(dsArrAnal, pathTofName);

      
        catch 
		
 
        errStr = getErrStringWithStack(lasterror);
      for ii =  1:length(errStr)
        disp(errStr{ii});
      end

        end
        
        ppm.increment(i*j);
        
  end % foreach analyser%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
  
    % Save the list of analysers for this file
%     saveArrDataInfo(dsArrAnal, pathTofName);
    
    % Create and add this AudioFile node 
    dsObjAudio = dataStorage(fName, fName, 'AudioFileFolder', 0);
    
%     To avoid simultaneous writing on dataInfo.mat that occured when analysing a large
%     ammount of files 
    dsArrAudioTemp{i} = dataStorageArray; 
    dsArrAudioTemp{i} = addNode(dsArrAudioTemp{i}, dsObjAudio);

    % Save dataInfo for the list of files for this set of data
    % Note: This next line is in the loop in case of a crash
%     Leads to simultaneous writing on the dataInfo.mat when parallel
%     compuing is activated.
%     saveArrDataInfo(dsArrAudio, dataSaveDir);

    % Create and save the timeseries object for the audio file
    audioSaveName = fullfile(pathTofName, [fName, '.mat']);
    if ~exist(audioSaveName, 'file')
      audioTSObj = createDataObject('AudioTSeries', fh.name);
      

      
      % and Save save(audioSaveName, 'dataObjS'); 
       ParSave(audioTSObj,audioSaveName, 'dataObjS');
    end
  


end % foreach filehandle%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fprintf(' \n **************************** ALL DONE **************************** \n ')


tic
for k=1:fLen
    dsObj = dsArrAudioTemp{k}.children;
    dsArrAudio = addNode(dsArrAudio,dsObj);
end

saveArrDataInfo(dsArrAudio, dataSaveDir)

toc


total_time = toc(t0);

% clean up progressbar
    try % use try / catch here, since delete(struct) will raise an error.
        delete(ppm);
    catch me %#ok<NASGU>
    end

    
      
        
    case 0 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
prefs        = getPsysound3Prefs;
dataSaveDir  = prefs.dataDir;
dataSaveName = 'dataInfo.mat';

fLen = length(fileHandles);
aLen = length(analysers);

% default states
verb        = 0;
estimate    = 0;


  % Create the dataStorage object files
  dsArrAudio = getDataStorageArrObj(dataSaveDir);
  
  % Set properties
  dsArrAudio = set(dsArrAudio, 'type', 'root');


do_debug = 1;
    
    %  initialize ParforProgress monitor
    
    try % Initialization
        ppm = ParforProgressStarter2('Analysing the files...', fLen*aLen, 0.1, do_debug);
    catch me % make sure "ParforProgressStarter2" didn't get moved to a different directory
        if strcmp(me.message, 'Undefined function or method ''ParforProgressStarter2'' for input arguments of type ''char''.')
            error('ParforProgressStarter2 not in path.');
        else
            % this should NEVER EVER happen.
            msg{1} = 'Unknown error while initializing "ParforProgressStarter2":';
            msg{2} = me.message;
            print_error_red(msg);
            % backup solution so that we can still continue.
            ppm.increment = nan(1, fLen*aLen);
        end
    end

t0 = tic();


% for each file %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i = 1:fLen 
  fh = fileHandles(i);
  % Just cache the name, paths may get annoying
  [jink, fName] = fileparts(fh.realName);

  
    % Create and cache the path
    pathTofName = fullfile(dataSaveDir, fName);
    if ~(exist(pathTofName, 'dir') == 7)
      % Create the directory
      [suc, mess] = mkdir(pathTofName);
      if ~suc
        error(mess);
      end
    end
  
  
    % Create the dataStorageArray object for Analysers
    dsArrAnal = getDataStorageArrObj(pathTofName);
    
    % Set properties
    dsArrAnal = set(dsArrAnal, 'type', 'AudioFileFolder');
    dsArrAnal = set(dsArrAnal, 'data', fh);
    dsArrAnal = set(dsArrAnal, 'date', datestr(now));
  
  
  % For each analyser%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  parfor j = 1:aLen
            
    pathToAnal=''; 

		try % so that the system doesn't fail at the first error. 
		 
    % This is the analyser as a string
    analyserStr = analyserList{i,j};
  
    % Instantiate it with the file handle
      obj=objList{i,j};

fprintf(' \n The Analyser "%s" (%d/%d) is processing the file (%d/%d): \n ',get(obj,'Name'),j,aLen,i,fLen)
    
      % Create and cache the path
      pathToAnal = fullfile(pathTofName, analyserStr);
      if ~(exist(pathToAnal, 'dir') == 7)
        % Create the directory
        [suc, mess] = mkdir(pathToAnal);
        if ~suc
          error(mess);
        end
      end
    
    

    fprintf('fh : %s \n',fh.realName)
    
      %%%%%%%%%%%%%%%%%%%%%
      % Run the analysers %
      %%%%%%%%%%%%%%%%%%%%%
      %%%%%%%%%%%%%%%%%%%%%
            
      
          % Run the analyser with no display
           if ~isempty(syncPeriod)
             obj = processParr(obj, fh, [], 'synchronise', syncPeriod);
           else
            obj = processParr(obj, fh, []);
           end

      
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
         dsArrAnal = addNodeparr(dsObjAnal,pathTofName);
         
         % Save it now (because of AddnodeParr)
         saveArrDataInfo(dsArrAnal, pathTofName);

        catch
 
        errStr = getErrStringWithStack(lasterror);
      for ii =  1:length(errStr)
        disp(errStr{ii});
      end

        end
        
        ppm.increment(i*j);
        
  end % foreach analyser%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  
    % Save the list of analysers for this file
%     saveArrDataInfo(dsArrAnal, pathTofName);
    
    % Create and add this AudioFile node 
    dsObjAudio = dataStorage(fName, fName, 'AudioFileFolder', 0);
    
%     To avoid simultaneous writing on dataInfo.mat that occured when analysing a large
%     ammount of files 
    dsArrAudioTemp{i} = dataStorageArray; 
    dsArrAudioTemp{i} = addNode(dsArrAudioTemp{i}, dsObjAudio);
  
    % Save dataInfo for the list of files for this set of data
    % Note: This next line is in the loop in case of a crash
%     Leads to simultaneous writing on the dataInfo.mat when parallel
%     compuing is activated.
%     saveArrDataInfo(dsArrAudio, dataSaveDir);

    % Create and save the timeseries object for the audio file
    audioSaveName = fullfile(pathTofName, [fName, '.mat']);
    if ~exist(audioSaveName, 'file')
      audioTSObj = createDataObject('AudioTSeries', fh.name);
      
      % and Save save(audioSaveName, 'dataObjS'); 
       ParSave(audioTSObj,audioSaveName, 'dataObjS');
    end
  
  
 
end % foreach filehandle%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

tic
for k=1:fLen
    dsObj = dsArrAudioTemp{k}.children;
    dsArrAudio = addNode(dsArrAudio,dsObj);
    
end

saveArrDataInfo(dsArrAudio, dataSaveDir)

toc

total_time = toc(t0);

fprintf(' \n **************************** ALL DONE **************************** \n ')


try % use try / catch here, since delete(struct) will raise an error.
        delete(ppm);
    catch me %#ok<NASGU>
end
    


end % ParonFiles
end % runanalysis

%
% Local subfunction to put times in pretty format
%
% function outStr = prettyTime(value)
% 
% outStr = '';
% 
% mins = value/60;
% secs = value - floor(mins)*60;
% 
% if mins > 1
%   outStr = sprintf('%dm %2.0fs', floor(mins), secs);
% else
%   outStr = sprintf('%0.2f secs', secs);
% end
% 
% end % prettyTime

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

%%%%%%% Added for parallell computing (can't use eval, save etc... in
%%%%%%% parfor loops). 

function ParSave(audioTSObj,audioSaveName, string)


% Make struct
dataObjS.DataObj     = audioTSObj;
dataObjS.AnalyserObj = [];
      
      % and Save
save(audioSaveName, string);

end

function obj = evalParr(analyserStr,fh)
obj = eval([analyserStr, '(fh)']);
end

function dsArr = addNodeparr(dsObj,str)
dsArr = getDataStorageArrObj(str);
dsArr = addNode(dsArr, dsObj);
end

% [EOF]
