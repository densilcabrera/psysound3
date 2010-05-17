function handles = InitialiseUI(handles)
%% Initialise all the UI panels as invisible.
%
% This file adds a set of uipanel handles to a parent figure, which can be
% made visible by another function as they are needed. It is where the
% layout of the panels is set up, and then each panel is made visible
% as it is needed.

% In 7.3 the character width is different to 7.2.
% Thus the width of a character has to be compared.
% This is also true of windows.

SizeInChars = get(handles.figure1,'Position');
set(handles.figure1,'Units','pixels');
SizeInPixels = get(handles.figure1,'Position');
set(handles.figure1,'Units','Characters');
set(handles.figure1,'Color',[0.9 0.9 0.9]);
% Work out the height of a Character
CharacterWidth = SizeInPixels(3)/SizeInChars(3);
CharacterHeight = SizeInPixels(4)/SizeInChars(4);
% The GUI was designed with a character 6 by 12 pixels hi, so set
% adjustment variables.
CharWide = 6/CharacterWidth;
CharHi = 12/CharacterHeight;
if (~(CharacterWidth==6&CharacterHeight==12))
  SizeInChars(3) = SizeInChars(3)*CharWide;
  SizeInChars(4) = SizeInChars(4)*CharHi;
  set(handles.figure1,'Position',SizeInChars);
end

buttonWidth = 15*CharWide;
buttonHeight = 2*CharHi;
handles.CharWide = CharWide;
handles.CharHi = CharHi;
guidata(handles.figure1, handles);

% Variables used for consistent placement and sizing
columnOneLeft = 1*CharWide;
columnTwoLeft = 64*CharWide;
buttonLeft = 48.3*CharWide;
columnWidth = 46*CharWide;

bgColor = [0.9 0.9 0.9];

%%%%%%%%%%%%%%%%%%%%%%%%
% Instructions UIPanel %
%%%%%%%%%%%%%%%%%%%%%%%%

handles.ProgressPanel = uipanel('Parent',handles.figure1,'Title','Instructions','FontSize',9,'Units','Characters',...
  'Position',[3*CharWide 1*CharHi 157*CharWide 5*CharHi],'Tag','ProgressPanel','Visible','on','BackgroundColor',bgColor);
handles.Files = uicontrol('Parent',handles.ProgressPanel ,'Style','pushbutton','Units','Characters',...
  'Position',[95*CharWide 0.2 buttonWidth buttonHeight],'String','Files','Tag','Files','Callback','PsySoundGUI(''Files_Callback'',gcbo,[],guidata(gcbo))');
handles.Calibration = uicontrol('Parent',handles.ProgressPanel ,'Style','pushbutton','Units','Characters',...
  'Position',[110*CharWide 0.2 buttonWidth buttonHeight],'String','Calibration','Tag','Calibration','Callback','PsySoundGUI(''Calibration_Callback'',gcbo,[],guidata(gcbo))');
handles.Analysers = uicontrol('Parent',handles.ProgressPanel ,'Style','pushbutton','Units','Characters',...
  'Position',[125*CharWide 0.2 buttonWidth buttonHeight],'String','Analysers','Tag','Analysers','Callback','PsySoundGUI(''Analysers_Callback'',gcbo,[],guidata(gcbo))');
handles.PostProcessing = uicontrol('Parent',handles.ProgressPanel ,'Style','pushbutton','Units','Characters',...
  'Position',[140*CharWide 0.2 buttonWidth buttonHeight],'String','PostProcessing','Tag','PostProcessing','Callback','PsySoundGUI(''PostProcessing_Callback'',gcbo,[],guidata(gcbo))');
handles.FilesLabel = uicontrol('Parent',handles.ProgressPanel,'Style','text','Units','Characters','FontSize',9,...
  'Position',[96*CharWide buttonHeight+0.5 15 1],'String','Step 1','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.CalibrationLabel = uicontrol('Parent',handles.ProgressPanel,'Style','text','Units','Characters','FontSize',9,...
  'Position',[111*CharWide buttonHeight+0.5  15 1],'String','Step 2','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.AnalysersLabel = uicontrol('Parent',handles.ProgressPanel,'Style','text','Units','Characters','FontSize',9,...
  'Position',[126*CharWide buttonHeight+0.5 15 1],'String','Step 3','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.PostProcessingLabel = uicontrol('Parent',handles.ProgressPanel,'Style','text','Units','Characters','FontSize',9,...
  'Position',[141*CharWide buttonHeight+0.5 15 1 ],'String','Step 4','HorizontalAlignment','Left','BackgroundColor',bgColor);

