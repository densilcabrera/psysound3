function handles = PostPropGUI_R2008b(handles, varargin)
% POSTPROPGUI  Sets up the Post-processing Panel
%
import javax.swing.tree.*;

if nargin > 1
  % We want to reset the tree
  if varargin{1} == 1
    theTree  = handles.PostPropTree;
    rootNode = theTree.getRoot;
    
    % Collapse the root node and set the loaded flag to false so
    % that the expansion callback is triggered
    theTree.Tree.collapseRow(0);
    theTree.setLoaded(rootNode, 0);

    % Expand the first level
    theTree.Tree.expandRow(0);
    
    return;
  end
end
  
h = handles.figure1;
psyPrefs = getPsysound3Prefs;
dataDir  = psyPrefs.dataDir;

bgColor = [0.9 0.9 0.9];

% Create the root node
root = uitreenode('v0',dataDir, 'PsySoundData', [], false);
% treeModel = DefaultTreeModel(root);

% Create the tree and set some properties
uit = uitree('v0',h, 'Root', root, 'ExpandFcn', @treeExpfcn,'position',[10 100 300 440]);
% uit.Units = 'normalized';
% uit.Position = [0.02 0.15 0.3 0.78];
uit.MultipleSelectionEnabled = 1;
uit.NodeSelectedCallback = @updateDataAnalyser;
% uit.Visible = 0;
% uit.setModel(treeModel);

 % Add mouse clicked
set(uit.tree, 'MouseClickedCallback', {@mouse_click_cb, uit});

uitHead = uicontrol('Parent', h, ...
                    'Style' , 'text', ...
                    'FontSize', 9, ...
                    'String', 'Result nodes (click on plus sign to expand):', ...
                    'units', 'normalized' ,...
                    'BackGroundColor', bgColor, ...              
                    'HorizontalAlignment', 'left', ...
                    'Position', [0.02 0.95 0.3 0.02]);


handles.PostPropTree     = uit;
handles.PostPropTreeHead = uitHead;

% Add file info panel
% handles.PostPropFileInfo = addPostPropFileInfo(h, bgColor);
handles.PostPropFileInfo = [];

% tabs
utg = uitabgroup('v0','Parent', h, ...
                 'BackGroundColor', bgColor, ...
                 'UserData', uit, ...
                 'Units', 'normalized', ...
                 'Position', [1/3 0.15 1-(1/3)-0.02, 0.8]);

% Cache the tab group handle on the tree
prop = schema.prop(uit, 'uitabgroup', 'mxArray');
uit.uitabgroup = utg;

% See comments in function for more info
set(utg, 'SelectionChangeFcn', @uitabCallback);

% ... and the file info panel
%prop = schema.prop(uit, 'fileInfo', 'mxArray');
%uit.fileInfo = handles.PostPropFileInfo;

% Cache handle xxx
handles.PostPropPanel = utg;

% These are the Group names of the tabs
tabStrs = { ...
    'Summary', ...
    'Visualisation', ...
    'Sonification',  ...
    'Statistics',    ...
    'Data Export',   ...
    'Data Analysis'};

% Get the list of all the data Analysers
dAnalysers = getDataAnalysers;

for i=1:length(tabStrs);
  group = tabStrs{i};
  
  % Create a tab for this group
  utb = uitab('v0','Parent', utg, ...
              'title',  group);
  
  dAObjs         = {};
  dAforThisGroup = {};
  dAHandles      = [];
  firstPanel     = true;
  
  % Populate this group with all of its data analysers
  for j=1:length(dAnalysers)
    % Instantiate an object
    dAObj = eval(dAnalysers{j});
    
    if strcmp(dAObj.Group, group)
      % Create the two panels
      panel = uipanel('Parent', utb, ...
                      'units', 'normalized', ...
                      'BackGroundColor', bgColor, ...              
                      'Visible', 'off', ...
                      'Position', [0.01 0.01 0.98 0.92]);

      if firstPanel
        set(panel, 'Visible', 'on');
        firstPanel = false;
      end
      
      % Add description
      uicontrol('Parent', panel, ...
                'Style' , 'text', ...
                'FontSize', 9, ...
                'String', getDescription(dAObj), ...
                'units', 'normalized' ,...
                'BackGroundColor', bgColor, ...              
                'Tag', 'Description', ...
                'HorizontalAlignment', 'left', ...
                'Position', [0.03 0.9 0.95 0.06]);
      
      % Call its ui method to populate any GUI items
      dAObj = ui(dAObj, panel);
      
      % Keep a running list for the popup
      dAforThisGroup{end+1} = dAObj.name;
      
      % Also keep track of the panel handles and data analyser objects
      dAHandles(end+1) = panel;
      dAObjs{end+1}    = dAObj;
    end
  end
  
  % Add popup
  en = 'on';
  if isempty(dAforThisGroup)
    en = 'off';
    dAforThisGroup = ' ';
  end
  
  % Create struct for user data
  ud.PanelHandles = dAHandles;
  ud.DataObjs     = dAObjs;
  ud.Tree         = uit;
  
  pH = uicontrol('Parent', utb, ...
                 'Style', 'popup', ...
                 'String', dAforThisGroup, ...
                 'Enable', en, ...
                 'units', 'normalized', ...
                 'UserData', ud, ...
                 'BackGroundColor', bgColor, ...              
                 'Tag',     'DataAnalyserPopup', ...
                 'Callback', @popupCallback, ...
                 'Position', [0.01 4/5 1/3 1/5]);
  
  % Cache the popup handle onto the uitab
  set(utb, 'UserData', pH);
