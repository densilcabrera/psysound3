function handles = DisplayUIPanel(handles)
% DISPLAYUIPANEL 

% Buttons
hButtons = [handles.Files; ...
  handles.Calibration; ...
  handles.Analysers; ...
  handles.PostProcessing];

% Show only the step we're in
set(hButtons, 'Enable', 'on');
set(hButtons(handles.UiPanelNumber), 'Enable', 'off');

% Calibration handling
p = getPsysound3Prefs;
calibEnb = 'on';
if p.calibrationIndex{3}
  calibEnb = 'off';
end
% Disable if calibration with SPL is selected
set(handles.Calibration,      'Enable', calibEnb);
set(handles.CalibrationLabel, 'Enable', calibEnb);

switch (handles.UiPanelNumber)
 case {1}
  set(handles.AssistString,'String','Choose the files you would like to analyse from the box at the left and click add. To change the current directory, click the Change Dir button and choose a folder. ');
  set(handles.FileChoicePanel,'Visible','on');
  set(handles.CalPanel,'Visible','off');
  set(handles.AdjustmentPanel,'Visible','off');
  set(handles.AnalysisSetupPanel,'Visible','off');
  try
      set(handles.Table,'Visible',1);
  catch
      handles.mtable.setVisible(1);
  end       
  % Post-prop
  set(handles.PostPropPanel, 'Visible','off');
  set(handles.PostPropFileInfo, 'Visible','off');
  set(handles.PostPropTreeHead, 'Visible', 'off');
  handles.PostPropTree.Visible = 0;

 case {2}
  if strcmp(handles.calAnswer,'With Files')
    set(handles.AssistString,'String','To calibrate this analysis: select a calibration file from the box at the left; select whichever analysis files are to be calibrated on the right, and then click ''Associate File''. ');
    set(handles.FileChoicePanel,'Visible','off');
    set(handles.CalPanel,'Visible','on');
    set(handles.AdjustmentPanel,'Visible','off');
    set(handles.AnalysisSetupPanel,'Visible','off');
    handles.DataHeaders = {'Files','Cal. Files','Cal. Level'};
    try
      set(handles.Table,'Visible',1);
      setColumnNames(handles.Table,handles.DataHeaders);
      setColumnWidth(handles.Table,150);
    catch
      handles.mtable.setVisible(1);
      handles.mtable.setColumnNames(handles.DataHeaders);
      handles.mtable.setColumnWidth(150);
    end       

  elseif strcmp(handles.calAnswer,'Without Files')
    set(handles.AssistString,'String','Choose a method for setting the level of these files. If you do not wish to set the level chooose ''No Change'' and click Standardise. ');
    set(handles.FileChoicePanel,'Visible','off');
    set(handles.CalPanel,'Visible','off');
    set(handles.AdjustmentPanel,'Visible','on');
    set(handles.AnalysisSetupPanel,'Visible','off');
    handles.DataHeaders = {'Files','Adjustment','Level'};
    try
      set(handles.Table,'Visible',1);
      setColumnNames(handles.Table,handles.DataHeaders);
      setColumnWidth(handles.Table,150);
    catch
      handles.mtable.setVisible(1);
      handles.mtable.setColumnNames(handles.DataHeaders);
      handles.mtable.setColumnWidth(150);
    end       

    
    % Post-prop
    set(handles.PostPropPanel, 'Visible','off');
    set(handles.PostPropFileInfo, 'Visible','off');
    set(handles.PostPropTreeHead, 'Visible', 'off');
    handles.PostPropTree.Visible = 0;
  
  end
    case {3}
     set(handles.AssistString,'String','Set analysis settings for each of the Analysers. Click an analyser in the left hand column to display its settings. When you are ready to begin the analysis click the ''Run Analysis'' button.');
     set(handles.FileChoicePanel,'Visible','off');
     set(handles.CalPanel,'Visible','off');
     set(handles.AdjustmentPanel,'Visible','off');
     set(handles.AnalysisSetupPanel,'Visible','on');
     try
        set(handles.Table,'Visible',0);
     catch
        handles.mtable.setVisible(0);
     end       
     % Post-prop
     set(handles.PostPropPanel, 'Visible','off');
     set(handles.PostPropFileInfo, 'Visible','off');
     set(handles.PostPropTreeHead, 'Visible', 'off');
     handles.PostPropTree.Visible = 0;
     
 case {4}
  set(handles.AssistString,'String','Open the the tree nodes and click on data objects to select them. Each Data Analyser tab will have different commands available depending on which data objects you choose.');
  try
    set(handles.Table,'Visible',0);
  catch
    handles.mtable.setVisible(0);
  end       
  
  set(handles.FileChoicePanel,'Visible','off');
  set(handles.CalPanel,'Visible','off');
  set(handles.AdjustmentPanel,'Visible','off');
  set(handles.AnalysisSetupPanel,'Visible','off');
  
  % Post-prop
  set(handles.PostPropPanel, 'Visible','on');
  set(handles.PostPropFileInfo, 'Visible','on');
  set(handles.PostPropTreeHead, 'Visible', 'on');
  handles.PostPropTree.Visible = 1;
end