handles.AssistString = uicontrol('Parent',handles.ProgressPanel,'Style','text','Units','Characters','FontSize',9,...
  'Position',[1*CharWide 0.2*CharHi 93*CharWide 3*CharHi],'String','','HorizontalAlignment','Left','BackgroundColor',bgColor);

%%%%%%%%%%%%%%%%%%%%%%%
% File Choice UIPanel %
%%%%%%%%%%%%%%%%%%%%%%%

handles.FileChoicePanel = uicontainer('Parent',handles.figure1,'Units','Characters',...
  'Position',[3 6*CharHi 112 42*CharHi],'Tag','FileChoicePanel','Visible','on','BackgroundColor',bgColor);
% Buttons
handles.ChangeDirectory = uicontrol('Parent',handles.FileChoicePanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 37.5*CharHi buttonWidth buttonHeight],'String','Change Dir','Tag','ChangeDirectory',...
  'Callback','PsySoundGUI(''ChangeDirectory_Callback'',gcbo,[],guidata(gcbo))',...
  'Tooltip','This button will change the directory that PsySound searches for files');
handles.AddFile = uicontrol('Parent',handles.FileChoicePanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 25*CharHi buttonWidth buttonHeight],'String','Add File','Tag','AddFile','Callback','PsySoundGUI(''AddFile_Callback'',gcbo,[],guidata(gcbo))');
handles.RemoveFile = uicontrol('Parent',handles.FileChoicePanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 23*CharHi buttonWidth buttonHeight],'String','Remove File','Tag','RemoveFile','Callback','PsySoundGUI(''RemoveFile_Callback'',gcbo,[],guidata(gcbo))');
handles.ClearAll = uicontrol('Parent',handles.FileChoicePanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 21*CharHi buttonWidth buttonHeight],'String','Clear Chosen','Tag','ClearAll','Callback','PsySoundGUI(''ClearAll_Callback'',gcbo,[],guidata(gcbo))');
handles.PlayFile = uicontrol('Parent',handles.FileChoicePanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 27*CharHi buttonWidth buttonHeight],'String','Play File','Tag','PlayFile','Callback','PsySoundGUI(''CurrentDirPlayFile_Callback'',gcbo,[],guidata(gcbo))');
% UiPanel and Text Objects
handles.FileInfoPanel = uipanel('Parent',handles.FileChoicePanel,'Title','File Information','FontSize',9,'Units','Characters',...
  'Position',[columnOneLeft 1*CharHi columnWidth 8*CharHi],'Tag','FileInfoPanel','Visible','on','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[1 0.5 12 1],'String','Channels:','HorizontalAlignment','Right','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[1 1.5 12 1],'String','Bit Depth:','HorizontalAlignment','Right','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[1 2.5 12 1],'String','Sample Rate:','HorizontalAlignment','Right','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[1 3.5 12 1],'String','Length:','HorizontalAlignment','Right','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[1 4.5 12 1],'String','Filename:','HorizontalAlignment','Right','BackgroundColor',bgColor);
handles.CurrentDirChannels = uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[14 0.5 25 1],'String','','Tag','CurrentDirChannels','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.CurrentDirBitDepth = uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[14 1.5 25 1],'String','','Tag','CurrentDirBitDepth','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.CurrentDirSampleRate = uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[14 2.5 25 1],'String','','Tag','CurrentDirSampleRate','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.CurrentDirLength = uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[14 3.5 25 1],'String','','Tag','CurrentDirLength','HorizontalAlignment','Left','BackgroundColor',bgColor);
handles.CurrentDirFileName = uicontrol('Parent',handles.FileInfoPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[14 4.5 25 1],'String','','Tag','CurrentDirFileName','HorizontalAlignment','Left','BackgroundColor',bgColor);
% List Boxes
handles.CurrentDir = uicontrol(...
    'Parent', handles.FileChoicePanel, ...
    'Style', 'listbox', ...
    'Units', 'Characters',...
    'Position', [columnOneLeft 9.5*CharHi columnWidth 27*CharHi], ...
    'String', '', ...
    'Tag', 'CurrentDir', ...
    'HorizontalAlignment', 'Right',...
    'FontSize',9, ...
    'Max', 50, ...
    'BackgroundColor', bgColor,...
    'CreateFcn', ...
   'PsySoundGUI(''CurrentDir_CreateFcn'',gcbo,[],guidata(gcbo))',...
    'Callback', ...
    'PsySoundGUI(''CurrentDir_Callback'',gcbo,[],guidata(gcbo))');

handles.CurrentDirPath = uicontrol('Parent',handles.FileChoicePanel,'Style','listbox','Units','Characters',...
  'Position',[columnOneLeft 38.2*CharHi columnWidth 1.5*CharHi],'String','','Tag','CurrentDirPath','HorizontalAlignment','Right',...
  'FontSize',9,'Enable','on','BackgroundColor',bgColor,...
  'CreateFcn','PsySoundGUI(''CurrentDirPath_CreateFcn'',gcbo,[],guidata(gcbo))');
% List Box Labels
uicontrol('Parent',handles.FileChoicePanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[columnOneLeft 40*CharHi 40 1.2*CharHi],'String','Current Directory:','Tag','label31','HorizontalAlignment','Left','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileChoicePanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[columnTwoLeft 39.7*CharHi 12 1*CharHi],'String','Files Chosen:','Tag','label31','HorizontalAlignment','Left','BackgroundColor',bgColor);
uicontrol('Parent',handles.FileChoicePanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[columnOneLeft 36.8*CharHi 40 1.2*CharHi],'String','Files in Current Directory:','Tag','label31','HorizontalAlignment','Left','BackgroundColor',bgColor);

% UITable
v = ver;
handles.DataHeaders = {'Files'};
currentdate = 1;
verdate = 1;
dateError = 0;

try 
  currentdate = datenum(v(1).Date);
  verdate     = datenum('01-Jan-2008');
catch
  dateError = 1;
end

if (currentdate > verdate || dateError == 1)
    handles.Table = uitable('v0',handles.figure1, {' ',' ',' '}, {'Files','Level','Adjustment'});
    handles.mtable  = handles.Table.getTable;
    % Java to make table not editable. Otherwise people try to change stuff with the keyboard - not the best way.
    set(handles.Table,'NumRows',0);
    setEditable(handles.Table,0);

    % This is a bit strange, as uitable refuses to take Units as Characters.
    handles.Table.setPosition([columnTwoLeft*CharacterWidth*1.05 87 columnWidth*CharacterWidth*2 460]);
    %handles.DataHeaders = {'Files'};
    %setColumnNames(handles.Table,handles.DataHeaders);
    %setColumnWidth(handles.Table,150);    
else  
    handles.Table = uitable('Parent', handles.figure1);
    % Java to make table not editable. Otherwise people try to change stuff
    % with the keyboard - not the best way.
    setEditable(handles.Table,0);

    % This is a bit strange, as uitable refuses to take Units as Characters.
    set(handles.Table,'Position',[columnTwoLeft*CharacterWidth*1.05 87 columnWidth*CharacterWidth*2 460]);
    setColumnNames(handles.Table,handles.DataHeaders);
    setColumnWidth(handles.Table,150);
end


%%%%%%%%%%%%%%%%%%%%%%%
% Calibration UIPanel %
%%%%%%%%%%%%%%%%%%%%%%%

handles.CalPanel = uicontainer('Parent',handles.figure1,'Units','Characters',...
  'Position',[3 6*CharHi 112 42*CharHi],'Tag','CalPanel','Visible','off','BackgroundColor',bgColor);
%Buttons
handles.AssociateFile = uicontrol('Parent',handles.CalPanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 27*CharHi buttonWidth buttonHeight],'String','Associate File','Tag','AssociateFile','Callback','PsySoundGUI(''AssociateFile_Callback'',gcbo,[],guidata(gcbo))');
handles.RemoveAssoc = uicontrol('Parent',handles.CalPanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 25*CharHi buttonWidth buttonHeight],'String','Disassociate','Tag','RemoveAssociation','Callback','PsySoundGUI(''RemoveAssociation_Callback'',gcbo,[],guidata(gcbo))');
handles.ClearAssoc = uicontrol('Parent',handles.CalPanel,'Style','pushbutton','Units','Characters',...
  'Position',[buttonLeft 23*CharHi buttonWidth buttonHeight],'String','Clear All','Tag','ClearAssoc','Callback','PsySoundGUI(''ClearAssoc_Callback'',gcbo,[],guidata(gcbo))');
