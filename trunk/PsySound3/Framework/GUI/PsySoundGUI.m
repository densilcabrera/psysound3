function varargout = PsySoundGUI(varargin)  
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PsySoundGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @PsySoundGUI_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end


function PsySoundGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% Choose default command line output for PsySoundGUI
handles.output = hObject;
% Initialise handles.SelectedFiles
handles.SelectedFiles = [];
handles.UiPanelNumber = 1;
handles.FilesInDir = getFilesInfo;
handles = InitialiseUI(handles);
% Update handles structure
guidata(hObject, handles);
% UIWAIT makes PsySoundGUI wait for user response (see UIRESUME)

function varargout = PsySoundGUI_OutputFcn(hObject, eventdata, handles) 
% Get default command line output from handles structure
varargout{1} = handles.output;

function CalFilesLeft_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'Value',[]);
set(hObject,'String',[]);

function CalFilesLeft_Callback(hObject, eventdata, handles)


function ModuleList_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'Value',1);


function ModuleList_Callback(hObject, eventdata, handles)
numberClicked = get(hObject,'Value');

if numberClicked==0
    return
end

% Is this a double click?
if strcmp(get(handles.figure1,'SelectionType'),'open');
  dblClick = 1;
  children = get(handles.SettingsPanel(numberClicked),'Children');
  % First child is always the checkbox 
  togValue = get(children(1),'Value');
  if togValue
    set(children(1),'Value',0);
  else
    set(children(1),'Value',1);
  end
  eval(get(children(1),'Callback'));
else
  dblClick = 0;
end


% Turn them all off
set(handles.SettingsPanel,'Visible','off');
% Except the clicked-on one
set(handles.SettingsPanel(numberClicked),'Visible','on');

guidata(hObject, handles);


%
% Updates the module's list on the extreme left pane of the
% Analysers tab
% 
function ModuleListUpdate_Callback(hObject, eventdata, handles)

possAnalysers = getAnalysers;	

% Make 'analysers' - a set of strings that has the names of all
% enabled analysers; 
% Use get object by tag to get the appropriately named checkbox.
% getAnalysers is also used in InitialiseUI to set up the ui and
% this checkbox.
%
% xxx This needn't loop - we should just be able to go straight to
% the appropriate field

EnabledAnalysers = {};

for i = 1:length(possAnalysers)
  h = findobj('Tag', [possAnalysers{i},'Enable']);
  
  % Instantiate this Analyser so that we can get its real name
  obj = eval(possAnalysers{i});
  
  if (get(h, 'Value'))
    str = sprintf('%-25s', obj.Name);
    AnalyserList{i} = ['* ', str];
    EnabledAnalysers{end+1} = possAnalysers{i};
  else
    AnalyserList{i} = ['  ', obj.Name];
  end
end

% Enable/Disable user settable fields
uip = get(hObject, 'parent'); % get parent panel
hdl = [];
hdl = [hdl; findobj(uip, 'Style', 'checkbox', '-not', 'Tag', get(hObject, 'Tag'))]; 
hdl = [hdl; findobj(uip, 'Style', 'edit')]; 
hdl = [hdl; findobj(uip, 'Style', 'popup')]; 

if get(hObject, 'Value')
  set(hdl, 'Enable', 'on');
else
  set(hdl, 'Enable', 'off');
end
% Cache the most recent list of enabled analysers
handles.EnabledAnalysers = EnabledAnalysers;
guidata(hObject, handles);

if isfield(handles, 'ModuleList') % Won't be for the CreateFcn
  set(handles.ModuleList,'String',AnalyserList); % update Module List
  guidata(hObject, handles); % update handle
end
% end ModuleListUpdate_Callback  

function FilesToCalibrate_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'Value', 0)
guidata(hObject, handles);


function FilesToCalibrate_Callback(hObject, eventdata, handles)
handles = updateCalInfo(handles);

%
% Updates the Calibration panel
%
function handles = updateCalInfo(handles)
AnalFileIndex  = get(handles.FilesToCalibrate,'Value');
AnalFileIndex  = AnalFileIndex(1);
AnalFileNumber = handles.SelectedFiles(AnalFileIndex);
AnalFilename   = handles.FilesInDir(AnalFileNumber).name;

if ~isempty(handles.FilesInDir(AnalFileNumber).CalFile)
  set(handles.AnalFilename,'String',AnalFilename);
  CalFileNumber = handles.FilesInDir(AnalFileNumber).CalFile;
  set(handles.CalFilename,'String',handles.FilesInDir(CalFileNumber).name);
  set(handles.CalFileLength,'String', ...
                    handles.FilesInDir(CalFileNumber).LengthStr);
  set(handles.CalFileSPL,'String',handles.FilesInDir(CalFileNumber).SPL);
  set(handles.AdjNecessary,'String', ...
                    94 - handles.FilesInDir(CalFileNumber).SPL);
else
  set(handles.AnalFilename,'String',AnalFilename); 
  set(handles.CalFilename,'String','No Cal. File');
  set(handles.CalFileLength,'String','No Cal. File');
  set(handles.CalFileSPL,'String','No Cal. File');
  set(handles.AdjNecessary,'String','No Cal. File');
end
% end updateCalInfo

function CurrentDirPath_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'String',pwd);

function CurrentDirPath_Callback(hObject, eventdata, handles)

function CurrentDir_Callback(hObject, eventdata, handles)

% Which one is selected
FileNumber = get(handles.CurrentDir,'Value');
if isempty(FileNumber)
  return
elseif FileNumber==0
  return
elseif strcmp(get(handles.CurrentDir,'String'),'No audio files found in this directory');
  return
end
% Make it single
FileNumber = FileNumber(1);

% Set the ui properties. 
set(handles.CurrentDirFileName,'String',handles.FilesInDir(FileNumber).name);
set(handles.CurrentDirLength,'String',handles.FilesInDir(FileNumber).LengthStr);
set(handles.CurrentDirSampleRate,'String',handles.FilesInDir(FileNumber).Fs);
set(handles.CurrentDirBitDepth,'String',handles.FilesInDir(FileNumber).Bits);
set(handles.CurrentDirChannels,'String',handles.FilesInDir(FileNumber).Channels);


function CurrentDir_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
handles.Directory = cd;
% initialise FilesInDir and get File Info - this is done in opening fcn
% handles.FilesInDir = getFilesInfo;
if (length(handles.FilesInDir)>0) % Get the names
    for i = 1:length(handles.FilesInDir)
        FilesInDirStr(i) = {handles.FilesInDir(i).name};
    end
else 
    FilesInDirStr =[];
end
% Tell FilesChosen to display the names 
if isempty(FilesInDirStr)
  FilesInDirStr = 'No audio files found in this directory';
end
set(hObject,'String',FilesInDirStr);
guidata(hObject, handles);

function FilesChosen_Callback(hObject, eventdata, handles)

function FilesChosen_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
set(hObject,'Value',[]);
set(hObject,'String',[]);

function ChangeDirectory_Callback(hObject, eventdata, handles)

if isfield(handles,'Directory')
    newDirectory = uigetdir(handles.Directory);
else
    newDirectory = uigetdir('~');
end
if newDirectory ==0
    return
end
handles.SelectedFiles = [];
cd(newDirectory);
handles.Directory = pwd;
handles.FilesInDir = getFilesInfo;
if (length(handles.FilesInDir)>0) % Get the names
    for i = 1:length(handles.FilesInDir)
        FilesInDirStr(i) = {handles.FilesInDir(i).name};
    end
else 
    FilesInDirStr =[];
end
% Tell FilesChosen to display the names 
if isempty(FilesInDirStr)
  FilesInDirStr = 'No audio files found in this directory';
end
set(handles.CurrentDir, 'Value', 1);
set(handles.CurrentDir,'String', FilesInDirStr);
set(handles.CurrentDirPath,'String',newDirectory);
handles = changeSelectedFiles(handles);
guidata(hObject, handles);


function AddFile_Callback(hObject, eventdata, handles)

% Which one is selected
FileNumber = get(handles.CurrentDir,'Value');
if isempty(FileNumber)
  return
