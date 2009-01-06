function handles = changeSelectedFiles(handles, varargin)
%% displays the Selected Files based on the information in handles.
%
% Controls the main table (handles.Table) and the calibration files list
% box (handles.CalFilesLeft). The display is simply updated with the 
% current data, changing the actual data is done in the original 
% callbacks that call this file. 

str = '';
if nargin > 1
  str = varargin{1};
end

% Prune the list of already selected files from appearing in the
% calibration list
handles = fixUpCalFilesList(handles);

% Create the Data model
handles = createDataTable(handles);

% Update the table
handles = updateFilesTable(handles);

% Empty out the filehandles' cache - force recalibration
handles.fileHandles = [];

% end changeSelectedFiles

%%%%%%%%%%%%%%%%%%%
% Local functions %
%%%%%%%%%%%%%%%%%%%

%
% fixUpCalFilesList
%
function handles = fixUpCalFilesList(handles)


handles.CalibrationFiles = 1:length(handles.FilesInDir);
for i = 1:length(handles.FilesInDir)
  CalFiles{i} = handles.FilesInDir(i).name;
end

if exist('CalFiles')
  set(handles.CalFilesLeft,'String',CalFiles);
  if isempty(get(handles.CalFilesLeft,'Value'))
    set(handles.CalFilesLeft,'Value',1);
  end
end

% end fixUpCalFilesList

%
% createDataTable
%
function handles = createDataTable(handles)

fid = handles.FilesInDir;

handles.Data = [];
if isfield(handles, 'calAnswer')
  if strcmp(handles.calAnswer, 'Without Files')
    % Used if the calibration system is offsets.
    handles.Data = [];
    for i = 1:length(handles.SelectedFiles)
      handles.Data{i,1} = fid(handles.SelectedFiles(i)).name;
      try
        handles.Data{i,2} = fid(handles.SelectedFiles(i)).Level;
      catch
        handles.Data{i,2} = '';
      end
      try
        handles.Data{i,3} = fid(handles.SelectedFiles(i)).Adjustment;
      catch
        handles.Data{i,3} = '';
      end
    end
    %        handles.DataHeaders = {'Files','SPL (dB)','Adjustment'};
  elseif strcmp(handles.calAnswer,'With Files')
    % Used if the calibration system is with calibration files rather
    % than offsets.
    for i = 1:length(handles.SelectedFiles)
      handles.Data{i,1} = fid(handles.SelectedFiles(i)).name;
      try
        handles.Data{i,2} = fid(fid(handles.SelectedFiles(i)).CalFile).name;
      catch
        handles.Data{i,2} = '';
      end
      try
        handles.Data{i,3} = char(fid(handles.SelectedFiles(i)).CalFileLevel);
      catch
        handles.Data{i,3} = '';
      end
    end
  end
else
  % loop through FilesInDir adding to Data
  for i = 1:length(handles.SelectedFiles)
    handles.Data{i,1} = fid(handles.SelectedFiles(i)).name;
  end
  %handles.DataHeaders = {'Files'};
end

% end createDataTable

% EOF