end

% Expand the first level
uit.Tree.expandRow(0);
    
% For some reason, lumping this above does not seem to work?
set(utg, 'Visible', 'off');



% 
%           
% b1 = uicontrol('Parent', h, 'string','add Node', ...
% 'units' , 'normalized', ...
% 'position', [0.5 0.5 0.2 0.2], ...
% 'callback', {@b1_cb, uit} ...
% );
% 
% b2 = uicontrol('Parent', h, 'string','remove Node', ...
% 'units' , 'normalized', ...
% 'position', [0.75 0.5 0.2 0.2], ...
% 'callback', {@b2_cb, uit} ...
% );
% 
% 

end % PostPropGUI




%%%%%%%%%%%%%%%%
% Subfunctions %
%%%%%%%%%%%%%%%%
%
% popupCallback.  Controls panels for data Analyser with a tab
%
function popupCallback(hObj, varargin)
  
  % Early return if not enabled
  enab = get(hObj, 'Enable');
  if strcmp(enab, 'off')
    return;
  end
  
  ud      = get(hObj, 'UserData');
  handles = ud.PanelHandles;
  value   = get(hObj, 'Value');
  
  % First turn them all off
  set(handles, 'Visible', 'off');
  
  % Then just show the current one
  set(handles(value), 'Visible', 'on');

  % Run the update function
  updateDataAnalyser(ud.Tree, []);

  % Execute any embedded callbacks - I think this will be needed
  %                                   for uitables
  cb = get(handles(value), 'UserData');
  if isa(cb, 'function_handle')
    cb();
  end
  
end % popupCallback

%
% uitabCallback. Normally, the visibility of tabs is controlled by
%                uitabgroup, however, uitables do not seem (this
%                may change in a future version of Matlab) to
%                honour the panel visibility settings that they are
%                a part of.  Adding a function handle to execute at
%                popupCallback fixes this for the case when
%                different selections are made from the pull-down
%                but not the very first time around.  Hence this
%                exists to force the callback
%
function uitabCallback(src, ev)
  
  ch  = get(src, 'Children');
  idOld = ev.OldValue;
  idNew = ev.NewValue;
  
  % Skip 0
  if idOld
    pH = findobj(ch(idOld), ...
                 'Tag',   'DataAnalyserPopup', ...
                 'Style', 'popup');
    
    % Run the Old callback
    cb = get(pH, 'Callback');
    cb(pH);
  end
  
  % Run new
  pH = findobj(ch(idNew), ...
               'Tag',   'DataAnalyserPopup', ...
               'Style', 'popup');
  cb = get(pH, 'Callback');
  cb(pH);

  % The following line ensures that the selections are updated for
  % the currently selected node
  uit = get(src, 'UserData');   % tree
  updateDataAnalyser(uit, []); % second argument is unused
  
end % popupCallback



%
% updateDataAnalyser : Node selection callback.
%
% Basically dispatches off to whatever is the current data analyser
function updateDataAnalyser(tree, value, varargin)

  doubleClick = false;
  if ~isempty(varargin)
    doubleClick = true;
  end
    
  % This is the uitab group
  utg = tree.uitabgroup;

  % Get the tabs
  tabs = get(utg, 'Children');
  ind  = get(utg, 'SelectedIndex');
  
  % Get the handle to the data Analyser popup
  pH = get(tabs(ind), 'UserData');

  if strcmp(get(pH, 'Enable'), 'on')
    val = get(pH, 'Value');
    
    % Get the UserData struct
    ud = get(pH, 'UserData');
    
    obj = ud.DataObjs{val};
    h   = ud.PanelHandles(val);
    
    if doubleClick
      % Execute the double click method, if it exists
      % Note: Because of the NodeSelectedCallback we would've
      % already executed updateDataAnalyserPanel, below
      execDoubleClick(obj, h);
    else
      % Execute the updateDataAnalyserPanel method
      updateDataAnalyserPanel(obj, h);
    end
    
  end
  
end % updateDataAnalyser