elseif FileNumber==0
  return
elseif strcmp(get(handles.CurrentDir,'String'),'No audio files found in this directory');
  return
end

% get the number of the selected file
handles.CurrentDirHighlighted = get(handles.CurrentDir, 'Value');
handles.SelectedFiles = [handles.SelectedFiles handles.CurrentDirHighlighted];
handles.SelectedFiles = unique(handles.SelectedFiles);
handles.CalibrationFiles = [];
handles.CalibrationLevels = [];
handles.DataHeaders={'Files','Cal. Files','Cal. Level'};
handles = changeSelectedFiles(handles);

guidata(hObject, handles);


function RemoveFile_Callback(hObject, eventdata, handles)

% How many rows are selected
RemoveRows = getSelectedRows(getTable(handles.Table))+1;
% The top left cell is what? (It will be empty if nothing has been added)
try
  TopLeftCell = getValueAt(getModel(getTable(handles.Table)),0,0);
catch
  return
end

if length(RemoveRows)>0  && ~isempty(TopLeftCell)
  handles.SelectedFiles(RemoveRows) = [];
  handles.SelectedFiles = unique(handles.SelectedFiles);
  handles = changeSelectedFiles(handles);
  guidata(hObject, handles);
end

%
% Executes when "RunAnalysis" is pressed
%
function RunAnalysis_Callback(hObject, eventdata, handles)
% Basic checks
if isempty(handles.SelectedFiles)
  msgbox('No Files Selected for Analysis');
  return
elseif isempty(handles.EnabledAnalysers)
  msgbox('No Analysers have been enabled');
  return
end

prefs = getPsysound3Prefs;
ht    = getTableModel(handles.Table);
if ~isfield(handles, 'calAnswer') && ~prefs.calibrationIndex{3}
  msgbox('Files have not been calibrated');
  return;
end

if isfield(handles, 'calAnswer')
  if strcmp(handles.calAnswer, 'With Files')
    % The filehandles from guidata should be empty
    if ~isempty(handles.fileHandles)
     % commented out until I see a situation where there is a reason for
     % this to be a fatal error. Usually it gets through with no problems.
     % errordlg('RunAnalysis calibration error 1');
     % return;
    end
  
    % First check if
    for i = 1:length(handles.SelectedFiles)
      file     = handles.SelectedFiles(i);
      calfile  = getValueAt(ht, i-1, 1);
      calLevel = str2double(getValueAt(ht, i-1, 2));
      fileName = handles.FilesInDir(file).name;

      if isempty(calfile)
        % This file has not been calibrated
        errordlg(['Calibration file/level not found for ',...
          fileName, '.  Please calibrate and try again']);
        return;
      end

      % Create the filehandle
      fhs(i) = readData(fileName);
    
      % ... and calibrate
      fhs(i) = calibrate(fhs(i), 'WithFiles', calfile, calLevel);
    end
  else
    fhs = handles.fileHandles;
    % The filehandles from guidata should be non-empty
    if isempty(fhs)
      errordlg('RunAnalysis calibration error 2');
      return;
    end
  end
  
  % The filehandles should've already been created and calibrated -
  % so check here
  if any(isnan([fhs(:).calCoeff]))
    % Found atleast one uncaibrated file handle
    errordlg('Atleast some of the files have not been calibrated');
    return;
  end
end  

waitCell = [];
if prefs.showWaitBar
  % We should now be ready to go with calibrated file handles
  waitCell{1} = handles.waitBarBuffer;
  waitCell{2} = handles.waitBarText;
end

% Set string
origStr = get(hObject, 'String');
set(hObject, 'String', 'analysing ...');
drawnow;

if prefs.calibrationIndex{3}
  % Default calibration is in effect.
  % xxx See ticket #111 for more details.
  selFiles     = handles.SelectedFiles;
  selFileNames = handles.FilesInDir(selFiles);
  fhs = readData({selFileNames.name});
  for kk=1:length(fhs)
    % fhs(kk).calCoeff = 10^(str2double(prefs.calibrationLvl) / 20);
    fhs(kk).calCoeff = 10^((str2double(prefs.calibrationLvl)-90.78) / 20);
  end
end
  
% Check synchronisation flag
syncStat = get(handles.SynchronisationTickbox, 'Value');
syncRate = [];
if syncStat
  syncPerVal = get(handles.SynchronisationPopup, 'Value');
  syncPerUD  = get(handles.SynchronisationPopup, 'UserData');
  syncRate   = 1/(syncPerUD(syncPerVal) * 1e-3); % Convert from ms
end

try
  runanalysis(fhs, handles.EnabledAnalysers, syncRate, ...
              waitCell, '', handles.Summary);
catch
  % reset state
  set(hObject, 'String', origStr);
  
  if ~isempty(waitCell)
    resetWaitBars(waitCell{1}, waitCell{2});
  end
  
  errStr = getErrStringWithStack(lasterror);
  errordlg(errStr, 'Time Estimate error');
  return;  % bail out
end

% Alls good
set(hObject, 'String', origStr);
handles.UiPanelNumber = handles.UiPanelNumber + 1;
% Re-create the postprop panel
handles = PostPropGUI(handles, 1);
handles = DisplayUIPanel(handles);

guidata(hObject, handles);
drawnow;

% end RunAnalysis_Callback

%
% Executes when "TimeEstimates" is pressed
%
function TimeEstimate_Callback(hObject, eventdata, handles)
% Return for no selection
if isempty(handles.SelectedFiles)
  msgbox('No Files Selected for Analysis');
  return
elseif isempty(handles.EnabledAnalysers)
  msgbox('No Analysers have been enabled');
  return
end

ht = getTableModel(handles.Table);

% Create a list of filehandles, if one does not already exist.  For
% time estimates, we don't care about calibration
% Chuck the filenames in a cell array
if ~isfield(handles, 'fileHandles') || isempty(handles.fileHandles)
  fnames = {};
  for i = 0:getRowCount(ht)-1
    fnames{end+1} = getValueAt(ht, i, 0);
  end

  % Create a list of filehandles
  fhs = readData(fnames);
else
  fhs = handles.fileHandles;
end

% Set string
origStr = get(hObject, 'String');
set(hObject, 'String', 'timing ...');
drawnow;

tStr = '';
try
  prefs    = getPsysound3Prefs;
  waitCell = [];
  if prefs.showWaitBar
    % Call the unified analysis function
    waitCell{1} = handles.waitBarBuffer;
    waitCell{2} = handles.waitBarText;
  end
  tStr = runanalysis(fhs, handles.EnabledAnalysers, [], ...
                     waitCell,  'estimate');
catch
  set(hObject, 'String', origStr);
  
  if ~isempty(waitCell)
    resetWaitBars(waitCell{1}, waitCell{2});
  end
  
  errStr = getErrStringWithStack(lasterror);
  errordlg(errStr, 'Time Estimate error');
end

set(hObject, 'String', origStr);
  
% Stick the timings cell array in the list box
set(handles.Summary, 'Value',  1);
set(handles.Summary, 'String', tStr);

drawnow;
guidata(hObject, handles);
% end TimeEstimate_Callback

function AssociateFile_Callback(hObject, eventdata, handles)
% get the selected calibration file. 
CalFileIndex = get(handles.CalFilesLeft,'Value');
if isempty(CalFileIndex)
   return
 end
% get the selected Analysis files. 
AnalFileIndexes = getSelectedRows(getTable(handles.Table))+1;
if isempty(AnalFileIndexes)
   return