% UiPanels
handles.CalFileDiagnostics = uipanel('Parent',handles.CalPanel,'FontSize',9,'Title','Calibration Details','Units','Characters',...
  'Position',[columnOneLeft 1*CharHi columnWidth 13*CharHi],'Tag','CalAdjustmentPanel','Visible','on','BackgroundColor',bgColor);
handles.CalFileAxes =   axes('Parent',handles.CalFileDiagnostics,'FontSize',9,'Units','Characters',...
  'Position',[6 4*CharHi columnWidth-9 7*CharHi],'Tag','CalAxes','Visible','on');
ylabel(handles.CalFileAxes,'SPL Zf (dB)');
handles.CalFileAnalyse = uicontrol('Parent',handles.CalFileDiagnostics,'Style','pushbutton','Units','Characters',...
  'Position',[1 0.5 buttonWidth buttonHeight],'String','Analyse','Tag','CalFileAnalyse','Callback','PsySoundGUI(''CalFileAnalyse_Callback'',gcbo,[],guidata(gcbo))');
% List Boxes
handles.CalFilesLeft = uicontrol('Parent',handles.CalPanel,'Style','listbox','FontSize',9,'Units','Characters',...
  'Position',[columnOneLeft 14.5*CharHi columnWidth 25*CharHi],'String','','Tag','CalFilesLeft','HorizontalAlignment','Right',...
  'BackgroundColor',bgColor,...
  'CreateFcn','PsySoundGUI(''CalFilesLeft_CreateFcn'',gcbo,[],guidata(gcbo))',...
  'Callback','PsySoundGUI(''CalFilesLeft_Callback'',gcbo,[],guidata(gcbo))');
