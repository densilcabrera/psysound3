function collapseAndUnLoadTree(obj, panel)
% COLLAPSEANDUNLOADTREE  Collapses and unloads tree so that
%                        subsequent expansion results in new
%                        files/nodes being picked up
%
uit = getTree(obj, panel);
selPath = uit.Tree.getSelectionPath;
uit.Tree.collapseRow(0);
setLoaded(uit, uit.getRoot, false);
drawnow;
uit.Tree.expandRow(0);
drawnow;

% EOF


%
% Tree expand fcn
%
function nodes = treeExpfcn(tree, value)
  
  psyIconDir = [getPsySoundDir, filesep, 'GUI/icons'];
  
  % Value should be a directory
  if exist(value, 'dir') == 7
    
    % Load the dataStorage object
    dataInfoFname = fullfile(value, filesep, 'dataInfo.mat');
    if exist(dataInfoFname, 'file')
      S =load(dataInfoFname);

      defaultContextMenu = createDefaultPopup;
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
          ctxMenu  = createAudioTSeriesPopup(fullfile(fullName, dsNode.name));
         
         case 'AudioTSeries'
          iconpath = [psyIconDir, filesep, 'mnote12.png'];
          ctxMenu  = createAudioTSeriesPopup(fullName);
        
          
         otherwise
          % Don't know so just whack in a page
          iconpath = [psyIconDir, filesep, 'pageicon.gif'];
        end
        
        % Stick the full file name as the value
        nodes(i) = uitreenode(fullName,        ...
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

% Note about context menus:
%   Right now there is only a single default menu but an instance
%   each for all AudioTSeries.  To create custom ones follow this
%   example
%