%
% Tree expand fcn
%
function nodes = treeExpfcn(tree, value)
  
  psyIconDir = [getPsySoundDir, filesep, 'Framework/GUI/icons'];
  
  % Value should be a directory
  if exist(value, 'dir') == 7
    
    % Load the dataStorage object
    dataInfoFname = fullfile(value, filesep, 'dataInfo.mat');
    if exist(dataInfoFname, 'file')
      S = load(dataInfoFname);

      defaultContextMenu = createDefaultPopup(tree);
      for i=1:getNumChildren(S.dsArr)
        dsNode   = S.dsArr(i);
        nodeType = dsNode.nodeType;
        fullName = fullfile(value, filesep, dsNode.filename);
        ctxMenu  = defaultContextMenu;
  
        if strcmp(nodeType, 'AudioFileFolder')
          nodeType = 'BaseAudioTSeries';
        end
        
        if ~isempty(findstr(nodeType, 'Folder'))
          nodeType = 'Folder';
        end
        
        switch nodeType
         case 'Folder'
          iconpath = [psyIconDir, filesep, 'foldericon.gif'];
          
          % The data objects
         case 'Spectrum'
          iconpath = [psyIconDir, filesep, 'Spec.gif'];
          
         case 'tSpectrum'
          iconpath = [psyIconDir, filesep, 'tSpec.gif'];
          
         case 'tSeries'
          iconpath = [psyIconDir, filesep, 'tSeries.gif'];
          
         case 'BaseAudioTSeries'
          iconpath = [psyIconDir, filesep, 'mnote12.png'];
          ctxMenu  = createAudioTSeriesPopup(fullfile(fullName, dsNode.name), tree);
         
         case 'AudioTSeries'
          iconpath = [psyIconDir, filesep, 'mnote12.png'];
          ctxMenu  = createAudioTSeriesPopup(fullName, tree);
        
          
         otherwise
          % Don't know so just whack in a page
          iconpath = [psyIconDir, filesep, 'pageicon.gif'];
        end
        
        % Stick the full file name as the value
        nodes(i) = uitreenode('v0',fullName,        ...
                              dsNode.name,     ...
                              iconpath,        ...
                              dsNode.isLeaf);

        % Add menu as a property
        setUserObject(nodes(i), ctxMenu);
      end
    else
      nodes = [];
    end
  else
    % Return empty so that no error is generated
    nodes = [];
  end
end

% Note about context menus:
%   Right now there is only a single default menu but an instance
%   each for all AudioTSeries.  To create custom ones follow this
%   example
%


%
% Functions to do with context menus
%
function out = createAudioTSeriesPopup(fName,tree)
  contextMenu = javax.swing.JPopupMenu;
  
  % Define the context menu items
  item1 = javax.swing.JMenuItem('Play audio');
  item2 = javax.swing.JMenuItem('Export audio');
  
  % Add callback
  set(item1, 'ActionPerformedCallback', {@playAudio, fName});
  set(item2, 'ActionPerformedCallback', {@exportAudio, fName})
  % Add item to menu
  contextMenu.add(item1);
  contextMenu.add(item2);
  
  playObj = [];
  function playAudio(src, ev, fName)
    if isempty(playObj)
      D  = load(fName);
      CB.stopFcn = @(a_src, a_ev)set(src, 'Text', 'Play audio');
      playObj = createPlayerObj(D.dataObjS.DataObj, CB);
      set(src, 'Text', 'Stop audio');
      play(playObj);
    else
      stop(playObj);
      playObj  = [];
    end
  end

  function exportAudio(src, ev, fName)
	D = load(fName);
		[filename,dirname,filterindex] = uiputfile({'*.wav','Save as .wav file';'*.aif','Save as .aif file'});
		if filterindex == 1
			if isempty(strfind(filename,'.wav'))
				filename = strcat(filename,'.wav');
			end
			wavwrite(D.dataObjS.DataObj.data,D.dataObjS.DataObj.Fs,fullfile(dirname,filename));
		elseif filterindex == 2
			if isempty(strfind(filename,'.aif'))
				filename = strcat(filename,'.aif');
			end
			aiffwrite(D.dataObjS.DataObj.data,D.dataObjS.DataObj.Fs,fullfile(dirname,filename));
		else
			return
    end
  end  

  out = contextMenu;
end