% List Box Labels
uicontrol('Parent',handles.CalPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[columnOneLeft 39.5*CharHi 20 1],'String','Calibration Files:','HorizontalAlignment','Left','BackgroundColor',bgColor);
uicontrol('Parent',handles.CalPanel,'Style','text','FontSize',9,'Units','Characters',...
  'Position',[columnTwoLeft 39.5*CharHi 50 1],'String','Files needing Calibration:','HorizontalAlignment','Left','BackgroundColor',bgColor);

%%%%%%%%%%%%%%%%%%%%%%%%%%
% No Calibration UIPanel %
%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.AdjustmentPanel = uicontainer(...
    'Parent', handles.figure1, ...
    'Units', 'Characters',...
    'Position', [3 6*CharHi 112 42*CharHi], ...
    'Tag', 'CalPanel', ...
    'Visible', 'off', ...
    'BackgroundColor',bgColor);

handles.CalFileAdjustment = uipanel(...
    'Parent', handles.AdjustmentPanel, ...
    'FontSize', 9, ...
    'Title', 'Calibration Adjustment', ...
    'Units', 'Characters',...
    'Position', [columnOneLeft 1 columnWidth 39*CharHi], ...
    'Tag', 'CalAdjustmentPanel', ...
    'Visible', 'on', ...
    'BackgroundColor',bgColor);

% Buttons
textString = ['You may standardise the level of these set ' ...
              'of files based on a number of parameters:'];

uicontrol('Parent', handles.CalFileAdjustment, ...
          'Style', 'text', ...
          'Units','Characters', ...
          'HorizontalAlignment','Left',...
          'Position',[1 32*CharHi  40*CharWide 5*CharHi], ...
          'String', textString, ...
          'Tag', 'Standardise', ...
          'BackgroundColor',bgColor);

handles.Standardise = uicontrol(...
    'Parent', handles.CalFileAdjustment, ...
    'Style', 'pushbutton', ...
    'Units','Characters',...
    'Position', [30*CharWide 1*CharHi buttonWidth buttonHeight], ...
    'String', 'Standardise', ...
    'Tag', 'Standardise', ...
    'Callback', ...
'PsySoundGUI(''Standardise_Callback'',gcbo,[],guidata(gcbo))','Enable','off');