end
calFileName = get(handles.CalFilesLeft,'String');
calFileName = calFileName{CalFileIndex};
questionString = strcat('What is the Level in dB SPL of Calibration File ''', calFileName,'''?');  
refresh;
drawnow;
CalibrationLevel = inputdlg(questionString,'Calibration Level',1,{'94'});
drawnow;
if isempty(CalibrationLevel) 
   return
end

% Associate a FilesInDir index with AnalFilesIndexes
for i = 1:length(AnalFileIndexes)
    AnalFileNumber = AnalFileIndexes(i);
    FilesInDirIndex = handles.SelectedFiles(AnalFileNumber);
    CalFileFilesInDirIndex = handles.CalibrationFiles(CalFileIndex);
    handles.FilesInDir(FilesInDirIndex).CalFile = CalFileFilesInDirIndex;
    handles.FilesInDir(FilesInDirIndex).CalFileLevel = CalibrationLevel;
end
%handles = updateCalInfo(handles);
handles = changeSelectedFiles(handles);
guidata(hObject, handles);

function RemoveAssociation_Callback(hObject, eventdata, handles)

try
  TopLeftCell = getValueAt(getModel(getTable(handles.Table)),0,0);
catch
  return
end

% get the selected Analysis files. 
AnalFileIndexes = getSelectedRows(getTable(handles.Table))+1;
if isempty(AnalFileIndexes)
    return
end
if length(AnalFileIndexes)==1&AnalFileIndexes==0
    return
end
    
% Associate a FilesInDir index with AnalFilesIndexes
for i = 1:length(AnalFileIndexes)
    AnalFileNumber = AnalFileIndexes(i);
    FilesInDirIndex = handles.SelectedFiles(AnalFileNumber);
    %CalFileFilesInDirIndex = handles.FilesNotSelected(CalFileIndex);
    handles.FilesInDir(FilesInDirIndex).CalFile = [];
    handles.FilesInDir(FilesInDirIndex).CalFileLevel = [];
end
%handles = updateCalInfo(handles);
handles = changeSelectedFiles(handles);
guidata(hObject, handles);

% Formats the lasterror string
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


% Uses the SLM module to calibrate
function CalFileAnalyse_Callback(hObject, eventdata, handles)
CalFileIndex    = get(handles.CalFilesLeft,'Value');
CalFileFIDIndex = handles.CalibrationFiles(CalFileIndex);
CalFilename     = handles.FilesInDir(CalFileFIDIndex).name;

origStr = get(hObject, 'String');
set(hObject, 'String', 'Please wait');
drawnow;

% Create the fileHandle
fh = readData(CalFilename);

slmObj = SLM(fh);
slmObj = setIgnoreDelay(slmObj, true);
slmObj.wChoices = 'Z';
slmObj.iChoices = 'f';

slmObj = process(slmObj, fh, [], 'calibrate');

ax = handles.CalFileAxes;
axes(ax);
cla;
plot(slmObj.output{1}, 'plot');
ylabel('SPL Zf (dB)');

% Add text annotations
xdata = get(get(ax, 'Children'), 'XData');

maxY = round(slmObj.output{1}.stats.max) + 1;
minY = round(slmObj.output{1}.stats.min) - 1;
avY  = slmObj.output{1}.stats.mean;

hold on;
plot((xdata(1):0.1:xdata(end)), avY, '--');

xval = 0.75 * xdata(end);

t1 = text(xval, minY,  ['Min.  ', sprintf('%.1f', slmObj.output{1}.min)]);
t2 = text(xval, maxY,  ['Max.  ', sprintf('%.1f', slmObj.output{1}.max)]);
t3 = text(xval, avY-2, ['Mean. ', sprintf('%.1f', slmObj.output{1}.mean)]);
set([t1 t2 t3], 'FontSize', 9);

set(hObject, 'String', origStr);
drawnow;

% end CalFileAnalyse_Callback

function ClearAll_Callback(hObject, eventdata, handles)
handles.SelectedFiles = [];
handles.Data = [];
handles = changeSelectedFiles(handles);
%updateSummary(handles);

% Reset calibration
if isfield(handles, 'calAnswer')
  handles = rmfield(handles, 'calAnswer');
end

guidata(hObject, handles);

function ClearAssoc_Callback(hObject, eventdata, handles)
for i = 1:length(handles.Data)
    handles.Data(i,2) = {''};
    handles.Data(i,3) = {''};
end
for i = 1:length(handles.FilesInDir)
    handles.FilesInDir(i).CalFile =[];
    handles.FilesInDir(i).CalFileLevel =[];
end
handles = changeSelectedFiles(handles);

guidata(hObject, handles);

%%%%%%%%%%%%%%%%%
% Standardising %
%%%%%%%%%%%%%%%%%

function ChosenMethod_Callback(hObject, eventdata, handles)
% enable or disable calibration uicontrols depending on a popupmenu
% selection

% Get Selection
Selection = get(handles.ChosenMethod, 'Value');
    
% Enable, Disable and change settings based on Selection
switch Selection
 case {1}
  set(handles.ChosenLevel, 'Enable','off');
  set(handles.ChosenFilter,'Enable','off');
  set(handles.Standardise, 'Enable','off');
 case {2}
  % SPL
  set(handles.ChosenLevel, 'Enable','on');
  set(handles.ChosenLevel, 'String',70);
  set(handles.ChosenFilter,'Enable','on');
  set(handles.Standardise, 'Enable','on');
 case {3}
  % Median
  set(handles.ChosenLevel, 'Enable','off');
  set(handles.ChosenLevel, 'String','Median');
  set(handles.ChosenFilter,'Enable','on');
  set(handles.Standardise, 'Enable','on');
 case {4}
  % Max
  set(handles.ChosenLevel, 'Enable','off');
  set(handles.ChosenLevel, 'String','Max');
  set(handles.ChosenFilter,'Enable','on');
  set(handles.Standardise, 'Enable','on');
 case {5}
  % Min
  set(handles.ChosenLevel, 'Enable','off');
  set(handles.ChosenLevel, 'String','Min');
  set(handles.ChosenFilter,'Enable','on');
  set(handles.Standardise, 'Enable','on');    
 case {6}
  % Constant
  set(handles.ChosenLevel, 'Enable','on');
  set(handles.ChosenLevel, 'String',10);
  set(handles.ChosenFilter,'Value',1);
  set(handles.ChosenFilter,'Enable','off');
  set(handles.Standardise, 'Enable','on');    
 case {7}
  % No change
  set(handles.ChosenLevel, 'Enable','off');
  set(handles.ChosenFilter,'Enable','off');
  set(handles.Standardise, 'Enable','on');
end

%
% The Standardise button callback
%
function handles = Standardise_Callback(hObject, eventdata, handles)
% This does the standardisation of the files, by calculating their level
% and then setting adjustments that are used by readData when the analysis
% is run. 

% Get choices
StandardiseMethod = get(handles.ChosenMethod,'Value');
StandardiseFilter = get(handles.ChosenFilter,'Value');
StandardiseLevel  = str2double(get(handles.ChosenLevel ,'String'));

switch (StandardiseFilter)
 case {1}
  weighting = 'Z';
 case {2}
  weighting = 'A';
 case {3}
  weighting = 'B';
 case {4}
  weighting = 'C';
end

% Get the list of files
ht = getTableModel(handles.Table);

% Get the list of filehandles
fhs = handles.fileHandles;

% Figure out which method
switch(StandardiseMethod)
 case 2
  calType = 'SPL';
 case 3
  calType = 'Median';
 case 4
  calType = 'Max';
 case 5
  calType = 'Min';
 case 6 
  calType = 'Constant';
 case 7
  calType = 'NoChange';
 otherwise
  calType = 'dunno';
end

% Calculate the levels with chosen weighting
wbh = waitbar(0, 'Calculating Adjustments');

% Change the color of the bar
pH = findobj(wbh, 'Type', 'patch');
set(pH, 'FaceColor', [0 0 1]);

% Use try/catch so that we can kill the wait bar on errors
try
  % Call unified calibrate method
  [fhs, meanLevels, adjs] = calibrate( ...
      fhs, 'WithOutFiles', weighting, calType, StandardiseLevel, wbh);
catch
  if ishandle(wbh)
    delete(wbh);
  end
  
  % Bubble up
  rethrow(lasterror);
end

% Fill in the mean levels and adjustments
for i = 1:getRowCount(ht)
  handles.FilesInDir(handles.SelectedFiles(i)).Level      = meanLevels(i);
  handles.FilesInDir(handles.SelectedFiles(i)).Adjustment = adjs(i);
end

% Change headers
handles.DataHeaders = {'Files',['dB SPL(' weighting ')'],'Adjustment'};

% Fill in table
handles = changeSelectedFiles(handles);

if ishandle(wbh)
  delete(wbh);
end

% Cache the filehandles
handles.fileHandles = fhs;

guidata(hObject,handles);

% end Standardise_Callback

%
function updateSummary(handles)
% Initialise
Length = 0;
% Calculate length of all files
for i = 1: length(handles.SelectedFiles)
    Length = Length + handles.FilesInDir(handles.SelectedFiles(i)).Length;    
end

% Prettify time display
if Length < 60
   Milliseconds = floor(mod(Length,1)*1000);
   Seconds = floor(Length);
   LengthStr = sprintf('%i s %i ms',Seconds,Milliseconds);
else
   Seconds = floor(mod(Length,60));
   Minutes = floor(Length/60);
   LengthStr = sprintf('%i min %i s', Minutes, Seconds);
end

% set the uitext properties.    
set(handles.SummaryNumberOfFiles,'String',length(handles.SelectedFiles));


function CurrentDirPlayFile_Callback(hObject, eventdata, handles)
persistent soundPlayer;
persistent Pressed;

% Which one is selected
FileNumber = get(handles.CurrentDir,'Value');
if isempty(FileNumber)
  return
elseif FileNumber==0
  return
elseif strcmp(get(handles.CurrentDir,'String'),'No audio files found in this directory');
  return
end

if ~(isempty(Pressed))
    if ~(Pressed==1)
        FileNumber = get(handles.CurrentDir,'Value');
        if FileNumber == 0|FileNumber ==-1
            return
        else
            FileNumber= FileNumber(1);
        end
        Filename = handles.FilesInDir(FileNumber).name;
        [wavfile,Fs,bits] = wavread(Filename);
        set(hObject,'String','Stop Playing');
        Pressed =1;
        soundPlayer = audioplayer(wavfile,Fs,16);
        play(soundPlayer);
        % get length
        % Pressed = 0;
        % set(hObject,'String','Play File');
    else
        Pressed = 0;
        set(hObject,'String','Play File');
        if exist('soundPlayer')
            stop(soundPlayer);
        end
    end
else
    FileNumber = get(handles.CurrentDir,'Value');
    if FileNumber == 0|FileNumber ==-1
        return
    else
        FileNumber= FileNumber(1);
    end
    Filename = handles.FilesInDir(FileNumber).name;
    try
      [wavfile,Fs,bits] = wavread(Filename);
    catch
      % Not a wav-file so try and find it
      wavFilename = [tempdir, filesep, Filename, '.temp.wav'];
      if exist(wavFilename) == 2
        [wavfile,Fs,bits] = wavread(wavFilename);
      end
    end
    set(hObject,'String','Stop Playing');
    Pressed =1;
    soundPlayer = audioplayer(wavfile,Fs,16);
    play(soundPlayer);

end

function Next_Callback(hObject, eventdata, handles)
handles.UiPanelNumber = handles.UiPanelNumber + 1;
handles = DisplayUIPanel(handles);
guidata(hObject, handles);

function Back_Callback(hObject, eventdata, handles)
handles.UiPanelNumber = handles.UiPanelNumber - 1;
handles = DisplayUIPanel(handles);
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Collect Ind. Variables % 
%%%%%%%%%%%%%%%%%%%%%%%%%%

function IV_Callback(hObject, eventdata, handles)
% read all filenames from the table
% Build a cell array of Independent Variables

% Get dash positions
% Are number of dashes equal?
ht = getTableModel(handles.Table);
rows = getRowCount(ht);
for i = 1:rows
    Filenames{i} = getValueAt(ht,i-1,0);
end
    
rows = length(Filenames);
try
    for i = 1:rows
        Positions = regexp(char(Filenames{i}),'[-_.]');
        Delimiters(i,:) = Positions;
    end
catch
    helpdlg('Number of dashes in all filenames should be equal');
end
% Get Number of Dashes
[numberOfFiles,numberOfDashes] = size(Delimiters);
% Now let's ask about the names
for i=1:numberOfDashes
    Question = sprintf('%s %i%s\n','Type in the name of Parameter',i,': '); 
    IndVar(i) = cellstr(inputdlg(Question,'Parameter Names in Filename'));
end
% Get all the cells delimited by the dashes or the dot.
for i = 1:length(Filenames)
    readPointL = 1;
    for j = 1:numberOfDashes 
        IV.filename{i} = Filenames{i};
        readPointR = Delimiters(i,j)-1;
        IV.Parameters{i,j} = IV.filename{i}(readPointL:readPointR);
        readPointL = Delimiters(i,j)+1;
        IV.name(j) = IndVar(j);
    end
end
handles.IV = IV;
h = figure(201);
set(h,'Position',[200 200 800 600]);
[rows,columns] = size(IV.Parameters);
for i = 1:rows
IVdisplay{i,1} = IV.filename{i};
ColumnNames{1} = 'Filename';
    for j=1:columns
        ColumnNames{j+1} = IV.name{j};
        IVdisplay{i,j+1} = IV.Parameters{i,j};
    end
end
ht = uitable(IVdisplay,ColumnNames,'Parent',h,'Position',[0 0 800 600],'ColumnWidth',120);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analyser Settings Callbacks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function SynchronisationTickbox_Callback(hObject, eventdata, handles)

if (get(handles.SynchronisationTickbox,'Value'))
    PopupEnable     = 'on';
    AnalyserSetting = 'off';
else
    PopupEnable     = 'off';
    AnalyserSetting = 'on';
end
set(handles.SynchronisationPopup,'Enable', PopupEnable);
set(handles.SynchronisationText, 'Enable', PopupEnable);

% Loop over all Analysis panels and disable all window/overlap controls
for i=1:length(handles.SettingsPanel)
  panel = handles.SettingsPanel(i);
  h     = findobj(panel, '-regexp', 'Tag', ['(OverlapSize|OverlapType)']);

  set(h, 'Enable', AnalyserSetting);
  
  % Find popup and run its callback
  % Same code for tickbox and popupmenu
  h  = findobj(panel, '-regexp', 'Tag', 'WindowSize', 'Style', 'popupmenu');
  try
    cb = get(h, 'Callback');
    cb(h);
  end
end
  
function SynchronisationPopup_Callback(hObject, eventdata, handles)
% Loop over all Analysis panels and disable all window/overlap controls
for i=1:length(handles.SettingsPanel)
  panel = handles.SettingsPanel(i);
 
  % Find popup and run its callback
  % Same code for tickbox and popupmenu
  h  = findobj(panel, '-regexp', 'Tag', 'WindowSize', 'Style', 'popupmenu');
  try
    cb = get(h, 'Callback');
    cb(h);
  end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PostProcessing Callbacks %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function OutputFilesList_Callback(hObject, eventdata, handles)
% load output file and show the names in OutputResultsList 

Choice= get(handles.OutputFilesList,'Value');
if length(Choice)>1
    Choice=Choice(1);
elseif length(Choice)<1
    return
end
FilesList = get(handles.OutputFilesList,'String');
AnalyserResults = whos('-file',char(FilesList(Choice)));
% only need names
for i = 1: length(AnalyserResults)-1
    AnalyserResultsStr{i} = AnalyserResults(i).name;
end
% set the listbox
set(handles.OutputResultsList,'String',AnalyserResultsStr);
set(handles.OutputResultsList,'Value',1);
%set(handles.OutputFilesList,'Value',Choice);
guidata(hObject, handles);

function OutputFilesList_CreateFcn(hObject, eventdata, handles)
%Do Nothing

function OutputResultsList_CreateFcn(hObject, eventdata, handles)
% Do Nothing 


function OutputResultsList_Callback(hObject, eventdata, handles)
FileChoice= get(handles.OutputFilesList,'Value');
if length(FileChoice)>1
    FileChoice=FileChoice(1);
elseif length(FileChoice)<1
    return
end
FilesList = get(handles.OutputFilesList,'String');
AnalyserResults = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObject = load(char(FilesList(FileChoice)),char(ResultsList(ResultsChoice)));
outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
for i=1:length(outputs)
    DataObjectsStr{i} = sprintf('%s: \t %s',class(outputs{i}),  get(outputs{i},'Name'));
end
% set the listbox
set(handles.OutputDataObjectsList,'String',DataObjectsStr);
set(handles.OutputDataObjectsList,'Value',1);
clear('DataObject','DataObjectsStr','outputs');
guidata(hObject, handles);

function OutputDataObjectsList_CreateFcn(hObject, eventdata, handles)
% Do Nothing 

function OutputDataObjectsList_Callback(hObject, eventdata, handles)
% Change visibility of Action Panel. 
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
DataObjectStr = get(handles.OutputDataObjectsList,'String');
DataObject = DataObjectStr(DataObjectChoice);

% Check that this is not being called before something has been loaded

% Look at the string to work out which data object is chosen
ColonPosition = regexp(DataObject,':');
DataObject = char(DataObject);
chosenDataObject = DataObject(1:ColonPosition{1}-1);

% Make all panels invisible
% Need one per Data Type. 
set(handles.TimeSeriesActions, 'Visible', 'off');
set(handles.TimeSpectrumActions, 'Visible', 'off'); 
set(handles.SpectrumActions, 'Visible', 'off');
% Make the panel chosen visible
% Need one case per Data Type. 
switch chosenDataObject
    case 'timeseries'
        set(handles.TimeSeriesActions, 'Visible', 'on');
    case 'tSpectrum'
        set(handles.TimeSpectrumActions, 'Visible', 'on'); 
    case 'ThirdOctaveTimeSpectrum'
        set(handles.TimeSpectrumActions, 'Visible', 'on'); 
    case 'Spectrum'
        set(handles.SpectrumActions, 'Visible', 'on');
    case 'ThirdOctaveSpectrum'
        set(handles.SpectrumActions, 'Visible', 'on');
end

%%%%%% Not implemented yet
% How many files have been chosen?

% If multiple 
% Display how many chosen. 

% Else if only one then:
% Load from the object
% Size of data
% Length of time
% Sampling rate of output data
% Useful Statistics

% Make the summary panel display this stuff. 

function TimeSeriesLinePlot_Callback(hObject, eventdata, handles)
% Graph the output. 

% What to graph
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
%AnalyserResults{i} = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
figure;
for i = 1:length(FileChoice)
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    subplot(length(FileChoice),1,i)
    plot(outputs{DataObjectChoice});
end

function TimeSpectrumImagePlot_Callback(hObject, eventdata, handles)
% Graph the output. 

% What to graph
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
%AnalyserResults{i} = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
figure;
for i = 1:length(FileChoice)
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    subplot(length(FileChoice),1,i)
    imagesc(outputs{DataObjectChoice});
end

function TimeSpectrumSurfPlot_Callback(hObject, eventdata, handles)
% Graph the output. 

% What to graph
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
%AnalyserResults{i} = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
figure;
for i = 1:length(FileChoice)
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    subplot(length(FileChoice),1,i)
    surf(outputs{DataObjectChoice});
end

function SpectrumLinePlot_Callback(hObject, eventdata, handles)
% Graph the output. 

% What to graph
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
%AnalyserResults{i} = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
figure;
for i = 1:length(FileChoice)
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    subplot(length(FileChoice),1,i)
    plot(outputs{DataObjectChoice});
end

function SpectrumBarPlot_Callback(hObject, eventdata, handles)
% Graph the output. 

% What to graph
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
%AnalyserResults{i} = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
figure;
for i = 1:length(FileChoice)
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    subplot(length(FileChoice),1,i)
    bar(outputs{DataObjectChoice});
end


function ExportSummary_Callback(hObject, eventdata, handles)
% Export Descriptive Statistics. 

% What to graph
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
%AnalyserResults{i} = whos('-file',char(FilesList(FileChoice)));
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');
j =1;
i =1;
Summary{i,j} = 'Filename';
j = j+1;
if isfield(handles,'IV')
    for k=1:length(handles.IV.name)
        Summary{i,j} = handles.IV.name{i,k};
        j = j+1;
    end
end
DataObject = load(char(FilesList(FileChoice(1))),char(ResultsList(ResultsChoice)));
outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
[selection,ok] = listdlg('liststring',fields(outputs{DataObjectChoice}.DataInfo.UserData));
if ~ok
    return
end
StatFields = fields(outputs{DataObjectChoice}.DataInfo.UserData);
Summary{i,j} = StatFields{selection};

for i = 1:length(FileChoice)
    j =1;
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    Summary{i+1,j} = FilesList{FileChoice(i)};
    j = j+1;
    if isfield(handles,'IV')
        for k=1:length(handles.IV.Parameters(i,:))
            Summary{i+1,j} = handles.IV.Parameters{i,k};
            j = j+1;
        end
    end

    Summary{i+1,j} = outputs{DataObjectChoice}.DataInfo.UserData.(StatFields{selection});
    j = j+1;
end
figure;
uitable(Summary,Summary(1,:),'Position',[20 20 500 400]);



function ExportData_Callback(hObject, eventdata, handles)
% Export the Data. 

% Initially defined for timeseries inputs. 
% Should be easy for spectrum, not so easy for timespectrum. 
% What to Export?
FileChoice= get(handles.OutputFilesList,'Value');
FilesList = get(handles.OutputFilesList,'String');
ResultsChoice = get(handles.OutputResultsList,'Value');
ResultsList = get(handles.OutputResultsList,'String');
DataObjectChoice = get(handles.OutputDataObjectsList,'Value');

for i = 1:length(FileChoice)
    DataObject = load(char(FilesList(FileChoice(i))),char(ResultsList(ResultsChoice)));
    outputs = get(DataObject.(char(ResultsList(ResultsChoice))),'output');
    filenames{i} = get(DataObject.(char(ResultsList(ResultsChoice))),'filename');
    dataForExport{i} = get(outputs{DataObjectChoice},'data');
    timeForExport{i} = get(outputs{DataObjectChoice},'Time');
    clear('outputs','DataObject');
end

for i = 1:length(dataForExport)
    [rows,columns] = size(dataForExport{i});
    dataLength(i) = rows;
end

[maximum, maxIndex]=max(dataLength);

for i = 1:length(dataForExport)
    dataForExport{i} = [dataForExport{i}; NaN(max(dataLength)-dataLength(i),1)];
end
formattedData = cell2mat([timeForExport{maxIndex} dataForExport]);
[filename, pathname, filterindex] = uiputfile( ...
       {'*.txt',  'Text-files (*.txt)'; ...
        '*.*',  'All Files (*.*)'}, ...
        'Save Data as:');

fid = fopen([pathname filename],'w');
fprintf(fid, '%s','Time (s)');
for i = 1:length(filenames)
    fprintf(fid, '\t%s',filenames{i});
end
fprintf(fid,'\n');
[rows,columns] = size(formattedData);
for i = 1:rows
    for j = 1:columns-1
        fprintf(fid, '%f\t',formattedData(i,j));
    end
    fprintf(fid,'%f\n',formattedData(i,columns));
end
fclose(fid);


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Load and Save Settings %
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% This basically executes all the callbacks as if it was done manually
function LoadFileSettings_Callback(hObject, eventdata, handles) 
file = uigetfile({'*.psyf', 'PsySound3 files (*.psyf)'}, ...
                 'Load files');

% Check for cancel
if isequal(file, 0)
  return;
end

% Make sure the file is in the current directory
if ~exist(file, 'file')
  errordlg([file, ' not found in the current directory: ', pwd, ...
            '.  Please change dir. and try again.']);
  return;
end

load('-mat', file);
if ~exist('psyfS', 'var')
  errordlg('This file does not contain file settings.');
  return
end

applySaveFilesStruct(hObject, eventdata, handles, psyfS);

% end LoadFileSettings_Callback

%
% Apply SaveFiles structure to psysound
%
% Figure out the indicies in the list box
function applySaveFilesStruct(hObject, eventdata, handles, psyfS)

% Clear all
ClearAll_Callback(hObject, eventdata, handles);
handles = guidata(hObject);

filesToLoad   = psyfS.filesData(:,1);
filesListStrs = get(handles.CurrentDir, 'String');
sel = [];

% Is there a better way to optimise this even more?
for k=1:length(filesToLoad)
  funcH  = @(x)strcmp(filesToLoad{k}, x);
  sel(k) = find(cellfun(funcH, filesListStrs)); 
end

% What about any files that were not found?

% Select these files
origVal = get(handles.CurrentDir, 'Value');
set(handles.CurrentDir, 'Value', sel);

% Add call Addfile
AddFile_Callback(hObject, eventdata, handles);
handles = guidata(hObject);

% Now check calibration
if ~strcmp(psyfS.calAnswer, 'Unset')
  handles.calAnswer = psyfS.calAnswer;
  
  if strcmp(handles.calAnswer, 'Without Files')
    calInfo = psyfS.calInfo;
    
    set(handles.ChosenMethod, 'Value',  calInfo.ChosenMethod);
    set(handles.ChosenFilter, 'Value',  calInfo.ChosenFilter);
    set(handles.ChosenLevel,  'String', calInfo.ChosenLevel);

    % Create a list of filehandles
    fhs = readData({psyfS.filesData{:,1}});
    for i=1:length(fhs)
      % Fill in the calibration coeffecients
      fhs(i).calCoeff = calInfo.calCoeffs(i);
    end
    handles.fileHandles = fhs;
  end
else
  % Remove the field
  if isfield(handles, 'calAnswer')
    handles = rmfield(handles, 'calAnswer');
  end
end

handles.Data        = psyfS.filesData;
handles.DataHeaders = psyfS.DataHeaders;

% Update the table
updateFilesTable(handles);

% Restore
set(handles.CurrentDir, 'Value', origVal);

guidata(hObject, handles);

% end applySaveFilesStruct

%
% Save file settings
%
function SaveFileSettings_Callback(hObject, eventdata, handles) 
% Give the user a dialog to choose a filename
[file, path] = uiputfile({'*.psyf', 'PsySound3 files (*.psyf)'}, ...
                         'Save files as', 'Untitled.psyf');

if ~isequal(file, 0) && ~isequal(path, 0)
  fName = [path, file];

  % Call helper function
  psyfS = constructSaveFilesStruct(handles);

  % Valid file name so save
  save(fName, '-mat', 'psyfS');
end
% end SaveFileSettings_Callback

%
% Get the SaveFilesStruct
%
function psyfS = constructSaveFilesStruct(handles)
if isfield(handles, 'calAnswer')
  psyfS.calAnswer   = handles.calAnswer;
  psyfS.DataHeaders = handles.DataHeaders;
  
  if strcmp(handles.calAnswer, 'Without Files')
    % Save calibration info
    calInfo.ChosenMethod = get(handles.ChosenMethod, 'Value');
    calInfo.ChosenFilter = get(handles.ChosenFilter, 'Value');
    calInfo.ChosenLevel  = get(handles.ChosenLevel,  'String');
    
    % Make sure the names are in the right order
    if ~isempty(handles.fileHandles)
      if ~strcmp([handles.Data{:,1}], [handles.fileHandles.name])
        error('SaveFileSettings: fileHandle name mismatch');
      end
      
      % Stick in an array
      calInfo.calCoeffs = [handles.fileHandles.calCoeff];
    else
      calInfo.calCoeffs = [];
    end
    
    psyfS.calInfo = calInfo;
  end
else
  psyfS.calAnswer = 'Unset';
end

psyfS.filesData = handles.Data;

% end constructSaveFilesStruct

%
% Load analyser settings
%
function LoadAnalyserSettings_Callback(hObject, eventdata, handles)

% Give the user a dialog to choose a filename
file = uigetfile({'*.psya', 'PsySound3 analyser (*.psya)'}, ...
                 'Load Analyser settings');

% Check for cancel
if isequal(file, 0)
  return;
end

% Make sure the file is in the current directory
if ~exist(file, 'file')
  errordlg([file, ' not found in the current directory: ', pwd, ...
            '.  Please change dir. and try again.']);
  return;
end

load('-mat', file);
if ~exist('aSettings', 'var')
  errordlg('This file does not contain analyser settings.');
  return
end

applyAnalyserSettingsStruct(handles, aSettings);

% end LoadAnalyserSettings_Callback

%
% Apply's the analyser settings struct
%
function handles = applyAnalyserSettingsStruct(handles, aSettings)

len = length(aSettings);

% Build up a structure array for each analyser
for i=1:len
  panel = [];
  name  = aSettings(i).name;
  for j=1:length(handles.SettingsPanel)
    panel = handles.SettingsPanel(j);
    aTag  = get(panel, 'Tag');
    
    if strcmp(aTag, name)
      break;
    end
  end
  
  if ~ishandle(panel)
    warning(['LoadAnalyserSettings: Analyser panel ', name, ' not found']);
    continue;
  end
  
  for k=1:length(aSettings(i).tags)
    tag = aSettings(i).tags{k};
    h   = findobj(panel, 'Tag', tag);
    if ~ishandle(h)
      warning(['LoadAnalyserSettings: Analyser settings tag ', ...
               tag, ' not found']);
      continue;
    end
    
    if strcmp(aSettings(i).style, 'edit')
      set(h, 'String', aSettings(i).string{k});
    else
      set(h, 'Value', aSettings(i).value{k});
    end
    
    % Trigger any callbacks
    cb = get(h, 'Callback');
    if ~isempty(cb)
      if ischar(cb)
        eval(cb);
      else
        % Assume function handle
        cb(h, []);
      end
    end
  end
end

% end applyAnalyserSettingsStruct

%
% Save analyser settings
% 
% Here, we could do the brute force thing and just save the entire
% panel as an hg object but that seems like an overkill and prone
% to unpredictable behaviour as some of these handles would've been
% cached in the handles struct.
%
% Also, I could key off of the index rather than enforce the need
% for valid tags but this way if new analysers are added, the old
% settings will still work.
%
function SaveAnalyserSettings_Callback(hObject, eventdata, handles)

aSettings = constructAnalyserSettingsStruct(handles);

% Give the user a dialog to choose a filename
[file, path] = uiputfile({'*.psya', 'PsySound3 analyser (*.psya)'}, ...
                         'Save Analyser settings as', 'Untitled.psya');

if ~isequal(file, 0) && ~isequal(path, 0)
  fName = [path, file];
  
  save(fName, '-mat', 'aSettings');
end

% end SaveAnalyserSettings_Callback

%
% Constructs the analyser settings' struct
%
function aSettings = constructAnalyserSettingsStruct(handles)

aSettings = [];
len       = length(handles.SettingsPanel);

% Build up a structure array for each analyser
for i=1:len
  panel = handles.SettingsPanel(i);
  
  % Find all checkboxes, popups and edits
  h = [];
  h = [h; findobj(panel, 'Style', 'checkbox')];
  h = [h; findobj(panel, 'Style', 'popup')];
  h = [h; findobj(panel, 'Style', 'edit')];

  % Make sure the tag is set
  name = get(panel, 'Tag');
  if isempty(name)
    error('Analyser Tag is not set!');
  end
  
  % Similarly with the saveables
  allTags = get(h, 'Tag'); if ~iscell(allTags), allTags = {allTags};end
  if any(cellfun(@isempty, allTags))
    error('Atleast some of the tags for Analyser settings are not set. ');
  end
  
  % Build struct
  aSettings(i).name   = name;
  aSettings(i).tags   = allTags;
  
  value = get(h, 'Value');
  if ~iscell(value)
    value = {value};
  end
  
  string = get(h, 'String');
  if ~iscell(string)
    string = {string};
  end
  
  style = get(h, 'Style');
  if ~iscell(style)
    style = {style};
  end
  
  aSettings(i).value  = value;
  aSettings(i).string = string;
  aSettings(i).style  = style;
end

% end constructAnalyserSettingsStruct

%
% Save project settings
%
% A project is File + Analyser settings. Perhaps we should
% incorporate Data analyser settings too?
function SaveProject_Callback(hObject, eventdata, handles)

% Give the user a dialog to choose a filename
[file, path] = uiputfile({'*.psyprj', 'PsySound3 projects (*.psyprj)'}, ...
                         'Save PsySound3 Project as', 'Untitled.psyprj');

if ~isequal(file, 0) && ~isequal(path, 0)
  fName = [path, file];

  % Files settings
  psyfS = constructSaveFilesStruct(handles);
  
  % Analyser settings
  aSettings = constructAnalyserSettingsStruct(handles);
  
  % Save
  save(fName, '-mat', 'aSettings', 'psyfS');
end

% end SaveProject_Callback

%
% Load project settings
%
function LoadProject_Callback(hObject, eventdata, handles) 
file = uigetfile({'*.psyprj', 'PsySound3 Projects (*.psyprj)'}, ...
                 'Load Project');

% Check for cancel
if isequal(file, 0)
  return;
end

% Make sure the file is in the current directory
if ~exist(file, 'file')
  errordlg([file, ' not found in the current directory: ', pwd, ...
            '.  Please change dir. and try again.']);
  return;
end

load('-mat', file);
if ~exist('psyfS', 'var') || ~exist('aSettings', 'var')
  errordlg('This file does not contain project settings.');
  return
end

% Apply file settings
applySaveFilesStruct(hObject, eventdata, handles, psyfS);

% Apply analyser settings
applyAnalyserSettingsStruct(handles, aSettings);

% end LoadProject_Callback

%
% Open preferences dialog box
%
function Preferences_Callback(hObject, eventdata, handles)

bgColor = [0.9 0.9 0.9];
d = dialog('WindowStyle', 'normal', ...
           'Color', bgColor, ...
           'Units', 'Normalized', ...
           'Name', 'PsySound3 Preferences');

p = getPsysound3Prefs;

% dataDir
uicontrol('Parent', d, ...
          'Style', 'text', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Position', [0.1 0.8 0.15 0.04], ...
          'HorizontalAlignment', 'right', ...
          'String', 'Data directory :');

uicontrol('Parent', d, ...
          'Style', 'text', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Tag', 'dataDir', ...
          'Position', [0.28 0.8 0.5 0.04], ...
          'HorizontalAlignment', 'left', ...
          'String', p.dataDir);

% ChangeDir
uicontrol('Parent', d, ...
          'Style', 'Pushbutton', ...
          'Units', 'normalized', ...
          'Position', [0.8 0.8 0.15 0.05], ...
          'Callback', @changePrefDir, ...
          'String', 'Change');

% Enable analyser animation
uicontrol('Parent', d, ...
          'Style', 'checkbox', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Position', [0.28 0.73 0.35 0.04], ...
          'Tag', 'showWaitBar', ...
          'HorizontalAlignment', 'left', ...
          'Value', p.showWaitBar, ...
          'String', 'Show analyser waitbar status');
% Cancel
uicontrol('Parent', d, ...
          'Style', 'Pushbutton', ...
          'Units', 'normalized', ...
          'Position', [0.8 0.05 0.15 0.08], ...
          'Callback', @(src, ev)close(d), ...
          'String', 'Cancel');

% Apply
uicontrol('Parent', d, ...
          'Style', 'Pushbutton', ...
          'Units', 'normalized', ...
          'Position', [0.65 0.05 0.15 0.08], ...
          'Callback', {@applyPrefs, handles},...
          'String', 'Apply');

% OK
uicontrol('Parent', d, ...
          'Style', 'Pushbutton', ...
          'Units', 'normalized', ...
          'Position', [0.5 0.05 0.15 0.08], ...
          'Callback', {@okPrefs, handles}, ...
          'String', 'OK');

% MultiChannel
uicontrol('Parent', d, ...
          'Style', 'text', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Position', [0.1 0.65 0.15 0.04], ...
          'HorizontalAlignment', 'right', ...
          'String', 'Multichannels :');

% Channel select popup
mctH = uicontrol('Parent', d, ...
                 'Style', 'popup', ...
                 'Units', 'normalized', ...
                 'BackGroundColor',  bgColor, ...
                 'FontSize',  9, ...
                 'Tag', 'multiChannelSelect', ...
                 'Value', p.multiChannelSelect, ...
                 'Position', [0.45 0.53 0.08 0.1], ...
                  'String', '1 (L)|2 (R)|3|4|5');

% Type popup
mcsH = uicontrol('Parent', d, ...
                 'Style', 'popup', ...
                 'Units', 'normalized', ...
                 'BackGroundColor',  bgColor, ...
                 'FontSize',  9, ...
                 'Tag', 'multiChannelType', ...
                 'Value', p.multiChannelType, ...
                 'Callback', {@multiCSelet, mctH}, ...
                 'CreateFcn', {@multiCSelet, mctH}, ...
                 'Position', [0.28 0.53 0.15 0.1], ...
                 'String', 'Average|Sum (mix)|Select -->');

% Combine streams
uicontrol('Parent', d, ...
          'Style', 'checkbox', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Tag', 'combineChannels', ...
          'Callback', {@cCcb, mcsH, mctH}, ...
          'CreateFcn', {@cCcb, mcsH, mctH}, ...
          'Value', p.combineChannels, ...
          'Enable', 'off', ...
          'ToolTipString', 'Uncombine is currently not supported', ...
          'Position', [0.28 0.65 0.25 0.04], ...
          'String', 'Combine channels');

% Calibration settings
uicontrol('Parent', d, ...
          'Style', 'text', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Position', [0.1 0.5 0.15 0.04], ..., ...
          'HorizontalAlignment', 'right', ...
          'String', 'Calibration :');

calNoteStr = ['Note: It is advisable to restart PsySound3 ', ...
  'if calibration is changed.'];

uicontrol('Parent', d, ...
          'Style', 'text', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Position', [0.66 0.3 0.25 0.15], ..., ...
          'HorizontalAlignment', 'left', ...
          'String', calNoteStr);

uibgrp = uibuttongroup('Parent', d, ...
                       'visible', 'off', ...
                       'BackGroundColor',  bgColor, ...
                       'SelectionChangeFcn', @toggleSPLEdit, ...
                       'Position', [0.28 0.3 0.35 0.25]);

uicontrol('Parent', uibgrp, ...
          'Style', 'Radio', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Tag', 'calibWithFiles', ...
          'Value', p.calibrationIndex{1}, ...
          'Position', [0.1 0.7 0.6 0.25], ...
          'String', 'With Files');

uicontrol('Parent', uibgrp, ...
          'Style', 'Radio', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Tag', 'calibWithoutFiles', ...
          'Value',  p.calibrationIndex{2}, ...
          'Position', [0.1 0.4 0.6 0.25], ...
          'String', 'Without Files');

uicontrol('Parent', uibgrp, ...
          'Style', 'Edit', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Tag', 'calibSPLEdit', ...
          'Position', [0.72 0.1 0.2 0.2], ...
          'String', p.calibrationLvl);

uicontrol('Parent', uibgrp, ...
          'Style', 'Radio', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  9, ...
          'Tag', 'calibSPL', ...
          'Value', p.calibrationIndex{3}, ...
          'Position', [0.1 0.1 0.6 0.25], ...
          'String', 'Set full-scale (dB):');

set(uibgrp, 'Visible', 'on');

% end Preferences_Callback

%
% Preference popup helpers
%
function toggleSPLEdit(src, ev)
h = findobj(src, 'Tag', 'calibSPLEdit');
enb = 'off';
if ~isempty(findstr(get(ev.NewValue, 'String'), 'Scale'))
  enb = 'on';
end

set(h, 'Enable', enb);

% end toggleSPLEdit

function multiCSelet(src, ev, h)

val = get(src, 'Value');

if val ~= 3
  set(h, 'Enable', 'off');
else
  set(h, 'Enable', 'on');
end

% end multiCSelet

function cCcb(src, ev, hs, ht)

if ~get(src,'Value')
  set([hs, ht], 'Enable', 'off');
else
  set(hs, 'Enable', 'on');
  multiCSelet(hs, [], ht);
end

% end cCcb

function changePrefDir(hObject, eventdata, handles)

p = getPsysound3Prefs;
dirName = uigetdir(fullfile(p.dataDir, '..'), 'Please select a directory');
h       = findobj(get(hObject, 'Parent'), 'Tag', 'dataDir');

set(h, 'String', fullfile(dirName, 'PsysoundData'));

% end changePrefDir

function applyPrefs(hObject, eventdata, handles)

prefs  = getPsysound3Prefs;
parent = get(hObject, 'Parent');

% dataDir
h = findobj(parent, 'Tag', 'dataDir');
p.dataDir = deblank(get(h, 'String'));

% WaitBarStatus
h = findobj(parent, 'Tag', 'showWaitBar');
p.showWaitBar = get(h, 'Value');

% multiChannelType
h = findobj(parent, 'Tag', 'multiChannelType');
p.multiChannelType = get(h, 'Value');

% multiChannelSelect
h = findobj(parent, 'Tag', 'multiChannelSelect');
p.multiChannelSelect = get(h, 'Value');

% combineChannels
h = findobj(parent, 'Tag', 'combineChannels');
p.combineChannels = get(h, 'Value');

% Calibration
h = [];
% NOTE: ORDER is VERY important!
h(1) = findobj(parent, 'Tag', 'calibWithFiles');
h(2) = findobj(parent, 'Tag', 'calibWithoutFiles');
h(3) = findobj(parent, 'Tag', 'calibSPL');
p.calibrationIndex = get(h, 'Value');
h = findobj(parent, 'Tag', 'calibSPLEdit');
p.calibrationLvl = get(h, 'String');

% Save
setPsysound3Prefs(p);

% Call this to refresh the Calibration button, if neccassary
% NOTE: Alternatively, we may throw up a warning that changes will take
%       effect at the next restart as then we could 
if handles.UiPanelNumber == 2
  % Go to next step
  handles.UiPanelNumber = 3;
  handles = DisplayUIPanel(handles);
  guidata(hObject,handles);
else
  % Just refresh
  DisplayUIPanel(handles);
end

% end applyPrefs

function okPrefs(hObject, eventdata, handles)

p = get(hObject, 'Parent');

% Call Apply
applyPrefs(hObject, eventdata, handles);

close(p);

% end okPrefs

%%%%%%%%%%%%%%%%
% About Dialog %
%%%%%%%%%%%%%%%%
function About_Callback(hObject, eventdata, handles)

bgColor = [0.9 0.9 0.9];
bgColor2 = [0.97 1 1];
d = dialog('WindowStyle', 'normal', ...
	'Color', bgColor, ...
	'Units', 'Normalized', ...
	'Name', 'About PsySound3');

cr = sprintf('\n');
pos = [0.1 0.9 0.8 0.08];
txt = 'PsySound3';
uicontrol('Parent', d, ...
	'Style', 'text', ...
	'Units', 'normalized', ...
	'BackGroundColor',  bgColor, ...
	'FontSize',  20, ...
	'Position', pos, ...
	'HorizontalAlignment', 'left', ...
	'String', txt);

% Adjust height
pos(4) = 0.1;
% Move down
pos(2) = pos(2) - pos(4) - 0.01;

txt = ['Audio analysis software', cr, ...
       'Project Copyright Densil Cabrera, University of Sydney, Australia 2008'];
uicontrol('Parent', d, ...
          'Style', 'text', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor, ...
          'FontSize',  10, ...
          'Position', pos, ...
          'FontWeight', 'Bold', ...
          'HorizontalAlignment', 'left', ...
          'String', txt);

% Adjust height
pos(4) = 0.7;
% Move down
pos(2) = pos(2) - pos(4) - 0.01;

txt = {' ', ...
       'PsySound3 is free open source software',  ...
       'for the analysis of sound recordings.',  ...
       ' ',  ...
       'The PsySound3 team:',  ...
       '  Densil Cabrera (University of Sydney)',  ...
       '  Sam Ferguson (University of Sydney)',  ...
       '  Farhan Rizwi (University of New South Wales)',  ...
       '  Emery Schubert (University of New South Wales)',  ...
       ' ',  ...
       'Acknowledgements',  ...
       '  PsPsySound3 was developed with financial support from:', ...
       '  Australian Research Council LIEF grant LE0668448 and', ...
       '  The University of New South Wales via its', ...
       '  Strategic Investment in Research Scheme.',  ...
       ' ',  ...
       'The following additional people contributed to or supported the ', ...
       '  initial version of PsySound3:',  ...
       '  Jens Brosbol, Josef Chalupper, Matt Flax,  Dik Hermes,',  ...
       '  Shin-ichi Sato, Alex Tarnopolsky, Ernst Terhardt',  ...
       ' ',  ...
       'The team gratefully acknowledge all those who gave ',...
       '  permission to use their code in PsySound3.',  ...
       ' ',  ...
       'Code copyright remains with contributors.',  ...
       ' ',  ...
       'Disclaimer',  ...
       '  This software comes as is, without implied or ', ...
       '  actual guarantee.  Contributions of software are ', ...
       '  not all by the authors.',  ...
       ' ',  ...
       'The initial publication about this program is: ',  ...
       '  Densil Cabrera, Sam Ferguson and Emery Schubert, ', ...
       '  "PsySound3: software for acoustical and psychoacoustical ', ...
       '  analysis of sound recordings"', ...
       '  Proceedings of the 13th International Conference on Auditory ', ...
       '  Display, Montreal Canada, June 26-29 2007, pp. 356-363.', ...
       ' ',  ...
       'Project url: http://www.psysound.org',  ...
       ' '};

uicontrol('Parent', d, ...
          'Style', 'listbox', ...
          'Units', 'normalized', ...
          'BackGroundColor',  bgColor2, ...
          'FontSize',  9, ...
          'Position', pos, ...
          'HorizontalAlignment', 'left', ...
          'String', txt);

% end About_Callback

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Choose Displayed Panel %
%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Step 1 button
%
function Files_Callback(hObject, eventdata, handles) 
% This opens the file selection panel
handles.UiPanelNumber = 1;
handles = DisplayUIPanel(handles);
guidata(hObject,handles);
%end Files_Callback

%
% Step 2 button
%
function Calibration_Callback(hObject, eventdata, handles) 
% This opens the calibration file selection panel

p = getPsysound3Prefs;
if p.calibrationIndex{1}
  calAnswer = 'With Files';
elseif p.calibrationIndex{2}
  calAnswer = 'Without Files';
else
  % Should never get in here
  error('There is a problem with calibration handling');
end

handles.calAnswer = calAnswer;
handles.UiPanelNumber = 2;
handles = DisplayUIPanel(handles);

% Chuck the filenames in a cell array
try
    ht     = getTableModel(handles.Table);
catch
    ht     = getTableModel(handles.mtable);
end
    fnames = {};
for i = 0:getRowCount(ht)-1
  fnames{end+1} = getValueAt(ht, i, 0);
end

% Create a list of filehandles
if length(fnames) > 0 && ~(isempty(fnames{1}))
  fhs = readData(fnames);
  handles.fileHandles = fhs;
else
  handles.fileHandles = [];
end

guidata(hObject,handles);

% end Calibration_Callback

%
% Step 3 button
%
function Analysers_Callback(hObject, eventdata, handles) 
% This opens the analyser selection panel
handles.UiPanelNumber = 3;
handles = DisplayUIPanel(handles);
guidata(hObject,handles);

% update the modules
ModuleListUpdate_Callback(hObject, eventdata, handles);

%end Analysers_Callback

%
% Step 4 button
%
function PostProcessing_Callback(hObject, eventdata, handles) 
% This opens the Postprocessing selection panel
handles.UiPanelNumber = 4;
handles = DisplayUIPanel(handles);
guidata(hObject,handles);
% end PostProcessing_Callback