% Creates a default disabled context menu
function out = createDefaultPopup(tree)
  
  
  menu = javax.swing.JPopupMenu;
  
  % Define the context menu items
  item1 = javax.swing.JMenuItem('Delete this node');
  set(item1, 'ActionPerformedCallback', {@removeCurrentNode, tree});
  

  
  function removeCurrentNode(src, ev, uit)
  % Nested function for removing nodes that are not wanted.

    nodes = uit.getSelectedNodes;
    node = nodes(1); % One at a time
    % get filesystem path from node
    pathDsArr = fileparts(getValue(node));
    % Get node structure within this path from dataInfo.mat
    dsArr = getDataStorageArrObj(pathDsArr);
    % Loop through to match node and remove
    for i = 1:getNumChildren(dsArr)
      if strcmp(getName(node),dsArr(i).name)
        
        if ~dsArr(i).isLeaf % This means it's a folder (or possibly both a file and folder)
          % Sometimes there is a file AND a folder so delete file if it
          % exists
          fn = fullfile(pathDsArr,[dsArr(i).filename '.mat']);
          if exist(fn,'file') 
            delete(fn);
          end
          dn = fullfile(pathDsArr,dsArr(i).filename);
          rmdir(dn,'s') % Delete directory and subdirectory tree
        else % It's just a file
          fn = fullfile(pathDsArr,[dsArr(i).filename '.mat']);
          delete(fn);
        end
        dsArr = removeNode(dsArr,i);
        break
      end
    end
    % Save resulting data Array.
    saveDataStorageArrObj(pathDsArr, dsArr);
    
    % Now update the uitree by removing the node
    treeModel = uit.getModel;
    if ~node.isRoot
      nP = node.getPreviousSibling;
      nN = node.getNextSibling;
      if ~isempty( nN )
        uit.setSelectedNode( nN );
      elseif ~isempty( nP )
        uit.setSelectedNode( nP );
      else
        uit.setSelectedNode( node.getParent );
      end
      treeModel.removeNodeFromParent( node );
    end

  end
  % Add item to menu and assign output
  menu.add(item1);
  
  out = menu;
end

%
% addPostPropFileInfo
%
function panel = addPostPropFileInfo(h, bgColor)
  panel = uipanel('Parent', h, ...
                  'Title', 'Info', ...
                  'FontSize', 9, ...
                  'Units', 'Normalized',...
                  'Position', [0.02 0.15 0.3 0.2], ...
                  'Tag', 'FileInfoPanel', ...
                  'Visible', 'on', ...
                  'BackgroundColor', bgColor);
  
  % Text labels
  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [1 0.5 18 1], ...
            'String', 'Date modified :', ...
            'HorizontalAlignment', 'Right', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [1 1.5 18 1], ...
            'String', 'Derived from:', ...
            'HorizontalAlignment', 'Right', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [1 2.5 18 1], ...
            'String', 'Overlap :', ...
            'HorizontalAlignment', 'Right', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [1 3.5 18 1], ...
            'String', 'Window function:', ...
            'HorizontalAlignment', 'Right', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [1 4.5 18 1], ...
            'String', 'Window length :', ...
            'HorizontalAlignment', 'Right', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [1 5.5 18 1], ...
            'String', 'Audio file name :', ...
            'HorizontalAlignment', 'Right', ...
            'BackgroundColor', bgColor);

  % Text editted
  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [20 0.5 18 1], ...
            'Tag', 'DateModified', ...
            'HorizontalAlignment', 'Left', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [20 1.5 18 1], ...
            'Tag', 'DerivedFrom', ...
            'HorizontalAlignment', 'Left', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [20 2.5 18 1], ...
            'Tag', 'Overlap', ...
            'HorizontalAlignment', 'Left', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [20 3.5 18 1], ...
            'Tag', 'WindowFunction', ...
            'HorizontalAlignment', 'Left', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [20 4.5 18 1], ...
            'Tag', 'WindowLength', ...
            'HorizontalAlignment', 'Left', ...
            'BackgroundColor', bgColor);

  uicontrol('Parent', panel, ...
            'Style', 'text', ...
            'FontSize', 9, ...
            'Units', 'Characters',...
            'Position', [20 5.5 18 1], ...
            'Tag', 'AudioFileName', ...
            'HorizontalAlignment', 'Left', ...
            'BackgroundColor', bgColor);
end % addPostPropFileInfo

%
% Mouse click handler
%
function mouse_click_cb(h, ev, tree)
  T = tree.tree;

  % Right click or Ctrl Click works
  if ev.getModifiers() == ev.META_MASK || ev.getModifiers() == (ev.BUTTON1_MASK + ev.CTRL_MASK) 
    
    % Figure out which node this is
    nodes = T.getPathForLocation(ev.getX, ev.getY).getPath();

    % Right-click
    popup = getUserObject(nodes(end));
    if ~isempty(popup)
      popup.show(T, ev.getX, ev.getY);
      popup.repaint;
    end
  elseif ev.getButton() == 1 && ev.getClickCount == 2
    % Double-click
    try
      nodes = T.getPathForLocation(ev.getX, ev.getY).getPath();
      updateDataAnalyser(tree, nodes(end), 1);
    catch 
    end
  end
end % mouse_click_cb



% [EOF]