handles.ChosenMethod = uicontrol(...
    'Parent', handles.CalFileAdjustment, ...
    'Style', 'popupmenu', ...
    'Units', 'Characters',...
    'Position', [1 27*CharHi buttonWidth*2 buttonHeight], ...
    'String', ['Please select ...|', ...
               'To Sound Pressure Level of...|', ...
               'To Median Level of Set of Files|',...
               'To Maximum Level of Set of Files|',...
               'To Minimum Level of Set of Files |',...
               'Adjust level by constant...|',...
               'No Change'], ...
    'Tag', 'ChosenMethod', ...
    'BackgroundColor',bgColor,...
    'Callback','PsySoundGUI(''ChosenMethod_Callback'',gcbo,[],guidata(gcbo))');

handles.ChosenLevel = uicontrol(...
    'Parent', handles.CalFileAdjustment, ...
    'Style', 'edit', ...
    'Units', 'Characters',...
    'Position', [1 25*CharHi buttonWidth/2 1.5*CharHi], ...
    'String', 70.0, ...
    'Tag', 'ChosenLevel', ...
    'BackgroundColor', bgColor, ...
    'HorizontalAlignment','Right', ...
    'Enable','off');

uicontrol('Parent',handles.CalFileAdjustment, ...
          'Style', 'text', ...
          'Units','Characters', ...
          'HorizontalAlignment', 'Left',...
          'Position', [1+buttonWidth/2 25*CharHi  3 1], ...
          'String', 'dB', ...
          'BackgroundColor',bgColor,'FontSize',9);

handles.ChosenFilter = uicontrol(...
    'Parent', handles.CalFileAdjustment, ...
    'Style', 'popupmenu', ...
    'Units','Characters',...
    'Position', [1+buttonWidth/2+3 25*CharHi buttonWidth*1.3 1.5*CharHi],...
    'String', ['Unweighted (Z)|', ...
               'A-weighted|',...
               'B-weighted|',...
               'C-weighted'], ...
    'Tag', 'Filter', ...
    'BackgroundColor', bgColor, ...
    'Enable','off');

%%%%%%%%%%%%%%%%%%%%%%%%%%
% Analysis Setup UIPanel %
%%%%%%%%%%%%%%%%%%%%%%%%%%

handles.AnalysisSetupPanel = uicontainer(...
    'Parent', handles.figure1, ...
    'Units', 'Characters',     ...
    'Position', [3*CharWide 6*CharHi 160*CharWide 42*CharHi], ...
    'Tag', 'AnalysisSetupPanel', ...
    'Visible', 'off', ...
    'BackgroundColor',bgColor);

moduleNames = getAnalysers;

handles.ModuleList = uicontrol(...
    'Parent', handles.AnalysisSetupPanel, ...
    'Style', 'listbox', ...
    'FontName', 'Monospaced', ...
    'FontSize', 9, ...
    'Units', 'Characters',...
    'Position',[columnOneLeft 8.5*CharHi columnWidth 31*CharHi], ...
    'Tag', 'ModuleList', ...
    'HorizontalAlignment', 'Right',...
    'BackgroundColor', bgColor, ...
    'CreateFcn', ...
    'PsySoundGUI(''ModuleList_CreateFcn'',gcbo,[],guidata(gcbo))',...
    'Callback', ...
    'PsySoundGUI(''ModuleList_Callback'',gcbo,[],guidata(gcbo))','Max',1);

handles.ModuleListLabel = uicontrol(...
    'Parent', handles.AnalysisSetupPanel, ...
    'Style', 'text', ...
    'FontSize', 9, ...
    'Units', 'Characters',...
    'Position', [columnOneLeft-1 39.6*CharHi 15*CharWide 1*CharHi], ...
    'String', 'Modules Available:', 'BackgroundColor',bgColor);

for i = 1:length(moduleNames)
  % Create an empty (default) Analyser object
  obj = eval(moduleNames{i});
  handles.SettingsPanel(i) = uipanel(...
      'Parent',  handles.AnalysisSetupPanel, ...
      'FontSize', 9, ...
      'Title', 'Analyser Settings', ...
      'Units', 'Characters',...
      'Position', [52*CharWide 1*CharHi 52*CharWide 39*CharHi], ...
      'Tag', char(moduleNames(i)), ...
      'Visible', 'off', 'BackgroundColor',bgColor);

  % Name
  uicontrol('Style', 'text', ...
            'FontSize', 12, ...
            'String', get(obj, 'Name'),...
            'Parent', handles.SettingsPanel(i), ...
            'Units','Characters',...
            'Position', [1*CharWide 34*CharHi 50*CharWide 1.75*CharHi], ...
            'Value', 1, ...
            'BackgroundColor', bgColor, ...
            'HorizontalAlignment','left');
% 
%   % Authors
%   authStr = getAuthors(obj);
%   if ~isempty(authStr)
%     uicontrol('Style', 'text', ...
%               'FontSize', 10, ...
%               'String', 'Authors: ',...
%               'Parent', handles.SettingsPanel(i), ...
%               'Units', 'Characters',...
%               'FontAngle', 'italic', ...
%               'Position', [1*CharWide 32.5*CharHi 35*CharWide 1.2*CharHi], ...
%               'Value', 1, ...
%               'BackgroundColor', bgColor, ...
%               'HorizontalAlignment','left');
% 
%     uicontrol('Style','text', ...
%               'FontSize', 9, ...
%               'String', authStr, ...
%               'Parent', handles.SettingsPanel(i), ...
%               'Units', 'Characters',...
%               'Position', [1*CharWide 28*CharHi 35*CharWide 4*CharHi], ...
%               'Value', 1, ...
%               'BackgroundColor', bgColor, ...
%               'HorizontalAlignment','left');
%   end
  
  % Description
  descStr = getDescription(obj);
  if ~isempty(descStr);
    uicontrol('Style', 'text', ...
              'FontSize', 9, ...
              'String', 'Description: ',...
              'Parent', handles.SettingsPanel(i), ...
              'Units', 'Characters',...
              'FontAngle', 'italic', ...
              'Position', [1*CharWide 33*CharHi 20*CharWide 1.2*CharHi], ...
              'Value', 1, ...
              'BackgroundColor', bgColor, ...
              'HorizontalAlignment','left');
    
    uicontrol('Style', 'listbox', ...
              'FontSize', 9, ...
              'String', descStr, ...
              'Parent', handles.SettingsPanel(i), ...
              'Units', 'Characters',...
              'Position', [1*CharWide 25*CharHi 50*CharWide 8*CharHi], ...
              'Value', 1, ...
              'BackgroundColor', bgColor, ...
              'HorizontalAlignment','left');
  end
  
  % Call the ui method to add any extra parameters
  ui(obj, handles.SettingsPanel(i));
  
  % Add the checkbox last so that we can run update
  % Checkbox
  uicontrol('Style', 'checkbox', ...
            'FontSize', 9, ...
            'String', 'Process files using this analyser.',...
            'Parent', handles.SettingsPanel(i), ...
            'Tag', strcat(char(moduleNames(i)),'Enable'), ...
            'Units', 'Characters',...
            'Position', [1*CharWide 36*CharHi 35*CharWide 1.5*CharHi], ...
            'Value', 0, ...
            'BackgroundColor',bgColor,...
            'Callback', ...
  'PsySoundGUI(''ModuleListUpdate_Callback'',gcbo,[],guidata(gcbo))',...
  'CreateFcn', ...
  'PsySoundGUI(''ModuleListUpdate_Callback'',gcbo,[],guidata(gcbo))');

end

handles.Summary = uicontrol(...
    'Parent', handles.AnalysisSetupPanel, ...
    'Style', 'listbox', ...
    'FontSize', 9, ...
    'FontName', 'monospaced' ,...
    'Units', 'Characters',...
    'Position', [108*CharWide 12.5*CharHi columnWidth+2 27*CharHi], ...
    'String', {'Choose analysers by ticking tickboxes, ' 'and press ''Run Analysis''.'}, ...
    'Tag', 'Summary', ...
    'HorizontalAlignment', 'Right',...
    'Selected' ,'off',...
    'BackgroundColor',bgColor);

handles.ResamplingPanel = uipanel(...
    'Parent', handles.AnalysisSetupPanel, ...
    'FontSize', 9, ...
    'Title', 'Analysis Actions', ...
    'Units', 'Characters',...
    'Position', [108*CharWide 1*CharHi columnWidth+2 11*CharHi], ...
    'Tag', 'ResamplingPanel', ...
    'Visible', 'on', ...
    'BackgroundColor',bgColor);

% handles.TimeEstimate = uicontrol(...
%     'Parent', handles.ResamplingPanel, ...
%     'Style', 'pushbutton', ...
%     'Units', 'Characters',...
%     'Position', [1*CharWide 4.5 1.2*buttonWidth buttonHeight], ...
%     'String', 'Time Estimate', ...
%     'Tag', 'TimeEstimate', ...
%     'Callback',  ...
%         'PsySoundGUI(''TimeEstimate_Callback'',gcbo,[],guidata(gcbo))');

handles.RunAnalysis = uicontrol(...
    'Parent', handles.ResamplingPanel, ...
    'Style', 'pushbutton', ...
    'Units', 'Characters',...
    'Position', [1*CharWide 1.5 1.2*buttonWidth buttonHeight], ...
    'String', 'Run Analysis', ...
    'Tag', 'Run_Analysis', ...
    'Callback', 'PsySoundGUI(''RunAnalysis_Callback'',gcbo,[],guidata(gcbo))');

% Specialised Waitbars
wBarPos = [1.5*buttonWidth 0 20 1];
wBarText = {'Buffer', 'Analyser', 'File'};
for i=1:3
  wBarPos(2) = 1 + (i-1)*2.5;
  handles.waitBarBuffer(i) = axes( ...
      'Parent', handles.ResamplingPanel, ...
      'Units', 'Characters',...
      'Position', wBarPos, ...
      'Box', 'on',...
      'XLim',[0 100],...
      'YLim',[0 1],...
      'XTickMode','manual',...
      'YTickMode','manual',...
      'XTick',[],...
      'YTick',[],...
      'XTickLabelMode','manual',...
      'XTickLabel',[],...
      'YTickLabelMode','manual',...
      'YTickLabel',[]);

  textPos = wBarPos;
  textPos(2) = textPos(2) + 1;
  handles.waitBarText(i) = uicontrol(...
      'Parent',          handles.ResamplingPanel, ...
      'Style',           'text', ...
      'FontSize',        9, ...
      'Units',           'Characters',...
      'Position',        textPos, ...
      'String',          wBarText{i}, ...
      'HorizontalAlignment','Center',...
      'BackgroundColor', bgColor);
end

% Synchronisation UIPanel
handles.SynchronisationPanel = uipanel(...
    'Parent', handles.AnalysisSetupPanel, ...
    'FontSize', 9, ...
    'Title', 'Data Synchronisation', ...
    'Units','Characters',...
    'Position', [columnOneLeft 1*CharHi columnWidth 7*CharHi], ...
    'Tag', 'SynchronisationPanel', ...
    'Visible','on', ...
    'BackgroundColor',bgColor);

handles.SynchronisationTickbox = uicontrol(...
    'Parent', handles.SynchronisationPanel, ...
    'Style', 'checkbox', ...
    'Units', 'Characters', ...
    'FontSize',        9, ...
    'BackgroundColor', bgColor, ...
    'Value',0,...
    'Position', [1*CharWide 4*CharHi 20*CharWide buttonHeight], ...
    'String', 'Synchronise Data', ...
    'Tag', 'SynchronisationTickbox', ...
    'Enable', 'on', ...
    'Callback', ...
        'PsySoundGUI(''SynchronisationTickbox_Callback'',gcbo,[],guidata(gcbo))');

handles.SynchronisationText(1) = uicontrol(...
    'Parent', handles.SynchronisationPanel, ...
    'Style', 'text', ...
    'Units', 'Characters', ...
    'FontSize',        9, ...
    'BackgroundColor', bgColor,...
    'HorizontalAlignment', 'left', ...
    'Position', [1*CharWide 2.5*CharHi 20*CharWide 1*CharHi], ...
    'Enable','off', ...
    'String', 'Choose synchronisation');

handles.SynchronisationText(2) = uicontrol(...
    'Parent', handles.SynchronisationPanel, ...
    'Style', 'text', ...
    'Units', 'Characters', ...
    'FontSize',        9, ...
    'BackgroundColor', bgColor,...
    'HorizontalAlignment', 'left', ...
    'Position', [1*CharWide 0.3*CharHi 6*CharWide 1.5*CharHi], ...
    'Enable','off', ...
    'String', 'period:');

handles.SynchronisationText(3) = uicontrol(...
    'Parent', handles.SynchronisationPanel, ...
    'Style', 'text', ...
    'Units', 'Characters', ...
    'FontSize',        9, ...
    'BackgroundColor', bgColor,...
    'HorizontalAlignment', 'left', ...
    'Position', [23*CharWide 0.7*CharHi 21*CharWide 5*CharHi], ...
    'Enable','off', ...
    'String', ['Note: Window overlap user setting will no longer be used.']);

handles.SynchronisationPopup = uicontrol(...
    'Parent', handles.SynchronisationPanel, ...
    'Style', 'popupmenu', ...
    'Units', 'Characters', ...
    'FontSize',        9, ...
    'BackgroundColor', bgColor,...
    'Position', [7*CharWide 0.3*CharHi 12*CharWide buttonHeight], ...
    'String', '1ms|2ms|5ms|10ms|20ms|25ms|50ms|100ms|200ms|250ms|0.5s|1.0s', ...
    'UserData', [1, 2, 5, 10, 20, 25, 50,100, 200, 250, 500, 1000], ...
    'Tag', 'SynchronisationPopup', ...
    'Enable','off', ...
    'Callback', ...
      'PsySoundGUI(''SynchronisationPopup_Callback'',gcbo,[],guidata(gcbo))');

set(handles.SettingsPanel(1),'Visible','on');

%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Post Processing UIPanel %
%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This is the overall panel
handles.OutputProcessingPanel = uicontainer( ...
    'Parent',          handles.figure1,                      ...
    'Units',           'Characters',                         ...
    'Position',        [3 6*CharHi 160*CharWide 42*CharHi],  ...
    'Tag',             'OutputProcessingPanel',              ...
    'Visible',         'off',                                ...
    'BackgroundColor', bgColor);

handles = PostPropGUI(handles);

%%%%%%%%%%%%
% Menu Bar %
%%%%%%%%%%%%

% File
handles.MenuBar = uimenu(handles.figure1, 'Label', 'File');
uimenu(handles.MenuBar,       ...
       'Label', 'Load files', ...
       'Callback', ...
       ['PsySoundGUI(''LoadFileSettings_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

uimenu(handles.MenuBar, ...
       'Label', 'Save files', ...
       'Callback', ...
       ['PsySoundGUI(''SaveFileSettings_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

uimenu(handles.MenuBar, ...
       'Label', 'Load project', ...
       'Separator', 'on', ...
       'Callback', ...
       ['PsySoundGUI(''LoadProject_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

uimenu(handles.MenuBar, ...
       'Label', 'Save project', ...
       'Callback', ...
       ['PsySoundGUI(''SaveProject_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

uimenu(handles.MenuBar, ...
       'Label', 'Preferences...', ...
       'Separator', 'on', ...
       'Callback', ...
       ['PsySoundGUI(''Preferences_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

% Analyser
handles.MenuBar = uimenu(handles.figure1, 'Label', 'Analyser');
uimenu(handles.MenuBar,       ...
       'Label', 'Load settings', ...
       'Callback', ...
       ['PsySoundGUI(''LoadAnalyserSettings_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

uimenu(handles.MenuBar,       ...
       'Label', 'Save settings', ...
       'Callback', ...
       ['PsySoundGUI(''SaveAnalyserSettings_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

% Help
handles.MenuBar = uimenu(handles.figure1,'Label','Help');
uimenu(handles.MenuBar, ...
       'Enable', 'off', ...
       'Label', 'Getting Started');
uimenu(handles.MenuBar, ...
       'Enable', 'off', ...
       'Label', 'Analyser Information');

uimenu(handles.MenuBar, ...
       'Label', 'About PsySound3...', ...
       'Separator', 'on', ...
       'Callback', ...
       ['PsySoundGUI(''About_Callback'',gcbo,[],' ...
        'guidata(gcbo))']);

% Make the first panel visible
handles.UiPanelNumber = 1;
DisplayUIPanel(handles);

% EOF
